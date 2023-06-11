import os
import json
import shutil

def init_eval(source_folder, files):
    sourceCount = 0

    # add count if file ends with pde from source folder
    for file in os.listdir(source_folder):
        if file.endswith(".pde"):
            sourceCount += 1

    # add count if file ends with pde from files only read source
    fileCount = 0
    for file in files:
        source_files = file["source"]
        for src in source_files:
            if src.endswith(".pde"):
                fileCount += 1

    # if sourceCount is not equal to fileCount, then there is a file that is not read
    if sourceCount != fileCount:
        print("There is a file that is not read")
        print(f"sourceCount: {sourceCount}, fileCount: {fileCount}")
        exit(1)
    else:
        print("All files are read")

def create_folder_if_not_exists(folder):
    if not os.path.exists(folder):
        os.makedirs(folder)

def delete_folder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)

def combine_files(source_folder, target_folder, files):
    for file in files:
        source_files = file["source"]
        target_file = file["target"]
        source_files = [os.path.join(source_folder, filename) for filename in source_files]
        target_file = os.path.join(target_folder, target_file)
        print(f"Reading files: {', '.join([os.path.basename(filename) for filename in source_files])} -> {os.path.basename(target_file)}")

        for src in source_files:
            with open(src, 'r') as file:
                content = file.read()
            with open(target_file, 'a') as file:
                file.write(content)
            if len(source_files) > 1:
                with open(target_file, 'a') as file:
                    file.write('\n\n')

    print("Files combined successfully")

def main():
    with open('./.github/workflows/files.json', 'r') as file:
        data = json.load(file)

    source_folder = data["source_folder"]
    target_folder = data["target_folder"]
    files = data["files"]

    init_eval(source_folder, files)  # Check if all files are read

    delete_folder(target_folder)  # Delete destination folder and its content
    create_folder_if_not_exists(target_folder)  # Create destination folder

    combine_files(source_folder, target_folder, files)

if __name__ == "__main__":
    main()