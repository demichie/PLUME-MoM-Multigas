print "Sampling TGSD"
print '\n'

from statsmodels.sandbox.distributions.extras import pdf_mvsk
import numpy as np
from parameters_range_Probmap import mu_range, sigma_range, skew_range, kurt_range
from pylab import plot, show

dist_space = np.arange((int(mu_range)-int(round(2)*round(sigma_range, 2))), (int(mu_range)+int(round(2)*round(sigma_range, 2))))
diam_phi=', '.join(map(str,dist_space))

diam_phi=str("[")+str(diam_phi)+str("]")

npar=str(len(dist_space))

a =(mu_range, sigma_range, skew_range, kurt_range)

mf=pdf_mvsk(a)
probs=np.round(abs(mf(dist_space)), 8)
probs2_1 =np.round(probs/sum(probs), 8)
probs2=', '.join(map(str,probs2_1))

probs2=str("[")+str(probs2)+str("]")

#plot(dist_space, probs2_1)
#show()
with open("sample_TGSD.txt", "w") as f1:
	f1.write(npar), f1.write('\n')
	f1.write(probs2), f1.write('\n')
	f1.write(diam_phi)
	f1.close()

print "Grain Sizes = ", npar
print "Mass fractions (wt%) =", probs2
print "Diameters (phi) =", diam_phi
print '\n'
print "Done"


