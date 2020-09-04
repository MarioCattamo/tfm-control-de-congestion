#!/bin/bash

echo 'Extracting ip len information from pcap files...'

FILE_NAME=$1
SRC_PORT1=$2
SRC_PORT2=$3
SRC_PORT3=$4
SRC_PORT4=$5
SRC_PORT5=$6
SRC_PORT6=$7
MECHANISM=$8

CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-'$MECHANISM'/bw-variation/'

# Calculo de throughput para friendliness 04/08/2020
tshark -r $CAPTURE_FOLDER$FILE_NAME'-1000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT1 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-1000kbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT2 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-2000kbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT3 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-4000kbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT4 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-8000kbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT5 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-16000kbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20000kbit.pcap' -R 'tcp.srcport=='$SRC_PORT6 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-20000kbit-throughput.csv'

# Llamar a friendliness solo si se esta calculando la friendliness, de lo contrario mantener comentado
python2 bottleneck-bw-analysis.py $FILE_NAME $MECHANISM