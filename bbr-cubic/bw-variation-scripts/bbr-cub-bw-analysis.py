#!/usr/bin/env python2

# Ejemplo de ejecucion ./bottleneck-bw-analysis.py file-name
#./bbr-cub-bw-analysis.py 2020-08-12_170441-bw-bottle-ledbat
# Ver: https://matplotlib.org/3.1.1/gallery/lines_bars_and_markers/barchart.html#sphx-glr-gallery-lines-bars-and-markers-barchart-py
import sys
import scipy.stats
import numpy as np
import matplotlib.pyplot as plt
import csv
import warnings
# ignore warnings from binned_statistic
warnings.simplefilter(action='ignore', category=FutureWarning)

#CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/just-cubic/burst-variation/'
#CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/cubic-ledbat/'
CAPTURE_FOLDER = '/home/mario/Documentos/UC3M/TFM/Local-experiments/Captures/bbr-cubic/'
FILE_NAME = sys.argv[1]

# ejemplo de file name 2020-08-07_022019-bw-bottle--cubic
csv_file_name1 = FILE_NAME+'-cub-1mbit-throughput.csv'
csv_file_name2 = FILE_NAME+'-cub-2mbit-throughput.csv'
csv_file_name3 = FILE_NAME+'-cub-4mbit-throughput.csv'
csv_file_name4 = FILE_NAME+'-cub-8mbit-throughput.csv'
csv_file_name5 = FILE_NAME+'-cub-16mbit-throughput.csv'
csv_file_name6 = FILE_NAME+'-cub-20mbit-throughput.csv'
csv_file_name7 = FILE_NAME+'-bbr-1mbit-throughput.csv'
csv_file_name8 = FILE_NAME+'-bbr-2mbit-throughput.csv'
csv_file_name9 = FILE_NAME+'-bbr-4mbit-throughput.csv'
csv_file_name10 = FILE_NAME+'-bbr-8mbit-throughput.csv'
csv_file_name11 = FILE_NAME+'-bbr-16mbit-throughput.csv'
csv_file_name12 = FILE_NAME+'-bbr-20mbit-throughput.csv'

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

# Funcion proporcionada en:
# https://matplotlib.org/3.1.1/gallery/lines_bars_and_markers/barchart.html#sphx-glr-gallery-lines-bars-and-markers-barchart-py
def autolabel(rects,h_offset):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{:.0f}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    #xytext=(0, 3),  # 3 points vertical offset
                    xytext=(float(h_offset), 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')

#ledbat_mean = []
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name1,binz))
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name2,binz))
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name3,binz))
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name4,binz))
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name5,binz))
#ledbat_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name6,binz))

cubic_mean = []
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name1,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name2,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name3,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name4,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name5,binz))
cubic_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name6,binz))

bbr_mean = []
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name7,binz))
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name8,binz))
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name9,binz))
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name10,binz))
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name11,binz))
bbr_mean.append(mean_throughput(CAPTURE_FOLDER,csv_file_name12,binz))


#print "cubic_means:"
#for i in cubic_mean:
#	print type(i), i
#print "ledbat_means:"
#for i in ledbat_mean:
#	print type(i), i
#print "bbr_means:"
#for i in bbr_mean:
#	print type(i), i

bw_axis = [1000, 2000, 4000, 8000, 16000, 20000] # bw axis in kbps
bw_axis1 = [float(i) for i in bw_axis]
bw_axis2 = [(float(i)+width) for i in bw_axis]
bw_axis3 = [(float(i)-width) for i in bw_axis]

#ledbat_means_ratio = []
#print "length ledbat_mean:"
#print len(ledbat_mean)
#for j in np.arange(0,len(ledbat_mean),1):
#	ledbat_means_ratio.append((ledbat_mean[j]*100)/bw_axis[j])
#	
#print "print ledbat_means_ratio:"
#for i in ledbat_means_ratio:
#	print i

cubic_means_ratio = []
print "length cubic_mean:"
print len(cubic_mean)
for j in np.arange(0,len(cubic_mean),1):
	cubic_means_ratio.append((cubic_mean[j]*100)/bw_axis[j])
	
print "print cubic_means_ratio:"
for i in cubic_means_ratio:
	print i

bbr_means_ratio = []
print "length bbr_mean:"
print len(bbr_mean)
for j in np.arange(0,len(bbr_mean),1):
	bbr_means_ratio.append((bbr_mean[j]*100)/bw_axis[j])
	
print "print bbr_means_ratio:"
for i in bbr_means_ratio:
	print i	

fig, ax = plt.subplots()

rects1 = ax.bar(bw_axis1, cubic_means_ratio, width, label='CUBIC', color='blue')
rects2 = ax.bar(bw_axis2, bbr_means_ratio, width, label='BBR', color='green')
#rects3 = ax.bar(bw_axis3, ledbat_means_ratio, width, label='LEDBAT', color='orange')

labels = [1, 2, 4, 8, 16, 20]

autolabel(rects1,'0.0')
autolabel(rects2,'7.0')
#autolabel(rects3,'-7.0')

#with plt.style.context('Solarize_Light2'):
plt.style.use('ggplot')
fig.tight_layout()
plt.title('Bottleneck Bandwidth Sharing')
plt.xlabel('Mbps')
plt.ylabel('Throughput Ratio %')
ax.legend(loc='upper right')
ax.set_xticks(bw_axis)
ax.set_xticklabels(labels)
plt.show()