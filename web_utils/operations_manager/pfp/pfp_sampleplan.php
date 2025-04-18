<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$proj_abbr = isset( $_POST['proj_abbr'] ) ? $_POST['proj_abbr'] : '';
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$sampleplan = isset( $_POST['sampleplan'] ) ? $_POST['sampleplan'] : '';
$template = isset( $_POST['template'] ) ? $_POST['template'] : '';
$serialport = isset( $_POST['serialport'] ) ? $_POST['serialport'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';
$set_limits = isset ($_POST['set_limits'])?$_POST['set_limits']:'';

$strat_abbr = 'pfp';
$strat_name = 'PFP';
$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";
$newlimits="";

if (empty($id)) $id = $selectedflasks;
#
# Get List of appropriate PFP Templates
#
$nflasks = DB_GetPFPNumFlasks($id);
list($name,$project) = split("_",$proj_abbr);
$key = sprintf("%s_%d_%s*.txt",strtolower($code),$nflasks,$project);

$r=rand();
$tmpfile="${omdir}tmp/xxx_${r}.txt";

$tmp = "/bin/ls /projects/aircraft/plans/sample/${key} > ${tmpfile}";
system($tmp);
$templates = file($tmpfile);
unlink($tmpfile);

$z = array_values(preg_grep("/_default.txt/", $templates));

$z[0] = ( isset($z[0]) ) ? $z[0] : '';
if (empty($template)) { $template = $z[0]; }

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_sampleplan.js'></SCRIPT>";
echo "<SCRIPT language='JavaScript' src='../messagealert.js'></SCRIPT>";

echo "<DIV id='messagebox' class='Message' ALIGN='center'>";
echo "<P class='MediumWhiteB'>Uploading PFP Sample Plan... Please Wait.</P>";
echo "</DIV>";
#
# Need this site list to verify codes
#
$siteinfo = DB_GetAllSiteInfo('',$strat_abbr);
for ($i=0,$z=''; $i<count($siteinfo); $i++)
{
   $field = split("\|",$siteinfo[$i]);
   $sites[$i] = $field[1];
}
$sites = array_values(array_unique($sites));
JavaScriptCommand("sites = \"".implode("|", $sites)."\"");

switch ($task)
{
   case 'upload':
      $uploadfile = sprintf("${omdir}pfp/src/tmp/xxx-%d.plan",rand());
      if (!($fp = fopen($uploadfile,"w")))
      {
         JavaScriptAlert("(upload)Unable to open ${uploadfile}.  Get help.");
         JavaScriptCommand("document.location='history.go(-1)'");
      }
      else
      {
         #
         # Save sample plan to temporary file
         #
         list($pre,$suf) = split("-",$id);
         fputs($fp,"${pre},${code}\n");

         $arr = explode('~',$sampleplan);
         for ($i=0; $i<count($arr); $i++)
         {
            $field = split("\|",$arr[$i]);
            $tmp = sprintf("%-4s %8s %8s %8s %12s %10s",
            $field[0],$field[1],$field[2],$field[3],$field[4],$field[5]);
            fputs($fp,"${tmp}\n");
         }
         fclose($fp);
         #
         # Upload saved sample plan
         #
         $arr = array();
         $z = "${omdir}pfp/src/as_comm/set_as_sampleplan.pl -f=${uploadfile} -p=${serialport} 2>&1";
         #$z = "${omdir}pfp/src/upload/pfp_uploadplan.pl -f${uploadfile} -p${serialport}";
         #JavaScriptAlert($z);

         exec($z,$arr,$ret);
         #unlink($uploadfile);

         if ($ret)
         {
            #
            # Upload Failed
            #
            $str = implode("\\n", $arr);
            UpdateLog($log,"Upload from ${serialport} to ${id} failed.");
            if ($str) { UpdateLog($log,"Error Message: ${str}."); }

            JavaScriptAlert($str);
            $task = 'prepare';
         }
         else
         {
            #
            # Upload Succeeded
            #
            
            
            $plan = implode("~", $arr);

            #Set limits if requested.
            if($set_limits){
                $z="${omdir}pfp/src/as_comm/set_as_limits.pl -p=${serialport} -pfpid=$pre -site=$code -project=$project";
                $arr=array();$ret=0;
                exec($z,$arr,$ret);
                if($ret){#failed
                    $str = implode("\\n", $arr);
                            UpdateLog($log,"setting limits on ${serialport} to ${id} failed.\n$z");
                            if ($str) { UpdateLog($log,"Error Message: ${str}.\n"); }
                }else{
                    $newlimits=implode("~",$arr);
                }
            }
            
            #Attempt to save off any processing changes if needed.
            preprocessTemplate($template,true);
         }
         break;
      }
      break;
   case 'bypass':
   case 'accept':
      DB_PreCheckout($id,$z);
      if ($z != "") { JavaScriptAlert($z); }
      else
      {
         #
         # check out
         #
         $z = ($task == 'bypass') ? "Upload by-passed." : "";

         $field = split("\/", $template);
         $tmp = split("_", $field[count($field)-1]);
         list ( $plan_name, $txt ) = split ("\.", $tmp[3]);
         if (DB_Checkout($id,$code,$proj_abbr,$plan_name))
         {
            UpdateLog($log,"${id} checked out to ${proj_abbr} at ${code}. ${z}");
            $arg1 = "pfp_sampleplanform.php?code=${code}&proj_abbr=${proj_abbr}&id=${id}";
            $arg1 = "${arg1}&plan=${sampleplan}&template=${template}";
            $arg2 = "scrollbars=yes,menubar=yes,resizeable=yes,width=600,height=800";
            $arg1 = rtrim($arg1);
            JavaScriptCommand("window.open('${arg1}','','${arg2}');");
         }
          else
          { JavaScriptAlert("Unable to check out ${id} to ${code}"); }
      }
      JavaScriptCommand("document.location='pfp_checkout.php'");
      break;
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $bg_color;
global $omdir;
global $code,$id;
global $proj_abbr;
global $task;
global $template;
global $templates;
global $sampleplan,$plan;
global $history;
global $nflasks;
global $set_limits;
global $newlimits;

$task = (empty($task)) ? 'plan' : $task;
if($task=='plan'){#Do a low pressure check and put up leak alert note if any found.
   $err= DB_CheckForLowPressure($id);
   if($err){ JavaScriptAlert($err); }
}
echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='task' VALUE='${task}'>";
echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE='${code}'>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_abbr' VALUE='${proj_abbr}'>";
echo "<INPUT TYPE='HIDDEN' NAME='id' VALUE='${id}'>";
echo "<INPUT TYPE='HIDDEN' NAME='sampleplan' VALUE='${sampleplan}'>";
echo "<INPUT TYPE='HIDDEN' NAME='template' VALUE='${template}'>";
echo "<INPUT TYPE='HIDDEN' NAME='serialport'>";
echo "<INPUT TYPE='HIDDEN' NAME='planheaders'>";
echo "<input type='hidden' name='set_limits' value='$set_limits'>";
#
##############################
# Title
##############################
#
echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>PFP Sample Plan";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

if ($task == 'upload')
{
   echo "<TABLE cellspacing=2 cellpadding=2 width='85%' align='center'>";
   echo "<TR></TR>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='LargeBlackB'>$id for $code</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "<TABLE align='center' width='75%' border='1' cellpadding='1' cellspacing='1'>";
   echo "<COLGROUP>";
   echo "<THEAD align='center'><TR>";
   echo "<TR><TH>Plan<TH></TR></THEAD>";
   echo "<TBODY>";

   $arr = explode('~',$plan);
   echo "<TR><TD><PRE>";
   for ($i=0; $i<count($arr); $i++)
   {
      $text = rtrim($arr[$i]);
      $text = ltrim($text, "\n\r\t");
      echo "$text<BR>";
   }
   echo "</PRE></TD></TR>";
   echo "</TABLE>";

   if($set_limits){#Print out the newly set limits   
	   $arr = explode('~',$newlimits);
	   echo "<div align='center'><h3>New Limits</h3></div><table align='center' border='1'><TR><TD><PRE>";
	   for ($i=0; $i<count($arr); $i++)
	   {
	      $text = rtrim($arr[$i]);
	      $text = ltrim($text, "\n\r\t");
	      echo "$text<BR>";
	   }
	   echo "</PRE></TD></TR>";
	   echo "</TABLE>";
   }
   echo "<TABLE width='20%' cellspacing='2' cellpadding='2' align='center'>";

   echo "<TR>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Accept' onClick='AcceptCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='history.back()'>";
   echo "</TD>";

   echo "</TR>";
   echo "</TABLE>";
}

if ($task == 'prepare')
{
   #
   ##############################
   # Download Instructions
   ##############################
   #
   echo "<TABLE cellspacing=10 cellpadding=10 width='75%' align='center'>";
   echo "<TR></TR>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='LargeBlackB'>$id for $code</TD>";
   echo "</TR>";
   echo "<TR></TR>";
   echo "<TR align='center'>";
   echo "<TD align='left' class='LargeRedB'>1. Connect PFP power and communication cables</TD>";
   echo "<TR align='center'>";
   echo "<TD align='left' class='LargeRedB'>2. Switch on PFP power</TD>";
   echo "<TR align='center'>";
   echo "<TD align='left' class='LargeRedB'>3. Select Port Location ";
   echo "<SELECT class='LargeBlackN' NAME='sp' SIZE='1'>";
   echo "<OPTION SELECTED VALUE='/dev/ttyr300'>PFP Prep Room (ttyr300)</OPTION>";
   echo "<OPTION VALUE='/dev/ttyr200'>PFP Repair Room (ttyr200)</OPTION>";
   echo "<OPTION VALUE='/dev/ttyr100'>John Mund's Office (ttyr100)</OPTION>";
   echo "</SELECT>";
   echo "</TD>";
   echo "<TR align='center'>";
   echo "<TD align='left' class='LargeRedB'>4. Press ";
   echo "<B><INPUT TYPE='button' class='Btn' value='Upload' onClick='UploadCB()'>";
   echo " or ";
   echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='history.back()'>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";
}
if ($task == 'plan')
{
   echo "<TABLE cellspacing=4 cellpadding=4 width='70%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='left' class='LargeBlackB'>${id}";
   echo "<FONT class='LargeBlackN'> for </FONT>";
   echo "<FONT class='LargeBlackB'>${code}</FONT></TD>";
   echo "<TD align='right' class='LargeBlackN'>Sample Plan ";
   echo "<SELECT class='LargeBlackB' NAME='planlist' SIZE=1 onChange='GetPlanCB()'>";

   for ($i=0; $i<count($templates); $i++)
   {
      $p1 = strrpos($templates[$i],"/")+1;
      $p2 = strrpos($templates[$i],".");
      $field =  split("_",substr($templates[$i],$p1,$p2-$p1));
      $z = strtoupper($field[2])." - (${field[3]})";

      $selected = (empty($template) && $field[3] == 'default') ? 'SELECTED' : '';
      if (trim($template) == trim($templates[$i])) $selected = 'SELECTED';
      echo "<OPTION ${selected} VALUE='${templates[$i]}'>${z}</OPTION>";
   }
   echo "</SELECT>";

   echo "</TR>";
   echo "</TABLE>";
   #
   ##############################
   # Define PFP Plan Table
   ##############################
   #
   echo "<TABLE align='center' border='1' cellpadding='4' cellspacing='1'>";

   echo "<TR></TR>";
   echo "<TR>";

   echo "<TH><FONT class='MediumBlackB'>Control</FONT></TH>";
   echo "<TH><FONT class='MediumBlackB'>Status</FONT></TH>";
   echo "<TH><FONT class='MediumBlackB'>No.</FONT></TH>";

   #$plan = file(rtrim($template));
   $plan=preprocessTemplate($template,false);#Load template from file (preprocessing if needed).

   $table["label"] = preg_split("/\s+/",array_shift($plan));

   JavaScriptCommand("document.mainform.planheaders.value = \"".implode("~",$table["label"])."\"");

   for ($i=0; $i<count($table['label']); $i++)
   {
      echo "<TH><FONT class='MediumBlackB'>";
      echo $table["label"][$i];
      echo "</FONT></TH>";

      $tmp = explode(":", $table["label"][$i]);
      $table["name"][$i] = strtolower($tmp[0]);
   }
   echo "</TR>";

   JavaScriptCommand("nsamples = \"${nflasks}\"");

   echo "<TR>";

   for ($i=0,$row=1; $i<count($plan); $i++,$row++)
   {
      echo "<TR>";
      echo "<TD class='MediumBlackB' align='center'>";
      $z = sprintf("plan_control%02d",$row);
      echo "<INPUT type='checkbox' CHECKED name='${z}'></TD>";
      echo "<TD class='MediumBlackB' align='center'>--</TD>";
      echo "<TD class='MediumBlackB' align='right'>${row}</TD>";

      $field = preg_split("/\s+/",trim($plan[$i]));

      for ($ii=0; $ii<count($table['label']); $ii++)
      {
         switch ( $table["name"][$ii] )
         {
            case "alt":
               $size = 6;
               $maxlen = 6;
               break;
            case "lat":
               $size = 8;
               $maxlen = 9;
               break;
            case "lon":
               $size = 9;
               $maxlen = 10;
               break;
            case "date":
               $size = 10;
               $maxlen = 10;
               break;
            case "time":
               $size = 8;
               $maxlen = 8;
               break;
            default:
               $size = 10;
               $maxlen = 10;
               break;
         }
         $z = sprintf("plan_%s%02d",$table["name"][$ii],$row);

         echo "<TD>";
         $field[$ii] = ( isset($field[$ii]) ) ? $field[$ii] : '';

         echo "<INPUT type='text' size='${size}' name='${z}'
         value='${field[$ii]}' maxlength='${maxlen}' class='MediumBlackN' DISABLED 
         onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
         echo "</TD>";
      }
   }
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "<TABLE width='40%' cellspacing='2' cellpadding='2' align='center'>";

   echo "<TR>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Upload' onClick='PrepareCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='ByPass' onClick='ByPassCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Edit' onClick='EditCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Defaults' onClick='SetDefaultsCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
   echo "</TD>";

   echo "</TR>";
   echo "</TABLE>";
}

echo "</BODY>";
echo "</HTML>";
}
function preprocessTemplate($template,$saveChanges=false){
   /*Function to do any pre-processing of template information before loading into the html form.
    *This is initially to support scheduled samples at sgp, but can be used arbitrarily.
    *When $saveChanges=false, this returns $template in an array (1 line per row, from file()).  Some file names may trigger preprocessing of the template
    *When $saveChanges=true, this does any preprocessing needed and then saves changes back to the file. 
    *This is called ($saveChanges=false) when loading the form and then with $saveChanges=true after
    *plan successfully uploaded to write the changes back to the file.  Note the file must be writable
    *to the apache user.
    *Returns false on error and may display an alert message..*/

   global $log;
   $err="";$modified=false;$plan=false;
   try{
      $template=rtrim($template);
      $plan = file($template);
      if($plan){
         #See if it's one we're programmed to process
         if(strpos(strtolower($template),'scheduledweekly')!==false){
            #Set 2 flasks to sample every week starting week after last date in the template.
            $labels = preg_split("/\s+/",$plan[0]);
            #Find the date col
            $datecol=-1;
            foreach($labels as $i=>$val){
               if(strpos(strtolower($val),'date')!==false){
                  $datecol=$i;  
                  break;
               }
            }
            if($datecol>=0){
               $numFlasks=sizeof($plan);
               
               #Fetch the date in the last row.  We'll use that as the starting point.
               $fields=preg_split("/\s+/",trim($plan[$numFlasks-1]));
               $lastDate=$fields[$datecol];
               if(strpos($lastDate,'9999')!==false)$err.="Last date in the template must be a valid date (not a fill date) for scheduledweekly templates.";
               
               else{
                  $date=strtotime($lastDate);
                  for($i=1;$i<sizeof($plan);$i++){#Start at first data line.
                     #We do 2 per date, so increment on odd count
            	     if(($i%2) != 0)$date=strtotime("+7 days",$date);#add week to date, disregard (keep) time portion.
                     $fields = preg_split("/\s+/",trim($plan[$i]));#split out row into an array.                     
                     $fields[$datecol]=date("Y-m-d",$date);#replace date with new one.
		     $fields[0]=-999;#Override sequence number with 9s because firmware won't accept seq and date in full auto mode.
                     $plan[$i]=implode('         ',$fields)."\n";#piece back to string
                  }
                  $modified=true;
                  
               }
                              
            }else{$err.="No date col specified in template.";}
            
         }
         if($saveChanges && $modified){
            #If requested, and some changes were made, try to write the file back out, saving new dates so we know where to start from next time.
            $t=file_put_contents($template,$plan);
            if($t===false)$err.="Error writing template.";
         }
      }
   }catch(Exception $e){$err.="Error doing date math for template.  ".$e->getMessage();}
   
   if($err){
      UpdateLog($log,"Loading $template failed.  $err");
      JavaScriptAlert($err);
   }
   return $plan;#return either the template as an array (might be processed) or false.
}
function DB_CheckForLowPressure($id){
    #checks to see if last recorded initial pressure was low and returns note with details
    #A little to tricky to tease out since we need to check each flask of the pfp so we'll just iterate through all 12.
    $threshold=30;#arbitrarly set by Molly
    $err='';
    $t=split('-',$id);
    $t=$t[0];
    for($i=1;$i<=12;$i++){//should probably be checking to see how many flasks there are, assume 12 for now (this is just informational anyway)
	$flask_id=$t."-".str_pad($i,2,'0',STR_PAD_LEFT);
    	$sql="select e.id,initial_flask_press,a.start_datetime from flask_analysis a join flask_event e on e.num=a.event_num where e.id like '${flask_id}' order by a.start_datetime desc limit 1";
    	#var_dump($sql);
    	$res=ccgg_query($sql);
    	if(count($res)==1){
        	$tmp=split("\|",$res[0]);
        	if($tmp[1]<$threshold){
		   	$err.=$tmp[0]."|".$tmp[2]."|".$tmp[1]." ";    
        	}
	}
    }
    if($err)$err="One or more flasks from $id had an initial flask pressure below threshold of $threshold.  Please verify that it has been serviced/repaired before checking out: $err";
    return $err;
}
#
# Function DB_PreCheckout ########################################################
#
function DB_PreCheckout($id,&$err)
{
   $err = "";

   $sql="SELECT id,sample_status_num FROM pfp_inv WHERE id='${id}'";

   $res = ccgg_query($sql);

   $n = count($res);
   if ($n == 0) { $err = "${id} no longer exists in DB."; }
   elseif ($n > 1) { $err = "${id} exists multiple times in DB."; }
   else
   {
      $tmp=split("\|",$res[0]);
      if ($tmp[1] != '1') { $err = "${id} no longer available for check out."; }
   }
}
#
# Function DB_Checkout ########################################################
#
function DB_Checkout($id,$code,$proj_abbr,$plan_name)
{
   #
   # Check flask out in DB
   #
   $now = date("Y-m-d");
   $site_num = DB_GetSiteNum($code);
   $proj_num = DB_GetProjectNum($proj_abbr);
   list($pre,$suf) = split("-FP",$id);

   $update = "UPDATE pfp_inv";
   $set = " SET site_num='$site_num',date_out='${now}'";
   $set = "${set},date_in='0000-00-00',sample_status_num='2'";
   $set = "${set},project_num='$proj_num',plan='$plan_name'";
   $where = " WHERE id LIKE '${pre}-%'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);
   #$res = "";
   if (!empty($res)) { return(FALSE); } 
   return(TRUE);
}
?>
