# Unit 2 Design Decisions

## Foreign Key Constraints

| Foreign Key | ON DELETE | Reason |
|---|---|---|
| `posts.user_id -> users.user_id` | CASCADE | If a user is removed, their posts should also be removed. |
| `likes.user_id -> users.user_id` | CASCADE | If a user is removed, their reactions should not remain without an owner. |
| `likes.post_id -> posts.post_id` | CASCADE | If a post is removed, reactions to that post should also be removed. |
| `post_hashtags_mapping.post_id -> posts.post_id` | CASCADE | If a post is removed, its hashtag links are no longer needed. |
| `post_hashtags_mapping.hashtag_id -> hashtags.hashtag_id` | CASCADE | If a hashtag is removed, its links to posts should also be removed. |
---
## ON DELETE Reasoning

For `posts.user_id`, I used `ON DELETE CASCADE` because when a user account is removed, that user's posts should not remain in the system without an owner.

For `likes.user_id`, I used `ON DELETE CASCADE` because reactions created by a deleted user should also be removed.

For `likes.post_id`, I used `ON DELETE CASCADE` because reactions have no meaning if the post they belong to is deleted.

For the post-hashtag mapping table, I used `ON DELETE CASCADE` for both foreign keys. If either the post or hashtag is removed, the relationship between them should also disappear automatically.

---

## CHECK Constraints

`chk_posts_visibility` prevents a post from storing an invalid visibility value. Without this check, values outside `public` or `friends` could be entered by mistake.

`chk_posts_view_count` prevents a negative number of views. A negative count would not make sense and could otherwise be stored through bad input or an application error.

`chk_likes_reaction_type` prevents unsupported reaction values. Without it, inconsistent values such as `happy` or `thumbsup` could be stored.

`chk_likes_reaction_weight` keeps the reaction weight between 1 and 5. Without this check, values such as 0, 6, or negative numbers could be entered.

---

## Schema

The database contains five tables: `users`, `posts`, `likes`, `hashtags`, and `post_hashtags_mapping`.

The design uses foreign keys to maintain relationships, CHECK constraints to prevent invalid values, and a composite primary key in `post_hashtags_mapping` to represent the many-to-many relationship between posts and hashtags.

Deleting a user, post, or hashtag automatically removes dependent records where appropriate using `ON DELETE CASCADE`.

---
