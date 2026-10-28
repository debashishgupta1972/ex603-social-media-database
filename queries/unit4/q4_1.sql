-- 4.1.1 What are the overall dwell-time statistics and number of distinct users?

SELECT
    COUNT(*) AS event_count,
    SUM(dwell_ms) AS total_dwell_ms,
    AVG(dwell_ms) AS avg_dwell_ms,
    MIN(dwell_ms) AS min_dwell_ms,
    MAX(dwell_ms) AS max_dwell_ms,
    COUNT(DISTINCT user_id) AS distinct_users
FROM likes;


-- 4.1.2 How many events and what average dwell time does each post have?

SELECT
    post_id,
    COUNT(*) AS event_count,
    AVG(dwell_ms) AS avg_dwell_ms
FROM likes
GROUP BY post_id
ORDER BY event_count DESC;


-- 4.1.3 Which posts have at least 10 events?

SELECT
    post_id,
    COUNT(*) AS event_count,
    AVG(dwell_ms) AS avg_dwell_ms
FROM likes
GROUP BY post_id
HAVING COUNT(*) >= 10
ORDER BY event_count DESC;


-- 4.1.4 How does performance vary by post and region?

SELECT
    post_id,
    client_country,
    COUNT(*) AS event_count,
    AVG(dwell_ms) AS avg_dwell_ms
FROM likes
GROUP BY post_id, client_country
ORDER BY post_id, client_country;