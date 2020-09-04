#!/bin/bash

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/burst-variation/'
# Ejemplo de ejecucion: 1 argumento de file name y 4 puertos
# ./burst-throughput-1.sh file-name port1 port2 port3 port4 


if [ $# -gt 2 ]
then
	echo 'too many arguments...'
	exit
fi

if [ -z $1 ]
then
	echo 'Provide file name...'
	exit
else
	FILE_NAME=$1
	#echo 'file name is: '$FILE_NAME
fi

# Obtencion de throughput a partir de la captura
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2250.pcap' -R "tcp.srcport==80" -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-2250-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-11250.pcap' -R "tcp.srcport==80" -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-11250-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16875.pcap' -R "tcp.srcport==80" -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-16875-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-22500.pcap' -R "tcp.srcport==80" -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-22500-throughput.csv'

python2 burst-throughput-2.py $FILE_NAME
