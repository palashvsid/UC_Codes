/*	
	IS6030 Homework 4a 
*/

USE HW4;
/*--------------------------------------------------------------------------------------
Instructions:

You will be using the StudentDinner database we created in class to answer the following questions.

Please download the StudentDinner.sql and execute the file to create the StudentDinner database
if you have not done so in class.

Answer each question as best as possible.  
Show your work if you need to take multiple steps to answer a problem. 
Partial answers will count.
--------------------------------------------------------------------------------------*/


/*Q1. List the restaurant according to their average ratings, from the highest to the lowest.*/
/* Q1. Query */
select 
	RName as 'Restaurant', AVG(Rating) as 'Restaurant_Rating'
from 
	dbo.Restaurant a
inner join
	dbo.Dinner b
on a.RID=b.RID
group by RName
order by Restaurant_Rating Desc;



/*Q2. List the names of student who eat out every single day of the week.*/
/* Q2. Query */
select 
	SName as 'Student'
from
	dbo.Student a
inner join
	dbo.Dinner b
on
	a.SID=b.SID
group by Sname
having count(distinct(DinnerDay))=7
order by SName;



/*Q3. List the restaurant whose total earning is greater than $100 and does not have a phone number, with the highest earning restaurant at the top.*/
/* Q3. Query */

select 
	RName as 'Restaurant', Sum(Cost) as 'Earning'
from 
	dbo.Restaurant a
inner join
	dbo.Dinner b
on a.RID=b.RID
where Phone IS NULL
group by RName
having Sum(Cost) >100 
order by Earning Desc
;


/*Q4. List the student according to the total distance they travel for dinner.*/
/* Q4. Query */

select
	SName as 'Student', Sum(LCBDistance) as 'Distance_Travelled'
from
	dbo.Student a
left join
	dbo.Dinner b
on a.SID= b.SID
left join
	dbo.Restaurant c
on b.RID = c.RID
group by Sname
order by Distance_Travelled Desc
;



/*Q5. List the names of student who do not like to eat out on Thursdays.*/
/* Q5. Query */

select 
	SName as 'Student' 
from 
	dbo.Student 
where 
	Sname 
NOT IN
	(
	select
		SName
	from
		dbo.Student a
	inner join
		dbo.Dinner b
	on a.SID = b.SID
	where DinnerDay='Thursday'
	)
order by SName;



/*Q6. Write a query to show the name and the rating of the highest rated restaurant.*/
/* Q6. Query */

select 
	top 1 RName as 'Restaurant', AVG(Rating) as 'Restaurant_Rating'
from 
	dbo.Restaurant a
inner join
	dbo.Dinner b
on a.RID=b.RID
group by RName
order by Restaurant_Rating Desc;




/*	
	IS6030 Homework 4b 
*/

USE HW4;
/*--------------------------------------------------------------------------------------
Instructions:

You will be using the Baltimore Parking Citations data set (14,705 rows)
(this is only a snapshot of all citations for Baltimore).

The name of your table should be called dbo.ParkingCitations.

Answer each question as best as possible.  
Show your work if you need to take multiple steps to answer a problem. 
Partial answers will count.
--------------------------------------------------------------------------------------*/

/* 
	You can run this query to check your table, if it does not run or you do not get 14,705 rows,
    you should revisit your import/table.  Before you do anything, make sure your data/table is correct!
	
	Reminder: Please check which database you imported data into and which database you are working with.
*/
print @@servername;


SELECT *
	FROM dbo.ParkingCitations
order by ViolFine; 

/* Q1.  Show the number of Citations, Total Fine amount, by Make and Violation Date. 
        Sort your results in a descending order of Violation Date and in an ascending order of Make.
		Hint: Check the data type for ViolDate and see whether any transformation is needed.
*/

/* Q1. Query */
select
	convert(varchar, ViolDate, 103) as "Violation Date",
	Make,
	count(Citation) as 'Number of Citations',
	sum(ViolFine) as 'Total Fine Amount'
from
	dbo.ParkingCitations
group by Make, convert(varchar, ViolDate, 103)
order by convert(varchar, ViolDate, 103) desc, Make asc;


/* Q2. Display just the State (2 character abbreviation) that has the most number of violations.
*/

/* Q2. Query */
select 
	top 2 State 
from 
	dbo.ParkingCitations 
group by State
order by count(Citation) desc;


/* Q3. Display the number of violations and the tag, for any tag that is registered at Maryland (MD) and has 6 or more violations. 
	   Order your results in a descending order of number of violations.
*/

/* Q3. Query */
select Tag, count(ParkingCitationID) as 'Number of Citations'		
from
	dbo.ParkingCitations
where
	State='MD'
group by Tag
having 
	count(ParkingCitationID)>=0
order by 
	count(ParkingCitationID) desc;


/* Q4. Use functions and generate a one column output by formatting the data into this format 
	(I'll use the first record as an example of the format, you'll need to apply this to all records with State of MD):	
			15TLR401 - Citation: 98348840 - OTH - Violation Fine: $502.00 
*/

/* Q4. Query */
select Tag + ' - ' + 'Citation: ' + Citation + ' - ' + Make + ' - Violation Fine: $' + convert(varchar, ViolFine)
from
	dbo.ParkingCitations;


/* Q5. Write a query to calculate which states MAX ViolFine differ more than 200 from MIN VioFine 
	   Display the State Name and the Difference.  Sort your output by State A->Z.
*/

/* Q5. Query */
select 
	State, MAX(ViolFine)-MIN(ViolFine) as 'Difference'
from
	dbo.ParkingCitations
group by State
having MAX(ViolFine)-MIN(ViolFine)>200
order by State;






/* Q6. You will need to bucket the entire ParkingCitations database into three segments by ViolFine. 
	   Your first segment will include records with ViolFine between $0.00 and $50.00 and will be labled as "01. $0.00 - $50.00".
	   The second segment will include records with ViolFine between $50.01 and $100.00 and will be labled as "02. $50.01 - $100.00".
	   The final segment will include records with ViolFine larger than $100.00 and will be labled as"03. larger than $100.00". 

	   Display Citation, Make, VioCode, VioDate, VioFine, and the Segment information in an descending order of ViolDate. 	    
*/ 

/* Q6. Query */

select
	Citation,
	Make,
	ViolCode,
	ViolDate,
	ViolFine,
	case 
		when ViolFine BETWEEN 0.00 AND 50.00 THEN '01. $0.00 - $50.00'
		when ViolFine BETWEEN 50.01 AND 100.00 THEN '02. $50.01 - $100.00'
		else '03. larger than $100.00'
		end as 'Segment'
from
	dbo.ParkingCitations
order by ViolDate desc;



/* Q7. Bonus Question:
	   Based on the three segments you created in Q6, display the AVG ViolFine and number of records for each segment. 
	   Order your output by the lowest -> highest segments.   
*/ 

/* Q7. Query */
select 
	Segment, 
	Sum(ViolFine) as 'Average Violation Fine', 
	count(*) as 'Number of Records' 
from 
(
	select
		case 
			when ViolFine BETWEEN 0.00 AND 50.00 THEN '01. $0.00 - $50.00'
			when ViolFine BETWEEN 50.01 AND 100.00 THEN '02. $50.01 - $100.00'
			else '03. larger than $100.00'
		end as 'Segment',
		ViolFine
	from
		dbo.ParkingCitations
) as a
group by 
	Segment
order by 
	Segment
;


/* Q8. Bonus Question:
	   You may share any challenge(s) you face while finishing the assignment and how you overcome the challenge.
*/

/* Q8. Answer */
/*
 The challenges face in this assignment were:
  1. Understanding what all tables to join on what columns for the relevant answer
  2. In Question 2, Maryland state seems to have an abnormally high number of citations which I wasn't able to explain
  3. In Question 3, number of tags with 6 or more violations returned only 2 tags, both with 6 vioations. This seemed counterintuitive to this question.
*/