import os

# specify the paths to the two folders containing the image files
folder1_path = "img"
folder2_path = "labels"

# get the list of image files in each folder
folder1_files = [file for file in os.listdir(folder1_path) if file.endswith(".jpg")]
folder2_files = [file for file in os.listdir(folder2_path) if file.endswith(".txt")]

# make sure that the number of files in each folder is the same
if len(folder1_files) != len(folder2_files):
  print("Error: the two folders contain a different number of files")

# rename the files in each folder as numbers that correspond to each other
for i in range(len(folder1_files)):
  # get the base file name without the extension
  base_name = os.path.splitext(folder1_files[i])[0]

  # rename the .jpg file in the first folder
  os.rename(folder1_path + "/" + folder1_files[i], folder1_path + "/" + str(i) + ".jpg")

  # rename the .txt file in the second folder using the same base name
  os.rename(folder2_path + "/" + base_name + ".txt", folder2_path + "/" + str(i) + ".txt")
