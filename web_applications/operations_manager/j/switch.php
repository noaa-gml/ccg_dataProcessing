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
    $dbconfig=$dbutilsPath."/dbutils_config.php";

    #_link to lib and open connection for dbutils tools.
    require_once("$dbutilsPath/dbutils.php");
    db_connect($dbconfig);
###

#Logic functions
require_once("lib/funcs.php");

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
switch($doWhat){
    case "i_loadList":
        /*_Generic function to load list based on search form.  See i_loadList() for details.
        mod controls which content we load.  See index.php for details on mod*/
        $module=getHTTPVar("mod");
        $html=i_loadList($module);
        break;
    case "loadExDetails":
        #_Load event details for example mod
        $event_num=getHTTPVar("event_num",0,VAL_INT);
        bldsql_init();
        bldsql_from("ccgg.flask_data_view");
        bldsql_where("event_num=?",$event_num);
        bldsql_col("site");
        bldsql_col("parameter");
        bldsql_col("value");
        $html=printTable(doquery());
        break;
    /*
    #_Order functions
    case "ord_loadOrder":
        $num=getHTTPVar("order_num",false,VAL_INT);
        $html=ord_loadOrder($num);    
        break;
      ....
    */
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
        case "example":
            $site_num=getHTTPVar("ev_site_num",0,VAL_INT);
            
            bldsql_init();
            bldsql_from("ccgg.flask_event_view e");
            bldsql_col("e.num as onClickParam");
            bldsql_col("e.site");
            bldsql_col("e.date");
            bldsql_col("e.project");
            bldsql_col("e.strategy");
            bldsql_orderby("e.date");
            bldsql_where("e.site_num=?",$site_num);
            $html=printTable(doquery(),'loadExDetails',1);
            
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
