<?php
function cf_getSearchFormContent(){
	#search form for cyl fill()
	$html=''; #organization
    bldsql_init();
    bldsql_distinct();
    bldsql_col("r.organization as 'key'");
    bldsql_col("r.organization as value");
    #bldsql_col("r.organization as label");
    bldsql_from("rgm_order_view r");
    bldsql_where("r.organization != ''");
    bldsql_orderby("r.organization");

    $org=i_getAutoCompleteSelect(doquery(),"ord_organization",28);
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
    $cust=i_getAutoCompleteSelect(doquery(),"ord_custID",28);
    $extra='';#getCheckBoxInput('product_extra','Product Extras',0);
    #$cust=getAutoComplete2(doquery(),"ord_custID",28,$custDefault,'i_loadList');
    #<button id='ord_clearSearchFields'>Clear</button>
    $html="
        <table style='width:100%'>
            <tr><td valign='top' class='title3'>Product Search Filters<br><br></td><td align='right' valign='top'><button style='font-size:16px' onclick='i_loadList();return false;' title='Reload list'><img src='j/images/refresh.png' width='12' height='12'/></button></td></tr>
            <tr>
                <td class='label'>MOU Num:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='ord_MOU' name='ord_MOU' value=''></td>
            </tr>
            <tr>
                <td class='label'>Order Num:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='ord_ordNum' name='ord_ordNum' value=''></td>
            </tr>


            <tr><td colspan='2' class='label' style='text-align:left;' align='left'><br>Organization:</td></tr>
            <tr><td colspan='2'>$org</td></tr>

            <tr><td colspan='2' class='label' style='text-align:left;' align='left'><br>Customer:</td></tr>
            <tr><td colspan='2'>$cust</td></tr>
            <tr><td colspan='2'>$extra</td></tr>
            <tr><td colspan='2' align='right'><br><br>
                <button id='ord_submitSearch'>Search</button>
                </td>
            </tr>


        </table>

        <script language='JavaScript'>
            i_loadList();//Submit the default search (processing)
            $('#ord_MOU').focus();//Set focus on mou field by default

            //Button handlers
            //$(\"#ord_clearSearchFields\").click(function(event){
            //    event.preventDefault();
            //    ord_resetSearchForm();
            //});
            $(\"#ord_submitSearch\").click(function(event){
                event.preventDefault();
                i_loadList();
            });

        </script>
    ";
    return $html;

}

function cf_getFillList(){
	#load list of available/ fillable products
	$html='';
	$order_num=getHTTPVar("ord_ordNum",false,VAL_INT);
    $org=getHTTPVar("ord_organization");
    $cust=getHTTPVar("ord_custID",false,VAL_INT);
    $mou=strtoupper(getHTTPVar("ord_MOU"));
    $extra=getHTTPVar("product_extra",false,VAL_BOOLCHECKBOX);

	bldsql_init();
	$join="product p left join order_tbl o on p.order_num=o.num
	    left join customers c on c.id=o.primary_customer_user_id
	    left join cylinder_size sz on sz.num=p.cylinder_size_num
	    left join calrequest co2 on co2.product_num=p.num and co2.calservice_num=1
	    left join calrequest ch4 on ch4.product_num=p.num and ch4.calservice_num=2
	    left join calrequest co on co.product_num=p.num and co.calservice_num=3
	    left join calrequest n2o on n2o.product_num=p.num and n2o.calservice_num=4
	    left join calrequest sf6 on sf6.product_num=p.num and sf6.calservice_num=5
	    left join calrequest h2 on h2.product_num=p.num and h2.calservice_num=11
        left join calrequest co2c13 on co2c13.product_num=p.num and co2c13.calservice_num=6
        left join calrequest co2c18 on co2c18.product_num=p.num and co2c18.calservice_num=7
        left join calrequest c2h6 on c2h6.product_num=p.num and c2h6.calservice_num=12

        ";
	bldsql_from("$join");
	bldsql_where("p.cylinder_num=0");
    if($order_num)bldsql_where("p.order_num=?",$order_num);
    if($cust)bldsql_where("o.primary_customer_user_id=?",$cust);
    if($mou)bldsql_where("o.mou=?",$mou);
    if($org)bldsql_where("o.organization=?",$org);
    bldsql_col("p.num as onClickParam");
    #Add a select column
    #Note the copytext label is "cyl,avg_targ,press,fill,reg,numcals"  this is set in todo_list.js
    ###$selCol="concat(\"<td class='tl_selection' style='background-color:white;'><input type='checkbox' id='selection_\",p.num,\"' value='".$row['copy_text']."' class='tl_selectBox'></td>";

    bldsql_col("p.sort_num as 'sort'");
    if($extra)bldsql_where("p.order_num=0");#not actually using this..  not sure that you actually fill extras, but leaving for now in case we change.
    else {
        bldsql_where("p.order_num!=0");
        bldsql_col("order_num as 'Ord #'");

        $mou="concat('<a target=\"_new\" href=\"j/mou.php?mou=',o.MOU_number,'\">',o.MOU_number,'</a>')";
        bldsql_col("$mou as MOU_number");
        bldsql_col("o.due_date");
        bldsql_col("c.email as 'Pri Email'");
        bldsql_col("o.organization");
    }
    $n="(select count(*)+1 from product where order_num=p.order_num and num<p.num)";
    $n2="(select count(*) from product where order_num=p.order_num)";
    bldsql_col("concat($n,'/',$n2) as '# in ord'");
    bldsql_col("sz.abbr as 'Cyl Size'");
    bldsql_col("co2.target_value as co2");
    bldsql_col("ch4.target_value as ch4");
    bldsql_col("co.target_value as co");
    bldsql_col("n2o.target_value as n2o");
    bldsql_col("sf6.target_value as sf6");
    bldsql_col("h2.target_value as h2");
    bldsql_col("co2c13.target_value as co2c13");
    bldsql_col("co2c18.target_value as co2c18");
    bldsql_col("c2h6.target_value as c2h6");

    bldsql_col("p.comments");
    bldsql_orderby("case when sort_num is null then 1 else 0 end, sort_num, due_date");
    #return bldsql_printableQuery();
    $html=printTableW(doquery(),array('onClick'=>'cf_rowClicked','leftHiddenCols'=>1,'passRowIDToOnClick'=>true,'editFieldOnClick'=>'cf_sortNumEdit','editableField'=>'sort'));
	return $html;
}
function cf_rowClicked(){
	#load cyl fill form
	$html='';
    $product_num=getHTTPVar("product_num",false, VAL_INT);
    $clicked_row_id=getHTTPVar("clicked_row_id");
    bldsql_init();
    bldsql_from("calrequest r join calservice s on s.num=r.calservice_num");
    bldsql_where("r.product_num=?",$product_num);
    bldsql_col('s.abbr as species');
    bldsql_col("r.target_value as target");
    bldsql_col("r.comments");
    bldsql_col("case when r.highlight_comments=1 then '*' else '' end as ''");
    $a=doquery();
    $cals=($a)?"<div class='title4'>Calibrations</div>".printTable($a,'',0,'','300px','180px'):'';
    $prodComments=doquery("select comments from product where num=?",0,array($product_num));


    $cyl=ord_getCylinderInputHTML('',false,'fill');
    $script='$("#ord_prodCylID").focus();$("#cf_fillCylinderForm").on("submit", function( event ) {event.preventDefault(); });';#prevent enter from submitting.


    #Note some form inputs (fill, dot) are created by ord_cylinderCheck() in editOrders_funcs.php after the cyl checks out.
    $html="<form id='cf_fillCylinderForm' name='cf_fillCylinderForm'><input type='hidden' id='cf_product_num' name='cf_product_num' value='$product_num'><input type='hidden' id='clicked_row_id' name='clicked_row_id' value='$clicked_row_id'>
            <table>
                <tr>
                    <td valign='top'>$cals $prodComments</td>
                    <td valign='top'>$cyl <div id='cf_formDiv'></div></td>
                <tr>
            </table></form>
            <script>$script</script><div class='ital' id='cf_submitMssg'></div>";
	return $html;
}
function cf_sortNumEdit($pkey,$newVal){
    /*Update the sort_num col in products*/

    $a=doupdate("update refgas_orders.product set sort_num=? where num=?",array($newVal,$pkey));
    #$js="<script>var trow = $('#${inpID}').closest('tr');trow.prop('onclick', null);trow.click(function(){alert('You must refresh the page to edit this row.');});</script>";#hack to avoid re-edits
        #$val=doquery("select format(sal,0) from sals where num=?",0,array($pk));
        #return $val.$js;
    if($a!==false){
        return $newVal;#doquery("select sort_num from refgas_orders.product where num=?",0,array($pkey));
    }
    else return "Error updating value";
}
function cf_getCylFormDependents(){
    #returns rest of form after cyl selected
    $cyl_num=getHTTPVar("cyl_num",false,VAL_INT);
    $html='';
    if($cyl_num){
        $dot=doquery("select date_format(recertification_date,'%m-%y') from cylinder where num=?",0,array($cyl_num));
        $dot="<tr><td class='label'>DOT Date:</td><td class='data'><input id='ord_addCylDOT' value='$dot' name='ord_addCylDOT' type='text' size='5' placeholder='mm-yy'></td></tr>";
        $fd="<tr><td class='label'>Fill Date:</td><td class='data'>".getDateInput("cf_FillDate",'',12,false,'','',true)."</td></tr>";
        $c="<tr><td class='label'>Comments</td><td>".getTextAreaInput('cf_comments','')."</td></tr>";
        $html.="<table>".$dot.$fd.$c."</table>";

        $html.=getJSButton('cf_submitCylBtn','cf_submitCyl','Submit');
       }
       return $html;
}
function cf_addCylinder(){
	#Fill a product with cyl.. update dot and fill date if needed.
	$html='';
	#We'll copy logic from cylinder_fill.php

	$product_num=getHTTPVar("cf_product_num",false, VAL_INT);
    $dot=getHTTPVar("ord_addCylDOT");
    $fillDate=getHTTPVar("cf_FillDate",false,VAL_DATE);
    $cylID=getHTTPVar("ord_prodCylID");
    $comments=getHTTPVar("cf_comments");
    $clicked_row_id=getHTTPVar("clicked_row_id");
    $order_num='';$email='';
    #Hard code location to 3 NWR, method to 'RIX SA6' for now.  Old one used to allow scott marin 'grav blend', but none entered recently.  We can always add inputs if Duane wants them.
    $loc_num=3;$locAbbr='NWR';$method='RIX SA6';
    if($product_num){

        $order_num=doquery("select order_num from product where num=?",0,array($product_num));
        #find assoc email (only intendeds with noaa.gov)
        if($order_num)$email=doquery("select c.email from customers c
                            join order_tbl o on c.id=o.primary_customer_user_id
                            join product p on p.order_num=o.num
                            where p.num=? and o.num=?
                            and ((p.intended_use is not null and p.intended_use >0 ) or (p.intended_site is not null and p.intended_site>0))
                            and c.email like '%noaa.gov'",0,array($product_num,$order_num));
        if($email){#send a note to notify noaa user
            $use=doquery("select name from product p join intended_uses u on p.intended_use=u.num where p.num=?",0,array($product_num));
            $site=doquery("select s.code from product p join gmd.site s on s.num=p.intended_site where p.num=?",0,array($product_num));
            $email_msg="
Cylinder $cylID was assigned to order # $order_num. \n
Intended site:$site \n
Intended use: $use \n\n
https://omi.cmdl.noaa.gov/rgm/index.php?mod=editOrder&order_num=$order_num \n
            ";
        }
    }else return "Error; no product num received.";
    if($cylID && $fillDate && $dot){
        try{
            require_once("../CCGDB.php");
            require_once("../DB_Cylinder.php");
            require_once("../DB_Location.php");
            require_once("../DB_ProductManager.php");
            require_once("../DB_CalRequestManager.php");
            require_once("../DB_LocationManager.php");
            require_once("/var/www/html/inc/ccgglib_inc.php");

            session_start();
                $database_object = new CCGDB();
                $order_object = new DB_Order($database_object, $order_num);
                $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
                $product_object = new DB_Product($database_object, $product_num);
                $cylinder_object = new DB_Cylinder($database_object, $cylID, 'id');

            session_write_close();

            if ( ! is_object($cylinder_object) )$html="Invalid cylinder ID";
            else{
                $location_object = new DB_Location($database_object,$loc_num);
                $cylinder_object->ship($location_object);# Set the cylinder to this location
                $cylinder_object->setRecertificationDate($dot);//Set/reset dot
                if($comments){
                    $cylinder_object->fill($fillDate, $locAbbr, $method, $comments);
                }else  $cylinder_object->fill($fillDate, $locAbbr, $method);
                $cylinder_object->saveToDB($user_obj);
                # Update product information
                $product_object->setCylinder($cylinder_object);
                if ( $cylinder_object->getLastFillCodeFromDB() != '' ){
                    #Get the Last Fill Code as we just added a new one with fill()
                    $product_object->setFillCode($cylinder_object->getLastFillCodeFromDB());
                }
                $product_object->preSaveToDB();
                $product_object->saveToDB($user_obj);
                #$action="$('#${clicked_row_id}').hide();$('#fixedHeightContentDiv').html('');";
                $action="i_loadList();";#Steve would prever full refresh. jwm 10/24
                $html="Cylinder Saved to Product/Order.<script>".delayedJS($action,1000)."</script>";
                #var_dump($email);var_dump($email_msg);$html='';
                if($email)$html.=send_email($email,"A cylinder was assigned to your refgas order $order_num",$email_msg);

            }
        }catch (Exception $e){ $html=$e; }
    }else{$html="Clyinder, fill date and dot are required fields.";}

	return $html;

}






?>
