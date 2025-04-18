<?php
#Include this file from your index.php (see that template file for details)

$html="";

#db_connect($dbconfig);


#Calculate the relative path for css and js libs if not specified in caller.  Requires webRootDir and $dbutils_relPath
if($dbutils_webPath==''){
    if(!$dbutils_relPath || !$webRootDir){echo 'Configuration error.  index.php and switch.php must specify $webRootDir and $dbutils_relPath to calculate relative path to css and js files.';exit();}
    $a=split("/",str_replace($webRootDir,'',getcwd()));#Strip the web root, then put the rest into an array
    foreach($a as $t){$dbutils_webPath.="../";}#replace each dir with ../ relative specifier
    $dbutils_webPath.=$dbutils_relPath;#Web path is back to root, then the dbutils rel path.
}

##
#Defaults for page layout.  Configure overrides in module switch below.
##background: #000000;
               # background-image: right url(\"$dbutils_webPath/template/resources/globe.jpg\") no-repeat;
#Set some optional variables (added in later iterations)
$onResizeJS=(isset($onResizeFunction))?$onResizeFunction:"";#See if a resize function was passed.

#Put side bar in a form for auto submitting?
$hasSideBarForm=(isset($includeSideBarForm))?$includeSideBarForm:true;

$titleRight=(isset($titleRightContent))?$titleRightContent:"";

#set the div layout and default content
$adjDiv="<div id='adjHeightContentDiv' style='height:300px;overflow: auto;border:thin solid Silver;min-height:100px;'>$slopDivContent</div>";
$fixDiv="<div id='fixedHeightContentDiv' style='height:$fixedDivHeight;border:thin solid Silver;'>$fixedDivContent</div>";
$spacerDiv="<div style='height:1px;font-size:1px;'>&nbsp;</div>";
$divs=($adjOnTop)?"$adjDiv $spacerDiv $fixDiv":"$fixDiv $spacerDiv $adjDiv";

#Set up the help if needed.
if($helpText){#Load into a dummy div and then set with js below.  We do this so it doesn't flash while screen loads.
    $helpText="<span style='float:left'><button id='i_helpBtn'>Show help</button><div title='Help' id='i_helpDiv'></div><div id='i_helpContents' style='display:none'><div class='helpDialog'>$helpText</div></div></span>";
}

#Set up the logo background image
#$logoBackground="<div class='header' style='background: #000066 url(\"$dbutils_webPath/template/resources/globe_top.png\") no-repeat ;'>";
$logoBackground="background: #000000;background: url(\"$dbutils_webPath/template/resources/globe3.jpg\") no-repeat right, linear-gradient(to right, blue , black 300px);";

#Include map library?
$mapIncludes=(isset($includeMapLib))?$includeMapLib:false;

?><!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <meta charset="UTF-8">
    <!--jquery and jquery ui controls-->
    <SCRIPT language='JavaScript' src="<?php echo $dbutils_webPath;?>/js/jquery-1.11.3.min.js"></SCRIPT>
    <SCRIPT language='JavaScript' src="<?php echo $dbutils_webPath;?>/js/jquery-ui-1.11.4/jquery-ui.js"></SCRIPT>
    <LINK rel="stylesheet" type="text/css" href="<?php echo $dbutils_webPath;?>/js/jquery-ui-1.11.4/jquery-ui.css">
    <LINK rel="stylesheet" type="text/css" href="<?php echo $dbutils_webPath;?>/js/jquery-ui-1.11.4/jquery-ui.theme.css">
    <?php #Load some js and css includes.
        echo get_HeaderIncludeText("$dbutils_webPath/template/resources/styles.css","css");#This has to come after the jquery_ui css to override some elements.
        echo get_HeaderIncludeText("$dbutils_webPath/js/net.js","js");
        echo get_HeaderIncludeText("$dbutils_webPath/js/ajax_handlers.js","js");
        echo get_HeaderIncludeText("$dbutils_webPath/js/index.js","js");
        echo get_HeaderIncludeText("$dbutils_webPath/js/validation.js","js");

        #Includes for the dbutils
        echo get_dbutilsHeaderIncludes("$dbutils_webPath",true,$mapIncludes);

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
    <?php echo $otherHeaderContent;?>
</HEAD>

<body><?php
if($html){#error or no module passed.   This will eventually be the index.php default content (listing).
    echo $html;
    exit();
}
?><div class="page">
    <div class='header' style='background: #000000;background: url("<?php echo $dbutils_webPath;?>/template/resources/globe3.jpg") no-repeat right, linear-gradient(to right, blue , black 350px);'>
        <table class='thinTable' style='margin:5px 5px 5px 5px;'>
            <tr>
                <td><img width="64" height="64" alt="NOAA Logo" src="<?php echo $dbutils_webPath;?>/template/resources/noaalogo2.png" style='vertical-align:middle;'></td>
                <td align='right'>&nbsp;<span class='title3'>E</span>arth <span class='title3'>S</span>ystem <span class='title3'>R</span>esearch <span class='title3'>L</span>aboratories<br>
                    <span class='title3'>G</span>lobal <span class='title3'>M</span>onitoring <span class='title3'>L</span>aboratory</td>
            </tr>
        </table>
        <noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
    </div>
    <div class='content'>
        <?php if (db_isDemoServer()){echo "<div class='demo_server'>DEMO SERVER</div>";}?>
        <table id='content_table' class='content_table'  border='0'>
            <tr>
                <td valign='bottom'><span class='title3'><?php echo($sidebarTitle);?></span></td>
                <td align='center' id='content_table_header' style='padding-right: 5px'><?php if($helpText) echo $helpText;?>
                    <span  id='listTitle' class='title3'><?php echo $pageTitle;?></span> <?php if($beta) echo "<span class='beta'>(beta)</span>";?>
                    <span  style='float:right;'><?php echo $titleRight;?><!--<a href='logout.php'><input type='button' value='Logout' onClick='if ( ! confirm("Are you sure you want to logout?") ) { return false;}'></a>--></span>
                </td>

            </tr>
            <tr>
                <td width='<?php echo $sidebarDivWidth;?>' valign='top'>
                    <?php if($hasSideBarForm) echo "
                        <form id='search_form' autocomplete='off' onsubmit='return false;'>
                        <input type='hidden' name='mod' id='mod' value='$module'>";?>
                        <div id='sidebarDiv' style='overflow-y: auto;width:<?php echo $sidebarDivWidth;?>;max-width:<?php echo $sidebarDivWidth;?>;border: thin solid silver;'>
                            <?php echo $sideBarContent;?>
                        </div>
                    <?php if($hasSideBarForm) echo "</form>";?>
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
</div><div class='hidden' id='dbutils_js_div'>dbutils_js_div</div>
<script language='JavaScript'>
$(document).ready(function() {//Set anything that needs to happen after form loaded.
    setwindowHeight();//Adjust content divs
    <?php echo "$onResizeJS;";?>//and any user defined resizes
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
});
//Bind logic to the window resize event to set our content div correctly.
$(window).resize(function(){
    setwindowHeight();
    <?php echo "$onResizeJS;"?>
});
function changeFixedDiveHeight(height){
    //Update the fixed div height and reflow everything.
    //pass height with px: '100px'
    $('#fixedHeightContentDiv').height(height);
    setwindowHeight();
}
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
    var searchWidth=$("#sidebarDiv").outerWidth();
    $("#adjHeightContentDiv").width(windoww-searchWidth-10);//-search area + some margin.
    $("#fixedHeightContentDiv").width(windoww-searchWidth-10);//-search area + some margin.
    $(".footer").width(windoww-5);//-search area + some margin.
    //setStatusMessage("wh:"+windowh+" hh:"+headerh+" fh:"+footerh+" ch:"+contentheaderh,50,'statusDiv');

}
</script>
</body>
</html>














