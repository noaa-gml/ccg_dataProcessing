<?php
# ct_inc.php
#
#
# CarbonTracker common functions
#
function SiteInfoDB($code)
{
   $info = array();

   # Parse Code

   # pal_01d0

   if ( ! preg_match("/^[A-za-z]{3}_[0-9]{2}(c|C|d|D|p|P)[0-9]$/", $code) ) { return; }

   $tmp = split('_', $code);
   $code = strtoupper($tmp[0]);

   $freqarr = array ( "C", "D", "P" );
   $pfnoarr = array ( "0", "1", "2", "3" );

   if ( ! CleanSiteCode($tmp[0]) ) { return; }

   if (count($tmp) > 1)
   {
      $labno = substr($tmp[1], 0, 2);
      if ( ! ValidInt($labno) ) { return; }
      if ( ! ValidinRange($labno,"0","99") ) { return; }

      $freqchar = strtoupper(substr($tmp[1], 2, 1));
      if ( ! (in_clnarray($freqchar, $freqarr) ) ) { return; }

      $pfno = substr($tmp[1], 3, 1);
      if ( ! (in_clnarray($pfno, $pfnoarr) ) ) { return; }
   
      # Temporary code
      
      if ($freqchar === "P") { $freq = 'Discrete Sampling Package'; }
      if ($freqchar === "D") { $freq = 'Discrete'; }
      if ($freqchar === "C") { $freq = 'Quasi-continuous'; }
      if ($pfno === "0") { $platform = 'Surface'; }
      if ($pfno === "1") { $platform = 'Shipboard'; }
      if ($pfno === "2") { $platform = 'Aircraft'; }
      if ($pfno === "3") { $platform = 'Tower'; }
      $info['strategy_char'] = $freqchar;
      $info['strategy'] = $freq;
      $info['platform_num'] = $pfno;
      $info['platform'] = $platform;
      #
      # Query DB for lab information
      #
      $sql = "SELECT name, country, abbr, logo FROM gv_lab WHERE num='".mysql_real_escape_string($labno)."'";
      $labinfo = ccgg_query($sql);
      list($lname, $lcountry, $abbr, $logo) = split("\|", $labinfo[0]);
      $info['lab'] = array();
      $info['lab']['num'] = $labno;
      $info['lab']['name'] = $lname;
      $info['lab']['country'] = $lcountry;
      $info['lab']['abbr'] = $abbr;
      $info['lab']['logo'] = $logo;

      #
      # Query DB for site information
      #
      $sql = "SELECT num, name, country, lat, lon, elev, lst2utc FROM gmd.site WHERE code='".mysql_real_escape_string($code)."'";
      $siteinfo = ccgg_query($sql);
      list($snum, $sname, $scountry, $lat, $lon, $elev, $lst2utc) = split("\|", $siteinfo[0]);
      $info['site'] = array();
      $info['site']['num'] = $snum;
      $info['site']['code'] = $code;
      $info['site']['name'] = $sname;
      $info['site']['country'] = $scountry;
      $info['site']['lat'] = $lat;
      $info['site']['lon'] = $lon;
      $info['site']['elev'] = $elev;
      $info['site']['lst2utc'] = $lst2utc;
   }
   return $info;
}

#
# Function GetSiteCoop #######################################################
#
function GetSiteCoop($aarr)
{
   if ( ! isset($aarr['site_num']) || empty($aarr['site_num'])) return;

   $select = ' SELECT name, abbr, url';
   $from = ' FROM ccgg.site_coop';
   $where = " WHERE site_num = '".$aarr['site_num']."'";

   if ( $aarr['strategy_char'] === 'P' )
   { $and = " AND strategy_num = '2'"; }
   elseif ( $aarr['strategy_char'] === 'D' )
   { $and = " AND strategy_num = '1'"; }
   elseif ( $aarr['strategy_char'] === 'C' )
   { $and = " AND strategy_num = '3'"; }
   else
   { $and = ''; }

   $sql = $select.$from.$where.$and;
   $coopinfo = ccgg_query($sql);

   $info = array ();
   for ( $i=0; $i<count($coopinfo); $i++ )
   {
      list($coopname, $coopabbr, $coopurl) = split("\|", $coopinfo[$i]);
      if ( empty($coopname) ) { continue; }
      $info[$i] = array();
      $info[$i]['name'] = $coopname;
      $info[$i]['abbr'] = $coopabbr;
      $info[$i]['url'] = $coopurl;
   }

   $info = array_values($info);

   return $info;
}

#
# Function GetDirList ########################################################
#
function GetDirList($dir)
{
   $dir_open = opendir($dir);
   if (! $dir_open)
   {
      #JavaScriptAlert("Could not open directory: $dir");
      return false;
   }
   while (($dir_content = readdir($dir_open)) !== false)
      $dirlist[] = $dir_content;

   return $dirlist;
}
?>
