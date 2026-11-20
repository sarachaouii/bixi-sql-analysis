-- 1. First 10 rows, all columns
SELECT * 
FROM bixi_trips_raw
limit 10;

-- 2. ONLY the start station name & borough, 20 rows
SELECT startstationname, startstationarrondissement   
FROM bixi_trips_raw
limit 20;

-- 3. Trips starting in Ville-Marie
SELECT startstationarrondissement, startstationname
FROM bixi_trips_raw
where startstationarrondissement  = 'Ville-Marie'
limit 10; 

-- 4. Trips starting in Le Plateau-Mont-Royal
SELECT startstationarrondissement, startstationname, endstationname    
FROM bixi_trips_raw
where startstationarrondissement  = 'Le Plateau-Mont-Royal'
limit 10;

-- 5. Trips that did not start in Ville-Marie
SELECT startstationarrondissement, startstationname
FROM bixi_trips_raw
where startstationarrondissement != 'Ville-Marie'
limit 10;

-- 6. Trips with no end station (IS NULL)
SELECT startstationname
FROM bixi_trips_raw
where endstationname is null 
limit 10;

-- 7. Trips that have an end station (IS NOT NULL)
SELECT startstationname
FROM bixi_trips_raw
where endstationname is not null 
limit 10;

-- 8. Trips starting and ending in the same borough
SELECT startstationname
FROM bixi_trips_raw
where startstationarrondissement = endstationarrondissement 
limit 10;

-- 9. Round trips: the start station equals the end station
SELECT startstationname
FROM bixi_trips_raw
where startstationname  = endstationname 
limit 10;

-- 10. Start stations whose name contains “Métro” (LIKE)
SELECT DISTINCT startstationname
FROM bixi_trips_raw
where startstationname like '%Métro%';

-- 11. Trips starting north of latitude 45.55
SELECT startstationname
FROM bixi_trips_raw
where startstationlatitude > 45.55
limit 10;

-- 12. Trips with a start longitude BETWEEN -73.60 and -73.55
SELECT startstationname
FROM bixi_trips_raw
where startstationlongitude between -73.60 and -73.55
limit 10;

-- 13. Trips starting in Ville-Marie or Le Plateau-Mont-Royal (use IN)
SELECT startstationname
FROM bixi_trips_raw
where startstationarrondissement in ('Ville-Marie', 'Le Plateau-Mont-Royal')
limit 10;

-- 14. The list of all distinct start boroughs
SELECT distinct startstationarrondissement 
FROM bixi_trips_raw;

-- 15. All distinct start station names, sorted A to Z
SELECT distinct startstationname  
FROM bixi_trips_raw
order by startstationname ASC;

-- 16. The 10 earliest trips of the year
SELECT startstationname , starttimems
FROM bixi_trips_raw
order by starttimems ASC
limit 10;

-- 17. The 10 latest trips of the year
SELECT startstationname, starttimems 
FROM bixi_trips_raw
order by starttimems DESC
limit 10;

-- 18. The northernmost start station
SELECT startstationname, startstationlatitude
FROM bixi_trips_raw
order by startstationlatitude desc 
limit 1;

-- 19. Stretch: the 10 longest trips, where duration = endtimems - starttimems
-- I noticed that the result is weird, because the data says 6187 hrs (once converted) is the longest bike ride which is 258 days, which is impossible, although the query is correct, so this means there is a data quality issue. 
SELECT startstationname, (endtimems - starttimems ) as duration   
FROM bixi_trips_raw
where endtimems is not null
and starttimems is not null 
order by duration desc 
limit 10;

-- 20. Stretch: trips shorter than one minute (60,000 ms)
-- My query is correct, however real data comes from machines, and they make errors, so there could be a case where an endtime is earlier than a starttime, so we need to add a where endtime is greater than starttime:
SELECT startstationname, round((endtimems - starttimems)/60000.0, 1) as duration_min
FROM bixi_trips_raw
where endtimems is not null
and starttimems is not null 
and ((endtimems - starttimems)/60000.0) <1
and starttimems < endtimems
limit 10;

-- Day 2: aggregations

-- 1. Number of trips per start borough, from most to least
SELECT btr.startstationarrondissement, count (*) as total_trips
from bixi_trips_raw btr
group by btr.startstationarrondissement
order by total_trips DESC;

-- 2.The 10 busiest start stations 
select btr.startstationname, count(*) as trips
from bixi_trips_raw btr 
group by btr.startstationname 
order by trips desc
limit 10; 

-- 3. Number of trips per hour of the day (0–23), in hour order
select EXTRACT(HOUR FROM (to_timestamp(btr.starttimems / 1000.0) AT TIME ZONE 'America/Toronto')) AS hour, count(*) as trips
	from bixi_trips_raw btr 
	group by hour
	order by hour ASC;  

-- 4. Number of trips per day of the week, Montreal time (0 = Sunday … 6 = Saturday)

SELECT EXTRACT(DOW FROM (TO_TIMESTAMP(starttimems / 1000.0)AT TIME ZONE 'America/Toronto')) AS day_of_week, count (*) AS trips
from bixi_trips_raw btr
group by day_of_week 
order by day_of_week;

-- 5.Average trip duration in minutes per start borough, showing only boroughs with more than 100,000 trips (use HAVING)
-- Assumptions:
--   - Trips with a missing start or end time are excluded (duration unknown)
--   - Durations of 0 or less are recording errors and are excluded
--   - Trips over 3 hours are excluded: 0.2% of trips, mostly undocked bikes so simply errors
--   - total_trips therefore counts valid trips only (slightly below the real total)

SELECT startstationarrondissement,
       COUNT(*) AS total_trips,
       ROUND(AVG((endtimems - starttimems) / 60000.0), 2) AS avg_duration_minutes
FROM bixi_trips_raw
WHERE starttimems IS NOT NULL
  AND endtimems IS NOT NULL
  AND endtimems > starttimems
  AND endtimems - starttimems < 10800000    --this number represents 3 hours in milliseconds
GROUP BY startstationarrondissement
HAVING COUNT(*) > 100000
ORDER BY avg_duration_minutes DESC;

-- 6. count the trips with no end station, per borough. 
SELECT btr.startstationarrondissement, count (*) as total_trips
from bixi_trips_raw btr
where btr.endstationname is null
group by btr.startstationarrondissement 
order by total_trips DESC;


