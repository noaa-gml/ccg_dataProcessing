<?php
#_One template to rule them all...
#_Copy this file and the switch.php file to your new directory, edit path and config variables below
#_and switch.php as needed.

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
    #$dbconfig="../lib/config.php";

    #_link to lib and open connection for dbutils tools.
    require_once("$dbutilsPath/dbutils.php");
    db_connect();
###


#_generic listing functions.
require_once("$dbutilsPath/template/resources/index_funcs.php");
require_once("air_funcs.php");
require_once("pv_funcs.php");
#require_once("../lib/funcs.php");

/*_Defaults for page layout.  Configure overrides in module switch below.
There are 3 divs;
   sidebarDiv: Full height, thin, on left side of window.  For search form/critera.
   adjHeightContentDiv: Automatically resizeing div on top by default($adjOnTop) that fills the slop area on right side of window.
   fixedHeightContentDiv: Fixed height div (can be zero) on right side of window.
   
   Content is controlled by 'mod' parameter (module -ie index.php?mod=orders) allowing different pages to be served from single
   index.php
   
   For content on single index.php (for a module), use ajax libs to load content.  See example mod below.
*/

#_default title and page layout.  Pagetitle should mirror module name
$windowTitle="Global Monitoring Division/CCGG";
$pageTitle="";
$sidebarDivWidth='275px';
$sidebarTitle="";
$fixedDivHeight='300px';
$onResizeFunction='';#Can be a js function that gets called on window resize. ex: 'setwindowHeight()'

#_Which div is on top (fixed or adjustable). 
$adjOnTop=true;

#_default content for 3 divs (can be loaded later via ajax too)
$sideBarContent="";/*Content is placed inside of a form with id 'search_form'.  Any form elements in sideBarContent
                    *will autosubmit the form  with a doWhat of i_loadList (see switch.php) if they are of
                    *the class 'search_form_auto_submit'.  $dbutilsPat/template/index_funcs.php has some custom
                    *widgets that will set the class for you.
                    *You can have an explicit submit too.*/
$slopDivContent="";
$fixedDivContent="";
$autoLoad=(getHTTPVar('autoLoad',0,VAL_INT))?'i_loadList()':'';
$onReadyJS=$autoLoad;#
    
$linkJS="review.js";#_Relative path to a js file (ie "j/lib/net.js");
$linkCS="styles.css";#_Ditto.
$otherHeaderContent="";#_Any other things to put in the head section of html
$helpText="";#_If set below, displays in a dialog.  Can be any valid html (not user generated!)
$beta=true;#_Puts a little beta message after title.


#_mod is the module to load.  Not required if index is single use (one page/module).  If you pass ie index.php?mod=orders,
#_you can set totally different content based on mod.  
$module=getHTTPVar("mod");
switch($module){#_Override defaults as needed for each module.
    
    case "ccg_aircraft":
        
        $includeSideBarForm=false;#no outer form (for standard selectors/filters), we'll roll our own.
        $sideBarContent=getSiteSelector();
        $slopDivContent=getPlotDivs();
        $sidebarDivWidth="300px";
        $fixedDivHeight="0";
        $fixedDivContent="";
        $sidebarTitle="CCG_Aircraft Automated Tag Review";
        $adjOnTop=true;
        $helpText=getHelpText();
        break;
    
    case "plotView":
        $includeSideBarForm=true;
        $sideBarContent=pv_getSideContent();
        $slopDivContent=getPlotDivs();
        $sidebarDivWidth="300px";
        $fixedDivHeight="0";
        $fixedDivContent="";
        $sidebarTitle="Plot View";
        $adjOnTop=true;
        #$helpText=getHelpText();
        break;
    
    default: #Index.php
        $sideBarContent="";
        $slopDivContent="";
        $fixedDivContent="";
        $pageTitle="CCGG";
        $fixedDivHeight='150px';
        $beta=true;
        $showHome=false;
        $adjOnTop=false;
        break;
}

#_Load the actual html...
require_once ($dbutilsPath."/template/index_includes.php");
