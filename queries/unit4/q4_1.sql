-- Task 4.1 Question 1
-- What are the overall dwell-time statistics, and how many distinct users appear?

SELECT
    COUNT(*) AS event_count,
    SUM(dwell_ms) AS total_dwell_ms,
    AVG(dwell_ms) AS avg_dwell_ms,
    MIN(dwell_ms) AS min_dwell_ms,
    MAX(dwell_ms) AS max_dwell_ms,
    COUNT(DISTINCT user_id) AS distinct_user_count
FROM likes;
