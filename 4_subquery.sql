-- Subquery
-- WHEN to use
-- 1
-- Identify the top-selling Amazon products in months where sales have exceeded $1m
-- Existing Table: Amazon daily sales
-- Subquery Aggregation: Daily to Monthly

-- 2
-- Examine the average price of a brand’s products for the highest-grossing brands
-- Existing Table: Product pricing data across all retailers
-- Subquery Aggregation: Individual to Average

-- 3
-- Order the annual salary of employees that are working less than 150 hours a month
-- Existing Table: Daily time-table of employees
-- Subquery Aggregation: Daily to Monthly

SELECT product_id,
       name,
       price
FROM db.product
Where price > (SELECT AVG(price)
              FROM db.product)

-- Subquery Placement:
-- With: This subquery is used when you’d like to “pseudo-create” a table 
-- from an existing table and visually scope the temporary table at the top 
-- of the larger query.

WITH subquery_name (column_name1, ...) AS
 (SELECT ...)
SELECT ...

-- Nested: This subquery is used when you’d like the temporary table to act 
-- as a filter within the larger query, which implies that it often sits within 
-- the WHERE clause.

SELECT s.s_id, s.s_name, g.final_grade
FROM student s, grades g
WHERE s.s_id = g.s_id
IN (SELECT final_grade
    FROM grades g
    WHERE final_grade >3.7
   );

-- Inline: This subquery is used in the same fashion as the WITH use case above. 
-- However, instead of the temporary table sitting on top of the larger query, 
-- it’s embedded within the FROM clause.

SELECT student_name
FROM
  (SELECT student_id, student_name, grade
   FROM student
   WHERE teacher =10)
WHERE grade >80;

-- Scalar: This subquery is used when you’d like to generate a scalar value to 
-- be used as a benchmark of some sort. For example, when you’d like to calculate 
-- the average salary across an entire organization to compare to individual employee salaries. 
-- Because it’s often a single value that is generated and used as a benchmark, 
-- the scalar subquery often sits within the SELECT clause.

SELECT s.student_name
  (SELECT AVG(final_score)
   FROM grades g
   WHERE g.student_id = s.student_id) AS
     avg_score
FROM student s;

-- practice
-- Questions to answer:
-- What is the top channel used by each account to market products?
-- How often was that same channel used?

-- wrong answer

WITH t1(aname, channel, use_times_per_a) AS (SELECT a.name, w.channel,count(w.*)
FROM accounts a JOIN web_events w ON w.account_id = a.id 
GROUP BY a.name, w.channel 
ORDER BY 1) 

SELECT t1.aname, t1.channel, t1.use_times_per_a
FROM t1
WHERE t1.use_times_per_a =(SELECT t1.aname, MAX(t1.use_times_per_a)
FROM t1 GROUP BY t1.aname) AND t1.aname =

-- 
-- correct answer
-- id and max_count should match at the same time!!
-- this is a column match, not a single match!!

SELECT t3.id, t3.name, t3.channel, t3.ct
FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
     FROM accounts a
     JOIN web_events we
     On a.id = we.account_id
     GROUP BY a.id, a.name, we.channel) T3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM (SELECT a.id, a.name, we.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events we
            ON a.id = we.account_id
            GROUP BY a.id, a.name, we.channel) t1
      GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id, t3.ct;

-- practice
-- Provide the name of the sales_rep in each region with 
-- the largest amount of total_amt_usd sales.

SELECT t3.sales_rep, t3.region, t3.total_sale
FROM (SELECT s.name sales_rep, r.name region, sum(total_amt_usd) total_sale
FROM region r JOIN sales_reps s ON s.region_id = r.id JOIN accounts a 
ON a.sales_rep_id = s.id JOIN orders o ON o.account_id = a.id
GROUP BY s.name, r.name) as t3 
JOIN (SELECT t1.region, MAX(t1.total_sale) max_sale
 FROM (SELECT s.name sales_rep, r.name region, sum(total_amt_usd) total_sale
FROM region r JOIN sales_reps s ON s.region_id = r.id JOIN accounts a 
ON a.sales_rep_id = s.id JOIN orders o ON o.account_id = a.id
GROUP BY s.name, r.name) as t1
GROUP BY t1.region) as t2
ON t3.region = t2.region AND t3.total_sale = t2.max_sale;

-- For the region with the largest (sum) of sales total_amt_usd, 
-- how many total (count) orders were placed?

SELECT r.name region, sum(o.total_amt_usd) total_sale, count(o.*) total_orders
FROM region r JOIN sales_reps s ON s.region_id = r.id JOIN accounts a 
ON a.sales_rep_id = s.id JOIN orders o ON o.account_id = a.id
GROUP BY r.name
ORDER BY total_sale DESC

-- How many accounts had more total purchases than the account 
-- which has bought the most standard_qty paper throughout their 
-- lifetime as a customer?
-- don't know how to(see notes!!)

SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;

-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- how many web_events did they have for each channel?
 
 SELECT a.name, w.channel, count(w.*) num_events
 FROM accounts a JOIN web_events w ON a.id = w. account_id
 GROUP BY a.name, w.channel
 HAVING a.name IN (SELECT t1.name 
 FROM (SELECT a.name, SUM(total_amt_usd) total_sale
 FROM accounts a JOIN orders o ON a.id = o.account_id
 GROUP BY a.name
 ORDER BY total_sale DESC
 LIMIT 1) t1)

--  What is the lifetime average amount spent in terms of total_amt_usd for 
--  the top 10 total spending accounts?

SELECT AVG(t1.total_sale)
FROM (SELECT a.name, SUM(total_amt_usd) total_sale
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sale DESC
LIMIT 10) t1

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, 
-- on average, than the average of all orders?
-- don't know how to
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;

-- WITH practice
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- For the region with the largest sales total_amt_usd, how many total orders were placed?

-- How many accounts had more total purchases than the account name which has bought the most 
-- standard_qty paper throughout their lifetime as a customer?

-- For the customer that spent the most (in total over their lifetime as a customer) 
-- total_amt_usd, how many web_events did they have for each channel?

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 
-- total spending accounts?

-- What is the lifetime average amount spent in terms of total_amt_usd, including only 
-- the companies that spent more per order, on average, than the average of all orders.


WITH t1 AS (
  		SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) 			   	   total_sale
  		FROM region r JOIN sales_reps s ON s.region_id = r.id 
  		JOIN accounts a ON s.id = a.sales_rep_id 
		JOIN orders o ON o.account_id = a.id
		GROUP BY s.name, r.name),

	t2 AS (
        SELECT MAX(t1.total_sale) max_sale, t1.region region
		FROM t1
		GROUP BY t1.region)

SELECT t1.sales_rep, t1.region, t1.total_sale
FROM t1 JOIN t2 ON t1.total_sale = t2.max_sale AND t1.region = t2.region;

-- 
WITH t1 AS (
  		SELECT r.name region, SUM(o.total_amt_usd) total_sale
  		FROM region r JOIN sales_reps s ON s.region_id = r.id 
  		JOIN accounts a ON s.id = a.sales_rep_id 
		JOIN orders o ON o.account_id = a.id
		GROUP BY r.name
        ORDER BY total_sale DESC
        LIMIT 1)

SELECT count(o.*) ct, r.name region
FROM region r JOIN sales_reps s ON s.region_id = r.id 
  		JOIN accounts a ON s.id = a.sales_rep_id 
		JOIN orders o ON o.account_id = a.id
GROUP BY r.name
HAVING r.name IN (SELECT t1.region FROM t1);

-- 

WITH t1 AS (SELECT SUM(o.standard_qty) st_total, SUM(o.total_amt_usd) total_usd, a.name
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY st_total DESC
LIMIT 1),

t2 AS (SELECT SUM(total_amt_usd)  total_sale, account_id
FROM orders o
GROUP BY account_id
HAVING SUM(total_amt_usd) > (SELECT t1.total_usd FROM t1))

SELECT count(*)
FROM t2;

-- NOT WRITTEN BY ME

WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;

-- 
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;

-- DATA CLEANING
-- Left/Right/Substr: Used to extract information typically when all information resides in a single column
-- Concat: Used commonly when two or more pieces of information can be used as a unique identifier
-- Cast: Used when data types default to a specific type (e.g., most commonly STRING) and need to be assigned 
-- to the appropriate data type to run computations
-- E.G.
-- LEFT(student_information, 8) AS student_id
-- RIGHT(student_information, 6) AS salary
-- SUBSTR(string, start, length)
-- SUBSTR(student_information, 11, 1) AS gender

-- PRACTICE
SELECT COUNT(*) ct, RIGHT(website,3) as web_kind
FROM accounts a
GROUP BY web_kind

SELECT COUNT(*) ct, LEFT(name,1) as name_1st
FROM accounts a
GROUP BY name_1st
ORDER BY ct DESC;

-- Use the accounts table and a CASE statement to create two groups: 
-- one group of company names that start with a number and the second group of those company names that start with a letter. 
-- What proportion of company names start with a letter?

-- answer
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;


-- Consider vowels as a, e, i, o, and u. 
-- What proportion of company names start with a vowel, 
-- and what percent start with anything else?

WITH t1 AS (SELECT COUNT(*) ct, LEFT(name,1) as name_1st
FROM accounts a
GROUP BY name_1st
ORDER BY ct DESC)

SELECT SUM(ct), CASE WHEN UPPER(name_1st) IN ('a','e','i','o','u') THEN 'vowels'
                     ELSE 'no-vowels' END AS vowels
FROM t1
GROUP BY vowels
-- ANSWER
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;


-- BONUS Concept: STRING_SPLIT
WITH table AS(
SELECT  student_information,
        value,
        ROW _NUMBER() OVER(PARTITION BY student_information ORDER BY (SELECT NULL)) AS row_number
FROM    student_db
        CROSS APPLY STRING_SPLIT(student_information, ',') AS back_values
)
SELECT  student_information,
        [1] AS STUDENT_ID,
        [2] AS GENDER,
        [3] AS CITY,
        [4] AS GPA,
        [5] AS SALARY
FROM    table
PIVOT(
        MAX(VALUE)
        FOR row_number IN([1],[2],[3],[4],[5])
) AS PVT)

-- CONCAT: Adds two or more expressions together

CONCAT(string1, string2, string3)
CONCAT(month, '-', day, '-', year) AS date

-- CAST: Converts a value of any type into a specific, different data type

CAST(expression AS datatype)
CAST(salary AS int)

-- POSITION/STRPOS
POSITION: Returns the position of the first occurrence of a substring in a string
POSITION(substring IN string)


POSITION("$" IN student_information) as
salary_starting_position

STRPOS: Converts a value of any type into a specific, different data type
STRPOS(string, substring)

-- Use the accounts table to create first and last name columns 
-- that hold the first and last names for the primary_poc.

SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

-- Each company in the accounts table wants to create an email address for each primary_poc. 
-- The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.

SELECT CONCAT(LEFT(primary_poc,STRPOS(primary_poc,' ')-1),'.',RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')),
'@',name,'.com') email 
FROM accounts
ORDER BY name;




-- You may have noticed that in the previous solution some of the company names include spaces, 
-- which will certainly not work in an email address. See if you can create an email address that 
-- will work by removing all of the spaces in the account name, but otherwise, your solution should be just as in question 1.
--  Some helpful documentation is here(opens in a new tab).

-- ADD REPLACE
SELECT CONCAT(LEFT(primary_poc,STRPOS(primary_poc,' ')-1),'.',RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')),
'@',replace( name, ' ', ''),'.com') email 
FROM accounts
ORDER BY name;


-- We would also like to create an initial password, which they will change after their first log in. 
-- The first password will be the first letter of the primary_poc's first name (lowercase), 
-- then the last letter of their first name (lowercase), the first letter of their last name (lowercase), 
-- the last letter of their last name (lowercase), the number of letters in their first name, the number of letters 
-- in their last name, and then the name of the company they are working with, all capitalized with no spaces.

WITH t1 AS (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name,
REPLACE(name,' ','') name_nosp
FROM accounts)

SELECT CONCAT(LOWER(LEFT(t1.first_name,1)),LOWER(RIGHT(t1.first_name,1)),
LOWER(LEFT(t1.last_name,1)),LOWER(RIGHT(t1.last_name,1)),LENGTH(t1.first_name),
LENGTH(t1.last_name),UPPER(t1.name_nosp)) passwords
FROM t1
ORDER BY passwords

-- COALESCE: Returns the first non-null value in a list.
-- SEE e.g.

COALESCE(val1, val2, val3)
COALESCE(hourly_wage*40*52, salary, commission*sales) AS annual_income

-- Use Case
-- If there are multiple columns that have a combination of null and non-null 
-- values and the user needs to extract the first non-null value, 
-- he/she can use the coalesce function.

-- COALESCE is a command that helps you deal with null values. 
-- Now before using COALESCE, take a step back and think through how’d you 
-- like to deal with missing values in the first place.

-- example
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, 
a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, 
o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) 
gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) 
gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, 
COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;