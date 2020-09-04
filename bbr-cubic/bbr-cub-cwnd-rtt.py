#!/usr/bin/env python2

# Ejemplo de ejecucion ./bbr-cub-cwnd-rtt-py 2020-08-16_011539-bbr-cubic

import sys
import numpy as np
import matplotlib.pyplot as plt
import csv

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/bbr-cubic/'
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


data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-S1-bbr.csv', delimiter='\t')
data2= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-S2-cubic.csv', delimiter='\t')


xtime1 = [row[0] for row in data1]
ywindow1 = [row[6] for row in data1]
zwindow1 = [row[9]/1000 for row in data1]

xtime2 = [row[0] for row in data2]
ywindow2 = [row[6] for row in data2]
zwindow2 = [row[9] for row in data2]

plt.figure(0)
plt.plot(xtime1,ywindow1,label='BBR cwnd',color='blue')
plt.plot(xtime2,ywindow2,label='CUBIC cwnd',color='red')
plt.title('CWND')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')
plt.grid()
plt.legend(loc='upper right')

plt.figure(1)
plt.plot(xtime1,zwindow1,label='BBR rtt',color='blue')
plt.plot(xtime2,zwindow2,label='CUBIC rtt',color='red')
plt.title('RTT')
plt.xlabel('time[seconds]')
plt.ylabel('ms')
plt.grid()
plt.legend(loc='upper right')
plt.show()