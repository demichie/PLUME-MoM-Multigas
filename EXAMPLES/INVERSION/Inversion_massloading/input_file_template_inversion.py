hysplit_dir = "/home/alessandro/Codici/hysplit-new/trunk"
plumemom_dir = "/home/alessandro/Codici/PLUME-MoM-Multigas-master_v3"
runname = 'Tungu_2006'
starttime="06 08 17 02 15" # Year,month,day,hour,minute
endemittime = "06 08 17 06 15"
endruntime = "06 08 17 20 15"
deltat_plumemom = 3600  # seconds

lat = -1.467   # center latitude of the grid
lon = -78.442  # center longitude of the grid
model_top = 32000.0
meteo_file ='DATA.ARL'

spacing_lat = 0.06 # degrees between nodes of the sampling grid
spacing_lon = 0.06 # degrees between nodes of the sampling grid
span_lat = 3.00   # the total span of the grid in x direction. For instance, a span of 10 degrees would cover 5 degrees on each side of the center grid location
span_lon = 3.00   # the total span of the grid in y direction. For instance, a span of 10 degrees would cover 5 degrees on each side of the center grid location


vent_lat = -1.467  	# vent latitude
vent_lon = -78.442       # vent longitude
vent_height = 5023.00    # vent height above sea level (it can be different from ground level of meteo data at vent lat,lon)
vent_velocity = 200.0
#log10_mfr =

# volcanic gas parameters
ngas = 2   # in addition to H2O
rvolcgas = [189, 130 ] # CO2 and SO2 R constant [J/kgK]
cpvolcgas = [844, 640]
volcgas_mol_wt = [0.044, 0.064]
volcgas_mass_fraction = [0.01, 0.01]

#initial volcanic water mass fraction
#water_mass_fraction0 =

#flag for water condensation - freezing - addition of external liquid water at the vent
water_flag = 'F'

#external water parametes
rho_lw =  1000.0
rho_ice =  920.0
added_water_temp =  273.0
added_water_mass_fraction =  0.1

# hysplit parameters
deltaz_release = 200.0
ncloud = 5

# setup.cfg parameters
kmsl=0  	# starting heights default to AGL=0 or MSL=1 *** NOTE: please do not change it (kmsl=0) ***
ninit=1  	# particle initialization(0-none; 1-once; 2-add; 3-replace)
ndump=1  	# dump particles to/from file 0-none or nhrs-output intervall
ncycl=1 	# pardump output cycle time
numpar = 500	# number of puffs or particles to released per cycle
maxpar = 100000 # maximum number of particles carried in simulation
initd = 3 	# initial distribution, particle, puff, or combination.  0 = 3D particle (DEFAULT); 1 = Gh-THv; 2 = THh-THv; 3 = Gh-Pv; 4 = THh-Pv *** NOTE: please use initd=0 or initd=3 ***
delt = 15 	# hysplit integration step (minutes)
pinpf = ''
kmixd = 0       # flag for boundary layer depth. Default value, see HYSPLIT used guide
kmix0 = 250     # minimum mixing depth. Default value, see HYSPLIT used guide
kzmix = 0       # Vertical Mixing Profile. Default value, see HYSPLIT used guide
kdef = 0        # Horizontal Turbulence. Default value, see HYSPLIT used guide
kbls = 1        # Boundary Layer Stability. Default value, see HYSPLIT used guide
kblt = 2        # Vertical Turbulence. Default value, see HYSPLIT used guide
cmass = 0       # Compute grid concentrations (cmass=0) or grid mass (cmass=1) *** NOTE: please do not change it (cmass=0) ***

# CONTROL parameters
#SAMPLING INTERVAL
SI_TYPE = 0 # Avg:0 Now:1 Max:2 *** NOTE: please set (0) for delt not equal to SI_HOUR(or SI_MINUTE) ***
SI_HOUR = 1 # hrs *** NOTE: see above ***
SI_MINUTE = 0 # min *** NOTE: see above ***
#HEIGHT OF EACH CONCENTRATION LEVEL (m-msl)
H_LEVELS = '0 30000'



# particles parameters
npart = 10
diam1 = 0.00025
rho1 = 2478
diam2 = 0.002
rho2 = 1607
cp_part = 1610
#shapefactor = 0.6

partial_mass_fractions = [	0.0062,	0.0286,	0.0703,	0.1059,	0.1240,	0.1628,	0.2425,	0.1930,	0.0653,	0.0014	]
diam_phi = 		 [	-5,	-4,	-3,	-2,	-1,	0,	1,	2,	3,	4	]




