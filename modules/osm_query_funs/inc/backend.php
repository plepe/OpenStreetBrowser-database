<?php
function osm_query_funs_create($table) {
  $fun ="CREATE OR REPLACE FUNCTION {$table}(\n";
  $fun.="  bbox geometry,\n";
  $fun.="  where_expr text DEFAULT null,\n";
  $fun.="  options hstore DEFAULT ''::hstore\n";
  $fun.=")\n";
  $fun.="RETURNS SETOF {$table} AS $$\n";
  $fun.="DECLARE\n";
  $fun.="  ret RECORD;\n";
  $fun.="  qry TEXT;\n";
  $fun.="BEGIN\n";
  $fun.="  qry='SELECT * FROM {$table} t WHERE t.way && ' ||\n";
  $fun.="    quote_nullable(cast(bbox as text));\n";
  $fun.="\n";
  $fun.="  IF where_expr IS NOT NULL THEN\n";
  $fun.="    qry=qry || ' AND '|| where_expr;\n";
  $fun.="  END IF;\n";
  $fun.="\n";
  // $fun.="  RAISE NOTICE '{$table}: %', qry;\n";
  $fun.="  RETURN QUERY EXECUTE qry;\n";
  $fun.="END;\n";
  $fun.="$$ LANGUAGE PLPGSQL;";

  sql_query($fun);
}
