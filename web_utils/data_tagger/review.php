<?php
#This page was initially created to review & confirm/change auto generated tags for the aircraft data.
#I left it generic so we can adapt easily for others if desired.
#Note it only shows data tags, no event tags.

require_once("./lib/funcs.php");
require_once("./lib/html_funcs.php");
require_once("./lib/review_funcs.php");
#echo phpinfo();exit;

#Do some gymnastics to get the include dir.  This is an issue because the dev site is in a subdir.. argh.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/dt")?"../inc/dbutils":"../../inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
db_connect("./lib/config.php");
#session_start();
#session_write_close(),


$description="";$project_num="";$program_num="";$strategy_num="";$parameter_num="";$site_num="";$selectedTagNum="";$preliminary=0;

$mode=getHTTPVar("mode");
switch($mode){
    #Set some defaults and labels
    case "aat":
        $description="Review automated aircraft tags";
        $project_num=2;#ccg_aircraft
        $program_num=1;#ccgg
        $selectedTagNum=97;
        $preliminary=1;
        break;
    default:
        $description="Review existing data tags";
        break;
}

?><!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <meta charset="UTF-8">
    <!--jquery and jquery ui controls-->
    <SCRIPT language='JavaScript' src="lib/jquery-1.11.3.min.js"></SCRIPT>
    <SCRIPT language='JavaScript' src="lib/jquery-ui-1.11.4/jquery-ui.js"></SCRIPT>
    

    <LINK rel="stylesheet" type="text/css" href="lib/jquery-ui-1.11.4/jquery-ui.css">
    <LINK rel="stylesheet" type="text/css" href="lib/jquery-ui-1.11.4/jquery-ui.theme.css">
  
    
        
    <!--All our jquery/ajax and ui js  This is index.php links.. leaving for reference.
    

    <script language='JavaScript' src='lib/rangeCriteriaFuncs.js'></script>
    <script language='JavaScript' src='lib/plotHandlers.js'></script><script language='JavaScript' src='lib/net.js'></script>
    <script language='JavaScript' src='lib/dates.js'></script>
    <script language='JavaScript' src='lib/ajax_handlers.js'></script>   
    <script language='JavaScript' src='lib/review.js'></script>
    -->
    <?php
    echo get_HeaderIncludeText('styles.css',"css");#This has to come after the jquery_ui css to override some elements.
    echo get_HeaderIncludeText('lib/net.js',"js");
    echo get_HeaderIncludeText('lib/dates.js',"js");
    echo get_HeaderIncludeText('lib/ajax_handlers.js',"js");
    echo get_HeaderIncludeText('lib/review.js',"js");
    
    ?>
   
    
    
    
    <!--<script language="JavaScript" src="lib/dates.js"></script>-->
    <?php echo get_dbutilsHeaderIncludes("$dbutils_dir");?>
    <script language='JavaScript'>
        window.onerror = function (errorMsg, url, lineNumber) {
            alert('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber);
            return false;
        }
        
        
    </script>
</HEAD>
<title>Data Tagger</title>
<body>
<div class="page">
    <div class='header'>
        <img width="64" height="64" alt="NOAA Logo" src="images/noaalogo2.png">		
                Global Monitoring Division/Data Tagger            
        <noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
    </div>
    <?php
            if (db_isDemoServer()){
                echo "<div style='width:99%;background:pink;border:thin black solid;text-align:center;'>DEMO SERVER</div>";
            }
    ?>
    <div class='content'>
        
        <table id='content_table' style='width: 100%' border='0'>
            <tr>
                <td valign='bottom'><span class='title3' id='content_table_header'><?php echo $description;?></span></td>
                <td align='center'><span  class='title3'></td>
            </tr>
            <tr>
                <td width='275px' valign='top'>
                    <form id='data_selection' action='' autocomplete='off'>
                        <input type='hidden' id='rev_mode' name='rev_mode' value='<?php echo $mode;?>'>
                        <div id='search_container' style='overflow-y: auto;width:275px;max-width:275px;border: thin solid silver;'>       
                            <h3>Select tagged event</h3>
                            
                            <div>
                                <table width='100%'>
                                    <tr>
                                        <td class='label'>Tag:</td>
                                        <td>
                                            <?php echo rev_getTags($project_num,$program_num,$strategy_num,$parameter_num,$selectedTagNum,$mode,'175px','rev_tags','rev_itemSelected',true,true);?>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td>
                                            <?php echo getCheckBoxInput('tag_prelim','Preliminary',$preliminary,'rev_itemSelected'); ?>                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan='2'>
                                            <?php echo  rev_getTaggedEventList($selectedTagNum,$project_num,$program_num,$strategy_num,$parameter_num,$site_num,$preliminary);?>        
                                        </td>
                                    </tr>                                    
                                    <tr>
                                        <td class='label'>Site code:</td>
                                        <td>
                                            <?php echo getAutoCompleteHTML("ev_site_num","ev",3,'','search_field',false,'rev_itemSelected');?>
                                        </td>
                                    </tr>
                                    <?php echo getSelectmenuHTML("ev_project_num","Project","rev",'',false,1,'','rev_itemSelected',$project_num);?>
                                    <?php echo getSelectmenuHTML("ev_strategy_num","Strategy","rev",'',false,1,'','rev_itemSelected',$strategy_num);?>
                                    <?php echo getSelectmenuHTML("d_program_num","Program","rev",'',false,1,'','rev_itemSelected',$program_num);?>
                                    
                                </table>
                            </div>
                            <a href='index.php' style='float:left'>Back</a>   
                        </div>
                     
                    </form>  
                </td>
                <td style='border:thin solid Silver;' width='100%' valign='top'>
                    <div id='dataDiv' style='height:300px;overflow: auto;border:thin inset Silver;min-height:100px;'>
                        <table width='100%'><tr><td align='center'><br><br><br><br>
                        <h2 style='color: lightgrey;'>Plot Area</h2><div style='color:grey'>Use the criteria on the left to select data set.</div></td></tr></table>
                    </div><?php #See js function below for sizing.. this one is dynamic slop?>
                    <div id='detailDiv' style='height:200px'></div>
                </td>
            </tr>
        </table>
        
       
    </div>
    <div class='footer'>
        <div style='display: inline;float: left;' id='statusDiv'></div>
        <div style='height:12px; display: inline; float: right;' id='networkActivityDiv'></div>
    </div>
</div>

</body>
</html>
<script language='JavaScript'>
<?php
    
         
?>

$(document).ready(function() {
    setwindowHeight();
});
//Bind logic to the window resize event to set our content div correctly.
$(window).resize(function(){
    setwindowHeight();
    //If the dataPlotVar exists, resize it to match the new space available.
    if(typeof searchResultsPlotVar !== 'undefined'){
        searchResultsPlotVar.resize();
        searchResultsPlotVar.setupGrid();
        searchResultsPlotVar.draw();
    }
});
function setwindowHeight() {
    //Figure out some fixed heights so auto scrolling will work.  What a pia.
    //Set the content div to be the remaining window space.
    //var height=$(window).innerheight()-$(".header").;
    var windowh=$(window).innerHeight();//window height
    var headerh=$(".header").outerHeight();//header height
    var footerh=$(".footer").outerHeight();//footer height
    var borderh=$(".content").outerHeight()-$(".content").height();//border height
    var buttonH=$("#searchBtnDiv").outerHeight();//button height for search area
    
    var contenth=windowh-headerh-footerh-borderh-30-buttonH;
    $(".content").height(contenth);//Main content area. Make this the remaining height of window minus fixed height stuff (header,footer,buttons & border).
    var contentheaderh=$("#content_table_header").height();//Find height of the content header
    $("#search_container").height(contenth-contentheaderh);//set search td div to it's max height.  This allows a scroll to be used when needed.
    
    //Now get the results area.  There is a fixed size div at bottom and the slop goes to the results area.
    var detailh=$("#detailDiv").height();
    $("#dataDiv").height(contenth-contentheaderh-detailh+buttonH-10);//No buttons on this side.. 10 is slop
    
    //Do the width too.
    var windoww=$(window).innerWidth();
    $("#dataDiv").width(windoww-300);//-search area + some margin.
    $("#detailDiv").width(windoww-300);//-search area + some margin.
    
}
</script>















