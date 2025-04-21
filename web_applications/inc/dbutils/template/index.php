<?php
#_One template to rule them all...
#_Copy this file and the switch.php file to your new directory, edit path and config variables below
#_and switch.php as needed.

#set default time zone utc for any tz naive objects so that they don't use system tz when parsing (strtotime)
date_default_timezone_set('UTC');

ob_start("ob_gzhandler");#Compress output.  NOTE; this may cause issues if cookies are being set.  I added this into template 11/5/21 (it was already in switch.php).

#_Note; all comments prepended with an underscore are template comments and may not always reflect modifications to the template
###
#_Paths for db includes
    #_Note: These entries must match in index.php and switch.php!

    #_The dbutils lib directory must be in a web accessible path.  We'll build up the various paths using defaults from om server.  Adjust as needed if moved

    #_Edit these 2 as needed.  These are the defaults on om and omi servers.
    #_Web root directory so we can figure out relative paths (file system path)
    $webRootDir="/var/www/html/";

    #_Path to dbutils from web root directory
    $dbutils_relPath="inc/dbutils";
    ###


    #_These next two can be calculated.
    #_Path to dbutils for php includes (actual path)
    $dbutilsPath=$webRootDir.$dbutils_relPath; #"/var/www/html/inc/dbutils";

    #_Path for html (css/js) includes.  This is relative to directory where you put index.php.
    #_Leave blank to auto-calculate in in index_includes.php
    $dbutils_webPath=""; #"../../inc/dbutils";

    #_config for db login info.  Customize in a local file if rw access needed.  Default is ro
    $dbconfig=$dbutilsPath."/dbutils_config.php";

    #_link to lib and open connection for dbutils tools.
    require_once("$dbutilsPath/dbutils.php");
    db_connect($dbconfig);
###

#Include printMap includes?
$includeMapLib=false;

#_generic listing functions.
require_once("$dbutilsPath/template/resources/index_funcs.php");

/*_Defaults for page layout.  Configure overrides in module switch below.
There are 3 divs;
   sidebarDiv: Full height, thin, on left side of window.  For search form/critera.
   adjHeightContentDiv: Automatically resizeing div on top by default($adjOnTop) that fills the slop area on right side of window.
   fixedHeightContentDiv: Fixed height div (can be zero) on right side of window.

The fixedHeightContentDiv height is set below intially but can be udpated with js function changeFixedDiveHeight('100px');

There is also a generic hidden div for js work: dbutils_js_div
   Content is controlled by 'mod' parameter (module -ie index.php?mod=orders) allowing different pages to be served from single
   index.php

   For content on single index.php (for a module), use ajax libs to load content.  See example mod below.
*/

#_default title and page layout.  Pagetitle should mirror module name
$windowTitle="Global Monitoring Division/CCGG";
$pageTitle="";
$titleRightContent="";#This can be small text/log out button... should not be higher than 1 em.  Shows up in float right of title bar.
$sidebarDivWidth='275px';
$sidebarTitle="";
$fixedDivHeight='300px';
$onResizeFunction='';#Can be a js function that gets called on window resize. ex: 'setwindowHeight()'

#_Which div is on top (fixed or adjustable).
$adjOnTop=true;

#_default content for 3 divs (can be loaded later via ajax too)
$sideBarContent="";/*Content is placed inside of a form with id 'search_form'.  Any form elements in sideBarContent
                    *will autosubmit the form  with a doWhat of i_loadList (see switch.php) if they are of
                    *the class 'search_form_auto_submit'.  $dbutilsPat/template/resources/index_funcs.php has some custom
                    *widgets that will set the class for you.
                    *You can have an explicit submit too.*/
$slopDivContent="";#goes into adjHeightContentDiv
$fixedDivContent="";#goes into fixedHeightContentDiv

$onReadyJS="";#_Can be any (jquery) js that needs to run after page is ready.  You could also put in below $linkJS (more efficient if alot of js)
    #_pass "i_loadList();" to auto-submit critera
$linkJS="";#_Relative path to a js file (ie "j/lib/net.js");
$linkCS="";#_Ditto.
$otherHeaderContent="";#_Any other things to put in the head section of html
$helpText="";#_If set below, displays in a dialog.  Can be any valid html (not user generated!)
$beta=true;#_Puts a little beta message after title.
$includeSideBarForm=true;#Set true (default) to include the search_form form in the side bar (described above).  False to skip it and roll your own.


#_mod is the module to load.  Not required if index is single use (one page/module).  If you pass ie index.php?mod=orders,
#_you can set totally different content based on mod.
$module=getHTTPVar("mod");
switch($module){#_Override defaults as needed for each module.
    /*_Example:
     case "orders":
        #Order Summary page.
        #See if an order num was passed to preload
        $order_num=getHTTPVar("order_num",'',VAL_INT);
        $sideBarContent=ord_getSearchFormContent($order_num);
        $pageTitle.="Orders";
        $fixedDivContent="<br><br><br><br><div style='width:100%;text-align: center;'><div class='title2' style='color:silver'>Order detail</div><div class='title4' style='color:silver'>Click an order below to load details</div></div>";
        $adjOnTop=false;
        $helpText=ord_getHelpText();
        $linkJS="j/lib/orders.js";
        $beta=false;
        break;*/
    case "example":
        bldsql_init();
        bldsql_from("gmd.site s");
        bldsql_col("s.num as 'key'");
        bldsql_col("s.code as 'value'");
        bldsql_col("concat('(',s.code,') ',s.name) as 'label'");
        bldsql_orderby("s.code");
        $siteSelect=i_getAutoCompleteSelect(doquery(),'ev_site_num',3);
        $submit=getJSButton('search_submit_btn','i_loadList','Submit');
        $sideBarContent="Site: $siteSelect $submit";
        $slopDivContent="";
        $fixedDivContent="";
        $sidebarTitle="Example";
        $adjOnTop=false;
        break;
     /*_ex from sdi...
      * default: #Index.php

        $sideBarContent=getSideBarContent($module);
        $slopDivContent="";
        $fixedDivContent="Fixed Div content";
        $pageTitle="Sample conditions";
        $fixedDivHeight='360px';
        $beta=true;
        $sidebarTitle="Filters";
        $adjOnTop=false;
        break;
    */
    default: #Index.php
        $sideBarContent="Side bar Content";
        $slopDivContent="Slop content";
        $fixedDivContent="Fixed Div content";
        $pageTitle="CCGG Template page title";
        $fixedDivHeight='150px';
        $beta=true;
        $showHome=false;
        $adjOnTop=false;
        break;
}

#_Load the actual html...
require_once ($dbutilsPath."/template/index_includes.php");
