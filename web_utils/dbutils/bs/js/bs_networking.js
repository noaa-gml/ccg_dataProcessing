DEPRECATED.. NOTES, some ideas that were tried.


//mdn examples
// Function to fetch JSON using PHP get
const getJSON = async () => {
  // Generate the Response object
  const response = await fetch("getJSON.php");
  if (response.ok) {
    // Get JSON value from the response body
    return response.json();
  }
  throw new Error("*** PHP file not found");
};

// Call the function and output value or error message to console
getJSON()
  .then((result) => console.log(result))
  .catch((error) => console.error(error));
  
// Example POST method implementation:
async function postData(url = "", data = {}) {
  // Default options are marked with *
  const response = await fetch(url, {
    method: "POST", // *GET, POST, PUT, DELETE, etc.
    mode: "cors", // no-cors, *cors, same-origin
    cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
    credentials: "same-origin", // include, *same-origin, omit
    headers: {
      "Content-Type": "application/json",
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    redirect: "follow", // manual, *follow, error
    referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
    body: JSON.stringify(data), // body data type must match "Content-Type" header
  });
  return response.json(); // parses JSON response into native JavaScript objects
}

postData("https://example.com/answer", { answer: 42 }).then((data) => {
  console.log(data); // JSON data parsed by `data.json()` call
});


//###
const send = document.querySelector("#send");

send.addEventListener("click", async () => {
  const userInfo = document.querySelector("#user-info");
  const formData = new FormData(userInfo);
  formData.append("serialnumber", 12345);

  const response = await fetch("http://example.org/post", {
    method: "POST",
    body: formData,
  });
  console.log(await response.json());
});

//####abort
let controller;
const url = "video.mp4";

const downloadBtn = document.querySelector(".download");
const abortBtn = document.querySelector(".abort");

downloadBtn.addEventListener("click", fetchVideo);

abortBtn.addEventListener("click", () => {
  if (controller) {
    controller.abort();
    console.log("Download aborted");
  }
});

function fetchVideo() {
  controller = new AbortController();
  const signal = controller.signal;
  fetch(url, { signal })
    .then((response) => {
      console.log("Download complete", response);
    })
    .catch((err) => {
      console.error(`Download error: ${err.message}`);
    });
}


//####chatgpt's take:
// Function to perform a GET request with parameters
function fetchGet(url, parameters, callback) {
  fetch(url + '?' + parameters)
    .then(response => response.text())
    .then(data => {
      executeScriptsFromText(data); // Execute scripts from response
      callback(data); // Call the callback function with the response
    })
    .catch(error => console.error('Error:', error));
}

// Function to perform a POST request with parameters
function fetchPost(url, parameters, callback) {
  fetch(url, {
    method: 'POST',
    body: parameters,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
    .then(response => response.text())
    .then(data => {
      executeScriptsFromText(data); // Execute scripts from response
      callback(data); // Call the callback function with the response
    })
    .catch(error => console.error('Error:', error));
}

// Function to serialize a Bootstrap 5 form into a query string
function serializeBootstrapForm(form) {
  var formData = new FormData(form);
  var serialized = [];
  for (var pair of formData.entries()) {
    serialized.push(encodeURIComponent(pair[0]) + '=' + encodeURIComponent(pair[1]));
  }
  return serialized.join('&');
}



// Example usage:

// GET request with parameters
// var parameters = 'param1=value1&param2=value2';
// fetchGet('https://example.com/data', parameters, function(response) {
//   console.log('Response:', response);
// });

// POST request with parameters
// var parameters = 'param1=value1&param2=value2';
// fetchPost('https://example.com/data', parameters, function(response) {
//   console.log('Response:', response);
// });

// Serialize Bootstrap form and make a POST request
// var myForm = document.getElementById('myForm'); // Assuming your form has an id of "myForm"
// var serializedForm = serializeBootstrapForm(myForm);
// fetchPost('https://example.com/data', serializedForm, function(response) {
//   console.log('Response:', response);
// });



old/restarted

//Functions to support networking/ajax calls

var bs_ajaxSwitchUrl="switch.php";
var bs_ajaxHandle=false; //Can be used generically by callers.

function bs_ajax(doWhat,params,destdiv,isPost,loadingText) {
    /*
     *General function to call switch.php with params and put results in destdiv.
     *dowhat is a parameter expected by your switch.php to tell it what to do.
      params are key=val[&key2=val2[...]] that can be parsed by httpd and used by switch to return data.
      destdiv is where to put whatever is returned by switch.php. (note doesn't have to be an actual div, just a valid container id)
        if not passed then bs_ajaxJSDiv is used (included on standard template) for js only (no content).
      isPost =1 for post, else get.  defaults get.
      loadingText is text to be displayed while loading.
      
      You can get form data like this:
      ####!!var formData=$("#search_form").serialize();//Grab current filters
    */
    destdiv=typeof destdiv !== 'undefined' ? destdiv:'bs_ajaxJSDiv';//default js only dest
    loadingText=typeof loadingText !== 'undefined' ? loadingText:'Loading...'; 
    
    if (bs_submitNotInProgress()) {
        bs_stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        bs_startNetworking(destdiv,loadingText);
        // Create a new XMLHttpRequest object
        bs_ajaxHandle = new XMLHttpRequest();

        // Configure the request
        bs_ajaxHandle.open('GET', url, true); // true for asynchronous request

        // Set up a function to handle the response
        bs_ajaxHandle.onload = function() {
            if (bs_ajaxHandle.status >= 200 && bs_ajaxHandle.status < 300) {
                // Request was successful
                var responseData = bs_ajaxHandle.responseText;//JSON.parse(bs_ajaxHandle.responseText);
                // Get reference to the destination div
                var destinationDiv = document.getElementById(destdiv);
                // Put the returned content into the destination div
                destinationDiv.innerHTML = responseData;
                // Execute any returned JS.  
                var scripts = destinationDiv.getElementsByTagName('script');
                for (var i = 0; i < scripts.length; i++) {
                    eval(scripts[i].innerHTML);//Dangerous if untrusted, but these are expected to be ui js blocks.  Caller/Server response must ensure any user content has been filtered.
                }
                bs_stopNetworking();
            } else {
              // Request failed
                status=bs_ajaxHandle.status;
                txt=bs_ajaxHandle.responseText
                if (status!="abort" && data.responseText !='') {
                    if(status==403 || data.responseText.includes("403 Forbidden")){
                        alert("Your session has timed out.  Page refresh required.");
                        window.location.reload();
                    }else{
                        alert("Unexpected return status for GET:"+status+"\nresponse.Text:"+data.responseText+"\nError:"+err);                              
                    }
                }
                bs_submitInProgress=false;
              console.error('Request failed with status:', bs_ajaxHandle.status);
            }
        };

          // Set up a function to handle errors
        bs_dfltAjaxHandle.onerror = function() {
            console.error('Request failed');
        };

        // Send the request
        bs_dfltAjaxHandle.send();
    }
}

var bs_networkActivityCounter=0;
var bs_networkActivityLastTime=Date.now();
var bs_keepAliveCounter=0;

function bs_startNetworking(targetDiv,message) {
    targetDiv=typeof targetDiv !== 'undefined' ? targetDiv:'';
    message=typeof message !== 'undefined' ? message:"";
    bs_networkActivityLastTime=Date.now();//Reset inactivity timer.
    if (targetDiv!="") {
        //Get the current height/width so we can put a place holder in to preserve layout.
        var div=document.getElementById(targetDiv);
        var height=div.innerHeight();
        var width=div.innerWidth();
        div.innerHTML("<div style='height:"+height+"px;width:"+width+"px;'>"+message+"</div>");
        
    }
    bs_networkActivityCounter++;
    if(targetDiv!='statusDiv'){keepAliveCounter=0;}//Reset keepalive counter used to force a reload after a period, only when not the keep alive...
    if (bs_networkActivityCounter>0) {
        var div=document.getElementById('bs_networkingActivityDiv');
        div.classList.remove('d-none');
    }
}
function bs_stopNetworking() {
    bs_networkActivityCounter--;
    if (bs_networkActivityCounter<=0) {
        var div=document.getElementById('bs_networkingActivityDiv');
        div.classList.add('d-none');
        bs_networkActivityCounter=0;//Reset just in case went negative.
    }
}
function bs_stopAjaxQuery(handler) {
    /*This will cancel any in progress ajax requests for the passed request handler.*/
    if(handler){//If one is still going, abort it.
        handler.abort();
        handler=false;
        bs_stopNetworking();
    }
}
function bs_ajaxGetOLD(doWhat,params,destdiv,ajaxhandle,loadingText) {
    /*
     *General function to call switch.php with params and put results in destdiv.
     *dowhat is a parameter expected by your switch.php to tell it what to do.
      params are key=val[&key2=val2[...]] that can be parsed by httpd and used by switch to return data.
      destdiv is where to put whatever is returned by switch.php. (note doesn't have to be an actual div, just a valid container id)
        if not passed then bs_ajaxJSDiv is used (included on standard template) for js only (no content).
      ajax handle must be a unique (for destdiv) global js var that we can use to stop prior calls for this same query(so they don't stack up).
      If not passed, then dfltAjaxHandle is used.
    
      You can get form data like this:
      var formData=$("#search_form").serialize();//Grab current filters
      */
    ajaxhandle=typeof ajaxhandle !== 'undefined' ? ajaxhandle:bs_dfltAjaxHandle;
    destdiv=typeof destdiv !== 'undefined' ? destdiv:'bs_ajaxJSDiv';//default js only dest
    loadingText=typeof loadingText !== 'undefined' ? loadingText:'Loading...'; 

    var xhr = new XMLHttpRequest();

    // Configure the request
    xhr.open('GET', url, true); // true for asynchronous request

    if (bs_submitNotInProgress()) {
        bs_stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        bs_startNetworking(destdiv,loadingText);
        //alert('doWhat='+doWhat+'&'+params);
        ajaxhandle=$.ajax({
            url:bs_ajaxSwitchUrl,
            type:'get',
            data: 'doWhat='+doWhat+'&'+params,
            success:function(data){
                $("#"+destdiv).html(data);
                bs_stopNetworking();
            },  
                error: function(data,status,err) {
                        if (status!="abort" && data.responseText !='') {
                            if(status==403 || data.responseText.includes("403 Forbidden")){
                                alert("Your session has timed out.  Page refresh required.");
                                window.location.reload();
                            }else{
                                alert("Unexpected return status for GET:"+status+"\nresponse.Text:"+data.responseText+"\nError:"+err);                              
                            }
                        }
                        bs_submitInProgress=false;
                }    
        });
    }
}

function bs_ajaxPostOLD(doWhat,params,destdiv,ajaxhandle,loadingText) {
    /*General function to call switch.php with a post of params and put result into dest div
      use $(...).serialize() to package a form
      see params above for comments.
      */
    
        ajaxhandle=typeof ajaxhandle !== 'undefined' ? ajaxhandle:bs_dfltAjaxHandle;
        destdiv=typeof destdiv !== 'undefined' ? destdiv:'bs_ajaxJSDiv';//default js only dest
        loadingText=typeof loadingText !== 'undefined' ? loadingText:'Submitting...';
        bs_submitInProgress=true;
        
        bs_stopAjaxQuery(ajaxhandle);//Stop any in progress tl queries        
        bs_startNetworking(destdiv,loadingText);
        ajaxhandle=$.ajax({
                type:'POST',
                url:bs_ajaxSwitchUrl,
                data: 'doWhat='+doWhat+'&'+params,
                success:function(data,stringStatus,obj){
                        $("#"+destdiv).html(data);
                        bs_stopNetworking();
                        bs_submitInProgress=false;
                },  
                error: function(data,status,err) {
                        if(status==403 || data.responseText.includes("403 Forbidden")){
                            alert("Your session has timed out.  Page refresh required.");
                            window.location.reload();
                        }else{
                            alert("Unexpected return status for GET:"+status+"\nresponse.Text:"+data.responseText+"\nError:"+err);                           
                        }
                        bs_submitInProgress=false;
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




