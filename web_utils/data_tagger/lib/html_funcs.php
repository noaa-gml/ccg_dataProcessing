<?php

#Functions to generate widgets and other html output options.  Note, there is corresponding js in index.js


function getEventInfo($event_num="",$evedit_form_message=""){
    /*Returns event edit form for passed event or current selection
    If message passed, that will be displayed too.  This is for when the form is submitted, success/err can be displayed.
    */
    $html="";
    #Fetch event details
    if($event_num){
        bldsql_init();
        #Note table aliases must match those in buildQueryBase();
        #Event joins happen regardless.
        bldsql_from("flask_event e");
        bldsql_where("e.num=?",$event_num);
        
        bldsql_from("gmd.project proj");
        bldsql_where("e.project_num=proj.num");
        
        bldsql_from("ccgg.strategy strat");
        bldsql_where("strat.num=e.strategy_num");
        
        bldsql_from("gmd.site s");
        bldsql_where("s.num=e.site_num");
    }else{
        #!!NOT PROGRAMMED YET>
        buildQueryBase();
        
    }
    bldsql_distinct();
    bldsql_col("e.num as event_num");
    bldsql_col("e.site_num");
    bldsql_col("proj.abbr as project");
    bldsql_col("strat.abbr as strategy");
    bldsql_col("case when e.time>'00:00:00' then concat(e.date,' ',substr(e.time,1,5)) else e.date end as datetime");
    
    bldsql_col("e.id as flaskid");
    bldsql_col("e.me");
    bldsql_col("e.lat");
    bldsql_col("e.lon");
    bldsql_col("e.alt");
    bldsql_col("e.elev");
    bldsql_col("e.comment");
               
    $a=doquery();
    $project="";$date="";
    if($a){
        extract($a[0]);

        $html.="<div class='title3'>Sample Event Details</div>
            <form id='evedit_form' name='evedit_form'>
            <table width='100%'>
                <tr>
                    <td class='label'>Event Number</td>
                    <td class='data'>
                        <input type='text' id='evedit_event_num' name='evedit_event_num' readonly size='10' value='$event_num'>
                    </td>
                    <td class='label'>Date</td>
                    <td class='data'>
                        <input type='text' id='evedit_date' readonly size='15' value='$datetime'>
                    </td>
                </tr>
                <tr>
                    <td class='label'>Project</td>
                    <td class='data'>
                        <input type='text' id='evedit_project' readonly size='10' value='$project'>
                    </td>
                    <td class='label'>Strategy</td>
                    <td class='data'>
                        <input type='text' id='evedit_strategy' readonly size='10' value='$strategy'>
                    </td>
                </tr>
                <tr>
                   <td class='label'>Flask</td>
                   <td class='data'>
                       <input type='text' id='evedit_flaskid' readonly size='10' value='$flaskid'>
                   </td>
                   <td class='label'>Method</td>
                   <td class='data'>
                       <input type='text' id='evedit_method' readonly size='10' value='$me'>
                   </td>
               </tr>
               <tr>
                   <td class='label'>Lat</td>
                   <td class='data'>
                       <input type='text' id='evedit_lat' size='10' name='evedit_lat' value='$lat' class='evedit_input'>
                   </td>
                   <td class='label'>lon</td>
                   <td class='data'>
                       <input type='text' id='evedit_lon' name='evedit_lon' size='10' value='$lon' class='evedit_input'>
                   </td>
               </tr>
               <tr>
                   <td class='label'>Alt</td>
                   <td class='data'>
                       <input type='text' id='evedit_alt' size='10' name='evedit_alt' value='$alt' class='evedit_input'>
                   </td>
                   <td class='label'>Elev</td>
                   <td class='data'>
                       <input type='text' id='evedit_elev' name='evedit_elev' size='10' value='$elev' class='evedit_input'>
                   </td>
               </tr>
               <tr>
                    <td class='label'>Comment</td>
                    <td colspan='3' class='data'><textarea rows='3' cols='40' id='evedit_comment' name='evedit_comment' class='evedit_input'>$comment</textarea>
               </tr>
               <tr><td colspan='3'><div id='evedit_form_message'>$evedit_form_message</div></td><td align='right'><button id='evedit_submit_button' disabled>Save</button>".getButtonJS('evedit_submit_button','submit_evedit_form')."</td></tr>
            </table>
            </form>
            <script language='JavaScript'>
                $('.evedit_input').change(function(event){
                    //Enable the submit button
                    $('#evedit_submit_button').prop('disabled',false);
                    //Clear any previous message
                    $('#evedit_form_message').empty();
               });
               //autoclear any message after a few seconds
               //setTimeout(clearDiv('evedit_form_message'),2000);
            </script>
        ";
    }
    return $html;
    
}
function getTagSelect($type,$a,$event_num,$data_num,$edit){
    #build the taglist select
    #$type is 'ev' or 'd'
    #$a is the query result containing tagID and name cols of tags
    $html="";
    
    #Set the form & id to use
    $editMode=($edit)?"'1'":"'0'";
    $selectID=($type=="d")?"d_tag_list":"ev_tag_list";
    $jsform=($type=="d")?"getDataTagEditForm(val,'$event_num','$data_num',$editMode);$('#tedit_ev_form_div').empty(); $('#ev_tag_list').val([]);":"getEvTagEditForm(val,'$event_num',$editMode); $('#tedit_d_form_div').empty();$('#d_tag_list').val([]);";

    if($a){
        #Set the select window size
        $size=count($a);
        if($size<3)$size=2;
        if($size>10)$size=10;
        
        
        $html.="    <select size='$size' id='$selectID' class='tag_select_box'>";
        foreach($a as $row){
            extract($row); 
            $html.="<option value='$tagID'>$name</option>";    
        }    
        $html.="    </select>
                    <script language='JavaScript'>
                        $('#".$selectID."').change(function(){
                            var val=$(this).val();
                            $jsform                       
                        });
                        
                    </script>";
    }
    
    $html.="<div id='tedit_".$type."_form_div'></div>";
    if($edit)$html.="<button id='add_tag_button'>Add tag</button>
            <script language='JavaScript'>
            $(\"#add_tag_button\").click(function(event){
                event.preventDefault();
                var val='';
                $jsform
            });
        </script>
        ";
    return $html;
}
function getButtonJS($id,$action,$param1="",$param2="",$confirmationText=""){
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
function getButtonJS2($id,$action,$numParams,$param1="",$param2="",$param3="",$confirmationText=""){
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
function getTagSeverityFormHTML($tag_num,$edit,$severity="0"){
    //Returns the severity widget (2 tds for a tr) for passed tag_num.
    $sql="select ifnull(min_severity,0) as min_severity,ifnull(max_severity,0) as max_severity,reject_min_severity from tag_dictionary where num=$tag_num";
    if($tag_num)$a=doquery($sql);
    $html="<td colspan='2'></td>";
    if($tag_num && $a){
        extract($a[0]);
        if($min_severity && $max_severity){
            $disabled=($edit)?"":"disabled: true,";
            $rej=($reject_min_severity)?$reject_min_severity."+ is cause for analysis rejection":"";
            $severity=($severity==0)?"":$severity;
            $sevVal=($severity)?"value:$severity,":"";
            $html="<td style='vertical-align: top;' class='label'>Severity</td>
            <td style='vertical-align: top;'>
                <table width='100%' cellspacing='0'>
                    <tr><td><input readonly type='text' size='3' id='tedit_severity' name='tedit_severity' value='$severity'></td><td>$min_severity</td><td width='70%'><div id='tedit_severity_slider'></div></td><td>&nbsp;$max_severity</td></tr>
                    <tr><td colspan='4'><span class='tiny_data' style='text-align: left;'>$rej</span></tr>
                    
                </table>
                <script language='JavaScript'>
                    $('#tedit_severity_slider').slider({
                        min:$min_severity,
                        max:$max_severity,
                        $disabled
                        $sevVal
                        slide: function(event, ui) {
                            $('#tedit_severity').val(ui.value);
                        }
                    });
                    
                </script></td>
            ";
        }
    }
    return $html;
}
function getSelectmenuHTML($id,$label,$type,$value='',$allowMultiple=false,$size='4',$helpSection="",$onChangeFunc="",$defaultValue=""){
    #returns the html & js for a selectmenu (select box).  
    #jwm 7.22 not sure what this references
    #If $useFilter, this will dynamically load the list from the selected range on open
    #<div id='".$id."_optionsDiv'>
    
    #$type is 'ev', 'd', 'evedit' or 'tedit'.  The first two are selection inputs, the last is the tag edit form
    #$allowMultiple changes the name variable to an array for php processing.  $size is only relevant when multiple is true.
    #NOTE; $value hasn't been tested yet... but should work if passed through.
    #Actually.. either a bug or deliberate because it caused an issue (don't remember), passing a value is not supported.  I'll
    #have to test thouroughly with dt before re-enabling...
    #Didn't have time to test it, and have sneaking suspition it was causing an issue, but needed to use functionality on different
    #caller (review.php), so added $defaultValue parameter.. not optimal.  bad programmer.
    #If onchangefunction passed, it will get called on a selection.
    
    #If a label is passed this returns a <TR> with 2 tds, if none, then returns tr with single td
    $title="Use the filter button to limit this list to available entries given the current selection criteria";
    $link=($type=='ev'||$type=='d')?"<a href='#' class='dynamic_selectmenu_filter' title='$title'><image id='".$id."_filter' src='images/iconFilter_Button.png' width='25px'></a>":"";
    $val=($value!=='')?"":'';
    $val=$defaultValue;
    $multi=($allowMultiple)?"multiple size='$size'":"";
    $name=($allowMultiple)?$id."[]":$id;
    $label=($label)?"<td class='label'>$label:</td>":"";
    $js=($onChangeFunc)?"onchange=\"$onChangeFunc('$id');\"":"";
    $html="
        <tr>
            $label
            <td>
                <div class='data ui-widget nowrap'>
                <select name='$name' id='$id' class='dynamic_selectmenu search_field ".$type."_field' style='max-width:175px;' $multi $js>
                    ".getSelectMenuOptions($id,false,$val)."
                </select>&nbsp;&nbsp;&nbsp;
                    $link";
                
                    if($id=='d_tag_num'|| $id=='ev_tag_num'){
                        $html.="<script language='JavaScript'>
                        $('#$name').selectmenu({
                                width:175,
                                maxWidth: 175,      maxHeight: 400, 
                                position: {my:'left', at: 'left bottom'}
                            })
                            .selectmenu( 'menuWidget' ).addClass( 'selectMenuLongText' )
                            ;
                    </script>";}
    if($helpSection)$html.=helpLink($helpSection); 
    $html.="    </div>              
            </td>
        </tr>
    ";
    return $html;
}
function getSelectMenuOptions($id,$filter=true, $preSelectVal=""){
    /*Build the options port of the select for passed id.  If curselected passed, then that one will.. get selected*/
    $firstOptionVal='';$firstOptionText='';
    bldsql_init();
    if($filter)buildQueryBase(true);
    bldsql_distinct();
        
    switch($id){
        case "ev_project_num":
            doquery("create temporary table if not exists t_project as select num,abbr from gmd.project where num in (1,2)",false);
            bldsql_from("t_project as opt_tab");
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.abbr as 'value'");
            bldsql_orderby("opt_tab.abbr");
            if($filter){
                bldsql_where("e.project_num=opt_tab.num");
            }
            break;
        case "ev_strategy_num":
            doquery("create temporary table if not exists t_strat as select num,abbr from ccgg.strategy where num in (1,2)",false);
            bldsql_from("t_strat as opt_tab");
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.abbr as 'value'");
            bldsql_orderby("opt_tab.abbr");
            if($filter){
                bldsql_where("e.strategy_num=opt_tab.num");
            }
            break;        
        case "d_program_num":
            doquery("create temporary table if not exists t_program as select num,abbr from gmd.program where num in (1,8,11,12,13)",false);
            bldsql_from("t_program as opt_tab");//Make sure to avoid name collisions
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.abbr as 'value'");
            bldsql_orderby("opt_tab.abbr");
            if($filter){
                bldsql_where("d.program_num=opt_tab.num");
            }
            break;
        case "d_parameter_num":
            doquery("create temporary table if not exists t_parameter as select distinct p.num,p.formula from gmd.parameter p, flask_data d where d.parameter_num=p.num",false);
            bldsql_from("t_parameter as opt_tab");
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.formula as 'value'");
            bldsql_orderby("case when opt_tab.num<=6 then 0 else 1 end");
            bldsql_orderby("opt_tab.formula");
            if($filter){
                bldsql_where("d.parameter_num=opt_tab.num");
            }else{
                #join to flask data to limit to params that actually are used (skip the 'none's)
                bldsql_from("flask_data d");
                bldsql_where("d.parameter_num=opt_tab.num");
            }
            #$firstOptionText='All';
            #$firstOptionVal='all';
            break;
        case "d_inst":
            doquery("create temporary table if not exists t_inst as select distinct inst from flask_data",false);
            bldsql_from("t_inst as opt_tab");
            bldsql_col("opt_tab.inst as 'key'");
            bldsql_col("opt_tab.inst as 'value'");
            bldsql_orderby("opt_tab.inst");
            if($filter){
                bldsql_where("d.inst=opt_tab.inst");
            }
            break;
        case "ev_tag_num":
        
            bldsql_from("tag_view opt_tab");
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.display_name as 'value'");
            bldsql_col("opt_tab.group_name2 as group_name");# adds 'automated ' group name
            if($filter){
                bldsql_from("flask_event_tag as opt_et");        #jwm 7/22.  I'm not sure what this table refers to.. is it ever used?
                bldsql_where("opt_et.tag_num=opt_tab.num");
                bldsql_where("opt_et.event_num=e.num");
            }
            bldsql_where("opt_tab.deprecated=0");
            bldsql_orderby("opt_tab.sort_order4");#puts automated at bottom of list.  NOTE needs ddl sync
            #bldsql_where("opt_tab.measurement_issue=0");
           #var_dump(bldsql_printableQuery());exit();
            break;
        case "d_tag_num":

            bldsql_from("tag_view opt_tab");
            bldsql_col("opt_tab.num as 'key'");
            bldsql_col("opt_tab.display_name as 'value'");
            bldsql_col("opt_tab.group_name2 as group_name");
            if($filter){
                bldsql_from("flask_data_tag as opt_dt");        #jwm 7/22.  I'm not sure what this table refers to.. is it ever used?
                bldsql_where("opt_dt.tag_num=opt_tab.num");
                bldsql_where("opt_dt.data_num=d.num");
            }
            bldsql_where("opt_tab.deprecated=0");
            #var_dump('asdf');exit();
            bldsql_orderby("opt_tab.sort_order4");
            #bldsql_where("opt_tab.collection_issue=0");
            break;

    }
    #var_dump(bldsql_printableQuery());
    $a=doquery();
    if(count($a)==0){
        $firstOptionText="None found";
        $firstOptionVal="";
    }
    #create first entry, either default blank or what was overidden above.
    $html="<option value='$firstOptionVal'>$firstOptionText</option>";
    $grpName='';
    foreach($a as $row){
        $group_name=(isset($row['group_name']))?$row['group_name']:'';
        if($group_name!=$grpName){
            $grpName=$group_name;
            $html.="<optgroup label='".htmlspecialchars($grpName)."'>";
        }
        $key=$row['key'];$value=str_replace(' ','&nbsp;',$row['value']);#preserve leading white space (for tag lists)
        
        $html.="<option value='$key'";
        if($key==$preSelectVal)$html.=" selected";#Select if selected item is there.
        $html.=">$value</option>";
    }
    //if($filter)var_dump($html);
    return $html;
}
function getAutoCompleteHTML($id,$type,$size=3,$existingID='',$class='search_field',$justJS=false,$onChangeFunction=""){
    #Returns the html & js for a popup controller.  Must have corresponding entry in below js method.
    #popup will be the input id/name element and will get set with the 'key' column in below js method.
    #$type is 'ev' or 'd' or 'tagEdit'.
    
    #We put the js here instead of in cached js file because some of these fields (tag edit) are loaded dynamically and so need to have the java binding happen after page load
    #Actually, I think the tag edit  logic doesn't use this any more so it could be in the static files...  Leaving for now because it doesn't do any real harm, except
    #we need to re call setFilterDescription() when gets called before this logic.
    #If onChangeFunction passed, we'll call that (with id) after below logic runs.
    
    #Actually, I just noticed a problem when static file (common) methods are used in the search fields, autocomplete in particular.  It doesn't put the class in the displayed
    #input so it doesn't get cleared.  Not sure if I can add that into common one, so just using this for now..
    $html="";
    $changeJS=($onChangeFunction)?"$onChangeFunction('$id');":"";
    if(!$justJS)$html.="
            <div class='data ui-widget'>
                <input class='popup_with_id search_field ".$type."_field' id='".$id."_display' size='$size'>
                <input type='hidden' class='$class ".$type."_field' value='' id='$id' name='$id'>";
    $html.="    <script language='JavaScript'>".getAutocompleteJSArray($id,$existingID)."
        
                            $(\"#".$id."_display\").autocomplete({
                                source: ".$id."_data,
                                delay:100,
                                minLength: 0,
                                autoFocus: true,
                                change: function(event,ui){
                                    var id=event.target.id;
                                    id=id.substring(0,id.length-8);                                        
                                    if (ui.item) {
                                        $('#'+id).val(ui.item['key']);
                                        console.log('change:'+ui.item['key']);
                                    }else{
                                        //Not a valid entry (user typed and tabbed out without selecting a real value).
                                        //Clear both display and key field
                                        $('#'+id).val('');
                                        $('#'+event.target.id).val('');
                                        console.log('change_clear:'+$('#'+id).val());
                                    }
                                    setFilterDescription();
                                    $changeJS
                                },   
                                select: function(event,ui){//Menu item selected.  Set value 
                                    var id=event.target.id;
                                    id=id.substring(0,id.length-8);                                        
                                    if (ui.item) {
                                        $('#'+id).val(ui.item['key']);
                                        console.log('select:'+ui.item['key']);
                                        setFilterDescription();
                                        $changeJS
                                    }
                                },                   
                            });
                            $(\"#".$id."_display\").on( 'focus', function( event, ui ) {
                                    //Clear the variables and display list
                                    var id=event.target.id;
                                    id=id.substring(0,id.length-8);
                                    $('#'+id).val('');
                                    $('#'+event.target.id).val('');
                                    $(this).autocomplete( 'search', '' );
                                    setFilterDescription();
                                }                                    
                            );
                        </script>";
                
    if(!$justJS)$html.="</div>";

    return $html;
}
function getAutocompleteJSArray($id,$existingID=""){
    #Returns the requested popup's data in js format for use in the initial page load
    #$popup is the form id for the popup.
    #Returned data is in an array specially formatted for the jQuery ui autocomplete widget
    #and will be named $popup_data;
    #key col is the primary key for the table
    #value col is what will get put in the displayed input once a user selects an item
    #label col is what shows up on the popup list.
    
    #$id is the main input id
    #if $existingID is passed, then logic below will make sure it's included in the list
    #NOTE; not yet implemented. slacker.
    bldsql_init();#reset to prevent confusion on programmer error...
    switch($id){
        case "ev_site_num":
            doquery("create temporary table if not exists t_site as select distinct s.num,s.code,s.name from gmd.site s, flask_event e where s.num=e.site_num",false);
            bldsql_init();
            bldsql_from("t_site s");
            bldsql_col("s.num as 'key'");
            bldsql_col("s.code as 'value'");
            bldsql_col("concat('(',s.code,') ',s.name) as 'label'");
            bldsql_orderby("s.code");
            break;
        case "tagEdit_tag_num":
            bldsql_init();
            $flaskData=buildQueryBase();
            bldsql_distinct();
            bldsql_from("tag_view tv ");#left join tag_filters tf on tv.num=tf.tag_num");
            #build up a where statement.  This is a little unwieldly because the bldsql_ lib doesn't support or'ing.
            $whr=" 
                (
                    (tv.project_num=0 or tv.project_num=e.project_num)  
                    and (tv.strategy_num=0 or tv.strategy_num=e.strategy_num)";
            if($flaskData)$whr.="
                    and (tv.program_num=0 or tv.program_num=d.program_num) 
                    and (tv.parameter_num=0 or tv.parameter_num=d.parameter_num)";
            $whr.=" )";
            bldsql_where($whr);
            if($flaskData){
                bldsql_orderby("tv.measurement_issue desc");#Put the measurement items first on the list
            }else{
                #For flask_event tags, we'll exclude measurement issues from the list of available tags
                bldsql_where("tv.measurement_issue=0");
            }
            bldsql_col("tv.num as 'key'");
            bldsql_col("tv.display_name as 'value'");
            bldsql_col("tv.display_name as 'label'");
            bldsql_orderby("tv.collection_issue desc");
            bldsql_orderby("lower(tv.internal_flag)");
            break;
        
        case "tagEdit_ev_tags":#I don't think this is used.  would need deprecated filter if so.
            bldsql_from("tag_view s");
            bldsql_col("s.num as 'key'");
            bldsql_col("s.display_name as 'value'");
            bldsql_col("concat(s.group_name2, ' - ', s.display_name) as 'label'");
            #bldsql_col("group_name2 as category");
            bldsql_orderby("s.internal_flag");
            
            break;
        case "tagEdit_d_tags":#I don't think this is used.  would need deprecated filter if so.
            bldsql_from("tag_view s");
            bldsql_col("s.num as 'key'");
            bldsql_col("s.display_name as 'value'");
            bldsql_col("concat(s.group_name2, ' - ', s.display_name) as 'label'");
            bldsql_orderby("s.internal_flag");
            
            break;
            
        case "ev_tag_num":
            bldsql_from("tag_view s");
            bldsql_col("s.num as 'key'");
            bldsql_col("s.display_name as 'value'");
            bldsql_col("concat(s.group_name2, ' - ', s.display_name) as 'label'");
            #bldsql_col("group_name2 as category");
            bldsql_orderby("s.sort_order4");
            bldsql_where("s.measurement_issue=0");
            bldsql_where("s.deprecated=0");
            
            break;
        case "d_tag_num":
            bldsql_from("tag_view s");
            bldsql_col("s.num as 'key'");
            bldsql_col("s.display_name as 'value'");
            bldsql_col("concat(s.group_name2, ' - ', s.display_name) as 'label'");
            #bldsql_col("group_name2 as category");
            bldsql_orderby("s.sort_order4");
            bldsql_where("s.deprecated=0");
            bldsql_where("s.collection_issue=0");
            break;
        /*These are using the select menu above now...
        case "ev_project_num":
            bldsql_from("gmd.project");
            bldsql_col("num as 'key'");
            bldsql_col("abbr as 'value'");
            bldsql_col("concat('(',abbr,') ',name) as 'label'");
            bldsql_orderby("abbr");
            break;
        case "ev_strategy_num":
            bldsql_from("ccgg.strategy");
            bldsql_col("num as 'key'");
            bldsql_col("abbr as 'value'");
            bldsql_col("concat('(',abbr,') ',name) as 'label'");
            bldsql_orderby("abbr");
            break;
        case "d_program_num":
            bldsql_from("gmd.program");
            bldsql_col("num as 'key'");
            bldsql_col("abbr as 'value'");
            bldsql_col("concat('(',abbr,') ',name) as 'label'");
            bldsql_orderby("abbr");
            break;
        case "d_parameter_num":
            bldsql_from("gmd.parameter");
            bldsql_col("num as 'key'");
            bldsql_col("formula as 'value'");
            bldsql_col("formula as 'label'");
            #bldsql_col("concat('(',formula,') ',name, unit_name) as 'label'");
            bldsql_orderby("formula");
            break;
        case "d_inst":
            bldsql_from("ccgg.inst");
            bldsql_col("id as 'key'");
            bldsql_col("inst as 'value'");
            bldsql_col("inst as 'label'");
            bldsql_orderby("inst");
            break;
        */
    }
    
    $a=doquery();
    #var_dump($a);
    $data="";
    foreach($a as $row){
        $label=str_replace('"','',$row['label']);#Filter out any quotes if present as that'll mess up the js syntax.
        $cat=(isset($row['category']))?", category:\"".$row['category']."\"":"";#attempt to add categories to list.. didn't quite get it to work yet though.
        $data=appendToList($data,"{ label: \"$label\", value:\"".$row['value']."\", key:\"".$row['key']."\"${cat}}");
        
    }
    
    $data="var ".$id."_data = [".$data."];";
    return "$data\n";
}
function getDateRangeHTML($type,$label,$defaultDate=false){
    #Type is ev or d
    #if default, we'll set a date in the start field and today as the end date.  Note we set an end date
    #because it's required by the logic that adds new data to tags as it gets inserted into the db (function updateOpenEndedRangeCriteria)
    $sdate="";$js="";
    if($defaultDate){#default to beginning of year.  Do as a function so can be called from elsewhere.
        #jwm 4/17, this isn't factored very well...  why is the function defined here?  It doesn't appear to be called from elsewhere anymore either. (actually, now the end date one is (reset btn))
        $sdate=date("Y");
        $edate=gmdate("Y-m-d");#UTC current date.  pfp/flask dates are all utc.  We leave off time (default is 23:59 on end dates) because that would be confusing.  This is really just to catch the oddball case of someone searching in the evening (from - utc zones) and missing events because the utc date has already rolled.

        $js="<script language='JavaScript'>
                function setEvStartDateDefault(){
                    var defaultDate='$sdate';
                    $('#ev_sDate').val(defaultDate);
                    validateDate('ev_sDate',true,-1);
                }
                if($('#ev_sDate').val()=='')setEvStartDateDefault();
                
                function setEvEndDateDefault(){
                    var d='$edate';
                    $('#ev_eDate').val(d);
                    validateDate('ev_eDate',true,-1);                
                }
                if($('#ev_eDate').val()=='')setEvEndDateDefault();
            </script>";
    }
    $size=20;
    $help=helpLink("Date Fields");
    $html="
        <tr>
            <td colspan='2'>
                <div>$label:$help</div>
                <table>
                    <tr>
                        <td align='right'><label class='tiny_data' for='${type}_sDate_display'>from</label></td>
                        <td>
                            <input value='' class='search_field ".$type."_field' type='text' id='${type}_sDate'  name='${type}_sDate' size='$size' onchange=\"return  validateDate('${type}_sDate',true,-1);\">
                        
                        </td>
                    </tr>
                    <tr>
                        <td align='right'><label class='tiny_data' for='${type}_eDate_display'>to</label></td>
                        <td>
                            <input class='search_field ".$type."_field' type='text' id='${type}_eDate' name='${type}_eDate' size='$size' onchange=\"return  validateDate('${type}_eDate',true,1);\">
                            $js
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    ";
    return $html;
}

function getTimeRangeHTML($fromID,$toID,$notID,$label,$type){
    $class="search_field ".$type."_field";
    $html="
        <tr>
            <td colspan='2'>
                <div>$label:<span class='sm_ital'>(gmt)</span></div>
                <table>
                    <tr>
                        <td align='right'><label class='tiny_data' for='$fromID'>from</label></td>
                        <td>".getTimeInput($fromID,"",$class,8,"setSampleWindowCheckBox()")."</td>
                        <td align='right'><label class='tiny_data' for='$toID'>to</label></td>
                        <td>".getTimeInput($toID,"",$class,8,"setSampleWindowCheckBox()")."</td>
                        <td>".getCheckBoxInput($notID,"<span class='tiny_ital'>Not in window</span>","","",$class)."<script language='JavaScript'>setSampleWindowCheckBox();</script></td>
                    </tr>
                </table>
            </td>
        </tr>
    ";#Note; time validation js function is actually in the local dates.js not dbutils validation.js
    return $html;
}
function getRangeHTML($fromID,$toID,$label,$type,$size='5',$postText=''){
    #This is just a convienence to make it easier to tweek layout on all of them at once.
    #Type is 'ev' or 'd'
    #If size=5, put all on 1 line, else 2
    #postText will go after 2nd box.
    if($size>5){
        $html="
        <tr>
            <td colspan='2'>
                <div>$label:</div>
                <table>
                    <tr>
                        <td align='right'><label class='tiny_data' for='$fromID'>from</label></td><td><input class='search_field ".$type."_field' type='text' id='$fromID' name='$fromID' size='$size'></td>
                        <td align='right'><label class='tiny_data' for='$toID'>to</label></td><td><input class='search_field ".$type."_field' type='text' id='$toID' name='$toID' size='$size'> $postText</td>
                    </tr>
                </table>
            </td>
        </tr>
        ";
    }else{
        $html="
        <tr>
            <td colspan='2'>
                <table>
                    <tr>
                        <td>$label:</td>
                        <td align='right'><label class='tiny_data' for='$fromID'>from</label></td><td><input class='search_field ".$type."_field' type='text' id='$fromID' name='$fromID' size='$size'></td>
                        <td align='right'><label class='tiny_data' for='$toID'>to</label></td><td><input class='search_field ".$type."_field' type='text' id='$toID' name='$toID' size='$size'> $postText</td>
                    </tr>
                </table>
            </td>
        </tr>
        ";
    }
    return $html;
}
function getTextInput($label,$value,$id,$name="",$size=-1,$ro=false){
    #Another convience method like above
    #Note; id and name are usually the same. If in a submitted form, only inputs with a name will be included though.
    $name=($name)?"name='$name'":"";
    $size=($size<0)?"20":$size;#default size to 20
    $ro=($ro)?"readonly":"";
    $html="<td class='label'>$label</td><td class='data'><input type='text' id='$id' $name $ro size='$size' value='$value'></input></td>";
    return $html;
}


#Class to create rainbow of colors.
class color
{
    public $sequence = array();

    /**
     * constructor fills $sequence with a list of colours as long as the $count param
     */
    public function __construct($count, $s = .5, $l = .5)
    {
        for($h = 0; $h <= .85; $h += .85/$count)    //.85 is pretty much in the middle of the violet spectrum
        {
            $this->sequence[] = color::hexHSLtoRGB($h, $s, $l);
        }
    }

    /**
     * from http://stackoverflow.com/questions/3597417/php-hsv-to-rgb-formula-comprehension#3642787
     */
    public static function HSLtoRGB($h, $s, $l)
    {

        $r = $l;
        $g = $l;
        $b = $l;
        $v = ($l <= 0.5) ? ($l * (1.0 + $s)) : (l + $s - l * $s);
        if ($v > 0){
              $m;
              $sv;
              $sextant;
              $fract;
              $vsf;
              $mid1;
              $mid2;

              $m = $l + $l - $v;
              $sv = ($v - $m ) / $v;
              $h *= 6.0;
              $sextant = floor($h);
              $fract = $h - $sextant;
              $vsf = $v * $sv * $fract;
              $mid1 = $m + $vsf;
              $mid2 = $v - $vsf;

              switch ($sextant)
              {
                    case 0:
                          $r = $v;
                          $g = $mid1;
                          $b = $m;
                          break;
                    case 1:
                          $r = $mid2;
                          $g = $v;
                          $b = $m;
                          break;
                    case 2:
                          $r = $m;
                          $g = $v;
                          $b = $mid1;
                          break;
                    case 3:
                          $r = $m;
                          $g = $mid2;
                          $b = $v;
                          break;
                    case 4:
                          $r = $mid1;
                          $g = $m;
                          $b = $v;
                          break;
                    case 5:
                          $r = $v;
                          $g = $m;
                          $b = $mid2;
                          break;
              }
        }
        return array('r' => floor($r * 255.0),
                    'g' => floor($g * 255.0), 
                    'b' => floor($b * 255.0)
                    );
    }

    //return a hex code from hsv values
    public static function hexHSLtoRGB($h, $s, $l)
    {
        $rgb = self::HSLtoRGB($h, $s, $l);
        $hex = base_convert($rgb['r'], 10, 16) . base_convert($rgb['g'], 10, 16) . base_convert($rgb['b'], 10, 16);
        return $hex;
    }
}
?>
