<?php
#Various functions for the orders module.
require_once("editOrders_funcs.php");

/*
To add a new species/calservice you need to:
-add to the calservice table in db
-edit ord_printCylSheets() (make sure all print on one sheet.)


*/
#Orders list/search

function ord_loadList(){
    #Load the list of orders using passed search criteria.
    $html="";$js="";
    $label="'None'";#this is a js string, built below.  see down there for comments.

    $type=getHTTPVar("ord_ordType",false,VAL_INT);
    $num=getHTTPVar("ord_ordNum",false,VAL_INT);
    $org=getHTTPVar("ord_organization");
    $cust=getHTTPVar("ord_custID",false,VAL_INT);
    $cylinder=getHTTPVar("ord_cylID");
    $mou=strtoupper(getHTTPVar("ord_MOU"));
    $selectedOrder=getHTTPVar("ord_selectedOrder");

    #Save off filters for possible defaults when page is next loaded.
    ord_setFilterDefaults($num,$mou,$cylinder,$type,$org,$cust,$selectedOrder);

    doquery("drop temporary table if exists t_calcounts,t_calcounts2,t_calcounts3",false);
    $sql="create temporary table t_calcounts as
            select order_num, calrequest_status_num as status,count(distinct cylinder_id) as c
            from rgm_calrequest_view
            group by order_num,status";
    doquery($sql,false);
    doquery("create temporary table t_calcounts2 as select * from t_calcounts",false);
    doquery("create temporary table t_calcounts3 as select * from t_calcounts",false);
    bldsql_init();

    bldsql_col("v.order_num as onClickParam");
    bldsql_col("v.order_num as 'Order #'");
    bldsql_col("v.MOU_number as 'MOU #'");
    bldsql_col("v.organization as 'Organization'");
    $status="concat(\"<span style='white-space: nowrap;'><span class='statusbox \",
            case when datediff(v.due_date,now())<15 then 'red' when datediff(v.due_date,now())<31 then 'yellow' else 'green' end,
            \"'>&nbsp;&nbsp;</span></span>&nbsp;\",v.due_date)";
    bldsql_col("$status as 'Due Date'");
    bldsql_col("date(v.creation_datetime) as Created");
    bldsql_col("v.order_status as 'Status'");
    bldsql_col("v.pri_cust_email as 'Customer'");
    bldsql_col("wait.c as '# Cyl not ready'");
    bldsql_col("proc.c as '# Processing'");
    bldsql_col("compl.c as '# Complete'");

    #return bldsql_printableQuery();
    if($num){
        #Num overrides any other filters
        bldsql_where("v.order_num=?",$num);
        $label='"Order #'.$num.'"';

    }elseif($mou){
        #So does entering an MOU number
        bldsql_where("upper(v.MOU_number)=?",$mou);
        $label='"MOU #'.$mou.'"';

    }else{
        $sep="";
        if($type){
            bldsql_where("v.order_status_num=?",$type);
            $label='$("#ord_ordType option:selected").text()';//Kind of confusing because its a js var.  This is so we can get the desplay text
            $sep=" |";
        }
        if($org){
            bldsql_where("v.organization=?",$org);
            $label.="+'$sep ".$org."'";
            $sep=" |";
        }
        if($cust){
            bldsql_where("v.pri_cust_id=?",$cust);
            $label.="+'$sep '+$(\"#ord_custID_display\").val()";#again, confusing js var... this is way too complicated for a f'n label.  This should be ripped out.
            $sep=" |";
        }
        if($cylinder){
            bldsql_distinct();
            bldsql_from("product p");
            bldsql_from("cylinder c");
            bldsql_where("p.cylinder_num=c.num");
            bldsql_where("p.order_num=v.order_num");
            bldsql_where("lower(c.id) like ?",strtolower("%${cylinder}%"));
            $label.="+'$sep Cylinder ".$cylinder."'";

        }
    }
    $sql="rgm_order_view v left join t_calcounts compl
            on (compl.order_num=v.order_num and compl.status=3)
                left join t_calcounts2 proc on (proc.order_num=v.order_num and proc.status=2)
                    left join t_calcounts3 wait on(wait.order_num=v.order_num and wait.status=4)";
    bldsql_from($sql);#We want other joins to come before these left joins.
    bldsql_orderby("v.order_num desc");
    #return bldsql_printableQuery();
    $a=doquery();
    #var_dump($a);exit;
    $divID=uniqid();

    $html=printTable($a,"ord_loadOrder",1,'','','',$divID,$selectedOrder);

    $js.=($a)?"setStatusMessage(\"".count($a)." matching orders.\",10);":"";

    if($a && count($a)==1){#If only 1 row returned, auto select it.
        #$n=$a[0]['onClickParam'];ord_loadOrder($n);
        $js.="$(\"#${divID} tr:nth-child(1)\").click();";
    }
    $html.='<script language="JavaScript">
                var title='.$label.';
                title="Orders <span class=\'title4\'>(Filter:"+title+")</span>";
                $("#listTitle").html(title);
                '.$js.'
            </script>';
    return $html;
}
function ord_loadOrder($orderNum){
    /*Returns html contents of order for display on order summary page... originally this was going to be the edit page too (hence form objects), but that's now separate.*/
    ord_setFilterDefaultsSelectedOrder($orderNum);#Set this as the 'selected' order (for page refresh and back button).

    bldsql_init();
    bldsql_from("rgm_order_view v");
    bldsql_col("v.order_num");
    bldsql_col("v.organization");
    bldsql_col("v.pri_cust_email");
    bldsql_col("v.pri_cust_id");
    bldsql_col("v.creation_datetime");
    bldsql_col("v.due_date");
    bldsql_col("v.MOU_number");
    bldsql_col("v.order_status");
    bldsql_col("v.order_status_num as statNum");
    bldsql_col("v.comments");
    bldsql_col("invoice_submit_dt");
    bldsql_col("invoice_cost");
    bldsql_col("ship_date");
    bldsql_col("ship_cost");
    bldsql_where("v.order_num=?",$orderNum);
    $a=doquery();
    $html="";$order_num="";$organization="";$pri_cust_email="";$pri_cust_id="";$creation_datetime;$statNum=0;$comments="";
    if($a){extract($a[0]);}
    $commentBtn=($comments)?getPopUp($comments,"..."):"";
    #$commentBtn="<span style='float:right;'>$commentBtn</span>";
    $comments="<div style='width:250px;height:35px; border:thin silver solid;overflow-y:auto'>$comments</div>";
    #Customer email
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.pri_cust_id as value");
    bldsql_col("r.pri_cust_email as display_name");
    bldsql_from("rgm_order_view r");
    bldsql_where("r.pri_cust_id != ''");
    bldsql_orderby("r.pri_cust_email");
    $cust="<select disabled class='ord_editable' id='ord_priCustID' name='ord_priCustID' style='max-width:275px;min-width:275px;'>
            ".getSelectInputOptions(doquery(),$pri_cust_id,true)."</select>";
    $inv=($invoice_submit_dt||$invoice_cost)?"<td class='label'>Invoiced:</td><td>$invoice_submit_dt for $${invoice_cost}</td>":"<td colspan='2'></td>";
    $ship=($ship_date||$ship_cost)?"<td class='label'>Shipped:</td><td>$ship_date for $${ship_cost}</td>":"<td colspan='2'></td>";
    $html="<div class='data' style='width:100%;min-width:750px;height:100%;border:thin black solid;background-color:#DCDCDC' >
    <form id='ord_orderEditForm' onsubmit='return false;'>
    <input type='hidden' name='ord_orderNum' id='ord_orderNum' value='$orderNum'>
    <table width='800'>
        <tr>
            <td class='label'>Order #:</td><td class='data'>$order_num</td>

            <td class='label'>Order status:</td><td class='data' style='font-style: italic'>$order_status</td>

        </tr>
        <tr>
            ".ord_getFormInputTR('ord_organization','Organization',$organization)."
            <td class='label'>Customer email:</td><td class='data'>$cust</td>
        </tr>
        <tr>
            <td class='label'>Due date:</td>
            <td class='data'>
                <input size='10' class='ord_editable' type='text' id='ord_dueDate' name='ord_dueDate' readonly value='$due_date'>
                <button class='ord_dueDateButtons' id='ord_minusDueDate' >-</button><button class='ord_dueDateButtons' id='ord_plusDueDate'>+</button>
                <span id='ord_dueDateJSDiv' class='title4'></span><span id='ord_dueDateMssgDiv' ></span>
                <script language='JavaScript'>
                    $(\"#ord_minusDueDate\").click(function(){
                        $(\".ord_dueDateButtons\").prop('disabled',true);
                        ajax_post('ord_updateDueDate','order_num=$order_num&ord_updateDueDateNum=-1','ord_dueDateJSDiv',i_ajax_req);
                    });
                    $(\"#ord_plusDueDate\").click(function(){
                        $(\".ord_dueDateButtons\").prop('disabled',true);
                        ajax_post('ord_updateDueDate','order_num=$order_num&ord_updateDueDateNum=1','ord_dueDateJSDiv',i_ajax_req);
                    });
                </script>
            </td>

            ".ord_getFormInputTR('ord_mouNum','MOU #',$MOU_number)."
        </tr>
        <tr>
            <td class='label'>Comments:</td><td class='data' valign='top' style='vertical-align: text-top;'>$comments</td>
            <td colspan='2'>
                <table>
                    <tr><td class='label'>Created:</td><td align='left' class='data'>$creation_datetime</td></tr>
                    <tr><td colspan='2'><table><tr><td>$inv $ship</td></tr></table></td></tr>
                </table>
            </td>
        </tr>

    </table>
    </form>
    <table>
        <tr>
            <td><div style='height:140px;overflow:auto;'>".ord_loadProductDetails($order_num)."</div></td>
            <td><div  id='calReqDiv'></div></td>
        </tr>
    </table><br><div style='width:100%;text-align:center'>";

    #Build up the button links.

    #build a popup form to zip certificates ord_zipCertificates
    $zipCertsBtn=ord_getZipCertsButton($orderNum);

    $editLink="index.php?mod=editOrder&order_num=$order_num";
    #$editLink="order_edit.php?num=$order_num&rand=".uniqid();
    if($statNum==1 || $statNum==2 || $statNum==3){

        $html.="<A href='$editLink'><INPUT type='button' value='Edit order'></A>";

        #build a popup form to print cylinder sheets
        $formData=ord_getPrintCylinderForm($orderNum);
        $html.="<div style='display:inline' id='ord_cylSheetDiv'></div>
        ".getPopUpForm($formData,"Print cylinder sheets","Select cylinders to print","Print cylinder sheets","ord_printCylSheets","ord_cylSheetDiv",'');

        $n=doquery("select count(*) from rgm_calrequest_view where order_num=$orderNum and (product_status_num=3 or calrequest_status_num=3)",0);
        if($n)$html.="<A href='order_finalapproval.php?num=$order_num'><INPUT type='button' value='Final approval'></A>";

        # If a product is 'ready to ship' then provide the ability to upload shipping  documents
        $n=doquery("select count(*) from rgm_calrequest_view where order_num=$orderNum and product_status_num=6",0);
        if ($n)$html.="<A href='order_ship-docs.php?num=$order_num'><INPUT type='button' value='Shipping documents'></A>";

        $html.="<A href='order_certificates.php?num=$order_num'><INPUT type='button' value='Make certificates'></A>";

        #If any certs are available, make zippable.
        $html.=$zipCertsBtn;
    }elseif ( $statNum == 4 ){
        # If order is 'processing complete' we still need the final approval step
        $html.="<A href='$editLink'><INPUT type='button' value='Edit order'></A>";
        $html.="<A href='order_finalapproval.php?num=$order_num'><INPUT type='button' value='Final approval'></A>";
        $html.="<A href='order_ship-docs.php?num=$order_num'><INPUT type='button' value='Shipping documents'></A>";
        $html.="<A href='order_certificates.php?num=$order_num'><INPUT type='button' value='Make certificates'></A>";
        $html.=$zipCertsBtn;
    }elseif ( $statNum==6 ){
        # If order is 'Ready to ship' then display the edit order,  shipping docs page and
        #   order complete button
        $html.="<A href='$editLink'><INPUT type='button' value='Edit order'></A>";
        $html.="<span id='${order_num}_completeResponseDiv'></span>".getConfirmationButton("Complete order","Mark this order completed?","ord_completeOrder($order_num)");
        #$html.="<INPUT type='button' value='Complete order' onClick='CompleteCB()'>";
        $html.="<A href='order_ship-docs.php?num=$order_num'><INPUT type='button' value='Shipping documents'></A>";
        $html.="<A href='order_certificates.php?num=$order_num'><INPUT type='button' value='Make certificates'></A>";
        $html.=$zipCertsBtn;
    }elseif ( $statNum == 5 ){
        # If order is 'order complete' then we need to provide functions for
        #  adding shipping documents and creating certificates
        $html.="<A href='$editLink'><INPUT type='button' value='Edit order'></A>";#Added edit in on request from duane.
        $html.="<A href='order_ship-docs.php?num=$order_num'><INPUT type='button' value='Shipping documents'></A>";
        $html.="<A href='order_certificates.php?num=$order_num'><INPUT type='button' value='Make certificates'></A>";
        $html.=$zipCertsBtn;
    }elseif ($statNum == 8 ){
        $html.="<A href='$editLink'><INPUT type='button' value='Edit order'></A>";
    }
    #add a delete button if there are no products associated with order.
    $n=doquery("select count(*) from product where order_num=?",0,array($order_num));
    if($n==0)$html.=" ".getJSButton('delOrdButton','ord_deleteOrder','Delete Order',$order_num,'','Are you sure you want to delete this order?')."<div id='ordDeleteMssgDiv'></div>";

    $html.="</div></div>";

    return $html;
}
function ord_deleteOrder(){
	#delete order with no products
	$html='';
	#Load user info from session for logging.
    setLoggingUser();
	$order_num=getHTTPVar("order_num",false,VAL_INT);
    $n=doquery("select count(*) from product where order_num=?",0,array($order_num));
    if($n==0){
        if(doupdate("delete from order_tbl where num=?",array($order_num))!==false){
            $html="<script>".delayedJS('i_loadList();')."</script>";
        }else $html="Error deleting this order";
    }else $html="This order can't be deleted because it has associated products.  Delete those first.";

	return $html;
}
function ord_completeOrder($order_num){
    $html="";
    if($order_num){
        require_once("../CCGDB.php");
        require_once("../DB_Order.php");
        #require_once("../DB_ProductManager.php");
        require_once("../Log.php");

        try{
            session_start();
                $database_object = new CCGDB();
                $order_object = new DB_Order($database_object, $order_num);
                $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
            session_write_close();

            # Mark the order as 'order complete'
            $order_object->complete();
            $order_object->saveToDB($user_obj);

            $js="ord_loadOrder($order_num);setStatusMessage('Order completed.',5);";
            $html="<script language='JavaScript'>".delayedJSExec("$js")."</script>";
        }catch ( Exception $e ){
            $html.=getPopupAlert($e->getMessage());
        }
    }
    return $html;
}

/*Zip certificates */
function ord_getZipCertsButton($order_num){
    #build a popup form to zip certificates
    $zipCertsBtn="";
    $formData=ord_getZipCertificatesFormInput($order_num);
    if($formData)$zipCertsBtn="<div style='display:inline' id='ord_certZipDiv'></div>".getPopUpForm($formData,"Zip certificates","Select certificates to zip","Zip certficates","ord_zipCertificates","ord_certZipDiv",'');
    return $zipCertsBtn;
}
function ord_getZipCertificatesFormInput($order_num){
    #Returns inputs to select certificates for zipping
    $html="";
    $certs=ord_getCertificateFiles($order_num);
    if($certs){
        $a=array();
        foreach($certs as $file){#Split into name/value pairs.
            $filename=basename($file);
            $a[]=array('value'=>$filename,'display_name'=>$filename);#Create an array in the same format as a db results array so we can use utility functions.
        }
        if($a){
            $html.="<input type='hidden' name='order_num' value='$order_num'>".
                getCheckBoxInputArray($a,"ord_certsToZip",'',true);
        }
    }
    return $html;
}
function ord_getCertificateFiles($order_num){
    #Retrieves filenames of any available (created) certificates for passed order.
    #Note I initially tried to use the class obj method for this (DB_Product->getAnalysisDocuments()), but the overhead
    #was tremendous, so just querying directly now.  These methods' logic should be kept in sync.

    $certs=array();
    if($order_num){
        bldsql_init();
        bldsql_from("rgm_product_view v");
        bldsql_where("v.order_num=?",$order_num);
        bldsql_col("v.product_num");
        $a=doquery();

        if($a){
            $nums=arrayFromCol($a,"product_num");
            foreach($nums as $num){
                $target = "../documents/*_P".$num.".pdf";#Note path is relative to calling file (rgm/j/switch.php)
                $files = glob($target);
                $certs=array_merge($certs,$files);
            }
        }
    }
    return $certs;
}
function ord_zipCertificates(){
    #Zip up passed certs ($_REQUEST) and put on nfs drive.
    $out="";
    $destFolder="/ccg/refgas/rgm_cert-rep/";
    #var_dump($_REQUEST);
    $order_num=getHTTPVar("order_num",false,VAL_INT);
    $certs=getHTTPVar("ord_certsToZip",array(),VAL_ARRAY);
    if($order_num && $certs){
        $cwd=getcwd();#Remember our current loc.
        chdir("../documents");#Change into the docs dir so that we don't create a dir structure in zip file.  Our cwd is j(switch.php).

        $filename="ordnum_".$order_num."_documents_".date('Y-m-d').".zip";

        if(file_exists($filename))unlink($filename);#Delete any created today, on assumption that we are re-running.  Leave any previous days entries though.
        $cmd="zip ".$destFolder.$filename;
        foreach ($certs as $cert){
            $cmd.=" $cert";
        }
        exec($cmd,$output,$return);
        if($return)$out="Error creating zip ($return):<br>".join("<br>",$output);
        elseif(!file_exists($destFolder.$filename)){$out="Error: Zip file not created.<br>$cmd";}
        else $out="Created zip:<br><b>$filename</b><br><br> in directory:<br><b>$destFolder</b><br>";

        chdir($cwd);#just for cleanliness, switch back.
    }else $out="Error: invalid order or no certificates selected";
    if($out){return getPopupAlert($out,true,"Zip certificates");}
}


/*Print cylinder sheets */
function ord_getPrintCylinderForm($order_num){
    /*Returns a form inputs to select cyls for printing*/
    $html="";
    bldsql_init();
    bldsql_distinct();
    bldsql_from("rgm_calrequest_view");#This filters out ones with no calservices requested.
    bldsql_where("order_num=?",$order_num);
    bldsql_where("cylinder_id is not null");
    bldsql_col("cylinder_num as value");
    bldsql_col("cylinder_id as display_name");
    #bldsql_col("1 as selected");
    bldsql_orderby("cylinder_id");
    $a=doquery();
    if($a){
        $html.="<input type='hidden' name='order_num' value='$order_num'>".
                getCheckBoxInputArray($a,"ord_cylsToPrint",'',true);

    }else $html="No cylinders assigned yet.";


    return $html;
}
function ord_printCylSheets(){
    #Prints selected cylinders
    $order_num=getHTTPVar("order_num",false,VAL_INT);
    $cyls=getHTTPVar("ord_cylsToPrint",array(),VAL_ARRAY);
    $pageWidth="7.5in";$labelWidth="3.5in";
    $html="<div id='outerTable'><table style='padding:2px;'>";
    bldsql_init();
    bldsql_from("rgm_calrequest_view v");
    bldsql_where("v.order_num=?",$order_num);
    bldsql_col("v.cylinder_id");
    bldsql_col("v.organization");
    bldsql_col("(SELECT concat(date,case when isnull(code) or lower(code) != lower(v.fill_code)  collate latin1_general_ci
                    then ' - !! fill code mismatch!!' else '' end)
                FROM reftank.fill where serial_number=v.cylinder_id  collate latin1_general_ci order by date desc limit 1) as fill");
    bldsql_col("v.target_value");
    bldsql_col("v.species");
    bldsql_col("v.analysis_value");
    bldsql_col("case v.analysis_type_num when 1 then 'I' when 2 then 'R' when 3 then 'F' else '' end as analysis_type");
    bldsql_orderby("calservice_num");
    foreach($cyls as $i=>$cylNum){
        $pos=$i%4;
        bldsql_where("v.cylinder_num=?",$cylNum,true);#replace the where clause each loop.
        $a=doquery();
        if($a){#Build the output 4 cyls per page
            #Loop through results and pull out common and per species data.. kind of kludgey
            $sp['CO2']='X';$sp['CH4']='X';$sp['CO']='X';$sp['N2O']='X';$sp['SF6']='X';$sp['SIL CO2']='X';$sp['FLASK']='X';$sp['GCMS']='X';$sp['SIL CH4']='X';$sp['H2']='X';
            $sp['C2H6']='X';$sp['COS']='X';
            $analysis_types=array();
            foreach($sp as $k=>$v){$analysis_types[$k]='';}

            $cylinder_id="";$organization="";$fill="";$target_value="";$species="";$analysis_value="";$targets='';$cals='';$analysis_type="";
            foreach($a as $row){
                extract($row);#sets cyl,org & fill.
                $label='';
                if($species=='co2')$label="CO2";
                if($species=='ch4')$label="CH4";
                if($species=='co')$label="CO";
                if($species=='n2o')$label="N2O";
                if($species=='sf6')$label="SF6";
                if($species=='co2c13' || $species=='co2o18') $label="SIL CO2";
                if($species=='ch4c13')$label='SIL CH4';
                if($species=='isotopes flask')$label="FLASK";
                if($species=='GCMS')$label="GCMS";
                if($species=='h2')$label="H2";
                if($species=='c2h6')$label="C2H6";
                IF($species=='cos')$label='COS';
                if($label){
                    $sp[$label]=$target_value;#Note sil co2 is glommed, only last recorded..
                    $analysis_types[$label]=$analysis_type;
                    $targets=appendToList($targets,"$label $target_value",", ");#Use species to unglom  sil.  Not sure why these are glommed anyway..
                    $cals=appendToList($cals,$label,", ");
                }

            }
            if($pos==0 && $i==0)$html.="<tr>";#First page
            #elseif($pos==0)$html.="<tr style='page-break-after:always;'><td colspan='2'></td></tr><tr>";#2nd + page, insert a blank (because our printers default to double sided)
            #Disabling for now, causes issues if one of them is too big and forces slop
            elseif($pos==0)$html.="<tr>";#Leaving logic mostly inplace (commented) incase we want to give another try.
            elseif($pos==2)$html.="<tr style='page-break-after:always;'>";#2nd row, add a page break;
            $html.="
                <td style='max-width:$labelWidth;width:$labelWidth;' valign='top'>
                    <div style='page-break-inside:avoid !important;'>
                    <table style='max-width:$labelWidth;width:$labelWidth' class='ord_cylPrintTbl'>
                        <tr><td class='label'>CYLINDER</td><td colspan='3' class='data' style='font-size:18px'>$cylinder_id</td></tr>
                        <tr><td class='label'>INSTITUTION</td><td class='data' colspan='3'>$organization</td></tr>
                        <tr style='border-bottom:medium black solid;'><td class='label'>FILL DATE</td><td class='data' colspan='3'>$fill</td></tr>
                        <tr><td class='label'>TARGET</td><td class='data' style='font-size:12px;' colspan='3'>$targets</td></tr>
                        <tr style='border-bottom:medium black solid;'><td class='label'>CALS</td><td class='data' colspan='3'>$cals</td></tr>

                        <tr>
                            <td>&nbsp;</td>
                            <td style='font-size: 10px;'>Flask Conc./Old Cal.</td>
                            <td style='font-size: 10px;'>(I)nitial<br>(R)ecal<br>(F)inal</td>
                            <td style='font-size: 10px;width:20em;'>Finish Date/Initials</td>
                        </tr>
                        <tr><td class='label'>CO2</td><td class='data'>".$sp['CO2']."</td><td>".$analysis_types['CO2']."</td><td></td></tr>
                        <tr><td class='label'>CH4</td><td class='data'>".$sp['CH4']."</td><td>".$analysis_types['CH4']."</td><td></td></tr>
                        <tr><td class='label'>CO</td><td class='data'>".$sp['CO']."</td><td>".$analysis_types['CO']."</td><td></td></tr>
                        <tr><td class='label'>H2</td><td class='data'>".$sp['H2']."</td><td>".$analysis_types['H2']."</td><td></td></tr>
                        <tr><td class='label'>N2O</td><td class='data'>".$sp['N2O']."</td><td>".$analysis_types['N2O']."</td><td></td></tr>
                        <tr><td class='label'>SF6</td><td class='data'>".$sp['SF6']."</td><td>".$analysis_types['SF6']."</td><td></td></tr>
                        <tr><td class='label'>SIL CO2</td><td class='data'>".$sp['SIL CO2']."</td><td>".$analysis_types['SIL CO2']."</td><td></td></tr>
                        <tr><td class='label'>SIL CH4</td><td class='data'>".$sp['SIL CH4']."</td><td>".$analysis_types['SIL CH4']."</td><td></td></tr>
                        <tr><td class='label'>GCMS</td><td class='data'>".$sp['GCMS']."</td><td>".$analysis_types['GCMS']."</td><td></td></tr>
                        <tr><td class='label'>C2H6</td><td class='data'>".$sp['C2H6']."</td><td>".$analysis_types['C2H6']."</td><td></td></tr>
                        <tr><td class='label'>COS</td><td class='data'>".$sp['COS']."</td><td>".$analysis_types['COS']."</td><td></td></tr>
                        <tr><td>&nbsp;</td><td></td><td></td><td></td></tr>
                    </table>
                    </div>
                </td>";#<tr><td class='label'>FLASK</td><td class='data'>".$sp['FLASK']."</td><td>".$analysis_types['FLASK']."</td><td></td></tr>

            if($pos==1 || $pos==3)$html.="</tr>";

        }
    }
    $html.="</table></div>";
    $html="<div id='ord_cylPrintContents'>$html</div>
        <script language='JavaScript'>
            var div=$(\"#ord_cylPrintContents\");
            div.hide();
            var w=window.open();
            var p=div.html();
            var css=\"<style type='text/css' >.label{font-size:12px;}.data{font-size:13px;font-weight:bolder;}\";
                css+=\".ord_cylPrintTbl{border-collapse:collapse;border:medium black solid;}\";
                css+=\".ord_cylPrintTbl td{padding: 4px;border: thin gray solid;}\";
                css+=\"@page{size:auto;margin:10mm;}\";
                css+=\".outerTable{background-color: white;}</style>\"
            w.document.write('<html><head><title>Print Cylinder Sheets</title>'+css+'</head><body>'+p+'</body></html>');
            w.window.print();
            w.document.close();
            div.html('');
        </script>
    ";

    return $html;
}
function ord_updateDueDate($order_num,$months){
    #Adds passed number of months to the order due date.
    $html="";
    if($order_num){

        $message="";$error="";$js='';

        #Load user info from session for logging.
        setLoggingUser();

        bldsql_init();
        bldsql_update("order_tbl");
        bldsql_where("num=?",$order_num);
        bldsql_set("due_date=date_add(due_date, interval ? month)",$months);

        if(doupdate()!==false){
            $message="Saved";
        }else{
            $error="Error saving entry.";
        }


        #Fetch stored (maybe updated) value from table and send text back.
        bldsql_init();
        bldsql_from("order_tbl");
        bldsql_col("due_date");
        bldsql_where("num=?",$order_num);
        $val=doquery("",0);

        if($error)$js="alert(\"$error\");";
        else $js="$(\"#ord_dueDate\").val('$val');
            setStatusMessage('$message','2','ord_dueDateMssgDiv');
            $(\".ord_dueDateButtons\").prop('disabled',false);";
        $html="<script language='JavaScript'>
            $js
        </script>
        ";

    }else $html="Error; no order num!";
    return $html;

}
function ord_loadProductDetails($order_num){
    #Loads all cyls and cals for order
    bldsql_init();
    bldsql_from("rgm_calrequest_view v");
    $lj="product p left join cylinder cyl
            on cyl.num=p.cylinder_num
        left join rgm_calrequest_view v on p.num=v.product_num";
    #bldsql_from($lj);
    bldsql_where("v.order_num=?",$order_num);
    bldsql_orderby("v.cylinder_id");


    bldsql_col("v.product_num as onClickParam");
    bldsql_col("v.cylinder_id as Cylinder");
    #bldsql_col("ifnull(cyl.id, 'not assigned') as Cylinder");
    bldsql_col("v.fill_code as 'Fill'");
    bldsql_col("v.prod_status as 'Cyl. status'");
    $t="group_concat(
            concat(case when v.calrequest_status_num!=3 then \"<span style='font-weight: bold;font-style: italic;'>\" else '' end,
                    v.species,
                    case when v.calrequest_status_num!=3 then \"</span>\" else '' end) separator ', ') as 'Cals'";

    bldsql_col($t);
    bldsql_col("concat_ws('-',v.current_location,case when v.current_location_comments ='' then null else v.current_location_comments end) as 'Location'");
    bldsql_groupby("v.product_num");
    bldsql_groupby("v.cylinder_id");
    bldsql_groupby("v.prod_status");
    bldsql_groupby("v.current_location");
    bldsql_groupby("v.current_location_comments");
    $a=doquery();
    #($a,$onClick="",$leftHiddenCols=0,$class='',$width="",$height="",$divID="",$selectedRowKey='',$floatHeader=true)
    $html=printTable($a,'ord_loadCalRequests',1,'','','','','',false);

    $sql="select ifnull(cyl.id,'Not assigned') as Cylinder,p.comments
from product p left join cylinder cyl on p.cylinder_num=cyl.num
	left join calrequest c on p.num=c.product_num
where c.product_num is null and p.order_num=?";
    $a=doquery($sql,-1,array($order_num));
    if($a)$html.=getPopUp(printTable($a),"Show hidden products",$windowTitle="Products with no calibration requests",'',$buttonTrigger=false);
    return $html;

}

function ord_loadCalRequests($product_num){
    $html="";
    #Returns all calrequests for product, and now last cal/location
    #fetch last location & cal
    $ll_cylid=doquery("select cylinder_id from rgm_calrequest_view where product_num=?",0,array($product_num));
    $ll_loc=doquery("select concat(l.abbr,' ',c.location_comments,' (',date(c.location_datetime),'-',c.location_action_user,')') from cylinder c join location l on c.location_num=l.num where c.id=?",0,array($ll_cylid));
    $ll_lastCal=doquery("select concat(species,' (',date,')') from reftank.calibrations c where serial_number=? order by timestamp(date,time) desc limit 1",0,array($ll_cylid));
    if(!$ll_lastCal)$ll_lastCal='None';
    $ll="<table width='100%'><tr><td>$ll_loc</td><td align='right'>Last <a href='/refgas2/index.php?sn=${ll_cylid}&option=results' target='_new'>cal</a>: $ll_lastCal</td></tr></table>";

    #Calrequest details
    bldsql_init();
    bldsql_from("rgm_calrequest_view v");
    bldsql_where("v.product_num=?",$product_num);
    #cyl
    bldsql_col("v.request_num");
    bldsql_col("v.cylinder_id");

    #cal
    bldsql_col("v.species");
    bldsql_col("v.analysis_type");
    bldsql_col("v.status");
    bldsql_col("v.calrequest_status_num");
    bldsql_col("v.status_color");
    bldsql_col("v.target_value");
    bldsql_col("v.analysis_comments");
    bldsql_col("v.analysis_value as 'aval'");
    bldsql_col("v.analysis_repeatability as 'arep'");
    bldsql_col("v.analysis_reference_scale as 'asca'");
    bldsql_col("case when v.analysis_submit_datetime='0000-00-00' then '' else v.analysis_submit_datetime end as 'adt'");
    bldsql_col("v.analysis_submit_user 'au'");
    bldsql_col("v.analysis_calibrations_selected as 'asel'");
    bldsql_col("v.co2c13_value");
    bldsql_col("v.co2o18_value");
    #bldsql_col("v.num_calibrations");
    bldsql_orderby("v.species");
    #return bldsql_printableQuery();
    $a=doquery();

    if($a){
        $js="";
        #See if any of the calrequests are processing and add a nag col if so
        $t=arrayFromCol($a,'calrequest_status_num');
        $nag=(array_search(2,$t)!==false)?"<th></th>":"";#add spot for nag email button
        $html="
        <div class='scrollingDiv' style='height:125px;' id='calReqDiv'>
        <table class='borderTable' style='width:100%;'>
            <tr><th></th><th>Cal</th><th>Status</th><th>Targ. val</th><th>Value</th><th>Rep.</th><th>Analysis details</th>$nag</tr>";
        foreach($a as $row){
            extract($row);

            #Create the expanded details content
            $co2c13=($co2c13_value)?"<tr><td class='data'>co2c13:</td><td>$co2c13_value</td></tr>":"";
            $co2o18=($co2o18_value)?"<tr><td class='data'>co2o18:</td><td>$co2o18_value</td></tr>":"";
            $details="<div id='${request_num}_div' class='aDetailsDiv' title='Cylinder $cylinder_id $species calibration details'>
                <table>
                    <tr><td class='data'>Target value:</td><td>$target_value</td></tr>
                    <tr><td class='data'>Analysis value:</td><td>$aval</td></tr>
                    <tr><td class='data'>Repeatability:</td><td>$arep</td></tr>
                    <tr><td class='data'>Scale:</td><td>$asca</td></tr>
                    $co2c13 $co2o18
                    <tr><td class='data'>Date submitted:</td><td>$adt</td></tr>
                    <tr><td class='data'>Submitter:</td><td>$au</td></tr>
                    <tr><td class='data'>Calibrations selected:</td><td></td></tr>
                </table>
                <table class='tl_calTable'>
                    <tr><td>$asel</td></tr>
                </table>
            </div>";
            #Put expanded details into a popup button.
            $details=getPopUp($details,"Show","Cylinder $cylinder_id $species calibration details",600);


            #nag email btn?
            if($calrequest_status_num==2){
                $nag=getButtonJS("${request_num}_nagBtn",'ord_nagCalManager',"$request_num","","Send a reminder email to the calibration manager?");
                $nag="<td><div id='${request_num}_nagBtnDiv'><button id='${request_num}_nagBtn'>Send Reminder</button>$nag</div><td>";#wrap in a container div so we can replace with server response message
            }else $nag="";

            #Main content
            $html.="<tr>
                <td><div class='stat' style='background-color:$status_color'>&nbsp;</div></td>
                <td>$species</td><td>$status</td><td>$target_value</td>
                <td>$aval</td><td>$arep</td><td>$details</td>
                $nag
            </tr>";

        }
        $html.="</table></div>$ll";

    }else $html="No calrequests found for this cylinder!";

    return $html;

}
function ord_nagCalManager($request_num){
    #Send a nag email to cal manager for a cylinder
    require_once("../DB_CalRequest.php");
    require_once("../CCGDB.php");;
    require_once("../DB_CalRequestManager.php");
    $html="";
    try{
        $database_object = new CCGDB();
        $calrequest_obj = new DB_CalRequest($database_object, $request_num);
        $cyl=$calrequest_obj->getProduct()->getCylinder()->getID();
        $species=$calrequest_obj->getCalService()->getAbbreviation();
        $email_subject = "Reminder: Cylinder $cyl $species analysis has not been completed.";
        $msg="Hello,<br>
            Cylinder $cyl is part of an order that has been prioritized for expedited completion.<br>
            This is a reminder notification that $species analysis for $cyl is still in processing.<br>
            Your prompt assistance in completing this order is greatly appreciated.
            <br><br>
            -rgm
            ";
        $calrequest_obj->emailUsers($email_subject,$msg);
        $html="Reminder Sent";
    }catch ( Exception $e ){
        $html=$e;
    }
    return $html;
}
function ord_getFormInputTR($id,$label,$val,$size=''){
    #Helper
    $size=($size)?"size='$size'":'';
    return "<td class='label'>$label:</td><td class='data'><input $size class='ord_editable' type='text' id='$id' name='$id' readonly value='$val'></td>";
}
function ord_getSearchFormContent($order_num=""){
    /*Returns the contents of criteria form for orders module.  Note <form... is defined in index page.
     *note search_form_auto_submit items automatically call load list on change
     *
     *We'll preload any previous filters that where saved off.
     */
    $defaults=ord_getFilterDefaults();

    #set defaults.  If order_num was passed, then we won't default any other values
    if($order_num){
        $statusDefault="";$orgDefault="";$custDefault="";$selectedOrderDefault="";$cylDefault="";$mouDefault="";
        $orderNumDefault=$order_num;
    }else{
        $statusDefault=$defaults['status'];#Note there is a default value for this on initial page load set in ord_getFilterDefaults();
        $orgDefault=$defaults['org'];
        $custDefault=$defaults['cust'];
        $selectedOrderDefault=$defaults['selectedOrder'];
        $cylDefault=$defaults['cylID'];
        $mouDefault=$defaults['mou'];
        $orderNumDefault=$defaults['orderNum'];
    }


    #Status
    bldsql_init();
    bldsql_from("order_status");
    bldsql_col("num as value");
    bldsql_col("abbr as display_name");
    bldsql_orderby("num");
    $a=doquery();
    $ordType=i_getInputSelect($a,'ord_ordType',$statusDefault,true);#Default to processing.

    #organization
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.organization as 'key'");
    bldsql_col("r.organization as value");
    #bldsql_col("r.organization as label");
    bldsql_from("rgm_order_view r");
    bldsql_where("r.organization != ''");
    bldsql_orderby("r.organization");

    $org=i_getAutoCompleteSelect(doquery(),"ord_organization",28,$orgDefault);
    #$org=getAutoComplete2(doquery(),"ord_organization",28,$orgDefault);

    #Customer email
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.pri_cust_id as 'key'");
    bldsql_col("r.pri_cust_email as value");
    bldsql_col("concat(r.pri_cust_first_name,' ',r.pri_cust_last_name,' <',r.pri_cust_email,'>') as label");

    #bldsql_col("r.pri_cust_email as label");
    bldsql_from("rgm_order_view r");
    bldsql_where("r.pri_cust_id != ''");
    bldsql_orderby("r.pri_cust_email");
    $cust=i_getAutoCompleteSelect(doquery(),"ord_custID",28,$custDefault);
    #$cust=getAutoComplete2(doquery(),"ord_custID",28,$custDefault,'i_loadList');
    $html="
        <table style='width:100%'>
            <tr><td valign='top' class='title3'>Order Search Filters<br><br></td><td align='right' valign='top'><button style='font-size:16px' onclick='i_loadList();return false;' title='Reload list'><img src='j/images/refresh.png' width='12' height='12'/></button></td></tr>
            <tr>
                <td class='label'>MOU Num:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='ord_MOU' name='ord_MOU' value='$mouDefault'></td>
            </tr>
            <tr>
                <td class='label'>Order Num:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='ord_ordNum' name='ord_ordNum' value='$orderNumDefault'></td>
            </tr>
             <tr>
                <td class='label'>Clyinder ID:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='ord_cylID' name='ord_cylID' value='$cylDefault'></td>
            </tr>
            <tr><td colspan='2'><div id='ord_cylIDSearchCheckOutput'></div></td></tr>
            <tr><td colspan='2' class='label' style='text-align:left;' align='left'><br>Status:</td></tr>
            <tr><td colspan='2'>$ordType</td></tr>

            <tr><td colspan='2' class='label' style='text-align:left;' align='left'><br>Organization:</td></tr>
            <tr><td colspan='2'>$org</td></tr>

            <tr><td colspan='2' class='label' style='text-align:left;' align='left'><br>Customer:</td></tr>
            <tr><td colspan='2'>$cust</td></tr>
            <tr><td colspan='2' align='right'><br><br>
                <button id='ord_clearSearchFields'>Clear</button><button id='ord_submitSearch'>Search</button>
                </td>
            </tr>
            <tr><td align='center' colspan='2'><br><br><br><br><br><br>
                    <h2><a  href='index.php?mod=addOrder'>Add Order</a></h2>
                </td>
            </tr>

        </table>

        <input type='hidden' name='ord_selectedOrder' id='ord_selectedOrder' value='$selectedOrderDefault'>
        <script language='JavaScript'>
            i_loadList();//Submit the default search (processing)
            $('#ord_MOU').focus();//Set focus on mou field by default
            //$('#ord_selectedOrder').val('');//If this was set, clear now that the search was submitted (above) so it doesn't keep reselected this row.  This is to support back arrow functionality.

            //Button handlers
            $(\"#ord_clearSearchFields\").click(function(event){
                event.preventDefault();
                ord_resetSearchForm();
            });
            $(\"#ord_submitSearch\").click(function(event){
                event.preventDefault();
                i_loadList();
            });
            $(\"#ord_cylID\").change(function(event){
                //event.preventDefault();//DOn't think this should fire (it might interfere with normal search logic)
                cyl= $(\"#ord_cylID\").val();
                if(cyl){//do some convienence checks for cyl
                    ajax_get('ord_cylinderCheck','&ord_cylID='+cyl+'&ord_cylCheckSrc=index','ord_cylIDSearchCheckOutput',ajax_dfltHandle,'');
                }else{
                    $(\"#ord_cylIDSearchCheckOutput\").empty();
                }
            });
        </script>
    ";
    return $html;
/*<input class='search_form_auto_submit' type='radio' id='ord_ordType' name='ord_ordType' value='all'>All</input>
                    <input class='search_form_auto_submit' type='radio' id='ord_ordType' name='ord_ordType' checked value='current'>Current</input>
                    <input class='search_form_auto_submit' type='radio' id='ord_ordType' name='ord_ordType' value='pending'>Pending</input>
                */
}

function ord_getHelpText(){
    $help="
            <div class='title4'>Orders page</div>
            <ul>
                <li>To search for a specific order, enter the order/MOU number then tab or enter key.</li>
                <li>To search for orders with a specific cylinder, enter either the whole cylinder ID or part of it to find matching orders.
                Only orders that have the selected 'status' will be displayed, so choose the status first.</li>
                <li>To filter orders by status, select the status from the drop down.  Default is processing.</li>
                <li>You can further filter the list by selecting an organization or customer.</li>
            </ul>
            <div class='title4'>Order detail</div>
            <ul>
                <li>To load an order's details, select the row from the list.</li>
                <li>You can select specific cylinders in the detail area to view calibration requests.</li>
                <li>If a calibration request is still 'Processing', you can send a reminder email to the calibration manager requesting expedited analysis.</li>
                <li>Edit, approval, shipping and other functions appropriate to the current status are available in the detail area</li>
            </ul>
        ";
    return $help;
}
#Filter default functions.  These save/restore filters on the orders page.
function ord_setFilterDefaults($orderNum="",$mou="",$cylID="",$status="",$org="",$cust="",$selectedOrder=""){
    #Set the filters in use so we can use to reload when pages is reloaded.
    $a=array('orderNum'=>$orderNum,'mou'=>$mou,'cylID'=>$cylID,'status'=>$status,'org'=>$org,'cust'=>$cust,'selectedOrder'=>$selectedOrder);#must match below if adding new filters
    session_start();
        $_SESSION['ord_filterDefaults']=$a;
    session_write_close();
}
function ord_setFilterDefaultsSelectedOrder($selectedOrder){
    #Sets just the 'selected order'.  This is the order that was last loaded (like if clicked on).  It's used to reselect an order on back.
    #Slightly wasteful to make 2 calls that open/close session, but is worth it for cleaner logic.
    $a=ord_getFilterDefaults(false);
    ord_setFilterDefaults($a['orderNum'],$a['mou'],$a['cylID'],$a['status'],$a['org'],$a['cust'],$selectedOrder);
}
function ord_getFilterDefaults($clearAfterReading=true){
    #Returns previously set filters in an array.
    #Note defaults set here (status->processing) are only set very first time page is loaded.
    $a=array('orderNum'=>'','mou'=>'','cylID'=>'','status'=>'','org'=>'','cust'=>'','selectedOrder'=>'');#must match above if adding new filters
    session_start();
        if(!isset($_SESSION['ord_filterDefaultsHaveLoaded'])){
            #Very first time through (for this session), load some defaults
            #jwm. 10/24. turned off- request by steve  $a['status']=3;#set status to processing.
            $_SESSION['ord_filterDefaultsHaveLoaded']=true;
        }
        if(isset($_SESSION['ord_filterDefaults'])){
            $a=$_SESSION['ord_filterDefaults'];
            if($clearAfterReading)unset($_SESSION['ord_filterDefaults']);
        }
    session_write_close();
    return $a;
}
function ord_clearFilterDefaults(){
    session_start();
        if(isset($_SESSION['ord_filterDefaults'])){
            unset($_SESSION['ord_filterDefaults']);
        }
    session_write_close();
}








?>
