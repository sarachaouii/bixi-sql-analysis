-- 1. Firsr 10 rows, all columns
SELECT * 
FROM bixi_trips_raw
limit 10;

-- 2. ONLY the start station name & borough, Only the start station name and borough, 20 rows
SELECT startstationname, startstationarrondissement   
FROM bixi_trips_raw
limit 20;

-- 3. Trips starting in Ville-Marie
SELECT startstationarrondissement  
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
SELECT startstationname
FROM bixi_trips_raw
where startstationname like '%Métro%'
limit 10;

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
FROM bixi_trips_raw
limit 10;

-- 15. All distinct start station names, sorted A to Z
SELECT distinct startstationname  
FROM bixi_trips_raw
order by startstationname ASC
limit 10;

-- 16. The 10 earliest trips of the year
SELECT startstationname  
FROM bixi_trips_raw
order by starttimems ASC
limit 10;

-- 17. The 10 latest trips of the year
SELECT startstationname  
FROM bixi_trips_raw
order by starttimems DESC
limit 10;

-- 18. The northernmost start station
SELECT startstationname  
FROM bixi_trips_raw
order by startstationlatitude desc 
limit 1;

-- 19. Stretch: the 10 longest trips, where duration = endtimems - starttimems
SELECT startstationname, (endtimems - starttimems ) as duration   
FROM bixi_trips_raw
where endtimems is not null
and starttimems is not null 
order by duration desc 
limit 10;

-- 20. Stretch: trips shorter than one minute (60,000 ms)
SELECT startstationname, (endtimems - starttimems ) as duration   
FROM bixi_trips_raw
where endtimems is not null
and starttimems is not null 
and (endtimems - starttimems) < 60000
limit 10;

