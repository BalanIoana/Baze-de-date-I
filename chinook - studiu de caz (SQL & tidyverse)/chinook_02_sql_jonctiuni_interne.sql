-- 						Interogari BD Chinook - IE si SPE:
--
-- SQL 02: Jonctiuni interne
--
-- ultima actualizare: 2020-03-07


-- JOIN

-- ############################################################################
-- 						Care sunt albumele formatiei `U2`
-- ############################################################################

-- sol. 1 - NATURAL JOIN
select *
from album natural join artist
where name = 'U2'

-- sol. 2 - ECHI-JOIN
select *
from album inner join artist on album.artistid = artist.artistid
where name = 'U2'

--
select album.*, artist.name
from album inner join artist on album.artistid = artist.artistid
where name = 'U2'


-- ############################################################################
-- 		Care sunt piesele de pe albumul `Achtung Baby` al formatiei U2?
-- ############################################################################

-- sol. eronata care foloseste NATURAL JOIN
select *
from album
	natural join artist
	natural join track
where name = 'U2'

-- sol. corecta - folosind INNER JOIN
select track.*
from album
	natural join artist
	inner join track on album.albumid = track.albumid
where artist.name = 'U2' and title = 'Achtung Baby'

-- ############################################################################
-- 					Care sunt piesele formatiei U2 vandute in anul 2013?
-- ############################################################################

SELECT track.name as track_name, title as album_title
FROM track
	INNER JOIN album ON track.albumid = album.albumid
	INNER JOIN artist ON album.artistid = artist.artistid
	INNER JOIN invoiceline ON track.trackid = invoiceline.trackid
	INNER JOIN invoice ON invoiceline.invoiceid = invoice.invoiceid
WHERE artist.name = 'U2' AND EXTRACT (YEAR FROM invoicedate) = 2013
ORDER BY 1 ;



-- ############################################################################
-- 								AUTOJONCTIUNE
-- ############################################################################


-- ############################################################################
-- 			Care sunt celelalte albume ale formatiei care a lansat
-- 							albumul 'Achtung Baby'?
-- ############################################################################

-- solutie care utilizeaza AUTO JOIN
SELECT a2.*
FROM album NATURAL JOIN artist
	INNER JOIN album a2 ON album.artistid = a2.artistid
WHERE album.title = 'Achtung Baby'



-- ############################################################################
-- 	Care este numele angajatului: lastname = 'Johnson' AND firstname = 'Steve'
-- ############################################################################


-- care este numele angajatului: lastname = 'Johnson' AND firstname = 'Steve'
SELECT sefi.*
FROM employee subordonati
	INNER JOIN employee sefi ON subordonati.reportsto = sefi.employeeid
WHERE subordonati.lastname = 'Johnson' AND subordonati.firstname = 'Steve'




-- ############################################################################
-- 						Probleme de rezolvat la curs/laborator/acasa
-- ############################################################################

-- In ce tari s-a vandut muzica formatiei `Led Zeppelin`

-- Afisare piesele si artistii din playlistul `Heavy Metal Classic`

-- Care sunt piesele formatiei `Led Zeppelin` la care, printre autori, se
--  numara bateristul `John Bonham`

-- Care sunt piesele formatiei `Led Zeppelin` compuse de cel putin trei muzicieni?

-- Care sunt piesele formatiei `Led Zeppelin` compuse (si) de `John Bonham`


-- Care sunt piesele formatiei `Led Zeppelin` la care, printre compozitori, nu apare
--	`Robert Plant`

-- Care sunt piesele formatiei `Led Zeppelin` la care, printre compozitori, nu apare
--	nici `Robert Plant`, nici `Jimmy Page`


-- ############################################################################
-- 						La ce intrebari raspund urmatoarele interogari ?
-- ############################################################################


--
select name as artist_name, title as album_title
from artist inner join album on artist.artistid = album.artistid
where name = title
order by 1 ;


--
select track.name as track_name,
	title as album_title, artist.name as artist_name,
    milliseconds / 1000 as duration_seconds
from track
		inner join album on track.albumid = album.albumid
		inner join artist on album.artistid = artist.artistid
where artist.name = 'U2'
order by milliseconds desc
limit 9