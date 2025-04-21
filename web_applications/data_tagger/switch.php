<?php
ini_set("error_log","/var/www/html/mund/datatagger/log/php_err.log");

#Do some gymnastics to get the include dir.  This is an issue because the dev site is in a subdir.. argh.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/dt")?"../inc/dbutils":"../../inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
require_once("lib/funcs.php");
require_once("./lib/html_funcs.php");
require_once("./lib/review_funcs.php");
db_connect("lib/config.php");


$html="";
session_start();
//Get/set any user preferences and session level items.

session_write_close();

#Fetch out some common params that may or may not present for use below
$event_num=getHTTPVar("event_num","",VAL_INT);
$data_num=getHTTPVar("data_num","",VAL_INT);
$range_num=getHTTPVar("range_num","",VAL_INT);
$tag_num=getHTTPVar("tag_num","",VAL_INT);
        

$doWhat=getHTTPVar("doWhat","",VAL_STRING);
#var_dump($doWhat); exit;
switch($doWhat){
    case "doSearch":
        $html=doSearch();
        break;
    case "getTagList":
        $v=getHTTPVar("getTagListversion",false,VAL_INT);
        if($v==2)$html=getTagList2($event_num,$data_num);#Special case to load old one.
        else $html=getTagList3($event_num,$data_num);
        break;

    case "getSelectMenuOptions":        
        $targetSelectID=getHTTPVar("targetSelectID");
        $filter=getHTTPVar("filter","0",VAL_INT);
        if($targetSelectID)$html=getSelectMenuOptions($targetSelectID,$filter);
        else $html="<option>Error; invalid select id</option>";
        break;
    case "getTagRangeDetails":
        if($range_num)$html=getRangeDetails($range_num);
        break;
    case "getTagEditForm":
        $range_num=getHTTPVar("range_num","",VAL_INT);#Might be blank for add mode.
        $edit_mode=getHTTPVar("edit_mode");
        $event_num=getHTTPVar("event_num","",VAL_INT);#may or may not be present (add mode relevant)
        $data_num=getHTTPVar("data_num","",VAL_INT);#may or may not be present (add mode relevant)
        $html= getTagEditForm($range_num,$edit_mode,$event_num,$data_num);
        break;
    /*case "getDataTagEditForm":
        $tagID=getHTTPVar("tagID","",VAL_INT);
        $data_num=getHTTPVar("data_num","",VAL_INT);
        $event_num=getHTTPVar("event_num","",VAL_INT);
        $baseQueryHash=getHTTPVar("baseQueryHash");
        $edit_mode=getHTTPVar("edit_mode");
        $html= getDataTagEditForm($tagID,$event_num,$data_num,$baseQueryHash,$edit_mode);
        break;*/
    case "submitTagEdit":
        $html=submitTagEdit();
        break;
    case "getTeditSeverityInput":
        $html=getTagSeverityFormHTML($tag_num,true);
        break;
    case "submitEvEditForm":
        $html=submitEvEditForm();
        break;
    case "getRangeCriteriaEditDetails":
        $html=getRangeCriteriaEditDetails($range_num);
        break;
    case "submitTagRangeCriteriaEdit":
        $html=submitTagRangeCriteriaEdit($range_num);
        break;
    case "getEventsForRange":
        $html=getEventsForRange($range_num);
        break;
    case "getDataForRange":
        $html=getDataForRange($range_num);
        break;
    case "keepAlive":
        $html="Keep alive pinged at: ".date("h:i a");
        sleep(5);
        break;
    case "getDataForEvent":
        $html=getDataForEvent($event_num,$range_num);
        break;
    /*review.php functions*/
    case "rev_getTaggedEventList":
        require_once("./lib/review_funcs.php");
        #function rev_getTaggedEventList($tag_num,$project_num="",$program_num="",$strategy_num="",$parameter_num="",$site_num="",$preliminary=0){
        $tag_num=getHTTPVar('rev_tags','',VAL_INT);
        $program_num=getHTTPVar("d_program_num","",VAL_INT);
        $project_num=getHTTPVar("ev_project_num","",VAL_INT);
        $strategy_num=getHTTPVar("ev_strategy_num","",VAL_INT);
        $prelim=getHTTPVar("tag_prelim",0,VAL_BOOLCHECKBOX);
        $site_num=getHTTPVar("ev_site_num","");
        $html=rev_getTaggedEventList($tag_num,$project_num,$program_num,$strategy_num,'',$site_num,$prelim);
        break;
    case "rev_getEventPlot":
        $rev_mode=getHTTPVar("rev_mode");
        $html=rev_getEventPlot($range_num,$rev_mode);
        #$html=rev_getAATPlotArea($range_num);
        break;
    case "rev_getRangeEditForm":
        $rev_mode=getHTTPVar("rev_mode");
        $html=rev_getRangeEditForm($range_num,$rev_mode);
        break;
    case "rev_submitTagEdit":
        #We need to submit twice (once for comment append, once for tag change/prelimi change);
        $comment=true;#forcing comment everytime.... see submitTagEdit for details. getHTTPVar("tagEdit_comment");
        $continue=true;        
        $html=submitTagEdit("rev_editForm","","edit");
        $continue=(substr($html,0,1)=="1");#Only continue if the append was successful.  Otherwise we'll just return the error.
        if($comment && $continue){
            $html=submitTagEdit("rev_editForm","","append");            
        }
        break;
    case "getEventPopup":#NOT Finished... for plot click handler
        getEventDetails($event_num,$data_num);
        break;
    case "rev_profilePlots":
        $html=rev_profilePlots($event_num);
        break;
    case "rev_profilePlot":
        #$event_num=getHTTPVar("event_num","",VAL_INT); #done above
        $parameter_num=getHTTPVar("parameter_num","",VAL_INT);
        if($event_num && $parameter_num)$html=rev_profilePlot($event_num,$parameter_num);
        break;
    case "rev_getTableSummary":
        //$html=rev_getTableSummary($)
        break;
    case "rev_dynLoadSinglePlotsData":
        $html=rev_dynLoadSinglePlotsData();
        break;
    case "rev_getSinglePlots":
        $html=rev_getSinglePlots($range_num);
        break;
    
    /*Download.php functions*/
    case "downloadSearch":
        $rowLimit=getHTTPVar("rowLimit",-1,VAL_INT);
        $html=doSearch($rowLimit,'download');
        break;
    
    /*Stats*/
    case "getStatistics":
        $html=getStatistics();
        break;
}

#ini_set("zlib.output_compression","On");#did work, probably no zlib installed..
ob_start("ob_gzhandler");
echo $html;
exit();

?>