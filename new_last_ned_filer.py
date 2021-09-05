import bs4 as bs
#from urllib.request import urlopen
import urllib.request
from urllib.error import URLError, HTTPError
import time, os.path, socket, re
from new_new_parse import openFile

target_dir_const = "filer"
arkiv_dir_const = "arkiv"

if not os.path.exists(target_dir_const):
    os.makedirs(target_dir_const)
if not os.path.exists(arkiv_dir_const):
    os.makedirs(arkiv_dir_const)
socket.setdefaulttimeout(10)

travsportlink = "http://www.travsport.no"
sr = "/Sport/Resultater"

#print("***************************************************************")
#print("Preparing to scrape " + travsportlink + sr)
#print("***************************************************************\n")

try:
    travbaner = open("travbaner.txt", "r")

    for travbane in travbaner:
        travbane = travbane.rstrip("\n")
        link = "%s%s/%s" % (travsportlink, sr, travbane)
        target_dir = target_dir_const + "/" + travbane + "/"
        arkiv_dir = arkiv_dir_const + "/" + travbane + "/"

        print("***************************************************************")
        print("Preparing to download results from " + travbane + " at " + link)
        print("***************************************************************\n")

        if not os.path.exists("filer/" + travbane):
            os.makedirs("filer/" + travbane)
        if not os.path.exists("arkiv/" + travbane):
            os.makedirs("arkiv/" + travbane)

        time.sleep(1)

        source = urllib.request.urlopen(link).read()
        soup = bs.BeautifulSoup(source, "lxml")
        main = soup.find("div", "article")

        # henter alle resultat-urler
        for url in main.find_all("a"):
            url = url.get("href")
            dato = re.sub(".*date=", "", url)
            url = travsportlink + url

            if not os.path.exists(arkiv_dir+dato) and not os.path.exists(target_dir+dato):
                time.sleep(1)
                print("***************************************************************")
                print("Downloading " + url + " to directory /" + (target_dir+dato))
                print()
                print("[*    ]")
                time.sleep(1)
                print("[**   ]")
                time.sleep(1)
                print("[***  ]")
                time.sleep(1)
                print("[**** ]")
                time.sleep(2)
                #print("***************************************************************\n")
                urllib.request.urlretrieve(url, (target_dir+dato))
                print("[*****]")
                time.sleep(1)
                print()
                print("Download finished.")
                print("***************************************************************\n")
            else:
                print("***************************************************************")
                print("Results for date " + dato + " already downloaded")
                print("***************************************************************\n")


    travbaner.close()
    print()
    print("All downloads finished!")
except Exception as e:
    print(e)
    travbaner.close()

# kaller på parsing
test = openFile("filer/", "lop.csv", "finished.csv", "dnf.csv")
