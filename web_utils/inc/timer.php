<?php
$t1=microtime(true);
require_once("../inc/dbutils/dbutils.php");
$t2=microtime(true);
echo $t2-$t1." ms to load libs<br>";
db_connect();
$t3=microtime(true);
echo $t3-$t2." ms to connect<br>";

$n=doquery("select now()",0);
$t4=microtime(true);
echo $t4-$t3." ms to select<br>";

$t5=microtime(true);
echo $t5-$t1." total exec time<br>";

echo $n."<br>";

exit();
?>

