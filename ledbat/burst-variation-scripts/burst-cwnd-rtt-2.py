#!/usr/bin/env python2

# ejemplo de ejecucion ./burst-cwnd-rtt.py file-name mechanism 
# FILE_NAME ejemplo: 2020-08-10_191201-burst-2-ledbat
import sys
import numpy as np
import matplotlib.pyplot as plt
import csv

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/burst-variation/'
MECHANISM = 'LEDBAT'
mss = 1448 # Maximum segment size
nanosec_scale = 1000000000
mssec_scale = 1000000

if len(sys.argv)<2:
	print "Provide file name..."
	sys.exit()
else:
	FILE_NAME = sys.argv[1]

	if len(sys.argv)==3:
		if sys.argv[2] == 'CUBIC' or sys.argv[2] == 'BBR':
			MECHANISM = sys.argv[2]
		else:
			if sys.argv[2] == 'LEDBAT':
				MECHANISM = sys.argv[2]
			else:
				print "Provide proper arguments: ./individual-cwnd-rtt-py filename mechanism"
				sys.exit() 
	else:
		print "Provide proper arguments: ./individual-cwnd-rtt-py filename mechanism"
		sys.exit()

# 0		Time									Time (in seconds) since beginning of probe output
# 1		sender									Source address and port of the packet, as IP:port
# 2		Receiver								Destination address and port of the packet, as IP:port
# 3		Bytes									Bytes in packet
# 4		Next									Next send sequence number, in hex format
# 5		unacknowledged							Smallest sequence number of packet send but unacknowledged, in hex format
# 6		Send CWND								Size of send congestion window for this connection (in MSS)
# 7		Slow start threshold					Size of send congestion window for this connection (in MSS)
# 8		Send window	Send window size (in MSS). 	Set to the minimum of send CWND and receive window size
# 9		Smoothed RTT							Smoothed estimated RTT for this connection (in ms)
# 10	Receive window							Receiver window size (in MSS), received in the lack ACK. This limit prevents the receiver 
#												buffer from overflowing, i.e. prevents the sender from sending at a rate that is faster than the receiver can process the data.

data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-2250.csv', delimiter=';')
data2= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-11250.csv', delimiter=';')
data3= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-16875.csv', delimiter=';')
data4= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-22500.csv', delimiter=';')

xtime1 = [(row[11]/nanosec_scale) for row in data1] #time stamp value in nanosecs
xtime2 = [(row[11]/nanosec_scale) for row in data2]
xtime3 = [(row[11]/nanosec_scale) for row in data3]
xtime4 = [(row[11]/nanosec_scale) for row in data4]

xtime1 = [elem-xtime1[0] for elem in xtime1]
xtime2 = [elem-xtime2[0] for elem in xtime2]
xtime3 = [elem-xtime3[0] for elem in xtime3]
xtime4 = [elem-xtime4[0] for elem in xtime4]

ywindow1 = [(row[5])/mss for row in data1] # congestion window
ywindow2 = [(row[5])/mss for row in data2] # congestion window
ywindow3 = [(row[5])/mss for row in data3] # congestion window
ywindow4 = [(row[5])/mss for row in data4] # congestion window

zwindow1 = [(row[14]/mssec_scale) for row in data1] # RTT
zwindow2 = [(row[14]/mssec_scale) for row in data2] # RTT
zwindow3 = [(row[14]/mssec_scale) for row in data3] # RTT
zwindow4 = [(row[14]/mssec_scale) for row in data4] # RTT

plt.figure(0)
plt.subplot(221)
plt.plot(xtime1,ywindow1,label='Burst 2250B',color='red')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')

plt.subplot(222)
plt.plot(xtime2,ywindow2,label='Burst 11250B',color='green')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')

plt.subplot(223)
plt.plot(xtime3,ywindow3,label='Burst 16875B',color='cyan')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')

plt.subplot(224)
plt.plot(xtime4,ywindow4,label='Burst 22500B',color='magenta')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')

plt.suptitle("LEDBAT cwnd")
#plt.show()

plt.figure(1)
plt.subplot(221)
plt.plot(xtime1,zwindow1,label='Burst 2250B',color='red')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('ms')


plt.subplot(222)
plt.plot(xtime2,zwindow2,label='Burst 11250B',color='green')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('ms')

plt.subplot(223)
plt.plot(xtime3,zwindow3,label='Burst 16875B',color='cyan')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('ms')

plt.subplot(224)
plt.plot(xtime4,zwindow4,label='Burst 22500B',color='magenta')
plt.legend(loc='upper right')
plt.xlabel('time[seconds]')
plt.ylabel('ms')

plt.suptitle("LEDBAT RTT")
plt.show()