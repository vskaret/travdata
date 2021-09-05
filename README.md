# travdata
An old personal database project for gathering, structuring and querying Norwegian harness racing data

## (MIDLERTIDIG) OPPSKRIFT
1. last ned og parse med new_last_ned_filer.py (og new_new_parse.py)
2. lable varm/kald med klassifiser_varmblods.py
3. sorter på dato (siste dato først) [kan gjøres med sql]
4. finn antall forekomster av hver hest i finished og dnf (forekomster.ipynb)
5. importer til sql

## Filbeskrivelser

### denne mappen:

- new_last_ned_filer.py: nedlastning av resultat-html-er
- new_new_parse.py: parsing av resultat-html-er (genererer csv fil)
- travbaner.txt: navn på travbaner som brukes i url på travsport.no (til hjelp ved nedlastning)
- varmblods_klassifisering.py: klassifiserer hesters rase (varm eller kaldblods)
- forekomster.py: husker ikke helt

### db:

- arkiv.sql: arkiverte spørringer
- failed.sql:
- midl_tables.sql:
- modellering_td40.sql:
- modellering.sql:
- sporring.sql: hente data som kanskje kan brukes til analyse
- new_sporring.sql: å hente mer data som kanskje kan brukes til analyse
- tables.sql: første versjon av databasestruktur
- new_tables.sql: andre versjon av databasestruktur
- new_new_tables.sql: siste versjon av databasestruktur

### div

- tidligere_utenladsregistrerte.py: noe rensing av data
