-- null
-- IS NULL/IS NOT NULL with WHERE

-- COUNT
-- Notice that COUNT does not consider rows that have NULL values. 
-- Therefore, this can be useful for quickly identifying which rows have missing data. 

SELECT COUNT(primary_poc) AS account_primary_poc_count
FROM accounts

-- SUM
SELECT SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster
FROM orders

-- Practice
SELECT SUM(poster_qty) poster
FROM orders;

SELECT SUM(standard_qty) standard
FROM orders;

SELECT SUM(total_amt_usd) total
FROM orders;

SELECT (standard_amt_usd + gloss_amt_usd) total_sg 
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) unit_price_standard
FROM orders;

-- MIN/MAX
-- Notice that MIN and MAX are aggregators that again ignore NULL values. 
-- Check the expert tip below for a cool trick with MAX & MIN.

SELECT MIN(standard_qty) AS standard_min,
       MIN(gloss_qty) AS gloss_min,
       MIN(poster_qty) AS poster_min,
       MAX(standard_qty) AS standard_max,
       MAX(gloss_qty) AS gloss_max,
       MAX(poster_qty) AS poster_max
FROM   orders

-- AVG (ignore NULL)

-- This aggregate function again ignores 
-- the NULL values in both the numerator and the denominator.

-- If you want to count NULLs as zero, 
-- you will need to use SUM and COUNT. 
-- However, this is probably not a good idea 
-- if the NULL values truly just represent unknown values for a cell.
SELECT AVG(standard_qty) AS standard_avg,
       AVG(gloss_qty) AS gloss_avg,
       AVG(poster_qty) AS poster_avg
FROM orders

-- MIN/MAX/AGV PRACTICE
SELECT MIN(occured_at)
FROM orders;

SELECT occured_at
FROM orders
ORDER BY occured_at
LIMIT 1;

SELECT Max(occured_at)
FROM web_events;

SELECT occured_at
FROM web_events
ORDER BY occured_at DESC
LIMIT 1;

SELECT AVG(standard_qty) standard_avg, AVG(poster_qty) poster_avg, AVG(gloss_qty) gloss_avg,
       AVG(standard_amt_usd) standard_avg_usd, AVG(poster_amt_usd) poster_avg_usd, AVG(gloss_amt_usd) gloss_avg_usd
FROM orders;SELECT MIN(occured_at)
FROM orders;

-- GROUP BY
SELECT account_id,
       SUM(standard_qty) AS standard,
       SUM(gloss_qty) AS gloss,
       SUM(poster_qty) AS poster
FROM orders
GROUP BY account_id
ORDER BY account_id

-- Any column in the SELECT statement that is 
-- not within an aggregator(i.e. account_id in the axample) 
-- must be in the GROUP BY clause.

-- GROUP BY practice 1
SELECT a.name aname, o.occurred_at odate
FROM orders o JOIN accounts a ON o.account_id = a.id 
ORDER BY odate
LIMIT 1;

SELECT a.name aname, SUM(total_amt_usd) total_sales
FROM orders o JOIN accounts a ON a.id= o.account_id
GROUP BY name;

SELECT a.name aname, w.occurred_at wdate, w.channel channel
FROM accounts a JOIN web_events w ON a.id = w.account_id
ORDER BY wdate DESC
LIMIT 1;

SELECT channel, count(channel)
FROM web_events
GROUP BY channel;

SELECT w.occurred_at wdate, a.primary_poc primary_con 
FROM web_events w JOIN accounts a ON w.account_id = a.id
ORDER BY wdate
LIMIT 1;

SELECT a.name aname, min(o.total) total_usd 
FROM accounts a JOIN orders o ON o.account_id = a.id
GROUP BY aname
ORDER BY total_usd;

SELECT COUNT(s.id) num_sales, r.name region
FROM region r JOIN sales_reps s ON r.id = s.region_id
GROUP BY region;

-- GROUP BY Practice 2
SELECT a.name aname, AVG(standard_qty) st_avg, AVG(poster_qty) po_avg, AVG(gloss_qty) gloss_avg
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY aname;


SELECT a.name aname, AVG(standard_amt_usd) st_avg, AVG(poster_amt_usd) po_avg, AVG(gloss_amt_usd) gloss_avg
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY aname;

SELECT s.name sname, w.channel channel, count(w.id) number_oc
FROM sales_reps s JOIN accounts a ON s.id = a.sales_rep_id
JOIN web_events w ON w.account_id = a.id
GROUP BY sname, channel
ORDER BY number_oc DESC;

SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a JOIN web_events w ON a.id = w.account_id
JOIN sales_reps s ON s.id = a.sales_rep_id
JOIN region r ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;

-- DISTINCT

-- Use DISTINCT to test if there are any accounts associated with more than one region.
-- The below two queries have the same number of resulting rows (351), 
-- so we know that every account is associated with only one region. 
-- If each account was associated with more than one region, 
-- the first query should have returned more rows than the second query.

SELECT a.id a_id, s.region_id region
FROM accounts a JOIN sales_reps s ON a.sales_rep_id = s.id


SELECT DISTINCT id, name
FROM accounts;


-- Have any sales reps worked on more than one account?
-- Actually, all of the sales reps have worked on more than one account. 
-- The fewest number of accounts any sales rep works on is 3. 
-- There are 50 sales reps, and they all have more than one account. 
-- Using DISTINCT in the second query assures that all of the sales 
-- reps are accounted for in the first query.

SELECT s.name s_name, s.id s_id, COUNT(*) num_account
FROM accounts a JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
ORDER BY num_account;

SELECT DISTINCT id, name
FROM sales_reps;


-- HAVING (WHERE clause for aggregate query)

-- HAVING is the “clean” way to filter a query that has been aggregated, 
-- but this is also commonly done using a subquery(opens in a new tab). 
-- Essentially, any time you want to perform a WHERE on an element of your query 
-- that was created by an aggregate, you need to use HAVING instead.


-- Practice

-- How many of the sales reps have more than 5 accounts that they manage?
-- How many accounts have more than 20 orders?
-- Which account has the most orders?
-- Which accounts spent more than 30,000 usd total across all orders?
-- Which accounts spent less than 1,000 usd total across all orders?
-- Which account has spent the most with us?
-- Which account has spent the least with us?
-- Which accounts used facebook as a channel to contact customers more than 6 times?
-- Which account used facebook most as a channel?
-- Which channel was most frequently used by most accounts?


SELECT s.name s_name, s.id s_id, COUNT(*) num_account
FROM accounts a JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5 
ORDER BY num_account;

SELECT a.id a_id, a.name a_name, COUNT(*) number_order
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
HAVING COUNT(*) > 20
ORDER BY number_order;

SELECT a.id a_id,a.name a_name, COUNT(*) number_order
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
ORDER BY number_order DESC
LIMIT 1;

SELECT a.id a_id,a.name a_name, SUM(o.total_amt_usd) total_spent
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent DESC;

SELECT a.id a_id, a.name a_name,SUM(o.total_amt_usd) total_spent
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent DESC;

SELECT a.id a_id, a.name a_name, SUM(o.total_amt_usd) total_spent
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
ORDER BY total_spent DESC
LIMIT 1;

SELECT a.id a_id, a.name a_name, SUM(o.total_amt_usd) total_spent
FROM accounts a JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a_name
ORDER BY total_spent
LIMIT 1;

SELECT a.id a_id, a.name a_name, COUNT(w.channel) num_channel
FROM accounts a JOIN web_events w ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a_name
HAVING COUNT(w.channel) > 6;

SELECT a.id a_id, a.name a_name, COUNT(w.channel) num_channel
FROM accounts a JOIN web_events w ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a_name
ORDER BY num_channel DESC
LIMIT 1;

SELECT a.id a_id, w.channel channel, COUNT(w.channel) num_channel
FROM accounts a JOIN web_events w ON a.id = w.account_id
GROUP BY a.id, w.channel
ORDER BY num_channel DESC
LIMIT 10;

-- DATE functions

-- DATE_TRUNC allows you to truncate your date to a particular part of your 
-- date-time column. Common truncations are day, month, and year. 
-- This blog post by Mode Analytics on the power of this function: 
-- DATE_TRUNC: A SQL Timestamp Function You Can Count On(opens in a new tab).

-- DATE_PART can be useful for pulling a specific portion of a date, 
-- but notice pulling month or day of the week (dow) means that you are no longer 
-- keeping the years in order. Rather you are grouping for certain components 
-- regardless of which year they belonged in.

-- The DATE_TRUNC and DATE_PART functions definitely give you a great start! 
-- For additional functions, you can use with dates, check out the documentation: 
-- Date/Time Functions and Operators (opens in a new tab).

-- You can reference the columns in your select statement in GROUP BY and ORDER BY 
-- clauses with numbers that follow the order they appear in the select statement. 

-- practice
SELECT DATE_TRUNC('year',occurred_at) saleyear, SUM(total_amt_usd) total_sales
FROM orders
GROUP BY DATE_TRUNC('year',occurred_at)
ORDER BY DATE_TRUNC('year',occurred_at) DESC;

-- OR
SELECT DATE_PART('year',occurred_at) saleyear, SUM(total_amt_usd) total_sales
FROM orders
GROUP BY DATE_PART('year',occurred_at)
ORDER BY DATE_PART('year',occurred_at) DESC;

SELECT DATE_PART('month',occurred_at) salemonth, SUM(total_amt_usd) total_sales
FROM orders
GROUP BY DATE_PART('month',occurred_at)
ORDER BY DATE_PART('month',occurred_at) DESC;

SELECT DATE_TRUNC('year',occurred_at) saleyear, COUNT(*) total_orders
FROM orders
GROUP BY DATE_TRUNC('year',occurred_at)
ORDER BY DATE_TRUNC('year',occurred_at) DESC; 

SELECT DATE_PART('month',occurred_at) salemonth, COUNT(*) total_orders
FROM orders
GROUP BY DATE_PART('month',occurred_at)
ORDER BY DATE_PART('month',occurred_at) DESC; 

-- add WHERE DATE_PART('year', occurred_at) BETWEEN 2014 AND 2016 to have a fair compare

SELECT DATE_PART('year',o.occurred_at), DATE_PART('month',o.occurred_at) salemonth,SUM(o.gloss_amt_usd) total_spend
FROM orders o JOIN accounts a ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY DATE_part('year',o.occurred_at),DATE_PART('month',o.occurred_at)
ORDER BY total_spend DESC; 


-- CASE,WHEN, THEN, END AS COLUMN NAME
SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' THEN 'yes' END AS is_facebook
FROM web_events
ORDER BY occurred_at

SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' THEN 'yes' ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY occurred_at

SELECT id,
       account_id,
       occurred_at,
       channel,
       CASE WHEN channel = 'facebook' OR channel = 'direct' THEN 'yes' 
       ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY occurred_at

SELECT account_id,
       occurred_at,
       total,
       CASE WHEN total > 500 THEN 'Over 500'
            WHEN total > 300 THEN '301 - 500'
            WHEN total > 100 THEN '101 - 300'
            ELSE '100 or under' END AS total_group
FROM orders

-- with aggregation
SELECT CASE WHEN total > 500 THEN 'OVer 500' ELSE '500 or under' END AS total_group, 
COUNT(*) AS order_count FROM orders GROUP BY 1

-- practice
SELECT account_id,
       total_amt_usd,
       CASE WHEN total_amt_usd > 3000 THEN 'Large'
            ELSE 'Small' END AS level_of_order
FROM orders

SELECT CASE WHEN total > 2000 THEN 'At least 2000'
            WHEN total > 1000 THEN 'Between 1000 and 2000'
            ELSE 'Less than 1000' END AS level_of_order,
        count(*) as order_count
FROM orders
GROUP BY 1

SELECT a.name,
       SUM(total_amt_usd) total_value,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'high value'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low' END AS level_of_customer
FROM orders o JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_value DESC;

SELECT a.name,
       SUM(total_amt_usd) total_value,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'high value'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low' END AS level_of_customer
FROM orders o JOIN accounts a ON o.account_id = a.id
WHERE DATE_PART('year', o.occurred_at) BETWEEN 2016 AND 2017
GROUP BY a.name
ORDER BY total_value DESC;

SELECT s.name, COUNT(o.*) total_orders,
        CASE WHEN COUNT(o.*) > 200 THEN 'top'
            ELSE 'not' END AS level_of_sp
FROM sales_reps s JOIN accounts a ON s.id = a.sales_rep_id JOIN orders o ON o.account_id=a.id
GROUP BY s.name
ORDER BY total_orders DESC;

SELECT s.name, COUNT(o.*) total_orders, SUM(o.total_amt_usd) total_sales,
        CASE WHEN COUNT(o.*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
             WHEN COUNT(o.*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
            ELSE 'low' END AS level_of_sp
FROM sales_reps s JOIN accounts a ON s.id = a.sales_rep_id JOIN orders o ON o.account_id=a.id
GROUP BY s.name
ORDER BY SUM(o.total_amt_usd) DESC;





