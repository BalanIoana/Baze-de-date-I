####       -- 		Interogari `tidyverse` vs SQL - BD Chinook (IE si SPE)
# # --
# # -- 03: Operatori ansamblisti (UNION, INTERSECT, EXCEPT)
# # --
# # -- ultima actualizare: 2020-03-10
# #
#install.packages('tidyverse')
library(tidyverse)
library(lubridate)

setwd('/Users/marinfotache/Google Drive/Baze de date 2020/Studii de caz/chinook')
load("chinook.RData")

#
# #
# #
# # -- ############################################################################
# # -- 					UNION
# # -- ############################################################################
# #
# # -- ############################################################################
# # -- 		Care sunt piesele care apar pe doua discuri ale formatiei
# # -- 		    'Iron Maiden', `Fear Of The Dark` si `A Real Live One`
# # -- ############################################################################
# #
# #-- SQL
#
# # -- solutie bazata pe OR (dubluri neeliminate)
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND (title = 'Fear Of The Dark'
# # 	OR title = 'A Real Live One')
# # ORDER BY 1
# #
# # -- solutie bazata pe OR (dubluri eliminate)
# # SELECT DISTINCT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND (title = 'Fear Of The Dark'
# # 	OR title = 'A Real Live One')
# # ORDER BY 1
# #
# #
# # -- solutie bazata pe UNION (dubluri eliminate)
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'Fear Of The Dark'
# # UNION
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'A Real Live One'
# # ORDER BY 1
# #

###
### tidyverse
###

# solutia urmatoare nu elimina dublurile
temp <- artist %>%
     filter (name == 'Iron Maiden') %>%
     select (-name) %>%
     inner_join(album) %>%
     filter (title == 'Fear Of The Dark' | title == 'A Real Live One') %>%
     inner_join(track) %>%
     select (name) %>%
     arrange(name)

# solutia urmatoare elimina dublurile
temp <- artist %>%
     filter (name == 'Iron Maiden') %>%
     select (-name) %>%
     inner_join(album) %>%
     filter (title == 'Fear Of The Dark' | title == 'A Real Live One') %>%
     inner_join(track) %>%
     distinct (name) %>%
     arrange(name)


# sol. 1 cu `union`
temp <- dplyr::union(
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          distinct (name),
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'A Real Live One') %>%
          inner_join(track) %>%
          distinct (name)) %>%
     arrange(name)


# sol. 2 cu `union`
temp <- artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          distinct (name) %>%
     dplyr::union(
          artist %>%
               filter (name == 'Iron Maiden') %>%
               select (-name) %>%
               inner_join(album) %>%
               filter (title == 'A Real Live One') %>%
               inner_join(track) %>%
               distinct (name)
          ) %>%
     arrange(name)


# # -- ############################################################################
# -- Care sunt subordonatii de ordinul 1 (directi) si 2 (subordonatii direct ai subordonatilor de ordinul 1)
# -- ai lui `Adams` (lastname) `Andrew` (firstname)
# 
# -- subordonatii de ordinul 1
# SELECT subordonati1.*
# FROM employee sefi 
# 	INNER JOIN employee subordonati1 ON sefi.employeeid = subordonati1.reportsto
# 	INNER JOIN employee subordonati2 ON subordonati1.employeeid = subordonati2.reportsto
# WHERE sefi.lastname = 'Adams' AND sefi.firstname = 'Andrew'
# UNION
# -- subordonatii de ordinul 2
# SELECT subordonati2.*
# FROM employee sefi 
# 	INNER JOIN employee subordonati1 ON sefi.employeeid = subordonati1.reportsto
# 	INNER JOIN employee subordonati2 ON subordonati1.employeeid = subordonati2.reportsto
# WHERE sefi.lastname = 'Adams' AND sefi.firstname = 'Andrew'
# # -- ############################################################################


# solutie bazata pe `union`
temp <- 
        # subordonatii de ordinul I
        employee %>%
                filter (lastname == 'Adams' & firstname == 'Andrew') %>%
                transmute (boss_employeeid = employeeid) %>%
                inner_join(employee, by = c('boss_employeeid' = 'reportsto')) %>%
                select (-boss_employeeid) %>%
        dplyr::union( # subordonatii de ordinul II
                employee %>%
                        filter (lastname == 'Adams' & firstname == 'Andrew') %>%
                        transmute (boss_employeeid = employeeid) %>%
                        inner_join(employee, by = c('boss_employeeid' = 'reportsto')) %>% 
                        transmute (first_order_subordinates_id = employeeid) %>%
                        inner_join(employee, by = c('first_order_subordinates_id' = 'reportsto')) %>%
                        select (-first_order_subordinates_id)
        )        



# solutie bazata pe `bind_rows`
temp <- bind_rows(
        # subordonatii de ordinul I
        employee %>%
                filter (lastname == 'Adams' & firstname == 'Andrew') %>%
                transmute (boss_employeeid = employeeid) %>%
                inner_join(employee, by = c('boss_employeeid' = 'reportsto')) %>%
                select (-boss_employeeid),
        # subordonarii de ordinul II
        employee %>%
                filter (lastname == 'Adams' & firstname == 'Andrew') %>%
                transmute (boss_employeeid = employeeid) %>%
                inner_join(employee, by = c('boss_employeeid' = 'reportsto')) %>% #subordonatii directi
                transmute (first_order_subordinates_id = employeeid) %>%
                inner_join(employee, by = c('first_order_subordinates_id' = 'reportsto')) %>%
                select (-first_order_subordinates_id)
        )        
        
        




# # -- ############################################################################
# # -- 				INTERSECT
# # -- ############################################################################
# #
# # -- ############################################################################
# # -- 			Care sunt piesele comune (cu acelasi titlu) de pe
# # -- 			albumele `Fear Of The Dark` si `A Real Live One`
# # -- 					ale formatiei 'Iron Maiden'
# # -- ############################################################################
# #
# # -- SQL
#
# # -- solutie ERONATA 1 !!!
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'Fear Of The Dark'
# # 	AND title = 'A Real Live One'
# # -- nicio linie!!!
# #
# #
# # -- solutie ERONATA 2 !!!
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND (title = 'Fear Of The Dark'
# # 	OR title = 'A Real Live One')
# # -- extrage solutie extrage, de fapt, piesele de pe ambele albume,
# # -- nu piesele comune!!!
# #
# #
# #
# # -- solutie corecta bazata pe intersect
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'Fear Of The Dark'
# # INTERSECT
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'A Real Live One'
# #
# #
# # -- solutie bazata de auto-join
# # SELECT track1.name
# # FROM artist artist1
# # 	INNER JOIN album album1 ON artist1.artistid = album1.artistid
# # 	  	AND artist1.name = 'Iron Maiden' AND album1.title = 'Fear Of The Dark'
# # 	INNER JOIN track track1 ON album1.albumid = track1.albumid
# # 	INNER JOIN track track2 ON track1.name = track2.name -- AICI E AUTOJONCTIUNEA
# # 	INNER JOIN album album2 ON track2.albumid = album2.albumid
# # 		AND album2.title = 'A Real Live One'
# # 	INNER JOIN artist artist2 ON album2.artistid = artist2.artistid
# # 		AND artist2.name = 'Iron Maiden'
# #

###
### tidyverse
###

# solutie eronata 1 !!! (AND)
temp <- artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark' & title == 'A Real Live One') %>%
          inner_join(track) %>%
          select (name)

# solutie eronata 2 !!! (OR)
temp <- artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark' | title == 'A Real Live One') %>%
          inner_join(track) %>%
          select (name)


# solutie corecta bazata pe `intersect`
temp <- dplyr::intersect(
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          select (name),
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'A Real Live One') %>%
          inner_join(track) %>%
          select (name)
     )


# solutie corecta bazata pe `intersect`
# 
# de vazut ce e in neregula !!!
temp <- artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          select (name) %>%
        dplyr::intersect(
             artist %>%
                filter (name == 'Iron Maiden') %>%
                select (-name) %>%
                inner_join(album) %>%
                filter (title == 'A Real Live One') %>%
                inner_join(track) %>%
                select (name)
                        )


# -- solutie bazata de auto-join
temp <- artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          select (name) %>%
     inner_join(
          artist %>%
               filter (name == 'Iron Maiden') %>%
               select (-name) %>%
               inner_join(album) %>%
               filter (title == 'A Real Live One') %>%
               inner_join(track) %>%
               select (name)
               )



# solutie noua (fara echivalent in SQL-PostgreSQL): SEMI JOIN
temp <- track %>%
     semi_join(
          album %>%
               filter (title == 'Fear Of The Dark') %>%
               semi_join(
                    artist %>%
                         filter (name == 'Iron Maiden')
                         )) %>%
     select (name) %>%
     semi_join(
          track %>%
               semi_join(
                    album %>%
                         filter (title == 'A Real Live One') %>%
                    semi_join(
                         artist %>%
                              filter (name == 'Iron Maiden')
                              ))
     )



# # -- ############################################################################
# # -- 				    EXCEPT
# # -- ############################################################################
# #
# # -- ############################################################################
# # -- Care sunt piesele formatiei 'Iron Maiden' de pe albumul `Fear Of The Dark`
# # -- 				care NU apar si pe albumul `A Real Live One`
# # -- ############################################################################
# #
# # -- SQL
#
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'Fear Of The Dark'
# # EXCEPT
# # SELECT track.name
# # FROM artist
# # 	INNER JOIN album ON artist.artistid = album.artistid
# # 	INNER JOIN track ON album.albumid = track.albumid
# # WHERE artist.name = 'Iron Maiden' AND title = 'A Real Live One'
# #
# #
# #

###
### tidyverse
###

# solutie bazata pe `setdiff` (exchivalentul EXCEPT)
temp <- dplyr::setdiff(
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'Fear Of The Dark') %>%
          inner_join(track) %>%
          select (name),
     artist %>%
          filter (name == 'Iron Maiden') %>%
          select (-name) %>%
          inner_join(album) %>%
          filter (title == 'A Real Live One') %>%
          inner_join(track) %>%
          select (name)
     )


# solutie noua (fara echivalent in SQL-PostgreSQL): ANTI JOIN
temp <- track %>%
     semi_join(
          album %>%
               filter (title == 'Fear Of The Dark') %>%
               semi_join(
                    artist %>%
                         filter (name == 'Iron Maiden')
                         )) %>%
     select (name) %>%
     anti_join(
          track %>%
               semi_join(
                    album %>%
                         filter (title == 'A Real Live One') %>%
                    semi_join(
                         artist %>%
                              filter (name == 'Iron Maiden')
                              ))
     )



# -- ############################################################################
# -- Care sunt piesele formatiei `Led Zeppelin` la care, printre compozitori, nu apare
# --	nici `Robert Plant`, nici `Jimmy Page`
# -- ############################################################################
temp <- artist %>%
        filter (name == 'Led Zeppelin') %>%
        transmute(artistid, artist_name = name) %>%
        inner_join(album) %>%
        inner_join(track) %>% 
        anti_join(
                artist %>%
                filter (name == 'Led Zeppelin') %>%
                transmute(artistid, artist_name = name) %>%
                inner_join(album) %>%
                inner_join(track) %>%
                filter (str_detect(composer, 'Plant'))) %>%
        anti_join(
                artist %>%
                filter (name == 'Led Zeppelin') %>%
                transmute(artistid, artist_name = name) %>%
                inner_join(album) %>%
                inner_join(track) %>%
                filter (str_detect(composer, 'Page')))




#
# -- ############################################################################
# -- 		Probleme de rezolvat la curs/laborator/acasa
# -- ############################################################################
#
#
# -- Afisare piesele (si artistii) comune playlisturilor `Heavy Metal Classic` si `Music`
#
# -- Care sunt piesele formatiei `Led Zeppelin` compuse numai de `Robert Plant`
#
# -- Care sunt piesele formatiei `Led Zeppelin` compuse, impreuna, de `Robert Plant` si
# --  `Jimmy Page`, cu sau fara alti colegi/muzicieni?
#
# -- Care sunt piesele formatiei `Led Zeppelin` compuse, impreuna, de `Robert Plant` si
# --  `Jimmy Page`, fara alti colegi/muzicieni?
#
# -- Care sunt piesele formatiei `Led Zeppelin` la care, printre compozitori, nu apare
# --	`Robert Plant`
#
