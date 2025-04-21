<?php
/*Various functions for db interactions and to wrap layout utilities using bootstrap.*/

#Set a flag to selectively load some libraries and dependencies
define("BS_LIB_BEING_USED",True);

#unix directory of utility functions (parent of bs utils dir)
define("UTILS_ROOT",WWW_ROOT.UTILS_ROOT_RELPATH);

#Web visible Bootstrap Dir relative path for including resources and src files
define("BOOTSTRAP_UTILS_RELPATH",UTILS_ROOT_RELPATH."/bs");

#web visible relative path to bootstrap source (from www_root).  Version we are on..
#For transitioning to new version, this could be conditional from index.php setting
#if($bs_version==5)... else..
define("BOOTSTRAP_SRC_RELPATH",BOOTSTRAP_UTILS_RELPATH."/src/bootstrap-5.3.2-dist");
define("BOOTSTRAP_VERSION",5);//Major version for use by bs_class and other logic for upgrade transitions

#Dygraph plotting Dir
define("DYGRAPH_SRC_RELPATH",UTILS_ROOT_RELPATH."/graphing/dygraph/v2.2.1");

#Utility Libraries
require_once(UTILS_ROOT."/dbutils.php");
require_once(UTILS_ROOT."/htmlValidation.php");
require_once(UTILS_ROOT."/bs/bs_output.php");
require_once(UTILS_ROOT."/bs/bs_formUtils.php");

#Set a RO database connection if caller didn't specify
if(!isset($bs_dbConfig))$bs_dbConfig=UTILS_ROOT."/dbutils_config.php";
#Make connection echo "Submitting:$sql<br>";

#If caller set to '', we'll skip and let them make connection
if($bs_dbConfig)db_connect($bs_dbConfig);


function bs_getNavBarContents($options,$currentModule='',$includeSearch=False){
    /*Returns html for navbar widget contents (links and menus)
        $options is an array of "menu text"=>link
            link is a full url, a mod for index.php mod or a submenu array of 'menu text'=>link (only 1, 2level not currently supported.)
                subMenu items can have blank link which makes it a divider.  leave text blank too to just have an empty space
            array can be empty if no options.
        $currentModule will be highlighted in the menu

    */
    $html="";
        if($options){
            $html.="<div class='collapse navbar-collapse' id='navbarSupportedContent'>
                        <ul class='navbar-nav me-auto mb-2 mb-lg-0'>";
            foreach($options as $text=>$link){
                if(is_array($link)){#drop down menu
                    $subMenu=$link;#just for clarity
                    $linkActiveClass=(in_array($currentModule,$subMenu))?"active":"";#highlight current topline item
                    $html.="<li class='nav-item dropdown'>
                              <a class='nav-link dropdown-toggle $linkActiveClass' href='#' role='button' data-bs-toggle='dropdown' aria-expanded='false'>
                                $text
                              </a>
                              <ul class='dropdown-menu'>";
                    foreach($subMenu as $subText=>$subLink){
                        if($subLink){
                            $linkURL=(stripos($subLink,'http')===0)?$subLink:"index.php?mod=$subLink";
                            $html.="<li><a class='dropdown-item' href='$linkURL'>$subText</a></li>";
                        }else{#Divider
                            $html.="<li><hr class='dropdown-divider'>$subText</li>";
                        }
                    }
                    $html.="  </ul>
                           </li>";
                }else{#top line menu pick
                    $linkClass=($currentModule==$link)?"class='nav-link active' aria-current='page'":"class='nav-link'";#highlight current topline item
                    $linkURL=(stripos($link,'http')===0 || stripos($link,'.php')!==false)?$link:"index.php?mod=$link";#allow for relative paths too
                    $html.="<li class='nav-item'>
                              <a $linkClass href='$linkURL'>$text</a>
                            </li>";
                    #They have disabled entries too.. not needed for now: <a class='nav-link disabled' aria-disabled='true'>Disabled</a>
                }
            }
            $html.="    </ul>";
            if($includeSearch){###finish
                $html.="<form class='d-flex' role='search'>
                          <input class='form-control me-2' type='search' placeholder='Search' aria-label='Search'>
                          <button class='btn btn-outline-success' type='submit'>Search</button>
                        </form>";
            }
            $html.="</div>";
          }
    return $html;
}

function bs_getHeaderIncludes(){
    /*Return include text for html header*/
    $html=bs_getIncludeText(BOOTSTRAP_SRC_RELPATH."/css/bootstrap.min.css",'css');
    $html.=bs_getIncludeText(BOOTSTRAP_UTILS_RELPATH."/bs_utils.css",'css');
    $html.=bs_getIncludeText(BOOTSTRAP_UTILS_RELPATH."/js/bs_net.js");
    $html.=bs_getIncludeText(BOOTSTRAP_UTILS_RELPATH."/js/bs_utils.js");
    $html.=bs_getIncludeText(DYGRAPH_SRC_RELPATH."/dygraph.min.js");
    $html.=bs_getIncludeText(DYGRAPH_SRC_RELPATH."/dygraph.min.css","css");
    $html.=bs_getIncludeText(DYGRAPH_SRC_RELPATH."/smooth-plotter.js");

    return $html;
}
function bs_getBodyJSIncludes(){
    /*Returns js include for bootstrap that goes at end of body section*/
    $html=bs_getIncludeText(BOOTSTRAP_SRC_RELPATH."/js/bootstrap.bundle.js");
    return $html;
}

function bs_getIncludeText($file,$type='js',$relative=false){
        /*Returns the html head text for passed js or css file, adding a mod time to the url to force reloads.
        $file is www path to file from www_root.
        $type is js or css.
        if relative, it's relative to caller, generally index.php.  no file check or timestamp added.
        */
        $fp=WWW_ROOT.$file;
        if(file_exists($fp)){
            $t=filemtime($fp);
            if($t)$file.="?ver=$t";#This forces a reload when the file is modified.
            if($type=='js')$file="<script src='$file' type='text/javascript' language='JavaScript'></script>\n";
            else $file="<link rel='stylesheet' href='$file' type='text/css'>\n";
        }elseif($relative){
            if($type=='js')$file="<script src='$file' type='text/javascript' language='JavaScript'></script>\n";
            else $file="<link rel='stylesheet' href='$file' type='text/css'>\n";
        }else{
            var_dump("Invalid path name passed to bs_getIncludeText:$file");exit;
        }
        return $file;
}
function bs_startsWith($haystack,$needle){
    return strpos($haystack, $needle) === 0;
}
function bs_contains($haystack,$needle,$caseinsensitive=True){
    #Returns true if haystack contains needle.  There is a php8 builtin for this
    if($caseinsensitive)return (stripos($haystack,$needle)!==False);
    else return (strpos($haystack,$needle)!==False);
}
function bs_getJSTimestamp($dt,$UTCLDate=false,$pad=0){
    /*Return a unix timestamp suitable for passing to js new Date(x) obj. 0 (1970) on error.
    //NOTE UTCLDate not being used (8/22), found an option in dygraph to use utc all the way through.  Leaving in for now for reference.  pia.
    If $UTCLDate, this returns a js funciton call that returns a js date object by calling a function to create the date (the new Date() part)
    and adds the tz offset so that when javascript converts it to local tz, it will look like UTC.  Note the time will
    be off by offset now, so be careful if using this to submit back to db.  This is mostly so js plots look right (dygraph)
    JS Date parsing/tz handling absolutely sucks.
    $pad is to add a microsecond to the final time.  This is to allow caller to separate duplicate datetimes by incrementing a microsecond(for plotting)
    */
    $r=0;
    $dt=strtotime($dt);
    if($dt!==false){
        $r=($dt*1000)+$pad;#microseconds
        if($UTCLDate)$r="UTCLDate($r)";
        else $r="new Date($r)";
    }
    return $r;
}

function bs_appendToList(&$list,$new,$delim=','){#MUCH better performance on large list because of pass by reference.
    # bs_appendToList2($list,$new,',');
	if($list!=='' && $new!=='')$list.=$delim.$new;
	else $list.=$new;
}

function bs_boolstr($bool){
    #Utility to convert boolean to js compatible string.  Returns the string if not a boolean val
    if($bool===true || $bool==='true' || $bool==='True' || $bool==='TRUE')return 'true';
    elseif($bool===false || $bool==='false' || $bool==='False' || $bool==='FALSE')return 'false';
    return "'$bool'";
}

/*User interactions*/
function bs_offCanvasArea($id,$btnText,$title,$content){
    /*Returns a button that opens an off canvas area with title and content*/
    $html="
        <a class='btn btn-secondary btn-sm ' data-bs-toggle='offcanvas' href='#{$id}' role='button' aria-controls='$id'>
            $btnText
        </a>

    <div class='offcanvas offcanvas-start' tabindex='-1' id='$id' aria-labelledby='{$id}_title'>
        <div class='offcanvas-header'>
            <h5 class='offcanvas-title' id='{$id}_title'>$title</h5>
            <button type='button' class='btn-close' data-bs-dismiss='offcanvas' aria-label='Close'></button>
        </div>
        <div class='offcanvas-body'>
            $content
        </div>
    </div>";

    return $html;
}
function bs_delayedJS($func,$msDelay=100) {
    /*Run arbitrary js function on delay (so current execution cycle completes).  This is mostly needed
    so an ajax submit can fully complete before it fires off a reload or similar.)
    $func can be any arbitrary js code.
    ex $func: "ord_loadProduct($product_num);"
    */
    return "setTimeout(function(){ $func },$msDelay)";
}
function bs_alert($text,$postJS=''){
/*Shows an alert with pure js, so can go in the hidden js div
If postJS, it's run after alert returns*/
    $uid=uniqid('bs_');
    $html="<div id='{$uid}' style='display:none;'>$text</div>
        <script language='JavaScript'>
            var t=bs_getHTML('{$uid}');
            alert(t);
            $postJS
        </script>
        ";
    return $html;
}
function bs_help($text,$windowTitle="Information",$linkText="Help"){
    return bs_modal($text,$windowTitle,['linkText'=>$linkText,'dynamic'=>false]);
}
function bs_modal($text,$title='Alert',$options=[]){
    /*Show a modal alert.
     #$options can override $allowedOptions defaults
     Note; when hidden, content is still in the dom.
    */
    $fullOpts=array(
        'size'=>'',#window width: lg, xl, sm
        'divID'=>uniqid('bs_'),# ID if you will need to reference (like to close from custom buttons)
        'buttons'=>'',#pass buttons to use on form footer instead of standard 'close' btn.
        'scrollable'=>false,#pass true to allow content to scroll

        #how to launch
        'dynamic'=>false,#true to launch on load (popup alert style).  Must be put in a visible div (not hidden js div)
        #if dynamic=false, this button launches it
        'linkType'=>'button',# or link or none.
            #if none, caller must pass divID and then can launch with bs_showModal([divid])
            #to use in custom object (like an onclick event)(only supported when dynamic=false)
        'linkText'=>'Help',
        'btnClass'=>'btn-info',#btn class when displaying a btn, any bootstrap class.

        'removeClass'=>'bs_modal_hidable',#If set to bs_modal_hidable, this form will get closed when bs_hideModal() is called with ''
            #This allows you to close it withouth knowing the divID.  Set this to blank to not be included in general close.
            #Switched to this model instead of passing divID around because that was awkward and it's  expected that
            #only one modal is open at any time.
        'removeOnHide'=>false,#Remove from DOM when hidden and destroy element.  Generally not needed
            #on static content (help) or forms that are dynamically loaded/reloaded.  Maybe needed
            #in some edge cases though, so leaving in as option.
    );
    extract(bs_setOptions($fullOpts,$options));#Set default options and overrides into namespace

    $html="";
    $size=($size)?"modal-{$size}":"";
    $removeFromDom=($removeOnHide)?"true":"false";
    $scroll=($scrollable)?"modal-dialog-scrollable":"";

    #either provide a close button or use passed.
    $formButtons=($buttons)?$buttons:"<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Close</button>";

    if(!$dynamic){
        if($linkType!='none'){
            $btnClass=($linkType=='button')?$btnClass:'btn-link';
            $html.=bs_button($linkText,"bs_showModal('{$divID}',$removeFromDom);",['btnClass'=>$btnClass]);
        }
    }
    #<button type='button' class='btn btn-primary'>Save changes</button>
    $html.="
        <div class='modal fade $removeClass' id='$divID' tabindex='-1' aria-labelledby='exampleModalLabel' aria-hidden='true'>
          <div class='modal-dialog $size $scroll'>
            <div class='modal-content'>
              <div class='modal-header'>
                <h1 class='modal-title fs-5' id='{$divID}_label'>$title</h1>
                <button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
              </div>
              <div class='modal-body'>
                $text
              </div>
              <div class='modal-footer'>$formButtons</div>
            </div>
          </div>
        </div>";
        if($dynamic){
            $html.="<script>bs_showModal('{$divID}',$removeFromDom);</script>";
        }

    return $html;
}
function bs_parseCSVFile($fileName,$comment='#',$delimiter=',',$enclosure='"'){
    /*Read in and parse csv file. Output is an array of assoc arrays.
    First non-comment row is used as header
    Not optimized for large files.
    */
    $row = 1;$a=[];$headers=[];$headerCount=0;
    if (($handle = fopen($fileName, "r")) !== FALSE) {
        while(($line = fgets($handle))!== false){
        #while (($fdata = fgetcsv($handle, 1000, $delimiter)) !== FALSE) {
            if($delimiter==' '){#preprocess to collapse whitespace
                $line = preg_replace('/\s+/', ' ', $line);
            }
            $line = trim($line);
            $fdata = str_getcsv($line, $delimiter, $enclosure);
            $data=array_map('trim', $fdata);
            if ($data === null || (count($data) === 1 && $data[0] === '')) {
                continue; #skip blank lines
            }
            if(!$comment || !bs_startsWith($data[0],$comment)){#skip comments too
                if($row==1){
                    $headers=$data;
                    $headerCount=count($data);
                }else{
                    $t=[];
                    if(count($data)==$headerCount){
                        foreach($headers as $i=>$name){
                            $t[$name]=$data[$i];
                        }
                        $a[]=$t;
                    }else{
                        $err="Error reading file; incorrect number of fields:<br>";
                        $err.=join($delimiter,$data);#foreach($data as $d){$err.=$d.",";}
                        $err.="<br>Expecting:<br>";
                        $err.=join($delimiter,$headers);#foreach($headers as $d){$err.=$d."$delimiter";}
                        $err.="<br>";
                        echo($err);exit();
                    }
                }
                $row++;
            }
        }
        fclose($handle);
    }
    return $a;
}
function bs_validateCSVData($expected,$data){
	/*Validate csv data row using expected template
	$expected is  'colname'=>['type'=[datatype],'required'=[bool], 'allowed' = array(), 'min' = '', 'max' = ''] array
	$data is array of colname=>value
	returns error message on false, '' success*/
	#check order
	$error='';
	$a=array_keys($expected);
	$b=array_keys($data);
	if(count($a)!=count($b)){
	    $error.="Incorrect number of columns.  Expecting:<br> ".implode(', ',$a)."<br>Found:<br> ".implode(', ',$b);
	    if(count($b)==1)$error.="<br>Incorrect delimiter specified?  Change in import options.";
	}
	if(!$error){
        foreach($a as $i=>$col){
            if($b[$i]!=$col)$error.="Incorrect column: expected '$col', found: '".$b[$i]."'<br>";
        }
    }
	if(!$error){
		foreach($a as $col_name){
			$col=$expected[$col_name];
			$type=$col['type'];$required=$col['required'];$allowed=$col['allowed'];$min=$col['min'];$max=$col['max'];
			if($data[$col_name]=='' && $required)$error.="Row missing required field '$col_name':";
			else{
				$tmp=getHTTPVar($col_name,'',$type,$allowed,$min,$max,false,$data);
				if($tmp=='' && $required){#didn't pass getHTTPVar
					$error.="Invalid value in '$col_name' (".$data[$col_name].")<br>";
					if($allowed)$error.="Allowed values:";
					foreach($allowed as $f){bs_appendToList($error,$f);}
					$error.="<br>";
				}
			}
			if($error){
			    $error.="Error row:<br>";
				foreach($data as $f){bs_appendToList($error,$f);}
				break;
			}
		}
	}
	return $error;
}
function bs_progressBars($a){
    /*Wrapper for below using a  DB resultset.
    Expects columns bs_progress_max, bs_progress_current,
    optional bs_progress_text, bs_progress_colorClass, bs_progress_title.
    */
    $html='';
    foreach($a as $row){
        $options=[];
        if(isset($row['bs_progress_text']))$options['text']=$row['bs_progress_text'];
        if(isset($row['bs_progress_title']))$options['title']=$row['bs_progress_title'];
        if(isset($row['bs_progress_colorClass']))$options['colorClass']=$row['bs_progress_colorClass'];
        $html.=bs_progressBar($row['bs_progress_max'],$row['bs_progress_current'],$options);
    }
    return $html;
}
function bs_progressBar($max,$current,$options=[]){
    /*Output a progress bar
    max is total from 0, current is current, text shows in bar, colorClass can be any bs background class:
    ex: bg-success:green, bg-info:aquamarine, bg-warning:orange,bg-danger:red (currently)
    default '' is blue
    */
    $opt=[
        'text'=>'',#shows in bar
        'colorClass'=>"",
        'title'=>''
    ];
    foreach($options as $key=>$val){$opt[$key]=$val;}#Overwrite defaults
    extract($opt);$html='';
    $width=(($current/$max)*100);
    if($title)$html.="<div class='title4'>$title</div>";
    $html.="
    <div class='progress'>
        <div class='progress-bar $colorClass' role='progressbar' style='width:{$width}%' aria-valuenow='$current' aria-valuemin='0' aria-valuemax='$max'>$text</div>
    </div>";
    return $html;
}
function bs_class($class){
    /*Wrapper to abstract specific bs classes to make upgrades easier.  This will allow changed
    class names to be updated here by version.  (not fully implemented yet)*/

    if(BOOTSTRAP_VERSION==5){
        return $class;
    }//else... map class name changes.

}
function bs_printVar($var){
    echo "<pre>";
    var_export($var);#print_r
    echo "</pre>";
}
function bs_getThisURL($host_only=False){
    /*Returns the url used to get the current script (no parameters)*/
    // Get the protocol (http or https)
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https" : "http";

    // Get the host (e.g., www.example.com)
    $host = $_SERVER['HTTP_HOST'];

    if($host_only)return $protocol . "://" . $host;

    // Get the URI (e.g., /path/to/script.php?id=123)
    $request_uri = $_SERVER['REQUEST_URI'];

    // Parse the URL to separate path and query
    $parsed_url = parse_url($request_uri);

    // Get the base URL without the query string
    $base_url = $protocol . "://" . $host . $parsed_url['path'];

    return $base_url;
}
?>
