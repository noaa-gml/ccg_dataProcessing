<?php
#One template to rule them all... (except for todo list which this is modeled on)

require_once("./j/lib/todo_list_funcs.php");
require_once("./j/lib/index_funcs.php");
require_once("j/lib/orders_funcs.php");
#Dan's includes.
require_once "menu_utils.php";
require_once "CCGDB.php";
require_once "DB_UserManager.php";
require_once "utils.php";

$html="";

#Do some gymnastics to figure out where we're calling from so we can link to db lib.. need relative path for css link.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/rgm")?"../inc/dbutils":"../../inc/dbutils";

#link to lib for dbutils tools.
require_once("$dbutils_dir/dbutils.php");

#Load post vars here so we can save in session var if needed (to login)
$module=getHTTPVar("mod");
$order_num=getHTTPVar("order_num",'',VAL_INT);

#Load session and validate user auth using legacy code.
session_start();
$database_object = new CCGDB();
$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';




if($user_obj){
    $userID=$user_obj->getNum();
    ValidateAuthentication($database_object, $user_obj);
    #Set a session cookie to tell the ajax handler we've been authenticated.  Once on a page,
    #we won't force further checks, particularly for the ajax content as there isn't an easy
    #way to redirect failed ajax loads to login page.  If for some reason we need to implement
    #timeout restrictions, it should be done as a page timer auth check on this page.
    $_SESSION['i_userValidated']=true;
    #Try loading post vars from session if we just got redirected through the auth logic
    if(!$module){
        if (isset($_SESSION['posted_module']))$module=$_SESSION['posted_module'];
    }
    if(!$order_num){
        if (isset($_SESSION['posted_order_num']))$order_num=$_SESSION['posted_order_num'];
    }
    #Unset regardless.. we don't want this to persist
    unset($_SESSION['posted_module']);
    unset($_SESSION['posted_order_num']);
    session_write_close();
}else{
    #Save off some post data so we can use after validation (above)
    $_SESSION['posted_module']=$module;
    $_SESSION['posted_order_num']=$order_num;
    session_write_close();
    #var_dump($_GET);exit();
    include('login.php');
    exit();
}


#Connect to db
db_connect("./j/lib/config.php");

##
#Defaults for page layout.  Configure overrides in module switch below.
##

#default title and page layout.  Pagetitle should mirror module name
#Note; $sideBarDivWidth can be set smaller, but the menu takes a fixed amount of space so it can be set to less than that without reprogramming the layout of the top tr
$windowTitle="RefGas Manager";$pageTitle="";$sidebarDivWidth='275px';$fixedDivHeight='300px';

#Which div is on top (fixed or adjustable).
$adjOnTop=true;

#default content for 3 divs (can be loaded later via ajax too)
$sideBarContent="";$slopDivContent="";$fixedDivContent="";

$onReadyJS="";//Can be any (jquery) js that needs to run after page is ready.  You could also put in below $linkJS (more efficient if alot)
$linkJS="";#Relative path to a js file (ie "j/lib/net.js");
$linkCS="";#Ditto.
$helpText="";//If set below, displays in a dialog.  Can be any valid html (not user generated!)
$showHome=true;#Shows a little house next to menu
$beta=false;#Puts a little beta message after title.


switch($module){#Override defaults as needed for each module.
    case "orders":
        #Order Summary page.
        #See if an order num was passed to preload

        $sideBarContent=ord_getSearchFormContent($order_num);
        $pageTitle.="Orders";
        $fixedDivContent="<br><br><br><br><div style='width:100%;text-align: center;'><div class='title2' style='color:silver'>Order detail</div><div class='title4' style='color:silver'>Click an order below to load details</div></div>";
        $adjOnTop=false;
        $helpText=ord_getHelpText();
        $linkJS="j/lib/orders.js";
        $beta=false;
        $fixedDivHeight='330px';
        break;
    case 'addOrder':
        $pageTitle.="Add Order";
        $slopDivContent=ord_editOrderForm();
        $sideBarContent=ord_editSideBar();
        $fixedDivHeight='0px';#Only show adjustable window.
        $sidebarDivWidth='150px';#Make as small as can
        $linkJS="j/lib/orders.js";
        $beta=false;
        break;
    case 'editOrder':
        $pageTitle.="Edit Order";
        $slopDivContent=($order_num)?ord_editOrderForm($order_num):"Invalid order Number $order_num.  Unable to edit.";
        $sideBarContent=ord_editSideBar($order_num);
        $fixedDivHeight='0px';#Only show adjustable window.
        $sidebarDivWidth='200px';#Make as small as can
        $linkJS="j/lib/orders.js";
        $beta=false;
        break;
    case 'cylinderLocations':
        $pageTitle="Current Cylinder Locations";
        $sideBarContent=cl_getSearchFormContent();
        #$adjDivContent=getCylinderLocations();
        $fixedDivHeight='250px';
        #$sidebarDivWidth='200px';
        break;
    case "orders_dev":
        #Order Summary page.
        #See if an order num was passed to preload
        $sideBarContent=ord_getSearchFormContent($order_num);
        $pageTitle.="Orders";
        $fixedDivContent="<br><br><br><br><div style='width:100%;text-align: center;'><div class='title2' style='color:silver'>Order detail</div><div class='title4' style='color:silver'>Click an order below to load details</div></div>";
        $adjOnTop=false;
        $helpText=ord_getHelpText();
        $linkJS="j/lib/orders.js";
        $beta=false;
        $fixedDivHeight='330px';
        break;
    case "fill":
        require_once("j/lib/cylfill.php");
        $pageTitle="Cylinder Fill";
        $sideBarContent=cf_getSearchFormContent();
        $fixedDivHeight='250px';
        $linkJS='j/lib/cylfill.js';
        break;
    default: #Index.php
        $sideBarContent=i_getIndexList();
        $pageTitle="RefGas Manager";
        $fixedDivHeight='0px';#Only show adjustable window.
        $beta=false;
        $showHome=false;
        #reset any saved filter defaults for the orders module every time we go back to the landing page.
        #Actually, don't for now.  It seems to make more sense to never wipe.
        #$t=ord_clearFilterDefaults();
        break;
}

#set the div layout and default content
$adjDiv="<div id='adjHeightContentDiv' style='height:300px;overflow: auto;border:thin solid Silver;min-height:100px;'>$slopDivContent</div>";
$fixDiv="<div id='fixedHeightContentDiv' style='height:$fixedDivHeight;border:thin solid Silver;'>$fixedDivContent</div>";
$spacerDiv="<div style='height:1px;font-size:1px;'>&nbsp;</div>";
$divs=($adjOnTop)?"$adjDiv $spacerDiv $fixDiv":"$fixDiv $spacerDiv $adjDiv";

#Set up the help if needed.
if($helpText){#Load into a dummy div and then set with js below.  We do this so it doesn't flash while screen loads.
    $helpText="<span style='float:left'><button id='i_helpBtn'>Show help</button><div title='Help' id='i_helpDiv'></div><div id='i_helpContents' style='display:none'><div class='helpDialog'>$helpText</div></div></span>";
}
?><!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <meta charset="UTF-8">
    <!--jquery and jquery ui controls-->
    <SCRIPT language='JavaScript' src="j/lib/jquery-1.11.3.min.js"></SCRIPT>
    <SCRIPT language='JavaScript' src="j/lib/jquery-ui-1.11.4/jquery-ui.js"></SCRIPT>
    <LINK rel="stylesheet" type="text/css" href="j/lib/jquery-ui-1.11.4/jquery-ui.css">
    <LINK rel="stylesheet" type="text/css" href="j/lib/jquery-ui-1.11.4/jquery-ui.theme.css">
    <?php #Load some js and css includes.
        echo get_HeaderIncludeText('j/styles.css',"css");#This has to come after the jquery_ui css to override some elements.
        echo get_HeaderIncludeText('j/lib/net.js',"js");
        echo get_HeaderIncludeText('j/lib/dates.js',"js");
        echo get_HeaderIncludeText('j/lib/ajax_handlers.js',"js");
        echo get_HeaderIncludeText('j/lib/index.js',"js");
        #Includes for the dbutils
        echo get_dbutilsHeaderIncludes("$dbutils_dir",true);

        #any others
        if($linkJS)echo get_HeaderIncludeText($linkJS,"js");
        if($linkCS)echo get_HeaderIncludeText($linkCS,"css");

    ?>
    <script language='JavaScript'>
        window.onerror = function (errorMsg, url, lineNumber) {
            alert('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber);
            return false;
        }
    </script>
    <title><?php echo $windowTitle;?></title>
</HEAD>

<body><?php
#$a=NULL;

#if(db_getAuthUserID()!=60){
#echo "<h4>Hi :)  I need to analyze a potential issue before you use this.  I will be in the office today (5.19). Stop by for free chocolate while you wait for RGM to return!<br><br>-John</h4>";exit();
#}
if($html){#error or no module passed.   This will eventually be the index.php default content (listing).
echo $html;
exit();
}
?><div class="page">
<div class='header' style='background: #000000;background: url("<?php echo $dbutils_dir;?>/template/resources/globe3.jpg") no-repeat right, linear-gradient(to right, blue , black 300px);'>
<table class='thinTable' style='margin:5px 5px 5px 5px;'>
    <tr>
	<td><img width="64" height="64" alt="NOAA Logo" src="<?php echo $dbutils_dir;?>/template/resources/noaalogo2.png" style='vertical-align:middle;'></td>
	<td align='right'>&nbsp;<span class='title3'>E</span>arth <span class='title3'>S</span>ystem <span class='title3'>R</span>esearch <span class='title3'>L</span>aboratories<br>
	    <span class='title3'>G</span>lobal <span class='title3'>M</span>onitoring <span class='title3'>L</span>aboratory</td>
    </tr>
</table>
<noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
</div>
<!--<div class='header'>
<img width="64" height="64" alt="NOAA Logo" src="j/images/noaalogo2.png">
	Global Monitoring Laboratory/RefGas Manager
<noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
</div>-->
<div class='content'>
<?php if (db_isDemoServer()){echo "<div class='demo_server'>DEMO SERVER</div>";}?>
<table id='content_table' class='content_table'  border='0'>
    <tr>
	<td valign='bottom'><span><?php echo createMenu2($showHome);?></span></td>
	<td align='center' id='content_table_header' style='padding-right: 5px'><?php if($helpText) echo $helpText;?>
	    <span  id='listTitle' class='title3'><?php echo $pageTitle;?></span> <?php if($beta) echo "<span class='beta'>(beta)</span>";?>
	    <span  style='float:right;'><a href='logout.php'><input type='button' value='Logout' onClick='if ( ! confirm("Are you sure you want to logout?") ) { return false;}'></a></span>
	</td>

    </tr>
    <tr>
	<td width='<?php echo $sidebarDivWidth;?>' valign='top'>
	    <form id='search_form' autocomplete='off' onsubmit='return false;'>
		<input type='hidden' name='mod' id='mod' value='<?php echo $module;?>'>
		<div id='sidebarDiv' style='overflow-y: auto;width:<?php echo $sidebarDivWidth;?>;max-width:<?php echo $sidebarDivWidth;?>;border: thin solid silver;'>
		    <?php echo $sideBarContent;?>
		</div>
                    </form>
                </td>
                <td width='100%' valign='top'>
                    <?php echo $divs;?>
                </td>
            </tr>
        </table>
    </div>
    <div class='footer' style='text-align: center;'>
        <div style='display: inline;float: left;' id='statusDiv'></div>
        <span class='beta'>Questions?  Comments? -> <a href='mailto:john.mund@noaa.gov?subject=New%20Refgas%20Todo%20list'>john.mund@noaa.gov</a> 2D131</span>
        <div style='height:12px; display: inline; float: right;' id='networkActivityDiv'></div>
    </div>
</div>

<script language='JavaScript'>
$(document).ready(function() {//Set anything that needs to happen after form loaded.
    setwindowHeight();//Adjust content divs
    //Generic form handler to load list when form criteria is changed.
    //Any inputs with class 'search_form_auto_submit' will fire this when changed.
    $("#search_form").on("change",".search_form_auto_submit", function(){
        i_loadList();
    });
    //Set up the help dialog.
    <?php
    if($helpText) echo '
    var helpText=$("#i_helpContents").html();//Load from hidden div.
    $("#i_helpDiv").dialog({
       autoOpen:false,
       height:400,
       width:500,
       buttons:{Close:function(){$(this).dialog("close");}},
       open:function(){
            $(this).html($("#i_helpContents").html());
       }

    });
    $("#i_helpBtn").on("click",function(event){
        event.preventDefault();
        $("#i_helpDiv").dialog("open");
    });';
    ?>
    keepAlive();//see net.js for comments.
    <?php echo $onReadyJS;?>
    //$('input').addClass("ui-widget ui-widget-content ui-corner-all ui-textfield");//Didn't work..

});
//Bind logic to the window resize event to set our content div correctly.
$(window).resize(function(){
    setwindowHeight();
});
function setwindowHeight() {
    //Figure out some fixed heights so auto scrolling will work.  What a pia.'
    //Note, we put this function here so it can call php func (below)

    //Set the adjHeightContentDiv div to be the remaining window space.
    var windowh=$(window).height();//innerHeight();//window height
    var headerh=$(".header").outerHeight();//header height
    var footerh=$(".footer").outerHeight();//footer height
    var borderh=$(".content").outerHeight()-$(".content").height();//border height
    <?php
        if (db_isDemoServer()) echo "var demoHeight=20;";
        else echo "var demoHeight=0;";
    ?>
    var fudge=10;//Can't f'n figure out why this is needed.
    var contenth=windowh-headerh-footerh-borderh-fudge;
    $(".content").height(contenth);//Main content area. Make this the remaining height of window minus fixed height stuff (header,footer,buttons & border).
    var contentheaderh=$("#content_table_header").height();//Find height of the content header
    $("#sidebarDiv").height(contenth-contentheaderh-demoHeight+3);//set search td div to it's max height.  This allows a scroll to be used when needed. +3 is to make same as right side's 2 center borders and the spacer div

    //Now get fixed/adj divs area.  There is a fixed size div at bottom and the slop goes to the results area.
    var fixedh=$("#fixedHeightContentDiv").height();
    $("#adjHeightContentDiv").height(contenth-contentheaderh-demoHeight-fixedh);//No buttons on this side.. 10 is slop

    //Do the width too.
    var windoww=$(window).innerWidth();
    $("#adjHeightContentDiv").width(windoww-285);//-search area + some margin.
    $("#fixedHeightContentDiv").width(windoww-285);//-search area + some margin.
    $(".footer").width(windoww-5);//-search area + some margin.
    //setStatusMessage("wh:"+windowh+" hh:"+headerh+" fh:"+footerh+" ch:"+contentheaderh,50,'statusDiv');

}
</script>
</body>
</html>
