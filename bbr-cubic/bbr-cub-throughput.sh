#!/bin/bash

# BBR vs CUBIC, fichero para calculo de throughput de BBR y CUBIC en la misma grafica.
# Ejemplo de ejecucion ./bbr-cub-throughput.sh 2020-08-16_011539-bbr-cubic bbr-source-port cubic-source-port

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/bbr-cubic/'

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
	echo 'Provide BBR source port for to filter the pcap capture...'
	exit
else
	SRC_PORT_1=$2
	echo 'Source port is: '$SRC_PORT_1
fi

if [ -z $3 ]
then
	echo 'Provide CUBIC source port for to filter the pcap capture...'
	exit
else
	SRC_PORT_2=$3
	echo 'Source port is: '$SRC_PORT_2
fi
# Obtencion de throughput a partir de la captura
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport=='$SRC_PORT_1 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport=='$SRC_PORT_2 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-throughput.csv'
python2 bbr-cub-throughput.py $FILE_NAME 
