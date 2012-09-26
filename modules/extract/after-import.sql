select extract_init();

create index osm_extract_point_way_tags on osm_point_extract using gist(osm_way, osm_tags);
create index osm_extract_line_way_tags on osm_line_extract using gist(osm_way, osm_tags);
create index osm_extract_polygon_way_tags on osm_polygon_extract using gist(osm_way, osm_tags);
