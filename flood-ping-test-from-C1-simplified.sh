#!/usr/bin/env bash

echo 'Measuring bottleneck capacity. Link between R1<--->R2'

LOCAL_CAPTURES='/home/ledbat/Documents/100325165'
FILE_NAME=$(date '+%F_%H%M%S')-ping-flood

sudo pkill ping
################################################

#sudo pkill tcpdump

# Conexión a R1
echo 'entrando a R1...'
ssh R1 "echo it | sudo -S pkill tcpdump"
echo 'capturando en R1...'
ssh R1 "echo it | sudo -S tcpdump -i eth1 -w $LOCAL_CAPTURES/$FILE_NAME.pcap" &
#################################################

echo 'entrando a S1'
echo 'haciendo ping S1-->C1 durante 60 segs...'
ssh S1 "echo it | sudo -S ping C1 -w60 -f -s 1458" &
ssh S1 "echo it | sudo -S ping C1 -w60 -f -s 1458" &
ssh S1 "echo it | sudo -S ping C1 -w60 -f -s 1458" &
ssh S1 "echo it | sudo -S ping C1 -w60 -f -s 1458" &
ssh S1 "echo it | sudo -S ping C1 -w60 -f -s 1458" &
echo 'fin del ping...'

####################################################################################
#
echo 'durmiendo 80 segs mas...'
sleep 80
echo 'entrando a S1 para matar el ping...'
ssh S1 "echo it | sudo -S pkill ping" &
#
##
echo 'entrando a R1 para matar el tcpdump...'
ssh R1 "echo it | sudo -S pkill tcpdump" &
#echo 'fin'
echo
echo 'empezando copia de pcap R1 -->S1'
#ssh R1 "echo it | it sudo scp $LOCAL_CAPTURES/$FILE_NAME.pcap ledbat@C1:/home/ledbat/$LOCAL_CAPTURES"
scp R1:$LOCAL_CAPTURES/$FILE_NAME.pcap $LOCAL_CAPTURES
echo 'terminando copia del pcap...'

tshark -r $LOCAL_CAPTURES/$FILE_NAME.pcap -R 'icmp.type==8' -2 -T fields -E separator=/t -e frame.time_relative -e frame.len > $LOCAL_CAPTURES/$FILE_NAME.csv
#
start_time=$(head -1 $LOCAL_CAPTURES/$FILE_NAME.csv | awk -F"\t" '{print $1}')
echo $start_time
#
end_time=$(tail -1 $LOCAL_CAPTURES/$FILE_NAME.csv | awk -F"\t" '{print $1}')
echo $end_time
#
lines=$(wc -l < $LOCAL_CAPTURES/$FILE_NAME.csv)
echo $lines
#
echo 'Quantity of file lines'
echo $lines
echo 'time elapsed:'
echo "($end_time - $start_time)" | bc
echo 'Capacity of bottleneck between R1<-->R2 in kbps:'
echo "(1500*8*$lines*0.001)/($end_time - $start_time)" | bc
