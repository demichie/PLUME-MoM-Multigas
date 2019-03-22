print "Calculating Mdphi and sigmaphi"
print '\n'

import numpy as np
import os
import glob, os
import matplotlib.pyplot as plt
from scipy import interpolate, stats
import scipy
import scipy.stats


def median(histogram):
    total = 0
    median_index = (sum(histogram.values()) + 1) / 2
    for value in sorted(histogram.keys()):
        total += histogram[value]
        if total > median_index:
            return value

with open("GrainSize_mdphi_sigmaphi.txt", "w") as f1:
	f1.write('Sample'), f1.write(' '), f1.write('Mdphi'), f1.write(' '), f1.write('Sigmaphi'), f1.write('\n')
	f1.close()

folder_name =os.getcwd()
list_of_files=[i for i in os.listdir(folder_name) if i.endswith("txt")]
list_of_files.remove('column_height.txt')
list_of_files.remove('sample_deposit_total.txt')
list_of_files.remove('GrainSize_mdphi_sigmaphi.txt')
list_of_files.remove('atm.txt')
list_of_files.remove('con2stn.txt')
list_of_files.remove('profile_00.txt')
list_of_files.remove('profile_01.txt')
list_of_files.remove('atm_profile.txt')
list_of_files.remove('meteo_ground_elev.txt')
list_of_files.sort(key=lambda f: int((filter(str.isdigit, f))))




list_of_files1=[str(folder_name)+"/"+list_of_files for list_of_files in list_of_files]


delim = ' '

i = 0
for file in list_of_files1:
	with open(file, "r") as f1, open("new_sample_deposit%s.txt" % i, "w") as f2:
 		data = f1.read()
		data = data.replace("[", " ")
		data = data.replace("]", "")
		f2.write(data)
		f2.close()
	with open('new_sample_deposit%s.txt' % i, "r") as f3, open ('sample_deposit_new%s.txt' % i, "w") as f4:
    		for line in f3.readlines():
    			line = line.rstrip() 
    			datarow = line.split(delim)
    			f4.write(delim.join(datarow[2:]) + "\n")
	with open('sample_deposit_new%s.txt' % i, "r") as f5:
		x = [line.split()[0] for line in f5]
		x = map(float, x)
		x = map(int, x)
		f5.close()
	with open('sample_deposit_new%s.txt' % i, "r") as f6, open("GrainSize_mdphi_sigmaphi.txt", "a") as f7:	
		y = [line.split()[1] for line in f6]
		y = map(float, y)
		y1 = y
		h = np.cumsum(y)
		med1 = [y for y in h if y <= 50]
		med2 = [y for y in h if y > 50]
		len1 = (len(med1) - int(1))
		len2 = len1 + int(1)
		a = med1[-1]
		b = med2[0]
		alpha = x[len1]
		beta = x[len2]
		mdphi = alpha+((50-a)*((beta-alpha)/(b-a)))
		print 'sample%s_mdphi = ' % i, mdphi
		sixteen1 = [y for y in h if y <= 16]
		sixteen2 = [y for y in h if y > 16]
		if not sixteen1:
			sixteen1 = sixteen2[0]
			sixteen2 = sixteen2[1:]
			len3 = int(0)
			a1 = sixteen1
		else:
			len3 = (len(sixteen1) - int(1))
			a1 = sixteen1[-1]
		len4 = len3 + int(1)
		b1 = sixteen2[0]
		alpha1 = x[len3]
		beta1 = x[len4]
		phi16 = alpha1+((16-a1)*((beta1-alpha1)/(b1-a1)))
		eightyfour1 = [y for y in h if y <= 84]
		eightyfour2 = [y for y in h if y > 84]
		len5 = (len(eightyfour1) - int(1))
		len6 = len5 + int(1)
		a2 = eightyfour1[-1]
		b2 = eightyfour2[0]
		alpha2 = x[len5]
		beta2 = x[len6]
		phi84 = alpha2+((84-a2)*((beta2-alpha2)/(b2-a2)))
		sigmaphi = (phi84-phi16)/2
		print 'sample%s_sigmaphi = ' % i, sigmaphi
		f7.write(str(i)), f7.write(' '), f7.write(str(mdphi)), f7.write(' '), f7.write(str(sigmaphi)) , f7.write('\n')		
	i += 1


filelist = glob.glob('new_sample*')
for f in filelist:
    os.remove(f)

filelist = glob.glob('sample_deposit_new*')
for f in filelist:
    os.remove(f)

print ('\n')
print "Done"





