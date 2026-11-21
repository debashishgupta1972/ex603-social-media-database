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

## Task 6.3 — Reporting Patterns

### Part A: Top three events per post

**Question:** Which three reactions have the highest dwell time for each post?

I used `ROW_NUMBER() OVER (PARTITION BY post_id ORDER BY dwell_ms DESC, like_id)` in a CTE and filtered the outer query to ranks 1–3. I also used `FIRST_VALUE(dwell_ms)` to show each post's highest dwell time alongside its top events. The result returned **39 rows**: three events each for **13 posts** with events. Posts 14 and 15 have no events, so they do not appear.

Post 4 had the highest single dwell time, **70,860 ms** (event 43). I used `ROW_NUMBER()` so a post always has exactly three selected events; if two events tie, the smaller `like_id` comes first. This is a consistent tie-break rule, but it does not treat equal dwell times as equal ranks.

**Platform feature:** A post analytics panel could highlight the top **three** engagement events for each post. Three is enough to show more than one standout event while keeping the panel short and readable. Showing only one could overemphasize an outlier; showing ten could overwhelm a small report.

### Part B: Month-over-month activity

**Question:** Did the number of reaction events rise or fall compared with the previous calendar month?

I grouped events by month, used `LAG()` to retrieve the previous month's count, and calculated the percentage change using `NULLIF(previous_month_events, 0)` to avoid dividing by zero. I generated a complete monthly calendar and left-joined the counts so an absent month would appear as **zero** rather than causing `LAG()` to compare nonadjacent months.

The output showed **all 12 months of 2023**, with no missing months. January and February each had **21 events**. March fell to **11** (−47.62% from February), and May increased to **17** (+54.55% from April), the largest month-over-month increase. December had **16 events**, up **14.29%** from November's 14, but below January's 21.

A large change could reflect real user engagement, a promotion, post visibility, or a tracking issue. The platform team should investigate changes in post availability and event logging before assuming a product improvement or decline. Event counts alone cannot establish whether **spam-removal failure rates** are improving.

## Reflection (150–250 words)

A useful reporting question for our social media platform is: how does each reaction’s dwell time compare with the usual dwell time for its post? A window function makes this straightforward. Using `AVG(dwell_ms) OVER (PARTITION BY post_id)`, I can show the post’s average beside every individual reaction. That lets me spot events that are much shorter or longer than normal while still seeing their event IDs and original dwell times.

A `GROUP BY` query can calculate the same averages, but it reduces the result to one row per post. In our dataset, the window query returned 200 events, while `GROUP BY` returned only 13 post averages. To identify unusual reactions with `GROUP BY` alone, I would need another join or subquery to connect the averages back to the original events.

Window functions also help with trends. `LAG()` lets me compare one reaction with the previous reaction for the same post, and a running `SUM()` shows how activity builds over time. These are more informative than one overall average or total. The key benefit is context: the original rows stay visible, so the numbers are easier to check and explain.

