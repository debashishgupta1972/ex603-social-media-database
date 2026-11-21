-- Task 6.3, Part A: What are the top three dwell-time events for each post?
-- Ties at third place: ROW_NUMBER picks exactly three; smaller like_id wins a tie.
WITH ranked_events AS (
  SELECT post_id, like_id, dwell_ms,
         ROW_NUMBER() OVER (
           PARTITION BY post_id ORDER BY dwell_ms DESC, like_id
         ) AS event_rank,
         FIRST_VALUE(dwell_ms) OVER (
           PARTITION BY post_id ORDER BY dwell_ms DESC, like_id
         ) AS highest_dwell_ms
  FROM likes
)
SELECT post_id, like_id, dwell_ms, event_rank, highest_dwell_ms
FROM ranked_events
WHERE event_rank <= 3
ORDER BY post_id, event_rank;

-- Task 6.3, Part B: How did event counts change from one calendar month to the next?
-- Generate all months, including months with zero events, to prevent LAG skipping a month.
WITH monthly_counts AS (
  SELECT DATE_TRUNC('month', liked_at)::date AS month, COUNT(*) AS event_count
  FROM likes
  GROUP BY 1
),
calendar_months AS (
  SELECT GENERATE_SERIES(
      DATE_TRUNC('month', MIN(liked_at)),
      DATE_TRUNC('month', MAX(liked_at)),
      INTERVAL '1 month'
    )::date AS month
  FROM likes
),
monthly_series AS (
  SELECT c.month, COALESCE(m.event_count, 0) AS event_count
  FROM calendar_months c LEFT JOIN monthly_counts m ON c.month = m.month
),
monthly_comparison AS (
  SELECT month, event_count,
         LAG(event_count) OVER (ORDER BY month) AS previous_month_events
  FROM monthly_series
)
SELECT month, event_count, previous_month_events,
       ROUND(
         100.0 * (event_count - previous_month_events)
         / NULLIF(previous_month_events, 0), 2
       ) AS percent_change
FROM monthly_comparison
ORDER BY month;
