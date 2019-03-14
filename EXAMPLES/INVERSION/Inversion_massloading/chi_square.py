import numpy as np

Mo=np.loadtxt('mass_loadings', delimiter=',')
Mc=np.loadtxt('sample_deposit_total.txt', delimiter=',')

chi_square=str(sum(((Mc-Mo)**2)*(Mo)**-1))


with open("chi_square.txt", "w") as f1:
	f1.write(chi_square)
	f1.close()


