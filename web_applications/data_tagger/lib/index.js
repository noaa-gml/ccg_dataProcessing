$(document).ready(function() {
    //All JS that needs to run after the document has loaded.

    //When an id is entered, disable the corresponding filters and clear other id fields
    $("#ev_event_num").change(function(event){
         if ($(this).val()) {//Blank the data id num if there.
            $("#d_data_num").val("");
            $("#ev_flask_id").val("");
         }
         setState();     
    });
    $("#d_data_num").change(function(event){
         if ($(this).val()) {//Blank the ev id num if there.
            $("#ev_event_num").val("");
            $("#ev_flask_id").val("");
         }
         setState();
    });
    $("#ev_flask_id").change(function(event){
         if ($(this).val()) {
            $("#ev_event_num").val("");
            $("#d_data_num").val("");
         }
         setState();
    });
    
        //New layout js
    $("#search_accordion").accordion({
        heightStyle: "content",
        active:1 //event box
    });
    
    //Functions to update the list in a selectmenu drop down.
    //filter popup buttons
    //Vers 1.11 $(".dynamic_selectmenu").selectmenu();
    $(".dynamic_selectmenu_filter").click(function( event ) {
        event.preventDefault();
        var id=event.target.id;
        id=id.substring(0,id.length-7);
        updateSelectMenu(id,1);
    });
    
    //Search function button click and enter key binding.
    $("#searchButton").click(function(event){
       event.preventDefault();
       //Put actual search call in a timeout so that any other change logic (like site on change event) have a chance to run through
       setTimeout("doSearch();",200);
    });
    $("#resetButton").click(function(event){
        event.preventDefault();
        resetSearchFields();
    });
    $("#resetButton_aircraft").click(function(event){
        event.preventDefault();
        resetSearchFields();
    });
    $("#submitCriteriaEditButton").click(function(event){
        event.preventDefault();
        doRangeChangeSubmit();
    });
    $("#cancelCriteriaSubmitButton").click(function(event){
        event.preventDefault();
        setCriteria(cancelEditCriteriaSelection_oldCriteria);
        setMode(0);//Reset mode to search mode.
        clearDataAreas();
        $("#tagList").html("<div align='center'><br><br><br>Click search button to reload your previous selection</div>");
        
    });
    
    //If any filter is changed, reset the results div
    //This is to ensure that the results always match the current filters.
    $(".search_field").change(function(){
        clearDataAreas();
    });
    
    setDateDefaults();
    
    //Set the initial state if variables came in from the browser cache
    setState();
    
    //Set filter and hook into change events to update as needed.
    setFilterDescription();
    $(".search_field").change(function(event){
        setFilterDescription();
    });
    
    //Set some globals and hide/show elements based on the 'mode' we're in.
    setMode(0);//Default search
    
    setwindowHeight();
    
    //Set a keep alive to get around annoying issue with self signed certs
    keepAlive();
});

function resetSearchFields(){
    clearFields("ev");
    clearFields("d");
    clearFields("id");
    clearFields("tag");
    clearFields("at");//aircraft tagging
    //setDateDefaults();
    //setEvStartDateDefault();
    setEvEndDateDefault();//We want to try to always have an end date in here for criteria logic.
    setState();
    setFilterDescription();

}
function clearFields(type) {
    //type== ev, d, id, tag or at (aircraft tagging)
    //NOTE! if adding new field, make sure to add to the rangeCriteriaFuncs.js function setCriteria()!
    //If adding a select, it must be cleared below
     
    //$("."+type+"_field :input:not(:checkbox)").val("");//Clear all of the type that we can easily.
    $("."+type+"_field").val("");
    /*Note that checkboxes are a little weird.  Setting val("") just changes what gets sent when checked, it doesn't
    uncheck it.  We set the php side to treat presence (checked) of checkbox var as true and so don't care what the value is.*/
    $(":checkbox."+type+"_field").prop('checked',false);
    
    switch (type) {//Get all the selects that are more complicated
        case "ev":
            $("#ev_project_num").val([]);
            $("#ev_strategy_num").val([]);
            $("#ev_sTimewindow").val([]);
            $("#ev_eTimewindow").val([]);
            updateSelectMenu("ev_project_num",0);
            updateSelectMenu("ev_strategy_num",0);
            
        case "d":
            $("#d_program_num").val([]);
            $("#d_parameter_num").val([]);
            $("#d_inst").val([]);
            updateSelectMenu("d_program_num",0);
            updateSelectMenu("d_parameter_num",0);
            updateSelectMenu("d_inst",0);
            break;
        case "id":
            setState();
            break;
        case "tag":
        //pia.  changed to select menu (like tag edit) to better handle long text, but had to add handlers to clear
            $("#d_tag_num").val();
            $("#ev_tag_num").val();
            $("#d_tag_num")[0].selectedIndex = 0;
            $("#d_tag_num").selectmenu("refresh");
            $("#ev_tag_num")[0].selectedIndex = 0;
            $("#ev_tag_num").selectmenu("refresh");
            //updateSelectMenu("d_tag_num");
            //updateSelectMenu("ev_tag_num");
            break;
        case "at":
            //updateSelectMenu("at_episodes");
            break;
    }
    clearDataAreas();
    setFilterDescription();

}


function setAutomcompleteVal(id,key) {
    //Set the val and key for an autocomplete.  id is the input id, key is the primary key (key element in the data array)
    if (key) {
        var arr=eval(id+'_data');
        if (arr) {
            var display=getValForAutocompleteKey(arr,key);
            if(display){
                $("#"+id).val(key);//sets the actual hidden datafield.
                $("#"+id+"_display").val(display);//Sets the autocomplete value
                //$("#"+id+"_display").siblings('.ui-combobox').find('.ui-autocomplete-input').val(display);//sets the display
            }            
        }
    }
}
function getValForAutocompleteKey(array,key) {
    /*get the display 'val' for passed key in an autocomplete data array
     */
    
    var result=$.grep(array,function(e){return e.key==key;});
    if (result.length==0) {
        return false;
    }else return result[0]['value'];
}
var okToClearDataArea=true;//Global so that we can turn off the auto clear when data areas aren't showing results
function clearDataAreas() {
    if (okToClearDataArea) {//Only clear when there's not something sticky (like range edit) there.    
        //Clear any search results/tag list data and stop any in progress queries.
        stopAjaxQuery(search_ajax_request);//Stop any in progress searches
        stopAjaxQuery(tag_ajax_request);//.. and tag list selects (which could be longer).
        //stopAjaxQuery(selectMenuAjaxRequest);Not sure this should abort
        $("#searchResults").empty();
        $("#tagList").empty();
        setStatusMessage("",0)
    }

}
function setDateDefaults(){
    //$("#ev_eDate").datepicker("setDate","-1d");
    //$("#ev_sDate").datepicker("setDate","-3m");
}
function setMode(mode){
    /*Set various switches and visibilites based on overall mode.
     *0 default search mode.
     *1 range criteria edit mode.
     */
    if (mode==0) {
        okToClearDataArea=true;
        $("#submitCriteriaEditButton").hide();
        $("#cancelCriteriaSubmitButton").hide();
        $("#searchButton").show();
        $("#resetButton").show();
        //$("#searchButton").prop('disabled',false);
        //$("#resetButton").prop('disabled',false);
    }else if(mode==1){
        okToClearDataArea=false;
        $("#submitCriteriaEditButton").show();
        $("#cancelCriteriaSubmitButton").show();
        $("#searchButton").hide();
        $("#resetButton").hide();
        //$("#searchButton").prop('disabled',true);
        //$("#resetButton").prop('disabled',true);
    }
}
function setState(){
    //This sets the state of the various controls based on whether a unique id was entered
    var ev_disabled=false;
    var d_disabled=false;
    if($("#ev_event_num").val()){
        ev_disabled=true;
    }else if($("#d_data_num").val()){
        ev_disabled=true;
        d_disabled=true;
    }
    $(".d_field").prop("disabled",d_disabled);
    $("#d_plot").prop("disabled",d_disabled);
    $(".ev_field").prop("disabled",ev_disabled);
    $("#ev_tag_num").prop("disabled",ev_disabled);
    $("#d_tag_num").prop("disabled",d_disabled);
}
function setFilterDescription() {

    //This sets the readable description of the currently selected filters.  Only count enabled fields with a name attr set (ones that will get included in form data).
    var desc="";var id_val=0; var ev_val=0; var d_val=0;var tag_val=0;
    $(".id_field").each(function(){
        if ($(this).val() && !($(this).prop("disabled")) && $(this).attr("name")) {
            id_val++;
        }
    });
    $(".d_field").each(function(){
        //console.log(this.id+": "+$(this).val());
        if ($(this).val() && $(this).val() != null && $(this).val() != '' && !($(this).prop("disabled")) && $(this).attr("name") && !($(this).is(':checkbox'))) {
            d_val++;
        }else if($(this).is(':checkbox') && $(this).prop("checked")){//The 'val' isn't relevant, we want to know if  it's checked or not.
            d_val++;
        }
    });
    $(".ev_field").each(function(){

        if ($(this).val() && $(this).val() != null && $(this).val() != '' && !($(this).prop("disabled")) && $(this).attr("name") && !$(this).is(':checkbox')) {
            ev_val++;
        }else if($(this).is(':checkbox') && $(this).prop("checked")){
            ev_val++;
        }
    });
    $(".tag_field").each(function(){
        if ($(this).val() && $(this).val() != null && $(this).val() != '' && !($(this).prop("disabled")) && $(this).attr("name") && !($(this).is(':checkbox'))) {
            tag_val++;
        }else if($(this).attr("type")=='checkbox' && $(this).prop("checked")){
            tag_val++;
        }
    });
    $("#id_filter_desc").html(filterDesc(id_val));
    $("#ev_filter_desc").html(filterDesc(ev_val));
    $("#d_filter_desc").html(filterDesc(d_val));
    $("#tag_filter_desc").html(filterDesc(tag_val));

}
function filterDesc(num) {
    var s="";
    if (num>0){
        s="("+num.toString()+" filter";
        if (num>1)s+="s";
        s+=")";
        
    }
    return s
}


function cancel_tagEdit(range_num,event_num,data_num){
    $('#tagEditFormDiv').empty();
    //Reload the details if applicable.
    range_num=typeof range_num !== 'undefined' ? range_num:'';
    event_num=typeof event_num !== 'undefined' ? event_num:'';
    data_num=typeof data_num !== 'undefined' ? data_num:'';
    if (range_num!='') {
        tagRangeSelected(range_num);
    }else getTagList(event_num,data_num);
}

function clearDiv(divID){
    //This exists so can be called on delay like setTimeout(clearDiv(myDivID),2000);
    $('#'+divID).empty();
}
var clearTagEditFormTimeout;//Global so we can cancel if needed.
function clearTagEditForm(range_num) {
    //Clear the submit message and then reselect the row.
    clearTagEditFormTimeout=setTimeout(function(){
        $('#tagEditFormDiv').empty();
        if(range_num!="") tagRangeSelected(range_num);
        //else getTagList('','');
    },2*1000);
}



//Bind logic to the window resize event to set our content div correctly.
$(window).resize(function(){
    setwindowHeight();
    //If the searchResultsPlot exists, resize it to match the new space available.
    if(typeof searchResultsPlotVar !== 'undefined'){
        searchResultsPlotVar.resize();
        searchResultsPlotVar.setupGrid();
        searchResultsPlotVar.draw();
    }
});
function setwindowHeight() {
    //Figure out some fixed heights so auto scrolling will work.  What a pia.
    //Set the content div to be the remaining window space.
    //var height=$(window).innerheight()-$(".header").;
    var wh=$(window).innerHeight();//window height
    var hh=$(".header").outerHeight();//header height
    var fh=$(".footer").outerHeight();//footer height
    var bh=$(".content").outerHeight()-$(".content").height();//border height
    var buttonH=$("#searchBtnDiv").outerHeight();//button height for search area
    
    var ch=wh-hh-fh-bh-30-buttonH;//The 30 is padding.. not sure why needed, but it makes it all fit.
    $(".content").height(ch);//Main content area. Make this the remaining height of window minus fixed height stuff (header,footer,buttons & border).
    var chh=$("#content_table_header").height();//Find height of the content header
    $("#search_container").height(ch-chh);//set search td div to it's max height.  This allows a scroll to be used when needed.
    
    //Now get the results area.  There is a fixed size div at top and the slop goes to the results table.
    var th=$("#tagList").height();
    $("#searchResults").height(ch-chh-th+buttonH-10);//No buttons on this side.. 10 is slop
    
    //Do the width too.
    var ww=$(window).innerWidth();
    $("#searchResults").width(ww-300);//-search area + some margin.
    $("#tagList").width(ww-300);//-search area + some margin.
    
}

function setSampleWindowCheckBox(){
    //Sets whether the sample  window checkbox is enabled or not.
    if($("#ev_sTimewindow").val() && $("#ev_eTimewindow").val())$("#ev_notTimewindow").prop("disabled",false);
    else{
        $("#ev_notTimewindow").prop("checked",false);
        $("#ev_notTimewindow").prop("disabled",true);
    }
}



