-- window function
-- Window Function: A window function is a calculation across a set of rows in a table that are somehow related to the current row. This means we’re typically:

-- Calculating running totals that incorporate the current row or,
-- Ranking records across rows, inclusive of the current one
-- A window function is similar to aggregate functions combined with group by clauses but have one key difference: Window functions retain the total number of rows between the input table and the output table (or result). Behind the scenes, the window function is able to access more than just the current row of the query result.

-- When window functions are used, you’ll notice new column names like the following:

-- Average running price
-- Running total orders
-- Running sum sales
-- Rank
-- Percentile

-- core window func
Partition by: A subclause of the OVER clause. Similar to GROUP BY.
Over: Typically precedes the partition by that signals what to “GROUP BY”.
Aggregates: Aggregate functions that are used in window functions, too (e.g., sum, count, avg).

-- Ranking
Row_number(): Ranking function where each row gets a different number.
Rank(): Ranking function where a row could get the same rank if they have the same value.
Dense_rank(): Ranking function similar to rank() but ranks are not skipped with ties.

-- Advanced
Aliases: Shorthand that can be used if there are several window functions in one query.
Percentiles: Defines what percentile a value falls into over the entire table.
Lag/Lead: Calculating differences between rows’ values.

--  The sequence of Code for Window Functions
AGGREGATE_FUNCTION (column_1) OVER
 (PARTITION BY column_2 ORDER BY column_3)
  AS new_column_name;

PARTITION BY: A subclause of the OVER clause. 
I like to think of PARTITION BY as the GROUP BY equivalent in window functions. 
PARTITION BY allows you to determine what you’d like to “group by” within the window function. 
Most often, you are partitioning by a month, region, etc. as you are tracking changes over time.

OVER: This syntax signals a window function and precedes the details of the window function itself.

Typically, when you are writing a window function that tracks changes or a metric over time, 
you are likely to structure your syntax with the following components:

1.An aggregation function (e.g., sum, count, or average) + the column you’d like to track
2.OVER
3.PARTITION BY + the column you’d like to “group by”
4.ORDER BY (optional and is often a date column)
5.AS + the new column name

-- practice
-- Create a running total of standard_amt_usd (in the orders table) over 
-- order time with no date truncation. Your final table should have two columns: 
-- one with the amount being added for each new row, and a second with the running total.


SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders

-- Now, modify your query from the previous quiz to include partitions. 
-- Still create a running total of standard_amt_usd (in the orders table) over 
-- order time, but this time, date truncate occurred_at by year and partition by 
-- that same year-truncated occurred_at variable.

SELECT standard_amt_usd, DATE_PART('year',occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_PART('year',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

-- e.g.

SELECT id, account_id, standard_qty, DATE_TRUNC('month', occurred_at) AS month, 
DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS dense_rank, 
SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_standard_qty, 
COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS count_standard_qty, 
AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_standard_qty, 
MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS min_standard_qty, 
MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS max_standard_qty 
FROM orders

-- WITH and WITHOUT ORDER BY
The ORDER BY clause is one of two clauses integral to window functions. 
The ORDER and PARTITION define what is referred to as the “window”—the ordered 
subset of data over which calculations are made. 
Removing ORDER BY just leaves an unordered partition; 
in our query's case, each column's value is simply an aggregation 
(e.g., sum, count, average, minimum, or maximum) of all the standard_qty 
values in its respective account_id.

The easiest way to think about this - leaving the ORDER BY out is equivalent to "ordering" 
in a way that all rows in the partition are "equal" to each other. 
Indeed, you can get the same effect by explicitly adding the ORDER BY clause like this:
 ORDER BY 0 (or "order by" any constant expression), or even, more emphatically, ORDER BY NULL.

--  RANK
Row_number(): Ranking is distinct amongst records even with ties in what the table is ranked against.
Rank(): Ranking is the same amongst tied values and ranks skip for subsequent values.
Dense_rank(): Ranking is the same amongst tied values and ranks do not skip for subsequent values.

-- Query1
SELECT ROW_NUMBER() OVER(ORDER BY date_time) AS rank,
       date_time
FROM   db;
-- Query2
SELECT RANK() OVER(ORDER BY date_time) AS rank,
       date_time
FROM   db;
-- Query3
SELECT DENSE_RANK() OVER(ORDER BY date_time) AS rank,
       date_time
FROM   db;

-- PRACTICE
Select the id, account_id, and total variable from the orders table, 
then create a column called total_rank that ranks this total amount of 
paper ordered (from highest to lowest) for each account using a partition. 
Your final table should have these four columns.

SELECT id, account_id, total, DENSE_RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM   orders;

-- Aliases for multiple window function
SELECT order_id,
       order_total,
       order_price,
       SUM(order_total) OVER monthly_window AS running_monthly_sales,
       COUNT(order_id) OVER monthly_window AS running_monthly orders,
       AVG(order_price) OVER monthly_window AS average_monthly_price
FROM   amazon_sales_db
WHERE  order_date < '2017-01-01'
WINDOW monthly_window AS
       (PARTITION BY month(order_date) ORDER BY order_date);

-- LAG/LEAD
When you need to compare the values in adjacent 
rows or rows that are offset by a certain number, 
LAG and LEAD come in very handy.

-- LAG function
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
      ) sub
-- LEAD function

SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
     ) sub


-- practice
Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis.
 You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so.
  In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.

SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
) sub

-- Percentiles Use Case
When there are a large number of records that need to be ranked, individual ranks (e.g., 1, 2, 3, 4…) are ineffective in helping teams determine the best of the distribution from the rest. Percentiles help better describe large datasets. For example, a team might want to reach out to the Top 5% of customers.

You can use window functions to identify what percentile (or quartile, or any other subdivision) a given row falls into. The syntax is NTILE(# of buckets). In this case, ORDER BY determines which column to use to determine the quartiles (or whatever number of ‘tiles you specify).

Percentiles Syntax
The following components are important to consider when building a query with percentiles:

NTILE + the number of buckets you’d like to create within a column (e.g., 100 buckets would create traditional percentiles, 4 buckets would create quartiles, etc.)
OVER
ORDER BY (optional, typically a date column)
AS + the new column name

Expert Tip
In cases with relatively few rows in a window, the NTILE function doesn’t calculate exactly as you might expect. 
For example, If you only had two records and you were measuring percentiles, you’d expect one record to define the 1st percentile, 
and the other record to define the 100th percentile. Using the NTILE function, what you’d actually see is one record in the 1st percentile, 
and one in the 2nd percentile.

In other words, when you use an NTILE function but the number of rows in the partition is 
less than the NTILE(number of groups), then NTILE will divide the rows into as many groups 
as there are members (rows) in the set but then stop short of the requested number of groups. 
If you’re working with very small windows, keep this in mind and consider using quartiles or similarly small bands.

SELECT  customer_id,
        composite_score,
        NTILE(100) OVER(ORDER BY composite_score) AS percentile
FROM    customer_lead_score;

-- PRACTICE
-- Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased,
--  and one of four levels in a standard_quartile column.

SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty DESC) AS standard_quartile
  FROM orders 
 ORDER BY account_id DESC

--  Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
--  Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
--  and one of two levels in a gloss_half column.
SELECT
       account_id,
       occurred_at,
       gloss_qty,
       NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
  FROM orders 
 ORDER BY account_id DESC

-- Use the NTILE functionality to divide the orders for each account into 100 levels 
-- in terms of the amount of total_amt_usd for their orders.
--  Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, 
-- and one of 100 levels in a total_percentile column.

SELECT
       account_id,
       occurred_at,
       total_amt_usd,
       NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
  FROM orders 
 ORDER BY account_id DESC