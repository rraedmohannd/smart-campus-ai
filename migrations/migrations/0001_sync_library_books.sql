-- migrations/0001_sync_library_books.sql
-- Safe migration to ensure library_books has integer category_id FK to library_categories(id)
-- Preconditions: run only after taking a DB backup.

BEGIN;

-- 1) If category_id already exists, do nothing (idempotent check)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='library_books' AND column_name='category_id'
  ) THEN
    -- 2) Add temporary integer column
    ALTER TABLE library_books ADD COLUMN category_id_tmp INTEGER;
  END IF;
END$$;

-- 3) If there is an existing 'category' column, attempt to map names to ids
--    This assumes library_books.category stores category name; adjust mapping if different.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='library_books' AND column_name='category'
  ) THEN
    -- Map category names to library_categories.id where possible
    UPDATE library_books lb
    SET category_id_tmp = lc.id
    FROM library_categories lc
    WHERE lb.category = lc.name;
  END IF;
END$$;

-- 4) If category column exists and mapping done, drop old column and rename tmp
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='library_books' AND column_name='category'
  ) THEN
    -- drop old column
    ALTER TABLE library_books DROP COLUMN IF EXISTS category;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='library_books' AND column_name='category_id_tmp'
  ) THEN
    ALTER TABLE library_books RENAME COLUMN category_id_tmp TO category_id;
  END IF;
END$$;

-- 5) Ensure category_id column type is integer (if not, try to cast safely)
--    If category_id exists but is not integer, attempt to create new tmp int and map.
DO $$
DECLARE
  t text;
BEGIN
  SELECT data_type INTO t
  FROM information_schema.columns
  WHERE table_name='library_books' AND column_name='category_id';

  IF t IS NOT NULL AND t <> 'integer' THEN
    -- create tmp int column and try to cast numeric strings
    ALTER TABLE library_books ADD COLUMN category_id_tmp INTEGER;
    UPDATE library_books SET category_id_tmp = NULL;
    -- try to cast numeric strings to integer where possible
    UPDATE library_books
    SET category_id_tmp = (CASE WHEN (category_id ~ '^[0-9]+$') THEN (category_id::integer) ELSE NULL END);
    ALTER TABLE library_books DROP COLUMN category_id;
    ALTER TABLE library_books RENAME COLUMN category_id_tmp TO category_id;
  END IF;
END$$;

-- 6) Add FK constraint if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
    WHERE tc.table_name = 'library_books' AND tc.constraint_type = 'FOREIGN KEY' AND kcu.column_name = 'category_id'
  ) THEN
    ALTER TABLE library_books
      ADD CONSTRAINT fk_library_books_category
      FOREIGN KEY (category_id) REFERENCES library_categories(id)
      ON DELETE SET NULL;
  END IF;
END$$;

COMMIT;
