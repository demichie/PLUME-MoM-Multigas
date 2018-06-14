import Tkinter, tkFileDialog
import sys
import os
import re
import numpy as np
import matplotlib.pyplot as plt
import math
from matplotlib.pyplot import cm 
from mpl_toolkits.mplot3d import Axes3D
import easygui

filename = easygui.fileopenbox( filetypes=['*.col'])

filename = filename.split('/')[-1]
filename = re.sub('\.col$', '', filename)

class smf_array:
  pass


d1={}

with open("%s.col" % filename, "r") as file1:
    line=file1.readlines()
    header_line=line[0]
    header_split = header_line.split()
    n_part_org = 0
    n_part_agg = 0
    n_gas = 0


    for i in range(len(header_split)-1):


        d1["smf{0}".format(i)] = smf_array() 



        if header_split[i] == "sol.massfract":
             
            

            n_part_org = n_part_org +1
            
             
            d1["smf{0}".format(n_part_org)].org = n_part_org 

            d1["smf{0}".format(n_part_org)].column_org = i
       

            if header_split[i+1] == "agr.massfract":
                n_part_agg = n_part_agg + 1

                d1["smf{0}".format(n_part_org)].agg = n_part_agg
                d1["smf{0}".format(n_part_org)].column_agg = i+1

            else:

                d1["smf{0}".format(n_part_org)].agg = 0

        elif header_split[i] == "volgas.massf":
             n_gas = n_gas + 1

       

print 'number of original particles ', n_part_org
print 'number of aggregates ',n_part_agg
print 'number of volcanic gases ',n_gas



n_part = n_part_org + n_part_agg



results = np.loadtxt("%s.col" % filename, skiprows = 1)

file_moments = open("%s.mom" % filename, "r")
moments = file_moments.readlines()
file_moments.close()

n_mom = int(moments[1])

f = open("%s.mom" % filename, "r")
moments = f.readlines()[2:]
f.close()

moments=np.asarray(moments)

print 'number of moments ',n_mom


a=[]

for i in range(moments.shape[0]):
    a.append(moments[i].split())

a=np.asarray(a)
a=a[:,1:]


moments = a.reshape((results.shape[0],n_mom,n_part))




z_levels = moments.shape[0]
results=results.reshape((z_levels,-1))





z = results[:,0]/float(1000)
r_mt = results[:,1]
r = results[:,1]/float(1000)
x = results[:,2]/float(1000)
y = results[:,3]/float(1000)
rho_mix = results[:,4]
temp = results[:,5]
w = results[:,6]
mag_u = results[:,7]
dry_air_mass_fraction = results[:,8]
wvapour_mass_fraction = results[:,9]
liquid_water_mass_fraction = results[:,10]
ice_mass_fraction = results[:,11]

z=z.reshape((-1,1))
r_mt = r_mt.reshape((-1,1))
r = r.reshape((-1,1))
x = x.reshape((-1,1))
y = y.reshape((-1,1))
rho_mix = rho_mix.reshape((-1,1))
temp = temp.reshape((-1,1))
w = w.reshape((-1,1))
mag_u = mag_u.reshape((-1,1))
dry_air_mass_fraction = dry_air_mass_fraction.reshape((-1,1))
wvapour_mass_fraction = wvapour_mass_fraction.reshape((-1,1))
liquid_water_mass_fraction = liquid_water_mass_fraction.reshape((-1,1))
ice_mass_fraction = ice_mass_fraction.reshape((-1,1))



solid_partial_mass_fraction_org = np.zeros((results.shape[0],n_part_org))
solid_partial_mass_fraction_agg = np.zeros((results.shape[0],n_part_org))


for i in range(n_part_org):
    solid_partial_mass_fraction_org[:,i] = results[:,d1["smf"+str(i+1)].column_org]

    if d1["smf"+str(i+1)].agg != 0:
        solid_partial_mass_fraction_agg[:,i] = results[:,d1["smf"+str(i+1)].column_agg]
        



if n_gas == 0:

    volcgas_mass_fraction = np.zeros((results.shape[0],1))
    volcgas_mix_mass_fraction = np.zeros((results.shape[0],1))

else:

    volcgas_mass_fraction = np.zeros((results.shape[0],n_gas))

    for i in range(n_gas):

        volcgas_mass_fraction[:,i] = results[:,12+n_part+i]

    volcgas_mix_mass_fraction = results[:,12+n_part+n_gas]

#print volcgas_mass_fraction

volcgas_mass_fraction_tot = np.sum(volcgas_mass_fraction, axis = 1)
volcgas_mass_fraction_tot=volcgas_mass_fraction_tot.reshape((-1,1))

gas_mass_fraction = np.zeros((results.shape[0],1))

for i in range(gas_mass_fraction.shape[0]):
    gas_mass_fraction[i,0] = dry_air_mass_fraction[i,0] + wvapour_mass_fraction[i,0] + volcgas_mass_fraction_tot[i,0] 


solid_mass_fraction_org = np.zeros((results.shape[0],n_part_org))
solid_mass_fraction_agg = np.zeros((results.shape[0],n_part_org))

for i in range(n_part_org):
    solid_mass_fraction_org[:,i] = results[:,d1["smf"+str(i+1)].column_org] * ( 1 - gas_mass_fraction[:,0] - ice_mass_fraction[:,0] - liquid_water_mass_fraction[:,0])
    if d1["smf"+str(i+1)].agg != 0:
        solid_mass_fraction_agg[:,i] = results[:,d1["smf"+str(i+1)].column_agg] * ( 1 - gas_mass_fraction[:,0] - ice_mass_fraction[:,0] - liquid_water_mass_fraction[:,0])
       



solid_tot_mass_fraction_org = np.zeros((results.shape[0],1))
solid_tot_mass_fraction_org[:,0] = np.sum(solid_mass_fraction_org,axis=1)
solid_tot_mass_fraction_agg = np.zeros((results.shape[0],1))
solid_tot_mass_fraction_agg[:,0] = np.sum(solid_mass_fraction_agg,axis=1)

solid_tot_mass_fraction = solid_tot_mass_fraction_org + solid_tot_mass_fraction_agg


rho_atm = results[:,12+n_part+n_gas+1]
rho_atm = rho_atm.reshape((-1,1))

mfr = results[:,12+n_part+n_gas+2]
mfr = mfr.reshape((-1,1))

temp_atm = results[:,12+n_part+n_gas+3]
temp_atm = temp_atm.reshape((-1,1))

p_atm = results[:,12+n_part+n_gas+4]
p_atm = p_atm.reshape((-1,1))


n_z = z.shape[0]

rho_rel = rho_mix - rho_atm
rho_rel = rho_rel.reshape((-1,1))



# PLOT FIGURES

# MASS FRACTION 

fig = plt.figure()

plt.subplot(2, 2, 1)

lines = plt.plot(dry_air_mass_fraction,z, volcgas_mix_mass_fraction,z,wvapour_mass_fraction,z,gas_mass_fraction,z)

names = ['dry air','volcgas','wv','totalgas']

plt.legend(lines, [names[j] for j in range(len(names))])
plt.xlabel('Gas mass fraction')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 2)

water = wvapour_mass_fraction + liquid_water_mass_fraction + ice_mass_fraction

lines = plt.plot(wvapour_mass_fraction/water,z,'.',liquid_water_mass_fraction/water,z,'.', ice_mass_fraction/water, z,'.')

plt.xlabel('Water mass fraction')
plt.ylabel('Height (km)')
names = ['wv','lq','ice']

plt.legend(lines, [names[j] for j in range(len(names))])

plt.subplot(2, 2, 3)

color=iter(cm.rainbow(np.linspace(0,1,n_part_org)))

for i in range(n_part_org):
    c=next(color)
    plt.plot(solid_mass_fraction_org[:,i],z,'-', c=c, label="CL{0}".format(i+1))
    plt.plot(solid_mass_fraction_agg[:,i],z,'--', c=c)   
    #plt.plot(solid_mass_fraction_org[:,i] + solid_mass_fraction_agg[:,i],z,'*-', c=c)


plt.legend()

plt.xlabel('Particles mass fraction')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 4)

lines = plt.plot(solid_tot_mass_fraction ,z, gas_mass_fraction,z,liquid_water_mass_fraction,z, ice_mass_fraction, z,'--')

plt.xlabel('Phases mass fraction')
plt.ylabel('Height (km)')
names = ['part','gas','lq','ice']
plt.legend(lines, [names[j] for j in range(len(names))])
fig.tight_layout()
fig.savefig(str(filename)+'_mass_fraction.pdf')   # save the figure to file
#plt.close()


# temperature

fig = plt.figure()


plt.plot(temp+273,z)
plt.axvline(273, c = 'r')
plt.axvline(233, c = 'r')
#plt.plot(temp_atm,z,'.r')
plt.xlabel('Temp [K]')
plt.ylabel('Height (km)')
fig.savefig(str(filename)+'_temp.pdf')   # save the figure to file
#plt.close()

# ORG PARTICLE LOSS FRACTION - AGGR PARTICLE CREATION

fig = plt.figure()

solid_mass_flux_org = np.zeros((results.shape[0],n_part_org))
solid_mass_loss_org = np.zeros((results.shape[0],n_part_org))

solid_mass_flux_agg = np.zeros((results.shape[0],n_part_org))

solid_mass_loss_cum = np.zeros((results.shape[0],n_part_org))
solid_mass_flux = np.zeros((results.shape[0],n_part_org))


for i in range(n_part_org):

    solid_mass_flux_org[:,i] = solid_mass_fraction_org[:,i] * rho_mix[:,0] * math.pi * r_mt[:,0]**2 * mag_u[:,0] 

    solid_mass_loss_org[:,i] = solid_mass_flux_org[1,i] - solid_mass_flux_org[:,i]  

    solid_mass_flux_agg[:,i] = solid_mass_fraction_agg[:,i] * rho_mix[:,0] * math.pi * r_mt[:,0]**2 * mag_u[:,0] 
  
    solid_mass_flux[:,i] = ( solid_mass_fraction_org[:,i] + solid_mass_fraction_agg[:,i] ) * rho_mix[:,0] * math.pi * r_mt[:,0]**2 * mag_u[:,0] 
    
    solid_mass_loss_cum[:,i] =  1 - (solid_mass_flux[:,i]/float(solid_mass_flux[0,i]))

    plt.plot(solid_mass_loss_cum[:,i],z,'-' , label="CL{0}".format(i+1))


plt.legend()
plt.xlabel('Particles mass loss fraction')
plt.ylabel('Height (km)')



fig.savefig(str(filename)+'_particles_fraction.pdf')   # save the figure to file
#plt.close()

fig = plt.figure()

if n_part == 1:
    
    plt.subplot(1,4,1)
    plt.plot(moments[:,1]/moments[:,0],z)    
    plt.xlabel(r'$\mu$'"("r'$\phi$'")")

    
    
else:
    
    for i in range(n_part):
        
        plt.subplot(2,n_part,i+1)
        
        M0 = np.asarray(moments[:,0,i], dtype = float).reshape((-1,1))
        M1 = np.asarray(moments[:,1,i], dtype = float).reshape((-1,1))      
        plt.plot(M1[:,0]/M0[:,0],z)        
        plt.xlabel(r'$\mu$'"("r'$\phi$'")")
                           
    
    plt.ylabel('Height (km)')



if n_part == 1 :
    
    plt.subplot(1,4,2)
 
    sigma = np.zeros((results.shape[0],1)) 

    M0 = np.asarray(moments[:,0], dtype = float).reshape((-1,1))
    M1 = np.asarray(moments[:,1], dtype = float).reshape((-1,1))
    M2 = np.asarray(moments[:,2], dtype = float).reshape((-1,1))       
    M3 = np.asarray(moments[:,3], dtype = float).reshape((-1,1)) 

    sigma[:,0] = np.sqrt(M2[:,0]/M0[:,0]-(M1[:,0]/M0[:,0])**2)


    plt.plot(sigma,z)
   
    
    plt.xlabel(r'$\sigma$'"("r'$\phi$'")")
    plt.ylabel('Height (km)')

    plt.subplot(1,4,3)

    skew = np.zeros((results.shape[0],1)) 

    skew[:,0] = M3[:,0] - 3 * M1[:,0] * M2[:,0] + 2 * M1[:,0]**3      
 
    plt.plot(skew,z)

    plt.xlabel('Skew (\phi)'"("r'$\phi$'")")
    plt.ylabel('Height (km)')

    plt.subplot(1,4,4)
    plt.plot(100*solid_mass_loss_cum[:,i],z,'-')
    plt.xlabel('Solid Mass Flux lost (%)')
    plt.ylabel('Height (km)')

   
else:    
    
    for i in range(n_part):
        
        plt.subplot(2,n_part,n_part+i+1)                      
        sigma = np.zeros((results.shape[0],1))         

        M0 = np.asarray(moments[:,0,i], dtype = float).reshape((-1,1))
        M1 = np.asarray(moments[:,1,i], dtype = float).reshape((-1,1))
        M2 = np.asarray(moments[:,2,i], dtype = float).reshape((-1,1))       
        M3 = np.asarray(moments[:,3,i], dtype = float).reshape((-1,1))      
        sigma[:,0] = np.sqrt(M2[:,0]/M0[:,0]-(M1[:,0]/M0[:,0])**2)
        plt.plot(sigma,z,'.')
         
                        
        plt.xlabel(r'$\sigma$')
        plt.ylabel('Height (km)')

fig.tight_layout()
fig.savefig(str(filename)+'_moments.pdf')   # save the figure to file
#plt.close()

# VARIABLES

fig = plt.figure()

plt.subplot(2, 2, 1)

plt.plot(r,z)

plt.xlabel('Radius (km)')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 2)

plt.plot(w,z)

plt.xlabel('Velocity (m/s)')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 3)

plt.plot(rho_mix,z)

plt.xlabel('Mixture density (kg/m$^3$)')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 4)

plt.plot(rho_rel,z)
#plt.plot(rho_atm,z,'.r')

plt.xlabel('Relative density (kg/m$^3$)')
plt.ylabel('Height (km)')

fig.tight_layout()
fig.savefig(str(filename)+'_profiles.pdf')   # save the figure to file
#plt.close()

# plot plume 3d

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(x, y,z)

angle = np.linspace(0, 2*math.pi, num=50)
angle = angle.reshape((-1,1))

x_plume = np.cos(angle)
y_plume = np.sin(angle)

z_max = max(z)
z_min = min(z)

n_sect = 50

zeta_grid = np.linspace(z_min,z_max*0.99,num = n_sect)

l_seg = []

for i in range(1,x.shape[0],1):
    l_seg.append(((x[i,0]-x[i-1,0])**2 + (y[i,0]-y[i-1,0])**2 + (z[i,0]-z[i-1,0])**2)**0.5)

l_seg = np.asarray(l_seg)
l_seg = l_seg.reshape((-1,1))
    
s_axis = np.zeros((x.shape[0],1))

s_axis[0,0] = 0
s_axis[1:,0] =  np.cumsum (l_seg[:,0])

s_grid = np.linspace(0,max(s_axis)*0.99,num = n_sect)

for i in range(n_sect):
  
    ind0 =  np.where(s_axis[:,0]-s_grid[i]>0)
    ind0 = np.asarray(ind0)
    ind0 = ind0.reshape((-1,1))
    ind = min(ind0[:,0])
    
    vect = np.zeros((1,3))  
   
    vect[0,0] = x[ind,0] - x[ind-1,0]
    vect[0,1] = y[ind,0] - y[ind-1,0]
    vect[0,2] = z[ind,0] - z[ind-1,0]

    vect = vect / float(np.linalg.norm(vect, ord=2)) 
    
    vect0 = np.zeros((1,3))  

    vect0[0,0] = 0
    vect0[0,1] = 0
    vect0[0,2] = 1

    v = np.cross(vect0,vect)

    s = np.linalg.norm(v, ord=2)

    c = np.vdot(vect0,vect)

   
    mat_v = np.zeros((3,3))

    mat_v[1,0] = v[0,2]
    mat_v[0,1] = -v[0,2]
   
    mat_v[2,0] = -v[0,1]
    mat_v[0,2] = v[0,1]
   
    mat_v[1,2] = -v[0,0]
    mat_v[2,1] = v[0,0]



    R = np.eye(3) + mat_v + mat_v**2 * (1 - c) / s**2

    plume = np.zeros((3,x_plume.shape[0]))

    plume[0,:] = r[ind,0]*x_plume[:,0] 
    plume[1,:] = r[ind,0]*y_plume[:,0] 

    plume_rotated = np.dot(R, plume)

    ax.scatter(x[ind,0]+plume_rotated[0,:], y[ind,0]+plume_rotated[1,:],z[ind,0]+plume_rotated[2,:])

ax.set_xlabel('x (km)')
ax.set_ylabel('y (km)')
ax.set_zlabel('z (km)')
fig.tight_layout()   
fig.savefig(str(filename)+'_plume.pdf')   # save the figure to file

plt.show()


