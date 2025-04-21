<?php
/*This is the main ajax content portal for all newly generated (jwm) pages
 *This is designed to be called by ajax scripts (see j/lib/ajax_handlers.js) from html elements on index.php (or todo_list2.php which was first).
 *$doWhat is the switch to load or process some data.  You should use getHTTPVar to load any user form passed data.
 */
ini_set("error_log","/var/www/html/mund/rgm/j/log/php_err.log");
ob_start("ob_gzhandler");
$dbutils_dir="/var/www/html/inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
require_once("lib/cylfill.php");
require_once("lib/todo_list_funcs.php");
require_once("lib/index_funcs.php");
require_once("lib/orders_funcs.php");
require_once("lib/intended_use.php");
db_connect("lib/config.php");
 
$doWhat="";
$html="";
session_start();
#See if the index page validated the user.  Note, we keep auth for duration of session.  See index(2).php for comments.
#Also note, this is also set in todo_list2.php
if(isset($_SESSION['i_userValidated']) && $_SESSION['i_userValidated']){
   $doWhat=getHTTPVar("doWhat","",VAL_STRING); 
}else{
    echo "Authorization error in switch.php";
    exit();
}
session_write_close();
            
switch($doWhat){
    case "i_loadList":
        /*Generic function to load list based on search form.  See index_funcs.php=>i_loadList() for details on how to use.*/
        $html=i_loadList();
        break;
    case "i_getSummary":
        $html=i_getSummary();
        break;
    #cyl fill
    case "cf_rowClicked":
    	$html=cf_rowClicked();
    	break;
    
    #Order functions
    case "ord_loadOrder":
        $num=getHTTPVar("order_num",false,VAL_INT);
        $html=ord_loadOrder($num);    
        break;
   case "ord_completeOrder":
      $num=getHTTPVar("order_num",false,VAL_INT);
      $html=ord_completeOrder($num);
      break;
   case "ord_loadCalRequests":
      $num=getHTTPVar("product_num",false,VAL_INT);
      $html=ord_loadCalRequests($num);
      break;
   case "ord_nagCalManager":
      $num=getHTTPVar("request_num",false,VAL_INT);
      $html=ord_nagCalManager($num);
      break;
   case "ord_editOrderForm":
      $num=getHTTPVar("order_num",false,VAL_INT);
      $html=ord_editOrderForm($num);
      break;
   case "ord_submitOrder":
      $html=ord_submitOrder();   
      break;
   case "ord_getProductList":
      $order_num=getHTTPVar("order_num",false,VAL_INT);
      $product_num=getHTTPVar("product_num",false,VAL_INT);
      $mssg=getHTTPVar("mssg");
      $html=ord_getProductList($order_num,$product_num,$mssg);
      break;
   case "ord_loadProduct":
      $num=getHTTPVar("product_num",false,VAL_INT);
      $html=ord_getProductForm($num);
      break;
   case "ord_submitProduct":
      $html=ord_submitProduct();   
      break;
   case "ord_addCyl":
      $html=ord_addClyinder();
      break;
   case "ord_cylinderCheck":
      $src=getHTTPVar("ord_cylCheckSrc",'edit');
      if($src=='edit' || $src=='fill')$cyl=getHTTPVar("cylinderID");
      else $cyl=getHTTPVar("ord_cylID");
      if($cyl)$html=ord_cylinderCheck($cyl,false,$src);
      break;
   case "ord_cloneProduct":
      $html=ord_cloneProduct();
      break;
   case "ord_deleteProduct":
      $html=ord_deleteProduct();
      break;
   case "ord_updateDueDate":
      $order_num=getHTTPVar("order_num",false,VAL_INT);
      $num=getHTTPVar("ord_updateDueDateNum",false,VAL_INT);
      $html=ord_updateDueDate($order_num,$num);
      break;
   case "ord_printCylSheets":
      $html=ord_printCylSheets();
      break;
   case "ord_zipCertificates":
      $html=ord_zipCertificates();
      break;
    case "cf_addCylinder":
    	$html=cf_addCylinder();
    	break;
    case "cf_getCylFormDependents":
    	$html=cf_getCylFormDependents();
    	break;
    
    case "ord_deleteOrder":
    	$html=ord_deleteOrder();
    	break;
    
    #TodoList Functions;
    case "getCalServiceList":
        $extra=getHTTPVar("tl_extraCols",false,VAL_INT);
        $org=getHTTPVar("tl_organization");
        $cs_num=getHTTPVar("cs_num","",VAL_INT);
        $addl=getHTTPVar("tl_showAddlSpecies",false,VAL_INT);
        $sort=getHTTPVar("tl_sort_mode",1,VAL_INT);
        $html=getCalServiceList($cs_num,$extra,$org,$addl,$sort);
        break;
    case "tl_editSortNum":
        $tl_request_num=getHTTPVar("tl_request_num","",VAL_INT);
        $html=tl_editSortNum($tl_request_num);
        break;
    case "tl_editComment":
        $tl_comment=getHTTPVar("tl_comment");
        $tl_request_num=getHTTPVar("tl_request_num","",VAL_INT);
        $html=tl_editComment($tl_request_num,$tl_comment);
        break;
    case "tl_loadCalibrations":
        $tl_request_num=getHTTPVar("tl_request_num","",VAL_INT);
        $tl_cs_abbr=getHTTPVar("tl_cs_abbr");
        $tl_cyl=getHTTPVar("tl_cyl");
        $tl_fill_code=getHTTPVar("tl_fill_code");
        if($tl_request_num && $tl_cs_abbr && $tl_cyl && $tl_fill_code){
            $html=tl_loadCalibrations($tl_request_num,$tl_cs_abbr,$tl_cyl,$tl_fill_code);
        }else $html="Error with parameters.";        
        break;
    case "tl_calibration_submitAnalysis":
        $html=tl_calibration_submitAnalysis();
        break;
    case "tl_getOrgSelect":
        $cs_num=getHTTPVar("cs_num","",VAL_INT);
        $html=tl_getOrgSelect($cs_num);
        break;
   #Cylinder fills
   case "cf_sortNumEdit":
      $pkey=getHTTPVar('ptef_pk',false,VAL_INT);
      $newVal=getHTTPVar('ptef_val',false,VAL_INT);
      
      $html=cf_sortNumEdit($pkey,$newVal);
      break;
    #Cylinder locations
    case "currentCylinderLocations":
      $html=getCylinderLocations();
      break;
    case "cl_loadDetail":
      $html=cl_loadDetail();
      break;
    case "iu_submitForm":
        $intended_use=getHTTPVar('intended_use',false,VAL_INT);
        $intended_site=getHTTPVar('intended_site',false,VAL_INT);
        $product_num=getHTTPVar('iu_product_num',0,VAL_INT);#0 so can use in string
        $next_checkin_comment=getHTTPVar('next_checkin_comment');
        $cylinder_num=getHTTPVar('iu_cylinder_num',false,VAL_INT);
        $fill_code=getHTTPVar("iu_fill");
        $int_cal_on_next_checkin=getHTTPVar('int_cal_on_next_checkin',0,VAL_BOOLCHECKBOX);
        $fin_cal_on_next_checkin=getHTTPVar('fin_cal_on_next_checkin',0,VAL_BOOLCHECKBOX);
        
        #var_dump($_POST);
        $sp=0;$sn=0;
        if($product_num)$sp=iu_updateProductIntentions($product_num,$intended_use,$intended_site);
        if($cylinder_num && $fill_code)$sn.=iu_updateCylinderCheckinNotes($cylinder_num,$fill_code,$next_checkin_comment,$int_cal_on_next_checkin,$fin_cal_on_next_checkin);
        if($sp!==False && $sn!==False)$html="<script>".delayedJS("cl_loadDetail($cylinder_num,$product_num);")."</script>";
        else $html="Error submitting form.";
        break;
    #Dynamic loading autocompletes (Testing)
    case "loadAutoCompleteData";
      $id=getHTTPVar("inputID");
      $term=getHTTPVar('term');
      if($id=='ord_custID' && $term ){
         bldsql_init();
         bldsql_distinct();
         bldsql_col("r.pri_cust_id as 'key'");
         bldsql_col("r.pri_cust_email as value");
         #bldsql_col("r.pri_cust_email as label");
         bldsql_from("rgm_order_view r");
         bldsql_where("r.pri_cust_id like ?",$term);
         bldsql_orderby("r.pri_cust_email");
      }
      $html=getAutocompleteWidgetJSArray(doquery(),'ord_custID');
   
      break;
      case "loadImg":#didn't end up using this..
         $filename=getHTTPVar("filename");
         $dir=getHTTPVar("dir");
         $html=streamIMG($dir."/".$filename,0,0);
         break;
    #Networking/Utils
    case "keepAlive":
       $html="Server last contacted:".date("h:i a");
       break;
}

        
#ini_set("zlib.output_compression","On");#did work, probably no zlib installed..
#ob_start("ob_gzhandler");  I put at top so it gets errors and debug out too.
echo $html;
exit();

?>
