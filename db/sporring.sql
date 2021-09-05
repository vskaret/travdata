-- siste 5 avsluttede løp med hastighet (dagens løp er også avsluttet)
-- bugga fordi finished må ha egne forekomstnumre (er nå blandet med DNF)
-- når dette er fikset bruk inner join
SELECT
  f.dato dato,
  f.travbane travbane,
  f.hestenavn hest,
  f.l lopnr,
  f.km km,
  (f.dato - l1.dato) l1d,
  l1.startmetode l1s,
  l1.hdist l1dist,
  l1.km l1,
  (f.dato - l2.dato) l2d,
  l2.startmetode l2s,
  l2.hdist l2dist,
  l2.km l2,
  (f.dato - l3.dato) l3d,
  l3.startmetode l3s,
  l3.hdist l3dist,
  l3.km l3,
  (f.dato - l4.dato) l4d,
  l4.startmetode l4s,
  l4.hdist l4dist,
  l4.km l4,
  (f.dato - l5.dato) l5d,
  l5.startmetode l5s,
  l5.hdist l5dist,
  l5.km l5
FROM finished f
--INNER JOIN
LEFT JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, l.startmetode, i.hdist, i.km, (i.f-1) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.l = l.lopnr
  WHERE f <> 1
) AS l1 ON l1.hestenavn = f.hestenavn AND l1.f = f.f
--INNER JOIN
LEFT JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, l.startmetode, i.hdist, i.km, (i.f-2) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.l = l.lopnr
  WHERE f <> 1
) AS l2 ON l2.hestenavn = f.hestenavn AND l2.f = f.f
--INNER JOIN
LEFT JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, l.startmetode, i.hdist, i.km, (i.f-3) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.l = l.lopnr
  WHERE f <> 1
) AS l3 ON l3.hestenavn = f.hestenavn AND l3.f = f.f
--INNER JOIN
LEFT JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, l.startmetode, i.hdist, i.km, (i.f-4) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.l = l.lopnr
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l4 ON l4.hestenavn = f.hestenavn AND l4.f = f.f
--INNER JOIN
LEFT JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, l.startmetode, i.hdist, i.km, (i.f-5) AS f
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.l = l.lopnr
  WHERE f <> 1
) AS l5 ON l5.hestenavn = f.hestenavn AND l5.f = f.f
ORDER BY f.dato DESC, f.travbane DESC, f.l ASC
;


-- finner starter og antall brutte løp (innenfor hver kategori) hesten har hatt
-- de hestene i løpet som ikke har noen brutte løp de siste 365 dager vil ikke vises i spørringen
SELECT DISTINCT
  s.dato start_dato,
  s.travbane start_travbane,
  s.l start_lopnr,
  s.hestenavn start_hest,
  SUM(dnf.gX) g_i_maal,
  SUM(dnf.dg) dg,
  SUM(dnf.dp) dp,
  SUM(dnf.dgp) dgp,
  SUM(dnf.br) br,
  SUM(dnf.dv) dv,
  SUM(dnf.d) dist
FROM
  start s
LEFT JOIN
  dnf
ON
  dnf.hestenavn = s.hestenavn
WHERE
  s.dato <> dnf.dato AND
  (s.dato - dnf.dato) < 366 AND
  (s.dato - dnf.dato) > 0 AND
  -- s.pl <> 'Strøket' AND????
  dnf.pl <> 'Strøket'
GROUP BY
  s.dato, s.travbane, s.l, s.hestenavn
ORDER BY
  s.dato DESC,
  s.travbane DESC,
  s.l DESC,
  s.hestenavn DESC;


-- antall løp hvor hesten har startet siste 365 og hvor mye den har vunnet
-- samt antall seire, andreplasser og tredjeplasser
-- CREATE VIEW startpremie AS
SELECT
  s.dato,
  s.travbane,
  s.l lopnr,
  s.hestenavn,
  COUNT(p.premie) antstarter365,
  COUNT(CASE WHEN p.pl = '1' THEN 1 END) ant_seire,
  ROUND((COUNT(CASE WHEN p.pl = '1' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS seier_prosent,
  COUNT(CASE WHEN p.pl = '2' THEN 1 END) ant_andre,
  ROUND((COUNT(CASE WHEN p.pl = '2' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS andre_prosent,
  COUNT(CASE WHEN p.pl = '3' THEN 1 END) ant_tredje,
  ROUND((COUNT(CASE WHEN p.pl = '3' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS tredje_prosent,
  SUM(p.premie) premie365,
  SUM(p.premie) / COUNT(p.premie) premie_per_start365
FROM
  start s
INNER JOIN
  start p
ON
  s.hestenavn = p.hestenavn
WHERE
  (s.dato <> p.dato) AND
  (s.dato - p.dato) < 366 AND
  (s.dato - p.dato) > 0 AND
  -- s.pl <> 'Strøket' AND???
  p.pl <> 'Strøket'
GROUP BY
  s.dato,
  s.travbane,
  s.l,
  s.hestenavn
--HAVING count(p.premie) > 5
ORDER BY
  s.dato DESC,
  s.travbane DESC,
  s.l DESC,
  s.hestenavn DESC;



-- finner starter og starter hvor hesten avsluttet,
-- men galopperte eller gikk passgang (litt bugga med oppsettet nå fordi
-- g har også med verdier fra dg og gX)
  SELECT
    s.dato,
    s.travbane,
    s.l lopnr,
    s.hestenavn,
    SUM(g.g) antgalopp365,
    SUM(g.p) antpassgang365
  FROM
    start s
  INNER JOIN
    start g
  ON
    s.hestenavn = g.hestenavn
  WHERE
    (s.dato <> g.dato) AND
    (s.dato - g.dato) < 366 AND
    (s.dato - g.dato) > 0 AND
    -- s.pl <> 'Strøket' AND???
    g.pl <> 'Strøket'
  GROUP BY
    s.dato,
    s.travbane,
    s.l,
    s.hestenavn
  ORDER BY
    s.dato DESC,
    s.travbane DESC,
    s.l DESC,
    s.hestenavn DESC;



-- trekker fra dg, gX og dp
-- funker ikke med databaseløsningen som er nå..
-- må skille mellom brg og brp, burde også i parsingen skille mellom g, dg, osv
SELECT
  s.dato,
  s.travbane,
  s.l lopnr,
  s.hestenavn,
  (SUM(g.g) - (SUM(g.dg) + SUM(g.gX) + SUM(g.brg))) antgalopp365,
  (SUM(g.p) - (SUM(g.p) + SUM(g.brp))) antpassgang365
FROM
  start s
  INNER JOIN start g ON s.hestenavn = g.hestenavn
  LEFT JOIN siste365dnf d ON
    s.hestenavn = d.start_hest AND
    s.dato = d.start_dato AND
    s.travbane = d.start_travbane AND
    s.l = d.start_lopnr
WHERE
  (s.dato <> g.dato) AND
  (s.dato - g.dato) < 366 AND
  (s.dato - g.dato) > 0 AND
  -- s.pl <> 'Strøket' AND???
  g.pl <> 'Strøket'
GROUP BY
  s.dato,
  s.travbane,
  s.l,
  s.hestenavn
ORDER BY
  s.dato DESC,
  s.travbane DESC,
  s.l DESC,
  s.hestenavn DESC;

-- travkusker
-- MÅ HA LØP FRA OG MED 01.01.2010 pga monteløp er dårlig merka før det!
-- får litt andre resultater enn travsport.no sin kusketabell, men der mangler det noen løp
-- eks: http://www.travsport.no/Sport/Resultater/Jarlsberg-Travbane/?date=20160101
-- her deltar øyvind ruttenborg i to løp uten at de er i tabellen hans
-- CREATE VIEW kusker AS
SELECT DISTINCT
  s.kusk,
  COUNT(*) antstarter,
  COUNT(CASE WHEN s.pl = '1' THEN 1 END) ant_seire,
  ROUND((COUNT(CASE WHEN s.pl = '1' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS seier_prosent,
  COUNT(CASE WHEN s.pl = '2' THEN 1 END) ant_andre,
  ROUND((COUNT(CASE WHEN s.pl = '2' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS andre_prosent,
  COUNT(CASE WHEN s.pl = '3' THEN 1 END) ant_tredje,
  ROUND((COUNT(CASE WHEN s.pl = '3' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS tredje_prosent
FROM start s
INNER JOIN Lop l ON
  s.dato = l.dato AND
  s.tidspunkt = l.tidspunkt AND
  s.travbane = l.travbane AND
  s.l = l.lopnr
WHERE
  s.dato >= '2010-01-01' AND
  s.kusk NOT IN (' Privat', ' Rasmussen') AND
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
  l.lopnavn NOT LIKE '%mõnte%'
GROUP BY s.kusk
HAVING COUNT(*) > 100
ORDER BY seier_prosent DESC, andre_prosent DESC, tredje_prosent DESC
;



-- montékusker
SELECT DISTINCT
  s.kusk,
  COUNT(*) antstarter,
  COUNT(CASE WHEN s.pl = '1' THEN 1 END) ant_seire,
  ROUND((COUNT(CASE WHEN s.pl = '1' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS seier_prosent,
  COUNT(CASE WHEN s.pl = '2' THEN 1 END) ant_andre,
  ROUND((COUNT(CASE WHEN s.pl = '2' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS andre_prosent,
  COUNT(CASE WHEN s.pl = '3' THEN 1 END) ant_tredje,
  ROUND((COUNT(CASE WHEN s.pl = '3' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS tredje_prosent
FROM start s
INNER JOIN Lop l ON
  s.dato = l.dato AND
  s.tidspunkt = l.tidspunkt AND
  s.travbane = l.travbane AND
  s.l = l.lopnr
WHERE
  s.kusk NOT IN (' Privat', ' Rasmussen') AND
  (l.lopnavn LIKE '%monte%' OR
  l.lopnavn LIKE '%montè%' OR
  l.lopnavn LIKE '%monté%' OR
  l.lopnavn LIKE '%Monte%' OR
  l.lopnavn LIKE '%Montè%' OR
  l.lopnavn LIKE '%Monté%' OR
  l.lopnavn LIKE '%MONTE%' OR
  l.lopnavn LIKE '%MONTÈ%' OR
  l.lopnavn LIKE '%MONTÉ%' OR
  l.lopnavn LIKE '%MÕNTE%' OR
  l.lopnavn LIKE '%Mõnte%' OR
  l.lopnavn LIKE '%mõnte%' OR
  l.lopnavn LIKE '%dame%' OR
  l.lopnavn LIKE '%Dame%' OR
  l.lopnavn LIKE '%DAME%' OR
  l.lopnavn LIKE '%Mónte%' OR
  l.lopnavn LIKE '%mónte%' OR
  l.lopnavn LIKE '%MÓNTE%')
GROUP BY s.kusk
HAVING COUNT(*) > 50
ORDER BY antstarter ASC --s.kusk ASC
;



-- travkusker sortert på seier_prosent osv (IKKE INKLUDERT DAMELØP)
-- CREATE VIEW travkusker AS
SELECT DISTINCT
  s.dato,
  s.tidspunkt,
  s.travbane,
  s.l,
  s.kusk,
  COUNT(*) antstarter,
  COUNT(CASE WHEN s.pl = '1' THEN 1 END) ant_seire,
  ROUND((COUNT(CASE WHEN s.pl = '1' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS seier_prosent,
  COUNT(CASE WHEN s.pl = '2' THEN 1 END) ant_andre,
  ROUND((COUNT(CASE WHEN s.pl = '2' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS andre_prosent,
  COUNT(CASE WHEN s.pl = '3' THEN 1 END) ant_tredje,
  ROUND((COUNT(CASE WHEN s.pl = '3' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) AS tredje_prosent,
  SUM(s.premie) premiesum--,
  --SUM(s.premie) / COUNT(*) premie_per_start,
  --ROUND(SUM(sp.seier_prosent) / COUNT(sp.seier_prosent), 2) hest_seier
FROM start s
INNER JOIN Lop l ON
  s.dato = l.dato AND
  s.tidspunkt = l.tidspunkt AND
  s.travbane = l.travbane AND
  s.l = l.lopnr
INNER JOIN siste365startpremie sp ON
  s.dato = sp.dato AND
  s.travbane = sp.travbane AND
  s.l = sp.lopnr AND
  s.hestenavn = sp.hestenavn
WHERE
  s.dato >= '2010-01-01' AND
  s.kusk NOT IN (' Privat', ' Rasmussen') AND NOT
  (l.lopnavn LIKE '%monte%' OR l.lopnavn LIKE '%montè%' OR
  l.lopnavn LIKE '%monté%' OR l.lopnavn LIKE '%Monte%' OR
  l.lopnavn LIKE '%Montè%' OR l.lopnavn LIKE '%Monté%' OR
  l.lopnavn LIKE '%MONTE%' OR l.lopnavn LIKE '%MONTÈ%' OR
  l.lopnavn LIKE '%MONTÉ%' OR l.lopnavn LIKE '%MÕNTE%' OR
  l.lopnavn LIKE '%Mõnte%' OR l.lopnavn LIKE '%mõnte%' OR
  l.lopnavn LIKE '%dame%' OR l.lopnavn LIKE '%Dame%' OR
  l.lopnavn LIKE '%DAME%' OR l.lopnavn LIKE '%Mónte%' OR
  l.lopnavn LIKE '%mónte%' OR l.lopnavn LIKE '%MÓNTE%')
GROUP BY s.kusk
HAVING COUNT(*) > 100
ORDER BY seier_prosent DESC, andre_prosent DESC, tredje_prosent DESC;



-- antall løp kusken har startet siste 365 og hvor mye han har kjørt inn
-- samt antall seire, andreplasser og tredjeplasser
SELECT
  s.dato,
  s.travbane,
  s.l lopnr,
  s.kusk,
  p.hestenavn,
  p.pl
  /*COUNT(p.premie) antstarter365,
  COUNT(CASE WHEN p.pl = '1' THEN 1 END) ant_seire,
  ROUND((COUNT(CASE WHEN p.pl = '1' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) seier_prosent,
  COUNT(CASE WHEN p.pl = '2' THEN 1 END) ant_andre,
  ROUND((COUNT(CASE WHEN p.pl = '2' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) andre_prosent,
  COUNT(CASE WHEN p.pl = '3' THEN 1 END) ant_tredje,
  ROUND((COUNT(CASE WHEN p.pl = '3' THEN 1 END) * 100)::NUMERIC / COUNT(*), 2) tredje_prosent,
  SUM(p.premie) premie365,
  SUM(p.premie) / COUNT(p.premie) premie_per_start365*/
FROM
  start s
INNER JOIN
  start p
ON
  --s.hestenavn = p.hestenavn AND
  s.kusk = p.kusk
WHERE
  (s.dato <> p.dato) AND
  (s.dato - p.dato) < 366 AND
  (s.dato - p.dato) > 0 AND
  -- s.pl <> 'Strøket' AND???
  p.pl <> 'Strøket'
/*GROUP BY
  s.dato,
  s.travbane,
  s.l,
  s.kusk*/
ORDER BY
  s.dato DESC,
  s.travbane DESC,
  s.l DESC,
  s.kusk DESC
  limit 1000;

  select count(*) from siste365startpremie;
  select count(*) from siste5km;
