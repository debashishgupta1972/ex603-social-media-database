# Unit 1 &mdash; Modelling Justification and Reflection

## Modelling Justification

I designed the database around five main tables: `users`, `posts`, `likes`, `hashtags`, and `post_hashtags_mapping`. My goal was to keep the design simple while making sure the database can prevent common data problems.

For the main tables, I used a separate ID as the primary key. For example, `user_id` identifies a user, `post_id` identifies a post, `like_id` identifies a reaction, and `hashtag_id` identifies a hashtag. I chose IDs instead of fields such as email, display name, or hashtag name because those values may change. An ID gives each record a stable identity even if other information is updated.

The `post_hashtags_mapping` table is different because its primary key is made from both `post_id` and `hashtag_id`. This makes sense because its purpose is only to connect a post with a hashtag. The combined key also prevents the same hashtag from being attached to the same post more than once.

Foreign keys are used to make sure related records really exist. For example, a post must belong to an existing user, and a like must point to an existing user and post. The hashtag mapping must also point to an existing post and hashtag. This prevents records from referring to data that does not exist.

I chose `ON DELETE CASCADE` for these relationships. If a user is deleted, their posts and likes should not remain without an owner. If a post is deleted, its likes and hashtag mappings no longer have a purpose. In the same way, if a hashtag is removed, its mappings should also be removed. Using cascade keeps the database clean and avoids orphaned records.

I also chose to enforce several rules directly in the database instead of depending only on the application. For example, email addresses and hashtag names must be unique. A post visibility value must be either `public` or `friends`. The view count cannot be negative, and a reaction type must come from an allowed set such as `like`, `love`, `care`, `laugh`, or `sad`. A user can also have only one current reaction to the same post.

I prefer putting these rules in the database because different applications could use the same database in the future. If the rules existed only in one application, another program could accidentally store invalid data. Database constraints provide one consistent layer of protection regardless of which application is writing the data.

## Reflection

One design decision that another designer could reasonably make differently is storing `view_count` directly in the `posts` table.

Another approach would be to create a separate table containing one record for every time a user views a post. That design would provide much more detail. It could show who viewed a post, when they viewed it, and possibly how many times the same user viewed it.

I chose to keep `view_count` in the `posts` table because I expect the platform to read this number very often. A social media application may need to quickly display popular posts or filter posts with more than a certain number of views. Reading one number directly from the post record is simpler and faster than counting a very large number of view records each time.

The disadvantage is that this design stores less detail and the count must be updated whenever a new view occurs. For this project, I think that trade-off is reasonable because it keeps the model simpler and supports the kind of frequent read operations a social media platform is likely to perform.