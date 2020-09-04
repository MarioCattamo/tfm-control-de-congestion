#!/usr/bin/env bash

# ANALYSIS-3.SH
# Replica de la segunda version del fichero para  iniciar descarga C1<--S1 con LEDBAT
# Ejemplo de ejecucion desde C1: ./individual-analysis-3.sh short|long

echo 'Generating LEDBAT download C1<--S1 for later analysis...'
LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-ind-3-ledbat
MY_BURST="2250" # No disminuir este valor en bytes
R_QUEUE_LENGTH="50ms"
S_QUEUE_LENGTH="1000ms"
MY_BW="1mbit"

if [ $# -ge 2 ]
then
	echo 'too many arguments...'
	exit
fi

if [ -z $1 ]
then
	MY_DELAY="10ms"
	echo 'delay is: '$MY_DELAY
else
	if [ $1 = 'long' ]
	then
		MY_DELAY="200ms"
		echo 'delay is: '$MY_DELAY
	else
		if [ $1 = 'short' ]
		then
			MY_DELAY="10ms"
			echo 'delay is: '$MY_DELAY	
		else
			MY_DELAY="10ms"
			echo 'Bad argument, configured default delay is: '$MY_DELAY
		fi
	fi
fi

echo 'File name is: '$FILE_NAME

sudo pkill nc
sudo pkill dd
sudo pkill scp
sudo pkill tcpdump
sudo pkill ping
sudo tc -p qdisc ls dev eth0

# Conexion a R1
echo 'entrando a R1...'
ssh R1 "echo it | sudo -S pkill tcpdump"
ssh R1 "echo it | sudo -S tc qdisc replace dev eth1 root netem delay $MY_DELAY"
ssh R1 "echo it | sudo -S tc -p qdisc ls dev eth1"

# Conexion a R2
echo 'entrando a R2...'
ssh R2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $R_QUEUE_LENGTH burst $MY_BURST"
ssh R2 "echo it | sudo -S tc -p qdisc ls dev eth0"
#
# Conexion a S1
echo 'entrando a S1...'
ssh S1 "echo it | sudo -S pkill dd"
ssh S1 "echo it | sudo -S pkill nc"
#ssh S1 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $S_QUEUE_LENGTH burst $MY_BURST"
ssh S1 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a R1
echo 'Capturando en R1...'
ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME.pcap" &

echo 'Ejecutando en S1 tcpprobe...'
ssh S1 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME.dat > /dev/null 2>&1" &
echo 'Listening in S1 port 80...'
ssh S1 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 80 2>&1 &" &

sleep 15

# Conexion a C1
echo 'Starting download C1:49000<--S1:80...'
nc -dp 49000 S1 80 > /dev/null &

sleep 300

echo 'Deteneniendo tcpprobe...'
ssh S1 "echo it | sudo -S pkill dd"
ssh S1 "echo it | sudo -S pkill nc"

echo 'Deteniendo netcat en C1...'
sudo -S pkill dd
sudo -S pkill nc

echo 'Deteneniendo captura en R1' 
ssh R1 "echo it | sudo -S pkill tcpdump"

echo 'Copiando .dat C1<--S1'
ssh -t S1 "echo it | sudo -S scp /tmp/$FILE_NAME.dat ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Copiando pcap C1<--R1'
ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME.pcap ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Local captures folder is:'$LOCAL_CAPTURES
echo '...'
echo 'File name is:'$FILE_NAME
echo 'FIN de generacion de capturas...'
