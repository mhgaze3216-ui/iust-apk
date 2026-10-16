ALTER TABLE feed_posts
  ALTER COLUMN course_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS scope TEXT NOT NULL DEFAULT 'course'
    CHECK (scope IN ('course', 'campus'));

CREATE INDEX IF NOT EXISTS feed_posts_scope_created_idx
  ON feed_posts(scope, created_at DESC);
