###Question 1     
####Using HDFS:     
####PUT 3 files (train.tsv, test.tsv, titanic_master.tsv) into HDFS under /user/hue directory ( *.tsv files under /STAGING/TITANIC/ )     


--Import test table from mysql into HDFS as tsv       
sqoop import --connect jdbc:mysql://localhost:3306/test --table test --target-dir /user/hue/titanic -m 1 --fields-terminated-by '\t' --driver com.mysql.jdbc.Driver;       

-- Change superuser for hdfs        
su - hdfs        
chmod 777 /staging/titanic           
hdfs dfs -get /user/hue/titanic/part-m-00000 /staging/titanic/test.tsv        

-- Code to Transfer from LFS to HDFS        
hdfs dfs -put /staging/titanic/test.tsv /user/hue/test.tsv        
hdfs dfs -put /staging/titanic/train.tsv /user/hue/train.tsv        
hdfs dfs -put /staging/titanic/titanic_master.tsv /user/hue/titanic_master.tsv        

-- Confirm whether the file is transferred       
hdfs dfs -ls /user/hue        

--Confirm HDFS files are populated        

hdfs dfs -cat /user/hue/train.tsv      
hdfs dfs -cat /user/hue/test.tsv        
hdfs dfs -cat /user/hue/titanic_master.tsv      


###Question 2     
####Using Hive:     
####Create 2 tables (TRAIN, TEST) and confirm can query. Using Cube, find passenger counts who Survived based on 'pclass' in TRAIN table.       
####Also query to find how many boys under 16 years younger Survived       

--Created database     
create database hackathon;     
use hackathon;     


-- drop tables if they are already present     
DROP table train; DROP table test; DROP table titanic_master;     

--create table train     
CREATE TABLE train     
(passengerid INT, survived INT, pclass INT, name STRING, sex STRING, age INT, sibsp INT, parch INT, ticket INT, fare DECIMAL(7,4), cabin STRING,embarked STRING)     
ROW format delimited fields terminated by '\t'     
tblproperties("skip.header.line.count"="1");     
--Load data     
LOAD data LOCAL inpath '/staging/titanic/train.tsv' overwrite into table train;     

describe train;     

--create table test     
CREATE TABLE test     
(passengerid INT, survived INT, pclass INT, name STRING, sex STRING, age INT, sibsp INT, parch INT, ticket INT, fare DECIMAL(7,4), cabin STRING,embarked STRING)     
ROW format delimited fields terminated by '\t'     
tblproperties("skip.header.line.count"="1");     
--Load data     
LOAD data LOCAL inpath '/staging/titanic/test.tsv' overwrite into table test;     

describe test;     


--create table titanic_master     
CREATE TABLE titanic_master     
(passengerid INT, survived INT, pclass INT, name STRING, sex STRING, age INT, sibsp INT, parch INT, ticket INT, fare DECIMAL(7,4), cabin STRING,embarked STRING)     
ROW format delimited fields terminated by '\t'     
tblproperties("skip.header.line.count"="1");     
describe titanic_master;     

--Load data     
LOAD data LOCAL inpath '/staging/titanic/titanic_master.tsv' overwrite into table titanic_master;     


--- From Hive, query all 3 tables and confirm have the correct row count     
SELECT * from train; --891 rows     
SELECT * from test; -- 418 rows     
SELECT * from titanic_master; --1309 rows     


--- From TRAIN, use CUBE to find passenger counts      
SELECT survived, pclass, COUNT(passengerid) as Count     
FROM train     
GROUP BY survived, pclass with CUBE     
ORDER BY survived, pclass;     

--. Masters table     
--This threw different counts than expected     
---SELECT survived, COUNT(passengerid) as Count     
---FROM train     
---WHERE age < 16 and sex = 'male'     
---GROUP BY survived      
---ORDER BY survived;     


SELECT survived, COUNT(passengerid) as Count FROM train     
WHERE name like '%Master%'     
GROUP BY survived      
ORDER BY survived;     
      


###Question 3:     
####Using Spark:     
####Create a Temporary Table and query to find the counts of how many Males and Females were in the TITANIC_MASTER table     

pyspark     
sqlContext.sql('hackathon')     

masterDF = sqlContext.table("titanic_master")     

masterDF.show()     

masterDF.registerTempTable("master_temp")     
sqlContext.sql('show tables').show()     

sqlContext.sql('select sex, count(passengerid) from master_temp group by sex').show()     

###Question 4:     
####Using Presto:        
####Who paid more than 250 pounds for their 'fare'?     
####Which 'embarked' location had the most passengers?     

--go to the presto folder     
cd /usr/lib/presto/bin     

--logon to presto     
/presto-cli-0.127-executable.jar --server localhost:8081     

--select database, change default to name     
use hive.hackathon;     

show tables;     
--type q to return to prompt     

--query     
SELECT name,fare from titanic_master WHERE fare > cast(250 as decimal(7,4));     

SELECT embarked, count(passengerid) as Count     
FROM titanic_master     
GROUP BY embarked;     


###Question 5     
####Using Pig: (Extra Credit)     
####Create 2 tables (TRAIN, TEST) and confirm can query. Using Group By, find passenger counts who survived based on 'pclass' in TRAIN table     
####Did Captain go down with the ship?     

pig -x tez     

copyFromLocal /staging/titanic/train.tsv /user/pig/     

train = load '/user/pig/train.tsv' as     
(passengerid: int, survived: int, pclass: int,     
name: chararray, sex: chararray, age: int, sibsp: int, parch: int, ticket: int, fare: float, cabin: chararray,embarked: chararray);     

dump train;     

b= group train by (survived, pclass);;     
SurvivedByClass = foreach b generate group as grp, COUNT(train.passengerid);     
dump SurvivedByClass;     


f = FILTER train BY  (name matches '.*Capt.*.');     
DUMP f;     
