<?php
require_once("./j/lib/todo_list_funcs.php");
require_once "menu_utils.php";
#Dan's code
require_once "CCGDB.php";
require_once "DB_UserManager.php";
require_once "utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
if($user_obj){
    $userID=$user_obj->getNum();
    ValidateAuthentication($database_object, $user_obj);
    #See comments in index(2).php and switch.php for below sess var.
    $_SESSION['i_userValidated']=true;
    session_write_close();
}else{
    session_write_close();
    include('login.php');
    exit();
}

#Do some gymnastics to figure out where we're calling from so we can link to db lib.. need relative path for css link.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/rgm")?"../inc/dbutils":"../../inc/dbutils";

require_once("$dbutils_dir/dbutils.php");
db_connect("./j/lib/config.php");
#session_start();
#session_write_close(),
$cs_num=getHTTPVar("cs_num","",VAL_INT);

$helpText="<span style='float:left'><button id='i_helpBtn'>Show help</button><div title='Help' id='i_helpDiv'></div><div id='i_helpContents' style='display:none'><div class='helpDialog'>".tl_getHelpText()."</div></div></span>";


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
  
    
    <?php
        echo get_HeaderIncludeText('j/styles.css',"css");#This has to come after the jquery_ui css to override some elements.
        echo get_HeaderIncludeText('j/lib/net.js',"js");
        echo get_HeaderIncludeText('j/lib/dates.js',"js");
        echo get_HeaderIncludeText('j/lib/ajax_handlers.js',"js");
        echo get_HeaderIncludeText("j/lib/todo_list2.js");
        echo get_HeaderIncludeText('j/tl_styles.css','css');
        
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
<title>RefGas Manager</title>
<body>
<div class="page">
    <div class='header'>
        <img width="64" height="64" alt="NOAA Logo" src="j/images/noaalogo2.png">		
                Global Monitoring Division/RefGas Manager       
        <noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
    </div>
    <div class='content'>
        <?php if (db_isDemoServer()){echo "<div class='demo_server'>DEMO SERVER</div>";}?>
        <table id='content_table' class='content_table'  border='0'>
            <tr>
                <td valign='bottom'><span><?php echo createMenu2();?></span></td>
                <td align='center'  id='content_table_header'><?php echo $helpText;?>
                    <span  class='title3'>Todo List - <span id='tl_species_div'></span></span>
                    <span  style='float:right;'><a href='logout.php'><input type='button' value='Logout' onClick='if ( ! confirm("Are you sure you want to logout?") ) { return false;}'></a></span>
                </td>
            </tr>
            <tr>
                <td width='275px' valign='top'>
                        <form id='search_container_form' autocomplete='off'>
                        <div id='search_container' style='overflow-y: auto;width:275px;max-width:275px;border: thin solid silver;'>       
                           <div>
                                <table width='100%'>
                                    <tr>
                                        <td class='label'>Cal Service:</td>
                                        <td>
                                          <?php
                                             bldsql_init();
                                             bldsql_col("c.num as value");
                                             bldsql_col("c.abbr as display_name");
                                             bldsql_from("calservice c");
                                             bldsql_from("calservice_user u");
                                             bldsql_where("u.contact_num=?",$userID);
                                             bldsql_where("u.calservice_num=c.num");
                                             bldsql_orderby("c.num");
                                             $a=doquery();
                                             if($a){
                                                if(!$cs_num){#If no cs_num passed, select the first available row
                                                    $cs_num=$a[0]["value"];
                                                }
                                                echo getSelectInput($a,'tl_calservice_select',$cs_num,"tl_calservice_select_changed",false,'175px',false);
                                             }else echo"Sorry, you are not configured to see any todo lists.";
                                             #Build an array of sort options so we can use same select maker
                                             $a=array(array('value'=>1, 'display_name'=>"Sort#, Cylinder"),array('value'=>2, 'display_name'=>"Sort#, Order#, Cylinder"),array('value'=>3, 'display_name'=>"&darr;Last cal date, Order#, Cylinder"),array('value'=>4, 'display_name'=>"&uarr;Last cal date, Order#, Cylinder"));
                                             $sortBy=getSelectInput($a,'tl_calservice_sort_mode',1,"tl_loadList",false,'175px',false);
                                          ?>
                                        </td>
                                    </tr>                                  
                                    <tr>                                       
                                        <td colspan='2' align='right'><div id='tl_showAddlSpeciesDiv'><input class='tl_checkBoxOptions' checked type='checkbox' id='tl_showAddlSpecies' name='tl_showAddlSpecies'><label for='tl_showAddlSpecies' id='tl_showAddlSpecies_label'>Include ch4</label></input></div></td>
                                    </tr>
                                    <tr>                                       
                                        <td colspan='2' align='right'><input class='tl_checkBoxOptions' type='checkbox' id='tl_extraCols' name='tl_extraCols'>Show extra columns</input><br><br></td>
                                    
                                    </tr>
                                    <tr><td class='label'>Order by:</td><td><?php echo $sortBy;?></td></tr>
                                    <tr><td colspan='2' align='right'>Reload/Resort list &nbsp;<button style='font-size:16px' onclick='tl_loadList();return false;'title='Reload list'><img src='j/images/refresh.png' width='12' height='12'/></button></td></tr>
                                    <tr>
                                        <td class='label'>Organization</td>
                                        <td>
                                          <div id='tl_org_select_div'>
                                            <?php echo tl_getOrgSelect($cs_num);?>
                                          </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan='2' align='right'><br><button onclick='printDivTable("dataDiv");return false;' title='Print the currently displayed todo list'>Print list</button></td>
                                    </tr>
                                    <tr><td colspan='2'><br><hr style='width:50%;'><br><span class='title4'>Select rows with:</span></td></tr>
                                    <!--<tr>
                                        <td>Cylinder:</td>
                                        <td><input type='text' size='15' onchange='tl_selectBySearch(this.value,"Cylinder");'></td>
                                    </tr>-->
                                    <tr>
                                        <td>Sort num:</td>
                                        <td><input type='text' id='tl_select_sort_num' size='3' onchange='tl_selectBySortNum();'></td>
                                    </tr>
                                    <tr><td colspan='2'><br><div style='border:thin solid silver' id='tl_copyMssgDiv'></div><br><br></td></tr>
                                    <tr>
                                        <td colspan='2' align='right'>Copy checked rows:
                                        <button style='font-size:16px' onclick='tl_copySelected();return false;'title='Copy selected'><img src='j/images/copy-icon.png' width='12' height='12'/></button></td>
                                    </tr>
                                    <tr>
                                        <td colspan='2'>
                                            <textarea rows='5' cols='30' id='tl_copyArea'></textarea>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <br>
                            
                            
                        </div>
                        </form>
                        
                </td>
                <td style='border:thin solid Silver;' width='100%' valign='top'>
                    <div id='dataDiv' style='height:300px;overflow: auto;border:thin inset Silver;min-height:100px;'>
                        <table width='100%'><tr><td align='center'><br><br><br><br>
                        <h2 style='color: lightgrey;'>List area</h2><div style='color:grey'></div></td></tr></table>
                    </div><?php #See js function below for sizing.. this one is dynamic slop, below is fixed height (and has correlated hard coded sizes in todo_list_funcs.php and tl_styles.css) ?>
                    <div id='detailDiv' style='height:250px;border:medium outset Silver;min-width: 800px;width:800px;max-width: 900px;'></div>
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
</body>
</html>
<script language='JavaScript'>

$(document).ready(function() {//Set anything that needs to happen after form loaded.
    setwindowHeight();
    $("#tl_helpDiv").hide();//Start hidden.
    $(".tl_checkBoxOptions").click(function(event){
        tl_loadList();
    });
    //$("#tl_calservice_sort_mode").
    $("#tl_copyArea").hide();//js will show when needed.
    $("#help").click(function(event){
        event.preventDefault();
        $("#tl_helpDiv").toggle();
    });
    keepAlive();//see net.js for comments.
    
    //Set up the help dialog.
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
    });
    
    //Load the list once the page is ready
    tl_calservice_select_changed();
});
//Bind logic to the window resize event to set our content div correctly.
$(window).resize(function(){
    setwindowHeight();
    
});
function setwindowHeight() {
    //Figure out some fixed heights so auto scrolling will work.  What a pia.
    //Set the content div to be the remaining window space.
    //var height=$(window).innerheight()-$(".header").;
    var windowh=$(window).height();//innerHeight();//window height
    var headerh=$(".header").outerHeight();//header height
    var footerh=$(".footer").outerHeight();//footer height
    var borderh=$(".content").outerHeight()-$(".content").height();//border height
    <?php
        if (db_isDemoServer()) echo "var demoHeight=20;";
        else echo "var demoHeight=0;";
    ?>
    var fudge=20;//Can't f'n figure out why this is needed.
    var contenth=windowh-headerh-footerh-borderh-fudge;
    $(".content").height(contenth);//Main content area. Make this the remaining height of window minus fixed height stuff (header,footer,buttons & border).
    var contentheaderh=$("#content_table_header").height();//Find height of the content header
    $("#search_container").height(contenth-contentheaderh-demoHeight);//set search td div to it's max height.  This allows a scroll to be used when needed.
    
    //Now get the results area.  There is a fixed size div at bottom and the slop goes to the results area.
    var detailh=$("#detailDiv").height();
    $("#dataDiv").height(contenth-contentheaderh-demoHeight-detailh);//No buttons on this side.. 10 is slop
    //$("#dataDiv").height(10);
    //Do the width too.
    var windoww=$(window).innerWidth();
    $("#dataDiv").width(windoww-300);//-search area + some margin.
    $("#detailDiv").width(windoww-300);//-search area + some margin.
    //setStatusMessage("wh:"+windowh+" hh:"+headerh+" fh:"+footerh+" ch:"+contentheaderh,50,'statusDiv'); 
    
}
</script>















