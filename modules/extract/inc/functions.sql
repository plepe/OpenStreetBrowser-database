create or replace function extract_classify_point
(text, hstore, geometry)
returns boolean as $$
declare
  _osm_id   alias for $1;
  osm_tags  alias for $2;
  osm_way   alias for $3;
  result hstore:=null;
begin
  if ( coalesce(osm_tags->E'place', '') in (E'continent', E'country', E'state', E'city', E'county', E'region', E'town', E'island', E'ocean', E'sea')) then
    result:=E'"icon_text"=>"[name];[ref];[operator]", "name"=>"Important Places", "match"=>"place=continent;country;state;city;county;region;town;island;ocean;sea", "description"=>"", "icon"=>"", "importance"=>"urban", "type"=>"point", "rule_id"=>"4da682ca817a4"'::hstore;
  end if;

  if result is not null then
    --raise notice 'classified point %', _osm_id;
    return true;
  end if;

  return false;
end;
$$ language plpgsql immutable;

create or replace function extract_classify_line(
text, hstore, geometry)
returns boolean as $$
declare
  _osm_id	alias for $1;
  osm_tags	alias for $2;
  osm_way	alias for $3;
  tag_voltage	text[];
  tag_width	text[];
  tag_est_width	text[];
  result	hstore:=null;
begin
  tag_voltage:=split_semicolon(osm_tags->E'voltage');
  tag_width:=split_semicolon(osm_tags->E'width');
  tag_est_width:=split_semicolon(osm_tags->E'est_width');

  if ( coalesce(osm_tags->E'highway', '') in (E'motorway', E'motorway_link', E'trunk', E'trunk_link', E'primary', E'primary_link', E'secondary', E'tertiary')) then
    result:=E'"line_text"=>"[name];[ref];[operator]", "name"=>"Highways", "match"=>"highway=motorway;motorway_link;trunk;trunk_link;primary;primary_link;secondary;tertiary", "description"=>"", "icon"=>"", "importance"=>"international", "type"=>"line", "rule_id"=>"4da434dceee5b"'::hstore;
  elseif ( coalesce(osm_tags->E'aeroway', '') in (E'runway')) then
    result:=E'"line_text"=>"[name];[ref];[operator]", "name"=>"Aeroways", "match"=>"aeroway=runway", "description"=>"", "icon"=>"", "importance"=>"international", "type"=>"line", "rule_id"=>"4da43523eee5d"'::hstore;
  elseif (( coalesce(osm_tags->E'railway', '') in (E'rail'))) and (( coalesce(osm_tags->E'usage', '') in (E'main'))) then
    result:=E'"line_text"=>"[name];[ref];[operator]", "name"=>"Railways", "match"=>"railway=rail usage=main", "description"=>"", "icon"=>"", "importance"=>"international", "type"=>"line", "rule_id"=>"4da43534eee5f"'::hstore;
  elseif (( coalesce(osm_tags->E'power', '') in (E'line'))) and (oneof_between(tag_voltage, 150000, true, null, null)) then
    result:=E'"line_text"=>"[name];[ref];[operator]", "name"=>"High Voltage Power Lines", "match"=>"power=line voltage>=150kV", "description"=>"", "icon"=>"", "importance"=>"international", "type"=>"line", "rule_id"=>"4da4355aeee61"'::hstore;
  elseif ((( coalesce(osm_tags->E'waterway', '') in (E'river', E'canal'))) and (oneof_between(tag_width, 15, true, null, null))) or ((( coalesce(osm_tags->E'waterway', '') in (E'river', E'canal'))) and (oneof_between(tag_est_width, 15, true, null, null))) then
    result:=E'"line_text"=>"[name];[ref];[operator]", "name"=>"Waterways", "match"=>"waterway=river;canal width>=15m, waterway=river;canal est_width>=15m", "description"=>"", "icon"=>"", "importance"=>"international", "type"=>"line", "rule_id"=>"4da4357eeee63"'::hstore;
  end if;

  if result is not null then
    -- raise notice 'classified line %', _osm_id;
    return true;
  end if;

  return false;
end;
$$ language plpgsql immutable;

CREATE OR REPLACE FUNCTION extract_init() RETURNS boolean AS $$
DECLARE
  num_rows  int;
  match text;
BEGIN
  match:='((tags @> E''"place"=>"continent"''::hstore) or (tags @> E''"place"=>"country"''::hstore) or (tags @> E''"place"=>"state"''::hstore) or (tags @> E''"place"=>"city"''::hstore) or (tags @> E''"place"=>"county"''::hstore) or (tags @> E''"place"=>"region"''::hstore) or (tags @> E''"place"=>"town"''::hstore) or (tags @> E''"place"=>"island"''::hstore) or (tags @> E''"place"=>"ocean"''::hstore) or (tags @> E''"place"=>"sea"''::hstore))';

  execute 'insert into osm_point_extract ( '
    || 'select * '
    || 'from ( '
    || '  select '
    || '    id, '
    || '    tags, '
    || '    way '
    || '  from '
    || '    osm_point '
    || '  where '
    || match
    || ') x '
    || 'where '
    || '  extract_classify_point(id, tags, way));';

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_point_extract (%)', num_rows;

  match:='(((tags @> E''"highway"=>"motorway"''::hstore) or (tags @> E''"highway"=>"motorway_link"''::hstore) or (tags @> E''"highway"=>"trunk"''::hstore) or (tags @> E''"highway"=>"trunk_link"''::hstore) or (tags @> E''"highway"=>"primary"''::hstore) or (tags @> E''"highway"=>"primary_link"''::hstore) or (tags @> E''"highway"=>"secondary"''::hstore) or (tags @> E''"highway"=>"tertiary"''::hstore)) or ((tags @> E''"aeroway"=>"runway"''::hstore)) or (((tags @> E''"railway"=>"rail"''::hstore)) and ( (tags @> E''"usage"=>"main"''::hstore))) or (( (tags @> E''"power"=>"line"''::hstore))) or (((tags @> E''"waterway"=>"river"''::hstore) or (tags @> E''"waterway"=>"canal"''::hstore))))';

  execute 'insert into osm_line_extract ( '
    || 'select * '
    || 'from ( '
    || '  select '
    || '    id, '
    || '    tags, '
    || '    way '
    || '  from '
    || '    osm_line '
    || '  where '
    || match
    || ') x '
    || 'where '
    || '  extract_classify_line(id, tags, way));';

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_line_extract (%)', num_rows;

  execute 'insert into osm_polygon_extract ( '
    || 'select * '
    || 'from ( '
    || '  select '
    || '    id, '
    || '    tags, '
    || '    way '
    || '  from '
    || '    osm_polygon '
    || '  where '
    || '    ST_Area(way)>1000000'
    || ') x);';

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_polygon_extract (%)', num_rows;

  return true;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION extract_update_delete() RETURNS boolean AS $$
DECLARE
  num_rows  int;
BEGIN
  delete from osm_point_extract using
    (select (data_type || id) as id from actions) x
    where id=x.id;

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'deleted from osm_point_extract (%)', num_rows;

  delete from osm_line_extract using
    (select (CASE WHEN data_type='W' THEN 'W'||id
	    END) as id from actions) x
    where id=x.id;

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'deleted from osm_line_extract (%)', num_rows;

  delete from osm_polygon_extract using
    (select data_type || id as id from actions) x
    where id=x.id;

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'deleted from osm_polygon_extract (%)', num_rows;

  return true;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION extract_update_insert() RETURNS boolean AS $$
DECLARE
  num_rows  int;
BEGIN
  insert into osm_point_extract (
    select
      osm_point.id,
      osm_point.tags,
      osm_point.way
    from 
      osm_point join
      actions on
        osm_point.id=(data_type || actions.id) and
        action not in ('D')
     where
       extract_classify_point(osm_point.id, osm_point.tags, osm_point.way)
   );

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_point_extract (%)', num_rows;

  insert into osm_line_extract (
    select
      osm_line.id,
      osm_line.tags,
      osm_line.way
    from 
      osm_line join
      actions on
        osm_line.id=(data_type || actions.id) and
        action not in ('D')
     where
       extract_classify_line(osm_line.id, osm_line.tags, osm_line.way)
   );

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_line_extract (%)', num_rows;

  insert into osm_polygon_extract (
    select
      osm_polygon.id,
      osm_polygon.tags,
      osm_polygon.way
    from 
      osm_polygon join
      actions on
        osm_polygon.id=(data_type||actions.id) and
        action not in ('D')
     where
       ST_Area(osm_polygon.way)>1000000
   );

  GET DIAGNOSTICS num_rows = ROW_COUNT;
  raise notice 'inserted to osm_polygon_extract (%)', num_rows;

  return true;
END;
$$ language 'plpgsql';
