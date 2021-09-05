-- Hest
CREATE TABLE Hest (
  hestenavn       varchar(100) PRIMARY KEY,
  hesterase       varchar(9),

  CHECK (
    hesterase IN ('Varmblods', 'Kaldblods', '')
  )
);

-- HestiLøp
CREATE TABLE HestiLop (
  dato            date,
  tidspunkt       time,
  travbane        varchar(20),
  lopnr           int,
  hestenavn       varchar(100),
  --tid             time,
  tid             varchar(20),
  --KMtid           time,
  KMtid           varchar(10),
  galloptype      varchar(10),
  div-info        text,
  startnr         varchar(20) NOT NULL,
  plassering      varchar(20),
  hestedistanse   int NOT NULL,
  premie          int,
  kusk            varchar(100),
  odds            varchar(10),

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr, hestenavn),
  FOREIGN KEY (dato, tidspunkt, travbane, lopnr) REFERENCES Lop(dato, tidspunkt, travbane, lopnr)
  --FOREIGN KEY (hestenavn) REFERENCES Hest(hestenavn)
);

-- Løp
CREATE TABLE Lop (
  dato            date,
  tidspunkt       time,
  travbane        varchar(50),
  lopnr           int,
  lopnavn         text,
  premiesum       int,
  distanse        int,
  startmetode     varchar(5) NOT NULL,
  --kjonn           varchar(6) NOT NULL,   det kjøres blandaløp
  --ant_paameldte   int NOT NULL,          lag med view
  lop_rase        varchar(9),

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr),
  CHECK (
    lop_rase IN ('Varmblods', 'Kaldblods', '') AND
    startmetode IN ('Auto', 'Volte', 'Linje')
  )
);
