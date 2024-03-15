-- From guidline #1-#4, there will be the following 5 tables:
-- snuser [id, use_rname]
-- topic [id, topic_name, description]
-- post [id, title, content_url, content_text,user_id, topic_id]
-- comment [id, content,user_id, post_id, parent_comment_id]
-- vote [id, user_id, post_id, vote]

-- === Create snuser table ===
-- i.	Each username has to be unique
-- ii.	Usernames can be composed of at most 25 characters
-- iii.	Usernames can’t be empty

CREATE TABLE "snuser"
(
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(25) NOT NULL, 
  last_login TIMESTAMP,
  CONSTRAINT "unique_user_name" UNIQUE ("user_name"), 
  CONSTRAINT "no_empty_user_name" CHECK (LENGTH(TRIM("user_name")) > 0)
);


-- === Create topic table ===
-- i.	Topic names have to be unique.
-- ii.	The topic’s name is at most 30 characters
-- iii.	The topic’s name can’t be empty
-- iv.	Topics can have an optional description of at most 500 characters.

CREATE TABLE "topic"
(
  id SERIAL PRIMARY KEY,
  topic_name VARCHAR(30) NOT NULL,
  description VARCHAR(500),
  CONSTRAINT "unique_topic" UNIQUE ("topic_name"),
  CONSTRAINT "no_empty_topic_name" CHECK (LENGTH(TRIM("topic_name")) > 0)
);


-- === Create post table ===
-- i.	Posts have a required title of at most 100 characters
-- ii.	The title of a post can’t be empty.
-- iii.	Posts should contain either a URL or a text content, but not both.
-- iv.	If a topic gets deleted, all the posts associated with it should be automatically deleted too.
-- v.	If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.

CREATE TABLE "post" 
(
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  content_url VARCHAR(400),
  content_text TEXT,
  created_on TIMESTAMP,
  topic_id INTEGER NOT NULL REFERENCES "topic" ON DELETE CASCADE,
  user_id INTEGER REFERENCES "snuser" ON DELETE SET NULL,
  CONSTRAINT "no_empty_title" CHECK (LENGTH(TRIM("title")) > 0),
  CONSTRAINT "exclusive_url_text" CHECK (
    (LENGTH(TRIM("content_url")) > 0 AND LENGTH(TRIM("content_text")) = 0) OR
    (LENGTH(TRIM("content_url")) = 0 AND LENGTH(TRIM("content_text")) > 0)
  )

);



-- === Create comment table ===
-- i.	A comment’s text content can’t be empty.
-- ii.	Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
-- iii.	If a post gets deleted, all comments associated with it should be automatically deleted too.
-- iv.	If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.
-- v.	If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too.

CREATE TABLE "comment"
(
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  post_id INTEGER REFERENCES NOT NULL "post" ON DELETE CASCADE,
  user_id INTEGER REFERENCES "snuser" ON DELETE SET NULL,
  parent_comment_id INTEGER REFERENCES "comment" ON DELETE CASCADE
  CONSTRAINT "no_empty_content" CHECK(LENGTH(TRIM("content")) > 0)
);

--  === Create vote table ===
-- i.	Hint: you can store the (up/down) value of the vote as the values 1 and -1 respectively.
-- ii.	If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
-- iii.	If a post gets deleted, then all the votes for that post should be automatically deleted too.
--  A user can only cast one vote on a given post
CREATE TABLE "vote"
(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES "snuser" ON DELETE SET NULL,
  post_id INTEGER REFERENCES NOT NULL "post" ON DELETE CASCADE,
  vote INTEGER NOT NULL,
  CONSTRAINT "vote_up_down" CHECK("vote" = 1 OR "vote" = -1),
  CONSTRAINT "one_vote_per_user_per_post" UNIQUE (user_id, post_id)
);



-- Mitigate bad_db to new_db
-- 1. mitigate username from 'bad_posts' and 'bad_comments' to 'snuser' table -- 'user_name' column

INSERT INTO "snuser" ("user_name")
  SELECT DISTINCT username
  FROM bad_posts
  UNION
  SELECT DISTINCT username
  FROM bad_comments
  UNION
  SELECT DISTINCT regexp_split_to_table(upvotes, ',')
  FROM bad_posts
  UNION
  SELECT DISTINCT regexp_split_to_table(downvotes, ',')
  FROM bad_posts;

-- 2. mitigate 'topic' from 'bad_posts' to 'topic' table -- 'topic_name' column

INSERT INTO "topic" ("topic_name")
SELECT DISTINCT topic FROM bad_posts;

-- 3. mitigate 5 columns from 'bad_posts' to 'post'

INSERT INTO "post" ("user_id", "topic_id", "title", "content_url","content_text")
SELECT s.id, tp.id, LEFT(b.title, 100),b.url,b.text_content
FROM bad_posts b
JOIN snuser s ON b.username = s.use_rname
JOIN topic tp ON b.topic = tp.topic_name;

-- 4. mitigate 3 columns from 'bad_comments' to 'post'
INSERT INTO "comment" ("post_id","user_id", "content")
SELECT po.id, s.id, b.text_content
FROM bad_comments b
JOIN snuser s ON b.username = s.user_name
JOIN post po ON po.id = b.post_id;

-- 5. mitigate 3 columns into 'vote'

WITH upvote AS (SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes,',') upvoters
                FROM bad_posts) 


INSERT INTO "vote" ("post_id","user_id", "vote")
SELECT up.id, s.id, 1 vote_up
FROM upvote up
JOIN snuser s ON s.user_name=up.upvoters;


WITH downvote AS (SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes,',') downvoters 
                  FROM bad_posts) 

INSERT INTO "vote" ("post_id","user_id", "vote")
SELECT d.id, s.id, -1 AS vote_down
FROM downvote d
JOIN snuser s ON s.user_name=d.downvoters;


-- Create index for fast queries
-- constraints, automatically create INDEXES for the columns on which they are defined
-- CREATE INDEX ON "snuser" ("user_name" VARCHAR_PATTERN_OPS);(unique constrait)
-- CREATE INDEX ON "topic" ("topic_name" VARCHAR_PATTERN_OPS);(unique constrait)
CREATE INDEX ON "post" ("title" VARCHAR_PATTERN_OPS);