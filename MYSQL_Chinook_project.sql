/* ************************************************************************** */
                             -- PROJECT--
/* ************************************************************************** */

/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

create database chinook;
use chinook;

select * from Album; 
select * from Artist; 
select * from Customer; 
select * from Employee; 
select * from Genre; 
select * from Invoice; 
select * from InvoiceLine; 
select * from MediaType; 
select * from Playlist; 
select * from PlaylistTrack; 
select * from Track; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

           ----------- SQL Queries to answer some questions from the chinook database -----------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1) Find the artist who has contributed with the maximum no of songs. Display the artist name and the no of albums.

-- Highest no of albums
select artist_name, no_of_album
  from (
    select ar.name as artist_name,count(1)as no_of_album
	,rank()over(order by count(1) desc) as rnk	
    from album al
    join artist ar on ar.artistid = al.artistid
	join track t on t.albumid = al.albumid
	group by artist_name) x
  where x.rnk = 1;
  
  -- Highest no of songs/tracks
   select name from (
        select ar.name,count(1)
        ,rank() over(order by count(1) desc) as rnk
        from Track t
        join album a on a.albumid = t.albumid
        join artist ar on ar.artistid = a.artistid
        group by ar.name
        order by 2 desc) x
    where rnk = 1;
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
-- 2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

   select concat(c.firstname,' ', c.lastname) as customer_name
    , c.email, c.country, g.name as genre
   from genre g
   join track t on t.genreid = g.genreid
   join invoiceline il on il.trackid = t.trackid
   join invoice i on i.invoiceid = il.invoiceid
   join customer c on c.customerid = i.customerid
   where g.name in ('Jazz','Rock','Pop');

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
-- 3) Find the employee who has supported the most no of customers. Display the employee name and designation
   
select employee_name,designation
from
     ( select concat(e.firstname,' ', e.lastname) as employee_name,e.title as designation
	  ,count(1) as no_of_customer
	  ,rank()over(order by count(1)desc) as rnk
	  from customer c
	  join employee e on e.employeeid = c.supportrepid
	  group by employee_name,designation )x
	where x.rnk = 1
 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- 4) Which city corresponds to the best customers?

select city
from
    (select i.customerid,c.city as city ,sum(total) as tot_purchase
    ,rank()over(order by sum(total) desc) as rnk
    from customer c
    join invoice i on i.customerid = c.customerid
    group by 1,2)x
	where x.rnk = 1;
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
 -- 5) The highest number of invoices belongs to which country?

 select country
 from(
    select billingcountry as country,count(1) as no_of_invoice
   ,rank()over(order by count(1)desc)as rnk
   from invoice
   group by country)x
   where x.rnk = 1;
   
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
-- 6) Name the best customer (customer who spent the most money).
 
  select customer_name
  from
    (select i.customerid,concat(c.firstname,' ',c.lastname) as customer_name,sum(total) as tot_purchase
    ,rank()over(order by sum(total) desc) as rnk
    from customer c
    join invoice i on i.customerid = c.customerid
    group by 1,2)x
	where x.rnk = 1;
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
-- 7) Suppose you want to host a rock concert in a city and want to know which location should host it.
 --   Query the dataset to find the city with the most rock-music listeners to answer this question.
   
   select i.billingcity,count(1) as rock_music_listeners
   from genre g
   join track t on t.genreid = g.genreid
   join invoiceline il on il.trackid = t.trackid
   join invoice i on i.invoiceid = il.invoiceid
   where g.name = 'Rock'
   group by i.billingcity
   order by 2 desc;
   
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
  -- 8) Identify all the albums who have less then 5 track under them.
  
   select al.title as album_name, art.name as artist_name, count(1) as no_of_tracks
   from album al
   join track t on t.albumid = al.albumid
   join artist art on art.artistid = al.artistid
   group by al.title, art.name
   having count(1) < 5;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
 -- 9) Display the track, album, artist and the genre for all tracks which are not purchased.
   
    select t.name as track_name, al.title as album_title, art.name as artist_name, g.name as genre
    from Track t
	left join invoiceline il on il.trackid = t.trackid
    join album al on al.albumid=t.albumid
    join artist art on art.artistid = al.artistid
    join genre g on g.genreid = t.genreid
	where il.invoiceid is  null;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
 -- 10) Find artist who have performed in multiple genres. Diplay the artist name and the genre.
   
   with cte as
		   (select distinct ar.name as artist_name,g.name as genre_name
		   from track t
		   join album al on al.albumid = t.albumid
		   join artist ar on ar.artistid = al.artistid
		   join genre g on g.genreid = t.genreid),
	   multiple_genre as
	       (select artist_name,count(1)
            from cte
			group by artist_name
		   having count(1) > 1)
   select mg.artist_name , cte.genre_name
   from multiple_genre mg
   join cte on cte.artist_name = mg.artist_name
   order by 1,2;   

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
-- 11) Which is the most popular and least popular genre?  
--    Popularity is defined based on how many times it has been purchased.

  with cte as 
      (select g.name as genre_name, count(1) as no_of_purchase
      ,rank()over(order by count(1)desc) as rnk
      from invoiceline il
      join track t on t.trackid = il.trackid
      join genre g on g.genreid = t.genreid
      group by genre_name)
  select genre_name,'Most popular' as popularity
  from cte
  where rnk = 1
  union
  select genre_name,'Least popular' as popularity
  from cte
  where rnk in(select max(rnk) from cte);
  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
-- 12) Identify if there are tracks more expensive than others. If there are then
  --   display the track name along with the album title and artist name for these expensive tracks.
	
	select t.name as track_name,al.title as album_name,ar.name as artist_name
	from track t
    join album al on al.albumid = t.albumid
	join artist ar on ar.artistid = al.artistid
	where t.unitprice > (select min(unitprice)from track)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
--  13) Identify the 5 most popular artist for the most popular genre.
--      Popularity is defined based on how many songs an artist has performed in for the particular genre.
--	    Display the artist name along with the no of songs.
	
    with cte as 
          (select g.genreid,g.name as genre_name, count(1) as no_of_purchase
          ,rank()over(order by count(1)desc) as rnk
          from invoiceline il
          join track t on t.trackid = il.trackid
          join genre g on g.genreid = t.genreid
          group by g.genreid,g.name),
	  most_popular_genre as
	     (select genreid,genre_name from cte where rnk = 1 ),
	  final_data as
	     (select ar.name as artist_name,count(1) as no_of_songs
		 ,rank()over(order by count(1) desc) as rnk
	     from track t
	     join album al on al.albumid = t.albumid
	     join artist ar on ar.artistid = al.artistid
	     join most_popular_genre pop on pop.genreid = t.genreid
	     group by ar.name)
   select artist_name,no_of_songs
   from final_data
   where rnk < 6;
   
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   