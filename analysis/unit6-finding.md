# Unit 6 Closing Memo — Is the Platform Improving?

## Question 1: Is the failure problem getting better or worse?

**Failure definition:** An event in `likes` whose `reaction_status = 'removed'` and `removal_reason = 'Spam detected'`. This is the same definition used in Unit 4.

The original BU reference dataset contains **200 reaction events** during 2023, of which **12** meet that definition: an overall **6.00%** failure rate.

| Quarter | Events | Spam-removal failures | Failure rate |
| --- | ---: | ---: | ---: |
| Q1 (Jan–Mar) | 53 | 4 | 7.55% |
| Q2 (Apr–Jun) | 48 | 3 | 6.25% |
| Q3 (Jul–Sep) | 51 | 3 | 5.88% |
| Q4 (Oct–Dec) | 48 | 2 | 4.17% |

**Conclusion:** The quarterly failure rate improved over the period in the data, falling from **7.55% in Q1** to **4.17% in Q4**, a decrease of **3.38 percentage points**. However, the monthly picture is uneven: December had **2 failures in 16 events (12.50%)**, versus zero spam-removal failures in October and November. The dataset is small, so these short-term changes should not be treated as evidence of a lasting trend without more data.

Separately, the month-over-month event-count query in Task 6.3 found **21 events** in January and **16** in December. Fewer events do not necessarily mean the failure problem worsened; total activity and failure rate measure different things.

## Question 2: What should the team do next quarter?

1. **Monitor failure rates monthly and by post**, using the same failure definition and reporting both event counts and percentages. Investigate whether December's increase persists.
2. **Review spam-removal cases and moderation rules**, especially for posts with recurring failures. Check the recorded reasons and individual events before changing moderation behavior.
3. **Check data completeness and post visibility.** Unit 6 gap detection found intervals of **112.58 days for Post 9** and **106.74 days for Post 12** without recorded reactions. These gaps do not prove a logging failure or intentional inactivity, so investigate instrumentation and visibility before acting.
4. **Use a larger period of data** before setting strict performance targets. With only 200 events and 12 spam-removal failures, even one or two cases materially change the monthly rate.

## Evidence and reproducibility

- **Unit 4, Task 4.2:** Defined failures as spam-detected removed reactions; counted 12 in 200 events.
- **Unit 6, Task 6.2:** Measured event gaps with `LAG()`.
- **Unit 6, Task 6.3:** Compared monthly event counts using `LAG()` and a complete month calendar.
- **Quarterly rates above:** Calculated directly from the 200 event rows in BU's provided `social.sql`. The following SQL was **run and verified in DataGrip** against the restored PostgreSQL database. Its four quarterly counts and rates matched the memo exactly.

```sql
-- Task 6.4: Is the spam-removal failure rate improving by quarter?
SELECT
    DATE_TRUNC('quarter', liked_at)::date AS quarter_start,
    COUNT(*) AS total_events,
    COUNT(*) FILTER (
        WHERE reaction_status = 'removed'
          AND removal_reason = 'Spam detected'
    ) AS spam_failures,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE reaction_status = 'removed'
              AND removal_reason = 'Spam detected'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS failure_rate_pct
FROM likes
GROUP BY 1
ORDER BY 1;
```
