<?php
/*Tag edit functions*/
function isRangeEditable($range_num){
    #Returns true if range can be edited (doesn't check user permissions though)
    #false if this range is from a data source (like HATS) that should not be edited.
    $dataSource=0;
    $dataSource=doquery("select data_source from tag_ranges where num=?",0,array($range_num));
    if($dataSource== 11 || $dataSource==12)return false; #Both HATS syncs
    return true;
}
function getTagEditForm($range_num,$mode,$event_num,$data_num){
    /*$mode can be 'add', 'edit' or 'append'.  Append allows adding a comment.
     *$range_num is required for edit/append mode.
     *$event_num and $data_num are only relevant in add mode.  If passed they override the selection criteria.
     *Note we don't do security check here, we assume the above logic only enabled the edit/add button appropriately so
    we don't need to do another frontend check.  Once submitted to server, we'll of course verify access before sending to db.*/
    $range_comment="";$tag_num="";$tag_desc="";$range_prelim=0;$d_count=0;$ev_count=0;$unsel_ev_count=0;$unsel_d_count=0;$warning="";
    if($mode!='add' && $mode!='edit' && $mode!='append')return "Error: Invalid form mode";
    if(($mode=='append' || $mode=='edit') && $range_num=="")return "Error: invalid form parameters.";
    
    if($range_num){
        bldsql_init();
        bldsql_from("tag_ranges r");
        bldsql_where("r.num=?",$range_num);
        bldsql_col("r.tag_num");
        bldsql_from("tag_view t");
        bldsql_where("r.tag_num=t.num");
        bldsql_col("t.display_name as tag_desc");
        bldsql_col("r.comment as 'range_comment'");
        bldsql_col("r.prelim as range_prelim");
        $a=doquery();
        if($a) extract($a[0],EXTR_OVERWRITE);//This overrites above declared variables for selected col vars.
        $range_comment=htmlentities($range_comment);
    }
    
    #Get some metrics on how many rows will be impacted
    $flaskData=buildIDTable2($event_num,$data_num);
    if($range_num){        
        $ev_count=doquery("select count(*) from flask_event_tag_range where range_num=$range_num",0);
        if($ev_count>0)$d_count=doquery("select count(d.num) from flask_event_tag_range r, flask_data d where d.event_num=r.event_num and r.range_num=$range_num",0);
        else $d_count=doquery("select count(*) from flask_data_tag_range where range_num=$range_num",0);
        
        
        #See if the range is covered by the current selection;
        $sql="";
        #Flesh out both event and data selection tables to make the queries a bit easier.
        if($flaskData)doquery("create temporary table t_events as select distinct event_num as num from flask_data d, t_data t where t.num=d.num",false);
        else doquery("create temporary table t_data as select d.num from t_events t, flask_data d where d.event_num=t.num",false);
        
        $unsel_ev_count=doquery("select count(r.event_num) from flask_event_tag_range r left join t_events t on r.event_num=t.num where r.range_num=$range_num and t.num is null",0);
        $unsel_d_count=doquery("select count(r.data_num) from flask_data_tag_range r left join t_data t on r.data_num=t.num where r.range_num=$range_num and t.num is null",0);
        $warning="Warning!  This tag is attached to ";
        if($unsel_ev_count){                
            $warning.=($unsel_ev_count>1)?number_format($unsel_ev_count)." flask_event samples ":"1 flask_event sample ";
            $warning.="not in the current search results.  Any changes to the tag will also apply to those samples.  Continue?";
        }elseif($unsel_d_count){
            $warning.=($unsel_d_count>1)?number_format($unsel_d_count)." flask_data measurements ":"1 flask_data measurement ";
            $warning.="not in the current search results.  Any changes to the tag will also apply to those measurements.  Continue?";
        }else $warning="";#unset
    }else{
        #presumeably adding, get the count from the selection criteria.
        if($flaskData){
            $ev_count=0;
            $d_count=doquery("select count(*) from t_data",0);
        }else{
            $ev_count=doquery("select count(*) from t_events",0);
            $d_count=doquery("select count(*) from t_events t, flask_data d where d.event_num=t.num",0);
        }
    }
    
    $alert="";
    #Build the alert mssg.
    $ev_plural=($ev_count>1)?"s":"";
    $d_plural=($d_count>1)?"s":"";
    $evthese=($ev_count>1)?"these":"this";
    if($ev_count==0){#adding to data ros.
        $alert="<span class='alert_num'>".number_format($d_count)."</span> flask_data measurement".$d_plural.".";            
    }else{
        $alert="<span class='alert_num'>".number_format($ev_count)."</span> sample event".$ev_plural."
                and<br> apply to <span class='alert_num'>".number_format($d_count)."</span> existing (and all future) measurement${d_plural} from $evthese sample${ev_plural}.";
    }
    if($mode=='add'){       
        $alert="This tag will be added to: $alert";
    }elseif($mode=='edit')$alert="This edit will apply to: $alert<br><i>Changing the tag may affect the external flags of all measurement rows.</i>";
    else $alert="This comment will be applied to:<br> $alert";
    
    $prelimChecked=($range_prelim)?"checked":"";
    #$jsonCriteria="";NOTE if enabling append function, need to add this somehow.<input type='hidden' id='tagEdit_jsonCriteria' name='tagEdit_jsonCriteria' value='$jsonCriteria'>
    $baseQueryHash=getHTTPVar("baseQueryHash");
    $tagEditable=($mode=='add'||$mode=='edit')?true:false;
    $autoAddText=($tagEditable)?updateOpenEndedRangeCriteria($range_num,$event_num,$data_num):"";#This definately should show on add/edit.  Not sure about other modes (like non-programmed append)
    
    $html="<form id='tagEditForm' style='height:100%'>
            <input type='hidden' id='tagEdit_range_num' name='tagEdit_range_num' value='$range_num'>
            <input type='hidden' id='tagEdit_editMode' name='tagEdit_editMode' value='$mode'>
            <input type='hidden' id='tagEdit_baseQueryHash' name='tagEdit_baseQueryHash' value='$baseQueryHash'>
            ";
    if($mode=='add'){
        $html.="<input type='hidden' id='tagEdit_event_num' name='tagEdit_event_num' value='$event_num'>
                <input type='hidden' id='tagEdit_data_num' name='tagEdit_data_num' value='$data_num'>";
    }
    $html.="<table width='100%' style='height:100%' border='0'>
                <tr>
                    <td colspan='2' class='label' valign='top'>";
    $html.=getTagEditTagSelect($tag_num,$event_num,$data_num,$tagEditable);
    $html.="        </td>
                </tr>";
    if($mode=='append'){#Show the existing comment ro and provide spot for new comment
        $html.="<tr><td class='label'></td>
                    <td  class='data'><textarea style='width:95%;' rows='3' class='tedit_field' >$range_comment</textarea></td></tr>
                <tr><td class='label'>New Comment: </td><td class='data' style='height:100%;'><textarea style='width:95%;height:95%;' rows='2' class='tedit_field' name='tagEdit_comment' id='tagEdit_comment' ></textarea></td></tr>        
            ";
    }else{
        $html.="<tr><td class='label'>Comment: </td><td class='data' style='height:100%;'><textarea style='width:95%;height:95%;' rows='3' class='tedit_field' name='tagEdit_comment' id='tagEdit_comment' >$range_comment</textarea></td></tr>
                <tr><td colspan='2' align='right'>Preliminary<input type='checkbox' id='tagEdit_prelim' name='tagEdit_prelim' $prelimChecked value='1'></td></tr>
                <tr><td colspan='2' align='right'>$autoAddText</td></tr>";
    }
    $html.="    
                <tr>
                    <td align='center' colspan='2' valign='bottom'><span>$alert</span></td>     
                </tr>           
                <tr>
                    <td align='left' valign='bottom' width='20px'>
                        <button style='float:left;' id='tagEdit_cancel_button'>Cancel</button>".getButtonJS2('tagEdit_cancel_button','cancel_tagEdit',3,$range_num,$event_num,$data_num)."
                    </td>
                                  
                    <td align='right' valign='bottom'>
                        <button style='float:right;' id='tagEdit_submit_button' >Save</button>".getButtonJS('tagEdit_submit_button','submit_tagEdit_form','','',$warning)."
                    </td>
                </tr>
                       
                    
                
            </table>";
    return $html;
}
function getTagEditTagSelect($tag_num="",$event_num="",$data_num="",$editable=true){//Build html for the tag select on edit form.  This could probably be merged with the one for selection at some point
    #If $tag_num passed, we make sure that tag (existing) is included and selected 
    $name="tagEdit_tag_num";
    $html="";$inSubCat=false;
    $sql=getAvailTagsForSelectionQuery($tag_num,$event_num,$data_num);
    #return $sql;
    $editable=($editable)?"":"disabled";
    $a=doquery($sql);
    if($a){
        $grpName='';
        $html.="<div class='data ui-widget'><span class'label' style='vertical-align:top;'>Tag: </span><select $editable id='$name' name='$name' class='tagEdit dynamic_selectmenu'  style='width:95%;max-width:400px;'>";
        $html.="<option value=''></option>";
        foreach($a as $row){
                extract($row);
                if($group_name!=$grpName){
                    $grpName=$group_name;
                    $html.="<optgroup label='".htmlspecialchars($grpName)."'>";
                }
                $selected=($tag_num==$pkey)?"selected":"";
                if(strpos($display_name,"   ")===0 ){#make assumption that sub-cats are indented 3 spaces
                    if(!$inSubCat){
                        $t=substr($display_name, 3, 6);
                        $html.="<option value='-1' disabled>&nbsp;&nbsp;&nbsp;Optional subcategories of $t</option>";#first one gets a title
                    }
                    $inSubCat=true;#mark that we're currently processing a sub-cat
                }else $inSubCat=false;
                $display_name=str_replace("   ","&nbsp;&nbsp;&nbsp;",$display_name);#preserve leading white space for sub-cats
                $html.="<option value='$pkey' title='".htmlspecialchars($display_name)."' $selected>$display_name</option>";
        }
        $html.="</select>
                <script language='JavaScript'>
                    $('#$name').selectmenu({
                            width:400,
                            maxWidth: 400,      maxHeight: 300, 
                            position: {my:'right top', at: 'right bottom'}
                        })
                        .selectmenu( 'menuWidget' ).addClass( 'selectMenuLongText' )
                        ;
                </script>";#
    }else $html="Error retrieving list of available tags.";
    return $html;#
    
                            
}


function getAvailTagsForSelectionQuery($currTag='',$event_num,$data_num,$flaskData=''){
    /*This returns query (and fills tmp tables) for all available tags for the current
     *selection including current tag if passed.
     *
     *Added the flaskData param because I wanted to use this in a place where the id tables had already been created (no need to do twice).
     *If flaskData is '' (default) then we'll create the tables.  If passed true/false (already been set), we'll just use that value.
      */    
    if($flaskData==="")$flaskData=buildIDTable2($event_num,$data_num);
    bldsql_init();
    bldsql_distinct();
    bldsql_from("tag_view tv");
    bldsql_col("tv.num as pkey");
    bldsql_col("tv.display_name");
    bldsql_col("tv.group_name");
    bldsql_col("tv.sort_order");

    bldsql_from("flask_event e");
    if($flaskData){
        bldsql_from("flask_data d");
        bldsql_from("t_data t");
        bldsql_where("t.num=d.num");
        bldsql_where("d.event_num=e.num");
        
        #See if more than one program in selected data and skip meas tags if so.
        $c=doquery("select count(distinct program_num) from flask_data d join t_data t on t.num=d.num",0);
        if($c!=1){
            bldsql_where("tv.measurement_issue=0"); #Exclude measurement issues from the list of available tags
            bldsql_where("tv.program_num=0"); #and data specific tags
            bldsql_where("tv.parameter_num=0");
        }else{
            bldsql_where("(tv.program_num=0 or tv.program_num=d.program_num)");
            bldsql_where("(tv.parameter_num=0 or tv.parameter_num=d.parameter_num)");
        }
    }else{
        bldsql_from("t_events t");
        bldsql_where("t.num=e.num");
        bldsql_where("tv.measurement_issue=0"); #For flask_event tags, we'll exclude measurement issues from the list of available tags
        bldsql_where("tv.program_num=0"); #and data specific tags
        bldsql_where("tv.parameter_num=0");
    }
    bldsql_where("(tv.strategy_num=0 or tv.strategy_num=e.strategy_num)");
    bldsql_where("(tv.project_num=0 or tv.project_num=e.project_num)");
    $id=db_getAuthUserID();

    if(db_getAuthUserID()!=60 && db_getAuthUserID()!=18)bldsql_where("tv.automated=0");#hide automatic tags from entry selection except for the superuser (john & Molly)
    bldsql_where("tv.deprecated=0");#and deprecated ones.  Note if currtag is deprecated, it will be added in below union
    $sql=bldsql_cmd();
    
    if($currTag){
        #if a current tag was passed, do a union to ensure that it is in the resulting list.  If it already was, this will be a no op because union removes dups
        bldsql_init();
        bldsql_col("tv.num as pkey");
        bldsql_col("tv.display_name");
        bldsql_col("tv.group_name");
        bldsql_col("tv.sort_order");
        bldsql_from("tag_view tv");
        bldsql_where("tv.num=$currTag");
        $sql.=" union ".bldsql_cmd();
    }
    #var_dump($sql);exit();
    $sql.=" order by sort_order";
    return $sql;
}
function updateOpenEndedRangeCriteria($range_num,$event_num,$data_num,$precheck=true){
    /*If appropriate, update the openEndedRange criteria table. 
     *  Range_num, event_num and data_num can all be '' when appropriate (add vs edit mode)
        If $precheck=true then we don't actually update the table, just return a mssg for tag_edit form (checkbox and explanation).
            Note this differs if we're in add or edit mode.  In edit mode (range_num exists), we check the actual table to
            get the current status as legacy rows may not be converted.  In add mode, we look at current selection to see if it's appropriate.
        If precheck=false, we return an empty string on success and error message otherwise.
            Note no update is considered a success when we can't update due to criteria.
        Note; this does NOT wipe out any bldsql_ base (initialize) 
        Note; to add new openEnd-able filter:
            -add to $filters below
            -add to $t in the add message
            -add to insert statement and $bind array
            -add to mysql tag_range_openended_criteria table
            -add to mysql tag_addToOpenEndedRanges procedure 
            
    */

    if($event_num || $data_num)return "";#This logic is not relevant when tagging by id.
    
    $flaskData=buildQueryBase(false,false,false,false,true);#call once to get target data for mssg.
    $criteria=buildQueryBase(false,false,false,true);#Call again for all the actual filters.
    $filterDesc=($precheck)?buildQueryBase(false,false,true):"";#generate a description in precheck mode.
    #Prettify the desc a little.
    $filterDesc="<ul><li>".str_replace("|","</li><li>",$filterDesc)."</li></ul>";


    #These are the target filters we can use.
    $filters=array('ev_site_num','ev_project_num','ev_strategy_num','ev_sDate','ev_eDate','d_program_num','d_parameter_num','ev_method');
    
    #Loop through criteria and see if we should add/update criteria table.
    $canUpdate=true;$hasFilters=false;$mssg='Error in updateOpenEndedRangeCriteria';
    $targets=($flaskData)?"measurement rows":"sample events";
   
    
    foreach ($filters as $fkey){#See if at least one of the filters were set.
        if($criteria[$fkey]){
            $hasFilters=true;
        }
        #Verify that both ev dates were set
        $hasFilters=($hasFilters && $criteria['ev_sDate'] && $criteria['ev_eDate']);
    }
    foreach ($criteria as $key=>$val){#If any of the 'other' filters are set, we can't update.
        if($val && !in_array($key,$filters)){
            $canUpdate=false;            
        }
    }
    #toLogFile("hasFilters:$hasFilters canUpdate:".var_export($canUpdate,true)." flaskData:$flaskData Criteria:".var_export($criteria,true).", filterdesc:$filterDesc" );
    if($precheck){
        $checked=($canUpdate && $hasFilters)?"checked":"";
        $t="";
        if($range_num){#Existing tag.  We'll check to see if it's in the table and display a message appropriately.
            #Note; the current selection criteria is not likely the same as was used for selected tag (canUpdate and hasFilters are wrong).
            #because to get here, the user clicked an existing tag which could be for just a subset of the current selection.  It might be the
            #same, but not likely, so recalc checked and $targets.
            $hasRows=doquery("select count(*) from tag_range_openended_criteria where range_num=?",0,array($range_num));
            $checked=($hasRows)?"checked":"";
            if($hasRows){#Fetchout info on range.
                doquery("create temporary table t_range_nums (index(num)) as select num from tag_ranges where num=?",false,array($range_num));
                doquery("call tag_getTagRangeInfo",false);
                $flaskData=false;$filterDesc='';
                $a=doquery("select is_data_range as flaskData, tag_description as filterDesc from t_range_info where range_num=?",-1,array($range_num));
                if($a){extract($a[0]);}
                $targets=($flaskData)?"measurement rows":"sample events";
                #Prettify the desc a little.
                $filterDesc="<ul><li>".str_replace("|","</li><li>",$filterDesc)."</li></ul>";
                $t="Any new $targets added to the database will be automatically added to this tag if they match this tag's selection criteria:<br>$filterDesc";
            }
            else{return "";}#existing row with no entries.  Eventually these should be converted.. We could put up a nice message, but...
        }else{#New tag, edit form in add mode.
            if($canUpdate && $hasFilters){           
                $t="Any new $targets added to the database will be automatically added to this tag if they match your selection criteria:<br>$filterDesc";
            }else{
                $t="When the 'Auto add' checkbox is checked, new $targets added to the database are checked to see if they match the
                search criteria used to create a tag. If so, they are automatically added to the tag.<br><br>
                
                This is to allow automatic tagging of things like an ongoing leak at a
                site or to tag measurements that may not have been added to the database yet (sil, arl, curl), but need to be tagged for a sampling
                related issue when they are.<br><br>
                 This box is unchecked when search criteria was used that is not supported by the current logic.  At this time, only searches containing
                one or more of: <ul><li>site</li><li>project</li><li>strategy</li><li>program</li><li>parameter(s)</li><li>method</li></ul>And both:<ul><li>event date 'from' & 'to'</li></ul>
                are eligable for this functionality.<br><br> Because your search:<br>$filterDesc included other criteria, new $targets can't be automatically added to the tag.  Only
                the rows matched below will be tagged.<br>
                Please contact John with any questions.";
            }            
        }
        
        $mssg=getPopUp($t,"?","What is 'auto add'?",'500');
        $mssg="Auto add new matching $targets $mssg<input type='checkbox' $checked disabled>";
        #$mssg='';foreach($criteria as $key=>$val){$mssg.= "$key:$val ";}
    }else{
        #Attempt to update if needed.
        if($canUpdate && $hasFilters){
            if($range_num){
                $a=doquery("select * from tag_range_openended_criteria where range_num=?",-1,array($range_num));                
                $t="";$status=true;
                if($a){#Select out current and log it.
                    foreach($a as $row){
                        foreach($row as $key=>$val){
                            $t.="$key:$val,";
                        }
                        $t.="\n";
                    }
			#jwm 2/23. not sure why needed to delete and then insert with same key instead of just using replace.  Probably because I hadn't started using replace when this was developed (non-sql standard)
                    $sql="delete from tag_range_openended_criteria where range_num=?";
                    #Log the attempt
                    $logText="[AUX SQL]$sql (range_num:$range_num)\nAffected rows:$t";                    
                    logDML($logText);
                    #Execute the stmt
                    $status=doquery($sql,false,array($range_num));
                }
                if($status!==false){                        
                    #Build the sql inserts for new criteria.
                    $sql="insert tag_range_openended_criteria (range_num,site_num,project_num,strategy_num,program_num,parameter_num,ev_s_datetime,ev_e_datetime,method) values ";
                    
                    #Parameter is an array, so loop through, creating an insert for each.
                    if($criteria['d_parameter_num'])$params=$criteria['d_parameter_num'];
                    else $params=array('0');#Sub a zero for empty array.
                    $bind=array();
                    foreach($params as $parameter_num){
                        $sql.="(?,?,?,?,?,?,timestamp(?),timestamp(?),?),";
                        $bind[]=$range_num;
                        $bind[]=($criteria['ev_site_num'])?$criteria['ev_site_num']:0;
                        $bind[]=($criteria['ev_project_num'])?$criteria['ev_project_num']:0;
                        $bind[]=($criteria['ev_strategy_num'])?$criteria['ev_strategy_num']:0;
                        $bind[]=($criteria['d_program_num'])?$criteria['d_program_num']:0;
                        $bind[]=$parameter_num;
                        $bind[]=$criteria['ev_sDate'];
                        $bind[]=$criteria['ev_eDate'];
                        $bind[]=($criteria['ev_method'])?$criteria['ev_method']:'';
                    }
                    $sql=substr($sql, 0, -1);#Strip trailing comma.
                    
                    #Log the insert
                    $bindText='';
                    foreach($bind as $val){$bindText=appendToList($bindText,$val);}
                    logDML('[AUX SQL]'.$sql." ".$bindText);
                    #Send through
                    $status=doquery($sql,false,$bind);
                    if($status!==false)$mssg="";#Success!
                    else logDML("Error: previous insert tag_range_openeded_criteria failed");
                }else $mssg="There was an error removing previous criteria.";
            }else $mssg="Error; no rangeNum passed to updateOpenEndedRangeCriteria.";
        }else $mssg='';#We return no error if we don't attempt.
    }
    
    return $mssg;
    
}
function submitTagEdit($callMode='editForm',$range_num="",$editModeOverride=""){
    #Submit posted tag edit/add
    #Returns updated tagInfo area  with either a success message or error message
    #We prepend a status number to the returned message to tell the js where to load the text.
    #1  is success, reload the whole taglist/edit area with returned contents.
    #2 is a error, put returned data into the form edit div

    /*$callMode= editForm is default, edit tag form. 'criteriaRange' is when editing the members using filter criteria.  In that case range_num is required.*/
    $event_num="";$editMode="";$data_num="";$tag_num="";$prelim="";$comment="";$hash="";
    if($callMode=='editForm' || $callMode=='rev_editForm' || $callMode=='air_editForm'){
        $editMode=($callMode=='editForm' || $callMode=='air_editForm')?getHTTPVar("tagEdit_editMode"):$editModeOverride;
        $event_num=getHTTPVar("tagEdit_event_num","",VAL_INT);
        $data_num=getHTTPVar("tagEdit_data_num","",VAL_INT);
        $range_num=getHTTPVar("tagEdit_range_num","",VAL_INT);
        $tag_num=getHTTPVar("tagEdit_tag_num","",VAL_INT);
        $prelim=getHTTPVar("tagEdit_prelim","0",VAL_INT);
        if(($callMode=='rev_editForm' || $callMode=='air_editForm') && $editMode=='edit')$comment=getHTTPVar("tagEdit_existingComment",null);
        elseif(($callMode=='rev_editForm' || $callMode=='air_editForm') && $editMode=='append')$comment=getHTTPVar("tagEdit_comment","Tag reviewed");#Default text for review to create an entry.
        else $comment=getHTTPVar("tagEdit_comment",null);
        $hash=getHTTPVar("tagEdit_baseQueryHash");
    }elseif($callMode=='criteriaRange'){
        $editMode=$callMode;
    }else return "Unknown submit mode: $callMode";
    
    $msg="";$counter=0;
    $v_userID=db_getAuthUserID();

    $logParams="[Parameters] Edit Mode:$editMode, Event num:$event_num, Data num:$data_num, Range_num: $range_num, Tag_num: $tag_num, Prelim:$prelim, Comment:\"$comment\"";
    /*Actually, we've decided to drop this as it doesn't really add much value
    #Verify the search hash hasn't changed since they loaded the tedit form. Start by rebuilding the filter criteria
    $flaskData=buildQueryBase();    
    #Create a temp table to hold our keys.  We also use this to verify the search criteria hasn't changed by creating a hash with the criteria.
    $numRows=buildIDTable($flaskData);
    $currHash=bldsql_getQueryHash($numRows);
    $idTable=($flaskData)?"t_data":"t_events";
    
    if($hash!=$currHash){
        $msg="2ERROR: Filter parameters have changed since this form was loaded or the number of matching rows has changed since the search button was clicked.  Please click search button to reload and try again.<br>Orig hash:$hash<br>Curr hash:$currHash";
        logError($msg,4);
        return $msg;
    }
    */
    
    $status="1";$mssg="";$numrows="";$a=false;$sql="";$bArray=array();$logKeySQL="";$logText="";$logKeys="";
    $statusSQL="select @v_status as status, @v_mssg as mssg, @v_numrows as numrows";

    #We'll call a few different procedures depending on the edit mode.  Note the stored procedures will handle doing security check as appropriate.
    switch($editMode){
        case "add":
            #Build the json search criteria used to create this range.
            $json=array();$description="";
            if($data_num){
                $json=arrayToJSON(array('d_data_num'=>$data_num),false);
                $description="Datanum:$data_num";
            }elseif($event_num){
                $json=arrayToJSON(array('ev_event_num'=>$event_num),false);
                $description="Eventnum:$event_num";
            }else{
                $json=buildQueryBase(false,true);
                $description=buildQueryBase(false,false,true);
            }
            
            $logParams.=",JSON:$json,Description:$description";
            
             #Create needed temp tables:
            doquery("create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0",false);
            doquery("create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0",false);
            
            #Fill with target ids
            $flaskData=buildIDTable2($event_num,$data_num);            
            if($flaskData){
                #Inserting for flask_data selection
                $sql="insert t_data_nums select num from t_data";
                $logKeySQL="select num from t_data";#fetch keys for logging.
                $logText="[flask_data pkeys]";
            }else{
                $sql="insert t_event_nums select num from t_events";
                $logKeySQL="select num from t_events";
                $logText="[flask_event pkeys]";
            }            
            doquery($sql,false);
            
            #Fetch out keys for logging
            $a=doquery($logKeySQL);
            $keys="";
            foreach($a as $row){$keys=appendToList($keys,$row['num']);}            
            $logKeys=$logText.$keys;
            
            #call stored proc to do inserts and update external flags if needed.
            $sql="call tag_createTagRange (?,?,?,?,?,7,?,@v_status,@v_mssg,@v_numrows,@v_range_num)";
            $bArray=array($v_userID,$tag_num,$comment,$prelim,$json,$description);
            $statusSQL.=", @v_range_num as range_num";
 
            break;
        
        case 'criteriaRange':
            #Build the json search criteria & description used to create this range.
            $json=array();
            $json=buildQueryBase(false,true);
            $description=buildQueryBase(false,false,true);
            $logParams.=",JSON:$json,Description:$description";
            
             #Create needed temp tables:
            doquery("create temporary table t_data_nums (index(num)) as select num from flask_data where 1=0",false);
            doquery("create temporary table t_event_nums (index(num)) as select num from flask_event where 1=0",false);
            
            #Fill with target ids
            $flaskData=buildIDTable2($event_num,$data_num);            
            if($flaskData){
                #Inserting for flask_data selection
                $sql="insert t_data_nums select num from t_data";
                $logKeySQL="select num from t_data";#fetch keys for logging.
                $logText="[flask_data pkeys]";
            }else{
                $sql="insert t_event_nums select num from t_events";
                $logKeySQL="select num from t_events";
                $logText="[flask_event pkeys]";
            }            
            doquery($sql,false);
            
            #Fetch out keys for logging
            $a=doquery($logKeySQL);
            $keys="";
            foreach($a as $row){$keys=appendToList($keys,$row['num']);}            
            $logKeys=$logText.$keys;
            
            #call stored proc to do inserts and update external flags if needed.
            $sql="call tag_updateTagRangeMembers(?,?,?,?,@v_status,@v_mssg,@v_numrows)";
            $bArray=array($v_userID,$range_num,$json,$description);
 
            break;
        
        case 'append':
            #Add comment.
            $sql="call tag_appendTagComment (?,?,?,@v_status,@v_mssg,@v_numrows)";
            $bArray=array($v_userID,$range_num,$comment);
            
            break;
        case 'appendTo':
            
            break;
        case "edit":
            #edit row.
            $sql="call tag_updateTagRange (?,?,?,?,?,@v_status,@v_mssg,@v_numrows)";
            $bArray=array($v_userID,$range_num,$comment,$tag_num,$prelim);
            break;
        case "delete":
            #delete row.
            $sql="call tag_deleteTagRange (?,?,@v_status,@v_mssg,@v_numrows)";
            $bArray=array($v_userID,$range_num);
            $range_num="";#Clear old num so form doesn't try to reload.
            break;
        default:
            return "2Error: invalid edit mode: $editMode.";
            break;
    }
    
    #Log the attempt
    $logText="[SQL]$sql\n$logParams\n$logKeys";
    logDML($logText);
    
    #Execute the procedure
    doquery($sql,false,$bArray);
    
    #Fetch the status
    $a=doquery($statusSQL);
        
    #Unpack the return variables.
    if($a)extract($a[0]);
    
    if($status==0 && $callMode!="air_editForm" && $callMode!="rev_editForm"){
        #No error, try to update the criteria table if appropriate.
        if($editMode=='criteriaRange' || $editMode=='add'){
            $tmssg=updateOpenEndedRangeCriteria($range_num,$event_num,$data_num,false);
            if($tmssg){
                #any mssg returned is an error.
                logError("[updateOpenEndedRngeError]".$tmssg,4);
                $mssg.=" $tmssg";
                $status=1;
            }
        }
    }
    if($status){
        #Some sort of error.  Just display message returned from procedure.
        logError($mssg,4);
        $html="2".$mssg;
  
    }else{
        #Success, show mssg in a self clearing div.
        
        if($callMode=="rev_editForm"){#review module
            $mssg="<div class='title4' style='text-align: center;'><br><br><br>Changes successfully submitted.</div>
                <script language='JavaScript'>
                    rev_clearTagEditForm('$range_num');//Clear after a slight delay, then reselect row.
                </script>";
            $html="1".$mssg;
        }elseif($callMode=='air_editForm'){
            return true;#caller assumes ===true is success, all else fail
        }elseif($editMode=='criteriaRange'){#range criteria edit
            $btn="<button id='doSearchButton'>Search</button>".getButtonJS('doSearchButton','doSearch');
            $html="1<div class='title4' style='text-align: center;'><br><br><br>$mssg
            <br><br><br>Your search criteria have been reloaded.  Click $btn to reload the results.
            </div>";
        }else{#normal tag edit..
            $btn="<button id='reloadQueryBtn' onclick='doSearch();return false;'>Reload table</button>";
            $staleMssg="Tag and flag columns in these search results may have just changed. $btn";
            $mssg="<div class='title4' style='text-align: center;'><br><br><br>$mssg</div>
                <script language='JavaScript'>
                    clearTagEditForm('$range_num');//Clear after a slight delay, then reselect row.
                    setStatusMessage(\"$mssg\",20);
                    $(\"#searchOutOfDateDiv\").html(\"$staleMssg\");
                </script>";
            $html="1".getTagList3($event_num,$data_num,$mssg);
        }
    }

    #log the return variables
    $logText="";
    foreach($a as $row){foreach($row as $key=>$val){$logText=appendToList($logText,"$key:$val");}}
    logDML("[CALL STATUS]$logText");

    return $html;
}


?>
