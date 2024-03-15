-- FULL OUTER JOIN

-- Finding Matched and Unmatched Rows with FULL OUTER JOIN
-- If unmatched rows existed (they don't for this query), 
-- you could isolate them by adding the following line to the end of the query:

SELECT *
  FROM accounts
 FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL

-- Inequality JOIN
-- If you recall from earlier lessons on joins, 
-- the join clause is evaluated before the where clause 
-- filtering in the join clause will eliminate rows before they are joined, 
-- while filtering in the WHERE clause will leave those rows in and produce some nulls.

SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name

SELECT orders.id,
       orders.occurred_at  AS order_date,
       events.*
FROM   orders
LEFT JOIN web_events events
       ON events.account_id = orders.account_id
      AND events.occurred_at < orders.occurred_at
WHERE  DATE_TRUNC('month', orders.occurred_at)=
       (SELECT DATE_TRUNC('month', MIN(orders.occurred_at)) FROM orders)
ORDER BY orders.occurred_at, orders.occurred_at

-- Self JOINs (often see in interview) 

SELECT o1.id AS o1_id,
    o1.account_id AS o1_account_id,
    o1.occurred_at AS o1_occurred_at,
    o2.id AS o2_id,
    o2.account_id AS o2_account_id,
    o2.occurred_at AS o2_occurred_at
FROM   orders o1
LEFT JOIN orders o2
ON     o1.account_id = o2.account_id
AND    o2.occurred_at > o1.occurred_at
AND    o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at

-- SELF_JOIN with unequal condition is commonly used

-- UNION/UNION ALL
Nice! UNION only appends distinct values. 
More specifically, when you use UNION, 
the dataset is appended, and any rows in 
the appended table that are exactly identical 
to rows in the first table are dropped. 
If you’d like to append all the values from the second table, 
use UNION ALL. You’ll likely use UNION ALL far more often than UNION.


-- PERFORMANCE TUNING

--1. One way to make a query run faster is to reduce the number 
-- of calculations that need to be performed. Some of the high-level 
-- things that will affect the number of calculations a given query will make include:

-- Table size
-- Joins
-- Aggregations
-- Query runtime is also dependent on some things that you can’t really control related to the database itself:

-- Other users running queries concurrently on the database
-- Database software and optimization
--  (e.g., Postgres is optimized differently than Redshift)

-- 2.The second thing you can do is to make joins less complicated, 
-- that is, reduce the number of rows that need to be evaluated. 
-- It is better to reduce table sizes before joining them. 
-- This can be done by creating subqueries and joining them to an outer query. 
-- Aggregating before joining will improve query speed; however, 
-- be sure that what you are doing is logically consistent. 
-- Accuracy is more important than run speed.


-- 3.add EXPLAIN COMMAND

