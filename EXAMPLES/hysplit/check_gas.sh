#!/bin/sh

echo "### $0 ###"


FILE="check_gas.out"

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

DUMP_GAS="cdump_gas_$result"


#----------------------------------------------------------

echo "-------------- check mass ---------------"

${MDL}/exec/con2asc -i$DUMP_GAS -t -x -z

mv CON2ASC.OUT CON2ASC.AIR

python check_gas.py > $FILE

rm CON2ASC.AIR


echo
echo "Created 1) check_gas.out 2) mass_in_the_domain.gas"
