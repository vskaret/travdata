/*
Hester som har vært registrert i utlandet, men er nå registrert i Norge.
De har altså hatt stjerne i navnet.
Vainqueur R.P.*
Alphatron*
Astoria Dotcom
Caprino B.R.
Cristal R.R.
Egregious
L''orage
Lovisa Mykla
Magnetic Fightline
Passphoto B.R.
Real Superb
Safe Bourbon
Scarlet Creation
S.J.''s Majesty
U.S. Marshal
*/

UPDATE finished SET hest = 'Vainqueur R.P.' WHERE hest = 'Vainqueur R.P.*';
UPDATE dnf SET hest = 'Vainqueur R.P.' WHERE hest = 'Vainqueur R.P.*';
UPDATE finished SET hest = 'Alphatron' WHERE hest = 'Alphatron*';
UPDATE dnf SET hest = 'Alphatron' WHERE hest = 'Alphatron*';
UPDATE finished SET hest = 'Astoria Dotcom' WHERE hest = 'Astoria Dotcom*';
UPDATE dnf SET hest = 'Astoria Dotcom' WHERE hest = 'Astoria Dotcom*';
UPDATE finished SET hest = 'Caprino B.R.' WHERE hest = 'Caprino B.R.*';
UPDATE dnf SET hest = 'Caprino B.R.' WHERE hest = 'Caprino B.R.*';
UPDATE finished SET hest = 'Cristal R.R.' WHERE hest = 'Cristal R.R.*';
UPDATE dnf SET hest = 'Cristal R.R.' WHERE hest = 'Cristal R.R.*';
UPDATE finished SET hest = 'Egregious' WHERE hest = 'Egregious*';
UPDATE dnf SET hest = 'Egregious' WHERE hest = 'Egregious*';
UPDATE finished SET hest = 'L''orage' WHERE hest = 'L''orage*';
UPDATE dnf SET hest = 'L''orage' WHERE hest = 'L''orage*';
UPDATE finished SET hest = 'Lovisa Mykla' WHERE hest = 'Lovisa Mykla*';
UPDATE dnf SET hest = 'Lovisa Mykla' WHERE hest = 'Lovisa Mykla*';
UPDATE finished SET hest = 'Magnetic Fightline' WHERE hest = 'Magnetic Fightline*';
UPDATE dnf SET hest = 'Magnetic Fightline' WHERE hest = 'Magnetic Fightline*';
UPDATE finished SET hest = 'Passphoto B.R.' WHERE hest = 'Passphoto B.R.*';
UPDATE dnf SET hest = 'Passphoto B.R.' WHERE hest = 'Passphoto B.R.*';
UPDATE finished SET hest = 'Real Superb' WHERE hest = 'Real Superb*';
UPDATE dnf SET hest = 'Real Superb' WHERE hest = 'Real Superb*';
UPDATE finished SET hest = 'Safe Bourbon' WHERE hest = 'Safe Bourbon*';
UPDATE dnf SET hest = 'Safe Bourbon' WHERE hest = 'Safe Bourbon*';
UPDATE finished SET hest = 'Scarlet Creation' WHERE hest = 'Scarlet Creation*';
UPDATE dnf SET hest = 'Scarlet Creation' WHERE hest = 'Scarlet Creation*';
UPDATE finished SET hest = 'S.J.''s Majesty' WHERE hest = 'S.J.''s Majesty*';
UPDATE dnf SET hest = 'S.J.''s Majesty' WHERE hest = 'S.J.''s Majesty*';
UPDATE finished SET hest = 'U.S. Marshal' WHERE hest = 'U.S. Marshal*';
UPDATE dnf SET hest = 'U.S. Marshal' WHERE hest = 'U.S. Marshal*';

REFRESH MATERIALIZED VIEW viewnavn;



/*
Annet
Bare en hest i ett løp som har brukt mer enn to minutter per kilometer (02.6).
Endrer til 62.6 per kilometer så KM kan min-max normaliseres i området 0-62.6
*/
UPDATE finished SET km = 62.6
WHERE
	dato = '2006-12-22' AND
	travbane = 'Harstad Travpark' AND
	lopnr = 7 AND
	hest = 'Jåra Vesla';
