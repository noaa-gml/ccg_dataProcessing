<?php
require_once("./lib/cylinder_funcs.php");

#Do some gymnastics to get the include dir.  This is an issue because the dev site is in a subdir.. argh.
$cwd=getcwd();
$dbutils_dir=($cwd=="/var/www/html/rgm")?"../inc/dbutils":"../../../inc/dbutils";
$dbutils_dir="../../inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
db_connect("./lib/config.php");

    $mou=getHTTPVar('mou');
	#scan dir and display contents for selection.
	$html='';$files=array();$selected='';
	$dir="/nfs/ccl/SalesFixedFee/MOUs/1-signed/";
   	# '/xyz.*\.(pdf|jpg)$/i';
	#$dir="/var/www/html/mund";
	if($dir){
	    $t = preg_grep('~'.$mou.'\.(pdf|jpeg|jpg|png)$~i', scandir($dir));#scandir($dir);
	    if($t){
            $filename=array_shift($t);#just take the first.  We may want to improve and show a matching list or show all with this selected and let them browse, but that wasn't asked for yet
            $html=streamPDF($dir."/".$filename,0,0);
            #"<img src='/j/switch.php?doWhat=loadImg&filename=${filename}&dir=${dir}&uid=".uniqid()."'>";
            
            
            /*foreach($t as $file){
                $files[$file]=$file;#expected format for select wrapper
                if(!$selected)$selected=$file;#save off first to preselect
            }
            $html=getSelectFromArray('selectedFile',$files,$selected,10,'loadFile()');
            if($selected)$html.="<script>loadFile();</script>";*/
        }else $html.="<h4>No matching file found for $mou</h4><div class='sm_ital'>If this happens a lot or you expect this mou to be in the directory, ask John to improve the search or provide a list of similar files for you to select.</div>";
	}

	echo $html;



    ?>










