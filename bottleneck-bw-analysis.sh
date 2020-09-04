#!/usr/bin/env bash

# 07/08/2020
# Analisis expermiento 2, generacion de datos para estudio de Friendliness en TCP
# Se generaliza el funcionamiento del experimento 1 para generar varias conjuntos de throughput con una latencia fija, tamaño de buffer/burst fijo y 
# y variacion del RATE...

# Ejemplo de ejecucion ./bottleneck-bw-analysis.sh delay mechanism 
# La queue latency y el burst son valores fijos


LOCAL_CAPTURES='/home/ledbat/Documents/100325165/'
FILE_NAME=$(date '+%F_%H%M%S')'-bw-bottle'
echo 'File name is: '$FILE_NAME

# Inicio de la funcion
generate_throughput_data (){
	
	BOTTLENECK_RATE=$1
	MECHANISM=$2
	MY_DELAY=$3
	echo "generating throughput data with $BOTTLENECK_RATE"
	
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
	ssh R2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $BOTTLENECK_RATE latency 200ms burst 2250"
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
	echo 'Capturando en R1...'
	ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES$FILE_NAME-$MECHANISM-$BOTTLENECK_RATE.pcap" &

	# Conexion a S1
	echo 'Executing tcpprobe in S1...'
	ssh S1 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME-$MECHANISM-$BOTTLENECK_RATE.dat > /dev/null 2>&1" &
	ssh -t S1 "echo it | sudo -S scp Documents/100325165/dummy-ping.pcap ledbat@C1:/home/ledbat/Documents/100325165"

	sleep 10
	echo 'Stopping tcpprobe...'
	ssh S1 "echo it | sudo -S pkill dd"

	echo 'Stopping capture in R1' 
	ssh R1 "echo it | sudo -S pkill tcpdump"
	
	echo 'Copying .dat file C1<--S1'
	ssh -t S1 "echo it | sudo -S scp /tmp/$FILE_NAME-$MECHANISM-$BOTTLENECK_RATE.dat ledbat@C1:/home/ledbat/Documents/100325165"
	echo 'Copying pcap file C1<--R1'
	ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME-$MECHANISM-$BOTTLENECK_RATE.pcap ledbat@C1:/home/ledbat/Documents/100325165"

	echo 'Local captures folder is:'$LOCAL_CAPTURES
	echo '...'
	echo 'File name is:'$FILE_NAME
	echo 'FIN de generacion de capturas...'
}

if [ $# -ge 3 ]
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
		MY_DELAY="100ms"
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


# Llamadas a la funcion 

generate_throughput_data 1000kbit $MECHANISM $MY_DELAY
generate_throughput_data 2000kbit $MECHANISM $MY_DELAY
generate_throughput_data 4000kbit $MECHANISM $MY_DELAY
generate_throughput_data 8000kbit $MECHANISM $MY_DELAY
generate_throughput_data 16000kbit $MECHANISM $MY_DELAY
generate_throughput_data 20000kbit $MECHANISM $MY_DELAY






#./analysis-experimento-2.sh 	1000kbit
##./analysis-experimento-2.sh 	2000kbit
##./analysis-experimento-2.sh 	4000kbit
##./analysis-experimento-2.sh 	8000kbit
#./analysis-experimento-2.sh 	16000kbit
#./analysis-experimento-2.sh 	20000kbit
