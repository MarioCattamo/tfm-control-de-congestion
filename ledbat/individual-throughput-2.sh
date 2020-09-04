#!/bin/bash

# Individual throughput 2 sh, fichero para calculo de throughput solo para ledbat.
# Ejemplo de ejecucion ./individual-throughput-2.sh file-name source-port

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/buffer-2250/'

if [ -z $1 ]
then
	echo 'Provide file name...'
	exit
else
	FILE_NAME=$1
	echo 'file name is: '$FILE_NAME
fi

if [ -z $2 ]
then
	echo 'Provide source port to filter the pcap capture...'
	exit
else
	SRC_PORT=$2
	echo 'Source port is: '$SRC_PORT
fi
# Obtencion de throughput a partir de la captura
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport=='$SRC_PORT -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-throughput.csv'

python2 individual-throughput-2.py $FILE_NAME'-throughput'
