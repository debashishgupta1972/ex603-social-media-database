/* 
   ===============================================
   EX 603 Assignment 2 - schema.sql
   Theme: Social Media
   Author: Debashish Gupta
   Target: PostgreSQL 14+
   ===============================================
*/

/*Reset. Drop tables in reverse creation order.*/
DROP TABLE IF EXISTS post_hashtags_mapping CASCADE;
DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS hashtags CASCADE;
DROP TABLE IF EXISTS users CASCADE;

/* Create users table first because other tables reference it */
CREATE TABLE users (
   user_id INTEGER GENERATED ALWAYS AS IDENTITY,
   display_name VARCHAR(100) NOT NULL,
   email VARCHAR(255) NOT NULL,
   profile_description TEXT,
   education VARCHAR(150),

   CONSTRAINT pk_users PRIMARY KEY (user_id),
   CONSTRAINT uq_users_email UNIQUE (email)
);

/* Create hashtags table  early because other tables reference it */
CREATE TABLE hashtags (
   hashtag_id INTEGER GENERATED ALWAYS AS IDENTITY,
   hashtag_name VARCHAR(100) NOT NULL,

   CONSTRAINT pk_hashtags PRIMARY KEY (hashtag_id),
   CONSTRAINT uq_hashtags_tag_name UNIQUE (hashtag_name)
);

/* Create posts table */
CREATE TABLE posts (
   post_id INTEGER GENERATED ALWAYS AS IDENTITY,
   user_id INTEGER NOT NULL,
   post_title VARCHAR(200) NOT NULL,
   post_description TEXT,
   post_visibility VARCHAR(20) NOT NULL DEFAULT 'public',
   is_active BOOLEAN NOT NULL DEFAULT TRUE,
   view_count INTEGER NOT NULL DEFAULT 0,

   CONSTRAINT pk_posts PRIMARY KEY (post_id),

   CONSTRAINT fk_posts_user
      FOREIGN KEY (user_id) 
      REFERENCES users(user_id)
      ON DELETE CASCADE,

   CONSTRAINT chk_posts_visibility
      CHECK (post_visibility IN ('public', 'friends')),

   CONSTRAINT chk_posts_view_count
      CHECK (view_count >= 0)
);

/* Create likes table */
CREATE TABLE likes (
   like_id INTEGER GENERATED ALWAYS AS IDENTITY,
   post_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   liked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   reaction_type VARCHAR(20) NOT NULL,
   reaction_weight INTEGER NOT NULL DEFAULT 1,

   CONSTRAINT pk_likes PRIMARY KEY (like_id),

   CONSTRAINT fk_likes_post
      FOREIGN KEY (post_id) 
      REFERENCES posts(post_id)
      ON DELETE CASCADE,

   CONSTRAINT fk_likes_user
      FOREIGN KEY (user_id) 
      REFERENCES users(user_id)
      ON DELETE CASCADE,

   CONSTRAINT chk_likes_reaction_weight
      CHECK (reaction_weight BETWEEN 1 AND 5),

   CONSTRAINT chk_likes_reaction_type
      CHECK (reaction_type IN ('like', 'love', 'care', 'sad', 'laugh'))
);

/* Create post_hashtags_mapping table */
CREATE TABLE post_hashtags_mapping (
   post_id INTEGER NOT NULL,
   hashtag_id INTEGER NOT NULL,

   CONSTRAINT pk_post_hashtags_mapping PRIMARY KEY (post_id, hashtag_id),

   CONSTRAINT fk_post_hashtags_mapping_post
      FOREIGN KEY (post_id) 
      REFERENCES posts(post_id)
      ON DELETE CASCADE,

   CONSTRAINT fk_post_hashtags_mapping_hashtag
      FOREIGN KEY (hashtag_id)
      REFERENCES hashtags(hashtag_id)
      ON DELETE CASCADE
);