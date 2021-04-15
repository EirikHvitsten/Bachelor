# Legge ny jsonfil inn i datafieldet, build for device og legg inn på klokka


# 1. Legg jsonfil inn i HeartRateAnalyser -> data -> og erstatt med analyse.json
# 2. Monkey C: Build for Device
# 3. Legg HeartRateAnalyser.prg fra 
    # HeartRateAnalyser -> bin -> HeartRateAnalyser.prg til
    # D:\GARMIN\APPS

import shutil
import os

def flytt_fil():
    source = r'C:\Bachelor\Bach\Bachelor\Json_script\analyse.json'
    destination = r'C:\Bachelor\Bach\Bachelor\MonkeyC\HeartRateAnalyser\resources\data\analyse.json'

    shutil.copyfile(source, destination)

    os.system("cd ..\..\.. &"
              "monkeyc -y dev_key\developer_key -f Bach\Bachelor\MonkeyC\HeartRateAnalyser\monkey.jungle -o testting.prg")

    new_source = r'C:\Bachelor\testting.prg'
    new_dest = r'D:\GARMIN\APPS\testting.prg'
    shutil.copyfile(new_source, new_dest)

    #os.system("monkeyc")

if __name__ == '__main__':
    flytt_fil()
  




#"monkeyc -y dev_key\developer_key -f bach\Bachelor\MonkeyC\HeartRateAnalyser\monkey.jungle -o myapp.prg"