### Clara Richter
### HW-4 (ANLY-640)

# remove first row from table because has headers
# DELETE FROM al_perf LIMIT 1;

#### 1) Find maximal departure delay in minutes for each airline. 
# Sort results from smallest to largest maximum delay. 
# Output airline names and values of the delay.

select Reporting_Airline as "Airline", max(DepDelayMinutes) as max_delay
from al_perf
where DepDelayMinutes <> 0
group by Reporting_Airline
order by max_delay;
-- 16 row(s) returned


#### 2) Find maximal early departures in minutes for each airline. 
# Sort results from largest to smallest. Output airline names.

select Reporting_Airline as "Airline", max(min_early) as max_early
from (select Reporting_Airline, DepDelay*-1 as min_early 
from al_perf) as dep_early
group by Reporting_Airline
order by max_early desc;
-- 16 rows returned


#### 3)Rank days of the week by the number of flights performed by all airlines 
# on that day (1 is the busiest). Output the day of the week names, 
# number of flights and ranks in the rank increasing order.

select WEEKDAYS.Day, count(al_perf.Flights) as "Number of Flights", 
rank() over (order by (count(al_perf.Flights)) desc) as flights_rank 
from al_perf, WEEKDAYS
where WEEKDAYS.code = al_perf.DayOfWeek
group by WEEKDAYS.Day;
-- 7 row(s) returned


#### 4) Find the airport that has the highest average departure delay among all airports. 
# Consider 0 minutes delay for flights that departed early. 
# Output one line of results: the airport name, code, and average delay.

# Including flights with 0 minute delays:
select Airport_Name as "Airport Name", 
Airport_Code as "Code",
max(maxDepDelay.avg_DepDelay) as "Average Delay (min)"
from (select Substring(Name, locate(': ', Name) + 1, length(Name)) as Airport_Name, 
Origin as Airport_Code, 
avg(DepDelayMinutes) as avg_DepDelay
      from al_perf, AIRPORT
      where AIRPORT.Code = al_perf.Origin
      group by Origin
      order by avg_DepDelay desc
      ) as maxDepDelay;
-- 1 row returned


#### If I were to not include flights with 0 minute delays,
# because those are for flights that departed early 
# and I am just looking at flights that had delayed departures, 
# I would run this query:
select Airport_Name as "Airport Name", 
Airport_Code as "Code",
max(maxDepDelay.avg_DepDelay) as "Average Delay (min)"
from (select Substring(Name, locate(': ', Name) + 1, length(Name)) as Airport_Name, 
Origin as Airport_Code, 
avg(DepDelayMinutes) as avg_DepDelay
      from al_perf, AIRPORT
      where AIRPORT.Code = al_perf.Origin and 
      DepDelayMinutes <> 0
      group by Origin
      order by avg_DepDelay desc
      ) as maxDepDelay;
-- 1 row returned


#### 5) For each airline find an airport where it has the highest average departure delay. 
# Output an airline name, a name of the airport that has the highest average delay, 
# and the value of that average delay.

# including 0 minute departure delays:
select Reporting_Airline as "Airline", 
Airport_Name as "Airport Name", 
max(avg_DepDelay) as "Average Delay (min)"
from (select Reporting_Airline, 
	Substring(Name, locate(': ', Name) + 1, length(Name)) as Airport_Name, 
	avg(DepDelayMinutes) as avg_DepDelay
	from al_perf, AIRPORT
	where AIRPORT.Code = al_perf.Origin
	group by Origin, Reporting_Airline
	order by avg_DepDelay desc) as maxDepDelay
group by Reporting_Airline;
-- 16 rows returned


#### 6a) Check if your dataset has any canceled flights.
select count(*)
from al_perf
where Cancelled IS NOT NULL;
-- 494577 cancelled flights

#### 6b) If it does, what was the most frequent reason for each departure airport? 
# Output airport name, the most frequent reason, and the number of 
# cancelations for that reason.

select Substring(Name, locate(': ', Name) + 1, length(Name)) as "Airport Name", 
Reason, 
max(count_code) as "Cancelations for Reason"
from (select Origin, CancellationCode, count(CancellationCode) as count_code
from al_perf
where Cancelled <> 0
group by Origin, CancellationCode) as maxCancelle, AIRPORT, CANCELATION
	where AIRPORT.Code = maxCancelle.Origin and
    CANCELATION.Code = maxCancelle.CancellationCode
	group by Origin;
-- 282 rows returned


#### 7) Build a report that for each day, output the average number of flights 
# over the preceding 3 days.

select FlightDate, avg(all_flights) over (order by FlightDate rows 3 preceding) 
as "average flights over preceding 3 days"
from (select FlightDate, sum(Flights) as all_flights
from al_perf
group by FlightDate) as sum_flights
group by FlightDate;
-- 31 rows returned








