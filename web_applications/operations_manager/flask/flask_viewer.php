<?PHP

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

$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';
$begin = isset( $_POST['begin'] ) ? $_POST['begin'] : '';
$end = isset( $_POST['end'] ) ? $_POST['end'] : '';

$searchstr = isset( $_POST['searchstr'] ) ? $_POST['searchstr'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_viewer.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

if ($file && empty($searchstr) )
{
   $textarray=FileToArray($file);
   rsort($textarray);
   $count = count($textarray);
   $title = substr(strrchr($file, "/"),1);
}
else
{
   if ( empty($searchstr) )
   {
      $today=date("D M j G:i:s T Y");

      switch($task)
      {
         case 'in_analysis':
            $arr = DB_GetFlasksInAnalysis();
            $count = count($arr);
            $title = "Flasks in Analysis Loop";

            $formatarr = array();

            for ($i=0,$j=1; $i<$count; $i++,$j++)
            {
               if (!($i))
               {
                   $formatarr[] = sprintf("%-5s %6s %8s %6s %15s %12s %12s %s\n",'#', 'evn', 'id', 'code', 'project','date out', 'date in', 'path');
               }
               list($id,$code,$proj_abbr,$out,$in,$ev,$path) = split("\|",$arr[$i]);
               $path = DB_GetAnalysisPath($path);
               $z = sprintf("%-5s %6s %8s %6s %15s %12s %12s %s",
               $j,$ev,$id,$code,$proj_abbr,$out,$in,$path);
               $formatarr[] = "${z}\n";
            }
            $file = ArrayToFile($formatarr);
            $textarray = FileToArray($file);
            break;
         case 'in_prep':
            $arr = DB_GetFlasksInPrep();
            $count = count($arr);
            $title = "Flasks in Prep Room";

            $formatarr = array();

            #$formatarr[] = "${count} ${title}\n";
            #$formatarr[] = "${today}\n\n";

            for ($i=0,$j=1; $i<$count; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s\n", '#', 'id'); }

               list($id) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s",$j,$id);
               $formatarr[] = "${z}\n";
            }
            $file = ArrayToFile($formatarr);
            $textarray = FileToArray($file);
            break;
         case 'not_in_use':
            $arr = DB_GetFlasksNotInUse();
            $count = count($arr);
            $title = "Not in Use";

            $formatarr = array();

            for ($i=0,$j=1; $i<$count; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $file = ArrayToFile($formatarr);
            $textarray = FileToArray($file);
            break;
         case 'retired':
            $arr = DB_GetFlasksRetired();
            $count = count($arr);
            $title = "Retired Flasks";

            $formatarr = array();

            for ($i=0,$j=1; $i<$count; $i++,$j++)
            {
               if (!($i)) { $formatarr[] = sprintf("%-5s %8s %12s\n", '#', 'id', 'date out'); }

               list($id,$out) = split("\|",$arr[$i]);
               $z = sprintf("%-5s %8s %12s",$j,$id,$out);
               $formatarr[] = "${z}\n";
            }
            $file = ArrayToFile($formatarr);
            $textarray = FileToArray($file);
            break;
         case 'notes':
            $arr = DB_GetFlasksWithNotes();
            $count = count($arr);
            $title = "Flasks with Notes";

            $formatarr = array();

            #$formatarr[] = "${count} ${title}\n";
            #$formatarr[] = "${today}\n\n";

            for ($i=0,$j=1; $i<$count; $i++,$j++)
            {
               list($id,$notes) = split("\|",$arr[$i]);
               $z = sprintf("%s\n%s",$id,$notes);
               $formatarr[] = "${z}\n";
            }
            $file = ArrayToFile($formatarr);
            $textarray = FileToArray($file);
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
         rsort($arr);
         $file = ArrayToFile($arr);
         $textarray = FileToArray($file);
      }

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
global $count;
global $textarray;
global $begin,$end;

global $file;
global $searchstr;

$step = 499;
$total = count($textarray);

echo "<FORM name='mainform' method=POST>";

if (empty($begin))  { $begin = 1; }
if (empty($end))  { $end = (($begin + $step) > $total) ? $total : $begin + $step; }

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
   if ( !isset( $_GET['file'] ) ) { echo "<TABLE align='center'>"; }
   else {  echo "<TABLE align='right'>"; }
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
if ( isset( $_GET['file'] ) )
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
for ($i=($begin-1); $i<$end; $i++) { echo "$textarray[$i]"; }
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
# Function DB_GetFlasksInAnalysis ########################################################
#
function DB_GetFlasksInAnalysis()
{
   #
   # Get list of flasks that are in analysis loop
   #
   $select = "SELECT flask_inv.id,gmd.site.code,project.abbr";
   $select = "${select},flask_inv.date_out,flask_inv.date_in";
   $select = "${select},flask_inv.event_num,flask_inv.path";
   $from = " FROM flask_inv,gmd.site,project";
   $where = " WHERE flask_inv.sample_status_num='3'";
   $and = " AND gmd.site.num=flask_inv.site_num";
   $and = "${and} AND project.num=flask_inv.project_num";
   $and = "${and} AND flask_inv.event_num != '0'";
   $etc = " ORDER BY gmd.site.code, flask_inv.id"; 

   return ccgg_query($select.$from.$where.$and.$etc);
}
#
# Function DB_GetFlasksInPrep ########################################################
#
function DB_GetFlasksInPrep()
{
   #
   # Get list of flasks that are in analysis loop
   #
   $select = "SELECT flask_inv.id";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.sample_status_num='1'";
   $order = " ORDER BY flask_inv.id";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetFlasksNotInUse ########################################################
#
function DB_GetFlasksNotInUse()
{
   #
   # Get list of flasks that are not in use
   #
   $select = "SELECT flask_inv.id,flask_inv.date_out";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.sample_status_num='4'";

   return ccgg_query($select.$from.$where);
}
#
# Function DB_GetFlasksRetired ########################################################
#
function DB_GetFlasksRetired()
{
   #
   # Get list of flasks that have been retired
   #
   $select = "SELECT flask_inv.id,flask_inv.date_out";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.sample_status_num='5'";

   return ccgg_query($select.$from.$where);
}
#
# Function DB_GetFlasksWithNotes ########################################################
#
function DB_GetFlasksWithNotes()
{
   #
   # Get list of flasks with Notes
   #
   $select = "SELECT flask_inv.id,flask_inv.comments";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.comments != ''";
   $and = " AND flask_inv.comments != 'NULL'";
   $etc = " ORDER BY flask_inv.id";

   return ccgg_query($select.$from.$where.$and.$etc);
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
   $id = rand();
   $file = "${omdir}tmp/xxx_${id}.txt";
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
   $arr=file($file);
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
