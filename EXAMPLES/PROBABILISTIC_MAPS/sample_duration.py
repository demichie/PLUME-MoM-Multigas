from random import randint
from parameters_range_Probmap import par_dur, er_dur

print "Sampling durations"
print '\n'
if par_dur < 60:
	par_dur_h = int(0)
	par_dur_min = int(par_dur)

if par_dur >= 60:
	par_dur_h = int(1)
	par_dur_min = int(par_dur)-int(60)
		
if par_dur_min >= 60:
	par_dur_h = int(2)
	par_dur_min = int(par_dur_min)-int(60)


if er_dur < 24:
	er_dur_mo=int(0)
	er_dur_day=int(1)
	er_dur_h=int(er_dur)-int(24)

if er_dur >= 24 and er_dur < 720:
	er_dur_mo=int(0)
	er_dur_day=int(er_dur)/int(24)
	er_dur_h=int(er_dur)%int(24)
	

if er_dur >= 720:
	er_dur_mo=int(er_dur)/int(720)
	er_dur_day=int(er_dur)%int(720)
	er_dur_h=int(er_dur)-int(720)

toter_dur_mo=int(er_dur_mo)
toter_dur_day=int(er_dur_day)
toter_dur_h=int(par_dur_h)+int(er_dur_h)
toter_dur_min=int(par_dur_min)

if toter_dur_min >= 60:
	toter_dur_h = toter_dur_h + int(1)
	toter_dur_min = toter_dur_min-int(60)
		
if toter_dur_h >= 24:
	toter_dur_day=toter_dur_day + int(1)
	toter_dur_h= toter_dur_h - int(24)
	
par_dur_h=str(par_dur_h)
par_dur_min=str(par_dur_min)
er_dur_mo=str(er_dur_mo)
er_dur_day=str(er_dur_day)
er_dur_h=str(er_dur_h)
toter_dur_mo=str(toter_dur_mo)
toter_dur_day=str(toter_dur_day)
toter_dur_h=str(toter_dur_h)
toter_dur_min=str(toter_dur_min)

print "paroxysm duration (h) = ", par_dur_h
print "paroxysm duration (min) = ", par_dur_min
print "eruption duration (month) = ", er_dur_mo
print "eruption duration (day) = ", er_dur_day
print "eruption duration (h) = ", er_dur_h
print "total eruption duration (mo) = ", toter_dur_mo
print "total eruption duration (day) = ", toter_dur_day
print "total eruption duration (h) = ", toter_dur_h
print "total eruption duration (min) = ", toter_dur_min


with open("sample_duration1.py", "w") as f1:
	f1.write("paroxysm_duration_h = "), f1.write(par_dur_h), f1.write('\n')
	f1.write("paroxysm_duration_min = "), f1.write(par_dur_min), f1.write('\n')
	f1.write("eruption_duration_mo = "), f1.write(er_dur_mo), f1.write('\n')
	f1.write("eruption_duration_day = "), f1.write(er_dur_day), f1.write('\n')
	f1.write("eruption_duration_h = "), f1.write(er_dur_h), f1.write('\n')
	f1.write("toteruption_duration_mo = "), f1.write(toter_dur_mo), f1.write('\n')
	f1.write("toteruption_duration_day = "), f1.write(toter_dur_day), f1.write('\n')
	f1.write("toteruption_duration_h = "), f1.write(toter_dur_h), f1.write('\n')
	f1.write("toteruption_duration_min = "), f1.write(toter_dur_min)
	f1.close()
print '\n'
print "Done"
