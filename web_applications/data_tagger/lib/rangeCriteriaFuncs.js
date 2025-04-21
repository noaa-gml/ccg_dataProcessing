function setCriteria(json) {
    /*NOTE!  This function must be kept in sync with the function clearFields().  
    We clear the fields here (instead of calling it) because of issues with updating select menus and call back timing.
    Make sure to keep both in sync when editing either.
    
    Note; selects need be cleared and set with new value below
    autocompletes just set (cleared in defaults)
    
    Loads passed json obj into criteria selection
    arr is a json object that is loaded dynamically, keys are form input ids, val is current value when range was selected.
    */
    
    json=typeof json !== 'undefined' ? json:false;
    //console.log(json);
    if (json && typeof json =='object') {
        $(".ev_field").val("");
        $(".d_field").val("");
        $(".id_field").val("");
        $(".tag_field").val("");
        $("#ev_project_num").val([]);
        $("#ev_strategy_num").val([]);
        $("#ev_sTimewindow").val([]);
        $("#ev_eTimewindow").val([]);
            
        $("#d_program_num").val([]);
        $("#d_parameter_num").val([]);
        $("#d_inst").val([]);
        $(":checkbox.search_field").prop('checked',false);
        
        $.each(json,function(key,val){//Set all.  Note some select menus may not get set if they have a filtered options list.  We'll get them below.
            if(!(jQuery.isEmptyObject(val))){
                if($("#"+key).is(':checkbox') && parseInt(val))$("#"+key).prop('checked',true);//Check any checkboxes.  Note val can be string '0' which evals to true.
                $("#"+key).val(val);//Set values for all.
            }
        });
        updateSelectMenu("ev_project_num",0,json['ev_project_num']);
        updateSelectMenu("ev_strategy_num",0,json['ev_strategy_num']);
        updateSelectMenu("d_program_num",0,json['d_program_num']);
        updateSelectMenu("d_parameter_num",0,json['d_parameter_num']);
        updateSelectMenu("d_inst",0,json['d_inst']);
        updateSelectMenu("d_tag_num",0,json['d_tag_num']);
        updateSelectMenu("ev_tag_num",0,json['ev_tag_num']);
        setAutomcompleteVal("ev_site_num",json['ev_site_num']);
        
        clearDataAreas();
        setState();
        setFilterDescription();
        
        
    //This was causing problems when json='', which happens if you try to edit a range with criteria that matches current selection.
    //For now we'll just silently ignore any errors.
    //}else{
    //    alert("Error loading selection criteria"+json);
    }
}
var cancelEditCriteriaSelection_oldCriteria="";//Global for use below by the cancel button.. couldn't figure a good way to do this dynamically.
function loadRangeCriteriaEdit(searchCriteria,range_num,currentSelectionCriteria) {
    /*This loads a range's criteria to allow editing and loads the details screen in the results area.
    */
    
    //Load the original criteria
    setCriteria(searchCriteria);
    
    //Set the display mode for range criteria edit    
    setMode(1);
    
    //Set the range num
    $("#rangeCriteriaEditRangeNum").val(range_num);
    
    //Set the cancel button reset data.  Note this is a global var
    //Only set it if it's different than the searchCriteria (original).  Ie, if user just created a range, then edited
    //the criteria, we want the 'reloaded' criteria to be what they just changed it to.  If, on the other hand
    //they had an open search, then clicked a range, edited criteria, we want the full original search to be reloaded.
    if (JSON.stringify(searchCriteria)!=JSON.stringify(currentSelectionCriteria)) {
        cancelEditCriteriaSelection_oldCriteria=currentSelectionCriteria;
    }else{
        cancelEditCriteriaSelection_oldCriteria="";//Signal to below logic not to load it.
    }
    
    //Fill the diplay area with range details
    getRangeCriteriaEditDetails(range_num);
   
}
function getRangeCriteriaEditDetails(range_num) {
    if (submitNotInProgress()) {
        range_num=typeof range_num !== 'undefined' ? range_num:'';
        stopAjaxQuery(tag_ajax_request);//Stop any in progress tag queries
        
        startNetworking("tagList");
        
        tag_ajax_request=$.ajax({
            url:"switch.php",
            type:'get',
            data: '&doWhat=getRangeCriteriaEditDetails&range_num='+range_num,
            success:function(data){
                $("#tagList").html(data);
                stopNetworking();
                //alert(data);
            }
        });
    }
}
function doRangeChangeSubmit() {
    //Submit changes to the range criteria
    
    
    var formData=$("#data_selection").serialize();//Grab current filters
    //Grab the range_num
    var range_num=$("#rangeCriteriaEditRangeNum").val();
    if(cancelEditCriteriaSelection_oldCriteria!="")setCriteria(cancelEditCriteriaSelection_oldCriteria);//Reset to old criteria if set. (see above)
    setMode(0);//Reset mode to search mode.
    
    if (range_num!=""){ 
        submitInProgress=true;
        stopAjaxQuery(submitAjaxRequest);//Stop any inprogress tag submit
        //clearTimeout(clearTagEditFormTimeout);//remove any timers that will wipe the form area
     
        //$("[id^=tagEdit_]").prop("disabled",true);//Disable form while submitting
        startNetworking("tagList","Submitting...");
        submitAjaxRequest=$.ajax({
            type:'POST',
            url:'switch.php',
            data: formData+'&doWhat=submitTagRangeCriteriaEdit&range_num='+range_num,
            success:function(data,stringStatus,obj){
                //We expect html with a pre-pended status telling us where to put the returned text.
                //1 is success, reload old criteria, initiate search and reload taglist area
                //2 is a submission error, offer to reload page.
                
                var stat=data.charAt(0);
                if (stat=='1') {
                        //$("#tagList").empty();
                        $("#tagList").html(data.slice(1));
                        
                        
                }else if(stat=='2'){
                        $("#tagList").html(data.slice(1));
                        //Do some error handling...
                        
                }else{
                    var s="Hmm.  Unexpected return value: '"+stringStatus+"'.  Reload selection to verify changes made and correct as needed.  Please send this message to John Mund.  Click 'Search' to reset.";
                    var s=s+JSON.stringify(data, null, 4);
                    var s=s+JSON.stringify(obj, null, 4);
                   
                    alert(s);
                    $('#tagList').html("<code>"+s+"</code>");
                }
                stopNetworking();
                submitInProgress=false;
            },  
            error: function(data,status,err) {
                    
                    if (status!="abort") {
                        alert("Error: unexpected return value");
                            $('#tagEditFormDiv').html(JSON.stringify(data, null, 4));
                    }
                    submitInProgress=false;
            }     
        });
    }else{alert("Error submitting range change.  Range_num not specified.");}
}