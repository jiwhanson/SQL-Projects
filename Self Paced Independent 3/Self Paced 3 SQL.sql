--How many public high schools are in each zip code?
SELECT zip_code, COUNT(DISTINCT school_name) AS 'num_schools' FROM public_hs_data
GROUP BY 1;

--How many public high schools are in each state?
SELECT state_code, COUNT(DISTINCT school_name) AS 'num_schools' FROM public_hs_data
GROUP BY 1;

--Convert locale code to text and size
SELECT school_name,
CASE
	WHEN locale_code = 11 OR locale_code = 12 OR locale_code = 13 THEN 'City'
	WHEN locale_code = 21 OR locale_code = 22 OR locale_code = 23 THEN 'Suburb'
	WHEN locale_code = 31 OR locale_code = 32 OR locale_code = 33 THEN 'Town'
	WHEN locale_code = 41 OR locale_code = 42 OR locale_code = 43 THEN 'Rural'
	ELSE NULL
END AS 'locale_text',
CASE
	WHEN locale_code = 11 OR locale_code = 21 THEN 'Large'
	WHEN locale_code = 12 OR locale_code = 22 THEN 'Midsize'
	WHEN locale_code = 13 OR locale_code = 23 THEN 'Small'
	WHEN locale_code = 31 OR locale_code = 41 THEN 'Fringe'
	WHEN locale_code = 32 OR locale_code = 42 THEN 'Distant'
	WHEN locale_code = 33 OR locale_code = 43 THEN 'Remote'
	ELSE NULL
END AS 'locale_size'
FROM public_hs_data;

--What is the minimum, maximum, and average median_household_income of the nation?
SELECT MAX(median_household_income) AS 'max_median_income',
MIN(median_household_income) AS 'min_median_income',
ROUND(AVG(median_household_income), 2) AS 'avg_median_income' FROM census_data
WHERE median_household_income != 'NULL';

--What is the minimum, maximum, and average median_household_income for each state?
SELECT state_code, MAX(median_household_income) AS 'max_median_income',
MIN(median_household_income) AS 'min_median_income',
ROUND(AVG(median_household_income), 2) AS 'avg_median_income' FROM census_data
WHERE median_household_income != 'NULL'
GROUP BY 1;


--Do characteristics of the zip-code area, such as median household income, influence students’ performance in high school?
--Zipcode & income data
WITH income AS(SELECT zip_code,
CASE
	WHEN median_household_income < 50000 THEN '1. Low Income'
	WHEN median_household_income BETWEEN 50000 AND 100000 THEN '2. Medium Income'
	WHEN median_household_income > 100000 THEN '3. High Income'
	ELSE 'NULL'
END AS 'income_level'
FROM census_data),

--zipcode and math proficiency average
math AS (SELECT zip_code, AVG(pct_proficient_math) AS 'math_prof' FROM public_hs_data
WHERE pct_proficient_math != 'NULL'
GROUP BY 1),

--zipcode and reading proficiency average
reading AS (SELECT zip_code, AVG(pct_proficient_reading) AS 'reading_prof' FROM public_hs_data
WHERE pct_proficient_reading != 'NULL'
GROUP BY 1)

--List average math & reading proficiency by income level
SELECT income.income_level, ROUND(AVG(math.math_prof), 2) AS 'avg_math_prof',
 ROUND(AVG(reading.reading_prof), 2) AS 'avg_reading_prof' FROM income
JOIN math
ON income.zip_code = math.zip_code
JOIN reading
ON math.zip_code = reading.zip_code
GROUP BY 1
ORDER BY 1 DESC;

--On average, do students perform better on the math or reading exam?
--Find the number of states where students do better on the math exam, and vice versa
--state and math proficiency average
WITH math AS (SELECT state_code, AVG(pct_proficient_math) AS 'math_prof' FROM public_hs_data
WHERE pct_proficient_math != 'NULL'
GROUP BY 1),

--state and reading proficiency average
reading AS (SELECT state_code, AVG(pct_proficient_reading) AS 'reading_prof' FROM public_hs_data
WHERE pct_proficient_reading != 'NULL'
GROUP BY 1)

--Count # of states better at math & states better at reading
SELECT
SUM(CASE
	WHEN math.math_prof > reading.reading_prof THEN 1
	ELSE 0
END) AS 'better_at_math',
SUM(CASE
	WHEN math.math_prof <= reading.reading_prof THEN 1
	ELSE 0
END) AS 'better_at_reading'
FROM math
JOIN reading
ON math.state_code = reading.state_code;

--What is the average proficiency on state assessment exams for each zip code?
--How do they compare to other zip codes in the same state?
--Table for state averages
WITH state_avg AS (
SELECT * FROM 
(SELECT state_code, AVG(pct_proficient_math) AS 'state_math_prof' FROM public_hs_data
WHERE pct_proficient_math != 'NULL'
GROUP BY 1) AS 'm_st'
JOIN
(SELECT state_code, AVG(pct_proficient_reading) AS 'state_reading_prof' FROM public_hs_data
WHERE pct_proficient_reading != 'NULL'
GROUP BY 1) AS 'r_st'
ON m_st.state_code = r_st.state_code),

--Table for zipcode averages
zip_avg AS (
SELECT * FROM 
(SELECT state_code, zip_code, AVG(pct_proficient_math) AS 'zip_math_prof' FROM public_hs_data
WHERE pct_proficient_math != 'NULL'
GROUP BY 2) AS 'm_zip'
JOIN
(SELECT zip_code, AVG(pct_proficient_reading) AS 'zip_reading_prof' FROM public_hs_data
WHERE pct_proficient_reading != 'NULL'
GROUP BY 1) AS 'r_zip'
ON m_zip.zip_code = r_zip.zip_code)

--List zipcodes as below/above the state average
SELECT zip_avg.zip_code, ROUND(zip_avg.zip_math_prof, 2) AS 'Math Proficieny', 
CASE
	WHEN zip_avg.zip_math_prof < state_avg.state_math_prof THEN 'Below'
	WHEN zip_avg.zip_math_prof > state_avg.state_math_prof THEN 'Above'
	ELSE 'Equal'
END AS 'math_compare_to_state', ROUND(zip_avg.zip_reading_prof, 2) AS 'Reading Proficiency', 
CASE
	WHEN zip_avg.zip_reading_prof < state_avg.state_reading_prof THEN 'Below'
	WHEN zip_avg.zip_reading_prof > state_avg.state_reading_prof THEN 'Above'
	ELSE 'Equal'
END AS 'reading_compare_to_state' FROM zip_avg
JOIN state_avg 
ON zip_avg.state_code = state_avg.state_code;

