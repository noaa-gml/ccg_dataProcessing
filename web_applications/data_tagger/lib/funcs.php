<?php
include_once("help_contents.php");
require_once("rangeCriteriaFuncs.php");
require_once("tagEditFuncs.php");
require_once("tagDisplayFuncs.php");
/*Main search function*/
function doSearch($rowLimit=1000,$mode='tag'){
    #return printTable(doquery("select * from ccgg.inst"));
    #return buildQueryBase(false,false,true);
    #$rowLimit=1000;//Arbitrary cutoff
    $plotRowLimit=8000;//Also arbitrary, but too big causes ajax errors.
    $html="";
    $data_num="";#These 2 need to be declared outside of the loop for possible use below.
    $event_num="";
    $rowClickAction=($mode=='tag')?"getTagList":"";
    #setDebugLogFile();
    
    #Build the base query with appropriate joins.
    $flaskData=buildQueryBase();
    
    ##Debug
    #return bldsql_printableQuery();
    #$t.=var_export($_REQUEST);
    #print ($t);
    #exit();
    ##
    
    
    #Create a temp table to hold our keys.
    $numRows=buildIDTable($flaskData);
    
    if(!$numRows){
        $msg="No matching results found.  Try removing some selection filters.<br>";
        $t=buildQueryBase(false,false,true);
        if($t)$msg.="Current filters:<br>".str_replace('|','<br>',$t);
        return $msg;
    }
    
    
    #Get a hash of the base query to pass along with the results.  This is so later edit functions can be sure they are using the same base query
    #if the are acting on mulitple event/data rows.  
    $queryHash=bldsql_getQueryHash($numRows);#Not currently being used...
    
    #Now select out the data using temp table and appropriate view
    bldsql_init();
    
    #Build the param col to pass to the js function on row click, we have to pass as a string since the data_num could be null
    $param=($flaskData)?"concat(v.event_num,',',v.data_num)":"v.event_num";
   
    #see if we're to pair average when searching for data
    $doPairAverage=getHTTPVar("d_pairAverage",0,VAL_BOOLCHECKBOX);
    #Automatically set for flaskdata
    
    #See if we're going to plot or output a table
    $plot=getHTTPVar("d_plot",0,VAL_BOOLCHECKBOX);
    $parameter_nums=getHTTPVar("d_parameter_num","",VAL_ARRAY_NE);
    $program_num=getHTTPVar("d_program_num",0,VAL_INT);
    $doPlot=false;
    
    #Plot if 1+ (but not too many) params selected or ccgg (has 6) selected.
    if($flaskData && $plot && ($parameter_nums || $program_num===1))$doPlot=($program_num===1 ||($parameter_nums[0]!='all' && count($parameter_nums)<=10));#Arbitrary cutoff to keep reasonable
    
    #build measurement paths info if inloop was checked.  Fairly annoying to have to do this, but the path is packed into a single col.
    $ev_inloop=getHTTPVar("ev_inloop",0,VAL_BOOLCHECKBOX);

    $buildPath=($ev_inloop && !$doPlot);
    if($buildPath){
        doquery("drop temporary table if exists t_loopPaths",false);
        doquery("create temporary table t_loopPaths(path varchar(255),display varchar(255) null)",false);
        doquery("insert t_loopPaths (path) select path from flask_inv where sample_status_num = 3 and event_num>0 union select path from pfp_inv where sample_status_num=3 and event_num>0",false);
        $a=doquery("select path from t_loopPaths");
        $t=array();$c=0;
        foreach($a as $row){
            
            $path = explode(",",$row['path']);
            
            if($path){
                for ($i=0,$list = array(); $i<count($path); $i++){
                    
                   if($path[$i]){
                        $x=$path[$i];
                        $sql = "SELECT route FROM ccgg.system WHERE num=$x";
                        
                        if(isset($t[$x])){
                            $res=$t[$x];
                        }
                        else{
                            $res = doquery($sql,0);
                            $c++;
                            $t[$x]=$res;
                        }
                        
                        $list[$i] = $res;
                   }
                }

                doquery("update t_loopPaths set display='".implode(" - ",array_values(array_unique($list)))."' where path='".$row['path']."'",false);
            }
        }
        bldsql_from("t_loopPaths tlp");
        bldsql_from("(select event_num,path as  loopPath from flask_inv where sample_status_num=3 and event_num>0 union select event_num,path as loopPath from pfp_inv where sample_status_num=3 and event_num>0) as loop_ev");
        bldsql_where("loop_ev.event_num=v.event_num");
        bldsql_where("tlp.path=loop_ev.loopPath");
        
    }
    
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
    $dtable="";$etable="";$ejoin="";
    doquery("drop temporary table if exists t__dt,t__et",false);
    if($flaskData){#t_data table contains target data_nums.
        $sql="create temporary table t__dt (index (data_num)) as
                select v.data_num,group_concat(v.flag separator ',') as tags
                    from flask_data_tag_view v join t_data t on v.data_num=t.num
                    group by v.data_num";
        doquery($sql,false);
        $dtable="left join t__dt as dt on v.data_num=dt.data_num";#for big select below.
        $ejoin="join flask_data d on d.event_num=v.event_num join t_data t on d.num=t.num";#for $etable query
    }else{#t_events table contains target event_nums.
        $ejoin="join t_events t on v.event_num=t.num";#for $etable query.
    }
    $sql="create temporary table t__et (index (event_num)) as
            select v.event_num, group_concat(distinct v.flag separator ',') as tags
                from flask_event_tag_view v $ejoin
                group by v.event_num";
    doquery($sql,false);
    $etable="left join t__et as et on v.event_num=et.event_num";#for big select below.

    
    
    if($flaskData){
        bldsql_from("t_data d");
        bldsql_from("flask_data_view v $dtable $etable");
        bldsql_where("v.data_num=d.num");
    }else{
        bldsql_from("t_events e");
        bldsql_from("flask_event_view v $etable");
        bldsql_where("v.event_num=e.num");
    }
    if($doPlot){
        bldsql_col("v.parameter as series");
        bldsql_col("timestamp(v.ev_date,v.ev_time) as x");
        bldsql_col("v.value as y");
        bldsql_col("-1 as 'yaxis'");
        $hasTags=($flaskData)?"et.tags is not null or dt.tags is not null":"et.tags is not null";
        bldsql_col("case when $hasTags then 1 else 0 end as highlightPoint");
        #bldsql_col("avg(v.value) as y");
        #bldsql_groupby("v.parameter");
        #bldsql_groupby("timestamp(ev_date,ev_time)");
        bldsql_col($param." as onClickParam");
        bldsql_orderby("v.parameter");
        bldsql_orderby("timestamp(v.ev_date,v.ev_time)");
        bldsql_limit($plotRowLimit);
        
    }else{#table output
        #Some cols we'll select regardless, others only if involved in the selection criteria.
        bldsql_col($param." as onClickParam");
        if($buildPath)bldsql_col("tlp.display as Path");
        bldsql_col("v.event_num as 'event #'");
        bldsql_col("v.site");#Note-pairaverge function below uses this name
        bldsql_col("v.project");#Note-pairaverge function below uses this name
        bldsql_col("v.strategy");#Note-pairaverge function below uses this name
        bldsql_col("v.me");#Note-pairaverge function below uses this name
        bldsql_col("v.ev_datetime as 'Sample date'");#Note-pairaverge function below uses this name
        bldsql_col("v.flask_id as 'flask id'");
        bldsql_orderby("v.ev_date");
        bldsql_orderby("v.ev_time");
        bldsql_orderby("v.flask_id");
        
        
        if($flaskData){
            $d_sunc=getHTTPVar("d_sunc","",VAL_FLOAT);
            $d_eunc=getHTTPVar("d_eunc","",VAL_FLOAT);
            $d_inst=getHTTPVar("d_inst","");
            $d_comment=getHTTPVar("d_comment","");
            bldsql_col("v.data_num as 'data #'");
            bldsql_col("v.program");
            bldsql_col("v.parameter");#Note-pairaverge function below uses this name
            bldsql_col("v.value");#Note-pairaverge function below uses this name
            bldsql_col("v.flag");
            if($d_sunc || $d_eunc) bldsql_col("v.unc");
            bldsql_col("v.a_datetime 'Meas Date'");
            #bldsql_col("v.time as atime");
            if($d_inst)bldsql_col("v.inst as inst");#!! should be inst.inst (RO)
            if($d_comment)bldsql_col("v.comment as comment");
            bldsql_orderby("v.parameter");
            #bldsql_col("inst.inst");
            bldsql_col("concat_ws(',',dt.tags,et.tags) as tags");
            #bldsql_col("dt.tags");
            #bldsql_col("et.tags as 'sample tags'");
         }else{
            bldsql_col("v.lat");
            bldsql_col("v.lon");
            bldsql_col("v.alt");
            bldsql_col("v.elev");
            bldsql_col("v.comment as comment");
            bldsql_col("et.tags");
         }
        
        
        if($rowLimit>0)bldsql_limit($rowLimit);
    }
    #return bldsql_printableQuery();
    $a=doquery();
    /*if($doPairAverage && $flaskData){
        $a=pairAverage($a);
        $numRows=count($a);
    }*/
    if($doPlot){
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
        #$js.="searchResultsPlotVar.highlight(1,2);";
        $js="<script language='JavaScript'>var selectionPlotParams=new Array();$js</script>";
     
        #Build the function to highlight the datapoints with tags
        #$pointsOpt="function"
        #Build the plot options
        $d=getPlotMinMaxDates();
        #Note on the yaxis labels.  This functionality is not built into current version of flot, so using this workaround.
        $options="  series: { lines: { show: true }, points: { show: true }},
                    xaxis:{mode:\"time\",$d},
                    yaxis:{show:true,min:0,tickFormatter: function(val, axis) { $yaxisLabels return val < axis.max ? val.toFixed(2) : yaxisLables[axis.n-1];}},
                    grid:{clickable:true,hoverable:true} ";
        $html.=printGraph($a,"","searchResultsPlotVar","searchResultsPlotClicked","searchResultsPlotHover",array(),$options,true,true).$js;
    }else{
        $html.="<div id='searchOutOfDateDiv'></div>".printTable($a,$rowClickAction,1);
    }
    $html.="<input type='hidden' id='baseQueryHash' value='$queryHash'>";
    
     #Build the label
    $label="";
    
    if($numRows && $flaskData)$label.="$numRows matching analysis records.";
    elseif($numRows)$label.="$numRows matching sample events.";
    else $label.="No matching results found.  Try removing some selection filters.";
    if($numRows>$rowLimit)$label.="  Only the first $rowLimit results are shown.";
    
    $html.=setStatusMessage($label,0);
    
    return $html;
}

function createTagProcTempTables(){
    /*create (if needed) and empty temp tables needed to interact with the tag_ stored procedures*/
    doquery("create temporary table if not exists t_range_nums as select num from tag_ranges where 1=0",false);
    doquery("create temporary table if not exists t_data_nums as select num from flask_data where 1=0",false);
    doquery("create temporary table if not exists t_event_nums as select num from flask_event where 1=0",false);
    doquery("delete from t_range_nums",false);
    doquery("delete from t_data_nums",false);
    doquery("delete from t_event_nums",false);
}
function userAccess($operation){
    /*Returns true if user can insert for the current selection set.  Assumes that the proc temp tables have already been created and filled.
    See tag_securityAccess for details.
    $operation:
    insert, append (comments), edit, delete
    */
    
    $ret=false;
    $id=db_getAuthUserID();
    if($id){
        if($operation=="insert")$op=1;
        if($operation=="append")$op=2;
        if($operation=="edit")$op=3;
        if($operation=="delete")$op=4;
        if($op){
            doquery("call tag_securityAccess($id,$op,@v_status,@v_mssg)",false);
            $t=doquery("select @v_status",0);
            #Note; either php or mysql returns ints as string, so be careful checking for the '0' success value.  Also make sure to gracefully handle if bug is ever fixed.
            if($t!==false && ($t===0 || $t==="0"))$ret=true;
        }
    }
    return $ret;
}


function buildDataTagView($data_num,$event_num){
    
}
function logError($error,$severity){
    //Stub.
}
function setStatusMessage($message,$wipeAfter=10){
    #Returns js html to include with output to set the status message.  Auto wipes after $wipeAfter, pass 0 to keep
    
    $js="<script language='JavaScript'>
    var message=\"".htmlspecialchars($message)."\";
    setStatusMessage('$message',$wipeAfter)
    </script>";
    return $js;
}

function buildIDTable($flaskData){
    /*Fills a temp table with all filtered ids from search criteria
     *If $flaskData is false, the table is named t_events
     *otherwise, the table is named t_data
     *The only column is num
     *Returns number of rows or false on error.
     *Must have already called $flaskData=buildQueryBase();
     *
     **/
    if($flaskData){
        bldsql_into("t_data","n(num)");
        bldsql_col("d.num");
    }else{
        bldsql_into("t_events","n(num)");
        bldsql_col("e.num");
    }
    return doselectinto();
}
function buildIDTable2($event_num='',$data_num=''){
    /*Fills a temp table with all filtered ids from search criteria or $event_num/$data_num if passed
     *If this is an event based search the table is named t_events
     *otherwise, the table is named t_data
     *The only column is num
     *Returns $flaskData.
     This is like above, but handles ev/data nums too.
     **/
    bldsql_init();
    $flaskData=($data_num);
    if($event_num=='' && $data_num==''){
       $flaskData=buildQueryBase();        
    }else{//RowMode: We join to table to get id so that it can inherit col type (in case we have to change type in future)
        if($flaskData){
            bldsql_from("flask_data d");
            bldsql_where("d.num=?",$data_num);
        }else{
            bldsql_from("flask_event e");
            bldsql_where("e.num=?",$event_num);
        }
    }
    if($flaskData){
        bldsql_into("t_data","n(num)");
        bldsql_col("d.num");
    }else{
        bldsql_into("t_events","n(num)");
        bldsql_col("e.num");
    }
    
    doselectinto();
    return $flaskData;
}
function getNumName($table,$num,$nameCol){
    #Retruns namecol from table for id:num.  Totally not injection safe, use with caution.
    return doquery("select $nameCol from $table where num=$num",0);
}
function getNumsNames($table,$nums,$nameCol){
    #Like above, for comma separated list
    $desc="";
    $n="";
    foreach($nums as $num){$n=appendToList($n,$num);}
    $a=doquery("select $nameCol from $table where num in ($n)");
    if($a){
        foreach($a as $row){
            $desc=appendToList($desc,$row[$nameCol],', ');
        }
    }
    return $desc;
}

function buildQueryBase($doAllJoins=false,$returnJSON=false,$returnDesc=false,$returnArray=false, $returnFlaskDataOnly=false){
    #Parse $_REQUEST for filter parameters
    #if $doAllJoins then we join to flask_data (and related tables) regardless if there is a data filter present
    #
    #If $returnJSON=true, we don't actually create the query base, but just build a json string of form objects present to return.
    #This functionality could(should?) be in another function, but it was kind of nice to share all the parsing/cleaning logic.
    #As a bonus, this keeps both logics in sync.
    
    #Totally overloading this logic now.. if $returnDesc=true, we don't build a query, but instead build a description of the filters.Note json/desc are exclusive (can only pass 1 true).
    
    #4/17.  Third time's an overloading charm...  I wish I had made a 'returnType' parameter instead of the boolean flags.  We could
    #update that (and all callers) sometime, but for now adding $returnArray to have the logic return all the filters in an array.
    #This is used by function updateOpenEndedRangeCriteria().
    
    #4/17.  Again.. stop the insanity.  I should really refactor the call parameters.  This sucks.
    #Would require much testing though... so once more into the breach.  Common form parsing is great, call params and multiple return types no so much...
    #If $returnFlaskDataOnly=true, this just returns true/false if target is flask_data.  It does NOT initialize the bldsql_ env and is non-destructive.
    
    #Note all of the extra return type modes are non-destructive (don't re-init bldsql_).
    
    #NOTE; if adding NEW criteria fields.  
    #$a[name] must be equal to the $_REQUEST/form name so that the json logic can apply back to the form
    #Also; aside from multiple spots below, you may(will likely) need to add to index.js->clearFields and rangeCriteriaFuncs.js->setCriteria
    #Also make sure to set class for input correctly (see others for example).
    
    #NOTE; if changing the logic (particularly date matching) or adding new significant fields, you must review mysql stored
    #procedure tag_addToOpenEndedRanges() to see if that logic needs to be updated.
    
    #Also note that date time fields are separated for the query, but reside as a single field in the form and in json (actually I think this changed below... jwm 4/18/19)
    
    #We allow single event/data nums or comma separated list.
    #NOTE; don't add range_num to criteria.  Use search_range_num or similar.  There is a var name conflict with processes passing that variable (criteria edit)
 
    $a['ev_event_num']=parseIDsFromList(getHTTPVar("ev_event_num"));#Returns an array
    $a['d_data_num']=parseIDsFromList(getHTTPVar("d_data_num"));
    #$a['d_data_num']=getHTTPVar("d_data_num","",VAL_INT,array(),1);
    
    $a['ev_flask_id']=getHTTPVar("ev_flask_id");
    
    #flask_event
    $a['ev_site_num']=getHTTPVar("ev_site_num","");#Note if changing this filter (like adding mulitpick), above funciton updateOpenEndedRangeCriteria needs editing.
    

    $a['ev_sDate']=getHTTPVar("ev_sDate","",VAL_DATE_TIME);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    $a['ev_eDate']=getHTTPVar("ev_eDate","",VAL_DATE_TIME);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    
    $a['ev_sTimewindow']=getHTTPVar("ev_sTimewindow",'',VAL_TIME);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    $a['ev_eTimewindow']=getHTTPVar("ev_eTimewindow",'',VAL_TIME);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    $a['ev_notTimewindow']=getHTTPVar("ev_notTimewindow",False,VAL_BOOLCHECKBOX);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    #Enforce that not checkbox can't be checked unless both start and end are selected.  This is to make logic easier
    if(!($a['ev_sTimewindow'] && $a['ev_eTimewindow']))$a['ev_notTimewindow']=false;
    
    $a['ev_inloop']=getHTTPVar("ev_inloop",0,VAL_BOOLCHECKBOX);
    $a['ev_project_num']=getHTTPVar("ev_project_num","",VAL_INT);#Note if changing this filter (like adding mulitpick), funciton updateOpenEndedRangeCriteria needs editing.
    $a['ev_strategy_num']=getHTTPVar("ev_strategy_num","",VAL_INT);#Note if changing this filter (like adding mulitpick), funciton updateOpenEndedRangeCriteria needs editing.
    $a['ev_comment']=getHTTPVar("ev_comment","");
    $a['ev_method']=getHTTPVar("ev_method");
    
    #ev ranges
    $a['ev_from_lat']=getHTTPVar("ev_from_lat","",VAL_FLOAT);
    $a['ev_to_lat']=getHTTPVar("ev_to_lat","",VAL_FLOAT);
    $a['ev_from_lon']=getHTTPVar("ev_from_lon","",VAL_FLOAT);
    $a['ev_to_lon']=getHTTPVar("ev_to_lon","",VAL_FLOAT);
    $a['ev_from_alt']=getHTTPVar("ev_from_alt","",VAL_FLOAT);
    $a['ev_to_alt']=getHTTPVar("ev_to_alt","",VAL_FLOAT);
    $a['ev_from_elev']=getHTTPVar("ev_from_elev","",VAL_FLOAT);
    $a['ev_to_elev']=getHTTPVar("ev_to_elev","",VAL_FLOAT);
    
    #flask_data
    $a['d_program_num']=getHTTPVar("d_program_num","",VAL_INT);#Note if changing this filter (like adding mulitpick), funciton updateOpenEndedRangeCriteria needs editing.
    #$a['d_parameter_num']=getHTTPVar("d_parameter_num","",VAL_INT);
    $a['d_parameter_num']=getHTTPVar("d_parameter_num","",VAL_ARRAY_NE);#Note if changing this filter, funciton updateOpenEndedRangeCriteria needs editing.
    $a['d_inst']=getHTTPVar("d_inst","");#Note this used to be the ccgg.inst.num, but now is flask_data.inst.  Not sure what inst table is used for.
    $a['d_sunc']=getHTTPVar("d_sunc","",VAL_FLOAT);
    $a['d_eunc']=getHTTPVar("d_eunc","",VAL_FLOAT);
    

    $a['d_sDate']=getHTTPVar("d_sDate","",VAL_DATE_TIME);
    $a['d_eDate']=getHTTPVar("d_eDate","",VAL_DATE_TIME);
    
    $a['d_comment']=getHTTPVar("d_comment","");
    
    #existing tag
    $a['ev_tag_num']=getHTTPVar("ev_tag_num","",VAL_INT);
    $a['d_tag_num']=getHTTPVar("d_tag_num","",VAL_INT);
    $a['tag_prelim']=getHTTPVar("tag_prelim",0,VAL_BOOLCHECKBOX);
    
    #Short circuit logic if caller requested a special return type.
    if($returnJSON){
        #build json object of form
        #Note; the 3 key cols (event_num & data_num) can be entered as a csv string which gets exploded above for
        #use in query.  We'll reverse that to store in json so it's in the same format as the client.
        $a['ev_event_num']=implode(",",$a['ev_event_num']);
        $a['d_data_num']=implode(",",$a['d_data_num']);
        
        #return json_encode($a);
        #this would have worked great, but we're on php 5.1!? So I had to write this instead:
        $json=arrayToJSON($a,false);
        return $json;
        #probably should use built in when updated...
    }elseif($returnDesc){#Build a human readable description.
        $desc="";$delim=' | ';extract($a);#Note | is used in some displays (replaced with ul formatting), so don't change it.  You'll have to add a new output mode.
        if($ev_event_num)$desc=appendToList($desc,"EventNum(s):".$ev_event_num,$delim);
        if($d_data_num)$desc=appendToList($desc,"DataNum(s):".$d_data_num,$delim);
        if($ev_flask_id)$desc=appendToList($desc,"Flask ID:".$ev_flask_id,$delim);
        if($ev_site_num)$desc=appendToList($desc,"Site:".getNumName("gmd.site",$ev_site_num,'code'),$delim);
        if($ev_sDate)$desc=appendToList($desc,"Event From:$ev_sDate",$delim);
        if($ev_eDate)$desc=appendToList($desc,"Event To:$ev_eDate",$delim);
        if($ev_notTimewindow && ($ev_sTimewindow && $ev_eTimewindow))$desc=appendToList($desc,"Sample not taken in ");
        if($ev_sTimewindow)$desc=appendToList($desc,"Sample Window From:$ev_sTimewindow",$delim);
        if($ev_eTimewindow)$desc=appendToList($desc,"Sample Window To:$ev_eTimewindow",$delim);
        if($ev_inloop)$desc=appendToList($desc,"In Anal Loop:true",$delim);
        if($ev_project_num)$desc=appendToList($desc,"Project:".getNumName("gmd.project",$ev_project_num,'abbr'),$delim);
        if($ev_strategy_num)$desc=appendToList($desc,"Strategy:".getNumName("ccgg.strategy",$ev_strategy_num,'abbr'),$delim);
        if($ev_comment)$desc=appendToList($desc,"Comment:$ev_comment",$delim);
        if($ev_method)$desc=appendToList($desc,"Method:$ev_method",$delim);
        if($ev_from_lat!=='')$desc=appendToList($desc,"LAT From:$ev_from_lat",$delim);#Note 0 is a valid value.
        if($ev_to_lat!=='')$desc=appendToList($desc,"LAT To:$ev_to_lat",$delim);
        if($ev_from_lon!=='')$desc=appendToList($desc,"LON From:$ev_from_lon",$delim);
        if($ev_to_lon!=='')$desc=appendToList($desc,"LON To:$ev_to_lon",$delim);
        if($ev_from_elev!=='')$desc=appendToList($desc,"ELEV From:$ev_from_elev",$delim);
        if($ev_to_elev!=='')$desc=appendToList($desc,"ELEV To:$ev_to_elev",$delim);
        if($d_program_num)$desc=appendToList($desc,"Program:".getNumName("gmd.program",$d_program_num,'abbr'),$delim);
        if($d_parameter_num)$desc=appendToList($desc,"Parameter(s):".getNumsNames("gmd.parameter",$d_parameter_num,'formula'),$delim);
        if($d_inst)$desc=appendToList($desc,"Inst:".$d_inst,$delim);
        if($d_sDate)$desc=appendToList($desc,"Meas. From:$d_sDate",$delim);
        if($d_eDate)$desc=appendToList($desc,"Meas. To:$d_eDate",$delim);
        if($d_sunc)$desc=appendToList($desc,"Unc From:$d_sunc",$delim);
        if($d_eunc)$desc=appendToList($desc,"Unc To:$d_eunc",$delim);
        if($d_comment)$desc=appendToList($desc,"Meas. Comment:$d_comment",$delim);
        if($ev_tag_num)$desc=appendToList($desc,"Event Tag:".getNumName("tag_view",$ev_tag_num,'display_name'),$delim);
        if($d_tag_num)$desc=appendToList($desc,"Meas. Tag:".getNumName("tag_view",$d_tag_num,'display_name'),$delim);
        if($tag_prelim)$desc=appendToList($desc,"Prelim tag:true");
        return $desc;
    }elseif($returnArray){
        return $a;
    }
    extract($a);#turn into variables for convience.
    $d_range_num=0;
    if($range_num){#set var to note if passed range_num is for flask data range or ev range
        $d_range_num=doquery("select count(*) from flask_data_tag_range where range_num=?",0,array($range_num));
    }
    #See if any of the flask_data params are being filtered on
    $flaskData=($doAllJoins || count($d_data_num) || $d_program_num || count($d_parameter_num) || $d_inst || $d_sunc!=='' || $d_eunc !=='' || $d_sDate  || $d_eDate || $d_comment || $d_tag_num || $d_range_num);
    
    #Non destructive exit if caller just wants the target data
    if($returnFlaskDataOnly)return $flaskData;
    
    bldsql_init();
    
    if($flaskData){
        bldsql_from("flask_data d");
        bldsql_where("d.event_num=e.num");
       
        
        bldsql_from("gmd.parameter param");
        bldsql_where("param.num=d.parameter_num");
        
        
        bldsql_from("gmd.program prog");
        bldsql_where("prog.num=d.program_num");
        
        #Conditionally join (because we don't select cols from it) to the tag table if needed.
        if($d_tag_num){
            bldsql_from("flask_data_tag_view dt");
            bldsql_where("d.num=dt.data_num");
            #bldsql_where("dt.tag_num=?",$d_tag_num);
            bldsql_where("(dt.tag_num=$d_tag_num or dt.parent_tag_num=$d_tag_num)");#bldsql doesn't support multiple bind params, so have to hard code (inj vuln), but should be ok as val is parsed as an int
            
            bldsql_distinct();#It's possible to have 2 rows with same tag num.  We don't want that to return multple data rows.
        }
        #bldsql_from("ccgg.inst inst");
        #bldsql_where("inst.id=d.inst");
        
    }
    #Event joins happen regardless.
    bldsql_from("flask_event e");
    
    bldsql_from("gmd.project proj");
    bldsql_where("e.project_num=proj.num");
    
    bldsql_from("ccgg.strategy strat");
    bldsql_where("strat.num=e.strategy_num");
    
    bldsql_from("gmd.site s");
    bldsql_where("s.num=e.site_num");
    
    #Conditionally join (because we don't select cols from it) to the tag table if needed.
    if($ev_tag_num){
            bldsql_from("flask_event_tag_view et");
            bldsql_where("e.num=et.event_num");
            #bldsql_where("et.tag_num=?",$ev_tag_num);
            bldsql_where("(et.tag_num=$ev_tag_num or et.parent_tag_num=$ev_tag_num)");#bldsql doesn't support multiple bind params, so have to hard code (inj vuln), but should be ok as val is parsed as an int
            bldsql_distinct();#It's possible to have 2 rows with same tag num.  We don't want that to return multple data rows.
    }
    
    if($ev_inloop){
        #limit to flasks currently in the anal loop
        bldsql_from("(select event_num from flask_inv where sample_status_num=3 and event_num>0 union select event_num from pfp_inv where sample_status_num=3 and event_num>0) as loop_ev");
        bldsql_where("loop_ev.event_num=e.num");
    }
    #Filters
    
    #ID/nums
    if($d_data_num)bldsql_wherein("d.num in",$d_data_num);
    if($ev_event_num)bldsql_wherein("e.num in",$ev_event_num);
    if($range_num){#join to appropriate table.
        if($d_range_num){
            bldsql_from("flask_data_tag_range dtr");
            bldsql_where("dtr.data_num=d.num");
        }else{ 
            bldsql_from("flask_event_tag_range etr");
            bldsql_where("etr.event_num=e.num");
        }
    }
    if($ev_flask_id)bldsql_where("e.id like ?",$ev_flask_id);        

    #flask_event filters
    if($ev_sDate)bldsql_where("e.date>=date(?)",$ev_sDate);#This one can use the index.
    if($ev_sDate)bldsql_where("timestamp(e.date,e.time)>=timestamp(?)",$ev_sDate);#this one filters on time (no index)
    
    if($ev_eDate)bldsql_where("e.date<=date(?)",$ev_eDate);#This one can use the index.
    if($ev_eDate)bldsql_where("timestamp(e.date,case when time(timestamp('$ev_eDate'))='00:00:00' then '00:00:00' else e.time end)<=timestamp(?)",$ev_eDate);#this one filters on time (no index).Treat null time as end of day
    
    if($ev_notTimewindow && ($ev_sTimewindow && $ev_eTimewindow)){
        if($ev_sTimewindow)bldsql_where("(e.time<'$ev_sTimewindow' or e.time>'$ev_eTimewindow')");#Note; can't param 2 inputs in this framework...  these are filtered above anyway though.
    }else{
        if($ev_sTimewindow)bldsql_where("e.time>=time(?)",$ev_sTimewindow);
        if($ev_eTimewindow)bldsql_where("e.time<=time(?)",$ev_eTimewindow);
    }    
    if($ev_site_num)bldsql_where("e.site_num=?",$ev_site_num);
    if($ev_project_num)bldsql_where("e.project_num=?",$ev_project_num);
    if($ev_strategy_num)bldsql_where("e.strategy_num=?",$ev_strategy_num);
    if($ev_comment)bldsql_where("lower(e.comment) like ?",$ev_comment);
    if($ev_method)bldsql_where("lower(e.me)=?",$ev_method);
    
    #ranges.  Note; 0 is a valid value for some of these, so must do !== check.
    if($ev_from_lat!=='')bldsql_where("e.lat>=?",$ev_from_lat);
    if($ev_to_lat!=='')bldsql_where("e.lat<=?",$ev_to_lat);
    if($ev_from_lon!=='')bldsql_where("e.lon>=?",$ev_from_lon);
    if($ev_to_lon!=='')bldsql_where("e.lon<=?",$ev_to_lon);
    if($ev_from_alt!=='')bldsql_where("e.alt>=?",$ev_from_alt);
    if($ev_to_alt!=='')bldsql_where("e.alt<=?",$ev_to_alt);
    if($ev_from_elev!=='')bldsql_where("e.elev>=?",$ev_from_elev);
    if($ev_to_elev!=='')bldsql_where("e.elev<=?",$ev_to_elev);
    

    #flask_data filters
    if($d_program_num){
        bldsql_where("d.program_num=?",$d_program_num);
        if($d_program_num==1){
            #Unless specifically selected, skip wind,temp,rh
            if(array_search(58,$d_parameter_num)===false)bldsql_where("d.parameter_num!=58");#ws
            if(array_search(59,$d_parameter_num)===false)bldsql_where("d.parameter_num!=59");#wd
            if(array_search(60,$d_parameter_num)===false)bldsql_where("d.parameter_num!=60");#temp
            if(array_search(61,$d_parameter_num)===false)bldsql_where("d.parameter_num!=61");#press
            if(array_search(62,$d_parameter_num)===false)bldsql_where("d.parameter_num!=62");#rh

        }
        
    }
    #if($d_parameter_num)bldsql_where("d.parameter_num=?",$d_parameter_num);
    if(count($d_parameter_num)){
        if($d_parameter_num[0]!='all')
            bldsql_wherein("d.parameter_num in ",$d_parameter_num);        
    }
    if($d_inst)bldsql_where("d.inst=?",$d_inst);
    if($d_sunc!=='')bldsql_where("d.unc>=?",$d_sunc);
    if($d_eunc!=='')bldsql_where("d.unc<=?",$d_eunc);
    if($d_sDate)bldsql_where("d.date>=date(?)",$d_sDate);#This one can use the index.
    if($d_sDate)bldsql_where("timestamp(d.date,d.time)>=?",$d_sDate);#this one filters on time (no index)
    if($d_eDate)bldsql_where("d.date<=date(?)",$d_eDate);#This one can use the index.
    if($d_eDate)bldsql_where("timestamp(d.date,case when time(timestamp('$d_eDate'))='00:00:00' then '00:00:00' else d.time end)<=timestamp(?)",$d_eDate);#this one filters on time (no index).treat null time as end of day
    if($d_comment)bldsql_where("d.comment like ?",$d_comment);
    
    if($tag_prelim){#make sure to include events with no measurements yet.
        $sql="(select d.event_num,v.data_num from flask_data d, flask_data_tag_view v where v.data_num=d.num and v.prelim=1
                union
                select v.event_num,ifnull(d.num,0) as data_num from flask_event_tag_view v left join flask_data d on v.event_num=d.num where v.prelim=1) as prelimTags";
        bldsql_from ($sql);
        if($flaskData)bldsql_where("d.num=prelimTags.data_num");
        bldsql_where("e.num=prelimTags.event_num");
        bldsql_distinct();#There'll be mulitple events when not in flaskData mode.
    }
    return $flaskData;
}

function fillTableFromArray($tableName,$colName,$arr){
	/*Create and pass tablename, it will be filled with values from arr.  Not very efficient, could do multiple values list but then would have to split occasionally*/
	$i=0;
	foreach($arr as $val){
		if(doinsert("insert into $tableName ($colName) values (?)",array($val)))$i++;
	}
	return $i;
}
function helpText($topic){
    global $help;
    return $help[$topic];    
}
function helpLink($topic,$style='',$linkText="&nbsp;&nbsp;&nbsp;?"){
    #Returns a href to topic.
    $text=htmlspecialchars(helpText($topic));
    $id=uniqid("help");
    $style=($style)?"style='$style'":"";
    $html="<a id='$id' href=\"help.php?#$topic\" title=\"$text\" class='help' target='_new' $style>$linkText</a>
    <script language='JavaScript'>$('#$id').tooltip({
        content: function (){
            return $(this).prop('title');
            }
        });</script>";
    return $html;
}
function getStatistics(){
    #Returns html to display statistics on tag converted datasets, number of tags...
    bldsql_init();
    bldsql_from("autoupdateable_data_flags a");
    bldsql_from("gmd.site s");
    bldsql_from("gmd.project p");
    bldsql_from("ccgg.strategy st");
    bldsql_from("gmd.program pr");
    bldsql_where("a.project_num=p.num");
    bldsql_where("a.site_num=s.num");
    bldsql_where("a.program_num=pr.num");
    bldsql_where("a.strategy_num=st.num");
    bldsql_col("s.code as site");
    bldsql_col("p.abbr as project");
    bldsql_col("pr.abbr as program");
    bldsql_col("st.abbr as strategy");
    bldsql_col("case when a.parameter_num=0 and a.program_num=0 then 'all' when a.parameter_num=0 then 'all for program' else a.parameter_num end as gases");
    bldsql_orderby("s.code");
    #$datasets=printTable(doquery(),"",0,"","","300px");
    
    #Actually, we'll group as it's getting a bit bigger now.
    bldsql_init();
    bldsql_from("autoupdateable_data_flags a");
    bldsql_from("gmd.site s");
    bldsql_from("gmd.project p");
    bldsql_from("ccgg.strategy st");
    bldsql_from("gmd.program pr");
    bldsql_where("a.project_num=p.num");
    bldsql_where("a.site_num=s.num");
    bldsql_where("a.program_num=pr.num");
    bldsql_where("a.strategy_num=st.num");
    bldsql_col("pr.abbr as program");
    bldsql_col("p.abbr as project");
    bldsql_col("st.abbr as strategy");
    bldsql_col("group_concat(distinct s.code order by s.code separator ', ') as sites");
    #bldsql_col("case when a.parameter_num=0 and a.program_num=0 then 'all' when a.parameter_num=0 then 'all for program' else a.parameter_num end as gases");
    bldsql_groupby("pr.abbr,p.abbr,st.abbr");
    #$datasets=printTable(doquery(),"",0,"","","");
    #$hats=printTable(doquery("select 'HATS' as program, 'all' as project, 'all' as strategy,'all' as sites"));
    #$params=printTable(doquery("select 'ccgg' as program, 'ccg_surface' as project,'flask' as strategy,'all' as sites, 'co' as parameter"));
    #$num=doquery("select count(*) from flask_data where update_flag_from_tags=1",0);
    $html="<table width='500px'>
            <tr><td><span class='title3'>Datasets converted to tagging system:</span></td></tr>
            <tr><td>$datasets</td></tr>
            <tr><td>$hats</td></tr>
            <tr><td>$params</td></tr>
        </table>
            
    ";
    $sql="select distinct case when a.project_num=0 then 'all' else s.project end as project, 
    case when a.strategy_num=0 then 'all' else s.strategy end as strategy,
    case when a.program_num=0 then 'all' else s.program end as program,
    case when a.parameter_num=0 then 'all' else s.parameter end as parameter,
    case when a.site_num=0 then 'all' else s.site end as site
from autoupdateable_data_flags a join data_summary_view s on
    (a.project_num=0 or a.project_num=s.project_num) and (a.strategy_num=0 or a.strategy_num=s.strategy_num)
    and (a.program_num=0 or a.program_num=s.program_num) and (a.parameter_num=0 or a.parameter_num=s.parameter_num)
    and (a.site_num=0 or a.site_num=s.site_num)";
    
    $html=printTable(doquery($sql),'',0,'','500px','500px','','',false);

    #$html=getPopup($html,"Datasets","Data Tagger Statisitics","500");
    $html=getPopupAlert($html,true,$windowTitle="Datasets");
    return $html;
}

?>
