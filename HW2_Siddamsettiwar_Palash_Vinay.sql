Use UC;

select * from dbo.ChicagoSalary;
--Homework #2 Query from A Single Table

/*--------------------------------------------------------------------------------------
Instructions:

You will need to import the data for Chicago Salary in order to complete this assignment. 

The Chicago Salary tabe should be called dbo.ChicagoSalary and have 4 fields 
Name varchar(255) 
PositionTitle varchar(255) 
Department varchar(255) 
Salary decimal(19,2)

You should have a total of 32,432 rows.

Don't forget to name your columns, an output of (No column name) will reduce your overall grade.

Answer each question as best as possible.  
Show your work if you need to take multiple step to answer a problem. 
Partial answers will count.
--------------------------------------------------------------------------------------*/


/* 
Q1.
Write the query to COUNT the number of Records in the Salary table 
*/

/* Q1. Query*/
select count(*) as "Number of Records" from dbo.ChicagoSalary;






/* 
Q2.
Write a query to display the number of unique names
*/

/* Q2. Query */
select count(distinct(Name)) as "Number of Unique Names" from dbo.ChicagoSalary;





/* 
Q3.
Write a query to display the only the name and positiontitle of those with a full name that contains the text Spangler in it
*/

/* Q3. Query*/
select Name, PositionTitle as 'Position' from dbo.ChicagoSalary where name like '%Spangler%';





/* 
Q4. Write a query to display the name and position of the person who has the lowest Half of the Salary (Name the half salary as HalfYEarSalary) in the the AVIATION department.
*/

/* Q4. Query */

select top 1 Name, PositionTitle as 'Position', Salary/2 as 'HalfYearSalary' from dbo.ChicagoSalary where Department='Aviation' order by Salary asc;




/* 
Q5. Write a query to display all the names and salaries of everyone in the WATER MGMNT department
that makes more than 150K in salary, order the output by Salary descending
*/

/* Q5. Query */ 
select Name, Salary from dbo.ChicagoSalary where Department='WATER MGMNT' and Salary>150000.00 order by Salary desc;





/* 
Q6. Display the total salary of the entire Chicago salary table
*/

/* Q6. Query */
select sum(Salary) as 'Total Salary'from dbo.ChicagoSalary;





/* 
Q7. Display the department name and average salary where average salary for the department is more than 90000
*/

/* Q7. Query */
select Department, AVG(Salary) as 'Average Department Salary' from dbo.ChicagoSalary group by Department having AVG(Salary)>90000;





/* Q8. Which Employee has the highest salary? How Much higher is that person's salary compared to the AVG salary of the department they belong too?
*/

/*Q8. Query */
select top 1 Name, Salary, Salary-Avg_Salary as 'Salary Difference' from 
(
(select Name, Salary, Department from dbo.ChicagoSalary) a
inner join
(select Department, AVG(Salary) as 'Avg_Salary' from dbo.ChicagoSalary group by Department) b
on a.Department = b.Department
)
order by Salary desc; 




/* Q9. Display the Name, Department, Salary (to the nearest whole number) of any employee who has a salary of 60000 or more and their name begins with 'Aaron'
*/ 

/* Q9. Query */
select Name, Department, CAST(ROUND(Salary, 0) AS INT) AS 'Salary' from dbo.ChicagoSalary where Salary>=60000 and Name like 'Aaron%';





/* Q10. If we wanted to stored Social Security Number (SSN) for each employee what kind of data type should we use for the column? What type of data type should we use for Phone Number? Explain your reasoning for both questions.
*/

/* Q10. Answer */
/* 
For SSN, we should use the data-type VARCHAR(11). For SSN, the standard format is of 9 numbers with 2 dashes such as '123-23-2345'. VARCHAR(11) takes care of this.
For phone number, we should use the data-type VARCHAR(14) to accomodate text such as (123) 412-2143. Since we know that phone numbers are generally only 10 numbers with the added punctuation as mentioned, this data type should do.





*/

/* Bonus Q11.  Display LastName and FirstName (with Middle Initial) as seperate columns/fields derived from the Name field. Write down your query in the answersheet.

*/

/* Q11. Query */
select LEFT(Name, CHARINDEX(',', Name)-1), RIGHT(Name, LEN(Name)- CHARINDEX(',', Name)) as 'Last Name' from dbo.ChicagoSalary;








/*Bonus Q12. You may share any challenge(s) you face while finishing the assignment and how you overcome the challenge.
*/

The challenges faced my me in this assignment were:
> To figure out how to import the excel data in the first place
> To find out how to solve the Question 8th. Approaching logically, it took time to figure out how to struccture the query.
> To research and use the left, right and charindex functions in the 11th question.
All three challenges were solved by putting additional effort and time, researching for solutions by Googling and referring to the class notes.