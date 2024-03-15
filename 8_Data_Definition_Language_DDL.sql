-- CREATE TABLE (https://www.postgresql.org/docs/9.6/sql-createtable.html)
-- Exercise: Creating Tables
CREATE TABLE "employees" (
  "id" SERIAL,
  "emp_name" TEXT,
  "manager_id" INTEGER
);

CREATE TABLE "employee_phones" (
  "emp_id" INTEGER,
  "phone_number" TEXT
);

-- Data type 
-- 
-- DATE/TIME: https://www.postgresql.org/docs/9.6/datatype-datetime.html

-- ALTER TABLE: Modifying Table Structure with
-- You may use ALTER TABLE with ADD COLUMN 
-- You may use ALTER TABLE with ALTER COLUMN to change the data type
-- You may use ALTER TABLE with DROP COLUMN to completely remove a column

-- e.g.
ALTER TABLE "students" ALTER COLUMN "email_address" SET DATA TYPE VARCHAR;
ALTER TABLE "courses" ALTER COLUMN "rating" SET DATA TYPE REAL;

-- Other DDL Commands
-- Postgres offers three other DDL commands: DROP, TRUNCATE, and COMMENT.

-- DROP TABLE will completely remove a table's structure and all associated data from the database
-- TRUNCATE TABLE keeps the table structure intact, but removes all the data in the table.

UPDATE "people" SET "last_name" =
  SUBSTR("last_name", 1, 1) ||
  LOWER(SUBSTR("last_name", 2));

-- Change the born_ago column to date_of_birth
ALTER TABLE "people" ADD column "date_of_birth" DATE;

UPDATE "people" SET "date_of_birth" = 
  (CURRENT_TIMESTAMP - "born_ago"::INTERVAL)::DATE;

ALTER TABLE "people" DROP COLUMN "born_ago";