<?PHP
#
# ccggdb_utils.php
#  This is separate from ccggdb_inc.php because many different projects have their own
#  copy of ccggdb_inc.php with similar function names.
#

#
# Function DB_DataSummaryInfo #########################################################
#
function DB_DataSummaryInfo($args=array())
{
   # $args['constraints']
   # $args['orderby']
   # $args['delimiter']

   $delimiter = ( isset($args['delimiter']) && $args['delimiter'] != '' ) ? $args['delimiter'] : '~+~';

   $selectcolumns = array ();

   # data_summary
   array_push($selectcolumns, 't1.first~datasum_first');
   array_push($selectcolumns, 't1.last~datasum_last');
   array_push($selectcolumns, 't1.count~datasum_count');

   # gmd.site
   array_push($selectcolumns, 't2.num~site_num');
   array_push($selectcolumns, 't2.code~site_code');
   array_push($selectcolumns, 't2.name~site_name');
   array_push($selectcolumns, 't2.country~site_country');
   array_push($selectcolumns, 't2.lat~site_lat');
   array_push($selectcolumns, 't2.lon~site_lon');
   array_push($selectcolumns, 't2.elev~site_elev');
   array_push($selectcolumns, 't2.lst2utc~site_lst2utc');
   array_push($selectcolumns, 't2.flag~site_flag');
   array_push($selectcolumns, 't2.description~site_description');
   array_push($selectcolumns, 't2.map_coords~site_map_coords');
   array_push($selectcolumns, 't2.image~site_image');
   array_push($selectcolumns, 't2.comments~site_comments');

   # gmd.parameter
   array_push($selectcolumns, 't3.num~parameter_num');
   array_push($selectcolumns, 't3.formula~parameter_formula');
   array_push($selectcolumns, 't3.name~parameter_name');
   array_push($selectcolumns, 't3.unit~parameter_unit');
   array_push($selectcolumns, 't3.unit_name~parameter_unit_name');
   array_push($selectcolumns, 't3.formula_html~parameter_formula_html');
   array_push($selectcolumns, 't3.unit_html~parameter_unit_html');
   array_push($selectcolumns, 't3.formula_idl~parameter_formula_idl');
   array_push($selectcolumns, 't3.unit_idl~parameter_unit_idl');
   array_push($selectcolumns, 't3.formula_matplotlib~parameter_formula_matplotlib');
   array_push($selectcolumns, 't3.unit_matplotlib~parameter_unit_matplotlib');
   array_push($selectcolumns, 't3.description~parameter_description');
   
   # gmd.project
   array_push($selectcolumns, 't4.num~project_num');
   array_push($selectcolumns, 't4.name~project_name');
   array_push($selectcolumns, 't4.abbr~project_abbr');
   array_push($selectcolumns, 't4.program_num~project_program_num');
   array_push($selectcolumns, 't4.data_available~project_data_available');
   array_push($selectcolumns, 't4.description~project_description');
   array_push($selectcolumns, 't4.url~project_url');
   array_push($selectcolumns, 't4.comments~project_comments');
   
   # strategy
   array_push($selectcolumns, 't5.num~strategy_num');
   array_push($selectcolumns, 't5.name~strategy_name');
   array_push($selectcolumns, 't5.abbr~strategy_abbr');

   # status
   array_push($selectcolumns, 't6.num~status_num');
   array_push($selectcolumns, 't6.name~status_name');
   array_push($selectcolumns, 't6.comments~status_comments');

   $select = '';
   $fieldaliases = array(); 
   foreach ($selectcolumns as $selectcolumn)
   {
      list($name, $alias) = split('~', $selectcolumn, 2);

      $select = ( $select === '' ) ? " SELECT $name AS $alias" : $select.", $name AS $alias";
      array_push($fieldaliases,$alias);
   }

   $from = " FROM ccgg.data_summary as t1, gmd.site as t2, gmd.parameter as t3";
   $from = $from.", gmd.project as t4, ccgg.strategy as t5, ccgg.status as t6";
   $where = " WHERE 1=1";
   $and = " AND t1.site_num = t2.num AND t1.parameter_num = t3.num";
   $and = $and." AND t1.project_num = t4.num AND t1.strategy_num = t5.num";
   $and = $and." AND t1.status_num = t6.num";

   if ( isset($args['constraints']) && ! empty($args['constraints']) )
   {
      $constraintstr = $args['constraints'];
      foreach ($selectcolumns as $selectcolumn)
      {
         list($name, $alias) = split('~', $selectcolumn, 2);

         # Search beginning
         $constraintstr = preg_replace('/^'.$alias.'([^A-Za-z])/', $name.'$1', $constraintstr);
         # Search middle
         $constraintstr = preg_replace('/([^A-Za-z])'.$alias.'([^A-Za-z])/', '$1'.$name.'$2', $constraintstr);
         # Search end
         $constraintstr = preg_replace('/([^A-Za-z])'.$alias.'$/', '$1'.$name, $constraintstr);
      }

      $where = $where.' AND '.$constraintstr;
   }

   #print "$where<BR>";

   $etc = '';
   if ( isset($args['orderby']) && ! empty($args['orderby']) )
   {
      # 12345
      # Multiple orders
      # ASC/DESC?
      if ( $args['orderby'] === "site_code" )
      { $etc = " ORDER BY t2.code"; }
      elseif ( $args['orderby'] === "site_num" )
      { $etc = " ORDER BY t2.num"; }
      elseif ( $args['orderby'] === "parameter_formula" )
      { $etc = " ORDER BY t3.formula"; }
      elseif ( $args['orderby'] === "parameter_num" )
      { $etc = " ORDER BY t3.num"; }
      elseif ( $args['orderby'] === "project_abbr" )
      { $etc = " ORDER BY t4.abbr"; }
      elseif ( $args['orderby'] === "project_num" )
      { $etc = " ORDER BY t4.num"; }
      elseif ( $args['orderby'] === "strategy_abbr" )
      { $etc = " ORDER BY t5.abbr"; }
      elseif ( $args['orderby'] === "strategy_num" )
      { $etc = " ORDER BY t5.num"; }
      elseif ( $args['orderby'] === "status_name" )
      { $etc = " ORDER BY t5.abbr"; }
      elseif ( $args['orderby'] === "status_num" )
      { $etc = " ORDER BY t5.num"; }
   }

   $sql = $select.$from.$where.$and.$etc;
#   print "$sql<BR>";
   $res = ccgg_query($sql,$delimiter);

#   print_r($res);

   return(array($fieldaliases, $res));

}
#
# Function DB_EventInfo ############################################################
#
function DB_EventInfo($args=array())
{
   # $args['constraints']
   # $args['orderby']
   # $args['delimiter']

   $delimiter = ( isset($args['delimiter']) && $args['delimiter'] != '' ) ? $args['delimiter'] : '~+~';

   $selectcolumns = array ();

   # flask_event
   array_push($selectcolumns, 't1.date~event_date');
   array_push($selectcolumns, 't1.time~event_time');
   array_push($selectcolumns, 't1.dd~event_dd');
   array_push($selectcolumns, 't1.id~event_id');
   array_push($selectcolumns, 't1.me~event_me');
   array_push($selectcolumns, 't1.lat~event_lat');
   array_push($selectcolumns, 't1.lon~event_lon');
   array_push($selectcolumns, 't1.alt~event_alt');
   array_push($selectcolumns, 't1.comment~event_comment');

   # gmd.site
   array_push($selectcolumns, 't2.num~site_num');
   array_push($selectcolumns, 't2.code~site_code');
   array_push($selectcolumns, 't2.name~site_name');
   array_push($selectcolumns, 't2.country~site_country');
   array_push($selectcolumns, 't2.lat~site_lat');
   array_push($selectcolumns, 't2.lon~site_lon');
   array_push($selectcolumns, 't2.elev~site_elev');
   array_push($selectcolumns, 't2.lst2utc~site_lst2utc');
   array_push($selectcolumns, 't2.flag~site_flag');
   array_push($selectcolumns, 't2.description~site_description');
   array_push($selectcolumns, 't2.map_coords~site_map_coords');
   array_push($selectcolumns, 't2.image~site_image');
   array_push($selectcolumns, 't2.comments~site_comments');

   # gmd.project
   array_push($selectcolumns, 't3.num~project_num');
   array_push($selectcolumns, 't3.name~project_name');
   array_push($selectcolumns, 't3.abbr~project_abbr');
   array_push($selectcolumns, 't3.program_num~project_program_num');
   array_push($selectcolumns, 't3.data_available~project_data_available');
   array_push($selectcolumns, 't3.description~project_description');
   array_push($selectcolumns, 't3.url~project_url');
   array_push($selectcolumns, 't3.comments~project_comments');
   
   # strategy
   array_push($selectcolumns, 't4.num~strategy_num');
   array_push($selectcolumns, 't4.name~strategy_name');
   array_push($selectcolumns, 't4.abbr~strategy_abbr');

   $select = '';
   $fieldaliases = array(); 
   foreach ($selectcolumns as $selectcolumn)
   {
      list($name, $alias) = split('~', $selectcolumn, 2);

      $select = ( $select === '' ) ? " SELECT $name AS $alias" : $select.", $name AS $alias";
      array_push($fieldaliases,$alias);
   }

   $from = " FROM ccgg.flask_event as t1, gmd.site as t2, gmd.project as t3";
   $from = $from.", ccgg.strategy as t4";
   $where = " WHERE 1=1";
   $and = " AND t1.site_num = t2.num AND t1.project_num = t3.num";
   $and = $and." AND t1.strategy_num = t4.num";

   if ( isset($args['constraints']) && ! empty($args['constraints']) )
   {
      $constraintstr = $args['constraints'];
      foreach ($selectcolumns as $selectcolumn)
      {
         list($name, $alias) = split('~', $selectcolumn, 2);

         # Search beginning
         $constraintstr = preg_replace('/^'.$alias.'([^A-Za-z])/', $name.'$1', $constraintstr);
         # Search middle
         $constraintstr = preg_replace('/([^A-Za-z])'.$alias.'([^A-Za-z])/', '$1'.$name.'$2', $constraintstr);
         # Search end
         $constraintstr = preg_replace('/([^A-Za-z])'.$alias.'$/', '$1'.$name, $constraintstr);
      }

      $where = $where.' AND '.$constraintstr;
   }

   $etc = '';
   if ( isset($args['orderby']) && ! empty($args['orderby']) )
   {
      # 12345
      # Multiple orders
      # ASC/DESC?
      if ( $args['orderby'] === "site_code" )
      { $etc = " ORDER BY t2.code"; }
      elseif ( $args['orderby'] === "site_num" )
      { $etc = " ORDER BY t2.num"; }
      elseif ( $args['orderby'] === "project_abbr" )
      { $etc = " ORDER BY t3.abbr"; }
      elseif ( $args['orderby'] === "project_num" )
      { $etc = " ORDER BY t3.num"; }
      elseif ( $args['orderby'] === "strategy_abbr" )
      { $etc = " ORDER BY t4.abbr"; }
      elseif ( $args['orderby'] === "strategy_num" )
      { $etc = " ORDER BY t4.num"; }
      elseif ( $args['orderby'] === "event_date" )
      { $etc = " ORDER BY t1.date"; }
   }

   $sql = $select.$from.$where.$and.$etc;
   #print "$sql<BR>";
   $res = ccgg_query($sql,$delimiter);

#   print_r($res);

   return(array($fieldaliases, $res));

}

?>
