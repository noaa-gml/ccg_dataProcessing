<?php
#Various functions for the aircraft tag review logic.

require_once("../lib/funcs.php");

function getPlotDivs(){
    #Returns structure for plot area.
    $buttons[]=array('label'=>'Values','js'=>'air_showValuesPlots');
    $buttons[]=array('label'=>'Profiles','js'=>'air_showProfilesPlots');
    $html="<div></div><div id='valuesPlots'></div><div id='profilesPlots'></div><div class='hidden' id='plotsJSDiv'></div>";
    return $html;
}

function getSiteSelector(){
    #Returns site selector + controls
    $html="";
    #Get counts of unreviewed (tag 6) tags by site.  We'll filter by site to give optimizer options, but these should all be aircraft anyway.
    bldsql_init();
    bldsql_from("flask_ev_data_view d");
    bldsql_from("flask_data_tag_view t");
    bldsql_where("d.data_num=t.data_num");
    bldsql_where("d.project_num=2");#Aircraft
    bldsql_where("t.tag_num=97");
    bldsql_where("t.data_source=6");#auto air tagging scripts
    bldsql_col("d.site_num");
    bldsql_col("count(distinct t.range_num) as num_tags");
    bldsql_groupby("d.site_num");
    bldsql_into("t_tagCounts", "i(site_num)");
    doselectinto();

    #Fetch out site list for selector, left join to above for counts/grouping.
    bldsql_init();
    bldsql_distinct();
    bldsql_from("flask_event_view e left join t_tagCounts c on e.site_num=c.site_num");
    bldsql_where("e.project_num=2");#Aircraft
    bldsql_where("e.site not in ('bld','tst')");
    #bldsql_where("e.strategy_num=2");#PFP
    bldsql_col("e.site_num as 'value'");
    bldsql_col("concat(e.site, case when c.site_num is not null then '*' else '' end) as 'display_name'");
    #bldsql_col("case when c.site_num is null then 'Other sites' else 'Sites with tags to review (#)' end as group_name");
    bldsql_orderby("case when c.site_num is null then 1 else 0 end, e.site");

    $sites=getSelectInput(doquery(),'air_siteSelector','','air_siteSelected',false,'275px',false,false,'',-8);

    #Build the output. Note the prelim checkbox and lookback aren't fully programmed yet and so disabled.
    #jwm-7/13 - moved '<tr><td colspan='2'><div id='navWidgetDiv'></div></td></tr>' outside of first table/form so that we wouldn't get a nested form.
    $html="
    <form id='air_selectForm' autocomplete='off'>
    <input type='hidden' id='air_issueType' name='air_issueType' value='tag6'>
    <table width='100%'>
        <tr><td colspan='2' class='title4'>Select Site (* has unreviewed tags)</td></tr>
        <tr><td colspan='2'>$sites</td></tr>
        <tr>
            <td class='small_data'><input class='reloadSiteListOnClick' type='checkbox' id='air_prelimOnly' name='air_prelimOnly' checked><span>Un-reviewed tags</span></td>
            <td class='small_data' align='right'><span>Show +/- <input class='reloadSiteListOnClick' size='2' id='air_lookback' name='air_lookback' value='12'> months</td>
        </tr>

    </table>
    </form>
    <table width='100%'>
        <tr><td colspan='2'><div id='navWidgetDiv'></div></td></tr>
    </table>
    <script language='JavaScript'>$('.reloadSiteListOnClick').change(function(event){
                        event.preventDefault();
                        air_siteSelected();//Reload site.
                    });
    </script>";
    
    return $html;
}

function air_getNavWidget(){
    #Returns the navigation widget for a selected site.Note this is limited to data tags (no event based tags)
    $site_num=getHTTPVar("air_siteSelector",'',VAL_INT);
    $prelimOnly=getHTTPVar("air_prelimOnly",false,VAL_BOOLCHECKBOX);
    $html="";
    if($site_num){
        bldsql_init();
        bldsql_from("flask_data_tag_view t");
        bldsql_from("flask_data_view d");
        bldsql_where("d.data_num=t.data_num");
        if($prelimOnly)bldsql_where("t.prelim=1");
        bldsql_where("d.project_num=2");#air
        bldsql_where("d.program_num=1");#ccgg
        #bldsql_where("d.strategy_num=2");May want to limit to pfps, but will leave open for now.
        bldsql_where("d.site_num=?",$site_num);
        bldsql_where("t.tag_num in (96,97)");#96=>..5 97=>6..  If filtered to prelim, then this will be all 6s because 5s dont get created preliminary.
        bldsql_where("t.data_source=6");#auto air tagging scripts
        $d="concat_ws(' | ',d.ev_date,d.site,concat('alt:',d.alt)) as display_name";
        bldsql_col($d);
        bldsql_col("d.event_num");
        bldsql_col("t.range_num");
        bldsql_orderby("d.ev_datetime");
        bldsql_distinct();#there will be one for each gas, so distinctify.
        $a=doquery();
        if($a){
            #Build a js array to hold each tag/event
            $json=arrayToJSON($a);
            
            #Build controller buttons.
            $prevBtn=getJSButton("air_prevBtn","air_loadPrevRange","Previous");
            $nextBtn=getJSButton("air_nextBtn","air_loadNextRange","Next");
                   
            $html="<br>
            <table width='100%' border='0'>
                <tr><td align='right' width='50%'><span id='listCounter' style='float:left;'></span>$prevBtn</td><td align='left'>$nextBtn<span class='tiny_ital' id='nextBtnTxt'></span></td></tr>
                <tr><td colspan='2' align='center'><div id='currentEventDisplayDiv'></div></td>
            </table>
            <div id='navWidgetJSDiv' class='hidden'></div>
            <script language='JavaScript'>
                air_tagRangeList=$json;
                //Reset nav controller vars.
                air_currentRangeData=false;air_nextRangeData=false; air_prevRangeData=false;
                air_currentRange=-1;air_nextRange=-1;air_prevRange=-1;
                
                //Default buttons to disabled.
                $('#air_nextBtn').prop('disabled',true);
                $('#air_prevBtn').prop('disabled',true);
                
                air_loadNextRange();//Load the first one.
            </script>";
        }
    }
    
    return $html;
    
    
    
   
}


function air_fetchNextRange($range_num,$range_index){
    #Returns plot data for passed range and sets into the next control.
    
    $a=air_getPlotsData($range_num);//Actual plot x,y data
    
    #build a description for the plots:
    $description="";
    $json=doquery("select json_selection_criteria from tag_ranges where num=?",0,array($range_num));
    if($json){
        #Aircraft automated tagging should have alt bin in json selection criteria
        $jsonArr=JSONToArray($json);
        if(isset($jsonArr['ev_from_alt'])) $description.="Alt bin from: ".$jsonArr['ev_from_alt'];
        if(isset($jsonArr['ev_to_alt'])) $description.=" to: ".$jsonArr['ev_to_alt'];
    }
    
    #Now we'll build up the json array/obj that the js functions are expecting.  see js sp2_createPlots for details.
    $jsData="";
    foreach($a as $label=>$data){
        $series=sp_getSinglePlotSeriesJSON($data,$label);#Plot data
        $d="{plotsTitle:\"$description\",onClickMethod:'air_plotClickHandler', series:$series}";#Plot obj data
        
        $jsData=appendToList($jsData,$d);#Concat all together

    }
    $jsData="var d=[$jsData];";
    $html="<script language='JavaScript'>$jsData air_setNextRange($range_index,d);</script>";#
    return $html;
}




//Plot Data Fetchers
/*function air_loadPlots(){
    #Returns main plot area content.
    #build a description for the plot:
    $html=getSinglePlots(air_loadPlotData(),"","","850","150","","air_plotClickHandler");
    return $html;
}*/



function air_getPlotsData($range_num,$startDate='',$endDate=''){
    #Returns plots data
    #If fromDate/toDate are passed, we'll use those to bracket data (like when called from slider button).  Otherwise we'll calc dates around range event.
    $lookback=getHTTPVar("air_lookback",12,VAL_INT);#NOTE not working.. form isn't passed on this call currently.
    
    $html="";$jsonArr="";$flaskData=true;$plotRowLimit=8000;//arbitrary, but too big causes ajax errors.
    $rangeStartDate='';$rangeEndDate='';
    $parameterList=array("CO","CO2","CH4","H2","N2O","SF6");#default parameter list
    $hatsParameterList=array('C2H2','F134A','H1211');
    $ret=array();
    
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
    bldsql_col("d.event_num");
    bldsql_orderby("d.ev_date");
    bldsql_limit(1);#We just need the first date.

    $a=doquery();

    if($a){
        $json="";$data_num="";$params=array();$minDate="";$maxDate="";
        extract($a[0]);#json & data_num and event_num

        if($json){
            #If there was a criteria set, parse it out and attempt to get some filters to use.. otherwise we'll just use 'sane' ones.
            $jsonArr=JSONToArray($json);            
        }

      
        #Get the range's date range to highlight
        doquery("drop temporary table if exists t_range_nums",false);
        doquery("create temporary table t_range_nums as select num from tag_ranges where num=$range_num",false);
        doquery("call tag_getTagRangeInfo()",false);
        bldsql_init();
        bldsql_from("t_range_info");
        bldsql_col("startDate as rangeStartDate");
        bldsql_col("endDate as rangeEndDate");
        $a=doquery();        
        if($a){
            extract($a[0]);
        }
      
         #combined params, prevent overlap (eg sf6).
        $paramsWhr="((d2.program='ccgg' and d2.parameter in ('".implode("','",$parameterList)."'))
            or (d2.program='hats' and d2.parameter in ('".implode("','",$hatsParameterList)."')))";
        
        
        #Now build the query to pull out the data.  Our caller is expecting a result set for each param, so we'll loop through
        $t=array_merge($parameterList,$hatsParameterList);
        foreach($t as $parameter){
            air_buildPlotDataBaseQuery($data_num,$jsonArr,true);
            bldsql_from("flask_data_view d2 left join flask_data_tag_range r on d2.data_num=r.data_num and r.range_num=$range_num");
            #Double size the range members, highlight any flagged data.
            bldsql_col("case when r.data_num is not null then 2 when d2.flag like '.%' then 0 else 1 end as hl");
            
            bldsql_where($paramsWhr);
            
            bldsql_where("d2.value>-999");
            #Filter dates by lookback or passed values.
            if($minDate)bldsql_where("d2.ev_date>=?",$minDate);
            else bldsql_where("d2.ev_datetime >= date_add(d.ev_datetime, interval -(?) MONTH)",$lookback);
            if($maxDate)bldsql_where("d2.ev_date<=?",$maxDate);
            else bldsql_where("d2.ev_datetime <= date_add(d.ev_datetime, interval ? MONTH)",$lookback);
            
            bldsql_col("d2.ev_datetime as x");
            bldsql_col("d2.value as y");
            bldsql_col("d2.ev_dd as dd");#For averageing logic.
            bldsql_col("d2.data_num as num");#For click handler
            
            bldsql_orderby("d2.program");
            bldsql_orderby("d2.parameter");
            bldsql_orderby("timestamp(d2.ev_date,d2.ev_time)");
            bldsql_limit($plotRowLimit);
            
            bldsql_where("d2.parameter=?",$parameter);
            $ret[$parameter]=doquery();

        }
       
    
    }
    
    return $ret;
   
}

function air_buildPlotDataBaseQuery($data_num,$jsonArr,$skipEvDateTime=false){
    #Just for reuse
    bldsql_init();
    bldsql_from("flask_data_view d");
    bldsql_where("d.data_num=?",$data_num);
    bldsql_where("d.site_num=d2.site_num");#d2 is joined above by caller
    bldsql_where("d.project_num=d2.project_num");    
    bldsql_where("d.strategy_num=d2.strategy_num");
    if(!$skipEvDateTime)bldsql_col("d2.ev_datetime");
    if(isset($jsonArr['ev_from_alt']))#Aircraft automated tagging, filter on alt if there.
        bldsql_where("d2.alt>=?",$jsonArr['ev_from_alt']);
    if(isset($jsonArr['ev_to_alt']))
        bldsql_where("d2.alt<=?",$jsonArr['ev_to_alt']);
}

//Event Form/Tag editor
function air_loadEventDataPopup(){
    $html=air_loadEventTagDisplay();
    return getPopupAlert($html,true,"");#Wrap in a popup
}
function air_loadEventTagDisplay(){
    #Return display area for event data and tag edit/add form.
    $event_num=getHTTPVar("event_num",'',VAL_INT);
    $range_num=getHTTPVar("range_num",'',VAL_INT);
    $data_num=getHTTPVar("data_num",'',VAL_INT);
    $html='';
    if(!$event_num)$event_num=doquery("select event_num from flask_data where num=?",0,array($data_num));
    if($event_num){
        if($range_num){
            #Editing the pre-created ranges
            $html=air_loadRangeEditForm($event_num,$data_num,$range_num);
        }else $html=air_loadTagAddForm($event_num,$data_num,$range_num);
    }else $html='Error; missing event/data num.';
    return $html;
}
function air_loadEventData($event_num,$data_num='',$range_num=''){
    #Requires event_num and either data_num or range_num
    #Returns html to show an event data for posted event/data_num
    
    #Specialized for aircraft tagging,  tag editing limited to auto aircraft single event tags, or adding new ones.  
    $html="";$profileBtn="";
    if($event_num &&($range_num || $data_num)){
        #Build event details
        bldsql_init();
        bldsql_from("flask_event_view e");
        bldsql_where("e.event_num=?",$event_num);
        bldsql_col("e.prettyEvDate as date");
        bldsql_col("e.site");
        bldsql_col("e.flask_id");
        bldsql_col("e.project");
        bldsql_col("e.strategy");
        bldsql_col("e.me");
        bldsql_col("e.lat");
        bldsql_col("e.lon");
        bldsql_col("e.alt");
        bldsql_col("e.elev");
        bldsql_col("e.comment");
        
        $a=doquery();
        if($a){
            extract($a[0]);
            $html.="        
                <div class='title4'>Event: $event_num &nbsp;&nbsp;Flask:$flask_id </div>
                <div class='label' style='text-align:center'><span class='title4'>$site</span> - $date</div>
                <div><span class='data'>Lat: </span><span class='label'>$lat </span> <span class='data'>Lon: </span><span class='label'>$lon</span></div>
                <div><span class='data'>Alt: </span><span class='label'>$alt </span> <span class='data'>Elev: </span><span class='label'>$elev</span></div>
            ";
                
            #Build up the ccgg data display
            #Make call to tag details proc to build formatted details
            doquery("drop temporary table if exists t_data_nums",false);
            doquery("create temporary table t_data_nums (index (num)) as select num from flask_data where event_num=? and program_num=1",false,array($event_num));
            doquery("call tag_getTagDetails()",false);
            
            bldsql_init();
            $lj=($range_num)?"left join flask_data_tag_view v on d.data_num=v.data_num and v.range_num=$range_num":"";
            bldsql_from("flask_data_view d left join t_tag_details t on d.data_num=t.data_num $lj");
            bldsql_where("d.event_num=?",$event_num);
            bldsql_where("d.program_num=1 and d.parameter_num<7");#ccgg
            bldsql_orderby("d.parameter_num");
            bldsql_col("d.data_num as ev_data_num");
            bldsql_col("d.parameter");
            bldsql_col("d.value");
            bldsql_col("d.flag");
            bldsql_col("t.tags");
            bldsql_col("t.tag_details_html");
            bldsql_col("case when t.tags like '%2%' then 1 else 0 end as outlier");
            if($range_num)bldsql_col("case when v.range_num is not null then 'checked' else '' end as checked");
            else bldsql_col("case when d.data_num=$data_num then 'checked' else '' end as checked");#New ones, just the selected checked..
            $a=doquery();
            
            if($a){
                $g="<table class='dbutils'><tr><th>Species</th><th>Value</th><th>Flag</th><th>Tags</th></tr>";
                $allChecked=true;#track if all were checked for control widget.
                foreach($a as $i=>$row){
                    extract($row);
                    if(!$checked)$allChecked=false;
                    $style=($outlier)?"style='border:medium red inset;'":"";
                    $popup=($tag_details_html)?getPopUp($tag_details_html,"$tags","$parameter tags",'',false):"$tags";
                    $selected=($data_num==$ev_data_num)?"class='dbutils_selectedRow'":"";
                    $disabled=($data_num)?"disabled":"";
                    $g.="<tr $selected><td><input type='hidden' name='air_data_num_$i' value='$ev_data_num'><input $disabled class='air_includeNumInRange' $checked type='checkbox' id='air_includeNumInRange_$i' name='air_includeNumInRange_$i'>$parameter</td><td>$value</td><td>$flag</td><td $style>$popup</td></tr>";
                }
                $checked=($allChecked)?"checked":"";
                $show=($allChecked)?"hide":"show";#Initial state of the indiv chk boxes.
                $html.="$g</table>";
                if(!$data_num)$html.="
                <input $checked type='checkbox' id='air_includeAllNumsInRange' name='air_includeAllNumsInRange'>Include all ccgg gases in tag.
                <script language='JavaScript'>
                    $('.air_includeNumInRange').$show();
                    $('#air_includeAllNumsInRange').click(function(event){
                        $('.air_includeNumInRange').toggle();
                    });
                </script>";
                
            }
        }
    }else $html="Error; missing required identifier numbers (event,data,range) in air_loadEventData()";
    return $html;
}
function air_loadRangeEditForm($event_num,$data_num,$range_num){
    #Build up the form for the tag edit part.  This is the 'simplified' confirm 6/mark as 5 if range_num passed or a full on tag edit form.
    #Its assumed to be from the automated tagging system (5 or 6)
    #Range and event num are required.
    $tag_desc='';$range_comment='';$range_prelim='';$json_selection_criteria='';$tag_num='';$canAppend=false;$canEdit=false;$html='';
    
    #Set up tables for security checks to see what user can do
    createTagProcTempTables();
    doquery("insert t_data_nums select num from flask_data where event_num=? and program_num=1",false,array($event_num));
    if($range_num && $event_num){
        
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
        $profileBtn=getJSButton('profilesBtn',"showProfilesPlots",'Profiles',$event_num);#Only show profiles when in sidebar, not when clicked from plot.
        $formTitle=($range_prelim)?"":"This tag has been reviewed";
        $warning=(!$range_prelim)?"This event has already been reviewed.  Are you sure you want to change it?":"";
        $saveNote=($range_prelim)?"This tag is preliminary.  Click Save to finalize.":"";
        $submitBtn=getJSButton("air_submitTagEditBtn",'air_submitTagEdit','Save','','',$warning,'air_right');
        $radioBtnVals=array();
        $radioBtnVals[97]="1st Col <span class='air_reject'>REJECT</span><br><span class='tiny_ital'>(6..) Outlier in 1 or more CCGG gases and confirmed leak from analysis of HATS tracer gases</span></br>";
        $radioBtnVals[96]="3rd Col <span class='air_warn'>WARN</span><br><span class='tiny_ital'>(..5) Outlier in 1 or more CCGG gases and suspected leak from analysis of HATS tracer gases</span><br>";
        $radio=getRadioBtnInputs('tagEdit_tag_num',$radioBtnVals,$tag_num);
        
        if(userAccess("edit")){
            $html.="<br><br>
            <form id='tagEditForm'>
            <div style='float:right;'>$profileBtn</div>
            <div style='width:90%;border:thin outset black;'>
                ".air_loadEventData($event_num,$data_num,$range_num)."
            </div>
            
            <div id='rev_rangeEditDiv' style='height:100%;vertical-align: top;'>
                <div id='tagEditFormDiv'>
                    <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value='$range_num'>
                    <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='edit'>
                    <input type='hidden' id='tagEdit_existingComment' name='tagEdit_existingComment' value='$range_comment'>
                    <table width='100%' >
                        <tr>
                            <td colspan='2' valign='top' align='right'><span style='float:left;' class='title4'>$formTitle</span></td>
                        </tr>
                        <tr>
                            <td align='left' colspan='2'>
                                $radio
                                $submitBtn
                            </td>
                        </tr>
                        <tr><td align='right' class='tiny_ital' colspan='2'>$saveNote</td></tr>
                    </table>
                </div>
            </div>
            </form>";
        }else{#Just print
            $html.="Tag: $tag_desc applied to checked measurements.";
            if($range_prelim)$html.="This tag has not been reviewed yet.";
            else $html.="This tag has been confirmed.";
        }
    }else $html="Error; missing required identifiers (event, range) in air_loadRangeEditForm().";
    return $html;
}
function air_loadTagAddForm($event_num,$data_num,$range_num){
    #Build up the form for the tag edit part.  This is the 'simplified' confirm 6/mark as 5 if range_num passed or a full on tag edit form.
    #Its assumed to be from the automated tagging system (5 or 6)
    #eventHTML is event summary as returned by air_loadEventData()
    #$data_num and event_num are required.
    $tag_desc='';$range_comment='';$range_prelim='';$json_selection_criteria='';$tag_num='';$canAppend=false;$canEdit=false;$html='';
    
    #Set up tables for security checks to see what user can do
    createTagProcTempTables();
    doquery("insert t_data_nums select num from flask_data where event_num=? and program_num=1",false,array($event_num));
            
    #Add new; we'll limit it to the N.. tag for simplicity.
    if($data_num && $event_num){
        if(userAccess("edit")){
            #See if this measurement was already id'd by the auto logic.
            $isAutoTagged=doquery("select count(*) from flask_data_tag_view where tag_num in (96,97) and data_num=?",0,array($data_num));
            if($isAutoTagged){
                $html="<div>".air_loadEventData($event_num,$data_num,$range_num)."</div><div><br>This measurement has already been <br>identified/tagged by the automatic <br>filtiering logic.</div>";
            }else{
                $currFlag=doquery("select flag from flask_data where num=?",0,array($data_num));
                $currParam=doquery("select parameter from flask_data_view where data_num=?",0,array($data_num));
                $messg=($currFlag=='...')?'':"<div class='title4'>This $currParam measurement has already<BR> been flagged '$currFlag'.</div><BR><br>";
                $warning=($currFlag!='...')?"This measurement already has a flag of $currFlag.  Are you sure you want to add another tag?":"";
                $html="$messg $html";
                $submitBtn=getJSButton("air_submitTagEditBtn2",'air_submitTagEdit2','Add Tag','','',$warning,'air_right');
                $radioBtnVals=array();
                $radioBtnVals[12]="1st Col <span class='air_reject'>REJECT</span><br><span class='tiny_ital'>(N..) Sample collection problem/protocol error </span></br>";
                $radioBtnVals[13]="3rd Col <span class='air_warn'>WARN</span><br><span class='tiny_ital'>(..n) Sample collection problem/protocol error </span><br>";
                $radio=getRadioBtnInputs('tagEdit_tag_num',$radioBtnVals,12);
        
                $html.="
                <form id='tagEditForm2'>
                <div id='tagEditForm2_eventData'>".air_loadEventData($event_num,$data_num,$range_num)."</div>
                <div id='rev_rangeEditDiv2' style='height:100%;vertical-align: top;'>
                    <div id='tagEditFormDiv2'>
                        <input type='hidden' id='event_num' name='event_num' value='$event_num'>
                        <input type='hidden' id='data_num' name='data_num' value='$data_num'>
                        <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value=''>
                        <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='add'>
                        <input type='hidden' id='tagEdit_existingComment' name='tagEdit_comment' value=''>
                        <input type='hidden' id='tagEdit_data_num' name='tagEdit_data_num' value='$data_num'>
                        <table width='100%' >
                            <tr>
                                <td colspan='2' valign='top' align='right'><span style='float:left;' class='title4'>Add Tag to $currParam measurement?</span></td>
                            </tr>
                            <tr>
                                <td align='left' colspan='2'>
                                    $radio
                                    $submitBtn
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                </form><br>
                Or edit in <a href=\"../index.php?loadDataNum=$data_num\" target=\"_blank\">DataTagger</a>.";
            }
        }
    }else $html="Error; missing required identifiers (event, range) in air_loadTagAddForm().";
    return $html;
}


function air_submitTagEdit(){
    #First submit form, then update members (if needed);
    $ret=submitTagEdit("air_editForm");$js='';
    if($ret===true){#Returns true on success, some message else.
        #Now update range members.
        #This maybe should go through the submitTagEdit, but won't be used by the generic logic, so putting here for now..
        #Create needed temp tables:
        doquery("drop temporary table if exists t_data_nums, t_event_nums",false);
        doquery("create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0",false);
        doquery("create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0",false);
        
        #Figure out  which nums to include
        $all=getHTTPVar("air_includeAllNumsInRange",false,VAL_BOOLCHECKBOX);$nums='';$c=0;
        for($i=0;$i<6;$i++){#Loop through the 6 ccgg checkboxes... hardcoded # here for convienence
            if($all || getHTTPVar("air_includeNumInRange_$i",false,VAL_BOOLCHECKBOX)){#If all box is checked, then ignore the row's checkbox.
                $n=getHTTPVar("air_data_num_$i",false,VAL_INT);#The data_num
                if($n)if(doinsert("insert t_data_nums select ?",array($n)))$c++;#It would be more efficient to do this in one query, but we've only got a fixed number so not too bad... and easier.
            }
        }
        if($c){#at least 1 row still attached.
            $range_num=getHTTPVar("tagEdit_range_num",false,VAL_INT);
            $v_userID=db_getAuthUserID();
            if($range_num && $v_userID){
                #Fetch json and description from existing.. we'll just pass back thru without updating.
                $a=doquery("select json_selection_criteria as json,description from tag_ranges where num=?",-1,array($range_num));
                if($a){
                    extract($a[0]);
                    #call stored proc to do inserts and update external flags if needed.  Only if atleast 1 row
                    $sql="call tag_updateTagRangeMembers(?,?,?,?,@v_status,@v_mssg,@v_numrows)";
                    $bArray=array($v_userID,$range_num,$json,$description);
                    doquery($sql,false,$bArray);
                    #Fetch the status
                    $a=doquery("select @v_status as status, @v_mssg as mssg, @v_numrows as numrows");
                    #Unpack the return variables.
                    if($a)extract($a[0]);
                    if($status) $js="air_submitFailHandler(\"$mssg\");";
                    else $js="air_submitSuccesHandler();";
                }else $js="air_submitFailHandler(\"Range not found! $range_num\");";
            }else $js="air_submitFailHandler(\"Missing range/userid\");";
        }else $js="air_submitFailHandler(\"Must select at least 1 measurement.\");";
    }else $js="air_submitFailHandler(\"$ret\");";
    
    return "<script language='JavaScript'>$js</script>";
}
function air_submitTagEdit2(){
    $ret= submitTagEdit("air_editForm");
    if($ret===true){
        $event_num=getHTTPVar("event_num",'',VAL_INT);#Load ids from form
        $data_num=getHTTPVar("data_num",'',VAL_INT);
        #Refetch event for updated display
        #$html=air_loadEventData($event_num,$data_num,$range_num).;
        $html="<br><br><br><div class='title3'>Saved.</div>";
        $js="air_submitSuccesHandler2(\"$html\",$event_num,$data_num);";
    }else $js="air_submitFailHandler2(\"$ret\");";
    return "<script language='JavaScript'>$js</script>";
}


///Profile plot functions
function air_profilePlots($event_num){
    /*create a plot for a single pfp (all events), one willhave all gases, there there will be one for each gas with +- 6 pfps on each side.*/
    #air_getProfileEvents($event_num);#get events for this profile.
    $backBtn=getJSButton("backToValuesBtn","showValuesPlots","<- Back");
    $backBtn2=getJSButton("backToValuesBtn2","showValuesPlots","<- Back");
    $height='400px';$width='400px';
    $plot0=air_getAllGasesProfile($event_num);#load this one now, the rest async.
    
    $plot1=air_profilePlot($event_num,1);#co2
    $plot2=air_profilePlot($event_num,2);#ch4
    $plot3=air_profilePlot($event_num,3);#co
    $plot4=air_profilePlot($event_num,4);#h2
    $plot5=air_profilePlot($event_num,5);#n2o
    $plot6=air_profilePlot($event_num,6);#sf6
    $html="
    <div id='single_gas_profiles' style='width:100%;height:100%;'>
        <table >
            <tr><td colspan='2' align='center'><span style='float:left;'>$backBtn</span><div style='width:400px;height:300px;'>$plot0</div><br></td></tr>
            <tr><td colspan='2' align='center'><br><div class='title4'>Single gas profiles (+/- 6).  Selected event's profile is in Red.</div></td></tr>
            <tr><td><div style='width:$width;height:$height;'>$plot1</div><br></td><td><div style='width:$width;height:$height;'>$plot2</div><br></td></tr>
            <tr><td><div style='width:$width;height:$height;'>$plot3</div><br></td><td><div style='width:$width;height:$height;'>$plot4</div><br></td></tr>
            <tr><td><div style='width:$width;height:$height;'>$plot5</div><br></td><td><div style='width:$width;height:$height;'>$plot6</div><br></td></tr>
            <tr><td colspan='2'>$backBtn2</td></tr>
        </table>
    </div>";#note, something about the desc div (float maybe) causes it to go below the border.. hence the <br>s quick hack.
    #return $event_num.printTable(doquery("select * from t_profile_events n join flask_event e on n.num=e.num order by timestamp(e.date,e.time) "));
    return $html;
}
function air_profilePlot($event_num,$parameter_num){
    #printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts=''){
    /*Returns a profile plot for a single gas. event_num is a num (highlighted) from the pfp profile.  Profiles fill all tanks of pfp at different alts
    */
    $html="";
    #Find 6 pre/post profiles.  We'll select an event from each as representative.
    air_buildProfileBaseQuery($event_num);    
    
    bldsql_col("min(e2.num) as event_num");#pick one at random.
    #bldsql_col("concat(min(e2.date),' (',min(substring_index(e2.id,'-',1)),')') as profileID");
    bldsql_col("min(e2.date) as profileID");
    bldsql_col("abs(datediff(e.date,e2.date)) as dist");
    bldsql_groupby("e2.site_num");
    bldsql_groupby("e2.project_num");
    bldsql_groupby("e2.strategy_num");
    bldsql_groupby("e2.date");
    bldsql_groupby("e.date");
    bldsql_groupby("substring_index(e2.id,'-',1)");
    bldsql_where("e.date>=e2.date");
    bldsql_orderby("e2.date desc");
    bldsql_limit(7);#6+this event
    bldsql_into("t_profile_events");
    doselectinto();
     
    #Once again for post profiles...
    air_buildProfileBaseQuery($event_num);    
    bldsql_col("min(e2.num) as event_num");#pick one at random.
    bldsql_col("min(e2.date) as profileID");
    bldsql_col("abs(datediff(e.date,e2.date)) as dist");
    bldsql_groupby("e2.site_num");
    bldsql_groupby("e2.project_num");
    bldsql_groupby("e2.strategy_num");
    bldsql_groupby("e2.date");
    bldsql_groupby("e.date");
    bldsql_groupby("substring_index(e2.id,'-',1)");
    bldsql_where("e.date<e2.date");
    bldsql_orderby("e2.date");
    bldsql_limit(6);
    #bldsql_insert("t_profile_events");
    doinsert("insert t_profile_events ".bldsql_cmd());
    
    #Now for each of the 13 profiles, get the related event_nums and create a combined data table.  each profile will be a 'series' for the plot.
    $a=doquery("select event_num,profileID,dist from t_profile_events");
    
    if($a){
        doquery("drop temporary table if exists t_plot_data",false);
        doquery("create temporary table t_plot_data (event_num int,profileID varchar(255),color_index float)",false);
        $max=doquery("select max(dist) as m from t_profile_events",0);#min is always 0
        
        foreach($a as $row){
            air_getProfileEvents($row['event_num']);#fills temp table with relevant events.
            $c=$row['dist'];
            #the color_index field normalizes the distance of the sample to a 1-100 scale, which we'll translate to a greyscale below.
            doinsert("insert t_plot_data select num,?,case when $c=0 then 0 else ($c/$max)*100 end from t_event_nums",array($row['profileID']));
        }
        $desc=doquery("select distinct v.parameter as d from flask_data_view v where event_num=? and parameter_num=?",0,array($event_num,$parameter_num));
        bldsql_init();
        bldsql_from("t_plot_data t");
        bldsql_from("flask_data_view v");
        bldsql_where("t.event_num=v.event_num");
        bldsql_where("v.parameter_num=?",$parameter_num);
        bldsql_where("v.value>-999");
        bldsql_col("v.value as x");
        bldsql_col("v.alt as y");
        bldsql_col("t.profileID as series");
        #Mark the passed ev in red, others in descending shades of grey
        bldsql_col("case when t.color_index=0 then 'rgb(255,0,0)' else concat('rgb(',round(100+t.color_index,0),',',round(100+t.color_index,0),',',round(100+t.color_index,0),')') end as series_color");
        #build the hover label.
        bldsql_col("concat('Date:<b>',v.ev_date, '</b> Flask:<b>',v.flask_id,'</b> (<b>',v.parameter,'</b>): <b>',v.value,'</b> ',case when v.flag!='...' then concat('Flag:(<b>',v.flag,'</b>)') else '' end) as hoverLabel");
        #highlight the selected event.
        bldsql_col("case when v.event_num=$event_num then 1 when v.flag not like '.%' then 1 else 0 end as highlightPoint");
        
        bldsql_orderby("v.ev_datetime");
#printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts=''){
        $plot=printGraph(doquery(),'','','','default',array(),'',false,true,$desc,false);
        $html="<div style='width:100%;height:100%'>$plot</div>";
        #return printTable(doquery());
        doquery("drop temporary table t_plot_data",false);
    }
    return $html;
}
function air_getProfileEvents($event_num){
    #Fills t_event_nums with all events for a pfp aircraft profile.
    #NOTE; assumes pfp ids are always like ###[#]-#[#] (have a dash) and that the first part is the same for all flasks in the pfp.
    #NOTE; assumes that all samples from a profile are in a 24 hr period and from same 'site'
    air_buildProfileBaseQuery($event_num);    
    bldsql_where("substring_index(e.id,'-',1)=substring_index(e2.id,'-',1)");
    bldsql_where("abs(datediff(e.date,e2.date))<=1");
    bldsql_col("e2.num");
    bldsql_into("t_event_nums");
    bldsql_orderby("timestamp(e2.date,e2.time)");
    doselectinto();
}
function air_getAllGasesProfile($event_num){
    #Returns profile plot with all gases for profile containing event_num
    air_getProfileEvents($event_num);
    $desc=doquery("select distinct concat(v.site,': ',v.ev_date) as d from flask_event_view v where event_num=?",0,array($event_num));
    bldsql_init();
    bldsql_from("t_event_nums t");
    bldsql_from("flask_data_view v");
    bldsql_where("t.num=v.event_num");
    bldsql_col("avg(v.value) as 'mean'");
    bldsql_col("v.parameter_num");
    bldsql_groupby("v.parameter_num");
    bldsql_where("v.parameter_num in (1,2,3,4,5,6)");#probably shouldn't be hard coding this...
    bldsql_into("t_means");
    doselectinto();
    
    bldsql_init();
    bldsql_from("t_event_nums t");
    bldsql_from("flask_data_view v");
    bldsql_where("t.num=v.event_num");
    bldsql_from("t_means m");
    bldsql_where("v.parameter_num=m.parameter_num");
    bldsql_col("v.value/m.mean as x");
    bldsql_col("v.alt as y");
    bldsql_col("v.parameter as series");
    #build the hover label.
    bldsql_col("concat('Date:<b>',v.ev_date, '</b> Flask:<b>',v.flask_id,'</b> (<b>',v.parameter,'</b>): <b>',v.value,'</b> ',case when v.flag!='...' then v.flag else '' end) as hoverLabel");
    #highlight flagged points
    #bldsql_col("case when v.flag like '...' then 0 else 1 end as highlightPoint");
    bldsql_where("v.parameter_num in (1,2,3,4,5,6)");#probably shouldn't be hard coding this...
    bldsql_orderby("v.parameter");
    bldsql_orderby("v.alt");
    bldsql_orderby("v.ev_datetime");
    #printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts=''){
    $plot=printGraph(doquery(),'','','','default',array(),'',false,true,$desc,false);
    $html="<div class='title4'>Profile from $desc.  X axis is value/profile mean</div><div style='width:100%;height:100%'>$plot</div>";
    return $html;
}
function air_buildProfileBaseQuery($event_num){
    #builds the common parts of the profile joins.. purely for convienence.
    bldsql_init();
    bldsql_from("flask_event e");
    bldsql_from("flask_event e2");
    bldsql_where("e.num=?",$event_num);
    bldsql_where("e.site_num=e2.site_num");
    bldsql_where("e.project_num=e2.project_num");
    bldsql_where("e.strategy_num=e2.strategy_num");
    bldsql_where("e.project_num=2");#sanity check.. only relevant for air pfps.
    bldsql_where("e.strategy_num=2");#pfp
}


function getHelpText(){
    return "
    Instructions:<br>
-Select a site. <br>
&nbsp;Sites with an * have unreviewed tags. -<br>
&nbsp;The first un-reviewed event will be loaded and plots displayed.<br><br>
<ul>
<li>Plots:</li>
    <ul>
      <li>The selected event's measurements are marked with a double size black dot.
      <li>Other rejected measurements in the plot are marked with a black dot.
      <li>You can select a data point to see details and to add a N.. or ..n flag to any measurement that didn't get picked up by the algorithm.
      <li>You can adjust the y axis by dragging the sliders on the right of the plots
      <li>You can click the 'Profiles' button to see profile plots (back button to return).
    </ul>
   <li>Event area:
        <ul>
      <li>Event details and the 6 ccgg gases are displayed with their current 3 char flag and any applicable tags.
      <li>The ccgg outlier(s) is outlined in red
      <li>If you uncheck 'Include all ccgg gases in tag. ', you can deselect gases that you don't want to include in the tag
      <li>By default, the measurements are set to be rejected (6..).  You can change to a warning (..5)
      <li>Clicking 'Save' finalizes this tag and removes it from the list for future review
      <li>After clicking Save, the next event and plots will be automatically loaded for you to review
      <li>You can use the Next button to skip an event or the 'Previous button to go back to the last 1 event.
      </ul>
    </ul>";
}


/*
 *
 function air_loadEventDataOLD(){
    #Returns html to show an event/range edit form.
    #Specialized for aircraft tagging,  tag editing limited to auto aircraft single event tags, or adding new ones.
    
    #Requires event_num or data_num passed, optional range_num
    $event_num=getHTTPVar("event_num",'',VAL_INT);
    $range_num=getHTTPVar("range_num",'',VAL_INT);
    $data_num=getHTTPVar("data_num",'',VAL_INT);
  
    $html="";$profileBtn="";
    if($data_num || $event_num){#require one just for simplicity.. all callers will pass either or.
        if(!$event_num)$event_num=doquery("select event_num from flask_data where num=?",0,array($data_num));
        
        #Build event details
        bldsql_init();
        bldsql_from("flask_event_view e");
        bldsql_where("e.event_num=?",$event_num);
        bldsql_col("e.prettyEvDate as date");
        bldsql_col("e.site");
        bldsql_col("e.flask_id");
        bldsql_col("e.project");
        bldsql_col("e.strategy");
        bldsql_col("e.me");
        bldsql_col("e.lat");
        bldsql_col("e.lon");
        bldsql_col("e.alt");
        bldsql_col("e.elev");
        bldsql_col("e.comment");
        
        $a=doquery();
        if($a){
            extract($a[0]);
            $formID=($data_num)?"tagEditForm2":"tagEditForm";
            $html.="<form id='$formID'>          
                <div class='title4'>Event: $event_num &nbsp;&nbsp;Flask:$flask_id </div>
                <div class='label' style='text-align:center'><span class='title4'>$site</span> - $date</div>
                <div><span class='data'>Lat: </span><span class='label'>$lat </span> <span class='data'>Lon: </span><span class='label'>$lon</span></div>
                <div><span class='data'>Alt: </span><span class='label'>$alt </span> <span class='data'>Elev: </span><span class='label'>$elev</span></div>
            ";
                
            #Build up the ccgg data display
            #Make call to tag details proc to build formatted details
            doquery("drop temporary table if exists t_data_nums",false);
            doquery("create temporary table t_data_nums (index (num)) as select num from flask_data where event_num=? and program_num=1",false,array($event_num));
            doquery("call tag_getTagDetails()",false);
            
            bldsql_init();
            $lj=($range_num)?"left join flask_data_tag_view v on d.data_num=v.data_num and v.range_num=$range_num":"";
            bldsql_from("flask_data_view d left join t_tag_details t on d.data_num=t.data_num $lj");
            bldsql_where("d.event_num=?",$event_num);
            bldsql_where("d.program_num=1 and d.parameter_num<7");#ccgg
            bldsql_orderby("d.parameter_num");
            bldsql_col("d.data_num as ev_data_num");
            bldsql_col("d.parameter");
            bldsql_col("d.value");
            bldsql_col("d.flag");
            bldsql_col("t.tags");
            bldsql_col("t.tag_details_html");
            bldsql_col("case when t.tags like '%2%' then 1 else 0 end as outlier");
            if($range_num)bldsql_col("case when v.range_num is not null then 'checked' else '' end as checked");
            else bldsql_col("case when d.data_num=$data_num then 'checked' else '' end as checked");#New ones, just the selected checked..
            $a=doquery();
            
            if($a){
                $g="<table class='dbutils'><tr><th>Species</th><th>Value</th><th>Flag</th><th>Tags</th></tr>";
                $allChecked=true;#track if all were checked for control widget.
                foreach($a as $i=>$row){
                    extract($row);
                    if(!$checked)$allChecked=false;
                    $style=($outlier)?"style='border:medium red inset;'":"";
                    $popup=($tag_details_html)?getPopUp($tag_details_html,"$tags","$parameter tags",'',false):"$tags";
                    $selected=($data_num==$ev_data_num)?"class='dbutils_selectedRow'":"";
                    $disabled=($data_num)?"disabled":"";
                    $g.="<tr $selected><td><input type='hidden' name='air_data_num_$i' value='$ev_data_num'><input $disabled class='air_includeNumInRange' $checked type='checkbox' id='air_includeNumInRange_$i' name='air_includeNumInRange_$i'>$parameter</td><td>$value</td><td>$flag</td><td $style>$popup</td></tr>";
                }
                $checked=($allChecked)?"checked":"";
                $show=($allChecked)?"hide":"show";#Initial state of the indiv chk boxes.
                $html.="$g</table>";
                if(!$data_num)$html.="
                <input $checked type='checkbox' id='air_includeAllNumsInRange' name='air_includeAllNumsInRange'>Include all ccgg gases in tag.
                <script language='JavaScript'>
                    $('.air_includeNumInRange').$show();
                    $('#air_includeAllNumsInRange').click(function(event){
                        $('.air_includeNumInRange').toggle();
                    });
                </script>";
                
            
            
                #Build up the form for the tag edit part.  This will either be 'simplified' confirm 6/mark as 5 if range_num passed or a full on tag edit form.
                #If range num is passed, its assumed to be from the automated tagging system (5 or 6)
                $tag_desc='';$range_comment='';$range_prelim='';$json_selection_criteria='';$tag_num='';$canAppend=false;$canEdit=false;
                
                #Security checks to see what user can do
                createTagProcTempTables();
                doquery("insert t_data_nums select num from flask_data where event_num=? and program_num=1",false,array($event_num));
                if($range_num){
                    
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
                    $profileBtn=getJSButton('profilesBtn',"showProfilesPlots",'Profiles',$event_num);#Only show profiles when in sidebar, not when clicked from plot.
                    $formTitle=($range_prelim)?"":"This tag has been reviewed";
                    $warning=(!$range_prelim)?"This event has already been reviewed.  Are you sure you want to change it?":"";
                    $submitBtn=getJSButton("air_submitTagEditBtn",'air_submitTagEdit','Save','','',$warning,'air_right');
                    $radioBtnVals=array();
                    $radioBtnVals[97]="1st Col <span class='air_reject'>REJECT</span><br><span class='tiny_ital'>(6..) Outlier in 1 or more CCGG gases and confirmed leak from analysis of HATS tracer gases</span></br>";
                    $radioBtnVals[96]="3rd Col <span class='air_warn'>WARN</span><br><span class='tiny_ital'>(..5) Outlier in 1 or more CCGG gases and suspected leak from analysis of HATS tracer gases</span><br>";
                    $radio=getRadioBtnInputs('tagEdit_tag_num',$radioBtnVals,$tag_num);
                    if(userAccess("edit")){
                        $html.="<div id='rev_rangeEditDiv' style='height:100%;vertical-align: top;'>
                                <div id='tagEditFormDiv'>
                                    <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value='$range_num'>
                                    <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='edit'>
                                    <input type='hidden' id='tagEdit_existingComment' name='tagEdit_existingComment' value='$range_comment'>
                                    <table width='100%' >
                                        <tr>
                                            <td colspan='2' valign='top' align='right'><span style='float:left;' class='title4'>$formTitle</span></td>
                                        </tr>
                                        <tr>
                                            <td align='left' colspan='2'>
                                                $radio
                                                $submitBtn
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            ";
                    }else{#Just print
                        $html.="Tag: $tag_desc applied to checked measurements.";
                        if($range_prelim)$html.="This tag has not been reviewed yet.";
                        else $html.="This tag has been confirmed.";
                    }
                    
                }else{#Add new; we'll limit it to the N.. tag for simplicity.
                    if($data_num){
                        if(userAccess("edit")){
                            $currFlag=doquery("select flag from flask_data where num=?",0,array($data_num));
                            var_dump($currFlag);
                            $messg=($currFlag=='...')?'':"<div class='title4'>This measurement has already<BR> been flagged '$currFlag'.</div><BR><br>";
                            $warning=($currFlag!='...')?"Are you sure?":"";
                            $html="$messg $html";
                            $submitBtn=getJSButton("air_submitTagEditBtn2",'air_submitTagEdit2','Save','','',$warning,'air_right');
                            $radioBtnVals=array();
                            $radioBtnVals[12]="1st Col <span class='air_reject'>REJECT</span><br><span class='tiny_ital'>(N..) Sample collection problem/protocol error </span></br>";
                            $radioBtnVals[13]="3rd Col <span class='air_warn'>WARN</span><br><span class='tiny_ital'>(..n) Sample collection problem/protocol error </span><br>";
                            $radio=getRadioBtnInputs('tagEdit_tag_num',$radioBtnVals,12);
                    
                            $html.="<div id='rev_rangeEditDiv2' style='height:100%;vertical-align: top;'>
                                
                                <div id='tagEditFormDiv2'>
                                    <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value=''>
                                    <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='add'>
                                    <input type='hidden' id='tagEdit_existingComment' name='tagEdit_comment' value=''>
                                    <input type='hidden' id='tagEdit_data_num' name='tagEdit_data_num' value='$data_num'>
                                    <table width='100%' >
                                        <tr>
                                            <td colspan='2' valign='top' align='right'><span style='float:left;' class='title4'>Tag selected measurements</span></td>
                                        </tr>
                                        <tr>
                                            <td align='left' colspan='2'>
                                                $radio
                                                $submitBtn
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            ";
                                           
                        }
                    }
                    
                }
             
            }
            $html.="</form>";
            
            if(!$data_num)$html="<br><br><div style='width:90%;border:thin outset black;'>$html</div><br><div>$profileBtn</div>";#Wrap in div with profile
        }
        
    }
    return $html;
}
*/











?>
