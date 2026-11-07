-- Task 5.1 Question 1
-- Who performed each event, which post was involved, and when did it happen?

SELECT
    u.user_id,
    u.user_name,
    p.post_id,
    p.post_title,
    l.liked_at
FROM likes l
INNER JOIN users u
    ON l.user_id = u.user_id
INNER JOIN posts p
    ON l.post_id = p.post_id
ORDER BY l.liked_at, l.like_id;


-- Task 5.1 Question 2
-- Which hashtags are associated with the high-failure posts identified in Unit 4?

SELECT
    p.post_id,
    p.post_title,
    h.hashtag_name
FROM posts p
INNER JOIN post_hashtags ph
    ON p.post_id = ph.post_id
INNER JOIN hashtags h
    ON ph.hashtag_id = h.hashtag_id
WHERE p.post_id IN (1, 2, 3)
ORDER BY p.post_id, h.hashtag_name;


-- Task 5.1 Question 3
-- How do the Unit 4 high-failure posts compare with posts from the same author country?

SELECT
    target.post_id AS target_post_id,
    target.post_title AS target_post_title,
    target.author_country,
    target.like_count AS target_like_count,
    peer.post_id AS peer_post_id,
    peer.post_title AS peer_post_title,
    peer.like_count AS peer_like_count,
    peer.is_visible AS peer_is_visible
FROM posts target
INNER JOIN posts peer
    ON target.author_country = peer.author_country
   AND target.post_id <> peer.post_id
WHERE target.post_id IN (1, 2, 3)
ORDER BY target.post_id, peer.post_id;
