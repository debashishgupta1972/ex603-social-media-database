# Unit 5 Finding

The Unit 4 analysis identified Posts 2, 3, and 1 as the higher-failure posts that deserve review. Their hashtag data does not show one common tag shared by all three, so the evidence does not support treating the problem as a single hashtag-specific issue. I recommend reviewing the spam-removal events for these posts, including the affected users, event timing, and moderation reasons, to determine whether the failures are related to content behavior, user behavior, or moderation rules.

Posts 14 and 15 require a different response. The `likes` table contains no matching events for either post, so they disappear from an INNER JOIN. Leadership should investigate why they have no event records instead of treating them as high-failure producers. Possible areas to investigate include discoverability, visibility, onboarding, the time period represented by the event data, and event instrumentation.

The data does not establish the reason for their lack of events. Therefore, the high-failure group should be investigated for failure reduction, while the no-event group should be investigated for activation or data-quality issues.
