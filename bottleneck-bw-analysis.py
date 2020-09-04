#!/usr/bin/env python2

#15/08/2020
# Analisis de ancho de banda en cuello de botella
# Ejemplo de ejecucion ./bottleneck-bw-analysis.py file-name
#./bottleneck-bw-analysis.py 2020-08-07_022019-bw-bottle--cubic

import sys
import scipy.stats
import numpy as np
import matplotlib.pyplot as plt
import csv
import warnings
# ignore warnings from binned_statistic
warnings.simplefilter(action='ignore', category=FutureWarning)

FILE_NAME = sys.argv[1]
MECHANISM = sys.argv[2]
csv_file_name1 = FILE_NAME+'-1000kbit-throughput.csv'
csv_file_name2 = FILE_NAME+'-2000kbit-throughput.csv'
csv_file_name3 = FILE_NAME+'-4000kbit-throughput.csv'
csv_file_name4 = FILE_NAME+'-8000kbit-throughput.csv'
csv_file_name5 = FILE_NAME+'-16000kbit-throughput.csv'
csv_file_name6 = FILE_NAME+'-20000kbit-throughput.csv'

CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-'+MECHANISM+'/bw-variation/'

binz = 1.0
width = 0.1 * 2000 # ancho de las barras


def mean_throughput(capture_folder,csv_file_name,my_bins):
	bin_size = float (my_bins)
	data= np.genfromtxt(capture_folder+csv_file_name, delimiter='\t')
	time = [row[1] for row in data]
	y = [row[2] for row in data]
	bins = np.arange(0,float(time[len(time)-1]),bin_size)
	bins_sums, bin_edges, bin_number = scipy.stats.binned_statistic(time, y,'sum', bins)
	bins_sums = bins_sums*8/bin_size/1000
	print "."
	# Average Throughput in kbps:
	avr_th = np.mean(bins_sums)
	
	#print avr_th
	return avr_th

cubic_mean = []
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name1,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name2,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name3,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name4,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name5,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name6,binz))

print "cubic_means:"
for i in cubic_mean:
	print type(i), i

bw_axis = [1000, 2000, 4000, 8000, 16000, 20000] # bw axis in kbps
bw_axis1 = [float(i) for i in bw_axis]

cubic_means_ratio = []
print "length cubic_mean:"
print len(cubic_mean)
for j in np.arange(0,len(cubic_mean),1):
	cubic_means_ratio.append((cubic_mean[j]*100)/bw_axis[j])
	
print "print cubic_means_ratio:"
for i in cubic_means_ratio:
	print i

fig, ax = plt.subplots()

rects1 = ax.bar(bw_axis1, cubic_means_ratio, width, label=MECHANISM, color='green')
# De momento solo se grafica CUBIC

labels = [1, 2, 4, 8, 16, 20]
fig.tight_layout()
plt.title('TCP Friendliness')
plt.xlabel('Mbps')
plt.ylabel('Throughput Ratio %')
ax.legend(loc='upper right')
ax.set_xticks(bw_axis)
ax.set_xticklabels(labels)
plt.show()