RETURN;

--Homework #3a Querying Multiple Tables
--Your Name: Siddamsettiwar, Palash Vinay

/*--------------------------------------------------------------------------------------
Instructions:

If you haven't done so in class, please download and run the entire syntax in the MovieDatabase.sql file to establish a Movies database.
Answer the following questions as best as possible.
Show your work if you need to take multiple steps to answer a problem. 
Partial answers will count.
--------------------------------------------------------------------------------------*/

USE UC;

/*Q1. List Film Name, Director Name, Studio Name, and Country Name of all films.*/
/*Q1. Syntax*/
select 
	FilmName, DirectorName, StudioName, CountryName
from 
	dbo.tblFilm a 
left outer join 
	dbo.tblDirector b
on 
	a.FilmDirectorID=b.DirectorID
left outer join
	dbo.tblStudio c
on
	a.FilmStudioID = c.StudioID
left outer join
	dbo.tblCountry d
on  
	a.FilmCountryID = d.CountryID
;	

/*Q2. List people who have been actors but not directors.*/
/*Q2. Syntax*/
select 
	ActorName 
from 
	dbo.tblActor a
left outer join 
	dbo.tblDirector b
on
	a.ActorName= b.DirectorName
where 
	DirectorID IS NULL;




/*Q3. List actors that have never been directors and directors that have never been actors.*/
/*Q3. Syntax*/
select
	ActorName
from
	dbo.tblActor a
full outer join
	dbo.tblDirector b
on
	a.ActorName=b.DirectorName
where 
	ActorID IS NULL OR
	DirectorID is NULL;





/*Q4. List all films that are released in the same year when the film Casino is released.*/
/*Q4. Syntax*/

select
	FilmName
from
	dbo.tblFilm
where
	YEAR(FilmReleaseDate) = (select YEAR(FilmReleaseDate) from dbo.tblFilm where FilmName= 'Casino');


/*Q5. Using JOIN to list films whose directors were born between '1946-01-01' AND '1946-12-31'. */
/*Q5. Syntax*/
select
	FilmName
from
	dbo.tblFilm a
inner join
	dbo.tblDirector b
on
	a.FilmDirectorID= b.DirectorID
where
	DirectorDOB BETWEEN '1946-01-01' AND '1946-12-31';


/*Q6. Using subquery to list films whose directors were born between '1946-01-01' AND '1946-12-31'. */
/*Q6. Syntax*/

select 
	FilmName 
from 
	dbo.tblFilm a
where FilmDirectorID in (select DirectorID from dbo.tblDirector where DirectorDOB between '1946-01-01' AND '1946-12-31');


