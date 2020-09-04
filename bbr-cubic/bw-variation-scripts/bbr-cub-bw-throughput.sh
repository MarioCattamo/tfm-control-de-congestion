#!/bin/bash

echo 'Extracting ip len information from pcap files...'
# Ejemplo de ejecucion ./bbr-cub-bw-throughput.sh 2020-08-16_160740-bw-bottle-ledbat 59730 59734 59738 59742 59746 59750

CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/bbr-cubic/'
FILE_NAME=$1
SRC_PORT1=$2
SRC_PORT2=$3
SRC_PORT3=$4
SRC_PORT4=$5
SRC_PORT5=$6
SRC_PORT6=$7
SRC_PORT7=$8
SRC_PORT8=$9
SRC_PORT9=$10
SRC_PORT10=$11
SRC_PORT11=$12
SRC_PORT12=$13


# Calculo de throughput para friendliness 04/08/2020

tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport=='$SRC_PORT1 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport=='$SRC_PORT2 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport=='$SRC_PORT3 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport=='$SRC_PORT4 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport=='$SRC_PORT5 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport=='$SRC_PORT6 -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-20mbit-throughput.csv'
#
tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==49100' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cub-20mbit-throughput.csv'

python2 bbr-cub-bw-analysis.py $FILE_NAME