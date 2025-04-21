<?PHP

require_once "CCGDB.php";
require_once "DB_Product.php";
require_once "DB_CalRequestManager.php";
require_once "/var/www/html/inc/validator.php";

# Product number must be specified
if ( ! isset($argv[1]) ||
     ! ValidInt($argv[1]) )
{
   exit(1);
}

# User must be specified
if ( ! isset($argv[2]) ||
     ! ValidInt($argv[2]) )
{
   exit(2);
}

try
{
   $database_object = new CCGDB();

   $product_object = new DB_Product($database_object, $argv[1]);

   $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

   $user_object = new DB_User($database_object, $argv[2]);
}
catch ( Exception $e )
{
   exit(3);
}

$errors = array();
$calservice_info = array();
$calservice_info['calibration_method'] = array();
$calservice_info['calibration_method']['CO2'] = array('NDIR'=>'non-dispersive infrared spectroscopy');
$calservice_info['calibration_method']['CH4'] = array('GC-FID'=>'gas chromatography with flame ionization detection');
$calservice_info['calibration_method']['CO'] = array('OA-ICOS'=>'off-axis integrated cavity absorption spoctroscopy');
$calservice_info['calibration_method']['N2O'] = array('GC-ECD'=>'gas chromatography with electron capture detection');
$calservice_info['calibration_method']['SF6'] = array('GC-ECD'=>'gas chromatography with electron capture detection');

$calservice_info['references']['CO2'] = 'Zhao, C. L., P. P. Tans, and K. W. Thoning, A high precision manometric system for absolute calibrations of CO<sub>2</sub> in dry air, <I>J. Geophys. Res., 102</I>, D5, pp. 5885-5894, 1997. <BR><BR>Zhao, C. L. and Tans, P. P., Estimating the uncertainty of the WMO mole fraction scale for carbon dioxide in air, <I>J. Geophys. Res., 111</I>, D08S09, doi:10.1029/2005JD006003, 2006.';
$calservice_info['references']['CH4'] = 'Dlugokencky, E. J. et al., Conversion of NOAA atmospheric dry air CH<sub>4</sub> mole fractions to a gravimetrically prepared standard scale, <I>J. Geophys. Res., 110</I>, D18306, 2005.';
$calservice_info['references']['CO'] = 'Novelli, P. C., K. A. Masarie, P. M. Lang, B. D. Hall, R. C. Myers, and J. W. Elkins, Reanalysis of tropospheric CO trends: Effects of the 1997–1998 wildfires, <i>J. Geophys. Res.</i>, 108(D15), 4464, doi:10.1029/2002JD003031, 2003';
$calservice_info['references']['N2O'] = 'Hall, B. D., G. S. Dutton, and J. W. Elkins, The NOAA nitrous oxide standard scale for atmospheric observations, <I>J. Geophys. Res., 112</I>, D09305, doi:10.1029/2006JD007954, 2007.';
$calservice_info['references']['SF6'] = 'Hall, B. D. et al., Improving measurements of SF<sub>6</sub> for the study of atmospheric transport and emissions, <I>Atmos. Meas. Tech.</I>, 4, 2441-2451, 2011.';
?>

<HTML>
 <HEAD>
  <style>
body
{
   font-size: 9pt;
   font-family:"Times";
   width: 612px;
   line-height:125%;
}
table
{
   font-size: 9pt;
   font-family:"Times";
   line-height:125%;
}
.banner
{
   font-size: 10pt;
   font-family:"Arial";
   color:#1A6B98;
}
.captions
{
   font-size: 8pt;
   font-family:"Times";
   line-height: 100%;
}
.results
{
   border-collapse: collapse;
   text-align: center;
}
.bordertop
{
   border-top: 1px solid black;
}
.borderbottom
{
   border-bottom: 1px solid black;
}
.borderleft
{
   border-left: 1px solid black;
}
.borderright
{
   border-right: 1px solid black;
}
  </style>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
 </HEAD>
 <BODY>
  <TABLE width='100%' cellpadding='3'>
   <TR>
    <TD>
     <TABLE align='center' cellspacing='1'>
      <TR>
       <TD>
        <IMG height='100px' src='../images/dept_of_commerce_emblem.jpg'>
       </TD>
       <TD style='background-color:#1A6B98'>
&nbsp;
       </TD>
       <TD>
        <FONT class='banner'>
         <FONT style='font-weight:bold'>
UNITED STATES DEPARTMENT OF COMMERCE<BR>
National Oceanic and Atmospheric Administration<BR>
         </FONT>
Earth System Research Laboratory<BR>
Global Monitoring Division<BR>
325 Broadway - David Skaggs Research Center<BR>
Boulder, CO 80305-3328<BR>
        </FONT>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD align='center'>
     <DIV style='font-size:1.3em; font-weight:bold;'>Certificate of Analysis</DIV>
     <BR>
     <DIV style='font-size:1.1em;'>NOAA Global Monitoring Division (GMD)</DIV>
    </TD>
   </TR>
   <TR>
    <TD>
     <TABLE width='100%' cellspacing='0' cellpadding='0'>
      <TR>
       <TD width='20%'>Certificate Number:</TD>
       <TD style='color:red;'>
<?PHP
try
{
   echo $product_object->getCylinder()->getID().'-'.$product_object->getFillCode().'_COA';
}
catch ( Exception $e )
{
   array_push($errors, $e);
}
?>
       </TD>
      </TR>
      </TR>
      <TR>
       <TD valign='top'>Issue Date:</TD>
       <TD style='color:red;'><?PHP echo date('j F Y'); ?></TD>
      </TR>
      <TR>
       <TD valign='top'>Document Version:</TD>
       <TD style='color:red;'><?PHP echo "1.2"; ?></TD>
      </TR>
      <TR>
       <TD valign='top'>Material:</TD>
       <TD>Air, compressed, in an aluminum gas cylinder, nominal pressure 13.6 MPa (2000 psi)</TD>
      </TR>
      <TR>
       <TD valign='top'>Intended Use:</TD>
       <TD>For the calibration of instruments for determining the mole fraction of trace gases in air. Experience has shown that high flow applications may lead to changes in CO<SUB>2</SUB> mole fraction. For high precision measurement, flow should be less than 0.5 liters per min.</TD>
      </TR>
      <TR>
       <TD valign='top'>Use and Storage:</TD>
       <TD>Cylinders should be used under normal laboratory conditions (room temperature). For storage, we recommend -30 to 40 deg C.</TD>
      </TR>
      <TR>
       <TD valign='top'>Period of Analysis:</TD>
       <TD style='color:red;'>
<?PHP
try
{
   echo htmlentities($product_object->getLastAnalysisFromDB(), ENT_QUOTES, 'UTF-8');
}
catch ( Exception $e )
{
   array_push($errors, $e);
}
?>
       </TD>
      </TR>
      <TR>
       <TD>Prepared by:</TD>
       <TD style='color:red;'>
<?PHP
try
{
   echo htmlentities($user_object->getName(), ENT_QUOTES, 'UTF-8');
}
catch ( Exception $e )
{
   array_push($errors, $e);
}
?>
       </TD>
      </TR>
      <TR>
       <TD>&nbsp;</TD>
       <TD>&nbsp;</TD>
      </TR>
      <TR>
       <TD class='bordertop borderbottom borderleft' width='20%' style='padding: 3px;'>
        <FONT style='font-weight:bold'>Cylinder ID:</FONT>
       </TD>
       <TD class='bordertop borderbottom borderright' style='padding: 3px;'>
        <FONT style='font-weight:bold; color:red;'>
<?PHP
try
{ echo htmlentities($product_object->getCylinder()->getID(), ENT_QUOTES, 'UTF-8'); }
catch ( Exception $e )
{ array_push($errors, $e); }
?>
        </FONT>
       </TD>
      </TR>
      <TR>
       <TD>&nbsp;</TD>
       <TD>&nbsp;</TD>
      </TR>
      <TR>
       <TD colspan='2'>
Results are based on analysis performed by the WMO/GAW Central Calibration Laboratories (CCL) located at the NOAA Global Monitoring Division (GMD). WMO/GAW mole fraction scales are developed and maintained by GMD in their role as CCL. Results are traceable to the SI unit “amount of substance fraction”. Equipment used to develop mole fraction scales and establish traceability to the SI are traceable to national standards for mass, temperature, pressure, and amount of substance fraction (O<sub>2</sub> in N<sub>2</sub>). For more information on calibration scales and analysis methods, see <A href='http://www.esrl.noaa.gov/gmd/ccl'>http://www.esrl.noaa.gov/gmd/ccl</A>.  For isotopic ratios or other informational values, if applicable, see <A href='http://www.esrl.noaa.gov/gmd/ccl/refgas.html/'>http://www.esrl.noaa.gov/gmd/ccl/refgas.html/</A>.
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <DIV style='font-size:1.05em; font-weight:bold; line-height:200%;'>Results</DIV>
     <TABLE class='results' cellspacing='2' cellpadding='2' width='100%'>
      <TR>
       <TH class='bordertop borderbottom borderleft borderright' style='line-height: 80%;'></TH>
       <TH class='bordertop borderbottom' style='line-height: 80%;'>Mole<BR>Fraction<SUP>1</SUP></TH>
       <TH class='bordertop borderbottom' style='line-height: 80%;'>Reproducibility<SUP>2</SUP></TH>
       <TH class='bordertop borderbottom' style='line-height: 80%;'>Expanded<BR>Uncertainty<SUP>3</SUP></TH>
       <TH class='bordertop borderbottom' style='line-height: 80%;'>Unit</TH>
       <TH class='bordertop borderbottom' style='line-height: 80%;'>Method</TH>
       <TH class='bordertop borderbottom borderright' style='line-height: 80%;'>Calibration Scale</TH>
      </TR>
<?PHP

$calservice_objects = array ();
$certificate_calservice_objects = DB_CalServiceManager::getCertificateCalServices($database_object);
$calrequest_count = 0;

foreach ( $calrequest_objects as $calrequest_object )
{
   # Only display the results of a calservice that should be displayed
   #  on certificates
   if ( ! equal_in_array($calrequest_object->getCalService(), $certificate_calservice_objects) ) { continue; }   

   #
   # Only put this calrequest on the certificate if it is WITHIN the reference scale span
   #
   #echo "<PRE>";
   #echo $calrequest_object->getAnalysisValue().' '.$calrequest_object->getAnalysisReferenceScale().' '.$calrequest_object->getCalService()->getReferenceScaleSpan($calrequest_object->getAnalysisReferenceScale());
   #echo "</PRE>";

   list($reference_scale_span_min, $reference_scale_span_max) = split(',',$calrequest_object->getCalService()->getReferenceScaleSpan($calrequest_object->getAnalysisReferenceScale()));
   if ( ! ValidFloat($calrequest_object->getAnalysisValue()) ||
        $calrequest_object->getAnalysisValue() < $reference_scale_span_min ||
        $calrequest_object->getAnalysisValue() > $reference_scale_span_max ||
        ! ValidFloat($calrequest_object->getReproducibility()) ||
        ! ValidFloat($calrequest_object->getExpandedUncertainty()) )
   { continue; }

   $calrequest_count++;

   try
   { array_push($calservice_objects, $calrequest_object->getCalService()); }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo "<TR>\n";
   echo " <TD class='borderbottom borderleft borderright'>\n";

   echo "<FONT style='font-weight: bold'>";
   try
   {
      echo $calrequest_object->getCalService()->getAbbreviationHTML();
   }
   catch ( Exception $e )
   { array_push($errors, $e); }
   echo "</FONT>";

   echo " </TD>\n";

   echo " <TD class='borderbottom' style='color:red;'>\n";

   try
   { 
      if ( $calrequest_object->getCalService()->getNum() == '2' ||
           $calrequest_object->getCalService()->getNum() == '3' )
      {
         echo number_format($calrequest_object->getAnalysisValue(), 1, '.', '');
      }
      else
      {
         echo number_format($calrequest_object->getAnalysisValue(), 2, '.', '');
      }
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo " </TD>\n";

   echo " <TD class='borderbottom' style='color:red;'>\n";

   try
   { echo $calrequest_object->getReproducibility(); }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo " </TD>\n";

   echo " <TD class='borderbottom' style='color:red;'>\n";

   try
   { echo $calrequest_object->getExpandedUncertainty(); }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo " </TD>\n";

   echo " <TD class='borderbottom'>\n";

   try
   { echo $calrequest_object->getCalService()->getUnitHTML(); }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo " </TD>\n";

   echo " <TD class='borderbottom'>\n";

   $calservice_abbr = strtoupper($calrequest_object->getCalService()->getAbbreviation());

   echo key($calservice_info['calibration_method'][$calservice_abbr]);

   echo " </TD>\n";

   echo " <TD class='borderbottom borderright'>\n";

   try
   {
      echo $calrequest_object->getAnalysisReferenceScale();
      /*jwm-2/10/16 no longer need this footnote per andy crotwell.  Leaving commented for reference, but can be removed.
      if ( $calrequest_object->getCalService()->getNum() == '3' )
      {
         echo "<SUP>4</SUP>";
      }*/
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   echo " </TD>\n";

   echo "</TR>\n";
}

?>
     </TABLE>
     <DIV class='captions'>
     <SUP>1</SUP> mole fraction in dry air, expressed on a WMO/GAW mole fraction calibration scale (µmol mol<SUP>-1</SUP> = ppm, nmol mol<SUP>-1</SUP> = ppb, pmol mol<SUP>-1</SUP> = ppt).
     <BR>
     <SUP>2</SUP> expected long-term variation of analysis results assuming no cylinder drift (95% confidence level)
     <BR>
     <SUP>3</SUP> total uncertainty, estimated with coverage factor <I>k</I>=2, (~95% confidence level).  Total uncertainty includes uncertainties associated with preparation and analysis of primary standards, as well as scale propagation.  Note that we explicitly express the results with the number of significant figures corresponding to the number of significant figures in the reproducibility estimate. This is deliberate, as it provides important information to WMO/GAW end users. 

<?PHP
/*jwm-2/10/16 no longer need this footnote per andy crotwell.  Leaving commented for reference, but can be removed.
   $unique_calservice_objects = array_unique_obj($calservice_objects);

   foreach ( $unique_calservice_objects as $calservice_object )
   {
      if ( $calservice_object->getNum() == '3' )
      {
         echo "<BR>";
         echo "<SUP>4</SUP> CO mole fractions are currently underestimated by as much as 2 ppb due to known drift in secondary standards. A method to reliably determine drift rates of secondary standards is under development. An update will be announced at a later date.";
         break;
      }
   }
   */
?>
     </DIV>
    </TD>
   </TR>
   <TR>
    <TD>
    <BR>
     Recalibrations are highly recommended (see WMO/GAW reports #206 and #213 for more information about recalibration intervals). At a minimum, it is recommended to perform a final calibration at the end of the cylinder's term of use (pressure &ge; 24 atm.).  Mole fractions shown are valid for a period of 3 years.
    </TD>
   </TR>
   <TR>
    <TD>

<?PHP

     # Make sure we have a signature for authorized users

     if ( $user_object->getNum() == '49' )
     {
        echo "<IMG src='../images/Duane-Kitzis_signature.jpg'>";
        echo "<BR>";
        echo htmlentities($user_object->getName(), ENT_QUOTES, 'UTF-8')."<BR>";
        echo "Associate Scientist III, CIRES<BR>";
     }
     elseif ( $user_object->getNum() == '51' )
     {
        echo "<IMG src='../images/Thomas-Mefford_signature.jpg'>";
        echo "<BR>";
        echo htmlentities($user_object->getName(), ENT_QUOTES, 'UTF-8')."<BR>";
        echo "Associate Scientist III, CIRES<BR>";
     }
     else
     {
        #throw new Exception ("No signature on file to create certificate.");
        exit(4);
     }

     $matches = array();
     preg_match('/^\(([0-9]{3})\) ([0-9]{3}\-[0-9]{4})$/', $user_object->getTelephone(), $matches);
     if ( isset($matches[1]) &&
          isset($matches[2]) )
     { $phone = '+1-'.$matches[1].'-'.$matches[2]; }
     else
     { $phone = '+1 '.$user_object->getTelephone(); }
     echo "Ph: $phone Fax: +1-303-497-6290 E-mail: <A href='mailto:".$user_object->getEmail()."'>".$user_object->getEmail()."</A>";

?>
    </TD>
   </TR>
   <TR>
    <TD>
     <DIV style='font-size:1.05em; font-weight:bold; line-height: 200%;'>Terms</DIV>
     <TABLE cellspacing='1' cellpadding='1'>
<?PHP
   $acronym_arr = array();

   foreach ( $unique_calservice_objects as $calservice_object )
   {
      $calservice_abbr = strtoupper($calservice_object->getAbbreviation());

      if ( ! in_array(key($calservice_info['calibration_method'][$calservice_abbr]), $acronym_arr ) )
      {
         echo "<TR>";
         echo " <TD>";
         echo key($calservice_info['calibration_method'][$calservice_abbr]).':';
         echo " </TD>";
         echo " <TD>";
         echo current($calservice_info['calibration_method'][$calservice_abbr]);
         echo " </TD>";
         echo "</TR>";

         array_push($acronym_arr, key($calservice_info['calibration_method'][$calservice_abbr]));
      }
   }
?>
      <TR>
       <TD>
        WMO/GAW:
       </TD>
       <TD>
        World Meteorological Organization, Global Atmosphere Watch
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <DIV style='font-size:1.05em; font-weight:bold; line-height:200%;'>References</DIV>
     <TABLE cellspacing='2' cellpadding='2'>

<?PHP
   #
   # Display the reference paper citations
   #

   foreach ( $unique_calservice_objects as $calservice_object )
   {
      echo "<TR>";
      echo " <TD valign='top'>";
      echo $calservice_object->getAbbreviationHTML().':&nbsp;&nbsp;&nbsp;';
      echo " </TD>";
      echo " <TD style='line-height: 105%;'>";

      $calservice_abbr = strtoupper($calservice_object->getAbbreviation());
      echo $calservice_info['references'][$calservice_abbr];
      echo " </TD>";
      echo "</TR>";
   }
?>
      <TR>
       <TD colspan='2'>
GAW Report No. 206: 16<SUP>th</SUP> WMO/IAEA meeting of experts on carbon dioxide, other greenhouse gases and related tracers measurement techniques, (Wellington, New Zealand, 25-28 October 2011), Geneva, Switzerland, 2012.  <A href='http://www.wmo.int/pages/prog/arep/gaw/documents/Final_GAW_206_web.pdf'>http://www.wmo.int/pages/prog/arep/gaw/documents/Final_GAW_206_web.pdf</A>
       </TD>
      </TR>
      <TR>
       <TD colspan='2'>
GAW Report No. 213: 17<SUP>th</SUP> WMO/IAEA meeting of experts on carbon dioxide, other greenhouse gases and related tracers measurement techniques, (Beijing, China, 10-13 June 2013), Geneva, Switzerland, 2014. <A href='http://www.wmo.int/pages/prog/arep/gaw/documents/Final_GAW_213_web.pdf'>http://www.wmo.int/pages/prog/arep/gaw/documents/Final_GAW_213_web.pdf</A>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <HR>
     <ul>
      <li style='margin: 8px 0;'>
       Regulators can be purchased directly from the manufacturer. We use Scott Gas model 51-14C-590 or Airgas Y12-C144B590. For mass spectrometer measurement of the stable isotopes of CO<sub>2</sub> we use Airgas model Y11-C444A590. The listing of part numbers here does not constitute an endorsement.
      </li>
      <li style='margin: 8px 0;'>
       Amended certificates will not be issued following calibration scale updates. Results are available at <A href='http://www.esrl.noaa.gov/gmd/ccl'>http://www.esrl.noaa.gov/gmd/ccl</A>
      </li>
      <li style='margin: 8px 0;'>
       This certificate shall not be reproduced except in full, without written approval of the laboratory.
      </li>
      <li style='margin: 8px 0;'>
       Compressed gas cylinders are regulated by U.S. Law under CFR Title 49, parts 106-179. Users should ensure safe handling and storage. Cylinders should not be exposed to temperatures above 130 deg C.  (<A href='http://www.luxfercylinders.com/support/care-maintenance/508-temperature-exposure'>http://www.luxfercylinders.com/support/care-maintenance/508-temperature-exposure</A>)
      </li>
     </ul>
    </TD>
   </TR>
  </TABLE>
 </BODY>
</HTML>

<?

try
{
   #
   # If no calrequests are displayed on the certificate (this can happen as
   #  we are not allowed to display results for isotopes) then throw an
   #  error
   #
   if ( $calrequest_count == 0 )
   {
      throw new Exception ("No calrequests displayed on certificate."); 
   }
}
catch ( Exception $e )
{
   array_push($errors, $e);
}

if ( count($errors) == 0 )
{
   exit(0);
}
else
{
   exit (5);
}

?>
