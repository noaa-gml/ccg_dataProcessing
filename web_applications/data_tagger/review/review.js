//Various functions to support the aircraft tag review logic
var air_ajaxhandle;
var air_tagRangeList=[];
var air_currentRange=-1;var air_nextRange=-1;var air_prevRange=-1;//To track array indexes
var air_currentRangeData;var air_nextRangeData; var air_prevRangeData;//Bins for nav plot data.

//Navigation
function air_siteSelected() {
    //Load site data
    //We had some weird issues with the index counter getting out of sync/skipping numbers when switching sites.  I think it may be due to lag when ajax is slow.
    //Click first site, hit next, click 2nd site, click first site, x of total now off.
    var formData=$("#air_selectForm").serialize();//Grab current selection
    ajax_get("air_getNavWidget",formData,"navWidgetDiv",air_ajaxhandle);
}
function air_reloadCurrentRange() {
    //Reloads the current range
    var i=air_currentRange;//Save off the current index
    air_currentRange=-1;//Reset current index pointer
    air_currentRangeData=false;
    //Reset prev controller too.
    air_prevRange=-1;
    air_prevRangeData=false;
    //And the next
    air_nextRange=-1;
    air_nextRangeData=false;
    //Load this into next.  That should force it to load into current after.  We have to clear all to reflect new data entered.
    air_fetchNextRange(i);
}
function air_loadNextRange() {
    //Loads the next range in array
    if (air_nextRange<0) {//Note air_nextRange,air_prevRange and air_currentRange are all indexes into the air_tagRangeList array
        //Need to load the first one.
        air_fetchNextRange(0);
    }else{
        //Save current into previous
        air_prevRange=air_currentRange;
        air_prevRangeData=air_currentRangeData;
        $("#air_prevBtn").prop("disabled",(air_prevRange<0));//Disable btn if no data for it to load yet.

        //Copy the next into current.
        air_currentRange=air_nextRange;
        air_currentRangeData=air_nextRangeData;

        //Load data
        air_loadCurrentRange();

        //Pre-fetch the next one.
        air_fetchNextRange(air_currentRange+1);
    }

}
function air_loadCurrentRange() {
    //Loads data/plots for currently selected range.
    if (air_currentRange>=0) {
        var a=air_tagRangeList[air_currentRange];

        //Set the display text
        //$('#currentRangeDisplayDiv').html(a['display_name']);//<tr><td colspan='2'><div id='currentRangeDisplayDiv' style='border:thin outset grey;text-align:center;'></div></td>

        $('#listCounter').html("("+(air_currentRange+1)+" of "+air_tagRangeList.length+")");

        //Load the event area
        air_loadEventData(a['event_num'],a['range_num']);

        //And then plots.
        air_loadPlotData(air_currentRangeData);

    }else{
        $('#currentEventDisplayDiv').html('');
        $('#adjHeightContentDiv').html('');
    }
}
function air_loadPrevRange() {
    //Loads previous range
    if (air_prevRange>=0) {
        //Move current to the 'next'
        air_nextRange=air_currentRange;
        air_nextRangeData=air_currentRangeData;

        //Move prev to current.
        air_currentRange=air_prevRange;
        air_currentRangeData=air_prevRangeData;

        //Reset prev controller (we only keep 1 history)
        air_prevRange=-1;
        air_prevRangeData=false;

        //Load data
        air_loadCurrentRange();

        //Disable the prev btn as we only keep 1 history.
        $("#air_prevBtn").prop("disabled",true);
    }
}
function air_fetchNextRange(range_index) {
    //Loads passed index into the next controller.
    if (air_tagRangeList.length>range_index) {//Index is 0 based, length is num elements
        //fetch the range info array
        var a=air_tagRangeList[range_index];
        var range_num=a['range_num'];
        var formData=$("#air_selectForm").serialize();//Current options
        //console.log(formData);
        ajax_get("air_fetchNextRange",formData+"&range_num="+range_num+"&range_index="+range_index,"navWidgetJSDiv",air_ajaxhandle);
        $('#nextBtnTxt').html("Pre-fetching");
    }
    $("#air_nextBtn").prop("disabled",true);//Default disabled until data is loaded.
}
function air_setNextRange(range_index,data) {
    //Sets the next control with passed data.
    $('#nextBtnTxt').html("");
    if (range_index>=0 && data) {
        air_nextRange=range_index;
        air_nextRangeData=data;
        if (air_currentRange<0) {
            //Load into current if none there already (initial).
            air_loadNextRange();
        }else{
            $("#air_nextBtn").prop("disabled",false);//Enable the button
        }
    }else{alert("Error loading next range");}
}

//Content Loaders
function air_loadEventData(event_num,range_num) {
    //Load event data for selected event/range.
    ajax_get("air_loadEventTagDisplay","event_num="+event_num+"&range_num="+range_num,"currentEventDisplayDiv",air_ajaxhandle);
}
function air_loadPlotData(data) {
    //Loads passed plot data.
    $('#valuesPlots').html('');
    $('#profilesPlots').html('');
    showValuesPlots();
    sp2_createPlots(data,'valuesPlots');
    //$('#adjHeightContentDiv').html(data);//testing.. this will be the plot loader
}
function showValuesPlots() {
    //Set divs to display values plots
    $('#valuesPlots').show();
    $('#profilesPlots').hide();
}
function showProfilesPlots(event_num) {
    //Loads profiles and shows divs appropriately.
    $('#valuesPlots').hide();
    $('#profilesPlots').show();
    ajax_get('air_profilePlots',"event_num="+event_num,'profilesPlots',air_ajaxhandle);
}

//Submit
function air_submitTagEdit() {
    //Submit the current tag range form.
    var formData=$("#tagEditForm").serialize();//Grab current form
    ajax_post('air_submitTagEdit',formData,'currentEventDisplayDiv',air_ajaxhandle);
}

function air_submitTagEdit2() {//From popup, we put results back in form.
    //Submit the current tag range form.
    var formData=$("#tagEditForm2").serialize();//Grab current form
    ajax_post('air_submitTagEdit2',formData,'rev_rangeEditDiv2',air_ajaxhandle);
}
function air_submitSuccesHandler() {
    //Handler that gets called after successfully
    var mssg="<br><br><br><div class='title3'>Saved.</div>";
    $("#currentEventDisplayDiv").html(mssg);
    setTimeout(function(){air_loadNextRange()},1000);//reload after 2 seconds.
}
function air_submitFailHandler(mssg) {
    //Called on submit fail.
    $("#currentEventDisplayDiv").html(mssg);//Display whatever was returned.
    setTimeout(function(){air_loadCurrentRange()},2000);//reload after 2 seconds.
}
function air_submitSuccesHandler2(mssg,event_num,data_num) {
    //Handler that gets called after successfully submitting add from popup form
    //console.log(event_num);console.log(mssg);console.log(data_num);
    setTimeout(function(){//Let current execution complete before firing off next get request.
         ajax_get("air_loadEventData","event_num="+event_num+"&data_num="+data_num,"tagEditForm2_eventData");
         air_reloadCurrentRange();
    },100);

}

function air_submitFailHandler2(mssg) {
    //Called on submit fail.
    $("#rev_rangeEditDiv2").html(mssg);//Display whatever was returned.

}



//Click handler
function air_plotClickHandler(num) {
    ajax_get('air_loadEventDataPopup','data_num='+num,'plotsJSDiv',air_ajaxhandle);
}
function pv_spPlotOnClick(num){
    ajax_get('pv_spPlotOnClick','data_num='+num,'sp3_plotsJSDiv');
}


//SinglePlots2 JS functions
function sp2_createPlots(data,destDivID) {
    //Creates 1 or more linked single plots.
    //Expects an array of plot data objects
        //each obj has:
            //data[i]['series'] ;as returned by sp_getSinglePlotSeriesJSON() php method.
            //(optional)data[i]['onClickMethod'] ;text of js method to call with num parameter (see above method).  just the text, no parens.
    //DestDivID is where to load plots.
    if (data) {
        //Figure out some current dimensions
        var width=$('#'+destDivID).innerWidth();
        var displayWidth=100;
        var plotWidth=width-displayWidth-30;
        var plotHeight=200;

        //Description--just grab the first one.
        var description=data[0]["plotsTitle"];

        //Create wrapper html
        var html="<table border='0' class='sp2_plotTable'><tr><td align='center' class='title4'>"+description+"</td><td></td></tr>";
        var divID='sp2_plot_';
        //Loop through data array and create plot divs for each obj.
        //We'll do 2 loops, creating the dom objects first, then the plots.  Probably could do in one step, but this seems cleaner.
        for (var i=0,len=data.length;i<len;i++) {
            var id=divID+i.toString();
            html+="<tr><td><div class='sp2_plotDiv' id='"+id+"' style='width:"+plotWidth+"px;height:"+plotHeight+"px;'></div></td><td valign='center'><table><tr><td><div style='height:180px' id='"+id+"_yrangeSlider'></div></td><td><div style='float:right;' id='"+id+"_displayDiv' style='width:"+displayWidth+"px;'></div></td></tr></table></td></tr>";
        }
        html+="</table>";
        $("#"+destDivID).html(html);//Set into the dom

        //Now the actual plots.
        for (var i=0,len=data.length;i<len;i++) {
            var id=divID+i.toString();
            sp2_createPlot(data[i],id,i);
        }
    }else{$("#"+destDivID).html("No plot data available");}
}
function sp2_createPlot(data,divID,index) {
    //Called by above, creates a single plot.
    //Options object is defaulted below.. Caller can pass in overrides for some (clickable, lines...) in the series obj.
    //Data['series'] contains all the series data for this plot
    //divID is id of destination div.  Assumes existence of a divID_displayDiv for on hover text
    //Could return plot var if needed.

    var options={
        xaxis:{mode:"time",timeformat: "%m/%y",show:true},
        yaxis:{show:true,labelWidth:30},
        grid:{clickable:true,hoverable:true,margin:0,borderWidth:0},
        series: {
            lines: { show: true,lineWidth:.5 },
            points: { show: true, fill: true,fillColor:0 },
            color: index
        },
        //selection:{mode:'x'},
        //zoom: {interactive: true},pan: {interactive: false}
    };
    var series=data['series'];
    var plotVar=$.plot(("#"+divID),series,options);

    //Bind the hover function
    $("#"+divID).bind("plothover",function(event,pos,item){
        //var desc=(data.hasOwnProperty('hoverDescription'))?data['hoverDescription']:'';
        $("#"+divID+"_displayDiv").html('');//Clear out or set to passed msg
        if(item){
            var time=new Date(item.datapoint[0]);
            var o=$.datepicker.formatDate('yy-m-d',time);
            o="<div style='border:1px silver solid;'><span>"+o+"</span><br><span style='font-weight:600;'> "+item.datapoint[1]+"</span></div>";
            $('#'+divID+'_displayDiv').html(o);
        }
    });

    //Bind onclick function too if caller data obj has an onClickMethod;
    //This assumes that a 'num' column was selected in datasets.
    //We'll bind a function to this plot to extract the num and pass off to handler.
    //Assumes data series has 3rd element data_num (see sp_getSinglePlotSeriesJSON)
    if (data.hasOwnProperty('onClickMethod')) {
        $("#"+divID).bind("plotclick",function (event,pos,item){
            if(item){
                var s=data['onClickMethod']+"("+item.series.data[item.dataIndex][2]+")";
                eval(s);
            }
        });
    }


    //Set up the slider widget to adjust the yaxis.
    var oMin=plotVar.getAxes().yaxis.min;//Default vals from plot
    var oMax=plotVar.getAxes().yaxis.max;
    //console.log("oMin:"+oMin+"  oMax:"+oMax);
    $("#"+divID+"_yrangeSlider").slider({
        range:true,
        min:0,
        max:100,
        values:[0,100],
        orientation:"vertical",
        slide:function(event,ui){
            var options=plotVar.getOptions();
            var newMin=(ui.values[0]==0)?oMin:oMin+((ui.values[0]/100)*(oMax-oMin));//% of slider*total range
            var newMax=(ui.values[1]==100)?oMax:oMin+((ui.values[1]/100)*(oMax-oMin));//% of slider*total range
            options.yaxes[0].min=newMin;
            options.yaxes[0].max=newMax;
            plotVar.setupGrid();
            plotVar.draw();
        }
    });
}










