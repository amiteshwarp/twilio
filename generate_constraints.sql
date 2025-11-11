-- generate_constraints.sql

-- Generate ADD CONSTRAINT statements (PK, FK, UNIQUE, CHECK)
SELECT
  'DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = '
  || quote_literal(c.conname) || ' AND conrelid = '
  || c.conrelid || ') THEN ALTER TABLE '
  || quote_ident(n.nspname) || '.' || quote_ident(t.relname)
  || ' ADD CONSTRAINT ' || quote_ident(c.conname)
  || ' ' || pg_get_constraintdef(c.oid)
  || CASE WHEN c.contype = 'p' THEN ';' ELSE ' NOT VALID;' END
  || ' END IF; END $$ LANGUAGE plpgsql;'
FROM pg_constraint c
JOIN pg_class t ON c.conrelid = t.oid
JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE n.nspname = 'public';

-- Generate COMMENT ON TABLE
SELECT
  'COMMENT ON TABLE '
  || quote_ident(n.nspname) || '.' || quote_ident(t.relname)
  || ' IS ' || quote_literal(COALESCE(d.description, '')) || ';'
FROM pg_class t
JOIN pg_namespace n ON t.relnamespace = n.oid
LEFT JOIN pg_description d ON d.objoid = t.oid
WHERE t.relkind = 'r' AND n.nspname = 'public';

-- Generate COMMENT ON COLUMN
SELECT
  'COMMENT ON COLUMN '
  || quote_ident(n.nspname) || '.' || quote_ident(t.relname)
  || '.' || quote_ident(a.attname) || ' IS '
  || quote_literal(COALESCE(d.description, '')) || ';'
FROM pg_class t
JOIN pg_namespace n ON t.relnamespace = n.oid
JOIN pg_attribute a ON a.attrelid = t.oid
LEFT JOIN pg_description d ON d.objoid = a.attrelid AND d.objsubid = a.attnum
WHERE a.attnum > 0 AND NOT a.attisdropped
AND t.relkind = 'r' AND n.nspname = 'public';