<?
function osm_enable_partitions_before_import() {
# Initialize osm_tables
  $file=modulekit_file("partition_geometry", "boundary_examples/osm_line_2012apr_64.900913", true);
  sql_query("select partition_geometry_init_table('osm_point', '{$file}')");
  sql_query("select partition_geometry_init_table('osm_line', '{$file}')");
  sql_query("select partition_geometry_init_table('osm_polygon', '{$file}')");
  sql_query("select partition_geometry_init_table('osm_rel', '{$file}')");

  $file=modulekit_file("partition_geometry", "boundary_examples/osm_line_2012apr_16.900913", true);
# If available also initialize extract tables
  if(modulekit_loaded("extract")) {
    sql_query("select partition_geometry_init_table('osm_point_extract', '{$file}')");
    sql_query("select partition_geometry_init_table('osm_line_extract', '{$file}')");
    sql_query("select partition_geometry_init_table('osm_polygon_extract', '{$file}')");
  }

# If available also initialize boundary table
  if(modulekit_loaded("boundary")) {
    sql_query("select partition_geometry_init_table('osm_boundary', '{$file}')");
  }
}

register_hook("osm_import_schema_created", "osm_enable_partitions_before_import");
