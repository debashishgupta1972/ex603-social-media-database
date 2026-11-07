-- Task 5.2 Part A
-- Which producers appear when LEFT JOIN keeps all posts, including posts with no events?

SELECT
    p.post_id,
    p.post_title,
    COUNT(l.like_id) AS event_count
FROM posts p
LEFT JOIN likes l
    ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;


-- Task 5.2 Part A
-- Which producers appear when INNER JOIN keeps only posts that have matching events?

SELECT
    p.post_id,
    p.post_title,
    COUNT(l.like_id) AS event_count
FROM posts p
INNER JOIN likes l
    ON p.post_id = l.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;


-- Task 5.2 Part A
-- How many producers are excluded by the INNER JOIN?

SELECT
    (SELECT COUNT(DISTINCT p.post_id)
     FROM posts p
     LEFT JOIN likes l ON p.post_id = l.post_id) AS left_join_producers,

    (SELECT COUNT(DISTINCT p.post_id)
     FROM posts p
     INNER JOIN likes l ON p.post_id = l.post_id) AS inner_join_producers,

    (SELECT COUNT(*)
     FROM posts p
     WHERE NOT EXISTS (
         SELECT 1
         FROM likes l
         WHERE l.post_id = p.post_id
     )) AS excluded_producers;


-- Task 5.2 Part A
-- Which producers are missing from the INNER JOIN because they have no events?

SELECT
    p.post_id,
    p.post_title
FROM posts p
LEFT JOIN likes l
    ON p.post_id = l.post_id
WHERE l.like_id IS NULL
ORDER BY p.post_id;


-- Task 5.2 Part B
-- Can a RIGHT JOIN return the same producer event counts as the LEFT JOIN?

SELECT
    p.post_id,
    p.post_title,
    COUNT(l.like_id) AS event_count
FROM likes l
RIGHT JOIN posts p
    ON l.post_id = p.post_id
GROUP BY p.post_id, p.post_title
ORDER BY p.post_id;


-- Task 5.2 Part B
-- What matching and unmatched records are visible with a FULL OUTER JOIN?

SELECT
    COALESCE(p.post_id, l.post_id) AS post_id,
    p.post_title,
    l.like_id,
    CASE
        WHEN p.post_id IS NULL THEN 'event_without_post'
        WHEN l.like_id IS NULL THEN 'post_without_event'
        ELSE 'matched'
    END AS relationship_status
FROM posts p
FULL OUTER JOIN likes l
    ON p.post_id = l.post_id
ORDER BY post_id, l.like_id;


-- Task 5.2 Part B
-- How many rows fall into each FULL OUTER JOIN relationship category?

SELECT
    CASE
        WHEN p.post_id IS NULL THEN 'event_without_post'
        WHEN l.like_id IS NULL THEN 'post_without_event'
        ELSE 'matched'
    END AS relationship_status,
    COUNT(*) AS row_count
FROM posts p
FULL OUTER JOIN likes l
    ON p.post_id = l.post_id
GROUP BY 1
ORDER BY 1;


-- Task 5.2 Part C
-- Which producers have never had an event, using NOT EXISTS?

SELECT
    p.post_id,
    p.post_title
FROM posts p
WHERE NOT EXISTS (
    SELECT 1
    FROM likes l
    WHERE l.post_id = p.post_id
)
ORDER BY p.post_id;


-- Task 5.2 Part C
-- Which producers have never had an event, using EXCEPT?

SELECT
    p.post_id,
    p.post_title
FROM posts p
INNER JOIN (
    SELECT post_id
    FROM posts

    EXCEPT

    SELECT post_id
    FROM likes
) missing
    ON p.post_id = missing.post_id
ORDER BY p.post_id;
