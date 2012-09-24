<?php
global $osm_table_list;

class osm_table {
  public $name;

  function __construct($name) {
    $this->name=$name;

    $this->create_query_fun();
  }

  function create_query_fun() {
    $fun ="CREATE OR REPLACE FUNCTION {$this->name}(\n";
    $fun.="  bbox geometry,\n";
    $fun.="  where_expr text DEFAULT null,\n";
    $fun.="  options hstore DEFAULT ''::hstore\n";
    $fun.=")\n";
    $fun.="RETURNS SETOF {$this->name} AS $$\n";
    $fun.="DECLARE\n";
    $fun.="  ret RECORD;\n";
    $fun.="  qry TEXT;\n";
    $fun.="BEGIN\n";
    $fun.="  qry='SELECT * FROM {$this->name} t WHERE t.way && ' ||\n";
    $fun.="    quote_nullable(cast(bbox as text));\n";
    $fun.="\n";
    $fun.="  IF where_expr IS NOT NULL THEN\n";
    $fun.="    qry=qry || ' AND '|| where_expr;\n";
    $fun.="  END IF;\n";
    $fun.="\n";
    // $fun.="  RAISE NOTICE '{$this->name}: %', qry;\n";
    $fun.="  RETURN QUERY EXECUTE qry;\n";
    $fun.="END;\n";
    $fun.="$$ LANGUAGE PLPGSQL;";

    sql_query($fun);
  }
}

function register_osm_table($table) {
  global $osm_table_list;

  $osm_table_list[$table]=new osm_table($table);
}
