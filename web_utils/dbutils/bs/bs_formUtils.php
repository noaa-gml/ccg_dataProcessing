<?php
/*Various wrappers and utilities for creating and processing forms.*/

function bs_input($inputType,$id,$label='',$value='',$options=[]){
    /*HTML for standard inputs
    $inputType can be either constant int defined in htmlValidation.php or a text string:
        text, date, datetime, int, float, select,
        checkbox, radio, datalist, filteredAutocomplete).
        See bs_inputType() for list of accepted integer values

        date and datetime $value (if passed) must be in standard sql yyyy-mm-dd/ yyyy-mm-dd hh:mm:ss  format
        int and float are both html5 'number' but with different 'steps' for validation.
        select & datalist require 'listData' option (see below)

        datetime: timezone-less datetime
        select: returns html for a select input using the passed result set as options.
            $value will be pre-selected if matched.  Pass '_first_' to select the first row.
            use below bs_getSelectInputOptions if you just want the options.
            use bs_optionsResultSetFromList to turn csv into result set format
            pass listData as $a result set from doquery() with 2 named cols; value, name
            if optional group_name col exists, that will be used to group options.
        datalist: same as above for listData
        filteredAutocomplete:same as above for listData.  Opens in a popup.  Can have 2 group_name (group_name2)
        which get turned into filters.  See options below for labeling
    $id is the input id (& name)
    $label is the input label, see below for positioning
    $value is a scalar int/string or an array of int/strings (for multi selects)
    $options can be any of below $fullOpts
    */
    $fullOpts=array(
        #Visual/layout options
        'disabled'=>False,
        'size'=>'12', #int, number of characters wide for text, number, date, textarea type inputs.
            #For select If size>1 then select is displayed with that many rows.
            #   If <1, then we dynamically size it upto that number of rows

        'maxWidth'=>'', #width with units (ex: '175px').  Use this for width on selects and text area
        'height'=>'sm', #input height; '' for default, large:lg
        'labelHeight'=>'', #sm,'', lg ('' looks good)
        'labelNoWrap'=>false,#pass true to force label onto 1 line when possible.
        'class'=>'', #Optional classes
        'placeHolder'=>'',
        'preText'=>'',#Pass string to put inline before input like '$'
        'postText'=>'',#Pass string to put inline after input like 'mg'
        'preButton'=>'',#Pass a bs_button() to put inline before input
        'postButton'=>'',#Pass a bs_button() to put inline after input like submit or go
        'marginBottom'=>'1',#margin below input/label
        'autofocus'=>false, #set this input as default.  Doesn't really seem to work from ajax call though.

        #select
        'listData'=>[],#For selects, datalist or filteredAutocomplete, $listData is a result set from doquery() with 2 named cols;
            #value, name
            #if optional group_name col exists, that will be used to group options (select only).
            #   For filteredAutocomplete, it will be a column
            #for datalist &filteredAutocomplete it can also select abbr (ie site.code).  Should concat with name so searches work better though
                #if set, then this gets put in display field on select.
        'addBlankRow'=>false,#pass true for empty row at top to allow unselection.
        'multiple'=>false,#allow more than row to be selected.

        #filteredAutocomplete
        'searchBoxLabel'=>'Search <span class="bs_sm_ital">(* wildcard)</span>',#Label for search box.  First is text
        'searchBoxTimeoutMS'=>'100',#how many milliseconds after keydown does it wait to do search.  may need longer for bigger datasets
        'searchboxDisplayType'=>'text',#results area (so can switch to textarea)
        'searchWindowTitle'=>'Search',#title on popup window
        'group1ColLabel'=>'Group1',#when passed, the table col header for first group
        'group2ColLabel'=>'Group2',

        #checkbox/radio
        #Pass value=1 to have it be checked, 0 for unchecked
        #'inline'=>false,#Pass true to have adjacent checkbox/radio inputs render on same line (NOT WORKING YET).
        #'radio_n'=>'',#for radio buttons, this is n of button list and gets appended to id.

        #textarea
        'textareaHeight'=>3,#num rows of a textarea
        #'size'=>'12' (set above)

        #file input (process with bs_processUploadedFiles())
        'acceptedFiles'=>"",#any accept filters to restrict file types ex; '.csv', 'image/*', 'image/png, image/jpeg'
            #https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/accept
        #'multiple'=>false,#allow multiple files to be selected.   Commented out because also used above in select, but is a valid option

        #JS
        'onChangeFunc'=>"", #If passed, that js function will get called on change with $id passed as param.
            #Fetch value in js func like const val=bs_getEl(id).value;
        'fireOnLoad'=>False, #Fire 'change' event when loaded and a selection is made

        #Auto submit search form
        'autoSubmit'=>False, #For inputs on the search form, this will autosubmit on change. Note! doesn't work for other forms.
        'dynSearchFormEl'=>False, #For inputs on the search form, this will autosubmit on change and reload sidebar content.
            #switch.php must have a handler for doWhat='bs_reloadSearchForm' that returns dynamic content based on current values (like this el) & mod
            #For longer searchforms (like icp2), you'll probably want a custom method to do this, but this works well for smaller # of filters.

        #Label Layout
        'labelPos'=>'left', #above, left or float (inside of input).  Controls where label (if passed) is placed.
            ####!Note; float is being deprecated (by me) for layout issues.  Hard codes to above now.
        'bsLabelSize'=>'3',#bootstrap grid layout.  1-12
        'bsInputSize'=>'9',#bootstrap grid layout. 1-12. Probably shouldn't pass size or maxWidth above too.



    );
    #Extract options into namespace and keep a filtered copy
    $inputOptions=bs_setOptions($fullOpts,$options);
    extract($inputOptions);
    $class.=" p-1"; #set general 1 padding
    $inputHeight="form-control-{$height}";

    $inputType=bs_inputType($inputType);//Translate to text if needed.

    $onChange=($onChangeFunc && (!$disabled))?"onchange=\"$onChangeFunc('$id');\"":"";

    #disable?
    $ro=($disabled)?"readonly":"";
    $rocss=($disabled)?"readonly-input":'';

    $width=($maxWidth)?"max-width:$maxWidth;min-width=$maxWidth;":"";
    $af=($autofocus)?"autofocus":"";

    $step='';$input='';$html='';
    $marginBottom=($preText || $postText || $preButton || $postButton)?0:$marginBottom;//Zero out if we'll be applying to addon group

    $acceptedFiles=($acceptedFiles)?"accept='$acceptedFiles'":'';
    $multiple=($multiple)?"multiple":"";
    $inputName=($multiple)?$id."[]":$id;#php syntax for multi (select, file...). note haven't test multi select yet.
    $js='';

    $class.=' '.bs_class("form-control-sm");
    #set some defaults and config options by type
    if($inputType=='int' || $inputType=='float'){
        $step=($inputType=='float')?"step='any'":"";#Allow decimal entries.
        $inputType='number';
    }elseif($inputType=='datetime'|| $inputType=='date'){
        $inputType=($inputType=='datetime')?"datetime-local":"date";
        if($value){#convert to iso 8601 that input is expecting (with T)
            #We assume format is standard sql yyyy-mm-dd plus optional hh:mm:ss
            if (strpos($value, ' ') === false) {$value .= ' 00:00:00';}
            $dateTime = DateTime::createFromFormat('Y-m-d H:i:s', $value);

            if ($dateTime === false) {$value='';}
            else{
                if($inputType=='date'){
                    $value=$dateTime->format('Y-m-d');
                }else{
                    $value=$dateTime->format('Y-m-d\TH:i:s');
                }
            }

        }
    }
#var_dump($inputType);
     #Special output handling for some inputs
    if($inputType=='select'){
        $ro=($disabled)?"disabled":"";
        $class="class='form-select mb-{$marginBottom} $class $inputHeight'";
        $selsize='';$html='';
        if($size>1)$selsize="size='$size'";
        if($size<1){
            $n=count($listData);
            if($addBlankRow)$n++;
            $n=($n>abs($size))?abs($size):$n;
            $selsize="size='$n'";
        }

        $input="<select $class id='$id' name='$inputName' aria-label='' style='$width' $ro $selsize autocomplete='off' $af $multiple>";
        $input.=bs_getSelectInputOptions($listData,$value,$addBlankRow);
        $input.="</select>";

    }elseif($inputType=='datalist'){
        /*To allow enforced selection, we'll put the datalist into js arrays too.  This could be optimized for larger
        lists by building the html components from these js arrays client side (dom).  For now we'll just
        send both and rely on compression and assumed small lists (relatively).

        */

        $values=arrayFromCol($listData,'value');
        $names=arrayFromCol($listData,'name');
        $shortNames=arrayFromCol($listData,'abbr');
        $groupNames=arrayFromCol($listData,'group_name');
        $selDisp="";
        $selIndex=($value=='_first_' && $values)?0:array_search($value,$values);
        if($selIndex!==False){
            $selDisp=($shortNames)?$shortNames[$selIndex]:$names[$selIndex];
        }
        $jsArr=json_encode(array('id'=>$id,'values'=>$values,'names'=>$names,'shortNames'=>$shortNames));//To pass of to js handler
        $value=($selIndex!==False)?$values[$selIndex]:'';
        $input=bs_getHiddenInput($id,$value);
        $input.="<input type='text' class='form-control $inputHeight w-auto' list='{$id}_list' id='{$id}_display' value='$selDisp' $af autocomplete='off''></input>
            <datalist  id='{$id}_list'>";
        $prevGroup='';
        foreach($names as $i=>$name){
        #bs_printVar($groupNames[$i]);
            $group=(isset($groupNames[$i]))?$groupNames[$i]:'';
            #var_dump($group);
            if($group!=$prevGroup){
                $input.="<option value='$group' disabled></option>";
                $prevGroup=$group;
            }else $input.="<option value='$name'></option>";
        }
        $input.="</datalist>";
        $js.="let {$id}_arr={$jsArr}; bs_dataList({$id}_arr);";

    }elseif($inputType=='filteredAutocomplete'){
        #Type ahead/search widget for larger selects
        $values=arrayFromCol($listData,'value');
        $names=arrayFromCol($listData,'name');
        $shortNames=arrayFromCol($listData,'abbr');
        $groupNames=arrayFromCol($listData,'group_name');
        $groupNames2=arrayFromCol($listData,'group_name2');

        #preselect anything?
        $selDisp="";
        $selIndex=($value=='_first_' && $values)?0:array_search($value,$values);

        if($selIndex!==False){
            $selDisp=($shortNames)?$shortNames[$selIndex]:$names[$selIndex];
            $value=$values[$selIndex];
        }

        #Hidden input will be set with selected value, a _display will show text (short/name)
        $input=bs_getHiddenInput($id,$value);
        $inputOptions['disabled']=true;
        $input.=bs_input($searchboxDisplayType,"{$id}_display",'',$selDisp,$inputOptions);

        #Modal content that displays when button pushed.
        $searchBoxID=uniqid('bs_');$groupInp='';$group2Inp='';
        $searchBoxInp=bs_input('text',$searchBoxID,$searchBoxLabel,'',['labelPos'=>'float']);

        #if group passed, then make up a select widget for it.
        $groupInpID=$searchBoxID."_group";
        if($groupNames){
            $tmp=implode(",",array_unique($groupNames));//Put into csv list of unique groups
            $a=bs_optionsResultSetFromList($tmp);//put unique groups into a result set
            $groupInp=bs_input("select",$groupInpID,"$group1ColLabel","",['listData'=>$a,'addBlankRow'=>true,'size'=>'1','labelPos'=>'above']);#'maxWidth'=>'175px',
        }
        #if group2 passed, then make up a select widget for it.
        $group2InpID=$searchBoxID."_group2";
        if($groupNames2){
            $tmp=implode(",",array_unique($groupNames2));//Put into csv list of unique groups
            $a=bs_optionsResultSetFromList($tmp);//put unique groups into a result set
            $group2Inp=bs_input("select",$group2InpID,"$group2ColLabel","",['listData'=>$a,'addBlankRow'=>true,'size'=>'1','labelPos'=>'above']);#'maxWidth'=>'175px',
        }

        #Make up a resultset for display table list in format bs_table expects
        $a=[];
        $tableID=$searchBoxID."_table";
        $ns=($shortNames)?$shortNames:$names;#what eventually gets put into the display field
        foreach($values as $i=>$v){
            $arr=['bs_param1'=>$v,'bs_param2'=>$ns[$i]];#value, name to have table click event pass to js handler
            $arr['Name']=$names[$i];#Text to display.  Note order of columns is significant and expected in bs_searchTable js func.
            if($groupNames)$arr[$group1ColLabel]=$groupNames[$i];#display group if present
            if($groupNames2)$arr[$group2ColLabel]=$groupNames2[$i];#display group2 if present (should be able to pass name)
            $a[]=$arr;
        }
        $tableInp=bs_table($a,['divID'=>$tableID,'onClickJS'=>'bs_filteredAutocompleteSelected','onClickJSTargID'=>$id,'width'=>'100%','height'=>'400px','clickSelectedRowKey'=>false,'selectedRowKey'=>$value]);

        #Filter widgets with table below
        $modHTML="<div class='row align-items-start'><div class='col'>$searchBoxInp</div><div class='col'>$groupInp</div><div class='col'>$group2Inp</div></div>";
        $modHTML.=$tableInp;

        #Add modal to displayed field
        $modalID=$searchBoxID."_modal";
        #This way has a button below:
            #$input.=bs_modal($modHTML,$searchWindowTitle,['divID'=>$modalID,'linkText'=>'Choose','size'=>'xl']);
        #This one (2 lines) makes the displayed field clickable
            $input="<div style='display: inline-block;' id='{$searchBoxID}_modalClickHndl' onclick=\"bs_showModal('$modalID');\">$input</div>";
            $input.=bs_modal($modHTML,$searchWindowTitle,['divID'=>$modalID,'linkType'=>'none','size'=>'xl']);

        #Attach event listeners for dynamic search, up/down arrow handlers and enter key to select highlighted row.
        $searchTimeout="{$searchBoxID}_searchTimeout";
        $js.="bs_initAutocomplete('{$searchBoxID}',{$searchBoxTimeoutMS});";//Sets up all the event listeners


    }elseif($inputType=='checkbox' || $inputType=='radio'){
        #$c=($inline)?"form-check-inline":"";#makes div non-blocking to put on same line.
        $t_checked=($value)?'checked':'';
        #$html="<div class='row'>$label<div class='col-sm-{$bsInputSize}'>$input</div></div>";

        $input="<input class='form-check-input $rocss' type='$inputType' $ro value='$value' id='$id".$radio_n."' name='$id' $t_checked>";

    }elseif($inputType=='textarea'){
        $ro=($disabled)?"readonly":"";
        $input="<textarea class='form-control $class $inputHeight' id='$id' name='$id' rows='$textareaHeight' cols='$size' style='$width' $ro>$value</textarea>";
    }else{
        #make the input and add label if passed.
        $input="<input type='$inputType'  style='$width' name='$inputName' id='$id' value='$value' $step size='$size' class='form-control mb-{$marginBottom} $class $inputHeight $rocss w-auto' $multiple $acceptedFiles placeholder='$placeHolder' $ro $onChange $af></input>";
    }

    if($label){#$input,$inputID,$label,$labelPos,$bsLabelSize,$bsInputSize,$margin='3'){
        if($labelPos=='float')$html.=bs_inputLabelLayout($input,$id,$label,'float',$bsLabelSize,$bsInputSize,$marginBottom,$labelHeight,$labelNoWrap);
        elseif($labelPos=='left')$html.=bs_inputLabelLayout($input,$id,$label,'left',$bsLabelSize,$bsInputSize,$marginBottom,$labelHeight,$labelNoWrap);
        else $html.=bs_inputLabelLayout($input,$id,$label,'above',$bsLabelSize,$bsInputSize,$marginBottom,$labelHeight,$labelNoWrap);
    }else $html.=$input;

    #Add any pre/post text & buttons
    $html=bs_inputAddons($html,$inputOptions);

    #Add some search form submits js if needed.
    if($dynSearchFormEl)$js.="bs_elementReloadsSearchForm('$id');";
    elseif($autoSubmit)$js.="bs_elementSubmitsSearchForm('$id');";

    if($value && $fireOnLoad)$js.=bs_delayedJS("bs_fireEvent('$id');");#do after above so listeners are added, and after delay so whole dom is loaded including dest divs
    if($js)$html.="<script>$js</script>";

    return $html;
}
function bs_getHiddenInput($id,$value,$class=''){
    return "<input type='hidden' class='$class' name='$id' id='$id' value='$value'>";
}



/*Input layout*/
function bs_inputAddons($inp,$options){
    /*Internal utility func to add any passed text or button addons to put inline with the input
    */

    extract($options);
    $pre='';$post='';$html=$inp;
    $pre=($preText)?"<span class='input-group-text'>$preText</span>":'';
    $pre=($preButton)?$pre.$preButton:$pre;
    $post=($postText)?"<span class='input-group-text'>$postText</span>":"";
    $post=($postButton)?$post.$postButton:$post;
    if($pre || $post){
        $html="<div class='input-group mb-{$marginBottom}'>$pre $inp $post</div>";
    }
    return $html;
}
function bs_inputLabel($text,$inputID,$marginbottom=0, $class='',$bsLabelSize='',$height=''){
    /*Returns standard label for input.
        inputID is the associated input ID*/
    $mb=($marginbottom)?"mb-$marginbottom":"";
    $ls=($bsLabelSize)?"col-sm-{$bsLabelSize}":"";
    $h=($height)?"col-form-label-{$height}":"";
    return "<label for='$inputID' class='form-label $mb $class $ls $h'>$text</label>";
}
function bs_inputLabelLayout($input,$inputID,$label,$labelPos,$bsLabelSize,$bsInputSize,$margin='3',$height='',$nowrap=false){
    /*Returns a bootstrap style input/label layout.  labelPos are left, above, or float (embedded in input).
        Assumes will be in a container class div
        Input is a full input with placeholder specified if labelPos=float
        label is text to display
        $bsLabelSize and $bsInputSize are 1-12 on bs grid system.
        if labelPos=above, inputsize is used for group.
        $nowrap keeps label on 1 line if possible.
    */

    $html='';
    $is=($bsInputSize)?"col-sm-{$bsInputSize}":"";
    $ls=($bsLabelSize)?"col-sm-{$bsLabelSize}":"";
    $h=($height)?"col-form-label-{$height}":"";
    $nw=($nowrap)?"nowrap":"";
    #floating labels seemed to have broke and now overlap the text making it unreadable.  Probably somethink I did
    #with margins or padding, but just disabling for now because they seem problematic and non standard.
    if($labelPos=='float')$labelPos='above';
    switch($labelPos){
        case "float":
            $label="<label for='$inputID' class='form-label'>$label</label>";
            $html=" <div class='form-floating mb-{$margin}'>$input $label</div>";//Order of input then prompt is significant.
            break;
        case "above":#set both to full width (12)
            $label="<label for='$inputID' class='form-label $h $nw mb-0 col-sm-12'>$label</label>";
            $html=" <div class='col col-sm-12 text-start'>$label $input</div>";
            break;
        case "left_inprog":
            $label="<label for='$inputID' class='col-form-label col-auto text-end $nw m-0 p-0'>$label</label>";
            $html="<div class='row d-flex '>$label<div class='col-sm'>$input</div></div>";
            break;
        case "left":
            $label="<label for='$inputID' class='col-form-label $ls text-end $nw m-0 p-0'>$label</label>";
            $html="<div class='row'>$label<div class='col-sm-{$bsInputSize}'>$input</div></div>";
            break;
        default:
            var_dump("UNKNOWN labelPos:$labelPos");exit();break;
    }

    return $html;
}

/*buttons*/
function bs_button($text,$action,$options=[]){
    /*Return a JS button.
        $action can be a function call or series of js statements.  Use all single quotes for parameters.
        $options can override $fullOpts defaults
    */
    $fullOpts=array(
        'buttonType'=>'button',#Note we don't use submit mechanism on standard form wrappers (ajax post instead)
        'btnClass'=>'btn-outline-primary',#Custom class or see bootstrap button classes for options. btn-secondary is a good one too
        'useLink'=>false,#alais for btnClass btn-link.  overrides btnClass
        'btnSize'=>'btn-sm',#Defaulting to this, but can pass other sizes or '' too.
        'id'=>uniqid("bs_"),#Supply id if you need to be able to reference it.
        'ro'=>false,#disable button on true
        'confirmText'=>'',#If passed, we do a popup confirmation before running action
        'class'=>'',#Other classes to add so can reference groups.
    );
    extract(bs_setOptions($fullOpts,$options));#Put options into name space

    $btnClass=($useLink)?bs_class("btn-link"):$btnClass;
    $action=($action && $confirmText)?"if(confirm('{$confirmText}')){ {$action}; }":$action;
    $onclick=($action && !$ro)?"onclick=\"$action\"":"";
    $disabled=($ro)?"disabled":"";
    $html="<button id=\"$id\" type='button' $onclick class='btn $btnClass $btnSize $class' $disabled>$text</button>";

    return $html;
}
function bs_searchFormSubmit($text="Search",$options=[]){
    /* Submit button for main search form.  Options are passed straight through to bs_button() */
    return bs_button($text,"bs_submitSearchForm()",$options);
}
function bs_addButton($table,$text='Add',$modal=1,$btnOptions=[]){
    /*Returns an add form that reloads search form on submit.
    Pass modal 1/0 for dynamic form.
    Loads into default table click div if !modal, else we create one to use
    $btnOptions passed straight through to bs_button()*/

    $destDiv=($modal)?"'".uniqid("bs_")."'":"bs_tableClickedDestDiv";#special quoting for js text/var
    $span=($modal)?"<span id={$destDiv}></span>":"";
    if(!array_key_exists('btnClass',$btnOptions))$btnOptions['btnClass']=bs_class('btn-secondary');
    $html=$span.bs_button($text,"bs_addRecord('$table',$destDiv,$modal)",$btnOptions);
    return $html;
}
function bs_submitSearchJS(){
    return "<script>".bs_delayedJS("bs_submitSearchForm()")."</script>";//on delay so everything can load
}
function bs_fileInput($inputID,$options=[]){
    /*Returns a file input that auto submits and can be handled in switch.php bs_fileUploaded handler
    using passed $inputID to match filename.
    //Not currently passing additional bs_input options, only below///$options can be any of bs_input() options, except id and onchange
    */
    $fullOpts=array(
        'destDivID'=>'',#Supply id for destDiv of switch response if you need to be able to reference it.
            #default is right next to button.
        'multiple'=>false,#Allow multiple files to be selected
        'acceptedFiles'=>"",#file type filter (see bs_input() accept)
        'parameters'=>'',#optional parameters to pass along in key1=value1&key2=value2 format
        'label'=>'',#Label before 'choose file' button
        'js'=>'',#additional js to run on click before bs_uploadFile called. Include trailing semicolon and single quote any parameters.
            #this overwrites onChangeFunc in options
		'includeCSVOptions'=>true,#Include options for CSV parsing
    );
    $fullOpts=bs_setOptions($fullOpts,$options);#Put options into name space
	extract($fullOpts);#Put options into name space

    if(!$destDivID){
        $destDivID=uniqid("bs_");
        $destDiv="<span id='$destDivID'></span>";
    }else $destDiv='';

	#Add csv options form if requested
	$csvOptionsForm='';#initialize
	if($includeCSVOptions){//Include a button to launch a dialog to set CSV options
		#Set some defaults.
		$delimiter=',';	$enclosure='"';	$escape='\\';	$comment='#'; $acceptedFiles='.csv';
		#Override defaults with session values if they exist
		if(!session_status() === PHP_SESSION_NONE)session_start();
		$sessKey="bs_csv_".$inputID;$a=[];
		if(isset($_SESSION[$sessKey])){//Load options from session if they exist
			$a=$_SESSION[$sessKey];
			$delimiter=$a['delimiter'];$enclosure=$a['enclosure'];$comment=$a['comment'];$acceptedFiles=$a['acceptedFiles'];$escape=$a['escape'];
		}
        #Create form to set CSV options
		$delimInp=bs_input('text','bs_csv_delimiter','Delimiter',$delimiter,['labelPos'=>'left','bsInputSize'=>2]);
		$enclosureInp=bs_input('text','bs_csv_enclosure','Quotes',$enclosure,['labelPos'=>'left','bsInputSize'=>1]);
		#Excluding for now... bs_input('text','bs_csv_escape','Escape',$escape,['labelPos'=>'left','bsInputSize'=>1]);
		$commentInp=bs_input('text','bs_csv_comment','Comment line',$comment,['labelPos'=>'left','bsInputSize'=>1]);
		$acceptedFilesInp=bs_input('text','bs_csv_acceptedFiles','File ext.',$acceptedFiles,['labelPos'=>'left','bsInputSize'=>5]);
		$idInp=bs_getHiddenInput('bs_csv_inputID',$inputID);

		$csvSettings="$delimInp $enclosureInp $commentInp $acceptedFilesInp $idInp";#<span class='bs_tiny_ital'>Use 'S+' for whitespace</span>
		$csvOptionsForm=bs_form($csvSettings,['modalSize'=>'sm','doWhat'=>'bs_csv_setImportOptions','responseDestDiv'=>$destDivID,'modal'=>true,'modalTitle'=>'CSV Import Options','modalBtnTitle'=>'Import Options']);
	}
	$fullOpts['onChangeFunc']="$js bs_uploadFile('$inputID','$destDivID','$parameters');";
	if($csvOptionsForm)$fullOpts['postButton']=$csvOptionsForm;
	$inp=bs_input('file',$inputID,$label,'',$fullOpts);
    return $inp.$destDiv;
}
function bs_processUploadedFiles($inputID,$destDir='',$csv=true){
    /*Can be called from switch.php->doWhat bs_fileUploaded to process file(s).
    $destDir - if passed and writable by apache, file(s) is copied in with original name.
    If $csv, we open file and parse into an array of assoc arrays (col=>val,col2=>val2...) like doquery() results
        If caller used bs_getCSVFileInputDialog(), we'll read the session variables for how to parse csv (only on single file import)
    Returns file contents from each file in an array ($a[file name]=first file)
    */
    $a=[];
    if(isset($_FILES[$inputID])){
        if(!is_array($_FILES[$inputID]["error"])){//Annoying variable syntax
            $error=$_FILES[$inputID]["error"];
            if ($error == UPLOAD_ERR_OK) {
                $tmp_name = $_FILES["$inputID"]["tmp_name"];
                $name = basename($_FILES["$inputID"]["name"]);
                if($csv){
                    $comment='#';$delimiter=',';$enclosure='"';$escape='\\';#Defaults
                    if(!session_status() === PHP_SESSION_NONE)session_start();#Override from session if exists
                    $sessKey="bs_csv_".$inputID;
                    if(isset($_SESSION[$sessKey])){
                        $tmp=$_SESSION[$sessKey];
                        $comment=$tmp['comment'];
                        $delimiter=$tmp['delimiter'];
                        $enclosure=$tmp['enclosure'];
                    }
                    $a[$name]=bs_parseCSVFile($tmp_name,$comment,$delimiter,$enclosure);
                }else $a[$name]=file_get_contents($tmp_name);
                if($destDir){#mk a copy if requested.
                    move_uploaded_file($tmp_name, "$destDir/$name");
                }
            }
        }else{

            foreach ($_FILES[$inputID]["error"] as $key => $error) {
                if ($error == UPLOAD_ERR_OK) {
                    $tmp_name = $_FILES["$inputID"]["tmp_name"][$key];
                    $name = basename($_FILES["$inputID"]["name"][$key]);
                    if($csv)$a[$name]=bs_parseCSVFile($tmp_name);
                    else $a[$name]=file_get_contents($tmp_name);
                    if($destDir){#mk a copy if requested.
                        move_uploaded_file($tmp_name, "$destDir/$name");
                    }
                }
            }
        }
    }
    return $a;
}

/*Form wrappers*/
function bs_form($inputs,$options=[]){
    /*Returns form in a bootstrap container (for layout if used).
    $inputs is html of all input fields
    See below for $options.
    There are 3 modes;
        -Pass table and use the 'system' which will provide buttons, validate entries (html5), submit and handle response.
        -Pass doWhat and this will handle buttons, validation, js submission.  caller provides doWhat handler in switch and may need to close modal form (if using modal, add bs_hideModal() to return $html)
        -Or, you can provide a js callback to handle everything.  Also will need buttons, close modal form (provide uid) and handle response.

    This method provides a submit button by default, which means caller must provide options doWhat/dest or a callback (see below).
    $options can override $fullOpts defaults
    */
    $fullOpts=array(
        'formID'=>uniqid("bs_"), #form id.  Caller should pass if needs to reference (like to close modal form).

        //One of these 3 are required:
        'table'=>'',#db table being submitted.  this form will provide submit and js logic & send to switch.php with doWhat of bs_processTableForm and
            #tablename in bs_processedTable post var.
            #Caller must hook into that handler to call bs_addEditTable with table/field information. Response will go into responseDestDiv.  Handler will
            #close modal form.  See switch.php template for examples. (NOT FULLY PROGRAMMED YET)
        'doWhat'=>'', #Generic doWhat action to submit for switch.php to handle.  This form will provide submit and js logic.
            #Response will go into responseDestDiv.  If form is modal, response must include js bs_hideModal() to close modal window on success
        'callback'=>'',#optional js handler to process form and post. See js bs_processForm() for example.
            #Any params need to be single quoted as call is wrapped in double quotes
        //

        'responseDestDiv'=>'',#Where to send results. Defaults to a response div next to submit button.
            #Can use bs_ajaxJSDiv (which is hidden)
            #for pure js response (like popups, set status text & clear form area or similar)

        'submitText'=>'Submit',#blank to not include submit button here (if already in inputs)
            #If providing submit in $inputs, you can use button action: "bs_processForm('$formID', '$doWhat', '$responseDestDiv');"
        'disableButtonsOnSubmit'=>true,#disable submit, delete (and any button with class $formID_btn) on submit.  False to not (for search for for example)
        'canDeleteRowNum'=>false,#Pass '' on insert or if no access and button is disabled.  Pass false to skip button.
            #If user can delete, pass the pkey value which is used to verify action by handler.
            #A hidden input is added with id='delete_[table]' with default value of 0.  If user clicks delete,
            #this is set to passed value and form submitted (see below).  swith.php needs to handle actual deleting.
        'canSubmitEdit'=>true,#pass false to not allow submits.  Note; caller must set inputs readonly, this only disables the submit button.
        'outlineBtns'=>false, #pass true to use outline family of buttons
        'formMaxWidth'=>'900px',#max width of form regardless of window size.
        'additionalBtns'=>'',#any additional buttons to put on the form (left of del/submit)

        //HTML form content or a modal popup window for content
        'modal'=>false,#Pass true to return modal popup, is dynamic html (auto launches from ajax call) unless you pass modalBtn=true, then you get a button to launch it
        #...if true then:
        'modalSize'=>'lg',#see bs_modal()
        'modalTitle'=>'',#'Displays on top of modal window, ex :Lab Edit
        'modalBtn'=>true,#Return a button that launches modal instead of the popup form dynamically
        'modalBtnTitle'=>'Edit',
    );
    extract(bs_setOptions($fullOpts,$options));#Put options into name space

    $outline=($outlineBtns)?"outline-":"";//bs btn class option
    $deleteBtn='';$modalID='';$submitBtn='';

    $responseDestDiv=($responseDestDiv)?"$responseDestDiv":"{$formID}_responseDiv";

    //Figure out how to submit & process
    if($callback)$submitAction=$callback;//Caller is rolling own.
    else{
        if($table && !$doWhat)$doWhat="bs_processTableForm";//Default switch.php handler
        $submitAction="bs_processForm('$formID', '$doWhat', '$responseDestDiv');";
    }

    //Gen submit & delete buttons
    $class=($disableButtonsOnSubmit)?$formID."_btn":"";#Submit logic disables buttons with this class
    if($submitText){#include submit
        if($canSubmitEdit){#enabled
            $submitBtn=bs_button($submitText,$submitAction,['class'=>$class,'btnClass'=>bs_class("btn-{$outline}primary")]);
        }else{#disabled
            $submitBtn=bs_button('Submit','',['ro'=>true]);
        }
    }
    #$submitBtn=($submitText)?bs_button($submitText,$submitAction,['class'=>$class,'btnClass'=>bs_class("btn-{$outline}primary")]):"";
    if($canDeleteRowNum!==false){
        if($canDeleteRowNum){
            $action="if(bs_confirmDelete('{$table}',$canDeleteRowNum,'Are you sure you want to delete this record?')){ $submitAction }";
            $deleteBtn=bs_getHiddenInput("delete_{$table}",0).bs_button('Delete',$action,['class'=>$class,'btnClass'=>bs_class("btn-{$outline}secondary")]);
        }else $deleteBtn=bs_button('Delete','',['ro'=>true]);
    }
    $buttons="$additionalBtns &nbsp; $deleteBtn &nbsp; $submitBtn";
    $formButtons=($modal)?"":$buttons;#We'll pass to modal to put in window footer

    if($table)$inputs.=bs_getHiddenInput("bs_processedTable",$table);
    if($modal){
        $modalID=$formID."_modalDiv";
        $inputs.=bs_getHiddenInput("bs_modalFormID",$modalID);
    }

    $html="
        <div class='container' style='max-width:{$formMaxWidth};text-align:left;'>
        <form id='$formID' autocomplete='off' class='needs-validation' onsubmit='return false;'>
                $inputs
                <div class='col-12 text-end' ><span id='{$formID}_responseDiv'></span>$formButtons</div>
        </form>
        </div>
    ";
    if($modal)$html=bs_modal($html,$modalTitle,['divID'=>$modalID,'dynamic'=>(!$modalBtn),'size'=>'lg','linkText'=>$modalBtnTitle,'btnClass'=>bs_class("btn-{$outline}secondary"),'buttons'=>$buttons]);
    return $html;
}
function bs_formLayout_1col($inputs,$pkVal,$pkLabel=''){
    /*Utility to layout form inputs in 1 column using 100% of container.
     $inputs is an ordered array of label&inputs as returned by bs_input()
        if $pk and pkLabel, then a row at top is added at top to display the row's id number
        Assumes that a parent .container div has already been defined (bs_form() does).
    */
    $html='';$idrow='';$hidden='';$sdiv="<div class='row mb-1'>";

    #Add PK id field if present
    if($pkVal && $pkLabel){
        $idrow="<div class='row align-items-start'>
                    <div class='col'>$pkLabel:$pkVal</div>
                </div>";
    }

    $html.=$idrow;
    foreach($inputs as $inp){
        if(str_contains($inp,'input_hidden')){
            $hidden.=$inp;#these will go outside of table
        }else{
            $html.=$sdiv."<div class='col'>".$inp."</div></div>";
        }
    }
    return $hidden.$html;
}
function bs_formLayout_2col($inputs,$pkVal='',$pkLabel=''){
        /*Utility to layout form inputs in 2 columns
    $inputs is an ordered array of label&inputs as returned by bs_input()
        if $pk and pkLabel, then a row at top is added at top to display the row's id number
        Assumes that a parent .container div has already been defined (bs_form() does).
    */
        $idrow='';$hidden='';
        $html="";

        #Add PK id field if present
        if($pkVal && $pkLabel){
                $idrow="<div class='row align-items-start'>
                            <div class='col'>$pkLabel:$pkVal</div>
                        </div>";
        }

        $i=0;$sdiv="<div class='row mb-1'>";# align-items-start
        $html.=$idrow.$sdiv;
    #Loop through list of inputs, adding to two columns.  Note ones designated doubleWide will get their own row.
        foreach($inputs as $inp){
                if(str_contains($inp,'input_hidden')){
                        $hidden.=$inp;#these will go outside of table
                }elseif(str_contains($inp,'input_doubleWide')){
                        #special handling for double wide input
                        if($i % 2 ==0){
                                #This is the first column, so add it and end row
                                $html.="$inp</div>$sdiv";
                                #Don't increment counter (already at 1st col for next row).
                        }else{
                                #We're at the 2nd col, so add filler, end row and then add it.
                                $html.="<div class='col-6'></div></div>
                                $sdiv $inp</div>$sdiv";
                                $i++;
                        }
                }else{
                        #start new row every 2 inputs
                        $i++;
                        $html.=$inp;
                        if($i % 2==0)$html.="</div>$sdiv";#new row
                }
                #if($i>1){var_dump("<pre>".htmlspecialchars($html)."</pre>".$i);exit();}
        }
        return $hidden.$html;
}

/*Search Form*/
function bs_getSearchFormWrapper($content,$submitText='Search',$submitOnLoad=false){
    /*Standard search form for left div.  Content is all the form inputs.
    Should include a hidden input for mod: bs_getHiddenInput('mod',$module), added from get if present;
    The form tags and search button are provided*/

    //Add mod if set so it gets passed along.
    $mod=getHTTPVar("mod");
    if($mod)$content.=bs_getHiddenInput('mod',$mod);

    $html=bs_form($content,['formID'=>'search_form','disableButtonsOnSubmit'=>false,'submitText'=>$submitText,'callback'=>'bs_submitSearchForm()']);
    if($submitOnLoad)$html.=bs_submitSearchJS();
    return $html;
}


/*Utilities*/
function bs_setStatusDiv($msg,$status='success',$clearAfterSec=3){
    /*Returns html/js to set status message and then auto clear
        $status is success, error or '' (not currently used, but could be)
    */
    if($status=='success')$class='bs_success';
    elseif($status=='error')$class='bs_error';
    else $class='';
    $t=$clearAfterSec*1000;
    #if($class)$msg="<span class=\"$class\">$msg</span>";
    return "<script>bs_setStatusMssg('$msg',$t);</script>";
}
function bs_inputType($type){
    /*Util function to return the text string input type for
    passed type which can be either text or integer constant (defined in htmlValidation.php)
    */
    $t=$type;
    if(is_int($type)){#Translate constant int
        $t='';
        if($type==VAL_INT)$t='int';
        elseif($type==VAL_FLOAT)$t='float';
        elseif($type==VAL_STRING || $type==VAL_STRING_RO)$t='text';
        elseif($type==VAL_TEXT)$t='textarea';
        elseif($type==VAL_DATE)$t='date';
        elseif($type==VAL_DATETIME)$t='datetime';
        elseif($type==VAL_SELECT_INT)$t='select';
        elseif($type==VAL_BOOLCHECKBOX)$t='checkbox';
        elseif($type==VAL_RADIO)$t='radio';
        else{
            #Fail hard for dev
            var_dump("Unknown const supplied to bs_input()->bs_inputType().  Needs to be added to bs_inputType()");
            var_dump($type);
            exit();
        }
    }
    return $t;
}
function bs_getSelectInputOptions($a,$selectedValue,$addBlankRow=false){
    /*Returns the options for a select input using result set $a and preselecting selectedValue where appropriate.
     *$a is a result set (from above) with 2 named cols; value, name
     *$selectedValue is a scalar int/string or an array of int/strings (for multi selects)
     *if optional group_name col exists, that will be used to group options.
     */
    $html="";
    #var_dump("selval:".$selectedValue);
    if($a){
        $value="";$name="";$grpName="";$group_name="";$n=1;
        if($addBlankRow)$html.="<option value=''></option>";
        foreach($a as $row){
            $value=$row['value'];$name=$row['name'];
            $group_name=(isset($row['group_name']))?$row['group_name']:'';
            if($group_name!=$grpName){
                $grpName=$group_name;
                $html.="<optgroup label='".htmlspecialchars($grpName)."'>";
            }
            #Match selected options, for scalar/array selectedValue
            $sel=((is_array($selectedValue) && in_array($value, $selectedValue))
                || (!is_array($selectedValue) && $value==$selectedValue)
                ||($n==1 && $selectedValue==='_first_'))?"selected":"";
            $html.="<option value='$value' $sel>$name</option>";
            $n++;
       }
    }else{$html.="<option value=''>None found</option>";}
    return $html;
}
function bs_optionsResultSetFromList($list){
    /*Returns csv list in same format as result sets from doquery (array of assoc arrays) for use in select inputs.*/
    $t=explode(',',$list);
    $a=[];
    foreach($t as $i){
        $a[]=['value'=>$i,'name'=>$i];
    }
    return $a;
}
function bs_optionsResultSetFromArray($arr){
    /*Returns array of a[value]=display_name in same format as result sets from doquery (array of assoc arrays) for use in select inputs.*/
    $a=[];
    foreach($arr as $k=>$v){
        $a[]=['value'=>$k,'name'=>$v];
    }
    return $a;
}


/*Search function for resultsets
these functions are a combination of db access/queries and manipulation of returned result sets to highlight
matches but are grouped together here to making it easier to document/read.
Only one, doSearchEverythingFilter(), actually interacts with the bldsql query builder, the others
all create or manipulate ui objects.
*/

function bs_getSearchEveryThingBox($placeHolderText='Search Data',$includeTrailingHR=true){
    /*Returns the Search Everything widget to be used on sidebar.
        Input is named searchEverythingTerm.  You need to hook into standard bs_loadList() handler
        and do a side line search.  Optional if you want to include other present filters in sidebar,
        or just do a solo search with no other filters.
        There is a convienence function below bs_doSearchEverythingFilter() to add it in to a bldsql instance.
        ex: add into sidebar search form:
            $html.='<div>'.bs_getSearchEveryThingBox();
        then in handler for bs_loadList():
            bldsql_init();
            bldsql_from("ghgdb.labs l");
            bldsql_col("lab_id as onClickParam");
            bldsql_col("abbr");
            bldsql_col("name");
            bldsql_col("address");
            bldsql_col("primary_contact");
            bldsql_orderby("abbr");
            $filter=bs_doSearchEverythingFilter(array('abbr','name','address','primary_contact','shipping_address'));
            $a=doquery();
            $html=printTable(highlightSearch($a,$filter,1),'loadLabDetail',1);
    */
    $searchEverythingTerm=bs_getSearchEveryThingFilter();
    $html=bs_input('text','searchEverythingTerm','',$searchEverythingTerm,['size'=>20,'placeHolder'=>$placeHolderText,'postButton'=>bs_button('Search','bs_searchEveryThing()',['btnClass'=>bs_class('btn-secondary')]),'autofocus'=>false]);
    if($includeTrailingHR)$html.="<hr width='70%'></hr><br>";
    #Add an event listener for enter key
    $html.="
    <script>var el = bs_getEl('searchEverythingTerm');
    el.addEventListener('keydown', function(event) {
      // Check if Enter key was pressed (key code 13)
      if (event.keyCode === 13) {
           bs_searchEveryThing();
           event.preventDefault();
      }
    });</script>";
    return $html;
}
function bs_getSearchEveryThingFilter(){
    #Returns filter, if set, for the search everything widget.
    #This exists so some callers can get filter without having to know the name of input.
    return getHTTPVar("searchEverythingTerm");
}
function bs_doSearchEverythingFilter($cols=array()){
    #Adds to current bldsql statement each col as a filter with bind parameters
    #Columns are db colnames to search.  Generally should match displayed columns (so can highlight match),
    #but does not need to.
    #Returns the search term
    $searchEverythingTerm=bs_getSearchEveryThingFilter();
    if($searchEverythingTerm){
        $f='';$p=array();
        foreach($cols as $i){#Build up a giant or conditional with each of the columns
            bs_appendToList($f,"$i like concat('%',?,'%')", ' or ');
            $p[]=$searchEverythingTerm;
        }
        $f="(".$f.")";
        bldsql_mwhere($f,$p);
    }
    return $searchEverythingTerm;
}
function bs_highlightSearchEverythingFilter($a,$hiddenCols=0){
    /*Applies highlightSearchPhrase() to all values in $a.  See below.
    Skips columns with a bs_ prefix or if hiddenCols passed.
    */
    $searchEverythingTerm=bs_getSearchEveryThingFilter();
    if($searchEverythingTerm=='')return $a;
    $b=array();
    foreach($a as $row){
       $nr=array();
       $i=1;
       foreach($row as $key=>$value){
            if(!bs_startsWith($key,"bs_") && $i>$hiddenCols){#Skip any that should be hidden.
                $nr[$key]=bs_highlightSearchPhrase($value,$searchEverythingTerm);
            }else $nr[$key]=$value;
            $i++;
       }
       $b[]=$nr;
    }
    return $b;
}
function bs_highlightSearchPhrase($text, $phrase, $highlightClass = 'bs_textHighlight') {
    #does a case insensitive find of phrase and highlights, maintaining case.
      $pos = stripos($text, $phrase); // Case-insensitive search for the position of the phrase in the text

      if ($pos !== false) { // If the phrase is found in the text
        $before = substr($text, 0, $pos); // Get the text before the phrase
        $matched = substr($text, $pos, strlen($phrase)); // Get the matched phrase
        $after = substr($text, $pos + strlen($phrase)); // Get the text after the phrase

        $highlighted = "<span class='$highlightClass'>$matched</span>";

        // Recursively call the function on the text after the phrase to find and highlight any additional occurrences
        $after_highlighted = bs_highlightSearchPhrase($after, $phrase, $highlightClass);

        // Return the highlighted text
        return $before . $highlighted . $after_highlighted;
      }
      else { // If the phrase is not found in the text
        return $text; // Return the original text
      }
}
/*End SearchEveryThingBox */

function bs_dateRange($start='',$end='',$options=[],$inputOptions=[]){
    /*Returns start/end date selectors.
    ids are like: $[prefix]_start_{$datetype}, $[prefix]_end_{$datetype}
    $inputOptions are just passed straight through to bs_input();
    */
    $opt=[
        'prefix'=>'ev',#input prefix
        'labelPrefix'=>"Sample",
        'datetype'=>'date',#'time', 'datetime'
    ];
    foreach($options as $key=>$val){$opt[$key]=$val;}#Overwrite defaults

    $s=bs_input($opt['datetype'],$opt['prefix']."_start_".$opt['datetype'],$opt["labelPrefix"]." start",$start,$inputOptions);
    $e=bs_input($opt['datetype'],$opt['prefix']."_end_".$opt['datetype'],$opt["labelPrefix"]." end",$end,$inputOptions);
    return $s.$e;
}


/*Utilities*/
function bs_setOptions($allowedOptions,$passedOptions){
    /*Utility function to safely use an array to pass parameters with defaulted values.
    Use like this:
    function myFunc($options=[]){
        #$options can override $allowedOptions defaults
        $allowedOptions[
            $foo='bar',#value of foo
            $foo2='bar2',#value of foo2
        ];
        extract(bs_setOptions($allowedOptions,$options));#Set default options and overrides into namespace
    }
    Note; this isn't passed by reference, so src array not updated only returned array.
    Note; We don't do a type check to allow some parameters to accept multiple types (similar to $selectedValue)
    */
    $keys=array_keys($allowedOptions);#Allowed keys
    foreach($keys as $key){if(isset($passedOptions[$key]))$allowedOptions[$key]=$passedOptions[$key];}#Overwrite defaults if passed.
    return $allowedOptions;
}
?>
