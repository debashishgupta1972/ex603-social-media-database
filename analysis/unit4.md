## Task 4.1

The creator monetization team would use the per-post breakdown to identify posts that may need review.

The overall results show 200 events with an average dwell time of 18,140.95 ms. However, an overall average can hide differences between individual posts. Among posts with at least 10 events, failure rates ranged from 0% to 18.75%.

A post-level and regional breakdown is therefore more useful for identifying where failures are concentrated and which posts may need further investigation.

## Task 4.2

### Part A

The conditional aggregation shows the total number of events and the number of spam-removal failures for each post in one query. Post 2 had the highest number of failures with 3.

### Part B

The regional totals show 200 events and 12 spam-removal failures across the platform. India had 4 failures, the US and Brazil had 3 each, and the UK and Vietnam had 1 each.

The grand total gives leadership a platform-wide view, while the regional totals show where failures are concentrated.

### Part C

Using only posts with at least 10 events, the failure-rate baseline is 5.67%. The minimum threshold reduces the effect of very small samples when comparing producers.

## Reflection

Conditional aggregation calculates total events and failures in the same query over the same set of rows. This makes the comparison easier to understand and reduces the chance of using different filters for the numerator and denominator. It also keeps related measures together, which is useful when comparing posts or regions.

Using separate filtered queries could produce the same result, but it would require more SQL and may scan the same table more than once. Separate queries also make it easier to apply slightly different conditions by mistake, which could make the counts inconsistent.

With this dataset of 200 rows, the performance difference is small. With a table containing millions of events, however, scanning the data once can reduce unnecessary work and make the query easier to maintain. Conditional aggregation is therefore useful both for clarity and for efficiency. It gives the team one result set containing the totals needed to compare producer performance and identify areas that need further review.
