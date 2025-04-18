<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'om';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'om';

$input = isset( $_POST['input'] ) ? $_POST['input'] : '|||||||||||||||||';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : 0;

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_events.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$projinfo = DB_GetAllProjectInfo();
$paraminfo = DB_GetAllParamInfo();

switch ($task)
{
   case "query":
 
   #$perlcode = "${omdir}perl/ccgg_getflask_new.pl";
   $perlcode = "/projects/src/db/ccg_flask.pl";
   $tmpfile = sprintf("${omdir}tmp/xxx-%d.txt",rand());

   list($ev_num,$ev_code,$ev_projabbr,$ev_date1,$ev_date2,
   $ev_time1,$ev_time2,$ev_id,$ev_loopdb,$ev_meth,$ev_comment,
   $an_param,$an_flag,$an_id,$an_date1,$an_date2,
   $an_time1,$an_time2) = split("\|",$input);

   if ( $ev_loopdb )
   {
      $eventscode = "/projects/src/db/ccg_inanalysis.pl -id=${ev_id}";

      #
      # Run the perl call
      #
      #echo "$eventscode\n";
      exec($eventscode,$arr,$ret);

      #
      # If there is nothing returned, set the eventmax and eventmin
      # numbers to impossible event ids. Otherwise loop through the
      # event numbers and get the max and min
      #
      if ( count($arr) == 0 )
      {
         $eventmax = -99;
         $eventmin = -99;
      }
      else
      {
         for ( $i=0; $i<count($arr); $i++ )
         {
            $tmp = split(" ",$arr[$i]);
            $eventsnum[$i] = $tmp[0];
         }
         $eventmax = max($eventsnum);
         $eventmin = min($eventsnum);
      }
      #JavaScriptAlert($eventmin." ".$eventmax);
   }
   #
   # Build call to ccgg_getflask
   #
   $args = "-stdout -outfile=${tmpfile}";

   $oldformat = 0;

   #
   # Print the old format whenever parameter is set to none
   #
   if ( $an_param == 'none' && $ev_num == '' && $ev_code == '' && $ev_date1 == '' && $ev_date2 == '' && $ev_time1 == '' && $ev_time2 == '' && $ev_id == '' && $ev_meth == '' && $ev_comment == '' )
   {
      $oldformat = 1;
   }

   #
   # Specifically for Pat, if everything is clear but the measurement date
   # then set then specify parameter as co2
   #
   # 10/03/2005 - Pat mentioned that there are flasks that were not measured
   # for co2 (i.e, they were only measure for n2o).
   #
   if ( $ev_num == '' && $ev_code == '' && $ev_date1 == '' && $ev_date2 == '' && $ev_time1 == '' && $ev_id == '' && $ev_loopdb == '0' && $ev_meth == '' && $ev_comment == '' && $an_param == 'none' && $an_flag == 'all' && $an_id == '' && $an_date1 != '' && $an_time1 == '' )
   {
      if ( $strat_abbr == "pfp" ) { $an_param = "co2,temp,press,rh"; }
      elseif ( $strat_abbr == "flask" ) { $an_param = "co2,ws,wd"; }
      else { $an_param = "co2"; }

      $args = $args.' -merge=1';
   }
   $z = ($an_param == 'none' || $an_param == '') ? "" : "-parameter=${an_param}";
   $args = $args.' '.$z;
   $z = ($ev_code == '') ? "" : "-site=${ev_code}";
   $args = $args.' '.$z;
   $z = ($ev_projabbr == 'all') ? "" : "-project=${ev_projabbr}";
   $args = $args.' '.$z;
   $z = ($ev_meth == '') ? "" : "-method=${ev_meth}";
   $args = $args.' '.$z;

   $dbin = '';
   $dbin2 = '';

   if ( $an_flag != '' || $an_id != '' || $an_date1 != '' || $an_time1 != '' )
   {
     $dbin = '1'; 
   }

   if ( $dbin != '' )
   {
      switch($an_flag)
      {
         case "ret":
            $an_flag = '..%';
            break;
         case "nb":
            $an_flag = '_._';
            $args = $args.' -not';
            break;
         case "rej":
            $an_flag = '.%';
            $args = $args.' -not';
            break;
         case "norej":
            $an_flag = '.%';
            break;
         default:
            $an_flag = '';
            break;
      }
      $z = ($an_flag == '') ? "" : "flag:${an_flag}";
      if ( $z != '' ) { $dbin2 = ($dbin2 == '') ? "${z}" : "${dbin2}~${z}"; }

      $z = ($an_id == '') ? "" : "inst:${an_id}";
      if ( $z != '' ) { $dbin2 = ($dbin2 == '') ? "${z}" : "${dbin2}~${z}"; }

      $z = ($an_date1 == '') ? "" : "date:${an_date1},${an_date2}";
      if ( $z != '' ) { $dbin2 = ($dbin2 == '') ? "${z}" : "${dbin2}~${z}"; }
      
      $z = ($an_time1 == '') ? "" : "time:${an_time1},${an_time2}";
      if ( $z != '' ) { $dbin2 = ($dbin2 == '') ? "${z}" : "${dbin2}~${z}"; }
   }
   else
   {
      $dbin2 = '';
   }

   $z = ($dbin2 == '') ? '' : "-data='${dbin2}'";
   $args = $args.' '.$z;

   
   #
   # event binning
   #
   $ebin = '';
   $ebin2 = '';

   if ( $ev_num != '' || $ev_date1 != '' || $ev_time1 != '' || $ev_id != '' || $ev_comment != '' )
   {
      $ebin = '1';
   }

   if ( $ebin != '' )
   {
      if ( $ev_loopdb )
      {
         $z = ($eventmin == '') ? "" : "num:${eventmin},${eventmax}";
      }
      else
      {
         $z = ($ev_num == '') ? "" : "num:${ev_num},${ev_num}";
      }
      if ( $z != '' ) { $ebin2 = ($ebin2 == '') ? "${z}" : "${ebin2}~${z}"; }

      $z = ($ev_date1 == '') ? "" : "date:${ev_date1},${ev_date2}";
      if ( $z != '' ) { $ebin2 = ($ebin2 == '') ? "${z}" : "${ebin2}~${z}"; }
      
      $z = ($ev_time1 == '') ? "" : "time:${ev_time1},${ev_time2}";
      if ( $z != '' ) { $ebin2 = ($ebin2 == '') ? "${z}" : "${ebin2}~${z}"; }

      $ev_comment = str_replace("*", "%", $ev_comment);
      $z = ($ev_comment == '') ? "" : "comment:${ev_comment}";
      if ( $z != '' ) { $ebin2 = ($ebin2 == '') ? "${z}" : "${ebin2}~${z}"; }
      
      $z = '';
      if ($ev_id)
      {
         list($pre, $suf) = split ('-', $ev_id);
         if ( strtoupper($suf) == "FP" ) { $z = "id:${pre}-%"; }
         else { $z = "id:${ev_id}"; }
      }

      if ( $z != '' ) { $ebin2 = ($ebin2 == '') ? "${z}" : "${ebin2}~${z}"; }
   }
   else
   {
      $ebin2 = '';
   }

   $z = ($ebin2 == '') ? '' : "-event='${ebin2}'";
   $args = $args.' '.$z;

   if ( $strat_abbr == 'pfp' || $strat_abbr == 'flask' )
   {
      $args = $args.' -strategy='.$strat_abbr;
   }

   # Comments
   $args = $args.' -comment';

   #jwm 6/16.  added elevation per request.  We'll see if anyone complains...
   #That didn't take long.. removed as it caused weird formatting issues (expected order of col changed in some
   #cases, not all) below.  I'm sure it's fixable, but way too confusing for now.
   #$args = $args.' -elevation';
   $z = $perlcode.' '.$args;
   

   #echo "$z\n";
   #JavaScriptAlert($z);
   exec($z,$arr,$ret);
   $ret = 0;

   if ($ret)
   {
      #
      # Query Failed
      #
      $str = implode("\n", $arr);
      JavaScriptAlert($str);
   }
  
   $prev_code = "???";
   #
   # This perl script reformats the output from ccg_flask to the format
   # that it was before this page was made
   #
   if ( $oldformat == 1 )
   {
      if (!($fp = fopen($tmpfile, "r")))
      { JavaScriptAlert("Unable to open ${tmpfile}.  Get help."); }

      $contents = fread($fp, filesize($tmpfile));
      $contents = split("\n",$contents);
      fclose($fp);

      if (!($fp = fopen($tmpfile, "w")))
      { JavaScriptAlert("Unable to open ${tmpfile}.  Get help."); }

      for ($i=0; $i<count($contents)-1; $i++)
      {
         if ( $strat_abbr == 'pfp' )
         {
            list($code,$yr,$mon,$day,$hr,$min,$sec,$id,$meth,$f1,$f2,$f3,$eventnum,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$d10,$d11,$d12,$d13,$d14,$d15,$tmp) = preg_split("/\s+/", $contents[$i], 29);

            if ( preg_match("/\s/", $tmp) )
            { list($d16,$notes) = preg_split("/\s+/",$tmp,2); }
            else
            { $notes = ''; }

            $line = sprintf("%7d  %-3s    %7s %04d-%02d-%02d %02d:%02d:%02d %-1s %5.2f %7.2f %5d %7.2f %7.2f %7.2f %-s",$eventnum,$code,$id,$yr,$mon,$day,$hr,$min,$sec,$meth,$f1,$f2,round($f3/0.3048),$d7,$d11,$d15,$notes);
         }
         elseif ( $strat_abbr == 'flask' )
         {
            #list($code,$yr,$mon,$day,$hr,$min,$id,$meth,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$f8,$f9,$d1,$d2,$d3,$tmp) = preg_split("/\s+/", $contents[$i], 21);
            list($code,$yr,$mon,$day,$hr,$min,$sec,$id,$meth,$f1,$f2,$f3,$eventnum,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8,$d9,$d10,$d11,$tmp) = preg_split("/\s+/", $contents[$i], 25);

            if ( preg_match("/\s/", $tmp) )
            { list($d12,$notes) = preg_split("/\s+/",$tmp,2); }
            else
            { $notes = ''; }

            $line = sprintf("%7d  %-3s    %9s %04d-%02d-%02d %02d:%02d:%02d %-1s %6.2f %7.2f %7.1f %7.2f %4d %-s",$eventnum,$code,$id,$yr,$mon,$day,$hr,$min,$sec,$meth,$f1,$f2,$f3,$d7,$d11,$notes);
         }
         else
         {
            list($code,$yr,$mon,$day,$hr,$min,$sec,$id,$meth,$f1,$f2,$f3,$eventnum,$d1,$d2,$d3,$tmp) = split(" +", $contents[$i], 17);

            if ( preg_match("/\s/", $tmp) )
            { list($d4,$notes) = preg_split("/\s+/",$tmp,2); }
            else
            { $eventnum = $tmp; $notes = ''; }

            $line = sprintf("%7d %-3s %7s %04d-%02d-%02d %02d:%02d:%02d %-1s %-s",$eventnum,$code,$id,$yr,$mon,$day,$hr,$min,$sec,$meth,$notes);
         }

         if ( $prev_code != $code )
         {
            #
            # Put a carriage return between each different site
            #
            if ( $i > 1 ) { fwrite($fp,"\n"); }
            $prev_code = $code;
         }
         fwrite($fp, "$line\n");
      }
      
      fclose($fp);
   }
   if ($ret)
   {
      #
      # Query Failed
      #
      $str = implode("\n", $arr);
      JavaScriptAlert('Error:'.$str);
   }
   else
   {
      #
      # Query Succeeded
      #
      if ( file_exists($tmpfile) ) { $output = file($tmpfile); }
      else { $output = array(); }
   }
   #unlink($tmpfile);
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $input,$output;
global $paraminfo;
global $projinfo;
global $eventinfo;
global $nsubmits;
global $omdir;
global $tmpfile;

list($ev_num,$ev_code,$ev_projabbr,$ev_date1,$ev_date2,
$ev_time1,$ev_time2,$ev_id,$ev_loopdb,$ev_meth,$ev_comment,
$an_param,$an_flag,$an_id,$an_date1,$an_date2,$an_time1,
$an_time2) = split("\|",$input);

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='input'>";
echo "<INPUT type='hidden' name='task'>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center' valign='top'>";
echo "<TD align='center' class='XLargeBlueB'>Event Information</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' width=80% border='0' cellpadding='4' cellspacing='4'>";
#
##############################
# Row 1: Selection Windows
##############################
#
echo "<TR valign='top'>";
echo "<TD align='center' class='LargeBlackN'>";
echo "Sample Details";
echo "<TABLE bgcolor='#DDDDDD' border='0' cellpadding='2' cellspacing='2'>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Event Number</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_num' VALUE='${ev_num}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Code</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_code' VALUE='${ev_code}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=3></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'>Project</TD>";
echo "<TD>";
echo "<SELECT class='MediumBlackB' NAME='selectproject' SIZE='1'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";

$selected = ( $ev_projabbr == 'all' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='all' $selected>All Selected</OPTION>";
for ($i=0; $i<count($projinfo); $i++)
{
   $tmp = split("\|",$projinfo[$i]);
   $selected = ($tmp[2] == $ev_projabbr ) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=${tmp[2]}>${tmp[2]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Date (2005-02-04)</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_date1' VALUE='${ev_date1}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10>";
echo " <INPUT TYPE='text' NAME='ev_date2' VALUE='${ev_date2}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Time (11:11[:00])</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_time1' VALUE='${ev_time1}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=8>";
echo " <INPUT TYPE='text' NAME='ev_time2' VALUE='${ev_time2}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=8></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Id</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_id' VALUE='${ev_id}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10>";
$selected = ( $ev_loopdb == '1' ) ? 'CHECKED' : '';
echo "<INPUT TYPE='checkbox' NAME='ev_loopdb' VALUE='${ev_loopdb}' $selected>";
echo "<FONT class='MediumBlackB'>In Analysis</FONT></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Method</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_meth' VALUE='${ev_meth}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=1></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Comment</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_comment' VALUE='${ev_comment}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10></TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TD align='center' class='LargeBlackN'>";
echo "Measurement Details";
echo "<TABLE bgcolor='#DDDDDD' border='0' cellpadding='2' cellspacing='2'>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'>Parameter</TD>";
echo "<TD>";
echo "<SELECT class='MediumBlackB' NAME='selectparam' SIZE='4' MULTIPLE
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";

$param = split("," , $an_param);
$selected = ( $an_param == '' || $an_param == 'none' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='none' $selected>None Selected</OPTION>";
$selected = ( $an_param == 'all' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='all' $selected>All Selected</OPTION>";
for ($i=0; $i<count($paraminfo); $i++)
{
   $tmp = split("\|",$paraminfo[$i]);
   for ($ii = 0; $ii < count($param); $ii++) { if (!strcasecmp($tmp[1], $param[$ii])) break; }
   $selected = ($ii < count($param)) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=${tmp[1]}>${tmp[1]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'>Flag</TD>";
echo "<TD>";
echo "<SELECT class='MediumBlackB' NAME='selectflag' SIZE='1'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
$selected = ( $an_flag == 'all' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='all' $selected>Accept All</OPTION>";
$selected = ( $an_flag == 'ret' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='ret' $selected>Retained Only</OPTION>";
$selected = ( $an_flag == 'nb' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='nb' $selected>Non-Background Only</OPTION>";
$selected = ( $an_flag == 'rej' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='rej' $selected>Rejected Only</OPTION>";
$selected = ( $an_flag == 'norej' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='norej' $selected>Exclude Rejected</OPTION>";
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TD align='right' class='MediumBlackB'> Instrument Id</TD>";
echo "<TD><INPUT TYPE='text' NAME='an_id' VALUE='${an_id}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=3></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Date (2005-02-04)</TD>";
echo "<TD><INPUT TYPE='text' NAME='an_date1' VALUE='${an_date1}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10>";
echo " <INPUT TYPE='text' NAME='an_date2' VALUE='${an_date2}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=10></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackB'> Time (11:11[:00])</TD>";
echo "<TD><INPUT TYPE='text' NAME='an_time1' VALUE='${an_time1}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=8>";
echo " <INPUT TYPE='text' NAME='an_time2' VALUE='${an_time2}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackB' SIZE=10 MAXLENGTH=8></TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='10%' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Submit' onClick='SubmitCB()'>";
echo "</TD>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Reset' onClick='ResetCB()'>";
echo "</TD>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='history.go(${nsubmits});'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE bgcolor='#DDDDDD' align='center' id='output' width=90% border='0' cellpadding='4' cellspacing='4'>";

if ($output)
{
   $n = count($output);

   #
   # Subtract 1 for each white line, because they don't count
   #
   for ( $j=0; $j<count($output); $j++ )
   {
      if ( urlencode($output[$j]) == "%0A" )
      {
         $n = $n - 1;
      }
   }

   echo "<TR>";
   echo "<TD align='left' class='LargeBlackB'>${n} line(s) returned</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD align='left'>";

   echo "<PRE>";
   $j = 1;
   for ($i=0; $i<count($output); $i++)
   {
      $check = str_replace(array(" ", "\n"), "", $output[$i]);
      #echo "aaa${output[$i]}aaa";
      #echo "aaa${check}aaa";
      if ( $check != "" )
      {
         echo sprintf("%-5d %s",$j, $output[$i]);
         $j++;
      }
      else
      {
         echo "\n";
      }
   }
   echo "</PRE>";
   $tmpstr = str_replace($omdir, "", $tmpfile);
   echo "<A HREF='${tmpstr}'>Text Version</A>";
   echo "</TD>";
   echo "</TR>";
}

echo "</TABLE>";
echo "</BODY>";
echo "</HTML>";
}
?>
