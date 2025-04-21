//Network activity gif...
var network_activity_counter=0;
var network_activity_last_time=Date.now();
var keepAliveAjaxHandle;
var keepAliveCounter=0;
var networkActivityGif="<image src='/inc/dbutils/template/resources/ajax-loader2.gif'>";
function startNetworking(targetDiv,message) {
    targetDiv=typeof targetDiv !== 'undefined' ? targetDiv:'';
    message=typeof message !== 'undefined' ? message:"Loading...";
    network_activity_last_time=Date.now();//Reset inactivity timer.
    if (targetDiv!="") {
        //Get the current height/width so we can put a place holder in to preserve layout.
        var div=$("#"+targetDiv);
        var height=div.innerHeight();
        var width=div.innerWidth();
        div.html("<div style='height:"+height+"px;width:"+width+"px;'>"+message+"</div>");
        
        //$("#"+targetDiv).empty();
        //$("#"+targetDiv).html("<span class='loading'>"+message+"</span>");
    }
    network_activity_counter++;
    if(targetDiv!='statusDiv'){keepAliveCounter=0;}//Reset keepalive counter used to force a reload after a period, only when not the keep alive...
    if (network_activity_counter>0) {
        //$("#networkActivityDiv").html("<image src='https://omi.cmdl.noaa.gov/inc/dbutils/template/resources/ajax-loader2.gif'>");
        $("#networkActivityDiv").html(networkActivityGif);
    }
    //setStatusMessage('',0);Commented out, this was wiping legit comments
}
function stopNetworking() {
    network_activity_counter--;
    if (network_activity_counter<=0) {
        $("#networkActivityDiv").empty();
        network_activity_counter=0;//Reset just in case.
    }
}
function stopAjaxQuery(handler) {
    /*This will cancel any in progress ajax requests for the passed request handler.*/
    if(handler){//If one is still going, abort it.
        handler.abort();
        handler=false;
        stopNetworking();
    }
}
var clearStatusMessageTimer;//Global used (in php code) to wipe the status after a set time.  Global allows us to unset it.
function setStatusMessage(message,wipeAfter,destDiv) {
    //auto clears message in wipeafter seconds (0 to leave).
    //Destdiv is statusDiv by default.
    destDiv=typeof destDiv !== 'undefined' ? destDiv:'statusDiv';
    clearTimeout(clearStatusMessageTimer);//Prevent an earlier message from wiping us early.
    $("#"+destDiv).html(message);
    if (wipeAfter>0 && message!="") {
        clearStatusMessageTimer=setTimeout(function(){$("#"+destDiv).empty();},wipeAfter*1000);
    }
}

function keepAlive() {
    //Super annoying work around attempt for how chrome handles self signed certs (which use of is prime annoying cause)
    //After some period, chrome will 'forget' the acceptance override of a self signed cert.  Normally, the next link you goto
    //will just get the bad cert message, but with ajax app, the query silently fails!
    //We'll setup a little ping to try to keep cert from timing out.
    //jwm 11/19.  Adding a refresh after awhile.  Now that we switched to icam auth, chrome is having a new problem.  THe icam times out after a day or so and
    //then puts up a dialog box to accept gov restrictions.  Chrome keeps opening new windows, using on my mac ~40gb of mem, blowing up computer. 
    var keepaliveTime=1000*10*60;
    //keepaliveTime=1000*1;
    var now=Date.now();
    var timePassed=now-network_activity_last_time;
    keepAliveCounter++;
    if(keepAliveCounter>12 ){//~120min.  5/20 bumpted up from 5 because was causing Ed issues when reloaded too fast
        //window.location.reload(true);//note this reloads post data too, so not uskng
        keepAliveCounter=0;//make sure it resets.some browsers seem to keep values after loc.href
        window.location.href=window.location.href;//This will pass get params if in qs, but not post.  May get cached.  hopefully that doesn't cause issues
        
    }else{
        if (timePassed>keepaliveTime) {
            ajax_get("keepAlive","keepAliveCounter="+keepAliveCounter,"statusDiv",keepAliveAjaxHandle);
        }
        setTimeout(function(){keepAlive();},keepaliveTime);    
    }    
}
