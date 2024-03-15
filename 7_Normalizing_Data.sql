-- Denormalized data exhibits many issues:

-- Inconsistent data types across a given column, making it difficult to manage and reason about
-- Repeated columns, which disable us from scaling the number of items of related data
-- Repeated values in a column, which make querying on those values more challenging
-- The inability to uniquely identify rows of data to target them for manipulation
-- Irrelevant dependencies, which cause repetitions and anomalies
-- In this lesson, we'll learn how to normalize data through "normal forms" in order to avoid all the problems mentioned above.

-- First Normal Form — 1NF:
-- same type，single value, no repeat column,unique ID!!

-- Make all values in a column consistently of the same data type
-- Make sure each cell contains only a single value
-- Make sure there are no repeating columns for the same data (e.g. category 1, 2, 3…)
-- Enable the rows of data to be uniquely identified through a column or combination of columns

-- Candidate key: a set of one or more columns that can uniquely identify a row in a table
-- Primary key: the key we choose from the candidate keys to uniquely represent a row in a table.


-- Second Normal Form Recipe:
-- No partial dependency!!

-- Bring table to First Normal Form
-- Remove all partial dependencies
-- Partial dependency: a column that isn't part of the primary key, 
-- and that depends only on part of the primary key. 
-- For example, if the primary key (PK) is (student_no, course_id), 
-- then a column called student_name would be a partial dependency on the PK because it only depends on the student_no.


-- Recipe for Third Normal Form:
-- NO transitive dependencies!
-- Sometimes follow the 3rd normal form lead to absurd results, 
-- NOT follow 3rd Normal form is acceptable (LIKE addresses and something that do not often change)

-- Bring the table to Second Normal Form
-- Eliminate transitive dependencies

-- Transitive dependency: when a column that isn't part of the primary key depends 
-- on the primary key, but through another non-key column. 
-- For example, a table of movie reviews would have a surrogate id column as its PK,
--  and a movie_id column to refer to the movie which is being reviewed. 
--  If the table also contains a movie_name column, 
--  then that movie_name is transitively dependent on the PK, because it depends on it through movie_id.

-- practice
-- Correct! While book_title, the primary key, 
-- fully determines the author, author_rating is determined by author. 
-- Therefore we should add an authors table which would contain the rating, 
-- and leave only the author in the books table.

-- The pragmatic approach to resolving a lack of normal forms:

1.Identify entities in the denormalized or partially normalized table
2.Create new tables for each entity
3.Go back to the original table and use it to relate the ids to each other
-- In our case, this was more logically breaking out the data into artists, agents, and agent_phones tables.

-- !!!Conclusion

-- Denormalized data contains repetitions that can cause anomalies
-- Rules exist to normalize data

-- First Normal Form:
-- Single-valued columns
-- No repeating columns
-- Consistent data across a column
-- Uniquely identify a row

-- Second Normal Form: 
-- No partial dependencies

-- Third Normal Form: 
-- No transitive dependencies

-- Sometimes, it's OK to violate normal forms; use your best judgement

