<?php
/*Functions to support index page*/
require_once("/var/www/html/inc/dbutils/template/resources/index_funcs.php");

function i_loadList(){
    /*generic function to load list from search criteria.  Requires http var 'mod', a handler for the mode and whatever
     *requirements the handler sets.  See below for examples.*/
    $html="";
    $module=getHTTPVar("mod");
    switch($module){#Override defaults as needed for each module.
        case "orders":
            require_once("orders_funcs.php");
            $html=ord_loadList();
	    $html.=setTitleJS("'RGM Orders'");
            break;
        case "cylinderLocations":
            $html=getCylinderLocations();
	    $html.=setTitleJS("'RGM CylLocs'");
            break;
        case 'fill':
            $html=cf_getFillList();
	    $html.=setTitleJS("'RGM Fills'");
            break;
        default:
            $html="<div align='center' style='width:100%'><br><br><br><br><br>Unknown module: $module</div>";
            break;
    }
    return $html;
}
/*Loaded in include above
function i_getInputSelect($a,$id,$selectedValue="",$addBlankRow=false,$maxWidth='250px'){
    #Returns html input for query result $a.  If $selectedValue passed, it's selected.  automatically fires i_loadList on change.
    #requires 2 cols value, display_name
    $html="<select class='search_form_auto_submit' id='$id' name='$id' style='max-width:$maxWidth;min-width:$maxWidth;'>";
    $html.=getSelectInputOptions($a,$selectedValue,$addBlankRow);
    $html.="</select>";
    return $html;
}
*/

function i_getIndexList(){
    /*Returns a list of links to different modules for the index page defaults*/
    require_once("menu_utils.php");
    $html=createMenu2(false)."<script language='JavaScript'>i_getSummary();</script>";
    return $html;
}

function i_getSummary(){
    /*loads general summary info dashboard thingy*/
    #Orders
    #By due date
    $sql="SELECT  order_status as 'series', CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE) as 'x', count(*) as 'y'
            FROM refgas_orders.rgm_order_view
            where  datediff(due_date,now())<180  and order_num not in (317,336,342,276,468)
                and due_date>=(select min(due_date) from refgas_orders.rgm_order_view where order_status_num not in (5,7))
            group by order_status,CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE)
            order by order_status,CAST(DATE_FORMAT(due_date ,'%Y-%m-01') as DATE)";
    $ordDue=printStackedBarChart(doquery($sql),"Order status by month due",'600px','300px','month');
    #By status
    $sql="select order_status as label, count(*) as num,order_status_num
            from rgm_order_view
            where order_status_num not in (5,7)  and order_num not in (317,336,342,276,468)
            group by order_status,order_status_num
            order by order_status_num";
    $ordStatus=printPieChart(doquery($sql),"Open order status",'250px','125px');
    #by year
    $sql="  select year(due_date) as 'Year due',species as 'Cal',count(distinct(request_num)) as '# cals',
                count(distinct(order_num)) as '# orders',count(distinct(organization)) as '# orgs'
            from refgas_orders.rgm_calrequest_view
            where due_date is not null and order_num not in (317,336,342,276,468)
            group by year(due_date),species with rollup
            ";
    $ordTotals=printTable(doquery($sql));
    $ordTotals="<div style='overflow:auto;height:275px;border:thin silver solid;'>$ordTotals</div><br>
                <div style='display: inline;border:thin outset grey;width:50%;min-width:50%;text-align:center;padding-left:5px;padding-right:5px;'>Order totals by year/species</div>";
    #Calibrations
    bldsql_init();
    bldsql_from("rgm_calrequest_view v");
    bldsql_from("calservice c");
    bldsql_where("c.num=v.calservice_num");
    bldsql_col("v.status as 'series'");
    bldsql_col("v.calservice_num as 'x'");
    bldsql_col("count(v.request_num) as 'y'");
    bldsql_col("c.abbr as xlabel");
    bldsql_where("v.order_status_num not in (5,7)");
    bldsql_groupby("v.status");
    bldsql_groupby("v.calservice_num");
    bldsql_orderby("v.status");
    bldsql_orderby("v.calservice_num");
    #return bldsql_printableQuery();
    $calStatus=printStackedBarChart(doquery(),"Open order cal requests",'400px','300px','Request type');
    #return bldsql_printableQuery();
    $width='250px';$height='100px';
    $cyllocs=getPopUp(selfLoadingDiv("currentCylinderLocations",''),"Current cylinder locations","Current Cylinder Locations",600,false);

    $html="<div class='title3'>Orders <span style='float:right'>$cyllocs</span></div>
    <table align='center' valign='top' class='summaryTable'>
        <tr><td>$ordDue</td><td>$ordTotals</td></tr>
        <tr><td colspan='2'>$ordStatus</td></tr>
    </table>
    <br>
    <div class='title3'>Calibrations</div>
    <table align='center' valign='top' class='summaryTable'>
        <tr><td>$calStatus</td></tr>
    </table>
    ";

        $sql="
            select CAST(DATE_FORMAT(date ,'%Y-01-01') as DATE)  as x,inst as series,count(*) as y
 from reftank.calibrations where species='co2' and date>='2014-01-01'
group by inst, CAST(DATE_FORMAT(date ,'%Y-01-01') as DATE)
order by inst, CAST(DATE_FORMAT(date ,'%Y-01-01') as DATE)

       ";
    $html.=printStackedBarChart(doquery($sql),"CO2 Calibrations by instrument",'400px','300px','year');

    return $html;
}

function getButtonJS($id,$action,$param1="",$param2="",$confirmationText=""){
    /*param1/2 are optional.  No good way currently to pass '', but that could be added if needed.
     *if $confirmationText is passed, we'll do a confirm with a ok/cancel button first
     */
    $action.="(";
    if($param1)$action.="'$param1'";
    if($param2)$action.=",'$param2'";
    $action.=");";
    $action=($confirmationText)?"if(confirm('".htmlentities($confirmationText)."')){$action}":"$action";
    $js="<script language='JavaScript'>
            $(\"#$id\").click(function(event){
                event.preventDefault();
                $action
            });</script>";
    return $js;
}

function delayedJSExec($func,$msDelay=100) {
    /*Run arbitrary js function on delay (so current execution cycle completes).  This is mostly needed
    so an ajax submit can fully complete before it fires off a reload or similar.)
    $func can be any arbitrary js code.
    ex $func: "ord_loadProduct($product_num);"
    */
    return "setTimeout(function(){ $func },$msDelay)";
}

//Cylinder Location
function cl_getSearchFormContent(){

    #location
    bldsql_init();
    bldsql_distinct();
    bldsql_col("concat(l.abbr,' (',l.name,')') as 'value'");
    bldsql_col("l.num as 'key'");
    bldsql_from("location l");
    bldsql_from("cylinder c");
    bldsql_where("l.num=c.location_num");
    $locs=i_getAutoCompleteSelect(doquery(),"cl_location",20);
    $cylid=getHTTPVar('cl_clyID');
    $intendeds=iu_getEditWidget('','','search_form_auto_submit',true,true);

    $html="<br><br>
    <table>
        <tr><td class='label'>Location</td><td class='data'>$locs</td></tr>
        <tr><td class='label'>Clyinder ID:</td><td class='data'><input size='10' class='search_form_auto_submit' type='text' id='cl_clyID' name='cl_clyID' value='$cylid'></td></tr>
        $intendeds
        <tr><td colspan='2' align='right'><br><br>
            <a href='index.php?mod=cylinderLocations'>Reset</a> <button id='cl_submitSearch'>Search</button>
            </td>
        </tr>
    </table>
    <script language='JavaScript'>
        i_loadList();//Submit the default search (processing)
        //Button handlers
        $(\"#cl_submitSearch\").click(function(event){
            event.preventDefault();
            i_loadList();
        });
        function cl_loadDetail(cyl_num,product_num){
            //Load cylinder detail
            ajax_get('cl_loadDetail','cyl_num='+cyl_num+'&product_num='+product_num,'fixedHeightContentDiv');
        }
    </script>
    ";
    return $html;
}
function getCylinderLocations(){
    #Returns a table of all current cylinder locations
    $loc=getHTTPVar('cl_location');
    $cyl=getHTTPVar('cl_clyID');
    $use=getHTTPVar('intended_use');
    $site=getHTTPVar('intended_site');
    $int_cal_on_next_checkin=getHTTPVar('int_cal_on_next_checkin',0,VAL_BOOL);
    $fin_cal_on_next_checkin=getHTTPVar('fin_cal_on_next_checkin',0,VAL_BOOL);
    $next_checkin_comment=getHTTPVar('next_checkin_comment');
    bldsql_init();
    
    $join="cylinder c join location l on c.location_num=l.num 
            left join cylinder_checkin_notes n on c.num=n.cylinder_num and n.fill_code=reftank.f_getFillCode(c.id,now())
            left join rgm_product_view p on p.cylinder_num=c.num and p.order_status_num in (1,2,3,4,6)
            left join intended_uses u on u.num=p.intended_use
            left join gmd.site s on s.num=p.intended_site ";
    bldsql_from($join);
    
    #bldsql_from("cylinder c");
    #bldsql_from("location l");
   # bldsql_where("c.location_num=l.num");
    bldsql_col("concat(c.num,',',ifnull(p.product_num,0)) as onClickParam");
    bldsql_col("c.id as 'Cylinder'");
    bldsql_col("concat(l.abbr,' (',l.name,')') as 'Location'");
    bldsql_col("c.location_comments as 'location detail'");
    bldsql_col("c.location_datetime as 'Date'");
    bldsql_col("c.location_action_user as 'User'");
    bldsql_col("u.name as intended_use");
    bldsql_col("s.code as intended_site");
    bldsql_col("n.next_checkin_notes");
    bldsql_col("case when n.int_cal_on_next_checkin=1 then 'X' else '' end as 'Int Cal'");
    bldsql_col("case when n.fin_cal_on_next_checkin=1 then 'X' else '' end as 'Fin Cal'");
    #bldsql_col("p.product_num");
    if($loc)bldsql_where("c.location_num=?",$loc);
    if($cyl)bldsql_where("c.id=?",$cyl);
    if($use)bldsql_where('p.intended_use=?',$use);
    if($site)bldsql_where('p.intended_site=?',$site);
    if($int_cal_on_next_checkin)bldsql_where('n.int_cal_on_next_checkin=1');
    if($fin_cal_on_next_checkin)bldsql_where('n.fin_cal_on_next_checkin=1');
    if($next_checkin_comment)bldsql_where("n.next_checkin_notes like concat('%',?,'%')",$next_checkin_comment);
    bldsql_orderby("l.abbr");
    #$sql="select c.id as 'cylinder', l.abbr as 'Location', c.location_comments as 'loc_detail', location_datetime as 'Date', location_action_user as 'user'
    #from cylinder c join location l
	#on c.location_num=l.num ";
    #echo bldsql_printableQuery();
    $html=printTable(doquery(),'cl_loadDetail',1);

    return $html;

}
function cl_loadDetail(){
    #Returns detail for cyl location history.
    $cyl=getHTTPVar("cyl_num",false,VAL_INT);
    $product_num=getHTTPVar("product_num",0,VAL_INT);#0 is used by caller so doesn't have to concat null
    $id=doquery("select id from cylinder where num=?",0,array($cyl));
    $fill_code=($id)?doquery("select reftank.f_getFillCode(?,now())",0,array($id)):'';
    $ordinfo='';$html='';
    #var_dump($product_num);
    if(!$product_num){#see if an extra
        $x=doquery("select product_num from refgas_orders.rgm_product_view where cylinder_num=? and order_num=0",0,array($cyl));
        if($x){
            $html="This cylinder is currently attached to a <a href='product_extra_edit.php?num=$x' target='_blank'>product extra</a>.";            
            return $html;
        }
        $html="<div class='title4'>Note; cylinder intended use and intended site can only be set once it is attached to an order.</div>";
    }
    $int=iu_editForm($cyl,$id,$fill_code,$product_num);
    $ordinfo=iu_getCylOrderDetail($cyl,$fill_code);

    $html.="<table width='100%'>
        <tr><td width='30%'><h3>Cylinder $id Intentions:</h3></td><td><h4>Related orders for fill:$fill_code</h4></td></tr>
        <tr><td width='30%' valign='top'>$int</td><td valign='top'>$ordinfo</td></tr>
    </table>";
   
    return $html;
/*    bldsql_init();
    bldsql_from("cylinder_location cl");
    bldsql_from("cylinder c");
    bldsql_from("location l");
    bldsql_where("c.num=cl.cylinder_num");
    bldsql_where("l.num=cl.location_num");
    bldsql_where("c.num=?",$cyl);
    bldsql_col("c.id as 'Cylinder'");
    bldsql_col("l.abbr as 'Location'");
    bldsql_col("cl.location_comments as 'location detail'");
    bldsql_col("cl.location_datetime as 'Date'");
    bldsql_col("cl.location_action_user as 'User'");
    bldsql_orderby("cl.location_datetime desc");
    return "<br><div class='title3'>Previous Locations for $id</div><div style='height:220px;width:100%' class='scrolling'>".printTable(doquery())."</div>";*/
}
?>
