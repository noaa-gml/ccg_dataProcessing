//For dygraph plots to remove 'undefined' when a series doesn't have a datapoint for a date
function dygraphLegendFormatter_old(data) {
    return data.series.map(element => {
    var d=new Date(data.x);var dt='';var t='';
    if(d != 'Invalid Date' && element.yHTML){
        var mm = d.getUTCMonth() + 1; // getMonth() is zero-based
        var dd = d.getUTCDate();
        var yy = d.getUTCFullYear();
        var tt = d.getTime();
        dt=String(yy+'-'+mm+ '-' +dd);
    }
        return `<div style="width:95%;height:100%;border:thin solid silver;"><span style="font-weight:bold; color:${element.color};">${element.labelHTML}:<div>${dt || ' '} ${element.yHTML || '<br>'}</div></span></div>`;//<div style='width:300px;' class="dygraph-legend-line"></div>
    }).join('');
}
function dygraphLegendFormatter(data) {//DEPRECATED see printDygraphPlot()
    //console.log(data['dygraph']);
    //Couldn't quite get toggle in legend it to work.  Can't figure out how to pass the variable plotVar to the toggle method in link below.
    var i=0;//track index so we can add a toggle to title.
    var plotVar=get_variable_name(data['dygraph']);
    //console.log(plotVar);
    return "<table width='100%' class='thinBorderedTable'>"+data.series.map(element => {
        var d=new Date(data.x);var dt='<br>&nbsp;';var t='';

        if(d != 'Invalid Date' && element.yHTML){
            var mm = d.getUTCMonth() + 1; // getMonth() is zero-based
            var dd = d.getUTCDate();
            var yy = d.getUTCFullYear();
            var hh = d.getUTCHours();
            var m = d.getUTCMinutes();
            var ss = d.getUTCSeconds();
            var df= yy + '-' + ('0' + mm).slice(-2)+'-'+('0'+dd).slice(-2);
            var tt= ('0' + hh).slice(-2) + ':' + ('0' + m).slice(-2)+':'+('0'+ss).slice(-2);//zero pad
            //var tt= "<span class='tiny_ital'>"+tt+"</span>";
            dt=String(df+'<br><span class="tiny_ital" >'+tt+'Z</span>');
        }

        t=`<tr class='border'>
                <td align='left' valign='top'><div class='title5' style="color:${element.color};">${element.labelHTML}</div></td>
                <td align='left' valign='top'><span class='sm_data bold' style='width:100%;'>${element.yHTML || ' '}&nbsp;</span></td>
                <td align='right'><div class='sm_data' style='white-space: nowrap;'>${dt}</td>

           </tr>
        `;//<a onclick="jsfunction()" href="javascript:void(0);">


//console.log(t);
        i++;
        return t
    }).join('')+"</table>";
}
//special handler for dygraph plots that have a custom y axis so that double click resets to custom not full
//This isn't perfect.  If dblckicked after manual y set, reverts to out with number still in the y box.
const dygraphDoubleClickZoomOutPlugin = {
        activate: function(g) {
          // Save the initial y-axis range for later.
          //const initialValueRange = g.getOption('valueRange');//This didn't actually work, wasn't in scope.  Weird because this is the site's example code.
          //console.log(initialValueRange);
          return {
            dblclick: e => {
              var range = g.getOption('valueRange');
              e.dygraph.updateOptions({
                dateWindow: null,  // zoom all the way out
                valueRange: range  // zoom to a specific y-axis range.
              });
              //console.log("initialValueRange:");console.log(range);
              e.preventDefault();  // prevent the default zoom out action.
            }
          }
        }
      }

function dygraphLegendFormatter_side(data) {//DEPRECATED  see printDygraphPlot()
    return data.series.map(element => {
    var d=new Date(data.x);var dt='';var t='';
    //console.log(data);
    if(d != 'Invalid Date' && element.yHTML){
        var mm = d.getMonth() + 1; // getMonth() is zero-based
        var dd = d.getDate();
        var yy = d.getFullYear();
        dt=String(yy+'-'+mm+ '-' +dd);
    }

        return `<div style="width:100%;border-bottom:thin solid silver;'">
            <span style="font-weight:bold; color:${element.color};">${element.labelHTML}:</span> <span class='data'>${element.yHTML || '<br>'}</span><br>
            <span class='tiny_ital'>${dt || ' '}</span></div>`;//<div style='width:300px;' class="dygraph-legend-line"></div>
    }).join('');
}
function dygraph_toggleSeriesVisibility(plotVar,series_num){
    //toggles passed series visibility.
    w=dygraph_getLegendW(plotVar);
    h=dygraph_getLegendH(plotVar);
    console.log(w);
    var curr=this[plotVar].visibility();
    var b=curr[series_num];
    this[plotVar].setVisibility(series_num,!b);
    dygraph_setLegendW(plotVar,w);
    dygraph_setLegendH(plotVar,h);
}
function get_variable_name(variable){
    //Returns string name of variable for use in building jquery selectors
    const variableToString = varObj => Object.keys(varObj)[0]
    const variableNameStr = variableToString({ variable })
    return variableNameStr;
}
function dygraph_getLegendW(plotVar){
    //var n=get_variable_name(plotVar);
    //console.log(n);
    var legend=$('#'+plotVar+'_div').find('.dygraph-legend');
    return parseInt(legend.css('left'));//Current legend position
}
function dygraph_getLegendH(plotVar){
    var legend=$('#'+plotVar+'_div').find('.dygraph-legend');
    return parseInt(legend.css('top'));//Current legend position
}
function dygraph_setLegendW(plotVar,w){
    //var n=get_variable_name(plotVar);
    $('#'+plotVar+'_div').find('.dygraph-legend').css('left',w);
}
function dygraph_setLegendH(plotVar,h){
    //var n=get_variable_name(plotVar);
    $('#'+plotVar+'_div').find('.dygraph-legend').css('top',h);
}
function dygraph_horzLine(ctx,area,dygraph,x1,x2,y,color,lineWidth){
    var xl = dygraph.toDomCoords(x1,y);
    var xr = dygraph.toDomCoords(x2,y);
    ctx.strokeStyle=color;
    ctx.lineWidth=lineWidth;
    ctx.beginPath();
    ctx.moveTo(xl[0],xl[1]);
    ctx.lineTo(xr[0],xr[1]);
    ctx.closePath();
    ctx.stroke();
}
function dygraph_vertLine(ctx,area,dygraph,y1,y2,x,color,lineWidth){
    var yt = dygraph.toDomCoords(x,y1);
    var yb = dygraph.toDomCoords(x,y2);
    ctx.strokeStyle=color;
    ctx.lineWidth=lineWidth;
    ctx.beginPath();
    ctx.moveTo(yt[0],yt[1]);
    ctx.lineTo(yb[0],yb[1]);
    ctx.closePath();
    ctx.stroke();
}
//Global.  Used by js plotting (dygraph) wrappers.  See dbutils_htmlUtilities.php->getJSTimestamp() for comments.
//Actually, this global may not be used at moment, functions below instead.  Leaving becuase it's convienent in console.
//jwm - 8.22 - neither are 2 utc date funcs.  Leaving for now, but dygraph code was rewritten to avoid js tz
var tzoffset_mn = new Date().getTimezoneOffset();
console.log("tz offset:"+tzoffset_mn+" min");

function addUTCOffset(date) {
    var offset=date.getTimezoneOffset();
    return new Date(date.getTime() + offset*60000);
}
function UTCLDate(timestamp) {//For dygraph plots.. adjust local time to seem like utc so plots look correct.
    var d=new Date(timestamp);
    return addUTCOffset(d);
}
//

//for vertical tabs.  see dbutils_htmlUtilities->getSideTabs()
function setVerticalTabSelected(uid,n){
    var labelid=uid+'_L_'+n;
    var contentid=uid+'_C_'+n;
    $('.vertical_tab_content_'+uid).hide();//Hide all content
    $('.vertical_tab_label_'+uid).removeClass('vertical_tabLabels_sel');//Unselect any selected
    $('#'+contentid).show();//Show content of selected
    $('#'+labelid).addClass('vertical_tabLabels_sel');//select tab widget
}

//Functions for autocomplete widgets.
function setAutoCompleteValue(id,key) {
    //Set the val and key for an autocomplete.  id is the input id, key is the primary key (key element in the data array).  Pass '' to clear.
    //See dbutils_htmlUtilities.php->getAutoComplete() for details
    if (key) {
        var arr=eval(id+'_data');
        if (arr) {
            var display=getValueForAutoCompleteKey(arr,key);
            if(display){
                $("#"+id).val(key);//sets the actual hidden datafield.
                $("#"+id+"_display").val(display);//Sets the autocomplete value
                //$("#"+id+"_display").siblings('.ui-combobox').find('.ui-autocomplete-input').val(display);//sets the display
            }
        }
    }else{//No key passed, clear.
        $("#"+id).val('');//sets the actual hidden datafield.
        $("#"+id+"_display").val('');//Sets the autocomplete value
    }
}
function getValueForAutoCompleteKey(array,key) {
    /*get the display 'val' for passed key in an autocomplete data array
     */

    var result=$.grep(array,function(e){return e.key==key;});
    if (result.length==0) {
        return false;
    }else return result[0]['value'];
}

//Date functions
function ymdDate(date){//Returns yyyy-mm-dd date string for passed js date obj
    var mm = date.getMonth() + 1; // getMonth() is zero-based
    var dd = date.getDate();

    return [date.getFullYear(),
            (mm>9 ? '' : '0') + mm,
            (dd>9 ? '' : '0') + dd
           ].join('-');
};





function tryParseJSON (jsonString){
    try {
        var o = JSON.parse(jsonString);

        // Handle non-exception-throwing cases:
        // Neither JSON.parse(false) or JSON.parse(1234) throw errors, hence the type-checking,
        // but... JSON.parse(null) returns 'null', and typeof null === "object",
        // so we must check for that, too.
        if (o && typeof o === "object" && o !== null) {
            return o;
        }
    }
    catch (e) { }

    return false;
};
//Tooltip logic for printGraph
var onPrintGraph_previousPoint=null;
function onPrintGraphHoverShowToolTip(event,pos,item){//Show tooltip with plot point's data
console.log(event);
        if (item) {
            if (onPrintGraph_previousPoint != item.dataIndex) {

                onPrintGraph_previousPoint = item.dataIndex;

                $("#tooltip").remove();
                //build up a 'date (series label): value' string
                var time=new Date(item.datapoint[0]);
                var o=$.datepicker.formatDate('M d, yy',time);
                o="<span>"+o+"</span>&nbsp;&nbsp;("+item.series.label+"):<span style='font-weight: 600;'> "+item.datapoint[1]+"</span>";
                console.log(item.pageX,item.pageY,o);
                showTooltip(item.pageX, item.pageY,o);

            }
        } else {
            $("#tooltip").remove();
            onPrintGraph_previousPoint = null;
        }

}
function showTooltip(x, y, contents) {
    $("<div id='tooltip'>" + contents + "</div>").css({
        position: "absolute",
        display: "none",
        top: y + 5,
        left: x + 5,
        border: "1px solid #fdd",
        padding: "2px",
        "background-color": "#fee",
        opacity: 0.80
    }).appendTo("body").fadeIn(200);
}


/*Below table sorting voodoo curtesy of http://www.kryogenix.org/code/browser/sorttable/
Thanks guys!
*/

addEvent(window, "load", sortables_init);

var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    tbls = document.getElementsByTagName("table");
    for (ti=0;ti<tbls.length;ti++) {
        thisTbl = tbls[ti];
        if (((' '+thisTbl.className+' ').indexOf("sortable") != -1) && (thisTbl.id)) {
            //initTable(thisTbl.id);
            ts_makeSortable(thisTbl);
        }
    }
}

function ts_makeSortable(table) {
    if (table.rows && table.rows.length > 0) {
        var firstRow = table.rows[0];
    }
    if (!firstRow) return;

    // We have a first row: assume it's the header, and make its contents clickable links
    for (var i=0;i<firstRow.cells.length;i++) {
        var cell = firstRow.cells[i];
        var txt = ts_getInnerText(cell);
	if(txt.indexOf("sortable") == -1){//skip if we've already done this table
	   cell.innerHTML = '<a href="#" class="sortheader" '+
	   'onclick="ts_resortTable(this, '+i+');return false;">' +
	   txt+'<span class="sortarrow">&nbsp;</span></a>';
	}
    }
}

function ts_getInnerText(el) {
    //console.log(el);
    if (typeof el == "string") return el;
	if (typeof el == "undefined") { return el };
    if (typeof el == "object" && el.type=='text') {//This is to handle inputs
        return el.value
    };
	if (el.innerText) return el.innerText;	//Not needed but it is faster
    //if (typeof el == 'text'){alert(el.type.value)};
	var str = "";

	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}

function ts_resortTable(lnk,clid,table) {
    // get the span
    var span;
    for (var ci=0;ci<lnk.childNodes.length;ci++) {
        if (lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase() == 'span') span = lnk.childNodes[ci];
    }
    var spantext = ts_getInnerText(span);
    var td = lnk.parentNode;
    var column = clid || td.cellIndex;
    var table = table || getParent(td,'TABLE');

    // Work out a type for the column
    if (table.rows.length <= 1) return;
    var i=1;
    do{//loop thru finding the first non empty cell in this col so we can determine datatype
	    var itm = ts_getInnerText(table.rows[i].cells[column]);
	i++;
    }while(((itm=="") || (itm.charCodeAt(0)==160 && itm.length==1))&& (i<table.rows.length));//&nbsp or a ' ' commonly used to fill an empty <td>
    sortfn = ts_sort_caseinsensitive;
    var DATE_RE = /^((\d\d)?\d\d)[\/\.-](\d\d?)[\/\.-](\d\d?)$/;//yyyy-mm-dd
    if(!isNaN(Date.parse(itm)) && (itm.match(DATE_RE)!=null))sortfn = ts_sort_date;//jwm- added a regex match for yyyy-mm-dd because js date parse was matching on some integers.  Its a terrible parser.  Newer version of sorttable uses similar regex logic (more comprehensive), but it was hard to integrate new version in, so left that for another project.
    else if (itm.match(/^[£$]/)) sortfn = ts_sort_currency;
    else if (itm.match(/^[\d\.]+$/)) sortfn = ts_sort_numeric;

    //console.log("col:"+clid+" item:"+itm+" sort:"+sortfn+" date:"+Date.parse(itm)+" "+itm.match(DATE_RE));
    SORT_COLUMN_INDEX = column;
    var firstRow = new Array();
    var newRows = new Array();
    for (i=0;i<table.rows[0].length;i++) { firstRow[i] = table.rows[0][i]; }
    for (j=1;j<table.rows.length;j++) { newRows[j-1] = table.rows[j]; }

    newRows.sort(sortfn);

    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '&nbsp;&nbsp;&uarr;';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '&nbsp;&nbsp;&darr;';
        span.setAttribute('sortdir','down');
    }

    // We appendChild rows that already exist to the tbody, so it moves them rather than creating new ones
    // don't do sortbottom rows
    for (i=0;i<newRows.length;i++) { if (!newRows[i].className || (newRows[i].className && (newRows[i].className.indexOf('sortbottom') == -1))) table.tBodies[0].appendChild(newRows[i]);}
    // do sortbottom rows only
    for (i=0;i<newRows.length;i++) { if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) table.tBodies[0].appendChild(newRows[i]);}

    // Delete any other arrows there may be showing
    var allspans = document.getElementsByTagName("span");
    for (var ci=0;ci<allspans.length;ci++) {
        if (allspans[ci].className == 'sortarrow') {
            if (getParent(allspans[ci],"table") == getParent(lnk,"table")) { // in the same table as us?
                allspans[ci].innerHTML = '&nbsp;&nbsp;&nbsp;';
            }
        }
    }

    span.innerHTML = ARROW;
}

function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}
function ts_sort_date(a,b){/*Sort 2 dates.. note that Date.parse will parse most date formats
    and return the number of seconds (+/-) since unix epoch.  The range of a js date is
    +/- 100,000 days from epoch (I believe);*/
    d1 = Date.parse(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
    d2 = Date.parse(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]));
    if((isNaN(d1))&&(isNaN(d2))){//neither a date
	return 0;
    }else if(isNaN(d1))return -1;
    else if(isNaN(d2)) return 1;
    else if(d1==d2)return 0;
    else if(d1<d2)return -1;
    return 1;

}

function ts_sort_currency(a,b) {
    aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,''));
    bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,''));
    if((isNaN(aa))&&(isNaN(bb))){//neither a number
	return 0;
    }else if(isNaN(aa))return -1;
    else if(isNaN(bb)) return 1;
    else return aa-bb;
}

function ts_sort_numeric(a,b) {
    aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
    bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]));
    if((isNaN(aa))&&(isNaN(bb))){//neither a number
	return 0;
    }else if(isNaN(aa))return -1;
    else if(isNaN(bb)) return 1;
    else return aa-bb;
}
function ts_sort_caseinsensitive(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function ts_sort_default(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}


function addEvent(elm, evType, fn, useCapture)
// addEvent and removeEvent
// cross-browser event handling for IE5+,  NS6 and Mozilla
// By Scott Andrew
{
  if (elm.addEventListener){
    elm.addEventListener(evType, fn, useCapture);
    return true;
  } else if (elm.attachEvent){
    var r = elm.attachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
}

function printDivTable(divID){
    //Quick and dirty function to print first table contents of a div.
    //It adds basic border to any tables(because no styles are carried over).
    //Pass the wrapper div's id
   var t=$("#"+divID+" table:first");
   if (t) {
        var html="<html><head><title></title><style>.t {font-size: x-small;border-collapse:collapse;width:100%;page-break-inside:auto}.t tr{page-break-inside:avoid; page-break-after:auto}.t thead{display:table-header-group}.t td{border:thin black solid;}@media print {body {color: #000;background: #fff;margin:0;padding:0;}@page{margin:2cm;}}</style></head><body>";
        var win=window.open('','printwindow');
        if (win) {
            win.document.write(html);
            win.document.write("<div style='width:650px'><table class='t'>"+t.html()+"</table></div>");//Need to add back on table tags...
            win.document.write("</body></html>");
            win.print();
            win.close();
        }
   }

}



//SinglePlots3 JS functions
var sp_plotVars=[];//Global array to hold pointers to various plots.
var sp_plotIDs=[];//Ditto for unique ids.
var sp_minDate=false;
var sp_maxDate=false;

function sp3_createPlots(data,destDivID) {
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
        var html="<table border='0' class='sp3_plotTable'><tr><td align='center' class='title4'>&nbsp;"+description+"<span style='float:right'><input id='sp3_resetBtn' type='button' value='Reset'></span></td></tr>";
        var divID='sp3_plot_';
        //Loop through data array and create plot divs for each obj.
        //We'll do 2 loops, creating the dom objects first, then the plots.  Probably could do in one step, but this seems cleaner.
        for (var i=0,len=data.length;i<len;i++) {
            var id=divID+i.toString();
            html+="<tr><td><div class='sp3_plotDiv'  class='sp_plot' id='"+id+"' style='width:"+plotWidth+"px;height:"+plotHeight+"px;border:thin silver solid;'></div></td><td valign='center'><table><tr><td><div style='height:180px' id='"+id+"_yrangeSlider'></div></td><td><div style='float:right;' id='"+id+"_displayDiv' style='width:"+displayWidth+"px;'></div></td></tr></table></td></tr>";
        }
        html+="</table>";
        $("#"+destDivID).html(html);//Set into the dom

        //Now the actual plots.
        sp_plotVars=[];//Reset each time this is called to clear state
        sp_plotIDs=[];
        sp_minDate=false;
        sp_maxDate=false;

        for (var i=0,len=data.length;i<len;i++) {
            var id=divID+i.toString();
            sp_plotVars[i]=sp3_createPlot(data[i],id,i);
            sp_plotIDs[i]=id;//Don't think this one is actually used anymore, but keeping for now in case want to.
        }

        //Zoom reset btn.
        $("#sp3_resetBtn").hide();//Hide until needed.
        $("#sp3_resetBtn").click(function(event){
                event.preventDefault();
                sp3_unzoom();
            });

    }else{$("#"+destDivID).html("No plot data available");}
}
function sp3_unzoom(){//Resets zoom window to all available data.
    for(i=0;i<sp_plotIDs.length;i++){
        var id=sp_plotIDs[i];
        var plot=sp_plotVars[i];
        $.each(plot.getXAxes(), function(_, axis) {
            var opts = axis.options;
            opts.min = sp_minDate;
            opts.max = sp_maxDate;
        });
        plot.setupGrid();
        plot.draw();
        plot.clearSelection();
    }
    $('#sp3_resetBtn').hide();
}
function sp3_createPlot(data,divID,index) {
    //Called by above, creates a single plot.
    //Options object is defaulted below.. Caller can pass in overrides for some (clickable, lines...) in the series obj.
    //Data['series'] contains all the series data for this plot
    //divID is id of destination div.  Assumes existence of a divID_displayDiv for on hover text
    //Could return plot var if needed.
    //xaxis:{mode:"time",timeformat: "%m/%y",show:true,min:sp_allPlotsMinX,max:sp_allPlotsMaxX},

//
    var options={
        legend:{position:'nw'},
        xaxis:{mode:"time",timeBase: "milliseconds",show:true,min:sp_allPlotsMinX,max:sp_allPlotsMaxX},
        yaxis:{show:true,labelWidth:40},
        grid:{clickable:true,hoverable:true,margin:0,borderWidth:0},
        series: {
            lines: { show: true,lineWidth:0.5 },
            points: { show: true, fill: true,fillColor:0 },
            color: index
        },
        selection:{mode:'x'}
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
            o=time.toUTCString();
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
                var s=data['onClickMethod']+"('"+item.series.data[item.dataIndex][2]+"')";
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

    //Set up zooming
    sp_minDate=plotVar.getAxes().xaxis.min;//Default vals from plot
    sp_maxDate=plotVar.getAxes().xaxis.max;
    //console.log("spmin:"+sp_minDate+" max:"+sp_maxDate);
    $("#"+divID).bind("plotselected", function (event, ranges) {//Allows user to select a section of displayed plot to zoom in on.
        for(i=0;i<sp_plotIDs.length;i++){
            //var id=sp_plotIDs[i];
            var plot=sp_plotVars[i];
            $.each(plot.getXAxes(), function(_, axis) {
                var opts = axis.options;
                opts.min = ranges.xaxis.from;
                opts.max = ranges.xaxis.to;
            });
            plot.setupGrid();
            plot.draw();
            plot.clearSelection();
        }
        $('#sp3_resetBtn').show();//Show button to un-zoom
    });


    return plotVar;
}

//Function to relay editable field for printTable
function editablePrintTableField(fn,pk,cb){
    //assumes naming convention from printTable lib.
    //This is called when display div clicked
    var disp=fn+"_display_div_"+pk;
    var inp=fn+"_input_"+pk;
    $("#"+disp).hide();
    $("#"+inp).show().focus();
    $("#"+inp).change(function (){
        //console.log(cb,"ptef_val="+$("#"+inp).val()+"&ptef_pk="+pk,disp);
        ajax_post(cb,"ptef_val="+$("#"+inp).val()+"&ptef_pk="+pk,disp);
        $("#"+inp).hide();
        $("#"+disp).show();
    });


}
