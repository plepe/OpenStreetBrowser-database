<?
function osm_enable_partitions_before_import() {
# Initialize osm_tables
  $file=modulekit_file("partition_geometry", "boundary_examples/osm_line_2012apr_48.4326", true);
  sql_query("select partition_geometry_init_table('osm_point', '{$file}', 'srid=>4326')");
  sql_query("select partition_geometry_init_table('osm_line', '{$file}', 'srid=>4326')");
  sql_query("select partition_geometry_init_table('osm_polygon', '{$file}', 'srid=>4326')");
  sql_query("select partition_geometry_init_table('osm_rel', '{$file}', 'srid=>4326')");

  $file=modulekit_file("partition_geometry", "boundary_examples/osm_line_2012apr_16.4326", true);
# If available also initialize extract tables
  if(modulekit_loaded("extract")) {
    sql_query("select partition_geometry_init_table('osm_point_extract', '{$file}', 'srid=>4326')");
    sql_query("select partition_geometry_init_table('osm_line_extract', '{$file}', 'srid=>4326')");
    sql_query("select partition_geometry_init_table('osm_polygon_extract', '{$file}', 'srid=>4326')");
  }

# If available also initialize boundary table
  if(modulekit_loaded("boundary")) {
    sql_query("select partition_geometry_init_table('osm_boundary', '{$file}', 'srid=>4326')");
  }
}

register_hook("osm_import_schema_created", "osm_enable_partitions_before_import");
