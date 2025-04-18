//DEPRECATED

//SEE /review for updated.

function rev_itemSelected(id) {
    $("#dataDiv").empty();
    $("#detailDiv").empty();
    if (id=='rev_taggedEvents') {//If event was selected, load the plots
        //Doing this in the edit form button nav now.
        //rev_getTaggedEventPlot();
        rev_getRangeEditForm();//And the range edit form.
    }else{//Otherwise, reload the event list.
        if (id=='rev_tags') {
            //If tag was changed, en/dis able the prelim check box.  we'll only allow on 6
            //var tagNum=$('#rev_tags').val();
            $("#tag_prelim").prop("disabled",($('#rev_tags').val()!=97));
        }
        rev_getTaggedEventList();
    }
}

function setFilterDescription() {
    //Stub for index.js function (called by auto complete (site) js).  We may implement in future to give a filter desc...
}
var rev_clearTagEditFormTimeout;//Global so we can cancel if needed.
function rev_clearTagEditForm(range_num) {
    //Clear the submit message and then reselect the row.
    rev_clearTagEditFormTimeout=setTimeout(function(){
        $('#rev_tagEditFormDiv').empty();
        if(range_num!="") rev_itemSelected('');
        
    },2*1000);
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
function rev_plotClickHandler(data_num) {
    alert(data_num);
}