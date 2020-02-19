--What range of years are represented in the data?
/*SELECT MAX(Year), MIN(Year) FROM airfare;

--What are the shortest and longest-distanced flights, and between which 2 cities are they?
SELECT city1, city2, nsmiles FROM airfare
ORDER BY 3 DESC
LIMIT 1;

SELECT city1, city2, nsmiles FROM airfare
ORDER BY 3 ASC
LIMIT 1;

--How many distinct cities are represented in the data (regardless of whether it is the source or destination)?
WITH allCities AS (
SELECT city1 FROM airfare
UNION
SELECT city2 FROM airfare)

SELECT COUNT(DISTINCT city1) FROM allCities;

--Which airline appear most frequently as the carrier with the lowest fare (ie. carrier_low)?
--How about the airline with the largest market share (ie. carrier_lg)?
SELECT carrier_low, COUNT(carrier_low) FROM airfare
WHERE carrier_low IS NOT NULL
GROUP BY 1;

SELECT carrier_lg, COUNT(carrier_lg) FROM airfare
WHERE carrier_lg IS NOT NULL
GROUP BY 1;

--How many instances are there where the carrier with the largest market share is not the carrier with the lowest fare?
--What is the average difference in fare?
SELECT COUNT(*) FROM airfare
WHERE carrier_low <> carrier_lg;

SELECT AVG(fare_lg - fare_low) FROM airfare
WHERE carrier_low <> carrier_lg;

--What is the percent change 4 in average fare from 2007 to 2017 by flight?
--How about from 1997 to 2017
WITH airfare2007 AS (SELECT city1, city2, AVG(fare) AS 'Av2007' FROM airfare
WHERE Year = 2007
GROUP BY 1, 2),

airfare2017 AS (SELECT city1, city2, AVG(fare) AS 'Av2017' FROM airfare
WHERE Year = 2017
GROUP BY 1, 2)

SELECT airfare2007.city1, airfare2007.city2, ROUND((100. * (Av2017 - Av2007) / Av2007), 2) AS 'Percent Change' FROM airfare2007
JOIN airfare2017
ON (airfare2007.city1 = airfare2017.city1 AND airfare2007.city2 = airfare2017.city2);

--What is the average fare for each quarter? Which quarter of the year has the highest overall average fare? lowest?
SELECT quarter, ROUND(AVG(fare), 2) FROM airfare
GROUP BY 1;*/

--Considering only the flights that have data available on all 4 quarters of the year, which quarter has the highest overall average fare? lowest?
--Try breaking it down by year as well.
WITH flightq1 AS (SELECT city1, city2 FROM airfare
WHERE quarter = 1
GROUP BY 1, 2),

flightq2 AS (SELECT city1, city2 FROM airfare
WHERE quarter = 2
GROUP BY 1, 2),

flightq3 AS (SELECT city1, city2 FROM airfare
WHERE quarter = 3
GROUP BY 1, 2),

flightq4 AS (SELECT city1, city2 FROM airfare
WHERE quarter = 4
GROUP BY 1, 2),

flightsq14 AS (SELECT * FROM flightq1
JOIN flightq2
ON (flightq1.city1 = flightq2.city1 AND flightq1.city2 = flightq2.city2)
JOIN flightq3
ON (flightq2.city1 = flightq3.city1 AND flightq2.city2 = flightq3.city2)
JOIN flightq4
ON (flightq3.city1 = flightq4.city1 AND flightq3.city2 = flightq4.city2))

SELECT quarter, ROUND(AVG(fare), 2) FROM airfare
JOIN flightsq14
ON (airfare.city1 = flightsq14.city1 AND airfare.city2 = flightsq14.city2)
GROUP BY 1;


