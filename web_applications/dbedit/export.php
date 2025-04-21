<?php

include "dbedit.php";

if (isset($_GET["dbe_table"])) {
	$table = $_GET["dbe_table"];
}

	$editor = new dbEdit(array($table));
	$editor->display();
