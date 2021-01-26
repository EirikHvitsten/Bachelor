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
    return pulsdict, starttidspunkt, sluttidspunkt

def info(array):
    makspuls = 0
    total = 0
    for puls in array:
        if puls > makspuls:
            makspuls = puls
        total += puls
    snitt = total/len(array)
    print(f"Makspuls siste 30 sek: {makspuls}, gjennomsnitt siste 30 sek: " + "%.2f" % snitt)


def simuler(hastighet, fitdict, naa, slutt):
    antrunder = 0
    funnet = 0
    ikkefunnet = 0
    puls = None
    avgarray = [0]*30
    indeks = 0
    while naa != slutt:
        antrunder += 1
        if naa in fitdict:
            funnet += 1
            puls = fitdict[naa]
        else:
            ikkefunnet += 1
            # print("\tFant ikke dette tidspunktet, beholder samme puls")
        # print(f"Puls: {puls}, tidspunkt: {naa}\n")
        avgarray[indeks] = puls
        indeks += 1
        if indeks == 30:
            indeks = 0
        info(avgarray)
        naa += datetime.timedelta(seconds=1)
        sleep(hastighet)
    andel = funnet/antrunder
    print(f"Antall runder: {antrunder}, funnet: {funnet}, ikke funnet: {ikkefunnet}, andel funnet i prosent: " + "%.4f" % andel)

if __name__ == "__main__":
    for file in os.listdir("fitfiles"):
        pulsdict, starttidspunkt, sluttidspunkt= les_fil("fitfiles/" + file)
        # hastighet = float(input("Hvor lenge er ett sekund: "))
        hastighet = 0
        print(starttidspunkt)
        print(sluttidspunkt)
        kjor = simuler(hastighet, pulsdict, starttidspunkt, sluttidspunkt)
        # print(pulsdict)

        # Ta vekk break for å lese alle filene
        break

