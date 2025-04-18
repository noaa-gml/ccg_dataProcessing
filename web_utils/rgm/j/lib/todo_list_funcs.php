<?php
require_once "/var/www/html/inc/validator.php";

function getCalServiceList($cs_num,$showExtraCols,$org="",$showAdditionalCalrequests=false,$sort_mode=1){
    #Return the todo list for passed cal service num.
    $html="";
    if($cs_num){
        
        #The query logic is encapsulated in a stored procedure so that it can be shared with the calibration system python code.
        $display_mode=($showExtraCols)?2:1;#See sp comments for details.
        if($showAdditionalCalrequests)$display_mode+=100; #101,102,103 include add'l species when appropriate.

        $sql="call rgm_buildTodoList2(?,?,?)";
        $a=doquery($sql,-1,array($cs_num,$display_mode,$sort_mode));
        #var_dump($a);
        #Mark some col names so we can pick them out below.  Name changes must be synced here & in sp!
        #Note; we could use column number but as long as the header labels are synced it doesn't really offer much advantage
        #as the order could change as easily as the label.
        $cylLabel='Cylinder';
        $sortLabel='Sort';
        $fillLabel='Fill';
        $commentLabel='Comments';
        
        
        $rowStyle="";$mouseOver="";
        $leftHiddenCols=7;
        
        $class="tl_table";
        $tableClass="class='$class sortable'";
        $rowStyle=" style='cursor: pointer;' ";
        
        if($a){
            $html.="<table $tableClass id='calServiceListTable' $rowStyle><thead><tr id='tableheadrow'>";
            $i=1;
            $sortCounter=1;
            foreach($a as $row){
                #return(join(",",$row));
                if($i==1){#Include a header row
                    #Translate the col headers into nice text
                    $j=1;
                    #Add the selection col
                    $html.="<th></th>";
                    
                    foreach($row as $key=>$val){
                        $image=($key==$sortLabel || $key==$commentLabel)?"&nbsp;&nbsp;<img style='border:1px solid blue;' src='j/images/write.jpeg' width='12' height='12'/>":"";
                        
                        if($j>$leftHiddenCols){#Skip any that should be hidden.
                            $html.="<th><a href='#' class='sortheader' onclick=\"ts_resortTable(this,$sortCounter,getElementById('calServiceListTable'));return false;\">$key<span class='sortarrow'></span></a>$image</th>";
                            $sortCounter++;
                        }
                        $j++;
                    }
                    $html.="</tr></thead><tbody>";
                }
                $i++;
                
                
                #Super lame way to filter output.. but had to put query in sp above so it could be easily shared and now it's hard
                #to add filter to it because you can't have optional params in a sp !@!
                #If there's any more customizing needed, I think I'll add a 2nd sp with new params and have first call it.
                if($org){
                    if($row['org_name']!=$org){continue;}
                }
                
                $request_num=$row['request_num'];#Pull out for use below.
                
                #highlight rows when requested
                $rowClass=($row['highlight_comments'])?"class='highlight_comment_row'":"";
                
                #Since we've started included other cals in the list (ch4 on co2 list), we need to differentiate between those
                #we can do final cals on and not.  If can, then build unique id for this row with all data needed to load cals.
                $id=($row['calservice_num']!=$cs_num)?"donotload~$request_num":$request_num."~".$row['cs_abbr']."~".$row[$cylLabel]."~".$row[$fillLabel];
                $html.="<tr id='$id' $rowClass>";#We assign the whole row the id which allows us to attach event to row click
                
                #Add a select column
                #Note the copytext label is "cyl,avg_targ,press,fill,reg,numcals"  this is set in todo_list.js
                $html.="<td class='tl_selection' style='background-color:white;'><input type='checkbox' id='selection_${request_num}' value='".$row['copy_text']."' class='tl_selectBox'></td>";
                
                $j=1;
                    
                foreach($row as $key=>$val){
                    #Sort col
                    if($j>$leftHiddenCols){#Skip any that should be hidden and handle the de fields separately.
                        if($key==$sortLabel){
                            $id="sort_${request_num}";
                            $html.="<td id='${id}_sorttd' class='tl_sortde editableTD'><div id='${id}_div'>".getSortTDContents($val,$id,$request_num)."</div></td>";
                        }elseif($key==$commentLabel){
                            $id="comment_${request_num}";
                            $html.="<td id='${id}_comtd' class='tl_commentde editableTD'><div id='${id}_div'>".getCommentTDContents($val,$id,$request_num)."</div></td>";
                        
                        }else{
                            $val=str_replace("|","<br>",$val);#change any | to new lines for better formatting.
                            $html.="<td id='${j}_${request_num}' class='$key'>$val</td>";
                        }
                    }
                    
                    $j++;
                }
                $html.="</tr>";
                
            }
            $html.="</tbody></table>
            <script language='JavaScript'>//First three are the special editable tds
            //We'll detect when they are clicked and then toggle the de/display widgets
                $( \"#calServiceListTable tbody\" ).on( \"click\", \".tl_sortde\", function(event) {
                        var a=this.id.split('_');//sort_[idnum]_sorttd.  parse out the id portion
                        var req=a[0]+'_'+a[1];//rebuild the id prefix
                        $(\"#\"+req+\"_display\").toggle();
                        $(\"#\"+req+\"_inputDiv\").toggle();
                        if($(\"#\"+req).is(':visible')){//highlight current entry and set focus.
                            $(\"#\"+req).select();
                        }
                        event.stopPropagation();                    
                });
                $( \"#calServiceListTable tbody\" ).on( \"click\", \".tl_commentde\", function(event) {
                        var a=this.id.split('_');//comment_[idnum]_comtd.  parse out the id portion
                        var req=a[0]+'_'+a[1];//rebuild the id prefix
                        $(\"#\"+req+\"_display\").toggle();
                        $(\"#\"+req+\"_inputDiv\").toggle();
                        if($(\"#\"+req).is(':visible')){//Set cursor to end of current text
                            var data=$(\"#\"+req).val();
                            //data=(data)?data+' ~~ ':'';//Add a delim if needed.
                            $(\"#\"+req).focus().val('').val(data);                            
                        }
                        event.stopPropagation();                    
                });
                //selection check box.
                $( \"#calServiceListTable tbody\" ).on( \"click\", \".tl_selection\", function(event) {
                        tl_checkboxSelected();
                        event.stopPropagation();                    
                });
                
                //row selection, load the calibrations for selected row.
                $( \"#calServiceListTable tbody\" ).on( \"click\", \"tr\", function(event) {
                    //Unselect any previous selection.
                    $(\".selectedRow\").removeClass(\"selectedRow\");
                    
                    //Select current row
                    $(this).addClass(\"selectedRow\");
                    
                    //Load the calibrations for this row if applicable.
                    
                    $('#detailDiv').empty();
                    var id=$(this).attr('id');//Row id: reqnum~gas~cyl~fillcode
                    var a=id.split('~');
                    var destDiv='detailDiv';
                    if(a[0]=='donotload'){
                        $('#detailDiv').html(\"Select the applicable species in the Cal Serivce drop down above to view the Todo List/calibrations for this request\");
                    }else{
                        var params='tl_request_num='+a[0]+'&tl_cs_abbr='+a[1]+'&tl_cyl='+a[2]+'&tl_fill_code='+a[3];
                        ajax_get('tl_loadCalibrations',params,destDiv,tl_ajax_req);
                    }
                    console.log(params);
                    
                });
                //Set up the floating header row...
                $(function(){
                    var tble = $(\"#calServiceListTable\");
                    tble.floatThead({
                        position: \"fixed\",
                        scrollContainer: true
                    });        
                });  
            </script>
            ";
            
        }else{
            #No results found
            $html.="No items found to process.";
            
        }
    }
    $html.=setTitleJS("'RGM ToDo'");    
    return $html;
}
function getSortTDContents($val,$id,$request_num,$error="",$message=""){
    #Returns contents of sort col td for enterability.  This should be inside a div. broken out so can be called by list gen and submit
    #onblur='$(\"#${id}_sorttd\").click();'
    $html=" <div class='tl_sort_num_class' id='${id}_display'>$val</div>
            <div id='${id}_inputDiv' style='display:none;'>
                <input  size='2' style='width:2em' type='text' id='${id}' value='$val'  onchange='tl_setsortnum($request_num);'>
            </div>
            <div id='${id}_message'></div>";
    if($error)$html.="<script language='JavaScript'>setStatusMessage(\"$error\",2,'${id}_message');</script>";
    if($message)$html.="<script language='JavaScript'>setStatusMessage(\"$message\",2);</script>";
    return $html;
}
function getCommentTDContents($val,$id,$request_num,$error="",$message=""){
    #Returns contents of sort col td for enterability.  This should be inside a div. broken out so can be called by list gen and submit
    $val=htmlentities($val);
    $html="<div id='${id}_display' >$val</div>
         <div id='${id}_inputDiv' style='display:none;'>
            <textarea  cols='20' rows='4' id='${id}'  onchange='tl_setcomment($request_num);'>$val</textarea>
        </div><div id='${id}_message'></div>";
    if($error)$html.="<script language='JavaScript'>setStatusMessage(\"$error\",2,'${id}_message');</script>";
    if($message)$html.="<script language='JavaScript'>setStatusMessage(\"$message\",2);</script>";
    return $html;
}
function setLoggingUser(){
    #Loads the user from session and sets into dbutils for dml logging.
    $cwd=getcwd();
    chdir("..");#All the scripts expect us in the parent directory.
    require_once "DB_UserManager.php";
    session_start();
    $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
    db_setAuthUser($user_obj->getUsername());#Set the username for dml.log
    session_write_close();
    chdir($cwd);#..reset
}
function tl_editSortNum($reqNum){
    $html="";
    if($reqNum){
        $id="sort_${reqNum}";
        #See if passed sort_num is blank (legal) or a number
        $sortVal=getHTTPVar("tl_sortNum");
        if($sortVal!='')$sortVal=getHTTPVar("tl_sortNum",0,VAL_INT,array(),0);
        $message="";$error="";
        if($sortVal>0 || $sortVal===''){
            #Load user info from session for logging.
            setLoggingUser();
        
            bldsql_init();
            bldsql_update("calrequest");
            bldsql_where("num=?",$reqNum);
            if(!$sortVal)$sortVal=null;
            bldsql_set("sort_order=?",$sortVal);
            
            if(doupdate()!==false){
                $message="Saved";
            }else{
                $error="Error saving entry.";
            }
            
        }elseif($sortVal===0){#Invalid sort value (not a number)
            $error="Sort value must be a positive number";
        }
        #Fetch stored (maybe updated) value from table and send text back.    
        bldsql_init();
        bldsql_from("calrequest");
        bldsql_col("sort_order");
        bldsql_where("num=?",$reqNum);
        $val=doquery("",0);
        
        $html=getSortTDContents($val,$id,$reqNum,$error,$message);
        
    }else $html="Error; no request num!";
    return $html;
}
function tl_editComment($reqNum,$comment){
    $html="";
    if($reqNum){
        $id="comment_${reqNum}";
        $message="";$error="";
        
        #Load user info from session for logging.
        setLoggingUser();
        
        bldsql_init();
        bldsql_update("calrequest");
        bldsql_where("num=?",$reqNum);
        if(!$comment)$comment=null;
        bldsql_set("comments=?",$comment);
        
        if(doupdate()!==false){
            $message="Saved";
        }else{
            $error="Error saving entry.";
        }
        
        #Fetch stored (maybe updated) value from table and send text back.    
        bldsql_init();
        bldsql_from("calrequest");
        bldsql_col("comments");
        bldsql_where("num=?",$reqNum);
        $val=doquery("",0);
        
        $html=getCommentTDContents($val,$id,$reqNum,$error,$message);
        
    }else $html="Error; no request num!";
    return $html;
}
function tl_getCalibrationResults($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code,$limitToOfficial=false){
    #Return the calibration results in an array.
    #Note tl_request_num isn't actually used anymore...
    $o=($limitToOfficial)?"-o":"";
    $cmd = "/ccg/bin/reftank $o --legacy -g".$tl_cs_abbr." -c".$tl_fill_code." ".$tl_cyl;
#    var_dump($cmd);
    $res = array();
    exec($cmd, $res);
    if ( preg_grep('/No filling information/', $res) && $tl_fill_code=='A'){ #Try again without fill code listed
        $cmd = "/ccg/bin/reftank $o --legacy -g".$tl_cs_abbr." ".$tl_cyl;
        $res = array();
        exec($cmd, $res);
    }
    return $res;
}
function tl_plotCalibrations($calibrationResults,$cylID,$fill){
    #Returns a button to show plot of all calibrations for species/fill code in a poppup window.. $calibrationResults is what's returned by tl_getCalibrationResults
    $vals=array();
    $dates=array();
    $insts=array();
    $html="";
    foreach($calibrationResults as $i=>$row){
        $fields = preg_split('/\s+/', trim($row));
        if ( preg_match('/^[A-Z]|(None)$/', $fields[0]) && ValidDate($fields[1]) ){//Calibration row
            if ( ValidFloat($fields[6]) && $fields[8]=='.'){                
                $vals[]=$fields[6];
                $dates[]=$fields[1];#." 11:59:00";
                $insts[]=$fields[4];
            }
        }
    }
    #$html.="vals:".var_export($vals)."<br>$dates:".var_export($dates)."<br>$insts:".var_export($insts)."<br>";
    array_multisort($insts,$dates,$vals);
    #$html.="vals:".var_export($vals)."<br>$dates:".var_export($dates)."<br>$insts:".var_export($insts)."<br>";
    $a=array();
    foreach($insts as $key=>$inst){
        $a[]=array('series'=>$inst,'x'=>$dates[$key],'y'=>$vals[$key]);
    }
    if($a){
        $id=uniqid();
        $options="  grid:{hoverable:true},
                    series: { lines: { show: false }, points: { show: true }},
                    xaxis:{autoscaleMargin:0.05,mode:\"time\",timeformat:\"%m/%y\"},
                    legend: {
                        labelFormatter: function(label, series){
                          return '<a href=\"#\" onClick=\"togglePlot_${id}(\''+label+'\'); return false;\">'+label+'</a>';
                        }
                    }
                    ";
        $html.=printGraph($a,'',"plot_${id}",'','default',array(),$options,false,false,"$cylID (Fill $fill))");
        
        $html="<div id='$id' style='width:600px;height:400px;'>
            <div style='height:90%;width:100%;'>$html</div>
        </div><button id='${id}_btn'>Plot Cals</button>
        <script language='JavaScript'>
            var dialog=$(\"#$id\").dialog({
                title: \"$cylID - (Fill $fill)\",
                autoOpen:false,
                height: 450,
                width: 650,
                modal:true
            });
            $(\"#${id}_btn\").click(function(event){
                event.preventDefault();
                dialog.dialog(\"open\");
            });
            togglePlot_${id} = function(label)
            {console.log(label);
              var seriesIdx=-1;
              var someData = plot_${id}.getData();
              for(var i = 0, len=someData.length;i<len;i++){
                console.log(someData[i]);
                if(someData[i].label==label){seriesIdx=i;}
              }
              someData[seriesIdx].points.show = !someData[seriesIdx].points.show;
              plot_${id}.setData(someData);
              plot_${id}.draw();
            }
        </script>
        ";
    }
    return $html;
    
}

function tl_loadCalibrations2($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code){
    #New version that retrieves data from db as well as Kirk's script so that it can
    #meld extra data into the list.  
    #Initially only used on co2
    
    $isCO2=(strtoupper($tl_cs_abbr)=='CO2');
    $status=doquery("select calrequest_status_num from calrequest where num=$tl_request_num",0);
    if($status==2){#2 is processing.  Once a row is submitted, it'll change to 3, proc complete.
        $a=array();
        bldsql_init();
        bldsql_from("reftank.fill f");
        bldsql_where("f.serial_number=?",$tl_cyl);
        bldsql_where("f.code=?",$tl_fill_code);
        bldsql_col("min(f.date)");
        $minDate=doquery("",0);
        if($minDate){
            bldsql_init();
            bldsql_from("reftank.fill f");
            bldsql_where("f.serial_number=?",$tl_cyl);
            bldsql_where("f.code!=?",$tl_fill_code);
            bldsql_where("f.date>?",$minDate);
            bldsql_col("ifnull(min(f.date),date_add(curdate(), interval 1 day))");
            $maxDate=doquery("",0);
            bldsql_init();
            bldsql_where("c.date>=?",$minDate);
            bldsql_where("c.date<?",$maxDate);
            bldsql_where("c.serial_number=?",$tl_cyl);
            bldsql_where("upper(c.species)=upper(?)",$tl_cs_abbr);
            #Note that names are significant (used below).
            bldsql_col("'$tl_fill_code' as 'Fill'");
            bldsql_col("c.date as 'Date'");
            bldsql_col("c.location as 'Loc'");
            bldsql_col("c.species as 'Gas'");
            bldsql_col("c.inst as 'Inst'");
            bldsql_col("c.pressure as 'Press'");
            bldsql_col("c.mixratio as 'Value'");
            bldsql_col("c.stddev as 'S.D.'");
            bldsql_col("c.flag as 'Flag'");
            
            if($isCO2){#Include isotopes from same date/time.
                #Note we could filter on inst, but we won't so that they can change out machines in the future.
                #Hopefully date/time/species is enough to uniquely id a measurement and related isotopes.. logically if they have the
                #same timestamp, they should be all related to eachother.
                #Note that ch4 measurements may be present too with same stamp.
                ##and c.inst='PC1' and c13.inst='LGR6'
                $t="reftank.calibrations c left join reftank.calibrations c13 on
                        c.date=c13.date
                        and c.time=c13.time
                        and c.serial_number=c13.serial_number
                        and upper(c13.species)='CO2C13'
                        and c13.flag like '.'
                    left join reftank.calibrations o18 on
                        c.date=o18.date
                        and c.time=o18.time
                        and c.serial_number=o18.serial_number
                        and upper(o18.species)='CO2O18'
                        and o18.flag like '.'";
                bldsql_from($t);
                bldsql_col("c13.mixratio as 'c13_value'");
                bldsql_col("c13.inst as 'c13_inst'");
		bldsql_col("c13.stddev as 'c13stdv'");
                bldsql_col("o18.mixratio as 'o18_value'");
                bldsql_col("o18.inst as 'o18_inst'");
		bldsql_col("o18.stddev as 'o18stdv'");
                
            }else{
                bldsql_from("reftank.calibrations c");
            }
            $a=doquery();        
        }
    
        #Now get results from the 'official' source (Kirk's script).
        #We do this to make sure that our results match whatever logic is being used there.
        #We'll call twice, once for all, so we can show all results, and once for official so we know which ones to
        #put a check box on.
        $html="";
        
        $res=tl_getCalibrationResults($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
        $officalInst=tl_getCalibrationResults($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code,true);#results from official insts only.
        $plot=tl_plotCalibrations($res,$tl_cyl,$tl_fill_code);
        $html.="<form id='calibrationAnalForm'>
                <input type='hidden' id='tl_calibration_requestNum' name='tl_calibration_requestNum' value='$tl_request_num'>
                <input type='hidden' id='tl_cs_abbr' name='tl_cs_abbr' value='$tl_cs_abbr'>
                <input type='hidden' id='tl_cyl' name='tl_cyl' value='$tl_cyl'>
                <input type='hidden' id='tl_fill_code' name='tl_fill_code' value='$tl_fill_code'>
                <textarea style='display:none;' id='tl_calibration_selectedRowText' name='tl_calibration_selectedRowText' value=''></textarea>
        <table border='0' style='width:100%;height:250px;'>
            <tr><td style='height:200px;'>
                <div class='tl_calibrationsDiv'>";
        $i=0;
        $cals="";#build up table of cals, if present.
        $nonCals="";$co2HeaderCols="";
        foreach($res as $i=>$row){
            $fields = preg_split('/\s+/', trim($row));
            if ( preg_match('/^[A-Z]|(None)$/', $fields[0]) && ValidDate($fields[1]) ){//Calibration row
                $value=$fields[6];
                #Find the matching row from db
                $outRow="Something unexpected happened, error matching this row to db query.  Please contact John Mund so he can fix it.<br>";
                $savedRowText="";
                $matched=false;$k=-1;
                foreach($a as $k=>$db_row){#Match all fields but fill, which i left out because it's sometimes a little wonky on the first fill.  Shouldn't be needed anyway as we filter by date.
                    if(strtotime($db_row['Date'])==strtotime($fields[1]) && $db_row['Loc']==$fields[2]
                            && $db_row['Gas']==$fields[3] && $db_row['Inst']==$fields[4] && $db_row['Press']==$fields[5]
                            && $db_row['Value']==$value && $db_row['S.D.']==$fields[7] && $db_row['Flag']==$fields[8]){
                        $outRow="<td>".$db_row['Fill']."</td><td>".$db_row['Date']."</td><td>".$db_row['Loc']."</td><td>".$db_row['Gas']."</td><td>".
                            $db_row['Inst']."</td><td>".$db_row['Press']."</td><td>".$db_row['Value']."</td><td>".$db_row['S.D.'].
                            "</td><td>".$db_row['Flag']."</td>";
                            
                        if($isCO2){
                            $outRow.="<td>".$db_row['c13_value']."</td><td>".$db_row['c13stdv']."</td><td>".$db_row['o18_value']."</td><td>".$db_row['o18stdv']."</td>";
                            $co2HeaderCols="<th>co2c13</th><th>c13stdv</th><th>co2o18</th><th>o18stdv</th>";
                            $value.="~".$db_row['c13_value']."~".$db_row['o18_value'];
                        }
                        $matched=true;
                        break;
                    }
                }
                if($matched)unset($a[$k]);#remove from available.  This is to handle if there are multiple matches (unlikely except for  maybe in testing) so that each (with possibly different isotopes) are represented in the output.
                if ($matched && ValidFloat($fields[6]) && $fields[8]=='.' && in_array($row,$officalInst)){#Only 'official' results get a selectable checkbox.
                    #note that the '$value' var may have isotope data appended on now, so have to match against source in above float check and use $value below
                   $outRow="<td style='border:none'><input id='tl_calibration_checkbox_${i}' name='tl_calibration_checkbox_${i}' type='checkbox' class='tl_calibration_checkbox' value='$value' data='$row'></input></td>".$outRow;
                   #$outRow="<label class='tl_calDataLabel' for='tl_calibration_checkbox_${i}'>$outRow</label>";#Make the text clickable
                }else $outRow="<td></td>".$outRow;#Checkbox disabled was confusing looking"<input type='checkbox' disabled></input>";#No value, don't let it be selectable.
                $outRow="<tr>$outRow</tr>";
                $cals.=$outRow;
            }else{$nonCals.="<tr><td>$row</td></tr>";}#build up a list of whatever output was returned.
            
        }

        $extraInputs="";
        if($cals)$html.="<div class='title3'>".strtoupper($tl_cs_abbr)." calibration summary for tank # $tl_cyl</div><br>
                        <table class='tl_calTable2'>
                            <tr><th></th><th>Fill</th><th>Date</th><th>Loc</th><th>Gas</th><th>Inst</th><th>Press</th><th>Value</th><th>S.D.</th><th>Flag</th>$co2HeaderCols</tr>
                            $cals
                        </table>";

        else $html.="<table>$nonCals</table>";
        $inputs="
                <table>
                    <tr><td></td><td><div class='tl_error' id='tl_calibrations_mssg_div'></div></td></tr>
                    <tr>
                        <td align='right'>Value</td><td><input type='textbox' size='10' id='tl_calibration_value' name='tl_calibration_value' class='tl_calibration_vr_entry'></input></td>
                    </tr>
                    <tr>
                        <td align='right'>Repeatability</td><td><input type='textbox' size='10' class='tl_calibration_vr_entry' id='tl_calibration_repeatability' name='tl_calibration_repeatability'></input></td>
                    </tr>
                    <tr>
                        <td colspan='2'><input type='checkbox' id='tl_calibration_analComplete' name='tl_calibration_analComplete' value='1'></input><label for='tl_calibration_analComplete'>Analysis Complete</label></td>
                    </tr>
                </table>";
        if($isCO2){#Add isotopes for co2
            #Note the inputs are generically named (2/3) so that we can added isotopes or 2ndary values for other gases if needed.  The js logic will just fill if there without caring what it is.
            $inputs="
                <table>
                    <tr><td></td><td><div class='tl_error' id='tl_calibrations_mssg_div'></div></td></tr>
                    <tr>
                        <td align='right'>co2 Value</td><td><input type='textbox' size='10' id='tl_calibration_value' name='tl_calibration_value' class='tl_calibration_vr_entry'></input></td>
                    </tr>
                    <tr>
                        <td align='right'>co2 Repeatability</td><td><input type='textbox' size='10' class='tl_calibration_vr_entry' id='tl_calibration_repeatability' name='tl_calibration_repeatability'></input></td>
                    </tr>
                    <tr><td colspan='2'><br></td></tr>
                    <tr>
                        <td align='right'>co2c13</td><td><input type='textbox' size='10' id='tl_calibration_value_2' name='tl_calibration_value_2' class='tl_calibration_vr_entry'></input></td>
                    </tr>
                    <tr>
                        <td align='right'>co2o18</td><td><input type='textbox' size='10' id='tl_calibration_value_3' name='tl_calibration_value_3' class='tl_calibration_vr_entry'></input></td>
                    </tr>
                    <tr>
                        <td colspan='2'><input type='checkbox' id='tl_calibration_analComplete' name='tl_calibration_analComplete' value='1'></input><label for='tl_calibration_analComplete'>Analysis Complete</label></td>
                    </tr>
                </table>";
        }
        $html.="
                </div>
            </td>
            <td>
                $inputs
            </td>
            </tr>
            <tr><td valign='bottom'>
                <div >
                    <button id='tl_calibration_selectAll'>Select All</button><button id='tl_calibration_selectNone'>Select None</button>$plot
                    <span class='tinyital' style='float:right;'>These selections are for reporting only, they do not change flags in reftank.</span>                
                </div>
            </td>
            <td valign='bottom'><button disabled style='float:right;' id='tl_calibration_submit'>Submit</button></td>
            </tr>
        </table></form>
        <script language='JavaScript'>
            //click handlers
            $(\"#tl_calibration_selectAll\").click(function(event){
                event.preventDefault();
                $(\".tl_calibration_checkbox\").prop(\"checked\",true);
                tl_calibration_updateSelected();
            });
            $(\"#tl_calibration_selectNone\").click(function(event){
                event.preventDefault();
                $(\".tl_calibration_checkbox\").prop(\"checked\",false);
                tl_calibration_updateSelected();
            });
            $(\".tl_calibration_checkbox\").change(function(){
                tl_calibration_updateSelected();
            });
            $(\".tl_calibration_vr_entry\").change(function(){
                tl_calibration_validate_vr_entry($(this).attr('id')); 
            });
            $(\"#tl_calibration_analComplete\").change(function(){//Make them select the complete box before submitting
                $(\"#tl_calibration_submit\").prop(\"disabled\",!(this.checked));
            });
            $(\"#tl_calibration_submit\").click(function(event){
                event.preventDefault();
                tl_calibration_submitAnalysis();
            });
        </script>
        ";
    
    
    }else{
        #Print a summary of cal request (likely 3, complete);
        $mssg=($status==3)?"Processing complete":"";
        $html=tl_getSubmittedCals($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code,$mssg);
    }
    return $html;    
}
function tl_loadCalibrations($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code){
    
    #Loads the calibrations and form to select final cals.  We're transitioning to new..2 above
    if(strtolower($tl_cs_abbr)=='co2')return tl_loadCalibrations2($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
    
    $status=doquery("select calrequest_status_num from calrequest where num=$tl_request_num",0);
    if($status==2){#2 is processing.  Once a row is submitted, it'll change to 3, proc complete.
        $html="";
        #the 'official' list of instruments is stored in the reftank bin logic.  We'll call twice,
        #once for all, so we can show all results, and once for official so we know which ones to
        #put a check box on.
        $res=tl_getCalibrationResults($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
        $officalInst=tl_getCalibrationResults($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code,true);#results from official insts only.
        $plot=tl_plotCalibrations($res,$tl_cyl,$tl_fill_code);
        $html.="<form id='calibrationAnalForm'>
                <input type='hidden' id='tl_calibration_requestNum' name='tl_calibration_requestNum' value='$tl_request_num'>
                <input type='hidden' id='tl_cs_abbr' name='tl_cs_abbr' value='$tl_cs_abbr'>
                <input type='hidden' id='tl_cyl' name='tl_cyl' value='$tl_cyl'>
                <input type='hidden' id='tl_fill_code' name='tl_fill_code' value='$tl_fill_code'>
                <textarea style='display:none;' id='tl_calibration_selectedRowText' name='tl_calibration_selectedRowText' value=''></textarea>
        <table border='0' style='width:100%;height:250px;'>
            <tr><td style='height:200px;'>
                <div class='tl_calibrationsDiv'>
                <table class='tl_calTable'>";
        $i=0;
#var_dump($officalInst);var_dump($res);
        foreach($res as $i=>$row){
            $html.="<tr><td>";
            $fields = preg_split('/\s+/', trim($row));
#    var_dump($fields);
            if ( preg_match('/^[A-Z]|(None)$/', $fields[0]) && ValidDate($fields[1]) ){//Calibration row
                if ( ValidFloat($fields[6]) && $fields[8]=='.' && in_array($row,$officalInst)){#Only 'official' results get a selectable checkbox.
                   $html.="<input id='tl_calibration_checkbox_${i}' name='tl_calibration_checkbox_${i}' type='checkbox' class='tl_calibration_checkbox' value='$fields[6]' data='$row'></input>";
                   $row="<label class='tl_calDataLabel' for='tl_calibration_checkbox_${i}'>$row</label>";#Make the text clickable
                }else $html.="";#Checkbox disabled was confusing looking"<input type='checkbox' disabled></input>";#No value, don't let it be selectable.
            }
            $html.="</td><td>$row</td></tr>";
            
        }
        $html.="</table>
                </div>
            </td>
            <td>
                <table>
                    <tr><td></td><td><div class='tl_error' id='tl_calibrations_mssg_div'></div></td></tr>
                    <tr>
                        <td>Value</td><td><input type='textbox' size='10' id='tl_calibration_value' name='tl_calibration_value' class='tl_calibration_vr_entry'></input></td>
                    </tr>
                    <tr>
                        <td>Repeatability</td><td><input type='textbox' size='10' class='tl_calibration_vr_entry' id='tl_calibration_repeatability' name='tl_calibration_repeatability'></input></td>
                    </tr>
                    <tr>
                        <td colspan='2'><input type='checkbox' id='tl_calibration_analComplete' name='tl_calibration_analComplete' value='1'></input><label for='tl_calibration_analComplete'>Analysis Complete</label></td>
                    </tr>
                </table>
            </td>
            </tr>
            <tr><td valign='bottom'>
                <div >
                    <button id='tl_calibration_selectAll'>Select All</button><button id='tl_calibration_selectNone'>Select None</button>$plot
                    <span class='tinyital' style='float:right;'>These selections are for reporting only, they do not change flags in reftank.</span>                
                </div>
            </td>
            <td valign='bottom'><button disabled style='float:right;' id='tl_calibration_submit'>Submit</button></td>
            </tr>
        </table></form>
        <script language='JavaScript'>
            //click handlers
            $(\"#tl_calibration_selectAll\").click(function(event){
                event.preventDefault();
                $(\".tl_calibration_checkbox\").prop(\"checked\",true);
                tl_calibration_updateSelected();
            });
            $(\"#tl_calibration_selectNone\").click(function(event){
                event.preventDefault();
                $(\".tl_calibration_checkbox\").prop(\"checked\",false);
                tl_calibration_updateSelected();
            });
            $(\".tl_calibration_checkbox\").change(function(){
                tl_calibration_updateSelected();
            });
            $(\".tl_calibration_vr_entry\").change(function(){
                tl_calibration_validate_vr_entry($(this).attr('id')); 
            });
            $(\"#tl_calibration_analComplete\").change(function(){//Make them select the complete box before submitting
                $(\"#tl_calibration_submit\").prop(\"disabled\",!(this.checked));
            });
            $(\"#tl_calibration_submit\").click(function(event){
                event.preventDefault();
                tl_calibration_submitAnalysis();
            });
        </script>
        ";
    }else{
        #Print a summary of cal request (likely 3, complete);
        $mssg=($status==3)?"Processing complete":"";
        $html=tl_getSubmittedCals($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code,$mssg);
    }
    return $html;
}
function tl_calibration_submitAnalysis(){
    /* This function submits a calibration analysis form (from tl_loadCalibrations).*/
    $reqNum=getHTTPVar("tl_calibration_requestNum",0,VAL_INT);
    $selRowsText="   ".getHTTPVar("tl_calibration_selectedRowText");#Prepend the 3space formatting that just got trimmed.
    $value=getHTTPVar("tl_calibration_value");#Note this can be a float or NaN or complete or skipped.
    $value2=getHTTPVar("tl_calibration_value_2");#May not be present.  Currently only programmed for co2 isotopes.
    $value3=getHTTPVar("tl_calibration_value_3");#Ditto
    $repeat=getHTTPVar("tl_calibration_repeatability",'',VAL_FLOAT);
    $complete=getHTTPVar("tl_calibration_analComplete",false,VAL_BOOLCHECKBOX);#sanity check, form should have required to submit.
    $html="";
    $logtext="fn:tl_calibration_submitAnalysis reqnum:$reqNum selRowsText:\n$selRowsText\n value=$value value2=$value2 value3:$value3 repeat=$repeat complete:$complete ";
    
    if($complete && $reqNum){
        #Set the dml logging user incase we do a bldsql update below. We set here because this call and below both mess with cwd to load legacy files.  We want to keep the log user code separate though.
        setLoggingUser();
        
        #Set up the environment from legacy todo list so we can create objects needed to submit this entry.  For now we'll use legacy code
        #although, we may in future want to bypass and insert db directly.
        $cwd=getcwd();
        chdir("..");#All the scripts expect us in the parent directory.
        require_once "CCGDB.php";
        require_once "DB_CalRequestManager.php";
        require_once "DB_CalServiceManager.php";
        require_once "DB_UserManager.php";
        
        $tl_cs_abbr=getHTTPVar("tl_cs_abbr");
        $tl_cyl=getHTTPVar("tl_cyl");
        $tl_fill_code=getHTTPVar("tl_fill_code");
        $logtext.="tl_cs_abbr:$tl_cs_abbr tl_cly:$tl_cyl tl_fill_code:$tl_fill_code ";
        
        #require_once "utils.php";
        #require_once "menu_utils.php";
        session_start();
        
        $database_object = new CCGDB();
        
        $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
        ValidateAuthentication($database_object, $user_obj);
        
        try
         {
            $calrequest_obj = new DB_CalRequest($database_object, $reqNum);

            $calrequest_obj->analysisComplete($user_obj, $value, $repeat,$selRowsText);

            $calrequest_obj->saveToDB($user_obj);
            
            #Submit isotopes for co2 if present.  We should probably add this to the DB_CalRequest logic to be consistent,
            #but for now just doing it here as it's not required data and this is far easier.
            if($value2 || $value3){
                $isco2=doquery("select count(*) from calrequest where num=? and calservice_num=1",0,array($reqNum));
                if($isco2){
                    bldsql_init();
                    bldsql_update("calrequest");
                    if($value2)bldsql_set("co2c13_value=?",$value2);
                    if($value3)bldsql_set("co2o18_value=?",$value3);
                    bldsql_where("num=?",$reqNum);
                    doupdate();
                }
            }
                
            $html.=tl_getSubmittedCals($reqNum,$tl_cs_abbr,$tl_cyl,$tl_fill_code,"Calibrations submitted successfully.");
            
            //$tmpaarr = array();
            //$tmpaarr['calrequest_num'] = $reqNum;
            //$tmpaarr['calrequest_analysis-value'] = $value;
            //$tmpaarr['calrequest_analysis-repeatability'] = $repeat;
            //$tmpaarr['calrequest_analysis-reference-scale'] = $calrequest_obj->getAnalysisReferenceScale();
            //$tmpaarr['calrequest_analysis-submit-datetime'] = $calrequest_obj->getAnalysisSubmitDatetime();
            //if ( $calrequest_obj->getAnalysisCalibrationsSelected() != '' )
            //{ $tmpaarr['calrequest_analysis-calibrations-selected'] = urlencode($calrequest_obj->getAnalysisCalibrationsSelected()); }
            //#print serialize($tmpaarr);
            #jwm-changing logging..
            
            Log::update($user_obj->getUsername(), '(ANALYSIS COMPLETE) '.$logtext);
         }
         catch(Exception $e)
         {
            Log::update($user_obj->getUsername(), $e->__toString());

            $html.="<script language='JavaScript'>alert(\"".$e->getMessage()."\");</script>";
            $html.=tl_loadCalibrations($reqNum,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
         }
         session_write_close();#I'm not sure if some of legacy code needs this, so putting here instead of right after open above.  Should matter much either way as we should be on way out after this.
         chdir($cwd);#reset..
    }else $html='Unexpected parameters';
    return $html;

}

function tl_getSubmittedCals($reqNum,$tl_cs_abbr,$tl_cyl,$tl_fill_code,$mssg=""){
    $html="";
    #Fetch out a summary from saved data
    bldsql_init();
    bldsql_from("rgm_calrequest_view r");
    bldsql_where("r.request_num=?",$reqNum);
    bldsql_col("r.species");
    bldsql_col("r.cylinder_id");
    bldsql_col("r.target_value");
    bldsql_col("r.analysis_value");
    bldsql_col("r.analysis_repeatability ");
    bldsql_col("r.analysis_reference_scale");
    bldsql_col("r.analysis_submit_datetime");
    bldsql_col("r.analysis_submit_user");
    if(strtolower($tl_cs_abbr)=='co2'){
        bldsql_col("r.co2c13_value");
        bldsql_col("r.co2o18_value");
    }
    bldsql_col("r.analysis_calibrations_selected");
    bldsql_col("r.organization");
    bldsql_col("r.MOU_number");
    $a=doquery();
    if($a){
        extract($a[0]);
        $mssg=($mssg)?"<div class='title3'>$mssg</div>":"";               
        $html.="
        <table style='height:100%'>
            <tr><td style='width:95%'>$mssg
            <div class='tl_calibrations_results_div'>
            <table class='tl_calibrations_results_table'>
                <tr><td>Cylinder</td><td style='width:80%'>$cylinder_id</td></tr>
                <tr><td>Species</td><td>$species</td></tr>
                <tr><td>Scale</td><td>$analysis_reference_scale</td></tr>
                <tr><td>Target Value</td><td>$target_value</td></tr>
                <tr><td>Value</td><td>$analysis_value</td></tr>
                <tr><td>Repeatability</td><td>$analysis_repeatability</td></tr>
                <tr><td>Scale</td><td>$analysis_reference_scale</td></tr>
        ";
        if(strtolower($tl_cs_abbr)=='co2'){
            $html.="
                <tr><td>co2c13</td><td>$co2c13_value</td></tr>
                <tr><td>co2o18</td><td>$co2o18_value</td></tr>";
        }
        $html.="
                <tr><td>Submitted</td><td>$analysis_submit_datetime</td></tr>
                <tr><td>By</td><td>$analysis_submit_user</td></tr>
                <tr><td>Organization</td><td>$organization</td></tr>
                <tr><td>MOU</td><td>$MOU_number</td></tr>";
                
                
        #Fetch actual cal results to display inline with selected.
        $res=tl_getCalibrationResults($reqNum,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
        $html.="<tr><td colspan='2'>Calibrations</td></tr>
                <tr>
                    <td colspan='2'>
                        <table class='tl_calTable'>";
        foreach($res as $row){
            $html.="        <tr><td style='border:none;'>$row</td></tr>";                        
        }
        $html.="        </table>
                    </td>
                </tr>
                <tr><td colspan='2'>Calibrations selected:</td></tr>";
        $res=explode("\n",$analysis_calibrations_selected);
        $html.="<tr>
                    <td colspan='2'>
                        <table class='tl_calTable'>";
        foreach($res as $row){
            $html.="        <tr><td style='border:none;'>$row</td></tr>";                        
        }
        $html.="        </table>
                    </td>
                </tr>                        
            </table>
            </div>
        </td>
        <td valign='bottom'><button  style='float:right;' id='tl_calibration_print'>Print</button></td>
        </tr>
        </table>
        <script language='JavaScript'>
        $(\"#tl_calibration_print\").click(function(event){
            event.preventDefault();
            window.print();
        });
        </script>
        ";
        
    }
    return $html;
}

function tl_getOrgSelect($cs_num=""){
    
    $html="";
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.organization as value");
    bldsql_col("r.organization as display_name");
    bldsql_from("rgm_calrequest_view r");
    bldsql_where("r.calrequest_status_num=2");
    bldsql_where("organization is not null");
    bldsql_where("organization != '' ");
    if($cs_num)bldsql_where("r.calservice_num=?",$cs_num);
    bldsql_orderby("r.organization");
    $a=doquery();
    if($a){
        $html=getSelectInput($a,'tl_org_select','',"tl_org_selected",true);
    }
    return $html;
}

function tl_getHelpText(){
    return "
        <div class='title4'>Final Calibrations</div>
        <ul>
            <li>To select a calibration request, click on the cylinder row in one of the white fields.</li>
            <li>After the calibration summary loads below, either 'Select All' or choose individual calibrations, verify the value and repeatability, check 'Analysis Complete' and then Submit.</li>
            <li>If no calibrations were done you can enter 'na' or 'skipped' into the value field as appropriate, check analysis complete and then submit.</li>
        </ul>
        <div class='title4'>Comments and Sort</div>
        <ul>
            <li>The comments and sort columns (yellow) can be entered directly into the row without leaving the page.</li>
            <li>Click the field, make your entry and then the tab button.  Your entry is saved immeadiately to the database.</li>
            <li>Sort numbers can be used to order/group cylinders together in the list.  After entering 1 or more numbers, reload the list to resort the rows.</li>
        </ul>
        <div class='title4'>Field notes</div>
        <ul>
            <li>Avg Fill and # Cals are the average/# of unflagged calibration values for reported fill.</li>
            <li>Last Pressure and Last Regulator are also the last for the reported fill and may not be recent.</li>
        </ul>
        <div class='title4'>Show extra columns</div>
        <ul>
            <li>The 'Show extra columns' checkbox loads additional details for the calibration request off to the right of the comment box.</li>
        </ul>
        <div class='title4'>Filter by organization</div>
        <ul>
            <li>Choose an organization from the drop down to filter the list.</li>
            <li>You can choose the blank entry (top) to remove the filter.</li>  
        </ul>
        <div class='title4'>Copy to clipboard</div>
        <ul>
            <li>You can copy a subset of the fields from one or more rows to the clipboard by checking the left box on target rows and then clicking the 'Copy checked rows' button.</li>
            <li>Once in the clipboard, you can paste into excel for further processing.</li>
            <li>You can also select rows by entering a number in the 'Select rows with: Sort num' box to check all matching rows in the list and to copy to the clipboard.  </li>  
        </ul>";
}









?>
