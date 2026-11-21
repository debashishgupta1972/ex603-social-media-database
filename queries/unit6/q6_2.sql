-- Task 6.2, Part A: How does Post 2's dwell time change relative to adjacent events?
WITH event_trends AS (
  SELECT like_id, post_id, liked_at, dwell_ms,
         LAG(dwell_ms) OVER (PARTITION BY post_id ORDER BY liked_at, like_id) AS previous_dwell_ms,
         LEAD(dwell_ms) OVER (PARTITION BY post_id ORDER BY liked_at, like_id) AS next_dwell_ms
  FROM likes
)
SELECT *, dwell_ms - previous_dwell_ms AS delta_ms
FROM event_trends
WHERE post_id = 2
ORDER BY liked_at, like_id;

-- Task 6.2, Part B: How does the running event count approach 200,
-- and what is the moving average over seven recorded event dates?
-- ROWS means seven recorded dates, not seven consecutive calendar days.
WITH daily_events AS (
  SELECT liked_at::date AS event_date, COUNT(*) AS event_count
  FROM likes
  GROUP BY liked_at::date
)
SELECT event_date, event_count,
       SUM(event_count) OVER (
         ORDER BY event_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total,
       ROUND(AVG(event_count) OVER (
         ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_7_rows
FROM daily_events
ORDER BY event_date;

-- Task 6.2, Part C: Which posts have over 30 days between recorded events?
WITH event_gaps AS (
  SELECT post_id, like_id, liked_at,
         LAG(liked_at) OVER (
           PARTITION BY post_id ORDER BY liked_at, like_id
         ) AS previous_event
  FROM likes
)
SELECT post_id, previous_event, liked_at AS current_event,
       ROUND(EXTRACT(EPOCH FROM (liked_at - previous_event)) / 86400, 2) AS gap_days
FROM event_gaps
WHERE liked_at - previous_event > INTERVAL '30 days'
ORDER BY gap_days DESC, post_id;
