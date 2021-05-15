import os

project_location = "C:/Users/magnu/eclipse-workspace/"
project_name = "SeveralDataFields"
key = "C:/Users/magnu/keys/developer_key"
def bygg_fil(prosjekt_location, project_name, key, text_to_write):
    # Change to directory
    dir = project_location + project_name + "/resources/data"
    os.chdir(dir)

    # Write to file, overwrites the one that is there
    file = open("analyse.json", "w")
    file.write(text_to_write)
    file.close()

    os.system(
        "monkeyc -y " + key + " -f " + project_location+project_name+"/monkey.jungle " + "-o " + project_location+project_name+"/bin/"+project_name+".prg"
    )


if __name__ == '__main__':
    bygg_fil(project_location, project_name, key)