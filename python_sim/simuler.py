import fitdecode
from time import sleep
import datetime
import os

def les_fil(filnavn):
    pulsdict = {}
    # pulsarray = []
    puls = None
    tidspunkt = None
    starttidspunkt = None
    sluttidspunkt = None
    with fitdecode.FitReader(filnavn) as fit:
        for ramme in fit:
            # ramme er en av følgende objekter:
            # - fitdecode.FitHeader
            # - fitdecode.FitDefinitionMessage
            # - fitdecode.FitDataMessage
            # - fitdecode.FitCRC
            if isinstance(ramme, fitdecode.FitDataMessage):
                for innhold in ramme.fields:
                    if innhold.name == "heart_rate":
                        puls = innhold.value
                    if innhold.name == "timestamp":
                        tidspunkt = innhold.value
                        if starttidspunkt == None:
                            starttidspunkt = innhold.value
                    # pulsarray.append([str(tidspunkt), puls])
                if puls != None and tidspunkt != None:
                    pulsdict[tidspunkt] = puls
                sluttidspunkt = tidspunkt
                puls = None
                tidspunkt = None
    # print(pulsarray)
    # print(pulsdict)
    # print(starttidspunkt)
    return pulsdict, starttidspunkt, sluttidspunkt

def simuler(hastighet, fitdict, naa, slutt):
    antrunder = 0
    funnet = 0
    ikkefunnet = 0
    puls = None
    while naa != slutt:
        antrunder += 1
        if naa in fitdict:
            funnet += 1
            puls = fitdict[naa]
        else:
            ikkefunnet += 1
            # print("\tFant ikke dette tidspunktet, beholder samme puls")
        # print(f"Puls: {puls}, tidspunkt: {naa}\n")
        naa += datetime.timedelta(seconds=1)
        sleep(hastighet)
    print(f"Antall runder: {antrunder}, funnet: {funnet}, ikke funnet: {ikkefunnet}, % funnet: {funnet/antrunder}")

if __name__ == "__main__":
    for file in os.listdir("fitfiles"):
        pulsdict, starttidspunkt, sluttidspunkt= les_fil("fitfiles/" + file)
        # hastighet = float(input("Hvor lenge er ett sekund: "))
        hastighet = 0
        print(starttidspunkt)
        print(sluttidspunkt)
        kjor = simuler(hastighet, pulsdict, starttidspunkt, sluttidspunkt)
        # print(pulsdict)

