#!/usr/bin/env python2

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

#CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-cubic/burst-variation/'
CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-ledbat/bw-variation/'
FILE_NAME = sys.argv[1]
# ejemplo de file name 2020-08-07_022019-bw-bottle--cubic
csv_file_name1 = FILE_NAME+'-1mbit-throughput.csv'
csv_file_name2 = FILE_NAME+'-2mbit-throughput.csv'
csv_file_name3 = FILE_NAME+'-4mbit-throughput.csv'
csv_file_name4 = FILE_NAME+'-8mbit-throughput.csv'
csv_file_name5 = FILE_NAME+'-16mbit-throughput.csv'
csv_file_name6 = FILE_NAME+'-20mbit-throughput.csv'

binz = 1.0
width = 0.1 * 2000 # the width of the bars


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

ledbat_mean = []
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name1,binz))
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name2,binz))
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name3,binz))
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name4,binz))
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name5,binz))
ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name6,binz))


bw_axis = [1000, 2000, 4000, 8000, 16000, 20000] # bw axis in kbps
bw_axis1 = [float(i) for i in bw_axis]
#bw_axis2 = [(float(i)+width) for i in bw_axis]
bw_axis3 = [(float(i)-width) for i in bw_axis]

ledbat_means_ratio = []
print "length ledbat_mean:"
print len(ledbat_mean)
for j in np.arange(0,len(ledbat_mean),1):
	ledbat_means_ratio.append((ledbat_mean[j]*100)/bw_axis[j])
	
print "print ledbat_means_ratio:"
for i in ledbat_means_ratio:
	print i

fig, ax = plt.subplots()


# De momento solo se grafica LEDBAT

rects3 = ax.bar(bw_axis3, ledbat_means_ratio, width, label='LEDBAT', color='orange')

labels = [1, 2, 4, 8, 16, 20]


plt.style.use('ggplot')
fig.tight_layout()
plt.title('TCP Friendliness')
plt.xlabel('Mbps')
plt.ylabel('Throughput Ratio %')
ax.legend(loc='upper right')
ax.set_xticks(bw_axis)
ax.set_xticklabels(labels)
plt.show()