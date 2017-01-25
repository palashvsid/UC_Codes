RETURN;
--Homework #3b Querying Multiple Tables
--Your Name: Siddamsettiwar, Palash Vinay

/*--------------------------------------------------------------------------------------
Instructions:

You will be using the Chicago Salary table but you will following the questions 
to normalize the data in order to provide a table structure to test your JOIN abilities. 

You can use the original summary table to double check any answers.

Answer each question as best as possible.  
Show your work if you need to take multiple steps to answer a problem. 
Partial answers will count.
--------------------------------------------------------------------------------------*/

USE UC;
/* 
Q1. Write the syntax to drop and build a table called dbo.Employee. 
	Create an EmployeeID field (IDENTITY PK), a Name field and a Salary field for the Employee table.
	Populate the Employee table with unique Name and Salary information from the dbo.ChicagoSalary table.
*/


/* Q1. Syntax*/
IF OBJECT_ID('dbo.Employee', 'U') IS NOT NULL DROP TABLE dbo.Employee;
create table dbo.Employee
(
 EmployeeID INT IDENTITY PRIMARY KEY,
 Name VARCHAR(100),
 Salary DECIMAL (10,4)
);

INSERT INTO dbo.Employee(Name, Salary) (select distinct Name, Salary from dbo.ChicagoSalary);




/* 
Q2. Write the syntax to drop and build a table called dbo.Department.
	Create an DepartmentID field (IDENTITY PK), and a Name field for the Department Table.
	Populate the Department table with unique Department Names.
*/

/* Q2. Syntax */
IF OBJECT_ID('dbo.Department', 'U') IS NOT NULL DROP TABLE dbo.Department;
create table dbo.Department
(
 DepartmentID INT IDENTITY PRIMARY KEY,
 Name VARCHAR(100)
);

INSERT INTO dbo.Department(Name) (select distinct Department from dbo.ChicagoSalary);






/* 
Q3. Write the syntax to drop and build a table called dbo.Position.
	Create an PositionID field (IDENTITY PK), and a Name field for the Position table.
	Populate the Position table with unique PositionTitles (call the field Title).
*/

/* Q3. Syntax */
IF OBJECT_ID('dbo.Position', 'U') IS NOT NULL DROP TABLE dbo.Position;
create table dbo.Position
(
 PositionID INT IDENTITY PRIMARY KEY,
 Title VARCHAR(100)
);

INSERT INTO dbo.Position(Title) (select distinct PositionTitle from dbo.ChicagoSalary);






/* Run the following query to populate a Employment table to help build the relationship between the above three tables. */

/*
IF OBJECT_ID('dbo.Employment','U') IS NOT NULL DROP TABLE dbo.Employment;

SELECT IDENTITY(INT,1,1)  EmploymentID
		, EmployeeID
		, PositionID
		, DepartmentID
 INTO dbo.Employment
FROM dbo.ChicagoSalary CS
INNER JOIN dbo.Employee E on CS.Name = E.Name and CS.Salary = E.Salary 
INNER JOIN dbo.Position P on P.Title = CS.PositionTitle  
INNER JOIN dbo.Department D on D.Name = CS.Department;
*/

--You should get 32,432 if you do not, your above queries are probably incorrect (check for duplicates, non unique records)

/* 
Q4. Display the same output as the dbo.ChicagoSalary table but use the new 4 tables you created.
*/

/* Q4. Syntax*/

select 
	a.Name as 'Name', 
	b.Title as 'PositionTitle', 
	c.Name as 'Department', 
	a.Salary as 'Salary'
from
	dbo.Employee a
	inner join
	dbo.Employment d
	on a.EmployeeID = d.EmployeeID
	inner join
	dbo.Position b
	on b.PositionID=d.PositionID
	inner join
	dbo.Department c
	on c.DepartmentID=d.DepartmentID
;
	






/* 
Q5. Using the new tables and JOINs to display Number of Employees and Average Salary in the Police department.
*/

/*Q5. Syntax*/

select 
	COUNT(a.employeeID) as 'Number of Employees', 
	AVG(a.salary) as 'Average Salary'
from
	dbo.Employee a
inner join
	dbo.Employment b
on
	a.EmployeeID=b.EmployeeID
inner join
	dbo.Department c
on
	b.DepartmentID = c.DepartmentID
where
	c.Name= 'POLICE'
;
 




/* 
Q6. Using the new tables and JOINs to provide the Number of Employees and Total Salary of Each Department.
	Sort the output by Department A->Z.
*/

/*Q6. Syntax*/
select
	c.Name as 'Department Name', 
	COUNT(a.employeeID) as 'Number of Employees', 
	SUM(a.salary) as 'Total Salary'
from
	dbo.Employee a
inner join
	dbo.Employment b
on
	a.EmployeeID=b.EmployeeID
inner join
	dbo.Department c
on
	b.DepartmentID = c.DepartmentID
group by c.Name
order by c.Name asc;



/*Q6. Answer:
Number of Employees=
Average Salary= 
*/


/* 
Q7.Using the new table(s) and subqueries to list the name(s) and salary of employee(s) whose last name is Aaron and work for the POLICE department. 
*/ 

/*Q7. Syntax*/
select 
	a.Name,
	a.Salary
from
	dbo.Employee a
inner join
	dbo.Employment b
on
	a.EmployeeID=b.EmployeeID
inner join
	dbo.Department c
on
	c.DepartmentID=b.DepartmentID
where
	a.Name like 'Aaron%'
and
	c.Name like '%Police%'
;


/*Q7. Answer:
Name= AARON,  JEFFERY M
Salary= 75372.0000
*/

 

/* Q8. Display the name(s) of the people who have the longest name(s) 
*/

/* Q8. Syntax */
select name from dbo.Employee where len(name) = (select max(len(name)) from dbo.Employee);


/* Q8.Answer: 
CLEMONS SAMS,  MICHAEL ANTHONY C
WRZESNIEWSKA KOZAK,  ANNABELLA M
*/


					 
/*
Bonus Q9. You may share any challenge(s) you face while finishing the assignment and how you overcome the challenge.
*/

/* Q9.Answer: 
Challenges were faced in:
1. Understanding how to use only subqueries and new tables in question 7 in part (b)
2. Understanding how to join the new tables . This challenge was solved by understanding how to use Employment table to join multiple new tables
3. In Question 5, understanding if 'Police Board' falls in 'Police' department.
*/
