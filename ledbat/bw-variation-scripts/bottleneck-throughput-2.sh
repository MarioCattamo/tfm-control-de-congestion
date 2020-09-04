#!/bin/bash

echo 'Extracting ip len information from pcap files...'
CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/bw-variation/'
FILE_NAME=$1

# Calculo de throughput para friendliness 04/08/2020
tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-20mbit-throughput.csv'


python2 bottleneck-bw-analysis-2.py $FILE_NAME