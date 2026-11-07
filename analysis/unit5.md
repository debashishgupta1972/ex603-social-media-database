# Unit 5 Analysis

## Task 5.1 — Connect Producers to Their Data

### Three-table join

A platform activity report could use the three-table join to show who performed each reaction, which post received it, and when the event happened. This gives leadership or an operations team a readable activity trail instead of only user and post identifiers.

### Junction table

The `post_hashtags` table is important because posts and hashtags have a many-to-many relationship. One post can have several hashtags, and one hashtag can belong to several posts. The junction table stores those relationships without repeating post or hashtag data.

For the three higher-failure posts identified in Unit 4:

- Post 1: `food`, `travel`
- Post 2: `fitness`, `tech`, `travel`
- Post 3: `food`, `tech`

There is no single hashtag shared by all three. Posts 1 and 2 share `travel`, Posts 1 and 3 share `food`, and Posts 2 and 3 share `tech`. Therefore, the higher failure rates cannot be explained by one common hashtag alone.

The self join compares the higher-failure posts with other posts from the same author country. The peer posts have different `like_count` values, so author country alone does not explain the higher failure rates.

## Task 5.2 — Find Records That Joins May Exclude

The LEFT JOIN returns all 15 posts, including Posts 14 and 15 with zero matching events. The INNER JOIN returns only 13 posts because it requires a matching row in the `likes` table.

The producers excluded by the INNER JOIN are:

- Post 14 (`post_id = 14`)
- Post 15 (`post_id = 15`)

They are excluded because there are no matching rows for those post IDs in the `likes` table.

A producer with no events may be inactive, newly added, not exposed to users, outside the time period represented by the event data, or affected by a data or instrumentation problem. The data only proves that there are no matching events for Posts 14 and 15; it does not explain why.

A report based only on an INNER JOIN would give leadership an incomplete picture because producers with zero events would disappear entirely. Leadership may want to identify these producers to investigate discoverability, visibility, onboarding, or data collection.

The RIGHT JOIN returns the same 15 producer-level results as the LEFT JOIN when the table order is reversed.

The FULL OUTER JOIN returned 202 rows: 200 matched event rows and 2 `post_without_event` rows. There were no `event_without_post` rows. This shows that a FULL OUTER JOIN can reveal unmatched records from either side in one result.

Both `NOT EXISTS` and `EXCEPT` identify the same two producers: Posts 14 and 15. `NOT EXISTS` checks whether each post lacks a matching event, while `EXCEPT` subtracts the set of post IDs found in `likes` from the complete set of post IDs.

## Task 5.3 — Join Performance and Execution Plans

### CROSS JOIN

The `posts` table contains 15 rows and the `hashtags` table contains 5 rows. Their CROSS JOIN produces 75 rows:

`15 × 5 = 75`

A Cartesian product could be useful when intentionally generating every possible post/hashtag combination for analysis or testing. In a normal reporting query, an unexpected Cartesian product may indicate a missing join condition and can cause the number of rows to grow very quickly.

### PostgreSQL execution plan

PostgreSQL chose a combination of a Hash Join and a Nested Loop.

First, it performs sequential scans on the `likes` and `users` tables. It builds a hash table for the `users` rows and uses a Hash Join on `likes.user_id = users.user_id`. This produces an estimated 200 rows.

PostgreSQL then uses a Nested Loop to join those results to `posts`. It uses `Memoize` with `l.post_id` as the cache key so repeated lookups for the same post can reuse an earlier result. The lookup on `posts` uses the primary-key index with the condition `post_id = l.post_id`.

Finally, PostgreSQL sorts the approximately 200 result rows by `liked_at` and `like_id`.

These choices make sense for the current dataset because `likes` and `users` are small enough that sequential scans are inexpensive, while the primary-key index on `posts` provides an efficient lookup for each post ID.

As the platform grows, the `likes` table is the most likely part of the query to become more expensive because it is the high-volume event table. A much larger `likes` table could change the cost of the sequential scan, join, and final sort. PostgreSQL might then choose different scan or join strategies depending on table size, indexes, data distribution, and the number of matching rows.

Understanding the selected join algorithms is useful because it shows how PostgreSQL is actually combining the tables and where query costs may increase as the data grows. Additional or different indexes, larger tables, different filtering conditions, or different data distributions could cause PostgreSQL to choose another plan, such as different index access, hash joins, nested loops, or merge joins.

## Reflection

PostgreSQL can choose a different join algorithm when the size or shape of the data changes. With small tables, scanning the whole table may be cheaper than using an index because only a small amount of data must be read. In the current execution plan, PostgreSQL uses sequential scans on `likes` and `users`, a Hash Join between them, and an indexed lookup into `posts`.

If the `likes` table grows to millions of rows, the cost of scanning and joining it will become much more important. New indexes on frequently used join or filter columns could make index-based access more attractive, especially when a query returns only a small portion of the table. If most rows still match, PostgreSQL may continue to prefer a sequential scan and hash-based processing.

The number of matching rows and the distribution of values also affect the planner's estimates. If inputs are already ordered on compatible join keys, a Merge Join could become more attractive. Accurate statistics are important because PostgreSQL uses them to estimate row counts and costs. Understanding the plan helps identify where performance may change as the platform grows and where indexes or query changes may eventually be useful.
