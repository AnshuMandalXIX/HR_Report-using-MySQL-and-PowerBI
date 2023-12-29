/*
Sql Queries Performed over the Raw Data to get desired tables for forcasting 
*/

-- create database
CREATE DATABASE hr

use hr

-- explore the loaded data into hr_data
SELECT * FROM hr_data;

-- explore table structure
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'hr_data';


-- Fix column "termdate" formatting, format termdate datetime UTC values, Update date/time to date
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');


-- Update from nvachar to date
-- First, add a new date column
ALTER TABLE hr_data
ADD new_termdate DATE;

-- Update the new date column with the converted values
UPDATE hr_data
SET new_termdate = CASE
    WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1
        THEN CAST(termdate AS DATETIME)
        ELSE NULL
    END;


SELECT new_termdate
FROM hr_data
ORDER BY new_termdate desc;

-- create new column "age"
ALTER TABLE hr_data
ADD age nvarchar(50)

-- populate new column with age
UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT birthdate, age
FROM hr_data
ORDER BY age;

-- min and max ages
SELECT 
 MIN(age) AS min_age, 
 MAX(AGE) AS max_age
FROM hr_data;

-- QUESTIONS TO ANSWER FROM THE DATA

-- 1)Age Group Distribution by gender

SELECT
  age_group,
  gender,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age <= 21 AND age <= 30 THEN '21 to 30'
      WHEN age <= 31 AND age <= 40 THEN '31 to 40'
      WHEN age <= 41 AND age <= 50 THEN '41-50'
      ELSE '50+'
    END AS age_group,
	gender
  FROM hr_data
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 2) What is the Average tenure distribution for each department?

SELECT 
    department,
    AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM 
    hr_data
WHERE 
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY 
    department;

-- 3) How does gender vary across departments ?

SELECT department, gender, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- 4)What's the race distribution in the company?
SELECT race,
 COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;


-- 5) How many employees work remotely for each department?
SELECT
 location,
 count(*) AS count
 FROM hr_data
 WHERE new_termdate IS NULL
 GROUP BY location;

-- 6) What's the distribution of employees across different states?
SELECT
location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;