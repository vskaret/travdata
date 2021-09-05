-- bruker 0.8 som vekt
CREATE MATERIALIZED VIEW gwtimeweight80 AS
SELECT
  s.dato, s.tidspunkt, s.travbane, s.lopnr, s.hest,
  g.dato ldato, g.travbane lbane, g.lopnr lnr,
  CASE WHEN ((s.dato - g.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((s.dato - g.dato)::NUMERIC / 365), 6) END tweight,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp
FROM starter s
INNER JOIN starter g ON s.hest = g.hest
WHERE
  (s.dato <> g.dato) AND
  (s.dato - g.dato) > 0
--GROUP BY  s.dato, s.tidspunkt, s.travbane, s.lopnr, s.hest
ORDER BY  s.dato DESC, s.travbane DESC, s.lopnr ASC, s.hest ASC, g.dato DESC
;

CREATE MATERIALIZED VIEW weightedg80 AS
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
FROM gwtimeweight80
GROUP BY dato, tidspunkt, travbane, lopnr, hest
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;


CREATE MATERIALIZED VIEW antstarterwtimeweight80 AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((f.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((f.dato - l.dato)::NUMERIC / 365), 6) END tweight,
       1 AS start
FROM starter f
INNER JOIN starter l ON f.hest = l.hest
WHERE f.dato <> l.dato AND (f.dato - l.dato) > 0
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest ASC;

CREATE MATERIALIZED VIEW weightedstarter80 AS
SELECT dato, tidspunkt, travbane, lopnr, hest,
       SUM(tweight) wstarter
       --ROUND(SUM(tweight*start), 4) wstarter
FROM antstarterwtimeweight80
GROUP BY dato, tidspunkt, travbane, lopnr, hest
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;


-- maa deles opp i forskjellige distanser >> prøver heller med avg hdist
CREATE MATERIALIZED VIEW kmwtimeweight80 AS
SELECT f.dato, f.tidspunkt, f.travbane, f.lopnr, f.hest, f.snr, f.rase, f.hdist, f.km okm,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((f.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((f.dato - l.dato)::NUMERIC / 365), 6) END tweight,
       l.km, l.premie
FROM finished f
INNER JOIN finished l ON f.hest = l.hest
WHERE f.dato <> l.dato AND (f.dato - l.dato) > 0
--ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC, f.hest ASC, l.dato DESC
UNION
SELECT d.dato, d.tidspunkt, d.travbane, d.lopnr, d.hest, d.snr, d.rase, d.hdist, d.km okm,
       l.dato ldato, l.travbane lbane, l.lopnr lnr,
       CASE WHEN ((d.dato - l.dato)::NUMERIC / 365) <= 1 THEN 0.8 ELSE ROUND(0.8^((d.dato - l.dato)::NUMERIC / 365), 6) END tweight,
       l.km, l.premie
FROM dnf d
INNER JOIN finished l ON d.hest = l.hest
WHERE d.dato <> l.dato AND (d.dato - l.dato) > 0 AND d.pl <> 'Strøket'
--ORDER BY d.dato DESC, d.travbane DESC, d.lopnr ASC, d.hest ASC, l.dato DESC
;



CREATE MATERIALIZED VIEW weightedkm80 AS
SELECT dato, tidspunkt, travbane, lopnr, hest, snr, rase, okm, hdist,
       SUM(tweight) sweight,
       ROUND(SUM(tweight*km) / COUNT(*), 4) wkm,
       ROUND(SUM(tweight*hdist) / COUNT(*), 4) whdist,
       ROUND(SUM(tweight*premie) / COUNT(*), 4) wpremie
FROM kmwtimeweight80
GROUP BY dato, tidspunkt, travbane, lopnr, hest, snr, rase, okm, hdist
ORDER BY dato DESC, travbane DESC, lopnr ASC, hest ASC;


CREATE MATERIALIZED VIEW wkmpluswg80 AS
SELECT DISTINCT
       k.dato, k.tidspunkt, k.travbane, k.lopnr, k.hest, k.snr, k.rase, k.hdist, k.okm,
       k.sweight ksweight, g.sweight gsweight, k.wkm, k.wpremie, k.whdist, s.wstarter,
       g.wg, g.wgx, g.wdg, g.wbrg, g.wdgp, g.wp, g.wdp, g.wbrp
FROM weightedkm80 k
INNER JOIN weightedg80 g ON
  k.dato = g.dato AND k.tidspunkt = g.tidspunkt AND k.travbane = g.travbane AND
  k.lopnr = g.lopnr AND k.hest = g.hest
INNER JOIN weightedstarter80 s ON
  k.dato = s.dato AND k.tidspunkt = s.tidspunkt AND k.travbane = s.travbane AND
  k.lopnr = s.lopnr AND k.hest = s.hest
ORDER BY k.dato DESC, k.travbane DESC, k.lopnr ASC, k.hest ASC;

-- for csv
CREATE MATERIALIZED VIEW h2hv80 AS
SELECT h.dato, h.travbane, h.lopnr, h.hest h1, m.hest h2, ROUND((1 / (h.ksweight + m.ksweight)),4) uncertainty,
       (h.wkm-m.wkm) wkm, (h.hdist-m.hdist) dist, (h.wg-m.wg) g, (h.wgx-m.wgx) gx, (h.wdg-m.wdg) dg,
       (h.wbrg-m.wbrg) brg, (h.wdgp-m.wdgp) dgp, (h.wp-m.wp) p, (h.wdp-m.wdp) dp, (h.wbrp-m.wbrp) brp,
       (h.wpremie-m.wpremie) premie, (h.whdist-m.whdist) whdist,
       CASE WHEN lop.startmetode = 'Auto' THEN 0 WHEN lop.startmetode ='Volte' THEN 1 WHEN lop.startmetode = 'Linje' Then 2 END sm,
       CASE WHEN h.okm = -1 AND m.okm = -1 THEN 0 ---1    -- hvis begge feiler
            WHEN h.okm = -1 THEN 0
            WHEN m.okm = -1 THEN 1
            WHEN ((h.okm+60) * (h.hdist/1000)::NUMERIC) <= ((m.okm+60)*(m.hdist/1000)::NUMERIC) THEN 1
            WHEN ((h.okm+60) * (h.hdist/1000)::NUMERIC) > ((m.okm+60)*(m.hdist/1000)::NUMERIC) THEN 0
            ELSE 1 END fim  -- 0 hvis begge kommer i mål likt
FROM wkmpluswg80 h
INNER JOIN wkmpluswg80 m ON
  h.dato = m.dato AND h.travbane = m.travbane AND
  h.lopnr = m.lopnr AND h.hest <> m.hest
INNER JOIN lop ON
  h.dato = lop.dato AND h.travbane = lop.travbane AND h.lopnr = lop.lopnr AND h.tidspunkt = lop.tidspunkt
WHERE h.snr < m.snr AND h.rase = 'Varmblods'
ORDER BY h.dato DESC, h.travbane DESC, h.lopnr ASC, h.snr ASC
;

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.1
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/10.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.2
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/20.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.3
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/30.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.4
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/40.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.5
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/50.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.6
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/60.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.7
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/70.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.8
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/80.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  WHERE uncertainty <= 0.9
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/90.csv' DELIMITER ';';

COPY
(
  SELECT wkm, dist, g, gx, dg, brg, dgp, p, dp, brp, premie, whdist, sm, fim
  FROM h2hv80
  --WHERE uncertainty <= 0.9
  ORDER BY dato ASC, travbane DESC, lopnr DESC
)
TO '/var/lib/pgsql/midl/100.csv' DELIMITER ';';

drop materialized view h2hv80, wkmpluswg80, weightedkm80, kmtimeweight80, weightedstarter80, antstarterwtimeweight80, weightedg80, gwtimeweight80;
