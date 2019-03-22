print "Sampling TGSD"
print '\n'

import scipy as sc
from scipy.special import erf 
import numpy as np
from parameters_range_Probmap import mu_range, sigma_range, skew_range, kurt_range
from pylab import plot, show

def pdf(x):
	return 1/sc.sqrt(2*sc.pi) * sc.exp(-x**2/2)

def cdf(x):
	return (1 + erf(x/sc.sqrt(2))) / 2

def skew(x,e=0,w=1,a=0):
	t = (x-e) /w
	return 2 / w * pdf(t) * cdf(a*t)

dist_space = np.arange((int(mu_range)-int(round(2)*round(sigma_range, 2))), (int(mu_range)+int(round(2)*round(sigma_range, 2))))
diam_phi=', '.join(map(str,dist_space))
diam_phi=str("[")+str(diam_phi)+str("]")

npar=str(len(dist_space))

x = dist_space
e = mu_range
w = sigma_range
a = skew_range

mf=skew(x,e,w,a)
smf=sum(mf)

partial_mass_fractions=[x / smf for x in mf]
partial_mass_fractions1=str(partial_mass_fractions)

#plot(dist_space,partial_mass_fractions)

#show()


with open("sample_TGSD.txt", "w") as f1:
	f1.write(npar), f1.write('\n')
	f1.write(partial_mass_fractions1), f1.write('\n')
	f1.write(diam_phi)
	f1.close()

print "Grain Sizes = ", npar
print "Mass fractions (wt%) =", partial_mass_fractions
print "Diameters (phi) =", diam_phi
print '\n'
print "Done"


