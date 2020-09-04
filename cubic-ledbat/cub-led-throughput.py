#!/usr/bin/env python2

import sys
import scipy.stats
import numpy as np
import matplotlib.pyplot as plt
import csv
import warnings
# ignore warnings from binned_statistic
warnings.simplefilter(action='ignore', category=FutureWarning)

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-ledbat/'
FILE_NAME = sys.argv[1]
binz = 1.0

def plot_throughput(capture_folder,csv_file_name,line_color1,my_bins,my_label):
	bin_size = float (my_bins)
	
	data1= np.genfromtxt(capture_folder+csv_file_name+'-'+my_label+'-throughput.csv', delimiter='\t')
	time1 = [row[1] for row in data1]
	y1 = [row[2] for row in data1]
			
	bins1 = np.arange(0,float(time1[len(time1)-1]),bin_size)
	bins_sums1, bin_edges1, bin_number1 = scipy.stats.binned_statistic(time1, y1,'sum', bins1)
	bins_sums1 = bins_sums1*8/bin_size/1000
	plt.plot(bin_edges1[:-1], bins_sums1, label=my_label, color=line_color1)

print "Plotting throughput..."

plot_throughput(CAPTURE_FOLDER,FILE_NAME,'blue',binz,'cubic')
plot_throughput(CAPTURE_FOLDER,FILE_NAME,'red',binz,'ledbat')

plt.title('Throughput')
plt.xlabel('time[seconds]')
plt.ylabel('Kbits')
plt.grid()
plt.legend(loc='upper right')
plt.show()
