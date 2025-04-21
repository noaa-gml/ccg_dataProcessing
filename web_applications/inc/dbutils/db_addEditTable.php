<?php

#MARK table editing
function addEditTable($tableName,$pkName,$editCols,$aliases=array(),$reqFields=array(),$deleteVarName='',$jsFuncOnSuccess='',$validationCallback='',$addPKToJSFunctionOnSuccess=true,$useTransaction=true,$useNullForDefault=False,$modifyValuesCallback='',$srcData=[]){
    #Save changes.  Returns an array with 3 elements: status (true(success)/false(error)), pkVal & html (any error msgs in an alertPopup, '' on success (or if jsFuncOnSuccess passed, returns that (see below).))

    #$tableName is table to add/edit.  NOTE: this must be provided by caller, NOT by user form data (sql injection vector)
    #$pkName is the name of the primary key input/column.  If no value for pk form input in request data, then we are in insert mode.
    #   NOTE: this must be provided by caller, NOT by user editable form data (sql injection vector)

    #$editCols is $inputname=>coltype (from getHTTPVar())  of all cols in form and in table that we'll update.  Include pk.
    #  editCols name must be the input name, which should also be the table col name unless passing $aliases (see below)
    #If jsFuncOnSuccess is passed, then primary key is passed to it (if $addPKToJSFunctionOnSuccess) on slight delay (so that ajax finishes and you can call new ajax_get).
    #  if blank then this returns with no error and caller can decide what to do.
    #$reqFields is an array of required fields;  db col_name=>printable name.
    #$validationCallback, if passed, gets called with newVals array as a parameter.  colname=>value.  If it returns an error message, update is aborted, mssg sent to alert.
    #ifaddPKToJSFunctionOnSuccess we pass pk to js, otherwise we just pass js straight through.
    /*Example
        use getPopUpForm_dyn or getPopUpForm or getForm to create form.

        function gnt_grantSubmitValidationCallback($newVals){#Validate entries in grant submission
            $error='';extract($newVals);
            #Dates rational?
            $t=doquery("select datediff(?,?)",0,array($end_date,$start_date));
            if($t<1)$error.="End date must come after start date<br>";

            #pi exists?
            if(doquery("select count(*) from pis where num=?",0,array($pi_num))!=1)$error.="ERROR pi_num $pi_num doesn't exists<br>";

            return $error;
        }
        function gnt_submitEditForm(){
            #Save changes
                  $editCols=array('group_num'=>VAL_INT,'grant_num'=>VAL_INT,'institution'=>VAL_STRING,'sub_contractor'=>VAL_STRING,'start_date'=>VAL_DATE,'end_date'=>VAL_DATE,'pi_num'=>VAL_INT);
            $reqCols=array('institution'=>'Institution','start_date'=>'Start date','end_date'=>'End date','pi_num'=>'PI');
            return addEditTable('grants',$editCols,'grant_num','gnt_grantSaveSubmitted',$reqCols,"gnt_grantSubmitValidationCallback");
        }
    $useTransaction wraps in begin/rollback/commit.  I think (needs to test) if trigger raises exception, it should rollback.
        Can also pass false, and do in caller if want to do other stuff (cascading deletes...).


    $aliases is list of input names to exchange for db colnames. This is needed when you can't have same input id in form (because its in parent for ex)
       array('input_name'=>'col_name')
    $editCols should have input name=>col_type.
    $reqCols should be db col_names->printable name


    if deleteVarName is passed, then we look in post for deleteVarName=1 and delete row if so.  See getPopUpForm_dyn() for details
    if useNullForDefault then NULL is inserted instead of ''.  Make sure validation logic ignores
    if modifyValuesCallback then we pass newVals (after aliasing and pk removed) to callback and update with what ever is passed back.  This can be
        used change user entered values for what ever reason (like splitting record).
        Recieves parameters ($newVals,$origVals).

        Return modified/unchanged newVals array to continue with normal processing logic
        Return false to short circuit remaining logic and return error.
        Return True to short circuit remaining logic and report no error
    $srcData is optional source for loading data instead of $_REQUEST
    */
    $ret=array('status'=>false,'html'=>'');
    $html="";$error='';$newVals=array();$pkVal='';$delete=false;

    if($useTransaction) beginTransaction();#if available...
    #load and clean variables
    foreach($editCols as $col=>$type){
        #load submitted values
        $dflt=($useNullForDefault)?NULL:'';
        $newVals[$col]=getHTTPVar($col,$dflt,$type,[],'','',false,$srcData);
    }

    #rename as needed
    foreach($aliases as $input_name=>$col_name){
        $newVals[$col_name]=$newVals[$input_name];
        unset($newVals[$input_name]);
    }

    #find pkval.
    $pkVal=$newVals[$pkName];

    #fetch original row values (if present) so we can know which columns to update.  This will make the logging much cleaner.
    #also so we can pass to callback if needed.
    $origVals=addEditTable_fetchOrigValues($tableName, $pkName, $pkVal);

    #see if caller wants to have a chance to modify values
    if($modifyValuesCallback){
        $newVals=call_user_func($modifyValuesCallback,$newVals,$origVals);
        if($newVals==False){$ret['status']=False;return $ret;}#empty array is error too.
        if($newVals===True){$ret['status']=True;return $ret;}
    }

    #find pkval again. Do this after callback incase was zeroed out for insert
    if($pkVal!=$newVals[$pkName]){
        $pkVal=$newVals[$pkName];
        $origVals=addEditTable_fetchOrigValues($tableName, $pkName, $pkVal);
    }
    unset($newVals[$pkName]);#this one is handled separately.


    #var_dump($newVals);var_dump($reqFields);
    #check for required fields
    foreach($reqFields as $reqcol=>$reqname){
        if($newVals[$reqcol]==='' || $newVals[$reqcol]===false || is_null($newVals[$reqcol])) $error.="$reqname is a required field<br>";
    }

    #see if we might be deleteing.
    if($deleteVarName){
        $delete=getHTTPVar($deleteVarName,false,VAL_INT,[],'','',false,$srcData);
    }

    if(!$error){
        if($delete){#danger will robinson...
            if($pkVal && $pkName && $tableName){
                $t=dodelete("delete from $tableName where $pkName=? limit 1",array($pkVal));#Security authorization is handled in dodelete
                if($t!==1)$error.="Unable to delete key $pkVal";
            }else $error.="Can't delete row that doesn't exist yet.";

        }else{
            #validate if requested.
            if($validationCallback){
                $t=$newVals;$t[$pkName]=$pkVal;#Make a copy of newVals and add in the pk
                $error.=call_user_func($validationCallback,$t);
            }

            if(!$error){
                #Submit
                bldsql_init();
                #set each col
                $nupdatecols=0;
                foreach($newVals as $col=>$val){
                    #include all cols if inserting, on update see if different from original values.
                    #This is mostly to clean up logging to make it easier to see what changed.
                    #jwm - 5/23.  Actually changing to use filter on both update & insert.  New db version doesn't
                    #allow default '' into inappropriate column (int, float..) and fails.  Old used to allow then force to 0 or something.

                    #note; some cols may be included just because the format changed, ie- dates put into yyyymmdd by php/js logic may
                    #be equivelent to origVal but included because we're just doing a string match.  This doesn't harm the logic, just
                    #adds unnecessary columns.

                    if((!$origVals && $val) || (array_key_exists($col,$origVals) && $origVals[$col]!=$val) || (array_key_exists($col,$origVals) && $origVals[$col]==NULL && $val) ){#!$origVals ||
                        bldsql_set("$col=?",$val);
                        $nupdatecols++;
                    }
                }

                #var_dump(bldsql_printableQuery());
                if($nupdatecols==0)$error.="No fields updated.";
                if(!$error){
                    if($pkVal){#Update
                        #Edit
                        bldsql_update($tableName);
                        bldsql_where("$pkName=?",$pkVal);
                        $a=doupdate();
                        if($a===false)$error.="Error editing this row.<br>";
                    }else{
                        #Add mode
                        bldsql_insert($tableName);
                        $pkVal=doinsert();
                        if(!$pkVal)$error="Error inserting this row<br>";
                    }
                }
            }
        }
    }
    $html='';

    if($error){
        #var_dump($error);
        $ret['status']=False;
        if($useTransaction)rollbackTransaction();
        $html=$error;
    }else{
        if($useTransaction)commitTransaction();
        if($jsFuncOnSuccess){
            $js=($addPKToJSFunctionOnSuccess)?"$jsFuncOnSuccess($pkVal)":"$jsFuncOnSuccess()";
            $html="<script>".bs_delayedJS($js)."</script>";
        }
        $ret['status']=True;
    }
    $ret['html']=$html;
    $ret['pkVal']=$pkVal;
    return $ret;
}
function addEditTable_handler($ret){
    /*Does basic handling of return status from above*/
    $modalDivID=getHTTPVar("bs_modalFormID");//Is modal window?
    if($ret['status']){
        $pkVal=$ret['pkVal'];
        #Close modal window?
        $modalJS=($modalDivID)?"bs_hideModal('$modalDivID');":"";
        #call the generic js handler to reload the listings and this row after a brief pause.
        $html="<h6 class='bs_textHighlightB'>Changes saved.</h6> &nbsp<script>".bs_delayedJS("$modalJS bs_submitSearchForm('bs_loadList&preloadID=${pkVal}');",1500)."</script>";
    }else{
        $html=$ret['html'];
        #return in a popup if regular form, just text if already in modal window.
        if(!$modalDivID)$html=bs_modal($html,'Alert',['dynamic'=>true,'size'=>'lg']);
        #If formID passed, re-enable buttons so user can fix
        $formID=getHTTPVar("formID");
        if($formID){$html.="<script>bs_disable('.".$formID."_btn',false);</script>";}
    }
    #var_dump(htmlspecialchars($html));exit();
    return $html;

}
function addEditTable_fetchOrigValues($tableName, $pkName, $pkVal){
    #fetchs 1 row from table and returns assoc array of all cols=>values
    #NOTE: $tableName and $pkName must be provided by calling code (server side code), NOT by user editable form data (sql injection vector)
    #Returns empty array if row doesn't exist or pkVal is (false).
    $ret=array();

    if($pkVal){
        $a=doquery("select * from $tableName where $pkName=?",-1,array($pkVal));
        if($a)$ret=$a[0];
    }
    return $ret;
}



