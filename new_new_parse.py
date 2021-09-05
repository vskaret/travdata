import re
import bs4 as bs
import urllib.request, time, os.path
import csv

def skrivListTilCsv(lst, output_fil):
    with open(output_fil, "w") as delete:
        delete.write("")

    with open(output_fil, "a") as csvfil:
        writer = csv.writer(csvfil, delimiter=";")
        for row in lst:
            writer.writerow(row)

def skrivNestedListTilCsv(list_with_list, output_fil):
    with open(output_fil, "w") as delete:
        delete.write("")

    with open(output_fil, "a") as csvfil:
        writer = csv.writer(csvfil, delimiter=";")
        for lst in list_with_list:
            for nested_list in lst:
                writer.writerow(nested_list)

def openFile(target_dir, lopcsv, fihestcsv, dnfhestcsv):
    løp_resultat_løp = []
    løp_resultat_hest_finished = []
    løp_resultat_hest_dnf = []

    i = 0
    for filtuppel in os.walk(target_dir):
        if i > 0:
            for fil in filtuppel[2]:
                filsti = filtuppel[0] + "/" + fil
                try:
                    sourcefile = open(filsti)
                    source = sourcefile.read()
                    soup = bs.BeautifulSoup(source, "lxml")
                    trippel = parseSoup(soup)    # parsekall

                    if trippel == "Exception":
                        sourcefile.close()
                        quit()

                    løp_resultat_løp.append(trippel[0])
                    løp_resultat_hest_finished.append(trippel[1])
                    løp_resultat_hest_dnf.append(trippel[2])
                    sourcefile.close()
                except Exception as e:
                    print(e)
                    sourcefile.close()
                    continue
                #os.rename(filsti, re.sub("filer/", "arkiv/", filsti)) # flytter filen
        i += 1

    # skriver race_result_race til csv
    skrivNestedListTilCsv(løp_resultat_løp, lopcsv)
    skrivNestedListTilCsv(løp_resultat_hest_finished, fihestcsv)
    skrivNestedListTilCsv(løp_resultat_hest_dnf, dnfhestcsv)


def parseSoup(soup):
    tables = soup.findAll("table")
    race_result_horse_finished = []
    race_result_horse_dnf = []
    race_result_race = []
    start_row = []
    provelop = False

    for t in tables:
        # finner løpnr
        if len(t.find_parents("table")) == 1:
            span_left = t.find("span")
            if not span_left is None:
                lop_nr = re.sub(".*Løp: ", "", span_left.text).lstrip("\n")

        # finner resten av informasjonen (bortsett fra divinfotabell, tempotabell og oddstabell)
        if len(t.find_parents("table")) == 2:
            for tr in t.findAll("tr"):
                if len(tr.find_parents("tr")) == 2 and not tr.find("tbody"):

                    td = tr.findAll("td")
                    row = [re.sub("\s+", " ", i.text.lstrip("\n").rstrip("\n")) for i in td]

                    if len(row) > 0:
                        # hopper over radene med tempo og vunnet (etter tabellen)
                        if row[0].startswith("Vunnet") or row[0].startswith("Tempo"):
                            continue
                        # første header linje
                        if row[0].startswith("Start"):
                            start_row = row

                            # fjerner labels
                            bane = start_row[1] = re.sub("Bane: ", "", start_row[1])
                            # noe ukonsekvens navngivning
                            if bane.startswith("JARLSBERG TRAVB."):
                                bane = "Jarlsberg Travbane"
                            elif bane.startswith("LEANGEN TRAVBANE A/S"):
                                bane = "Leangen Travbane"
                            elif bane.startswith("FORUS TRAV A/S"):
                                bane = "Forus Travbane"
                            elif bane.startswith("BIRI TRAV A/S"):
                                bane = "Biri Travbane"
                            start_row[1] = bane

                            lopnavn = re.sub("Løpnavn: ", "", start_row[2])
                            lopnavn = re.sub("Lopnavn: ", "", lopnavn)
                            lopnavn = re.sub("Ø", "O", re.sub("ø", "o", lopnavn)) # fjerner ø Ø
                            lopnavn = re.sub("Æ", "AE", re.sub("æ", "ae", lopnavn)) # fjerner æ Æ
                            lopnavn = re.sub("Å", "AA", re.sub("å", "aa", lopnavn)) # fjerner å Å
                            if lopnavn.rstrip(" ") == "": # trengs for string comparison i databasen
                                lopnavn = "-"
                            start_row[2] = lopnavn.rstrip(" ")
                            start_row = start_row[0:2] + [lop_nr] + start_row[2:]

                            # dato og klokkeslett hver for seg
                            dato = re.sub("\.", "", re.sub(" ", "", start_row[0][7:19]))
                            dato =  dato[4:8] + "-" + dato[2:4] + "-" + dato[0:2]       # YYYY-MM-DD
                            kl = start_row[0][24:] + ":00"                              # HH:MM:SS
                            start_row[0] = kl
                            start_row = [dato] + start_row
                        # andre header linje
                        elif row[0].startswith("Premie"):
                            for cell in row:
                                start_row.append(cell)

                            # fjerner labels
                            premiesum = start_row[5] = re.sub("Premiesum: ", "", start_row[5])
                            start_row[6] = re.sub("Distanse: ", "", start_row[6])
                            start_row[8] = re.sub("Startmetode: ", "", start_row[8])
                            start_row.pop(7)            # fjerner baneverdi
                            start_row.append("")

                            if not premiesum == "" and not premiesum == "0":
                                race_result_race.append(start_row)

                        # resten av tabellen
                        else:
                            odds = row[8].lstrip("*")
                            if not (premiesum == "" or premiesum == "0"):      # hopper over prøveløp!
                                hestTid = row[4]
                                KMdef = row[5] # "29.7" "28.9"
                                KMtid = -1

                                galopp = 0
                                passgang = 0
                                galopp_i_mål = 0
                                disket_for_galopp = 0
                                disket_for_passgang = 0
                                disket_for_galopp_og_passgang = 0
                                brutt_løp_galopp = 0
                                brutt_løp_passgang = 0
                                disket_for_annet = 0
                                distansert = 0
                                temp = 0
                                dnf = False

                                plassering = row[0]
                                if plassering == "":
                                    plassering = 0

                                if len(KMdef) == 0:
                                    pleasecontinue = 1
                                    dnf = True
                                else:
                                    if len(KMdef) > 3 and KMdef[0:2].isnumeric():
                                        KMtid = re.sub(",", ".", KMdef[0:4])
                                    if KMdef == "dgpp" or KMdef == "dpp" or KMdef == "brp":
                                        print("Lurt seg inn et prøveløp!")
                                        print(start_row)
                                        print(row)

                                    # galopp
                                    if len(KMdef) >= 2 and KMdef.__contains__("g") and (KMdef[1].isnumeric() or KMdef[1:3].isnumeric()) and KMtid == -1:
                                        galopp_i_mål = 1
                                        dnf = True
                                    elif KMdef.__contains__("dg"):
                                        disket_for_galopp = 1
                                        dnf = True
                                    elif KMdef.__contains__("dgp"):
                                        disket_for_galopp_og_passgang = 1
                                        dnf = True
                                    elif KMdef.__contains__("br") and not KMdef.__contains__("p") and KMdef.__contains__("g"):
                                        brutt_løp_galopp = 1
                                        dnf = True
                                    elif KMdef.__contains__("g"):
                                        galopp = 1

                                    # passgang
                                    if KMdef.__contains__("dp"):
                                        disket_for_passgang = 1
                                        dnf = True
                                    elif KMdef.__contains__("br") and not KMdef.__contains__("g"):
                                        brutt_løp_passgang = 1
                                        dnf = True
                                    elif KMdef.__contains__("p"): # and not KMdef.__contains__("dp"): MEH
                                        passgang = 1

                                    if KMdef.__contains__("dv") or str(plassering).startswith("Diskvalifisert"):
                                        disket_for_annet = 1
                                        dnf = True
                                    if KMdef.__contains__("dist"):
                                        distansert = 1
                                        dnf = True
                                    if KMdef.__contains__("temp") or KMdef.__contains__("nc"):
                                        temp = 1
                                        dnf = True

                                premie = row[6]
                                if premie == "":
                                    premie = 0

                                odds = row[8].lstrip("*")
                                if odds == "":
                                    odds = 0


                                startnr = row[1]
                                navn = row[2]
                                dist = row[3]
                                tid_brukt = re.sub(",", ":", row[4])
                                kusk = row[7]


                                row = [navn] + [kusk] + [plassering] + [startnr] + [dist] + [premie] + [odds] + [KMtid] \
                                             + [galopp] + [passgang] + [galopp_i_mål] + [disket_for_galopp] \
                                             + [disket_for_passgang] + [disket_for_galopp_og_passgang] + [brutt_løp_galopp] \
                                             + [brutt_løp_passgang] + [disket_for_annet] + [distansert] + [temp]
                                row = [dato] + [kl] + [bane] + [lop_nr] + row

                                if (dnf and KMtid == -1):
                                    race_result_horse_dnf.append(row)
                                else:
                                    race_result_horse_finished.append(row)

                                #print(row)
                                #print(start_row)
                                #time.sleep(1)


    return (race_result_race, race_result_horse_finished, race_result_horse_dnf)


def main():
    # default åpning
    openFile("filer/", "lop.csv", "finished.csv", "dnf.csv")

if __name__ == "__main__":
    main()
