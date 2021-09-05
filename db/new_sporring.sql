CREATE VIEW travfinished AS
SELECT * FROM finished
WHERE
  f.dato >= '2010-01-01' AND
  f.lopnavn NOT LIKE '%monte%' AND
  f.lopnavn NOT LIKE '%montè%' AND
  f.lopnavn NOT LIKE '%monté%' AND
  f.lopnavn NOT LIKE '%Monte%' AND
  f.lopnavn NOT LIKE '%Montè%' AND
  f.lopnavn NOT LIKE '%Monté%' AND
  f.lopnavn NOT LIKE '%MONTE%' AND
  f.lopnavn NOT LIKE '%MONTÈ%' AND
  f.lopnavn NOT LIKE '%MONTÉ%' AND
  f.lopnavn NOT LIKE '%MÕNTE%' AND
  f.lopnavn NOT LIKE '%Mõnte%' AND
  f.lopnavn NOT LIKE '%mõnte%';

CREATE VIEW vtravfinished AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.kusk, f.pl, f.snr, f.hdist, f.premie,
       f.odds, f.KM, f.g, f.p, f.gX, f.dg, f.dp, f.dgp, f.brg, f.brp, f.dv, f.d, f.t, f.rase, f.f
FROM finished f INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr
WHERE
  f.dato >= '2010-01-01' AND
  f.rase = 'Varmblods' AND
  l.lopnavn NOT LIKE '%monte%' AND
  l.lopnavn NOT LIKE '%montè%' AND
  l.lopnavn NOT LIKE '%monté%' AND
  l.lopnavn NOT LIKE '%Monte%' AND
  l.lopnavn NOT LIKE '%Montè%' AND
  l.lopnavn NOT LIKE '%Monté%' AND
  l.lopnavn NOT LIKE '%MONTE%' AND
  l.lopnavn NOT LIKE '%MONTÈ%' AND
  l.lopnavn NOT LIKE '%MONTÉ%' AND
  l.lopnavn NOT LIKE '%MÕNTE%' AND
  l.lopnavn NOT LIKE '%Mõnte%' AND
  l.lopnavn NOT LIKE '%mõnte%';

  CREATE VIEW ktravfinished AS
  SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.kusk, f.pl, f.snr, f.hdist, f.premie,
         f.odds, f.KM, f.g, f.p, f.gX, f.dg, f.dp, f.dgp, f.brg, f.brp, f.dv, f.d, f.t, f.rase, f.f
  FROM finished f INNER JOIN lop l ON
    f.dato = l.dato AND
    f.tidspunkt = l.tidspunkt AND
    f.travbane = l.travbane AND
    f.lopnr = l.lopnr
  WHERE
    f.dato >= '2010-01-01' AND
    f.rase = 'Kaldblods' AND
    l.lopnavn NOT LIKE '%monte%' AND
    l.lopnavn NOT LIKE '%montè%' AND
    l.lopnavn NOT LIKE '%monté%' AND
    l.lopnavn NOT LIKE '%Monte%' AND
    l.lopnavn NOT LIKE '%Montè%' AND
    l.lopnavn NOT LIKE '%Monté%' AND
    l.lopnavn NOT LIKE '%MONTE%' AND
    l.lopnavn NOT LIKE '%MONTÈ%' AND
    l.lopnavn NOT LIKE '%MONTÉ%' AND
    l.lopnavn NOT LIKE '%MÕNTE%' AND
    l.lopnavn NOT LIKE '%Mõnte%' AND
    l.lopnavn NOT LIKE '%mõnte%';

-- finner antall hester til start i løp hvor en eller flere er strøket
-- (order by fucker visst opp på union så dropper det)
CREATE MATERIALIZED VIEW anthestertilstart AS
SELECT r.dato, r.tidspunkt, r.travbane, r.lopnr, (f.anthester + d.anthester) AS anthester
FROM lop r
INNER JOIN
(
  SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, COUNT(*) AS anthester
  FROM finished f
  GROUP BY f.dato, f.tidspunkt, f.travbane, f.lopnr
) AS f ON
  r.dato = f.dato AND
  r.tidspunkt = f.tidspunkt AND
  r.travbane = f.travbane AND
  r.lopnr = f.lopnr
INNER JOIN
(
  SELECT d.dato, d.tidspunkt, d.travbane, d.lopnr, COUNT(*) anthester
  FROM dnf d
  WHERE d.pl <> 'Strøket'
  GROUP BY d.dato, d.tidspunkt, d.travbane, d.lopnr
) AS d ON
  r.dato = d.dato AND
  r.tidspunkt = d.tidspunkt AND
  r.travbane = d.travbane AND
  r.lopnr = d.lopnr
UNION
-- finner antall hester til start hvor ingen hester er strøket
SELECT r.dato, r.tidspunkt, r.travbane, r.lopnr, (f.anthester) AS anthester
FROM lop r
INNER JOIN
(
  SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, COUNT(*) AS anthester
  FROM finished f
  GROUP BY f.dato, f.tidspunkt, f.travbane, f.lopnr
) AS f ON
  r.dato = f.dato AND
  r.tidspunkt = f.tidspunkt AND
  r.travbane = f.travbane AND
  r.lopnr = f.lopnr
LEFT JOIN
(
  SELECT d.dato, d.tidspunkt, d.travbane, d.lopnr, COUNT(*) anthester
  FROM dnf d
  WHERE d.pl <> 'Strøket'
  GROUP BY d.dato, d.tidspunkt, d.travbane, d.lopnr
) AS d ON
  r.dato = d.dato AND
  r.tidspunkt = d.tidspunkt AND
  r.travbane = d.travbane AND
  r.lopnr = d.lopnr
WHERE
  d.dato IS NULL AND
  d.tidspunkt IS NULL AND
  d.travbane IS NULL AND
  d.lopnr IS NULL;



CREATE MATERIALIZED VIEW starter AS
-- starter fra finished
SELECT
  f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.g, f.p,
  f.gx, f.dg, f.dp, f.dgp, f.brg, f.brp
FROM
  finished f
-- Starter fra dnf
UNION
SELECT
  d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.g, d.p,
  d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp
FROM dnf d
WHERE d.pl <> 'Strøket'
;

CREATE MATERIALIZED VIEW g365 AS
SELECT
  s.dato,
  s.tidspunkt,
  s.travbane,
  s.lopnr,
  s.hest,
  COUNT(*) antstarter,
  ROUND(SUM(g.g)::NUMERIC / COUNT(g.hest), 4)    g,
  ROUND(SUM(g.gx)::NUMERIC / COUNT(g.hest), 4)   gx,
  ROUND(SUM(g.dg)::NUMERIC / COUNT(g.hest), 4)   dg,
  ROUND(SUM(g.brg)::NUMERIC / COUNT(g.hest), 4)  brg,
  ROUND(SUM(g.dgp)::NUMERIC / COUNT(g.hest), 4)  dgp,
  ROUND(SUM(g.p)::NUMERIC / COUNT(g.hest), 4)    p,
  ROUND(SUM(g.dp)::NUMERIC / COUNT(g.hest), 4)   dp,
  ROUND(SUM(g.brp)::NUMERIC / COUNT(g.hest), 4)  brp
FROM starter s
INNER JOIN starter g ON s.hest = g.hest
WHERE
  (s.dato <> g.dato) AND
  (s.dato - g.dato) < 366 AND
  (s.dato - g.dato) > 0
GROUP BY  s.dato, s.tidspunkt, s.travbane, s.lopnr, s.hest
ORDER BY  s.dato DESC, s.travbane DESC, s.lopnr DESC, s.hest DESC;

-- bruker 0.8 som vekt
CREATE MATERIALIZED VIEW gwtimeweight AS
SELECT
  s.dato, s.tidspunkt, s.travbane, s.lopnr, s.hest,
  g.dato ldato, g.travbane lbane, g.lopnr lnr,
  CASE WHEN ((s.dato - g.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((s.dato - g.dato)::NUMERIC / 365), 3) END tweight,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp
FROM starter s
INNER JOIN starter g ON s.hest = g.hest
WHERE
  (s.dato <> g.dato) AND
  (s.dato - g.dato) > 0
--GROUP BY  s.dato, s.tidspunkt, s.travbane, s.lopnr, s.hest
ORDER BY  s.dato DESC, s.travbane DESC, s.lopnr ASC, s.hest ASC, g.dato DESC
;

CREATE MATERIALIZED VIEW weightedg AS
SELECT dato, tidspunkt, travbane, lopnr, hest,
       SUM(tweight) sweight,
       ROUND(SUM(tweight*g) / COUNT(*), 4) wg,
       ROUND(SUM(tweight*gx) / COUNT(*), 4) wgx,
       ROUND(SUM(tweight*dg) / COUNT(*), 4) wdg,
       ROUND(SUM(tweight*brg) / COUNT(*), 4) wbrg,
       ROUND(SUM(tweight*dgp) / COUNT(*), 4) wdgp,
       ROUND(SUM(tweight*p) / COUNT(*), 4) wp,
       ROUND(SUM(tweight*dp) / COUNT(*), 4) wdp,
       ROUND(SUM(tweight*brp) / COUNT(*), 4) wbrp
FROM gwtimeweight
GROUP BY dato, tidspunkt, travbane, lopnr, hest
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;

-- bruker 0.8 some vekt
CREATE MATERIALIZED VIEW kmwtimeweight AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((f.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((f.dato - l.dato)::NUMERIC / 365), 3) END tweight,
       l.km
FROM finished f
INNER JOIN finished l ON f.hest = l.hest
WHERE f.dato <> l.dato AND (f.dato - l.dato) > 0
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest ASC, l.dato DESC
;


CREATE MATERIALIZED VIEW weightedkm AS
SELECT dato, tidspunkt, travbane, lopnr, hest,
       SUM(tweight) sweight,
       ROUND(SUM(tweight*km) / COUNT(*), 4) wkm
FROM kmwtimeweight
GROUP BY dato, tidspunkt, travbane, lopnr, hest
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;


-- Perfekt!
-- Eller.. trenger ikke galopp for hver gang som over amg
CREATE MATERIALIZED VIEW l1v1 AS
SELECT i.dato, i.travbane, i.hest, (i.f-1) AS f, i.km, il.startmetode, il.distanse,
--ROUND(i.hdist::NUMERIC / il.distanse - 1, 4) hdist, i.snr, ia.anthester, i.rase--,
       i.hdist, i.snr, ia.anthester, i.rase
       --g.antstarter, g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp
FROM finished i
INNER JOIN g365 g ON
  i.dato = g.dato AND
  i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest
INNER JOIN lop il ON
  i.dato = il.dato AND
  i.tidspunkt = il.tidspunkt AND
  i.travbane = il.travbane AND
  i.lopnr = il.lopnr AND
  i.rase = il.lop_rase
INNER JOIN anthestertilstart ia ON
  i.dato = ia.dato AND
  i.tidspunkt = ia.tidspunkt AND
  i.travbane = ia.travbane AND
  i.lopnr = ia.lopnr
WHERE f > 1
ORDER BY i.dato DESC;

CREATE MATERIALIZED VIEW l2v1 AS
SELECT i.dato, i.travbane, i.hest, (i.f-2) AS f, i.km, il.startmetode, il.distanse,
--ROUND(i.hdist::NUMERIC / il.distanse - 1, 4) hdist, i.snr, ia.anthester, i.rase--,
       i.hdist, i.snr, ia.anthester, i.rase
       --g.antstarter, g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp
FROM finished i
INNER JOIN g365 g ON
  i.dato = g.dato AND
  i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest
INNER JOIN lop il ON
  i.dato = il.dato AND
  i.tidspunkt = il.tidspunkt AND
  i.travbane = il.travbane AND
  i.lopnr = il.lopnr AND
  i.rase = il.lop_rase
INNER JOIN anthestertilstart ia ON
  i.dato = ia.dato AND
  i.tidspunkt = ia.tidspunkt AND
  i.travbane = ia.travbane AND
  i.lopnr = ia.lopnr
WHERE f > 2
ORDER BY i.dato DESC;

CREATE MATERIALIZED VIEW l3v1 AS
SELECT i.dato, i.travbane, i.hest, (i.f-3) AS f, i.km, il.startmetode, il.distanse,
--ROUND(i.hdist::NUMERIC / il.distanse - 1, 4) hdist, i.snr, ia.anthester, i.rase--,
       i.hdist, i.snr, ia.anthester, i.rase
       --g.antstarter, g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp
FROM finished i
INNER JOIN g365 g ON
  i.dato = g.dato AND
  i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest
INNER JOIN lop il ON
  i.dato = il.dato AND
  i.tidspunkt = il.tidspunkt AND
  i.travbane = il.travbane AND
  i.lopnr = il.lopnr AND
  i.rase = il.lop_rase
INNER JOIN anthestertilstart ia ON
  i.dato = ia.dato AND
  i.tidspunkt = ia.tidspunkt AND
  i.travbane = ia.travbane AND
  i.lopnr = ia.lopnr
WHERE f > 3
ORDER BY i.dato DESC;

CREATE MATERIALIZED VIEW l4v1 AS
SELECT i.dato, i.travbane, i.hest, (i.f-4) AS f, i.km, il.startmetode, il.distanse,
--ROUND(i.hdist::NUMERIC / il.distanse - 1, 4) hdist, i.snr, ia.anthester, i.rase--,
       i.hdist, i.snr, ia.anthester, i.rase
       --g.antstarter, g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp
FROM finished i
INNER JOIN g365 g ON
  i.dato = g.dato AND
  i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest
INNER JOIN lop il ON
  i.dato = il.dato AND
  i.tidspunkt = il.tidspunkt AND
  i.travbane = il.travbane AND
  i.lopnr = il.lopnr AND
  i.rase = il.lop_rase
INNER JOIN anthestertilstart ia ON
  i.dato = ia.dato AND
  i.tidspunkt = ia.tidspunkt AND
  i.travbane = ia.travbane AND
  i.lopnr = ia.lopnr
WHERE f > 4
ORDER BY i.dato DESC;

CREATE MATERIALIZED VIEW l5v1 AS
SELECT i.dato, i.travbane, i.hest, (i.f-5) AS f, i.km, il.startmetode, il.distanse,
--ROUND(i.hdist::NUMERIC / il.distanse - 1, 4) hdist, i.snr, ia.anthester, i.rase--,
       i.hdist, i.snr, ia.anthester, i.rase
       --g.antstarter, g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp
FROM finished i
INNER JOIN g365 g ON
  i.dato = g.dato AND
  i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest
INNER JOIN lop il ON
  i.dato = il.dato AND
  i.tidspunkt = il.tidspunkt AND
  i.travbane = il.travbane AND
  i.lopnr = il.lopnr AND
  i.rase = il.lop_rase
INNER JOIN anthestertilstart ia ON
  i.dato = ia.dato AND
  i.tidspunkt = ia.tidspunkt AND
  i.travbane = ia.travbane AND
  i.lopnr = ia.lopnr
WHERE f > 5
ORDER BY i.dato DESC;

CREATE MATERIALIZED VIEW rg365 AS
SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, g.antstarter ants, r.startmetode sm,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp, f.f, f.rase
FROM finished f
INNER JOIN lop r ON
  f.dato = r.dato AND
  f.tidspunkt = r.tidspunkt AND
  f.travbane = r.travbane AND
  f.lopnr = r.lopnr
INNER JOIN anthestertilstart a ON
  f.dato = a.dato AND
  f.tidspunkt = a.tidspunkt AND
  f.travbane = a.travbane AND
  f.lopnr = a.lopnr
INNER JOIN g365 g ON
  f.dato = g.dato AND
  f.tidspunkt = g.tidspunkt AND
  f.travbane = g.travbane AND
  f.lopnr = g.lopnr AND
  f.hest = g.hest
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC;


CREATE MATERIALIZED VIEW r3l AS
SELECT
  r.dato, r.travbane, r.lopnr, r.rase, r.hest, r.km, r.distanse dist, r.hdist hd, r.snr, r.anth, r.ants,
  CASE WHEN r.sm = 'Auto' THEN 0 WHEN r.sm = 'Volte' THEN 1 WHEN r.sm = 'Linje' THEN 2 END sm,
  r.g, r.gx, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  (r.dato - l1.dato) l1d, l1.km l1km, l1.distanse l1dist, l1.hdist l1hd, l1.snr l1snr, l1.anthester l1anth,
  CASE WHEN l1.startmetode = 'Auto' THEN 0 WHEN l1.startmetode = 'Volte' THEN 1 WHEN l1.startmetode = 'Linje' THEN 2 END l1sm,   --l1.startmetode l1sm,
  (r.dato - l2.dato) l2d, l2.km l2km, l2.distanse l2dist, l2.hdist l2hd, l2.snr l2snr, l2.anthester l2anth,
  CASE WHEN l2.startmetode = 'Auto' THEN 0 WHEN l2.startmetode = 'Volte' THEN 1 WHEN l2.startmetode = 'Linje' THEN 2 END l2sm, --l2.startmetode l2sm,
  (r.dato - l3.dato) l3d, l3.km l3km, l3.distanse l3dist, l3.hdist l3hd, l3.snr l3snr, l3.anthester l3anth,
  CASE WHEN l3.startmetode = 'Auto' THEN 0 WHEN l3.startmetode = 'Volte' THEN 1 WHEN l3.startmetode = 'Linje' THEN 2 END l3sm  --l3.startmetode l3sm
FROM rg365 r
INNER JOIN l1 ON r.hest = l1.hest AND r.f = l1.f
INNER JOIN l2 ON r.hest = l2.hest AND r.f = l2.f
INNER JOIN l3 ON r.hest = l3.hest AND r.f = l3.f
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;



CREATE MATERIALIZED VIEW r5l AS
SELECT
  r.dato, r.travbane, r.lopnr, r.rase, r.hest, r.km, r.distanse dist, r.hdist hd, r.snr, r.anth, r.ants,
  CASE WHEN r.sm = 'Auto' THEN 0 WHEN r.sm = 'Volte' THEN 1 WHEN r.sm = 'Linje' THEN 2 END sm,
  r.g, r.gx, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  (r.dato - l1.dato) l1d, l1.km l1km, l1.distanse l1dist, l1.hdist l1hd, l1.snr l1snr, l1.anthester l1anth,
  CASE WHEN l1.startmetode = 'Auto' THEN 0 WHEN l1.startmetode = 'Volte' THEN 1 WHEN l1.startmetode = 'Linje' THEN 2 END l1sm,   --l1.startmetode l1sm,
  (r.dato - l2.dato) l2d, l2.km l2km, l2.distanse l2dist, l2.hdist l2hd, l2.snr l2snr, l2.anthester l2anth,
  CASE WHEN l2.startmetode = 'Auto' THEN 0 WHEN l2.startmetode = 'Volte' THEN 1 WHEN l2.startmetode = 'Linje' THEN 2 END l2sm, --l2.startmetode l2sm,
  (r.dato - l3.dato) l3d, l3.km l3km, l3.distanse l3dist, l3.hdist l3hd, l3.snr l3snr, l3.anthester l3anth,
  CASE WHEN l3.startmetode = 'Auto' THEN 0 WHEN l3.startmetode = 'Volte' THEN 1 WHEN l3.startmetode = 'Linje' THEN 2 END l3sm,  --l3.startmetode l3sm
  (r.dato - l4.dato) l4d, l4.km l4km, l4.distanse l4dist, l4.hdist l4hd, l4.snr l4snr, l4.anthester l4anth,
  CASE WHEN l4.startmetode = 'Auto' THEN 0 WHEN l4.startmetode = 'Volte' THEN 1 WHEN l4.startmetode = 'Linje' THEN 2 END l4sm,  --l3.startmetode l3sm
  (r.dato - l5.dato) l5d, l5.km l5km, l5.distanse l5dist, l5.hdist l5hd, l5.snr l5snr, l5.anthester l5anth,
  CASE WHEN l5.startmetode = 'Auto' THEN 0 WHEN l5.startmetode = 'Volte' THEN 1 WHEN l5.startmetode = 'Linje' THEN 2 END l5sm  --l3.startmetode l3sm
FROM rg365 r
INNER JOIN l1 ON r.hest = l1.hest AND r.f = l1.f
INNER JOIN l2 ON r.hest = l2.hest AND r.f = l2.f
INNER JOIN l3 ON r.hest = l3.hest AND r.f = l3.f
INNER JOIN l4 ON r.hest = l4.hest AND r.f = l4.f
INNER JOIN l5 ON r.hest = l5.hest AND r.f = l5.f
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;


/*
CREATE MATERIALIZED VIEW r5l AS
SELECT
  r.dato, r.travbane, r.lopnr, r.rase, r.hest, r.km, r.distanse dist, r.hdist hd, r.snr, r.anth, r.ants, r.sm,
  r.g, r.gx, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  (r.dato - l1.dato) l1d, l1.km l1km, l1.distanse l1dist, l1.hdist l1hd, l1.snr l1snr, l1.anthester l1anth, l1.startmetode l1sm,
  (r.dato - l2.dato) l2d, l2.km l2km, l2.distanse l2dist, l2.hdist l2hd, l2.snr l2snr, l2.anthester l2anth, l2.startmetode l2sm,
  (r.dato - l3.dato) l3d, l3.km l3km, l3.distanse l3dist, l3.hdist l3hd, l3.snr l3snr, l3.anthester l3anth, l3.startmetode l3sm,
  (r.dato - l4.dato) l4d, l4.km l4km, l4.distanse l4dist, l4.hdist l4hd, l4.snr l4snr, l4.anthester l4anth, l4.startmetode l4sm,
  (r.dato - l5.dato) l5d, l5.km l5km, l5.distanse l5dist, l5.hdist l5hd, l5.snr l5snr, l5.anthester l5anth, l5.startmetode l5sm
FROM rg365 r
INNER JOIN l1 ON r.hest = l1.hest AND r.f = l1.f
INNER JOIN l2 ON r.hest = l2.hest AND r.f = l2.f
INNER JOIN l3 ON r.hest = l3.hest AND r.f = l3.f
INNER JOIN l4 ON r.hest = l4.hest AND r.f = l4.f
INNER JOIN l5 ON r.hest = l5.hest AND r.f = l5.f
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;
*/

-- Data til CSV
SELECT
  r.km, r.dist, ROUND(r.hd::NUMERIC/r.dist - 1, 4) hd, r.snr, r.anth, r.ants, r.sm, r.g, r.g, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  r.l1d, r.l1km, r.l1dist, r.l1hd, r.l1snr, r.l1anth, r.l1sm,
  r.l2d, r.l2km, r.l2dist, r.l2hd, r.l2snr, r.l2anth, r.l2sm,
  r.l3d, r.l3km, r.l3dist, r.l3hd, r.l3snr, r.l3anth, r.l3sm,
  r.l4d, r.l4km, r.l4dist, r.l4hd, r.l4snr, r.l4anth, r.l4sm,
  r.l5d, r.l5km, r.l5dist, r.l5hd, r.l5snr, r.l5anth, r.l5sm
FROM r5l r
WHERE rase = 'Varmblods'
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;

SELECT
  r.km, r.dist, ROUND(r.hd::NUMERIC/r.dist - 1, 4) hd, r.snr, r.anth, r.ants, r.sm, r.g, r.g, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  r.l1d, r.l1km, r.l1dist, r.l1hd, r.l1snr, r.l1anth, r.l1sm,
  r.l2d, r.l2km, r.l2dist, r.l2hd, r.l2snr, r.l2anth, r.l2sm,
  r.l3d, r.l3km, r.l3dist, r.l3hd, r.l3snr, r.l3anth, r.l3sm,
  r.l4d, r.l4km, r.l4dist, r.l4hd, r.l4snr, r.l4anth, r.l4sm,
  r.l5d, r.l5km, r.l5dist, r.l5hd, r.l5snr, r.l5anth, r.l5sm
FROM r5l r
WHERE rase = 'Kaldblods'
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;

CREATE MATERIALIZED VIEW hpremie365 AS
SELECT f.dato, f.travbane, f.lopnr, f.hest,
       ROUND((COUNT(CASE WHEN p.pl = '1' THEN 1 END))::NUMERIC / COUNT(*), 4) AS seier_prosent,
       ROUND((COUNT(CASE WHEN p.pl = '2' THEN 1 END))::NUMERIC / COUNT(*), 4) AS andre_prosent,
       ROUND((COUNT(CASE WHEN p.pl = '3' THEN 1 END))::NUMERIC / COUNT(*), 4) AS tredje_prosent,
       SUM(p.premie) premie365
FROM finished f
INNER JOIN finished p ON f.hest = p.hest
WHERE
  (f.dato <> p.dato) AND
  (f.dato - p.dato) < 366 AND
  (f.dato - p.dato) > 0
GROUP BY f.dato, f.travbane, f.lopnr, f.hest
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest;

CREATE MATERIALIZED VIEW hpremiepre365 AS
SELECT f.dato, f.travbane, f.lopnr, f.hest,
       ROUND((COUNT(CASE WHEN p.pl = '1' THEN 1 END))::NUMERIC / COUNT(*), 4) AS seier_prosent,
       ROUND((COUNT(CASE WHEN p.pl = '2' THEN 1 END))::NUMERIC / COUNT(*), 4) AS andre_prosent,
       ROUND((COUNT(CASE WHEN p.pl = '3' THEN 1 END))::NUMERIC / COUNT(*), 4) AS tredje_prosent,
       SUM(p.premie) premie365
       INNER JOIN finished p ON f.hest = p.hest
FROM finished f
WHERE
  (f.dato - p.dato) > 365
GROUP BY f.dato, f.travbane, f.lopnr, f.hest
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest;


-- Henter alle dueller fra alle løp fra r3l (COUNT(*) = 1476674)
SELECT h.dato, h.travbane, h.lopnr, h.hest,
       m.dato, m.travbane, m.lopnr, m.hest, (h.km - m.km)
FROM r3l h
INNER JOIN r3l m ON
  h.dato = m.dato AND
  h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND
  h.hest <> m.hest
WHERE h.snr < m.snr
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.snr ASC;


--COPY (SELECT * FROM r3l WHERE rase = 'Varmblods') TO '/var/lib/pgsql/midl/r3lv.csv' DELIMITER ';';
COPY (
SELECT (h.l3d - m.l3d) l3dd, (h.l3hd - m.l3hd) l3hdd, (h.l3km - m.l3km) l3kmd,
       (h.l2d - m.l2d) l2dd, (h.l2hd - m.l2hd) l2hdd, (h.l2km - m.l2km) l2kmd,
       (h.l1d - m.l1d) l1dd, (h.l1hd - m.l1hd) l1hdd, (h.l1km - m.l1km) l1kmd,
       (h.hd - m.hd) hdd, (h.g - m.g) gd, (h.gx - m.gx) gx, (h.dg - m.dg) dgd,
       (h.brg - m.brg) brgd, (h.dgp - m.dgp) dgpd, (h.p - m.p) pd, (h.brp - m.brp) brpd,
       (h.km - m.km) kmd  -- OUTPUT (y)
FROM r3l h
INNER JOIN r3l m ON
  h.dato = m.dato AND
  h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND
  h.hest <> m.hest
WHERE h.snr < m.snr AND h.rase = 'Varmblods' AND m.rase = 'Varmblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.snr ASC
)
TO '/var/lib/pgsql/midl/r3lv.csv' DELIMITER ';';


-- trengs for å joine dnf i lag
-- SKAL IKKE I LAG! blir da problemet med at man får NAN verdier i lag..
CREATE MATERIALIZED VIEW dnf_f AS
SELECT d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
       d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase,
       (COUNT(f.dato)+1) f
FROM dnf d
INNER JOIN finished f ON
  d.hest = f.hest
WHERE d.pl <> 'Strøket' AND d.pl <>  'Tid ikke tatt' AND d.dato < f.dato
GROUP BY d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
         d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase;
--HAVING COUNT(f.dato) > 1

--ORDER BY d.dato DESC, d.travbane DESC, d.lopnr ASC;
UNION
SELECT DISTINCT
       d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
       d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase,
       COUNT(f.dato)+1 f
FROM dnf d
INNER JOIN finished f ON
  d.hest = f.hest
WHERE d.pl <> 'Strøket' AND d.pl <>  'Tid ikke tatt' AND d.dato > f.dato AND d.f = 1
GROUP BY d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
         d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase,
         f.dato, f.travbane, f.lopnr, f.hest
        -- COUNT(f.dato)
--HAVING COUNT(f.dato) = 1
;
ORDER BY d.dato DESC, d.travbane DESC, d.lopnr ASC;


-- funker endelig?
CREATE MATERIALIZED VIEW dnff AS
SELECT DISTINCT
       d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
       d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase,
       MAX(d.f) f
FROM dnf d
WHERE d.pl <> 'Strøket' AND d.pl <> 'Tid ikke tatt'
GROUP BY
  d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.kusk, d.pl, d.snr, d.hdist, d.premie,
  d.odds, d.km, d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.dv, d.d, d.t, d.rase
ORDER BY d.dato DESC, d.travbane DESC, d.lopnr ASC, d.hest ASC;


CREATE MATERIALIZED VIEW rg365mdnf AS
SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, g.antstarter ants, r.startmetode sm,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp, f.f, f.rase
FROM finished f
INNER JOIN lop r ON
  f.dato = r.dato AND
  f.tidspunkt = r.tidspunkt AND
  f.travbane = r.travbane AND
  f.lopnr = r.lopnr
INNER JOIN anthestertilstart a ON
  f.dato = a.dato AND
  f.tidspunkt = a.tidspunkt AND
  f.travbane = a.travbane AND
  f.lopnr = a.lopnr
INNER JOIN g365 g ON
  f.dato = g.dato AND
  f.tidspunkt = g.tidspunkt AND
  f.travbane = g.travbane AND
  f.lopnr = g.lopnr AND
  f.hest = g.hest
WHERE f.dato >= '2007-01-01'
UNION
SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, g.antstarter ants, r.startmetode sm,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp, f.f, f.rase
FROM dnff f
INNER JOIN lop r ON
  f.dato = r.dato AND
  f.tidspunkt = r.tidspunkt AND
  f.travbane = r.travbane AND
  f.lopnr = r.lopnr
INNER JOIN anthestertilstart a ON
  f.dato = a.dato AND
  f.tidspunkt = a.tidspunkt AND
  f.travbane = a.travbane AND
  f.lopnr = a.lopnr
INNER JOIN g365 g ON
  f.dato = g.dato AND
  f.tidspunkt = g.tidspunkt AND
  f.travbane = g.travbane AND
  f.lopnr = g.lopnr AND
  f.hest = g.hest
  WHERE f.dato >= '2007-01-01';


CREATE MATERIALIZED VIEW r3lmdnf AS
SELECT
  r.dato, r.travbane, r.lopnr, r.rase, r.hest, r.km, r.distanse dist, r.hdist hd, r.snr, r.anth, r.ants,
  CASE WHEN r.sm = 'Auto' THEN 0 WHEN r.sm = 'Volte' THEN 1 WHEN r.sm = 'Linje' THEN 2 END sm,
  r.g, r.gx, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  (r.dato - l1.dato) l1d, l1.km l1km, l1.distanse l1dist, l1.hdist l1hd, l1.snr l1snr, l1.anthester l1anth,
  CASE WHEN l1.startmetode = 'Auto' THEN 0 WHEN l1.startmetode = 'Volte' THEN 1 WHEN l1.startmetode = 'Linje' THEN 2 END l1sm,   --l1.startmetode l1sm,
  (r.dato - l2.dato) l2d, l2.km l2km, l2.distanse l2dist, l2.hdist l2hd, l2.snr l2snr, l2.anthester l2anth,
  CASE WHEN l2.startmetode = 'Auto' THEN 0 WHEN l2.startmetode = 'Volte' THEN 1 WHEN l2.startmetode = 'Linje' THEN 2 END l2sm, --l2.startmetode l2sm,
  (r.dato - l3.dato) l3d, l3.km l3km, l3.distanse l3dist, l3.hdist l3hd, l3.snr l3snr, l3.anthester l3anth,
  CASE WHEN l3.startmetode = 'Auto' THEN 0 WHEN l3.startmetode = 'Volte' THEN 1 WHEN l3.startmetode = 'Linje' THEN 2 END l3sm  --l3.startmetode l3sm
FROM rg365mdnf r
INNER JOIN l1 ON r.hest = l1.hest AND r.f = l1.f
INNER JOIN l2 ON r.hest = l2.hest AND r.f = l2.f
INNER JOIN l3 ON r.hest = l3.hest AND r.f = l3.f
--WHERE r.km = -1
ORDER BY r.dato DESC, r.travbane DESC, r.lopnr ASC;
UNION
SELECT
  r.dato, r.travbane, r.lopnr, r.rase, r.hest, r.km, r.distanse dist, r.hdist hd, r.snr, r.anth, r.ants,
  CASE WHEN r.sm = 'Auto' THEN 0 WHEN r.sm = 'Volte' THEN 1 WHEN r.sm = 'Linje' THEN 2 END sm,
  r.g, r.gx, r.dg, r.brg, r.dgp, r.p, r.dp, r.brp,
  (r.dato - l1.dato) l1d, l1.km l1km, l1.distanse l1dist, l1.hdist l1hd, l1.snr l1snr, l1.anthester l1anth,
  CASE WHEN l1.startmetode = 'Auto' THEN 0 WHEN l1.startmetode = 'Volte' THEN 1 WHEN l1.startmetode = 'Linje' THEN 2 END l1sm,   --l1.startmetode l1sm,
  (r.dato - l2.dato) l2d, l2.km l2km, l2.distanse l2dist, l2.hdist l2hd, l2.snr l2snr, l2.anthester l2anth,
  CASE WHEN l2.startmetode = 'Auto' THEN 0 WHEN l2.startmetode = 'Volte' THEN 1 WHEN l2.startmetode = 'Linje' THEN 2 END l2sm, --l2.startmetode l2sm,
  (r.dato - l3.dato) l3d, l3.km l3km, l3.distanse l3dist, l3.hdist l3hd, l3.snr l3snr, l3.anthester l3anth,
  CASE WHEN l3.startmetode = 'Auto' THEN 0 WHEN l3.startmetode = 'Volte' THEN 1 WHEN l3.startmetode = 'Linje' THEN 2 END l3sm  --l3.startmetode l3sm
FROM rg365 r
INNER JOIN l1 ON r.hest = l1.hest AND r.f = l1.f
INNER JOIN l2 ON r.hest = l2.hest AND r.f = l2.f
INNER JOIN l3 ON r.hest = l3.hest AND r.f = l3.f;


-- alle varmblodsdueller
  COPY (
SELECT (h.l3d - m.l3d) l3dd, (h.l3hd - m.l3hd) l3hdd, (h.l3km - m.l3km) l3kmd,
       (h.l2d - m.l2d) l2dd, (h.l2hd - m.l2hd) l2hdd, (h.l2km - m.l2km) l2kmd,
       (h.l1d - m.l1d) l1dd, (h.l1hd - m.l1hd) l1hdd, (h.l1km - m.l1km) l1kmd,
       (h.hd - m.hd) hdd, (h.g - m.g) gd, (h.gx - m.gx) gx, (h.dg - m.dg) dgd,
       (h.brg - m.brg) brgd, (h.dgp - m.dgp) dgpd, (h.p - m.p) pd, (h.brp - m.brp) brpd,
       /*h.km, h.hd, m.km, m.hd,
       ROUND(((h.km + 60) * (h.hd::NUMERIC/1000)),3) htid,
       ROUND(((m.km + 60) * (m.hd::NUMERIC/1000)),3) mtid,*/
       CASE WHEN h.km = -1 THEN 0
            WHEN m.km = -1 THEN 1
            WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) <= ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 1
            WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) > ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 0
            ELSE 1 END AS fim   -- 1 hvis begge kommer i mål likt
            --WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) > ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 0 END
FROM r3lmdnf h
INNER JOIN r3lmdnf m ON
  h.dato = m.dato AND
  h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND
  h.hest <> m.hest
WHERE h.snr < m.snr AND h.rase = 'Varmblods' AND m.rase = 'Varmblods'
ORDER BY h.dato ASC, h.travbane DESC, h.lopnr DESC, h.snr DESC
  )
  TO '/var/lib/pgsql/midl/r3lv.csv' DELIMITER ';';


  -- alle kaldblodsdueller
    COPY (
  SELECT (h.l3d - m.l3d) l3dd, (h.l3hd - m.l3hd) l3hdd, (h.l3km - m.l3km) l3kmd,
         (h.l2d - m.l2d) l2dd, (h.l2hd - m.l2hd) l2hdd, (h.l2km - m.l2km) l2kmd,
         (h.l1d - m.l1d) l1dd, (h.l1hd - m.l1hd) l1hdd, (h.l1km - m.l1km) l1kmd,
         (h.hd - m.hd) hdd, (h.g - m.g) gd, (h.gx - m.gx) gx, (h.dg - m.dg) dgd,
         (h.brg - m.brg) brgd, (h.dgp - m.dgp) dgpd, (h.p - m.p) pd, (h.brp - m.brp) brpd,
         /*h.km, h.hd, m.km, m.hd,
         ROUND(((h.km + 60) * (h.hd::NUMERIC/1000)),3) htid,
         ROUND(((m.km + 60) * (m.hd::NUMERIC/1000)),3) mtid,*/
         CASE WHEN h.km = -1 THEN 0
              WHEN m.km = -1 THEN 1
              WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) <= ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 1
              WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) > ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 0
              ELSE 1 END AS fim   -- 1 hvis begge kommer i mål likt
              --WHEN ((h.km + 60) * (h.hd/1000)::NUMERIC) > ((m.km + 60) * (m.hd/1000)::NUMERIC) THEN 0 END
  FROM r3lmdnf h
  INNER JOIN r3lmdnf m ON
    h.dato = m.dato AND
    h.travbane = m.travbane AND
    h.lopnr = m.lopnr AND
    h.hest <> m.hest
  WHERE h.snr < m.snr AND h.rase = 'Kaldblods' AND m.rase = 'Kaldblods'
  ORDER BY h.dato ASC, h.travbane DESC, h.lopnr DESC, h.snr DESC
    )
    TO '/var/lib/pgsql/midl/r3lk.csv' DELIMITER ';';
