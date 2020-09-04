#!/usr/bin/env bash

# 12/08/2020
# Analisis expermiento 2, generacion de datos para estudio de Friendliness en TCP
# Se generaliza el funcionamiento del experimento 1 para generar varias conjuntos de throughput con una latencia fija, tamaño de buffer/burst fijo y 
# y variacion del RATE...

# Ejemplo de ejecucion ./cub-led-bw-analysis.sh [short|long] mechanism 

# La queue latency y el burst son valores fijos


LOCAL_CAPTURES='/home/ledbat/Documents/100325165/'
FILE_NAME=$(date '+%F_%H%M%S')'-bw-bottle'
echo 'File name is: '$FILE_NAME
MECHANISM='ledbat'

# Inicio de la funcion
generate_throughput_data (){
	
	BOTTLENECK_RATE=$1
	MECHANISM=$2
	MY_DELAY=$3
	MY_BURST='2250' # No disminuir este valor en bytes
	R_QUEUE_LENGTH='200ms'
	S_QUEUE_LENGTH='1000ms'
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
	ssh R2 "echo it | sudo -S tc qdisc replace dev eth0 root tbf rate $BOTTLENECK_RATE latency $R_QUEUE_LENGTH burst $MY_BURST"
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
	ssh S2 "echo it | sudo -S tc -p qdisc ls dev eth0"
	
	# Conexion a R1
	echo 'Capturando en R1...'
	ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME.pcap" &
	
	# Conexion a S1
	echo 'Executing tcpprobe in S1...'
	ssh S1 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME.dat > /dev/null 2>&1" &
	echo 'Listening in S1 port 49101...' 
	ssh S1 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 49101 2>&1 &" &
	
	# Conexion a S2
	echo 'Executing tcpprobe in S2...'
	ssh S2 "dd if=/proc/net/tcpprobe ibs=128 obs=128 | tee /tmp/$FILE_NAME.dat > /dev/null 2>&1" &
	echo 'Listening in S2 port 80...' # Destination port 80 for LEDBAT
	ssh S2 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 80 2>&1 &" &
	echo 'Listening in S2 port 49102...' # Destination port for CUBIC
	ssh S2 "dd if=/dev/zero bs=1M count=100000000 | sudo nc -l 49102 2>&1 &" &
	
	sleep 5
	
	# Iniciando descarga C2<--S2
	echo 'Starting download C2:49000<--S2:80...'
	ssh C2 "nc -dp 49000 S2 80 > /dev/null &"
	echo 'Starting download C2:49002<--S2:49102...'
	ssh C2 "nc -dp 49002 S2 49102 > /dev/null &"
	
	# Iniciando descarga C1<--S1
	echo 'Executing tcpprobe in S1...'
	echo 'Starting download C1:49001<--S2:49101...'
	ssh C1 "nc -dp 49001 S1 49101 > /dev/null &"
	
	
	sleep 300 # 5 minutos de experimento
	
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
	ssh -t S1 "echo it | sudo -S scp /tmp/$FILE_NAME.dat ledbat@C1:/home/ledbat/Documents/100325165/$FILE_NAME-$BOTTLENECK_RATE-S1.dat"
	
	echo 'Copiando .dat C1<--S2'
	ssh -t S2 "echo it | sudo -S scp /tmp/$FILE_NAME.dat ledbat@C1:/home/ledbat/Documents/100325165/$FILE_NAME-$BOTTLENECK_RATE-S2.dat"
	
	echo 'Copiando Kernel log...'
	ssh -t C2 "echo it | sudo -S scp /var/log/kern.log ledbat@C1:/home/ledbat/Documents/100325165/$FILE_NAME-$BOTTLENECK_RATE.log"
	
	echo 'Copiando pcap C1<--R1'
	ssh -t R1 "echo it | sudo -S scp $LOCAL_CAPTURES/$FILE_NAME.pcap ledbat@C1:/home/ledbat/Documents/100325165/$FILE_NAME-$BOTTLENECK_RATE.pcap"

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


generate_throughput_data 1mbit $MECHANISM $MY_DELAY
generate_throughput_data 2mbit $MECHANISM $MY_DELAY
generate_throughput_data 4mbit $MECHANISM $MY_DELAY
generate_throughput_data 8mbit $MECHANISM $MY_DELAY
generate_throughput_data 16mbit $MECHANISM $MY_DELAY
generate_throughput_data 20mbit $MECHANISM $MY_DELAY