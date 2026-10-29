-- Task 4.2 Part A
-- How many total events and failures did each producer have?

SELECT
    post_id,
    COUNT(*) AS total_events,
    SUM(CASE
        WHEN reaction_status = 'removed'
         AND removal_reason = 'Spam detected'
        THEN 1 ELSE 0
    END) AS failure_events
FROM likes
GROUP BY post_id;


-- Task 4.2 Part B
-- What are the failure totals by region and for the whole platform?

SELECT
    CASE
        WHEN GROUPING(client_country) = 1 THEN 'Platform Total'
        ELSE client_country
    END AS region,
    COUNT(*) AS total_events,
    SUM(CASE
        WHEN reaction_status = 'removed'
         AND removal_reason = 'Spam detected'
        THEN 1 ELSE 0
    END) AS failure_events
FROM likes
GROUP BY ROLLUP(client_country);


-- Task 4.2 Part C
-- What is the failure-rate baseline for high-volume producers?

WITH producer_summary AS (
    SELECT
        post_id,
        COUNT(*) AS total_events,
        SUM(CASE
            WHEN reaction_status = 'removed'
             AND removal_reason = 'Spam detected'
            THEN 1 ELSE 0
        END) AS failure_events
    FROM likes
    GROUP BY post_id
)
SELECT
    100.0 * SUM(failure_events) / SUM(total_events) AS failure_rate
FROM producer_summary
WHERE total_events >= 10;
