<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}
global $ccgg_equip;

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$date_out = isset( $_POST['date_out'] ) ? $_POST['date_out'] : '';
$date_in = isset( $_POST['date_in'] ) ? $_POST['date_in'] : '';
$unitinfo = isset( $_POST['unitinfo'] ) ? $_POST['unitinfo'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_shipinfo.js'></SCRIPT>";

switch ( $task )
{
   case "update":
      $fields = explode("|", $unitinfo);

      for ( $i=0; $i<count($fields); $i++ )
      {
         list($nameinfo,$value) = explode("~", $fields[$i]);
         list($table, $column) = explode(":", $nameinfo);

         $sql = "UPDATE ${table} SET ${column} = '".mysql_real_escape_string($value)."'";

         if ( $table === "${ccgg_equip}.gen_inv" ) { $sql = "${sql} WHERE id = '${id}'"; }
         else { $sql = "${sql} WHERE gen_inv_id = '${id}'"; }

         $tmpsql = "SELECT num from gmd.site where code = '$code'";
         $res = ccgg_query($tmpsql);
         $site_num = isset($res[0]) ? $res[0] : '';
         
         $sql = "${sql} AND site_num = '${site_num}'";
         $sql = "${sql} AND date_out = '${date_out}'"; 
         $sql = "${sql} AND date_in = '${date_in}'"; 

         $res = ccgg_insert($sql);
         if (!empty($res)) { JavaScriptAlert($res); }
      }

      echo "<FORM name='mainform' method=POST action='gen_shipping.php?invtype=${gen_type_abbr}&strat_abbr=pfp&strat_name=PFP'>";

      echo "<INPUT type='HIDDEN' NAME='task' VALUE=''>";
      echo "<INPUT type='HIDDEN' NAME='id' VALUE='$id'>";
      echo "<INPUT type='HIDDEN' NAME='code' VALUE='$code'>";

      JavaScriptCommand("document.mainform.submit()");
      break;
}

MainWorkArea();
exit;
#  
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $ccgg_equip;
   global $gen_type_num;
   global $gen_type_abbr;
   global $id;
   global $code;
   global $date_out;
   global $date_in;

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center' border='0'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr}: ${id}</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT type='HIDDEN' NAME='task' VALUE=''>";
   echo "<INPUT type='HIDDEN' NAME='id' VALUE='$id'>";
   echo "<INPUT type='HIDDEN' NAME='code' VALUE='$code'>";
   echo "<INPUT type='HIDDEN' NAME='date_out' VALUE='$date_out'>";
   echo "<INPUT type='HIDDEN' NAME='date_in' VALUE='$date_in'>";
   echo "<INPUT type='HIDDEN' NAME='unitinfo' VALUE=''>";

   if ( $date_in === '0000-00-00' ) { $table = "${ccgg_equip}.gen_inv"; }
   else { $table = "${ccgg_equip}.gen_shipping"; }

   echo "<TABLE align='center' width='90%' border='0' cellpadding='5' cellspacing='0'>";

   PostTable2Edit($table);

   echo "<TR>";
   echo "<TD colspan='2' align='center'>";

   echo "<TABLE cellpadding='10' cellspacing='10' border='0' width='50%'>";
   echo "<TR>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Update' onClick='UpdateCB()'>";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "</TD>";
   echo "</TR>";

   echo "</TABLE>";

   echo "</BODY>";
   echo "</HTML>";
}

#
# Function PostTable2Edit ########################################################
#
function PostTable2Edit($table)
{
   global $gen_type_num;
   global $id;
   global $code;
   global $date_out;
   global $date_in;

   echo "<HR>";
   #
   # returns data about the datatype
   #
   $res = ccgg_fields($table,$name,$type,$length);
   $info = DB_GetTableContents($table);

   if ( isset($info[0]) ) { $field = split("\|", $info[0]); }

   #
   # Loop through all of the fields and output the name and data
   #
   for ($i=0; $i<count($name); $i++)
   {
      $disabled = '';
      $color = '';

      $value = ( isset($field[$i]) ) ? $field[$i] : '';

      echo "<TR>";

      $oname = $name[$i];
      $writable = 1;

      switch($name[$i])
      {
         case 'gen_inv_id':
            $oname = 'id';
         case 'id':
            $writable = 0;
            break;
         case 'site_num':
            $oname = 'site_code';
            $sql = "SELECT code from gmd.site where num = '$value'";
            $site_code = ccgg_query($sql);
            $value = isset($site_code[0]) ? $site_code[0] : '';
            $writable = 0;
            break;
         case 'project_num':
            $oname = 'project';
            $writable = 0;
            $tmp = DB_GetProjectInfo($value);
            if ( !empty($tmp) ) { list( $junk, $value ) = split("\|", $tmp); }
            else { $value = ''; }
            break;
         case 'date_out':
         case 'date_in':
            $writable = 0;
            break;
         case 'gen_type_num':
         case 'gen_status_num':
         case 'event_num':
         case 'comments':
            continue 2;
            break;
         case 'notes':
            switch ( $gen_type_num )
            {
               case 1:
                  $oname = 'project_notes';
                  break;
               case 2:
                  $oname = 'checkin_notes';
                  break;
               default:
                  break;
            }
            break;
      }

      echo "<TD ALIGN='right' class='LargeBlueN'>$oname</TD>";
      #
      # Based on the type of field, switch for different outputs
      #
      switch ($type[$i])
      {
         case "blob":
         case "text":
            echo "<TD ALIGN='left'>";
            if ( $writable )
            {
               echo "<TEXTAREA class='MediumBlackN' name='data~${table}:$name[$i]' rows=5 cols=40 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            }
            else
            {
               echo "<TEXTAREA class='MediumBlackN' name='${table}:$name[$i]' rows=5 cols=40 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' DISABLED>";
            }
            echo $value;
            echo "</TEXTAREA></TD>";
            break;
         default:
            echo "<TD ALIGN='left'>";
            if ( $writable )
            {
               echo "<INPUT type=text class='MediumBlackN' name='data~${table}:$name[$i]' value='${value}' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' $disabled $color>";
            }
            else
            {
               echo "<FONT class='MediumBlackN'>$value</FONT></TD>";
            } 
            break;
      }
      echo "</TR>";
   }
}
#           
# Function DB_GetTableContents ########################################################
#              
function DB_GetTableContents($table)
{
   global $ccgg_equip;
   global $gen_type_num;
   global $id;
   global $code;
   global $date_out;
   global $date_in;

   $sql = "SELECT num from gmd.site where code = '$code'";
   $res = ccgg_query($sql);
   $site_num = isset($res[0]) ? $res[0] : '';
   #        
   # Get contents of passed table
   #        
   ccgg_fields($table,$name,$type,$length);
            
   $select = "SELECT * ";
   $from = " FROM ${table}";

   if ( $table === "${ccgg_equip}.gen_inv" )
   {
      $where = " WHERE id='${id}'";
   }
   else
   {
      $where = " WHERE gen_inv_id='${id}'";
   }

   $and = " AND gen_type_num='${gen_type_num}'";
   $and = "${and} AND site_num = '${site_num}'";
   $and = "${and} AND date_out = '${date_out}'";
   $and = "${and} AND date_in = '${date_in}'";
   $sql = $select.$from.$where.$and;

   return ccgg_query($sql);
}
