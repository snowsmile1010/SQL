-- JOIN
SELECT *
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

SELECT orders.standard_qty, orders.gloss_qty, orders.poster_qty,
        accounts.website, accounts.primary_poc
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

-- FOREIGN KEY Crow-foot Notation?

-- Alias: AS/ no AS
Select t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2

-- same statement with Alias 
FROM tablename AS t1
JOIN tablename2 AS t2

FROM tablename t1
JOIN tablename2 t2

-- practice with JOIN (alias)
SELECT web_events.*, accounts.name
FROM web_events
JOIN accounts 
ON web_events.account_id = accounts.id
WHERE accounts.name = 'Walmart';

SELECT region.name r, sales_reps.name s, accounts.name a
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
JOIN accounts
On sales_reps.id = accounts.sales_rep_id
ORDER BY accounts.name;

SELECT region.name r, accounts.name a, total_amt_usd/(total+0.01) unit_price
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
JOIN accounts ON sales_reps.id = accounts.sales_rep_id
JOIN orders ON accounts.id = orders.account_id;

-- IMPORTANT: AND replace WHERE in JOIN Statement
-- (Video ON join and fitering)
-- AND : like a WHERE clause execute BEFORE the JOIN 
-- WHERE: WHERE clause happens AFTER the JOIN

SELECT orders.*, accounts.* 
FROM orders 
LEFT JOIN accounts ON orders.account_id = accounts.id 
WHERE accounts.sales_rep_id = 321500

SELECT orders.*, accounts.* 
FROM orders LEFT JOIN accounts ON orders.account_id = accounts.id 
AND accounts.sales_rep_id = 321500

-- A simple rule to remember is that, 
-- when the database executes this "AND" query, 
-- it executes the join and everything in the ON clause first. 
-- Think of this as building the new result set. 
-- That result set is then filtered using the WHERE clause.

-- The fact that this example is a left join is important. 
-- Because inner joins only return the rows for which the two tables match, 
-- moving this filter to the ON clause of an inner join will produce 
-- the same result as keeping it in the WHERE clause.


-- practice
SELECT r.name region, s.name sales, a.name account
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;

SELECT r.name region, s.name sales, a.name account
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

SELECT r.name region, s.name sales, a.name account
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;

SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON a.id = o.account_id
WHERE o.standard_qty > 100;

SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON a.id = o.account_id
WHERE o.standard_qty > 100 AND poster_qty >50;

SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) unit_price
FROM region r JOIN sales_reps s ON r.id = s.region_id
JOIN accounts a ON a.sales_rep_id = s.id
JOIN orders o ON a.id = o.account_id
WHERE o.standard_qty > 100 AND poster_qty >50
ORDER BY unit_price DESC;

SELECT DISTINCT a.name account, w.channel channel
FROM accounts a JOIN web_events w ON a.id = w.account_id
WHERE a.id = 1001;

SELECT a.name account, o.occurred_at sale_time, o.total total_qty, o.total_amt_usd total_usd
FROM accounts a JOIN orders o ON accounts.id = o.account_id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;


