<?
function osm_enable_partitions_before_import() {
  sql_query("select partition_integer_init_table('nodes')");
  sql_query("select partition_integer_init_table('node_tags', 'id_column=>node_id')");
  sql_query("select partition_integer_init_table('ways')");
  sql_query("select partition_integer_init_table('way_tags', 'id_column=>way_id')");
  sql_query("select partition_integer_init_table('way_nodes', 'id_column=>way_id')");
  sql_query("select partition_integer_init_table('relations')");
  sql_query("select partition_integer_init_table('relation_tags', 'id_column=>relation_id')");
  sql_query("select partition_integer_init_table('relation_members', 'id_column=>relation_id')");
}

register_hook("osm_import_schema_created", "osm_enable_partitions_before_import");
