var tl_ajax_req;
function tl_loadList() {
    //Load processing calservices for selected cs_num
    
    $("#detailDiv").empty();
    var cs_num=$("#tl_calservice_select").val();
    //Set the title text
    $("#tl_species_div").html($("#tl_calservice_select option:selected").text());
    
    var org=$("#tl_org_select").val();
    if (org==undefined) {
        org="";
    }
    if (org!="") {
        //If filtering by org, check the extras col so it displays
        $("#tl_extraCols").prop('checked',true);
    }
    var extra=($("#tl_extraCols").prop('checked'))?1:0;
    var addl=(!$("#tl_showAddlSpecies").attr('disabled') && $("#tl_showAddlSpecies").prop('checked'))?1:0;
    var sort=$("#tl_calservice_sort_mode").val();
    ajax_get("getCalServiceList","cs_num="+cs_num+"&tl_extraCols="+extra+"&tl_organization="+org+"&tl_showAddlSpecies="+addl+"&tl_sort_mode="+sort,"dataDiv",tl_ajax_req)
}
function tl_getOrgSelect() {
    var cs_num=$("#tl_calservice_select").val();
    ajax_get("tl_getOrgSelect","cs_num="+cs_num,"tl_org_select_div",tl_ajax_req)
}
function tl_org_selected() {
    tl_loadList();
}
function tl_calservice_select_changed() {
    //Fires on cs change event
    
    //Show/Hide the addl species checkbox, currently only for ch4 & co
    var cs_num=$("#tl_calservice_select").val();
    if(cs_num==1 || cs_num==3){
        $("#tl_showAddlSpeciesDiv").show();
        $("#tl_showAddlSpecies").attr("disabled",false);
        if(cs_num==1){$("#tl_showAddlSpecies_label").html("Include ch4");}
        else{$("#tl_showAddlSpecies_label").html("Include h2/n2o");}
    }
    else{
        $("#tl_showAddlSpecies").attr("disabled",true);//So it doesn't get submitted.
        $("#tl_showAddlSpeciesDiv").hide();
        
    }
    
    //Load the list
    tl_loadList();//Load the todo list.
    tl_getOrgSelect();//Reload org select
    
}
function tl_setsortnum(request_num) {
    var val=$("#sort_"+request_num).val();
    ajax_post("tl_editSortNum","tl_request_num="+request_num+"&tl_sortNum="+val,"sort_"+request_num+"_div",tl_ajax_req);
}
function tl_setcomment(request_num) {
    var val=$("#comment_"+request_num).val();
    ajax_post("tl_editComment","tl_request_num="+request_num+"&tl_comment="+val,"comment_"+request_num+"_div",tl_ajax_req);
}

function tl_checkboxSelected() {
    //code
    console.log("do some cool check box stuff");
}
function tl_selectBySortNum() {
    //checks rows with entered sortnum
    var num=$("#tl_select_sort_num").val();
    $(".tl_selectBox").prop("checked",false);//reset all.
    if (num) {
        $(".tl_sort_num_class").each(function(){        
            if($(this).html()==num){
                 var t=$(this).attr("id");
                 var a=t.split("_");
                 var id="selection_"+a[1];
                 $("#"+id).prop("checked",true);
            }        
        });
        tl_copySelected();
    }
}
function tl_selectBySearch(val,colclass) {
    //checks rows with entered sortnum

    $(".tl_selectBox").prop("checked",false);//reset all.
    $("."+colclass).each(function(){
        if ($(this).html().toLowerCase().indexOf(val)>=0) {
             var t=$(this).attr("id");
             var a=t.split("_");
             var id="selection_"+a[1];
             $("#"+id).prop("checked",true);
        }        
    });
    tl_copySelected();
}
function tl_copySelected() {
    //Copies the target rows to clipboard.
        var i=0;
        var txt="";
        //Find all rows with check box selected and copy them
        $("input:checked.tl_selectBox").each(function(){
            txt+=$(this).val()+"\n";
            i++;
        });
        if(i>0)txt="cyl,avg_targ,press,fill,reg,numcals\n"+txt;
        $("#tl_copyArea").show();
        $("#tl_copyArea").html(txt).select();
        var ok=document.execCommand("copy");
        
        if(ok){
            $("#tl_copyArea").hide();
            var msg=(i==1)?"row":"rows";
            msg=i+" "+msg+" copied to clipboard.";
            setStatusMessage(msg,4,"tl_copyMssgDiv");
        }else{
            if (i>0) {
                msg="Your browser prevented copying rows to clipboard.  You can ctrl+c to copy the text below.";
                $("#tl_copyArea").html(txt).select();//Above select doesn't work when hidden.
                setStatusMessage(msg,6,"tl_copyMssgDiv");
            }
        }
       
}
function tl_calibration_updateSelected() {
    //Loop through displayed calibration checkboxes and calculate the mean and repeatability for selected ones.
    //CO2 has two isotopes in some cases, so we'll calc those too.  Note isotope values are appended onto the value with '~'s when present.
    //They are genericly labelled though.
    //Note we only calc mean for 2/3 (if present) because that's all that was requested.
    var aVal=[];
    var sum=0.0;var sum2=0.0; var sum3=0.0;
    var mean=0.0;var mean2=0.0; var mean3=0.0;
    var numChecked=0;var numChecked2=0;var numChecked3=0;
    var variance=0.0;var stdev=0.0; var text=""; 
    $(".tl_calibration_checkbox").each(function(){
        if($(this).prop("checked")){
            var value=0.0;var value2=0.0;var value3=0.0;
            var a=$(this).val().split('~');
            value=parseFloat(a[0]);
            if (a.length>1) {
                if(a[1]){
                    value2=parseFloat(a[1]);//might be empty string (if co2 on inst that doesn't produce )
                    numChecked2++;//Only average actual values (not empty strings).
                }
                if (a.length>2) {
                    if(a[2]){
                        value3=parseFloat(a[2]);
                        numChecked3++;
                    }
                }
            }
            aVal.push(value);//so we can calc variance below.
            sum+=value;
            sum2+=value2;
            sum3+=value3;
            numChecked++;
            text+=$(this).attr('data')+"\n";
        }
    });
    mean=sum/numChecked;
    if (sum2!==0) {
        mean2=sum2/numChecked2;
    }
    if (sum3!==0) {
        mean3=sum3/numChecked3;
    }
    
    //calculate the variance
    var t=0.0;
    for(var j=0;j<numChecked;j++){t+= Math.pow(aVal[j]-mean,2);}
    // Needs to be divided by n-1 because the value was determined from this
    //  sample data not independently (this is a sample variance, not a population variance)
    variance=t/(numChecked-1);
    //console.log(variance);
    stdev=Math.sqrt(variance);
    meanVal=(mean)?mean.toFixed(3):"";//Clean up the output a little.
    mean2Val=(mean2)?mean2.toFixed(3):"";
    mean3Val=(mean3)?mean3.toFixed(3):"";

    stdevVal=(stdev)?stdev.toFixed(3):"NaN";
    //stdevVal=stdev.toFixed(3);//Actually we'll leave it as nan for compatibility reasons.
    
    $("#tl_calibration_value").val(meanVal);
    $("#tl_calibration_value_2").val(mean2Val);
    $("#tl_calibration_value_3").val(mean3Val);
    
    $("#tl_calibration_repeatability").val(stdevVal);
    $("#tl_calibration_selectedRowText").val(text);//This is a hidden textarea to store/pass along the text of selected rows.
}

function tl_calibration_submitAnalysis(){
    if ($("#tl_calibration_value").val()=="" || $("#tl_calibration_repeatability").val()=="") {
        var mssg="Please select calibrations or enter 'na' in the value field.";
        setStatusMessage(mssg,4,"tl_calibrations_mssg_div") 
    }else{
        var formData=$("#calibrationAnalForm").serialize();//Grab current filters
        ajax_post('tl_calibration_submitAnalysis',formData,'detailDiv',tl_ajax_req);
    }
}

function tl_calibration_validate_vr_entry(id) {
    //Restrict available entrys to a float or 1 or more keywords.
    var val=$("#"+id).val();
    var fval=parseFloat(val);
    if (isNaN(fval)) {
        //See if valid string
        val=val.toLowerCase();
        if (val=='na') val='n/a';
        if (val!='skipped' && val!='completed' && val!='n/a' ) {
            var mssg="Valid entries are 'skipped', 'completed', 'n/a' or an actual number.";
            setStatusMessage(mssg,4,"tl_calibrations_mssg_div") 
            $("#"+id).val('');     
        }else{
            $("#"+id).val(val);//convert to lowercase if needed.
            if (id=='tl_calibration_value') {
                //Set repeatability to same
                $("#tl_calibration_repeatability").val(val);
            }
        }
    }
}




