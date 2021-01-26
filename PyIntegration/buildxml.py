import os
import xml.etree.ElementTree as ET

seconds_input = input("Measure by heartrate by (/s): ")

# Path to my Monkey C project, where we save our created XML
dir = "C:/Users/magnu/eclipse-workspace/SeveralDataFields/resources"
os.chdir(dir)

# Create an XML file and put in resources
# Create the Tree-Structure with content
resources = ET.Element("resources")
data1 = ET.SubElement(resources, "jsonData")
data1.set("id", "variables")
data1.text = "\"" + seconds_input + "\""
# Turn the tree structure into something writeable, and make a file
alldata = ET.tostring(resources)
createfile = open("data.xml", "w")
createfile.write(alldata.decode("utf-8"))