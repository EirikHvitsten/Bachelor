import os

def find_index(list, start_index, cur_height):
    for i in range(start_index+1, len(list)):
        if(list[i][1] == cur_height):
            return i

#print("\n")

file = open("DTPulsTekstAvstand3.txt", "r")
#read = file.read()
#print(read)

lines = file.readlines()

tuples = []
info_tuples = []
for line in lines:
    strip_line = line.strip()
    
    # GRUPPER I LISTE, SE ETTER HØYDE BASERT PÅ |---
    split_by_space = strip_line.split(" ")
    
    height_counter = 0
    for string in split_by_space:
        if string == '|---':
            # Store the lines of string together with their height as tuples
                # Add to a list to keep track
            if height_counter == 0:
                tup = (strip_line, height_counter)
                tuples.append(tup)
            else:
                node_height = int(height_counter / 3)

                tup = (strip_line, node_height)
                tuples.append(tup)
            break;
        else:
            height_counter += 1

    # Get the actual information
    if 'weights' in strip_line:
        idx = split_by_space.index('weights:')
        sep = " "
        info = sep.join(split_by_space[idx : len(split_by_space)])
        print(info)
        info_tuples.append(info)
    else:
        list_idx = None
        if split_by_space[-3].isnumeric():
            list_idx = split_by_space[-3]
        else:
            list_idx = split_by_space[-4]
        value = split_by_space[-1]
        print("Value : " + value + ", Index: " + list_idx)
        info_tuples.append((int(float(list_idx)), float(value)))
print("\n")

# Print the tuples
for tup in tuples:
    print(tup)
print("\n")

# For each tuple, find it's pair if it has one
    # Does not have one if the string contains 'weights'
checked_indexes = []
pairs = []
for index, tup in enumerate(tuples):
    streng = tup[0]
    hoyde = tup[1]

    # SØK ETTER WEIGHTS I STRENGEN
    if 'weights' in streng:
        # BLAD NODE, GJØR NOE MED DEN..
        #print(streng)
        print("WEIGHT at index: " + str(index))
    else:
        # VANLIG NODE, LAG IF ELSE FUNKSJON

        # Find the pair-node
        if index not in checked_indexes:
            first_node = index
            second_node = find_index(tuples, index, hoyde)

            # Mark the indexes as checked
            checked_indexes.append(first_node)
            if second_node != None:
                checked_indexes.append(second_node)

            print("The node at index: " + str(first_node) + " has a pair at index: " + str(second_node))

            pairs.append((first_node, second_node, hoyde+1))
print("\n")

for pair in pairs:
    print(pair)
print("\n")

for info in info_tuples:
    print(info)
print("\n")


# 1: Build a dictionary with all the information needed
# 2: Start from the back of the list
    # Build each if / else statement
        # Use the dictionary to know what to place inside the if / else
function_text = {}
for i in range(len(pairs)-1, -1, -1):
    # Find the values of our nodes
    first_index = pairs[i][0]
    second_index = pairs[i][1]
    list_index = info_tuples[first_index][0]
    value = info_tuples[first_index][1]

    # Get the height for tab-usage
    height = pairs[i][2]

    # Find the values of the children nodes
    if_child = info_tuples[first_index+1]
    else_child = info_tuples[second_index+1]

    # Write if / else statement
    # IF
    func_text = ""
    func_text += "\t"*height
    func_text += "if (list["+str(list_index)+"] <= "+str(value)+"){\n"
    if 'weights:' in if_child:
        func_text += "\t"*(height+1)
        func_text += "System.println(\""+if_child+"\");"
        func_text += "\n"
    else:
        #func_text += "\t"*(height+1)
        func_text += function_text[first_index+1]
        func_text += "\n"
    func_text += "\t"*height
    func_text += "}"
    # ELSE
    func_text += "else {\n"
    if 'weights:' in else_child:
        func_text += "\t"*(height+1)
        func_text += "System.println(\""+else_child+"\");"
        func_text += "\n"
    else:
        #func_text += "\t"*(height+1)
        func_text += function_text[second_index+1]
        func_text += "\n"
    func_text += "\t"*height
    func_text += "}"

    # Save node in the dictionary
    function_text[first_index] = func_text

# Build the base of the function
func_text = "function decTree(list){\n"
func_text += "\t" + function_text[0]
func_text += "\n}"

print(func_text)

# WRITE TO A NEW .MC FILE AND PUT INSIDE THE APP
    # REBUILD
# POTENTIALLY MAKE A LOOP OVER SEVERAL .TXT FILES
def bygg_fil(prosjekt_location, project_name, key, text_to_write):
    # Change to directory
    dir = project_location + project_name + "/resources/data"
    os.chdir(dir)

    # Write to file, overwrites the one that is there
    file = open("DecisionTree.mc", "w")
    file.write(text_to_write)
    file.close()

    os.system(
        "monkeyc -y " + key + " -f " + project_location+project_name+"/monkey.jungle " + "-o " + project_location+project_name+"/bin/"+project_name+".prg"
    )

# File locations
project_location = "C:/Users/magnu/eclipse-workspace/"
project_name = "SeveralDataFields"
key = "C:/Users/magnu/keys/developer_key"

# Make it into a class
class_text = "class DecisionTree {\n"
class_text += "\t" + func_text
class_text += "\n}"

bygg_fil(project_location, project_name, key, class_text)