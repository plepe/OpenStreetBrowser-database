create or replace function osm_rel_members(bbox geometry, member_table text, where_expr text DEFAULT NULL::text, options hstore DEFAULT ''::hstore) returns setof osm_rel_members
as $body$
DECLARE
  sql text;
  sql_members text;
BEGIN
  sql:=partition_geometry_compile_query('osm_rel', bbox, where_expr, options);
  sql_members:=partition_geometry_compile_query(member_table, bbox, null, null);

  sql:=$$select rel.id, member.id, rel.member_ids, rel.member_role, rel.tags, member.tags, rel.way, member.way from $$ ||
       $$ (select *, unnest(member_ids) as member_id, unnest(member_roles) as member_role from ($$||sql||$$) rel1) rel $$ ||
       $$ join ($$||sql_members||$$) member on member.id=rel.member_id$$;

  return query execute sql;

  return;
END;
$body$ language 'plpgsql';

