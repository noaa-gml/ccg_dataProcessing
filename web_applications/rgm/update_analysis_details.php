<?PHP

require_once("DB_CalRequest.php");
require_once("CCGDB.php");
require_once("utils.php");

#
# 2015-10-07 (dyc)
# A script used to update calibrations reference scale, calibrations selected,
#   submission datetime and user for analyzes completed in the past. This
#   processes the log files for this information.
#
# This will not work properly after this date because new information has been
#   added into the log.
#

session_start();

$database_object = new CCGDB();

$login_user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $login_user_obj);

#$file = '/var/www/html/rgm/log/2014.txt';
$file = '/var/www/html/rgm/log/2015.txt';
#$file = '/var/www/html/chao/cylinder2/log/2014.txt';
#$file = '/var/www/html/chao/cylinder2/log/2015.txt';

$myfile = fopen($file, 'r');

echo "<PRE>";

$prevline = '';
while (!feof($myfile) )
{
#for ($idx=0; $idx<count($arr); $idx++)

   $line = fgets($myfile);

   if ( strpos($line, "ANALYSIS COMPLETE") )
   {
      $fields = split(" ", $prevline);
      $date = $fields[0];
      $time = $fields[1];
      $user = str_replace(array('(', ')'), '', $fields[2]);

      if ( $user == 'chao' )
      { $user = 'danlei.chao'; }
      elseif ( $user == 'pat' )
      { $user = 'patricia.m.lang'; }
      elseif ( $user == 'hall' )
      { $user = 'bradley.hall'; }
      elseif ( $user == 'paul' )
      { $user = 'paul.c.novelli'; }
      elseif ( $user == 'duane' )
      { $user = 'duane.r.kitzis'; }
      elseif ( $user == 'mund' )
      { $user = 'john.mund'; }

      print $date.' '.$time.' '.$user."\n";
      $tmpaarr = unserialize(str_replace("(ANALYSIS COMPLETE) ", "",$line));
      print_r($tmpaarr);

      if ( $tmpaarr['calrequest_num'] != '' && 
           $tmpaarr['calrequest_analysis-value'] != '' )
      { 
         try
         {
            $calrequest_object = new DB_CalRequest($database_object,$tmpaarr['calrequest_num']); 
            #print_r($calrequest_object);
         }
         catch (Exception $e)
         {
            # Do nothing
            continue;
         }

         # Determine the reference scale
         $calservice_num = $calrequest_object->getCalService()->getNum();

         if ( $calservice_num == 1 )
         {
            $reference_scale = 'CO2_X2007';
         }
         elseif ( $calservice_num == 2 )
         {
            if ( $date >= '2015-07-06' )
            { $reference_scale = 'CH4_X2004A'; }
            else
            { $reference_scale = 'CH4_X2004'; }
         }
         elseif ( $calservice_num == 3 )
         {
            if ( $date >= '2014-01-01' )
            { $reference_scale = 'CO_X2014'; }
            else
            { $reference_scale = 'CO_X2004'; }
         }
         elseif ( $calservice_num == 4 )
         {
            $reference_scale = 'N2O_X2006A';
         }
         elseif ( $calservice_num == 5 )
         {
            if ( $date >= '2014-08-22' )
            { $reference_scale = 'SF6_X2014'; }
            else
            { $reference_scale = 'SF6_X2006'; }
         }

         #print $reference_scale."\n";

         try
         {
            $user_obj = new DB_User($database_object, $user, '' );
            print $user_obj->getEmail()."\n";
         }
         catch (Exception $e)
         {
            print "User $user not found.\n";
            exit;
         }

         if ( $calrequest_object->getAnalysisValue() != strtolower($tmpaarr['calrequest_analysis-value']))
         {
            print "ERROR: Analysis values do not match.\n";
            print $calrequest_object->getNum()."\n";
            print $calrequest_object->getAnalysisValue()."\n";
            print $calrequest_object->getAnalysisRepeatability()."\n";
            #print_r($calrequest_object);
            continue;
         }

         if ( $calrequest_object->getAnalysisRepeatability() != strtolower($tmpaarr['calrequest_analysis-repeatability']))
         {
            print "ERROR: Analysis repeatability values do not match.\n";
            print $calrequest_object->getNum()."\n";
            print $calrequest_object->getAnalysisValue()."\n";
            print $calrequest_object->getAnalysisRepeatability()."\n";
            #print_r($calrequest_object);
            continue;
         }

         $dataaarr = array();
         $dataaarr['analysis_submit_datetime'] = $date.' '.$time;
         $dataaarr['analysis_submit_user'] = $user_obj->getUsername(); 

         $calrequest_analyzes = '';
         if ( isset($tmpaarr['calrequest_analyzes']) )
         {
            $calrequest_analyzes = join("\n", $tmpaarr['calrequest_analyzes']);
         }

         $dataaarr['analysis_calibrations_selected'] = $calrequest_analyzes;

         if ( $calrequest_analyzes != '' || is_float($tmpaarr['calrequest_analysis-value']) )
         {
            $dataaarr['analysis_reference_scale'] = $reference_scale;
         }

         echo "DATAAARR: \n";
         print_r($dataaarr);

         $setarr = array();
         $sqlargs = array();
         foreach ( $dataaarr as $key=>$value )
         {
            array_push($setarr, "$key = ?");
            array_push($sqlargs, $value);
         }

         $sql = " UPDATE calrequest SET ".join(', ', $setarr)." WHERE num = ? LIMIT 1";
         array_push($sqlargs, $calrequest_object->getNum());

         print $sql."<BR>";
         print join("|", $sqlargs)."<BR>";

         #$database_object->executeSQL($sql, $sqlargs);
      }
   }

   $prevline = $line;
}

echo "<PRE>";
?>
