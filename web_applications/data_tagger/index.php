<?php
#echo phpinfo();exit;
require_once("./lib/funcs.php");
require_once("./lib/html_funcs.php");
#echo phpinfo();exit;

#Do some gymnastics to get the include dir.  This is an issue because the dev site is in a subdir.. argh.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/dt")?"../inc/dbutils":"../../inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
db_connect("./lib/config.php");
#session_start();
#session_write_close(),

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
  
    <!--Put this one after jquery-ui to override some elements-->    
    <LINK rel="stylesheet" type="text/css" href="styles.css?ver=<?php echo filemtime('styles.css');?>">
        
    <!--All our jquery/ajax and ui js-->
    
    <script language='JavaScript' src="lib/net.js?ver=<?php echo filemtime('lib/net.js');?>"></script>
    <script language='JavaScript' src="lib/ajax_handlers.js?ver=<?php echo filemtime('lib/ajax_handlers.js');?>"></script>   
    <script language='JavaScript' src="lib/index.js?ver=<?php echo filemtime('lib/index.js');?>"></script>
    <script language='JavaScript' src="lib/dates.js?ver=<?php echo filemtime('lib/dates.js');?>"></script>
    <script language='JavaScript' src="lib/rangeCriteriaFuncs.js?ver=<?php echo filemtime('lib/rangeCriteriaFuncs.js');?>"></script>
    <script language='JavaScript' src="lib/plotHandlers.js?ver=<?php echo filemtime('lib/plotHandlers.js');?>"></script>
    
    <!--<script language="JavaScript" src="lib/dates.js"></script>-->
    <?php echo get_dbutilsHeaderIncludes("$dbutils_dir");?>
    <script language='JavaScript'>
        window.onerror = function (errorMsg, url, lineNumber) {
            alert('Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber);
            return false;
        }
        
        
    </script>
    <title>Data Tagger</title>
</HEAD>

<body>
<div class="page">
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
        <img width="64" height="64" alt="NOAA Logo" src="images/noaalogo2.png">		
                Global Monitoring Division/Data Tagger            
        <noscript><h2>This site requires that JavaScript be enabled in your browser to properly function.</h2>Please enable JavaScript in your browser settings and then reload the page.<br><br></noscript>
    </div>-->
    <?php
            if (db_isDemoServer()){
                echo "<div style='width:99%;background:pink;border:thin black solid;text-align:center;'>DEMO SERVER</div>";
            }
    ?>
    <div class='content'>
        
        <table id='content_table' style='width: 100%' border='0'>
            <tr>
                <td valign='bottom'><span class='title3' id='content_table_header'>Selection</span><?php echo helpLink("Data Selection"); ?></td>
                <td align='center'><span  class='title3'>Data</span><?php echo helpLink("Data"); ?>
                    <span style='float:right'>
                        <button id='showStatsButton' value='Datasets' disabled>Datasets</button><!--jwm 4/23 turned off after converting magicc (Molly request)-->
                        <div id='statisticsDiv' style='display: inline;'></div>
                        <?php
                        $js="<script language='JavaScript'>
                                $(\"#showStatsButton\").click(function(event){
                                    event.preventDefault();
                                    ajax_get('getStatistics','','statisticsDiv',search_ajax_request);
                                });
                            </script>";
                        echo $js;
                    ?></span>
                </td>
            </tr>
            <tr>
                <td width='275px' valign='top'>
                    <form id='data_selection' action='' autocomplete='off'>
                    <div id='search_container' style='overflow-y: auto;width:275px;max-width:275px;border: thin solid silver;'>       
                        
                        <div id='search_accordion' style='min-width: 250px;'>
                            <h3>Specific ID/Num<div class='filter_descs' id='id_filter_desc'></div></h3>
                            <div width='100%' >
                                <table width='100%'>
                                    <tr>
                                        <td class='label'>Event number: </td><td><input size='10' class='search_field id_field' id='ev_event_num' name='ev_event_num' type='text'></input></td>
                                    </tr>
                                    <tr>
                                        <td class='label'>Flask ID: </td><td><input size='10' class='search_field id_field' id='ev_flask_id' name='ev_flask_id' type='text'></input></td>
                                    </tr>
                                    <tr>                                        
                                        <td class='label'>Analysis number: </td><td><input size='10' class='search_field id_field' id='d_data_num' name='d_data_num' type='text' value=''></input></td>
                                    </tr>
                                    <!-- Not sure what this should return, so holding off for now.  Can still pass range_num on url though
                                        Danger will robinson!  var name conflict with range_num.  If decide to use, change to search_range_num or similar and then update funcs.php buildQueryBase  to pull that.
                                        I had left this in the criteria and just commented here. That caused it to get included in the critera array when used to pass the range_num by the criteria                                            edit func which caused mass havoc (canEdit critera array=false).  I changed there, leaving this for info.
                                    <tr>                                        
                                        <td class='label'>Range number: </td><td><input size='10' class='search_field id_field' id='range_num' name='range_num' type='text' value=''></input></td>
                                    </tr>-->
                                    <tr><td colspan='2' align='right'><a class='sm_data' href='#' onClick="JavaScript:clearFields('id');return false;">Clear</a></td></tr>
                                </table>                            
                            </div>
                            <h3>Sample event details<div class='filter_descs' id='ev_filter_desc'></div></h3>
                            <div>
                                <table width='100%'>
                                    <tr>
                                        <td class='label'>Site code:</td>
                                        <td>
                                           <?php echo getAutoCompleteHTML("ev_site_num","ev");?>
                                        </td>
                                    </tr>
                                    <?php echo getSelectmenuHTML("ev_project_num","Project","ev");?>
                                    <?php echo getSelectmenuHTML("ev_strategy_num","Strategy","ev");?>
                                    <?php
                                    //echo getRangeHTML("ev_sDate","ev_eDate","Sample date","ev",10);
                                    echo getDateRangeHTML("ev","Event date",true);
                                    echo getTimeRangeHTML("ev_sTimewindow","ev_eTimewindow","ev_notTimewindow","Sample window","ev");
                                    ?>
                                    
                                    <tr><td colspan='2'><input name='ev_inloop' id='ev_inloop' class='search_field ev_field' type='checkbox' >Flasks in Analysis Loop</input></td></tr>
                                    <?php echo getRangeHTML("ev_from_lat","ev_to_lat","Latitude","ev");
                                    echo getRangeHTML("ev_from_lon","ev_to_lon","Longitude","ev");
                                    echo getRangeHTML("ev_from_alt","ev_to_alt","Altitude","ev");
                                    echo getRangeHTML("ev_from_elev","ev_to_elev","Elevation","ev");
                                    ?>
                                    <tr>
                                        <td  class='label' style='text-align: left;'>Comment:<div class='tiny_data'>(% is wildcard)</div></td>
                                        <td><input class='search_field ev_field' id='ev_comment' name='ev_comment' type='text'></input></td></tr>
                                    </tr>
                                    <tr>
                                        <td class='label'>Method: </td>
                                        <td><input size='5' class='search_field ev_field' id='ev_method' name='ev_method' type='text'></input></td>
                                    </tr>
                                    <tr><td colspan='2' align='right'><a class='sm_data' href='#' onClick="JavaScript:clearFields('ev');return false;">Clear</a></td></tr>
                                </table>
                            </div>
                            <h3>Analysis details<div class='filter_descs' id='d_filter_desc'></div></h3>
                            <div>
                                <table>
                                    <?php echo getSelectmenuHTML("d_program_num","Program","d");
                                    echo getSelectmenuHTML("d_parameter_num","Parameter","d",'',true,6,"Parameter Selection");
                                    echo getSelectmenuHTML("d_inst","Instrument","d");
                                    
                                    echo getRangeHTML("d_sunc","d_eunc","Uncertainty","d");
                                    //echo getRangeHTML("d_sDate","d_eDate","Meas. date","d",10);
                                    echo getDateRangeHTML("d","Analysis date");
                                    ?>
                                    <tr>
                                         <td  class='label' style='text-align: left;'>Meas. comment:<div class='tiny_data'>(% is wildcard)</div></td>
                                            <td><input class='search_field d_field' id='d_comment' name='d_comment' type='text'></input></td></tr>
                                    </tr>
                                    <tr>
                                            <td colspan='2' align='right'>
                                                <span style='float:left';><input name='d_plot' id='d_plot' type='checkbox' >Plot results</input></span>
                                                <a class='sm_data' href='#' onClick="JavaScript:clearFields('d');return false;">Clear</a>
                                            </td>
                                    </tr>
                                </table>
                            </div>
                            <h3>Existing tag<div class='filter_descs' id='tag_filter_desc'></div></h3>
                            <div>
                                <table>
                                   <?php
                                    echo getSelectmenuHTML("ev_tag_num","Event tag","tag");
                                    echo getSelectmenuHTML("d_tag_num","Aliquot tag","tag");
                                    /*echo "<tr><td colspan='2'><br>...or how about these searchable ones Molly:</td></tr>
                                        <tr><td colspan='2' class='title'>Event tag:</td></tr>
                                        <tr><td colspan='2'>".getAutoCompleteHTML("ev_tag_num",'tag',30)."</td></tr>
                                        <tr><td colspan='2' class='title'>Aliquot tag:</td></tr>
                                        <tr><td colspan='2'>".getAutoCompleteHTML("d_tag_num",'tag',30)."</td></tr>";
                                     */   
                                    ?>
                                    <tr><td colspan='2'><input name='tag_prelim' id='tag_prelim' class='search_field tag_field' type='checkbox' >Preliminary Tags</input></td></tr>
                                    <tr><td colspan='2' align='right'><a class='sm_data' href='#' onClick="JavaScript:clearFields('tag');return false;">Clear</a></td></tr>
                                </table>
                            </div>
                            <h3>Specialized tag/data viewers</h3>
                            <div><br><a href='./review/?mod=ccg_aircraft' target='_new'>Automated aircraft tag viewer</a><br>
                                <i>Tags automatically created using statistical analysis and QA from the HATS program.</i><br>
                            <br><a href='./review/?mod=plotView' target='_new'>Plotting program for measurements</a><br>
                                <i>Select and plot data on demand</i><br>
                            </div>
                        </div>
                        
                    </div>
                    
                    <div id='searchBtnDiv' style='display:inline;float:right;'><br>
                        <button type='submit' id='searchButton'>Search</button>
                        <button id='resetButton'>Reset</button>
                        <button style='float:left;' id='cancelCriteriaSubmitButton'>Cancel</button>
                        <button id='submitCriteriaEditButton'>Submit new filter criteria for range</button></div>
                    <input type='hidden' id='rangeCriteriaEditRangeNum' value=''>    
                    </form>  
                </td>
                <td style='border:thin solid Silver;' width='100%' valign='top'>
                    <div id='tagList' style='height:330px'>
                        <table width='100%'><tr><td align='center'><br><br><br><br>
                        <h2 style='color: lightgrey;'>No Selection</h2><div style='color:grey'>Use the criteria on the left to select data set.</div></td></tr></table>
                    </div><?php #This height can be changed and below will take slop.  See index.js setwindowHeight() for details.?>
            
                    <div id='searchResults' style='height:300px;overflow: auto;border:thin inset Silver;min-height:100px;'></div>
                    
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
<?php 
//Preload a row?
$loadDataNum=getHTTPVar("data_num",'',VAL_INT);

if($loadDataNum){
    echo "<script>
        $('#d_data_num').val($loadDataNum).change();
        setTimeout(\"doSearch();\",500);
    </script>";
}

?>













