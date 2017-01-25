create database exam;

USE exam;


/* 19 */
IF OBJECT_ID('dbo.WineRating', 'U') IS NOT NULL DROP TABLE dbo.WineRating;
CREATE TABLE 
	dbo.WineRating 
(
	WineID INT IDENTITY PRIMARY KEY,
	Wine NVARCHAR(255),
	Type NVARCHAR(255),
	Variety NVARCHAR(255),
	Cost MONEY,
	Review NVARCHAR(255),
	Rating FLOAT,
	Store NVARCHAR(255),
	ReviewDate DATETIME
)
;

INSERT INTO 
	dbo.WineRating(Wine, [Type], Variety, Cost, Review, Rating, Store, ReviewDate)
SELECT *
FROM 
	dbo.ImportWineRating
;



/* 20 */
UPDATE 
	dbo.WineRating
SET 
	Rating=7.5
WHERE 
	Rating IS NULL
;



/* 21 */
SELECT 
	Wine AS Name, 
	Variety, 
	Cost, 
	Rating
FROM
	dbo.WineRating
WHERE
	[Type]= 'Red'
	AND
	Store = 'Costco'
ORDER BY 
	Cost
;



/* 22 */
SELECT
	TOP 1 Store, 
	COUNT(DISTINCT(Variety)) as 'Number of Varieties'
FROM
	dbo.WineRating
GROUP BY 
	Store
ORDER BY 
	COUNT(Variety) DESC
;



/* 23 */
SELECT 
	CONVERT(VARCHAR(MAX), MIN(Cost)) + ' - ' + CONVERT(VARCHAR(MAX), MAX(Cost)) as 'Price Range for wines produced in 2011'
FROM 
	dbo.WineRating
WHERE 
	LEFT(Wine, 4) = '2011'
;



/* 24 */
SELECT
	[Type],
	AVG(Rating) AS 'Average Rating',
	AVG(Cost) AS 'Average Cost'
FROM
	dbo.WineRating
GROUP BY 
	[Type]
HAVING 
	AVG(Rating)>7.2
ORDER BY 
	AVG(Cost) DESC
;



/* 25 */
SELECT
	[Type],
	COUNT(Wine) AS 'Number of Wines',
	AVG(Rating) AS 'Average Rating'
FROM
	dbo.WineRating
GROUP BY 
	[Type]
ORDER BY 
	[Type], AVG(Rating) DESC;
;



/* 26 */
SELECT 
	Wine, 
	Rating
FROM
	dbo.WineRating
WHERE
	Rating = (SELECT MAX(Rating) from dbo.WineRating WHERE [TYPE]='White')
	AND
	[Type]= 'White'
;



/* 27 */
SELECT
	CONCAT(WineID, ' - ', Wine, ': Type: ', Type, ' / ', Variety, ' - Price $', Cost, '- Recommended Buy') AS 'Wine details'
FROM
	dbo.WineRating
WHERE 
	[Type]='Red'
	AND
	Review <> 'Skip It';
;	



/* 28 */
IF OBJECT_ID('dbo.Type', 'U') IS NOT NULL DROP TABLE dbo.Type;
CREATE TABLE dbo.Type 
(
	TypeID INT IDENTITY PRIMARY KEY,
	Type NVARCHAR(255)
)
;

INSERT INTO 
	dbo.Type([Type])
SELECT
	DISTINCT([Type])
FROM
	dbo.WineRating
;


IF OBJECT_ID('dbo.Variety', 'U') IS NOT NULL DROP TABLE dbo.Variety;
CREATE TABLE dbo.Variety 
(
	VarietyID INT IDENTITY PRIMARY KEY,
	Variety NVARCHAR(255)
)
;

INSERT INTO 
	dbo.Variety(Variety)
SELECT
	DISTINCT(Variety)
FROM
	dbo.WineRating
;


IF OBJECT_ID('dbo.Store', 'U') IS NOT NULL DROP TABLE dbo.Store;
CREATE TABLE dbo.Store 
(
	StoreID INT IDENTITY PRIMARY KEY,
	Store NVARCHAR(255)
)
;

INSERT INTO 
	dbo.Store(Store)
SELECT
	DISTINCT(Store)
FROM
	dbo.WineRating
;


IF OBJECT_ID('dbo.Wine', 'U') IS NOT NULL DROP TABLE dbo.Wine;
CREATE TABLE dbo.Wine 
(
	WineID INT PRIMARY KEY,
	TypeID INT,
	VarietyID INT,
	StoreID INT,
	Wine NVARCHAR(255),
	Cost MONEY,
	Review NVARCHAR(255),
	Rating FLOAT,
	ReviewDate DATETIME
)
;

INSERT INTO
	dbo.Wine
SELECT 
	WineID, TypeID, VarietyID, StoreID, Wine, Cost, Review, Rating, ReviewDate
FROM
	dbo.WineRating a
INNER JOIN
	dbo.Type b
ON
	a.[Type] = b.[Type]
INNER JOIN
	dbo.Variety c
ON
	a.Variety = c.Variety
INNER JOIN
	dbo.Store d
ON
	a.Store = d.Store
;



/* 29 */
SELECT
	WineID,
	Wine,
	[Type], 
	Variety,
	Cost,
	Review,
	Rating,
	Store,
	ReviewDate
FROM
	dbo.Wine a
INNER JOIN
	dbo.Type b
ON
	a.TypeID = b.TypeID
INNER JOIN
	dbo.Variety c
ON
	a.VarietyID = c.VarietyID
INNER JOIN
	dbo.Store d
ON
	a.StoreID = d.StoreID
;



/* 30 */
select
	Wine AS 'Name',
	[Type] AS 'Type',
	Rating As 'Rating'
FROM
	dbo.Wine a
INNER JOIN
	dbo.[Type] b
ON
	a.TypeID = b.TypeID
WHERE 
	a.Cost<7
;



/* 31 */
select
	Store,
	COUNT(DISTINCT(WineID)) AS 'Number of Wines',
	COUNT(DISTINCT(VarietyID)) AS 'Number of Varieties'
FROM
	dbo.Wine a
INNER JOIN
	dbo.Store b
ON
	a.StoreID = b.StoreID
GROUP BY 
	Store
;



/* 32 */
select
	LEFT(LTRIM(Variety), 1) AS 'First Letter of Variety',
	COUNT(DISTINCT(WineID)) AS 'Number of Wines',
	CAST(AVG(Rating) AS DECIMAL(3,2)) AS 'Average Rating'
FROM
	dbo.Wine a
INNER JOIN
	dbo.Variety b
ON
	a.VarietyID = b.VarietyID	
GROUP BY 
	LEFT(LTRIM(Variety), 1)
ORDER BY 
	LEFT(LTRIM(Variety), 1)
;



/* 33 */
SELECT
	[Type]
FROM
	dbo.Wine a
INNER JOIN
	dbo.Type b
ON
	a.TypeID= b.TypeID
GROUP BY 
	[Type]
HAVING
	AVG(Rating) > (select AVG(Rating) from dbo.Wine)
;
	

/* 34 */
SELECT 
	Cost_Bucket, 
	AVG(Cost)  AS 'Average_Cost', 
	AVG(Rating) AS 'Average_Rating'
FROM
(
SELECT
	CASE
		WHEN Cost<5.00 THEN '01. Lower than $5'
		WHEN Cost>=5.00 AND Cost<=9.99 THEN '02. Between $5-$10'
		WHEN Cost>=10.00 THEN '03. Higher than $10'
	END AS 'Cost_Bucket',
	Cost,
	Rating
FROM
	dbo.Wine
) AS A
GROUP BY 
	Cost_Bucket
ORDER BY 
	Cost_Bucket
;



/* Bonus */

SELECT 
	'J Gumbo''s' AS 'My favorite restaurant',
	'White Chili' AS 'My favorite dish from there'
;

SELECT 'Puran Poli' AS 'My favorite dish that my family makes'
;



