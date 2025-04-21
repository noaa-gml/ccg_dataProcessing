//General js for index page.
//i_ prefix is for index...
var asdf=false;
function i_loadList() {
    //Generic function to package any search form selections and pass to switch to handle.
    //Loads results into the adjustable height div.
    //See i_loadList in switch.php for details on how to use (form inputs required and options)

    var formData=$("#search_form").serialize();//Grab current filters

    //Clear content divs
    $("#adjHeightContentDiv").empty();
    $("#fixedHeightContentDiv").empty();

    //Send the request
    ajax_get("i_loadList",formData,"adjHeightContentDiv");

}
function i_getSummary() {
    //Loads a general summary dashboard widget
    ajax_get("i_getSummary","","adjHeightContentDiv");
}

function i_setCSVLinkHref(linkID,doWhat){
    //sets the link (id=linkID) href to include current selection filters.  utility function for downloadCSVLink2
    var formData=$('#search_form').serialize();//Grab current filters
    var _href='switch.php?doWhat='+doWhat+'&'+formData;
    console.log(_href);
    $('#'+linkID).attr('href',_href);
}

function hideFixedDiv(){
    changeFixedDiveHeight('0px');
    $("#fixedHeightContentDiv").hide();
}
function showFixedDiv(ht){//Pass as string '200px'
    $("#fixedHeightContentDiv").show();
    changeFixedDiveHeight(ht);
}

//Example function
function loadExDetails(event_num) {
    //Loads passed event num in fixed height div (for example) using ajax handlers..
    //Note loadExDetails must be programmed into you switch.php for this to work.
    ajax_get("loadExDetails","event_num="+event_num,'fixedHeightContentDiv');
}


function formatNumber(num){
    return num.toLocaleString("en-US");
}
function parseFormattedFloat(num){
    var t=num+"";//toString(num);
    if(t=='')return 0;
    return parseFloat(t.replace(/[^\d\.]/g,''));
}
function cleanNumber(id){
    //returns cleaned,formatted num for input id
    var i=$('#'+id);//console.log(i);
    var val=i.val();//console.log(val);
    i.val(formatNumber(parseFormattedFloat(val)));
}

//Formatting/JQuery UI interactions.
//Not sure where to put this.. should probably have own js for stuff like this.
function setJQueryUIProgressBarColor(id,color){
    //color is a css color like 'red'
    $('#'+id).find('.ui-progressbar-value').css('background',color );
}


//Other js utils
function isChecked(id){//Just because I have to look it up every time.
    return $('#'+id).prop( "checked" );
}
