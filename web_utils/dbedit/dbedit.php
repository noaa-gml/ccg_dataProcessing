<?php


    // $Id: dbedit.php,v 1.0 2012/12/26 $

    /**
    * Copyright (c) 2012 Kirk Thoning
    *
    * All rights reserved.
    *
    */

    /**
    * dbedit Class 0.1
    *
    * Allows editing of mysql table information.
    *
    */


# TODO
# default and settable sort direction for defaultSortBy
# allow other editors than ckeditor to be used
# handle 'does not contain' advanced search criteria


#require_once('Net/URL.php');

define ("VAL_INT", 0);
define ("VAL_FLOAT", 1);
define ("VAL_DATE", 2);
define ("VAL_STRING", 3);
define ("VAL_ARRAY", 4);


###################################################################
# Main Class
###################################################################
class dbEdit {

        var $db;		# Database handle * @var object 
        var $pk;		# Name of primary key field * @var string 
        var $table; 		# Name of table to edit * @var string 
        var $script; 		# Name of php script calling this.  Needed for above javascript
	var $fields;		# Array of column names in database table
	var $showFields;	# Array of column names to show in listing. If empty show all of them.
	var $sortby;		# Field name to sort results by.
	var $defaultsortby;	# Field name to sort results by.
	var $direction;		# Directions to sort, 0 = ASC, 1 = DESC  !!!!! fix doesn't stay correct through edit table
	var $option;		# Array of optional query strings to keep track of
	var $optionUrl;		# Combination of query strings usable for a url.  !!!NOT USED
	var $search;		# Search string
	var $asearch;		# Advanced Search string
	var $showSearch;	# Whether to show search form or not.
	var $showASearch;	# Whether to show advanced search form or not.
	var $perPage;		# Number of rows per page in listing
        var $dataFilters; 	# Filter conditions (WHERE foo=bar)
	var $displayLength;	# Array of lengths to truncate field display
	var $pageID;		# page number for listing
	var $readonly;		# disable edit and delete
#	var $baseURL;



	######################################################################
        /**
        * Constructor
        *
        * @param string  $table     Optional. The table to be edited
        */
	######################################################################
	function __construct($tables=array(), $configfile="config.php") {

#print_r($_REQUEST);

#		$d = dirname( __FILE__);
#		include "$d/$configfile";
		# this is for config file outside of dbedit directory
		include "$configfile";

		// Make connection to database.
		if (! $this->db = mysqli_connect($host, $user, $password, $database)) {
			$msg = "Could not connect to $host as $user: " . mysqli_connect_error();
			$this->showError($msg);
			exit;
		}

		if (! is_array($tables)) {
			$tables = array($tables);
		}

		# Get list of tables for this database.
		$this->dbinfo = new dbInfo($this->db, $tables);

		# If no table name given, use first one from database.  Allow table selector too.
		$show_heading = 0;
		if (count($tables) == 0 || count($tables) > 1) {
			$table = $this->getHTTPVar("dbe_table", $this->dbinfo->tables[0], VAL_STRING, $this->dbinfo->tables);
			$show_heading = 1;
		} else {
			$table = $tables[0];
		}

		// Check for valid table, and get info for this table
		if (!$this->dbinfo->tableExists($table)) {
			$this->showError("Bad table name '$table'.");
			exit;
		}
		$this->dbinfo->getTableInfo($table);

#		$s = str_replace ($_SERVER['DOCUMENT_ROOT'], "", $d);
		$this->script               = $_SERVER['PHP_SELF'];
#		$this->baseURL              = $s;
		$this->table                = $table;
		$this->direction            = 0;
		$this->option               = "";
		$this->showSearch           = 1;
		$this->showASearch          = 1;
		$this->defaultperPage       = 100;
		$this->perPage              = 100;
		$this->querys               = array();
		$this->defaultDisplayLength = 120;
		$this->htmlEdit             = array();
		$this->fieldType            = array();
		$this->fieldName            = array();
		$this->pageID               = 1;
		$this->readonly             = 0;
#		$this->pk                   = $this->dbGetPrimaryKeyFields ($this->table);
		$this->pk                   = $this->dbinfo->keys;
#		$this->fields               = $this->dbGetFields($this->table);
		$this->fields               = $this->dbinfo->names;
		$this->showFields           = array();
		$this->sortby               = $this->pk[0];
		$this->asearchTerms         = array();
		$this->asearchMatch         = "";
		$this->showHeader           = $show_heading;
		$this->showExportButton     = 1;
		$this->showShowHideColumnsButton = 1;
		$this->showAdvSearch        = 1;
		$this->showSearch           = 1;
		$this->showPager            = 1;
		$this->showDelete           = 1;
		$this->logTable 	    = "";	

	}

	######################################################################
        /**
        * Destructor
        *
        */
	######################################################################
	function __destruct() {

		@$this->db->close();
	}

	#####################################################################
        /** Displays the page based on the action requested.
	*/
	######################################################################
        function display() {


		# get url querys that don't start with 'dbe_'.  These are used external
		# to here, so we need to remember them and pass them along
		$this->params = $this->getUrlParams();

		if (empty($this->pk)) {
			die ("dbEdit error:  No primary key field.  Please set one with 'setPrimaryKeyField()'");
		}


		# find which action to do coming out of add/edit page
		$action = "";
		if (!$this->readonly) {
			$cancel = $this->getHTTPVar ("dbe_cancel"); 	// Check if cancel button was pressed
			if ($cancel == "") { 				// If not, get action
				$action = $this->getHTTPVar("dbe_action", "", VAL_STRING, array("insert", "update", "delete"));
			}
		}


		$keystring = $this->getHTTPVar("dbe_key");
		$keystring = $this->db->real_escape_string($keystring);

		# get sort field, sort direction
		$sortby = $this->getHTTPVar('dbe_sortby');
		if (! empty($sortby)) {
			list($this->sortby, $direction) = split (':', $sortby);
			$n = (int) $direction;
			if ($n) {
				$this->direction = 1;
			} else {
				$this->direction = 0;
			}
			$this->params["dbe_sortby"] = $sortby;
		}

		# get page number to display
		$this->pageID = $this->getHTTPVar('dbe_pageID', 1, VAL_INT);
		if ($this->pageID != 1) { $this->params["dbe_pageID"] = $this->pageID; }

		# get number of rows to display
		$this->perPage = $this->getHTTPVar ("dbe_setPerPage", $this->defaultperPage, VAL_INT);
		if ($this->perPage != $this->defaultperPage) { $this->params["dbe_setPerPage"] = $this->perPage; }

		# get search term for filtering listing
		$this->search = $this->getHTTPVar('dbe_search');
		if ($this->search != "") { $this->params["dbe_search"] = $this->search; }

		$asearchterms = $this->getHTTPVar('dbe_asearchTerms', array(), VAL_ARRAY);
		if ($asearchterms != "") {
			$this->asearchTerms = $asearchterms;
			$this->params["dbe_asearchTerms"] = $asearchterms;
			$this->asearchMatch = $this->getHTTPVar('dbe_match', 'any', VAL_STRING, array("any", "all"));
			if ($this->asearchMatch != "any") { $this->params["dbe_match"] = $this->asearchMatch; }
		}

		# get advanced search terms for filtering listing
		$asearch = $this->getHTTPVar("dbe_asearch");
		if ($asearch == "Ok") {
			$fields = $this->getHTTPVar("dbe_fields", array(), VAL_ARRAY);
			$values = $this->getHTTPVar("dbe_values", array(), VAL_ARRAY);
			$operators = $this->getHTTPVar("dbe_operators", array(), VAL_ARRAY);
			$this->asearchMatch = $this->getHTTPVar('dbe_match', 'any', VAL_STRING, array("any", "all"));
			if ($this->asearchMatch != "any") { $this->params["dbe_match"] = $this->asearchMatch; }

			$n = 0;
			$this->asearchTerms = array();
			foreach ($fields as $field) {
				$operator = $operators[$n];
				$value = $values[$n];
				if (! empty($field) && !empty($value)) {
					$this->asearchTerms[] = implode ("|", array($field, $operator, $value));
				}
				$n++;
			}
			if (count($this->asearchTerms)) {
				$this->params["dbe_asearchTerms"] = $this->asearchTerms;
			};
		}
#print_r($this->asearchTerms);


		// check on which columns to display in listing
		$showcols = $this->getHTTPVar('dbe_showcols');
		if ($showcols != "") {
			$this->showFields = explode ("|", $showcols);
			$this->params["dbe_showcols"] = $showcols;
		}

		// check if show/hide form was submitted
		// if set, get new list of columns to display
		$showhide = $this->getHTTPVar("dbe_showhide");
		if ($showhide == "Ok") {
			$dlist = array();
			foreach ($this->fields as $name) {
				$s = "dbe_" . $name;
				if ($this->getHTTPVar($s, 0, VAL_INT, array(0,1))) {
					$dlist[] = $name;
				}
			}
			$this->showFields = $dlist;
			$this->params["dbe_showcols"] = implode("|", $dlist);
		}


		# find which page to display, default is listing
		if ($this->readonly) {
			$page = $this->getHTTPVar("dbe_page", "", VAL_STRING, array("export"));
		} else {
			$apply = $this->getHTTPVar ("dbe_apply"); 	// Check if apply button was pressed
			if ($apply != "") { 				// If it was return to edit page
				$page = "edit";
			} else {
				$page = $this->getHTTPVar("dbe_page", "", VAL_STRING, array("add", "edit", "export"));
			}
		}

		if ($page == "export") {
			ob_clean();
			header('Pragma: public');
			header('Expires: 0');
			header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
			header('Cache-Control: private', false);
			header("Content-type: text/csv");
			header('Content-disposition: attachment; filename="export.csv"');
			$this->dbExportCSV();
			ob_flush();
		} else {
			echo "<div class='dbeditmain'>\n";

			# if database update is needed, do it here
			if ($action == "insert") {
				$this->dbUpdate ($this->table, "insert", $keystring);
			} elseif ($action == "update") {
				$this->dbUpdate ($this->table, "update", $keystring);
			} elseif ($action == "delete") {
				$this->dbDelete ($this->table, $keystring);
			}

			switch ($page) {
			case "add": 
			case "edit": 
				echo "   <div class='card p-3 bg-light'>";
				if (count($this->htmlEdit)) {
					echo "<script type='text/javascript' src='ckeditor/ckeditor.js'></script>\n";
				}
				$this->dbEditRow($page, $keystring);
				echo "   </div>";
				break;
			default:
				echo "  <div class='card'>\n";
				if ($this->showHeader) {
					echo "  <div class='card-header'>";
					echo "     <div class='row'>";
					echo "        <div class='col-sm-9'>";
					echo "           <span class='p-2 bg-primary text-white rounded' >Editing table <span class='badge badge-dark'>$this->table</span></span>";
					echo "        </div>";
					echo "        <div class='col-sm-3'>";
					echo "           <div class='float-right'>";
					$this->dbTableSelect();
					echo "           </div>";
					echo "        </div>";
					echo "     </div>";
					echo "  </div>";
				}
				echo "  <div class='card-body'>\n";
				$this->dbList();
				$this->dbShowHideColumns();
				$this->showAdvancedSearchPage();
				echo "  </div>\n";	# end panel-body
				echo "  </div>\n";	# end panel
				print <<<HTML
				<script>
//				function confirmDelete(script) {
//					bootbox.confirm("Do you really want to permanently delete this entry?", function(agree) {
//					if (agree)
//						document.location=script;
//					});
//				}
$('[data-toggle=confirmation]').confirmation({
	rootSelector: '[data-toggle=confirmation]',
});
				</script>
HTML;
				break;
			}

			echo "</div>\n";
		}

	}

	######################################################################
	# Store each option string, 
	# as well as a combined string usable in a URL
#!!!! Need validation
#!!!! NOT IMPLEMENTED
	######################################################################
	function addOption ($name, $value) {
		$this->option[] = array ($name => $value);
		$s = array();
		foreach ($this->option as $a) {
			$key = key($a);
			$value = $a[$key];
			$s[] = "$key=$value";
		}
		$s2 = implode ('&amp;', $s);
		$this->optionUrl = $s2;
	}

	######################################################################
        /* Adds data filter conditions. Allows only showing of certain rows.
        * Arguments should be valid MySQL WHERE clause for this table.
        *
        * @param string ... One or more SQL WHERE clause conditions.
        * e.g. "status='cancelled'"
	*/
	######################################################################
        function addDataFilter() {
            $args = func_get_args();

            foreach ($args as $a) {
                $this->dataFilters[] = $a;
            }
        }

	######################################################################
        /* Sets default order by
        *
        * @param string $field     Name of field to order by
        * @param int    $direction 0 = ascending, 1 = descending
        */
	######################################################################
        function setSortField($field, $direction = 0) {
		$this->sortby = $field;
		$this->defaultsortby = $field;
		$n = (int)$direction;
		if ($n) {
			$this->direction = 1;
		} else {
			$this->direction = 0;
		}
	}

	######################################################################
	/* Sets the values from the given sql query.  Query should return
	* at least two columns, the first being the value that is set in this
	* tables column, the second and others being the value that is shown to the 
	* user.  Commonly used for foreign keys.
	* for example:
	* $editor->setValuesFromQuery("customerNumber", "select customerNumber,customerName from customers order by customerName");
	* will replace the customerNumber fields with the custermerName from a different table.
	*
	* @param string $field  the field name to be replaced
	* @param string $sql : the sql statement to execute for replacing the values in the original field.
	*/
	######################################################################
	function setValuesFromQuery ($field, $sql) {
		if (in_array ($field, $this->fields)) {
			$result = $this->dbGetAssoc($sql);
			if ($result) {
				$this->querys[$field]['values'] = $result;
			}
		}
	}

        ######################################################################
	/* Similar to setValuesFromQuery(), but set the pieces here and construct
	* an sql query from them.
	* for example:
	* $editor->setRelation("customerNumber", "customers", "customerNumber", "customerName");
	* will replace the customerNumber with customerName from the customers table where customerNumber matches.
	*
	* @param string $field : The field name to be replaced
	* @param string $reltable: The table name to use for the relation.
	* @param string $relid : the field name in $reltable that matches $field
	* @param string $relfield,$relfield2... : one or more field names in $reltable to substitute for $field
	*/
        ######################################################################
        function setRelation() {
                $args = func_get_args();
                $field = $args[0];
                $reltable = $args[1];
                $relid = $args[2];
                $relfields = implode(",", array_slice($args, 3));
                if (in_array ($args[0], $this->fields)) {
                        $sql = "select $relid, $relfields FROM $reltable order by $relfields";
                        $result = $this->dbGetAssoc($sql);
#print_r($result);
			if ($result) {
				$this->querys[$field]['values'] = $result;
			}
                }
#echo "<pre>";
#print_r ($this->querys[$field]['values']);
#echo "</pre>";

        }

	######################################################################
	function getTable() {

		return $this->table;

	}

	######################################################################
	function setValuesFromList ($field, $list) {
		if (in_array ($field, $this->fields)) {
			$this->querys[$field]['values'] = $list;
		}
	}
		
	######################################################################
        /* Show/hide table heading.   
        *
        * @param boolean $val     Show header if True, hide it if False
        */
	######################################################################
	function showHeading($val) {

		$b = (bool) $val;
		$this->showHeader = $b;

	}

	######################################################################
        /* Show/hide export csv button.   
        *
        * @param boolean $val     Show button if True, hide it if False
        */
	######################################################################
	function showExportButton($val) {

		$b = (bool) $val;
		$this->showExportButton = $b;

	}

	######################################################################
        /* Show/hide show/hide columns button.   
        *
        * @param boolean $val     Show button if True, hide it if False
        */
	######################################################################
	function showShowHideColumnsButton($val) {

		$b = (bool) $val;
		$this->showShowHideColumnsButton = $b;

	}

	######################################################################
        /* Show/hide advanced search button.   
        *
        * @param boolean $val     Show button if True, hide it if False
        */
	######################################################################
	function showAdvSearch($val) {

		$b = (bool) $val;
		$this->showAdvSearch = $b;

	}

	######################################################################
        /* Show/hide search form.   
        *
        * @param boolean $val     Show button if True, hide it if False
        */
	######################################################################
	function showSearch($val) {

		$b = (bool) $val;
		$this->showSearch = $b;

	}

	######################################################################
        /* Show/hide pager bar.   
        *
        * @param boolean $val     Show bar if True, hide it if False
        */
	######################################################################
	function showPager($val) {

		$b = (bool) $val;
		$this->showPager = $b;

	}

	######################################################################
        /* Show/hide delete button in listing.
        *
        * @param boolean $val     Show button if True, hide it if False
        */
	######################################################################
	function showDeleteButton($val) {

		$b = (bool) $val;
		$this->showDelete = $b;
	}

	######################################################################
        /* Make the table listing read only.  This will remove the edit and delete links, 
        * and the insert row link.
        *
        * @param boolean $val     Readonly if True, editable if False
        */
	######################################################################
	function setReadOnly($val) {

		$b = (bool) $val;
		$this->readonly = $b;

	}

	######################################################################
        /* Set which table fields will be shown in the listing.
        *
	* @param array $args   Array of table field names (column names) to show. 
        *                      If a field name is not in this array, it will not
        *                      be displayed in the list view.
        */
	######################################################################
        function setDisplayFields() {
		$args = func_get_args();

		$this->showFields = $args;

        }

        ######################################################################
        /* Set the title of the table field in the listing
        *
        * @param string $name  Table field name
        * @param string $value  Title to display instead of table field name
        */
        ######################################################################
        function setFieldName($name, $value) {
                $this->fieldName[$name] = $value;
        }


        ######################################################################
        /* Set which table fields will NOT be shown in the listing.
        *
	* @param string $args   One or more arguments of table field names (column names) to hide. 
	*/
        ######################################################################
        function hideDisplayFields() {
                $args = func_get_args();

                $this->showFields = $this->fields;
                foreach ($args as $field) {
                        $key = array_search($field, $this->showFields);
                        if ($key) {
                                unset($this->showFields[$key]);
                        }
                }
        }

	######################################################################
	/* Set the number of rows to display for each page of results.
	*
	* @param int $value	Number of rows to show in the list view.
	*/
	######################################################################
	function setPerPage ($value) {
		if (is_int($value)) {
			$this->perPage = $value;
		} else {
			die ("Error setPerPage: Bad integer value: $value.");
		}
	}

	######################################################################
	# Call this if the table doesn't have a primary key.
	# Use a different column as the key field.
	######################################################################
	function setPrimaryKeyField ($name) {
		if (in_array ($name, $this->fields)) {
			$this->pk = $name;
		} else {
			die ("Error in setPrimaryKeyField: Unknown field '$name' in table $this->table. ");
		}
	}

	######################################################################
	/* Set the number of characters to display for a given field.
	*
	* @param string $name	name of the field
	* @param int $value	integer specifying the number of characters to display
	*/
	######################################################################
	function setFieldDisplayLength($name, $value) {
		
		if (is_numeric($value)) {
			$this->displayLength[$name] = (int) $value;
		}
	}

	######################################################################
	# For text or blob types, set the textarea to either use the 
	# tinymce editor (value=1) or regular textarea (value=0) when editing.
	# $name is the field name
	######################################################################
	function setHtmlEdit($name, $value) {
		$this->htmlEdit[$name] = $value;
	}

        ######################################################################
        # Set if a field's content is editable.  
        # If (boolean) $value evaluates to False, 
        # don't allow editing the field in the edit form.
        ######################################################################
        function setEditContent($name, $value) {
                $this->editContent[$name] = (boolean) $value;
        }

	######################################################################
	function setFieldType($name, $value) {
		$this->fieldType[$name] = $value;
	}

	######################################################################
	function setFileDir($name, $value) {
		$this->fileDir[$name] = $value;
	}

	######################################################################
        /* Set the table name which has logging information
	*  The table must have 4 fields, 'num', 'user', 'date', 'query_string'
        *
	* @param $name   Table name
        */
	function setLogTable($name) {
		if ($this->dbinfo->tableExists($name)) {
			$this->logTable = $name;
		}
	}

	#------------------------------------------------------------------------
	# End public functions.  Everything below is protected.
	#------------------------------------------------------------------------

	######################################################################
	# Show a dropdown menu with database table names.
	# Selection of a table name will reload page with new table name.
	######################################################################
	protected function dbTableSelect() {

		echo "<div class='dropdown'>\n";
		echo " <button class='btn btn-secondary dropdown-toggle btn-sm' type='button' id='dropdownMenu1' data-toggle='dropdown' aria-expanded='true'>\n";
		echo " Select table";
		echo " <span class='caret'></span>\n";
		echo " </button>\n";
		echo " <div class='dropdown-menu dropdown-menu-right' role='menu' aria-labelledby='dropdownMenu1'>\n";
		foreach ($this->dbinfo->tables as $tablename) {
			$url = new dbUrl($this->params);
			$url->addQuery("dbe_table", $tablename);
			$url->removeQuery("dbe_showcols", $tablename);
			$url->removeQuery("dbe_asearchTerms", $tablename);
			$url->removeQuery("dbe_sortby", $tablename);
			$newurl = $url->getUrl();
			echo "<a class='dropdown-item' role='menuitem' tabindex='-1' href='$newurl'>$tablename</a>\n";
		}
		echo " </div>\n";
		echo "</div>\n";
	}

	######################################################################
	# Create a table header that has the field names for the table.
	# First and last column should be blank, to hold 'edit' and 'delete' links.
	######################################################################
	protected function dbTableHeader () {

		# get opposite direction of current sorting
		if ($this->direction) { $reverse = 0; } else { $reverse = 1;}

		if ($this->direction) {
			$direcname = "ascending";
		} else {
			$direcname = "descending"; 
		}

		echo "  <thead>\n";
		echo "    <tr>\n";
		if ( ! $this->readonly) { echo "      <th></th>\n"; } # No header for edit icon column

		$fields = $this->fields;
		if (count($this->showFields)) {
			$fields = $this->showFields;
		}

		$url = new dbUrl($this->params);
		$url->addQuery("dbe_table", $this->table);
		foreach ($fields as $name) {
			echo "      <th>\n";

			$url->addQuery("dbe_sortby", $name . ":" . $reverse);
			$newurl = $url->getUrl();



                        if (array_key_exists($name, $this->fieldName)) {
                                $title = $this->fieldName[$name];
                        } else {
                                $title = $name;
                        }


			$title = ucwords(str_replace("_", " ", $title));
			$sortclass = "";
			if (strtolower($name) == strtolower($this->sortby)) {
				$sortclass = "class='sortdown'";
				if ($this->direction) { $sortclass = "class='sortup'"; }
			}
			echo "        <a href='$newurl' title='Sort $direcname on this column' $sortclass>$title</a>\n";
			echo "      </th>\n";
		}

		if ( ! $this->readonly && $this->showDelete) { echo "      <th></th>\n"; }
		echo "    </tr>\n";
		echo "  </thead>\n";
	}

	######################################################################
	# Determine the 'ORDER BY' part of the sql query, based on the 
	# selected column for sorting and direction.
	######################################################################
	protected function dbGetOrderBySql() {
		$direct = "ASC";
		if ($this->direction == 1) { $direct = "DESC"; }

		$order = "";
		if (!empty($this->sortby)) {

			// If both sortby and defaultsortby are set, sort on two columns
			if ($this->sortby != $this->defaultsortby AND !empty($this->defaultsortby)) {
				$order = " ORDER BY $this->sortby $direct,$this->defaultsortby ASC";
			} else {
				$order = " ORDER BY $this->sortby $direct";
			}
		}

		return $order;
	}

	######################################################################
	# Export the data as comma seperated values
	######################################################################
	protected function dbExportCSV () {

		// Handle data filters if any
		$filters = "1";
		if (!empty($this->dataFilters)) {
			$filters = implode(' AND ', $this->dataFilters);
		}

		// Handle search request if any
		$searchClause = "1";
		if (!empty($this->search))  { $searchClause = $this->handleSearch(); }

		if (count($this->asearchTerms)) { $searchClause = $this->handleAsearch(); }

		// Handle sorting
		$order = $this->dbGetOrderBySql();

		// Now get the results 
		if (count($this->showFields)) {
			$fieldlist = implode (",", $this->showFields);
		} else {
			$fieldlist = "*";
		}
		$sql  = "SELECT $fieldlist FROM $this->table WHERE ($filters) AND ($searchClause) $order";

		$result = $this->db->query($sql) or die('Query failed: ' . $this->db->error);
		$rows = $result->num_rows;

		if (count($this->showFields)) {
			$fields = $this->showFields;
		} else {
			$fields = $this->fields;
		}


		$fp = fopen('php://output', 'w');
		fputcsv($fp, $fields);
		while ($line = $result->fetch_array(MYSQLI_NUM)) {
			fputcsv($fp, $line);
		}
		fclose($fp);

	}


	######################################################################
	# List the results of an sql query.
	######################################################################
	protected function dbList () {

		echo "<div class='row'>\n";
		echo "   <div class='col-sm-5 float-left' >\n";
		// Show csv export image and link
		if ($this->showExportButton) { $this->dbShowExportLink (); }		// Show the export csv link
		if ($this->showShowHideColumnsButton) { $this->dbShowHideColumnsLink(); } 	// Show the Show/Hide columns link
		if (!$this->readonly) { $this->dbShowInsertLink(); }		// Show insert new row link
		echo "   </div>\n";

		# Show text input box for search string
		echo "   <div class='col-sm-7 float-right'>\n";
		if ($this->showAdvSearch) { $this->dbShowAdvSearchLink(); }
		if ($this->showSearch) { $this->dbSearchForm(); }
		echo "   </div>\n";
		echo "</div>\n";

		# If there were advanced search terms, show them
		if (count($this->asearchTerms)) {
			$this->dbShowAsearchBox();
		}

		// Build sql query for selecting data from database

		// Handle data filters if any
		$filters = "1";
		if (!empty($this->dataFilters)) {
			$filters = implode(' AND ', $this->dataFilters);
		}

		// Handle search request if any
		$searchClause = "1";
		if (!empty($this->search))  { $searchClause = $this->handleSearch(); }

		# Handle advanced search request
		if (count($this->asearchTerms)) { $searchClause = $this->handleAsearch(); }

		// Handle sorting
		$order = $this->dbGetOrderBySql();

		// Show pager links
		$startOffset = $this->dbShowPager ($filters, $searchClause);


		// Now get the results 
		// Get all columns so if primary key field is not displayed, 
		// we can still determine $keystring for the edit link
		$sql  = "SELECT * FROM $this->table ";	
		$sql .= "WHERE ($filters) AND ($searchClause) ";
		$sql .= "$order LIMIT $startOffset,$this->perPage";
#echo $sql;

		$result = $this->db->query($sql) or die('Query failed: ' . $this->db->error);


		echo "<div class='table-responsive'>\n";
		// Create a table for holding row information, with header as first row.
		echo "<table class='table table-striped table-bordered table-sm'>\n";
		$this->dbTableHeader();
		echo "  <tbody>\n";


		// Print row results.
		while ($line = $result->fetch_array(MYSQL_ASSOC)) {
			echo "    <tr>\n";

			if (! empty($this->pk)) {
				$a = array();
				foreach ($this->pk as $key => $value) {
					$a[] = "$value:$line[$value]";
				}
				$keystring = implode(",", $a);
			}

			// Get URL for edit link
			if ( ! $this->readonly) {
				$url = new dbUrl($this->params);
				$url->addQuery("dbe_page", "edit");
				$url->addQuery("dbe_key", $keystring);
				$url->addQuery("dbe_table", $this->table);
				$newurl = $url->getUrl();

				echo "      <td class='centered'><a href='$newurl'>\n";
				echo "        <span class='badge badge-warning' title='Edit this row'><span class='fas fa-edit'></span></span></a>\n";
#echo "<button class='btn btn-warning btn-xs' title='Edit this row'><span class='glyphicon glyphicon-pencil'></span></button>";
				echo "      </td>\n";
			}

			$searchTerm = preg_quote($this->search);
			foreach ($line as $fieldname => $value) {

				# if this field is not in list of fields to show, skip it
				if (! in_array($fieldname, $this->showFields) && count($this->showFields)) { continue; }

				// Substitute query value for actual value
				if (!empty($this->querys[$fieldname])) {
					if (isset($this->querys[$fieldname]['values'][$value])) {
						$value = $this->querys[$fieldname]['values'][$value] . " ($value)";
					} else {
						$value = "";
					}
				}

				// Truncate value if requested
				if (!empty($this->displayLength[$fieldname])) {
					$len = $this->displayLength[$fieldname];
					if (strlen ($value) > $len) {
						$value = substr($value, 0, $len) . " ...";
					}
				} else {
					if (strlen ($value) > $this->defaultDisplayLength) {
						$value = substr($value, 0, $this->defaultDisplayLength) . " ...";
					}
				}

				# Make html tags readable
				$value = htmlspecialchars($value);

				// Highlight search string if present.
				if ($this->search) {
					$value = preg_replace("#($searchTerm)#i", "<span class='searchHighlight'>\$1</span>", $value);
				}

				// Highlight advanced search strings if present.
				foreach ($this->asearchTerms as $aterm) {
					list ($f, $o, $v) = explode("|", $aterm);
					if ($f == $fieldname) {
						$value = preg_replace("#($v)#i", "<span class='searchHighlight'>\$1</span>", $value);
					}
				}

				echo "      <td>$value</td>\n";
			}

			// Delete link
			if ( ! $this->readonly && $this->showDelete) {
				$url = new dbUrl($this->params);
				$url->addQuery("dbe_action", "delete");
				$url->addQuery("dbe_key", $keystring);
				$url->addQuery("dbe_table", $this->table);
				$newurl = $url->getUrl();


				echo "      <td class='centered'>\n";
#				echo "        <a href='javascript:confirmDelete(\"$newurl\")'>";
#echo "<button class='btn btn-default' data-toggle='confirmation'>";
echo "<a class='' data-toggle='confirmation' data-title='Are you sure you want to delete this?' href='$newurl'>";
				echo "<span class='badge badge-danger' title='Delete this row'><span class='fas fa-times'></span></span>\n";
echo "</button>";
				echo "      </td>\n";
			}
			echo "    </tr>\n";
		}

		// Free resultset
		$result->free();
		echo "  </tbody>\n";
		echo "</table>\n";
		echo "</div>\n";
		$startOffset = $this->dbShowPager ($filters, $searchClause);

	}

	#################################################################
	# Display pager information
	#################################################################
	protected function dbShowPager ($filters, $searchClause) {

		$url = new dbUrl($this->params);
		$url->addQuery("dbe_table", $this->table);

		// Get total rows
		$sql = "SELECT COUNT(*) FROM $this->table WHERE ($filters) AND ($searchClause)";
		$result = $this->db->query($sql);
		if (!$result) {
			$msg = 'Query failed: ' . $this->db->error;
			$this->showError($msg);
			return 0;
		}
		$row = $result->fetch_row();
		$result->free();
		$total = $row[0];

		$delta = 2;
		$lastpage = max(1,ceil($total/$this->perPage));
		if ($this->pageID > $lastpage) { $this->pageID = $lastpage; } 

		$startOffset = $this->perPage * ($this->pageID - 1);

		if (!$this->showPager) { return $startOffset; }

		// Show pager information
		echo "\n<div class='navbar navbar-light bg-light border'>";
		echo "    <div class='navbar-text float-left small'> Displaying [";
		echo ($total > 0 ? $startOffset + 1 : 0);
		echo " - ";
		echo min($startOffset + $this->perPage, $total);
		echo "] of $total records. &nbsp;&nbsp;&nbsp;";

		$ss = $url->getUrl();
		$a = strstr ($ss, "?");
		if ($a) {
			$ss .= "&dbe_setPerPage=";
		} else {
			$ss .= "?dbe_setPerPage=";
		}
		echo " (Show <input class='span1 inputsmall' type=\"text\" value=\"$this->perPage\" onchange=\"window.location = '$ss'+this.value\" size=\"3\"/> Records per page.)</div>\n";

		if ($lastpage > 1) {

			echo "  <ul class='pagination float-right'>\n";

			# determine page range for links
			if ($this->pageID <= $delta) {
				$startpage = 1;
				$endpage = min($lastpage, 1 + 2*$delta);
			} elseif ($this->pageID >= $lastpage - $delta) {
				$endpage = $lastpage;
				$startpage = max(1, $endpage - 2*$delta);
			} else {
				$startpage = max(1, $this->pageID - $delta);
				$endpage = min($lastpage, $this->pageID + $delta);
			}


			// first
			if ($startpage > 1) {
				$url->addQuery("dbe_pageID", 1);
				$prevurl = $url->getUrl();
				echo "    <li><a class='page-link' title='first page' href='$prevurl'>First</a></li>\n";
			}

			//previous
			if ($this->pageID > 1) {
				$url->addQuery("dbe_pageID", $this->pageID - 1);
				$prevurl = $url->getUrl();
				echo "    <li class='page-item'><a class='page-link' title='previous page' href='$prevurl'>&laquo; Previous</a></li>\n";
			}

			# pages
			for ($counter = $startpage; $counter <= $endpage; $counter++) {
				if ($counter == $this->pageID) {
					echo "    <li class='page-item active'><a class='page-link'>$counter</a></li>\n";
				} else {
					$url->addQuery("dbe_pageID", $counter);
					$newurl = $url->getUrl();
					echo "    <li class='page-item'><a class='page-link' title='page $counter' href='$newurl'>$counter</a></li>\n";
				}
			}

			// next
			if ($this->pageID < $lastpage) {
				$url->addQuery("dbe_pageID", $this->pageID+1);
				$nexturl = $url->getUrl();
				echo "    <li class='page-item'><a class='page-link' title='next page' href='$nexturl'>Next &raquo;</a></li>\n";
			}

			// last
			if ($lastpage > $endpage) {
				$url->addQuery("dbe_pageID", $lastpage);
				$nexturl = $url->getUrl();
				echo "    <li class='page-item'><a class='page-link' title='last page' href='$nexturl'>Last</a></li>\n";
			}

			echo "  </ul>\n";
		}

		echo "</div>\n";

		return $startOffset;

	}


	#################################################################
	# Create a form that shows each field name with a checkbox.
	# User can select fields that are to be visible in the dbList function.
	#################################################################
	protected function dbShowHideColumns () {

		$url = $this->script;

		echo "<div id='showhideform' class='modal fade' aria-hidden='true' aria-labelledby='myModalLabel' role='dialog' tabindex='-1'>\n";
		echo "  <div class='modal-dialog'>\n";
		echo "    <div class='modal-content'>\n";
		echo "      <div class='modal-header'>\n";
		echo "        <h5 class='modal-title'>Select Columns to Display</h5>\n";
		echo "        <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>\n";
		echo "      </div>\n";
		echo "      <form action='$url' method='post' name='editForm' id='editForm'>\n";
		echo "      <fieldset>\n";
		echo "      <div id='checklist' class='modal-body'>\n";

		foreach ($this->fields as $name) {
			$s = "dbe_" . $name;
			echo "      <input type='checkbox' value='1' name='$s' ";
			if (in_array($name, $this->showFields) || count($this->showFields) == 0) { echo "checked "; }
			echo "> $name<br>\n";
		}

		echo "      </div>\n";
		echo "      <div class='modal-footer'>\n";
		echo "        <button id='_checklistApply' class='btn btn-primary' name='dbe_showhide' value='Ok'>Apply</button>\n";
		echo "        <button id='_checklistClose' class='btn btn-light' name='dbe_cancel' value='Cancel' data-dismiss='modal'>Cancel</button>\n";
		echo "      </div>\n";

		$this->dbSetHiddenFormFields2($this->params);

		echo "      <input name='dbe_table' type='hidden' value='$this->table' />\n";
		echo "      </fieldset>\n";
		echo "      </form>\n";
		echo "    </div>\n";
		echo "  </div>\n";
		echo "</div>\n";

		return;

	}

	#################################################################
	# show a box listing filter criteria from advanced search
	#################################################################
	protected function dbShowAsearchBox() {
		echo "<div class='row'>\n";
		echo "  <div class='asearchbox float-right'>\n";
		echo "    <div class='legend'>Results filtered by: </div>\n";
		$foo = 1;
		if ($this->asearchMatch == "any") {
			$s = "OR";
		} else {
			$s = "AND";
		}
		foreach ($this->asearchTerms as $term) {
			list($f, $o, $v) = explode("|", $term);
			if ($o == "%") { $o = "Contains"; }
			if ($foo) {
				echo "    <i>$f</i> $o '$v'<br>\n";
				$foo = 0;
			} else {
				echo "    $s <i>$f</i> $o '$v'<br>\n";
			}
		}
		echo "  </div>";
		echo "</div>";
	}

	#################################################################
	protected function dbShowAdvSearchLink() {

		echo "<div class='float-right'>";
		echo "<a href='#' data-toggle='modal' data-target='#asearchform'><button class='btn btn-light border btn-sm ml-3'>Advanced Search <span class='fas fa-chevron-right'></span></button></a>";

		if (!empty($this->search) || count($this->asearchTerms)) {
			$url = new dbUrl($this->params);
			$url->removeQuery("dbe_page");
			$url->removeQuery("dbe_search");
			$url->removeQuery("dbe_asearchTerms");
			$url->addQuery("dbe_table", $this->table);
			$newurl = $url->getUrl();
			echo "<a href='$newurl'><button class='btn btn-light btn-sm border ml-3'>Clear Search <span class='fas fa-remove-sign'></span></button></a>\n";
		}
		echo "</div>";
	}

	#################################################################
	# Show a link for adding a new row, and search form.
	#################################################################
	protected function dbShowInsertLink() {

		if ($this->readonly) { return; }

		// Get URL for add link
		$url = new dbUrl($this->params);
		$url->addQuery("dbe_page", "add");
		$url->addQuery("dbe_table", $this->table);
		$newurl = $url->getUrl();
		echo "<a href='$newurl'><button class='btn btn-light btn-sm border'>";
		echo "Insert New Row";
		echo " <span class='fas fa-plus'></span>";
		echo "</button></a>\n";
	}

	#################################################################
	protected function dbShowHideColumnsLink() {
		
		echo "<button class='btn btn-light btn-sm border mr-3' data-toggle='modal' data-target='#showhideform' >Show/Hide columns</button>";
	}

	#################################################################
	# Display the link for export to csv
	#################################################################
	protected function dbShowExportLink () {

		// Show image for exporting csv link.
		$url = new dbUrl($this->params);
		$url->addQuery("dbe_page", "export");
		$url->addQuery("dbe_table", $this->table);

#		$path = $this->baseURL . "/export.php";
#!!!!FIX
#$path = "/dbedit/export.php";
		$newurl = $url->getUrl(); # $path);
		echo "<a href='$newurl'>";

		echo "<button class='btn btn-light btn-sm border mr-3' title='Export the current result set in comma separated value (CSV) format.'>";
		echo "<span class='fas fa-download'></span> CSV</button></a>";

	}

	#################################################################
	protected function showError($msg) {

		echo "<div class='alert alert-danger'>$msg</div>";

	}


	#################################################################
	/* Execute the sql statement, return results as associative array.
	* This means sql must return at least columns for each row.
	*
	*/
	protected function dbGetAssoc($sql) {
		$results = array();

		$res = $this->db->query($sql);
		if (!$res) {
			$msg ='Could not run query: ' . $this->db->error;
			$this->showError($msg);
			return;
		}

		$rows = $res->num_rows;
		if ($res AND $rows > 0) {
			while ($row = $res->fetch_row()) {
				$s = implode(" ", array_slice($row, 1));
				$results[$row[0]] = $s;
			}

			return $results;
		}

		return 0;
	}


	#################################################################
	# Create the sql string for querying the database to get the single
	# row of data to edit.
	#################################################################
	protected function getEditQuery($keystring) {

		$fieldlist = implode (",", $this->fields);

		$wheresql = $this->dbGetWhereCond($keystring);
		$sql = "SELECT $fieldlist FROM $this->table WHERE $wheresql";

		return $sql;
	}


	#################################################################
	# return a mysql 'where' condition based on primary keys and their values.
	#################################################################
	protected function dbGetWhereCond($keystring) {

		$whereitems = array();
		$wheresql = "";

		if (!empty($keystring)) {
			$a = explode(",", $keystring);
			foreach ($a as $item) {
				list($name, $value) = explode(":", rawurldecode($item));
				$str = $this->dbQuote($value);
				$whereitems[] = "$name=$str";
			}

			$wheresql = implode (" AND ", $whereitems);
		}

		return $wheresql;
	}


	#################################################################
	# Display the form for editing a row in the database.
	#################################################################
	protected function dbEditRow ($task, $keystring) {
#		$dateregexp = "/^(\d\d\d\d)-(\d|0\d|1[0-2])-([1-9]|0\d|1\d|2\d|3[0-1])?$/";
#		$timeregexp = "/^(\d|0\d|1\d|2[0-3]):([0-9]|[0-5]\d)(:[0-5]\d?)?$/";

		if ($task == "edit") {
			$headerstring = "<span class='badge badge-info p-2 rounded'>Edit row in table <span class='badge badge-light'>'$this->table'</span></span>";
			$sql = $this->getEditQuery($keystring);
#echo $sql;
			$result = $this->db->query($sql);
			if (!$result) {
				$msg ='Could not run query: ' . $this->db->error;
				$this->showError($msg);
				return;
			}
			$values = $result->fetch_assoc();
		} else {
			$headerstring = "<span class='label label-info'>Add row to table <span class='badge'>'$this->table'</span></span>";
		}

		$url = $this->script;

		echo "<div id='mainform'>\n";
		echo "  <form action='$url' method='post' name='editForm' id='editForm' class='form-horizontal'>\n";
		echo "  <fieldset>\n";
#		echo "    <legend>$headerstring</legend>\n";
		echo "    <h5>$headerstring</h5>\n";

                $autoinc = $this->dbinfo->autoinc_field;
$nd = 0;

		foreach ($this->fields as $name) {
			$formname = "dbe_" . $name;
			$value = "";
			if ($task == "edit") { $value = $values[$name]; }
			$label = ucwords($name);

			$editable = 1;

			if (isset($this->editContent[$name])) {
				$editable = $this->editContent[$name];
			}

			list($ftype, $size) = $this->dbinfo->fieldType($name);

			echo "  <div class='form-group row'>\n";
			echo "    <label class='col-sm-3 col-form-label text-right' for='$formname'>$label ($ftype)</label>\n";
			echo "    <div class='col-sm-6'>\n";


			# If the fieldname is related to some other table/field, 
			# use a select box with options instead of an input
			if (!empty($this->querys[$name])) {
				echo "<select name='$formname' class='form-control' ";
				if (!$editable) { echo " disabled "; }
                                echo ">\n";
				foreach ($this->querys[$name]['values'] as $key=>$val) {
					echo "  <option value='$key' ";
					if ($value == $key) { echo "selected"; }
					echo ">$val ($key)</option>\n";
				}
				echo "</select>\n";


			} else {

				switch ($ftype) {

				case 'boolean':
					echo "    <input type='hidden' name='$formname' value='0'>";
					echo "    <input type='checkbox' value='1' name='$formname' ";
					if ($value) { echo "checked "; }
					if (!$editable) { echo " disabled "; }
					echo ">\n";
					break;

				case 'date':
					echo "<div class='input-group date dateonly' id='datepicker$nd' data-target-input='nearest'>";
					echo "  <input type='text' class='form-control datetimepicker-input' value='$value' name='$formname' data-target='#datepicker$nd' ";
					if (!$editable) { echo " disabled "; }
					echo ">\n";
					echo "<div class='input-group-append' data-target='#datepicker$nd' data-toggle='datetimepicker'>";
					echo "    <div class='input-group-text'><i class='fas fa-calendar'></i></div>";
					echo "</div>";
					echo "</div>";
$nd += 1;
					break;

				case 'datetime':
				case 'timestamp':
					echo "<div class='input-group date datetime' id='datepicker$nd' data-target-input='nearest'>";
					echo "  <input type='text' class='form-control datetimepicker-input' value='$value' name='$formname' data-target='datepicker$nd' ";
					if (!$editable) { echo " disabled "; }
					echo ">\n";
					echo "<div class='input-group-append' data-target='#datepicker$nd' data-toggle='datetimepicker'>";
					echo "    <div class='input-group-text'><i class='fas fa-calendar'></i></div>";
					echo "</div>";
					echo "</div>";
$nd += 1;
					break;

				case 'enum':
					$a = split(',', str_replace("'", "", $size));
					echo "<select name='$formname' class='form-control' ";
					if (!$editable) { echo " disabled "; }
					echo ">\n";
					foreach ($a as $val) {
						echo "  <option value='$val' ";
						if ($value == $val) { echo "selected"; }
						echo ">$val</option>\n";
					}
					echo "</select>\n";
					break;

				case 'file':
	#				$form->addElement('file', $name, $label, 'size=' . $size . ' value=' . $value);
	#				$form->addElement('static', 'xxx', '', "<span class='small'>Currently ($value)</span>");
					break;

				case 'longtext':
				case 'text':
				case 'tinytext':
				case 'blob':
					$len = strlen($value);
					$nrows = (int)($len/120) + 1;
					$nnl = substr_count($value, "\n");
					$nrows = max($nrows, $nnl);
					$zn = count (explode ("\n", $value));
					$nrows = max($nrows, $zn);
					if ($nrows > 40) { $nrows = 40; }
					if ($nrows < 5) { $nrows = 5; }
					echo "<textarea rows='$nrows' id='$name' cols='100' name='$formname' class='form-control' ";
					if (!$editable) { echo " disabled "; }
					echo ">$value</textarea>\n";
					break;

				case 'tinyint':
				case 'smallint':
				case 'mediumint':
				case 'int':
				case 'bigint':
				case 'decimal':
				case 'float':
				case 'double':
					echo "        <input class='form-control number' type='text' value='$value' name='$formname' data-error='Enter a valid number' ";
					if ($name == $autoinc || !$editable) {
						echo "disabled";
					}
					echo ">\n";

					break;

				default:
					$value = htmlspecialchars($value, ENT_QUOTES);
					echo "<input class='form-control' type='text' value='$value' name='$formname' ";
					if (!$editable) { echo " disabled "; }
					echo ">\n";

					break;
				}
			}

			echo "    </div>\n";
			echo "  </div>\n";
		}

                echo "    <div class='row'>\n";
                echo "      <div class='col-sm-3'></div>\n";
                echo "      <div class='col-sm-6'>\n";
                echo "        <div class='form-actions'>\n";
#                echo "          <button id='_editApply' class='btn btn-primary' name='dbe_apply' value='Ok'>Apply</button>\n";
 #               echo "          <button id='_editClose' class='btn btn-light cancel' name='dbe_cancel' value='Cancel' data-dismiss='modal'>Cancel</button>\n";
                echo "          <input type='submit' class='btn btn-primary' name='dbe_save' value='Save' title='Save changes, return to listing.'/>\n";
		if ($task == "edit") { echo "          <input type='submit' class='btn btn-secondary' name='dbe_apply' value='Apply' title='Apply changes, remain on edit form.'/>\n"; }
                echo "          <input type='submit' class='btn btn-secondary cancel' name='dbe_cancel' value='Cancel' formnovalidate title='Cancel changes.'/>\n";
                echo "        </div>\n";
                echo "      </div>\n";
                echo "    </div>\n";

		echo "  </fieldset>\n";

		# Set hidden fields for info we need to remember on each load
		$this->dbSetHiddenFormFields2($this->params);

		if ($task == "edit") {
			$actionval = "update";
		} else {
			$actionval = "insert";
		}
		echo "  <input name='dbe_action' type='hidden' value='$actionval' />\n";
		echo "  <input name='dbe_key' type='hidden' value='$keystring' />\n";
		echo "  <input name='dbe_table' type='hidden' value='$this->table' />\n";
		if (!empty($this->option)) {
			foreach ($this->option as $a) {
				$optname = key($a);
				$val = $a[$optname];
				echo "  <input name='$optname' type='hidden' value='$val' />\n";
			}
		}
		echo "  </form>\n";
		echo "</div>\n";

		print <<<HTML
		<script>
		$(document).ready( function() {
$.fn.datetimepicker.Constructor.Default = $.extend({}, $.fn.datetimepicker.Constructor.Default, {
            icons: {
                time: 'fas fa-clock',
                date: 'fas fa-calendar',
                up: 'fas fa-arrow-up',
                down: 'fas fa-arrow-down',
                previous: 'fas fa-chevron-left',
                next: 'fas fa-chevron-right',
                today: 'fas fa-calendar-check-o',
                clear: 'fas fa-trash',
                close: 'fas fa-times'
            } });


			$('.dateonly').datetimepicker({format: 'YYYY-MM-DD', useCurrent: false});
			$('.datetime').datetimepicker({format: 'YYYY-MM-DD HH:mm:ss', useCurrent: false});
//			$("#editForm").validate();
		});
		</script>
HTML;

		foreach ($this->fields as $name) {
			if (isset($this->htmlEdit[$name])) {
				if ($this->htmlEdit[$name] == 1) {
					echo "<script type='text/javascript'> CKEDITOR.replace(\"$name\"); </script>";
				}
			}
		}

	}

	#################################################################
	# Update or insert a row in the database, after editing.
	#################################################################
	protected function dbUpdate ($table, $which, $keystring) {

		if ($this->readonly) { return; }

		# Find out if any key fields are auto_increment
		$autoinc = $this->dbinfo->autoinc_field;

		// Create the SET ... part of the sql query
		$sets = array();
		foreach ($this->fields as $name) {
			list($ftype, $size) = $this->dbinfo->fieldType($name);
			$formname = "dbe_" . $name;
			if (isset ($_POST[$formname])) {
				$s = $this->dbQuote($_POST[$formname], $ftype);
#echo "--- " . $formname . " " . $_POST[$formname] . " " . $ftype . " s is " . $s . " : " . strlen($s) . "<br>";
if ($s != "''" or strpos($ftype, "varchar")!==false) {
				if ($name != $autoinc) { 
					$sets[] = "$name = {$s}";
				}
}

/*
			} elseif (isset ($_FILES[$formnamname]['name'])) {
				$filename = $_FILES[$formnamename]['name'];
				$s = $this->dbQuote($filename);
				$sets[] = "$name = {$s}";

				if (isset($this->fileDir[$formname])) {
					$dir = $this->fileDir[$formname];
				} else {
					$dir = ".";
				}

				if (!move_uploaded_file($_FILES[$formname]['tmp_name'], $dir."/".$filename)) {
					echo "<span class='highlight'>There was an error uploading the file $filename.</span><p>";
				}
*/
			}
		}
		$sets = implode(', ', $sets);

#		if (!empty($this->dataFilters)) {
#			$filters = implode(' AND ', $this->dataFilters);
#			$query .= " AND " . $filters;
#		}
#echo $query;
#return;
		if ($which == "update") {
			$query = "UPDATE $table SET $sets ";
			$wheresql = $this->dbGetWhereCond($keystring);
			$query .= " WHERE $wheresql";
#echo $query;
			$result = $this->db->query($query);
			if (!$result) { 
				$msg = 'Update failed: ' . $this->db->error; 
				$this->showError($msg);
			} else {
				if (!empty($this->logTable)) {
					$this->logChange($query);
				}
				echo "<h6><span class='highlight'>Updated 1 record in table '$table'.</span></h6>";
			}
		} else {
			$query = "INSERT INTO $table SET $sets ";
#echo $query;
			$result = $this->db->query($query);
			if (!$result) { 
				$msg = 'Insert failed: ' . $this->db->error; 
				$this->showError($msg);
			} else {
				if (!empty($this->logTable)) {
					$this->logChange($query);
				}
				echo "<h6><span class='highlight'>Inserted 1 record into table '$table'.</span></h6>";
			}
		}
	}


	#################################################################
	protected function dbDelete ($table, $keystring) {


		if ($this->readonly) { return; }

		$wheresql = $this->dbGetWhereCond($keystring);
		$query = "DELETE FROM $table WHERE $wheresql LIMIT 1";
#echo $query;
		$result = $this->db->query ($query);
		if (!$result) { 
			$msg = 'Delete failed: ' . $this->db->error; 
			$this->showError($msg);
		} else {
			if (!empty($this->logTable)) {
				$this->logChange($query);
			}
			echo "<h6><span class='highlight'>Deleted 1 record from table '$table'.</span></h6>";
		}
	}

	#################################################################
	protected function logChange ($query) {

		$today = date("Y-m-d H:i:s");
		if (isset($_SERVER['REMOTE_USER'])) {
			$user = $_SERVER['REMOTE_USER'];
		} else {
			$user = "nouser";
		}

		$s = "INSERT INTO $this->logTable (user, date, query_string) VALUES (?, ?, ?)";
		$stmt = $this->db->prepare($s);
		if (!$stmt) {
			$this->showError($this->db->error);
		} else {
			$stmt->bind_param('sss', $user, $today, $query);
			$stmt->execute();
			$stmt->close();
		}

	}


	######################################################################
        # Quotes and escapes a string for use in a query.
	########################################################
        protected function dbQuote($str, $fieldtype="") {
		if (is_null($str)) { return 'NULL'; }

		// Handle magic_quotes_gpc 
		if (ini_get('magic_quotes_gpc')) {
			$str = stripslashes($str);
		}

		if ($fieldtype == "") {
			if (is_numeric($str)) {
				return $this->db->real_escape_string($str);
			} else {
				return "'" . $this->db->real_escape_string($str) . "'";
			}
		} else {
			if (strpos($fieldtype, "char") !== false) {
				return "'" . $this->db->real_escape_string($str) . "'";
			} else {		# should do more checks here
				if (is_numeric($str)) {
					return $this->db->real_escape_string($str);
				} else {
					return "'" . $this->db->real_escape_string($str) . "'";
				}
			}
		}
        }


	########################################################
	# Display the simple search form
	########################################################
	protected function dbSearchForm() {

		// Show Search form if desired
		if ($this->showSearch) {
			echo "<div class='float-right'>";

			// Url referring back to original page.
			$url = $this->script;

			// Create hidden fields to hold the optional query data
			echo "\n\n  <form class='form-search' action='$url' method='get' name='searchForm' id='searchForm'>\n";
			if (!empty($this->option)) {
				foreach ($this->option as $a) {
					$key = key($a);
					$value = $a[$key];
					echo "    <input type='hidden' value='$value' name='$key'>\n";
				}
			}
			$this->dbSetHiddenFormFields2($this->params);


			echo "    <input name='dbe_table' type='hidden' value='$this->table' />\n";
			echo "      <div class='input-group mb-3'>\n";
			echo "         <input type='text' name='dbe_search' value='$this->search' class='form-control form-control-sm' id='searchInput' placeholder='Search' aria-describedby='sizing-addon3'>\n";
			echo "         <div class='input-group-append'>\n";
			echo "            <button class='input-group-text'><i class='fas fa-search'></i></button>\n";
			echo "         </div>\n";
			echo "      </div>\n";

			echo "  </form>\n\n";
			echo "</div>\n";
			echo "<span class='small gray float-right' style='margin: 5px 5px 0 0;'><em>Show rows that contain:</em></span>";
		}
	}

	########################################################
        # Shows the advanced search page
	# This is called from the main page advanced search link,
	# with any previous parameters passed in via GET[].
	########################################################
        protected function showAdvancedSearchPage() {

		$searchFields = $this->fields;

		// Define the various operators
		$operators[] = array('value' => '%',  'text' => 'Contains');
		$operators[] = array('value' => '!%', 'text' => 'Does Not Contain');
		$operators[] = array('value' => '=',  'text' => 'Equals');
		$operators[] = array('value' => '>',  'text' => 'Greater Than (>)');
		$operators[] = array('value' => '>=', 'text' => 'Greater Than or Equal to (>=)');
		$operators[] = array('value' => '<',  'text' => 'Less Than (<)');
		$operators[] = array('value' => '<=', 'text' => 'Less Than or Equal to (<=)');

		// Check querystring for potential search modifications
		$criteria = array();
 
		if (count($this->asearchTerms)) {
			foreach ($this->asearchTerms as $f) {
				list($field, $oper, $val) = explode("|", $f);
				$criteria[] = array('field' => $field, 'operator' => $oper, 'value' => $val);
			}
		} else {
			$criteria[] = array('field' => '', 'operator' => '', 'value' => '');
		}

		// Display the form
		echo "<div id='asearchform' class='modal fade' aria-hidden='true' aria-labelledby='myModalLabel' role='dialog' tabindex='-1'>\n";
		echo "  <div class='modal-dialog'><div class='modal-content'>\n";
		echo "    <div class='modal-header'>\n";
		echo "       <h5>Advanced Search</h5>\n";
		echo "       <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>\n";
		echo "    </div>\n";
		echo "    <form action='$this->script' method='post' name='asearchForm' id='asearchForm'>\n";
		echo "    <fieldset>\n";
		echo "    <div class='modal-body'>\n";

		$numcriteria = count($this->asearchTerms);
		if ($numcriteria == 0) { $numcriteria = 1; }
		echo "      <div class='criteria'>      Number of Search Criteria:\n";
		echo "        <select class='span1' onchange='changeCriteria(); return false;' name='dbe_numcriteria'>\n";
		for ($i = 1; $i<=8; $i++) {
			echo "        <option value='$i' ";
			if ($i == $numcriteria) { echo "selected "; }
			echo ">$i</option>\n";
		}
		echo "        </select>\n";
		echo "      </div>\n";

		echo "      <table class='table table-condensed' id='asearchTable'>\n";
		foreach ($criteria as $num => $data) {
			echo "      <tr id='asearchRow'>\n";
    
			// First column, field names
			echo "      <td>\n";
			echo "        <select class='form-control' name='dbe_fields[]'>\n";
			echo "        <option value=''>Select...</option>\n";
			foreach ($searchFields as $sf) {
				echo "    <option value='$sf'";
				echo ($sf == $data['field'] ? ' selected' : '');
				echo ">$sf</option>\n";
			}
                	echo "        </select>\n";
			echo "      </td>\n";
    
			// Second column, operators
			echo "      <td>\n";
			echo "        <select class='form-control' name='dbe_operators[]'>\n";
			foreach ($operators as $o) {
				echo "    <option value='";
				echo $o['value'];
				echo "'";
				echo ($o['value'] == $data['operator'] ? ' selected': '');
				echo ">";
				echo $o['text'];
				echo "</option>\n";
			}
                	echo "        </select>\n";
			echo "      </td>\n";
    
			// Third column, values
			echo "      <td>\n";
			echo "        <input class='form-control' type='text' name='dbe_values[]' value='";
			echo htmlspecialchars($data['value']);
			echo "'>\n";
			echo "      </td>\n";
			echo "      </tr>\n";
		}
		echo "      </table>\n";

		echo "      <div>\n";
		echo "        Match:&nbsp;&nbsp;\n";
		echo "        <div class='radio'>\n";
		echo "          <label>";
		echo "          <input type='radio' name='dbe_match' value='any' id='match_any' ";
		if ($this->asearchMatch != 'all' ) { echo "checked"; }
		echo "> Any Criteria (OR) </label>\n";
		echo "        </div>\n";

		echo "        <div class='radio'>\n";
		echo "          <label class='radio inline' for='match_all'>";
		echo "          <input type='radio' name='dbe_match' value='all' id='match_all' ";
		if ($this->asearchMatch == 'all' ) { echo "checked"; }
		echo "> All Criteria (AND)</label>\n";
		echo "        </div>\n";

		echo "      </div>\n";
		echo "    </div>\n";	# end modal body
        
		// Show the cancel and search buttons
		echo "    <div class='modal-footer'>";
		echo "      <button id='_asearchApply' class='btn btn-primary' name='dbe_asearch' value='Ok'>Apply</button>\n";
		echo "      <button id='_asearchClose' class='btn btn-light' name='dbe_cancel' value='Cancel' data-dismiss='modal'>Cancel</button>\n";
		echo "    </div>";

		// Create hidden fields to hold the optional query data
		if (!empty($this->option)) {
			foreach ($this->option as $a) {
				$key = key($a);
				$value = $a[$key];
				echo "  <input type='hidden' value='$value' name='$key'>\n";
			}
		}

		$this->dbSetHiddenFormFields2($this->params);

		echo "    <input name='dbe_table' type='hidden' value='$this->table' />\n";
		echo "    </fieldset>\n";
		echo "    </form>\n";
		echo "  </div></div>\n";
		echo "</div>\n";

		// Include javascript for dynamically adding criteria fields.
		include "asearch.js";

        }

	########################################################
	# Return a valid sql where clause from requested search characters.
	########################################################
        protected function handleSearch() {

		$searchStr    = $this->dbQuote('%' . $this->search . '%');
		$searchClause = array();
		foreach ($this->fields as $sf) {

			// Handle fields which have predefined values set
			if (!empty($this->querys[$sf]['values'])) {
				foreach ($this->querys[$sf]['values'] as $k => $v) {
					if (strpos(strtolower($v), strtolower($this->search)) !== false) {
						$in[] = $this->dbQuote($k);
					}
				}

				if (!empty($in)) {
					$instring = implode (', ',$in);
					$searchClause[] = "$sf IN($instring)";
				}
			} else {
				$searchClause[] = "$sf LIKE $searchStr";
			}
		}
		if (!empty($searchClause)) {
			$searchClause = implode(' OR ', $searchClause);
		} else {
			$searchClause = '0';
		}

		return $searchClause;

	}

	########################################################
	# Take the values in the $this->asearchTerms array
	# and create an sql clause that will go into the 'WHERE' part of the sql statement
	########################################################
        protected function handleAsearch() {

		$searchClause = "";

		$terms = array();
		if ($this->asearchMatch == "any") {
			$s = " OR ";
		} else {
			$s = " AND ";
		}

		foreach ($this->asearchTerms as $term) {
			list($f, $o, $v) = explode("|", $term);
			if (in_array($f, $this->fields)) {
				if ($o == "%") {
					$v = $this->db->real_escape_string($v);
					$v = "'%" . $v . "%'";
					$o = 'LIKE';
				} else {
					$v = $this->dbQuote($v);
				}
				$str = "$f $o $v";
				$terms[] = $str;
			}
		}
		$searchClause = implode($s, $terms);
		
		return $searchClause;

	}


	#############################################################
	/* Get HTTP variable.
	*
	* @param string $name : name of the variable in the $_GET array
	* @param string $default : the default value to use if http variable doesn't exist or is bad
	* @param string $type : type of answer, int, float, string, date, array
	* @param array $allowed : an array of allowed values
	* @param float $min, $max : check variable is between minimum and maximum values if variable is an int or float
	* $checkdate if true means check that value is a valid date.
	* If variable name is given in URL (in _GET), use that instead of what might
	* be saved in cookie (in _COOKIE),
	*/
	#############################################################
	protected function getHTTPVar($name, $default = "", $type = VAL_STRING, $allowed = array(), $min = '', $max = '') {

		$val = $default;

		if (isset ($_GET[$name])) {
			$tmp = $_GET[$name];
		} elseif (isset ($_POST[$name])) {
			$tmp = $_POST[$name];
		} elseif (isset ($_COOKIE[$name])) {
			$tmp = $_COOKIE[$name];
		} else {
			return $default;
		}


		if ($type != VAL_ARRAY) {
			if (strlen($tmp) == 0) { return $default; }
		}

		switch ($type) {
		case VAL_INT:
			$int = intval($tmp);
			if((($min != '') && ($int < $min)) || (($max != '') && ($int > $max))) {
				return $default;
			}
			$val = $this->check_allowed($int, $allowed, $default);
			break;

		case VAL_FLOAT:
			$float = floatval($tmp);
			if ((($min != '') && ($float < $min)) || (($max != '') && ($float > $max))) {
				return $default;
			}
			$val = $this->check_allowed($float, $allowed, $default);
			break;

		case VAL_DATE:
			$t = strtotime($tmp);
			if ($t === FALSE) {
				return $default;
			}
			$val = date("Y-m-d", $t);
			break;

		case VAL_STRING:
			$val = $this->check_allowed($tmp, $allowed, $default);
			$val = rawurldecode($val);
			break;

		case VAL_ARRAY:
			$val = $tmp;
			break;

		}
		

		return $val;
	}

	###############################################
	# check that $tmp is in the $allowed array, otherwise return $default.
	# if nothing in $allowed, return the given value $tmp.
	protected function check_allowed($tmp, $allowed, $default) {

		$val = $tmp;

		if ( count($allowed)) {
			$val = $default;
			foreach ($allowed as $v) {
				if (strcasecmp((string) $tmp, (string) ($v)) == 0) {
					$val = $tmp;
					break;
				}
			}
		}

		return $val;
	}

	###############################################
	# get url queries that dont start with 'dbe_'
	###############################################
	protected function getUrlParams() {

		$params = array();
		foreach ($_GET as $key=>$value) {
			if ( substr($key, 0, 4) != "dbe_") {
				$params[$key] = $value;
			}
		}
		foreach ($_POST as $key=>$value) {
			if ( substr($key, 0, 4) != "dbe_") {
				$params[$key] = $value;
			}
		}

		return $params;

	}


	###############################################
	protected function dbSetHiddenFormFields2($params) {
		foreach ($params as $key=>$value) {
			if (is_array($value)) {
				foreach ($value as $v) {
					$k = $key . "[]";
					echo "    <input type='hidden' value='$v' name='$k'>\n";
				}
			} else {
				echo "    <input type='hidden' value='$value' name='$key'>\n";
			}
		}
	}



}

#=====================================================================================
class dbUrl {

	#-----------------------------------------------------
	function __construct($params = array()) {

		$this->params = array();

		if ( count($params)) {
			$this->params = $params;
		}

	}

	#-----------------------------------------------------
	function addQuery($name, $value) {

		$this->params[$name] = is_array($value) ? array_map('rawurlencode', $value): rawurlencode($value);
	}

	#-----------------------------------------------------
	function removeQuery($name) {

		if (isset($this->params[$name])) {
		    unset($this->params[$name]);
		}

	}

	#-----------------------------------------------------
	function getUrl($path = "") {

		$s = empty($_SERVER["HTTPS"]) ? '' : ($_SERVER["HTTPS"] == "on") ? "s" : "";
		$sp = strtolower($_SERVER["SERVER_PROTOCOL"]);
		$protocol = substr($sp, 0, strpos($sp, "/")) . $s;
		$port = ($_SERVER["SERVER_PORT"] == "80") ? "" : (":".$_SERVER["SERVER_PORT"]);

		if (empty($path)) {
			$path = !empty($_SERVER['PHP_SELF']) ? $_SERVER['PHP_SELF'] : '/';
		}

		$querystring = http_build_query($this->params);

		$query = (!empty($querystring) ? '?' . $querystring : '');

		$url = $protocol . "://" . $_SERVER['SERVER_NAME'] . $port . $path . $query;

		return $url;
	}
}

#=====================================================================================
class dbInfo {


        ######################################################################
        /**
        * Constructor
        *
        * @param mysqli connection  $conn
        * @param string  $table    Get column information for this table.
        */
        ######################################################################
        function __construct($conn, $allowed_tables=array()) {

		$this->db = $conn;

		$sql = "show tables";
		$result = $this->db->query($sql) or die('Query failed: ' . $this->db->error);
		$nrows = $result->num_rows;
		$this->tables = array();
		while ($row = $result->fetch_array()) {
			if (count($allowed_tables)) {
				if (in_array($row[0], $allowed_tables)) {
					$this->tables[] = $row[0];
				}
			} else {
				$this->tables[] = $row[0];
			}
		}

	}

        ######################################################################
	function tableExists($table) {

		if (in_array($table, $this->tables)) {
			return 1;
		} else {
			return 0;
		}
	}

        ######################################################################
	function getTableInfo($table) {

		$this->fields = array();
		$this->autoinc_field = "";
		$this->names = array();
		$this->keys = array();

		if (!$this->tableExists($table)) {
			return 0;
		}

		//Get names of columns in table, put them in array
		$query = "SHOW COLUMNS FROM $table";
		$result = $this->db->query($query);
		if (!$result) {
			echo 'Could not run query: ' . $this->db->error;
			exit;
		}


		while ($row = $result->fetch_assoc()) {
			$name = $row["Field"];
			$type = $row["Type"];
			if ($row["Extra"] == "auto_increment") {
				$this->autoinc_field = $name;
			}

			# get size
			$a = explode('\(', $type);
			if (count($a) > 1) {
				$f = $a[0];
				list($s, $z) = explode('\)', $a[1]);
			} else {
				$f = $type;
				$s = 0;
			}
			if ($f == 'tinyint' and $s == 1) { $f = "boolean"; }
			$this->fields[$name] = array($f, $s);
		}

		$this->names = array_keys($this->fields);


		//Get names of columns in table, put them in array
		$sql = "SHOW KEYS FROM $table WHERE key_name='PRIMARY';";
		$result = $this->db->query($sql);
		if (!$result) {
			echo 'Could not run query: ' . $this->db->error;
			exit;
		}
		while ($row = $result->fetch_assoc()) {
			$this->keys[] = $row["Column_name"];
		}

		return 1;

	}

        function fieldNames() {

		return $this->names;
	}

	function fieldType($name) {

		if (in_array($name, $this->names)) {
			return $this->fields[$name];
		} else {
			return array("None", 0);
		}
	}
}
?>
