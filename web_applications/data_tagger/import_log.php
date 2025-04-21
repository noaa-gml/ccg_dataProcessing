<?php
#echo phpinfo();exit();

$dbutils_dir="/var/www/html/inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
db_connect("./lib/config.php");
#session_start();
#session_write_close(),

?><!DOCTYPE html>
<HTML>
<HEAD>
    <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
    <meta charset="UTF-8">

</HEAD>
<body>
    <?php
    #!!!!Various functions to import tags from various places prior to conversion.  None of these can be reused blindly.  There is likely data
    #that has changed on imported items so it is not safe to run these functions (which delete data first).  Also note the
    #auto_generated_from_initial_conversion column has changed name so some of these queries won't work.
    
    
    #echo doquery("select now()",0);
    #importMFlagFile("measurement_flag_log.txt");
    #importCFlagFile("collection_flag_log.txt");
    #importTagsFromFlag();
    
    function importTagsFromFlag(){
        $tagImportNum=5;
        doquery("create temporary table t_data_nums as select num from flask_data where 1=0",false);
        doquery("create temporary table t_event_nums as select num from flask_event where 1=0",false);
        #doquery("create temporary table t_mflags (site varchar(3),event_num int, adate date,atime time,inst varchar(8),program varchar(4),parameter varchar(10),tag_num int,comment text)");
        #doquery("delete d from flask_event_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=$tagImportNum",false);
        #doquery("delete d from flask_data_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=$tagImportNum",false);
        #doquery("delete from tag_ranges where auto_generated_from_initial_conversion=$tagImportNum",false);
        doquery("create temporary table t_md2 (data_num int, adate date, tag_num int, comment text)",false);
           
        
        bldsql_init();
        bldsql_from("mund_dev.target_nums t");
        bldsql_where("t.tag_num is not null");
        bldsql_col("t.data_num");
        bldsql_col("t.tag_num");
        $a=doquery();
        
        if($a){
            foreach($a as $i=>$row){
                extract($row);
                    #Insert
                    #See if already part of a range (i was replacing obvious single entries with ranges)
                    $exists=doquery("select count(*) from flask_data_tag_view where data_num=$data_num and tag_num=$tag_num",0);
                    if($exists){continue;}
                    doquery("delete from t_data_nums",false);
                    $sql="insert t_data_nums select $data_num ";
                    doquery($sql,false);
                    $status="1";$mssg="";$numrows="";$a=false;$sql="";$bArray=array();$logKeySQL="";$logText="";$logKeys="";
                    $statusSQL="select @v_status as status, @v_mssg as mssg, @v_numrows as numrows";
                    $statusSQL.=", @v_range_num as range_num";
                    $v_userID=db_getAuthUserID();
                    $sql="call tag_createTagRange (?,?,?,0,'',$tagImportNum,?,@v_status,@v_mssg,@v_numrows,@v_range_num)";
                    $bArray=array($v_userID,$tag_num,'','imported from existing flag');
                    doquery($sql,false,$bArray);
        
                    #Fetch the status
                    $a=doquery($statusSQL);
                    if($a)extract($a[0]);
                    #echo "inserting $fullLine<br>";
                    echo "status:$status mssg:$mssg numrows:$numrows range_num:$range_num<br><br>";
                
                    #echo printTable(doquery("select * from t_md2"));
                    
                        
                
            }
            
        }
        doquery('update tag_ranges set comment=replace(comment,"john.mund","Imported from existing flag") where auto_generated_from_initial_conversion='.$tagImportNum,false);
                                    
    }
    function importTagsFromComments(){
        doquery("create temporary table t_data_nums as select num from flask_data where 1=0",false);
        doquery("create temporary table t_event_nums as select num from flask_event where 1=0",false);
        #doquery("create temporary table t_mflags (site varchar(3),event_num int, adate date,atime time,inst varchar(8),program varchar(4),parameter varchar(10),tag_num int,comment text)");
        doquery("delete d from flask_event_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=3",false);
        doquery("delete d from flask_data_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=3",false);
        doquery("delete from tag_ranges where auto_generated_from_initial_conversion=3",false);
        doquery("create temporary table t_md2 (data_num int, adate date, tag_num int, comment text)",false);
           
        
        bldsql_init();
        bldsql_from("flask_data_view v");
        bldsql_where("v.project='ccg_surface'");
        bldsql_where("v.strategy='pfp'");
        bldsql_where("v.comment like '%internal_flags%'");
        bldsql_col("v.data_num");
        bldsql_col("v.adate");
        bldsql_col("v.event_num");
        bldsql_col("v.comment");
        bldsql_orderby("v.event_num,v.data_num");
        #bldsql_limit(1000);
        #echo printTable(doquery());
        $a=doquery();
        
        if($a){
            $Ls=0;
            $Os=0;
            $existings=0;$dataNums="";
            $flagCounts=array();
            $newFlags=array();
            foreach($a as $i=>$row){
                #if($i%1000==0)print "$i<br>";
                $data_num=$row['data_num'];
                $event_num=$row['event_num'];
                $adate=$row['adate'];
                #print($row['comment']);
                $fields=explode("~+~",$row['comment']);
                foreach($fields as $el){
                    #print($el."<br>");
                    if(strpos($el,"internal_flags:")===0){
                        $f=substr($el,15);
                        $fs=explode("||",$f);
                        foreach($fs as $flag){
                            $parts=explode("|",$flag);
                            $type="";
                            if($parts[0]=="collection_flag")$type="collection_issue=1";
                            elseif($parts[0]=="automated_selection_flag")$type="selection_issue=1";
                            elseif($parts[0]=='measurement_flag')$type='measurement_issue=1 and program_num=1';
                            elseif($parts[0]=='automated_measurement_flag')$type='measurement_issue=1 and automated=1 and program_num=1';
                            elseif($parts[0]=='automated_collection_flag')$type='collection_issue=1 and automated=1';
                            if($type){
                                #print(join("|",$parts)."<br>");
                                if(isset($flagCounts[$type." ".$parts[1]]))$flagCounts[$type." ".$parts[1]]++;
                                else $flagCounts[$type." ".$parts[1]]=1;
                                $sql="select count(*) from tag_view where $type and flag='".$parts[1]."'";
                                $c=doquery($sql,0);
                                if($c!=1)print("can't find flag $flag<br>$sql<br>");
                                $sql="select num from tag_view where $type and flag='".$parts[1]."' ";
                                $tag_num=doquery($sql,0);
                                #NEED NEW Tag for 356 automated selection issue L - if($c!=1)print("can't find flag $flag<br>$sql<br>");
                                if($tag_num && $type!="collection_issue=1" ){
                                    $sql="select count(*) from 
                                        (select data_num, tag_num from flask_data_tag_view
                                            where tag_num=$tag_num and data_num=$data_num
                                            union
                                        select d.num,t.tag_num from flask_data d, flask_event_tag_view t
                                            where d.event_num=t.event_num and t.tag_num=$tag_num and d.num=$data_num)
                                        as t_";
                                    $c=doquery($sql,0);
                                    if($c==0){
                                        #print "Flag doesn't exist yet(ev:$event_num d:$data_num): $flag<br>";
                                        #$Os++;
                                        if(isset($newFlags[$type." ".$parts[1]]))$newFlags[$type." ".$parts[1]]++;
                                        else $newFlags[$type." ".$parts[1]]=1;
                                        $dataNums.=",$data_num";
                                        #Insert
                                        #doquery("insert t_md2 select $data_num,'$adate',$tag_num,''",false);
                                        #echo "insert t_md2 select $data_num,'$adate',$tag_num,'';<br>";
                                        
                                        doquery("delete from t_data_nums",false);
                                        $sql="insert t_data_nums select $data_num ";
                                        doquery($sql,false);
                                        $status="1";$mssg="";$numrows="";$a=false;$sql="";$bArray=array();$logKeySQL="";$logText="";$logKeys="";
                                        $statusSQL="select @v_status as status, @v_mssg as mssg, @v_numrows as numrows";
                                        $statusSQL.=", @v_range_num as range_num";
                                        $v_userID=db_getAuthUserID();
                                        $sql="call tag_createTagRange (?,?,?,0,'',3,?,@v_status,@v_mssg,@v_numrows,@v_range_num)";
                                        $bArray=array($v_userID,$tag_num,$flag,'imported from comments');
                                        doquery($sql,false,$bArray);
                            
                                        #Fetch the status
                                        $a=doquery($statusSQL);
                                        if($a)extract($a[0]);
                                        #echo "inserting $fullLine<br>";
                                        echo "status:$status mssg:$mssg numrows:$numrows range_num:$range_num<br><br>";
                                    
                                        #echo printTable(doquery("select * from t_md2"));
                                        
                                    }else $existings++;
                                }else $Ls++;
                                
                            }else {print("unknown flag type:".$parts[0]." quiting");exit();}
                            
                            #print(join("~",$parts)."<br>");
                        }
                        #print("<br>-$el<br>-$f<br><br>");
                        
                    }
                }
            }
            
        }
        echo "$dataNums<br><br>";
        #echo printTable(doquery("select * from t_md2"));
        #foreach ($flagCounts as $flag=>$num)print "$flag:$num<br>";
        print("new flags<br>");
        foreach ($newFlags as $flag=>$num)print("$flag:$num<br>");
        print("num existing:$existings, existing tags to add: $Os others: $Ls<br>");
        print("$Ls selection issues (L) that need a new tag entry.<br>$Os issues not yet in, that could be inserted<br>");
        doquery('update tag_ranges set comment=replace(comment,"john.mund","Imported from comment") where auto_generated_from_initial_conversion=3',false);
                                    
    }
    function importMFlagFile($file){
        $a=file($file);
        if($a){
            doquery("create temporary table t_data_nums as select num from flask_data where 1=0",false);
            doquery("create temporary table t_event_nums as select num from flask_event where 1=0",false);
            #doquery("create temporary table t_mflags (site varchar(3),event_num int, adate date,atime time,inst varchar(8),program varchar(4),parameter varchar(10),tag_num int,comment text)");
            doquery("delete d from flask_event_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=2",false);
            doquery("delete d from flask_data_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=2",false);
            doquery("delete from tag_ranges where auto_generated_from_initial_conversion=2",false);
            doquery("create temporary table t_md2 (data_num int, adate date, tag_num int, comment text)",false);
            foreach($a as $line){
                if($line){
                    
                    if($line[0]=='#')continue;
                    $fullLine=$line;
                    $fields = preg_split('/\s+/', $line,15);#assume remaining is comments
                    
                    #print join("|",$fields)."<br>";
                    $site=$fields[0];
                    $event_num=$fields[1];
                    $adate=$fields[2].'-'.$fields[3].'-'.$fields[4];
                    $atime=$fields[5].':'.$fields[6].':'.$fields[7];
                    $inst=$fields[8];
                    $species=$fields[9];
                    $flag=$fields[10];
                    $comment=$fields[14];
                    #print("$site|$event_num|$adate|$atime|$inst|$species|$flag|$comment<br>");
                    $sp=explode(":",$species);
    #if(count($sp)!=){echo $species;exit();}
                    $prog=$sp[0];$param=$sp[1];
                    #echo $param."<br>";
                    
                    #lookup flag
                    if($flag=='A')$tag_num=23;
                    elseif($flag=='0')$tag_num=37;
                    else{echo $flag;exit();}
                    
                    #echo "insert t_mflags select '$site',$event_num,'$adate','$atime','$inst','$prog','$param',$tag_num,'$comment';<br>";
                    bldsql_init();
                    bldsql_from("flask_data_view");
                    bldsql_col("data_num");
                    bldsql_col("adate");
                    bldsql_col($tag_num);
                    bldsql_col("'$comment'");
                    #bldsql_into("t_md2");
                    bldsql_where("site='$site'");
                    bldsql_where("event_num=$event_num");
                    bldsql_where("adate='$adate'");
                    bldsql_where("atime='$atime'");
                    bldsql_where("inst='$inst'");
                    bldsql_where("parameter='$param'");
                    bldsql_where("program='$prog'");
                    doquery("insert t_md2 ".bldsql_cmd(),false);
                    #echo "insert t_md2 ".bldsql_cmd().";<br>";
                    
                    
                }
            }
            doquery("delete from t_event_nums",false);
            $a=doquery("select distinct adate,tag_num,comment from t_md2");
            foreach($a as $row){
                doquery("delete from t_data_nums",false);
                $sql="insert t_data_nums select data_num from t_md2 where adate='".$row['adate']."' and tag_num=".$row['tag_num']." and comment='".$row['comment']."'";
                doquery($sql,false);
                $status="1";$mssg="";$numrows="";$a=false;$sql="";$bArray=array();$logKeySQL="";$logText="";$logKeys="";
                $statusSQL="select @v_status as status, @v_mssg as mssg, @v_numrows as numrows";
                $statusSQL.=", @v_range_num as range_num";
                $v_userID=db_getAuthUserID();
                $sql="call tag_createTagRange (?,?,?,0,'',2,?,@v_status,@v_mssg,@v_numrows,@v_range_num)";
                $bArray=array($v_userID,$row['tag_num'],$row['comment'],'imported from log file');
                doquery($sql,false,$bArray);
    
                #Fetch the status
                $a=doquery($statusSQL);
                if($a)extract($a[0]);
                #echo "inserting $fullLine<br>";
                echo "status:$status mssg:$mssg numrows:$numrows range_num:$range_num<br><br>";
            }
            doquery('update tag_ranges set comment=replace(comment,"john.mund","Imported from file") where auto_generated_from_initial_conversion=2',false);
            #echo printTable(doquery("select * from t_md2"));
        }
    }
    function importCFlagFile($file,$process9s=false){#Import a Molly flag file.
        #!DO NOT RUN ON PROD SERVER ANY MORE!  Changes have been made in interface to some of the imported tags!
        #!WAS Missing PFP and CCG_SURFACE filters on event selection.  If ever referenced again, those are implicit in Molly's list.
        return false;
        $a=file($file);    
        if($a){
            doquery("create temporary table t_data_nums as select num from flask_data where 1=0",false);
            doquery("create temporary table t_event_nums as select num from flask_event where 1=0",false);
            doquery("delete d from flask_event_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=1",false);
            doquery("delete d from flask_data_tag_range d, tag_ranges r where d.range_num=r.num and r.auto_generated_from_initial_conversion=1",false);
            doquery("delete from tag_ranges where auto_generated_from_initial_conversion=1",false);
            foreach($a as $line){
                if($line){
                    doquery("delete from t_data_nums",false);
                    doquery("delete from t_event_nums",false);
                    if($line[0]=='#')continue;
                    $fullLine=$line;
                    bldsql_init();
                    bldsql_from("flask_data_view");
                    $prg_paramWhere="";
                    #strip out the date & time.
                    $t=substr($line,0,10);
                    $line=substr($line,10);
                    $start=str_replace(" ","-",$t);
                    $t=substr($line,1,8);
                    $t=str_replace(" ",":",trim($t));
                    if($t)$start.=" $t";
                    else $start.=" 00:00:00";
                    $line=substr($line,11);
                    bldsql_where("timestamp(ev_date,ev_time)>=?",$start);
                    
                    $t=substr($line,0,10);
                    $line=substr($line,10);
                    $end=str_replace(" ","-",$t);
                    $t=substr($line,1,8);
                    $t=str_replace(" ",":",trim($t));
                    if($t)$end.=" $t";
                    else $start.=" 00:00:00";
                    $line=substr($line,11);
                    
                    if($end[0]!='9'|| $process9s)bldsql_where("timestamp(ev_date,ev_time)<=?",$end);
                    else{
                        echo "skipping $fullLine<br>";
                        continue;
                    }
                    
                    $fields = preg_split('/\s+/', $line,8);#assume remaining is comments
                    $site=$fields[0];
                    bldsql_where("site=?",$site);
                    
                    $sp=$fields[1];
                    $flag=$fields[2];
                    #lookup flag
                    $c=doquery("select count(*) from tag_dictionary where flag ='$flag' and collection_issue=1",0);
                    if($c!=1){
                        echo "Num matches:$c.  Skipping because couldn't match flag '$flag': $fullLine<br>";
                        continue;
                    }
                    $tag_num=doquery("select num from tag_dictionary where flag ='$flag' and collection_issue=1",0);
                    $prelim=$fields[3];
                    $flag_date=$fields[4]."-".$fields[5]."-".$fields[6];
                    $comment=$fields[7];
                    
                    $description="(imported) ".substr($fullLine,0,strpos($fullLine,$comment)-12);
    
                    #parse out the species list
                    $tagType=($sp=="*")?"event":"data";
                    if($tagType=='data'){
                        bldsql_col("data_num as num");
                        bldsql_into("t_data_nums");
                        $t=explode(",",$sp);
                        #echo "---".$sp."<br>";
                        $prgWhere="";
                        foreach($t as $prg){
                            $not=false;$species="";$program="";$speciesList=array();
                            if($prg[0]=="("){
                                $not=true;
                                $prg=substr($prg,1);
                                $prg=substr($prg,0,-1);
                            }
                            $t2=explode(":",$prg);#any species?
                            $program=$t2[0];
                            if(count($t2)>1){
                                $species=$t2[1];
                                $speciesList=explode("|",$species);
                            }
                            $prgWhere="(program='$program'";
                            if($speciesList){
                                if($not){$prgWhere.=" and parameter not in (";}
                                else $prgWhere.=" and parameter in (";
                                $tsp="";
                                foreach($speciesList as $parameter){
                                    $tsp=appendToList($tsp,"'$parameter'");
                                }
                                $prgWhere.="$tsp)";
                            }
                            $prgWhere.=")";
                            $prg_paramWhere=appendToList($prg_paramWhere,$prgWhere," or ");
                            #echo "$not~$program~$species<br>";
                        }
                        bldsql_where("($prg_paramWhere)");
                    }else{
                        bldsql_col("event_num as num");
                        bldsql_into("t_event_nums");
                    }
                    
                   
                    #echo bldsql_printableQuery()."<br>";
                    doselectinto();
                    bldsql_init();
                    bldsql_col("site");
                    bldsql_col("project");
                    bldsql_col("min(timestamp(ev_date,ev_time)) as start");
                    bldsql_col("max(timestamp(ev_date,ev_time)) as end");
                    bldsql_groupby("site");
                    bldsql_groupby("project");
                    bldsql_orderby("v.site");
                    bldsql_orderby("timestamp(ev_date,ev_time)");
                    if($tagType=='data'){
                        bldsql_from("flask_data_view v");
                        bldsql_from("t_data_nums t");
                        bldsql_where("v.data_num=t.num");
                        bldsql_col("v.program");
                        bldsql_col("v.parameter");
                        bldsql_groupby("v.program");
                        bldsql_groupby("v.parameter");
                        bldsql_orderby("v.program");
                        bldsql_orderby("v.parameter");
                    }else{
                        bldsql_from("flask_event_view v");
                        bldsql_from("t_event_nums t");
                        bldsql_where("t.num=v.event_num");
                
                    }
                    
                    
                    #$a=doquery("select site,project,strategy,,program,parameter from flask_data_view v, t_data_nums t where v.data_num=t.num");
                    #else $a=doquery("select * from flask_event_view v, t_event_nums t where v.event_num=t.num");
                    #var_dump($a);
                    #echo bldsql_printableQuery()."<br>";
                    #echo printTable(doquery());#exit;
                    $status="1";$mssg="";$numrows="";$a=false;$sql="";$bArray=array();$logKeySQL="";$logText="";$logKeys="";
                    $statusSQL="select @v_status as status, @v_mssg as mssg, @v_numrows as numrows";
                    $statusSQL.=", @v_range_num as range_num";
                    $v_userID=db_getAuthUserID();
                    $sql="call tag_createTagRange (?,?,?,?,?,1,?,@v_status,@v_mssg,@v_numrows,@v_range_num)";
                    $bArray=array($v_userID,$tag_num,$comment,$prelim,'',trim($description));
                    doquery($sql,false,$bArray);
        
                    #Fetch the status
                    $a=doquery($statusSQL);
                    if($a)extract($a[0]);
                    echo "inserting $fullLine<br>";
                    echo "status:$status mssg:$mssg numrows:$numrows range_num:$range_num<br><br>";
                    
                }
            }
            doquery('update tag_ranges set comment=replace(comment,"john.mund","Imported from file") where auto_generated_from_initial_conversion=1',false);
        }
    }


    ?>
</body>
</html>















