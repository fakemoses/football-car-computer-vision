# go to html folder
# look for all html files
# for each html file
#   read the file
# remove "Processing_CaptureJavaRT2022_012regler_MODULAR101_PID."


import os


folder = "Output/html"

for filename in os.listdir(folder):
    if filename.endswith(".html"):
        print(os.path.join(folder, filename))
        with open(os.path.join(folder, filename), 'r') as f:
            data = f.read()
            data = data.replace("Processing_CaptureJavaRT2022_012regler_MODULAR101_PID.", "")
        with open(os.path.join(folder, filename), 'w') as f:
            f.write(data)
    else:
        continue


# again loop for every file
# look for '<h2 class="groupheader">Constructor &amp; Destructor Documentation</h2>'

for filename in os.listdir(folder):
    if filename.endswith(".html"):
        # print(os.path.join(folder, filename))
        with open(os.path.join(folder, filename), 'r') as f:
            
            # get file name
            file_name = filename.split(".")[0]
            # remove html\interface_processing___capture_java_r_t2022__012regler___m_o_d_u_l_a_r101___p_i_d_1_1_i_
            file_name = file_name.replace("class_processing___capture_java_r_t2022__012regler___m_o_d_u_l_a_r101___p_i_d_1_1_", "")

            nameArray = file_name.split("_")
            
            #combine with CamelCase
            finalName = ""
            for name in nameArray:
                finalName += name.capitalize()

            print(finalName)

            data = f.read()

            # find finalName.
            # replace with ""
            data = data.replace(finalName + ".", "")
        
        with open(os.path.join(folder, filename), 'w') as f:
            f.write(data)
    else:
        continue
