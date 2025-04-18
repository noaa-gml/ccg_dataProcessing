<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");
require("../j/funcs.php");

if (!($fpdb = ccgg_connect()))
{
	JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
	exit;
}

#
# This program is used to view history files. The user selects a site, and then
#    selects a history file to view.
# jwm - 2/18 - adding filters for projects.  See below.

#
# Get the hidden variables
#
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$sitecode = isset( $_POST['sitecode'] ) ? $_POST['sitecode'] : '';
$filename = isset( $_POST['filename'] ) ? $_POST['filename'] : '';

$strat_name = "PFP";
$strat_abbr = "pfp";

$proj_abbr = "ccg_aircraft";

BuildBanner($strat_name,$strat_abbr,GetUser());
echo "<SCRIPT language='JavaScript' src='/inc/dbutils/js/jquery-1.11.3.min.js'></SCRIPT>";#For convience use in js below..
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_viewhistory.js'></SCRIPT>";

$siteinfo = DB_GetSiteList("", $strat_abbr);

MainWorkArea();
exit;

#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $task;
   global $sitecode;
   global $siteinfo;
   global $filename;

   #
   # If no site has been chosen by the user (i.e., the first loading of the page),
   #    then select the first site from $silelist
   #
   if ( empty($sitecode) ) { list($sitenum,$sitecode) = split("\|",$siteinfo[0]); }

   #
   # Set the directory based on the site, open the directory and read all the files
   #
   $dir = "/projects/aircraft/".strtolower($sitecode)."/history";

   $dir_open = @ opendir($dir);
   if (! $dir_open)
   {
      JavaScriptAlert("Could not open directory: $dir");
      return false;
   }
   while (($dir_content = readdir($dir_open)) !== false)
      $dirlist[] = $dir_content;

   #
   # Only get the history files, then sort them in reverse chronological order
   #
   $dirlist = array_values(preg_grep("/.*\.his$/i",$dirlist));
   rsort($dirlist);

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task' VALUE='$task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='sitecode' VALUE='${sitecode}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='filename'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>History File</TD>";
   echo "</TR>";
   echo "</TABLE>";

   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   echo "<TABLE align='center' width=80% border='0' cellpadding='4' cellspacing='4'>";

   if ( $task == 'view' )
   {
      #
      # If the user selected a history file, then show them it
      #
      $index = array_search($filename, $dirlist);
      $histfile = $dir."/".$filename;

      #
      # Open and read the file
      #
      $fp = fopen($histfile, "r") or die ("Could not open histfile!");
      $historyinfo = fread($fp, filesize($histfile));
      #print "$histfile\n";

      echo "<TR><TD align='center'>";
      echo "<TABLE border='0' width='25%'>";
         #
         # Create the user buttons on top for previous file, next file, and back
         #    to the main screen.
         #
         echo "<TR>";
         echo "<TD width='5%' align='center'>";

         #
         # Previous file goes to the file chronologically before the current one. 
         #    If the current file is the earliest file, then make the previous
         #    file button not show up
         #
         if ( $index != (count($dirlist) - 1 ) )
         {
            $prevfile = $dirlist[$index+1];
            echo "<INPUT TYPE='button' class='Btn' value='<' onClick=\"ViewFile('$prevfile');\">";
         }
         echo "</TD>";
         echo "<TD width='5%' align='center'>";

         #
         # Next file goes to the file chronologically after the current one.
         #    If the current file is the most recent file, then do not display
         #    the button
         #
         if ( $index != 0 )
         {
            $nextfile = $dirlist[$index-1];
            echo "<INPUT TYPE='button' class='Btn' value='>' onClick=\"ViewFile('$nextfile');\">";
         }
         echo "</TD>";
         echo "<TD width='5%' align='center'>";

         #
         # Go back to the main page
         #
         echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB();'>";
         echo "</TD>";
         echo "</TR>";
      echo "</TABLE>";
      echo "</TD></TR>";
      echo "<TR><TD><HR></TD></TR>";

      #
      # Print the site code and history file selected to the page
      #
      echo "<TR><TD align='center'>";
      echo "<FONT class='MediumBlackB'>SITE:</FONT> ";
      echo "<FONT class='MediumBlueB'>$sitecode</FONT><BR>";
      echo "<FONT class='MediumBlackB'>FILE:</FONT> ";
      echo "<FONT class='MediumBlueB'>$filename</FONT><BR>";
      echo "<TR><TD><PRE>";
      echo "$historyinfo";
      echo "</PRE></TD></TR>";
   }
   else
   {
      #
      ############################
      # Site List
      ############################
      #
      echo "<TR><TD align='center' colspan=5>";
      echo "<FONT class='MediumBlackB'>Site:</FONT> ";
      echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='1' onChange='ListSelectCB(this)'>";
      for ($i=0; $i<count($siteinfo); $i++)
      {
         # $siteinfo
         # num|code
         $tmp=split("\|",$siteinfo[$i]);
         $selected = (!(strcasecmp($tmp[1],$sitecode))) ? 'SELECTED' : '';
         $z = sprintf("%s",$tmp[1]);
         echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
      }
                                                                                          
      echo "</SELECT>";
        #See if there are more than 1 projects at this site and add filter buttons if so.
	$numProjects=doquery("select count(distinct project) from ccgg.flask_event_view where site=? and strategy='pfp'",0,array($sitecode));
	if($numProjects>1){
		$b=getJSButton('showAirBtn',"showAircraft","ccg_aircraft");
		$b.=getJSButton('showSurfBtn',"showSurface","ccg_surface");
		echo "
		<script language='JavaScript'>
			function showAircraft(){
				$('.projMarkClass').show();//May get overriden below.  This is the (a) (s), hidden by default until button clicked.
				$('.project_a').show();
				$('.project_s').toggle();
			}
			function showSurface(){
				$('.projMarkClass').show();
				$('.project_a').toggle();
				$('.project_s').show();
			}	
		</script>
		<br>$b<br>";
	}
      echo "</TD>";
      echo "</TR>";
      echo "<TR><TD colspan=5><HR></TD></TR>";
      #echo "<TR><TD class='MediumBlackB' colspan=5 align='center'>";
      #echo "History File List";
      #echo "</TD></TR>";

      #
      # After every 5 history files, start putting them on a new line.
      #    If the year changes, then print a space and begin listing
      #    the history files at the beginning
      #
	
      $counter = 0;
      for ( $i=0; $i<count($dirlist); $i++ )
      {
	#For sites with multiple projects (air/surface), we need to mark each file so above buttons can selectively hide them.  There's not an easy
	#way to get this information unfortunately, so we'll query the db and inspect the matching event from same date/flask.
	#We could grab all and bring down, but that's 12x as many as needed. so this is kind of a wash.  Note this is not 100% (like if first sample imported was after file date)
	#Only do this on multiproject sites.
	$fileparts=split("\.",$dirlist[$i]);
	$projMark='';$class='';
	if($numProjects>1 && count($fileparts)>2){
		$sql="select case when project='ccg_aircraft' then 'a' when project='ccg_surface' then 's' else 'u' end 
			from ccgg.flask_event_view 
			where site=? and ev_date=date(?) and flask_id like concat(?,'%') and strategy='pfp' limit 1";
		$parameters=array($sitecode,$fileparts[0],$fileparts[2]);
        	$t=doquery($sql,0,$parameters);
		if($t){
			$projMark="<span class='projMarkClass'>($t)</span>";
			$class="project_${t}";
		}
	}
	
	 list($cur_year,$junk) = split("\-", $dirlist[$i]);
         if ( $i == 0 ) { list($prev_year,$junk) = split("\-", $dirlist[$i]); }

         if ( $cur_year != $prev_year )
         { echo "</TR><TR></TR><TR></TR>"; $prev_year = $cur_year; $counter = 0; }

         if ( $counter == 0 ) { echo "<TR>"; }
         echo "<TD>";
         echo "<a class='NoUnderlineSmallBlackURL $class' href='javascript:ViewFile(\"$dirlist[$i]\")'>${projMark}$dirlist[$i]</a>";
         # echo "<INPUT TYPE='button' class='Btn' value='$dirlist[$i]' onClick=\"ViewFile('$dirlist[$i]');\">";
         echo "</TD>";

         if ( $counter == 4 ) { echo "</TR>"; $counter = -1; }
         $counter ++;
      }
   }
   #
   # End the Outermost Table
   #
   echo "</TABLE><script language='JavaScript'>$('.projMarkClass').hide();</script>";#hide project markers until a button is pressed.
}
