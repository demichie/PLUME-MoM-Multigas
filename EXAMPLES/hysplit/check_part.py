import numpy as np
import sys
from haversine import haversine
import os

GROUND=[]
AIR=[]

#print npart, n_levels, H_LEVELS
print ' '
print '*** MASS ON THE GROUND ***'
print ' '
# Check mass deposited on the ground

fname = 'CON2ASC.GROUND'

with open(fname) as f:

    for line in f:
         total_mass = 0
         filename = line.strip() 
         time = line.strip()[-4:]
         day = line.strip()[-8:-5]
           
         print ' ---> day and time ',day,' ',time,' '

         f = open(filename)
         data = f.read()
         first_line = data.split('\n', 1)[0]
        
         line_split = first_line.split()

         m = []        

         for j in range(99):

             h_new = []

             to_find = 'CL'+str(int(j)).zfill(2)

             occurrence = 0
             
             for i in range(len(line_split)):

                 if to_find in  line_split[i]:

                     occurrence = occurrence + 1

                     h_new.append(int(line_split[i][4:]))


             if occurrence > 0 :

                 h_old=np.asarray(h_new)

                 h_old=h_old.reshape((-1,1))

                 m.append([j,occurrence])

                 n_height = h_old.shape[0]

             if occurrence == 0 :
 
                 h = h_old
                                 
                 break                 

         m = np.asarray(m)
         m=m.reshape((-1,2))
        
         npart = m.shape[0]
         n_levels = h.shape[0]
         H_LEVELS = h

         #print 'Number of particle classes :'npart
         #print 'Heights :',H_LEVELS

         a = np.loadtxt(filename, skiprows = 1)
         
         if a.shape[0] == 0 :
         
             print 'No mass deposited at ',time
        
         else:

             a = np.asarray(a) 

             a = a.reshape((-1,(npart * n_levels + 4)))

             lat = a[:,2]

             lat = lat.reshape((-1,1))

             lon = a[:,3]

             lon = lon.reshape((-1,1))

             lon_unique = np.unique(lon)

             lat_unique = np.unique(lat)

             lon_unique = lon_unique.reshape((-1,1))
             lat_unique = lat_unique.reshape((-1,1))

             spacing_lat = np.absolute(lat_unique[0,0] - lat_unique[1,0])

             spacing_lon = np.absolute(lon_unique[0,0] - lon_unique[1,0])

             dist = []

             for i in range(a.shape[0]):

                 point1 = ((lat[i,0]-spacing_lat/2),lon[i,0])
                 point2 = ((lat[i,0]+spacing_lat/2),lon[i,0])
                  
                 d_lat = haversine(point1, point2) 


                 point3 = (lat[i,0],(lon[i,0]-spacing_lon/2))
                 point4 = (lat[i,0],(lon[i,0]+spacing_lon/2))
                  
                 d_lon = haversine(point3, point4)       
                 
                 dist.append([d_lat*1000,d_lon*1000])

             dist = np.asarray(dist)
             dist = dist.reshape((-1,2))

             a = a[:,4:]

             a = a.reshape((-1,(npart * n_levels)))

             column = 0

             for i in range(npart):

                     conc = a[:, column]

                     conc = conc.reshape((-1,1))


                     mass_on_the_ground = np.sum(conc[:,0] * dist[:,0] * dist[:,1])

                     total_mass = total_mass +  mass_on_the_ground 

                     print 'class CL',str(i+1).zfill(2),' mass ','%.1e'%mass_on_the_ground,' kg'                  

                     column = column + n_levels

         print 'Total mass deposited ','%.1e'%total_mass,' kg'

         GROUND.append([int(time),int(day),total_mass])

         os.remove(filename)
         
         print ' '

print '*** MASS IN THE AIR ***'
print ' '
# Check mass still in the atmosphere

fname = 'CON2ASC.AIR'

with open(fname) as f:

    for line in f:
         total_mass = 0
         filename = line.strip() 
         time = line.strip()[-4:]
         day = line.strip()[-8:-5]
         print ' ---> day and time ',day,' ',time,' '
         a = np.loadtxt(filename, skiprows = 1)
         
         if a.shape[0] == 0 :
         
             print 'No in the atmosphere at ',time
        
         else:

             a = a.reshape((-1,(npart * n_levels + 4)))

             lat = a[:,2]

             lat = lat.reshape((-1,1))

             lon = a[:,3]

             lon = lon.reshape((-1,1))

             lon_unique = np.unique(lon)

             lat_unique = np.unique(lat)

             lon_unique = lon_unique.reshape((-1,1))
             lat_unique = lat_unique.reshape((-1,1))

             spacing_lat = np.absolute(lat_unique[0,0] - lat_unique[1,0])

             spacing_lon = np.absolute(lon_unique[0,0] - lon_unique[1,0])

             dist = []

             for i in range(a.shape[0]):

                 point1 = ((lat[i,0]-spacing_lat/2),lon[i,0])
                 point2 = ((lat[i,0]+spacing_lat/2),lon[i,0])
                  
                 d_lat = haversine(point1, point2) 


                 point3 = (lat[i,0],(lon[i,0]-spacing_lon/2))
                 point4 = (lat[i,0],(lon[i,0]+spacing_lon/2))
                  
                 d_lon = haversine(point3, point4)       
                 
                 dist.append([d_lat*1000,d_lon*1000])

                 #print 'd_lat, d_lon ',d_lat,d_lon

             dist = np.asarray(dist)
             dist = dist.reshape((-1,2))
 
             
             a = a[:,4:]

             a = a.reshape((-1,(npart * n_levels)))

             column = 0

             for i in range(npart):

                     for j in range(n_levels-1):

                         #print 'j ',j

                         #print  column + j + 1
  
                         conc = a[:, column + j + 1]
            

                         conc = conc.reshape((-1,1))

                         mass_in_the_air = np.sum(conc[:,0] * dist[:,0] * dist[:,1] * (int(H_LEVELS[j+1,0])-int(H_LEVELS[j,0])))

                        

                         total_mass = total_mass + mass_in_the_air

                         #total_mass = total_mass +  mass_on_the_ground 

                         #print 'class CL',str(i+1).zfill(2),' level ',H_LEVELS[j+1,0],'  mass ',mass_in_the_air,' kg'   

                     print 'class CL',str(i+1).zfill(2),'  mass ','%.1e'%mass_in_the_air,' kg'   

                         

                     column = column + n_levels

              
         print 'Total mass in the air ', '%.1e'%total_mass ,' kg'
         print ' '
          
         AIR.append([total_mass])
         os.remove(filename)

GROUND = np.asarray(GROUND)
AIR = np.asarray(AIR)

file_mass=open('mass_in_the_domain.part','w')

file_mass.writelines("Day    Time    Mass Deposited[kg]    Mass in the Air[kg]        Tot Mass[kg]\n")


for i in range(GROUND.shape[0]):

    #print '*** day', int(GROUND[i,1]),' time ',str(int(GROUND[i,0])).zfill(4),' ***'
    #print 'Mass deposited ', '%.1e'%GROUND[i,2]
    #print 'Mass in the air ',AIR[i,0]
    #print 'Mass in the domain ',GROUND[i,2] + AIR[i,0]
    tot = GROUND[i,2] + AIR[i,0]
    
    file_mass.writelines("%d    %04d    %.1e               %.1e                    %.1e\n"%(GROUND[i,1],GROUND[i,0],GROUND[i,2],AIR[i,0],tot))
    
file_mass.close()

          


