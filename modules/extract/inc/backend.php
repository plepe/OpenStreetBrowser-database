<?
function extract_init() {
  register_osm_table("osm_point_extract");
  register_osm_table("osm_line_extract");
  register_osm_table("osm_polygon_extract");
}

register_hook("init", "boundary_init");
