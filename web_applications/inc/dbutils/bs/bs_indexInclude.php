<?php

/*This is the main body of index page.
Requires an index.php to set some expected variables & constants
See index.php template for documentation.*/


#Default in values for optional vars if needed
$bgPic=(isset($headerBGPicture) && $headerBGPicture!='')?$headerBGPicture:BOOTSTRAP_UTILS_RELPATH."/resources/globe3.jpg";
$logo=(isset($logoURL) && $logoURL!='')?$logoURL:BOOTSTRAP_UTILS_RELPATH."/resources/noaalogo2.png";
$orgHeader=(isset($orgHeaderText))?$orgHeaderText:"<span class='bs_title3'>G</span>lobal <span class='bs_title3'>M</span>onitoring <span class='bs_title3'>L</span>aboratory";
$jsInc=(isset($includeJS) && $includeJS)?bs_getIncludeText($includeJS,true):"";
$cssInc=(isset($includeCSS) && $includeCSS)?bs_getIncludeText($includeCSS,'css',true):"";

$navbarColorTheme=(isset($navbarColorTheme) && $navbarColorTheme!='')?$navbarColorTheme:"dark";#
$currMod=(isset($mod))?$mod:getHTTPVar('mod');
$contact=(isset($contactInfo) && $contactInfo!='john')?$contactInfo:"&nbsp;Questions? Issues? <a href='mailto:john.mund@noaa.gov'>John</a> 2D131";#allow empty
if($contact=='')$contact='&nbsp;';#needed for layout
if(!isset($leftSideBarPadding) && isset($leftSideBarWidth) && $leftSideBarWidth==0)$leftSideBarPadding=0;#If no sidebar, zero out the padding
$leftSideBarPadding=(isset($leftSideBarPadding))?$leftSideBarPadding:"3px";
$projectName=($projectName)?"$projectName &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ":"";


#figure out layout
$leftContentStyle="flex:0 0 {$leftSideBarWidth}px;padding:$leftSideBarPadding;";#fixed width
$fixContentStyle="flex:0 0 {$fixedContentHeight}px";#fixed height
$adjContentStyle="flex:1 1 0px;overflow:auto";#grow, shrink, set min size so scrolling logic can kick in (not sure I totally understand the need for this).
$topContentStyle=($adjOnTop)?$adjContentStyle:$fixContentStyle;
$botContentStyle=($adjOnTop)?$fixContentStyle:$adjContentStyle;
$topContentID=($adjOnTop)?'bs_adjContentDiv':'bs_fixedContentDiv';
$botContentID=($adjOnTop)?'bs_fixedContentDiv':'bs_adjContentDiv';
$topContent=($adjOnTop)?$bs_adjContent:$bs_fixedContent;
$botContent=($adjOnTop)?$bs_fixedContent:$bs_adjContent;

$tableClickedDestDiv=($searchFormDestDiv=='bs_adjContentDiv')?'bs_fixedContentDiv':'bs_adjContentDiv';//Be default, we'll send table clicks to the other main div.

#themes
$nvBgColorClass=($navbarColorTheme=='dark')?'navbar-dark bg-dark':'navbar-light bg-light';#'bg-body-tertiary';
$nvTextClass=($navbarColorTheme=='dark')?'text-light':'text-dark';
$nvSpinnerClass='text-primary';#($navbarColorTheme=='dark')?'text-light':'text-dark';

#set default time zone utc for any tz naive objects so that they don't use system tz when parsing (strtotime)
date_default_timezone_set('UTC');

#Compress output.  NOTE; this may cause issues if cookies are being set.
#!!!!!!!!!!!!
#NOT working at the moment and I can't access err lo to see why temporarily.  Should write a func to check if set and enable if not.
#ob_start("ob_gzhandler");

#ini_set("zlib.output_compression", "On");
#var_dump(ini_get("zlib.output_compression"));
?><!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo $title;?></title>
    <?php
        echo bs_getHeaderIncludes();
        echo "$jsInc $cssInc";
    ?>

    <script>//Global for use in support js.  Declared in included js script (bs_getHeaderIncludes).
        bs_searchFormDestDiv='<?php echo($searchFormDestDiv);?>';
        bs_tableClickedDestDiv='<?php echo($tableClickedDestDiv);?>';
    </script>
  </head>
  <body>

    <!--Main body content wrapper to set up flexbox layout-->
    <div class='bs_contentWrapper'>
        <div class='bs_header'>

            <!--Top header graphic-->
            <div class='bs_headerText' style='background: #000000;background: url("<?php echo $bgPic;?>") no-repeat right, linear-gradient(to right, blue , black 250px);'>
                <table class='bs_thinTable' style='margin:5px 5px 5px 5px;'>
                    <tr>
                        <td><img width="64" height="64" alt="Logo" src="<?php echo $logo;?>" style='vertical-align:middle;'></td>
                        <td align='right'>
                            <?php echo $orgHeader;?>
                        </td>
                    </tr>
                </table>
                <noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
            </div>

            <!--Menu Navigation Bar-->
            <nav class='navbar navbar-expand-lg <?php echo $nvBgColorClass;?> py-0 sticky-top'>
              <div class='container-fluid'>
                <a class='navbar-brand' href='index.php'><?php echo $projectName;?></a>
                <button class='navbar-toggler' type='button' data-bs-toggle='collapse' data-bs-target='#navbarSupportedContent' aria-controls='navbarSupportedContent' aria-expanded='false' aria-label='Toggle navigation'>
                  <span class='navbar-toggler-icon'></span>
                </button>
                <?php echo bs_getNavBarContents($menuOptions,$currMod);?>
                <div id='bs_networkingActivityDiv' class="spinner-border <?php echo $nvSpinnerClass;?> float-end" style='display:none;' role="status"></div>
              </div>
            </nav>

        </div>

        <!--Main Content -->
        <div class='bs_mainContentWrapper'>
            <div id='bs_leftContentDiv' class='bs_border bs_leftContent' style='<?php echo $leftContentStyle;?>'><?php echo $bs_leftContent;?></div>
            <div id='bs_rightContent' class='bs_rightContent'>
                <div id='<?php echo $topContentID;?>' class='bs_contentDivs' style="<?php echo $topContentStyle;?>"><?php echo $topContent;?></div>
                <div id='<?php echo $botContentID;?>' class='bs_contentDivs' style="<?php echo $botContentStyle;?>"><?php echo $botContent;?></div>
            </div>
        </div>



        <!--Footer-->
        <div class="bs_footer  <?php echo $nvBgColorClass.' '.$nvTextClass.' text-end';?> pe-2 justifiedContainer" style='display: flex; justify-content: space-between;'>
            <span class='bs_sm_ital' style='flex: 1; text-align: left;'><?php echo $contact;?></span>
            <span class='bs_sm_data' id='bs_statusDiv' style='flex: 1;width:100%;'></span>
            <span class='bs_sm_data' id='bs_netStatusDiv' style='flex: 1; text-align: right;'></span>
        </div>
    </div>

    <!--JS div for ajax calls-->
    <div class='bs_hidden' id='bs_ajaxJSDiv'></div>
    <!--And one for keep alive-->
    <div id='bs_keepAliveDiv'></div>

    <!--bootstrap js-->
    <?php echo bs_getBodyJSIncludes();?>
  </body>
</html>

<?php ob_flush();?>
