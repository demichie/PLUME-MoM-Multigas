#!/bin/sh

echo "### $0 ###"


FILE="check_part.out"

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

#----------------------------------------------------------

echo "-------------- check mass ---------------"

${MDL}/exec/con2asc -i$DUMP_PART -t -x -z

mv CON2ASC.OUT CON2ASC.AIR

${MDL}/exec/con2asc -i$DUMP_ACC_PART -t -x -z

mv CON2ASC.OUT CON2ASC.GROUND

python check_part.py > $FILE

rm CON2ASC.GROUND
rm CON2ASC.AIR


echo
echo "Created 1) check_part.out 2) mass_in_the_domain.part"
