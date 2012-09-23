<?
function osm_import_db_init() {
  global $osmosis_path;
  global $osm_import_source;
  global $db_central;
  global $tmp_dir;
  global $plugins_dir;

  // $res=sql_query("select * from pg_tables where schemaname='osm' and tablename='nodes'");
  $res=sql_query("select * from pg_tables where tablename='nodes'");
  if(pg_num_rows($res))
    return;

  $res=sql_query("select * from pg_tables where tablename='osm_point'");
  if(pg_num_rows($res))
    return;

  if(!$osm_import_source) {
    debug("set \$osm_import_source in conf.php to an osm-file", "osm_import");
    return;
  }

  if(isset($osmosis_path))
    $osmosis_path="{$osmosis_path}/";
  else
    $osmosis_path="";

  debug("database not initialized yet -> import", "osm_import");

  if(!isset($db_osmosis))
    $db_osmosis=$db_central;

  // remember search_path and set to 'osm'
  //$res=sql_query("show search_path");
  //$elem=pg_fetch_array($res);
  //$search_path=$elem[0];
  //sql_query("set search_path to {$osmosis_db['user']}, {$db_central['user']}, public");

  // load schema
  sql_file(modulekit_file("osm_import", "osmosis_scripts/pgsimple_schema_0.6.sql"));
  sql_file(modulekit_file("osm_import", "osmosis_scripts/pgsimple_schema_0.6_action.sql"));

  // create tmp_dir
  mkdir("pgimport");
  system("{$osmosis_path}osmosis --read-xml file=$osm_import_source --write-pgsimp-dump directory=pgimport");

  sql_file(modulekit_file("osm_import", "osmosis_scripts/pgsimple_load_0.6.sql"));

  // reset search_path
  //sql_query("set search_path to {$search_path}");
}