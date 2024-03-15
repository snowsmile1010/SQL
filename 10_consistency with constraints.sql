-- consistency with constraints

-- unique constraint
ALTER TABLE "users" ADD CONSTRAINT
"unique_usernames" UNIQUE ("username")

-- Primary Key Constraints

-- A primary key constraint is a special type of unique constraint: 
-- just like a unique constraint, it enforces unique values across a column or set of columns. 
-- In addition to that, it also enforces a NOT NULL, which is another database constraint that 
-- can be used by itself to ensure that a column's values cannot be null.


-- Unique & Primary Key Constraints Exercise: Solution

-- Remember: as a first step when confronted with a new database or dataset, 
-- always use all the introspection commands available to you — \d, \dt, \d+ — 
-- to observe and analyze the data before doing anything else.

ALTER TABLE "books" ADD PRIMARY KEY ("id");

ALTER TABLE "books" ADD UNIQUE ("isbn");

ALTER TABLE "authors" ADD PRIMARY KEY ("id");

ALTER TABLE "authors" ADD UNIQUE ("email_address");

ALTER TABLE "book_authors" ADD PRIMARY KEY ("book_id", "author_id");

ALTER TABLE "book_authors" ADD UNIQUE ("book_id", "contribution_rank");

-- foreign key constraint: ensure the values in the column are present in another column
-- We can add foreign key constraints while creating a table, 
-- either by adding a REFERENCES clause with the column definition, 
-- or by adding a CONSTRAINT … FOREIGN KEY clause along with all the column definitions.

FOREIGN KEY "referencing_column" 
REFERENCES "referenced_table" ("referenced_column")

-- If we omit the ("referenced_column") part of the foreign key definition, 
-- then it will be implied that we are referencing the primary key of the referenced table. 
-- This is one more thing that makes primary key constraints special compared to unique constraints.

-- delete content with foreign key constraint

-- Adding ON DELETE CASCADE to a foreign key constraint will 
-- have the effect that when the referenced data gets deleted, 
-- the referencing rows of data will be automatically deleted as well.

-- Adding ON DELETE SET NULL to a foreign key constraint will have the effect
--  that when the referenced data gets deleted, the referring column will have 
--  its value set to NULL. Since NULL is a special value, 
--  it won't break the foreign key constraint because it will be clear that 
--  that row of data is now referencing absolutely nothing.

-- exercise
ALTER TABLE "employees"
  ADD CONSTRAINT "valid_manager"
  FOREIGN KEY ("manager_id") REFERENCES "employees" ("id") ON DELETE SET NULL;

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_employee"
  FOREIGN KEY ("employee_id") REFERENCES "employees" ("id");

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_project"
  FOREIGN KEY ("project_id") REFERENCES "projects" ("id") ON DELETE CASCADE;

-- Check constraint
-- CHECK constraints allow us to implement custom business rules at the level of 
-- the database. Examples of such rules would be: "a product can't have a negative 
-- quantity" or "the discount price should always be less than the regular price".

CHECK (some expression that returns true or false)

-- final review
In this lesson, we've looked at database constraints as a way to make data more consistent and in line with business requirements. We've seen:

Unique constraints, which prevent duplicate values for a given column or columns, except for NULL which is allowed to appear many times.
Not null constraints, which prevent a column from containing the value NULL.
Primary key constraints, which, in addition to being a combination of Unique and Not Null constraints, are special: there can only be one per table, it's the official column or set of columns to uniquely identify a row in that table, and it's the default column(s) that will be used when setting up a foreign key constraint referencing that table.
Foreign key constraints, which restrict values in a column to only those values present in another column. They maintain what we called "referential integrity".
Check constraints, which can be used to implement custom checks against data that gets added or modified in our tables.


-- final practice

-- Identify the primary key for each table
-- Identify the unique constraints necessary for each table
-- Identify the foreign key constraints necessary for each table
-- In addition to the three types of constraints above, you'll have to implement some custom business rules:

-- Usernames need to have a minimum of 5 characters
-- A book's name cannot be empty
-- A book's name must start with a capital letter
-- A user's book preferences have to be distinct

-- Primary and unique keys
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");

ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id");


-- Foreign keys
ALTER TABLE "user_book_preferences"
  ADD FOREIGN KEY ("user_id") REFERENCES "users",
  ADD FOREIGN KEY ("book_id") REFERENCES "books";


-- Usernames need to have a minimum of 5 characters
ALTER TABLE "users" ADD CHECK (LENGTH("username") >= 5);


-- A book's name cannot be empty
ALTER TABLE "books" ADD CHECK(LENGTH(TRIM("name")) > 0);
-- trim: remove white space


-- A book's name must start with a capital letter
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);


-- A user's book preferences have to be distinct
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preference");
-- UNIQUE ("user_id", "preference"):combination unique

-- Conclusion
-- Design normalized data models
-- Bring models to life use DDL
-- Manipulate data with SQL DML
