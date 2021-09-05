-- Løp
CREATE TABLE Lop (
  dato            date,
  tidspunkt       time,
  travbane        varchar(50),
  lopnr           int,
  lopnavn         text NOT NULL,    -- kan ikke være null for da blir det fuck med string comparison (setter null til '-')
  premiesum       int,
  distanse        int,
  startmetode     varchar(5) NOT NULL,
  --kjonn           varchar(6) NOT NULL,   det kjøres blandaløp
  --ant_paameldte   int NOT NULL,          lag med view
  fuck            varchar(50),
  lop_rase        varchar(9),

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr),
  CHECK (
    lop_rase IN ('Varmblods', 'Kaldblods', '') AND
    startmetode IN ('Auto', 'Volte', 'Linje')
  )
);

-- Avsluttede løp
CREATE TABLE Finished (
  dato            date,
  tidspunkt       time,
  travbane        text,
  lopnr           int,
  hest            varchar(100),
  kusk            varchar(100),
  pl              varchar(50),
  snr             varchar(50) NOT NULL,
  hdist           int NOT NULL,
  premie          int NOT NULL,
  odds            varchar(10) NOT NULL,
  KM              decimal NOT NULL,        -- tid per KM (+ 60s)
  g               int NOT NULL,   -- galopp
  p               int NOT NULL,   -- passgang
  gX              int NOT NULL,   -- disket for galopp i mål
  dg              int NOT NULL,   -- disket for galopp
  dp              int NOT NULL,   -- disket for passgang
  dgp             int NOT NULL,   -- disket for galopp og passgang
  brg             int NOT NULL,   -- brutt løp galopp
  brp             int NOT NULL,   -- brutt løp passgang
  dv              int NOT NULL,   -- disket ved andre årsaker
  d               int NOT NULL,   -- distansert
  t               int NOT NULL,   -- temp
  rase            varchar(20) NOT NULL,
  f               int NOT NULL,   -- forekomstnr

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr, hest),
  FOREIGN KEY (dato, tidspunkt, travbane, lopnr) REFERENCES Lop(dato, tidspunkt, travbane, lopnr)
);

-- Brutte løp, diskete løp, etc
CREATE TABLE DNF (
  dato            date,
  tidspunkt       time,
  travbane        text,
  lopnr           int,
  hest            varchar(100),
  kusk            varchar(100),
  pl              varchar(50),
  snr             varchar(50) NOT NULL,
  hdist           int NOT NULL,
  premie          int NOT NULL,
  odds            varchar(10) NOT NULL,
  KM              decimal,        -- tid per KM (+ 60s)
  g               int NOT NULL,   -- galopp
  p               int NOT NULL,   -- passgang
  gX              int NOT NULL,   -- disket for galopp i mål
  dg              int NOT NULL,   -- disket for galopp
  dp              int NOT NULL,   -- disket for passgang
  dgp             int NOT NULL,   -- disket for galopp og passgang
  brg             int NOT NULL,   -- brutt løp galopp
  brp             int NOT NULL,   -- brutt løp passgang
  dv              int NOT NULL,   -- disket ved andre årsaker
  d               int NOT NULL,   -- distansert
  t               int NOT NULL,   -- temp
  rase            varchar(20) NOT NULL,
  f               int NOT NULL,          -- forekomstnr

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr, hest),
  FOREIGN KEY (dato, tidspunkt, travbane, lopnr) REFERENCES Lop(dato, tidspunkt, travbane, lopnr)
);


-- Importerer data fra csv fil til tabell
-- COPY <tablename> FROM '<path>' DELIMITER '<delim>' CSV;
-- Eksporterer query til csv fil (https://stackoverflow.com/questions/1517635/save-pl-pgsql-output-from-postgresql-to-a-csv-file)
-- COPY (SELECT * FROM <tablename>) TO '<path>' WITH CSV DELIMITER '<delim>';
-- As meta-command (runs inside the client): \copy (SELECT * FROM <tablename>) TO '<path>' WITH CSV
-- delim eks: ';'

-- LAG NY DATABASE
-- CREATE DATABASE name;
-- createdb dbname #in shell


/*
"could not write to hash-join temporary file: No space left on device"
show config_file; (shows location of postgresql.conf)
    SQL> create tablespace temp_tbs location '/some/big/disk';
    change temp_tablespaces = 'temp_tbs' in postgresql.conf.
    select pg_reload_conf();
