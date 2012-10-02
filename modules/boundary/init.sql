drop table if exists osm_boundary;
create table osm_boundary (
  id		text		not null,
  tags		hstore		null,
  admin_level		int		not null,
  rel_ids		text[]		default Array[]::text[],
  primary key(id)
);
select AddGeometryColumn('osm_boundary', 'way', 4326, 'LINESTRING', 2);

drop table if exists osm_boundary_update;
create table osm_boundary_update (
  id		bigint		not null,
  osm_id	text		not null
);

select register_hook('osmosis_update_delete', 'boundary_update_delete', 0);
select register_hook('osmosis_update_insert', 'boundary_update_insert', 0);
