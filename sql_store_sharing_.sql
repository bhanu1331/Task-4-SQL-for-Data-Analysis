CREATE DATABASE bike_rental;
USE bike_rental;

-- Original table
CREATE TABLE bike_rides (
    timestamp DATETIME,
    count INT,
    t1 FLOAT,
    t2 FLOAT,
    hum FLOAT,
    wind_speed FLOAT,
    weather_code INT,
    is_holiday INT,
    is_weekend INT,
    season INT
);
DROP TABLE IF EXISTS bike_rides_new;
-- New table with renamed columns
CREATE TABLE bike_rides_new AS
SELECT 
    timestamp AS ride_date,
    count AS ride_count,
    t1 AS temp_1,
    t2 AS temp_2,
    hum AS humidity,
    wind_speed AS wind,
    weather_code AS weather,
    is_holiday AS holiday_flag,
    is_weekend AS weekend_flag,
    season AS season_number
FROM bike_rides;




-- Use new table for all queries
SELECT * FROM bike_rides_new;
-- Rides with count > 1000
SELECT ride_date, ride_count
FROM bike_rides_new
WHERE ride_count > 1000
ORDER BY ride_count DESC;

-- Peak wind speed days
SELECT ride_date, wind, ride_count
FROM bike_rides_new
ORDER BY wind DESC
LIMIT 10;

-- Total rides (season_number only has 3, so one row)
SELECT DISTINCT season_number FROM bike_rides_new;
SELECT season_number, SUM(ride_count) AS total_rides
FROM bike_rides_new
GROUP BY season_number;

EXPLAIN SELECT season_number, SUM(ride_count) AS total_rides
FROM bike_rides_new
GROUP BY season_number;


-- Average rides on weekends vs weekdays
SELECT weekend_flag, AVG(ride_count) AS avg_rides
FROM bike_rides_new
GROUP BY weekend_flag;

-- Maximum, minimum, and average temperature
SELECT MAX(temp_1) AS max_temp, MIN(temp_1) AS min_temp, AVG(temp_1) AS avg_temp
FROM bike_rides_new;

-- Total rides per weather type
SELECT weather, SUM(ride_count) AS total_rides
FROM bike_rides_new
GROUP BY weather
ORDER BY total_rides DESC;

-- Average rides on holidays vs non-holidays
SELECT holiday_flag, AVG(ride_count) AS avg_rides
FROM bike_rides_new
GROUP BY holiday_flag;

-- Days with ride count higher than average
SELECT ride_date, ride_count
FROM bike_rides_new
WHERE ride_count > (
    SELECT AVG(ride_count) FROM bike_rides_new
);

-- Season with highest total rides
-- Only season 3 exists, so result will always be 3
DROP VIEW IF EXISTS monthly_summary;
CREATE VIEW monthly_summary AS
SELECT DATE_FORMAT(ride_date, '%Y-%m') AS month,
       SUM(ride_count) AS total_rides,
       AVG(temp_1) AS avg_temp,
       AVG(humidity) AS avg_humidity
FROM bike_rides_new
GROUP BY DATE_FORMAT(ride_date, '%Y-%m');
-- Query the view
SELECT * FROM monthly_summary ORDER BY month;

CREATE INDEX idx_ride_date ON bike_rides_new(ride_date);
CREATE INDEX idx_season_number ON bike_rides_new(season_number);

