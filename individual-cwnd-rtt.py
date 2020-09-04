#!/usr/bin/env python2

# Ejemplo de ejecucion ./cub-led-cwnd-rtt-py 2020-08-11_195606-cubic-ledbat

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
CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-'+MECHANISM+'/buffer-2250/'
data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'.csv', delimiter='\t')

xtime1 = [row[0] for row in data1]
ywindow1 = [row[6] for row in data1]
zwindow1 = [(row[9]/1000) for row in data1]

plt.figure(0)
plt.plot(xtime1,ywindow1,label='Burst 2250B',color='blue')
plt.title(MECHANISM+' cwnd')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')
plt.grid()
plt.legend(loc='upper right')

plt.figure(1)
plt.plot(xtime1,zwindow1,label='Burst 2250B',color='red')
plt.title(MECHANISM+' RTT')
plt.xlabel('time[seconds]')
plt.ylabel('ms')
plt.grid()
plt.legend(loc='upper right')
plt.show()