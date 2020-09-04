#!/usr/bin/env bash

# ANALYSIS-2.SH  
# Conjunto de comandos para iniciar descarga C2<--S2 con LEDBAT
# Ejemplo de ejecucion desde C1: ./individual-analysis-2.sh [short|long]

echo 'Generating LEDBAT download C2<--S2 for later analysis...'
LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-ind-2-ledbat
MY_BURST="2250" # No disminuir este valor en bytes
R_QUEUE_LENGTH="200ms"
S_QUEUE_LENGTH="1000ms"
MY_BW="1mbit"

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

# Conexion a S2
echo 'entrando a S2...'
ssh S2 "echo it | sudo -S pkill dd"
ssh S2 "echo it | sudo -S pkill nc"
ssh S2 "echo it | sudo -S tc qdisc del dev eth0 root"
ssh S2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $S_QUEUE_LENGTH burst $MY_BURST"
ssh S2 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a R1
echo 'Capturando en R1...'
ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME.pcap" &

echo 'Listening in S2 port 80...'
ssh S2 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 80 2>&1 &" &

sleep 15

# Conexion a C2
echo 'Starting download C2:49000<--S2:80...'
ssh C2 "nc -dp 49000 S2 80 > /dev/null &"

sleep 300

echo 'Deteneniendo netcat en S2...'
ssh S2 "echo it | sudo -S pkill dd"
ssh S2 "echo it | sudo -S pkill nc"

echo 'Deteniendo netcat en C2...'
ssh C2 "echo it | sudo -S pkill dd"
ssh C2 "echo it | sudo -S pkill nc"

echo 'Deteneniendo captura en R1' 
ssh R1 "echo it | sudo -S pkill tcpdump"

echo 'Copiando Kernel log...'
ssh -t C2 "echo it | sudo -S scp /var/log/kern.log ledbat@C1:/home/ledbat/Documents/100325165" 

echo 'Copiando pcap C1<--R1'
ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME.pcap ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Local captures folder is:'$LOCAL_CAPTURES
echo '...'
echo 'File name is:'$FILE_NAME
echo 'FIN de generacion de capturas...'
