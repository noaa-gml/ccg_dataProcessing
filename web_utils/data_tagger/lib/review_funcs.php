<?php
/*Various functions to support the tag review page (for reviewing automated tags).
 *
 *NOTE; these functions all work against flask_data_tag_range (as they are all geared to plotting data points).
 *They ignore event based tags
*/
function rev_getRangeEditForm($range_num,$reviewMode){
    /*
     *$range_num is required.
     
     reviewMode (confusing name) is the project this is customized for (aat)
     */

    $range_comment="";$tag_num="";$tag_desc="";$range_prelim=0;$d_count=0;$ev_count=0;$unsel_ev_count=0;$unsel_d_count=0;$warning="";$jsonArr=array();
    $program_num="";$strategy_num="";$project_num="";$parameter_num="";$html="";
    
    if($range_num=="")return "Error: Missing range_num.";
    
    #Get basic range info
    bldsql_init();
    bldsql_from("tag_ranges r");
    bldsql_where("r.num=?",$range_num);
    bldsql_col("r.tag_num");
    bldsql_from("tag_view t");
    bldsql_where("r.tag_num=t.num");
    bldsql_col("t.display_name as tag_desc");
    bldsql_col("r.comment as 'range_comment'");
    bldsql_col("r.prelim as range_prelim");
    bldsql_col("r.json_selection_criteria as json");
    $a=doquery();
    if($a) extract($a[0]);
    $range_comment=htmlentities($range_comment);
    
    if($json){
        #If there was a criteria set, parse it out and attempt to get some filters to use.
        $jsonArr=JSONToArray($json);
        if(isset($jsonArr['ev_program_num']))$program_num=$jsonArr['ev_program_num'];
        if(isset($jsonArr['ev_strategy_num']))$strategy_num=$jsonArr['ev_strategy_num'];
        if(isset($jsonArr['d_project_num']))$project_num=$jsonArr['d_project_num'];
        if(isset($jsonArr['d_parameter_num']))$parameter_num=$jsonArr['d_parameter_num'];            
    }

    
    #Get some event details
    $event_num="";$data_nums=array();$eventDetails="";
    bldsql_init();
    bldsql_from("flask_data_tag_view t");
    bldsql_from("flask_data d");
    bldsql_where("t.data_num=d.num");
    bldsql_where("t.range_num=?",$range_num);
    bldsql_distinct();
    bldsql_col("d.event_num");
    $a=doquery();
    if($a){
        if(count($a)>1){
            $eventDetails="This tag is applied to measurements in mulitple events<br>".getShowRangeMembersLinks($range_num);
            #Call sp to get tag range info.
            doquery("create temporary table t_range_nums as select num from tag_ranges where num=$range_num",false);
            doquery("call tag_getTagRangeInfo()",false);#Fills t_range_info table.
            
            bldsql_init();
            bldsql_from("t_range_info v");
            bldsql_where("v.range_Num=?",$range_num);
            bldsql_col("prettyStartDate");
            bldsql_col("prettyEndDate");
            bldsql_col("prettyRowCount");
            bldsql_col("tag_description");
            $a=doquery();
            if($a){
                extract($a[0]);
                $eventDetails.="<br><h4>Tag Range Detals:</h4>$prettyStartDate - $prettyEndDate<br>This range is $prettyRowCount<br>$tag_description<br>";                
            }
        }else{
            #Get the event details to print
            extract($a[0]);
            $eventDetails=getEventDetails($event_num,"",array(),true);
            $eventDetails.="<br>".getShowRangeMembersLinks($range_num,true,$event_num);
        }
    }
    
    $prelimChecked=($range_prelim)?"checked":"";
    $baseQueryHash="";#Not used.. historical.
    
    #Security checks to see what user can do
    $canAppend=false;$canEdit=false;
    
    #populate the temp tables needed for security check.
    createTagProcTempTables();
    doquery("insert t_data_nums select data_num from flask_data_tag_range where range_num=$range_num",false);
    doquery("insert t_event_nums select event_num from flask_event_tag_range where range_num=$range_num",false);
    $canAppend=userAccess("append");
    $canEdit=userAccess("edit");
    
    $tagSelect=rev_getTags($project_num,$program_num,$strategy_num,$parameter_num,$tag_num,$reviewMode,'355px','tagEdit_tag_num','',$canEdit,false,true);
    #Now build the output
    $edRO=($canEdit)?"":"readonly";
    $comRO=($canAppend)?"":"readonly";
    $submitRO=($canEdit || $canAppend)?"":"disabled";
    
    $html.="<div id='rev_rangeEditDiv' style='height:100%;vertical-align: top;'>
            <table width='100%' border='1'  style='height:100%'><tr>
            <td valign='top'>$eventDetails</td>
            <td><div id='tagEditFormDiv'>
            <form id='tagEditForm' style='height:100%'>
            <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value='$range_num'>
            <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='edit'>
            <input type='hidden' id='tagEdit_baseQueryHash' name='tagEdit_baseQueryHash' value='$baseQueryHash'>
            <table width='100%'  border='0' style='height:200px'>
                <tr>
                    <td colspan='2' valign='top' align='right'><span style='float:left;' class='title4'>Edit Tag</span>$tagSelect</td>
                </tr>
                <tr><td colspan='2' class='data'><textarea style='width:95%;' rows='3' class='tedit_field' readonly name='tagEdit_existingComment' id='tagEdit_existingComment'>$range_comment</textarea></td></tr>
                <tr><td class='data' style='height:950%;'><textarea placeholder='Enter new comments here' style='width:95%;height:95%;' rows='2' class='tedit_field' name='tagEdit_comment' id='tagEdit_comment' ></textarea></td></tr>        
                <tr>
                    <td align='left' valign='bottom' colspan='2'>
                        Preliminary<input $edRO type='checkbox' id='tagEdit_prelim' name='tagEdit_prelim' $prelimChecked value='1'>                  
                        <button $submitRO style='float:right;' id='tagEdit_submit_button' >Save</button>";
    if($canEdit)$html.=rev_getButtonJS('tagEdit_submit_button','submit_rev_tagEdit_form','','',$warning);
    $html.="
                    </td>
                </tr>
            </table></div></td></tr></table></div>";
    return $html;
}
function rev_getTags($project_num="",$program_num="",$strategy_num="",$parameter_num="",$selectedTagNum="",$mode="",$selwidth='175px',$id='rev_tags',$action='rev_itemSelected',$tagEditable=true,$limitToExisting=false,$inEditForm=false){
    /*This function has got way too many options.  There's only 2 callers, it should probably just be 2 functions*/
    bldsql_init();
    bldsql_from("tag_view v");
    bldsql_col("v.num as value");
    bldsql_col("v.display_name");
    if($limitToExisting){
        bldsql_from("tag_ranges r");
        bldsql_where("r.tag_num=v.num");
        bldsql_distinct();
    }
    if($mode!=='aat')bldsql_col("v.group_name");
    $orderby="";
    if($mode=='aat')$orderby="v.num";#This sorts better by just the num
    if($project_num){
        bldsql_where("(v.project_num is null or v.project_num=?)",$project_num);
        $orderby=appendToList($orderby,"case when v.project_num is not null then 0 else 1 end");
    }
    if($program_num){
        bldsql_where("(v.program_num is null or v.program_num=?)",$program_num);
        $orderby=appendToList($orderby,"case when v.program_num is not null then 0 else 1 end");
    }
    if($strategy_num){
        bldsql_where("(v.strategy_num is null or v.strategy_num=?)",$strategy_num);
        $orderby=appendToList($orderby,"case when v.strategy_num is not null then 0 else 1 end");
    }
    if($parameter_num){
        bldsql_where("(v.parameter_num is null or v.parameter_num=?)",$parameter_num);
        $orderby=appendToList($orderby,"case when v.parameter_num is not null then 0 else 1 end");
    }
    
    bldsql_orderby(appendToList($orderby,"v.sort_order"));
    if($mode=='aat'){
        bldsql_wherein("v.num in ",array(93,94,95,96,97));
        if($inEditForm && ($selectedTagNum==97 || $selectedTagNum==96))bldsql_where("v.num in (96,97)");/*Application logic.. if this automated tag is 6,
                                                               *the only options are to leave (and confrim by
                                                               *unmarking prelim) or change to 5.  Changing to any
                                                               *of the others doesn't make sense and you can't
                                                               *delete it because it'll just come back the next
                                                               *time stats are run.*/
    }
    $a=doquery();
    
    $html=getSelectInput($a,$id,$selectedTagNum,$action,false,$selwidth,!($tagEditable));
    
    return $html;
}

function rev_getTaggedEventList($tag_num,$project_num="",$program_num="",$strategy_num="",$parameter_num="",$site_num="",$preliminary=0){
    /*Returns the list of selectable tag range events to view.
    Note this is limited to data tags (no event based tags)*/
    
    $html="<div id='rev_taggerEventsDiv'><select id='rev_taggedEvents' onchange='rev_itemSelected(\"rev_taggedEvents\");' name='rev_taggedEvents' size='10' style='max-width:250px;min-width:250px;'>";
    #Select out samples that had 1+ of selected tag.
    bldsql_init();
    bldsql_from("flask_data_tag_view t");
    bldsql_from("flask_data_view d");
    bldsql_where("d.data_num=t.data_num");
    bldsql_where("t.tag_num=?",$tag_num);
    bldsql_where("t.prelim=$preliminary");
    if($project_num)bldsql_where("d.project_num=?",$project_num);
    if($program_num)bldsql_where("d.program_num=?",$program_num);
    if($strategy_num)bldsql_where("d.strategy_num=?",$strategy_num);
    if($parameter_num)bldsql_where("d.parameter_num=?",$parameter_num);
    if($site_num)bldsql_where("d.site_num=?",$site_num);
    bldsql_distinct();
    $d="concat_ws(' | ',d.ev_date";
    if(!$site_num)$d.=",d.site";
    #if(!$program_num)$d.=",d.program";
    if($project_num==2)$d.=",concat('alt:',d.alt)";
    $d.=") as display_name";
    bldsql_col($d);
    bldsql_col("d.event_num");
    bldsql_col("t.range_num");
    bldsql_orderby("d.ev_datetime");
    #return bldsql_printableQuery(); 
    $a=doquery();
    $selected=1;
    if($a){
        $num="";$display_name="";
        foreach($a as $row){
            extract($row);
            $sel=($selected)?"selected":"";
            $selected=0; 
            #$html.="<option value='$event_num' $sel>$display_name</option>";
            $html.="<option value='$range_num' $sel>$display_name</option>";
        }
    }else{$html.="<option value=''>None found</option>";}
    
    $html.="</select></div><script language='JavaScript'>rev_itemSelected('rev_taggedEvents');</script>";#Load the plot after select is returned.
    return $html;
}
function rev_getEventPlot($range_num,$mode){
    /*Plots various parameters before and after passed tag_range event. 
     *$mode (see below) gives hints on which parameters to plot and other filtering.
     */
    #defaults
    $html="";$jsonArr="";$lookback=150;$flaskData=true;$plotRowLimit=8000;//arbitrary, but too big causes ajax errors.
    $parameterList=array("CO","CO2","CH4","H2","N2O","SF6");#default parameter list
    $descs=array("site","ev_datetime");#Default fields we'll use to build the description header.
    switch ($mode){
        case "aat":
            #Add in some Hats tracers
            $parameterList[]="C2H2";
            $parameterList[]="F134A";
            $parameterList[]="H1211";
            $descs[]="ev_from_alt";
            $desc[]="ev_to_alt";
            break;
        default:
            #Graph ccgg gases by default, unless this tag range was for a group of params, then plot those.
            bldsql_init();
            bldsql_from("flask_data_tag_range r");
            bldsql_from("flask_data d");
            bldsql_from("gmd.parameter p");
            bldsql_where("d.parameter_num=p.num");
            bldsql_where("r.range_num=?",$range_num);
            bldsql_where("r.data_num=d.num");
            bldsql_distinct();
            bldsql_col("upper(p.formula) as 'p'");
            bldsql_orderby("d.parameter_num");//arbitrary.
            bldsql_limit(10);//also arbitrary
            $a=doquery();
            if($a)$parameterList=arrayFromCol($a,'p');
           
            break;
    }
     
    #Retreive any information on the selection from the the passed tag_range's selection criteria.
    #Also grab 1 (expected only) data_num to use to figure the date range to show.
    bldsql_init();
    bldsql_from("tag_ranges r");
    bldsql_from("flask_data_tag_range dr");
    bldsql_from("flask_ev_data_view d");
    bldsql_where("r.num=?",$range_num);
    bldsql_where("r.num=dr.range_num");
    bldsql_where("dr.data_num=d.data_num");
    bldsql_col("r.json_selection_criteria as json");
    bldsql_col("d.data_num");
    bldsql_orderby("d.ev_date");
    bldsql_limit(1);#We just need the first date.
    #return bldsql_printableQuery();
    $a=doquery();
    
    if($a){
        $json="";$data_num="";$params=array();$minDate="";$maxDate="";
        extract($a[0]);#json & data_num
        if($json){
            #If there was a criteria set, parse it out and attempt to get some filters to use.. otherwise we'll just use 'sane' ones.
            $jsonArr=JSONToArray($json);            
        }
        #Find the min date we'll use for our display range
        rev_buildPlotDataBaseQuery($mode,$data_num,$jsonArr);
        bldsql_from("flask_data_view d2");
        bldsql_where("d.program_num=d2.program_num");
        bldsql_where("d.parameter=d2.parameter");
        bldsql_where("d2.ev_datetime <= d.ev_datetime");
        bldsql_orderby("d2.ev_datetime desc");
        bldsql_limit($lookback);
        #return bldsql_printableQuery();
        $a=doquery();
        if($a){#Should atleast find itself.
            $row=array_pop($a);
            $minDate=$row['ev_datetime'];
        }
        #return(bldsql_printableQuery());
        
        #Find the max date we'll use for our display range
        rev_buildPlotDataBaseQuery($mode,$data_num,$jsonArr);
        bldsql_from("flask_data_view d2");
        bldsql_where("d.program_num=d2.program_num");
        bldsql_where("d.parameter=d2.parameter");
        bldsql_where("d2.ev_datetime >= d.ev_datetime");
        bldsql_orderby("d2.ev_datetime");
        bldsql_limit($lookback);
        $a=doquery();
        if($a){#Should atleast find itself.
            $row=array_pop($a);
            $maxDate=$row['ev_datetime'];
        }
        #var_dump($a);var_dump($maxDate);exit;
        #Now select out all the target rows
        rev_buildPlotDataBaseQuery($mode,$data_num,$jsonArr);
        
        #left join to ranges to highlight tagged members..  
        $dtable="left join flask_data_tag_view dt on (d2.data_num=dt.data_num and dt.range_num=$range_num)";         
        bldsql_from("flask_data_view d2 $dtable ");
        bldsql_col("case when dt.data_num is not null then 1 else 0 end as highlightPoint");
        
        bldsql_wherein("upper(d2.parameter) in",$parameterList);
        bldsql_where("d2.ev_date>=?",$minDate);
        bldsql_where("d2.ev_date<=?",$maxDate);
        bldsql_col("d2.parameter as series");
        bldsql_col("d2.ev_datetime as x");
        bldsql_col("d2.value as y");
        #bldsql_col("-1 as 'yaxis'");
        
        #Build the param col to pass to the js function on row click.
        bldsql_col("concat(d2.event_num,',',d2.data_num) as onClickParam");
        bldsql_orderby("d2.program");
        bldsql_orderby("d2.parameter");
        bldsql_orderby("timestamp(d2.ev_date,d2.ev_time)");
        bldsql_limit($plotRowLimit);
        
    }
    #return bldsql_printableQuery();
    $a=doquery();
    #return printTable($a);
    
    #Plot the data on graph
    if(count($a)==$plotRowLimit)$html.="Maximum plot size reached, data has been truncated.<br>";
    #First loop through and create a parameters array to use for js onclick action.  While looping thru, also create y axis labels array.
    $s="";$js="";$tjs="";$yaxisLabels="";
    foreach($a as $row){
        extract($row);
        if($s!=$series){
            #New series
            $s=$series;
            if($tjs)$js.="selectionPlotParams.push(new Array($tjs));";
            $tjs="";
            $yaxisLabels=appendToList($yaxisLabels,"'".$series."'",",");
        }
        $tjs=appendToList($tjs,'"'.$onClickParam.'"');
    }
    $yaxisLabels="var yaxisLables=new Array($yaxisLabels);";
    if($tjs)$js.="selectionPlotParams.push([$tjs]);";
    $Seljs=' <script language="JavaScript">$("#plotDiv").bind("plotselected", function (event, ranges) {
    
        $.each(searchResultsPlotVar.getXAxes(), function(_, axis) {
					var opts = axis.options;
					opts.min = ranges.xaxis.from;
					opts.max = ranges.xaxis.to;
				});
				searchResultsPlotVar.setupGrid();
				searchResultsPlotVar.draw();
				searchResultsPlotVar.clearSelection();
        //searchResultsPlotVar.setSelection(ranges);
    });
    </script>';

    
    #$js.="searchResultsPlotVar.highlight(1,2);";
    $js="<script language='JavaScript'>var selectionPlotParams=new Array();$js</script>";
    $minJS=strtotime($minDate." UTC")*1000;
    $maxJS=strtotime($maxDate." UTC")*1000;
    #Build the plot options

    $options="  series: { lines: { show: true }, points: { show: true }},
                xaxis:{mode:\"time\"},
                yaxis:{show:false,min:0,tickFormatter: function(val, axis) { $yaxisLabels return val < axis.max ? val.toFixed(2) : yaxisLables[axis.n-1];}},
                grid:{clickable:true,hoverable:true}";
    
    #build a description for under the plot:
    $description="";
    if($mode=="aat" && isset($jsonArr['ev_from_alt']))#Aircraft automated tagging, filter on alt if there.
        $description.="Alt bin from: ".$jsonArr['ev_from_alt'];
    if($mode=="aat" && isset($jsonArr['ev_to_alt']))
        $description.=" to: ".$jsonArr['ev_to_alt'];
    $html.=printGraph($a,"","searchResultsPlotVar","","default",array(),$options,true,true,$description);
    $html.=$js;
    $html="<div id='plotDiv' style='width:100%;height:100%;min-height:50px;min-width:50px;'>$html</div>";
    return $html;
}
function rev_buildPlotDataBaseQuery($mode,$data_num,$jsonArr){
    #Just for reuse
    bldsql_init();
    bldsql_from("flask_data_view d");
    bldsql_where("d.data_num=?",$data_num);
    bldsql_where("d.site_num=d2.site_num");#d2 is joined above by caller
    bldsql_where("d.project_num=d2.project_num");    
    bldsql_where("d.strategy_num=d2.strategy_num");
    bldsql_col("d2.ev_datetime");
    if($mode=="aat" && isset($jsonArr['ev_from_alt']))#Aircraft automated tagging, filter on alt if there.
        bldsql_where("d2.alt>=?",$jsonArr['ev_from_alt']);
    if($mode=="aat" && isset($jsonArr['ev_to_alt']))
        bldsql_where("d2.alt<=?",$jsonArr['ev_to_alt']);
}

function rev_getButtonJS($id,$action,$param1="",$param2="",$confirmationText=""){
    /*param1/2 are optional.  No good way currently to pass '', but that could be added if needed.
     *if $confirmationText is passed, we'll do a confirm with a ok/cancel button first
     */
    $action.="(";
    if($param1)$action.="'$param1'";
    if($param2)$action.=",'$param2'";
    $action.=");";
    $action=($confirmationText)?"if(confirm('".htmlentities($confirmationText)."')){$action}":"$action";
    $js="<script language='JavaScript'>
            $(\"#$id\").click(function(event){
                event.preventDefault();
                $action
            });</script>";
    return $js;
}

function rev_getButtonJS2($id,$action,$numParams,$param1="",$param2="",$param3="",$confirmationText=""){
    /*Similar to above with explicit # of params.  missing params are sent with '';
     *if $confirmationText is passed, we'll do a confirm with a ok/cancel button first
     */

    $action.="(";
    if($numParams>0)$action.=($param1=="")?"''":"'$param1'";
    if($numParams>1)$action.=($param2=="")?",''":",'$param2'";
    if($numParams>2)$action.=($param3=="")?",''":",'$param3'";
    
    $action.=");";
    $action=($confirmationText)?"if(confirm('".htmlentities($confirmationText)."')){$action}":"$action";
    $js="<script language='JavaScript'>
            $(\"#$id\").click(function(event){
                event.preventDefault();
                $action
            });</script>";
    return $js;
}
?>