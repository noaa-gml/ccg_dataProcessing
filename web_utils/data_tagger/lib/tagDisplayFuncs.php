<?php

function getTagList3($event_num="",$data_num="",$formMessage=""){
    /*Try Number 3 of the taglist.. this one won't show tags for current selection (too confusing), only a summary..*/
    $rowMode=($event_num||$data_num);
    $html="";$formContent="";
    $flaskData=false;$numRows=0;
    $type='';$desc="";

    $backArrow="<button id='showTagsForAllLink' title='Return to the full selection'>&larr;</button>&nbsp;&nbsp".getButtonJS('showTagsForAllLink','getTagList');
    #Build the temp table with target ev/data nums
    $flaskData=buildIDTable2($event_num,$data_num);
    $idTable=($flaskData)?"t_data":"t_events";
    $numRows=doquery("select count(*) from $idTable",0);
    if($numRows==0)return '';

    #Set the labels
    if($rowMode){
        $desc=$backArrow."Tags for ";
        $desc.=($flaskData)?"analysis #{$data_num}":"event #{$event_num}";
        $desc.=getButtonJS('showTagsForAllLink','getTagList');
       
    }else{#use the current selection to find all matches
        $desc="$numRows matching ";
        $desc.=($flaskData)?"anal records.":"samples.";
        if($numRows==1){
            #Only a single result row (like if search by event_num).  Select out and autoset into row mode (as if user clicked a result row). 
            bldsql_init();            
            if($flaskData){
                bldsql_from("t_data d");
                bldsql_from("flask_data fd");#join to flask_data to get the event num
                bldsql_where("d.num=fd.num");
                bldsql_col("d.num as data_num");
                bldsql_col("fd.event_num");
            }else{
                bldsql_from("t_events e");
                bldsql_col("e.num as event_num");
            }
            $a=doquery();
            extract($a[0]);//!Note; this overwrites $event_num (and data_num when flaskData).
            $desc=($flaskData)?"Tags for analysis #{$data_num}":"Tags for event #{$event_num}";
            $rowMode=true;
            
        }
        $backArrow="";#there's no going back in full selection mode
    }
    
    #Find all ranges for any of the selected rows and put into a temp table
    createTagProcTempTables();#create t_data_nums, t_event_nums, and t_range_nums tables
    if($flaskData) doquery("insert t_data_nums select num from t_data",false);
    else doquery("insert t_event_nums select num from t_events",false);

    doquery("call tag_getTagRanges()",false);#This fills the t_ranges table with any associated range_nums.

    
    #Set some common elements for either display
    #heights
    $divHeight=290;#All content (lists and forms) derive layout from this fixed height.
    $rDivHeight=$divHeight+20;#for button height
    #insert button
    if(userAccess("insert"))$btn="<button id='tagEdit_add_button'>New Tag</button>".getButtonJS('tagEdit_add_button','tagEdit_add',$event_num,$data_num);
    else $btn="<button disabled>New Tag</button>";
    #Basic table structure
    $html="
        <table width='100%' border='1'>
            <tr><td valign='top' width='350px' >
                    <div class='title4' style='display: inline;'>$desc</div><div style='float:right'>$btn</div>
                    <div style='width:100%;height:${divHeight}px; overflow: auto; border:1px solid silver;'>";
                        
    
    #If row mode, then show all tags, else just fetch metrics
    if($rowMode){
        $html.="<table id='tagListTable' width='100%'>";
        #Build temp table with range info for target rows.
               
        doquery("call tag_getTagRangeInfo()",false);#Creates t_range_info temporary table using t_range_nums filled above.

        #get min/max dates for ranges
        $minRangeDate="";$maxRangeDate="";
        #$a=doquery("select min(v.startDate) as minRangeDate, max(v.endDate) as maxRangeDate from tag_range_info_view v, t_range_nums t where t.num=v.range_num");
        $a=doquery("select min(v.startDate) as minRangeDate, max(v.endDate) as maxRangeDate from t_range_info v");
        if($a)extract($a[0]);#overwrites above
        
        
        #get info for any of the ranges found
        bldsql_init();
        bldsql_from("t_range_info v");
        
        #Was prelim specified on the criteria list?  If so we'll break the normal model of returning all associated tags, and just show prelim ones.
        $tag_prelim=getHTTPVar("tag_prelim",0,VAL_BOOLCHECKBOX);
        if($tag_prelim)bldsql_where("v.prelim=1");
        
        bldsql_col("v.range_num");
        bldsql_col("v.prettyStartDate");
        bldsql_col("v.prettyEndDate");
        bldsql_col("v.prettyRowCount");
        #bldsql_col("v.tag_comment");
        bldsql_col("v.tag_description");
        bldsql_col("v.prelim");
        bldsql_col("v.display_name as tag_name");
        bldsql_col("case when v.collection_issue=1 then 'collection' when v.measurement_issue=1 then 'measurement' when v.selection_issue=1 then 'selection' else '' end as class");
        bldsql_col("case when v.reject=1 then 'Rejection' when v.selection=1 then 'Selection' when v.information='1' then 'Information' else ' ' end as rsi");
        bldsql_col("v.group_name");
        
        #These are for the display graph
        bldsql_col("v.startDate as tl_start");
        bldsql_col("v.endDate as tl_end");
        bldsql_col("v.tag_num");
        #bldsql_col("v.internal_flag");
        bldsql_col("v.startDate");
        bldsql_col("v.measurement_issue");
        bldsql_orderby("v.sort_order2");
        bldsql_orderby("v.startDate");
        
        $a=doquery();
        
        
        if($formMessage)$formContent=$formMessage;
        elseif($rowMode)$formContent=getEventDetails($event_num,$data_num);
        else $formContent=getTagRangePlot($a,$flaskData,$rDivHeight,$minRangeDate,$maxRangeDate);
           
        if($a){
            $lastGroupName="";
            foreach($a as $row){
                extract($row);
                if($group_name!=$lastGroupName){
                    $html.="<tr><td colspan='3' class='title'>";
                    if($lastGroupName)$html.="<br>";
                    $html.="$group_name</td></tr>";
                    $lastGroupName=$group_name;
                }
                $js="onClick=\"JavaScript:tagRangeSelected('$range_num')\"";
                $tag_name=htmlspecialchars($tag_name);
                if($tag_description)$tag_description="Selection Criteria: $tag_description";
                $prelimClass=($prelim)?"preliminary":"";
                $prelim=($prelim)?"<span class='tiny_data'> (Preliminary)</span>":"";
                $date=($prettyStartDate==$prettyEndDate)?$prettyStartDate:"${prettyStartDate} - ${prettyEndDate}";
                $date=($measurement_issue)?$date." (anal. dates)":$date;
                $t="<div class='tag_dateRange'>${date}${prelim}</div><div><span  class='$class'>&nbsp;</span>&nbsp;&nbsp;${tag_name}</div><div>&nbsp;&nbsp;&nbsp;<span class='sm_data'>${rsi} tag ${prettyRowCount}</span></div>";
                #$t="<div>$tag_name</div><div>(${startDate}-${endDate})<span class='tiny_data'>${rsi} ${count}</span></div>";
                $html.="<tr><td>&nbsp;</td><td class='selectable $prelimClass' style='border-top: thin silver solid;' $js title=\"".htmlentities($tag_description)."\">$t</td><td></td></tr>";
            }
        }else{
            $html.="<tr><td align='center'><br><br><br>No tags for current data selection.<br>Click 'New Tag' to add one.</td></tr>";
        }
        $html.="</table>";
    }else{
        $formContent=$formMessage;
        #metrics for the current selection
        $totRanges=doquery("select count(distinct num) from t_range_nums",0);
        if($totRanges==0)$html.="<div class='tag_metrics_div'><br><br><br>No tags for current data selection.<br>Click 'New Tag' to add one.</div>";
        else{
            
            $num_data_tags=0;$num_data_rows=0;$num_ev_rows=0;$num_ev_data_rows=0;$num_ev_tags=0;$num_ev_ranges=0;$num_data_ranges=0;
            $num_col_issues=0;$num_meas_issues=0;$num_sel_issues=0;$num_data_rej=0;$num_ev_data_rej=0;$num_data_sel=0;$num_data_inf=0;
            $num_ev_data_inf=0;$num_ev_data_sel=0;
            $t=($flaskData)?"measurements":"sample events";
            /*
             *Taking out for now for clarity and performance..  just commenting incase it was popular...
            #flask_data counts
            bldsql_init();
            bldsql_from("t_range_nums r");
            bldsql_from("flask_data_tag_range dr");
            bldsql_where("r.num=dr.range_num");
            bldsql_col("count(distinct range_num) as num_data_ranges");
            bldsql_col("count(distinct dr.data_num) as num_data_rows");
            bldsql_col("count(distinct rng.tag_num) as num_data_tags");
            
            bldsql_from("tag_dictionary dict");
            bldsql_from("tag_ranges rng");
            bldsql_where("rng.num=r.num");
            bldsql_where("rng.tag_num=dict.num");
            bldsql_col("sum(dict.reject) as num_data_rej");
            bldsql_col("sum(dict.selection) as num_data_sel");
            bldsql_col("sum(dict.information) as num_data_inf");
            #return bldsql_printableQuery();
            $a=doquery();
            if($a){
                extract($a[0]);
            }
            
            #flask event counts
            bldsql_init();
            bldsql_from("t_range_nums r");
            bldsql_from("flask_event_tag_range er left join flask_data d on er.event_num=d.event_num");
            bldsql_where("r.num=er.range_num");
            #bldsql_from("flask_data d");
            #bldsql_where("er.event_num=d.event_num");
            bldsql_col("count(distinct range_num) as num_ev_ranges");
            bldsql_col("count(distinct d.num) as num_ev_data_rows");
            bldsql_col("count(distinct er.event_num) as num_ev_rows");
            bldsql_col("count(distinct rng.tag_num) as num_ev_tags");
            
            bldsql_from("tag_dictionary dict");
            bldsql_from("tag_ranges rng");
            bldsql_where("rng.num=r.num");
            bldsql_where("rng.tag_num=dict.num");
            bldsql_col("sum(dict.reject) as num_ev_data_rej");
            bldsql_col("sum(dict.selection) as num_ev_data_sel");
            bldsql_col("sum(dict.information) as num_ev_data_inf");
            $a=doquery();
            if($a){
                extract($a[0]);
            }

            #tag types
            bldsql_init();
            bldsql_from("t_range_nums t");
            bldsql_from("tag_ranges r");
            bldsql_where("t.num=r.num");
            bldsql_from("tag_dictionary d");
            bldsql_where("r.tag_num=d.num");
            bldsql_col("sum(d.collection_issue) as num_col_issues");
            bldsql_col("sum(d.measurement_issue) as num_meas_issues");
            bldsql_col("sum(d.selection_issue) as num_sel_issues");
            
            $a=doquery();
            if($a){extract($a[0]);}
            */
            
            $filterDesc=buildQueryBase(false,false,true);#generate a description of current filters
            #Prettify the desc a little.
            $filterDesc="<ul><li>".str_replace("|","</li><li>",$filterDesc)."</li></ul>";
            $filterDesc="<h4>Search filters used:</h4>$filterDesc";
            
            $html.="
                <!--<div id='tag_metrics_wrapper_div' class='tag_metrics_div' style='border:thin solid silver'>
                        <div >Tagged sample <span class='tag_metrics_highlight'>events</span>:<span class='data'>$num_ev_rows</span></div>
                        <div >Individually tagged <span class='tag_metrics_highlight'>measurements</span>:
                            <span class='data'>$num_data_rows</span></div>
                        <div ><span class='tag_metrics_highlight'>Total</span> tagged
                            <span class='tag_metrics_highlight'>measurements</span> (including measurements from tagged samples):
                            <span class='data'>".($num_data_rows+$num_ev_data_rows)."</span></div>
                        <div ># of tag <span class='tag_metrics_highlight'>ranges</span> (1+ events/meas. tagged together):
                            <span class='data'>".($num_ev_ranges+$num_data_ranges)."</span></div>
                        <div ># of <span class='tag_metrics_highlight'>collection</span> issues:
                            <span class='data'>$num_col_issues</span></div>
                        <div ># of <span class='tag_metrics_highlight'>selection</span> issues:
                            <span class='data'>$num_sel_issues</span></div>
                        <div ># of <span class='tag_metrics_highlight'>measurement</span> issues:
                            <span class='data'>$num_meas_issues</span></div>
                        <div >Total measurements with <span class='tag_metrics_highlight'>rejection</span> tag:
                            <span class='data'>".($num_data_rej+$num_ev_data_rej)."</span></div>
                        <div >Total measurements with <span class='tag_metrics_highlight'>selection</span> tag:
                            <span class='data'>".($num_data_sel+$num_ev_data_sel)."</span></div>
                        <div >Total measurements with <span class='tag_metrics_highlight'>informational</span> tag:
                            <span class='data'>".($num_data_inf+$num_ev_data_inf)."</span></div>
                </div>-->
            
                <ul>
                    <li>Click the 'New Tag' button above to add a tag for <b><i>ALL</i></b> the $desc</li>
                    <li>Click a row below to view/add tags for individual $t.</li>
                </ul>
                <ul>
                    <!--<li>Click <button id='tag_metrics_btn'>here</button> to see some tag metrics of the current selection.</li>-->
                    <li>Click <button onclick='getTagList(\"\",\"\",\"2\");return false;'>here</button> to view all tag ranges associated with any of the below rows (2+ members).</li>
                    
                </ul>
                <br>
                $filterDesc
                <script language='JavaScript'>
                    //$(\"#tag_metrics_wrapper_div\").hide();
                    //$(\"#tag_metrics_btn\").click(function(event){
                    //    event.preventDefault();
                    //    $(\"#tag_metrics_wrapper_div\").toggle('slide',600);
                    //})
                    
                </script>
                 
                
            ";
            #var_dump($num_data_rows+$num_ev_data_rows);exit();
        }
    }
    $html.="        
                </div>
            </td>
            <td valign='top' align='left'>            
                <div id='tagEditFormDiv' style='border:thin black solid;width:100%;height:${rDivHeight}px;'>$formContent</div>
            </td>
        </tr>
    </table>";

    


    return $html;
}
function getTagList2($event_num="",$data_num="",$formMessage=""){
    /*Try Number 2(3) of the taglist.. this one will be sorting by collection/measurement tag ranges.  Note this is still in use (as a link), not replaced (entirely) by above...
    jwm - 4/19.  Changed meaning to show all ranges with 2+ members (too cluttered otherwise)
    */
    $rowMode=($event_num||$data_num);
    $html="";
    $flaskData=false;$numRows=0;
    $type='';$desc="";

    $backArrow="<button id='showTagsForAllLink' title='Return to the full selection'>&larr;</button>&nbsp;&nbsp".getButtonJS('showTagsForAllLink','getTagList');
    #Build the temp table with target ev/data nums
    $flaskData=buildIDTable2($event_num,$data_num);
    $idTable=($flaskData)?"t_data":"t_events";
    $numRows=doquery("select count(*) from $idTable",0);
    if($numRows==0)return '';
    
    #Set the labels
    if($rowMode){
        $desc=$backArrow."Tags for ";
        $desc.=($flaskData)?"analysis #{$data_num}":"event #{$event_num}";
        $desc.=getButtonJS('showTagsForAllLink','getTagList');
       
    }else{#use the current selection to find all matches
        $desc="Tag ranges in $numRows matching ";
        $desc.=($flaskData)?"anal records.":"samples.";
        if($numRows==1){
            #Only a single result row (like if search by event_num).  Select out and autoset into row mode (as if user clicked a result row). 
            bldsql_init();            
            if($flaskData){
                bldsql_from("t_data d");
                bldsql_from("flask_data fd");#join to flask_data to get the event num
                bldsql_where("d.num=fd.num");
                bldsql_col("d.num as data_num");
                bldsql_col("fd.event_num");
            }else{
                bldsql_from("t_events e");
                bldsql_col("e.num as event_num");
            }
            $a=doquery();
            extract($a[0]);//!Note; this overwrites $event_num (and data_num when flaskData).
            $desc=($flaskData)?"Tags for analysis #{$data_num}":"Tags for event #{$event_num}";
            $rowMode=true;
            
        }
        $backArrow="";#there's no going back in full selection mode
    }
    
    #Find all ranges for any of the selected rows and put into a temp table
    createTagProcTempTables();#create t_data_nums, t_event_nums, and t_range_nums tables
    if($flaskData) doquery("insert t_data_nums select num from t_data",false);
    else doquery("insert t_event_nums select num from t_events",false);
    
    
    doquery("call tag_getTagRanges()",false);#This fills the t_ranges table with any associated range_nums.
    #Build temp table with range info for target rows.
        
    doquery("call tag_getTagRangeInfo()",false);#Creates t_range_info temporary table using t_range_nums filled above.
    
    #get min/max dates for ranges
    $minRangeDate="";$maxRangeDate="";
    $a=doquery("select min(v.startDate) as minRangeDate, max(v.endDate) as maxRangeDate from t_range_info v where rowcount>1");
    if($a)extract($a[0]);#overwrites above
    
    
    #get info for any of the ranges found
    bldsql_init();
    bldsql_from("t_range_info v");
    bldsql_where("v.rowcount>1");#added to filter the list from uninteresting ones.
    #Was prelim specified on the criteria list?  If so we'll break the normal model of returning all associated tags, and just show prelim ones.
    $tag_prelim=getHTTPVar("tag_prelim",0,VAL_BOOLCHECKBOX);
    if($tag_prelim)bldsql_where("v.prelim=1");
    
    bldsql_col("v.range_num");
    bldsql_col("v.prettyStartDate");
    bldsql_col("v.prettyEndDate");
    bldsql_col("v.prettyRowCount");
    #bldsql_col("v.tag_comment");
    bldsql_col("v.tag_description");
    bldsql_col("v.prelim");
    bldsql_col("v.display_name as tag_name");
    bldsql_col("case when v.collection_issue=1 then 'collection' when v.measurement_issue=1 then 'measurement' when v.selection_issue=1 then 'selection' else '' end as class");
    bldsql_col("case when v.reject=1 then 'Rejection' when v.selection=1 then 'Selection' when v.information='1' then 'Information' else ' ' end as rsi");
    bldsql_col("v.group_name");
    
    #These are for the display graph
    bldsql_col("v.startDate as tl_start");
    bldsql_col("v.endDate as tl_end");
    bldsql_col("v.tag_num");
    #bldsql_col("v.internal_flag");
    bldsql_col("v.startDate");
    bldsql_col("v.measurement_issue");
    bldsql_orderby("v.sort_order2");
    bldsql_orderby("v.startDate");
    
    $a=doquery();
    $divHeight=290;#All content (lists and forms) derive layout from this fixed height.
    $rDivHeight=$divHeight+20;#for button height
    
    if($formMessage)$formContent=$formMessage;
    elseif($rowMode)$formContent=getEventDetails($event_num,$data_num);
    else $formContent=getTagRangePlot($a,$flaskData,$rDivHeight,$minRangeDate,$maxRangeDate);

    
    if(userAccess("insert"))$btn="<button id='tagEdit_add_button'>New Tag</button>".getButtonJS('tagEdit_add_button','tagEdit_add',$event_num,$data_num);
    else $btn="<button disabled>New Tag</button>";
    
    
    $html="
    <table width='100%' border='1'>
        <tr><td valign='top' width='350px' >
                <div class='title4' style='display: inline;'>$desc</div><div style='float:right'>$btn</div>
                <div style='width:100%;height:${divHeight}px; overflow: auto; border:1px solid silver;'>
                    <table id='tagListTable' width='100%'>";
    if($a){
        $lastGroupName="";
        foreach($a as $row){
            extract($row);
            if($group_name!=$lastGroupName){
                $html.="<tr><td colspan='3' class='title'>";
                if($lastGroupName)$html.="<br>";
                $html.="$group_name</td></tr>";
                $lastGroupName=$group_name;
            }
            $js="onClick=\"JavaScript:tagRangeSelected('$range_num')\"";
            $tag_name=htmlspecialchars($tag_name);
            if($tag_description)$tag_description="Selection Criteria: $tag_description";
            $prelimClass=($prelim)?"preliminary":"";
            $prelim=($prelim)?"<span class='tiny_data'> (Preliminary)</span>":"";
            $date=($prettyStartDate==$prettyEndDate)?$prettyStartDate:"${prettyStartDate} - ${prettyEndDate}";
            $date=($measurement_issue)?$date." (anal. dates)":$date;
            $t="<div class='tag_dateRange'>${date}${prelim}</div><div><span  class='$class'>&nbsp;</span>&nbsp;&nbsp;${tag_name}</div><div>&nbsp;&nbsp;&nbsp;<span class='sm_data'>${rsi} tag ${prettyRowCount}</span></div>";
            #$t="<div>$tag_name</div><div>(${startDate}-${endDate})<span class='tiny_data'>${rsi} ${count}</span></div>";
            $html.="<tr><td>&nbsp;</td><td class='selectable $prelimClass' style='border-top: thin silver solid;' $js title=\"".htmlentities($tag_description)."\">$t</td><td></td></tr>";
        }
    }else{
        $html.="<tr><td align='center'><br><br><br>No tags for current data selection.<br>Click 'New Tag' to add one.</td></tr>";
    }
    $html.="        </table>
                </div>
            </td>
            <td valign='top' align='left'>            
                <div id='tagEditFormDiv' style='border:thin black solid;width:100%;height:${rDivHeight}px;'>$formContent</div>
            </td>
        </tr>
    </table>";

    


    return $html;
}
function getEventDetails($event_num,$data_num,$data_nums=array(),$forReviewMode=false){
    /*Returns html for full event and data details
    If array of data_nums passed, all are highlighted.  This was added later (why both args accepted).  defaults to data_num
        Of course, now I decided not to even use it... leaving in because it might be useful for something else.
    If $forReviewMode passed, we make some small changes for display on that page.
    */
    
    $html="";
    bldsql_init();
    bldsql_from("flask_event_view v");
    bldsql_where("v.event_num=?",$event_num);
    bldsql_col("*");
    bldsql_col("v.prettyEvDate");
    
    $a=doquery();
        
    if($a){
        extract($a[0]);
        $html="<div><div class='psuedoInput'><u>Event # ${event_num} Details</u></div>
                <span class='label'>Date:</span> <span class='psuedoInput' >$prettyEvDate</span>&nbsp;&nbsp;
                <span class='label'>Site:</span> <span class='psuedoInput' >$site</span>&nbsp;&nbsp;
                <span class='label'>Flask:</span> <span class='psuedoInput' >$id</span><br>
                <span class='label'>Project:</span> <span class='psuedoInput' >$project</span>&nbsp;&nbsp;
                <span class='label'>Strategy:</span> <span class='psuedoInput' >$strategy</span>&nbsp;&nbsp;
                <span class='label'>Method:</span> <span class='psuedoInput' >$me</span><br>
                <span class='label'>Lat:</span> <span class='psuedoInput' >$lat</span>&nbsp;&nbsp;
                <span class='label'>Lon:</span> <span class='psuedoInput' >$lon</span>&nbsp;&nbsp;
                <span class='label'>Alt:</span> <span class='psuedoInput' >$alt</span>&nbsp;&nbsp;
                <span class='label'>Elev:</span> <span class='psuedoInput' >$elev</span><br>";
        if($forReviewMode)$html.="<span class='label'>Comment:</span> <span class='psuedoInput' >$comment</span><br>";
        else{
            $html.="<table width='100%'><tr><td valign='top'><span class='label'>Comment:</span></td><td valign='top' width='100%'><div class='psuedoInput' style='height:3em;overflow:auto;' >$comment</div></td></tr></table><br>";
            #Measurements
            #I've gone back and forth on whether to display rows directly or through link.  Doing link for now to reduce clutter.      
        
            #Build the param col to pass to the js function on row click, we have to pass as a string 
            $param="concat(v.event_num,',',v.data_num)";
            
            #build the concat'd list of tag tables.  We'll left join these to the main view when appropriate.
            /*$dtable="left join (select data_num,group_concat(flag separator ',') as tags
                        from flask_data_tag_view
                        group by data_num) as dt on v.data_num=dt.data_num";
            $etable="left join (select event_num, group_concat(flag separator ',') as tags
                        from flask_event_tag_view
                        group by event_num) as et on v.event_num=et.event_num";
                        */
            #Actually, these perform terribly once the tags table got large.  I think because below does a left join on a very large
            #derived table that can't have an index (because it's derived).  So we'll re-write with explicit temp tables to speed up.
            $dtable="";$etable="";
            doquery("drop temporary table if exists t__dt,t__et",false);
            #data tags
            $sql="create temporary table t__dt (index (data_num)) as
                    select v.data_num,group_concat(v.flag separator ',') as tags
                        from flask_data_tag_view v join flask_data d on v.data_num=d.num
                        where d.event_num=$event_num
                        group by v.data_num";
            doquery($sql,false);
            $dtable="left join t__dt as dt on v.data_num=dt.data_num";#for big select below.
            #event tags
            $sql="create temporary table t__et (index (event_num)) as
                    select v.event_num, group_concat(distinct v.flag separator ',') as tags
                        from flask_event_tag_view v where v.event_num=$event_num
                        group by v.event_num";
            doquery($sql,false);
            $etable="left join t__et as et on v.event_num=et.event_num";#for big select below.
    
    
            bldsql_init();
            bldsql_from("flask_data_view v $dtable $etable");
            bldsql_where("v.event_num=?",$event_num);
            bldsql_col($param." as onClickParam");
            if($data_num)bldsql_col("case when v.data_num=$data_num then 'highlightRow' else '' end as rowClass");
            elseif($data_nums)bldsql_col("case when v.data_num in (".join(",",$data_nums).") then 'highlightRow' else '' end as rowClass");
            else bldsql_col("'' as rowClass");#place holder
            bldsql_col("v.data_num as 'Data #'");
            bldsql_col("v.parameter");
            bldsql_col("v.program");
            bldsql_col("v.value");
            bldsql_col("v.unc");
            #bldsql_col("v.prettyADate as 'Meas date'");
            bldsql_col("v.flag");
            bldsql_col("v.inst as 'Inst.'");
            if(!$forReviewMode)bldsql_col("case when v.update_flag_from_tags=1 then 'Yes' else 'No' end as 'Auto flag'");
            bldsql_col("concat_ws(',',dt.tags,et.tags) as Tags");
            if(!$forReviewMode)bldsql_col("v.comment");
            #bldsql_col("concat_ws(dt.tags,et.tags) as tags");
            $callback=($forReviewMode)?"":"getTagList";
            $tableHeight=($forReviewMode)?'90':'180';
            $html.="<div style='border:thin silver solid;overflow:auto;height:${tableHeight}px;'>".printTable(doquery(),$callback,2)."</div>";
        }
        $html.="</div>";
    }
    return $html;
}
function getTagRangePlot($ranges,$flaskData,$divHeight,$minRangeDate,$maxRangeDate){
    #Plot the taglist for nice visual.  y is total number of tags, sorted collection at top.  x is the current selection range
    #We have to do some gymnastics to get it in the form that the dbutils method is expecting.
    $html="";$sColor="rgb(255,0,0)";$cColor="rgb(16,177,10)";$mColor="rgb(0,95,184)";
    $plotHeight='250';$mesgHeight=$divHeight-$plotHeight;
    $html="<div style='width:100%;height:${plotHeight}px;align:right;'>";
    if($ranges){
        #We'll use the index of the tag list as the y axis, order from collection down
        $a=doquery("select num,display_name,case when collection_issue=1 then 'collection' when measurement_issue=1 then 'measurement' when selection_issue=1 then 'selection' else '' end as type from tag_view order by sort_order desc");
        if($a){
            $tag_nums=array();$tag_names=array();$tag_types=array();
            $tag_nums[]="";$tag_names[]="";#we want a 1 based array, not zero because the index will be the y axis.
            foreach($a as $row){
                $tag_nums[]=$row['num'];
                $tag_names[]=$row['display_name'];
                $tag_types[]=$row['type'];
            }
            //var_dump($ranges);exit;
            #Extract the range info from the passed result set using the index of above tag list select as y value and create a 'result set' to pass to the graphing function
            $tagList=array();$jsDesc="";
            foreach($ranges as $row){
                $prettyStartDate=$row['prettyStartDate'];$prettyEndDate=$row['prettyEndDate'];$tag_name=$row['tag_name'];
                $date=($prettyStartDate==$prettyEndDate)?$prettyStartDate:"${prettyStartDate} - ${prettyEndDate}";
                $group_name=$row['group_name'];
                $group_name=(substr($group_name,-1)=='s')?substr($group_name,0,-1):$group_name;#Strip trailing s if there.
                $desc="<div>$group_name:&nbsp;&nbsp;&nbsp;$date</div><div style='font-weight: 600;'>$tag_name</div>";
                $tag_description=$row['tag_description'];
               #if($tag_description)$tag_description=str_replace(array('\r', '\n'), '', $tag_description);
                $tag_description=($row['tag_description'])?"<div style='font-weight: 600;'>Selection Criteria: ".str_replace(array('\r', '\n'), '', $tag_description)."</div>":"";
                $desc.=$tag_description;
                $jsDesc=appendToList($jsDesc,'"'.$desc.'"',",");
                #we'll basically pretend we selected out the data using start/end dates of the ranges as x1 and x2 for each line and the tag index as y.
                $t1=array();$t2=array();
                $t1['x']=$row['tl_start'];
                $t1['y']=array_search($row['tag_num'],$tag_nums);
                $t1['series']=$row['range_num'];
                $t1['end_point']=0;
                $class=$row['class'];
                $color="";
                if($class=='collection')$color=$cColor;#from styles.css
                if($class=='measurement')$color=$mColor;
                if($class=='selection')$color=$sColor;
                
                if($color)$t1['series_color']=$color;
                $tagList[]=$t1;
                $t2['x']=$row['tl_end'];
                $t2['y']=array_search($row['tag_num'],$tag_nums);
                $t2['series']=$row['range_num'];
                $t2['end_point']=1;#Mark as the 'end point' of the line.
                if($color)$t2['series_color']=$color;
                $tagList[]=$t2;
            }
            //var_dump($tagList);exit;
            #build up the graph options.
            $d=getPlotMinMaxDates($minRangeDate,$maxRangeDate);//$d="";
            
            #Get minmax dates again, but just for selection range so we can mark the area
            $markings=getPlotMinMaxDates("","",true);
            
            
            #Set the broad type of tag lines
            $w=.5;
            
            #Set the broad type of tag lines
            $i=array_search("selection",$tag_types);
            if($i)$markings.="{yaxis: {from:$i, to: $i}, color:\"$sColor\",lineWidth:$w},";
            $i=array_search("measurement",$tag_types);
            if($i)$markings.="{yaxis: {from:$i, to: $i}, color:\"$mColor\",lineWidth:$w},";
            $i=array_search("collection",$tag_types);
            if($i)$markings.="{yaxis: {from:$i, to: $i}, color:\"$cColor\",lineWidth:$w}";
            if($markings)$markings="markings:[$markings]";#var_dump($markings);exit;
            
            #build option list
            $seriesOptions="";
            $options="  series: { lines: { show: true }, points: { show: true }},
                        xaxis:{mode:\"time\",$d},
                        yaxis:{show:false,min:0,max:".count($tag_nums)."},
                        grid:{clickable:true,hoverable:true,$markings},
                        legend:{show:false}                        
                    ";#,timeformat:\"%Y-%m-%d\"
            
            $ylabel="<div style='float:left;display:inline;color:grey;z-index:1;position:relative;'><br>&nbsp;&nbsp;&nbsp;Collection issues<br><br><br><br><br><br>&nbsp;&nbsp;&nbsp;Measurement issues<br><br><br><br><br><br><br>&nbsp;&nbsp;&nbsp;Selection issues</div>";
            $tdHeight=floor(($plotHeight-20)/3);
            $ylabel="<div style='float:left;display:inline;color:#B3B3B3;'>
                <table border='0'>
                    <tr><td valign='top' style='height:${tdHeight}px;padding-left: 20px;'><br>Collection issues</td></tr>
                    <tr><td valign='middle' style='height:${tdHeight}px;padding-left: 20px;'>Measurement issues</td></tr>
                    <tr><td valign='bottom' style='padding-left: 20px;padding-top:49px;'>Selection issues</td></tr>
                </table></div>";
            $html.=$ylabel;
            $html.=printGraph($tagList,"","plotVar","tagRangePlotClicked","tagRangePlotHover",array(),$options);
            $html.="<script language='JavaScript'>var plotRangeDescriptions=[$jsDesc];</script>";
        }
    }
    $html.="</div><div align='center' style='height:${mesgHeight}px;width:100%;overflow:auto;'><div class='plotTextArea' id='plotTextArea'></div></div>";
    return $html;
}
function getPlotMinMaxDates($dataStart="",$dataEnd="",$forMarking=false){
    #Queries the current selection criteria to get min/max dates for a plot
    #returns the appropriate js
    $ev_sDate=getHTTPVar("ev_sDate","",VAL_DATE_TIME);#parse from criteria
    $ev_eDate=getHTTPVar("ev_eDate","",VAL_DATE_TIME);
    $d_sDate=getHTTPVar("d_sDate","",VAL_DATE_TIME);
    $d_eDate=getHTTPVar("d_eDate","",VAL_DATE_TIME);
    $ev_sDate=($ev_sDate)?strtotime($ev_sDate)*1000:"";#set into number format
    $ev_eDate=($ev_eDate)?strtotime($ev_eDate)*1000:"";
    $d_sDate=($d_sDate)?strtotime($d_sDate)*1000:"";
    $d_eDate=($d_eDate)?strtotime($d_eDate)*1000:"";
    $dataStart=($dataStart)?strtotime($dataStart)*1000:"";#include data dates if passed.
    $dataEnd=($dataEnd)?strtotime($dataEnd)*1000:"";
    
    $sarr=array();$earr=array();#put into array for sorting.
    if($dataStart)$sarr[]=$dataStart;
    if($ev_sDate)$sarr[]=$ev_sDate;
    if($d_sDate)$sarr[]=$d_sDate;
    if($dataEnd)$earr[]=$dataEnd;
    if($ev_eDate)$earr[]=$ev_eDate;
    if($d_eDate)$earr[]=$d_eDate;
   
    $minDate="";$maxDate="";$min=0;$max=0;$d="";
    if($sarr){
        sort($sarr,SORT_NUMERIC);
        $min=array_shift($sarr);
        $minDate="min:".$min;
    }
    if($earr){
        sort($earr,SORT_NUMERIC);
        $max=array_pop($earr);
        $maxDate="max:".$max;
    }
    if($forMarking){
        if($min && $max){
           $d="{xaxis:{from:$min, to:$max},color:\"rgb(241,241,241)\"},";
        } 
    }else{
        $d=appendToList($minDate,$maxDate);
    }
    return $d;
}
function getRangeDetails($range_num){
    /*Fetch details and edit buttons for the passed tag range*/
    $html="";

    if($range_num){
        
        #See if this range is editable in general or if it is synced by other processes (like HATS)
        $rangeIsEditable=isRangeEditable($range_num);
        
        #populate the temp tables needed for security check.
        createTagProcTempTables();
        doquery("insert t_data_nums select data_num from flask_data_tag_range where range_num=$range_num",false);
        doquery("insert t_event_nums select event_num from flask_event_tag_range where range_num=$range_num",false);
        $canAppend=(userAccess("append") && $rangeIsEditable);
        $canEdit=(userAccess("edit") && $rangeIsEditable);
        $canDelete=(userAccess("delete") && $rangeIsEditable);
        
        #Call sp to get tag range info.
        doquery("insert t_range_nums select num from tag_ranges where num=$range_num",false);
        doquery("call tag_getTagRangeInfo()",false);#Fills t_range_info table.
        
        bldsql_init();
        bldsql_from("t_range_info v");
        bldsql_where("v.range_num=?",$range_num);
        
        bldsql_col("v.range_num");
        bldsql_col("v.prettyStartDate");
        bldsql_col("v.prettyEndDate");
        bldsql_col("v.prettyRowCount");
        bldsql_col("v.tag_comment");
        bldsql_col("v.tag_description");
        bldsql_col("v.prelim");
        bldsql_col("v.json_selection_criteria");
        bldsql_col("v.display_name as tag_name");
        bldsql_col("case when v.reject=1 then 'rejection' when v.selection=1 then 'selection' when v.information=1 then 'information' else '' end as class");
        bldsql_col("case when v.reject=1 then ' rejection' when v.selection=1 then ' selection' when v.information='1' then ' information' else ' ' end as rsi");
        bldsql_col("v.is_data_range");
        bldsql_col("v.measurement_issue");
        $a=doquery();
        if($a){
            extract($a[0]);
            $backArrow="<button id='getTagListLink' title='Back'>&larr;</button>&nbsp;&nbsp".getButtonJS('getTagListLink','getTagList');
    
            $tag_name=htmlentities($tag_name);
            $tag_comment=htmlentities($tag_comment);
            $prelim=($prelim)?"Preliminary":"";
            $date=($prettyStartDate==$prettyEndDate)?$prettyStartDate:"${prettyStartDate} - ${prettyEndDate}";
            $dateLabel=($prettyStartDate==$prettyEndDate)?"Date: ":"Date Range: ";
            $dateLabel=($measurement_issue)?"a".$dateLabel:$dateLabel;
            $html="";$selJS="";
            if($tag_description)$tag_description=htmlentities($tag_description);
            #Load the json into a js variable.  I tried several methods to catch errors (try/catch, eval..) but couldn't get it to
            #trap syntax errors.  I left it with a global error catcher in index.php that alerts the error.
            
            #Before trying to load the json, first check to see if we should.  If another function (review of automated tags)
            #is using the criteria for its own purposes, we'll just wipe out here as if it wasn't present.
            #If we shouldn't edit these criteria there will be a "doNotEdit:'true'" key:val pair.
            if(strpos($json_selection_criteria,"doNotEdit")!==false)$json_selection_criteria="";
            
            if($json_selection_criteria){
                $currentSelectionCriteria=buildQueryBase(false,true);//We'll pass the current selection to load after submit or on cancel.
                $selJS.="
                <script type='text/javascript'>
                    $(\"#tagEdit_load_sel_button\").click(function(event){
                        event.preventDefault();
                        var selection_criteria=$json_selection_criteria;
                        var currentSelectionCriteria=$currentSelectionCriteria;
                        loadRangeCriteriaEdit(selection_criteria,$range_num,currentSelectionCriteria);
                });
                    
                </script>";
            }
            
            $html.="    
                <table width='100%' style='height:100%' border='0'>
                    <tr><td class='tagLabel'><span style='float:left;'>$backArrow</span>Tag:</td><td class='tagData'><textarea readonly style='width:95%;' rows='3' >$tag_name</textarea></td></tr>
                    <tr><td class='tagLabel'>Comment:</td><td style='height:95%;' class='tagData'><textarea readonly style='width:95%;height:95%;' rows='3' >$tag_comment</textarea></td></tr>";
            if($tag_description)$html.="<tr><td class='tagLabel'>Selection<br>Criteria</td><td class='tagData'><textarea readonly style='width:95%;' rows='2'>$tag_description</textarea></td></tr>";
            $html.="<tr><td valign='top' class='tagLabel'>$dateLabel</td><td valign='top' class='tagData'>$date</td></tr>";
                    
            if($prelim)$html.="<tr><td class='tagLabel'><td class='tagData'>*This tag is <span style='font-weight: bold;font-style: italic;'>preliminary</span></td></tr>";
            
            $showData=getShowRangeMembersLinks($range_num);
            $html.="<tr><td></td><td class='tagData' valign='bottom' style='height:100%' >This${rsi} tag is ${prettyRowCount}.<br>$showData</td></tr>";
            
            #Message explaining why buttons are disabled?
            if(!$rangeIsEditable)$html.="<tr><td colspan='2' class='tiny_data'>This tag can not be edited here be cause it is syncronized from another data source.</td></tr>";
            
            #buttons
            if($canEdit)$editbtn="<button id='tagEdit_edit_button'>Edit Tag</button>".getButtonJS('tagEdit_edit_button','tagEdit_edit',$range_num);
            else $editbtn="<button disabled>Edit Tag</button>";
            if($canAppend)$appendbtn="<button id='tagEdit_append_button'>Add Comment</button>".getButtonJS('tagEdit_append_button','tagEdit_append',$range_num);
            else $appendbtn="<button disabled>Add to Tag</button>";
            if(userAccess("insert")&& false)$addtobtn="<button id='tagEdit_addto_button'>Add selection to tag</button>".getButtonJS('tagEdit_addto_button','tagEdit_addto',$range_num);
            else $addtobtn="<button disabled>Add selection to tag</button>";
            if($canDelete){
                $msg="This${rsi} tag is ${prettyRowCount}.  Deleting this tag is not reversible.  Are you sure you want to continue?";
                $delbtn="<button id='tagEdit_delete_button'>Delete Tag</button>".getButtonJS('tagEdit_delete_button','tagEdit_delete',$range_num,'',$msg);
            }
            else $delbtn="<button disabled>Delete Tag</button>";
            if($json_selection_criteria){
                if($canEdit)$loadSelBtn="<button id='tagEdit_load_sel_button'>Edit Range Criteria</button>".$selJS;
                else $loadSelBtn="<button disabled>Edit Range Criteria</button>";
            }else $loadSelBtn="";
            
            $html.="<tr><td align='center' colspan='2'>$appendbtn $editbtn $delbtn $loadSelBtn ".helpLink("Tag Details")."<span title='Range:$range_num' style='float:right;'>&nbsp;&nbsp;&nbsp;</span></td></tr>
                </table></form>
            ";#$addtobtn
        }else{
            $html.="Tag range ($range_num) no longer exists
            <script language='JavaScript'>
                clearTagEditForm('');//Clear after a slight delay
            </script>";
            
        }
    }
    return $html;
}
function getShowRangeMembersLinks($range_num,$forReview=false,$event_num=""){
    #build links to dynamically load the range members
    #For review function does some slightly different details.  It uses event num for some display.
    $uid=uniqid();
    $showData="";
    
    if($forReview){
        $showData.="
        Show <a href='' id='showRangeDMembersLink_$uid'>Tagged Measurements</a><div id='showRangeDMembersDialog_$uid' title='Measurements attached to this tag range'>Loading...</div>";
        if($event_num)$showData.="<br>Show <a href='' id='showEventMeasurementsLink_$uid'>All Measurements</a> from Sample<div id='showEventMeasurementsDialog_$uid' title='Measurements from sample'>Loading...</div>";
        $showData.="
        <script language='JavaScript'>
        $(\"#showEventMeasurementsDialog_$uid\").dialog({
            modal:true,
            width: 800,
            height: 300,
            autoOpen: false,
            open: function (){
                $(this).load('switch.php?doWhat=getDataForEvent&event_num=$event_num&range_num=$range_num');
               
            }
        });
        $(\"#showEventMeasurementsLink_$uid\").click(function(event){
            event.preventDefault();
            $(\"#showEventMeasurementsDialog_$uid\").dialog(\"open\");
        });
        $(\"#showRangeDMembersDialog_$uid\").dialog({
            modal:true,
            width: 800,
            height: 300,
            autoOpen: false,
            open: function (){
                $(this).load('switch.php?doWhat=getDataForRange&range_num=$range_num');
               
            }
        });
       
        $(\"#showRangeDMembersLink_$uid\").click(function(event){
            event.preventDefault();
            $(\"#showRangeDMembersDialog_$uid\").dialog(\"open\");
        });
        </script>";
    }else{
        $showData.="<a href='' id='showRangeEvMembersLink_$uid'>Show Events</a> <div id='showRangeEvMembersDialog_$uid' title='Events attached to this tag range'>Loading...</div>
        <a href='' id='showRangeDMembersLink_$uid'>Show Measurements</a><div id='showRangeDMembersDialog_$uid' title='Measurements attached to this tag range'>Loading...</div>
        <script language='JavaScript'>
        $(\"#showRangeEvMembersDialog_$uid\").dialog({
            modal:true,
            width: 600,
            height: 300,
            autoOpen: false,
            open: function (){
                $(this).load('switch.php?doWhat=getEventsForRange&range_num=$range_num');
               
            }
        });
        $(\"#showRangeEvMembersLink_$uid\").click(function(event){
            event.preventDefault();
            $(\"#showRangeEvMembersDialog_$uid\").dialog(\"open\");
        });
        $(\"#showRangeDMembersDialog_$uid\").dialog({
            modal:true,
            width: 800,
            height: 300,
            autoOpen: false,
            open: function (){
                $(this).load('switch.php?doWhat=getDataForRange&range_num=$range_num');
               
            }
        });
       
        $(\"#showRangeDMembersLink_$uid\").click(function(event){
            event.preventDefault();
            $(\"#showRangeDMembersDialog_$uid\").dialog(\"open\");
        });
        </script>";
    }
    return $showData;
}
function getEventsForRange($range_num){
    /*Returns a table of events for passed rangenum*/
    $html="";
    if($range_num){
        doquery("drop temporary table if exists t_range_evs",false);
        $sql="create temporary table t_range_evs as
                select event_num from flask_event_tag_range where range_num=$range_num
                union
                select d.event_num from flask_data d, flask_data_tag_range r where d.num=r.data_num and r.range_num=$range_num";
        doquery($sql,false);
        bldsql_init();
        bldsql_from("flask_event_view e");
        bldsql_from("t_range_evs as t");
        bldsql_where("t.event_num=e.num");
        #bldsql_where("r.range_num=?",$range_num);
        bldsql_col("e.event_num");
        bldsql_col("e.site");
        bldsql_col("e.project");
        bldsql_col("e.strategy");
        bldsql_col("prettyEvDate as date");
        bldsql_col("id as 'Flask ID'");
        bldsql_col("me");
        bldsql_col("lat");
        bldsql_col("lon");
        bldsql_col("alt");
        bldsql_col("elev");
        #bldsql_col("comment");
        bldsql_orderby("timestamp(e.date,e.time)");
        $html=printTable(doquery());
    }
    return $html;
}

function getDataForRange($range_num){
    
    /*Returns a table of flaskdata rows for passed rangenum*/
    $html="";
    if($range_num){
        #build temp table of target rows.
        doquery("drop temporary table if exists t_range_ds",false);
        $sql="create temporary table t_range_ds as
                select data_num from flask_data_tag_range where range_num=$range_num
                union
                select d.num as data_num from flask_data d, flask_event_tag_range r
                    where d.event_num=r.event_num and r.range_num=$range_num
                    and d.parameter_num not in(58,59,60,61,62)";#Leave out wind, press... when getting an events rows.

        doquery($sql,false);
        
        #We'll sort on ev/meas date depending on the type of tag.
        $isMeas=doquery("select measurement_issue from tag_range_info_view where range_num=$range_num",0);

        #build the concat'd list of tag tables.  We'll left join these to the main view to get the rows associated tags.
        /*$dtable="left join (select data_num,group_concat(flag separator ',') as tags
                    from flask_data_tag_view
                    group by data_num) as dt on d.data_num=dt.data_num";
        $etable="left join (select event_num, group_concat(flag separator ',') as tags
                    from flask_event_tag_view
                    group by event_num) as et on d.event_num=et.event_num";*/
        #Actually, these perform terribly once the tags table got large.  I think because below does a left join on a very large
        #derived table that can't have an index (because it's derived).  So we'll re-write with explicit temp tables to speed up.
        $dtable="";$etable="";
        doquery("drop temporary table if exists t__dt,t__et",false);
        #data tags
        $sql="create temporary table t__dt (index (data_num)) as
                select v.data_num,group_concat(v.flag separator ',') as tags
                    from flask_data_tag_view v join t_range_ds r on v.data_num=r.data_num
                    group by v.data_num";
        doquery($sql,false);
        $dtable="left join t__dt as dt on d.data_num=dt.data_num";#for big select below.
        #event tags
        $sql="create temporary table t__et (index (event_num)) as
                select v.event_num, group_concat(distinct v.flag separator ',') as tags
                    from flask_event_tag_view v
                    where v.event_num in (select d.event_num from flask_data d, t_range_ds r where r.data_num=d.num)
                    group by v.event_num";
        doquery($sql,false);
        $etable="left join t__et as et on d.event_num=et.event_num";#for big select below.
        
        bldsql_init();
        bldsql_from("flask_data_view d join t_range_ds t on t.data_num=d.data_num $dtable $etable");
        #bldsql_from("t_range_ds t");
        #bldsql_where("t.data_num=d.data_num");
        bldsql_where("d.parameter_num not in(58,59,60,61,62)");
        bldsql_col("d.event_num as Event");
        bldsql_col("d.data_num as 'Data #'");
        bldsql_col("d.site");
        bldsql_col("d.project as 'Proj.'");
        bldsql_col("d.strategy as 'Strat.'");
        bldsql_col("d.program as 'Prog.'");
        bldsql_col("d.prettyEvDate as 'Date'");
        bldsql_col("flask_id as 'Flask ID'");
        bldsql_col("d.parameter as Species");
        bldsql_col("d.value");
        bldsql_col("d.unc");
        bldsql_col("d.prettyADate as 'Anal. Date'");
        bldsql_col("d.flag");
        bldsql_col("concat_ws(',',dt.tags,et.tags) as Tags");
        
        #bldsql_col("et.tags as 'sample tags'");
        if($isMeas)bldsql_orderby("timestamp(d.date,d.time)");
        bldsql_orderby("timestamp(d.ev_date,d.ev_time)");
        #return bldsql_printableQuery();
        $html=printTable(doquery());
    }
    return $html;
}
function getDataForEvent($event_num,$range_num=""){
    #nums in optional range_num will get highlighted
    $data_nums="";
    if($event_num){
        #If range num passed, get list of member flask_data rows to highlight.
        #this could be a left join, but that got confusing with two below so separated out for clarity.
        if($range_num){
            bldsql_init();
            bldsql_from("flask_data_tag_view t");
            bldsql_where("t.range_num=$range_num");
            bldsql_col("group_concat(t.data_num) as data_nums");
            bldsql_groupby("t.range_num");
            $data_nums=doquery("",0);
        }
        
        #build the concat'd list of tag tables.  We'll left join these to the main view to get the rows associated tags.
        /*$dtable="left join (select data_num,group_concat(flag separator ',') as tags
                    from flask_data_tag_view
                    group by data_num) as dt on d.data_num=dt.data_num";
        $etable="left join (select event_num, group_concat(flag separator ',') as tags
                    from flask_event_tag_view
                    group by event_num) as et on d.event_num=et.event_num";
        */
        #Actually, these perform terribly once the tags table got large.  I think because below does a left join on a very large
        #derived table that can't have an index (because it's derived).  So we'll re-write with explicit temp tables to speed up.
        $dtable="";$etable="";
        doquery("drop temporary table if exists t__dt,t__et",false);
        #data tags
        $sql="create temporary table t__dt (index (data_num)) as
                select v.data_num,group_concat(v.flag separator ',') as tags
                    from flask_data_tag_view v join flask_data d on v.data_num=d.num
                    where d.event_num=$event_num
                    group by v.data_num";
        doquery($sql,false);
        $dtable="left join t__dt as dt on d.data_num=dt.data_num";#for big select below.
        #event tags
        $sql="create temporary table t__et (index (event_num)) as
                select v.event_num, group_concat(distinct v.flag separator ',') as tags
                    from flask_event_tag_view v
                    where v.event_num=$event_num
                    group by v.event_num";
        doquery($sql,false);
        $etable="left join t__et as et on d.event_num=et.event_num";#for big select below.
                    
                    
        bldsql_init();
        bldsql_from("flask_data_view d $dtable $etable");
        bldsql_where("d.event_num=?",$event_num);
        bldsql_where("d.parameter_num not in(58,59,60,61,62)");
        if($data_nums)bldsql_col("case when d.data_num in ($data_nums) then 'highlightRow' else '' end as rowClass");
        else bldsql_col("'' as rowClass");#place holder
            
        bldsql_col("d.event_num as Event");
        bldsql_col("d.data_num as 'Data #'");
        bldsql_col("d.site");
        bldsql_col("d.project as 'Proj.'");
        bldsql_col("d.strategy as 'Strat.'");
        bldsql_col("d.program as 'Prog.'");
        bldsql_col("d.prettyEvDate as 'Date'");
        bldsql_col("flask_id as 'Flask ID'");
        bldsql_col("d.parameter as Species");
        bldsql_col("d.value");
        bldsql_col("d.unc");
        bldsql_col("d.prettyADate as 'Anal. Date'");
        bldsql_col("d.flag");
        bldsql_col("concat_ws(',',dt.tags,et.tags) as Tags");
        #bldsql_col("et.tags as 'sample tags'");
        
        bldsql_orderby("d.program,d.parameter");
        #return bldsql_printableQuery();
        $html=printTable(doquery(),'',1);
    }
    return $html;
    
}




?>