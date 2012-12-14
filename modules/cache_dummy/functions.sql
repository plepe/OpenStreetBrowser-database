-- Cache functions --
-- cache_insert(id, k, v[, depend][, outdate])
--   inserts a key/value pair into the cache
--   - id is the string representation of an object (e.g. 'rel_1234'). If this
--     object already exists in the cache, it will be updated
--   - k is the key (a string)
--   - v is a value and will be handled as string
--   - depend is an array of depending objects, e.g. a the geometric
--     representation of a way depends on the way and it's nodes. You don't
--     have to add the id of the object to the depend-array.
--   - outdate specifies an interval after which the content will be
--     deprecated. Specify the interval as pgsql interval, 
--     e.g. '5 days 3 hours'. Defaults to '1 month'.
--   - returns the value
-- Example: cache_insert('rel_1234', 'foo', 'bar', Array['node_1'], '1 hour');
-- 
-- cache_search(id, k)
--   returns a cached value for this object, if no value exists 'null' is
--   returned
-- Example: cache_search('rel_1234', 'foo') -> 'bar'
--
-- cache_remove(id)
--   deletes all values which belong to this object or depend on it
-- Example: cache_remove('node_1')
--
-- cache_clean()
--   removes all outdated entries

CREATE OR REPLACE FUNCTION cache_search(text, text) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return null;
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_insert(text, text, text, text[], interval) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
  content alias for $3;
BEGIN
  return content;
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_insert(text, text, text) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return (select cache_insert($1, $2, $3, null::text[], null::interval));
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_insert(text, text, text, text[]) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return (select cache_insert($1, $2, $3, $4, null::interval));
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_insert(text, text, text, interval) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return (select cache_insert($1, $2, $3, null::text[], $4));
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_insert(text, text, text, text) RETURNS text AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return (select cache_insert($1, $2, $3, null::text[], cast($4 as interval)));
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_remove(text) RETURNS bool AS $$
#variable_conflict use_variable
DECLARE
  depend_id alias for $1;
BEGIN
  return true;
END;
$$ LANGUAGE plpgsql volatile;

CREATE OR REPLACE FUNCTION cache_clean() RETURNS bool AS $$
#variable_conflict use_variable
DECLARE
BEGIN
  return true;
END;
$$ LANGUAGE plpgsql volatile;
