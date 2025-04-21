/*Order specific functions*/
function ord_resetSearchForm(){
    //Reset filters 
    $("#ord_ordNum").val("");
    //$("#ord_organization").val([]);For when a select, changed to autocomplete...
    setAutoCompleteValue('ord_organization','');
   
    $("#ord_custID").val([]);
    setAutoCompleteValue('ord_custID','');
    $("#ord_cylID").val("");
    $("#ord_MOU").val("");
    $("#ord_ordType").val([]);
    
    i_loadList();//Loads all orders
}
function ord_loadOrder(order_num){
    //Load order
    ajax_get("ord_loadOrder","order_num="+order_num,"fixedHeightContentDiv",i_ajax_req);
}
function ord_completeOrder(order_num) {
    //Mark order as completed
    ajax_get("ord_completeOrder","order_num="+order_num,order_num+"_completeResponseDiv",i_ajax_req);
    
}
function ord_loadCalRequests(product_num) {
    //load cal requests for product
    ajax_get("ord_loadCalRequests","product_num="+product_num,"calReqDiv",i_ajax_req);
}
function ord_nagCalManager(request_num) {
    //Sends an email to cal manager(s) for passed request_num
    ajax_get("ord_nagCalManager","request_num="+request_num,request_num+"_nagBtnDiv",i_ajax_req);
}
function ord_loadProduct(product_num) {
    //Loads a specific product details (or blank for add mode "");
    ajax_get("ord_loadProduct","product_num="+product_num,'ord_productFormDiv',i_ajax_req);
}
function ord_prodCalSeriviceCheck() {
    //Enables/disables certain fields for calservices
    //We'll just do all of them anytime any is selected because it's cleaner/easier and there's not too many to cause performance issues.
    $(".ord_prodCalSerivceCheckbox").each(function(){
        $(".ord_prodCSMember_"+$(this).val()).prop("disabled",!this.checked);
        if(this.checked && $("#ord_prodCSTargetValue_"+$(this).val()).val()==''){//Default target to ambient if not already filled in.
            $("#ord_prodCSTargetValue_"+$(this).val()).val('ambient');
        }
    });
}
function ord_deleteOrder(order_num){
	//Delete order_num
	//console.log(order_num);
    ajax_get("ord_deleteOrder","order_num="+order_num,'ordDeleteMssgDiv',i_ajax_req);
}
function ord_loadTargValue(id) {
    //Under some conditions, retrieve the latest fill value for a cyclinder to default as the target val
    //id is the analysis type selector id
    var cyl=$("#ord_prodCylID").val();
    var sel=$("#"+id);
    if((sel.val()==2 || sel.val()==3) && cyl!=''){//intermediate and final, load target from previous
        var t=id.split('_');//cal service num is [2];
        var cs=t[2];
        var sp=$("#ord_prodCSSpecies_"+cs).val();
        var targ=$("#ord_prodCSTargetValue_"+cs);
        if((targ.val()=='' || targ.val().toLowerCase()=='ambient') && ($("#ord_prodCS_"+cs).val()<6 ||$("#ord_prodCS_"+cs).val()==11)){//Only attempt for co2,ch4,co,n2o,sf6,h2
            //Attempt to load from db.
            i_ajax_req=$.ajax({
                url:'cylinder_get-last-analysis.php',
                type:'get',
                data:{id:cyl,calservice:sp},
                success:function(data){
                    var d=data.trim();
                    if($.isNumeric(d)){
                        targ.val(d);
                    }else if(d!=''){alert(d);}
                }
            });
        }
    } 
}

function ord_serializeProdForm(){
    //Returns serialized string of prod form elements
    var orderNum=$("#ord_orderNum").val();//Get the page order num
    //If the cyl and size fields are disabled, temporarily enable them so they get serialized.
    var s=$("#ord_prodCylSize"); var sd=s.is(':disabled');
    var c=$("#ord_prodCylID"); var cd=c.is(':disabled');
    if(sd){s.prop('disabled',false);}
    if(cd){c.prop('disabled',false);}
    //Serialize
    var formData=$("#ord_prodForm").serialize();
    //Reset if needed.
    if(sd){s.prop('disabled',true);}
    if(cd){c.prop('disabled',true);}
    return formData+"&ord_orderNum="+orderNum
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

