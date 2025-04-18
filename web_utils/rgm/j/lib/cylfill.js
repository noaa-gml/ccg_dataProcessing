function cf_rowClicked(product_num,rowID){
    //product_num
    ajax_get("cf_rowClicked","product_num="+product_num+'&clicked_row_id='+rowID,'fixedHeightContentDiv',i_ajax_req);
    //console.log(rowID);
}

function cf_submitCyl(){
    //Check the dot date format (mm-yy)
    var dt=$("#ord_addCylDOT");
    var recertification_date_patt=/^[0-9]{2}\-[0-9]{2}$/;
    if ( ! recertification_date_patt.test(dt.val()) ){
       alert('Please input a valid DOT date (MM-YY)');
       dt.val('');
       dt.focus();
       return false;
    }                
    var formData=$("#cf_fillCylinderForm").serialize();
    ajax_post('cf_addCylinder',formData,'cf_submitMssg',i_ajax_req);
    $("#cf_submitMssg").html("Submitting.... <image src='j/images/ajax-loader2.gif'>");
}