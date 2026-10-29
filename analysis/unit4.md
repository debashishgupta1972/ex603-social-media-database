## Task 4.1

The creator monetization team would use the per-post breakdown to identify posts that may need review.

The overall results show 200 events with an average dwell time of 18,140.95 ms. The overall aggregate does not show how activity is distributed across individual posts or which posts differ from the overall pattern.

For Question 3, I used a minimum of 10 events because very small event counts can make comparisons less meaningful while still keeping enough posts for comparison.

A post-level and regional breakdown helps show where activity differs and which posts may need further investigation.

## Task 4.2

### Part A

The two questions answered together are how many total events each post had and how many of those events were spam-removal failures. Post 2 had the highest number of failures with 3.

### Part B

A regional director can use the regional totals to compare areas. The platform grand total shows 200 events and 12 spam-removal failures, providing an overall reference for the regional results.

### Part C

Using only posts with at least 10 events, the failure-rate baseline is 5.67%. This provides a baseline for comparing higher-volume producers.

## Reflection

Conditional aggregation calculates total events and failures in the same query over the same set of rows. This makes the comparison easier to understand and reduces the chance of using different filters for the numerator and denominator. It also keeps related measures together, which is useful when comparing posts or regions.

Using separate filtered queries could produce the same result, but it would require more SQL and may scan the same table more than once. Separate queries also make it easier to apply slightly different conditions by mistake, which could make the counts inconsistent.

With this dataset of 200 rows, the performance difference is small. With a table containing millions of events, however, scanning the data once can reduce unnecessary work and make the query easier to maintain. Conditional aggregation is therefore useful both for clarity and for efficiency. It gives the team one result set containing the totals needed to compare producer performance and identify areas that need further review.
