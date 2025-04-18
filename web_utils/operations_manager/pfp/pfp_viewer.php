<?PHP
#jwm - 8.23 - adding in_testing status.  To add others, search below for testing and copy.  edit /pfp_init.js to add to pfp viewer menu.
include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$file = isset( $_GET['file'] ) ? $_GET['file'] : '';
$task = isset( $_GET['task'] ) ? $_GET['task'] : '';

$begin = isset( $_POST['begin'] ) ? $_POST['begin'] : '';
$end = isset( $_POST['end'] ) ? $_POST['end'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';

$searchstr = isset( $_POST['searchstr'] ) ? $_POST['searchstr'] : '';

$strat_abbr = 'pfp';
$strat_name = 'PFP';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_viewer.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$today=date("D M j G:i:s T Y");

#
# If $file is set, then read the file otherwise find out what we need to do
#    based of task
#

if ($file && empty($searchstr))
{
   $textarray=FileToArray($file);
   $textarray = array_reverse($textarray);
   $total = count($textarray);
   $title = substr(strrchr($file, "/"),1);

   if ( $begin == '' ) { $begin = 1; }
   if ( $end == '' ) { $end = 500; }
   if ( $end > $total ) { $end = $total; }

   $textarray = array_splice($textarray, $begin-1, '500');
}
else
{
   if ( empty($searchstr) )
   {
      #
      # Each task goes through basic steps:
      # 1. Grabs $step+1 lines after the current value of $begin
      # 2. Gets the total number of lines for that query
      # 3. Sets a title
      # 4. If the calculated end is after the actual end, set $end = $total
      # 5. Make and fill the output array
      #

      switch($task)
      {
         case 'in_analysis':
            $arr = DB_GetPFPsInAnalysis($begin);
            $total = count(DB_GetPFPsInAnalysis(''));
            $title = "PFPs in Analysis Loop";

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            $formatarr = array();

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i))
               {
                   $formatarr[] = sprintf("%-5s %6s %12s %6s %15s %12s %12s %s\n",
                   '#', 'evn', 'id', 'code', 'project', 'date out', 'date in', 'path');
               }
                 
               list($id,$code,$proj_abbr,$out,$in,$ev,$path) = split("\|",$arr[$i]);
               $path = DB_GetAnalysisPath($path);
               $z  = sprintf("%-5s %6s %12s %6s %15s %12s %12s %s",
               $j,$ev,$id,$code,$proj_abbr,$out,$in,$path);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;
         case 'in_prep':
            $arr = DB_GetPFPsInPrep($begin);
            $total = count(DB_GetPFPsInPrep(''));
            $title = "PFPs in Prep Room";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s\n", '#', 'id'); }

               $id = $arr[$i];
               $z = sprintf("%-5s %8s",$j,$id);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;
         case 'in_repair':
            $arr = DB_GetPFPsInRepair($begin);
            $total = count(DB_GetPFPsInRepair(''));
            $title = "PFPs In Repair";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;
            
         case 'in_testing':
            $arr = DB_GetPFPsInTesting($begin);
            $total = count(DB_GetPFPsInTesting(''));
            $title = "PFPs In Testing";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;    
         case 'reserved':
            $arr = DB_GetPFPsReserved($begin);
            $total = count(DB_GetPFPsReserved(''));
            $title = "PFPs Reserved";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;    
         case 'retired':
            $arr = DB_GetPFPsRetired($begin);
            $total = count(DB_GetPFPsRetired(''));
            $title = "Retired PFPs";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;
         case 'notes':
            $arr = DB_GetPFPsWithNotes($begin);
            $total = count(DB_GetPFPsWithNotes(''));
            $title = "PFPs with Notes";

            $formatarr = array();

            if ( $begin == '' ) { $begin = 1; }
            if ( $end == '' ) { $end = 500; }
            if ( $end > $total ) { $end = $total; }

            for ($i=0,$j=$begin; $j<=$end; $i++,$j++)
            {
               list($id,$notes) = split("\|",$arr[$i]);
               $z = sprintf("%s\n%s",$id,$notes);
               $formatarr[] = "${z}\n";
            }
            $textarray = $formatarr;
            break;
      }
   }
   else
   {
      #
      # Search $file for the specified $searchstr
      #
      $arr = SearchLogFile($file, $searchstr);
                                                                                          
      #
      # Get the file name that we are searching and set the title with it
      #
      $filename = substr(strrchr($file, "/"), 1);
      $title = "Searching $filename...";

      $count = count($arr);

      #
      # Only do this if the file search returned something
      #
      if ( !empty($arr) )
      {
         $file = ArrayToFile($arr);
         $textarray = FileToArray($file);
         $textarray = array_reverse($textarray);
      }

      $total = (isset($textarray) && !empty($textarray)) ? count($textarray) : 0;

      #
      # Set some variables back to their initial value
      #
      $begin = 0;
      $end = 0;

      #
      # Increase $nsubmits by 1 so that the Back button returns the
      #    user to the full view of the textfile instead of only
      #    the searched results
      #
      $nsubmits++;
   }
}
MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $nsubmits;
global $title;
global $total;
global $step;
global $textarray;
global $begin,$end;

global $file;
global $searchstr;

#
# Step size defines how many lines to display on each page
#

$step = 499;

#
# If $begin and $end are initialized, set them to defaults
#
if (empty($begin))  { $begin = 1; }
if (empty($end))  { $end = (($begin + $step) > $total) ? $total : $begin + $step; }

echo "<FORM name='mainform' method=POST>";

echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";
echo "<INPUT type='hidden' name='begin' value='${begin}'>";
echo "<INPUT type='hidden' name='end' value='${end}'>";
echo "<INPUT type='hidden' name='step' value='${step}'>";
echo "<INPUT type='hidden' name='total' value='${total}'>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>${title}<BR>";
echo "<FONT class='LargeBlackB'>showing ${begin}-${end} (${total} total)</FONT></TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=0 cellpadding=0 width='100%' align='center'>";
echo "<TR>";
echo "<TD align='right' width='58%'>";
   if ( empty($file) ) { echo "<TABLE align='center'>"; }
   else { echo "<TABLE align='right'>"; }
   echo "<TR>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='<<' onClick=\"CounterCB('begin');\">";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='<' onClick=\"CounterCB('dec');\">";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='>' onClick=\"CounterCB('inc');\">";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='>>' onClick=\"CounterCB('end');\">";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";
echo "</TD>";
if ( !empty($file) )
{
   echo "<TD align='center'>";
   if ( empty($searchstr) )
   {
      echo "<INPUT TYPE='text' class='MediumBlackB' NAME='searchstr' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' SIZE='15'>&nbsp;";
      echo "<INPUT TYPE='button' class='Btn' value='Search' onClick = 'Search()'>";
   }
   else
   {
      $filename = strrchr($file, "/");
      echo "<A class='label' HREF='../tmp${filename}'>Text Version</A>";
   }
   echo "</TD>";
}
echo "</TR>";
echo "</TABLE>";

#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' width=100% border='0' cellpadding='2' cellspacing='2'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<TEXTAREA class='MediumBlackMonoN' NAME='textarea' ROWS='20' COLS='90' WRAP='OFF'>";
for ( $i=0; $i<count($textarray); $i++ )
{
   if ( isset($textarray[$i]) ) { echo "$textarray[$i]"; }
}
echo "</TEXTAREA>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='10%' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' NAME='Task' value='Back' onClick='history.go(${nsubmits});'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function PostSiteList ########################################################
#
function PostSiteList(&$siteinfo)
{
   echo "<TABLE>";
   echo "<TR>";
   echo "<TD>";
   echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='15'>";

   for ($i=0; $i<count($siteinfo); $i++)
   {
      $tmp=split("\|",$siteinfo[$i]);
      echo "<OPTION VALUE=$tmp[1]>${tmp[1]} - ${tmp[2]}, ${tmp[3]}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";
}
#
# Function DB_GetPFPsInAnalysis ########################################################
#
function DB_GetPFPsInAnalysis($startnum)
{
   #
   # Get list of PFPs that are in analysis loop
   #
   $select = "SELECT pfp_inv.id,gmd.site.code,project.abbr";
   $select = "${select},pfp_inv.date_out,pfp_inv.date_in";
   $select = "${select},pfp_inv.event_num,pfp_inv.path";
   $from = " FROM pfp_inv,gmd.site,project";
   $where = " WHERE pfp_inv.sample_status_num='3'";
   $and = " AND gmd.site.num=pfp_inv.site_num";
   $and = "${and} AND project.num=pfp_inv.project_num";
   #$and = "${and} AND pfp_inv.event_num != '0'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$and.$etc.$limit);
}
#
# Function DB_GetPFPsInPrep ########################################################
#
function DB_GetPFPsInPrep($startnum)
{
   #
   # Get list of PFPs in analysis loop
   #
   $select = "SELECT pfp_inv.id";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.sample_status_num='1'";
   $where = "${where} AND pfp_inv.id LIKE '%-FP'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$etc.$limit);
}
#
# Function DB_GetPFPsInRepair ########################################################
#
function DB_GetPFPsInRepair($startnum)
{
   #
   # Get list of PFPs InRepair
   #
   $select = "SELECT pfp_inv.id,pfp_inv.date_out";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.sample_status_num='4'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$etc.$limit);
}
####jwm 8.23
function DB_GetPFPsInTesting($startnum)
{
   #
   # Get list of PFPs in testing
   #
   $select = "SELECT pfp_inv.id,pfp_inv.date_out";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.sample_status_num='6'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$etc.$limit);
}
function DB_GetPFPsReserved($startnum)
{
   #
   # Get list of PFPs in testing
   #
   $select = "SELECT pfp_inv.id,pfp_inv.date_out";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.sample_status_num='7'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$etc.$limit);
}
#
# Function DB_GetPFPsRetired ########################################################
#
function DB_GetPFPsRetired($startnum)
{
   #
   # Get list of flasks that have been retired
   #
   $select = "SELECT pfp_inv.id,pfp_inv.date_out";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.sample_status_num='5'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $limit = " LIMIT $startnum, 500";
   }

   return ccgg_query($select.$from.$where.$etc.$limit);
}
#
# Function DB_GetPFPsWithNotes ########################################################
#
function DB_GetPFPsWithNotes($startnum)
{
   global $step;

   #
   # Get list of PFPs with Notes
   #
   $select = "SELECT pfp_inv.id,pfp_inv.comments";
   $from = " FROM pfp_inv";
   $where = " WHERE pfp_inv.comments != ''";
   $and = " AND pfp_inv.comments != 'NULL'";
   $etc = " ORDER BY pfp_inv.id";

   $limit = "";
   if ( $startnum != '' )
   {
      $startnum = $startnum - 1;
      $stepnum = $step + 1;
      $limit = " LIMIT $startnum, $stepnum";
   }

   return ccgg_query($select.$from.$where.$and.$etc.$limit);
}
#
# Function DB_GetAnalysisPath ########################################################
#
function DB_GetAnalysisPath($p)
{
   #
   # Convert path numbers (delimited by commas) to system names
   #
   $path_num = split(',',$p);

   $sys_defi = DB_GetSystemDefi();

   for ($i=0,$path=''; $i<count($path_num); $i++)
   {
      for ($ii=0; $ii<count($sys_defi); $ii++)
      { 
         list($num,$abbr) = split('\|',$sys_defi[$ii]);
         if ($path_num[$i] != $num) continue;
         $path = ($path == '') ? "${abbr}" : "${path}-${abbr}";
      }
   }
   return $path;
}
#
# Function SearchLogFile ########################################################
#
function SearchLogFile($logfile, $str)
{
   if ( file_exists($logfile) && filesize($logfile) > 0 )
   { $contents = file($logfile); }
   else
   { JavaScriptAlert("Unable to open ${logfile}.  Get help."); }
                                                                                          
   $probs = array ( "-" , "." , "[" , "]" , "(" , ")" , "'" , "\"" );
   $solns = array ( "\-", "\.", "\[", "\]", "\(", "\)", "\'", "\\\"" );
   $str = str_replace( $probs, $solns, $str );
                                                                                          
   #echo "$str";
                                                                                          
   $filearr = array_values(preg_grep("/$str/", $contents));
                                                                                          
   return $filearr;
}
#
# Function ArrayToFile ########################################################
#
function ArrayToFile(&$arr)
{
   global $omdir;
   #
   # Save passed array to temporary file
   #
   $id=rand();
   $file="${omdir}tmp/xxx_${id}.txt";
   $fp = fopen("${file}","w");
   #
   # Send passed array to HTML
   #
   for ($i=0; $i<count($arr); $i++) { fputs($fp,$arr[$i]); }
   fclose($fp);
   return $file;
}
#
# Function FileToArray ########################################################
#
function FileToArray($file)
{
   #
   # Read contents of passed file name into array
   #
   error_reporting(0);
   $arr = file($file);
   error_reporting(15);
   if (count($arr)==1 && empty($arr[0])) return(JavaScriptAlert("Problem reading ".$file));
   return $arr;
}
#
# Function ArrayToWindow ########################################################
#
function ArrayToWindow(&$arr)
{
   #
   # Send passed array to HTML
   #
   echo "<PRE>";
   for ($i=0,$j=1; $i<count($arr); $i++,$j++) { $z = chop($arr[$i]); echo "${z}\n"; }
   echo "</PRE>";
}
?>
