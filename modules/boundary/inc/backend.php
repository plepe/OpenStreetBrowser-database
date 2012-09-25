<?
function boundary_init() {
  register_osm_table("osm_boundary");
}

register_hook("init", "boundary_init");
