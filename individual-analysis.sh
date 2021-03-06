#!/usr/bin/env bash

# 06/08/2020
# Generacion de capturas para mecanismo de control de congestion individual
# Ejemplo de ejecucion: ./individual-analysis.sh [short|long] mechanism
LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-ind-1
MY_BURST="2250" # No disminuir este valor en bytes 2250
R_QUEUE_LENGTH="200ms"
S_QUEUE_LENGTH="1000ms"
MY_BW="1mbit"

echo 'File name is: '$FILE_NAME

if [ $# -ge 3 ]
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

if [ -z $2 ]
then
	MECHANISM="cubic"
	echo 'Default mechanism selected: '$MECHANISM
else
	if [ $2 = 'cubic' ]
	then
		MECHANISM=$2
		echo 'Selected mechanism: '$MECHANISM
	else
		if [ $2 = 'bbr' ]
		then
			MECHANISM=$2
			echo 'Selected mechanism: '$MECHANISM
		else
			MECHANISM="cubic"
			echo 'Bad argument, default mechanism selected: CUBIC'
		fi
	fi

fi

echo 'En C1...'
sudo pkill nc
sudo pkill dd
sudo pkill scp
sudo pkill tcpdump
sudo pkill ping
tc qdisc del dev eth0 root
tc qdisc replace dev eth0 root netem delay $MY_DELAY
tc -p qdisc ls dev eth0

# Conexion a R1
echo 'Entering to R1...'
ssh R1 "echo it | sudo -S pkill tcpdump"
ssh R1 "echo it | sudo -S tc qdisc del dev eth1 root"
ssh R1 "echo it | sudo -S tc qdisc replace dev eth1 root netem delay $MY_DELAY"
ssh R1 "echo it | sudo -S tc -p qdisc ls dev eth1"

# Conexion a R2
echo 'Entering to R2...'
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
ssh S1 "echo it | sudo -S tc -p qdisc ls dev eth0"

# Conexion a R1
echo 'Starting capture in R1...'
ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME-$MECHANISM.pcap" &

# Conexion a S1
echo 'Executing tcpprobe in S1...'
ssh S1 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME-$MECHANISM.dat > /dev/null 2>&1" &
ssh -t S1 "echo it | sudo -S scp Documents/100325165/dummy-ping.pcap ledbat@C1:/home/ledbat/Documents/100325165"

sleep 10

echo 'Stopping tcpprobe in S1...'
ssh S1 "echo it | sudo -S pkill dd"

echo 'Stopping capture in R1' 
ssh R1 "echo it | sudo -S pkill tcpdump"

echo 'Copying .dat file C1<--S1'
ssh -t S1 "echo it | sudo -S scp /tmp/$FILE_NAME-$MECHANISM.dat ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Copyng .pcap file C1<--R1'
ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME-$MECHANISM.pcap ledbat@C1:/home/ledbat/Documents/100325165"

echo 'Local captures folder is:'$LOCAL_CAPTURES
echo 'File name is:'$FILE_NAME'-'$MECHANISM
echo 'Captures generation ended...'
