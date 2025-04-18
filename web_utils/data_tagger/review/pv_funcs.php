<?php
/*various functions for the plot view page
 */

 function pv_getSideContent(){
    #Side bar filters, don't auto-submit
    $dfltStart=doquery("SELECT DATE_ADD(now(),INTERVAL -2 year)",0);
    $site_num=getHTTPVar("site_num",75,VAL_INT);
    $project_num=getHTTPVar("project_num",0,VAL_INT);
    $strategy_num=getHTTPVar("strategy_num",0,VAL_INT);
    $h_inst_num=getHTTPVar("h_inst_num",0,VAL_INT);
    $sites=getSiteSelect($site_num,'site_num',true,'');
    $ev_start_date=getHTTPVar("ev_start_date",'',VAL_DATE);
    $autoLoad=getHTTPVar("autoLoad",0,VAL_INT);
    $pv_plotProfiles=getHTTPVar('pv_plotProfiles',false,VAL_BOOLEAN);
    $dfltParams=($autoLoad)?array(1,2,3,4,5,6):array();#plot ccg params by default
    if($ev_start_date)$dfltStart=$ev_start_date;
    #function getSiteSelect($selectedValue='',$id='site_num',$wrapInTR=true,$class='search_form_auto_submit',$onChange='',$prompt='Site')
    $sites2=getSiteSelect('','site_num2',true,'','','Overlay Site');
    $projects=getGMDProjectSelect($project_num,'project_num',array(1,8),true,true,'');
    $strategies=getStrategySelect($strategy_num,'strategy_num',true,true,'');
    #$programs=getProgramSelect('','program_num',true,'');
    $ccggparameters=getMultiParameterSelect($dfltParams,'ccgg','ccgg_parameter_nums',true,'',-6);
    #Note; hats param list should come from hats db, this is ccgg.datasummary.  Need to program a summary type lookup that's quick.  This should work for now because I think pr1 data on ccgg is superset
    $hatsparameters=getInputTR("LOGOS Parameters",getMultiParameterSelect(array(),'hats','hats_parameter_nums',false,'',-4));
    $silparameters=getMultiParameterSelect(array(),'sil','sil_parameter_nums',true,'',-4);
    $arlparameters=getMultiParameterSelect(array(),'arl','arl_parameter_nums',true,'',-4);
    $curlparameters=getMultiParameterSelect(array(),'curl','curl_parameter_nums',true,'',-5);
    $evdates=getEvDateRange($dfltStart);
    $a=doquery("select num as value, id as display_name from ccgg.inst_description where id in ('m1','m2','m3','m4','pr1') or id like 'fe%' order by case when id='pr1' then 0 else 1 end, id");
    $insts=getSelect($a,'h_inst_num',$h_inst_num);
    $insts=getInputTR("LOGOS Inst.",$insts);
    $proPlots=getCheckBoxInput("pv_plotProfiles","Plot Profiles",$pv_plotProfiles);
    $alts=getAltRange('','','pv_altEntryBoxes',$proPlots);
    $exRejected=getCheckBoxInput("pv_exRejected","Exclude rejected data",false);
    $exNonbackground=getCheckBoxInput("pv_exNonbackground","Exclude non-background data",false);
#Need to add a 'parameter sets' widget to preselect stuff.
    $html="
    <table width='100%'>
        $sites $sites2 $projects $strategies
        <tr><td colspan='2' class='label' align='left'><br>ctrl/cmd click for ++</td></tr>
        $ccggparameters $hatsparameters $insts $silparameters $arlparameters $curlparameters
        <tr><td colspan='2'><br></tr></td>
        $evdates $alts
        <tr><td colspan='2'>$exRejected</td></tr>
        <tr><td colspan='2'>$exNonbackground</td></tr>
        <tr><td colspan='2' align='right'>".getJSButton('submit_btn','i_loadList','View')."</td></tr>
    </table>
    ";
    return $html;
 }
function getPVFiltersParams(){
 $filters=getStandardFilterParams();#standard filters
 #add in addition pv specific ones.
 $filters['pv_plotProfiles']=getHTTPVar("pv_plotProfiles",false,VAL_BOOLCHECKBOX);
 $filters['site_num2']=getHTTPVar("site_num2",'',VAL_INT);
 $filters['pv_exRejected']=getHTTPVar('pv_exRejected',false,VAL_BOOLCHECKBOX);
 $filters['pv_exNonbackground']=getHTTPVar('pv_exNonbackground',false,VAL_BOOLCHECKBOX);
 $filters['h_inst_num']=getHTTPVar("h_inst_num",false,VAL_INT);
 return $filters;
}
function pv_loadPlots(){
    $html='No data.';
    $filters=getPVFiltersParams();
    $a=pv_getPlotsData();
    $overlayData=($filters['site_num2'])?pv_getPlotsData(true):false;#If site 2 passed, fetch overlay data (only for single plots).
    if($a){
      if($filters['pv_plotProfiles']){#Profile plots for each gas.
        #printGraph($a,$divID="",$plotVar="",$clickFunction="",$hoverFunction="",$seriesOptions=array(),$options="",$autoAssignSeriesToNewYAxis=false,$selectToZoomX=false,$description='',$timePlot=true,$togglePlot=true,$markings='',$yopts=''){
        $html="<table>";
        foreach($a as $g=>$data){
         $plot=printGraph($data,'','','','default',array(),'',false,true,$g,false);
         $html.="<tr><td><div style='border:thin silver solid;width:600px;height:600px;'>$plot</div></td></tr>";
        }
        $html.="</table>";
      }else{//Single gas time plots
        $html="<div id='pv_spPlotsDiv'></div>";
        $html.=sp3_getSinglePlots($a,'pv_spPlotsDiv','','pv_spPlotOnClick',$overlayData);
      }
    }
    return $html;
}


function pv_getPlotsData($overlayPlot=false){
    #Returns plots data for selected parameters
    $filters=getPVFiltersParams();
    extract($filters);
    $ret=array();
    if($site_num && ($ccgg_parameter_nums || $hats_parameter_nums || $sil_parameter_nums || $arl_parameter_nums || $curl_parameter_nums)){
        foreach($ccgg_parameter_nums as $n){
            $a=pv_buildQuery($filters,'ccgg',$n,$overlayPlot);
            if($a){
                $parameter=doquery("select formula from gmd.parameter where num=?",0,array($n));
                $ret['CCGG '.$parameter]=$a;
            }
        }
        foreach($hats_parameter_nums as $n){
            $a=pv_buildQuery($filters,'hats',$n,$overlayPlot);
            if($a){
                $parameter=doquery("select formula from gmd.parameter where num=?",0,array($n));
                $ret['HATS '.$parameter]=$a;
            }
        }
        foreach($sil_parameter_nums as $n){
            $a=pv_buildQuery($filters,'sil',$n,$overlayPlot);
            if($a){
                $parameter=doquery("select formula from gmd.parameter where num=?",0,array($n));
                $ret['SIL '.$parameter]=$a;
            }
        }
        foreach($arl_parameter_nums as $n){
            $a=pv_buildQuery($filters,'arl',$n,$overlayPlot);
            if($a){
                $parameter=doquery("select formula from gmd.parameter where num=?",0,array($n));
                $ret['ARL '.$parameter]=$a;
            }
        }
        foreach($curl_parameter_nums as $n){
            $a=pv_buildQuery($filters,'curl',$n,$overlayPlot);
            if($a){
                $parameter=doquery("select formula from gmd.parameter where num=?",0,array($n));
                $ret['CURL '.$parameter]=$a;
            }
        }

        return $ret;
    }else echo "You must select a Site and one or more parameters";
    return false;
}
function pv_buildQuery($filters,$program,$n,$overlayQuery=false){#helper function, assumes lots.
    #n is parameter_num (can't use that var name because extract overwrites..)
    #$overlayQuery uses alt params (site2) to get a 2nd plot to include
    extract($filters);
    bldsql_init();
    bldsql_from("gggrn_data_view d");
    if($site_num && !($overlayQuery))bldsql_where("d.site_num=?",$site_num);
    if($overlayQuery)bldsql_where("d.site_num=?",$site_num2);#assume site_num2 when overlay is passed true.
    if($project_num)bldsql_where("d.project_num=?",$project_num);
    if($strategy_num)bldsql_where("d.strategy_num=?",$strategy_num);
    if($program_num)bldsql_where("d.site_num=?",$program_num);
    if($ev_start_date)bldsql_where("d.ev_date>=?",$ev_start_date);
    if($ev_end_date)bldsql_where("d.ev_date<=?",$ev_end_date);
    if($h_inst_num)bldsql_where("(d.inst_num=? or d.program_num!=8)",$h_inst_num);#wildcard all others, force hats inst
    if($alt_min!=='' && $alt_min!==False)bldsql_where("d.alt>=?",$alt_min);
    if($alt_max!=='' && $alt_max!==False)bldsql_where("d.alt<=?",$alt_max);
    bldsql_where("d.program=?",$program);
    bldsql_where("d.parameter_num=?",$n);
    if($pv_exRejected)bldsql_where("d.flag like '.%'");
    if($pv_exNonbackground)bldsql_where("substring(d.flag,2,1) like '.'");
    #Super annoying workaround so that excluded data aren't highlighted as flagged so that molly can see what data has other issues.
    #There needs to be a more general solution to this for all datasets (and a determination on whether excluded data is 'rejected').
    #the problem is because we changed hats exclusions to be rejected making the whole excluded record show as highlighted in the plots.
    $hl="case when inst_num in (58) then
            case when
                exists (select * from hats.flags_system flag join ccgg.tag_dictionary t on t.num=flag.tag_num where flag.analysis_num=d.analysis_num and t.reject=1)
                or exists (select * from hats.flags_internal flag join ccgg.tag_dictionary t on t.num=flag.tag_num where flag.analysis_num=d.analysis_num and flag.parameter_num=d.parameter_num and t.reject=1 and t.exclusion=0)
                or exists (select * from ccgg.flask_event_tag_view t where d.ccgg_event_num=t.event_num and d.project_num in (1,2) and t.reject=1 )
                or exists (select * from ccgg.flask_data_tag_view dtv join ccgg.flask_data fd on fd.num=dtv.data_num
                    where fd.event_num=d.ccgg_event_num and fd.parameter_num=d.parameter_num
                        and d.project_num in (1,2)  and dtv.reject=1 and dtv.data_source not in (11,12))
            then 2 else 0 end
	    else case when d.flag like '.%' then 0 else 2 end
	    end";
    bldsql_col("$hl as hl");#case when d.flag like '.%' then 0 else 2 end

    bldsql_where("d.value>-999");
    if($pv_plotProfiles){
     bldsql_col("d.value as x");
     bldsql_col("d.alt as y");
     bldsql_col("d.ev_date as series");
     #build the hover label.
     bldsql_col("concat('Event:<b>',d.ccgg_event_num,'</b> Date:<b>',d.ev_date, '</b> Flask:<b>',d.flask_id,'</b> (<b>',d.parameter,'</b>): <b>',d.value,'</b> ',case when d.flag!='...' then concat('Flag:(<b>',d.flag,'</b>)') else '' end) as hoverLabel");
     #highlight the flagged events.
     bldsql_col("case when d.flag not like '.%' then 1 else 0 end as highlightPoint");
     bldsql_where("d.alt>-999");
    }else{#time series
      bldsql_col("d.ev_datetime as x");
      bldsql_col("d.value as y");
    }
    #bldsql_col("d.value as x");
    #bldsql_col("d.alt as y");

    #bldsql_col("d.ev_dd as dd");#For averageing logic.
    #bldsql_col("d.data_num as num");#For click handler
    bldsql_col("concat('\'',data_num,'|',ccgg_event_num,'|', pair_id_num,'|', analysis_num, '|', parameter_num,'\'') as num");#overloaded to handle hats data too.

    bldsql_orderby("d.program");
    bldsql_orderby("d.parameter");
    bldsql_orderby("d.ev_datetime");

    bldsql_limit(8000);//arbitrary, but too big causes ajax errors.
    #echo bldsql_printableQuery();
    return doquery();
}



//Profile plots
function pv_profilePlots(){
    /*create a profile plots for selected events*/
    $height='400px';$width='400px';

    $plot1=pv_profilePlot($event_num,1);#co2
    $plot2=pv_profilePlot($event_num,2);#ch4
    $plot3=pv_profilePlot($event_num,3);#co
    $plot4=pv_profilePlot($event_num,4);#h2
    $plot5=pv_profilePlot($event_num,5);#n2o
    $plot6=pv_profilePlot($event_num,6);#sf6
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
function pv_profilePlot($parameter_num){
    /*Returns a profile plot for a single gas. Profiles fill all tanks of pfp at different alts*/
    $html="";


    doquery("drop temporary table if exists t_plot_data",false);
    doquery("create temporary table t_plot_data (event_num int,profileID varchar(255),color_index float)",false);
    $max=doquery("select max(dist) as m from t_profile_events",0);#min is always 0

    foreach($a as $row){
      pv_getProfileEvents($row['event_num']);#fills temp table with relevant events.
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

    return $html;
}
function pv_getProfileEvents($event_num){
    #Fills t_event_nums with all events for a pfp aircraft profile.
    #NOTE; assumes pfp ids are always like ###[#]-#[#] (have a dash) and that the first part is the same for all flasks in the pfp.
    #NOTE; assumes that all samples from a profile are in a 24 hr period and from same 'site'
    pv_buildProfileBaseQuery($event_num);
    bldsql_where("substring_index(e.id,'-',1)=substring_index(e2.id,'-',1)");
    bldsql_where("abs(datediff(e.date,e2.date))<=1");
    bldsql_col("e2.num");
    bldsql_into("t_event_nums");
    bldsql_orderby("timestamp(e2.date,e2.time)");
    doselectinto();
}
function pv_getAllGasesProfile($event_num){
    #Returns profile plot with all gases for profile containing event_num
    pv_getProfileEvents($event_num);
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
function pv_buildProfileBaseQuery($event_num){
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

//Event Form
function pv_loadEventDataPopup(){
    $html=pv_loadEventTagDisplay();
    return getPopupAlert($html,true,"");#Wrap in a popup
}
function pv_loadEventTagDisplay(){
    #Return display area for event data and tag edit/add form.
    $html='';
    $event_num=getHTTPVar("event_num",0,VAL_INT);
    $pair_id_num=0;$parameter_num=0;$analysis_num=0;
    $n=getHTTPVar("data_num");#fetch as string

    if($n){//Overloaded with data_num, event_num, pair_id_num, analysis_num, parameter_num
        $a=explode("|",$n);
        #assume order
        if($a){
            $data_num=$a[0];
            if(isset($a[4])){$event_num=$a[1];$pair_id_num=$a[2];$analysis_num=$a[3];$parameter_num=$a[4];}
        }
    }
#    $data_num=getHTTPVar("data_num",'',VAL_INT);

    if(!$event_num)$event_num=doquery("select event_num from flask_data where num=?",0,array($data_num));
    if($event_num && !$analysis_num){#ccgg or sil
        $html=pv_loadEventData($event_num,$data_num,$parameter_num);
    }else{
        $html=pv_loadStatusMetData($pair_id_num,$parameter_num,$analysis_num,$event_num);
    }#else $html='Error; missing event/data num.';
    return $html;
}
function pv_loadEventData($event_num,$data_num='',$parameter_num=''){
    #Requires event_num or  data_num
    #Returns html to show an event data for posted event/data_num

    $html="";
    if($event_num  || $data_num){
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

            #Build up the data display
            #Make call to tag details proc to build formatted details
            doquery("drop temporary table if exists t_data_nums",false);
            doquery("create temporary table t_data_nums (index (num)) as select num from flask_data where event_num=?",false,array($event_num));
            doquery("call tag_getTagDetails()",false);

            bldsql_init();
            bldsql_from("flask_data_view d left join t_tag_details t on d.data_num=t.data_num");
            bldsql_where("d.event_num=?",$event_num);
            #if($parameter_num && $parameter_num<7)bldsql_where("d.program_num=1 and d.parameter_num<7");#ccgg
            bldsql_orderby("d.parameter_num");
            bldsql_col("d.parameter_num as ev_parameter_num");
            bldsql_col("d.parameter");
            bldsql_col("d.value");
            bldsql_col("d.flag");
            bldsql_col("t.tags");
            bldsql_col("t.tag_details_html");
            $a=doquery();

            if($a){
                $g="<div style='overflow:auto;border:thin silver solid; height:400px;'>
                    <table class='dbutils'><tr><th>Species</th><th>Value</th><th>Flag</th><th>Tags</th></tr>";
                foreach($a as $i=>$row){
                    extract($row);
                    $popup=($tag_details_html)?getPopUp($tag_details_html,"$tags","$parameter tags",'',false):"$tags";
                    $selected=($parameter_num==$ev_parameter_num)?"class='dbutils_selectedRow'":"";
                    $disabled=($data_num)?"disabled":"";
                    $g.="<tr $selected><td>$parameter</td><td>$value</td><td>$flag</td><td $style>$popup</td></tr>";
                }
                $html.="$g</table></div>Add/Edit Tag in <a href=\"../index.php?loadDataNum=$data_num\" target=\"_blank\">DataTagger</a>.";

            }
        }
    }else $html="Error; missing required identifier numbers (event,data,range) in pv_loadEventData()";
    return $html;
}
function pv_loadStatusMetData($pair_id_num,$parameter_num,$analysis_num,$event_num){
    #Requires $pair_id_num
    #Returns html to show hats event data for posted $pair_id_num/$parameter_num

    $html="";
    if($pair_id_num || $event_num){
        #Build event details
        bldsql_init();
        bldsql_from("gggrn_data_view e");
        bldsql_distinct();
        bldsql_where("e.pair_id_num=?",$pair_id_num);
        bldsql_where("e.analysis_num=?",$analysis_num);
        bldsql_where("e.parameter_num=?",$parameter_num);
        bldsql_where("e.ccgg_event_num=?",$event_num);
        bldsql_col("e.ev_datetime as date");
        bldsql_col("e.site");
        bldsql_col("e.flask_id");
        bldsql_col("e.project");
        bldsql_col("e.strategy");
        bldsql_col("e.me");
        bldsql_col("e.lat");
        bldsql_col("e.lon");
        bldsql_col("e.alt");
        bldsql_col("e.elev");
        #bldsql_col("e.comment");

        $a=doquery();

        if($a){
            extract($a[0]);
            if($event_num)$ev="Event_num: $event_num";
            else $ev="PairID: $pair_id_num";
            $html.="
                <div class='title4'>$ev &nbsp;&nbsp;Flask:$flask_id </div>
                <div class='label' style='text-align:center'><span class='title4'>$site</span> - $date</div>
                <div><span class='data'>Lat: </span><span class='label'>$lat </span> <span class='data'>Lon: </span><span class='label'>$lon</span></div>
                <div><span class='data'>Alt: </span><span class='label'>$alt </span> <span class='data'>Elev: </span><span class='label'>$elev</span></div>
            ";

            #Build up the data display
            bldsql_init();
            bldsql_into("t_tag_details");
            bldsql_from("hats.prs_mole_fraction_tag_view t");
            bldsql_col("analysis_num, parameter_num, group_concat(distinct t.flag order by t.flag separator ',') as tags,
            group_concat(distinct t.display_name order by t.flag separator '<br>') as tag_details_html");
            bldsql_groupby("analysis_num,parameter_num");
            bldsql_where("analysis_num=?",$analysis_num);
            doselectinto();

            bldsql_init();
            bldsql_from("gggrn_data_view d left join t_tag_details t on d.analysis_num=t.analysis_num and d.parameter_num=t.parameter_num");
            bldsql_where("d.pair_id_num=?",$pair_id_num);
            bldsql_where("d.analysis_num=?",$analysis_num);
            #bldsql_where("d.program_num=1 and d.parameter_num<7");#ccgg
            bldsql_orderby("d.parameter_num ");
            #bldsql_col("d.data_num as ev_data_num");
            bldsql_col("d.parameter_num as 'ev_parameter_num'");
            bldsql_col("d.parameter");
            bldsql_col("d.value");
            bldsql_col("d.flag");
            bldsql_col("t.tags");
            bldsql_col("t.tag_details_html");

            $a2=doquery();

            if($a2){
                $g="<div style='overflow:auto;border:thin silver solid; height:400px;'><table class='dbutils'><tr><th>Species</th><th>Value</th><th>Flag</th><th>Tags</th></tr>";
                foreach($a2 as $i=>$row){
                    extract($row);
                    $popup=($tag_details_html)?getPopUp($tag_details_html,"$tags","$parameter tags",'',false):"$tags";
                    $selected=($parameter_num==$ev_parameter_num)?"class='dbutils_selectedRow'":"";
                    $disabled=($data_num)?"disabled":"";
                    $g.="<tr $selected><td>$parameter</td><td>$value</td><td>$flag</td><td $style>$popup</td></tr>";
                }
                $html.="$g</table></div>";

            }
        }
    }else $html="Error; missing required identifier numbers";
    return $html;
}


?>
