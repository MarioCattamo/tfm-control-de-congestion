#!/bin/bash

# BBR vs LEDBAT, fichero para calculo de throughput de BBR, LEDBAT y CUBIC en la misma grafica.
# Ejemplo de ejecucion ./cub-bbr-led-throughput.sh 2020-08-16_011539-bbr-ledbat 

# C1:49001 	<-- 	S1:49101 	con BBR
# C2:49000 	<-- 	S2:80 		con LEDBAT
# C2:49002 	<-- 	S2:49102 	con CUBIC

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-bbr-ledbat/'

if [ -z $1 ]
then
	echo 'Provide file name...'
	exit
else
	FILE_NAME=$1
	echo 'file name is: '$FILE_NAME
fi

tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-ledbat-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-throughput.csv'

python2 cub-bbr-led-throughput.py $FILE_NAME
