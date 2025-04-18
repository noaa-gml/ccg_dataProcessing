<?php
/*Functions to support index page.. */
/*
 *When used in the index template search form, they automatically submit on change (assuming they are class search_form_auto_submit)
 *
 *See source functions in sftp://omi (mund)/var/www/html/mund/dbutils_htmlUtilites.php for most up to date comments and functionality.

 These don't really do much different from source functions other than specify the class.  Not sure if really needed, but thought it might be nice to split the
 functionality in case.  Probably not worth the documentation hassle though.
*/

function i_getSubmitBtn($label='Submit'){
    return getJSButton('search_submit_btn','i_loadList',$label);
}
function i_getInputSelect($a,$id,$selectedValue="",$addBlankRow=false,$maxWidth='250px',$class='search_form_auto_submit',$size=1){
    /*Returns html input for query result $a.  If $selectedValue passed, it's selected.  automatically fires i_loadList on change.
    $a is standard return obj from doquery() and requires 2 cols; value, display_name.  Unfortunate conflict with below col naming, but I like that one better and this is already being used...
    See dbutils->htmlUtilities.php for details*/
    $cl="search_form_auto_submit";
    if($class)$cl.=" $class";
    return getSelectInput($a,$id,$selectedValue,'',$addBlankRow,$maxWidth,false,false,$cl,$size);
}
function i_getAutoCompleteSelect($a,$id,$size=28,$selectedValue=""){
    #Returns the html & js for a popup autocomplete controller for a db lookup table.
    #that allows similar functionality to a select widget (user selects text, but key is stored/submitted value), but using an autocomplete widget
    #It also allows different display/selected values (label vs value), which allows for ex
    #full site name in the popup, but only site code as the selected text with site num as the submitted value.

    #$a is standard return obj from doquery() with 3 colums:
    #   key col is the primary key for the table/row (eg site_num).  This is what gets sent on form submit
    #   value col is what will get put in the displayed input once a user selects an item (eg site.code)
    #   label (optional) col is what shows up on the popup list(eg Mauna Loa...).  If not provided, then value is displayed in both.

    #See dbutiles_htmlUtilites.php->getAutoComplete() for details and further comments.


    /*ex query:
     *  doquery("create temporary table if not exists t_site as select distinct s.num,s.code,s.name from gmd.site s, flask_event e where s.num=e.site_num",false);
        bldsql_init();
        bldsql_from("t_site s");
        bldsql_col("s.num as 'key'");#Note; quote keyword 'key'
        bldsql_col("s.code as 'value'");
        bldsql_col("concat('(',s.code,') ',s.name) as 'label'");
        bldsql_orderby("s.code");
        $a=doquery();
    */

    $class="search_form_auto_submit";
    $onChangeFunction="i_loadList";
    return getAutoComplete($a,$id,$size,$selectedValue,$onChangeFunction,$class);
}

function i_getRadioButton($id,$checked,$value,$displayText){
    #Returns a single radio button.
    #Note id is not set (must be unique), but still calling param id to be consistent with other inputs
    $checked=($checked)?"checked":'';
    return "<label><input class='search_form_auto_submit' type='radio' name='$id' value='$value' $checked>$displayText</input></label>";
}

function i_getCheckBox($id,$checked,$displayText){
    #Returns a single checkbox
    $checked=($checked)?"checked":'';
    return "<label><input class='search_form_auto_submit' type='checkbox' name='$id' id='$id' value='1' $checked>$displayText</input></label>";
}
function i_reloadBtn($label=''){
    #button to reload the current selection
    $class='';$title=$label;
    if(!$label){#arrow thing.Note it's not standard angle so class rotates it
        $label="&#x21bb;";
        $class='i_refreshBtn';
        $title="Refresh";
    }
    return getJSButton('i_reloadBtn','i_loadList',$label,'','','',$class,$title);
}


?>
