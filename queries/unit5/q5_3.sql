-- Task 5.3 Part A
-- What Cartesian product is produced by combining every post with every hashtag?

SELECT
    p.post_id,
    p.post_title,
    h.hashtag_id,
    h.hashtag_name
FROM posts p
CROSS JOIN hashtags h
ORDER BY p.post_id, h.hashtag_id;


-- Task 5.3 Part A
-- Do the source counts multiply to the CROSS JOIN row count?

SELECT
    (SELECT COUNT(*) FROM posts) AS post_count,
    (SELECT COUNT(*) FROM hashtags) AS hashtag_count,
    (SELECT COUNT(*) FROM posts CROSS JOIN hashtags) AS cross_join_count,
    (SELECT COUNT(*) FROM posts) *
    (SELECT COUNT(*) FROM hashtags) AS expected_count;


-- Task 5.3 Part B
-- How does PostgreSQL plan the three-table join from Task 5.1 Question 1?

EXPLAIN
SELECT
    u.user_id,
    u.user_name,
    p.post_id,
    p.post_title,
    l.liked_at
FROM likes l
INNER JOIN users u
    ON l.user_id = u.user_id
INNER JOIN posts p
    ON l.post_id = p.post_id
ORDER BY l.liked_at, l.like_id;


-- Optional: run the read-only query and include actual execution timing.

EXPLAIN ANALYZE
SELECT
    u.user_id,
    u.user_name,
    p.post_id,
    p.post_title,
    l.liked_at
FROM likes l
INNER JOIN users u
    ON l.user_id = u.user_id
INNER JOIN posts p
    ON l.post_id = p.post_id
ORDER BY l.liked_at, l.like_id;
