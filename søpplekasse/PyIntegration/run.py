import os

# Build XML and PRG
os.system("c:/Users/magnu/OneDrive/Documents/Bachelor/PyIntegration/buildxml.py")
os.system("c:/Users/magnu/OneDrive/Documents/Bachelor/PyIntegration/buildprg.py")

# Run simulator
os.system("connectiq")
os.system("monkeydo C:/Users/magnu/eclipse-workspace/SeveralDataFields/bin/SeveralDataFields.prg fenix6")