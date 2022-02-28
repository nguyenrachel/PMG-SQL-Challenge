--Question 1
--The total number of clicks is 1792.

SELECT SUM(CLICKS) AS TOTAL_OF_CLICKS
FROM MARKETING_DATA;



--Question 2
--The sum of revenue by location is returned by the query below.

SELECT STORE_LOCATION, SUM(REVENUE) AS SUM_OF_REVENUE
FROM STORE_REVENUE
GROUP BY STORE_LOCATION;



--Question 3--Merge two datasets to see impressions, clicks, and revenue together by date and geo

--Step 1: Calculate revenue of each store/location by date from the Store_Revenue table and store the data in a new table called "Daily_Revenue"

CREATE TABLE DAILY_REVENUE AS 
    (
     SELECT DATE, STORE_LOCATION, SUM(REVENUE) AS DAILY_REVENUE
     FROM STORE_REVENUE
     GROUP BY DATE, STORE_LOCATION
    );
    
--See Daily_Revenue table
SELECT * FROM DAILY_REVENUE;


--Step 2: Merge Daily_Revenue and Marketing_data tables to display impressions, clicks, and revenue together by date and geo. Store the data in a new table called "Merged_Data".

CREATE TABLE MERGED_DATA AS
(SELECT
    CASE
        WHEN MARKETING_DATA.DATE IS NULL THEN DAILY_REVENUE.DATE
        ELSE MARKETING_DATA.DATE
    END AS DATE,
    CASE
        WHEN MARKETING_DATA.GEO IS NULL THEN REPLACE(DAILY_REVENUE.STORE_LOCATION,'United States-','')
        ELSE MARKETING_DATA.GEO
    END AS LOCATION,
    MARKETING_DATA.IMPRESSIONS,
    MARKETING_DATA.CLICKS,
    DAILY_REVENUE
FROM
    MARKETING_DATA 
FULL OUTER JOIN DAILY_REVENUE ON DAILY_REVENUE.DATE = MARKETING_DATA.DATE
            AND REPLACE(DAILY_REVENUE.STORE_LOCATION, 'United States-', '') = MARKETING_DATA.GEO
ORDER BY DATE
 );
 
 --Display the newly created table
 SELECT * FROM MERGED_DATA;



--Question 4--The most efficient store

--Check which store has the highest avarege revenue-per-click (RPC) and highest average click-through-rate (CTR) from 2016/1/1 to 2016/1/6

--The missing of revenue information for the MN store can cause the lack of accuracy in evaluation. Therefore, I personally think it is necessary to look at the CTR which all the stores have data to gain the most complete picture of the problem.

--Fetch the store having the highest RPC: CA store
SELECT 
    LOCATION,
    AVG(DAILY_REVENUE/CLICKS) AS AVG_REVENUE_PER_CLICK
FROM MERGED_DATA
GROUP BY LOCATION
HAVING AVG_REVENUE_PER_CLICK IS NOT NULL
ORDER BY AVG_REVENUE_PER_CLICK DESC
LIMIT 1
;

--Fetch the store having the highest CTR: MN store
SELECT 
     LOCATION,
    (AVG(CLICKS/IMPRESSIONS))*100 AS AVG_CLICK_THROUGH_RATE
FROM MERGED_DATA
GROUP BY LOCATION
ORDER BY AVG_CLICK_THROUGH_RATE DESC
LIMIT 1
;

--The answer to the question which store is the most efficient depends on the definition of efficiency of the business in that period of time.

--If the goal is to measure the performance of an ad campaign for these stores in capturing users' attention and how efficient this ad is in bringing more traffic to the website, the MN store is the most efficient with the highest CTR, about 12.9%.

--If the goal is to evaluate how efficient an ad campaign is in generating sales for these stores from 1/1 to 1/6, the CA store shows the most efficient result since the average RPC is the highest, about 1305 unit.



--Question 5

--Calculate the sum of revenue by each store over the period and create a new column to show its ranking in terms of total revenue. 
--The query is designed to return the top 10 revenue producing states. 1 represents the highest revenue-producing store. Only stores with revenue data are called.

SELECT LOCATION, 
       TOTAL_REVENUE, 
       ROW_NUMBER() OVER (ORDER BY TOTAL_REVENUE DESC) AS RANKING
FROM 
      (SELECT LOCATION, SUM(DAILY_REVENUE) AS TOTAL_REVENUE
       FROM MERGED_DATA
       GROUP BY LOCATION)
WHERE TOTAL_REVENUE IS NOT NULL 
LIMIT 10;

