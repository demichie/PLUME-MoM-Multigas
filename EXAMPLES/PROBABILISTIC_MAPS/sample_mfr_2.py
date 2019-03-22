print "Sampling Mass Flow Rates"
print '\n'

import subprocess
import datetime
import os,sys
import re
import shutil
import numpy as np
from numpy import math
from parameters_range_Probmap import er_mfr
from sample_duration1 import *
from sample_emittimes_output import *
from input_file_template_Probmap import deltat_plumemom 

def round_minutes(dt, direction, resolution):

    if ( dt.minute%resolution == 0 ):

        rounded_time = dt

    else: 

        new_minute = (dt.minute // resolution + (1 if direction == 'up' else 0)) * resolution

        rounded_time = dt + datetime.timedelta(minutes=new_minute - dt.minute)

    return rounded_time


Start_simulation = str(Start_simulation_year) + str(" ") + str(Start_simulation_month) + str(" ") + str(Start_simulation_day) + str(" ") + str(Start_simulation_hour) + str(" ") + str(Start_simulation_minute)

End_emission = str(End_emission_year) + str(" ") + str(End_emission_month) + str(" ") + str(End_emission_day) + str(" ") + str(End_emission_hour) + str(" ") + str(End_emission_minute)

time_format = "%y %m %d %H %M"

starttime_hhmm = datetime.datetime.strptime(Start_simulation,time_format)
starttime_round = round_minutes(starttime_hhmm, 'down', 60) # arrotonda per difetto starttime

endemittime_hhmm = datetime.datetime.strptime(End_emission,time_format)
endemittime_round = round_minutes(endemittime_hhmm, 'up', 60) # arrotonda per eccesso endemittime


runtime=endemittime_round-starttime_round # numero ore arrotondate tra inizio e fine emissione 
n_runs = np.int(np.floor( runtime.total_seconds() / deltat_plumemom ) ) # numero run di PlumeMoM

er_mfr_log10=float(math.log10(er_mfr))

er_mfr_log10in=str(((str(er_mfr_log10)+str(", "))*(int(n_runs)-int(1))))
er_mfr_log10=str(er_mfr_log10)
with open("mass_flow_rates_eruption.txt", "w") as f1:
	f1.write(er_mfr_log10in), f1.write(er_mfr_log10)
	f1.close()

print "MFR eruption (log10_kg/s) = ", er_mfr_log10
print '\n'
print "Done"
