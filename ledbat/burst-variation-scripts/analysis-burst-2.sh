#!/usr/bin/env bash

# 06/08/2020
# Generacion de capturas para mecanismo de control de congestion individual
# Ejecucion para LEDBAT desde C1
# Ejemplo de ejecucion: ./analysis-burst short|long
LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-burst-2
MIN_BURST="2250" # No disminuir este valor en bytes
R_QUEUE_LENGTH="200ms"
S_QUEUE_LENGTH="1000ms"
MY_BW="1mbit"
MECHANISM='ledbat'

generate_burst_data(){
	MY_DELAY=$1
	MECHANISM=$2
	LOCAL_CAPTURES=$3
	FILE_NAME=$4
	MY_BURST=$5
	R_QUEUE_LENGTH=$6
	MY_BW=$7
	S_QUEUE_LENGTH=$8
	
	echo "GENERATING DATA FOR BURST VALUE: $MY_BURST"
	
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
	echo 'Entering to R1...'
	ssh R1 "echo it | sudo -S pkill tcpdump"
	ssh R1 "echo it | sudo -S tc qdisc del dev eth1 root"
	ssh R1 "echo it | sudo -S tc qdisc replace dev eth1 root netem delay $MY_DELAY"
	ssh R1 "echo it | sudo -S tc -p qdisc ls dev eth1"
	
	# Conexion a R2
	echo 'Entering to R2...'
	ssh R2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $R_QUEUE_LENGTH burst $MY_BURST"
	ssh R2 "echo it | sudo -S tc -p qdisc ls dev eth0"
	
	# Conexion a S2
	echo 'Entering to S2...'
	ssh S2 "echo it | sudo -S pkill dd"
	ssh S2 "echo it | sudo -S pkill nc"
	ssh S2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $MY_BW latency $S_QUEUE_LENGTH burst $MY_BURST"
	ssh S2 "echo it | sudo -S tc -p qdisc ls dev eth0"
	
	# Conexion a R1
	echo 'Starting capture in R1...'
	ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME-$MECHANISM-$MY_BURST.pcap" &
	
	echo 'Listening in S2 port 80...'
	ssh S2 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 80 2>&1 &" &

	sleep 15

	# Conexion a C2
	echo 'Starting download C2:49000<--S2:80...'
	ssh C2 "nc -dp 49000 S2 80 > /dev/null &"
	
	sleep 300
	
	#echo 'Stopping tcpprobe in S1...'
	#ssh S1 "echo it | sudo -S pkill dd"

	echo 'Deteneniendo netcat en S2...'
	ssh S2 "echo it | sudo -S pkill dd"
	ssh S2 "echo it | sudo -S pkill nc"
	
	echo 'Deteniendo netcat en C2...'
	ssh C2 "echo it | sudo -S pkill dd"
	ssh C2 "echo it | sudo -S pkill nc"
	
	echo 'Stopping capture in R1' 
	ssh R1 "echo it | sudo -S pkill tcpdump"
	
	echo 'Copiando Kernel log...'
	ssh -t C2 "echo it | sudo -S scp /var/log/kern.log ledbat@C1:/home/ledbat/Documents/100325165/kern-$MY_BURST.log" 

	echo 'Copying .pcap file C1<--R1'
	ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME-$MECHANISM-$MY_BURST.pcap ledbat@C1:/home/ledbat/Documents/100325165"
	
	echo 'Local captures folder is:'$LOCAL_CAPTURES
	echo 'File name is:'$FILE_NAME-$MECHANISM-$MY_BURST
	echo 'Captures generation ended...'
}


#echo 'File name is: '$FILE_NAME
#
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
			echo 'Bad argument, default delay selected '$MY_DELAY
		fi
	fi
fi


generate_burst_data $MY_DELAY $MECHANISM $LOCAL_CAPTURES $FILE_NAME 2250 $R_QUEUE_LENGTH $MY_BW $S_QUEUE_LENGTH
generate_burst_data $MY_DELAY $MECHANISM $LOCAL_CAPTURES $FILE_NAME 11250 $R_QUEUE_LENGTH $MY_BW $S_QUEUE_LENGTH
generate_burst_data $MY_DELAY $MECHANISM $LOCAL_CAPTURES $FILE_NAME 16875 $R_QUEUE_LENGTH $MY_BW $S_QUEUE_LENGTH
generate_burst_data $MY_DELAY $MECHANISM $LOCAL_CAPTURES $FILE_NAME 22500 $R_QUEUE_LENGTH $MY_BW $S_QUEUE_LENGTH
