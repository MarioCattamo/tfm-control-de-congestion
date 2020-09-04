#!/usr/bin/env python2

# Ejemplo de ejecucion ./cub-led-cwnd-rtt-py 2020-08-16_011539-bbr-ledbat

import sys
import numpy as np
import matplotlib.pyplot as plt
import csv

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/bbr-ledbat/'
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


data1= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-bbr.csv', delimiter='\t')
data2= np.genfromtxt(CAPTURE_FOLDER+FILE_NAME+'-ledbat.csv', delimiter=';')


xtime1 = [row[0] for row in data1]
ywindow1 = [row[6] for row in data1]
zwindow1 = [row[9]/1000 for row in data1]

xtime2 = [(row[11]/nanosec_scale) for row in data2]
ywindow2 = [(row[5])/mss for row in data2] # congestion window
zwindow2 = [(row[14]/mssec_scale) for row in data2] # RTT

xtime2 = [elem-xtime2[0] for elem in xtime2]

plt.figure(0)
plt.plot(xtime1,ywindow1,label='BBR cwnd',color='blue')
plt.plot(xtime2,ywindow2,label='LEDBAT rcwnd_ok',color='red')
plt.title('CWND')
plt.xlabel('time[seconds]')
plt.ylabel('packets[MSS]')
plt.grid()
plt.legend(loc='upper right')

plt.figure(1)
plt.plot(xtime1,zwindow1,label='BBR rtt',color='blue')
plt.plot(xtime2,zwindow2,label='LEDBAT rtt',color='red')
plt.title('RTT')
plt.xlabel('time[seconds]')
plt.ylabel('ms')
plt.grid()
plt.legend(loc='upper right')
plt.show()