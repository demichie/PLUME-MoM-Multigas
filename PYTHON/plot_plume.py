import Tkinter, tkFileDialog
import sys
import os
import re
import numpy as np
import matplotlib.pyplot as plt
import math
from mpl_toolkits.mplot3d import Axes3D
import easygui

filename = easygui.fileopenbox( filetypes=['*.bak'])

#pathname = os.getcwd()
#root = Tkinter.Tk()
#root.withdraw()
#filename= tkFileDialog.askopenfilename(filetypes=[('Pick a file','*.bak')])

#      z (m)             r (m)           x (m)          y (m)      mix.dens(kg/m3) temperature(C)  vert vel (m/s)  mag vel (m/s)   d.a. massfract  w.v. massfract  l.w. massfract  i. massfract  sol massfract  sol massfract   volgasmix.massf atm.rho(kg/m3)  MFR (kg/s)      atm.temp (K)    atm pres (Pa) 

filename = filename.split('/')[-1]
filename = re.sub('\.bak$', '', filename)

#filename='test_weak'
prova_bak = open("%s.bak" % filename, "r")
findpart = 'N_PART'
for num, line in enumerate(prova_bak, 1):
        if findpart in line:
            n_part = int(line[8:-2])
prova_bak.close()


prova_bak = open("%s.bak" % filename, "r")
findgas = 'N_GAS'
for num, line in enumerate(prova_bak, 1):
        if findgas in line:
            n_gas = int(line[7:-2])
prova_bak.close()

var = "%s" % filename
module = __import__(var)

prova = np.loadtxt("%s.col" % filename, skiprows = 1)

file_moments = open("%s.mom" % filename, "r")
moments = file_moments.readlines()
file_moments.close()

n_mom = int(moments[1])

f = open("%s.mom" % filename, "r")
moments = f.readlines()[2:]
f.close()

moments=np.asarray(moments)

a=[]

for i in range(moments.shape[0]):
    a.append(moments[i].split())

a=np.asarray(a)
moments=a.reshape((-1,int(n_part*(n_mom+1)+1)))

z_levels = moments.shape[0]

prova=prova.reshape((z_levels,-1))

if n_mom > 1:
    moments = moments[:,1:]
    if n_part == 1:
        moments0 = np.zeros((moments.shape[0],n_mom+1))
        moments0[:,:] = moments[:,:]
        moments=moments0
    else:
        moments0 = np.zeros((moments.shape[0],n_part,n_mom+1))

        for j in range(n_mom+1):
            for i in range(n_part):
                moments0[:,:,j] = moments[:,:n_part]
            moments=np.delete(moments, 0, 1)   
            moments=np.delete(moments, 0, 1)  
        moments=moments0
else:
    moments=moments[:,1:]

moments = np.asarray(moments)

z = prova[:,0]/float(1000)
r_mt = prova[:,1]
r = prova[:,1]/float(1000)
x = prova[:,2]/float(1000)
y = prova[:,3]/float(1000)
rho_mix = prova[:,4]
temp = prova[:,5]
w = prova[:,6]
mag_u = prova[:,7]
dry_air_mass_fraction = prova[:,8]
wvapour_mass_fraction = prova[:,9]
liquid_water_mass_fraction = prova[:,10]
ice_mass_fraction = prova[:,11]

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
solid_partial_mass_fraction = np.zeros((prova.shape[0],n_part))

for i in range(n_part):

    solid_partial_mass_fraction[:,i] = prova[:,12+i]

if n_gas == 0:

    volcgas_mass_fraction = np.zeros((prova.shape[0],1))
    volcgas_mix_mass_fraction = np.zeros((prova.shape[0],1))

else:

    volcgas_mass_fraction = np.zeros((prova.shape[0],n_gas))
    for i in range(n_gas):
        volcgas_mass_fraction[:,i] = prova[:,12+n_part+i]

    volcgas_mix_mass_fraction = prova[:,12+n_part+n_gas]


gas_mass_fraction = dry_air_mass_fraction + wvapour_mass_fraction + volcgas_mass_fraction 

solid_mass_fraction = np.zeros((prova.shape[0],n_part))

for i in range(n_part):
    solid_mass_fraction[:,i] = solid_partial_mass_fraction[:,i] * ( 1 - gas_mass_fraction[:,0] - ice_mass_fraction[:,0] - liquid_water_mass_fraction[:,0])

solid_tot_mass_fraction = np.zeros((prova.shape[0],1))

solid_tot_mass_fraction[:,0] = np.sum(solid_mass_fraction,axis=1)

rho_atm = prova[:,12+n_part+n_gas+1]
rho_atm = rho_atm.reshape((-1,1))


mfr = prova[:,12+n_part+n_gas+2]
mfr = mfr.reshape((-1,1))

temp_atm = prova[:,12+n_part+n_gas+3]
temp_atm = temp_atm.reshape((-1,1))

p_atm = prova[:,12+n_part+n_gas+4]
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

for i in range(n_part):

    plt.plot(solid_mass_fraction[:,i],z,'-')
    
plt.xlabel('Particles mass fraction')
plt.ylabel('Height (km)')

plt.subplot(2, 2, 4)

lines = plt.plot(solid_tot_mass_fraction,z, gas_mass_fraction,z,liquid_water_mass_fraction,z, ice_mass_fraction, z,'--')

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

# PARTICLE LOSS FRACTION

fig = plt.figure()

solid_mass_flux = np.zeros((prova.shape[0],n_part))
solid_mass_loss = np.zeros((prova.shape[0],n_part))
solid_mass_loss_cum = np.zeros((prova.shape[0],n_part))

for i in range(n_part):

    solid_mass_flux[:,i] = solid_mass_fraction[:,i] * rho_mix[:,0] * math.pi * r_mt[:,0]**2 * mag_u[:,0]    
       
    solid_mass_loss[:,i] = solid_mass_flux[1,i] - solid_mass_flux[:,i]  
    
    solid_mass_loss_cum[:,i] =  1 - (solid_mass_flux[:,i]/float(solid_mass_flux[0,i]))

    plt.plot(solid_mass_loss_cum[:,i],z,'-')


plt.xlabel('Particles mass loss fraction')
plt.ylabel('Height (km)')
fig.savefig(str(filename)+'_particles_loss_fraction.pdf')   # save the figure to file
#plt.close()



fig = plt.figure()

if n_part == 1:
    
    plt.subplot(1,4,1)
    plt.plot(moments[:,1]/moments[:,0],z)    
    plt.xlabel(r'$\mu$'"("r'$\phi$'")")

    
    
else:
    
    for i in range(n_part):
        
        plt.subplot(2,n_part,i+1)
        
        M0 = np.asarray(moments[:,i,0], dtype = float).reshape((-1,1))
        M1 = np.asarray(moments[:,i,1], dtype = float).reshape((-1,1))       
        plt.plot(M1[:,0]/M0[:,0],z)        
        plt.xlabel(r'$\mu$'"("r'$\phi$'")")
                           
    
    plt.ylabel('Height (km)')



if n_part == 1 :
    
    plt.subplot(1,4,2)
 
    sigma = np.zeros((prova.shape[0],1)) 

    M0 = np.asarray(moments[:,0], dtype = float).reshape((-1,1))
    M1 = np.asarray(moments[:,1], dtype = float).reshape((-1,1))
    M2 = np.asarray(moments[:,2], dtype = float).reshape((-1,1))       
    M3 = np.asarray(moments[:,3], dtype = float).reshape((-1,1)) 

    sigma[:,0] = np.sqrt(M2[:,0]/M0[:,0]-(M1[:,0]/M0[:,0])**2)


    plt.plot(sigma,z)
   
    
    plt.xlabel(r'$\sigma$'"("r'$\phi$'")")
    plt.ylabel('Height (km)')

    plt.subplot(1,4,3)

    skew = np.zeros((prova.shape[0],1)) 

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
        sigma = np.zeros((prova.shape[0],1))         

        M0 = np.asarray(moments[:,i,0], dtype = float).reshape((-1,1))
        M1 = np.asarray(moments[:,i,1], dtype = float).reshape((-1,1))
        M2 = np.asarray(moments[:,i,2], dtype = float).reshape((-1,1))       
        M3 = np.asarray(moments[:,i,3], dtype = float).reshape((-1,1))      
        sigma[:,0] = np.sqrt(M2[:,0]/M0[:,0]-(M1[:,0]/M0[:,0])**2)

        plt.plot(sigma,z)
                        
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
#plt.close()


plt.show()


