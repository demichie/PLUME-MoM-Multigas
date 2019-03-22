import glob
import os
import numpy as np
from parameters_range_Probmap import folder_name, ML_value_1, ML_value_2, ML_value_3, ML_value_4, ML_value_5 

#read from last file
folder_name1=str(folder_name+str("/ML_SITES_*"))
list_of_files1 = glob.glob(folder_name1)
latest_file1 = str(min(list_of_files1, key=os.path.getctime))[85:]
matrix1 = np.loadtxt(latest_file1)[:, [0, 1]]


folder_name2=str(folder_name+str("/ML_SITES_*"))
list_of_files2 = glob.glob(folder_name2)
latest_file2 = str(min(list_of_files2, key=os.path.getctime))[85:]
matrix2 = np.loadtxt(latest_file2)[:, [2]]
b1 = matrix2 > ML_value_1
matrix3_1 = b1.astype(int)
b2 = matrix2 > ML_value_2
matrix3_2 = b2.astype(int)
b3 = matrix2 > ML_value_3
matrix3_3 = b3.astype(int)
b4 = matrix2 > ML_value_4
matrix3_4 = b4.astype(int)
b5 = matrix2 > ML_value_5
matrix3_5 = b5.astype(int)

i = 1
while os.path.exists("matrix_end%s_%s.txt" % (ML_value_1, i)):
	i += 1
	while os.path.exists("matrix_end%s_%s.txt" % (ML_value_2, i)):
		i += 1
		while os.path.exists("matrix_end%s_%s.txt" % (ML_value_3, i)):
			i += 1
			while os.path.exists("matrix_end%s_%s.txt" % (ML_value_4, i)):
				i += 1
				while os.path.exists("matrix_end%s_%s.txt" % (ML_value_5, i)):
					i += 1

with open("matrix_end%s_%s.txt" % (ML_value_1, i), "w") as f1,  open("matrix_end%s_%s.txt" % (ML_value_2, i), "w") as f2, open("matrix_end%s_%s.txt" % (ML_value_3, i), "w") as f3, open("matrix_end%s_%s.txt" % (ML_value_4, i), "w") as f4, open("matrix_end%s_%s.txt" % (ML_value_5, i), "w") as f5, open("coordinates.txt", "w") as f6:
	np.savetxt(f1, matrix3_1)
	np.savetxt(f2, matrix3_2)
	np.savetxt(f3, matrix3_3)
	np.savetxt(f4, matrix3_4)
	np.savetxt(f5, matrix3_5)
	np.savetxt(f6, matrix1)

	
