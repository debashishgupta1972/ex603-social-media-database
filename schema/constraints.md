# Unit 1 - Integrity Constraints

## 1. Primary Key Constraints

- `users.user_id` is the primary key of `users`.
  - Ensures every user is uniquely identifiable.

- `posts.post_id` is the primary key of `posts`.
  - Ensures every post is uniquely identifiable.

- `likes.like_id` is he primary key of `likes`.
  - Ensures every reaction event is uniquely identifiable.

- `hashtags.hashtag_id` is the primary key of `hashtags`.
  - Ensures every reaction event is uniquely identifiable.

- `post_hashtags_mapping` has a composite primary key of (`post_id`, `hashtag_id`).
  - Prevents the same hashtag from being assigned to the same post more than once.

## 2. Uniqueness Constraints

- `users.email` must be unique.
  - Two user accounts cannot use the same email address.

- `hashtags.hashtag_name` must be unique.
  - Prevents duplicate hashtag records. Example: Two separate entries for `#AI`.

- (`user_id`, `post_id`) in `likes` must be unique.
  - A user can have only one current reaction to a particular post. The reaction can be changed instead of creating another reaction row.

## 3. Foreign Key Constraints and ON DELETE Behavior

### posts.user_id &rarr; users.user_id
- `posts.user_id` must reference an existing `users.user_id`.
- **ON DELETE CASCADE**
- Justification: If a user account is deleted, the posts created by that user should also be removed rather than leaving posts with no valid owner.

### likes.user_id &rarr; users.user_id
- `likes.user_id` must reference an existing `users.user_id`.
- **ON DELETE CASCADE**
- Justification: If a user is deleted, that user's reactions should also be removed.

### likes.post_id &rarr; posts.post_id
- `likes.post_id` must reference an existing `posts.post_id`.
- **ON DELETE CASCADE**
- Justification: If a post is deleted, reactions to that post no longer have meaning and should also be deleted.

### post_hashtags_mapping.post_id &rarr; posts.post_id
- `post_hashtags_mapping.post_id` must reference an existing `posts.post_id`.
- **ON DELETE CASCADE**
- Justification: If a post is deleted, its hashtag mappings should also be removed.

### post_hashtags_mapping.hashtag_id &rarr; hashtags.hashtag_id
- `post_hashtags_mapping.hashtag_id` must reference an existing `hashtags.hashtag_id`.
- **ON DELETE CASCADE**
- Justification: If a hashtag is deleted, mappings that refer to that hashtag should also be removed.

## 4. Required and Domain Constraints

### users
- `user_id` must be a positive integer and cannot be NULL.
- `display_name` cannot be NULL or empty.
- `email` cannot be NULL or empty.
- `profile_description` may be NULL.
- `education` may be NULL.

### posts
- `post_id` must be a positive integer and cannot be NULL.
- `user_id` cannot be NULL and must reference an existing user.
- `post_title` cannot be NULL or empty.
- `post_visibility` must be either `public` or `friends`.
- `is_active` must be either `true` or `false`.
- `view_count` must be a non-negative integer.

### likes
- `like_id` must be a positive integer and cannot be NULL.
- `user_id` cannot be NULL.
- `post_id` cannot be NULL.
- `reaction_type` must be one of: `like`, `love`, `care`, `laugh`, or `sad`.
- `liked_at` cannot be NULL.
- `reaction_weight` must be an integer from 1 through 5.

### hashtags
- `hashtag_id` must be a positive integer and cannot be NULL.
- `hashtag_name` cannot be NULL or empty.
- `hashtag_name` must be unique.

### post_hashtags_mapping
- `post_id` cannot be NULL.
- `hashtag_id` cannot be NULL.
- The combination (`post_id`, `hashtag_id`) must be unique because it is the composite primary key.