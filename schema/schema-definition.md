# Unit 1: Relation  Schema Definition

## 1. users
| Attribute | Domain | Key |
|---|---|---|
| user_id | Positive integer | Primary Key |
| display_name | Non-empty text | |
| email | Valid Email text | |
| profile_description | Text, optional | |
|  education | Text, optional | |

**Primary Key:** `user_id`

---

## 2. posts
| Attribute | Domain | Key |
|---|---|---|
| post_id | Positive integer | Primary Key |
| user_id | Positive integer | Foreign Key &rarr; users.user_id |
| post_title | Non-empty text | |
| post_description | Text | |
| post_visibility | List (One of): public, friends | |
| is_active | Boolean: true or false | |
| view_count | Non-negative integer | |

**Primary Key:** `post_id`

---

## 3. likes
| Attribute | Domain | Key |
|---|---|---|
| like_id | Positive integer | Primary Key |
| user_id | Positive integer | Foreign Key &rarr; users.user_id |
| post_id | Positive integer | Foreign Key &rarr; posts.post_id |
| reaction_type | List (One of): like, love, care, laugh, sad | |
| liked_at | Date and time | |
| reaction_weight | Positive integer from 1 to 5 | |

**Primary Key:** `like_id`

---

## 4. hashtags
| Attribute | Domain | Key |
|---|---|---|
| hashtag_id | Positive integer | Primary Key |
| hashtag_name | Non-empty text | |

**Primary Key:** `hashtag_id`

---

## 5. post_hashtags_mapping
| Attribute | Domain | Key |
|---|---|---|
| post_id | Positive integer | Foreign Key  &rarr; posts.post_id |
| hashtag_id | Positive integer | Foreign Key &rarr; hashtags.hashtag_id |

**Primary Key:** (`post_id`,`hashtag_id`)

