# Unit 6 Analysis

## Task 6.1 — Compare Events and Rank Producers

### Part 1: Window average versus GROUP BY

**Question:** Which individual reactions have an unusually high or low dwell time compared with other reactions on the same post?

I used `AVG(dwell_ms) OVER (PARTITION BY post_id)` to show each reaction's dwell time beside its post's average. This returned **200 rows**, one for every event. For example, Post 1's average was **16,026.36 ms** and Post 2's was **17,021.88 ms**. Comparing each event against its post's average makes unusual events easy to spot.

The `GROUP BY post_id` version returned **13 rows**, one for each post that had events. Its averages were the same, but it removed the individual event IDs and dwell times. A group average alone cannot tell us which particular events were unusually long or short. Posts 14 and 15 have no events, so neither query against `likes` returns them.

### Part 2: Ranking producers and handling ties

I ranked all **15 posts** by their number of reaction events using `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`. The query used a `LEFT JOIN` so Posts 14 and 15, which have no events, were still included.

Post 6 ranked first with **21 events**; Post 8 had **20**, and Post 10 had **19**. Posts 5 and 7 both had **18** events. `ROW_NUMBER()` assigned them positions 4 and 5, while both `RANK()` and `DENSE_RANK()` gave them rank 4. The next post (Post 12, with 17 events) received rank 6 from `RANK()` but rank 5 from `DENSE_RANK()`.

**Platform feature:** A public post-activity leaderboard could use `DENSE_RANK()` because posts with the same number of events should share a rank, without gaps in the displayed ranking. `ROW_NUMBER()` is better when the application strictly needs one unique position for every post.

### Part 3: Four activity bands with NTILE

I used `NTILE(4)` to divide the 15 posts into four groups based on their event counts, from most active (Band 1) to least active (Band 4).

Posts 5 and 7 each had **18 events**, but Post 5 fell into **Band 1** while Post 7 fell into **Band 2**. This happens because `NTILE(4)` balances the number of rows in each band rather than keeping tied counts together. The bands are useful for a rough activity breakdown, but would be unfair as strict reward or eligibility thresholds unless tied posts are handled separately.

## Task 6.2 — Compare Events Over Time

### Part A: Previous and next event with LAG and LEAD

**Question:** Is the dwell time for Post 2 increasing or decreasing from one reaction to the next?

I used `LAG()` and `LEAD()` with `PARTITION BY post_id ORDER BY liked_at, like_id` to compare each event with the previous and next events on the same post. I calculated the difference as the current dwell time minus the previous dwell time, then filtered the results to **Post 2**. The query returned **16 events**. The first event had no previous value, and the last had no next value, so those fields were `NULL`.

The largest increase between consecutive events was **27,980 ms** (May 4, 2023), while the largest decrease was **32,590 ms** (June 3, 2023). A large difference could indicate a change in engagement worth investigating, but reactions with a dwell time of zero may have been removed. The team should check reaction status and removal reasons before drawing conclusions about user behavior.

### Part B: Running total and moving average

**Question:** How much activity has the platform recorded so far, and how does recent daily activity compare?

I counted events by calendar date, then used `SUM(event_count) OVER (ORDER BY event_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` for the running total. Unlike a plain `SUM()`, the running total shows **when** each level was reached, not just the final count.

I chose a target of **200 recorded events over the full dataset period**, January through December 2023. The running total reached **200 on December 28, 2023**, meeting that target. This is a full-period target, not a quarterly target.

I used a **7-row moving average** (`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`) to smooth changes in event counts across the seven most recent dates with activity. It ended at **1.14 events per recorded day**. I chose seven rows because it gives a short-term view without reacting too much to a single busy day. A shorter window would change more sharply; a longer one would smooth out more variation. Since the query only includes dates that had events, these **seven rows are not necessarily seven consecutive calendar days**. A true seven-calendar-day average would also need days with zero events.

**ROWS versus RANGE:** `ROWS` counts physical rows in the specified order, so two rows with the same ordering value are still treated as separate rows. `RANGE` defines the frame using the ordering values and can include all rows tied at a boundary. Our daily aggregation produces one row per date, so date ties do not occur in this output.

### Part C: Find gaps between recorded events

**Question:** Which posts went more than 30 days between consecutive reaction events?

I used `LAG(liked_at)` to find the previous event time for each post, calculated the gap in days in a CTE, and filtered the outer query to gaps **greater than 30 days**.

The largest gaps found were:

| Post | Gap between events |
| --- | ---: |
| 9 | 112.58 days |
| 12 | 106.74 days |
| 5 | 93.01 days |
| 11 | 89.47 days |
| 2 | 86.63 days |

These are **gaps in recorded reactions**, not proof that the posts were disabled or that the database lost data. For example, Post 9 has no recorded reaction between January 5 and April 28, 2023. This could reflect real inactivity, limited visibility, or incomplete tracking. The event table alone cannot identify the cause. The team should compare these periods with post visibility records and event-collection logs before deciding whether to address engagement or data quality.

## Task 6.3 — To complete after running the queries

## Reflection (150–250 words) — To complete after all Unit 6 queries
