//Plot event handlers
function tagRangePlotClicked(event,pos,item) {
    if (item) {
        var range_num=item.series.label;
        if(range_num)tagRangeSelected(range_num);
    }
}

function tagRangePlotHover(event,pos,item) {
    $("#plotTextArea").html("");
    if (item) {
        var o=plotRangeDescriptions[item.seriesIndex];
        $("#plotTextArea").html(o);
    }
}
var srPC_lastClickedSeriesIndex=-1;
var srPC_lastClickedDataIndex=-1;
function searchResultsPlotClicked(event,pos,item) {
    if (item ) {
        
        //Remove any previous highlight, and then highlight the selected item.
        if (srPC_lastClickedSeriesIndex>=0) {
            searchResultsPlotVar.unhighlight(srPC_lastClickedSeriesIndex,srPC_lastClickedDataIndex);
        }
        srPC_lastClickedSeriesIndex=item.seriesIndex;
        srPC_lastClickedDataIndex=item.dataIndex;
        
        //Highlight clicked item.
        searchResultsPlotVar.highlight(item.seriesIndex,item.dataIndex);
        
        //Handle click
        var param=selectionPlotParams[item.seriesIndex][item.dataIndex];
        var a=param.split(",");//break out the event and data nums
        if(a)getTagList(a[0],a[1]);
    }
}

function searchResultsPlotHover(event,pos,item) {
    $("#plotTextArea").html("");
    if (item) {
        var time=new Date(item.datapoint[0]);
        var o=$.datepicker.formatDate('M d, yy',time);
        o="<div>"+o+"</div><div style='font-weight: 600;'>("+item.series.label+") "+item.datapoint[1]+"</div>";
        $("#plotTextArea").html(o);
    }
}
function highlightPoints(plotVar,arr) {
    for (var i=0, len=arr.length; i<len;i++){
        var a=arr[i];
        plotVar.highlight(a[0],a[1]);
    }
   
}