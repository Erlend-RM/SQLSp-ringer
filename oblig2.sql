--Oppgave 2
--a) 
select navn
from planet
where stjerne = 'Proxima Centauri';


--b)
select distinct oppdaget
from planet
where stjerne = 'TRAPPIST-1' or stjerne= 'Kepler-154';


--c) 
select count(*)
from planet
where masse is null;

--d)
select navn, masse
from planet
where oppdaget='2020' and masse > (select avg(masse) from planet);

--e)
select max(oppdaget) - min(oppdaget) as Antall_år_mellom
from planet;

--Oppgave 3
--a)
Select navn, molekyl
from planet as p
    inner join materie as m on (p.navn = m.planet)
where m.molekyl = 'H2O' and p.masse > 3 and p.masse < 10;

--b)
Select distinct p.navn
from planet as p
  inner join materie as m on (p.navn = m.planet)
  inner join stjerne as s on (p.stjerne = s.navn)
where m.molekyl like '%H%' and s.avstand <= s.masse*12;

--c)
Select p.navn
from planet as p
    inner join planet as p2 on (p.stjerne = p2.stjerne) and (p.navn != p2.navn)
    inner join stjerne as s on (p.stjerne = s.navn)
where p.masse > 10 and p2.masse > 10 and s.avstand < 50;

/*
Oppgave 4
Stjerne = s
Planet = p
Nils kan ikke bruke NATURAL JOIN på grunn av at s.navn ikke er
det samme som p.navn.
Kollonen må være like for at det skal være muilig å kjøre en
NATURAL join. Så for at dette skal fungere så må man bruke en
inner join og sette p.stjerne til s.navn. for disse er like.
*/
--Froslag til nils
SELECT oppdaget
FROM planet
INNER JOIN stjerne as s on (planet.stjerne = s.navn)
WHERE avstand > 8000;


--Oppgave 5
--a)
insert into stjerne 
values ('Sola', 0, 1);

--b)
insert into planet
values ('Jorda', 0.003146, NULL, 'Sola');

--Oppgave 6
BEGIN;

DROP TABLE IF EXISTS observasjon CASCADE;

--CREATE SCHEMA et skjema navn om flere tabler;

CREATE TABLE observasjon (
    observasjons_id integer PRIMARY KEY,
    dato timestamp NOT NULL,
    planet text NOT NULL REFERENCES planet(navn),
    kommentar text,
);

COMMIT;