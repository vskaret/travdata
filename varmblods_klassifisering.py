import csv, time

def skrivTilCsv(lst, output_fil):
    with open(output_fil, "w") as delete:
        delete.write("")

    with open(output_fil, "a") as csvfil:
        writer = csv.writer(csvfil, delimiter=";")
        for row in lst:
            writer.writerow(row)

def lesCsv(filnavn):
    returListe = []
    #i = 0
    with open(filnavn, "r") as fil_csv:
        fil_read = csv.reader(fil_csv, delimiter=";")
        for fil_row in fil_read:
            #if i > 0:
            returListe.append(fil_row)
            #i += 1

    return returListe

def skrivDictTilCsv(dic, output_fil):
    with open(output_fil, "w") as delete:
        delete.write("")

    with open(output_fil, 'a') as csv_file:
        writer = csv.writer(csv_file, delimiter=";")
        for key, value in dic.items():
            writer.writerow(value)

def varmEllerKaldF():
    i = 0
    for row in finishedListe:
        print(row)
        svar = input("varmblods (y/n/q) >")
        if svar == "y":
            row = row + ["Varmblods"]
            #varmblodsLopId.append(row[0:4])
            varmblodsLopId[str(row[0:4])] = 1
            #varmblodsHest.append(row[4])
            varmblodsHest[row[4]] = 1
            #nyFinished.append(finishedListe.pop(i)+["Varmblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Varmblods"]
            i += 1

        elif svar == "n":
            row = row + ["Kaldblods"]
            #kaldblodsLopId.append(row[0:4])
            kaldblodsLopId[str(row[0:4])] = 1
            #kaldblodsHest.append(row[4])
            kaldblodsHest[row[4]] = 1
            #nyFinished.append(finishedListe.pop(i)+["Kaldblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Kaldblods"]
            i += 1

        else:
            return

def varmEllerKaldD():
    i = 0
    for row in dnfListe:
        print(row)
        svar = input("varmblods (y/n/q) >")
        if svar == "y":
            row = row + ["Varmblods"]
            #varmblodsLopId.append(row[0:4])
            varmblodsLopId[str(row[0:4])] = 1
            #nyDnf.append(finishedListe.pop(i)+["Varmblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Varmblods"]
            #varmblodsHest.append(row[4])
            varmblodsHest[row[4]] = 1
            i += 1

        elif svar == "n":
            row = row + ["Kaldblods"]
            #kaldblodsLopId.append(row[0:4])
            kaldblodsLopId[str(row[0:4])] = 1
            #nyDnf.append(finishedListe.pop(i)+["Kaldblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Kaldblods"]
            #kaldblodsHest.append(row[4])
            kaldblodsHest[row[4]] = 1
            i += 1

        else:
            return

def settLopStatusFraHest():
    i = 0
    for row in finishedListe:
        if row[4] in varmblodsHest:
            #varmblodsLopId.append(row[0:4])
            varmblodsLopId[str(row[0:4])] = 1
            #nyFinished.append(finishedListe.pop(i) + ["Varmblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Varmblods"]
        elif row[4] in kaldblodsHest:
            #kaldblodsLopId.append(row[0:4])
            kaldblodsLopId[str(row[0:4])] = 1
            #nyFinished.append(finishedListe.pop(i) + ["Kaldblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Kaldblods"]
        i += 1

    i = 0
    for row in dnfListe:
        if row[4] in varmblodsHest:
            #varmblodsLopId.append(row[0:4])
            varmblodsLopId[str(row[0:4])] = 1
            #nyDnf.append(dnfListe.pop(i) + ["Varmblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Varmblods"]
        elif row[4] in kaldblodsHest:
            #kaldblodsLopId.append(row[0:4])
            kaldblodsLopId[str(row[0:4])] = 1
            #nyDnf.append(dnfListe.pop(i) + ["Kaldblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Kaldblods"]
        i += 1

    i = 0
    for row in lopListe:
        if str(row[0:4]) in varmblodsLopId:
            #nyLop.append(lopListe.pop(i) + ["Varmblods"])
            nyLop[str(row)] = lopListe.pop(i) + ["Varmblods"]
        elif str(row[0:4]) in kaldblodsLopId:
            #nyLop.append(lopListe.pop(i) + ["Kaldblods"])
            nyLop[str(row)] = lopListe.pop(i) + ["Kaldblods"]
        i += 1

def settHestStatusFraLop():
    i = 0
    for row in finishedListe:
        if str(row[0:4]) in varmblodsLopId:
            #nyFinished.append(finishedListe.pop(i) + ["Varmblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Varmblods"]
            #varmblodsHest.append(row[4])
            varmblodsHest[row[4]] = 1
        elif str(row[0:4]) in kaldblodsLopId:
            #nyFinished.append(finishedListe.pop(i) + ["Kaldblods"])
            nyFinished[str(row)] = finishedListe.pop(i) + ["Kaldblods"]
            #kaldblodsHest.append(row[4])
            kaldblodsHest[row[4]] = 1
        i += 1

    i = 0
    for row in dnfListe:
        if str(row[0:4]) in varmblodsLopId:
            #nyDnf.append(dnfListe.pop(i) + ["Varmblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Varmblods"]
            varmblodsHest[row[4]] = 1
        elif str(row[0:4]) in kaldblodsLopId:
            #nyDnf.append(dnfListe.pop(i) + ["Kaldblods"])
            nyDnf[str(row)] = dnfListe.pop(i) + ["Kaldblods"]
            kaldblodsHest [row[4]] = 1
        i += 1
"""
def clean(lst):
    cleanerDict = {}
    nyListe = []
    for row in lst:
        if str(row) not in cleanerDict:
            cleanerDict[str(row)] = 1
            nyListe.append(row)
    return lst
"""

finishedListe = lesCsv("finished.csv")
#nyFinishedListe = lesCsv("ny_finished.csv")
dnfListe = lesCsv("dnf.csv")
lopListe = lesCsv("lop.csv")

#varmblodsLopId = []
#kaldblodsLopId = []
#varmblodsHest = []
#kaldblodsHest = []
varmblodsLopId = {}         # mye mer effektivt
kaldblodsLopId = {}
varmblodsHest = {}
kaldblodsHest = {}
#nyFinished = []
#nyDnf = []
#nyLop = []
nyFinished = {}
nyDnf = {}
nyLop = {}

"""
for row in finishedListe:
    for r in lopListe:
        print(row[0:4])
        print(r[0:4])
        time.sleep(1)
"""
"""
for row in finishedListe:
    if row + ["Varmblods"] not in nyFinishedListe and row + ["Kaldblods"] not in nyFinishedListe:
        print(row)
"""


while True:
    print("\nMeny")
    print("[00] varmellerkald_finishedliste!")
    print("[01] varmellerkald_dnfliste!")
    print("[1] settLopStatusFraHest")   # må fikses
    print("[2] settHestStatusFraLop")   # må fikses
    print("[3] vis antall hesterader uten status")
    print("[4] vis antall hesterader med status")
    print("[5] vis antall løp uten status")
    print("[6] vis antall løp med status")
    print("[7] skriv ut ny_finished")
    print("[8] skriv ut ny_dnf")
    print("[9] skriv ut ny_lop")
    print("[10] go ham (automatiser 1 og 2)")
    print("[11] clean nyfinished")
    print("[12] clean nydnf")
    #print("[13] clean nylop") er allerede clean
    print("[q] quit")
    svar = input("Velg alternativ >")
    if svar == "00":
        varmEllerKaldF()
    elif svar == "01":
        varmEllerKaldD()
    elif svar == "1":
        settLopStatusFraHest()
    elif svar == "2":
        settHestStatusFraLop()
    elif svar == "3":
        print("finished: " + str(len(finishedListe)) + "\ndnf: " + str(len(dnfListe)))
    elif svar == "4":
        print("finished: " + str(len(nyFinished)) + "\ndnf: " + str(len(nyDnf)))
    elif svar == "5":
        print("løp: " + str(len(lopListe)))
    elif svar == "6":
        print("løp: " + str(len(nyLop)))
    elif svar == "7":
        #skrivTilCsv(nyFinished, "ny_finished.csv")
        skrivDictTilCsv(nyFinished, "ny_finished.csv")
    elif svar == "8":
        #skrivTilCsv(nyDnf, "ny_dnf.csv")
        skrivDictTilCsv(nyDnf, "ny_dnf.csv")
    elif svar == "9":
        #skrivTilCsv(nyLop, "ny_lop.csv")
        skrivDictTilCsv(nyLop, "ny_lop.csv")
    elif svar == "10":
        while len(finishedListe) > 0 or len(dnfListe) > 0 or len(lopListe) > 0:
            settLopStatusFraHest()
            settHestStatusFraLop()
    elif svar == "11":
        nyFinished = clean(nyFinished)
    elif svar == "12":
        nyDnf = clean(nyDnf)
    elif svar == "q":
        quit()
