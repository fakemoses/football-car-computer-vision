import os

# specify the path to the folder containing the files
folder_path = "negative/"

# get the list of files in the folder
files = os.listdir(folder_path)

# open the output file for writing
outfile = open("negative.txt", "w")

# write the file names, including the directory, to the output file
for file in files:
  outfile.write(folder_path + "/" + file + "\n")

# close the output file
outfile.close()