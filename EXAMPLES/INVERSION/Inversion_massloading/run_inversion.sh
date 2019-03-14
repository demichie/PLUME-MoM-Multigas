#!/bin/sh

a=$(grep -i 'iterations' parameters_range_inversion.py | cut -c 13-21)
b=$(grep -i 'flag_plumeheight' parameters_range_inversion.py | cut -c 19-21)

for i in $(seq $a)
do
	python inputfile_generator_inversion_$b.py
	echo "### $0 ###"
	#-------------------------------------------------------------
	result=$(grep -i 'hysplit_dir' input_file.py | cut -c 15-)

	temp="${result%\"}"
	result="${temp#\"}"
	temp="${result%\'}"
	result="${temp#\'}"

	MDL="$result"

	result=$(grep -i 'runname' input_file.py | cut -c 11-)

	temp="${result%\"}"
	result="${temp#\"}"

	temp="${result%\'}"
	result="${temp#\'}"

	DUMP_PART="cdump_part_$result"

	DUMP_ACC_PART="cdumpcum_part_$result"

	DUMP_SUM_PART="cdumpsum_part_$result"

	PDUMP_PART="pdump_part_$result"

	DUMP_GAS="cdump_gas_$result"

	DUMP_ACC_GAS="cdumpcum_gas_$result"

	DUMP_SUM_GAS="cdumpsum_gas_$result"

	PDUMP_GAS="pdump_gas_$result"

	#----------------------------------------------------------
	python run_plumemom.py 

	python create_hysplit_emittimes_control.py

	python create_hysplit_setup_ascdata.py
 
	echo "-------------- particles dispersion simulation ---------------"

	${MDL}/exec/hycs_std part  

	#echo "-------------- gas dispersion simulation ---------------"

	#${MDL}/exec/hycs_std gas  

	echo "-------------- start postprocessing ---------------"

	${MDL}/exec/concacc -i$DUMP_PART -o$DUMP_ACC_PART

	${MDL}/exec/concsum -i$DUMP_ACC_PART -o$DUMP_SUM_PART

	#${MDL}/exec/concacc -i$DUMP_GAS -o$DUMP_ACC_GAS

	#${MDL}/exec/concsum -i$DUMP_ACC_GAS -o$DUMP_SUM_GAS

	echo "-------------- end postprocessing ---------------"
	echo "-------------- extract loading and GSD at locs ---------------"

	grep -A100000 POINTS input_file.py|grep -v "POINTS" > con2stn.tmp0

	sed 's/P/0/' con2stn.tmp0 > con2stn.tmp1
	sed 's/=/ /' con2stn.tmp1 > con2stn.tmp2
	sed 's/\[/ /' con2stn.tmp2 > con2stn.tmp3
	sed 's/,/ /' con2stn.tmp3 > con2stn.tmp4
	sed 's/\]//' con2stn.tmp4 > con2stn.tmp5
	sed '/^$/d' con2stn.tmp5 > con2stn.inp # elimina le ultime righe bianche dal file con2stn0.inp

	${MDL}/exec/con2stn -i$DUMP_ACC_PART -scon2stn.inp -d0 -p0 -xi -z1 -r0 -ocon2stn.txt

	python extract_samples.py

	rm con2stn.tmp*
	#----------------------------------------------------------
	python chi_square.py
	python create_output_$b.py
done

python clean_all_inversion.py





