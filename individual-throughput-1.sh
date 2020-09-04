#!/bin/bash

# Ejemplo de ejecucion: ./individual-throughput-1.sh 2020-08-13_181431-ind-1-bbr bbr 59564

echo 'Extracting ip len information from pcap files...'
#CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-cubic/buffer-2250/'


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
	echo 'Provide mechanism [cubic|bbr]...'
	exit
else
	MECHANISM=$2
	echo 'Selected mechanism: '$MECHANISM
fi

if [ -z $3 ]
then
	echo 'Provide source port to filter the pcap capture...'
	exit
else
	SRC_PORT=$3
	echo 'Source port is: '$SRC_PORT
fi

CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-'$MECHANISM'/buffer-2250/'
echo "$CAPTURE_FOLDER"
# Obtencion de throughput a partir de la captura
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport=='$SRC_PORT -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-throughput.csv'

python2 individual-throughput-1.py $FILE_NAME'-throughput' $MECHANISM
