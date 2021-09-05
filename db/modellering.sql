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

CREATE MATERIALIZED VIEW starterny AS
-- starter fra finished
SELECT
  f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.snr, f.hdist, f.km,
  f.g, f.p, f.gx, f.dg, f.dp, f.dgp, f.brg, f.brp, f.rase, f.odds
FROM
  finished f
-- Starter fra dnf
UNION
SELECT
  d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.snr, d.hdist, d.km,
  d.g, d.p, d.gx, d.dg, d.dp, d.dgp, d.brg, d.brp, d.rase, d.odds
FROM dnf d
WHERE d.pl <> 'Strøket'
;



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
-- brukes ikke, mangler dnf
/*
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
*/

-- tar også med dnf starter (fortsatt 0.8 som vekt)
CREATE MATERIALIZED VIEW kmwtimeweight AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.snr, f.rase, f.hdist, f.km okm,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((f.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((f.dato - l.dato)::NUMERIC / 365), 3) END tweight,
       l.km
FROM finished f
INNER JOIN finished l ON f.hest = l.hest
WHERE f.dato <> l.dato AND (f.dato - l.dato) > 0
--ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest ASC, l.dato DESC
UNION
SELECT d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.snr, d.rase, d.hdist, d.km okm,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((d.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((d.dato - l.dato)::NUMERIC / 365), 3) END tweight,
       l.km
FROM dnf d
INNER JOIN finished l ON d.hest = l.hest
WHERE d.dato <> l.dato AND (d.dato - l.dato) > 0 AND d.pl <> 'Strøket'
--ORDER BY d.dato DESC, d.travbane DESC, d.lopnr ASC, d.hest ASC, l.dato DESC
;


CREATE MATERIALIZED VIEW weightedkm AS
SELECT dato, tidspunkt, travbane, lopnr, hest, snr, rase, hdist, okm,
       SUM(tweight) sweight,
       ROUND(SUM(tweight*km) / COUNT(*), 4) wkm
FROM kmwtimeweight
GROUP BY dato, tidspunkt, travbane, lopnr, hest, snr, rase, hdist, okm
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;


CREATE MATERIALIZED VIEW wkmpluswg AS
SELECT k.dato, k.tidspunkt, k.travbane, k.lopnr, k.hest, k.snr, k.rase, k.hdist, k.okm,
       k.sweight ksweight, g.sweight gsweight, k.wkm,
       g.wg, g.wgx, g.wdg, g.wbrg, g.wdgp, g.wp, g.wdp, g.wbrp
FROM weightedkm k
INNER JOIN weightedg g ON
  k.dato = g.dato AND k.tidspunkt = g.tidspunkt AND k.travbane = g.travbane AND
  k.lopnr = g.lopnr AND k.hest = g.hest
ORDER BY k.dato DESC, k.travbane DESC, k.lopnr ASC, k.hest ASC;

-- for csv
CREATE MATERIALIZED VIEW h2hv AS
SELECT h.dato, h.travbane, h.lopnr, h.hest h1, m.hest h2, ROUND((1 / (h.ksweight + m.ksweight)),4) uncertainty,
       (h.wkm-m.wkm) wkm, (h.hdist-m.hdist) dist, (h.wg-m.wg) g, (h.wgx-m.wgx) gx, (h.wdg-m.wdg) dg,
       (h.wbrg-m.wbrg) brg, (h.wdgp-m.wdgp) dgp, (h.wp-m.wp) p, (h.wdp-m.wdp) dp, (h.wbrp-m.wbrp) brp,
       CASE WHEN lop.startmetode = 'Auto' THEN 0 WHEN lop.startmetode ='Volte' THEN 1 WHEN lop.startmetode = 'Linje' Then 2 END sm,
       CASE WHEN h.okm = -1 AND m.okm = -1 THEN 0 ---1    -- hvis begge feiler
            WHEN h.okm = -1 THEN 0
            WHEN m.okm = -1 THEN 1
            WHEN ((h.okm+60) * (h.hdist/1000)::NUMERIC) <= ((m.okm+60)*(m.hdist/1000)::NUMERIC) THEN 1
            WHEN ((h.okm+60) * (h.hdist/1000)::NUMERIC) > ((m.okm+60)*(m.hdist/1000)::NUMERIC) THEN 0
            ELSE 1 END fim  -- 0 hvis begge kommer i mål likt
FROM wkmpluswg h
INNER JOIN wkmpluswg m ON
  h.dato = m.dato AND h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND h.hest <> m.hest
INNER JOIN lop ON
  h.dato = lop.dato AND h.travbane = lop.travbane AND h.lopnr = lop.lopnr AND h.tidspunkt = lop.tidspunkt
WHERE h.snr < m.snr AND h.rase = 'Varmblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.snr ASC
;

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, sm, fim
  FROM h2hv
  WHERE uncertainty < 0.01
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/h2hv.csv' DELIMITER ';';


CREATE MATERIALIZED VIEW h2hk AS
SELECT h.dato, h.travbane, h.lopnr, h.hest h1, m.hest h2, ROUND((1 / (h.ksweight + m.ksweight)),4) uncertainty,
       (h.wkm-m.wkm) km, (h.hdist-m.hdist) dist, (h.wg-m.wg) g, (h.wgx-m.wgx) gx, (h.wdg-m.wdg) dg,
       (h.wbrg-m.wbrg) brg, (h.wdgp-m.wdgp) dgp, (h.wp-m.wp) p, (h.wdp-m.wdp) dp, (h.wbrp-m.wbrp) brp
FROM wkmpluswg h
INNER JOIN wkmpluswg m ON
  h.dato = m.dato AND h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND h.hest <> m.hest
WHERE h.snr < m.snr AND h.rase = 'Kaldblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.snr ASC
;

/*
CREATE MATERIALIZED VIEW h2hv AS
SELECT h.dato, h.travbane, h.lopnr, h.h1, h.h2, h.uncertainty,
       h.km, h.g, h.gx, h.dg, h.brg, h.dgp, h.p, h.dp, h.brp
FROM h2h h
INNER JOIN starterny s ON h.dato = s.dato AND h.travbane = s.travbane AND h.lopnr = s.lopnr AND h.h1 = s.hest
WHERE s.rase = 'Varmblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.h1 ASC;

CREATE MATERIALIZED VIEW h2hk AS
SELECT h.dato, h.travbane, h.lopnr, h.h1, h.h2, h.uncertainty,
       h.km, h.g, h.gx, h.dg, h.brg, h.dgp, h.p, h.dp, h.brp
FROM h2h h
INNER JOIN starterny s ON h.dato = s.dato AND h.travbane = s.travbane AND h.lopnr = s.lopnr AND h.h1 = s.hest
WHERE s.rase = 'Kaldblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.h1 ASC;
*/

/*
CREATE MATERIALIZED VIEW fnd AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, k.sweight ksweight, g.sweight gsweight,
       g.wg, g.wgx, g.wdg, g.wbrg, g.wdgp, g.wp, g.wdp, g.wbrp, k.wkm,
       f.hdist, f.km,
FROM starter f
INNER JOIN weightedg g ON
  f.dato = g.dato AND f.travbane = g.travbane AND
  f.lopnr = g.lopnr AND f.hest = g.hest
INNER JOIN weightedkm k ON
  f.dato = k.dato AND f.travbane = k.travbane AND
  f.lopnr = k.lopnr AND f.hest = k.hest
;
*/


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
