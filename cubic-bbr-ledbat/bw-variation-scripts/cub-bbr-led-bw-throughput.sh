#!/bin/bash

echo 'Extracting ip len information from pcap files...'
# Ejemplo de ejecucion ./bbr-led-bw-throughput.sh 2020-08-16_160740-bw-bottle-ledbat 59730 59734 59738 59742 59746 59750

CAPTURE_FOLDER='/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-bbr-ledbat/'
FILE_NAME=$1

# Calculo de throughput para friendliness 04/08/2020
tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==80' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-led-20mbit-throughput.csv'

tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==49101' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-bbr-20mbit-throughput.csv'

tshark -r $CAPTURE_FOLDER$FILE_NAME'-1mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-1mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-2mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-2mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-4mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-4mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-8mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-8mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-16mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-16mbit-throughput.csv'
tshark -r $CAPTURE_FOLDER$FILE_NAME'-20mbit.pcap' -R 'tcp.srcport==49102' -2 -T fields -E separator=/t -e frame.number -e frame.time_relative -e ip.len > $CAPTURE_FOLDER$FILE_NAME'-cubic-20mbit-throughput.csv'

python2 cub-bbr-led-bw-analysis.py $FILE_NAME