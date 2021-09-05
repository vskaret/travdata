
# coding: utf-8

# In[1]:

import csv, time, re

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

def skrivTilCsv(lst, output_fil):
    with open(output_fil, "w") as delete:
        delete.write("")

    with open(output_fil, "a") as csvfil:
        writer = csv.writer(csvfil, delimiter=";")
        for row in lst:
            writer.writerow(row)


# In[2]:

# fikse forekomster hver for seg med dictionary


# In[3]:

fi = lesCsv("sortert_finished.csv")
dn = lesCsv("sortert_dnf.csv")
nyfi = []
nydn = []
#navneDict = {}


# In[4]:

# finished
# (rad[4] = navn)
navneDict = {}

for rad in fi:
        if rad[4] not in navneDict:
            navneDict[rad[4]] = 1
        else:
            navneDict[rad[4]] = navneDict[rad[4]] + 1
            
        rad = rad + [navneDict[rad[4]]]
        nyfi.append(rad)


# In[5]:

skrivTilCsv(nyfi, "sortert_forekomst_finished.csv")


# In[6]:

# dnf
navneDict = {}

for rad in dn:
        if rad[4] not in navneDict:
            navneDict[rad[4]] = 1
        else:
            navneDict[rad[4]] = navneDict[rad[4]] + 1
            
        rad = rad + [navneDict[rad[4]]]
        nydn.append(rad)


# In[7]:

skrivTilCsv(nydn, "sortert_forekomst_dnf.csv")


# In[ ]:



