#!/bin/sh

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

DUMP_ACC_PART="cdumpcum_part_$result"

echo "cdumpcum_part_$result"

# echo "-------------- extract loading and GSD at locs ---------------"

${MDL}/exec/con2stn -i$DUMP_ACC_PART -scon2stn.inp -d0 -p0 -xi -z1 -r0 -ocon2stn.txt


python extract_samples.py






