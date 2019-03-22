print "Sampling emission times (yr,mo,day,h,min)"
print '\n'
from parameters_range_Probmap import meteo_start_year, meteo_end_year
from random import randint, choice
from sample_duration1 import toteruption_duration_mo, toteruption_duration_day, toteruption_duration_h, toteruption_duration_min
#choose starting year
for i in range(1):
	year=(randint(meteo_start_year,meteo_end_year))
	break


#choose starting month
month =12
if year == 18:
	year = randint(4, 17)
	
year_st_ff=str('"')+str(year)+str('"')
year_st=str(year)
year_st0=str(0)
if year_st is "0":
	year_st=year_st0+year_st
if year_st is "1":
	year_st=year_st0+year_st
elif year_st is "2":
	year_st=year_st0+year_st
elif year_st is "3":
	year_st=year_st0+year_st
elif year_st is "4":
	year_st=year_st0+year_st
elif year_st is "5":
	year_st=year_st0+year_st
elif year_st is "6":
	year_st=year_st0+year_st
elif year_st is "7":
	year_st=year_st0+year_st
elif year_st is "8":
	year_st=year_st0+year_st
elif year_st is "9":
	year_st=year_st0+year_st	

year_st_ff=str('"')+str(year_st)+str('"')


#choose starting day
for i in range(1):
	day=randint(1,31)
	break


#choose starting hour
for i in range(1):
	hour=randint(0,23)
	break


#choose starting minute
for i in range(1):
	minu=randint(0,59)
	break

month_st_ff=str(month)
month_st1=month
month_st=str(month)
month_st0=str(0)
if month_st is "1":
	month_st=month_st0+month_st
elif month_st is "2":
	month_st=month_st0+month_st
elif month_st is "3":
	month_st=month_st0+month_st
elif month_st is "4":
	month_st=month_st0+month_st
elif month_st is "5":
	month_st=month_st0+month_st
elif month_st is "6":
	month_st=month_st0+month_st
elif month_st is "7":
	month_st=month_st0+month_st
elif month_st is "8":
	month_st=month_st0+month_st
elif month_st is "9":
	month_st=month_st0+month_st
month_st_ff=str('"')+str(month_st)+str('"')

day_st_ff=str(day)
day_st=str(day)
day_st0=str(0)
if day_st is "1":
	day_st=day_st0+day_st
elif day_st is "2":
	day_st=day_st0+day_st
elif day_st is "3":
	day_st=day_st0+day_st
elif day_st is "4":
	day_st=day_st0+day_st
elif day_st is "5":
	day_st=day_st0+day_st
elif day_st is "6":
	day_st=day_st0+day_st
elif day_st is "7":
	day_st=day_st0+day_st
elif day_st is "8":
	day_st=day_st0+day_st
elif day_st is "9":
	day_st=day_st0+day_st

day_st_ff=str('"')+str(day_st)+str('"')

hour_st_ff=str(hour)
hour_st1=hour
hour_st=str(hour)
hour_st0=str(0)
if hour_st is "0":
	hour_st=hour_st0+hour_st
elif hour_st is "1":
	hour_st=hour_st0+hour_st
elif hour_st is "2":
	hour_st=hour_st0+hour_st
elif hour_st is "3":
	hour_st=hour_st0+hour_st
elif hour_st is "4":
	hour_st=hour_st0+hour_st
elif hour_st is "5":
	hour_st=hour_st0+hour_st
elif hour_st is "6":
	hour_st=hour_st0+hour_st
elif hour_st is "7":
	hour_st=hour_st0+hour_st
elif hour_st is "8":
	hour_st=hour_st0+hour_st
elif hour_st is "9":
	hour_st=hour_st0+hour_st

hour_st_ff=str('"')+str(hour_st)+str('"')

min_st_ff=str(minu)
min_st1=minu
min_st=str(minu)
min_st0=str(0)
if min_st is "0":
	min_st=min_st0+min_st
elif min_st is "1":
	min_st=min_st0+min_st
elif min_st is "2":
	min_st=min_st0+min_st
elif min_st is "3":
	min_st=min_st0+min_st
elif min_st is "4":
	min_st=min_st0+min_st
elif min_st is "5":
	min_st=min_st0+min_st
elif min_st is "6":
	min_st=min_st0+min_st
elif min_st is "7":
	min_st=min_st0+min_st
elif min_st is "8":
	min_st=min_st0+min_st
elif min_st is "9":
	min_st=min_st0+min_st

min_st_ff=str('"')+str(min_st)+str('"')


#choose end year
year_end=str(year_st)
year_end0=str(0)
if year_end is "0":
	year_end=year_end0+year_end

#choose end month
month_st2=int(month_st)

month_end=str(int(month_st2)+int(toteruption_duration_mo))

#choose end day
day_end=str(int(day_st)+int(toteruption_duration_day))

#choose end hour, min
hour_end=str(int(hour_st)+int(toteruption_duration_h))
min_end=str(int(min_st)+int(toteruption_duration_min))

#control
year_end=int(year_end)
month_end=int(month_end)
day_end=int(day_end)
hour_end=int(hour_end)
min_end=int(min_end)


#1st month and year check
if month_end > 12:
	month_end=int(month_end)-int(12)
	year_end=int(year_end)+int(1)
elif month_end >9 and year_end is "18":
	month_end = 9
	day_end = 29

if month_end == 9 and year_end is "18" and day > day_end:
	day_st = str(28)

day_st_ff=str('"')+str(day_st)+str('"')
	
#2nd hour and minute check
if min_end >= 60:
	hour_end=int(hour_end)+int(1)
	min_end=int(min_end)-int(60)
if hour_end >= 24:
	day_end=int(day_end)+int(1)
	hour_end=int(hour_end)-int(24)


#3rd day and month+year check
if month_end == 4 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)
elif month_end == 6 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)
elif month_end == 9 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)
elif month_end == 11 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)

if month_end == 1 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 3 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 5 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 7 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 8 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 10 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 12 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)

elif year_end == 4 and month_end == 2 and day_end > 29:
	day_end=int(day_end)-int(29)
	month_end=int(month_end)+int(1)
elif year_end == 8 and month_end == 2 and day_end > 29:
	day_end=int(day_end)-int(29)
	month_end=int(month_end)+int(1)
elif year_end == 12 and month_end == 2 and day_end > 29:
	day_end=int(day_end)-int(29)
	month_end=int(month_end)+int(1)
elif year_end == 16 and month_end == 2 and day_end > 29:
	day_end=int(day_end)-int(29)
	month_end=int(month_end)+int(1)

elif year_end != 4 and month_end == 2 and day_end > 28:
	day_end=int(day_end)-int(28)
	month_end=int(month_end)+int(1)
elif year_end != 8 and month_end == 2 and day_end > 28:
	day_end=int(day_end)-int(28)
	month_end=int(month_end)+int(1)
elif year_end != 12 and month_end == 2 and day_end > 28:
	day_end=int(day_end)-int(28)
	month_end=int(month_end)+int(1)
elif year_end != 16 and month_end == 2 and day_end > 28:
	day_end=int(day_end)-int(28)
	month_end=int(month_end)+int(1)


#change format - end emission

month_end=str(month_end)
year_end=str(year_end)
day_end=str(day_end)
hour_end=str(hour_end)
min_end=str(min_end)
month_end_ff=str(month_end)
year_end_ff=str(year_end)
day_end_ff=str(day_end)
hour_end_ff=str(hour_end)
min_end_ff=str(min_end)
year_end0=str(0)
month_end0=str(0)
day_end0=str(0)
hour_end0=str(0)
min_end0=str(0)
if year_end is "0":
	year_end=year_end0+year_end
elif year_end is "1":
	year_end=year_end0+year_end
elif year_end is "2":
	year_end=year_end0+year_end
elif year_end is "3":
	year_end=year_end0+year_end
elif year_end is "4":
	year_end=year_end0+year_end
elif year_end is "5":
	year_end=year_end0+year_end
elif year_end is "6":
	year_end=year_end0+year_end
elif year_end is "7":
	year_end=year_end0+year_end
elif year_end is "8":
	year_end=year_end0+year_end
elif year_end is "9":
	year_end=year_end0+year_end

if month_end is "1":
	month_end=month_end0+month_end
elif month_end is "2":
	month_end=month_end0+month_end
elif month_end is "3":
	month_end=month_end0+month_end
elif month_end is "4":
	month_end=month_end0+month_end
elif month_end is "5":
	month_end=month_end0+month_end
elif month_end is "6":
	month_end=month_end0+month_end
elif month_end is "7":
	month_end=month_end0+month_end
elif month_end is "8":
	month_end=month_end0+month_end
elif month_end is "9":
	month_end=month_end0+month_end

if day_end is "1":
	day_end=day_end0+day_end
elif day_end is "2":
	day_end=day_end0+day_end
elif day_end is "3":
	day_end=day_end0+day_end
elif day_end is "4":
	day_end=day_end0+day_end
elif day_end is "5":
	day_end=day_end0+day_end
elif day_end is "6":
	day_end=day_end0+day_end
elif day_end is "7":
	day_end=day_end0+day_end
elif day_end is "8":
	day_end=day_end0+day_end
elif day_end is "9":
	day_end=day_end0+day_end

if hour_end is "0":
	hour_end=hour_end0+hour_end
elif hour_end is "1":
	hour_end=hour_end0+hour_end
elif hour_end is "2":
	hour_end=hour_end0+hour_end
elif hour_end is "3":
	hour_end=hour_end0+hour_end
elif hour_end is "4":
	hour_end=hour_end0+hour_end
elif hour_end is "5":
	hour_end=hour_end0+hour_end
elif hour_end is "6":
	hour_end=hour_end0+hour_end
elif hour_end is "7":
	hour_end=hour_end0+hour_end
elif hour_end is "8":
	hour_end=hour_end0+hour_end
elif hour_end is "9":
	hour_end=hour_end0+hour_end

if min_end is "0":
	min_end=min_end0+min_end
elif min_end is "1":
	min_end=min_end0+min_end
elif min_end is "2":
	min_end=min_end0+min_end
elif min_end is "3":
	min_end=min_end0+min_end
elif min_end is "4":
	min_end=min_end0+min_end
elif min_end is "5":
	min_end=min_end0+min_end
elif min_end is "6":
	min_end=min_end0+min_end
elif min_end is "7":
	min_end=min_end0+min_end
elif min_end is "8":
	min_end=min_end0+min_end
elif min_end is "9":
	min_end=min_end0+min_end

year_end_ff=str('"')+str(year_end)+str('"')
month_end_ff=str('"')+str(month_end)+str('"')
day_end_ff=str('"')+str(day_end)+str('"')
hour_end_ff=str('"')+str(hour_end)+str('"')
min_end_ff=str('"')+str(min_end)+str('"')

with open("sample_emittimes_output.py", "w") as f2:
	f2.write('Start_simulation_year = '), f2.write(year_st_ff), f2.write('\n')
	f2.write('Start_simulation_month = '), f2.write(month_st_ff), f2.write('\n')
	f2.write('Start_simulation_day = '), f2.write(day_st_ff), f2.write('\n')
	f2.write('Start_simulation_hour = '), f2.write(hour_st_ff), f2.write('\n')
	f2.write('Start_simulation_minute = '), f2.write(min_st_ff), f2.write('\n')
	f2.write('End_emission_year = '), f2.write(year_end_ff), f2.write('\n')
	f2.write('End_emission_month = '), f2.write(month_end_ff), f2.write('\n')
	f2.write('End_emission_day = '), f2.write(day_end_ff), f2.write('\n')
	f2.write('End_emission_hour = '), f2.write(hour_end_ff), f2.write('\n')
	f2.write('End_emission_minute = '), f2.write(min_end_ff), f2.write('\n')
	f2.close()


print "start emission ", year_st, month_st, day_st, hour_st, min_st
print "end emission ", year_end, month_end, day_end, hour_end, min_end


#choose end simulation year,month,day, hour, min
year_endsim=int(year_end)
year_endsim0=str(0)
if year_endsim is "0":
	year_endsim=year_endsim0+year_endsim
month_endsim=int(month_end)
day_endsim=int(int(day_end)+int(1))
hour_endsim=str(hour_end)
min_endsim=str(min_end)

#1st month and year check
if month_endsim >12:
	month_endsim=int(month_endsim)-int(12)
	year_endsim=int(year_endsim)+int(1)


#2nd day and month+year check
if month_endsim == 4 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 6 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 9 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 11 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)

if month_endsim == 1 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 3 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 5 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 7 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 8 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 10 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 12 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)

elif year_endsim == 4 and month_endsim == 2 and day_endsim > 29:
	day_endsim=int(day_endsim)-int(29)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim == 8 and month_endsim == 2 and day_endsim > 29:
	day_endsim=int(day_endsim)-int(29)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim == 12 and month_endsim == 2 and day_endsim > 29:
	day_endsim=int(day_endsim)-int(29)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim == 16 and month_endsim == 2 and day_endsim > 29:
	day_endsim=int(day_endsim)-int(29)
	month_endsim=int(month_endsim)+int(1)

elif year_endsim != 4 and month_endsim == 2 and day_endsim > 28:
	day_endsim=int(day_endsim)-int(28)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim != 8 and month_endsim == 2 and day_endsim > 28:
	day_endsim=int(day_endsim)-int(28)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim != 12 and month_endsim == 2 and day_endsim > 28:
	day_endsim=int(day_endsim)-int(28)
	month_endsim=int(month_endsim)+int(1)
elif year_endsim != 16 and month_endsim == 2 and day_endsim > 28:
	day_endsim=int(day_endsim)-int(28)
	month_endsim=int(month_endsim)+int(1)

#3rd month and year check
if month_endsim >12:
	month_endsim=int(month_endsim)-int(12)
	year_endsim=int(year_endsim)+int(1)

#change format - end simulation
month_endsim=str(month_endsim)
year_endsim=str(year_endsim)
day_endsim=str(day_endsim)
year_endsim0=str(0)
month_endsim0=str(0)
day_endsim0=str(0)
if year_endsim is "1":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "2":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "3":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "4":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "5":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "6":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "7":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "8":
	year_endsim=year_endsim0+year_endsim
elif year_endsim is "9":
	year_endsim=year_endsim0+year_endsim

if month_endsim is "1":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "2":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "3":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "4":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "5":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "6":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "7":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "8":
	month_endsim=month_endsim0+month_endsim
elif month_endsim is "9":
	month_endsim=month_endsim0+month_endsim

if day_endsim is "1":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "2":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "3":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "4":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "5":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "6":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "7":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "8":
	day_endsim=day_endsim0+day_endsim
elif day_endsim is "9":
	day_endsim=day_endsim0+day_endsim



print "end simulation ", year_endsim, month_endsim, day_endsim, hour_endsim, min_endsim



#write to file
with open("sample_emittimes_output.txt", "w") as f:
	f.write('"'), f.write(year_st), f.write(" "), f.write(month_st), f.write(" "), f.write(day_st), f.write(" "), f.write(hour_st), f.write(" "), f.write(min_st), f.write('"'), f.write('\n'), 
	f.write('"'), f.write(year_end), f.write(" "), f.write(month_end), f.write(" "), f.write(day_end), f.write(" "), f.write(hour_end), f.write(" "), f.write(min_end), f.write('"'), f.write('\n'),
	f.write('"'), f.write(year_endsim), f.write(" "), f.write(month_endsim), f.write(" "), f.write(day_endsim), f.write(" "), f.write(hour_endsim), f.write(" "), f.write(min_endsim), f.write('"')
	f.close()

print '\n'
print "Done"
