/*Various networking functions to submit forms and perform gets*/

//TO DO ;
//print table

let bs_fetchController=null;//Global ajax abort controller

function bs_get(data,destDiv='bs_ajaxJSDiv',loadingText='Loading...',url='switch.php', abortPrevious=true, reuseAbortController=false){
     /* Send get request to server and load results asynchronously into destDiv
        data is a FormData object, use bs_getFormData() to create.
        destDiv is id of where to put response.  Can be a span or similar too.  Default bs_ajaxJSDiv is hidden and should only be used
        if only javascript will be returned.
        See bs_ajax for abort documentation.
     */
        bs_ajax(data,'GET',url,destDiv,loadingText,abortPrevious,reuseAbortController);

}
function bs_mget(isFirst,data,destDiv='bs_ajaxJSDiv',loadingText='Loading...',url='switch.php'){
     /* Multi get.  Load several divs at once.
        Pass isFirst true on first, false on rest.
        data is a FormData object, use bs_getFormData() to create.
        destDiv is id of where to put response.
     */

        bs_ajax(data,'GET',url,destDiv,loadingText,isFirst,!isFirst);

}
function bs_post(data,destDiv='bs_ajaxJSDiv',loadingText='Submitting...',url='switch.php'){
     /* Send post request to server and load results asynchronously into destDiv
        data is a FormData object, use bs_getFormData() to create.
        destDiv is id of where to put response.  Can be a span or similar too. Default bs_ajaxJSDiv is hidden and should only be used
        if only javascript will be returned.
        Aborts any previous operation
     */
        bs_ajax(data,'POST',url,destDiv,loadingText)

}
function bs_uploadFile(inputID,destDiv='bs_ajaxJSDiv',parameters='',loadingText='Submitting...',url='switch.php'){
    /*Wrapper to upload a file or mulitple files.  Use php bs_fileInput() to create input.
        parameters are in key=value&key2=value2 format and will get passed along to php
    */
    let el=bs_getEl(inputID);
    let formData=bs_getFormData('',parameters);
    let files=el.files;
    if (files.length > 1){inputID+="[]";}//PHP multiple input processing needs array syntax for input name.  Be sure to append using that when needed.
    for (let i = 0; i < files.length; i++) {
        let file = files[i];
        formData.append(inputID, file);
    }
    formData.append('doWhat','bs_fileUploaded');
    bs_post(formData,destDiv,loadingText,url);
    el.value=null;//Reset input
}

async function bs_ajax( data, submitMethod, url, destDiv, loadingText, abortPrevious=true, reuseAbortController=false) {
    /*General function for async data access.
    data is a FormData object, use bs_getFormData() to create.
    submitMethod is *GET, POST, PUT, DELETE, etc.
    url is src url (switch.php)
    abortPrevious kills prior submission if not completed.
    reuseAbortController true to use existing controller, false to make new one.  This is to enable multiple concurrent gets that can all
    be aborted.  Pass false on first, then true on rest.
    */
    let signal=null;let postData=null;let responseData='';
    const div=bs_getEl(destDiv);

    //Package data for method
    if(submitMethod=='GET'){//All on url
        const params = new URLSearchParams(data);
        url+="?"+params;
    }else{//POST in body
        postData=data;
    }
    //Abort previous if needed
    if(abortPrevious){
        if(bs_fetchController){bs_fetchController.abort();}
    }
    //Show network activity and set placeholder text.  Do after aborting, so abort logic doesn't clear.
    bs_startNetworking(loadingText);

    //Set up the abort controller
    if(!reuseAbortController){bs_fetchController=new AbortController();}
    signal=bs_fetchController.signal;

    try{
      //Submit the request
      fetch(url, {
        method: submitMethod, // *GET, POST, PUT, DELETE, etc.
        cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
        signal: signal,
        body: postData//null on get, form data on post
      }).then(response=>response.text())
      .then(responseData=>{
            //insertAndExecute(destDiv,responseData);
            div.innerHTML=responseData;
            bs_executeScriptsFromText(responseData);
            bs_stopNetworking();
      }).catch(e=>{//I think this is only on abort, in which case we'll leave the existing loadingText (async timing made difficult to set)
            console.log(e.message,destDiv);
            bs_logFormData(data);
            bs_stopNetworking();
      });


      return true;
    }catch(e){//Should put this in a status div somewhere.
        console.log(e.message);
    }
}

//JS.  still trying to figure how to mimic jquery html().  I think insertAndExecute is similar
// Function to execute JavaScript code inside <script> tags from a text string.  Assumes caller/server have cleaned any user content.  This is intended for UI js.
function bs_executeScriptsFromText(text) {
    try{
      var parser = new DOMParser();
      var htmlDoc = parser.parseFromString(text, 'text/html');
      var scripts = htmlDoc.getElementsByTagName('script');
      for (var i = 0; i < scripts.length; i++) {
          eval(scripts[i].textContent); // Execute JavaScript code from <script> tags
      }
    }catch(e){
        console.log(e);
    }
}
function insertAndExecute(id, text)
  {
    domelement = document.getElementById(id);
    domelement.innerHTML = text;
    var scripts = [];

    ret = domelement.childNodes;
    for ( var i = 0; ret[i]; i++ ) {
      if ( scripts && nodeName( ret[i], "script" ) && (!ret[i].type || ret[i].type.toLowerCase() === "text/javascript") ) {
            scripts.push( ret[i].parentNode ? ret[i].parentNode.removeChild( ret[i] ) : ret[i] );
        }
    }

    for(script in scripts)
    {
      evalScript(scripts[script]);
    }
  }
  function nodeName( elem, name ) {
    return elem.nodeName && elem.nodeName.toUpperCase() === name.toUpperCase();
  }
  function evalScript( elem ) {
    data = ( elem.text || elem.textContent || elem.innerHTML || "" );

    var head = document.getElementsByTagName("head")[0] || document.documentElement,
    script = document.createElement("script");
    script.type = "text/javascript";
    script.appendChild( document.createTextNode( data ) );
    head.insertBefore( script, head.firstChild );
    head.removeChild( script );

    if ( elem.parentNode ) {
        elem.parentNode.removeChild( elem );
    }
  }



/*Network status*/
var bs_networkActivityCounter=0;
var bs_networkActivityLastTime=Date.now();
var bs_keepAliveCounter=0;
function bs_startNetworking(message='',isKeepAlive=false) {
    bs_networkActivityLastTime=Date.now();//Reset inactivity timer.
    bs_setHTML('bs_netStatusDiv',message);
    bs_networkActivityCounter++;
    if(!isKeepAlive){keepAliveCounter=0;}//Reset keepalive counter used to force a reload after a period, only when not the keep alive...
    if (bs_networkActivityCounter>0) {
        bs_show('#bs_networkingActivityDiv');
    }
}
function bs_stopNetworking() {
    bs_networkActivityCounter--;
    if (bs_networkActivityCounter<=0) {
        bs_hide('#bs_networkingActivityDiv');
        bs_setHTML('bs_netStatusDiv','&nbsp;');//space to keep sizing
        bs_networkActivityCounter=0;//Reset just in case went negative.
    }
}

