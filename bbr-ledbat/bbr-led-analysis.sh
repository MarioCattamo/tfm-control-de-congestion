#!/usr/bin/env bash

# Conjunto de comandos para iniciar descarga C2<--S2 con LEDBAT
# y para iniciar descarga C1<--S1 con BBR
# Ejemplo de ejecucion desde C1: ./bbr-led-analysis.sh [short|long]
# [short|long] define si el delay en C2 eth0 y R1 eth1 simula una Short-RTT Network o Long-RTT network respectivamente
# Si el argumento opcional [short|long] no se especifica, por defecto se configura como short

echo 'Generating LEDBAT download C2<--S2 for later analysis...'
echo 'Generating BBR download C1<--S1 for later analysis...'
LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-bbr-ledbat
MY_BURST="2250" # No disminuir este valor en bytes
R_QUEUE_LENGTH="200ms"
S_QUEUE_LENGTH="1000ms"
MY_BW="2mbit"

if [ $# -ge 2 ]
then
	echo 'too many arguments...'
	exit
fi

if [ -z $1 ]
then
	MY_DELAY="25ms"
	echo 'delay is: '$MY_DELAY
else
	if [ $1 = 'long' ]
	then
		MY_DELAY="100ms"
		echo 'delay is: '$MY_DELAY
	else
		if [ $1 = 'short' ]
		then
			MY_DELAY="25ms"
			echo 'delay is: '$MY_DELAY	
		else
			MY_DELAY="25ms"
			echo 'Bad argument, configured default delay is: '$MY_DELAY
		fi
	fi
fi

echo 'File name is: '$FILE_NAME

echo 'En C1...'
sudo pkill nc
sudo pkill dd
sudo pkill scp
sudo pkill tcpdump
sudo pkill ping
tc qdisc del dev eth0 root
tc qdisc replace dev eth0 root netem delay $MY_DELAY
tc -p qdisc ls dev eth0

echo 'Entering to C2...'
ssh C2 "echo it | sudo -S pkill nc"
ssh C2 "echo it | sudo -S pkill dd"
ssh C2 "echo it | sudo -S pkill scp"
ssh C2 "echo it | sudo -S pkill tcpdump"
ssh C2 "echo it | sudo -S pkill ping"
ssh C2 "echo it | sudo -S tc qdisc del dev eth0 root"
ssh C2 "echo it | sudo -S tc qdisc replace dev eth0 root netem delay $MY_DELAY"
ssh C2 "echo it | sudo -S tc -p qdisc ls dev eth0"
ssh C2 "cd ~/SRC/; sudo ./install_rledbat.sh"

# Conexion a R1
echo 'entrando a R1...'
ssh R1 "echo it | sudo -S pkill tcpdump"
ssh R1 "echo it | sudo -S tc qdisc del dev eth1 root"
ssh R1 "echo it | sudo -S tc qdisc replace dev eth1 root netem delay $MY_DELAY"
ssh R1 "echo it | sudo -S tc -p qdisc ls dev eth1"

# Conexion a R2
echo 'entrando a R2...'
ssh R2 "echo it | sudo -S tc qdisc del dev eth0 root"
ssh R2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $R_QUEUE_LENGTH burst $MY_BURST"
ssh R2 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a S1
echo 'Entering to S1...'
ssh S1 "echo it | sudo -S pkill nc"
ssh S1 "echo it | sudo -S pkill dd"
ssh S1 "echo it | sudo -S pkill scp"
ssh S1 "echo it | sudo -S pkill tcpdump"
ssh S1 "echo it | sudo -S pkill ping"
ssh S1 "echo it | sudo -S tc qdisc del dev eth0 root"
ssh S1 "echo it | sudo -S tc qdisc replace dev eth0 root netem delay $MY_DELAY"
ssh S1 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a S2
echo 'entrando a S2...'
ssh S2 "echo it | sudo -S pkill dd"
ssh S2 "echo it | sudo -S pkill nc"
ssh S2 "echo it | sudo -S pkill scp"
ssh S2 "echo it | sudo -S pkill tcpdump"
ssh S2 "echo it | sudo -S tc qdisc del dev eth0 root"
ssh S2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $S_QUEUE_LENGTH burst $MY_BURST"
ssh S2 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a R1
echo 'Capturando en R1...'
ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME.pcap" &

# Conexion a S2
echo 'Listening in S2 port 80...'
ssh S2 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 80 2>&1 &" &

sleep 15

# Iniciando descarga C2<--S2
echo 'Starting download C2:49000<--S2:80...'
ssh C2 "nc -dp 49000 S2 80 > /dev/null &"

# Iniciando descarga C1<--S1
echo 'Executing tcpprobe in S1...'
ssh S1 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME.dat > /dev/null 2>&1" &
ssh -t S1 "echo it | sudo -S scp Documents/100325165/dummy-ping.pcap ledbat@C1:/home/ledbat/Documents/100325165"
sleep 10 # Suficiente para notar como se recupera LEDBAT luego de que finaliza la descarga de CUBIC

echo 'Deteneniendo netcat en S2...'
ssh S2 "echo it | sudo -S pkill dd"
ssh S2 "echo it | sudo -S pkill nc"

echo 'Deteniendo netcat en C2...'
ssh C2 "echo it | sudo -S pkill dd"
ssh C2 "echo it | sudo -S pkill nc"

echo 'Deteniendo dd en S1...'
ssh S1 "echo it | sudo -S pkill dd"

echo 'Deteneniendo captura en R1' 
ssh R1 "echo it | sudo -S pkill tcpdump"

echo 'Copiando .dat C1<--S1'
ssh -t S1 "echo it | sudo -S scp /tmp/$FILE_NAME.dat ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Copiando Kernel log...'
ssh -t C2 "echo it | sudo -S scp /var/log/kern.log ledbat@C1:/home/ledbat/Documents/100325165/$FILE_NAME.log"

echo 'Copiando pcap C1<--R1'
ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME.pcap ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Local captures folder is:'$LOCAL_CAPTURES
echo '...'
echo 'File name is:'$FILE_NAME
echo 'FIN de generacion de capturas...'
