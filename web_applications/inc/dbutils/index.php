<?php
require_once("./dbutils.php");
db_connect();
?>

<html>
    <head><SCRIPT language='JavaScript' src="./graphing/flot/jquery.min.js"></SCRIPT>
        <?php echo get_dbutilsHeaderIncludes("./");?>
         
    </head>
    <body>
        <?php
        #examples
        $limitToEvs=true;
        bldsql_init();
        
        bldsql_from("gmd.site s");
        bldsql_where("upper(s.code) like ?","A%");
        
        if($limitToEvs){
            bldsql_from("ccgg.flask_event e");
            bldsql_where("e.site_num=s.num");
            bldsql_distinct();
        }
        
        bldsql_col("s.name");
        bldsql_col("s.code");
        bldsql_col("count(*) as '# samples'");
        
        bldsql_groupby("s.name");
        bldsql_groupby("s.code");
        
        bldsql_orderby("s.name desc");
        echo printTable(doquery());
    
/*
        doquery("create temporary table temp (id int, name char(4))");
        
        bldsql_init();
        bldsql_insert("temp");
        bldsql_set("id=?","1");
        bldsql_set("name=?","asdf");
        
        doinsert();
        bldsql_set("id=?","2");
        bldsql_set("name=?","two");
        
        
        
        doinsert();
        bldsql_set("id=?","3");
        bldsql_set("name=?","thre");
        
         doinsert();
        
        bldsql_init();
        bldsql_update("temp");
        bldsql_set("id=?","2");
        bldsql_set("name=?","sdf");
        bldsql_where("id=?","1");
        $a=doupdate();
        
        
        $a=doquery("select * from temp where 1=1");
        echo printTable($a);
 */       
        
        
        ?>
        <br><br><h3>MLO</h3>


<div id='graphDiv' style='width:600px;height:300px;'>
    <?php
    /*basic graphing ex.  Requiures jquery link above.*/
        bldsql_init();
        bldsql_from("ccgg.flask_data_view v");
        bldsql_col("v.parameter as 'series'");
        bldsql_col("timestamp(v.ev_date,v.ev_time) as x");
        bldsql_col("avg(v.value) as y");
        bldsql_where("v.parameter_num in (1,2,3)");
        bldsql_where("v.site='mlo'");
        bldsql_where("v.ev_date>?",'2014-01-01');
        bldsql_where("v.ev_date<?",'2016-01-01');
        bldsql_groupby("v.parameter");
        bldsql_groupby("timestamp(ev_date,ev_time)");
        
        $a=doquery();
        echo printGraph($a);
       ?>
    </div><br>
Or a clickable one:<br>
    <?php 
     #or maybe
        $divID="plotDiv";$plotVar='plotVar';
        $seriesOptions['co2']="yaxis:2";
        $seriesOptions['co']="yaxis:3";
        $options="series: { lines: { show: true }, points: { show: true }},xaxis:{mode:\"time\",timeformat:\"%Y/%m/%d\"}, grid:{clickable:true,hoverable:true}";
        echo "<div id='plotDiv' style='width:800px;height:300px;'>".printGraph($a,$divID,$plotVar,"plotClicked", "plotHover",$seriesOptions,$options)."</div>";
    
    ?>
<div id='plotClickedOut'></div>
<div id='plotHoverOut'></div>
</body>
</html>
<script language='JavaScript'>
    function plotClicked(event,pos,item) {
        o="clicked at "+pos.x+", "+pos.y+".";
        if (item) {
            plotVar.highlight(item.series,item.datapoint);
            o+="point clicked";
        }
        
        $("#plotClickedOut").html(o);
        
    }
    function plotHover(event,pos,item) {
        if (item) {
            o="hovering: "+item.datapoint[0];
             $("#plotHoverOut").html(o);
        }
    }
</script>