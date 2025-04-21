<?php
require_once("orders_funcs.php");
require_once("intended_use.php");
/*see orders_funcs.php for details on how to add calservice.*/
#add/edit orders
function ord_editOrderForm($order_num=""){
    #Return order form either for edit or add (order_num='')
    $organization='';$due_date='';$MOU_number="";$pri_cust_id="";$order_status="";$comments="";$creation_datetime='';
    $invoice_submit_dt='';$ship_date='';$invoice_cost='';$ship_cost='';

    if($order_num){
        #edit mode, load data.
        bldsql_init();
        bldsql_from("rgm_order_view");
        bldsql_where("order_num=?",$order_num);
        bldsql_col("organization");
        bldsql_col("due_date");
        bldsql_col("MOU_number");
        bldsql_col("pri_cust_id");
        bldsql_col("order_status");
        bldsql_col("comments");
        bldsql_col("creation_datetime");
        bldsql_col("invoice_submit_dt");
        bldsql_col("invoice_cost");
        bldsql_col("ship_date");
        bldsql_col("ship_cost");
        $a=doquery();
        if($a)extract($a[0]);#overwrites above.
    }

    #organization
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.organization as value");
    bldsql_from("rgm_order_view r");
    bldsql_where("r.organization != ''");
    bldsql_orderby("r.organization");
    $a=doquery();
    $js_orgSrc="var orgSrc=".arrayToJSON(arrayFromCol($a,'value'),false);#jsonify


    #Customer email
    bldsql_init();
    bldsql_distinct();

    #bldsql_col("c.email as display_name");
    #bldsql_col("c.id as value");
    bldsql_col("c.email as value");
    bldsql_col("c.id as 'key'");
    bldsql_col("concat(c.first_name,' ',c.last_name,' <',c.email,'>') as label");
    bldsql_from("customers c");
    bldsql_orderby("c.email");

    $cust=getAutoComplete(doquery(),'ord_custID',50,$pri_cust_id,"",'ord_orderEditFormInput');

    #Add in a add form
    if($order_num==''){
        $form="<table>";
        $form.=getInputTr("Email address",getStringInput("ord_new_cust_email",'','25'));
        $form.=getInputTr("First Name",getStringInput("ord_new_cust_first_name",'','25'));
        $form.=getInputTr("Last Name",getStringInput("ord_new_cust_last_name",'','25'));
        $form.="</table>";
        $cust.=getHidingDiv($form,'Add','Hide');
    }
    $products=ord_getProductList($order_num);

    #Default the due date to +3 months.. man date logic sucks in js (and php).  Eventually this should be a little plus minus js button to roll the date... pia.
    $due_date=($order_num)?$due_date:doquery("select date_add(current_date(), interval 3 month)",0);

    $invdt=getDateInput('invoice_submit_dt',"$invoice_submit_dt",12,true,'ord_orderEditFormInput');
    $shipdt=getDateInput('ship_date',"$ship_date",12,true,'ord_orderEditFormInput');
    $invcost=getFFloatInput('invoice_cost',$invoice_cost,8,'ord_orderEditFormInput');
    $shipcost=getFFloatInput('ship_cost',$ship_cost,8,'ord_orderEditFormInput');

    $stat=($order_num)?"<tr><td class='label'>Created</td><td class='data'>$creation_datetime</td><td class='label'>Order status</td><td class='data'>$order_status</td></tr>":"";
    $html="<div style='border:thin black solid;background-color:#DCDCDC'>
    <span class='title3'>Order $order_num details</span><br>
    <form id='ord_orderEditForm' onsubmit='return false;'>
    <input type='hidden' id='ord_orderNum' name='ord_orderNum' value='$order_num'>
    <table >
        $stat
        <tr>
            <td class='label'>Due date</td><td class='data'><input class='ord_orderEditFormInput' type='text' id='ord_dueDate' name='ord_dueDate' size='12' value='$due_date' onchange=\"return  validateDate('ord_dueDate',false,-1);\"></td>
            <td class='label'>Organization</td><td class='data'><input class='ord_orderEditFormInput' type='text' id='ord_org' name='ord_org' size='40' value='$organization'></td>
        </tr>
        <tr>
            <td class='label'>MOU #</td><td class='data'><input class='ord_orderEditFormInput' type='text' id='ord_mouNum' name='ord_mouNum' size='20' value='$MOU_number'></td>
            <td class='label'>Primary Customer</td><td class='data'>$cust</td>
        </tr>
        <tr>
            <td class='label'>Order<br>Comments</td><td colspan='3' class='data'><textarea class='ord_orderEditFormInput' cols='80' rows='2' id='ord_comments' name='ord_comments'>$comments</textarea></td>
        </tr>
        <tr>
            <td class='label'>Invoice date:</td><td class='data'>$invdt</td><td class='label'>Invoice cost:</td><td class='data'>$invcost</td>
        </tr>
        <tr>
            <td class='label'>Ship date:</td><td class='data'>$shipdt</td><td class='label'>ship cost:</td><td class='data'>$shipcost</td>
        </tr>
        <tr><td colspan='4' align='right'><span id='ord_message' class='title4'></span>&nbsp;&nbsp;&nbsp;<button id='ord_orderEditSaveBtn' value='1' disabled>Save</button></td></tr>
    </table>
    </form>
    <table>
        <tr><td colspan='4' valign='top'><hr width='60%'></td></tr>
        <tr><td colspan='4' valign='top'><div id='ord_products'>$products</div></td></tr>

    </table>

    </div>
    <script>
    $(function(){
       $js_orgSrc;
       $(\"#ord_org\").autocomplete({source:orgSrc});
       $(\".ord_orderEditFormInput\").focus(function(){
            //Enable the save button once any field has been entered into.  We could wait for a change event, but this makes better ui and there's not too much harm in submitting a noop save.
            $(\"#ord_orderEditSaveBtn\").prop('disabled',false);
       });
       $(\"#ord_orderEditSaveBtn\").click(function(){
            //Submit if required fields present.
            //if($(\"#ord_org\").val()==''){
            //    alert('Please enter an organization.');
            //}else
            if($(\"#ord_dueDate\").val()==''){
                alert('Please enter a due date.');
            }else if(
            $(\"#ord_custID\").val()==''
                && (
                    $('#ord_new_cust_email').val()=='' ||
                    $('#ord_new_cust_first_name').val()=='' ||
                    $('#ord_new_cust_last_name').val()==''
                    )
            ){
                alert('Please select a primary customer or click Add to enter a new one (all fields).');
            }else{
                //Post the edits.
                var formData=$(\"#ord_orderEditForm\").serialize();
                ajax_post('ord_submitOrder',formData,'ord_message',i_ajax_req);

            }
       })
    });
    </script>";
    if($order_num){$html.=setTitleJS("'RGM Order:$order_num'");}
    return $html;
}
function ord_addCustomerEmail($email,$fname,$lname){
    #adds email, first, last name entries to customer table
    $cust_id='';
    #see if exists and return that
    $cust_id=doquery("select id from customers where email like ?",0,array($email));
    if($email && $fname && $lname && !$cust_id){
        bldsql_init();
        bldsql_insert("customers");
        bldsql_set("email=?",$email);
        bldsql_set("login=?",$email);#this and next were set by old system, I don't think they are needed anymore but including to be consistent
        bldsql_set("customer_id=?",$email);
        bldsql_set("first_name=?",$fname);
        bldsql_set("last_name=?",$lname);
        bldsql_set("create_time=?","now()");
        bldsql_set("change_time=?","now()");
        $cust_id=doinsert();
    }
    return $cust_id;
}
function ord_submitOrder(){
    $order_num=getHTTPVar("ord_orderNum",false,VAL_INT);
    $due_date=getHTTPVar("ord_dueDate",'',VAL_DATE);
    $organization=getHTTPVar("ord_org");
    $mou=getHTTPVar("ord_mouNum");
    $pri_cust=getHTTPVar("ord_custID");
    $comments=getHTTPVar("ord_comments");
    $email=getHTTPVar("ord_new_cust_email");
    $fname=getHTTPVar("ord_new_cust_first_name");
    $lname=getHTTPVar("ord_new_cust_last_name");
    $invoice_submit_dt=getHTTPVar("invoice_submit_dt",'',VAL_DATE);
    $ship_date=getHTTPVar("ship_date",'',VAL_DATE);
    $invoice_cost=getHTTPVar("invoice_cost",0,VAL_FLOAT);
    $ship_cost=getHTTPVar("ship_cost",0,VAL_FLOAT);

    #attempt to add new if passed and none currently selected
    if(!$pri_cust)$pri_cust=ord_addCustomerEmail($email,$fname,$lname);

    $html="";
    $js='';
    if($due_date && $pri_cust){
        require_once ("../CCGDB.php");
        require_once("../DB_Order.php");
        require_once("../Log.php");
        require_once("/var/www/html/inc/ccgglib_inc.php");

        #require_once("DB_ProductManager.php");
        #require_once("DB_CalRequestManager.php");
        #require_once("DB_CalServiceManager.php");
        #require_once("DB_CylinderManager.php");

        session_start();
        $db = new CCGDB();
        $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
        session_write_close();

        try{
            #Either create or load order
            if($order_num)$ordObj=new DB_Order($db,$order_num);
            else $ordObj=new DB_Order($db,$due_date);

            #mou
            $ordObj->setMOUNumber($mou);

            #Organiation
            $ordObj->setOrganization($organization);

            #pri cust
            if($pri_cust){
                $customer_object = new DB_Customer($db, $pri_cust);
                $ordObj->setPrimaryCustomer($customer_object);
            }

            #comments
            $ordObj->setComments($comments);

            #additional customers? Leaving out for now.. see order_creation.php->CreateObject() if need to add it

            #I'm not sure if the concept of pending orders is needed.. if so, next step should be conditional on whether user is 'submitting' vs creating a pending order.
            #For now we'll just ignore pending status and set directly to processing.
            $ordObj->process();

            #Save to db.  Note there's a 2nd prelim step 'preSaveToDB' that we could call first to check for errors, but
            #since saveToDB does that anyway (and we don't send emails anymore) we'll skip that step.
            #toLogFile($ordObj);var_dump($ordObj);exit();

            $ordObj->saveToDB($user_obj);
            $js='$("#ord_prodAddBtn").prop("disabled",false);';#Enable the 'add products' button once the order has been saved.. this is a noop on edits
            if(!$order_num){#If this was an add, fetch the new order num and set it into the form input so we can add products
                $order_num=$ordObj->getNum();
                $js.='$("#ord_orderNum").val("'.$order_num.'");';
                ord_setFilterDefaultsSelectedOrder($order_num);#Set this order as the 'selected' order to preload on summary page.
            }
            #We'll update the ship/invoice fields separately so we don't need to edit the classes...
            db_connect("lib/config.php");#above resets conn
            $sql="update order_tbl set ";
            $params=array();

            if($invoice_submit_dt){
                $sql.="invoice_submit_dt=?";
                $params[]=$invoice_submit_dt;
            }else $sql.="invoice_submit_dt=NULL";#null out if not being set. Can't do this via parameters (limitation)
            if($ship_date){
                $sql.=", ship_date=?";
                $params[]=$ship_date;
            }else $sql.=",ship_date=NULL";
            if($invoice_cost){
                $sql.=", invoice_cost=?";
                $params[]=$invoice_cost;
            }else $sql.=",invoice_cost=NULL";
            if($ship_cost){
                $sql.=", ship_cost=?";
                $params[]=$ship_cost;
            }else $sql.=",ship_cost=NULL";

            $sql.=" where num=?";
            $params[]=$order_num;
            #return $sql;
            if(doupdate($sql,$params)!==False)$html="Order successfully saved";
            else $html="Error saving some information.  Reload order, verify entries and try again.";

            $html="Order successfully saved";
        }catch ( Exception $e ){
            $html.=$e."<br>";
            var_dump($html);
        }

    }else $html="Missing a required field (due date,  primary customer)";
    return "<script>setStatusMessage(\"$html\",4,'ord_message');$js</script>";
}
function ord_getProductList($order_num,$selectedProdNum='',$formMessage=''){
    #Gets an order's product list and preselects a product (if passed).  Displays formMessage if passed (like 'saved').
    #If selectedProdNum= false then no product is selected, defaults to first row, or passed prodnum
    $html="";$table="";$addDisabled=($order_num)?'':'disabled';$printSheetsHTML="";
    $mssg=($formMessage)?"setStatusMessage('$formMessage',5,'ProdSubmitStatusDiv');":'';
    $divID="prod_ord_${order_num}_table";

    if($order_num){
        bldsql_init();
        bldsql_from("rgm_product_view p");
        bldsql_where("order_num=?",$order_num);
        bldsql_col("product_num as onClickParam");
        $n="(select count(*)+1 from product where order_num=p.order_num and num<p.product_num)";
        bldsql_col("$n as '#'");
        bldsql_col("cylinder_id as 'Cylinder'");
        bldsql_col("prod_cyl_size as 'Cyl size'");
        bldsql_col("prod_status as 'Status'");
        bldsql_orderby("product_num");#Needed so that cyl fill #/total works.
        $a=doquery();
        $selectedIndex=1;#default to pre-select 1st row.  If prod passed, find it's index and select it.
        if($selectedProdNum){
            $t=arrayFromCol($a,'onClickParam');
            $i=array_search($selectedProdNum,$t);
            if($i!==false)$selectedIndex=$i+1;#css starts at 1
        }
        if($a){
            $table=printTable($a,'ord_loadProduct',1,'','250px','250px',$divID);
            if($selectedProdNum!==false)$table.="
            <script language='JavaScript'>//Fire click event for first row to preload it.
                $(\"#${divID} tr:nth-child($selectedIndex)\").click();
            </script>
            ";

            #build a popup form to print cylinder sheets
            require_once("orders_funcs.php");#Incase it's not loaded already.
            $formData=ord_getPrintCylinderForm($order_num);
            $printSheetsHTML.="<div style='display:inline' id='ord_cylSheetDiv'></div>
            ".getPopUpForm($formData,"Print cylinder sheets","Select cylinders to print","Print cylinder sheets","ord_printCylSheets");

        }


    }

    $html="
    <table width='100%'>
        <tr>
            <td valign='top' style='min-width:200px;width:200px;'>
                <div class='title3'>Products</div>
                $table<br>
                <button id='ord_prodAddBtn' $addDisabled>Add</button>
                $printSheetsHTML
            </td>
            <td valign='top'><div class='title3'>Calibrations</div><div id='ord_productFormDiv' style='height:100%;width:100%;'></div></td>
        </tr>
        <tr><td colspan='2'><div style='float:right' class='title4' id='ProdSubmitStatusDiv'></div></tr>
    </table>
    <script language='JavaScript'>
        $(\"#ord_prodAddBtn\").click(function(event){
            event.preventDefault();
            $(\"#${divID} .dbutils_selectedRow\").removeClass(\"dbutils_selectedRow\");//Clear any selections
            ord_loadProduct(\"\");//Load add form
        });
        $mssg
    </script>
    ";

    return $html;
}
function ord_getProductForm($product_num=""){
    #Returns 1 product form section for edit or add ($product_num='')
    $cylinder_num="";$cylinder_id='';$recertification_date="";$cyl_size="";$cyl_type="";$cyl_status="";$cyl_checkin_status="";
    $intended_use='';$intended_site='';
    $cyl_loc="";$cyl_loc_comments;$cyl_loc_datetime="";$cyl_loc_action_user="";$fill_code="";$prod_status="";$prod_cyl_size_num="";$prod_comments="";
    if($product_num){
        bldsql_init();
        bldsql_from("rgm_product_view");
        bldsql_where("product_num=?",$product_num);
        bldsql_col("cylinder_num ");
        bldsql_col("cylinder_id");
        bldsql_col("recertification_date");
        bldsql_col("cyl_type");
        bldsql_col("cyl_status");
        bldsql_col("cyl_checkin_status");
        bldsql_col("cyl_loc");
        bldsql_col("cyl_loc_comments");
        bldsql_col("cyl_loc_datetime");
        bldsql_col("cyl_loc_action_user");
        bldsql_col("fill_code");
        bldsql_col("prod_status");
        bldsql_col("prod_cyl_size_num");
        bldsql_col("prod_comments");
        bldsql_col("intended_use");
        bldsql_col("intended_site");
        $a=doquery();
        if($a)extract($a[0]);
    }

    #Cyl sizes
    $cylsize=ord_getCylSizeSelect("ord_prodCylSize",$prod_cyl_size_num,"ord_prodFormInput",($cylinder_id));#make readonly on edit if cyl already assigned..

    #Cal services/requests.  We'll select out all calservices left joined to ones selected for this order
    bldsql_init();
    $t=($product_num)?$product_num:-1;#For add mode, sub in bogus product so left join will still work.
    bldsql_from("calservice cs left join calrequest r on (cs.num=r.calservice_num and r.product_num=$t)");
    bldsql_orderby("case when cs.num=11 then 3 when cs.num=10 then 7 else cs.num end");
    bldsql_col("cs.num as calservice_num");
    bldsql_col("case when cs.num=9 then 'Flask isotopes' when cs.num=6 then 'SIL CO2' when cs.num=10 then 'SIL CH4' else cs.abbr_html end as species");
    bldsql_col("cs.abbr as species_abbr");
    bldsql_col("cs.unit_html as unit");
    bldsql_col("r.num as calrequest_num");
    bldsql_col("r.analysis_type_num");
    bldsql_col("r.calrequest_status_num");
    bldsql_col("r.target_value");
    bldsql_col("r.analysis_value");
    bldsql_col("r.comments as calrequest_comment");
    bldsql_col("r.num_calibrations");
    bldsql_col("r.highlight_comments");
    bldsql_where("cs.num!=7");#Hard dropping co2o18 from list.  Implied with co2c13 SIL orders.
    $rs_cs=doquery();

    #analysis types
    bldsql_init();
    bldsql_distinct();
    bldsql_col("num as value");
    bldsql_col("abbr as display_name");
    bldsql_from("analysis_type");
    bldsql_orderby("num");
    $rs_at=doquery();//hold off for loop below.



    #Build the list of calservices
    $csr="";
    if($rs_cs){
        foreach($rs_cs as $row){
            extract($row);
            $cl="ord_prodCSMember_${calservice_num}";
            $analtype=getSelectInput($rs_at,"ord_prodCSAnalType_${calservice_num}",$analysis_type_num,'',false,'100px',false,false,"ord_prodFormInput $cl ord_prodAnalTypeSelect");
            $checked=($calrequest_num)?"checked":"";
            $highlightChecked=($highlight_comments)?"checked":"";

            $csr.="
            <tr>
                <td>
                    <input class='ord_prodFormInput ord_prodCalSerivceCheckbox' type='checkbox' id='ord_prodCS_${calservice_num}' value='$calservice_num' name='ord_prodCS_include[]' $checked>
                    <input class='ord_prodFormInput $cl' type='hidden' name='ord_prodCalRequestNum_${calservice_num}' id='ord_prodCalRequestNum_${calservice_num}' value='$calrequest_num'>
                </td>
                <td class='data'><label for='ord_prodCS_${calservice_num}'>$species</label><input type='hidden' value='$species_abbr' name='ord_prodCSSpecies_${calservice_num}' id='ord_prodCSSpecies_${calservice_num}'</td>
                <td class='data'>
                    <input class='ord_prodFormInput $cl ord_prod_targetInput' type='text' size='10' value='$target_value' id='ord_prodCSTargetValue_${calservice_num}' name='ord_prodCSTargetValue_${calservice_num}'>
                </td>
                <td class='data'>$analtype</td>
                <td class='data'><input class='ord_prodFormInput $cl' type='text' id='ord_prodCSComment_${calservice_num}' name='ord_prodCSComment_${calservice_num}' value='$calrequest_comment'></td>
                <td><input class='ord_prodFormInput' type='checkbox' id='ord_prodCSHighlight_${calservice_num}' value='1' name='ord_prodCSHighlight_${calservice_num}' $highlightChecked></td>
                <td class='data'>
                    <input class='ord_prodFormInput $cl' type='text' size='3' value='$num_calibrations' id='ord_prodCSNumCalibrations_${calservice_num}' name='ord_prodCSNumCalibrations_${calservice_num}'>
                </td>
            </tr>
            ";
        }
    }

    $disabled=($product_num)?"":"disabled";#Only allow cloning an existing record.
    $intended_use_html=iu_getEditWidget($intended_use,$intended_site,'ord_prodFormInput');
    $csr="
    <table>
        <tr><th></th><th>Cal service</th><th>Target Value</th><th>Type</th><th>Calibration Comments</th><th>Highlight</th><th># Cals</th></tr>
        $csr
        <tr>
            <td colspan='3' align='left'>
                <button id='ord_prodDelBtn' $disabled>Remove</button>
                <button id='ord_prodFormClone' $disabled>Clone</button>
                x <input size='2' style='width:2em;' $disabled type='text' id='ord_prodCloneCopies' name='ord_prodCloneCopies' value='1'>

            </td>
            <td colspan='2'  style='border:thin silver solid;'>$intended_use_html</td>
            <td colspan='2' align='right'>
                <span id='ord_prodMessage'></span>
                <button id='ord_prodFormSaveBtn' disabled>Save</button>
            </td>
        </tr>
    </table>";

    $ro=($cylinder_id)?"disabled":"";
    $cylInput=ord_getCylinderInputHTML($cylinder_id,$ro);
    $html="
        <div id='ord_prodOuterDiv' class='ord_prodOuterDiv'>
            <form id='ord_prodForm' autocomplete='off' onsubmit='return false;'>
            <input type='hidden' id='ord_prodNum' name='ord_prodNum' value='$product_num'>
            <table width='100%' border='0'>
                <tr>
                    <td colspan='2' valign='top'>$cylInput</td>
                    <td class='label'>size</td><td class='data'>$cylsize</td>
                    <td class='label' style='text-align:left'>Filling Comments</td><td class='data'><textarea class='ord_prodFormInput' cols='30' rows='2' id='ord_prodComments' name='ord_prodComments'>$prod_comments</textarea></td>
                </tr>
                <tr><td align='left' colspan='6'><div id='ord_prodCylMssg'></div></td></tr>
                <tr><td align='left' colspan='6'>$csr</td></tr>
            </table>
            </form>

            <script language='JavaScript'>

                //Anal type changed, load previous cal into target_value
                $(\".ord_prodAnalTypeSelect\").change(function(event){
                    var id=event.target.id;
                    ord_loadTargValue(id);
                });

                //Enable save btn on data focus
                $(\".ord_prodFormInput\").focus(function(){
                   $(\"#ord_prodFormSaveBtn\").prop('disabled',false);

                });


                //Save btn
                $(\"#ord_prodFormSaveBtn\").click(function(){
                    //Post the edits.
                    var formData=ord_serializeProdForm();
                    ajax_post('ord_submitProduct',formData,'ord_prodMessage',i_ajax_req);
               });

               //Clone btn
               $(\"#ord_prodFormClone\").click(function(){
                    //Post the edits.
                    var formData=ord_serializeProdForm();
                    ajax_post('ord_cloneProduct',formData,'ord_prodMessage',i_ajax_req);
               });
               //Clone copies
               $(\"#ord_prodCloneCopies\").change(function(){
                    var val=$(this).val();
                    if(!$.isNumeric(val) && val!=''){
                        $(this).val('1');
                        alert('Invalid target value:'+val);
                    }
               });

               //Delete button
               $(\"#ord_prodDelBtn\").click(function(){
                    if(confirm(\"Remove product from this order?\")){
                        var formData=ord_serializeProdForm();
                        ajax_post('ord_deleteProduct',formData,'ord_prodMessage',i_ajax_req);
                    }
               })

               //checkbox handler logic
               $(\".ord_prodCalSerivceCheckbox\").click(function(){ord_prodCalSeriviceCheck();});
               ord_prodCalSeriviceCheck();//And once on load to set the initial state.

               //Target value validator
               $(\".ord_prod_targetInput\").change(function(){
                    var val=$(this).val();
                    if(val.toLowerCase() != 'ambient' && !$.isNumeric(val) && val!=''){
                        $(this).val('');
                        alert('Invalid target value:'+val);
                    }
               });

               //Target value click, select all
               $(\".ord_prod_targetInput\").click(function(){
                    $(this).select();
               });



            </script>
        </div>
    ";
    return $html;
}
function ord_deleteProduct(){
    $product_num=getHTTPVar('ord_prodNum',false,VAL_INT);
    $order_num=getHTTPVar("ord_orderNum",false,VAL_INT);
    $html="";
    if($order_num && $product_num){

        require_once("../CCGDB.php");
        require_once("../DB_Order.php");
        require_once("../DB_ProductManager.php");
        require_once("../Log.php");

        try{
            session_start();
                $database_object = new CCGDB();
                $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
            session_write_close();

            $product_object = new DB_Product($database_object, $product_num);
            if ( $product_object->isActive() ){
                $product_object->setOrder('');
                $product_object->saveToDB($user_obj);
            }else{
                $product_object->deleteFromDB($user_obj);
            }

            $js="ajax_get('ord_getProductList','order_num=$order_num&product_num=-1&mssg=Product Removed','ord_products',i_ajax_req);
            setStatusMessage('Product Removed',5);
            ";
            $html="Removed.
            <script language='JavaScript'>".delayedJSExec("$js")."</script>";
        }catch ( Exception $e ){
            $html.=$e->getMessage();
        }
    }
    return $html;
}
function ord_cloneProduct(){
    #clones the passed product
    $product_num="";
    $cylSize=getHTTPVar("ord_prodCylSize",false,VAL_INT);
    $prodComments=getHTTPVar("ord_prodComments");
    $order_num=getHTTPVar("ord_orderNum",false,VAL_INT);
    $numClones=getHTTPVar("ord_prodCloneCopies",false,VAL_INT);
    $includes=getHTTPVar("ord_prodCS_include",array(),VAL_ARRAY);#Selected calservices.
    $intended_use=getHTTPVar("intended_use",false,VAL_INT);
    $intended_site=getHTTPVar("intended_site",false,VAL_INT);
    if(!$order_num)return "Error: Missing order number!?!";
    $cylStatus=3;#Defaults to processing.
    $product_nums=array();

    require_once("../CCGDB.php");
    require_once("../DB_CalRequestManager.php");
    require_once("../DB_CalServiceManager.php");
    require_once("../DB_CylinderManager.php");
    require_once("../DB_Order.php");
    require_once("../DB_ProductManager.php");
    require_once("../Log.php");

    try{
        $html="";
        session_start();
            $database_object = new CCGDB();
            $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
        session_write_close();

        $order_object = new DB_Order($database_object, $order_num);
        for($i=1;$i<=$numClones;$i++){

            #insert product.
            $product_object = new DB_Product($database_object, $order_object,$cylSize);
            $product_object->setComments($prodComments);

            if ( ! $order_object->isPending() ){
                #May need to add back (if $task =='process' || not pending...)  I'm trying to do away with pending orders.
                $product_object->process();
            }

            $product_object->saveToDB($user_obj);
            if(!$product_num)$product_num=$product_object->getNum();#Fetch first new num

            #save off product_nums to update intentions later
            $product_nums[]=$product_object->getNum();

            #Insert cal requests
            foreach($includes as $csNum){
                $cs_reqNum=getHTTPVar("ord_prodCalRequestNum_${csNum}",false,VAL_INT);
                $cs_species=getHTTPVar("ord_prodCSSpecies_${csNum}");
                $cs_target=getHTTPVar("ord_prodCSTargetValue_${csNum}");
                $cs_analType=getHTTPVar("ord_prodCSAnalType_${csNum}",false,VAL_INT);
                $cs_comment=getHTTPVar("ord_prodCSComment_${csNum}");
                $cs_numCalibrations=getHTTPVar("ord_prodCSNumCalibrations_${csNum}");
                $cs_highlightComments=getHTTPVar("ord_prodCSHighlight_${csNum}",0,VAL_BOOLCHECKBOX);

                $calservice_object = new DB_CalService($database_object, $cs_species);
                $calrequest_object = new DB_CalRequest($database_object, $product_object, $calservice_object, $cs_target, $cs_analType, $cs_numCalibrations,$cs_highlightComments);

                $calrequest_object->setComments($cs_comment);
                $calrequest_object->process();
                $calrequest_object->saveToDB($user_obj);
            }

        }

        #Update intentions.. Have to do this outside of loop because old style resets db conn...
        db_connect("lib/config.php");
        foreach($product_nums as $p){
            if($intended_use || $intended_site) iu_updateProductIntentions($p,$intended_use,$intended_site);
        }
        $js="ajax_get('ord_getProductList','order_num=$order_num&product_num=$product_num&mssg=Product Cloned','ord_products',i_ajax_req);
            setStatusMessage('Product Cloned',5);
        ";
        $html="Cloned.
        <script language='JavaScript'>".delayedJSExec("$js")."</script>";


    }catch ( Exception $e ){
        $html.=$e->getMessage();
    }
    return $html;
}
function ord_submitProduct(){
    #Submits product add/edit to db

    $product_num=getHTTPVar('ord_prodNum',false,VAL_INT);
    $cylSize=getHTTPVar("ord_prodCylSize",false,VAL_INT);
    $cylID=getHTTPVar("ord_prodCylID");
    $prodComments=getHTTPVar("ord_prodComments");
    $order_num=getHTTPVar("ord_orderNum",false,VAL_INT);
    $includes=getHTTPVar("ord_prodCS_include",array(),VAL_ARRAY);#Selected calservices.
    $intended_use=getHTTPVar('intended_use',false,VAL_INT);
    $intended_site=getHTTPVar("intended_site",false,VAL_INT);
    if(!$order_num)return "Error: Missing order number!?!";
    $cylStatus=3;#Defaults to processing.
    $existingCalRequests=array();
    $existingCalServiceNums=array();
    $delCalReqs=array();
    $emailNotice="";

    #Find existing calrequests (so we know if any should be deleted).
    if($product_num){
        bldsql_init();
        bldsql_from("rgm_calrequest_view v");
        bldsql_where("order_num=?",$order_num);
        bldsql_where("product_num=?",$product_num);
        bldsql_col("calservice_num");
        bldsql_col("request_num");
        $a=doquery();
        if($a){
            $existingCalServiceNums=arrayFromCol($a,'calservice_num');
            $existingCalRequests=arrayFromCol($a,'request_num');
            #Figure out which to delete.
            $t=array_diff($existingCalServiceNums,$includes);#which calservices are no longer selected
            $delCalReqs=array_intersect_key($existingCalRequests,$t);#which calrequests are no longer selected.
        }
    }


    require_once("../CCGDB.php");
    require_once("../DB_CalRequestManager.php");
    require_once("../DB_CalServiceManager.php");
    require_once("../DB_CylinderManager.php");
    require_once("../DB_Order.php");
    require_once("../DB_ProductManager.php");
    require_once("../Log.php");

    try{
        $html="";
        session_start();
            $database_object = new CCGDB();
            $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
        session_write_close();



        $order_object = new DB_Order($database_object, $order_num);


        if($product_num){
            #Updating
            $product_object = new DB_Product($database_object, $product_num);

            #If cyl already attached, fetch the status
            if(is_object($product_object->getCylinder())){
                $cylStatus=$product_object->getCylinder()->getCheckInStatus('num');#
            }
            if($cylID){#set or reset cyl.
                $cylinder_object = new DB_Cylinder($database_object, $cylID, 'id');
                $product_object->setCylinder($cylinder_object);
                $product_object->setCylinderSize($cylinder_object->getSize());
                $product_object->getCylinder()->setCheckInStatus($cylStatus);
            }else{
                #set to empty.
                $product_object->setCylinder('');
                $product_object->setCylinderSize($cylSize);
            }
        }else{
            #inserting product.
            if($cylID){
                $cylinder_object = new DB_Cylinder($database_object, $cylID, 'id');
                $product_object = new DB_Product($database_object, $order_object, $cylinder_object->getSize());

                $product_object->setCylinder($cylinder_object);
                $product_object->getCylinder()->setCheckInStatus($cylStatus);
            }else{
                $product_object = new DB_Product($database_object, $order_object,$cylSize);
            }
        }

        $product_object->setComments($prodComments);

        if ( ! $order_object->isPending() ){
            #May need to add back (if $task =='process' || not pending...)  I'm trying to do away with pending orders.
            $product_object->process();
        }


        $product_object->saveToDB($user_obj);
        if(!$product_num)$product_num=$product_object->getNum();#Fetch new num on adds


        #Delete any removed calrequests.
        foreach($delCalReqs as $key=>$val){
            $calrequest_object = new DB_CalRequest($database_object, $val);
            $calrequest_object->deleteFromDB($user_obj);
            #Send an email to cal manager to notify that it's been removed.
            try{
               # Only when it's 'in processing'
               if ( $calrequest_object->getStatus('num') == '2'  && $cylID){
                  $email_subject = "Cylinder ID '$cylID' no longer needs '".$calrequest_object->getCalService()->getAbbreviation()."' analysis.";
                  $message="Hello.<br> $cylID ".$calrequest_object->getCalService()->getAbbreviation()." analysis has been removed from order $order_num and no longer needs to be done.  Please remove it from any offline todo list you may have.";
                  $calrequest_object->emailUsers($email_subject,$message);
                  $emailNotice="Sending email notice to appropriate users.";

               }
            }catch ( Exception $e ){
               $emailNotice.="There was an error sending email to cal manager. ".$e->getMessage();
            }
        }
        #Insert/Update any others..
        foreach($includes as $csNum){
            $cs_reqNum=getHTTPVar("ord_prodCalRequestNum_${csNum}",false,VAL_INT);
            $cs_species=getHTTPVar("ord_prodCSSpecies_${csNum}");
            $cs_target=getHTTPVar("ord_prodCSTargetValue_${csNum}");
            $cs_analType=getHTTPVar("ord_prodCSAnalType_${csNum}",false,VAL_INT);
            $cs_comment=getHTTPVar("ord_prodCSComment_${csNum}");#NOTE; capital P in name.. obviously typo
            $cs_numCalibrations=getHTTPVar("ord_prodCSNumCalibrations_${csNum}",'',VAL_INT);#Default to empty string, db_calrequest will sub in default values.
            $cs_highlightComments=getHTTPVar("ord_prodCSHighlight_${csNum}",0,VAL_BOOLCHECKBOX);

            if($cs_reqNum){
                $calrequest_object = new DB_CalRequest($database_object, $cs_reqNum);
                $calrequest_object->setTargetValue($cs_target);
                $calrequest_object->setAnalysisType($cs_analType, 'num');
                #print("<script language='JavaScript'>alert('".$cs_numCalibrations."');</script>");
                $calrequest_object->setNumCalibrations($cs_numCalibrations);
                $calrequest_object->setHighlightComments($cs_highlightComments);
            }else{
                $calservice_object = new DB_CalService($database_object, $cs_species);
                $calrequest_object = new DB_CalRequest($database_object, $product_object, $calservice_object, $cs_target, $cs_analType,$cs_numCalibrations,$cs_highlightComments);
            }
            $calrequest_object->setComments($cs_comment);
            $calrequest_object->process();
            $calrequest_object->saveToDB($user_obj);
        }

        #update intended use/site
        db_connect("lib/config.php");#not sure why i need to reconnect, something about above class resets db conn.
        if(iu_updateProductIntentions($product_num,$intended_use,$intended_site)===False)throw new Exception('error updating intended use/site');

	#check to see if only calservice was a AMB (no fill) and mark as complete if so.
	$sql="select num from calrequest where product_num=? and calservice_num=14 and not exists (select * from calrequest where product_num=? and calservice_num!=14)";
	$amb_num=doquery($sql,0,array($product_num,$product_num));
	if($amb_num){
		#mark both calrequest and product as complete
		doupdate("update calrequest set calrequest_status_num=3 where num=?",array($amb_num));
		doupdate("update product set product_status_num=3 where num=?",array($product_num));
	}
        $js="ajax_get('ord_getProductList','order_num=$order_num&product_num=$product_num&mssg=Product Saved. $emailNotice','ord_products',i_ajax_req);
            setStatusMessage('Product Saved.  $emailNotice',5);
        ";
        $html.="Saved.
        <script language='JavaScript'>".delayedJSExec("$js")."</script>";


    }catch ( Exception $e ){
        $html.=$e->getMessage();
    }
    return $html;
}
function ord_deleteProdExtra($product_num){//Not actually used yet (or tested). but will get linked to cyl check script

    require_once("../CCGDB.php");
    require_once("../DB_CalRequestManager.php");
    require_once("../DB_CalServiceManager.php");
    require_once("../DB_CylinderManager.php");
    require_once("../Log.php");
    #require_once("/var/www/html/inc/ccgglib_inc.php");
    #require_once "utils.php";
    #require_once "menu_utils.php";
    $html="";
    session_start();
    $database_object = new CCGDB();
    $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
    session_write_close();

    try{
        $product_object = new DB_Product($database_object, $product_num);
        $product_object->deleteFromDB($user_obj);
        $html="Product successfully removed.
            <script language='JavaScript'>
                setTimeout(function(){//Recheck and update size.
                    $(\"#ord_prodCylID\").change();
                },100);
            </script>
        ";
    }catch ( Exception $e ){
        $html.=$e->getMessage();
    }
    return $html;
}
function ord_cylinderCheck($cylinderID,$fix=false,$srcScreen='edit'){
    /*This does some prechecks/data manipulation when a cylinder is added to a product.
     *It doesn't actually add to the product, but will check for any descrepancies and offer to fix them ($fix=true)
     *prior to saving (when Dan's full checks kick in).
     *$cylinderID is target cyl
     *$prodcutID is  to or blank for new product
     *$fix=true to automatically fix up issues (not implemented yet.)
     *
     *
     *NOTE; assumes use  of ord_getCylinderInputHTML() to generate cylinder input html.
     *
     *...Eventually, we'll upgrade this to be able to remove from orders/delete product extras and email cal managers,
     *for now, we'll just provide links to relevant screens.
     #We add some custome output if the source screen for the checks is on the order edit screen.
     **/
    $html="";

    #First check if cyl has been added to rgm yet
    bldsql_init();
    bldsql_from("cylinder c");
    bldsql_where("c.id=?",$cylinderID);
    bldsql_col("c.num");
    $cyl_num=doquery('',0);

    if(!$cyl_num){
        #Cyl hasn't been added, offer to add
        if($srcScreen=='edit'|| $srcScreen=='fill') $html.=ord_getAddCylinderForm($cylinderID);
        else{
            $html.="This cylinder has not been added to RGM yet.  <a href='cylinder_edit.php?action=add'>Add</a>";
        }

    }else{
        $oOrderNum="";$oProductNum="";
        #Cyl there, see if attached to another product.
        bldsql_init();
        bldsql_from("rgm_product_view v left join order_tbl o on v.order_num=o.num");
        bldsql_where("v.cylinder_num=?",$cyl_num);
        bldsql_where("( (o.order_status_num not in (5,7,9)) or o.num is null)");
        bldsql_col("v.order_num as oOrderNum");
        bldsql_col("v.product_num as oProductNum");
        $a=doquery();
        $new=uniqid("_new");
        if($a){
            /*TODO: For now we'll just link to attached order/prod extra.  We may want to offer to delete directly. (use ord_deleteProdExtra when programming*/
            extract($a[0]);
            if($oOrderNum){
                if($srcScreen=='edit' || $srcScreen=='fill')$html.="This cylinder is currently assigned to order number $oOrderNum.  It must be removed before you can add it to this order.
                <a href='index.php?mod=editOrder&order_num=$oOrderNum' target='$new'>Open order in new window</a>";
            }else{
                $i=uniqid();
                $html.="This cylinder is currently attached to a product extra.  <a href='product_extra_edit.php?num=$oProductNum&randnum=$i' target='$new'>Open product extras in new window</a>.";
            }
            if($srcScreen=='edit' || $srcScreen=='fill')$html.="<br><br><button id='recheckCylBtn'>Re-check cylinder</button><br>
            <script language='JavaScript'>
                $(\"#recheckCylBtn\").click(function(){
                    $(\"#ord_prodCylID\").change();//Recheck
                })
            </script>";
        }else{
            #It made it through out checks.. update the size
            if($srcScreen=='edit'){
                bldsql_init();
                bldsql_from("cylinder c");
                bldsql_where("c.id=?",$cylinderID);
                bldsql_col("c.cylinder_size_num");
                $cylSize=doquery('',0);
                $html.="
                    <script language='JavaScript'>
                        $(\"#ord_prodCylSize\").val($cylSize);//update
                    </script>";
            }elseif($srcScreen=='fill'){
                #pull up dot and fill date entry form inputs
                $html.="<script>ajax_get('cf_getCylFormDependents','cyl_num='+$cyl_num,'cf_formDiv',i_ajax_req)</script>";
            }

        }
    }

    return $html;
}
function ord_getCylinderInputHTML($cylinderID='',$ro=false,$srcScreen=''){
    #Helper function to put this logic in one place. Returns a self contained table
    $srcScreen=($srcScreen)?"+'&ord_cylCheckSrc=$srcScreen'":"";
    $html="
    <table><tr><td class='label'>Cylinder</td><td class='data'><input type='text' id='ord_prodCylID' name='ord_prodCylID' size='10' value='$cylinderID' $ro class='ord_prodFormInput'></td</tr>
        <tr><td colspan='2'><div id='ord_prodCylMssg'></div></td></tr></table>
    <script language='JavaScript'>
        $(\"#ord_prodCylID\").focus(function(){
           $(\"#ord_prodCylMssg\").empty();//Clear out any previous messages.
        });
        //Some cylinder pre-checks
        $(\"#ord_prodCylID\").change(function(){
         var cyl=$(this).val();
         if(cyl!=''){
             ajax_get('ord_cylinderCheck','cylinderID='+cyl${srcScreen},'ord_prodCylMssg',i_ajax_req);
         }
        });
    </script>
    ";
    return $html;
}
function ord_getCylSizeSelect($id,$val='',$class='',$disabled=false){#helper for code reuse..
    bldsql_init();
    bldsql_distinct();
    bldsql_col("num as value");
    bldsql_col("abbr as display_name");
    bldsql_from("cylinder_size");
    bldsql_orderby("num");
    $cylsize=getSelectInput(doquery(),"$id",$val,'',false,'100px',$disabled,false,$class);
    return $cylsize;
}
#Add cyl
function ord_getAddCylinderForm($cylinderID){
    /*$cylinderID is the id/serial num of cyl to add
     *
     *Note; assumes use of ord_getCylinderInputHTML to get cylinder input html (for names).
     */
    $cylinderInputID='ord_prodCylID';
    $cylinderMssgDivID='ord_prodCylMssg';
    $cylsize=ord_getCylSizeSelect("ord_addCylSize");
    #cyl type
    bldsql_init();
    bldsql_from("cylinder_type");
    bldsql_col("num as value");
    bldsql_col("abbr as display_name");
    $type=getSelectInput(doquery(),'ord_addCylType',1,'',false,'100px',false,false);
    $html="<div id='ord_addCylDiv'>
        <div class='title4'>This cylinder needs to be added to RefGas Manager.</div><br>
        <form id='ord_addCylinderForm'>
        <input type='hidden' id='ord_addCylID' name='ord_addCylID' value='$cylinderID'>
            <table>
                <tr><td class='label'>Cylinder ID:</td><td class='data'>$cylinderID</td></tr>
                <tr><td class='label'>Size:</td><td class='data'>$cylsize</td></tr>
                <tr><td class='label'>DOT Date:</td><td class='data'><input id='ord_addCylDOT' value='99-99' name='ord_addCylDOT' type='text' size='5'></td></tr>
                <tr><td class='label'>Type</td><td class='data'>$type</td></tr>
                <tr><td class='label'>Comment:</td><td class='data'><textarea id='ord_addCylComment' name='ord_addCylComment' cols='20' rows='4'></textarea></td></tr>
            </table>
                  <!-- Allow form submission with keyboard without duplicating the dialog button -->
                    <input type=\"submit\" tabindex=\"-1\" style=\"position:absolute; top:-1000px\">
        </form>
        </div>
        <script language='JavaScript'>
            var addCylForm=$(\"#ord_addCylinderForm\");
            var dialog=$(\"#ord_addCylDiv\").dialog({
               title:\"Add Cylinder\",
               autoOpen:true,
               height:350,
               width:350,
               modal: true,
               buttons:[{
                    text:\"Cancel\",
                    click: function(){
                        dialog.dialog( \"close\" );
                    }
               },{
                    text:\"Submit\",
                    click: function(){
                        addCylForm.submit();
               }
               }],
               close: function(){
                    $(this).dialog('close');
                    $(this).dialog('destroy').remove();//Need to do this to remove from the dom.
                    $(\"#$cylinderInputID\").val('');
                    $(\"#$cylinderMssgDivID\").empty();
               }

            });
            $(\"#ord_addCylinderForm\").on( \"submit\", function( event ) {
                event.preventDefault();

                //Check the dot date format (mm-yy)
                var dt=$(\"#ord_addCylDOT\");
                var recertification_date_patt=/^[0-9]{2}\-[0-9]{2}$/;
                if ( ! recertification_date_patt.test(dt.val()) ){
                   alert('Please input a valid DOT date (MM-YY)');
                   dt.val('');
                   dt.focus();
                   return false;
                }

                var formData=addCylForm.serialize();
                dialog.dialog( \"close\" );//Must do this before posting (so it clears val before post has a chance to return)
                ajax_post('ord_addCyl',formData,'$cylinderMssgDivID',i_ajax_req);
                $(\"#$cylinderMssgDivID\").html(\"Submitting.... <image src='j/images/ajax-loader2.gif'>\");
              });
            dialog.keypress(function(e){
                if(e.keyCode==$.ui.keyCode.ENTER){
                    addCylForm.submit();
                }
            });

        </script>
    ";
    return $html;
}
function ord_addClyinder(){
    #Add posted cylinder to refgas mgr db
    $cylinderID=getHTTPVar("ord_addCylID");
    $size=getHTTPVar("ord_addCylSize",false,VAL_INT);
    $dot=getHTTPVar("ord_addCylDOT",'');
    $comment=getHTTPVar("ord_addCylComment");
    $type=getHTTPVar("ord_addCylType",false,VAL_INT);
    $html="";
    if($cylinderID && $size && $dot){
        #Load up class structures
        require_once "../CCGDB.php";
        require_once "../DB_Cylinder.php";
        require_once "../Log.php";
        session_start();
        $db = new CCGDB();
        $user = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
        if($db && $user){
            try
              {
                 $cylinder_obj = new DB_Cylinder($db, $cylinderID, $dot);

                 $location_obj = new DB_Location($db, '1');
                 $cylinder_obj->checkin($location_obj);

                 $cylinder_obj->setComments($comment);

                 $cylinder_obj->setSize($size);
                 $cylinder_obj->setType($type);#For our purposes, hard code to 'normal' not archive

                 $cylinder_obj->saveToDB($user);

                 # Use the object to print the ID so that it is the same case as
                 #  the database entry.  Reset into field and fire change event again (mostly to set size)
                 $html.="<DIV align='center' style='color:green'>".$cylinder_obj->getID()." added successfully.</DIV>
                 <script language='JavaScript'>
                    var t=$(\"#ord_prodCylID\");
                    t.val(\"".$cylinder_obj->getID()."\");
                    setTimeout(function(){t.change();},100);
                 </script>
                 ";


                 # Create tank barcode label
                 system("/projects/refgas/label/tanklabelmaker.pl '".escapeshellarg($cylinder_obj->getID())."'", $errcode);

                 if ( $errcode != 0 )
                 { throw new LogicException("Failed to create tank barcode label."); }

              }
              catch (Exception $e)
              { $html.="Error: ".$e->getMessage(); }
        }else $html="Invalidated session object!";
    }else $html="Missing required fields; Cylinder ID, Cylinder Size & valid DOT date";
    return $html;
}

function ord_editSideBar($order_num=""){
    #Content for the left sidebar area.
    #Note, some callers expect returned html to have no double quotes (so it can be passed to js function).. so don't add any!
    #Note we used to make the return link include order num, but now do it in session to cause less confusion. (hopefully). So passed order num is a no-op

    $html="<br><span class='title4' >&larr;<a href='index.php?mod=orders'>Back to Orders</a></span>";
    return $html;
}

?>
