-- Avsluttede løp
CREATE TABLE Finished (
  f               int,          -- forekomstnr
  dato            date,
  tidspunkt       time,
  travbane        text,
  l               int,
  hestenavn       varchar(100),
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
  br              int NOT NULL,   -- brutt løp
  dv              int NOT NULL,   -- disket ved andre årsaker
  d               int NOT NULL,   -- distansert
  t               int NOT NULL,   -- temp

  PRIMARY KEY (dato, tidspunkt, travbane, l, hestenavn),
  FOREIGN KEY (dato, tidspunkt, travbane, l) REFERENCES Lop(dato, tidspunkt, travbane, lopnr)
  --FOREIGN KEY (hestenavn) REFERENCES Hest(hestenavn)
);

-- Brutte løp, diskete løp, etc
CREATE TABLE DNF (
  f               int,          -- forekomstnr
  dato            date,
  tidspunkt       time,
  travbane        text,
  l               int,
  hestenavn       varchar(100),
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
  br              int NOT NULL,   -- brutt løp
  dv              int NOT NULL,   -- disket ved andre årsaker
  d               int NOT NULL,   -- distansert
  t               int NOT NULL,   -- temp

  PRIMARY KEY (dato, tidspunkt, travbane, l, hestenavn),
  FOREIGN KEY (dato, tidspunkt, travbane, l) REFERENCES Lop(dato, tidspunkt, travbane, lopnr)
  --FOREIGN KEY (hestenavn) REFERENCES Hest(hestenavn)
);

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
  lop_rase        varchar(9),

  PRIMARY KEY (dato, tidspunkt, travbane, lopnr),
  CHECK (
    --lop_rase IN ('Varmblods', 'Kaldblods', '') AND
    startmetode IN ('Auto', 'Volte', 'Linje')
  )
);


-- Importerer data fra csv fil til tabell
-- COPY <tablename> FROM '<path>' DELIMITER '<delim>' CSV;
-- Eksporterer query til csv fil (https://stackoverflow.com/questions/1517635/save-pl-pgsql-output-from-postgresql-to-a-csv-file)
-- COPY (SELECT * FROM <tablename>) TO '<path>' WITH CSV DELIMITER '<delim>';
-- As meta-command (runs inside the client): \copy (SELECT * FROM <tablename>) TO '<path>' WITH CSV
-- delim eks: ';'

-- siste 5 avsluttede løp med hastighet (dagens løp er også avsluttet)
SELECT
  f.dato dato,
  f.travbane travbane,
  f.hestenavn hest,
  f.l lopnr,
  f.km km,
  (f.dato - l1.dato) l1d,
  l1.km l1,
  (f.dato - l2.dato) l2d,
  l2.km l2,
  (f.dato - l3.dato) l3d,
  l3.km l3,
  (f.dato - l4.dato) l4d,
  l4.km l4,
  (f.dato - l5.dato) l5d,
  l5.km l5
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-1) AS f
  FROM finished i
  WHERE f <> 1
  --ORDER BY i.dato DESC
) AS l1 ON l1.hestenavn = f.hestenavn AND l1.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-2) AS f
  FROM finished i
  WHERE f <> 1
  --ORDER BY i.dato DESC
) AS l2 ON l2.hestenavn = f.hestenavn AND l2.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-3) AS f
  FROM finished i
  WHERE f <> 1
  --ORDER BY i.dato DESC
) AS l3 ON l3.hestenavn = f.hestenavn AND l3.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-4) AS f
  FROM finished i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l4 ON l4.hestenavn = f.hestenavn AND l4.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-5) AS f
  FROM finished i
  WHERE f <> 1
  --ORDER BY i.dato DESC
) AS l5 ON l5.hestenavn = f.hestenavn AND l5.f = f.f
ORDER BY f.dato DESC
;



-- tell dnf løp og avsluttede løp innenfor siste 365 dager før løpet
-- TELLER BARE FOR DE SOM ER I DNF I LØPET (MÅ INKLUDERE DE FRA DEN ANDRE TABELLEN PÅ ET VIS)
SELECT
  d.dato dato,
  d.travbane travbane,
  d.hestenavn hest,
  d.l lopnr,
  (
    SELECT COUNT(b.dato)
    FROM dnf b
    WHERE
      b.hestenavn = d.hestenavn AND
      b.f <> 1 AND
      b.pl <> 'Strøket' AND
      (d.dato - b.dato) < 366 AND
      (d.dato - b.dato) > 0 -- for å hindre at løp som går i fremtiden blir med
  ) AS dnf_siste365,
  (
    SELECT COUNT(f.dato)
    FROM finished f
    WHERE
      f.hestenavn = d.hestenavn AND
      f.f <> 1 AND
      (d.dato - f.dato) < 366 AND
      (d.dato - f.dato) > 0
  ) AS finished_siste365
FROM dnf d
ORDER BY d.dato DESC, d.l DESC, d.hestenavn DESC
;

-- finner hvilke datoer innenfor 365 dager før løpet hvor hesten DNF/ble disket
SELECT
  d.dato dato,
  d.travbane travbane,
  d.hestenavn hest,
  d.l lopnr,
  l.dato
FROM dnf d
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-1) AS f
  FROM dnf i
  WHERE f <> 1 AND pl <> 'Strøket'
) AS l ON l.hestenavn = d.hestenavn
  AND (d.dato - l.dato) < 366
  AND (d.dato - l.dato) > 0
ORDER BY d.dato DESC, l.hestenavn DESC, l.dato DESC
LIMIT 100;

-- tell brutte løp innenfor siste 365 dager før løpet
SELECT
  d.dato dato,
  d.travbane travbane,
  d.hestenavn hest,
  d.l lopnr,
  COUNT(l.dato)
FROM dnf d
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-1) AS f
  FROM dnf i
  WHERE f <> 1 AND pl <> 'Strøket'
) AS l ON l.hestenavn = d.hestenavn
  AND (d.dato - l.dato) < 366
  AND (d.dato - l.dato) > 0
GROUP BY d.dato, d.travbane, d.hestenavn, d.l
ORDER BY d.dato DESC
;
--LIMIT 5;



-- finner alle som brøyt løpet og hvilke ganger tidligere de ikke brøyt løpet (innenfor ett år)
SELECT DISTINCT
  dnf.dato dnfdato,
  dnf.travbane dnftravbane,
  dnf.l dnflopnr,
  dnf.hestenavn dnfhest,
  f.dato fdato,
  f.travbane ftravbane,
  f.l flopnr,
  f.hestenavn fhest
FROM
  dnf
LEFT JOIN
  finished f
ON
  dnf.hestenavn = f.hestenavn
WHERE
  dnf.dato > '2017-03-24' AND
  (dnf.dato - f.dato) < 366 AND
  (dnf.dato - f.dato) > 0
ORDER BY
  dnf.dato DESC,
  dnf.l DESC,
  dnf.hestenavn DESC,
  f.dato DESC
LIMIT 10000;
