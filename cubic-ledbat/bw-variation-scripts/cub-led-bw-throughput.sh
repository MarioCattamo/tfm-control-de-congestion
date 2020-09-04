#!/bin/bash

echo 'Extracting ip len information from pcap files...'

# Ejemplo de ejecucion ./cub-led-bw-throughput.sh 2020-08-12_170441-bw-bottle-ledbat
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-ledbat/'
FILE_NAME=$1
SRC_PORT1=$2
SRC_PORT2=$3
SRC_PORT3=$4
SRC_PORT4=$5
SRC_PORT5=$6
SRC_PORT6=$7

# Calculo de throughput para friendliness 04/08/2020
tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-20mbit-throughput.csv'

tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport== 365'$SRC_PORT1 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport== 365'$SRC_PORT2 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport== 365'$SRC_PORT3 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport== 365'$SRC_PORT4 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==365'$SRC_PORT5 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==365'$SRC_PORT6 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-20mbit-throughput.csv'

python2 cub-led-bw-analysis.py $FILE_NAME