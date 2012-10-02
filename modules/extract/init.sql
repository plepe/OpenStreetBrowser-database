drop table if exists osm_point_extract;
create table osm_point_extract (
  id		text		not null,
  tags		hstore		null,
  primary key(id)
);
select AddGeometryColumn('osm_point_extract', 'way', 4326, 'GEOMETRY', 2);

drop table if exists osm_line_extract;
create table osm_line_extract (
  id		text		not null,
  tags		hstore		null,
  primary key(id)
);
select AddGeometryColumn('osm_line_extract', 'way', 4326, 'GEOMETRY', 2);

drop table if exists osm_polygon_extract;
create table osm_polygon_extract (
  id		text		not null,
  tags		hstore		null,
  primary key(id)
);
select AddGeometryColumn('osm_polygon_extract', 'way', 4326, 'GEOMETRY', 2);

-- drop all views
drop view if exists osm_all_extract;

drop view if exists osm_all_point_extract;
drop view if exists osm_all_line_extract;
drop view if exists osm_all_polygon_extract;

-- osm_all_point
create view osm_all_point_extract as (
  select
    "id",
    'type=>node, form=>point'::hstore as "type",
    "tags",
    "way" as "way",
    "way" as "way_point",
    ST_MakeLine("way", "way") as "way_line",
    ST_MakePolygon(ST_MakeLine(Array["way", "way", "way", "way"])) as "way_polygon"
  from osm_point_extract
);

-- osm_all_line
create view osm_all_line_extract as (
  select
    "id",
    'type=>way, form=>line'::hstore as "type",
    "tags",
    "way" as "way",
    ST_Line_Interpolate_Point("way", 0.5) as "way_point",
    "way" as "way_line",
    null::geometry as "way_polygon"
  from osm_line_extract
);

-- osm_all_polygon
create view osm_all_polygon_extract as (
  select
    "id",
    'form=>polygon'::hstore as "type",
    "tags",
    "way" as "way",
    ST_Centroid("way") as "way_point",
    ST_Boundary("way") as "way_line",
    "way" as "way_polygon"
  from osm_polygon_extract
);

-- osm_all
create view osm_all_extract as (
  select * from osm_all_point_extract
  union all
  select * from osm_all_line_extract
  union all
  select * from osm_all_polygon_extract
);

select register_hook('osmosis_update_delete', 'extract_update_delete', 0);
select register_hook('osmosis_update_insert', 'extract_update_insert', 0);
