<?php
/*_This is the main ajax content portal for all newly generated pages
 *This is designed to be called by ajax scripts (see j/lib/ajax_handlers.js) from html elements on index.php
 *ajax_get(doWhat,params,destdiv,ajaxhandle) and ajax_post(doWhat,params,destdiv,ajaxhandle)
 *Generally, destdiv will be    adjHeightContentDiv or fixedHeightContentDiv, but can be any embedded div too.
 *$doWhat is the switch to load or process some data.
 *You should use getHTTPVar to load any user form passed data.
 */

#_Note; all comments prepended with an underscore are template comments and may not always reflect modifications to the template

ob_start("ob_gzhandler");#Compress output.

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
require_once("air_funcs.php");
require_once("pv_funcs.php");
$doWhat="";
$html="";
/*_NOT programmed yet.. you can see rgm or dt for examples though... should use .htaccess (and can use dbutils builtin too.)
session_start();
#See if the index page validated the user.  Note, we keep auth for duration of session.  See index.php for comments.
#Also note, this is also set in todo_list2.php
if(isset($_SESSION['i_userValidated']) && $_SESSION['i_userValidated']){
   $doWhat=getHTTPVar("doWhat","",VAL_STRING);
}else{
    echo "Authorization error in switch.php";
    exit();
}
session_write_close();
*/
$doWhat=getHTTPVar("doWhat");
#var_dump($doWhat);
switch($doWhat){
    case "i_loadList":
        /*_Generic function to load list based on search form.  See i_loadList() for details.
        mod controls which content we load.  See index.php for details on mod*/
        $module=getHTTPVar("mod");
        $html=i_loadList($module);
        break;
    //case "air_loadPlots":
    //    $html=air_loadPlots();
    //    break;
    case "air_getNavWidget":
        $html=air_getNavWidget();
        break;
    case "air_fetchNextRange":
        $range_num=getHTTPVar("range_num",false,VAL_INT);
        $range_index=getHTTPVar("range_index",false,VAL_INT);//js control var
        $html=air_fetchNextRange($range_num,$range_index);
        break;
    case "air_loadEventTagDisplay":
        $html=air_loadEventTagDisplay();
        break;
    case "air_loadEventData":
        $event_num=getHTTPVar("event_num",'',VAL_INT);
        $range_num=getHTTPVar("range_num",'',VAL_INT);
        $data_num=getHTTPVar("data_num",'',VAL_INT);
        $html=air_loadEventData($event_num,$data_num,$range_num);
        break;
    case "air_loadEventDataPopup":
        $html=air_loadEventDataPopup();
        break;
    case "air_submitTagEdit":
        $html=air_submitTagEdit();
        break;
    case "air_submitTagEdit2":#from popup
        $html=air_submitTagEdit2();
        break;
    case "air_profilePlots":
        $event_num=getHTTPVar("event_num",'',VAL_INT);
        $html=air_profilePlots($event_num);
        break;

    #PlotView
    case "pv_spPlotOnClick":
    #var_dump($_REQUEST);
        $html=pv_loadEventDataPopup();
        break;
    #_Networking/Utils  Default js pings once every 5 minutes to keep session alive.
    case "keepAlive":
       $html="Server last contacted:".date("h:i a");
       break;
}
function i_loadList($module){
    /*_Generic function to load content (list of orders, sites...) from search criteria.  See below for examples.*/
    $html="";

    switch($module){#_Override defaults as needed for each module.
        #_case "orders":
        #    require_once("orders_funcs.php");
        #    $html=ord_loadList();
        #    break;
        case "":
            $html="default content";
            break;
        case "plotView":
            $html=pv_loadPlots();
            break;

        default:
            $html="<div align='center' style='width:100%'><br><br><br><br><br>Unknown module: $module</div>";
            break;
    }
    return $html;
}


echo $html;
exit();

?>
