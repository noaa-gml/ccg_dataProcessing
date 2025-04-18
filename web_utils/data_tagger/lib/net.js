//Network activity gif...
var network_activity_counter=0;
var network_activity_last_time=Date.now();
function startNetworking(targetDiv,message) {
    targetDiv=typeof targetDiv !== 'undefined' ? targetDiv:'';
    message=typeof message !== 'undefined' ? message:"Loading...";
    network_activity_last_time=Date.now();//Reset inactivity timer.
    if (targetDiv!="") {
        $("#"+targetDiv).empty();
        //$("#"+targetDiv).html("<div style='height: 100%;width:100%;vertical-align:middle;text-align: center;'><image src='images/loadingDots.gif'></div>")
        $("#"+targetDiv).html("<div class='loading'>"+message+"</div>");
    }
    network_activity_counter++;
    if (network_activity_counter>0) {
        $("#networkActivityDiv").html("<image src='images/ajax-loader2.gif'>");
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
function setStatusMessage(message,wipeAfter) {
    //auto clears message in wipeafter seconds (0 to leave).
    clearTimeout(clearStatusMessageTimer);//Prevent an earlier message from wiping us early.
    $("#statusDiv").html(message);
    if (wipeAfter>0 && message!="") {
        clearStatusMessageTimer=setTimeout(function(){$("#statusDiv").empty();},wipeAfter*1000);
    }
}
function keepAlive() {
    //Super annoying work around attempt for how chrome handles self signed certs (which use of is prime annoying cause)
    //After some period, chrome will 'forget' the acceptance override of a self signed cert.  Normally, the next like you goto
    //will just get the bad cert message, but with ajax app, the query silently fails!
    //We'll setup a little ping to try to keep cert from timing out.
    var keepaliveTime=1000*5*60;
    var now=Date.now();
    var timePassed=now-network_activity_last_time;
    
    if (timePassed>keepaliveTime) {
        startNetworking("statusDiv","Attempting keep alive");
        $.ajax({
                url:"switch.php",
                type:'get',
                data: "&doWhat=keepAlive",
                success:function(data){
                    stopNetworking();
                    $("#statusDiv").html(data);
                    setTimeout(function(){keepAlive();},keepaliveTime);
                }
                
        });
    }else{
        setTimeout(function(){keepAlive();},keepaliveTime);
    }
    
    
}