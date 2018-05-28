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





