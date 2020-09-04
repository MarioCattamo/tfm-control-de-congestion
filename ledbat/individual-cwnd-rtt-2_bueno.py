#!/usr/bin/env python2

# Ejemplo de ejecucion ./individual-cwnd-rtt-py filename mechanism

import sys
import numpy as np
import matplotlib.pyplot as plt
import csv

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/buffer-2250/'
MECHANISM = 'LEDBAT'
mss = 1448 # Maximum segment sizw
nanosec_scale = 1000000000
mssec_scale = 1000000

if len(sys.argv)<2:
	print "Provide file name..."
	sys.exit()
else:
	if len(sys.argv)>2:
		print "too many arguments..."
		sys.exit()
	else:
		FILE_NAME = sys.argv[1]


data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'.csv', delimiter=';')

xtime1 = [(row[11]/nanosec_scale) for row in data1]
ywindow1 = [(row[5])/mss for row in data1] # congestion window
zwindow1 = [(row[14]/mssec_scale) for row in data1] # RTT

xtime1 = [elem-xtime1[0] for elem in xtime1]
for i in xtime1:
	print i

plt.figure(0)
plt.plot(xtime1,ywindow1,label='rcwnd_ok',color='blue')
plt.title('LEDBAT cwnd')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')
plt.grid()
plt.legend(loc='upper right')

plt.figure(1)
plt.plot(xtime1,zwindow1,label='rtt',color='red')
#plt.tight_layout()
plt.title('LEDBAT RTT')
plt.xlabel('time[seconds]')
plt.ylabel('ms')
plt.grid()
plt.legend(loc='upper right')
plt.show()