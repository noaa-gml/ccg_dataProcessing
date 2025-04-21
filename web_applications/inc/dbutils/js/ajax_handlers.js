/*Various JS functions to handle interaction with the server.
Note, for easy of code navigation, some of ajax funcs reside in respective js files.

By default these functions will work if you have a switch.php page set up (see template version in ..)
*/
var ajax_switch_url="switch.php";
var dfltAjaxHandle=false; //Can be used generically by callers.

function ajax_get(doWhat,params,destdiv,ajaxhandle,loadingText) {
    /*
     *General function to call switch.php with params and put results in destdiv.
     *dowhat is a parameter expected by your switch.php to tell it what to do.
      params are key=val[&key2=val2[...]] that can be parsed by httpd and used by switch to return data.
      destdiv is where to put whatever is returned by switch.php. (note doesn't have to be an actual div, just a valid container id)
        if not passed then dbutils_js_div is used (included on standard template) for js only (no content).
      ajax handle must be a unique (for destdiv) global js var that we can use to stop prior calls for this same query(so they don't stack up).
      If not passed, then dfltAjaxHandle is used.
    
      You can get form data like this:
      var formData=$("#search_form").serialize();//Grab current filters
      */
    ajaxhandle=typeof ajaxhandle !== 'undefined' ? ajaxhandle:dfltAjaxHandle;
    destdiv=typeof destdiv !== 'undefined' ? destdiv:'dbutils_js_div';//default js only dest
    loadingText=typeof loadingText !== 'undefined' ? loadingText:'Loading...'; 

    if (submitNotInProgress()) {
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv,loadingText);
        //alert('doWhat='+doWhat+'&'+params);
        ajaxhandle=$.ajax({
            url:ajax_switch_url,
            type:'get',
            data: 'doWhat='+doWhat+'&'+params,
            success:function(data){
                $("#"+destdiv).html(data);
                stopNetworking();
            },  
                error: function(data,status,err) {
                        if (status!="abort" && data.responseText !='') {
                            if(status==403 || data.responseText.includes("403 Forbidden")){
                                alert("You have been signed out by NOAA SSO.  Page refresh required.");
                                window.location.reload();
                            }else{
                                alert("Unexpected return status for GET:"+status+"\nresponse.Text:"+data.responseText+"\nError:"+err);                              
                            }
                        }
                        submitInProgress=false;
                }    
        });
    }
}

function ajax_post(doWhat,params,destdiv,ajaxhandle,loadingText) {
    /*General function to call switch.php with a post of params and put result into dest div
      use $(...).serialize() to package a form
      see params above for comments.
      */
    
        ajaxhandle=typeof ajaxhandle !== 'undefined' ? ajaxhandle:dfltAjaxHandle;
        destdiv=typeof destdiv !== 'undefined' ? destdiv:'dbutils_js_div';//default js only dest
        loadingText=typeof loadingText !== 'undefined' ? loadingText:'Submitting...';
        submitInProgress=true;
        
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv,loadingText);
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
                        if(status==403 || data.responseText.includes("403 Forbidden")){
                            alert("You have been signed out by NOAA SSO.  Page refresh required.");
                            window.location.reload();
                        }else{
                            alert("Unexpected return status for GET:"+status+"\nresponse.Text:"+data.responseText+"\nError:"+err);                           
                        }
                        submitInProgress=false;
                }     
        });
    
}
function ajax_url(url,type,doWhat,params,destdiv,submitMssg,ajaxhandle) {
    /*Same as above, but allows you to pass custom url and either get or post.
      */
    
        ajaxhandle=typeof ajaxhandle !== 'undefined' ? ajaxhandle:dfltAjaxHandle;
        destdiv=typeof destdiv !== 'undefined' ? destdiv:'dbutils_js_div';//default js only dest
        submitMssg=typeof destdiv !== 'undefined' ? submitMssg:'Submitting...';
        
        submitInProgress=true;
        
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv,submitMssg);
        ajaxhandle=$.ajax({
                type:type,
                url:url,
                data: 'doWhat='+doWhat+'&'+params,
                success:function(data,stringStatus,obj){
                        $("#"+destdiv).html(data);
                        stopNetworking();
                        submitInProgress=false;
                },  
                error: function(data,status,err) {
                        if (status!="abort" && data.responseText !='') {
                            alert("Error: unexpected return status:"+data.responseText);
                        }
                        submitInProgress=false;
                }     
        });
    
}
var submitAjaxRequest;var submitInProgress=false;
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




