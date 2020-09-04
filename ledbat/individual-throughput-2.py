#!/usr/bin/env python2

import sys
import scipy.stats
import numpy as np
import matplotlib.pyplot as plt
import csv
import warnings
# ignore warnings from binned_statistic
warnings.simplefilter(action='ignore', category=FutureWarning)

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/buffer-2250/'
FILE_NAME = sys.argv[1]
binz = 1.0

def plot_throughput(capture_folder,csv_file_name,line_color,my_bins,my_label):
	bin_size = float (my_bins)
	data= np.genfromtxt(capture_folder+csv_file_name, delimiter='\t')
	time = [row[1] for row in data]
	y = [row[2] for row in data]
	bins = np.arange(0,float(time[len(time)-1]),bin_size)
	bins_sums, bin_edges, bin_number = scipy.stats.binned_statistic(time, y,'sum', bins)
	bins_sums = bins_sums*8/bin_size/1000
	plt.plot(bin_edges[:-1], bins_sums, label=my_label, color=line_color)


print "Plotting throughput..."

plot_throughput(CAPTURE_FOLDER,FILE_NAME+'.csv','blue',binz,'burst 2250B')

plt.title('LEDBAT throughput')
plt.xlabel('time[seconds]')
plt.ylabel('Kbits')
plt.grid()
plt.legend(loc='upper right')
plt.show()
