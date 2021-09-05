-- siste 5 avsluttede løp med hastighet (dagens løp er også avsluttet)
-- bugga fordi finished må ha egne forekomstnumre (er nå blandet med DNF)
-- når dette er fikset bruk inner join
CREATE MATERIALIZED VIEW varmblods5kmgp AS
SELECT
  f.km                km,
  l.startmetode       startm,
  l.distanse          ldist,
  f.hdist             hdist,
  l1.km               l1,
  (f.dato - l1.dato)  l1d,
  l1.startmetode      l1s,
  l1.distanse         l1ldist,
  l1.hdist            l1hdist,
  l1.anthester        l1ant,
  l1.g                l1g,
  l1.p                l1p,
  l2.km               l2,
  (f.dato - l2.dato)  l2d,
  l2.startmetode      l2s,
  l2.distanse         l2ldist,
  l2.hdist            l2hdist,
  l2.anthester        l2ant,
  l2.g                l2g,
  l2.p                l2p,
  l3.km               l3,
  (f.dato - l3.dato)  l3d,
  l3.startmetode      l3s,
  l3.distanse         l3ldist,
  l3.hdist            l3dist,
  l3.anthester        l3ant,
  l3.g                l3g,
  l3.p                l3p,
  l4.km               l4,
  (f.dato - l4.dato)  l4d,
  l4.startmetode      l4s,
  l4.distanse         l4ldist,
  l4.hdist            l4dist,
  l4.anthester        l4ant,
  l4.g                l4g,
  l4.p                l4p,
  l5.km               l5,
  (f.dato - l5.dato)  l5d,
  l5.startmetode      l5s,
  l5.distanse         l5ldist,
  l5.hdist            l5dist,
  l5.anthester        l5ant,
  l5.g                l5g,
  l5.p                l5p
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, a.anthester, i.g, i.p, (i.f-1) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1 AND rase = 'Varmblods'
) AS l1 ON l1.hest = f.hest AND l1.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, a.anthester, i.g, i.p, (i.f-2) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1 AND rase = 'Varmblods'
) AS l2 ON l2.hest = f.hest AND l2.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, a.anthester, i.g, i.p, (i.f-3) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1 AND rase = 'Varmblods'
) AS l3 ON l3.hest = f.hest AND l3.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, a.anthester, i.g, i.p, (i.f-4) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1 AND rase = 'Varmblods'
  ORDER BY i.dato DESC
) AS l4 ON l4.hest = f.hest AND l4.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, a.anthester, i.g, i.p, (i.f-5) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1 AND rase = 'Varmblods'
) AS l5 ON l5.hest = f.hest AND l5.f = f.f
INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr AND
  f.rase = l.lop_rase
WHERE rase = 'Varmblods'
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC
;


CREATE VIEW varmblods5km AS
SELECT
  l.startmetode       startm,
  l.distanse          ldist,
  f.hdist             hdist,
  f.km                km,
  (f.dato - l1.dato)  l1d,
  l1.startmetode      l1s,
  l1.distanse         l1ldist,
  l1.hdist            l1hdist,
  l1.km               l1,
  (f.dato - l2.dato)  l2d,
  l2.startmetode      l2s,
  l2.distanse         l2ldist,
  l2.hdist            l2hdist,
  l2.km               l2,
  (f.dato - l3.dato)  l3d,
  l3.startmetode      l3s,
  l3.distanse         l3ldist,
  l3.hdist            l3dist,
  l3.km               l3,
  (f.dato - l4.dato)  l4d,
  l4.startmetode      l4s,
  l4.distanse         l4ldist,
  l4.hdist            l4dist,
  l4.km               l4,
  (f.dato - l5.dato)  l5d,
  l5.startmetode      l5s,
  l5.distanse         l5ldist,
  l5.hdist            l5dist,
  l5.km               l5
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, (i.f-1) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr
  WHERE f <> 1 AND rase = 'Kaldblods'
) AS l1 ON l1.hest = f.hest AND l1.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, (i.f-2) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr
  WHERE f <> 1 AND rase = 'Kaldblods'
) AS l2 ON l2.hest = f.hest AND l2.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, (i.f-3) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr
  WHERE f <> 1 AND rase = 'Kaldblods'
) AS l3 ON l3.hest = f.hest AND l3.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, (i.f-4) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr
  WHERE f <> 1 AND rase = 'Kaldblods'
  ORDER BY i.dato DESC
) AS l4 ON l4.hest = f.hest AND l4.f = f.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, (i.f-5) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr
  WHERE f <> 1 AND rase = 'Kaldblods'
) AS l5 ON l5.hest = f.hest AND l5.f = f.f
INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr
WHERE rase = 'Kaldblods'
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC
;



CREATE MATERIALIZED VIEW l1km AS
SELECT
  f.dato,
  f.tidspunkt,
  f.travbane,
  f.lopnr,
  f.km                km,
  l.startmetode       startm,
  l.distanse          ldist,
  f.hdist             hdist,
  l1.km               l1,
  (f.dato - l1.dato)  l1d,
  l1.startmetode      l1s,
  l1.distanse         l1ldist,
  l1.hdist            l1hdist,
  l1.snr              l1snr,
  l1.anthester        l1ant,
  l1.g                l1g
  --l1.p                l1p alltid 0
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse, i.km, i.snr, a.anthester, i.g, (i.f-1) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND i.tidspunkt = a.tidspunkt AND i.travbane = a.travbane AND i.lopnr = a.lopnr
  WHERE f <> 1
) AS l1 ON l1.hest = f.hest AND l1.f = f.f
INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr AND
  f.rase = l.lop_rase
WHERE rase = 'Varmblods'
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC
;
