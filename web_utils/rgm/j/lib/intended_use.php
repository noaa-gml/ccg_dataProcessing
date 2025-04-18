<?php
#Note editOrders_funcs.php calls submit and selects from product_view too.

function iu_editForm($cylinder_num,$cylinder_id,$fill_code,$product_num=0){
/*Returns edit form for target cylinder, current fill only.We put into a popup for convienence so we can use the form sub logic.*/
    $html="";$intended_site='';$intended_use='';$next_checkin_comment='';$site='';$use='';$int='';

    #$fill_code=doquery("select reftank.f_getFillCode(?,now())",0,array($cylinder_id));
    if(!$fill_code)$int="No fill entry for this cylinder.  Initial fill entry is required to enter intentions.";
    else{
        #$a=doquery("select intended_use,intended_site,next_checkin_notes as next_checkin_comment from cylinder_intentions where cylinder_num=? and fill_code=?",-1,array($cylinder_num,$fill_code));
        if($product_num){
            $a=doquery("select intended_use,intended_site from product where num=?",-1,array($product_num));
            if($a){extract($a[0]);}#overwrites init'd vars}
        }
        #return($product_num);
        $next_checkin_comment=doquery("select next_checkin_notes from cylinder_checkin_notes where cylinder_num=? and fill_code=?",0,array($cylinder_num,$fill_code));
        $int_cal_on_next_checkin=doquery("select int_cal_on_next_checkin from cylinder_checkin_notes where cylinder_num=? and fill_code=?",0,array($cylinder_num,$fill_code));
        $fin_cal_on_next_checkin=doquery("select fin_cal_on_next_checkin from cylinder_checkin_notes where cylinder_num=? and fill_code=?",0,array($cylinder_num,$fill_code));
        if($intended_site)$site=doquery("select code from gmd.site where num=?",0,array($intended_site));
        if($intended_use)$use=doquery("select name from refgas_orders.intended_uses where num=?",0,array($intended_use));
        $fields=iu_getEditWidget($intended_use,$intended_site,'',true,true,$next_checkin_comment,$int_cal_on_next_checkin,$fin_cal_on_next_checkin,($product_num));#hide intentions when not attached to an active order.
        $form="<input type='hidden' id='iu_cylinder_num' name='iu_cylinder_num' value='$cylinder_num'>
            <input type='hidden' id='iu_product_num' name='iu_product_num' value='$product_num'>
            <input type='hidden' id='iu_fill' name='iu_fill' value='$fill_code'>
            <table>$fields</table>";
        $exists=($intended_site || $intended_use || $next_checkin_comment ||$int_cal_on_next_checkin || $fin_cal_on_next_checkin);
        $btext=($exists)?"Edit":"Enter intentions";
        $edit=getPopUpForm($form,'Cylinder Intentions','Edit Cylinder Intentions',$btext,"iu_submitForm",'','','Submitting...',$btext,'','','400');
        
        $int="<table>";
        $recaltext=($int_cal_on_next_checkin||$fin_cal_on_next_checkin)?"Yes":'';
        if($exists){
            $int.="<tr><td class='label'>Use:</td><td style='border-bottom:thin solid silver;' class='data'>$use</td></tr>
            <tr><td class='label'>Site:</td><td style='border-bottom:thin solid silver;' class='data'>$site</td></tr>
            <tr><td class='label'>Next checkin<br> notes:</td><td style='border-bottom:thin solid silver;' class='data'>$next_checkin_comment</td></tr>
            <tr><td class='label'>Re-cal on next checkin:</td><td>$recaltext</td></tr>";
        }else $int.="<tr><td colspan='2'><i>None set.</i></td></tr>";
        $int.="<tr><td colspan='2' align='right'>$edit</td></tr></table>";
    }    
    return $int;
}
function iu_getCylOrderDetail($cylinder_num,$fill_code){
    $html='';
    $sql="select distinct concat('<a target=\"_new\" href=\"index.php?mod=orders&order_num=',order_num,'\">',order_num,'</a>') as 'Order #',
            organization,order_status,due_date 
        from rgm_calrequest_view 
        where cylinder_num=? and fill_code=? 
        order by due_date desc";
    $a=doquery($sql,-1,array($cylinder_num,$fill_code));
    if($a){
        $html.=printTable($a);
    }
    
    return $html;
}
function iu_updateProductIntentions($product_num,$intended_use,$intended_site){
    #update product table intentions.  Returns false on error.
    #var_dump($product_num);exit();
    if(!$intended_use)$intended_use='NULL';
    if(!$intended_site)$intended_site='NULL';
    if(!$product_num){
        if($intended_use=='NULL' && $intended_site=='NULL') return false;#just return with no action
        else return getPopupAlert("Intended use and site can only be set once a cylinder is attached to an order");
    }
    $sql="update product set intended_use=$intended_use,intended_site=$intended_site where num=?"; #not useing binding so we can set to null (see dbutils.php->runquery() for details).  Note, values are filtered to ints on read.
    $parameters=array($product_num);
    #var_dump($sql);var_dump($parameters);exit();
    if(doupdate($sql,$parameters)!==false){#
        return True;
    }else return false;

}
function iu_updateCylinderCheckinNotes($cylinder_num,$fill_code,$notes,$int_cal_on_next_checkin,$fin_cal_on_next_checkin){
    #update cyl/fill notes

    if($fill_code && $cylinder_num){
        if($fin_cal_on_next_checkin && $int_cal_on_next_checkin)$fin_cal_on_next_checkin=0;#lame radio btn.  Force only one, default to intermediate to prevent blowout of tank.
        $sql="insert cylinder_checkin_notes (cylinder_num,fill_code,next_checkin_notes,int_cal_on_next_checkin,fin_cal_on_next_checkin)
            values(?,?,?,?,?) 
            on duplicate key update next_checkin_notes=?, int_cal_on_next_checkin=?, fin_cal_on_next_checkin=?";
            
        $parameters=array($cylinder_num,$fill_code,$notes,$int_cal_on_next_checkin,$fin_cal_on_next_checkin,$notes,$int_cal_on_next_checkin,$fin_cal_on_next_checkin);
        $ret=doinsert($sql,$parameters);
        
        if($ret && ($notes || $int_cal_on_next_checkin ||$fin_cal_on_next_checkin)){#send email to duane
            $sql2="select c.id as 'cylinder', l.abbr as 'Location', c.location_comments as 'loc_detail', location_datetime as 'Date'
    from cylinder c join location l
	on c.location_num=l.num and c.id=?";
	        
            $id=doquery("select id from cylinder where num=?",0,array($cylinder_num));
            
            $fcal=($fin_cal_on_next_checkin)?"Calibration request: Do FINAL CAL on next checkin":'';
            $ical=($int_cal_on_next_checkin)?"Calibration request: Do INTERMEDIATE CAL on next checkin":'';
            $cal=($ical)?$ical:$fcal;#default to int one if both somehow checked (safer).
            $a=doquery($sql2,-1,array($id));$loc='';
	        if($a){
	            $loc.="Current Location:\n";
	            foreach($a[0] as $row=>$val){$loc.="$row:$val \n";
	            }
	        }
	        $user=db_getAuthUser();
	        if(!$user)$user='Some one';
            $msg="
Hi Duane,
$user set the 'do a cal on next check in' box or 
added some general checkin notes for you on cylinder: $id.

$cal


Checkin Notes:$notes

https://omi.cmdl.noaa.gov/rgm/index.php?mod=cylinderLocations&cl_clyID=$id

$loc

            ";
            
            send_email("duane.r.kitzis@noaa.gov john.mund@noaa.gov","Checkin instructions for cylinder $id",$msg);
            #send_email(" john.mund@noaa.gov","Checkin instructions for cylinder $id",$msg);
        }
        if($ret){
            return True;
        }else return False;
    }else return False;
}

function iu_getEditWidget($intended_use,$intended_site,$class='',$asRows=false,$inc_next_checkin=False,$next_checkin_comment='',$needs_int_cal=0,$needs_fin_cal=0,$show_intentions=true){
#returns form objects for intendeds
#if !show_intentions, we disable the intended uses (like when not assigned to a product yet on cyl locs search page.)
    $intended_use_sel='';$intended_site_sel='';
    
    bldsql_init();
    bldsql_from("intended_uses u left join gmd.project p on u.project_num=p.num");
    bldsql_distinct();
    bldsql_col("u.num as 'value'");
    if($asRows){
        bldsql_col("u.name as 'display_name'");
        bldsql_col("p.abbr as 'group_name'");
        $usewidth='';
    }else{
        bldsql_col("u.abbr as 'display_name'");
        $usewidth='7em';
        bldsql_col("p.abbr as 'group_name'");
    }
    bldsql_orderby("u.abbr");
    #echo bldsql_printableQuery();
    $intended_use_sel=getSelectInput(doquery(),'intended_use',$intended_use,'',true,$usewidth,(!$show_intentions),false,$class);
    $sql="select distinct site_num as 'value', site as 'display_name',project as 'group_name' from ccgg.data_summary_view v where project_num in(3,4) order by project,site";
    $intended_site_sel=getSelectInput(doquery($sql),'intended_site',$intended_site,'',true,'5em',(!$show_intentions),false,$class);

    
    $next='';
    if($inc_next_checkin){//Include comments to show on next check in
        $nci="<tr><td colspan='2'>".getCheckBoxInput('int_cal_on_next_checkin','Needs Intermediate Cal on next check in',$needs_int_cal)."</td></tr>
            <tr><td colspan='2'>".getCheckBoxInput('fin_cal_on_next_checkin','Needs Final Cal on next check in',$needs_fin_cal)."</td></tr>
        ";
        $next=getTextAreaInput('next_checkin_comment',$next_checkin_comment,$rows='3',$cols='25',$class='');
        if($asRows)$next="<tr><td class='label'>Next check-in notes:</td><td class='data'>$next</td></tr>$nci";
        else $next=" Next check-in:$next";
        
    }

    if($asRows)return "
    <tr>
        <td class='label'>Intended use:</td>
        <td class='data'>$intended_use_sel</td>
        
    </tr>
    <tr>
        <td class='label'>Intended site:</td>
        <td class='data'>$intended_site_sel</td>
    </tr>
    $next";
    
    else return "
    <span>Intended: Use${intended_use_sel} site${intended_site_sel}$next</span>
    ";
}


?>