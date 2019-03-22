#!/bin/sh

abort()
{
	echo >&2 '
********************
***** ABORTED ******
********************
'
	echo "An error occurred. Exiting..." >&2
	exit 1
}

trap 'abort' 0


set -e

a=$(grep -i 'iterations' parameters_range_Probmap.py | cut -c 13-21)

for i in $(seq $a)
do
	echo "### $0 ###"
	b=$(grep -i 'meteo_type' parameters_range_Probmap.py | cut -c 14)
	c=$(grep -i 'paroxysm_flag' parameters_range_Probmap.py | cut -c 17)
	d=$(grep -i 'plumeheight_flag' parameters_range_Probmap.py |cut -c 20)
	python sample_duration.py
	python sample_emittimes_$b.py
	python sample_mfr_$c.py
	python sample_TGSD.py
	python inputfile_generator_Probmap_$d.py
	
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

	#----------------------------------------------------------

	python run_plumemom.py 

	python create_hysplit_emittimes_control.py

	python create_hysplit_setup_ascdata.py
	 
	echo "-------------- particles dispersion simulation ---------------"

	${MDL}/exec/hycs_std part 
	 
	echo "-------------- start postprocessing ---------------"
	 
	${MDL}/exec/concacc -i$DUMP_PART -o$DUMP_ACC_PART

	${MDL}/exec/concsum -i$DUMP_ACC_PART -o$DUMP_SUM_PART

	${MDL}/exec/con2asc -icdumpsum_part_$result.bin -m -oML_SITES -x -z

	echo "-------------- end postprocessing ---------------"
	echo "------------ creating file for maps -------------"
	python create_file_for_Probmap.py
	echo "--------------------- done ----------------------"
	python clean_all_intermediate.py
done

python final_file_for_Probmap.py
python clean_all_Probmap.py

trap : 0




