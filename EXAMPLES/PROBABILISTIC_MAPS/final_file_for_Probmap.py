import numpy as np
import glob
import os
from parameters_range_Probmap import iterations, folder_name, ML_value_1, ML_value_2, ML_value_3, ML_value_4, ML_value_5

#file for end simulation
i=0
data_list_1 =[]
data_list_2 =[]
data_list_3 =[]
data_list_4 =[]
data_list_5 =[]

folder_name2_1=str(folder_name+str("/matrix_end%s_*" % ML_value_1))
list_of_files2_1 = glob.glob(folder_name2_1)
latest_file2_1 = str(max(list_of_files2_1, key=os.path.getctime))[85:]
matrix2_1 = np.loadtxt(latest_file2_1)
for i in range(iterations):
	data_list_1.append(np.loadtxt('matrix_end%s_{0}.txt'.format(i+1) % ML_value_1))



folder_name2_2=str(folder_name+str("/matrix_end%s_*" % ML_value_2))
list_of_files2_2 = glob.glob(folder_name2_2)
latest_file2_2 = str(max(list_of_files2_2, key=os.path.getctime))[85:]
matrix2_2 = np.loadtxt(latest_file2_2)
for i in range(iterations):
	data_list_2.append(np.loadtxt('matrix_end%s_{0}.txt'.format(i+1) % ML_value_2))

folder_name2_3=str(folder_name+str("/matrix_end%s_*" % ML_value_3))
list_of_files2_3 = glob.glob(folder_name2_3)
latest_file2_3 = str(max(list_of_files2_3, key=os.path.getctime))[85:]
matrix2_3 = np.loadtxt(latest_file2_3)
for i in range(iterations):
	data_list_3.append(np.loadtxt('matrix_end%s_{0}.txt'.format(i+1) % ML_value_3))

folder_name2_4=str(folder_name+str("/matrix_end%s_*" % ML_value_4))
list_of_files2_4 = glob.glob(folder_name2_4)
latest_file2_4 = str(max(list_of_files2_4, key=os.path.getctime))[85:]
matrix2_4 = np.loadtxt(latest_file2_4)
for i in range(iterations):
	data_list_4.append(np.loadtxt('matrix_end%s_{0}.txt'.format(i+1) % ML_value_4))

folder_name2_5=str(folder_name+str("/matrix_end%s_*" % ML_value_5))
list_of_files2_5 = glob.glob(folder_name2_5)
latest_file2_5 = str(max(list_of_files2_5, key=os.path.getctime))[85:]
matrix2_5 = np.loadtxt(latest_file2_5)
for i in range(iterations):
	data_list_5.append(np.loadtxt('matrix_end%s_{0}.txt'.format(i+1) % ML_value_5))

with open("coordinates.txt", "r") as f1:
	matrix1= np.loadtxt(f1)
matrix_end_ML_value_1 = (sum(data_list_1))/iterations
matrix_union_ML_value_1 = np.c_[matrix1, matrix_end_ML_value_1]
matrix_end_ML_value_2 = (sum(data_list_2))/iterations
matrix_union_ML_value_2 = np.c_[matrix1, matrix_end_ML_value_2]
matrix_end_ML_value_3 = (sum(data_list_3))/iterations
matrix_union_ML_value_3 = np.c_[matrix1, matrix_end_ML_value_3]
matrix_end_ML_value_4 = (sum(data_list_4))/iterations
matrix_union_ML_value_4 = np.c_[matrix1, matrix_end_ML_value_4]
matrix_end_ML_value_5 = (sum(data_list_5))/iterations
matrix_union_ML_value_5 = np.c_[matrix1, matrix_end_ML_value_5]




with open("matrix_sum_end_%s" % ML_value_1, "w") as f2, open("matrix_sum_end_%s" % ML_value_2, "w") as f3, open("matrix_sum_end_%s" % ML_value_3, "w") as f4, open("matrix_sum_end_%s" % ML_value_4, "w") as f5, open("matrix_sum_end_%s" % ML_value_5, "w") as f6:
	f2.write("Lat"),f2.write(" "), f2.write("Lon"), f2.write(" "), f2.write("Freq"), f2.write('\n')	
	np.savetxt(f2, matrix_union_ML_value_1)
	f3.write("Lat"),f3.write(" "), f3.write("Lon"), f3.write(" "), f3.write("Freq"), f3.write('\n')	
	np.savetxt(f3, matrix_union_ML_value_2)
	f4.write("Lat"),f4.write(" "), f4.write("Lon"), f4.write(" "), f4.write("Freq"), f4.write('\n')	
	np.savetxt(f4, matrix_union_ML_value_3)
	f5.write("Lat"),f5.write(" "), f5.write("Lon"), f5.write(" "), f5.write("Freq"), f5.write('\n')	
	np.savetxt(f5, matrix_union_ML_value_4)
	f6.write("Lat"),f6.write(" "), f6.write("Lon"), f6.write(" "), f6.write("Freq"), f6.write('\n')	
	np.savetxt(f6, matrix_union_ML_value_5)
