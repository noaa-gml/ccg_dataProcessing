//General js for index page.
//i_ prefix is for index...
var i_ajax_req;
function i_loadList() {
    //Generic function to package any search form selections and pass to switch to handle.
    //Loads results into the adjustable height div.
    //See i_loadList in switch.php for details on how to use (form inputs required and options)
    
    var formData=$("#search_form").serialize();//Grab current filters
    
    //Clear content divs
    $("#adjHeightContentDiv").empty();
    $("#fixedHeightContentDiv").empty();
        
    //Send the request
    ajax_get("i_loadList",formData,"adjHeightContentDiv",i_ajax_req);
    //console.log("i_loadList called with formData:"+formData);
}
function i_getSummary() {
    //Loads a general summary dashboard widget
    ajax_get("i_getSummary","","adjHeightContentDiv",i_ajax_req);
}

