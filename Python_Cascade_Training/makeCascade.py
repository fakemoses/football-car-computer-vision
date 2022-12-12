# Import the necessary modules
import os
import cv2

# Define the dimensions of the images
IMAGE_WIDTH = 320
IMAGE_HEIGHT = 240

# Define the directories containing the images and labels
IMAGE_DIR = "images"
LABEL_DIR = "labels"

# Define the output file for the Haar cascade annotations
OUTPUT_FILE = "info_roboflow.txt"

# Create a dictionary to map the image filenames to their labels
image_labels = {}

# Iterate through the label files
for label_file in os.listdir(LABEL_DIR):
    # Open the label file
    with open(os.path.join(LABEL_DIR, label_file), "r") as f:
        # Iterate through the lines in the label file
        for line in f:
            # Split the line into columns
            columns = line.strip().split()
            # Get the filename and the bounding box coordinates
            filename = label_file.replace(".txt", ".jpg")
            x2 = int(float(columns[-2]) * IMAGE_WIDTH)
            y2 = int(float(columns[-1]) * IMAGE_HEIGHT)
            x1 = int(float(columns[-4]) * IMAGE_WIDTH) - int(x2/2)
            y1 = int(float(columns[-3]) * IMAGE_HEIGHT) - int(y2/2)
            # Save the bounding box coordinates in the dictionary
            image_labels[filename] = (x1, y1, x2, y2)

# Open the output file for writing
with open(OUTPUT_FILE, "w") as f:
    # Iterate through the image files
    for image_file in os.listdir(IMAGE_DIR):
        # Get the label for the image
        label = image_labels.get(image_file)
        # If the image has a label, write the annotation to the output file

        if label is not None:
            f.write(os.path.join(IMAGE_DIR, image_file) + " 1 " + " ".join(str(x) for x in label) + "\n")