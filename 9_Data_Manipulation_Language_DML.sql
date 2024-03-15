-- DML:
-- in order to add (INSERT), modify (UPDATE), and remove (DELETE) 

-- INSERT
-- FORM 1: INSERT new data
INSERT INTO table (column list) VALUES (first row of values), ...

-- FORM 2: transfer data from tb1 to tb2
-- INSERT INTO table_name (column list in the order it's returned by the SELECT) SELECT …
-- INSERT INTO "categories" ("name") SELECT DISTINCT "category" FROM "books"

-- e.gs
INSERT INTO "people_emails"
SELECT
  "p"."id",
  REGEXP_SPLIT_TO_TABLE("dn"."emails", ',')
FROM "denormalized_people" "dn"
JOIN "people" "p" ON (
  "dn"."first_name" = "p"."first_name"
  AND "dn"."last_name" = "p"."last_name"
);

-- Update
-- UPDATE table_name SET col1=newval1, … WHERE …
-- The WHERE part of the syntax is exactly the same as for a SELECT. 
-- Among other things, if you don't include a WHERE clause, 
-- you'll be updating all the rows in the table, 
-- which is not often what you'd want to do!

-- e.g.
UPDATE “users” SET “mood” = ‘Low’ WHERE “happiness_level” < 33;

-- Delete
-- The basic syntax for deleting rows from a table is DELETE FROM table_name WHERE …. 
-- Just like SELECT and UPDATE, omitting the WHERE clause will delete all rows from the table. 
-- Again, this is rarely what you want to do! Contrary to TRUNCATE TABLE, 
-- doing a DELETE without a WHERE won't allow you to restart the sequence if you have one in your table. 
-- More importantly, in a future lesson we'll learn about indexing as a way to make queries perform faster in the presence of large amounts of data. 
-- Running TRUNCATE will also clear these indexes, which will further accelerate queries once new data gets inserted in that table.
DELETE FROM table_name WHERE ….

-- Data Manipulation: Transactions

-- To help with these kinds of situations, Postgres and other relational databases provide transactional guarantees that can be remembered under the acronym ACID. They are:

-- Atomicity: The database guarantees that a transaction will either register all the commands in a transaction, or none of them.
-- Consistency: The database guarantees that a successful transaction will leave the data in a consistent state, one that obeys all the rules that you've setup. We've seen simple rules like limiting the number of characters in a VARCHAR column, and we'll see many more in the next lesson
-- Isolation: The database guarantees that concurrent transactions don't "see each other" until they are committed. Committing a transaction is a command that tells the database to execute all the commands we passed to it since we started that transaction.
-- Durability: The database guarantees that once it accepts a transaction and returns a success, the changes introduced by the transaction will be permanently stored on disk, even if the database crashes right after the success response.

-- EXERCISE:
-- For this exercise, you'll be given a table called user_data, 
-- and asked to make some changes to it. 
-- In order to make sure that your changes happen coherently, 
-- you're asked to turn off auto-commit, 
-- and create your own transaction around all the queries you will run.


-- Here are the changes you will need to make:

-- 1.Due to some obscure privacy regulations, all users from California and New York must be removed from the data set.
-- 2.For the remaining users, we want to split up the name column into two new columns: first_name and last_name.
-- 3.Finally, we want to simplify the data by changing the state column to a state_id column.
-- First create a states table with an automatically generated id and state abbreviation.
-- Then, migrate all the states from the dataset to that table, taking care to not have duplicates.
-- Once all the states are migrated and have their unique ID, add a state_id column to the user_data table.
-- Use the appropriate query to make the state_id of the user_data column match the appropriate ID from the new states table.
-- Remove the now redundant state column from the user_data table.
-- Remember

-- Do everything in a transaction
BEGIN;


-- Remove all users from New York and California
DELETE FROM "user_data" WHERE "state" IN ('NY', 'CA');


-- Split the name column in first_name and last_name
ALTER TABLE "user_data"
  ADD COLUMN "first_name" VARCHAR,
  ADD COLUMN "last_name" VARCHAR;

UPDATE "user_data" SET
  "first_name" = SPLIT_PART("name", ' ', 1),
  "last_name" = SPLIT_PART("name", ' ', 2);

ALTER TABLE "user_data" DROP COLUMN "name";


-- Change from state to state_id
CREATE TABLE "states" (
  "id" SMALLSERIAL,
  "state" CHAR(2)
);

INSERT INTO "states" ("state")
  SELECT DISTINCT "state" FROM "user_data";

ALTER TABLE "user_data" ADD COLUMN "state_id" SMALLINT;

UPDATE "user_data" SET "state_id" = (
  SELECT "s"."id"
  FROM "states" "s"
  WHERE "s"."state" = "user_data"."state"
);

ALTER TABLE "user_data" DROP COLUMN "state";