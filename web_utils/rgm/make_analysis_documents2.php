<?php
/*New combined logic to create certificate and reports of analysis.  Note this is called from command line to keep similar to
previous logic*/
$dev=false;
#To test in live mode:
#/var/www/html/rgm]$ php make_analysis_documents2.php>documents/t.html 2816 51 cert
#where 2816 is a product # and 51 is tom's user

require_once "/var/www/html/inc/validator.php";

#Do some gymnastics to figure out where we're calling from so we can link to db lib.. need relative path for css link.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/rgm")?"../inc/dbutils":"../../inc/dbutils";

require_once("$dbutils_dir/dbutils.php");
db_connect("./j/lib/config.php");

if($dev){
    $product_num=153;#153 has co2 isotopes
    $productnum=2816;
    $user_num=101;
    $docType='cert';#'report';#'cert';
    $imagesPath="./images";
    echo "DEV MODE";
}else{
    # Product number must be specified
    if ( ! isset($argv[1]) || ! ValidInt($argv[1]) ){ exit(1);}
    $product_num=$argv[1];

    # User must be specified
    if ( ! isset($argv[2]) || ! ValidInt($argv[2]) ){exit(2);}
    $user_num=$argv[2];

    #Doctype must be specified
    if(!isset($argv[3]) || ($argv[3]!='cert' && $argv[3]!='report')){exit(3);}
    $docType=$argv[3];

    $imagesPath="../images";
}

#Some Dan requires for content objects;
require_once "CCGDB.php";
require_once "DB_Product.php";
require_once "DB_CalRequestManager.php";

try{
    $database_object = new CCGDB();
    $product_object = new DB_Product($database_object,$product_num);
    $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);
    $user_object = new DB_User($database_object, $user_num);

    $analPeriod=htmlentities($product_object->getLastAnalysisFromDB(), ENT_QUOTES, 'UTF-8');
    $preparedBy=htmlentities($user_object->getName(), ENT_QUOTES, 'UTF-8');

    #Signature
    if ( $user_num == '49' ){$signature="<IMG src='${imagesPath}/Duane-Kitzis_signature.jpg'><br>$preparedBy<br>Associate Scientist III, CIRES<BR>";}
    elseif( $user_num == '101' || $user_num == '60'){$signature="<IMG src='${imagesPath}/devogel_signature.jpg'><br>$preparedBy<br>Associate Scientist III, CIRES<BR>";}#60 is john mund (for dev purposes only), so i can run the code.
    elseif ( $user_num == '51' ){
        $signature="<IMG src='${imagesPath}/Thomas-Mefford_signature.jpg'><br>$preparedBy<br>Associate Scientist III, CIRES<BR>";
    }
    else{throw new Exception ("No signature on file to create certificate.");}

    #Add phone/contact
    $matches = array();
    preg_match('/^\(([0-9]{3})\) ([0-9]{3}\-[0-9]{4})$/', $user_object->getTelephone(), $matches);
    if ( isset($matches[1]) && isset($matches[2]) ){ $phone = '+1-'.$matches[1].'-'.$matches[2]; }
    else{ $phone = '+1 '.$user_object->getTelephone(); }
    $signature.="Ph: $phone E-Mail: <A href='mailto:".$user_object->getEmail()."'>".$user_object->getEmail()."</A>";

}catch (Exception $e){
    echo $e->getMessage();
    exit(4);
}


#Some content that is docType specific
$title=($docType=='cert')?"Certificate of Analysis":"Report of Analysis";
$certLabel=($docType=='cert')?"Certificate Number":"Report Number";

#Analysis methods
$calservice_info = array();
$calservice_info['calibration_method'] = array();
$calservice_info['calibration_method']['CO2'] = array('LASER<br>SPECTROSCOPY'=>'generalized method indicating the application of CRDS with OA-ICOS or QC-TILDAS for making total CO<sub>2</sub>,&#948;<sup>13</sup>C, and &#948;<sup>18</sup>O measurements.  See <a href="http://www.esrl.noaa.gov/gmd/ccl/co2_calsystem.html">http://www.esrl.noaa.gov/gmd/ccl/co2_calsystem.html</a> and Tans et al. (2017) for details');
#NOTE; hard code in below becuase its referenced in a footnote $calservice_info['calibration_method']['CH4'] = array('GC-FID'=>'gas chromatography with flame ionization detection');
$calservice_info['calibration_method']['CH4'] = array('CRDS'=>'cavity ring-down spectroscopy');
#$calservice_info['calibration_method']['CO'] = array('OA-ICOS'=>'off-axis integrated cavity absorption spoctroscopy');
$calservice_info['calibration_method']['CO'] = array('VURF'=>'vacuum ultraviolet resonance fluorescence');
$calservice_info['calibration_method']['N2O'] = array('GC-ECD'=>'gas chromatography with electron capture detection');
$calservice_info['calibration_method']['SF6'] = array('GC-ECD'=>'gas chromatography with electron capture detection');

#References
#$calservice_info['references']['CO2'] = 'Hall, B. D., Crotwell, A. M., Kitzis, D. R., Mefford, T., Miller, B. R., Schibig, M. F., and Tans, P. P.: Revision of the WMO/GAW CO2 Calibration Scale, Atmos. Meas. Tech. Discuss., https://doi.org/10.5194/amt-2020-408, in review, 2020.<br>
#Tans, P. P., Crotwell, A. M., and Thoning, K. W.: Abundances of isotopologues and calibration of CO2 greenhouse gas measurements, Atmos. Meas. Tech., 10, 2669-2685, doi:10.5194/amt-10-2669-2017, 2017.<sub>&nbsp;</sub><br>Zhao, C. L., P. P. Tans, and K. W. Thoning, A high precision manometric system for absolute calibrations of CO<sub>2</sub> in dry air, <I>J. Geophys. Res., 102</I>, D5, pp. 5885-5894, 1997.';
$calservice_info['references']['CO2'] = 'Hall, B. D., Crotwell, A. M., Kitzis, D. R., Mefford, T., Miller, B. R., Schibig, M. F., and Tans, P. P.: Revision of the World Meteorological Organization Global Atmosphere Watch (WMO/GAW) CO2 calibration scale, Atmos. Meas. Tech., 14, 3015–3032, https://doi.org/10.5194/amt-14-3015-2021, 2021.<br><br>
Tans, P. P., Crotwell, A. M., and Thoning, K. W.: Abundances of isotopologues and calibration of CO2 greenhouse gas measurements, Atmos. Meas. Tech., 10, 2669-2685, doi:10.5194/amt-10-2669-2017, 2017.<sub>&nbsp;</sub><br>Zhao, C. L., P. P. Tans, and K. W. Thoning, A high precision manometric system for absolute calibrations of CO<sub>2</sub> in dry air, <I>J. Geophys. Res., 102</I>, D5, pp. 5885-5894, 1997.';

$calservice_info['references']['CH4'] = 'Dlugokencky, E. J. et al., Conversion of NOAA atmospheric dry air CH<sub>4</sub> mole fractions to a gravimetrically prepared standard scale, <I>J. Geophys. Res., 110</I>, D18306, 2005.';
$calservice_info['references']['CO'] = 'Novelli, P. C., K. A. Masarie, P. M. Lang, B. D. Hall, R. C. Myers, and J. W. Elkins, Reanalysis of tropospheric CO trends: Effects of the 1997–1998 wildfires, <i>J. Geophys. Res.</i>, 108(D15), 4464, doi:10.1029/2002JD003031, 2003.';
$calservice_info['references']['N2O'] = 'Hall, B. D., G. S. Dutton, and J. W. Elkins, The NOAA nitrous oxide standard scale for atmospheric observations, <I>J. Geophys. Res., 112</I>, D09305, doi:10.1029/2006JD007954, 2007.';
$calservice_info['references']['SF6'] = 'Hall, B. D. et al., Improving measurements of SF<sub>6</sub> for the study of atmospheric transport and emissions, <I>Atmos. Meas. Tech.</I>, 4, 2441-2451, 2011.';
$isotopeRef="<tr><td valign='top' style='white-space: nowrap;'>CO<sub>2</sub>&#948;<sup>13</sup>C and CO<sub>2</sub>&#948;<sup>18</sup>O:</td><td><p>Coplen, T.B., Reporting of stable carbon, hydrogen, and oxygen isotopic abundances, in Reference and intercomparison materials for stable isotopes of light elements (1995). Vienna, International Atomic Energy Agency, IAEA-TECDOC-825, p. 31-34.<br>Wendeberg, M., Richter, J. M., Rothe, M., and Brand, W. A.: Jena Reference Air Set (JRAS): a multi-point scale anchor for isotope measurements of CO2 in air, Atmos. Meas. Tech., 6, 817-822, 10.5194/amt-6-817-2013, 2013.</p></td></tr>";


#Grab out the product wide variables.
$cylinder_id=$product_object->getCylinder()->getID();
$fill_code=$product_object->getFillCode();

#Build some combined values for below.
$certNumber=$cylinder_id."-".$fill_code;

#Version is the last mod date of this file.  Tom M will keep is copy (for occasional manual made certs) in sync. yy.mm.dd
$version=date('Y.m.d',filemtime(__FILE__));
?>

<html>
    <head>
        <style>
            body{
               font-size: 9pt;
               font-family:"Times";
               width: 612px;
               line-height:125%;
            }
            table{
               font-size: 9pt;
               font-family:"Times";
               line-height:125%;
            }
            .banner{
               font-size: 10pt;
               font-family:"Arial";
               color:#1A6B98;
            }
            .captions{
               font-size: 8pt;
               font-family:"Times";
               line-height: 100%;

            }
            .title{
                font-size:1.3em;
                font-family: "Times";
                font-weight: bold;
            }
            .results{
               border-collapse: collapse;
               text-align: center;

            }
            .results th{border-top:1px solid black;border-bottom:1px solid black;}
            .results td{border-top:1px solid black;border-bottom:1px solid black;}

            .bordertop{
               border-top: 1px solid black;
            }
            .borderbottom{
               border-bottom: 1px solid black;
            }
            .borderleft{
               border-left: 1px solid black;
            }
            .borderright{
               border-right: 1px solid black;
            }
            .certData{color:red;}
            .certDataTable td{vertical-align:  top;}
            .csabbr{
                border-right:1px solid black;
                padding-left: 4px;
                padding-right: 4px;
                padding-bottom: 2px;
                padding-top: 2px;
                font-weight: bold;
            }
            img, p,li, blockquote {page-break-inside: avoid;}
        </style>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
        <meta charset="UTF-8">
    </head>
    <body>
        <table width='100%' border='0'>
            <!--Header info-->
            <?#php if($docType=='cert'){?>
            <tr>
                <td align='center'>
                    <table>
                        <tr>
                            <td style='border-right: solid black 3px;padding:10px;'><IMG height='100px' src='../images/dept_of_commerce_emblem.jpg'></td>
                            <td class='banner'>
                                <span style='font-weight:bold'>
                                    UNITED STATES DEPARTMENT OF COMMERCE<BR>
                                    National Oceanic and Atmospheric Administration<BR>
                                </span>
                                Office of Oceanic and Atmospheric Research<br>
                                Global Monitoring Laboratory<BR>
                                325 Broadway - David Skaggs Research Center<BR>
                                Boulder, CO 80305-3337<BR>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>
            <?php #} ?>
            <tr>
                <td align='center'>
                 <div class='title'><?php echo $title?></div>
                 <div style='font-size:1.1em;'>NOAA Global Monitoring Laboratory (GML)</div>
                </td>
            </tr>

            <!--Certificate contents-->
            <tr>
                <td>
                    <table width='100%' class='certDataTable' style='border-collapse: collapse'>
                        <tr><td width='20%'><?php echo $certLabel?>:</td><td class='certData'><?php echo $certNumber?></td></tr>
                        <tr><td>Issue Date:</td><td class='certData'><?PHP echo date('j F Y'); ?></td></tr>
                        <tr><td>Version:</td><td class='certData'><?PHP echo $version; ?></td></tr>
                        <tr><td>Material:</td><td>Air, compressed, in an aluminum gas cylinder, nominal pressure 13.6 MPa (2000 psi)</td></tr>
                        <tr><td>Intended Use:</td><td>For the calibration of instruments determining mole fractions of trace gases in air.  Experience has shown that high flow applications may lead to changes in CO<sub>2</sub> mole fraction. For high precision measurement, flow should be less than 0.5 liters per minute.</td></tr>

                        <?php if ($docType=='report'){
                           echo "<tr><td>Caution:</td><td class='certData'>Cylinders calibrated on extended scales do not establish traceability to the WMO/GAW scales.</td></tr>";
                        }?>
                        <tr><td>Use and Storage:</td><td>Cylinders should be used under normal laboratory conditions (room temperature).</td></tr>
                        <tr><td>Period of Analysis:</td><td class='certData'><?php echo $analPeriod; ?></td></tr>
                        <tr><td>Prepared by:</td><td class='certData'><?php echo $preparedBy;?></td></tr>
                        <tr><td colspan='2'>&nbsp;</td></tr>
                        <tr>
                            <td class='bordertop borderbottom borderleft title' valign='center'style='padding:4px;'>Cylinder ID:</td>
                            <td  style='padding:4px;' class='certData bordertop borderbottom borderright title' valign='center' ><?php echo $cylinder_id;?></td>
                        </tr>
<?php
$resultsText="Results are based on analyses performed by the WMO/GAW Central Calibration Laboratories (CCL) located at the NOAA Global Monitoring Laboratory (GML).  The CCL supports monitoring programs that contribute to WMO/GAW by maintaining and propagating scales for relevant atmospheric trace species.  Standards traceable to these scales are used to calibrate atmospheric measurements providing comparability across WMO/GAW contributing programs.  WMO/GAW mole fraction scales are developed and maintained by GML in its role as CCL.  Results are traceable to the dimensionless SI-derived quantity \"amount of substance fraction\", expressed in units of mole fraction.  Equipment used to develop mole fraction scales and establish traceability to the SI are traceable to national standards for mass, temperature, pressure, and amount of substance fraction. For more information on calibration scales and analysis methods, see <A href='http://www.esrl.noaa.gov/gmd/ccl'>http://www.esrl.noaa.gov/gmd/ccl</A>.";
if($docType!='cert')$resultsText="Results are based on analyses performed by the WMO/GAW Central Calibration Laboratories (CCL) located at the NOAA Global Monitoring Laboratory (GML).  Results reported on this Report of Analysis are outside the WMO/GAW scale ranges for the species of interest. Measurements outside the WMO/GAW scale ranges are calibrated against extended scales. Extended scales are designed to be consistent with the WMO/GAW scales through the use of similar techniques, but are not routinely investigated with quality control procedures and do not establish traceability to the WMO/GAW scales.  For more information on calibration scales and analysis methods, see <a href='http://www.esrl.noaa.gov/gmd/ccl'>http://www.esrl.noaa.gov/gmd/ccl</a>.";
?>
                        <tr><td colspan='2'><br><?php echo $resultsText; ?></td></tr>
                    </table>
                    <br>

                    <div class='title' style='padding-bottom:3px;'>Results</div>
                    <table width='100%' class='results'>
                        <tr>
                            <th class='borderleft'></th>
                            <th>Mole<BR>Fraction<SUP>1</SUP></th>
                            <th>Reproducibility<SUP>2<?php if ($docType=='report'){echo ",3";}?></sup></th>
                            <?php if($docType=='cert'){echo "<th>Expanded<BR>Uncertainty<SUP>3</SUP></th>";}?>
                            <th>Unit</th>
                            <th>Method</th>
                            <th class='borderright'>Calibration Scale</th>
                        </tr>

<?php
try{
    $calservice_objects = array ();
    $certificate_calservice_objects = DB_CalServiceManager::getCertificateCalServices($database_object);
    $calrequest_count = 0;
    $isotopes="";
    $isotopesReferences="";

    foreach ( $calrequest_objects as $calrequest_object ){
        # Only display the results of a calservice that should be displayed on certificates
        if ( ! equal_in_array($calrequest_object->getCalService(), $certificate_calservice_objects) ) { continue; }

        list($reference_scale_span_min, $reference_scale_span_max) = split(',',$calrequest_object->getCalService()->getReferenceScaleSpan($calrequest_object->getAnalysisReferenceScale()));

        # Only put this calrequest on the certificate if it is WITHIN the reference scale span and we have reproduceability and uncertainty.  Otherwise put on report if we're called for report
        if ( ! ValidFloat($calrequest_object->getAnalysisValue()) || $calrequest_object->getAnalysisValue() < $reference_scale_span_min || $calrequest_object->getAnalysisValue() > $reference_scale_span_max || ! ValidFloat($calrequest_object->getReproducibility()) || ! ValidFloat($calrequest_object->getExpandedUncertainty()) )
        {#Out side of scale range or missing required info.
            if($docType=='cert'){continue; }
        }else{#Inside scale range with all required info (put on certs, but skip for reports)
            if($docType=='report'){continue;}
        }

        $calrequest_count++;

        #Save off any that we are printing
        array_push($calservice_objects, $calrequest_object->getCalService());

        #Build output row
        $abbr=$calrequest_object->getCalService()->getAbbreviationHTML();
        $cs_num=$calrequest_object->getCalService()->getNum();
        $digits=($cs_num==2 || $cs_num==3)?1:2;#significant digits
        $value=number_format($calrequest_object->getAnalysisValue(), $digits, '.', '');
        $rep=$calrequest_object->getReproducibility();

        $unc=$calrequest_object->getExpandedUncertainty();
        $unit=$calrequest_object->getCalService()->getUnitHTML();
        $calservice_abbr = strtoupper($calrequest_object->getCalService()->getAbbreviation());
        $method=key($calservice_info['calibration_method'][$calservice_abbr]);
        $scale=$calrequest_object->getAnalysisReferenceScale();
        if($docType=='report')$scale.="_EXTENDED";
        if($scale && $docType=='cert')$scale="WMO-".$scale;
        #co scale footnote
        if($scale == 'WMO-CO_X2014A')$scale.="<sup>4</sup>";

        echo "
        <tr>
             <td class='csabbr borderleft'>$abbr</td>
             <td class='certData'>$value</td>
             <td class='certData'>$rep</td>";
        if($docType=='cert'){echo "<td class='certData'>$unc</td>";}
        echo "
             <td>$unit</td>
             <td>$method</td>
             <td class='borderright'>$scale</td>
        </tr>";

        #Build isotopes if this is co2
        if($cs_num==1){
            $tdCol=($docType=='cert')?7:6;#formatting kluges
            $tdFill=($docType=='cert')?"<td></td>":"";
            $thFill=($docType=='cert')?"<th></th>":"";
            bldsql_init();
            bldsql_from("rgm_calrequest_view v");
            bldsql_where("v.product_num=?",$product_num);
            bldsql_where("v.request_num=?",$calrequest_object->getNum());
            bldsql_where("(v.co2c13_value is not null and v.co2o18_value is not null)");
            bldsql_where("(v.co2c13_value != -999.99 and v.co2o18_value != -999.99)");
            bldsql_col("format(co2c13_value,1) as c13");
            bldsql_col("format(co2o18_value,1) as o18");
            $repo=($docType=='cert')?"0.4":"Out of scale range";
            $foot3=($docType=='report')?",3":"";

            $a=doquery();
            if($a){
                extract($a[0]);
                $isotopes="
                    <tr><td align='left' colspan='$tdCol' class='title' style='border:none;padding-bottom:3px;'><br>Informational Values</td></tr>
                    <tr><th class='borderleft'></th><th>Value<sup>5</sup></th><th>Reproducibility<sup>2".$foot3."</sup></th>$thFill<th>Unit</th><th>Method</th><th class='borderright'>Calibration Scale</th></tr>";
                if($c13){
                    $isotopes.="
                    <tr>
                        <td class='csabbr borderleft'>CO<sub>2</sub>&nbsp;&#948;<sup>13</sup>C</td>
                        <td class='certData'>$c13</td><td class='certData'>$repo</td>$tdFill<td>per mil</td><td>LASER<br>SPECTROSCOPY</td><td class='borderright'>VPDB-CO<sub>2</sub></td>
                    </tr>
                    ";
                }
                if($o18){
                    $isotopes.="
                    <tr>
                        <td class='csabbr borderleft'>CO<sub>2</sub>&nbsp;&#948;<sup>18</sup>O</td>
                        <td class='certData'>$o18</td><td class='certData'>$repo</td>$tdFill<td>per mil</td><td>LASER<br>SPECTROSCOPY</td><td class='borderright'>VPDB-CO<sub>2</sub></td>
                    </tr>
                    ";
                }
                $isotopesReferences=$isotopeRef;#Show references too.
            }
        }
    }
    echo $isotopes;
}catch(Exception $e){
    echo $e->getMessage();
    exit(5);
}
?>
                    </table>
                    <DIV class='captions' style="page-break-before:always;line-height:150%;">
                        <p><SUP>1</SUP> Mole fraction in dry air, expressed on
                        <?php if ($docType=='cert'){echo "a ";}else{echo "an extension of the ";}?>
                        WMO/GAW mole fraction calibration scale.<br>(µmol mol<SUP>-1</SUP> = ppm, nmol mol<SUP>-1</SUP> = ppb, pmol mol<SUP>-1</SUP> = ppt)</p>
                        <p><SUP>2</SUP> Expected long-term variation of analysis results assuming no cylinder drift (95% confidence level).</p>
<?php
if($docType=='cert'){
                echo "  <p><SUP>3</SUP> Total uncertainty, estimated with coverage factor <I>k</I>=2, (~95% confidence level).  Total uncertainty includes uncertainties associated with preparation and analysis of primary standards, as well as scale propagation.  Note that we explicitly express the results with the number of significant figures corresponding to the number of significant figures in the reproducibility estimate. This is deliberate, as it provides important information to WMO/GAW end users. For CO<sub>2</sub>, CH<sub>4</sub>, and N<sub>2</sub>O, we report expanded uncertainties consistent with results submitted to key comparisons CCQM-K68 (N<sub>2</sub>O), CCQM-K82 (CH<sub>4</sub>), and CCQM-K120a (CO<sub>2</sub>). Uncertainties for CH<sub>4</sub> at mixing ratios above 2500 ppb have not been validated by key comparison (see Flores et al., 2014; and https://www.esrl.noaa.gov/gmd/ccl/ccl_uncertainties.html).</p>";
}else{
                echo "  <p><SUP>3</sup> The reproducibility estimate given here was determined for the ranges of the WMO/GAW scale.  Reproducibility outside the WMO/GAW scale range has not been explicitly determined, but is expected to be similar.</p>";
}
?>
                        <p><sup>4</sup> The CCL has become aware of a bias in the CO X2014A scale and between the two analytical techniques used for CO calibrations since 2004 (VURF and OA-ICOS). These are under review by the CCL, see https://www.esrl.noaa.gov/gmd/ccl/co_scale.html for further information. Values reported on this certificate are based on VURF measurements only.</p>
                        <p><sup>5</sup> The reported CO<sub>2</sub> isotopic values are informational only. They are not to be used as a substitute to having cylinders directly measured by IRMS when isotopic standards are required. They are designed to be used only for making isotopic corrections to measurements of atmospheric CO<sub>2</sub> on instruments that are sensitive to isotopic differences between standards and samples. The values for reference materials used to determine instrument response were provided by the University of Colorado, Boulder, Institute of Arctic and Alpine Research (INSTAAR) on the JRAS-06 realization of the VPBD-CO<sub>2</sub> scale (Wendeberg et al., 2013). Isotopic values are reported as ‘delta’ values, in per mil units (&permil; or 10<sup>-3</sup>), relative to a standard reference material. The 'delta' notation is (for <sup>13</sup>C for example):<br>
                            &#948;<sup>13</sup>C = [ (<sup>13</sup>C/<sup>12</sup>C)/ (<sup>13</sup>C/<sup>12</sup>C)<sub>reference</sub> - 1 ]<br>
                            For carbon and oxygen isotopes, the reference is VPDB-CO2 (Coplen 1995).</p>

                    </DIV>
                    <div><br>
                        <div class='title'>Period of Validity</div>
                        Recalibrations are highly recommended (see WMO/GAW Report No. 255 for more information about recalibration intervals). At a minimum, it is recommended to perform a final calibration at the end of the cylinder's term of use (pressure &ge; 24 atm.).  Mole fractions shown are valid for a period of 3 years.  The more reactive analyte carbon monoxide typically shows measurable drift within 2 years.
                    </div>
                    <div><br>
                        <?php echo $signature;?><br><br><br>
                    </div>
                    <div class='title'>Terms</div>
                    <TABLE cellspacing='1' cellpadding='1'>

<?PHP
   $acronym_arr = array();
   $unique_calservice_objects = array_unique_obj($calservice_objects);
   foreach ( $unique_calservice_objects as $calservice_object )
   {
      $calservice_abbr = strtoupper($calservice_object->getAbbreviation());

      if ( ! in_array(key($calservice_info['calibration_method'][$calservice_abbr]), $acronym_arr ) ){
         echo "<TR><TD valign='top'><p style='white-space: nowrap;'>".key($calservice_info['calibration_method'][$calservice_abbr]).':</p></TD><TD><p>'.current($calservice_info['calibration_method'][$calservice_abbr])."</p></TD></tr>";
         if($calservice_abbr=='CO2'){
            #Add in the isotope terms too.
            echo "<tr><td><p>CRDS:</p></td><td><p>cavity ring-down spectroscopy</p></td></tr>
                <tr><td><p>QC-TILDAS:</p></td><td><p>quantum cascade tunable infrared laser differential absorption spectroscopy</p></td></tr>
            ";
            array_push($acronym_arr,"CRDS");
            array_push($acronym_arr,"OA-ICOS");
            array_push($acronym_arr,"QC-TILDAS");
         }
         array_push($acronym_arr, key($calservice_info['calibration_method'][$calservice_abbr]));
      }
   }
?>
                        <tr><td><p>OA-ICOS:</p></td><td><p>off-axis integrated cavity absorption spectroscopy</p></td></tr>
                        <tr><td><p>IRMS:</p></td><td><p>isotope ratio mass spectometry</p></td></tr>
                        <TR><TD><p>WMO/GAW:</p></TD><TD><p>World Meteorological Organization, Global Atmosphere Watch</p></TD></TR>
                    </TABLE>
                    <p>
                    <div class='title' style="page-break-before:always;">References</div>
                    <TABLE cellspacing='5' cellpadding='2'>

<?PHP
    #
    # Display the reference paper citations
    #

    foreach ( $unique_calservice_objects as $calservice_object )
    {
       echo "<TR><TD valign='top'><p>";
       echo $calservice_object->getAbbreviationHTML().':&nbsp;&nbsp;&nbsp;';
       echo " </p></TD><TD style='line-height: 105%;'><p>";
       $calservice_abbr = strtoupper($calservice_object->getAbbreviation());
       echo $calservice_info['references'][$calservice_abbr];
       echo " </p></TD></TR>";
    }
    if($isotopesReferences)echo "$isotopesReferences";
?>

                        <TR><!--
                            <TD valign='top' style='white-space: nowrap;'>WMO/GAW:</td><td><p>19<SUP>th</SUP> WMO/IAEA Meeting on Carbon Dioxide, Other Greenhouse Gases and Related Tracers Measurement Techniques (GGMT-2017), D&uuml;bendorf, Switzerland, 27-31 August 2017, World Meteorological Organization, Global Atmosphere Watch Report Series No. 242, available at <a href='https://library.wmo.int/doc_num.php?explnum_id=5456'>https://library.wmo.int/doc_num.php?explnum_id=5456</a>.<br>
                            </p></TD>-->
				<td valign='top' style='white-space: nowrap;'>WMO/GAW:</td><td><p>20<sup>th</sup> WMO/IAEA Meeting on Carbon Dioxide, Other Greenhouse Gases and Related Measurement Techniques (GGMT-2019) Jeju Island, South Korea 2-5 September 2019, GAW Rep. No. 255, Geneva, Switzerland, available at   <a href='https://library.wmo.int/index.php?lvl=notice_display&id=21758#.YCLR-JNKjOQ'>https://library.wmo.int/index.php?lvl=notice_display&id=21758#.YCLR-JNKjOQ</a><br></p><td>
                        </TR>

                    </TABLE>

                    <div>
                        <HR>
                        <ul>
                            <li style='margin: 8px 0;'>
                                Regulators can be purchased directly from the manufacturer. We use Scott Gas model 51-14C-590 or Airgas Y12-C144B590. For mass spectrometer measurement of the stable isotopes of CO<sub>2</sub> we use Airgas model Y11-C444A590. The listing of part numbers here does not constitute an endorsement.
                            </li>
                            <li style='margin: 8px 0;'>
                                Amended <?php if($docType=='cert'){echo "certificates";}else{echo "reports";}?> will not be issued following calibration scale updates. Results are available at <A href='http://www.esrl.noaa.gov/gmd/ccl'>http://www.esrl.noaa.gov/gmd/ccl</A>
                            </li>
                            <li style='margin: 8px 0;'>
                                This <?php if($docType=='cert'){echo 'certificate';}else{echo 'report';}?> shall not be reproduced except in full, without written approval of the NOAA Global Monitoring Laboratory.
                            </li>
                            <li style='margin: 8px 0;'>
                                Compressed gas cylinders are regulated by U.S. Law under CFR Title 49, parts 106-179. Users should ensure safe handling and storage. Cylinders should not be exposed to temperatures above 130&deg; C.  (<A href='http://www.luxfercylinders.com/support/temperature-exposure'>http://www.luxfercylinders.com/support/temperature-exposure</A>)
                            </li>
                        </ul>
                    </div>
                    </p>

                </td>
            </tr>
        </table>
    </body>

