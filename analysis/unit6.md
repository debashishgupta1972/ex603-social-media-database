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

## Task 6.2 — To complete after running the queries

## Task 6.3 — To complete after running the queries

## Reflection (150–250 words) — To complete after all Unit 6 queries
