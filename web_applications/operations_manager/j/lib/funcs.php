<?php
function smh_getHistory(){
    #retrieve the site manager history for posted table.
    $table=getHTTPVar("table");
    $site_num=getHTTPVar("site_num",0,VAL_INT);
    $project_num=getHTTPVar("project_num",0,VAL_INT);
    $strategy_num=getHTTPVar("strategy_num",0,VAL_INT);
    $html='';$label='History';
    if($table && $site_num && $project_num && $strategy_num){
        $site=doquery("select code from gmd.site where num=?",0,array($site_num));
        $project=doquery("select abbr from gmd.project where num=?",0,array($project_num));
        $strategy=doquery("select abbr from ccgg.strategy where num=?",0,array($strategy_num));

        bldsql_init();
        bldsql_where("a.site_num=?",$site_num);
        bldsql_where("a.project_num=?",$project_num);
        bldsql_where("a.strategy_num=?",$strategy_num);
        bldsql_orderby("a.modification_datetime,num");
        if($table=='site_coop'){
            bldsql_from("site_coop_archive a");
            bldsql_col("modification_datetime as modified,name,abbr,url,logo,contact,address,tel,fax,email,comment");
            $label='Cooperating Agency History';
        }elseif($table=='site_shipping'){
            bldsql_from("site_shipping_archive a");
            bldsql_col("modification_datetime as modified,send_address,send_carrier,send_doc,send_comments,return_address,return_carrier,return_doc,
              return_comments,samplesheet,meas_path,flask_type,name,tel,fax,email,mail_address,name2,tel2,fax2,email2");
            $label='Shipping and Receiving History';
        }
        else return 'Unknown table';

        $a=doquery();
        $html="<div class='max'><div class='title2'>$label<span class='title4'> (since July 2018)</span></div><div><span class='title3'> Site:$site Project:$project Strategy:$strategy</span></div>".printTable($a)."</div>";

    }else return "asdfasdf";
    return $html;
}
?>

