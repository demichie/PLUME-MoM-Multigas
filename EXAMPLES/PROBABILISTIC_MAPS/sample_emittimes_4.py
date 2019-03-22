print "Sampling emission times (yr,mo,day,h,min)"
print '\n'
from parameters_range_Probmap import meteo_start_year, meteo_end_year
from random import randint, choice
from sample_duration1 import toteruption_duration_mo, toteruption_duration_day, toteruption_duration_h, toteruption_duration_min
#choose starting year
year = 15
year_st=str(year)
#choose starting month
for i in range(1):
	month=randint(8,12)
	break



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



# month, day and hour check
if minu >= 60:
	hour = hour + 1
	minu = minu - 60
if hour >= 24:
	day= day + 1
	hour = hour - 24

hour_forfile=str(hour)
min_forfile=str(minu)

if month == 8 and day < 14:
	day = 14
if month == 12:
	day = 1 


if month == 9 and day > 30:
	day= day - 30
	month= month + 1
elif month == 11 and day > 30:
	day= day - 30
	month= month + 1

if month == 8 and day > 31:
	day= day - 31
	month= month + 1
elif month == 10 and day > 31:
	day= day - 31
	month= month + 1
elif month == 12 and day > 31:
	day= day - 31
	month= month + 1

month_forfile=str(month)

month_st=str(month)
month_st0=str(0)
if month_st is "8":
	month_st=month_st0+month_st
elif month_st is "9":
	month_st=month_st0+month_st

day_forfile=str(day)

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

with open("sample_emittimes_output.py", "w") as f2:
	f2.write('Start_simulation_year = '), f2.write(year_st), f2.write('\n')
	f2.write('Start_simulation_month = '), f2.write(month_forfile), f2.write('\n')
	f2.write('Start_simulation_day = '), f2.write(day_forfile), f2.write('\n')
	f2.write('Start_simulation_hour = '), f2.write(hour_forfile), f2.write('\n')
	f2.write('Start_simulation_minute = '), f2.write(min_forfile), f2.write('\n')
	
print "start emission ", year_st, month_st, day_st, hour_st, min_st

#choose end year
year_end = str(15)

#choose end month
month_end=str(int(month_st)+int(toteruption_duration_mo))

#choose end day
day_end=str(int(day_st)+int(toteruption_duration_day))

#choose end hour, min
hour_end=str(int(hour_st)+int(toteruption_duration_h))
min_end=str(int(min_st)+int(toteruption_duration_min))

#control 2
month_end=int(month_end)
day_end=int(day_end)
hour_end=int(hour_end)
min_end=int(min_end)


#hour and minute check
if min_end >= 60:
	hour_end=int(hour_end)+int(1)
	min_end=int(min_end)-int(60)
if hour_end >= 24:
	day_end=int(day_end)+int(1)
	hour_end=int(hour_end)-int(24)


#day and month+year check
if month_end == 9 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)
elif month_end == 11 and day_end > 30:
	day_end=int(day_end)-int(30)
	month_end=int(month_end)+int(1)

if month_end == 8 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 10 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)
elif month_end == 12 and day_end > 31:
	day_end=int(day_end)-int(31)
	month_end=int(month_end)+int(1)

#4th month and year check
if month_end >12:
	month_end=str(12)
	
#change format - end emission

month_end=str(month_end)
day_end=str(day_end)
hour_end=str(hour_end)
min_end=str(min_end)
year_end0=str(0)
month_end0=str(0)
day_end0=str(0)
hour_end0=str(0)
min_end0=str(0)

with open("sample_emittimes_output.py", "a") as f2:
	f2.write('End_emission_year = '), f2.write(year_end), f2.write('\n')
	f2.write('End_emission_month = '), f2.write(month_end), f2.write('\n')
	f2.write('End_emission_day = '), f2.write(day_end), f2.write('\n')
	f2.write('End_emission_hour = '), f2.write(hour_end), f2.write('\n')
	f2.write('End_emission_minute = '), f2.write(min_end), f2.write('\n')
	f2.close()


if month_end is "8":
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

# month and day check
if month_end == 8 and day_end <14:
	day_end = str(14)
if month_end == 12 and day_end >7:
	day_end = day_st0 + str(7)


print "end emission ", year_end, month_end, day_end, hour_end, min_end


#choose end simulation year,month,day, hour, min
year_endsim1 = 15
year_endsim =str(year_endsim1)
month_endsim=int(month_end)
day_endsim=int(int(day_end)+int(1))
hour_endsim=str(hour_end)
min_endsim=str(min_end)

	
#1st month and year check
if month_endsim >12:
	month_endsim=str(12)
	
#2nd day and month+year check
if month_endsim == 9 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 11 and day_endsim > 30:
	day_endsim=int(day_endsim)-int(30)
	month_endsim=int(month_endsim)+int(1)

if month_endsim == 8 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 10 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)
elif month_endsim == 12 and day_endsim > 31:
	day_endsim=int(day_endsim)-int(31)
	month_endsim=int(month_endsim)+int(1)

#change format - end simulation
month_endsim=str(month_endsim)

day_endsim=str(day_endsim)

month_endsim0=str(0)
day_endsim0=str(0)

if month_endsim is "8":
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

# month and day check
if month_endsim == 8 and day_endsim <14:
	day_endsim = str(14)
if month_endsim == 12 and day_endsim >7:
	day_endsim = day_st0 + str(7)

print "end simulation ", year_endsim, month_endsim, day_endsim, hour_endsim, min_endsim



#write to file
with open("sample_emittimes_output.txt", "w") as f1:
	f1.write('"'), f1.write(year_st), f1.write(" "), f1.write(month_st), f1.write(" "), f1.write(day_st), f1.write(" "), f1.write(hour_st), f1.write(" "), f1.write(min_st), f1.write('"'), f1.write('\n') 
	f1.write('"'), f1.write(year_end), f1.write(" "), f1.write(month_end), f1.write(" "), f1.write(day_end), f1.write(" "), f1.write(hour_end), f1.write(" "), f1.write(min_end), f1.write('"'), f1.write('\n')
	f1.write('"'), f1.write(year_endsim), f1.write(" "), f1.write(month_endsim), f1.write(" "), f1.write(day_endsim), f1.write(" "), f1.write(hour_endsim), f1.write(" "), f1.write(min_endsim), f1.write('"')
	f1.close()
	
print '\n'
print "Done"
