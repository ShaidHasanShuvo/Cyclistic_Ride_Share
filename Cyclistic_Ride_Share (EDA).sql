-- Exploring the data set
select *
From Cyclistic_bikeshare.dbo.Cyclistic_dataset

-- deleting null values as age or gender column's null items...
select *
From Cyclistic_bikeshare.dbo.Cyclistic_dataset
where trip_id is null or usertype is null or to_station_name is null or from_station_id is null or from_station_name is null or gender is null or birthyear is null 

-- (Good practice 01) It is a good practice to select and see every row or column before deleting them....
delete
From Cyclistic_bikeshare.dbo.Cyclistic_dataset
where trip_id is null or usertype is null or to_station_name is null or from_station_id is null or from_station_name is null or gender is null or birthyear is null 

-- Removing duplicate values
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY trip_id ORDER BY trip_id) AS RowNum
    FROM Cyclistic_bikeshare.dbo.Cyclistic_dataset
)
--(Good practice 01)
--select *
--FROM CTE WHERE RowNum > 1;
delete
FROM CTE WHERE RowNum > 1;

-- Formating and transforming Date time  
SELECT 
    CAST(start_time AS DATE) AS start_date
FROM 
    Cyclistic_bikeshare.dbo.Cyclistic_dataset;

SELECT 
    CAST(start_time AS TIME) AS start_time
FROM 
    Cyclistic_bikeshare.dbo.Cyclistic_dataset;

-- Add new columns for date and time components
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD startdate Date ,
    starttime Time;

-- Populate the new columns
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET startdate = CAST(start_time AS DATE),
    starttime = CAST(start_time AS TIME);

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD enddate Date ,
    endtime Time;

-- Populate the new columns
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET enddate = CAST(end_time AS DATE),
    endtime = CAST(end_time AS TIME);

-- Calculating age from birth year
select birthyear, (2020 - birthyear) as age
from Cyclistic_bikeshare.dbo.Cyclistic_dataset

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
DROP COLUMN age;

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD age int

UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET age = 2020 - birthyear  -- As the data set stores data of 2019

--Day type (weekday or weekend)
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD daytype varchar(50)
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET  daytype = CASE 
		WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END 
FROM 
    Cyclistic_bikeshare.dbo.Cyclistic_dataset;

-- age group 
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD agegroup varchar(50)
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET agegroup = CASE
        WHEN age <= 18 THEN '0-18'
        WHEN age <= 30 THEN '19-30'
        WHEN age <= 45 THEN '31-45'
        WHEN age <= 60 THEN '46-60'
        WHEN age <= 70 THEN '60-70'
        ELSE '71+'
    END

-- trip Route 
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
DROP COLUMN trip_route;

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD trip_route varchar(255)

UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET trip_route = CONCAT(from_station_name, ' to ', to_station_name)

-- Trip start hour for peak hour

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD trip_hour int
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
DROP COLUMN trip_route;
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET trip_hour = DATEPART(HOUR, starttime)

-- Minute Range for trip timeline

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD trip_minute int

UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET trip_minute = DATEPART(MINUTE, starttime)

ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD minute_range varchar(255)
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET minute_range = CASE 
        WHEN trip_minute BETWEEN 0 AND 10 THEN '0-10'
        WHEN trip_minute BETWEEN 11 AND 20 THEN '11-20'
        WHEN trip_minute BETWEEN 21 AND 30 THEN '21-30'
        WHEN trip_minute BETWEEN 31 AND 40 THEN '31-40'
        WHEN trip_minute BETWEEN 41 AND 50 THEN '41-50'
        WHEN trip_minute BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Invalid Range'
	END

-- trip_length
ALTER TABLE Cyclistic_bikeshare.dbo.Cyclistic_dataset
ADD trip_length_minute int
UPDATE Cyclistic_bikeshare.dbo.Cyclistic_dataset
SET trip_length_minute = DATEDIFF(MINUTE, start_time, end_time)

--Final data set for export
select trip_id, startdate, enddate, bikeid, from_station_id, 
	from_station_name, to_station_id, to_station_name, usertype, gender, daytype, agegroup, trip_route, trip_hour, minute_range, trip_length_minute, trip_timeline
From Cyclistic_bikeshare.dbo.Cyclistic_dataset

 
                                 --------- Conducting EDA --------

select distinct to_station_id
from Cyclistic_bikeshare.dbo.Cyclistic_dataset 
order by to_station_id

select distinct from_station_id
from Cyclistic_bikeshare.dbo.Cyclistic_dataset 
order by from_station_id



-- stations generate most trips
select from_station_id, usertype, COUNT(from_station_id) as total_trip_generated
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by from_station_id, usertype
having usertype = 'Customer'
order by COUNT(from_station_id) desc

-- stations attract most trips
select to_station_id, usertype, COUNT(to_station_id) as total_trip_attracted
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by to_station_id, usertype
having usertype = 'Customer'
order by COUNT(to_station_id) desc


-- trips vs daytype vs usertype
select daytype, usertype, COUNT(trip_id) as trip
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by daytype, usertype
order by COUNT(trip_id) desc

-- date vs trips vs daytype vs usertype
select startdate, usertype, count(trip_id) as trips, daytype
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by startdate, usertype, daytype
having usertype = 'Customer'
order by trips desc, startdate

-- age vs trips
select age, COUNT(trip_id) as trip
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by age
order by COUNT(trip_id) desc

-- looking for aged users
select age, COUNT(trip_id) as trips
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by age
having age > 60
order by trips desc

-- age group vs trips
select agegroup, usertype, COUNT(trip_id) as trips
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by agegroup, usertype
order by COUNT(trip_id) desc

-- Time vs trips vs usertype
select starttime, usertype, COUNT(trip_id) as trips
from Cyclistic_bikeshare.dbo.Cyclistic_dataset 
group by starttime, usertype
Having usertype = 'Customer'
order by COUNT(trip_id) desc

-- fav trip route for customers

SELECT trip_route, usertype, COUNT(trip_id) as trips
from Cyclistic_bikeshare.dbo.Cyclistic_dataset
group by trip_route, usertype
having usertype = 'Customer'
order by COUNT(trip_id) desc

-- Peak hour for trip vs usertype
SELECT trip_hour, usertype, COUNT(trip_id) as trips
FROM Cyclistic_bikeshare.dbo.Cyclistic_dataset
Group by trip_hour, usertype
Having usertype = 'Customer'
Order by COUNT(trip_id) desc

-- Trip_hour vs minute_range
SELECT trip_hour, minute_range, COUNT(trip_id) as trips
FROM 
    Cyclistic_bikeshare.dbo.Cyclistic_dataset
Group by trip_hour, minute_range
Order by COUNT(trip_id) desc;

-- trip_length_minute vs usertype
SELECT trip_length_minute, usertype, COUNT(trip_id) as trips
FROM 
    Cyclistic_bikeshare.dbo.Cyclistic_dataset
Group by trip_length_minute, usertype
Having trip_length_minute > 500
Order by trip_length_minute desc;
