-- Oppgave 1 - Oppvarming
SELECT concat(p.firstname, ' ', p.lastname) as Navn, fc.filmcharacter as Rolle   
FROM film as f
    inner join filmparticipation as fp using(filmid)
    inner join person as p using(personid)
    inner join filmcharacter as fc using(partid)
where title = 'Star Wars' and fp.parttype = 'cast'
;

-- Oppgave 2 - Land
SELECT country as land, count(*) as antall 
FROM filmcountry
group by country
Order by antall desc
;

-- Oppgave 3 - Spilletider
SELECT country as land, avg(cast(time as int)) as avrage  
FROM runningtime
where time ~ '^\d+$' and country != '' 
group by country Having count(time) >= 200
;

-- Oppgave 4 - Komplekse mennesker
SELECT f.title, count(fg.genre) as antall
FROM film as f
    inner join filmgenre as fg using(filmid)
    inner join filmitem as fi using(filmid)
where filmtype = 'C'
group by f.title, filmid
Order by antall desc, title
LIMIT 10
;

-- Oppgave 5 - Land og filmvaner
With 
t1 as(
SELECT country as land, count(*) as antall, avg(fr.rank) as gjsnitt
FROM filmcountry
    inner join filmrating as fr using(filmid)
group by country
Order by antall desc),

t2 as (
SELECT fc.country as land, count(fg.genre) as antall, fg.genre as sjanger
FROM filmcountry as fc
    inner join filmgenre as fg using(filmid)
group by fc.country, fg.genre
Order by antall desc
),

t3 as(SELECT t2.land as land, max(t2.antall) as maks
FROM t2
group by t2.land
Order by maks desc)

SELECT t1.land, t1.antall, t1.gjsnitt, max(t2.sjanger)
from t1
    inner join t2 on(t1.land = t2.land)
    inner join t3 on(t2.antall = t3.maks 
        and t2.land = t3.land 
        and t1.land = t3.land)
group by t1.land, t1.antall, t1.gjsnitt
order by antall desc
;


-- Oppgave 6 - Vennskap
With t1 as(
SELECT concat(p.firstname, ' ', p.lastname) as Navn, filmid
FROM film as f
    inner join filmparticipation as fp using(filmid)
    inner join person as p using(personid)
    inner join filmcountry as fc using(filmid)
    inner join filmitem as fi using(filmid)
where fc.country = 'Norway' 
    and filmtype = 'C'
)

SELECT T1.Navn as fp1, T2.Navn as fp2
FROM t1 T1, t1 T2
where T1.Navn != T2.Navn 
    and T1.filmid = T2.filmid 
    and T1.Navn < T2.Navn
group by T1.Navn, T2.Navn
Having count(T1.Navn) >= 40
;


-- Oppgave 7 - Mot
SELECT Distinct title, prodyear
FROM film
    left join filmgenre as fg using(filmid)
    left join filmcountry as fc using(filmid)
where (title Like '%Dark%'
or title Like '%Night%')
and (fc.country = 'Romania'
or fg.genre = 'Horror')
order by title
;


-- Oppgave 8 - Lunsj
SELECT f.title, count(partid) as antall
FROM film as f
    left join filmparticipation as fp using(filmid)
where prodyear >= 2010
group by f.title
Having count(partid) <= 2
;


-- Oppgave 9 - Introspeksjon
SELECT count(*)
From film
where filmid not in (
    SELECT distinct fg.filmid
    FROM filmgenre as fg
    where fg.genre = 'Sci-Fi' or fg.genre = 'Horror'   
    )
;


-- Oppgave 10 - Kompetanseheving
With 
t1 as(
SELECT f.title, count(fl.language) as antallSpråk
FROM film as f
    left join filmlanguage as fl using(filmid)
    inner join filmrating as fr using(filmid)
    inner join filmitem as fi using(filmid)
where fr.rank >= 8 
    and fr.votes > 1000
    and filmtype = 'C'
group by f.title, fr.votes, fr.rank
order by fr.rank desc, fr.votes desc
LIMIT 10
),

t2 as(
SELECT f.title, count(fl.language) as antallSpråk
FROM film as f
    left join filmlanguage as fl using(filmid)
    inner join filmparticipation as fp using(filmid)
    inner join person as p on (fp.personid = p.personid)
    inner join filmitem as fi using(filmid)
    inner join filmrating as fr using(filmid)
where (p.firstname = 'Harrison'
    and p.lastname = 'Ford')
    and filmtype = 'C'
    and (fr.rank >= 8 
    and fr.votes > 1000)
group by f.title
),

t3 as(
SELECT f.title, count(fl.language) as antallSpråk
FROM film as f
    left join filmlanguage as fl using(filmid)
    inner join filmgenre as fg using(filmid)
    inner join filmitem as fi using(filmid)
    inner join filmrating as fr using(filmid)
where fi.filmtype = 'C'
    and (fr.rank >= 8 
    and fr.votes > 1000) 
    and (fg.genre = 'Comedy' 
    or fg.genre = 'Romance')
group by f.title
)

SELECT title, COALESCE(t1.antallSpråk, t2.antallSpråk, t3.antallSpråk) as antallSpråk
from t1
    full outer join t2 using(title)
    full outer join t3 using(title)
group by title, t1.antallSpråk, t2.antallSpråk, t3.antallSpråk
;
