/*Various JS functions to handle interaction with the server.  Note, for easy of code navigation, some of ajax funcs reside in respective js files.*/
//Note; jwm - 3/21/19, set all the 'get' ajax calls to post/processData:false to allow larger criteria submissions (like when pasting in a bunch of ids)
//2 New wrappers from rgm...
var ajax_switch_url="switch.php";
function ajax_get(doWhat,params,destdiv,ajaxhandle) {
    //generic function to call switch.php with params and put results in destdiv.
    //params are key=val[&key2=val2[...]]
    //ajax handle must be a unique (for destdiv) global js var that we can use to stop prior calls for this same query(so they don't stack up).
    if (submitNotInProgress()) {
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv);
        //alert('doWhat='+doWhat+'&'+params);
        ajaxhandle=$.ajax({
            url:ajax_switch_url,
            type:'get',
            data: 'doWhat='+doWhat+'&'+params,
            success:function(data){
                //alert('"'+data+'"');
                //$("#"+destdiv).hide();
                $("#"+destdiv).html(data);
                //$("#"+destdiv).slideDown();
                stopNetworking();
            },  
                error: function(data,status,err) {
                        if (status!="abort") {
                            alert("Error: unexpected return status:"+JSON.stringify(data,null,4));
                        }
                        submitInProgress=false;
                }    
        });
    }
}

function ajax_post(doWhat,params,destdiv,ajaxhandle) {
    //generic function to call switch.php with a post of params and put results into dest div
    //use $(...).serialize() to package a form
        submitInProgress=true;
        
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv);
        ajaxhandle=$.ajax({
                type:'POST',
                url:ajax_switch_url,
                data: 'doWhat='+doWhat+'&'+params,
                success:function(data,stringStatus,obj){
                        $("#"+destdiv).html(data);
                        stopNetworking();
                        submitInProgress=false;
                },  
                error: function(data,status,err) {
                        if (status!="abort") {
                            alert("Error: unexpected return status:"+JSON.stringify(data,null,4));
                        }
                        submitInProgress=false;
                }     
        });
    
}
////

function updateSelectMenu(id,filter,newValue) {
        /*This method updates the passed id to filter the select menu to all (0) or options available in the current filter criteria(1)
        ID is select to update
        filter is 1 to limit to options in current filter criteria, 0 to get default list.
        --Maybe this should abort?  That might screw up logic if multiple are selected though.
        
        newValue(default '') .  If passed, we attempt to set to newVal
        
        */
        newValue=typeof newValue !== 'undefined' ? newValue:'';
        
        $("#"+id).empty();//set the option to a temp value
        $("#"+id).html("<option value='' selected>Loading...</option>");
        //Note, need to empty() before serializing so it doesn't participate in the filters.
        var formData=$("#data_selection").serialize();//Grab current filters
        //alert(formData);
        $.ajax({
            url:"switch.php",
            type:'get',
            data: formData+"&doWhat=getSelectMenuOptions&targetSelectID="+id+"&filter="+filter,
            success:function(data){
                $("#"+id).empty();
                $("#"+id).html(data);
                if (newValue!='') {
                    $("#"+id).val(newValue);
                    setFilterDescription();
                }
                //alert(data);
            }
        });
}

/*Search query*/
var search_ajax_request;//Global  ajax request object.  We use this so we can cancel if needed.
function doSearch(){
        if (submitNotInProgress()) {
                stopAjaxQuery(search_ajax_request);//Stop any in progress searches
                stopAjaxQuery(tag_ajax_request);//.. and tag list selects (which could be longer).
                
                startNetworking("searchResults");
                $("#tagList").empty();
                setStatusMessage('',0);
                var formData=$("#data_selection").serialize();
                //See if > 65,535 characters and bomb out if so.  This blows up various infrastructure (php text, mysql text...)
                if(formData.length>64000){
                	alert("Error; the criteria entered ("+formData.length+" characters) exceeds the maximum capacity for the web interface.  This tag must be entered manually (see John Mund)");
                }else{
                	//alert(formData);
                	search_ajax_request=$.ajax({
                	    url:"switch.php",
                	    proccessData:false,
                	    type:'post',
                	    data: formData+"&doWhat=doSearch",
                	    success:function(data){
                	        $("#searchResults").empty();
                	        $("#searchResults").html(data);
                	        stopNetworking();
                	        getTagList("","");
                	    }
                	});
                }
        }
}


/*Tags*/
var tag_ajax_request;//Global tag ajax request object.  We use this so we can cancel if needed.
function getTagList(event_num,data_num,version) {
    //Returns the list of tags for passed ev, data num or if neither, the current selection.  see php func for details.
    //Optional version is to specify which tag list to load.. this has gone thru mulitple iterations.  not passing or '' is current default version
    if (submitNotInProgress()) {
        data_num=typeof data_num !== 'undefined' ? data_num:'';
        event_num=typeof event_num !== 'undefined' ? event_num:'';
        version=typeof version !== 'undefined' ? version:'';
        stopAjaxQuery(tag_ajax_request);//Stop any in progress tag queries
        
        startNetworking("tagList");
        var formData=$("#data_selection").serialize();
        tag_ajax_request=$.ajax({
            url:"switch.php",
            type:'post',
            processData:false,
            data: formData+'&doWhat=getTagList&event_num='+event_num+'&data_num='+data_num+'&getTagListversion='+version,
            success:function(data){
                $("#tagList").html(data);
                stopNetworking();
                //alert(data);
            }
        });
    }
}
/*OLD
function tagRowSelected(tag_num,event_num,data_num){
    //An 'editable' (as defined by list) tag was clicked.  Load data in edit form.
    stopAjaxQuery(tag_ajax_request);//Stop any inprogress tag requests
    clearTimeout(clearTagEditFormTimeout);//remove any timers that will wipe the form area
    startNetworking('tagEditFormDiv');
    var formData=$("#data_selection").serialize();//Grab current filters
    var hash=$("#baseQueryHash").val();//Grab the hash of the original base query so server can make sure old/new are the same.  This is for when adding/editing on multiple tags
    tag_ajax_request=$.ajax({
        type:'GET',
        url:'switch.php',
        data: formData+'&doWhat=getTagEditForm&tag_num='+tag_num+'&baseQueryHash='+hash+'&event_num='+event_num+'&data_num='+data_num,
        success:function(data){
            $('#tagEditFormDiv').empty();
            $('#tagEditFormDiv').html(data);
            stopNetworking();
        }   
    });
}*/
/*Tag Edit Form (add,edit & append)*/
function tagEdit_add(event_num,data_num) {
    //package up the selection criteria used for this add.  If we're in single row mode, just use those fields (so the 'current selection' will work);
    data_num=typeof data_num !== 'undefined' ? data_num:'';
    event_num=typeof event_num !== 'undefined' ? event_num:'';
    
    var formData="";    
    if (event_num!="" || data_num!="" ) {
        formData="event_num="+event_num+"&data_num="+data_num;
    }else{
        formData=$("#data_selection").serialize();//Grab current filters
    }
    tagEdit_getEditForm("","add",formData);
}
function tagEdit_appendComment(range_num) {
    
}
function tagEdit_edit(range_num) {
    formData=$("#data_selection").serialize();//Grab current filters
    tagEdit_getEditForm(range_num,'edit',formData);
}
function tagEdit_append(range_num) {
    formData=$("#data_selection").serialize();//Grab current filters
    tagEdit_getEditForm(range_num,'append',formData);
}
function tagEdit_getEditForm(range_num,edit_mode,selection_criteria) {
    //edit_mode can be add,edit or append (comment).
    //range_num can be blank for add mode.
    //Selection criteria defines the range of events or data rows this will applied to in add mode
    if (submitNotInProgress()) {
        stopAjaxQuery(tag_ajax_request);//Stop any inprogress tag requests
        clearTimeout(clearTagEditFormTimeout);//remove any timers that will wipe the form area
        startNetworking('tagEditFormDiv');
        
        var hash=$("#baseQueryHash").val();//Grab the hash of the original base query.
        tag_ajax_request=$.ajax({
            proccessData:false,
            type:'post',
            url:'switch.php',
            data: selection_criteria+'&doWhat=getTagEditForm&range_num='+range_num+'&edit_mode='+edit_mode+'&baseQueryHash='+hash,
            success:function(data){
                $('#tagEditFormDiv').empty();
                $('#tagEditFormDiv').html(data);
                stopNetworking();
            }   
        });
    }
}

function tagRangeSelected(tag_range_num) {
    //A range from the tag list was selected.. load up the details.
    if (submitNotInProgress()) {
        stopAjaxQuery(tag_ajax_request);//Stop any inprogress tag requests
        clearTimeout(clearTagEditFormTimeout);//remove any timers that will wipe the form area
        startNetworking('tagEditFormDiv');
        var formData=$("#data_selection").serialize();//Pass so we can reset to selection if changed..
        tag_ajax_request=$.ajax({
            proccessData:false,
            type:'post',
            url:'switch.php',
            data: formData+'&doWhat=getTagRangeDetails&range_num='+tag_range_num,
            success:function(data){
                $('#tagEditFormDiv').empty();
                $('#tagEditFormDiv').html(data);
                stopNetworking();
            }   
        });
    }
}
function submitNotInProgress() {
    //See if a submit in progress and prompt to wait or cancel it
    if (submitInProgress) {
        var msg="A data modification has been submitted and the server has not yet responded.\n";
        msg+="Click 'Cancel' to wait for it to complete.  Click 'Continue' to abort it.\n";
        msg+="Note; Even if you abort, some changes may have already gone through.  You should reload your selection and verify the changes that have been made are as expected.";
        if (confirm(msg)){
                 stopAjaxQuery(submitAjaxRequest);
                 submitInProgress=false;
        }else return false;
    }
    return true;
}
/*Data submission*/
function submit_tagEdit_form(){
    if ($("#tagEdit_tag_num").val()) {
        var tagEdit_data=$("#tagEditForm").serialize();//And the tag data
        submitTagEdit("","",tagEdit_data);//Note, both range_num and edit_mode are inputs in the form
    }else{
        alert("You must select a tag for this entry");
        return;
    }
}
function submit_rev_tagEdit_form(){
    if ($("#tagEdit_tag_num").val()) {
        var tagEdit_data=$("#tagEditForm").serialize();//And the tag data
        submitTagEdit("","rev_tagEdit",tagEdit_data);
    }else{
        alert("You must select a tag for this entry");
        return;
    }
}
function tagEdit_addto(range_num) {
    //Append current selection to the passed range
    submitTagEdit(range_num,'addto','');
        
}

function tagEdit_delete(range_num) {
    //Delete passed range
    submitTagEdit(range_num,'delete','');
}
var submitAjaxRequest;var submitInProgress=false;
function submitTagEdit(range_num,edit_mode,otherParams) {
    /*Submit some sort of tagedit, either from form or button action.
     *range_num, edit_mode and otherParams can be passed '' when appropriate, but must be passed.*/
    submitInProgress=true;
    var formData=$("#data_selection").serialize();//Grab current filters
    if (range_num!="") {formData+="&tagEdit_range_num="+range_num;}
    if (edit_mode!="") {formData+="&tagEdit_editMode="+edit_mode;}
    if (otherParams!="") {formData+="&"+otherParams;}
    var doWhat=(edit_mode=='rev_tagEdit')?"rev_submitTagEdit":"submitTagEdit";
    var targetID=(edit_mode=='rev_tagEdit')?"rev_rangeEditDiv":"tagList";
    stopAjaxQuery(submitAjaxRequest);//Stop any inprogress tag submit
    //clearTimeout(clearTagEditFormTimeout);//remove any timers that will wipe the form area
    
    //$("[id^=tagEdit_]").prop("disabled",true);//Disable form while submitting
    startNetworking("tagEditFormDiv","Submitting...");
    submitAjaxRequest=$.ajax({
        proccessData:false,
        type:'post',
        url:'switch.php',
        data: formData+'&doWhat='+doWhat,
        success:function(data,stringStatus,obj){
            //We expect html with a pre-pended status telling us where to put the returned text.
            //1 is success, reload whole tagList area, data will be a fresh taglist
            //2 is a submission error, just reload the form div
            
            var stat=data.charAt(0);
            if (stat=='1') {
                    //$("#tagList").empty();rev_rangeEditDiv
                    $("#"+targetID).html(data.slice(1)); 
            }else if(stat=='2'){
                    //$('#tagEditFormDiv').empty();
                    $('#tagEditFormDiv').html(data.slice(1));
            }else{
                var s="Hmm.  Unexpected return value: '"+stringStatus+"'.  Reload selection to verify changes made and correct as needed.  Please send this message to John Mund.";
                var s=s+JSON.stringify(data, null, 4);
                var s=s+JSON.stringify(obj, null, 4);
                
                alert(s);
                $('#tagEditFormDiv').html("<code>"+s+"</code>");
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
    
}

//review.php functions
var rev_tag_ajax_request;//Global tag ajax request object.  We use this so we can cancel if needed.
function rev_getTaggedEventList() {
    //Returns the list tagged events (tag_ranges) for selected tag and other criteria
    if (submitNotInProgress()) {
        stopAjaxQuery(rev_tag_ajax_request);//Stop any in progress tag queries
        
        startNetworking("taggedEventList");
        var formData=$("#data_selection").serialize();
        rev_tag_ajax_request=$.ajax({
            url:"switch.php",
            proccessData:false,
            type:'post',
            data: formData+'&doWhat=rev_getTaggedEventList',
            success:function(data){
                $("#rev_taggerEventsDiv").html(data);
                stopNetworking();
                //alert(data);
            }
        });
    }
}
var rev_getTaggedEventPlot_ajax_req;
function rev_getTaggedEventPlot() {
    //Retrieves plot for selected event (if any row selected).
    if (submitNotInProgress()) {
        stopAjaxQuery(rev_getTaggedEventPlot_ajax_req);//Stop any in progress tag queries
        var range_num=$("#rev_taggedEvents").val();
        
        if (range_num) {
                startNetworking("dataDiv");
                var formData=$("#data_selection").serialize();
                rev_getTaggedEventPlot_ajax_req=$.ajax({
                    url:"switch.php",
                    proccessData:false,
                    type:'post',
                    data: formData+'&doWhat=rev_getEventPlot&range_num='+range_num,
                    success:function(data){
                        $("#dataDiv").html(data);
                        stopNetworking();
                        //alert(data);
                    }
                });
        }
    }
}
var rev_getRangeEditForm_ajax_req;
function rev_getRangeEditForm() {
    //Returns the range edit form
    if (submitNotInProgress()) {
        stopAjaxQuery(rev_getRangeEditForm_ajax_req);//Stop any in progress tag queries
        var range_num=$("#rev_taggedEvents").val();
        
        if (range_num) {
                startNetworking("detailDiv");
                var formData=$("#data_selection").serialize();
                rev_getRangeEditForm_ajax_req=$.ajax({
                    url:"switch.php",
                    proccessData:false,
                    type:'post',
                    data: formData+'&doWhat=rev_getRangeEditForm&range_num='+range_num,
                    success:function(data){
                        $("#detailDiv").html(data);
                        stopNetworking();
                        //alert(data);
                    }
                });
        }
    }
}



