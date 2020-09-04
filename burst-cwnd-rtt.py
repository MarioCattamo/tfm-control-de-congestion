#!/usr/bin/env python2

# ejemplo de ejecucion ./burst-cwnd-rtt.py file-name CUBIC 
import sys
import numpy as np
import matplotlib.pyplot as plt
import csv



if len(sys.argv)<2:
	print "Provide file name..."
	sys.exit()
else:
	FILE_NAME = sys.argv[1]

	if len(sys.argv)==3:
		if sys.argv[2] == 'cubic' or sys.argv[2] == 'bbr':
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

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-'+MECHANISM+'/burst-variation/'

data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-'+MECHANISM+'-2250.csv', delimiter='\t')
data2= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-'+MECHANISM+'-11250.csv', delimiter='\t')
data3= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-'+MECHANISM+'-16875.csv', delimiter='\t')
data4= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-'+MECHANISM+'-22500.csv', delimiter='\t')

xtime1 = [row[0] for row in data1]
xtime2 = [row[0] for row in data2]
xtime3 = [row[0] for row in data3]
xtime4 = [row[0] for row in data4]

ywindow1 = [row[6] for row in data1]
ywindow2 = [row[6] for row in data2]
ywindow3 = [row[6] for row in data3]
ywindow4 = [row[6] for row in data4]

zwindow1 = [(row[9]/1000) for row in data1]
zwindow2 = [(row[9]/1000) for row in data2]
zwindow3 = [(row[9]/1000) for row in data3]
zwindow4 = [(row[9]/1000) for row in data4]

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

plt.suptitle("BBR cwnd")

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

plt.suptitle("BBR RTT")
plt.show()