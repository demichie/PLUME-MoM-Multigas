import numpy as np
import os.path
with open("input_file.py", "r") as f1, open("chi_square.txt", "r") as f2:
	for i in range(23):
		next(f1)
	log10_MFR=next(f1)[13:-2]
	for i in range(9):
		next(f1)
	water_mass_fraction=next(f1)[23:-1]
	for i in range(49):
		next(f1)
	shapefactor=next(f1)[14:-1]
	f1.close()
	chi_square=f2.read()
	f2.close()
	
PATH='./output_inversion.txt'

if os.path.isfile(PATH) and os.access(PATH, os.R_OK):
	with open("output_inversion.txt", "a") as f3:
		f3.write('\n')
		f3.write('{a:^8} {b:^8} {c:^8} {d:^8}'.format(a=log10_MFR, b=water_mass_fraction, c=shapefactor, d=chi_square))
		f3.close()	
else:
	with open("output_inversion.txt", "w") as f3:
		f3.write('{a:^8} {b:^8} {c:^8} {d:^8}'.format(a='log10_MFR', b='water_mass_fraction', c='shapefactor', d='chi_square'))
		f3.write('\n')
		f3.write('{a:^8} {b:^8} {c:^8} {d:^8}'.format(a=log10_MFR, b=water_mass_fraction, c=shapefactor, d=chi_square))
		f3.close()
	
	
	

