/*Various JS functions to handle interaction with the server.  Note, for easy of code navigation, some of ajax funcs reside in respective js files.*/
var ajax_switch_url="j/switch.php";
var ajax_dfltHandle;
function ajax_get(doWhat,params,destdiv,ajaxhandle,loadingMessage) {
    //generic function to call switch.php with params and put results in destdiv.
    //params are key=val[&key2=val2[...]]
    //ajax handle must be a unique (for destdiv) global js var that we can use to stop prior calls for this same query(so they don't stack up).
    if (submitNotInProgress()) {
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        message=typeof loadingMessage !== 'undefined' ? loadingMessage:"Loading...";
        startNetworking(destdiv,message);
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
        //console.log(doWhat);
        stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        startNetworking(destdiv,'Submitting...');
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




