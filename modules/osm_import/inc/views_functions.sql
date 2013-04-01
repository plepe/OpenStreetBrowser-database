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

create or replace function osm_all(bbox geometry, where_expr text DEFAULT NULL::text, options hstore DEFAULT ''::hstore) returns setof osm_template_with_type
as $body$
DECLARE
BEGIN
  return query select id, tags, way, 'type=>node, form=>point'::hstore from osm_point(bbox, where_expr, options);
  return query select id, tags, way, 'type=>way, form=>line'::hstore from osm_line(bbox, where_expr, options);
  return query select id, tags, way,
    (CASE
      WHEN substr(id, 1, 1)='R' THEN 'type=>rel, form=>polygon'::hstore
      ELSE 'type=>way, form=>polygon'::hstore
    END)
    from osm_polygon(bbox, where_expr, options);
  return query select id, tags, way, 'type=>rel, form=>special'::hstore from osm_rel(bbox, where_expr, options);
  return;
END;
$body$ language 'plpgsql';

create or replace function osm_linepoly(bbox geometry, where_expr text DEFAULT NULL::text, options hstore DEFAULT ''::hstore) returns setof osm_template_with_type
as $body$
DECLARE
BEGIN
  return query select id, tags, way, 'type=>way, form=>line'::hstore from osm_line(bbox, where_expr, options);
  return query select id, tags, way,
    (CASE
      WHEN substr(id, 1, 1)='R' THEN 'type=>rel, form=>polygon'::hstore
      ELSE 'type=>way, form=>polygon'::hstore
    END)
    from osm_polygon(bbox, where_expr, options);
  return;
END;
$body$ language 'plpgsql';
