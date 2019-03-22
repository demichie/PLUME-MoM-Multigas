print "Sampling TGSD"
print '\n'

from scipy.stats import norm
import numpy as np
from parameters_range_Probmap import mu_range, sigma_range

mu=mu_range
sigma=sigma_range

dist_space = np.arange((int(mu)-int(round(2)*round(sigma_range, 2))), (int(mu)+int(round(2)*round(sigma_range, 2))))
diam_phi=', '.join(map(str,dist_space))
diam_phi=str("[")+str(diam_phi)+str("]")

npar=str(len(dist_space))

mf=norm(mu, sigma).pdf(dist_space)
smf=sum(mf)

partial_mass_fractions=[x / smf for x in mf]
partial_mass_fractions=str(partial_mass_fractions)


with open("sample_TGSD.txt", "w") as f1:
	f1.write(npar), f1.write('\n')
	f1.write(partial_mass_fractions), f1.write('\n')
	f1.write(diam_phi)
	f1.close()

print "Grain Sizes = ", npar
print "Mass fractions (wt%) =", partial_mass_fractions
print "Diameters (phi) =", diam_phi
print '\n'
print "Done"


