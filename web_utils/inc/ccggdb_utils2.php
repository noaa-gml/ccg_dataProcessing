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
   # User may supply constraints no
   #  site_num
   #  site_code
   #  parameter_num
   #  parameter_formula
   #  project_num
   #  project_abbr
   #  strategy_num
   #  strategy_abbr
   #  program_num
   #  program_abbr
   
   #new-jwm 9/15 filter for data summary 'releaseable' data
   #  releaseable = 1 to filter data to combos with valid readme and non-excluded data
   
   # $args['orderby']
   # $args['output'] = 'hash' (default) or 'array'
   #   return hash of arrays or array of hashes

   $selectcolumns = array ();

   # data_summary
   array_push($selectcolumns, 't1.first~datasum_first');
   array_push($selectcolumns, 't1.last~datasum_last');
   array_push($selectcolumns, 't1.count~datasum_count');
   array_push($selectcolumns, 't1.first_releaseable~datasum_first_releaseable');
   array_push($selectcolumns, 't1.last_releaseable~datasum_last_releaseable');
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

   # program
   array_push($selectcolumns, 't7.num~program_num');
   array_push($selectcolumns, 't7.name~program_name');
   array_push($selectcolumns, 't7.abbr~program_abbr');

   $tmparr = array();
   $fieldaliases = array(); 
   foreach ($selectcolumns as $selectcolumn)
   {
      list($name, $alias) = split('~', $selectcolumn, 2);

      array_push($tmparr, " $name AS $alias");
      array_push($fieldaliases,$alias);
   }
   $select = " SELECT ".join(',', $tmparr);

   $from = " FROM data_summary as t1, gmd.site as t2, gmd.parameter as t3";
   $from = $from.", gmd.project as t4, ccgg.strategy as t5, ccgg.status as t6";
   $from = $from.", gmd.program as t7";
   $where = " WHERE 1=1";
   $and = " AND t1.site_num = t2.num AND t1.parameter_num = t3.num";
   $and = $and." AND t1.project_num = t4.num AND t1.strategy_num = t5.num";
   $and = $and." AND t1.status_num = t6.num AND t1.program_num = t7.num";

   #JWM 9/15.  Filter for actual releaseable data.
   if ( isset($args['releaseable']) && $args['releaseable'] == 1){
      $where.=" and t1.first_releaseable>'0000:00:00' and t1.last_releaseable>'0000:00:00' and t1.readme_present=1 ";
   }
   
   if ( isset($args['site_num']) && $args['site_num'] != '' )
   {
      $arr = split(',', $args['site_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t2.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['site_code']) && $args['site_code'] != '' )
   {
      $arr = split(',', $args['site_code']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t2.code = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['parameter_num']) && $args['parameter_num'] != '' )
   {
      $arr = split(',', $args['parameter_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t3.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['parameter_formula']) && $args['parameter_formula'] != '' )
   {
      $arr = split(',', $args['parameter_formula']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t3.formula = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['project_num']) && $args['project_num'] != '' )
   {
      $arr = split(',', $args['project_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t4.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['project_abbr']) && $args['project_abbr'] != '' )
   {
      $arr = split(',', $args['project_abbr']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t4.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['strategy_num']) && $args['strategy_num'] != '' )
   {
      $arr = split(',', $args['strategy_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t5.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['strategy_abbr']) && $args['strategy_abbr'] != '' )
   {
      $arr = split(',', $args['strategy_abbr']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t5.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['program_num']) && $args['program_num'] != '' )
   {
      $arr = split(',', $args['program_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t7.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['program_abbr']) && $args['program_abbr'] != '' )
   {
      $arr = split(',', $args['program_abbr']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t7.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   #print "$where<BR>";

   $etc = '';
   if ( isset($args['orderby']) && ! empty($args['orderby']) )
   {
      $tmparr = array();
      $orderbyarr = array();
      $clnorderbyarr = array();
      # 12345
      # Multiple orders
      # ASC/DESC?

      $tmparr = split(',',$args['orderby']);

      $badline = 0;
      foreach ( $tmparr as $line )
      {
         $line = ltrim(rtrim($line));
         if ( ! preg_match('/^[A-Za-z_\s]+\s+(ASC|asc|DESC|desc)+$/', $line) )
         { $badline++; }

         $matchfound = 0;
         foreach ( $selectcolumns as $selectcolumn )
         {
            list($name, $alias) = split('~', $selectcolumn, 2);

            if ( preg_match("/^$alias\s/", $line) )
            {
               array_push($clnorderbyarr, preg_replace("/^$alias/", $name, $line));
               $matchfound++;
            }
         }

         if ( $matchfound != 1 ) { $badline++; }

         if ( $badline != 0 ) { break; }
      }

      if ( $badline == 0 )
      {
         $etc = ' ORDER BY '.join(',', $clnorderbyarr);
      }
   }

   $sql = $select.$from.$where.$and.$etc;
   #print "$sql<BR>";
   $res = ccgg_query($sql,'~+~');

   # print_r($res);
   
   $retarr = array();
   $tmparr = array();
   if ( isset($args['output']) && $args['output'] == 'hash' )
   {
      foreach ( $res as $line )
      {
         $tmparr = split('\~\+\~', $line);

         for ( $i=0; $i<count($tmparr); $i++ )
         {
            $fieldalias = $fieldaliases[$i];
            $value = $tmparr[$i];
            
            if ( ! isset($retarr[$fieldalias]) || ! is_array($retarr[$fieldalias]) )
            { $retarr[$fieldalias] = array(); }

            array_push($retarr[$fieldalias], $value);
         }
      }
   }
   else
   {
      $tmpaarr = array();
      foreach ( $res as $line )
      {
         $tmparr = split('\~\+\~', $line);

         for ( $i=0; $i<count($tmparr); $i++ )
         {
            $fieldalias = $fieldaliases[$i];
            $value = $tmparr[$i];
         
            $tmpaarr[$fieldalias] = $value;   
         }

         array_push($retarr, $tmpaarr); 
      }
   }

   return($retarr);

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
   array_push($selectcoulmns, 't1.num~event_num');
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

   $tmparr = array();
   $fieldaliases = array(); 
   foreach ($selectcolumns as $selectcolumn)
   {
      list($name, $alias) = split('~', $selectcolumn, 2);

      array_push($tmparr, " $name AS $alias");
      array_push($fieldaliases,$alias);
   }
   $select = " SELECT ".join(',', $tmparr);

   $from = " FROM ccgg.flask_event as t1, gmd.site as t2, gmd.project as t3";
   $from = $from.", ccgg.strategy as t4";
   $where = " WHERE 1=1";
   $and = " AND t1.site_num = t2.num AND t1.project_num = t3.num";
   $and = $and." AND t1.strategy_num = t4.num";

   if ( isset($args['site_num']) && $args['site_num'] != '' )
   {
      $arr = split(',', $args['site_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t2.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['site_code']) && $args['site_code'] != '' )
   {
      $arr = split(',', $args['site_code']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t2.code = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['project_num']) && $args['project_num'] != '' )
   {
      $arr = split(',', $args['project_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t3.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['project_abbr']) && $args['project_abbr'] != '' )
   {
      $arr = split(',', $args['project_abbr']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t3.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['strategy_num']) && $args['strategy_num'] != '' )
   {
      $arr = split(',', $args['strategy_num']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t4.num = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   if ( isset($args['strategy_abbr']) && $args['strategy_abbr'] != '' )
   {
      $arr = split(',', $args['strategy_abbr']);

      $strings = array();
      foreach ( $arr as $line )
      { array_push($strings, "t4.abbr = '".$line."'"); }

      $where = $where." AND (".join(' OR ', $strings)." )";
   }

   print "$where<BR>";

   $etc = '';
   if ( isset($args['orderby']) && ! empty($args['orderby']) )
   {
      $tmparr = array();
      $orderbyarr = array();
      $clnorderbyarr = array();
      # 12345
      # Multiple orders
      # ASC/DESC?

      $tmparr = split(',',$args['orderby']);

      $badline = 0;
      foreach ( $tmparr as $line )
      {
         $line = ltrim(rtrim($line));
         if ( ! preg_match('/^[A-Za-z_\s]+\s+(ASC|asc|DESC|desc)+$/', $line) )
         { $badline++; }

         $matchfound = 0;
         foreach ( $selectcolumns as $selectcolumn )
         {
            list($name, $alias) = split('~', $selectcolumn, 2);

            if ( preg_match("/^$alias\s/", $line) )
            {
               array_push($clnorderbyarr, preg_replace("/^$alias/", $name, $line));
               $matchfound++;
            }
         }

         if ( $matchfound != 1 ) { $badline++; }

         if ( $badline != 0 ) { break; }
      }

      if ( $badline == 0 )
      {
         $etc = ' ORDER BY '.join(',', $clnorderbyarr);
      }
   }

#   print_r($res);
   $retarr = array();
   $tmparr = array();
   if ( isset($args['output']) && $args['output'] == 'hash' )
   {
      foreach ( $res as $line )
      {
         $tmparr = split('\~\+\~', $line);

         for ( $i=0; $i<count($tmparr); $i++ )
         {
            $fieldalias = $fieldaliases[$i];
            $value = $tmparr[$i];
            
            if ( ! isset($retarr[$fieldalias]) || ! is_array($retarr[$fieldalias]) )
            { $retarr[$fieldalias] = array(); }

            array_push($retarr[$fieldalias], $value);
         }
      }
   }
   else
   {
      $tmpaarr = array();
      foreach ( $res as $line )
      {
         $tmparr = split('\~\+\~', $line);

         for ( $i=0; $i<count($tmparr); $i++ )
         {
            $fieldalias = $fieldaliases[$i];
            $value = $tmparr[$i];
         
            $tmpaarr[$fieldalias] = $value;   
         }

         array_push($retarr, $tmpaarr); 
      }
   }

   return($retarr);


}

?>
