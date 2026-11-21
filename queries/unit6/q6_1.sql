-- Task 6.1: How does each event's dwell time compare to its post average?
-- Window average keeps all 200 events.
SELECT like_id, post_id, dwell_ms,
       ROUND(AVG(dwell_ms) OVER (PARTITION BY post_id), 2) AS avg_post_dwell_ms
FROM likes
ORDER BY post_id, like_id;

-- Task 6.1: What does GROUP BY lose compared with a window average?
-- Returns 13 post-level rows instead of 200 event-level rows.
SELECT post_id, ROUND(AVG(dwell_ms), 2) AS avg_post_dwell_ms
FROM likes
GROUP BY post_id
ORDER BY post_id;

-- Task 6.1: How do three ranking methods handle ties in post activity?
WITH post_counts AS (
  SELECT p.post_id, COUNT(l.like_id) AS event_count
  FROM posts p LEFT JOIN likes l ON p.post_id = l.post_id
  GROUP BY p.post_id
)
SELECT post_id, event_count,
       ROW_NUMBER() OVER (ORDER BY event_count DESC, post_id) AS row_num,
       RANK() OVER (ORDER BY event_count DESC) AS rank_num,
       DENSE_RANK() OVER (ORDER BY event_count DESC) AS dense_rank_num
FROM post_counts
ORDER BY event_count DESC, post_id;

-- Task 6.1: Which of four activity bands does each post belong to?
-- NTILE balances group sizes, even if tied posts cross a band boundary.
WITH post_counts AS (
  SELECT p.post_id, COUNT(l.like_id) AS event_count
  FROM posts p LEFT JOIN likes l ON p.post_id = l.post_id
  GROUP BY p.post_id
)
SELECT post_id, event_count,
       NTILE(4) OVER (ORDER BY event_count DESC, post_id) AS activity_band
FROM post_counts
ORDER BY activity_band, event_count DESC, post_id;
