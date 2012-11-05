<?
$name="OpenStreetBrowser - Database";

$id="openstreetbrowser_database";

$depend=array("hooks");

$default_include=array(
  "pgsql-functions"=>array("inc/*.sql"),
  "pgsql-init"=>array("init.sql"),
  "pgsql-after-import"=>array("after-import.sql"),
  "php"=>array("inc/*.php"),
);
