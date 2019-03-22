from random import *
import numpy as np

paroxysm_flag = 1						#write either 1 (paroxysm) or 2 (no paroxysm)
par_dur=np.random.triangular(25,35,65)				#paroxysm duration in minutes
er_dur=np.random.triangular(24,36,48)				#rest of the eruption duration in hours

par_mfr=np.random.triangular(1.0E+07,1.0E+08)			#paroxysm mfr in kg/s
er_mfr=np.random.triangular(1.0E+05,1.0E+06)			#eruption mfr in kg/s

plumeheight_flag = 1						#write either 1 (no plume height) or 2 (with plume height)
plume_height = str(np.random.triangular(10000, 15000, 30000))	#plume height range in m (if plume height is chosen, mfr is not used)

water_mass_fraction0 = str(round(uniform(0.03, 0.06), 3))	#water mass fraction in wt%

diam1 = str(0.00025)						#lower particle diameter in m
rho1 = str(randint(2000, 2700))					#lower particle density in kg/m3
diam2 = str(0.002)						#upper particle diameter in m
rho2 = str(randint(500, 1600))					#upper particle density in kg/m3
cp_part = str(randint(1316, 1610))				#particles specific heat in J/(kg*K)
shapefactor = str(round(uniform(0.2, 0.6), 1))			#particles shape factor



mu_range=np.random.uniform(-3.0, 6.0)				#mean of the TGSD
sigma_range=np.random.uniform(1.0, 5.0)				#standard deviation of the TGSD
skew_range=np.random.uniform(-1.0, 1.0)				#skewness of the TGSD
kurt_range=np.random.uniform(-1.0, 1.0)				#kurtosis of the TGSD


iterations = 1200						#number of iterations
folder_name = "/home/alessandro/Codici/PLUME-MoM-Multigas-master_v3/EXAMPLES/hysplit_Tungurahua2006" 	#folder name
ML_value_1 = 1							#mass loading value (in kg/m2) for probabilistic map
ML_value_2 = 5							#mass loading value (in kg/m2) for probabilistic map
ML_value_3 = 10							#mass loading value (in kg/m2) for probabilistic map
ML_value_4 = 50							#mass loading value (in kg/m2) for probabilistic map
ML_value_5 = 100						#mass loading value (in kg/m2) for probabilistic map
meteo_file_name = "GDAS1_0418JanSep.bin"			#meteo file name
meteo_type = 1							#meteo data source (1=GDAS, 2=REANALYSIS, 3=ECMWF)
meteo_start_year = 4						#meteo start year - last two digits (if it is like 04, write only 4)
meteo_end_year = 18						#meteo end year - last two digits (if it is like 04, write only 4)

print iterations
