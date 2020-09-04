#!/bin/bash

# CUBIC vs LEDBAT, fichero para calculo de throughput de CUBIC y LEDBAT en la misma grafica.
# Ejemplo de ejecucion ./cub-led-throughput.sh 2020-08-11_204737-cubic-ledbat 36506

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-ledbat/'

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
	echo 'Provide CUBIC source port for to filter the pcap capture...'
	exit
else
	SRC_PORT=$2
	echo 'Source port is: '$SRC_PORT
fi
# Obtencion de throughput a partir de la captura
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport=='$SRC_PORT -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-ledbat-throughput.csv'
python2 cub-led-throughput.py $FILE_NAME
