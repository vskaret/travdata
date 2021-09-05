SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse,
       i.km, i.snr, a.anthester, i.g, (i.f-2) AS f--,
      -- g.g365, g.gx365, g.brg365, g.dgp365, g.p365, g.dp365, g.brp365
FROM finished i
INNER JOIN Lop l ON
  i.dato = l.dato AND
  --i.tidspunkt = l.tidspunkt AND
  i.travbane = l.travbane AND
  i.lopnr = l.lopnr AND
  i.rase = l.lop_rase
INNER JOIN anthestertilstart a ON
  i.dato = a.dato AND
  --i.tidspunkt = a.tidspunkt AND
  i.travbane = a.travbane AND
  i.lopnr = a.lopnr
/*INNER JOIN g365 g ON
  i.dato = g.dato AND
  --i.tidspunkt = g.tidspunkt AND
  i.travbane = g.travbane AND
  i.lopnr = g.lopnr AND
  i.hest = g.hest*/
WHERE f <> 1
ORDER BY i.dato DESC
LIMIT 20;

-- trenger ikke l1g osv.. skal bare ha galopp oversikt for tidligere 365 dager som input (IKKE tidligere 365 i laggen)
SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, r.startmetode sm,
  g.g, g.gx, g.dg, g.dp, g.dgp, g.brg, g.brp,
  (f.dato - l1.dato) l1d, l1.km l1km, l1.distanse, l1.hdist, l1.snr, l1.antstarter ants,
  (f.dato - l2.dato) l2d, l2.km l2km, l2.distanse, l2.hdist, l2.snr, l2.antstarter ants,
  (f.dato - l3.dato) l3d, l3.km l3km, l3.distanse, l3.hdist, l3.snr, l3.antstarter ants
FROM finished f
INNER JOIN l1 ON f.hest = l1.hest AND f.f = l1.f
INNER JOIN l2 ON f.hest = l2.hest AND f.f = l2.f
INNER JOIN l3 ON f.hest = l3.hest AND f.f = l3.f
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
  f.lopnr = g.lopnr
ORDER BY f.dato DESC;
--LIMIT 50;

SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, g.antstarter ants, r.startmetode sm,
  g.g, g.gx, g.brg, g.dgp, g.p, g.dp, g.brp,
  (f.dato - l1.dato) l1d, l1.km l1km, l1.distanse, l1.hdist, l1.snr, l1.anthester l1anth, l1.startmetode l1sm,
  (f.dato - l2.dato) l2d, l2.km l2km, l2.distanse, l2.hdist, l2.snr, l2.anthester l2anth, l2.startmetode l2sm,
  (f.dato - l3.dato) l3d, l3.km l3km, l3.distanse, l3.hdist, l3.snr, l3.anthester l3anth, l3.startmetode l3sm
FROM finished f
INNER JOIN l1 ON f.hest = l1.hest AND f.f = l1.f
INNER JOIN l2 ON f.hest = l2.hest AND f.f = l2.f
INNER JOIN l3 ON f.hest = l3.hest AND f.f = l3.f
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
ORDER BY f.dato DESC
LIMIT 20;


SELECT
  f.dato, f.travbane, f.lopnr, f.hest, f.km, r.distanse, f.hdist, f.snr, a.anthester anth, g.antstarter ants, r.startmetode sm,
  g.g, g.gx, g.dg, g.brg, g.dgp, g.p, g.dp, g.brp,
  (f.dato - l1.dato) l1d, l1.km l1km, l1.distanse, l1.hdist, l1.snr, l1.anthester l1anth, l1.startmetode l1sm,
  (f.dato - l2.dato) l2d, l2.km l2km, l2.distanse, l2.hdist, l2.snr, l2.anthester l2anth, l2.startmetode l2sm,
  (f.dato - l3.dato) l3d, l3.km l3km, l3.distanse, l3.hdist, l3.snr, l3.anthester l3anth, l3.startmetode l3sm
FROM finished f
INNER JOIN l1 ON f.hest = l1.hest AND f.f = l1.f
INNER JOIN l2 ON f.hest = l2.hest AND f.f = l2.f
INNER JOIN l3 ON f.hest = l3.hest AND f.f = l3.f
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
ORDER BY f.dato DESC;

-- KMtid med lag - må finne galoppinput
CREATE MATERIALIZED VIEW l2km AS
SELECT
  f.dato                                                            dato,
  f.tidspunkt                                                       tidspunkt,
  f.travbane                                                        travbane,
  f.lopnr                                                           lopnr,
  f.hest                                                            hest,
  f.km                                                              km,
  l.startmetode                                                     startm,
  l.distanse                                                        ldist,
  ROUND((f.hdist::NUMERIC / l.distanse) - 1, 4)                     hdist,
  f.snr                                                             snr,
  a.anthester                                                       ant,
  l2.km                                                             l2,
  (f.dato - l2.dato)                                                l2d,
  l2.startmetode                                                    l2s,
  l2.distanse                                                       l2ldist,
  ROUND((l2.hdist::NUMERIC / l2.distanse) - 1, 4)                   l2hdist,
  l2.snr                                                            l2snr,
  l2.anthester                                                      l2ant,
  l2.g365                                                           l2g,
  l2.gx365                                                          l2gx,
  l2.brg365                                                         l2brg,
  l2.dgp365                                                         l2dgp,
  l2.p365                                                           l2p,
  l2.dp365                                                          l2dp,
  l2.brp365                                                         l2brp
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, il.startmetode, i.hdist, il.distanse,
         i.km, i.snr, ia.anthester, i.g, (i.f-2) AS f,
         ig.g365, ig.gx365, ig.brg365, ig.dgp365, ig.p365, ig.dp365, ig.brp365
  FROM finished i
  INNER JOIN Lop il ON
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
  INNER JOIN g365 ig ON
    i.dato = ig.dato AND
    i.tidspunkt = ig.tidspunkt AND
    i.travbane = ig.travbane AND
    i.lopnr = ig.lopnr AND
    i.hest = ig.hest
  WHERE f <> 1
) AS l2 ON l2.hest = f.hest AND l2.f = f.f AND l2.hest = f.hest
INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr AND
  f.rase = l.lop_rase
INNER JOIN anthestertilstart a ON
  f.dato = a.dato AND
  f.tidspunkt = a.tidspunkt AND
  f.travbane = a.travbane AND
  f.lopnr = a.lopnr
/*INNER JOIN g365 g ON
  f.dato = g.dato AND
  f.travbane = g.travbane AND
  f.lopnr = g.lopnr AND
  f.hest = g.hest*/
WHERE l.lop_rase = 'Varmblods'
ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC
LIMIT 50
;


SELECT
  f.dato                                                            dato,
  f.tidspunkt                                                       tidspunkt,
  f.travbane                                                        travbane,
  f.lopnr                                                           lopnr,
  f.hest                                                            hest,
  f.km                                                              km,
  l.startmetode                                                     startm,
  l.distanse                                                        ldist,
  ROUND((f.hdist::NUMERIC / l.distanse) - 1, 4)                     hdist,
  f.snr                                                             snr,
  a.anthester                                                       ant,
  l2.km                                                             l2,
  (f.dato - l2.dato)                                                l2d,
  l2.startmetode                                                    l2s,
  l2.distanse                                                       l2ldist,
  ROUND((l2.hdist::NUMERIC / l2.distanse) - 1, 4)                   l2hdist,
  l2.snr                                                            l2snr,
  l2.anthester                                                      l2ant,
  l2.g365                                                           l2g,
  l2.gx365                                                          l2gx,
  l2.brg365                                                         l2brg,
  l2.dgp365                                                         l2dgp,
  l2.p365                                                           l2p,
  l2.dp365                                                          l2dp,
  l2.brp365                                                         l2brp
FROM finished f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hest, l.startmetode, i.hdist, l.distanse,
         i.km, i.snr, a.anthester, i.g, (i.f-1) AS f,
         g.g365, g.gx365, g.brg365, g.dgp365, g.p365, g.dp365, g.brp365
  FROM finished i
  INNER JOIN Lop l ON
    i.dato = l.dato AND
    i.tidspunkt = l.tidspunkt AND
    i.travbane = l.travbane AND
    i.lopnr = l.lopnr AND
    i.rase = l.lop_rase
  INNER JOIN anthestertilstart a ON
    i.dato = a.dato AND
    i.tidspunkt = a.tidspunkt AND
    i.travbane = a.travbane AND
    i.lopnr = a.lopnr
  INNER JOIN g365 g ON
    i.dato = g.dato AND
    i.tidspunkt = g.tidspunkt AND
    i.travbane = g.travbane AND
    i.lopnr = g.lopnr AND
    i.hest = g.hest
  ORDER BY i.dato DESC;
  WHERE f <> 1 AND l.lop_rase = 'Varmblods'
) AS l2 ON l2.hest = f.hest AND l2.f = f.f
INNER JOIN lop l ON
  f.dato = l.dato AND
  f.tidspunkt = l.tidspunkt AND
  f.travbane = l.travbane AND
  f.lopnr = l.lopnr AND
  f.rase = l.lop_rase
INNER JOIN anthestertilstart a ON
  f.dato = a.dato AND
  f.tidspunkt = a.tidspunkt AND
  f.travbane = a.travbane AND
  f.lopnr = a.lopnr
  ORDER BY f.dato DESC, f.travbane DESC, f.lopnr ASC
  LIMIT 50


SELECT s1.dato, s1.tidspunkt, s1.travbane, s1.l, s1.hestenavn, s1.KM, s2.dato, s2.KM, s3.dato, s3.KM, s4.dato, s4.KM
FROM start s1
INNER JOIN start s2 ON s2.hestenavn = s1.hestenavn AND s2.dato < s1.dato
INNER JOIN start s3 ON s3.hestenavn = s2.hestenavn AND s3.dato < s2.dato
INNER JOIN start s4 ON s4.hestenavn = s3.hestenavn AND s4.dato < s3.dato
WHERE s1.hestenavn = 'Sveapjokken'
AND s2.dato = ( SELECT MAX(dato)
                FROM start
                WHERE dato < s1.dato)
GROUP BY s1.dato, s1.tidspunkt, s1.travbane, s1.l, s1.hestenavn, s1.KM, s2.dato, s2.KM, s3.dato, s3.KM, s4.dato, s4.KM
ORDER BY s1.dato DESC;


SELECT now.dato, now.tidspunkt, now.travbane, now.l, now.hestenavn, now.KM, last.dato, last.KM
FROM start AS now
INNER JOIN
(
  SELECT s.hestenavn, s.dato, s.KM
  FROM start AS s
  ORDER BY s.dato DESC
) AS last ON last.hestenavn = now.hestenavn
WHERE now.hestenavn = 'Sveapjokken' AND last.dato < now.dato
ORDER BY now.dato DESC
LIMIT 5;


CREATE VIEW prevrunresult AS
SELECT s.dato, s.hestenavn, prev.KM, prev.dato
FROM start s
INNER JOIN
(
  SELECT dato, tidspunkt, travbane, l, hestenavn, KM
  FROM start
) AS prev ON prev.hestenavn = s.hestenavn
WHERE prev.dato  = ( SELECT MAX(dato)
                    FROM start
                    WHERE dato < s.dato
                  ) AND
                  s.hestenavn = 'Mylady'
LIMIT 100;


SELECT s.dato, s.travbane, s.hestenavn, s.KM, prev.dato AS pdato, prev.KM, prev2.dato, prev2.KM
FROM start s
INNER JOIN
(
  SELECT dato, KM, hestenavn, travbane
  FROM start
  ORDER BY dato DESC
) AS prev ON prev.hestenavn = s.hestenavn
INNER JOIN
(
  SELECT dato, KM, hestenavn, travbane
  FROM start
  ORDER BY dato DESC
) AS prev2 ON prev2.hestenavn = prev.hestenavn
WHERE prev.dato =  (SELECT dato
                    FROM start
                    WHERE dato < s.dato
                    ORDER BY dato DESC
                    LIMIT 1) AND
      prev2.dato = (SELECT dato
                    FROM prev
                    WHERE dato < pdato
                    ORDER BY dato DESC
                    LIMIT 1)
ORDER BY s.dato DESC
LIMIT 10;






SELECT s1.dato, s1.tidspunkt, s1.travbane, s1.l, s1.hestenavn, s1.KM, s2.dato, s2.KM
FROM start s1
INNER JOIN start s2 ON s2.hestenavn = s1.hestenavn AND s2.dato < s1.dato
WHERE s1.hestenavn = 'Lannem Frøyd'
AND s2.KM = ( SELECT KM
            FROM start
            ORDER BY dato DESC
            LIMIT 1)
ORDER BY s1.dato DESC
LIMIT 200;






SELECT dato, tidspunkt, travbane, l, hestenavn, km
FROM start
WHERE dato IN
(
  SELECT dato
  FROM start as s2
  WHERE s2.hestenavn = start.hestenavn
  ORDER BY dato DESC
  LIMIT 3
)
ORDER BY hestenavn DESC
LIMIT 50;







SELECT s.dato, s.hestenavn, s.KM,
  (SELECT MAX(dato)
   FROM start AS prev
   WHERE prev.dato < s.dato AND prev.hestenavn = s.hestenavn) AS prevdate,
   (
     SELECT KM
     FROM start as s1
     WHERE s1.hestenavn = s.hestenavn AND s1.dato < s.dato
     GROUP BY s1.dato, s1.hestenavn, s1.KM
     HAVING s1.dato = MAX(DATO)
     ORDER BY s1.dato DESC
     LIMIT 1
   ) AS prevkm
FROM start s
ORDER BY s.dato DESC
LIMIT 100;







SELECT s.hestenavn, s.dato, s.KM,
(
  SELECT dato
  FROM startf d
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > d.dato
    AND hestenavn = d.hestenavn
  ) AND d.hestenavn = s.hestenavn
) AS prev1date,
(
  SELECT km
  FROM startf k
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > k.dato
    AND hestenavn = k.hestenavn
  ) AND k.hestenavn = s.hestenavn
) AS prev1km,
(
  SELECT dato
  FROM startf d
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > d.dato
    AND hestenavn = d.hestenavn
  ) AND d.hestenavn = s.hestenavn
) AS prev2date,
(
  SELECT km
  FROM startf k
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > k.dato
    AND hestenavn = k.hestenavn
  ) AND k.hestenavn = s.hestenavn
) AS prev2km,
(
  SELECT dato
  FROM startf d
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > d.dato
    AND hestenavn = d.hestenavn
  ) AND d.hestenavn = s.hestenavn
) AS prev3date,
(
  SELECT km
  FROM startf k
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > k.dato
    AND hestenavn = k.hestenavn
  ) AND k.hestenavn = s.hestenavn
) AS prev3km,
(
  SELECT dato
  FROM startf d
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > d.dato
    AND hestenavn = d.hestenavn
  ) AND d.hestenavn = s.hestenavn
) AS prev4date,
(
  SELECT km
  FROM startf k
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > k.dato
    AND hestenavn = k.hestenavn
  ) AND k.hestenavn = s.hestenavn
) AS prev4km,
(
  SELECT dato
  FROM startf d
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > d.dato
    AND hestenavn = d.hestenavn
  ) AND d.hestenavn = s.hestenavn
) AS prev5date,
(
  SELECT km
  FROM startf k
  WHERE (f - 1) =
  (
    SELECT COUNT(DISTINCT(dato))
    FROM startf
    WHERE dato > k.dato
    AND hestenavn = k.hestenavn
  ) AND k.hestenavn = s.hestenavn
) AS prev5km
FROM startf s
WHERE s.hestenavn = 'Sun Beauty'
ORDER BY s.dato DESC
LIMIT 5;


SELECT s.hestenavn, s.dato, s.KM
FROM start s
WHERE 2 =
(
  SELECT COUNT(DISTINCT(dato))
  FROM start
  WHERE dato > s.dato
  AND hestenavn = s.hestenavn
) AND s.hestenavn = 'Il Tempo Tibur'
LIMIT 50;

SELECT k.dato, k.travbane, k.hestenavn, k.km, (f-1) AS f
FROM startf k
WHERE f <> 1
AND k.hestenavn = 'Il Tempo Tibur'
ORDER BY k.dato DESC;


-- f gir mulighet for lag
SELECT
  s.dato,
  s.travbane,
  s.hestenavn,
  COALESCE(s.km, -1) km,
  COALESCE(l1.km, l2.km, l3.km, l4.km, l5.km, l6.km, l7.km, l8.km, l9.km, l10.km) l1,
  COALESCE(l2.km, l3.km, l4.km, l5.km, l6.km, l7.km, l8.km, l9.km, l10.km) l2,
  COALESCE(l3.km, l4.km, l5.km, l6.km, l7.km, l8.km, l9.km, l10.km) l3,
  COALESCE(l4.km, l5.km, l6.km, l7.km, l8.km, l9.km, l10.km) l4,
  COALESCE(l5.km, l6.km, l7.km, l8.km, l9.km, l10.km) l5
FROM startfn s
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-1) AS f
  FROM startfn i
  WHERE f <> 1

  ORDER BY i.dato DESC
) AS l1 ON l1.hestenavn = s.hestenavn AND l1.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-2) AS f
  FROM startfn i
  WHERE f <> 1

  ORDER BY i.dato DESC
) AS l2 ON l2.hestenavn = s.hestenavn AND l2.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-3) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l3 ON l3.hestenavn = s.hestenavn AND l3.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-4) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l4 ON l4.hestenavn = s.hestenavn AND l4.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-5) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l5 ON l5.hestenavn = s.hestenavn AND l5.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-6) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l6 ON l6.hestenavn = s.hestenavn AND l6.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-7) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l7 ON l7.hestenavn = s.hestenavn AND l7.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-8) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l8 ON l8.hestenavn = s.hestenavn AND l8.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-9) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l9 ON l5.hestenavn = s.hestenavn AND l9.f = s.f
INNER JOIN
(
  SELECT i.dato, i.travbane, i.hestenavn, i.km, (i.f-10) AS f
  FROM startfn i
  WHERE f <> 1
  ORDER BY i.dato DESC
) AS l10 ON l10.hestenavn = s.hestenavn AND l10.f = s.f
INNER JOIN
(
  SELECT f, hestenavn, g, p, gX, dg, dp, dgp, br, dv, d
  FROM startfn
  ORDER BY dato DESC
) AS g ON g.hestenavn = s.hestenavn AND g.f = s.f
ORDER BY s.dato DESC
LIMIT 10;
