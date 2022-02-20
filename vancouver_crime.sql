--DATA EXPLORATION IN SQL - VANCOUVER CRIME DATA 
--THESE CODES WERE WRITTEN IN PostgreSQL 

--create a table to hold the data
	CREATE TABLE vancouver_crime(
		type_ varchar(100),
		year_ integer,
		month_ integer,
		day_ integer,
		hour_ integer,
		minute_ integer,
		hundred_block varchar(100),
		neighbourhood varchar(100),
		x numeric(7,1),
		y numeric(7,0),
		latitude numeric(7,5),
		longitude numeric(7,3)
);

--import the vancouver crime data
	COPY vancouver_crime
	FROM 'D:\Data Analytics\05_Public datasets\06_Vancouver_crime\crime.csv'
	WITH(FORMAT CSV, HEADER)

--load the vancouver crime data to see it in PostgreSQL
	SELECT *
	FROM vancouver_crime
	ORDER BY 
		year_,
		type_,
		month_,
		day_,
		hour_,
		minute_
		
--save a copy of the vancouver_crime data for reference, and call it vancouver_crime_original
	CREATE TABLE vancouver_crime_original AS 
	SELECT *
	FROM vancouver_crime

--count the total number of rows in the dataset
	SELECT COUNT(*)
	FROM vancouver_crime		--returns 530652 rows
	
--check the number of duplicate rows in the data
	SELECT type_,
		year_,
		month_,
		day_,
		hour_,
		minute_,
		hundred_block,
		neighbourhood,
		x,
		y,
		latitude,
		longitude,
		count(*)
	FROM vancouver_crime
	
	GROUP BY type_,
		year_,
		month_,
		day_,
		hour_,
		minute_,
		hundred_block,
		neighbourhood,
		x,
		y,
		latitude,
		longitude
	HAVING COUNT(*)>1	
										--- returns 5303 rows which were recorded as occuring more than once. The hours and neighbourhoods for these crimes were not captured.
	ORDER BY year_,						---OBSERVATION: The hour, minute, neighbourhood, latitude and longitude information for these were null.
		month_,							--In the "hundred_block" column associated with these, it was written 'offset to protect privacy'.
		day_,							--this suggests that these are not duplicates, but real crimes whose location and time info was withdrawn for security reasons
		hour_,							--if we count the number of rows with null hours, or minutes, and the column where "hundred_blocks" are offset to protect privacy, we get thesame figures. See the codes below
		minute_

--count the total number of rows without an entry in the  "hour" column
	SELECT COUNT (*)
	FROM vancouver_crime
	WHERE hour_ IS NULL			--returns 54362 rows.

--count the total number of rows without an entry in the "minute" minute
	SELECT COUNT (*)
	FROM vancouver_crime
	WHERE minute_ IS NULL		--returns 54362 rows.

--count the total number of rows where "hundred block" was offset to protect privacy,
	SELECT COUNT (*)
	FROM vancouver_crime
	WHERE hundred_block = 'OFFSET TO PROTECT PRIVACY' 		--returns 54362 rows...these are the same rows with null values for hour,minute, and zero for cordinates.
															--but these have real entries for types, year, month and days. This confirms that these are not duplicates but real crimes 
															--whose addresses were withdrawn as stated in "offset to protect privacy" for security / privacy reasons
															--hence they will not be deleted from the study, but simply neglected when performing certain queries associated 
															--with specific neighbourhoods 
															
--count the total number of rows without an entry in the "neighbourhood" column 
	SELECT COUNT (*)
	FROM vancouver_crime
	WHERE neighbourhood IS NULL	--returns 56624 rows.		--this shows that about 2262 rows without a neighbourhood address were not restricted due to privacy reasons.

--Distinct crimes reported in vancouver
	SELECT DISTINCT type_
	FROM vancouver_crime		--returns 11 distinct crimes --
	ORDER BY type_

--Distinct neighbourhoods in vancouver
	SELECT DISTINCT neighbourhood
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL --returns 24 distinct neighbourhoods
	ORDER BY neighbourhood

	
--crimes offset to protect privacy
	SELECT type_,
		COUNT(*)
	FROM vancouver_crime
	WHERE hundred_block = 'OFFSET TO PROTECT PRIVACY'
	GROUP BY type_									-- returns Homicide and offence against a person as the crimes that were offset for privacy reasons 
	

--Type of crime and total number reported 
	SELECT 	type_,
			COUNT(*) AS number_of_crimes_reported
	FROM vancouver_crime
	GROUP BY type_
	ORDER BY COUNT(*) DESC
	
--Number of crimes reported per  year (from 2003 - 2017)
	SELECT 	year_,
			COUNT(*) AS number_of_crimes_reported
	FROM vancouver_crime
	GROUP BY year_
	ORDER BY year_

--Type and number of crimes reported per year
	SELECT 	type_,
			year_,
			COUNT(*) AS number_of_crimes_committed
	FROM vancouver_crime
	GROUP BY type_,
			year_
	ORDER BY type_,
			year_
		--COUNT(*) DESC
		
--Distinct neighbourhoods in Vancouver
	SELECT DISTINCT neighbourhood
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL
	ORDER BY neighbourhood
	
--Total number of each type of crime reported between 2003 - 2017
	SELECT type_,
			COUNT(*)
	FROM vancouver_crime
	GROUP BY type_
	ORDER BY COUNT(*)DESC		--"theft from vehicle" and "Homicide" were the most and least frequently commited crime in vancouver from 2003 - 2017
	
	
--Total number of crimes reported  per neighbourhood (excluding null neighbourhoods)
	SELECT neighbourhood,
		COUNT(*)AS number_of_crimes
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL
	GROUP BY neighbourhood
	ORDER BY COUNT(*) DESC			--returns central business district as the neighbourhood with the highest number of crimes (110,947 cases) and Musqueam as the neighbourhood  
									--with the least number of reported crimes (532).


--number of crimes reported per year, per neighbourhood (excluding neighbourhoods with null entries)
	SELECT 
		neighbourhood,
		year_,
		COUNT(*) AS number_of_crimes
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL
	GROUP BY year_,
		neighbourhood
	ORDER BY neighbourhood,
		year_
			
--number and type of crime reported per neighbourhood 
	SELECT neighbourhood,
		type_ AS type_of_crime,
		COUNT(*) AS number_of_cases
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL
	GROUP BY type_,
		neighbourhood
	ORDER BY neighbourhood,
		COUNT(*) DESC					--returns "theft from vehicle" as the most popular crime reported in various neighnourhoods, except for Shaughnessy"
------------------------------------------------------------------

--neighbourhood, most reported crime, and number of cases...

--(1) Most prevalent crime in Arbutus Ridge
	
	WITH prevalent_crime
	AS
	(
	SELECT type_,
		neighbourhood,
		COUNT(*) AS number_of_crimes
	FROM vancouver_crime
	WHERE neighbourhood IS NOT NULL
	GROUP BY type_,
		neighbourhood
	ORDER BY neighbourhood,
		COUNT(*) DESC
	)
	
	SELECT neighbourhood,
			type_ AS most_reported_crime,
			number_of_crimes AS number_of_cases
	FROM prevalent_crime
	WHERE number_of_crimes = (SELECT MAX(number_of_crimes) FROM prevalent_crime WHERE neighbourhood = 'Arbutus Ridge') 		--By replacing "neigbourhood" on this line of code with the appropriate neighborhood, the exact values were obtained

	
	GROUP BY type_,
			neighbourhood,
			number_of_crimes
-----------------------------------------------------------------

--Total number of crimes reported per month
	SELECT month_,
		COUNT (month_) AS number_of_cases
	FROM vancouver_crime
	GROUP BY month_
	ORDER BY month_,
		COUNT(*) DESC

 --Type of crime and number of cases reported every  month...
	SELECT type_,
		month_,
		COUNT(*)
	FROM vancouver_crime
	GROUP BY type_,
		month_
	ORDER BY type_,
		month_,
		COUNT(*) DESC	
		

-- Hours and number of crime cases reported 
	SELECT hour_,
		COUNT(*) number_of_crimes
	FROM vancouver_crime
	WHERE hour_ IS NOT NULL
	GROUP BY hour_
	ORDER BY hour_
	
-----------------------------------------------------------
--Months in which specific crimes were reported

--(1)Break and enter commercial
	WITH Break_and_Enter_Commercial_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ = 'Break and Enter Commercial'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of break and enter commercial"
	FROM Break_and_Enter_Commercial_month
	GROUP BY month_
	ORDER BY "cases of break and enter commercial" DESC --	--	mostly reported in March (with 3124 cases)  and least reported in November (with 2655 cases)
																
	
	
--(2)Break and enter residential/other
	WITH Break_and_Enter_Residential_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Break and Enter Residential/Other'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Break and Enter Residential"
	FROM Break_and_Enter_Residential_month
	GROUP BY month_
	ORDER BY "cases of Break and Enter Residential" DESC --			--  mostly reported in January (with 5783 cases) and least reported in February (with 4723 cases)
																	
	
	
--(3)Homicide
	WITH Homicide_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Homicide'
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Homicide"
	FROM Homicide_month
	GROUP BY month_
	ORDER BY "cases of Homicide" DESC --	--  mostly reported in March (with 26 cases) and least reported in october (with 11 cases)
											
	
	
--(4) Mischief
	WITH Mischief_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Mischief'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Mischief"
	FROM Mischief_month
	GROUP BY month_
	ORDER BY "cases of Mischief" DESC 		--  mostly reported in June (with 6541 cases) and least reported in December with 5155 cases
											
	
--(5) Offence Against a Person
	WITH Offence_Against_a_Person_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Offence Against a Person'
	--AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Offence Against a Person"
	FROM Offence_Against_a_Person_month
	GROUP BY month_
	ORDER BY "cases of Offence Against a Person" DESC 		-- most reported in March (with 4847 cases) and least frequently in February with 4121 cases	
															
	
	
--(6) Other Theft
	WITH Other_Theft_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Other Theft'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Other Theft"
	FROM Other_Theft_month
	GROUP BY month_
	ORDER BY "cases of Other Theft" DESC 		-- mostly reported in August (with 4966 cases) and least frequently in december with 3885 cases
												
	
	
	
--(7) Theft from Vehicle
	WITH Theft_from_Vehicle_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Theft from Vehicle'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Theft from Vehicle"
	FROM Theft_from_Vehicle_month
	GROUP BY month_
	ORDER BY "cases of Theft from Vehicle" DESC 		-- mostly reported in May (with 15296 cases) and least frequently in February with 13171 cases
														

		
--(8) Theft of Bicycle
	WITH Theft_of_Bicycle_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Theft of Bicycle'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Theft of Bicycle"
	FROM Theft_of_Bicycle_month
	GROUP BY month_
	ORDER BY "cases of Theft of Bicycle" DESC 		-- mostly reported in July (with 3857 cases) and least frequently reported in December with 862 cases
													
	
--(9) Theft of Vehicle
	WITH Theft_of_Vehicle_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Theft of Vehicle'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Theft of Vehicle"
	FROM Theft_of_Vehicle_month
	GROUP BY month_
	ORDER BY "cases of Theft of Vehicle" DESC 		-- most frequently reported in january (with 3499 cases) and least frequently reported in december with 2855 cases
													
	
	
--(10) Vehicle Collision or Pedestrian Struck (with Fatality)
	WITH Vehicle_Collision_or_Pedestrian_Struck_with_Fatality_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Vehicle Collision or Pedestrian Struck (with Fatality)'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Vehicle Collision or Pedestrian Struck (with Fatality)"
	FROM Vehicle_Collision_or_Pedestrian_Struck_with_Fatality_month
	GROUP BY month_
	ORDER BY "cases of Vehicle Collision or Pedestrian Struck (with Fatality)" DESC 		-- mostly reported  in january (with 29 cases) and least reported in september ( with 15 cases)
																							

--(11) Vehicle Collision or Pedestrian Struck (with Injury)
	WITH Vehicle_Collision_or_Pedestrian_Struck_with_Injury_month
	AS
	(SELECT type_,
		month_
	FROM vancouver_crime
	WHERE type_ ILIKE 'Vehicle Collision or Pedestrian Struck (with Injury)'
	AND hour_ IS NOT NULL
	ORDER BY month_)
	
	SELECT month_,
		COUNT(*) AS "cases of Vehicle Collision or Pedestrian Struck (with Injury)"
	FROM Vehicle_Collision_or_Pedestrian_Struck_with_Injury_month
	GROUP BY month_
	ORDER BY "cases of Vehicle Collision or Pedestrian Struck (with Injury)" DESC 		-- mostly reported in August (with 1952 cases) and least frequently in Febrary (1600 cases)
																						
	
	
	
	
	

--- Hours in which specific crimes were reported 

--(1)Break and Enter Commercial_hour
	WITH Break_and_Enter_Commercial_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Break and Enter Commercial'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Break and Enter Commercial_hour"

	FROM Break_and_Enter_Commercial_hour
	GROUP BY hour_
	ORDER BY "cases of Break and Enter Commercial_hour" DESC 		 -- frequently reported around 4 am and least reported around 1 pm
	
	
--(2)Break and Enter Residential/Other
	WITH Break_and_Enter_Residential_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Break and Enter Residential'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Break and Enter Residential_hour"

	FROM Break_and_Enter_Residential_hour
	GROUP BY hour_
	ORDER BY "cases of Break and Enter Residential_hour" DESC  -- frequently reported around  and least reported around 
	
	
--(3)Homicide_hour
	WITH Homicide_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ ILIKE  'Homicide'
	--AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Homicide_hour"

	FROM Homicide_hour
	GROUP BY hour_
	ORDER BY "cases of Homicide_hour" DESC 		 -- time was withdrawn 
	

--(4)"Mischief_ hour
	WITH Mischief_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ LIKE 'Mischief'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Mischief"
	FROM Mischief_hour
	GROUP BY hour_
	ORDER BY "cases of Mischief" DESC  -- frequently reported around 12 midnight and least reported around 6 am
	
	
	
--(5) Offence Against a Person_hour
	WITH Offence_Against_a_Person_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ LIKE 'Offence Against a Person'
	--AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Offence Against a Person"
	FROM Offence_Against_a_Person_hour
	GROUP BY hour_
	ORDER BY "cases of Offence Against a Person" DESC 		--time was withdrawn
	
	
--(6)Other_Theft_hour
	WITH Other_Theft_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ LIKE 'Other Theft'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Other Theft"
	FROM Other_Theft_hour
	GROUP BY hour_
	ORDER BY "cases of Other Theft" DESC 		--most frequently reported at 3 pm and least reported at 4 am
	
	
	
--(7)Theft from Vehicle
	WITH Theft_from_Vehicle_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ LIKE 'Theft from Vehicle'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "cases of Theft from Vehicle"
	FROM Theft_from_Vehicle_hour
	GROUP BY hour_
	ORDER BY "cases of Theft from Vehicle" DESC 			--most frequently reported at 6 pm (14942 cases) and least reported at 4 am (1674 cases)
	

--(8)"Theft of Bicycle"
	WITH Theft_of_Bicycle_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Theft of Bicycle'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "Theft of Bicycle hour"
	FROM Theft_of_Bicycle_hour
	GROUP BY hour_
	ORDER BY "Theft of Bicycle hour" DESC  -- frequently reported around 6 pm (2060 cases) and least reported around 4 am (189 cases)


--(9)"Theft of Vehicle"
	WITH Theft_of_Vehicle_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Theft of Vehicle'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "Theft of Vehicle hour"
	FROM Theft_of_Vehicle_hour
	GROUP BY hour_
	ORDER BY "Theft of Vehicle hour" DESC 			 -- frequently reported around 10 pm (3361 cases) and least reported around 5 am (348 cases)


--(10)Vehicle Collision or Pedestrian Struck (with Fatality)
	WITH Vehicle_Collision_or_Pedestrian_Struck_with_Fatality_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Vehicle Collision or Pedestrian Struck (with Fatality)'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "Cases of Vehicle Collision or Pedestrian Struck (with Fatality)"
	FROM Vehicle_Collision_or_Pedestrian_Struck_with_Fatality_hour
	GROUP BY hour_
	ORDER BY "Cases of Vehicle Collision or Pedestrian Struck (with Fatality)" DESC  		-- frequently reported around 3 pm (19 cases) and least reported around 6 am (3 cases)


--(11)Vehicle Collision or Pedestrian Struck (with Injury)
	WITH Vehicle_Collision_or_Pedestrian_Struck_with_Injury_hour
	AS
	(SELECT type_,
		hour_
	FROM vancouver_crime
	WHERE type_ = 'Vehicle Collision or Pedestrian Struck (with Injury)'
	AND hour_ IS NOT NULL
	ORDER BY hour_)
	
	SELECT hour_,
		COUNT(*) AS "Cases of Vehicle Collision or Pedestrian Struck (with Injury)"
	FROM Vehicle_Collision_or_Pedestrian_Struck_with_Injury_hour
	GROUP BY hour_
	ORDER BY "Cases of Vehicle Collision or Pedestrian Struck (with Injury)" DESC  				-- frequently reported around 5 pm (1816 cases) and least reported around 4 am (224 cases)
