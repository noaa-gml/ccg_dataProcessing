<?php

/*Utility functions for parseing input and cleaning data.  */
/* Get HTTP variable.
*
* @param string $name : name of the variable in the $_GET array
* @param string $default : the default value to use if http variable doesn't exist or is bad, defaults to '' or array() for val_array or val_array_ne
* @param string $type : type of answer, int, float, string, date, array
*   If passed VAL_ARRAY_NE, this will check to see if a single element of '' is passed (select blank) and remove it (val_array_NotEmpty)
* @param array $allowed : an array of allowed values.  only programmed on string & numbers, not arrays currently.
* @param float $min, $max : check variable is between minimum and maximum values if variable is an int or float
* If variable name is given in URL (in $_GET), use that instead of what might
* be saved in cookie (in $_COOKIE),
* val_boolcheckbox returns 1 if the checkbox was set (checked). (regardless of value) and 0 if not.  This assumes that browser do not send the element if not checked.
#VAL_ARRAY_CONCAT returns a comma separate string of concated array values
Note for an array of checkboxes, name the variable with [] at the end.
*/
define ("VAL_INT", 0);
define ("VAL_FLOAT", 1);
define ("VAL_DATE", 2);
define ("VAL_STRING", 3);
define ("VAL_ARRAY", 4);
define ("VAL_ARRAY_NE", 5);
define ("VAL_DATE_TIME",6);define("VAL_DATETIME",6);
define ("VAL_TIME",7);#considers 00:00:00 to be null time
define ("VAL_BOOLCHECKBOX",8);define("VAL_CHECKBOX",8);define("VAL_BOOL",8);define("VAL_BOOLEAN",8);#I kept misnaming these, so created aliases for common ones.
define ("VAL_FLOAT_ARRAY",10);
define ("VAL_ARRAY_CONCAT",11);
define ("VAL_TIME2",12);#doesn't consider 00:00:00 to be null
define ("VAL_TEXT",13);#Same as VAL_STRING
define ("VAL_SELECT_INT",14);#for primary key that comes from a select into a lookup table.  Separated for display logic.
define ("VAL_AUTOCOMPLETE_INT",15);#Same for autocompletes
define ("VAL_STRING_RO",16);#For display
define ("VAL_INT_ARRAY",17);#For multi-select arrays (not sure this is 100%, caused issues in icp)
define ("VAL_CSV",18);#alphanum csv
define ("VAL_INT_CSV",19);#int csv
define ("VAL_RADIO",20);#radio buttons.  Maps to VAL_STRING.  Haven't tested yet!!
#Note cookies were causing havoc with standard inputs (ie; project_num), so made default off.

#MARK request utils
function getHTTPVar($name, $default = "", $type = VAL_STRING, $allowed = array(), $min = '', $max = '', $useCookies=false, $srcArray=[]) {
    /*Filter input by type*/
    #Set default for array types to empty array.
    #srcArray is optional data source instead of from $_REQUEST.  This is to support supplying values to edit wrappers that use this function to validate data.

    $isArrayType=($type==VAL_ARRAY || $type==VAL_ARRAY_NE || $type==VAL_FLOAT_ARRAY || $type==VAL_INT_ARRAY|| $type==VAL_ARRAY_CONCAT);
    $default=($isArrayType && $type!=VAL_ARRAY_CONCAT)?array():$default;
    $val = $default;
    if (isset($srcArray[$name])){
        $tmp=$srcArray[$name];
    }elseif (isset ($_GET[$name])) {
        $tmp = $_GET[$name];
    } elseif (isset ($_POST[$name])) {
        $tmp = $_POST[$name];
    } elseif (isset ($_COOKIE[$name]) && $useCookies) {
        $tmp = $_COOKIE[$name];
    } else {
        return $default;
    }

    if (!$isArrayType && $type!=VAL_BOOLCHECKBOX) {
        if (strlen($tmp) == 0) { return $default; }
    }

    switch ($type) {
    case VAL_INT_CSV:
    case VAL_CSV:
        $tarr = explode(',', $tmp);
        $tarr2=array();
        foreach ($tarr as $val) {
            if($type==VAL_INT_CSV)$tarr2[]=intval($val);
            else $tarr2[] = preg_replace('/[^a-zA-Z0-9]/', '', $val);
        }

        // Join the cleaned values back into a string
        $val = implode(',', $tarr2);
        break;
    case VAL_SELECT_INT:
    case VAL_AUTOCOMPLETE_INT:
    case VAL_INT:
        $int = intval($tmp);
        if((($min != '') && ($int < $min)) || (($max != '') && ($int > $max))) {
            return $default;
        }
        $val = check_allowed($int, $allowed, $default);
        break;
    case VAL_BOOLCHECKBOX:
        #assume if here, then the parameter was set (checked). Set to 1 regardless of value.
        #Unless it came from cookie then maintain value (so it can be unset)
        #Note i think some logic assumes it gets set to one when passed, so that's why the cookie logic is a little different.
        if(isset($_COOKIE[$name]))$val=$tmp;#set to passed vale so cookie can be overridden.
        else $val=1;
        break;
    case VAL_FLOAT:
        #breaks on 1,234 $tmp=str_replace(",", ".", $tmp);//Attempt to handle different decimal chars (,.) by switching comma to period and assuming no thousands separator.
        $tmp=str_replace(",", "", $tmp);//No international support :(
        $float = floatval($tmp);
        if ((($min != '') && ($float < $min)) || (($max != '') && ($float > $max))) {
            return $default;
        }
        $val = check_allowed($float, $allowed, $default);
        break;

    case VAL_DATE:
        $t = strtotime($tmp);
        if ($t === FALSE) {
            return $default;
        }
        $val = date("Y-m-d", $t);
        break;

    case VAL_DATE_TIME:
        $t = strtotime($tmp);
        if ($t === FALSE) {
            return $default;
        }
        if(date('H:i:s',$t)=="00:00:00") $val=date("Y-m-d",$t); #Strip time if not passed.
        else $val = date("Y-m-d H:i:s", $t);
        break;

    case VAL_TIME:
        $t = strtotime($tmp);
        if ($t === FALSE) {
            return $default;
        }
        $val = date("H:i:s", $t);
        #We consider 00:00:00 to be null time.
        if($val=='00:00:00')return $default;
        break;
    case VAL_TIME2:
        $t = strtotime($tmp);
        if ($t === FALSE) {
            return $default;
        }
        $val = date("H:i:s", $t);
        break;
    case VAL_RADIO:
    case VAL_TEXT:
    case VAL_STRING_RO:
    case VAL_STRING:
        $tmp = trim($tmp);
        $val = check_allowed($tmp, $allowed, $default);
        $val = rawurldecode($val);
        break;
    case VAL_ARRAY_CONCAT:
        $tmp2="";
        if(is_array($tmp)){
            $tmp2=join(",",$tmp);
        }
        $val=$tmp2;#var_dump($val);
        break;
    case VAL_ARRAY:
        $val=(is_array($tmp))?$tmp:$default;
        break;
    case VAL_INT_ARRAY:
        $tmp2=array();
        foreach($tmp as $i=>$v){
            $int = intval($v);
            if((($min != '') && ($int < $min)) || (($max != '') && ($int > $max))) {
                $int=false;
            }
            $int = check_allowed($int, $allowed, false);
            if($int)$tmp2[]=$int;
        }
        $val=$tmp2;
        break;
    case VAL_FLOAT_ARRAY:
        $tmp2=array();
        foreach($tmp as $i=>$v){
            $v=str_replace(",", "", $v);//Strip any embedded commas.. could cause issues with other nationalities, so use with caution.
            $v=str_replace("$","",$v);//ditto on $
            $f = floatval($v);
            $tmp2[$i]=$f;
        }
        $val=$tmp2;
        break;
    case VAL_ARRAY_NE:
        $tmp2=array();
        if(is_array($tmp)){
            foreach($tmp as $i=>$v){
                if($v!=="")$tmp2[]=$v;
            }
        }
        $val=$tmp2;
        break;
    }


    return $val;
}
# check that $tmp is in the $allowed array, otherwise return $default.
# if nothing in $allowed, return the given value $tmp.
function check_allowed($tmp, $allowed, $default) {

    $val = $tmp;

    if ( count($allowed)) {
        $val = $default;
        foreach ($allowed as $v) {
            if (strcasecmp((string) $tmp, (string) ($v)) == 0) {
                $val = $tmp;
                break;
            }
        }
    }

    return $val;
}

?>
