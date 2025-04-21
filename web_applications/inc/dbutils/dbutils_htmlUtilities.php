<?php
/*Utility functions for parseing input and cleaning data.  These are copied from Kirk's dbedit library.*/
require_once("htmlValidation.php");
/*Not ready to do this.. I think it should be folded into bs_ or needs new names as it conflicts with below versions.
This is the one I updated at bipm and I think is pretty good.  Would like to use going forward.
require_once("db_addEditTable.php");
*/
function setRequestValuesInCookie($keys, $expires=0){
    #Save off search params in current $_REQUEST to a cookie for reload next time
    #keys is array of keys to lookfor/save, values is variable type (see getHTTPVar)
    #expires is time in days from now to keep cookie for.  0 is session
    #Only sets for current directory
    #Not sure how best to unset things, particularly with checkboxes which are true when passed.
    #for now trying setting to false so you don't get zombied keys.
    #May need to actively unset somehow
    if($expires)$expires=time()+60*60*24*$expires;#setcookie is indexed by secs from epoch
    foreach($keys as $key=>$type){
        $val=getHTTPVar($key,false,$type);
        #if($val){#This was leaving cookies that should have been changed to false.
        setcookie($key,$val,$expires);
        #}
        #var_dump($key.":".$val);
    }
}
#MARK forms, popups and table editing
function addEditTable($tableName,$editCols,$pkName,$jsFuncOnSuccess='',$reqFields=array(),$validationCallback='',$addPKToJSFunctionOnSuccess=true,$pkColIsNum=true,$useTransaction=true,$aliases=array(),$deleteVarName='',$useNullForDefault=False,$modifyValuesCallback=''){
    #Save changes.  Returns any error msgs in an alertPopup, '' on success (or if jsFuncOnSuccess passed, returns that (see below).)

    #$pkName is the name of the primary key.  If no value then we are in insert mode.
    #$editCols is $name=>coltype (from getHTTPVar())  of all cols in form and in table that we'll update.  Include pk
    #Form inputs must match table col names.
    #If jsFuncOnSuccess is passed, then primary key is passed to it (if $addPKToJSFunctionOnSuccess) on slight delay (so that ajax finishes and you can call new ajax_get).
    #  if blank then this returns '' on no error and caller can decide what to do.
    #$reqFields is an array of required fields;  col_name=>printable name.
    #$validationCallback, if passed, gets called with newVals array as a parameter.  colname=>value.  If it returns an error message, update is aborted, mssg sent to alert.
    #ifaddPKToJSFunctionOnSuccess we pass pk to js, otherwise we just pass js straight through.
    #if pkColIsNum then we assume the pkname refers to the form input var and the real col name is actually just 'num'.  false we use pkName for both.
        #this is because most pk cols are labeled num but I don't want to pass just 'num' as input var name because that seems dangerous and is hard to read.
    /*Example
        use getPopUpForm_dyn or getPopUpForm to create form.

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
    $useTransaction wraps in begin/rollback/commit.  I think (needs to test) if trigger raises exception, it should rollback.  Can also pass false, and do in caller if want to do
    other stuff (cascading deletes...).

    $aliases is list of input names to  for db colnames
        array('input_name'=>'col_name')
        editCols should have input name.  This is needed whey you can't have same input id in form (cause its in parent ex)
        $reqCols should be col_name
        $pkName should be col_name

    if deleteVarName is passed, then we look in post for deleteVarName=1 and delete row if so.  See getPopUpForm_dyn() for details
    if useNullForDefault then NULL is inserted instead of ''.  Make sure validation logic ignores
    if modifyValuesCallback then we pass newVals (before aliasing) to callback and update with what ever is passed back.  This can be
        used change user entered values for what ever reason (like splitting record).  Return false for error.
    */
    $html="";$error='';$newVals=array();$pkVal='';$delete=false;
    if($useTransaction)beginTransaction();#if available...
    #load and clean variables
    foreach($editCols as $col=>$type){
        #load submitted values
        #if($col==$pkName)$pkVal=getHTTPVar($col,'',$type);#moved below
        $dflt=($useNullForDefault)?NULL:'';
        $newVals[$col]=getHTTPVar($col,$dflt,$type);
    }

    #see if caller wants to have a chance to modify values
    if($modifyValuesCallback){
        $newVals=call_user_func($modifyValuesCallback,$newVals);
        if($newVals==False){return False;}
    }

    #rename as needed
    foreach($aliases as $input_name=>$col_name){
        $newVals[$col_name]=$newVals[$input_name];
        unset($newVals[$input_name]);
    }

    #find pk. Do this after aliasing
    foreach($newVals as $col=>$val){
        if($col==$pkName)$pkVal=$val;
    }
    unset($newVals[$pkName]);#this one is handled separately.

    #var_dump($newVals);var_dump($reqFields);
    #check for required fields
    foreach($reqFields as $reqcol=>$reqname){
        if($newVals[$reqcol]==='' || $newVals[$reqcol]===false || is_null($newVals[$reqcol])) $error.="$reqname is a required field<br>";
    }
    #see if we might be deleteing.
    if($deleteVarName){
        $delete=getHTTPVar($deleteVarName,false,VAL_INT);
    }
    if(!$error){
        if($delete){#danger will robinson...
            if($pkVal && $pkName && $tableName){
                $col=($pkColIsNum)?'num':$pkName;
                $t=doupdate("delete from $tableName where $col=? limit 1",array($pkVal));
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
                foreach($newVals as $col=>$val){
                    bldsql_set("$col=?",$val);
                }

                if($pkVal){#Update
                    #Edit
                    bldsql_update($tableName);
                    $col=($pkColIsNum)?'num':$pkName;
                    bldsql_where("$col=?",$pkVal);
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
    $html='';
    if($error){
        if($useTransaction)rollbackTransaction();
        $html=getPopupAlert($error);
    }else{
        if($useTransaction)commitTransaction();
        if($jsFuncOnSuccess){
            $js=($addPKToJSFunctionOnSuccess)?"$jsFuncOnSuccess($pkVal)":$jsFuncOnSuccess;
            $html="<script>".delayedJS($js)."</script>";
        }
    }
    return $html;
}

function addEditTable2($tableName,$editCols,$pkName,$jsFuncOnSuccess='',$reqFields=array(),$validationCallback='',$addPKToJSFunctionOnSuccess=true,$pkColIsNum=true,$useTransaction=true,$aliases=array(),$deleteVarName='',$useNullForDefault=False,$modifyValuesCallback=''){
    #started as a replacement for addEditTable, but eventually had to make incompatible changes (return value).  This should be the one to be used going forward.
    #Save changes.  Returns an array with 2 elements: success (true/false) and html (any error msgs in an alertPopup, '' on success (or if jsFuncOnSuccess passed, returns that (see below).))


    #$tableName is table to add/edit.  NOTE: this must be provided by caller, NOT by user form data (sql injection vector)
    #$pkName is the name of the primary key input/column.  If no value for pk form input in request data, then we are in insert mode.
    #   NOTE: this must be provided by caller, NOT by user editable form data (sql injection vector)
    #if pkColIsNum then we assume the pkname refers to the form input var and the real col name is actually just 'num'.  false we use pkName for both.
        #this is because most pk cols are labeled num but I don't want to pass just 'num' as input var name because that seems dangerous and is hard to read.

    #$editCols is $name=>coltype (from getHTTPVar())  of all cols in form and in table that we'll update.  Include pk.
    #  editCols name must be the input name, which should also be the table col name unless passing $aliases (see below)
    #If jsFuncOnSuccess is passed, then primary key is passed to it (if $addPKToJSFunctionOnSuccess) on slight delay (so that ajax finishes and you can call new ajax_get).
    #  if blank then this returns '' on no error and caller can decide what to do.
    #$reqFields is an array of required fields;  col_name=>printable name.
    #$validationCallback, if passed, gets called with newVals array as a parameter.  colname=>value.  If it returns an error message, update is aborted, mssg sent to alert.
    #ifaddPKToJSFunctionOnSuccess we pass pk to js, otherwise we just pass js straight through.
    /*Example
        use getPopUpForm_dyn or getPopUpForm to create form.

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
            return addEditTable2('grants',$editCols,'grant_num','gnt_grantSaveSubmitted',$reqCols,"gnt_grantSubmitValidationCallback");
        }
    $useTransaction wraps in begin/rollback/commit.  I think (needs to test) if trigger raises exception, it should rollback.
        Can also pass false, and do in caller if want to do other stuff (cascading deletes...).


    $aliases is list of input names to exchange for db colnames. This is needed when you can't have same input id in form (cause its in parent ex)
        Note; do not include primary key alias in this array (use $pkColIsNum instead).  This is confusing, not sure why I did pk special instead of
        just using alias array.  Will probably break for non num pks (like id), but don't want to change due to existing callers.
        array('input_name'=>'col_name')
    $editCols should have input name.
    $reqCols should be col_names


    if deleteVarName is passed, then we look in post for deleteVarName=1 and delete row if so.  See getPopUpForm_dyn() for details
    if useNullForDefault then NULL is inserted instead of ''.  Make sure validation logic ignores
    if modifyValuesCallback then we pass newVals (after aliasing and pk removed) to callback and update with what ever is passed back.  This can be
        used change user entered values for what ever reason (like splitting record).
        Recieves parameters ($newVals,$origVals).

        Return modified/unchanged newVals array to continue with normal processing logic
        Return false to short circuit remaining logic and return error.
        Return True to short circuit remaining logic and report no error
    */
    $ret=array('status'=>false,'html'=>'');
    $html="";$error='';$newVals=array();$pkVal='';$delete=false;
    $pkTableColName=($pkColIsNum)?'num':$pkName;#table name

    if($useTransaction) beginTransaction();#if available...
    #load and clean variables
    foreach($editCols as $col=>$type){
        #load submitted values
        #if($col==$pkName)$pkVal=getHTTPVar($col,'',$type);#moved below
        $dflt=($useNullForDefault)?NULL:'';
        $newVals[$col]=getHTTPVar($col,$dflt,$type);
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
    $origVals=addEditTable_fetchOrigValues($tableName, $pkTableColName, $pkVal);

    #see if caller wants to have a chance to modify values
    if($modifyValuesCallback){
        $newVals=call_user_func($modifyValuesCallback,$newVals,$origVals);
        if($newVals==False){$ret['status']=False;return $ret;}#empty array is error too.
        if($newVals===True){$ret['status']=True;return $ret;}
    }

    #find pkval again. Do this after callback incase was zeroed out for insert
    if($pkVal!=$newVals[$pkName]){
        $pkVal=$newVals[$pkName];
        $origVals=addEditTable_fetchOrigValues($tableName, $pkTableColName, $pkVal);
    }
    unset($newVals[$pkName]);#this one is handled separately.


    #var_dump($newVals);var_dump($reqFields);
    #check for required fields
    foreach($reqFields as $reqcol=>$reqname){
        if($newVals[$reqcol]==='' || $newVals[$reqcol]===false || is_null($newVals[$reqcol])) $error.="$reqname is a required field<br>";
    }
    #see if we might be deleteing.
    if($deleteVarName){
        $delete=getHTTPVar($deleteVarName,false,VAL_INT);
    }

    if(!$error){
        if($delete){#danger will robinson...
            if($pkVal && $pkName && $tableName){
                $t=doupdate("delete from $tableName where $pkTableColName=? limit 1",array($pkVal));
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
#var_dump($origVals);var_dump($val);
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
                        $col=($pkColIsNum)?'num':$pkName;
                        bldsql_where("$col=?",$pkVal);


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
        $html=getPopupAlert($error);
    }else{
        if($useTransaction)commitTransaction();
        if($jsFuncOnSuccess){
            $js=($addPKToJSFunctionOnSuccess)?"$jsFuncOnSuccess($pkVal)":$jsFuncOnSuccess;
            $html="<script>".delayedJS($js)."</script>";
        }
        $ret['status']=True;
    }
    $ret['html']=$html;
    return $ret;
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

function getPopUpForm($formData,$windowTitle,$formTitle,$buttonText,$doWhat,$destDiv='',$submitJSChecks='',$submitMssg='Submitting...',$buttonTitleText='',$btnClass='',$deleteVar='',$width='',$hyperlink=false){

    /*Be wary of multiple submission bug with this.. There was an issue on another implementation where
     *because the dialog was still in memory, if reloaded from ajax call, a copy was created (with different form values!).
     *On submission, only the first value would be sent through.  Using destroy() in the close method seems to have fixed,
     *but in the other method I did a remove() too which removed all contents.  For this, that caused issues as removing the
     *div disallowed re-opening the form.  It appears to be settled, but be sure to test multiple submissions carefully.
    /NOTE

    This function submits the form for you, you do not need to create a js function to serialize the inputs and submit.  You
    need to create a switch.php case, and then a php function to submit the data (can use addeditform() ).  The return output of that
    submit gets put into destDiv.


     *Not really db related, but convient place to put this.  This will return a button that opens a popup window with a form to submit.
     *See below for details.  Makes assumptions that you are using and have linked the switch.php and js ajax libraries
     *
     *Returns html/js for a submitable popup form.
     *On submit this will pass form data to ajax_post (must be linked in switch already)
     *$formData is all of the inputs and layout html for the form.  Do not include <form> tags or submit/cancel buttons, those are added here.
     *$windowTitle is window title.
     *$formTitle is displayed at the top of the form (can be blank).
     *$doWhat is the ajax_post dowhat param (see it for details), but basically the php function in switch.php to process the form data.
     *$destDiv is the ajax_post dest div that will receive what ever is returned from the php function above(if blank, this creates one (didn't test though, so first time user needs to test it!).
     *$ajaxHandler is the ajax_post handler to use.
     *$submitJSChecks is any form validation you want to do.  Just have it 'return false' if you don't want it to submit.
     *  You can also have this js add any parameters (in standard name=val&name2=val2 format or by using .serialize()) that you want to submit with the form.
     *  just do a formData="name=val&name2=val2..."; or formData=myOtherForm.serialize(); in the code.
     *  Note this is just js code, not a function although it can contain a function.
     *
     *If $deleteVar is passed, then a delete button is added that when pressed passes the deleteVar in the post =1,
     *   ie- if passed 'icp_filterSetDelete', then &icp_filterSetDelete=1 is appended to the post submission when delete is pushed.
     *$width specifies initial width in px, leave blank for default (300 i think).
     *if $hyperlink, we use a <a> instead of a button.

     */
    $uid=uniqid();//Incase there's more than one on the page.
    $html="";
    if(!$destDiv){
        $destDiv="html_popUpFormDestDiv_${uid}";
        $html.="<div id='$destDiv'></div>";
    }
    $delBtn="";$delParamCheck="";
    if($deleteVar){#If a deleteVar was passed, add a button and action.
        $delDisable=(db_userCanDelete())?'':'disabled: true,';#still show the button, but disable.  This uses dbutils user table if configured, defaults to true
        $delBtn="{text:\"Delete\", ${delDisable} click:function(){deleteBtnClicked_${uid}();}},";
        $delParamCheck="if(delete_${uid}==1){formData+=\"&${deleteVar}=1\";}";
    }
    $title=($buttonTitleText)?"title='$buttonTitleText'":"";
    $width=($width)?"width: $width,":"";
    $button=($hyperlink)?"a href=''":"button";
    $buttonClose=($hyperlink)?"a":"button";
    $html.="<${button} class='$btnClass' id='html_popUpFormButton_${uid}' $title>$buttonText</${buttonClose}>
        <div id='html_popUpFormDiv_${uid}' >
            <div class='title4'>$formTitle</div><br>
            <form id='html_popUpForm_${uid}'>$formData</form>
        </div>
        <script language='JavaScript'>
            var html_popupFormAjaxHandler_${uid};
            var popUpForm_${uid}=$(\"#html_popUpForm_${uid}\");
            var dialog_${uid}=false;

            $(\"#html_popUpFormDiv_${uid}\").hide();//Since we don't create the dialog until button click, hide the contents of the div

            $(\"#html_popUpFormButton_${uid}\").click(function(event){
                event.preventDefault();
                $(\"#html_popUpFormDiv_${uid}\").show();
                dialog_${uid}=$(\"#html_popUpFormDiv_${uid}\").dialog({
                   title:\"$windowTitle\",
                   autoOpen:true,
                   modal: true,
                   $width
                   buttons:[$delBtn{
                        text:\"Cancel\",
                        click: function(){
                            dialog_${uid}.dialog( \"close\" );
                        }
                   },{
                        text:\"Submit\",
                        click: function(){
                            popUpForm_${uid}.submit();
                        }
                   }],
                   close: function(){
                        $(this).dialog('close');//close window
                        $(this).dialog('destroy');//remove dialog from dom, but leave div contents
                        $(this).hide();//hide div contents

                        //$(this).dialog('destroy').remove();//remove was too far....
                   }
                });
                dialog_${uid}.keypress(function(e){
                    if(e.keyCode==$.ui.keyCode.ENTER){
                        e.preventDefault();//Prevent enter button from submitting the form.  (we had bug before adding this (10/19) that tried to submit twice and got an error on 2nd because dialog was already gone.)
                        popUpForm_${uid}.submit();
                    }
                });
            });
            popUpForm_${uid}.on( \"submit\", function( event ) {
                event.preventDefault();
                var formData='';

                //form validation?
                $submitJSChecks
                if(formData){formData+='&';}//If custom js added some params, append a joiner

                formData+=popUpForm_${uid}.serialize();
                $delParamCheck
                //console.log(formData);

                ajax_post('$doWhat',formData,'$destDiv',html_popupFormAjaxHandler_${uid});
                $(\"#$destDiv\").html(\"$submitMssg\");
                dialog_${uid}.dialog( \"close\" );

            });
            var delete_${uid}=0;
            function deleteBtnClicked_${uid}(){
                if(confirm(\"Delete this entry?\")){
                    delete_${uid}=1;//Set bool to true.
                    popUpForm_${uid}.submit();  //submit.
                }
            }

        </script>
    ";
    return $html;
}
function getPopUpForm_dyn($formData,$windowTitle,$formTitle,$doWhat,$destDiv='',$submitJSChecks='',$submitMssg='Submitting...',$deleteVar='',$width='',$enterSubmits=True,$position='',$cloneJS='',$altSubmitBtnJS='',$altBtnText=''){
    /*Same as getPopUpForm, but meant to be called from ajax call (like from clicking row in table).  We could/should merge them, but
    that's too complicated to test right now...

    /NOTE

    This function submits the form for you, you do not need to create a js function to serialize the inputs and submit.  You
    need to create a switch.php case, and then a php function to submit the data (can use addeditform() ).  The return output of that
    submit gets put into destDiv.


     *This returns html/js to open a popup window with a form to submit.
     *See below for details.  Makes assumptions that you are using and have linked the switch.php and js ajax libraries
     *
     *Returns html/js for a submitable popup form.
     *On submit this will pass form data to ajax_post (must be linked already)
     *$formData is all of the inputs and layout html for the form.  Do not include <form> tags or submit/cancel buttons, those are added here.
     *$windowTitle is window title.
     *$formTitle is displayed at the top of the form (can be blank).
     *$doWhat is the ajax_post dowhat param (see it for details), but basically the php function in switch.php to process the form data.
     *$destDiv is the ajax_post dest div that will receive what ever is returned from the php function above
     *$ajaxHandler is the ajax_post handler to use.
     *$submitJSChecks is any form validation you want to do.  Just have it 'return false' if you don't want it to submit.
     *  You can also have this js add any parameters (in standard name=val&name2=val2 format or by using .serialize()) that you want to submit with the form.
     *  just do a formData="name=val&name2=val2..."; or formData=myOtherForm.serialize(); in the code.
     *  Note this is just js code, not a function although it can contain a function.
     *
     *If $deleteVar is passed, then a delete button is added that when pressed passes the deleteVar in the post =1,
     *   ie- if passed 'icp_filterSetDelete', then &icp_filterSetDelete=1 is appended to the post submission when delete is pushed.
     *$width specifies initial width in px, leave blank for default (300 i think).
     #$position: center (default), 'top left'
     #If cloneJS provided, then a clone button is added that runs cloneJS when clicked.  Generally this should wipe the pk hidden input and perhaps others.
        ex:
        $cloneJS="$('#drier_hist_num').val('0');$('#start_date').val('');$('#end_date').val('');
            $(this).dialog({ title: 'Add Drier Hist' });alert('Record clopied.  Enter new start/end dates.')";
    $altSubmitBtnJS- if passed a 2nd submit action button is added.  passed js is called first (like to open a popup to get additional info) and then form is submitted.  Being used on drier history to split/continue records. (actually not used, leaving for now though)
     */
    $uid=uniqid();//Incase there's more than one on the page.
    $html="";$cloneBtn='';$altBtn='';
    if(!$destDiv){
        $destDiv="html_popUpFormDestDiv_${uid}";
        $html.="<div id='$destDiv'></div>";
    }
    $pos='';
    if($position=='top left')$pos='position: { my: "left top", at: "left top", of: window },';
    #$destDiv="html_popUpFormDestDiv_${uid}";
    #$html.="<div id='$destDiv'></div>";
    $delBtn="";$delParamCheck="";
    #var_dump(db_userCanDelete());
    if($deleteVar){#If a deleteVar was passed, add a button and action.
        $delid="${uid}_delbtn";
        $delDisable=(db_userCanDelete())?'':'disabled: true,';#still show the button, but disable.  This uses dbutils user table if configured, defaults to true

        $delBtn="{id:\"${delid}\",text:\"Delete\", ${delDisable} click:function(){deleteBtnClicked_${uid}();}},";
        $delParamCheck="if(delete_${uid}==1){formData+=\"&${deleteVar}=1\";}";

    }
    if($cloneJS){#If cloneJS was passed, add a button and action.
        $cloneid="${uid}_clonebtn";
        $cloneDisable='$("#'.$cloneid.'").button("disable");';
        $delDisable='$("#'.$delid.'").button("disable");';
        $cloneBtn="{id:\"${cloneid}\", text:\"Clone\",click:function(){ ${cloneJS} ;${cloneDisable};${delDisable};}},";
    }
    if($altSubmitBtnJS){#add alt btn that submits with callers js
        $altid="${uid}_altbtn";
        $altbtn="{text:\"${altBtnText}\", click:function(){ ${altSubmitBtnsJS} popUpForm_${uid}.submit(); }}";
    }
    #$title=($buttonTitleText)?"title='$buttonTitleText'":"";
    $width=($width)?"width: $width,":"";
    $enterSubs=($enterSubmits)?"dialog_${uid}.keypress(function(e){
                if(e.keyCode==$.ui.keyCode.ENTER){
                    event.preventDefault();
                    popUpForm_${uid}.submit();
                }
            });":'';
    $html.="
        <div id='html_popUpFormDiv_${uid}' >
            <div class='title4'>$formTitle</div><br>
            <form id='html_popUpForm_${uid}'>$formData</form>
        </div>
        <script language='JavaScript'>
            var html_popupFormAjaxHandler_${uid};
            var popUpForm_${uid}=$(\"#html_popUpForm_${uid}\");
            var dialog_${uid}=false;
            $(\"#html_popUpFormDiv_${uid}\").show();
            dialog_${uid}=$(\"#html_popUpFormDiv_${uid}\").dialog({
               title:\"$windowTitle\",
               autoOpen:true,
               modal: true,
               $pos
               $width
               buttons:[$altBtn $delBtn $cloneBtn{
                    text:\"Cancel\",
                    click: function(){
                        dialog_${uid}.dialog( \"close\" );
                    }
               },{
                    text:\"Submit\",
                    click: function(){
                        popUpForm_${uid}.submit();
                    }
               }],
               close: function(){
                    $(this).dialog('close');//close window
                    $(this).dialog('destroy');//remove dialog from dom, but leave div contents
                    $(this).hide();//hide div contents

                    //$(this).dialog('destroy').remove();//remove was too far....
               }
            });
            $enterSubs

            popUpForm_${uid}.on( \"submit\", function( event ) {
                event.preventDefault();
                var formData='';

                //form validation?
                $submitJSChecks
                if(formData){formData+='&';}//If custom js added some params, append a joiner

                formData+=popUpForm_${uid}.serialize();
                $delParamCheck
                //console.log(formData);

                ajax_post('$doWhat',formData,'$destDiv',html_popupFormAjaxHandler_${uid});
                $(\"#$destDiv\").html(\"$submitMssg\");
                dialog_${uid}.dialog( \"close\" );

            });
            var delete_${uid}=0;
            function deleteBtnClicked_${uid}(){
                if(confirm(\"Delete this entry?\")){
                    delete_${uid}=1;//Set bool to true.
                    popUpForm_${uid}.submit();  //submit.
                }
            }

        </script>
    ";
    return $html;
}
function getPopUp($contents,$buttonText,$windowTitle="",$width="",$buttonTrigger=true,$popOut=false){
    /*Returns a button/link that when pressed will display $contents in a popup display.
     *It's fairly simple js, but there's a weird bug/feature when reclicking (see below form for more details),
     *so we wrap the js logic.
     *If no width passed, it's auto sized by content.  With is number of pixels (like 400).
     *If $buttonTrigger passed true, then a standard button is created.  If false, then a hyperlink.
     *if $popOut then the div is displayed by default (100%wide), with a popout button to the side that opens in a popup window.
     *NOTE popOut doesn't work right yet...
     **/
    $uid=uniqid();
    $width=($width)?"width: $width,":"";
    $hideContents='true';#hidden by default.
    $trigger=($buttonTrigger)?"<button id='html_popUpButton_${uid}'>$buttonText</button>":"<a href='_new' id='html_popUpButton_${uid}'>$buttonText</a>";
    if($popOut){
        $html="<table width='100%'><tr><td align='left'><div style='width:100%;height:100%' id='html_popUpDiv_${uid}'>$contents</div></td><td align='right' valign='top'>$trigger</td></tr></table>";
        $hideContents='false';
    }
    else $html="$trigger <div id='html_popUpDiv_${uid}'>$contents</div>";
    $html.="
        <script language='JavaScript'>
            var dialog_${uid}=false;
            if(${hideContents}){ $(\"#html_popUpDiv_${uid}\").hide();}//Since we don't create the dialog until button click, hide the contents of the div

            $(\"#html_popUpButton_${uid}\").click(function(event){
                event.preventDefault();
                $(\"#html_popUpDiv_${uid}\").show();
                dialog_${uid}=$(\"#html_popUpDiv_${uid}\").dialog({
                   title:\"$windowTitle\",
                   $width
                   autoOpen:true,
                   modal: true,
                   buttons:[{
                        text:\"Close\",
                        click: function(){
                            dialog_${uid}.dialog( \"close\" );
                        }
                   }],
                   close: function(){
                        $(this).dialog('close');//close window
                        $(this).dialog('destroy');//remove dialog from dom, but leave div contents
                        if($hideContents){ $(this).hide();}//hide div contents
                   }
                });
            });

        </script>
    ";
    return $html;
}

function getSavePopUpFormButton($formData,$windowTitle,$formTitle,$jsAction,$id='',$altText='Save'){
	#Returns a save button with little disk img.  Assumes dbutils path of /inc/dbutils...  Was too much of a pain to ensure path set in all callers otherwise.
	#if no id passed, we generate one.
	if(!$id)$id=uniqid();
	$saveBtn=getJSButton($id,$jsAction,"<img src='/inc/dbutils/template/resources/save.png' alt='$altText' height='14' width='14'>","","","","savebtn",$altText);
	return $saveBtn;
}
function getConfirmationButton($buttonText,$confirmationText,$actionJS){
    /*Returns a button that asks for confirmation before taking action*/
    $id=uniqid();
    $html="
        <input type='button' value='$buttonText' id='$id'>
        <script language='JavaScript'>
            $(\"#${id}\").click(function(event){
                event.preventDefault();
                if(confirm(\"$confirmationText\")){
                    $actionJS
                }
            })
        </script>";
    return $html;
}

function getPopupAlert($alertText,$formatted=true,$windowTitle="Alert"){
    /*Show an alert.
     *if $formatted=false this is just a standard popup (no formatting), and all html is stripped (via jquery.text() method.
     *This should be fairly safe to run (won't bug on " or special chars), but I wouldn't pass user content without bleaching.
     *Otherwise contents are displayed formatted.  I am not sure this is safe, (you'd have to research jquery popup),
     *so wouldn't display user content directly.*/
    $uid=uniqid();
    if($formatted){

        $html="
            <div id='html_popUpDiv_${uid}'>$alertText</div>
            <script language='JavaScript'>
                var dialog_${uid}=$(\"#html_popUpDiv_${uid}\").dialog({
                       title:\"$windowTitle\",
                       autoOpen:true,
                       width: 'auto',
                       modal: true,
                       buttons:[{
                            text:\"Close\",
                            click: function(){
                                dialog_${uid}.dialog( \"close\" );
                            }
                       }],
                       close: function(){
                            $(this).dialog('close');//close window
                            $(this).dialog('destroy');//remove dialog from dom, but leave div contents
                            $(this).hide();//hide div contents
                       }

                    });
            </script>
        ";
    }else{
        $html="<div id='${uid}' style='display:none;'>$alertText</div>
        <script language='JavaScript'>
            var t=$(\"#${uid}\").text();
            alert(t);
        </script>
        ";
    }
    return $html;
}



/*MARK General utility functions.*/
function parseIDsFromList($str){
    /*Returns an array of id nums from passed comma separated list*/
    $a=array();
    if($str){
        $a=explode(",",$str);
        $a=array_filter($a,"is_intKey");#Filter to only valid ints
    }

    return $a;
}
function getFileName($path, $name){#check if filename exists and append something if so so id doesn't overwrite.
    $path.="/";#add one whether needs or not (no harm)
    if(strlen($name)<4)$name.=".txt";
    $filename=$path.$name;
    if(is_file($filename)){
        #try to find one that's available
        $a=substr($name,0,-4);
        $b=substr($name,strlen($name)-4);
        $n=1;
        while($n){
            if(is_file($path.$a."(${n})".$b))$n+=1;
            else{
                $filename=$path.$a."(${n})".$b;
                $n=false;
            }
        }
    }
    return $filename;
}
function is_intKey($i){
    return (intval($i)>0);
}
function arrayToJSON($arr,$useType=true){
    #NOTE!  useType=true is failing to unpack (jsontoarray) in some cases (passing an array of $_REQUEST values).!  Didn't find where, switched to text only.
	/*Takes passed php array and converts to json array or object.  Array can be
	*index based or hash.  If first element key is 0, we assume index and ignore all keys.
	*Values can be string, numeric, bool or arrays.
	*Note php has built in support for this in current versions.  I wrote this because our php ver on om is old.
	*If $useType we output numbers and bools unquoted, if false all values are treated as string (for easier manipulation with html forms).
	*
	*NOTE! /ccg/src/db/ccg_addtag_range.pl creates it's own json array (of data_nums) to pass in, quoting as strings.  If behaviour changes
	*that script needs to be altered too.
	*Note; for compatiblity with below JSONToArray, we strip out any embedded ] or } chars in string values as they can cause issues.
	*
	*/
	#Figure out if $arr is a hash or indexed array.  Assume if first element is a number, it's indexed.

	if($arr){
        $keys=array_keys($arr);
        $hash=($keys[0]!==0);

        $json=($hash)?"{":"[";
        foreach($arr as $key=>$val){
            $json.=($hash)?"\"$key\":":"";
            if(is_array($val))$json.=arrayToJSON($val,$useType);
            elseif($val=='smoothPlotter')$json.=$val;#special case for dygraph plot object, no quotes (its an obj)
            elseif(is_numeric($val) && $useType)$json.=$val;
            elseif(is_bool($val) && $useType)$json.=($val)?"true":"false";
            else{
                $val=str_replace("\\\"","___ESCAPEDQUOTE___",$val);#Temporarily change any escaped quotes so they don't get escaped again
                $val=str_replace('"','\"',$val);#escape any embedded quotes
                $val=str_replace("___ESCAPEDQUOTE___","\\\"",$val);
                $val=str_replace("}",'',$val);#strip any end delims
                $val=str_replace("]",'',$val);
                $json.="\"$val\"";#quote the whole string.
            }
            $json.=",";
        }
        $json=substr($json,0,-1);#Strip trailing comma
        $json.=($hash)?"}":"]";
    }else $json="{}";#empty object
	return $json;
}
function JSONToArray($json,$verbose=false){
    /*Takes a json encoded obj/array and turns into a php array.  Note this hasn't been test on anything except output from the above,
     *in particular it is really only ok'd for above output where no string values have an embedded ] or }.  It will
     *likely have a fit if strings contain either of those.
     *It's on the list to correct this bug, but as current uses would never pass such a string, it's not an issue.
     *
     *If json is js array, we use number indexes (from 0), if object then hashes.
     *We assume any embedded double quotes are escaped with \.
     !!!Does not handle empty {} values!!!
     */
    $arr=array();
    if($verbose)echo "<br>Parsing $json<br>.<br>";
    #if($json=="{}" || $json=="[]")return array();
    $start=substr($json,0,1);
    if($start=="{" || $start=="[" ){
        $hash=($start=="{");
        #Strip wrapper
        $json=substr($json,1);
        $json=substr($json,0,-1);
        while(strlen($json)){
            if($verbose)print("JSON:".$json."<br><br>");

            $key="";$val="";
            if($hash){#Get the key
                #We expect "key":"val" or "key":val or "key":"val with \"quote\""
                $s=substr($json,0,1);
                if($s!=="\""){if($verbose)echo "\n\nerror(1) parsing json:$json\n";return false;}#Error.
                $json=substr($json,1);#remove quote
                $q=findEndQuote($json);#find next unescaped double quote
                $key=substr($json,0,$q);
                $json=substr($json,$q+1);#trim key"
                #verify next char : and strip
                $s=substr($json,0,1);
                if($s!==":"){if($verbose)echo "\n\nerror(2) parsing json:$json\n";return false;}#Error.
                $json=substr($json,1);#remove :
                #var_dump($key);var_dump($json);exit;
            }
            #now get the value
            $s=substr($json,0,1);
            if($s==="\""){#quoted, extract the string
                $json=substr($json,1);#remove quote
                $q=findEndQuote($json);#find next unescaped double quote
                $val=substr($json,0,$q);
                $json=substr($json,$q+1);#trim val"
            }elseif($s==="{" || $s==="["){#See if the val is another obj or array
                $delim=($s=="{")?"}":"]";
                $c=strpos($json,$delim);#assume there's none embedded in a string val!

                //Broken!! on {}
                    $val=JSONToArray(substr($json,0,$c+1));
                    if($val===false){if($verbose)echo "\n\nerror(3) parsing json:".substr($json,0,$c+1)."\n";return false;}#Error.

                $json=substr($json,$c+1);
            }else{#number or bool
                $c=strposa($json,array(",","}","]"));
                if($c){
                    $val=substr($json,0,$c);
                    $json=substr($json,$c+1);
                }else {if($verbose)echo "\n\nerror(4) parsing json:$c is false for json:$json\n";return false;}#Error.
            }
            if($key)$arr[$key]=$val;
            else $arr[]=$val;
            #Remove comma
            if(strpos($json,",")===0)$json=substr($json,1);
        }
    }
#    var_dump($arr);
    return $arr;
}
function strposa($haystack, $needles=array(), $offset=0) {
    /*Find 1st of multiple needles*/
    $chr = array();
    foreach($needles as $needle) {
            $res = strpos($haystack, $needle, $offset);
            if ($res !== false) $chr[$needle] = $res;
    }

    if(empty($chr)) return false;
    return min($chr);
}
function findEndQuote($str){
    /*Returns the next un-escaped double quote position in string starting at index 0.*/
    $n=false;
    $s=str_split($str);
    $i=0;
    while($i<count($s)){
        if($s[$i]=="\\") $i++;#if escape char \, then skip and skip next one too.
        elseif($s[$i]=="\"")return $i;
        $i++;
    }
    return $n;
}

function appendToList($a,$b,$delim=","){//util to append comma when needed.
    if($a!=="" && $b!=="")return $a.$delim.$b;
    return $a.$b;
}
function appendToList2(&$list,$new,$delim=','){#MUCH better performance on large list because of pass by reference.
    #Use this instead of above:
    # appendToList2($list,$new,',');
	if($list!=='' && $new!=='')$list.=$delim.$new;
	else $list.=$new;
}
function boolstr($bool){
    #utility to convert boolean to js compatible string.  Returns the string if not a boolean val
    if($bool===true || $bool==='true' || $bool==='True' || $bool==='TRUE')return 'true';
    elseif($bool===false || $bool==='false' || $bool==='False' || $bool==='FALSE')return 'false';
    return "'$bool'";
}
/*Utility functions to generate common html objects from queries*/
#MARK HTML input wrappers
#Note; we plan to eventually add validation logic (client js) to these, so they are really kind of stubs.  Don't use if you add your own
#validation logic to it as it may cause conflicts when added here.

function getInputTR($prompt,$input,$class='',$mergeCols=false){
    #Uses default classes for input display and returns a full table row.  Use getXXXInput methods below for 2nd param.
    $class=($class)?"class='$class'":"";
    if($mergeCols)return "<tr $class><td align='left' colspan='2' class='label data3' style='text-align:left;'>${prompt}${input}</td></tr>";
    return "<tr $class><td class='label'>$prompt</td><td class='data3'>$input</td></tr>";
}
function getInputTDs($prompt,$input){
    #similar to above, no tr wrapper
    return "<td class='label'>$prompt</td><td class='data3'>$input</td>";
}
function getInputSpans($prompt,$input,$class='',$mergeCols=false){
    #similar to above, but returns spans
    $class=($class)?"class='$class'":"";
    if($mergeCols)return "<span $class><span align='left' class='label data3' style='text-align:left;'>${prompt}${input}</span></span>";
    return "<span $class><span class='label'>$prompt</span><span class='data3'>$input</span></span>";
}
function getHiddenInput($id,$val){
    #Returns basic hidden input
    return "<input type='hidden' name='$id' id='$id' value='$val'>";
}
function getFloatInput($id,$val,$size='5',$class='',$onChange='',$onFocus='',$readOnly=false){
    #returns input for a float.
    $class=($class)?"class='$class'":"";
    $onChange=($onChange)?"onchange=\"$onChange\"":"";
    $onFocus=($onFocus)?"onfocus=\"$onFocus\"":"";
    $ro=($readOnly)?"readonly":"";
    return "<input style='width:${size}ch;' $class type='text' name='$id' id='$id' size='$size' $onChange $onFocus $ro value='$val' >";#
}
function getSearchEveryThingBox(){
    /*Returns the Search Everything widget to be used on sidebar.
        Input is named searchTerm.  You need to hook into standard i_loadList() handler
        and do a side line search.  Optional if you want to include other present filters in sidebar,
        or just do a solo search with no other filters.
    */
    $searchTerm=getHTTPVar("searchTerm");
	$inp=getStringInput('searchTerm',$searchTerm,20,'','Search Everything Box');
    $html="<table><tr><td>$inp</td><td>".getSearchFormSubmit(false, false,'',false,'searchEverythingBtn')."</td></tr></table> <hr width='70%'></hr><br>
    <script>
        $('#searchTerm').focus();
        $('#searchEverythingBtn').click(function(){
            $('#searchTerm').focus();//reset focus when search done.
        });
    </script>";
    return $html;
}
function getFFloatInput($id,$val,$size='5',$class='',$onChange='',$readOnly=false){
    #returns input for a float that self formats.
    ###On change is overriden?
    $class=($class)?"class='$class'":"";
    $onChange="cleanNumber('$id');";
    $onChange=($onChange)?"onchange=\"$onChange\"":"";
    $ro=($readOnly)?"readonly":"";
    return "<input style='width:${size}ch;' $class type='text' name='$id' id='$id' size='$size' $onChange $ro value='$val' >";
}
function getIntInput($id,$val='',$size='4',$class='',$readOnly=false,$onChange=''){
    #returns input for an integer input.
    #onChange should include full js function with () and any parameters
    $class=($class)?"class='$class'":"";
    $ro=($readOnly)?"readonly":'';
    $onChange=($onChange)?"onchange=\"$onChange\"":"";

    return "<input style='width:${size}ch;' $class $ro type='text' name='$id' id='$id' value='$val' size='$size' $onChange>";
}
function getStringInput($id,$val,$size='12',$class='',$placeholder='',$onChange='',$readonly=false){
    #returns input for an string input
    #onChange should include full js function with () and any parameters
    $ro=($readonly)?"readonly":"";
    $class=($class)?"class='$class'":"";
    $onChange=($onChange)?"onchange=\"$onChange\"":"";
    return "<input style='width:${size}ch;' $class type='text' name='$id' id='$id' value='$val' size='$size' placeholder='$placeholder' $onChange $ro>";
}
function getTextAreaInput($id,$val,$rows='4',$cols='50',$class=''){
    #returns input for an text area input
    $class=($class)?"class='$class'":"";
    return "<textarea $class rows='$rows' cols='$cols' name='$id' id='$id'>$val</textarea>";
}

function getTimeInput($id,$val,$class='',$size='8',$onChange=''){
    #returns input for an time input.
    #Onchange can be a js function call like "setSampleWindowCheckBox()".
    $class=($class)?"class='$class'":"";
    if($onChange)$onChange="onchange=\"if(validate24HrTime('$id'))$onChange;\"";
    else $onChange="onchange=\"return  validate24HrTime('$id');\"";
    return "<input style='width:${size}ch;' $class type='text' name='$id' id='$id' value='$val' $onChange size='$size' placeholder='00:00:00'>";
}
function getTimeSelect($id,$val='',$class=''){#Val must be in format 00:00:00
    $a=array();
    for($h=0;$h<24;$h++){
        $h=str_pad($h,2,"0",STR_PAD_LEFT);
        $t="${h}:00";$t2="${h}:15";$t3="${h}:30";$t4="${h}:45";
        $a[]=array("key"=>$t.":00","value"=>$t);
        $a[]=array("key"=>$t2.":00","value"=>$t2);
        $a[]=array("key"=>$t3.":00","value"=>$t3);
        $a[]=array("key"=>$t4.":00","value"=>$t4);
    }
    return getAutoComplete($a,$id,$size=6,$val,"",$class);
}
function getDateTimeInput($id,$val,$size=20,$validate=true,$class='',$onChange=''){
    #Returns input for datetime
    return getDateInput($id,$val,$size,$validate,$class,$onChange,false,'yyyymmdd [hh:mm:ss]');
}
function getDateInput($id,$val,$size='12',$validate=false,$class='',$onChange='',$useDatePicker=false,$placeholder='yyyy-mm-dd'){#I'm not sure if this is used anywhere, but want to add validation logic without breaking things.  Hence optional.
    #returns input for an date input
    #
    if($useDatePicker){
        if($onChange && $validate)$onChange="onchange=\"if(validateDate('$id',true,-1))$onChange;\"";
        elseif($onChange)$onChange="onchange=\"$onChange\"";
        elseif($validate)$onChange="onchange=\"return  validateDate('$id',true,-1);\"";
        else $onChange='';
        #$onChange=($onChange)?"onchange=\"$onChange\"":"";
        $html="<input style='width:${size}ch;' class='$class' type='text' name='$id' id='$id' value='$val' size='$size' placeholder='$placeholder' $onChange autocomplete='off'>";
        $html.="<script>$('#${id}').datepicker({ dateFormat: 'yy-mm-dd' });</script>";
    }elseif($validate){
        if($onChange)$onChange="onchange=\"if(validateDate('$id',true,-1))$onChange;\"";
        else $onChange="onchange=\"return  validateDate('$id',true,-1);\"";

        $html="<input style='width:${size}ch;' class='$class' type='text' id='$id'  name='$id' value='$val' size='$size' $onChange placeholder='$placeholder'>";
    }else{
        $onChange=($onChange)?"onchange=\"$onChange\"":"";
        $html="<input style='width:${size}ch;' class='$class' type='text' name='$id' id='$id' value='$val' size='$size' placeholder='$placeholder' $onChange>";
    }
    return $html;
}

function getLabelDataTDs($label,$data){
    #returns 2 tds with class label and data
    return "<td class='label'>$label</td><td class='data'>$data</td>";
}
function getMultiSelectInput($a,$id,$selectedValues=array(),$onChangeFunc="",$addBlankRow=false,$maxWidth='175px',$disabled=false,$class='',$size=-10,$blankRowLabel=''){
    /*Returns html for a select input using the passed result set as options.  Allows for multiple selections and will load preselected array.
     *$selectedValues will be pre-selected if matched.
     *$a is a result set with 2 named cols; value, display_name
     *$id will be turned into an array on form submit; use getHTTPVar($id,array(),VAL_ARRAY) to fetch.  Note use type VAL_ARRAY_NE if addBlankRow=true so that an empty selection ('') isn't returned.
     *if optional group_name col exists, that will be used to group options.
     *if onchangefunc is passed, that js function will get called on change with $id passed as param.
     *If selectedValue is passed and $fireOnLoad=true, we'll fire the onchangefunc
     *If size>1 then select is displayed with that many rows.  If <1, then we dynamically size it upto that number of rows
     #If blankRowLabel, that's in the first row when addBlankRow
     */
    $js=($onChangeFunc && !($disabled))?"onchange=\"$onChangeFunc('$id');\"":"";
    $ro=($disabled)?"disabled":"";
    $class=($class)?"class='$class'":"";
    $selsize='';
    if($size>1)$selsize="size='$size'";
    if($size<1){
        $n=count($a);
        if($addBlankRow)$n++;
        $n=($n>abs($size))?abs($size):$n;
        $selsize="size='$n'";
    }
    $html="<select multiple $class id='${id}' name='${id}[]' style='max-width:$maxWidth;min-width:$maxWidth;' $js $ro $selsize>";


    if($a){
        $value="";$display_name="";$grpName="";$group_name="";$n=1;
        if($addBlankRow)$html.="<option value=''>$blankRowLabel</option>";
        foreach($a as $row){
            extract($row);
            if($group_name!=$grpName){
                $grpName=$group_name;
                $html.="<optgroup label='".htmlspecialchars($grpName)."'>";
            }
            $sel=(in_array($value,$selectedValues))?"selected":"";
            $html.="<option value='$value' $sel>$display_name</option>";
            $n++;
       }
    }else{$html.="<option value=''>None found</option>";}



    $html.="</select>";
    #if($selectedValue && $onChangeFunc && $fireOnLoad)$html.="<script language='JavaScript'>$onChangeFunc('$id');</script>";
    return $html;
}
function getSelectFromList($id,$list,$selected,$size=1,$onChange=''){
    #returns html select from comma separated list
    #onChangeFunc is full func including parameters
    $onChange=($onChange)?"onchange=\"$onChange\"":"";
    $a=explode(',', $list);
    $html="<select id='$id' name='$id' size='$size' $onChange>";
    foreach($a as $v){
        $sel=($selected==$v)?"selected":'';
        $html.="<option value='$v' $sel>$v</option>";
    }
    $html.="</select>";
    return $html;
}
function getSelectFromArray($id,$arr,$selected,$size=1,$onChange=''){
    #returns html select from an array of val=>display
    #onChangeFunc is full func including parameters
    $onChange=($onChange)?"onchange=\"$onChange\"":"";
    $html="<select id='$id' name='$id' size='$size' $onChange>";
    foreach($arr as $val=>$disp){
        $sel=($selected==$val)?"selected":'';
        $html.="<option value='$val' $sel>$disp</option>";
    }
    $html.="</select>";
    return $html;
}
function getSelect($a,$id,$selectedValue,$opts=array()){
    /*Wrapper for getSelectInput for optional opts
    *$a is a result set (from above) with 2 named cols; value, display_name
    #See doc for getSelectInput()
    */
    $fullOpts=array(
        "onChangeFunc"=>"",
        "addBlankRow"=>false,
        "maxWidth"=>'175px',
        "disabled"=>false,
        "fireOnLoad"=>false,
        "class"=>'',
        "size"=>1
    );
    foreach($opts as $key=>$val){$fullOpts[$key]=$val;}#Overwrite defaults
    extract($fullOpts);
    return getSelectInput($a,$id,$selectedValue,$onChangeFunc,$addBlankRow,$maxWidth,$disabled,$fireOnLoad,$class,$size);
}
function getSelectInput($a,$id ,$selectedValue,$onChangeFunc="" ,$addBlankRow=false,$maxWidth='175px', $disabled=false,$fireOnLoad=false,$class='',$size=1,$onChangeWhenDisabled=false){
    /*Returns html for a select input using the passed result set as options.
     *$selectedValue will be pre-selected if matched.  Pass '_first_' to select the first row.
     *use below getSelectInputOptions if you just want the options.
     *$a is a result set (from above) with 2 named cols; value, display_name
     *if optional group_name col exists, that will be used to group options.
     *$addBlankRow puts an empty value row at top of list.
     *if onchangefunc is passed, that js function will get called on change with $id passed as param. Fetch value in js func like grant_num=$('#'+id).val();
     *If selectedValue is passed and $fireOnLoad=true, we'll fire the onchangefunc
     *If size>1 then select is displayed with that many rows.  If <1, then we dynamically size it upto that number of rows
     #if onChangeWhenDisabled we set the onchange event when disabled. this seems safe to do regardless,but I'm not sure if
     #existing code depends on that behaviour and this is used all over so added as an override
     */
    $js=($onChangeFunc && (!($disabled)|| $onChangeWhenDisabled))?"onchange=\"$onChangeFunc('$id');\"":"";
    $ro=($disabled)?"disabled":"";
    $class=($class)?"class='$class'":"";
    $selsize='';
    if($size>1)$selsize="size='$size'";
    if($size<1){
        $n=count($a);
        if($addBlankRow)$n++;
        $n=($n>abs($size))?abs($size):$n;
        $selsize="size='$n'";
    }
    $html="<select $class id='$id' name='$id' style='max-width:$maxWidth;min-width:$maxWidth;' $js $ro $selsize autocomplete='off'>";
    $html.=getSelectInputOptions($a,$selectedValue,$addBlankRow);
    $html.="</select>";
    if($selectedValue && $onChangeFunc && $fireOnLoad)$html.="<script language='JavaScript'>$onChangeFunc('$id');</script>";
    return $html;
}
function getSelectInputOptions($a,$selectedValue,$addBlankRow=false){
    /*Returns the options for a select input using result set $a and preselecting selectedValue where appropriate.
     *$a is a result set (from above) with 2 named cols; value, display_name
     */
    $html="";
    #var_dump($selectedValue);
    if($a){
        $value="";$display_name="";$grpName="";$group_name="";$n=1;
        if($addBlankRow)$html.="<option value=''></option>";
        foreach($a as $row){
            extract($row);
            if($group_name!=$grpName){
                $grpName=$group_name;
                $html.="<optgroup label='".htmlspecialchars($grpName)."'>";
            }
            $sel=(($value==$selectedValue)||($n==1 && $selectedValue==='_first_'))?"selected":"";
            $html.="<option value='$value' $sel>$display_name</option>";
            $n++;
       }
    }else{$html.="<option value=''>None found</option>";}
    return $html;
}
function getCheckBoxInput($id,$display_text,$checked=false,$onChangeFunc="",$class=''){
    #puts all the normal items in their place
    $js=($onChangeFunc)?"onchange=\"$onChangeFunc('$id');\"":"";
    $ck=($checked)?"checked":"";
    $class=($class)?"class='$class'":"";
    $html="<label><input $class type='checkbox' value='1' id='$id' name='$id' $js $ck>$display_text</input></label>";
    return $html;
}
function getCheckBoxInputArray($a,$id,$onChangeFunc="",$checkAllButton=false){
    #Returns a table of checkboxes that will submit to a php array.
    #$a must have value and display_name columns, and optional 'selected' if the box is to be pre-selected
    #id is the html id and eventual php array name
    #$onChangeFunc (if passed) is called on change for each checkbox, passing the value
        #Note; $onChangeFunc wasn't tested yet (first case didn't need it). Once verified, remove this comment.
    #If $checkAllButton=true, a checkbox to autoselect/deselect all is included.
    $html="<table>";$selected=false;$value="";$display_name='';$chkAll="";$class="";
    $id=$id."[]";#Make a php array

    if($checkAllButton){#add some logic to enable a check/uncheck all button
        $classID=uniqid("checkbox");#Add a class so it's easy to select them all.
        $class="class='$classID'";
        $chkAll="<tr><td><hr width='25%'><label><input type='checkbox' id='${classID}_checkAll'/> Check all</label>
                <script language='JavaScript'>
                    $(\"#${classID}_checkAll\").change(function () {
                        $(\".${classID}\").prop('checked', $(this).prop(\"checked\"));
                    });
                </script>
                </td></tr>";
    }

    foreach($a as $row){
        extract($row);#if selected in result set it overrides above.
        $js=($onChangeFunc)?"onchange=\"$onChangeFunc('$value');\"":"";
        $ck=($selected)?"checked":"";
        $html.="<tr><td><label><input $class type='checkbox' value='$value'  name='$id' $js $ck> $display_name</input></label></td></tr>";#note removed id='$id' (bad syntax) jwm. 1/1/18
    }

    $html.="$chkAll</table>";

    return $html;
}
function getRadioBtnInputs($id,$buttons,$selectedBtn,$class='',$dir='horz'){
    /**
     *$id is input name (id isn't actually used)
     *$buttons is an array[value]='label'
     *  like this:
     *  $buttons[1]='option 1'
     *  Probably shouldn't use 0 as a value.
     *$selectedBtn is $buttons value(index) of selected button
     *$dir is either horz or vert
     #ex:
     $mode=getRadioBtnInputs('db_view_mode', array('1'=>'Tabular','2'=>'Summary'), 2, 'search_form_auto_submit');
     $mode=getHTTPVar("db_view_mode",false,VAL_INT);
     js: var val=$('input[name=gf_calc_method]:checked', '#gnt2_yrtotal_form').val();
     **/
    $html="";
    $class=($class)?"class='$class'":"";
    foreach($buttons as $val=>$label){
        $checked=($val==$selectedBtn)?"checked":"";
        $html.="<label><input $class type='radio' value='$val' $checked name='$id'>$label</input></label>";
        if($dir=='vert')$html.="<br>";
    }
    return $html;
}
/*MARK Auto complete widget*/

function getAutoComplete($a,$id,$size=28,$selectedValue="",$onChangeFunction="",$class=''){
    #Returns the html & js for a popup autocomplete controller for a db lookup table.
    #that allows similar functionality to a select widget (user selects text, but key is stored/submitted value), but using an autocomplete widget
    #It also allows different display/selected values (label vs value), which allows for ex
    #full site name in the popup, but only site code as the selected text with site num as the submitted value.

    #$a is standard return obj from doquery() with 3 colums:
    #   key col is the primary key for the table/row (eg site_num).  This is what gets sent on form submit
    #   value col is what will get put in the displayed input once a user selects an item (eg site.code)
    #   label (optional) col is what shows up on the popup list(eg Mauna Loa...).  If not provided, then value is displayed in both.


    #(note these names come from jquery widget)

    #$id is the id of the input
    #size is the width of display field.
    #You can specify an on change function (js) to call.  $id is passed to it.
    #$selectedValue will get preselected.

    #2 html fields are created, a hidden input with $id name/id that will contain the key value from a selection and a
    # $id_display field that will show the display value.will be the input id/name element and will get set with the 'key' column in below js method.

    #You can set the selected value/display by calling js function setAutoCompleteValue(id,key) (blank '' key to clear.).
    #See sftp://omi (mund)/var/www/html/inc/dbutils/dbutils.js for documentation.

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
    $html="";
    $changeJS=($onChangeFunction)?"$onChangeFunction('$id');":"";
    #$changeJS.=($class=='search_form_auto_submit')?"i_loadList();":"";
    $sel=($selectedValue)?"setAutoCompleteValue('${id}','$selectedValue')":"";
    $html.="
            <span class='data ui-widget'>
                <input class='popup_with_id ' id='".$id."_display' size='$size'>
                <input type='hidden' class='$class' value='' id='$id' name='$id'>";
    $html.="    <script language='JavaScript'>".getAutocompleteWidgetJSArray($a,$id)."
                            $(\"#".$id."_display\").autocomplete({
                                source: ".$id."_data,
                                delay:100,
                                minLength: 0,
                                autoFocus: false,
                                change: function(event,ui){
                                    var inp=$('#${id}');
                                    var display=$(\"#".$id."_display\");
                                    if (ui.item) {
                                        inp.val(ui.item['key']);
                                    }else{
                                        //Not a valid entry (user typed and tabbed out without selecting a real value).
                                        //Clear both display and key field
                                        inp.val('');
                                        display.val('');
                                        $changeJS //Fire any change event when data cleared.  We'll call similar on selection below
                                    }
                                    console.log('change:'+inp.val());
                                },
                                response: function(event,ui){
                                    $('#${id}').val('');//Wipe the stored key when user does anything to initiate a new search so they are in sync.
                                    //This is mostly an issue if the user selects an entry (stored below) then backspaces and deletes the display which then doesn't
                                    //force a change event because we never left focus.  I tried doing blur() but that caused issues above because ui was no longer available.
                                },
                                select: function(event,ui){//Menu item selected.  Set value
                                    var inp=$('#${id}');
                                    var display=$(\"#".$id."_display\");
                                    if (ui.item) {
                                        inp.val(ui.item['key']);
                                        console.log('select:'+inp.val());
                                        $changeJS
                                    }
                                },
                            });
                            //Note this focus event is on the display input, not the autocomplete, which has a focus event for when a menu item is selected.
                            $(\"#".$id."_display\").on( 'focus', function( event, ui ) {
                                    //Clear the variables and display list
                                    var inp=$('#${id}');
                                    var display=$(\"#".$id."_display\");
                                    inp.val('');
                                    display.val('');
                                    $(this).autocomplete( 'search', '' );
                                }
                            );
                            $sel
                </script>
            </span>";

    return $html;
}
function getAutocompleteWidgetJSArray($a,$id){
    #Returns the requested popup's data in js format for use in the initial page load
    #$popup is the form id for the popup.
    #Returned data is in an array specially formatted for the jQuery ui autocomplete widget
    #and will be named $popup_data;
    #key col is the primary key for the table
    #value col is what will get put in the displayed input once a user selects an item
    #label (optional) col is what shows up on the popup list.
    #See getAutoComplete() above for details.

    $data="";

    foreach($a as $row){
        if(key_exists('label',$row)){
            $label=str_replace('"','',$row['label']);#Filter out any quotes if present as that'll mess up the js syntax.
            $data=appendToList($data,"{ label: \"$label\", value:\"".$row['value']."\", key:\"".$row['key']."\"}");
        }else{
            $data=appendToList($data,"{ value:\"".$row['value']."\", key:\"".$row['key']."\"}");
        }
    }

    $data="var ".$id."_data = [".$data."];";
    return "$data\n";
}
#MARK JS & Links- help, js, buttons, download, print, color picker...
function getHelpTextLink($helpText,$linkText='?',$width=''){
    $help="<div class='title5'>$helpText</div>";
    return getPopUp($help,$linkText,"Help",$width,false);
}
function getJSIsChecked($id){
    /*Javascript.  returns jquery selector/bool for checkbox to see if checked.
    Because I have to look up everytime.*/
    return "$('#${id}').prop('checked')";
}
function getJSTimestamp($dt,$UTCLDate=false,$pad=0){
    /*Return a unix timestamp suitable for passing to js new Date(x) obj. 0 (1970) on error.
    //NOTE UTCLDate not being used (8/22), found an option in dygraph to use utc all the way through.  Leaving in for now for reference.  pia.
    If $UTCLDate, this returns a js funciton call that returns a js date object by calling a function to create the date (the new Date() part) and adds the tz offset so that when javascript converts it to local tz, it will look like UTC.  Note the time will
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
function addHREF($a,$colname,$urlBase,$target='_new'){
    /*Add an anchor href link using column as a query parameter.
    this is useful for linking an id to another site to search (like google scholar) because
    it will encode the id field being linked.
    example:
        col is a doi: 10.15138/wkgj-f215
        bldsql_col("doi as 'DataCite'");
        ...
        $a=doquery();
        $a=addHREF($a,'DataCite','https://commons.datacite.org/doi.org?query=','_dc');
    This adds hyperlink with specified target and passes in doi.
    */
    if($a){
        $arr=arrayFromCol($a,$colname);#returns a copy of the col as array
        if($arr){
            foreach($arr as $i=>$str){

                $a[$i][$colname]="<a href='$urlBase".urlencode($str)."' target='$target'>$str</a>";#set back into src obj
            }
        }
    }
    return $a;
}
function getJSButton($id,$action,$label,$param1="",$param2="",$confirmationText="",$class='',$title='',$delayed=false){
    /*Returns a fully formed button with js click action.
     *$action is the js function to call (no parens).
     *$param1/2 are optional.  No convienent way to pass '' at this time.
     *$label is the button text
     *if $confirmationText is passed, we'll do a confirm with a ok/cancel button first
     *$class  is optional css class
     *if $delayed, then we wrap function in a setTimeout (see delayedJS() for comments)
     *ex: $addbtn=getJSButton('db_summary_addbtn','loadNetworkStatusItem','Add Item',0);
     */
    $action.="(";
    if($param1)$action.="'$param1'";
    if($param2)$action.=",'$param2'";
    $action.=");";
    if($delayed)$action=delayedJS($action);
    $action=($confirmationText)?"if(confirm('".htmlentities($confirmationText)."')){$action}":"$action";

    $js="<script language='JavaScript'>
            $(\"#$id\").click(function(event){
                event.preventDefault();
                $action
            });</script>";
    $button="<button id='$id' class='$class' title='$title'>$label</button>$js";
    return $button;
}
function getJSLink($id,$action,$text,$class='',$title=''){
    #Returns url hyperlink that calls js $action on click (like button above).
    #$action is just passed through, so can be js or a js function
    if(!$id)$id=uniqid();
    $title=($title)?"title='$title'":'';
    $class=($class)?"class='$class'":'';
    $html="<a href='' id='$id' $class $title>$text</a>
    <script language='JavaScript'>
        $('#$id').click(function(event){
            event.preventDefault();
            $action
        });
    </script>
    ";
    return $html;
}
function getSaveButton($jsAction,$id='',$altText='Save'){
	#Returns a save button with little disk img.  Assumes dbutils path of /inc/dbutils...  Was too much of a pain to ensure path set in all callers otherwise.
	#if no id passed, we generate one.
    #Note; i didn't end up using this because I needed it to open a popup form.  Not sure if this image works everywhere..  check icp_funcs_filters->icp_getFilterSetSelectWidget() for current implementation.
	if(!$id)$id=uniqid();
	$saveBtn=getJSButton($id,$jsAction,"<img src='/inc/dbutils/template/resources/save_sm.png' title='$altText' alt='$altText' height='20' width='20'>","","","","savebtn",$altText);
	return $saveBtn;
}
function copyToClipBoardJS($displayText,$copyText,$confirmText='Text copied'){
    /*Provides button that copies text to user's clipboard.*/
    $uid=uniqid('js_');
    $confirm=($confirmText)?"alert('$confirmText');":"";
    $html="<button style='cursor: pointer;' id='cp_$uid' onclick='copyToClipboard_${uid}()'>$displayText</button>
    <script>
    function copyToClipboard_${uid}() {
        var inputc = document.body.appendChild(document.createElement('input'));
        inputc.value = \"$copyText\";
        inputc.focus();
        inputc.select();
        document.execCommand('copy');
        inputc.parentNode.removeChild(inputc);
        $confirm
    }
    </script>";
    return $html;
}
function copyToClipBoardURLJS($displayText,$copyText,$confirmText='Text copied'){
    $action="var inputc = document.body.appendChild(document.createElement('input'));
        inputc.value = \"$copyText\";
        inputc.focus();
        inputc.select();
        document.execCommand('copy');
        inputc.parentNode.removeChild(inputc);
        alert('$confirmText');";
    $js=getJSLink(uniqid(),$action,$displayText);
    return $js;
}
function downloadCSVLink2($text='CSV',$switchFunction='',$parameters='',$class='',$includeSearchForm=True){
    /*Returns html/js for download link for current selection.
    Must have a switch.php dowhat of downloadCSV that builds query and passes to downloadCSV().
    */
    $uid=uniqid('i_');
    if(!$switchFunction)$switchFunction="downloadCSV";
    $class=($class)?"class='$class'":'';
    $html="<a id='$uid' href='switch.php?doWhat=${switchFunction}&${parameters}' $class>$text</a>";
    $js=($includeSearchForm)?"<script language='JavaScript'>
            $('#${uid}').click(function(){
                i_setCSVLinkHref('$uid','${switchFunction}&${parameters}');
            });
            </script>":"";
    return $html.$js;
}
function downloadCSVLink($text='CSV',$switchFunction='downloadCSV',$class='search_form_auto_submit'){
    /*USE above.  Need to migrate and make call compat, but didn't have time to try and test...
    Returns html/js for download link for current selection.  Must have a switch.php dowhat of downloadCSV that builds query and passes to downloadCSV()

    NOTE doesn't work on autocomplete.. need to fix.*/
    $html="Download <a id='dbutils_downloadSelection' href='switch.php?doWhat=$switchFunction'>$text</a>

            <script language='JavaScript'>
                function dbutils_setCSVLinkHref(){
                    var formData=$('#search_form').serialize();//Grab current filters
                    var _href='switch.php?doWhat=$switchFunction&'+formData;
                    console.log(_href);
                    $('#dbutils_downloadSelection').attr('href',_href);
                }
                //Set up the link whenever the form changes.  Other handlers submit the form.
                $('#search_form').on('change','.$class', function(){
                    dbutils_setCSVLinkHref();
                });
                //Call once to set initally.
                dbutils_setCSVLinkHref();

            </script>";
    return $html;
}
function saveDivButton($label,$divID,$filename,$showSaveButtonImage=true){
    /*Returns a save button that will make an image of passed div and prompt to save to disk.  Doesn't work with ie.*/
    if(!$showSaveButtonImage)$b=getJSButton("${divID}_sb_saveBtn","${divID}_sb_html2canvas","$label");
    else $b=getSaveButton("${divID}_sb_html2canvas","${divID}_sb_saveBtn",$label);
    $a="<a id='${divID}_sb_downLoadLink' href='' style='display:none;' download='$filename'>$label</a>";
    $js="<script language='JavaScript'>
        function ${divID}_sb_html2canvas(){
            html2canvas($('#${divID}').get(0)).then(function(canvas) {
                var a=document.getElementById('${divID}_sb_downLoadLink');
                a.href=canvas.toDataURL('image/png');
                a.click();
            });
        }</script>";
    return $b.$a.$js;
}
function printDivButton($label,$divID,$showPrintButtonImage=true){
    /*Returns a print button that will make an image of passed div and open print dialog.  Note; requires popup*/
    if($showPrintButtonImage)
        $b=getJSButton("${divID}_pb_printBtn","${divID}_pb_html2canvas","<img src='/inc/dbutils/template/resources/print.png' title='$label' alt='$label' height='20' width='20'>","","","","savebtn",$label);
    else $b=getJSButton("${divID}_pb_printBtn","${divID}_pb_html2canvas","$label");
    $js="<script>
        function ${divID}_pb_html2canvas(){
            html2canvas($('#${divID}').get(0)).then(function(canvas) {
                var a=document.getElementById('${divID}_pb_downLoadLink');
                var img=canvas.toDataURL('image/png');
                var html='<html><head><title></title></head><body style=\"width:100%;padding:0;margin:0;\"';
                html+=' onload=\"window.focus();window.print();window.close();\"><img src=\"'+img+'\"/></body></html>';
                var printWindow=window.open(\"\",'to_print','height=600,width=800');//data:text/html;charset=utf-8,\"+html
                printWindow.document.open();
                printWindow.document.write(html);
                printWindow.document.close();
            });
        }</script>";
    return $b.$js;
}
function getProgressBar($value=0,$id='',$max=100,$color='',$height='10px',$class='',$title=''){
    if($id=='')$id="progress_bar_".rand();
    $class=($class)?"class='$class'":'';
    $title=($title)?"title='$title'":'';
    $color=($color)?"setJQueryUIProgressBarColor('$id','$color');":'';
    $html="<div id='$id' name='$id' $class style='height:$height;max-height:$height;' $title></div>
    <script>
        $('#${id}').progressbar({value:$value, max:$max}); $color
    </script>";
    return $html;
}
function delayedJS($func,$msDelay=100) {
    /*Run arbitrary js function on delay (so current execution cycle completes).  This is mostly needed
    so an ajax submit can fully complete before it fires off a reload or similar.)
    $func can be any arbitrary js code.
    ex $func: "ord_loadProduct($product_num);"
    */
    return "setTimeout(function(){ $func },$msDelay)";
}
function selfClearingMssg($msg,$divID,$secs=2){
    #show msg in divID for $secs then clear
    $secs=$secs*1000;
    $js="<script>
            \$('#${divID}').html('$msg');
            setTimeout(function(){
                \$('#${divID}').html('');
            },$secs);
        </script>";
    return $js;
}

function getColorPicker($id,$color="#f00",$class='',$onChange=''){
    #Returns a color picker with initial color set to $color
    $onChange=($onChange)?"change: function(color){ ${onChange}; },":"";
    $html="<input size='6' class='$class' name='$id' id='$id' />
    <script language='JavaScript'>
        $('#$id').spectrum({
            color: \"$color\",
            showInitial:true,
            preferredFormat: 'hex',
            showInput:false,
            showInitial:true,
            $onChange
            palette: [ ],showPalette:true,showSelectionPalette:true,maxSelectionSize:8,selectionPalette: ['red', 'green', 'blue','purple','#f335e5']
            });
    </script>";#

    return $html;
}
function get_tooltip($linkText,$popupText,$url='#',$html=False,$target='',$delay=1200,$duration=0,$effect='none'){
    /*Returns a href with nice tooltip.  popuptext can be html
    If url='#' (default), it's a no-op link.
    I thought html was working, but having trouble getting it to render universally at the moment.  Seems wonky.  Showing brw description blows up.
    pass $target='_blank' to open in new window/tab
    */
    $uid=uniqid('tlt__');#$popupText=htmlentities($popupText);
    if(!$html){$popupText=strip_tags($popupText); }
    $popupText=str_replace("\n", '', $popupText);
    $html="<a href='$url' id='$uid' target='$target' title=''>$linkText</a>
    <script>$('#${uid}').tooltip({content: \"$popupText\",show: { effect: '$effect', delay: $delay, duration: $duration }});</script>";
    return $html;
}
function hideLongText($text,$displayLenthChars=200,$linktext='...more',$textClass='data'){
    /*truncates text at displayLengthChars, appends linktext with a popup to show all.
    Should work for html, but probably will get all messed up (tags truncated).
    We'll truncate at last word prior to max to make it look better...
    DIDN'T end up using, so free to alter.  Wasn't quite right.  Switched to jquery ui accordian*/
    $html='';$link='';
    if($text){
        $shorttext=substr($text,0,$displayLenthChars);
        if($shorttext!=$text){
            $shorttext=strip_tags($shorttext);
            $i=strrpos($shorttext,' ');#last space
            if(!$i)$i=strlen($shorttext);
            $shorttext=substr($text,0,$i);
            $link=getPopup($text,$linktext,'News Item', '',false);#get_tooltip($linktext,$text);
        }
        $html="<span class='$textClass'>$shorttext $link</span>";
    }#var_dump($html);
    return $html;
}
#MARK Navigation - radio button, tabbed list
function tabbedList($data=array('label'=>'<h3>Content</h3>')){//Horizontal tabs using jquery ui
    $html="";$i=1;$list="";$divs="";
    $id=uniqid("tabs_");
    foreach ($data as $label=>$content){
        $list.="<li><a href='#${id}_tab_$i'>$label</a></li>";
        $divs.="<div id='${id}_tab_$i'>$content</div>";
        $i++;
    }
    $list="<ul>$list</ul>";
    $divs="<div id='$id'>$list $divs</div>";
    $js='<script>$("#'.$id.'" ).tabs();</script>';
    $html=$divs.$js;
    return $html;
}
function getSideTabs($tabs,$height,$selected=1,$onSelJS=''){
    #Returns side tab widget.  Rolled my own because above jquery ui side tabs were wonky.
    #tabs is an array('tab label'=>'tab content');
    #height is fully specified: '100px'.  percentages don't seem to work.
    #selected is default selected tab
    #onSelJS is arbitrary js to run after tab switched.  You can use this to fix floating table header like this:
    #   $('#outputDataTable').floatThead('reflow'); for instance.
    #   in scope variable n contains the tab number if you want tab specific action:
    #   'if(n==1){$("#outputStatsTable").floatThead("reflow");}
    $uid=uniqid();$html="";$tabLabels='';$tabContents='';$i=1;
    foreach($tabs as $key=>$data){
        $tabLabels.="<tr><td class='vertical_tab_label_${uid} vertical_tabLabels_unsel' id='${uid}_L_${i}'>$key</td></tr>";
        $tabContents.="<div width='100%' align='left' valign='top' class='vertical_tab_content_${uid}' id='${uid}_C_${i}'>$data</div>";
        $i++;
    }
    $labels="<table class='vertical_tabLabels'>$tabLabels</table>";
    $html="<table border='1' class='thinTable' width='100%'><tr><td valign='top'>$labels</td><td width='100%'><div class='scrolling' style='height:$height;width:100%;'>$tabContents</div></td></tr></table>";

    $js="<script>
        $('.vertical_tab_label_${uid}').click(function(event){
            event.preventDefault();
            var n=this.id.split('_')[2];
            setVerticalTabSelected('$uid',n);//defined in dbutils/dbutils.js
            $onSelJS
        });
        setVerticalTabSelected('$uid',$selected);
    </script>";

    return $html.$js;
}
function radioButtonNav($destDiv,$buttons,$selectedBtn=0){
    /*Returns a radio button like navigation menu that uses the switch.php/dowhat mechinism to load content dynamically.  Must
     *have switch dowhat actions programmed already.  Note this uses gets (not posts) so shouldn't be used to submit a form.
     *
     *$destDiv is where content will be loaded
     *$buttons is an array of arrays, each sub array is for 1 button and must contain label, doWhat, parameters
     *  like this:
     *  $buttons[]=array('label'=>'button1label','doWhat'=>'loadBtnOneContent','parameters'=>'num=256&id=2');
     *$selectedBtn is $buttons index of selected button, -1 for none.
     *
     */
     $uid=uniqid('rbn_');
     #build up the button display
     $b='';$js="var ${uid}_handle;";
     foreach($buttons as $i=>$button){
        extract($button);#label, doWhat and parameters
        $class=($i==$selectedBtn)?"selectedNavButton":"unSelectedNavButton";
        $b.="<td><button id='${uid}_btn_${i}' class='$class ${uid}_buttons navBtn'>$label</button></td>";
        $js.="
        $(\"#${uid}_btn_${i}\").click(function(){
            $(\".${uid}_buttons\").removeClass(\"navBtn_selected\");
            $(this).addClass(\"navBtn_selected\");
            ajax_get('$doWhat','$parameters','$destDiv',${uid}_handle);
        });";
     }
     if($selectedBtn >= 0)$js.="$(\"#${uid}_btn_${selectedBtn}\").click();";
     $html="
     <div>
        <table  class='navBtn_table'>
            <tr>
                $b
            </tr>
        </table>
        <script language='JavaScript'>$js</script>
     </div>
     ";
    return $html;
}
function radioButtonJS($buttons,$selectedBtn=0){
    /*Returns a radio button like navigation menu that calls passed js functions
     *
     *$buttons is an array of arrays, each sub array is for 1 button and must contain label, js
     *  like this:
     *  $buttons[]=array('label'=>'button1label','js'=>'jsFunction()');
     *$selectedBtn is $buttons index of selected button, -1 for none.
     *
     */
     $uid=uniqid('rbn_');
     #build up the button display
     $b='';$js="var ${uid}_handle;";
     foreach($buttons as $i=>$button){
        extract($button);#label, doWhat and parameters
        $class=($i==$selectedBtn)?"selectedNavButton":"unSelectedNavButton";
        $b.="<td><button id='${uid}_btn_${i}' class='$class ${uid}_buttons navBtn'>$label</button></td>";
        $js.="
        $(\"#${uid}_btn_${i}\").click(function(){
            $(\".${uid}_buttons\").removeClass(\"navBtn_selected\");
            $(this).addClass(\"navBtn_selected\");
            $js;
        });";
     }
     if($selectedBtn >= 0)$js.="$(\"#${uid}_btn_${selectedBtn}\").click();";
     $html="
     <div>
        <table  class='navBtn_table'>
            <tr>
                $b
            </tr>
        </table>
        <script language='JavaScript'>$js</script>
     </div>
     ";
    return $html;
}



#MARK DIVs- self loading, hiding
function selfLoadingDiv($doWhat,$parameters,$width='100%',$height='100%',$delayed=false,$loadingText='Loading...'){
    /*Returns html for an asyncronous self loading div using the switch mechinism.  Dowhat must be handled there.
     *parameters are in standard 'get' format: param1=val1[&param2=val2...]
     *width and height can either be % or px (ie '300px')
     *if $delayed, load pauses until current exec finishes. see delayedJS for details.
     **/
    $uid=uniqid('sld');
    $get="ajax_get('$doWhat','$parameters','$uid',plotHandle,'$loadingText');";
    if($delayed)$get=delayedJS($get);
    $div="<div id='$uid' style='width:$width;height:$height'></div>
        <script language='JavaScript' >var plotHandle;$get</script>";
    return $div;
}
function getHidingDiv($divHTML,$showText,$hideText,$labelClass='title4',$appendArrows=true,$effect='blind',$extraJS=''){
    #Returns js/html to display $showText and hidden $divHTML (below).  When clicked, $divhtml is un-hidden and $hideText is displayed.
    #Appends html arrows to label if $appendArrows
    #If hide text is '', then no hide option is allowed.
    #can pass extrajs to run on click (function call like "myJS()")
    #THIS should be refactored to call below toggleJquerySelector?
    $uid=uniqid();
    $showID="html_show_$uid";
    $hideID="html_hide_$uid";
    $ua=($appendArrows)?"&uarr;":'';
    $da=($appendArrows)?"&darr;":'';
    $displayID="html_display_$uid";
    $js=($extraJS)?"$extraJS;":"";
    $effect=($effect)?"'$effect'":"";
    $hideText=($hideText)?"<div id='${hideID}_div' class='$labelClass'><a href='_new' id='${hideID}_link'>$hideText $ua</a></div>":"";
    $html="<div id='${displayID}_htmlDiv' style='border:thin inset silver;'>$divHTML</div>
    <div id='${showID}_div' class='$labelClass'><a href='_new' id='${showID}_link'>$showText $da</a></div>$hideText

    <script language='JavaScript'>
        //js vodoo.
        $(\"#${displayID}_htmlDiv\").hide();
        $('#${showID}_link').show();
        $('#${hideID}_link').hide();
        $('#${showID}_link').click(function(event){
            event.preventDefault();
            $(\"#${displayID}_htmlDiv\").show($effect);
            $('#${showID}_link').hide();
            $('#${hideID}_link').show();
            $js
        });
        $('#${hideID}_link').click(function(event){
            event.preventDefault();
            $(\"#${displayID}_htmlDiv\").hide($effect);
            $('#${showID}_link').show();
            $('#${hideID}_link').hide();
            $js
        });
    </script>
    ";

    return $html;
}

function toggleJquerySelector($sel,$showText,$hideText,$labelClass='',$effect='blind',$showOnLoad=False){
    #js to show/hide a div (or any jquery selector).  Pass the full selector.
    #for an id it's like "#myid" for a class like ".myclass"
    $uid=uniqid();
    $showID="html_show_$uid";
    $hideID="html_hide_$uid";
    $effect=($effect)?"'$effect'":"";
    $showText="<span id='${showID}_div' class='$labelClass'><a href='_blank' id='${showID}_link'>$showText</a></span>";
    $hideText="<span id='${hideID}_div' class='$labelClass'><a href='_blank' id='${hideID}_link'>$hideText</a></span>";
    $html=$showText.$hideText;
    if($showOnLoad){
        $s="
            $(\"$sel\").show();
            $('#${showID}_link').hide();
            $('#${hideID}_link').show();
        ";
    }else{
        $s="
            $(\"$sel\").hide();
            $('#${showID}_link').show();
            $('#${hideID}_link').hide();
        ";
    }
    $html.="<script>
        $('#${showID}_link').hide();
        $('#${hideID}_link').show();
        $('#${showID}_link').click(function(event){
            event.preventDefault();
            $(\"$sel\").show($effect);
            $('#${showID}_link').hide();
            $('#${hideID}_link').show();
        });
        $('#${hideID}_link').click(function(event){
            event.preventDefault();
            $(\"$sel\").hide($effect);
            $('#${showID}_link').show();
            $('#${hideID}_link').hide();
        });
        $s
    </script>";
    return $html;
}


/*MARK prebuilt selects & inputs*/
function getInstSelect($selectedValue='',$id='inst', $wrapInTR=true, $class='search_form_auto_submit',$onChange='',$label='Inst',$program_num=false){
    #Returns a standard inst select widget
    bldsql_init();
    bldsql_from("ccgg.flask_data");
    bldsql_distinct();
    bldsql_col("inst as 'value'");
    bldsql_col("inst as 'display_name'");
    if($program_num)bldsql_where("program_num=?",$program_num);
    bldsql_orderby("inst");
    $sel=getSelectInput(doquery(),$id,$selectedValue,'',true,'100px',false,false,$class);
    if($wrapInTR)$sel="<tr><td class='label'>$label</td><td>$sel</td></tr>";
    return $sel;
}
function getSystemSelect($selectedValue='',$id='system', $wrapInTR=true, $class='search_form_auto_submit',$onChange='',$label='System'){
    #Returns a standard system select widget
    #!!performs badly.  needs index or summary table.
    bldsql_init();
    bldsql_from("ccgg.flask_data");
    bldsql_distinct();
    bldsql_col("system as 'value'");
    bldsql_col("system as 'display_name'");
    bldsql_orderby("system");
    bldsql_where("system is not null");
    bldsql_where("system!=''");
    $sel=getSelectInput(doquery(),$id,$selectedValue,'',true,'100px',false,false,$class);
    if($wrapInTR)$sel="<tr><td class='label'>$label</td><td>$sel</td></tr>";
    return $sel;
}
function getParameterSelect($selectedValue='',$id='parameter_num',$wrapInTR=true,$class='search_form_auto_submit',$onChange='',$prompt='',$program_num=''){
    #Returns a standard parameter autoComplete select widget
    if(!$prompt)$prompt="Parameter";
    bldsql_init();
    bldsql_distinct();
    bldsql_from("gmd.parameter p");
    bldsql_from("ccgg.data_summary s");
    bldsql_where("p.num=s.parameter_num");
    if($program_num)bldsql_where("s.program_num=?",$program_num);
    bldsql_distinct();
    bldsql_col("p.num as 'key'");
    bldsql_col("p.formula as 'value'");
    bldsql_col("concat('(',p.formula,') ',p.name,' ',p.unit) as label");
    bldsql_orderby("case when p.num<=8 then p.num else 9 end,p.formula");
    $sel=getAutoComplete(doquery(),$id,6,$selectedValue,$onChange,$class);
    if($wrapInTR)$sel="<tr><td class='label'>$prompt</td><td>$sel</td></tr>";
    return $sel;
}
function getMultiParameterSelect($selectedValues=array(),$program='',$id='parameter_nums',$wrapInTR=true,$class='search_form_auto_submit',$size='-10',$onChange='',$selectFirst=False){
    #Returns multi select parameter list.
    #program can be  ccgg hats arl sil curl, id changes to [program]_parameter_nums if default parameter_nums is passed for id.
    #if selectFirst, we select the first parameter
    $program_num='';
    if($program)$program_num=doquery("select num from gmd.program where abbr=?",0,array($program));
    if($program && $id=='parameter_nums')$id=strtolower($program)."_parameter_nums";
    bldsql_init();
    bldsql_distinct();
    bldsql_from("gmd.parameter p");
    bldsql_from("ccgg.data_summary s");
    bldsql_where("p.num=s.parameter_num");
    #if($program_num==1)bldsql_where("p.num<=6");#limit ccgg to main six (no wind);
    if($program_num)bldsql_where("s.program_num=?",$program_num);
    bldsql_distinct();
    bldsql_col("p.num as 'value'");
    bldsql_col("p.formula as 'display_name'");
    #bldsql_col("concat('(',p.formula,') ',p.name,' ',p.unit) as display_name");
    bldsql_orderby("case when p.num<=8 then p.num else 9 end,p.formula");
    $a=doquery();
    if(!$selectedValues && $selectFirst && $a)$selectedValues=array($a[0]['value']);
    $sel=getMultiSelectInput($a,$id,$selectedValues,$onChange,false,'175px',false,$class,$size);
    $label=($program)?strtoupper($program)." Parameters":"Parameters";
    if($wrapInTR)$sel="<tr><td class='label'>$label</td><td>$sel</td></tr>";
    return $sel;
}
function getStrategySelect($selectedValue='',$id='strategy_num',$wrapInTR=true,$limitToFlask=false,$class='search_form_auto_submit',$size=1,$addBlank=true,$onChange=''){
    #Returns a standard strategy select widget
    bldsql_init();
    bldsql_distinct();
    bldsql_from("ccgg.strategy");
    bldsql_col("num as 'value'");
    bldsql_col("abbr as 'display_name'");
    if($limitToFlask)bldsql_where("num in (1,2)");
    $sel=getSelectInput(doquery(),$id,$selectedValue,$onChange,$addBlank,'80px',false,false,$class,$size);
    if($wrapInTR)$sel="<tr><td class='label'>Strategy</td><td>$sel</td></tr>";
    return $sel;
}
function getProjectSelect($selectedValue='',$id='project_num',$wrapInTR=true,$limitToFlask=false,$class='search_form_auto_submit',$size=1,$addBlank=true,$onChange=''){
    #Returns a standard project select widget
    bldsql_init();
    bldsql_distinct();
    bldsql_from("ccgg.project");
    bldsql_col("num as 'value'");
    bldsql_col("abbr as 'display_name'");
    if($limitToFlask)bldsql_where("num in (1,2)");
    $sel=getSelectInput(doquery(),$id,$selectedValue,$onChange,$addBlank,'125px',false,false,$class,$size);
    if($wrapInTR)$sel="<tr><td class='label'>Project</td><td>$sel</td></tr>";
    return $sel;
}
function getGMDProjectSelect($selectedValue='',$id='project_num',$program_nums=array(1),$wrapInTR=true,$class='search_form_auto_submit',$size=1,$addBlank=true,$onChange=''){
    #Returns a standard project select widget from gmd.project
    #program_nums is a array of programs to filter
    bldsql_init();
    bldsql_distinct();
    bldsql_from("gmd.project");
    bldsql_col("num as 'value'");
    bldsql_col("abbr as 'display_name'");
    if($program_nums)bldsql_wherein("program_num in ",$program_nums);
    $sel=getSelectInput(doquery(),$id,$selectedValue,$onChange,$addBlank,'125px',false,false,$class,$size);
    if($wrapInTR)$sel="<tr><td class='label'>Project</td><td>$sel</td></tr>";
    return $sel;
}
function getProgramSelect($selectedValue='',$id='program_num',$wrapInTR=true,$class='search_form_auto_submit'){
    #Returns a standard program select widget
    bldsql_init();
    bldsql_distinct();
    bldsql_from("gmd.program p");
    bldsql_from("ccgg.data_summary s");
    bldsql_col("p.num as 'value'");
    bldsql_col("p.abbr as 'display_name'");#limit to ones in our data.
    bldsql_where("p.num=s.program_num");
    bldsql_distinct();
    $sel=getSelectInput(doquery(),$id,$selectedValue,'',true,'80px',false,false,$class);
    if($wrapInTR)$sel="<tr><td class='label'>Program</td><td>$sel</td></tr>";
    return $sel;
}
function getSiteSelect($selectedValue='',$id='site_num',$wrapInTR=true,$class='search_form_auto_submit',$onChange='',$prompt='Site',$autoComplete=True, $limitToCCGG=true){
    #Returns a standard site autoComplete select widget
    bldsql_init();
    bldsql_distinct();
    bldsql_from("gmd.site p");
    if($limitToCCGG){
        bldsql_from("ccgg.data_summary s");
        bldsql_where("p.num=s.site_num");
    }
    bldsql_orderby("p.code");
    if($autoComplete){
        bldsql_col("p.num as 'key'");
        bldsql_col("p.code as 'value'");
        bldsql_col("concat('(',p.code,') ',p.name) as label");
        $sel=getAutoComplete(doquery(),$id,5,$selectedValue,$onChange,$class);
    }else{
        bldsql_col("p.num as 'value'");
        bldsql_col("p.code as 'display_name'");
        $sel=getSelectInput(doquery(),$id,$selectedValue, '', true, '50px', false, false, $class);
    }
    if($wrapInTR)$sel="<tr><td class='label'>$prompt</td><td>$sel</td></tr>";
    return $sel;
}
function getEvDateRange($start_val='',$end_val='',$dateClass='',$labelClass='',$prompt='Event date range:'){
    #Returns ev_start_date and ev_end_date inputs in a tr
    #pass dateClass='search_form_auto_submit' if wanting auto
    #labelClass='label' to make bold.. not sure why this one was different, but no idea where else being used, so defaulting to off
    $s=getDateInput('ev_start_date',$start_val,12,true,$dateClass);
    $e=getDateInput('ev_end_date',$end_val,12,true,$dateClass);
    $html="<tr><td colspan='2' align='left' class='$labelClass' style='text-align:left'>$prompt</td></tr>
    <tr><td colspan='2'>$s to $e</td></tr>";
    return $html;
}
function getEvDateScroll($selectedInterval='month', $selectedN=1, $submit=true){
    /*Returns a i_loadList forward/back buttons. If submit then we do standard i_loadList submit.
    Only works if there is a ev_start_date entered.  This sets both ev_date fields.
    */
    $opts=array("hour"=>"hour(s)","day"=>"day(s)","week"=>"week(s)","month"=>"month(s)","year"=>"year(s)");

    $intervalSel=getSelectFromArray('ev_scroll_interval',$opts,$selectedInterval);
    $period=getIntInput('ev_scroll_interval_n',$selectedN,'2');
    $bbtn=getJSButton('ev_scroll_back','scroll_ev_date','&larr;','-1');
    $fbtn=getJSButton('ev_scroll_for','scroll_ev_date','&rarr;','1');
    $html="<span>Scroll by: $period $intervalSel $bbtn $fbtn</span>";
    //Including dynamically for now.  I'm not sure I'm comfortable using prototype concept. Can probably move to outside js script for cacheing and wider use. jwm- 2/23
    $html.="<script>
        //Credit Jacobi (https://stackoverflow.com/users/1689133/jacobi) for date addition logic (https://stackoverflow.com/a/22515961).
        Date.prototype.j_addHours = function(hours) {
          this.setHours(this.getHours() + hours);
          return this;
        };

        Date.prototype.j_addDays = function(days) {
          this.setDate(this.getDate() + days);
          return this;
        };

        Date.prototype.j_addWeeks = function(weeks) {
          this.j_addDays(weeks*7);
          return this;
        };

        Date.prototype.j_addMonths = function (months) {
          var dt = this.getDate();
          this.setMonth(this.getMonth() + months);
          var currDt = this.getDate();
          if (dt !== currDt) {
            this.j_addDays(-currDt);
          }
          return this;
        };

        Date.prototype.j_addYears = function(years) {
          var dt = this.getDate();
          this.setFullYear(this.getFullYear() + years);
          var currDt = this.getDate();
          if (dt !== currDt) {
            this.j_addDays(-currDt);
          }
          return this;
        };
        Date.prototype.j_addInterval = function(interval,n){
            if(interval=='hour'){this.j_addHours(n);}
            else if(interval=='day'){this.j_addDays(n);}
            else if(interval=='week'){this.j_addWeeks(n);}
            else if(interval=='month'){this.j_addMonths(n);}
            else if(interval=='year'){this.j_addYears(n);}
            return this;
        }
        function scroll_ev_date(dir){
            var interval=$('#ev_scroll_interval').val();
            var n=$('#ev_scroll_interval_n').val();
            var sd_t=$('#ev_start_date').val();
            var ed_t=$('#ev_end_date').val();
            var ed='';

            if(sd_t && n>0 && interval!=''){
                var sd=new Date($('#ev_start_date').val());
                if(ed_t==''){
                    ed=new Date(sd.getTime());//deep copy
                    if(dir<1){//set start -n
                        sd.j_addInterval(interval,dir*n);
                    }else{//just set end to +n
                        ed.j_addInterval(interval,dir*n);
                    }
                }else{
                    //See if ed already set to next interval
                    ed=new Date(ed_t);
                    var t=new Date(sd.getTime());//Deep copy date obj

                    t.j_addInterval(interval,1*n);//temp var with target interval end for current start.
                    if(ed.getTime()==t.getTime()){//Already set once, scroll to next.  Otherwise we'll leave at current and just set the ed
                        sd.j_addInterval(interval,dir*n);
                    }
                    ed=new Date(sd.getTime());ed.j_addInterval(interval,1*n);//Either next period or on first, start to end of interval

                }
                //Set new dates back into form and submit.
                //console.log(sd);console.log(ed);
                $('#ev_start_date').val(vd_createDateString(sd,'ymd')+' '+vd_createTimeString(sd,'24hms'));
                $('#ev_end_date').val(vd_createDateString(ed,'ymd')+' '+vd_createTimeString(ed,'24hms'));
                i_loadList();//Submit with new dates
            }else{alert('Enter a start date to scroll from');}
        }
    </script>";
    return $html;
}
function getADateRange($start_val='',$end_val=''){
    #Returns a_start_date and a_end_date inputs in a tr
    $s=getDateInput('a_start_date',$start_val,12,true);
    $e=getDateInput('a_end_date',$end_val,12,true);
    $html="<tr><td colspan='2' align='left'>Anal. date range:</td></tr>
    <tr><td colspan='2'>$s to $e</td></tr>";
    return $html;
}
function getAltRange($min_val='',$max_val='',$class='search_form_auto_submit',$extraText=''){
    #Returns alt_min and alt_max inputs in a tr
    $s=getIntInput('alt_min',$min_val,4,$class);
    $e=getIntInput('alt_max',$max_val,4,$class);
    $html="<tr><td colspan='2' align='left'>Altitude range:</td></tr>
    <tr><td colspan='2'>$s to $e $extraText</td></tr>";
    return $html;
}
function getLatRange($min_val='',$max_val='',$class='search_form_auto_submit',$extraText=''){
    #Returns alt_min and alt_max inputs in a tr
    $s=getIntInput('lat_min',$min_val,4,$class);
    $e=getIntInput('lat_max',$max_val,4,$class);
    $html="<tr><td colspan='2' align='left'>Latitude range:</td></tr>
    <tr><td colspan='2'>$s to $e $extraText</td></tr>";
    return $html;
}
function getLonRange($min_val='',$max_val='',$class='search_form_auto_submit',$extraText=''){
    #Returns alt_min and alt_max inputs in a tr
    $s=getIntInput('lon_min',$min_val,4,$class);
    $e=getIntInput('lon_max',$max_val,4,$class);
    $html="<tr><td colspan='2' align='left'>Longitude range:</td></tr>
    <tr><td colspan='2'>$s to $e $extraText</td></tr>";
    return $html;
}
function getMethodSelect($selectedValue='', $prompt='Method', $useAbbrs=true, $id='method',$wrapInTR=true, $class='search_form_auto_submit', $size=1,$addBlank=true){
    #Returns a standard method code select widget
    $width=($useAbbrs)?"35ch":"5ch";
    bldsql_init();
    bldsql_distinct();
    bldsql_from("ccgg.flask_method");
    bldsql_col("method as 'value'");
    if($useAbbrs)
        bldsql_col("case when abbr is not null then concat(method,'-',abbr) else method end as 'display_name'");
    else bldsql_col("method as display_name");
    $sel=getSelectInput(doquery(),$id,$selectedValue,'',$addBlank,$width,false,false,$class,$size);
    if($wrapInTR)$sel="<tr><td class='label'>$prompt</td><td>$sel</td></tr>";
    return $sel;
}
function getStandardFilterParams(){
    #Fetches, cleans and puts into an array all above standard filters
    #use extract($a); to put  into namespace.
    $a=array();
    $a['ev_start_date']=getHTTPVar("ev_start_date",'',VAL_DATE);
    $a['ev_end_date']=getHTTPVar("ev_end_date",'',VAL_DATE);
    $a['a_start_date']=getHTTPVar("a_start_date",'',VAL_DATE);
    $a['a_end_date']=getHTTPVar("a_end_date",'',VAL_DATE);
    $a['site_num']=getHTTPVar("site_num",'',VAL_INT);
    $a['program_num']=getHTTPVar("program_num",'',VAL_INT);
    $a['project_num']=getHTTPVar("project_num",'',VAL_INT);
    $a['strategy_num']=getHTTPVar("strategy_num",'',VAL_INT);
    $a['parameter_num']=getHTTPVar("parameter_num",'',VAL_INT);
    $a['parameter_nums']=getHTTPVar("parameter_nums",array(),VAL_ARRAY);
    $a['ccgg_parameter_nums']=getHTTPVar("ccgg_parameter_nums",array(),VAL_ARRAY);
    $a['hats_parameter_nums']=getHTTPVar("hats_parameter_nums",array(),VAL_ARRAY);
    $a['sil_parameter_nums']=getHTTPVar("sil_parameter_nums",array(),VAL_ARRAY);
    $a['arl_parameter_nums']=getHTTPVar("arl_parameter_nums",array(),VAL_ARRAY);
    $a['curl_parameter_nums']=getHTTPVar("curl_parameter_nums",array(),VAL_ARRAY);
    $a['alt_min']=getHTTPVar("alt_min",false,VAL_INT);
    $a['alt_max']=getHTTPVar("alt_max",false,VAL_INT);
    $a['inst']=getHTTPVar("inst");
    $a['lat_min']=getHTTPVar("lat_min",false,VAL_FLOAT);
    $a['lat_max']=getHTTPVar("lat_max",false,VAL_FLOAT);
    $a['lon_min']=getHTTPVar("lon_min",false,VAL_FLOAT);
    $a['lon_max']=getHTTPVar("lon_max",false,VAL_FLOAT);
    $a['system']=getHTTPVar("system");
    $a['method']=getHTTPVar("method");
    return $a;
}
function ital($txt,$size='sm'){
    #returns txt in a span for sm or tiny ital.
    return "<span class='${size}_ital'>$txt</span>";
}
function send_email($to,$subject,$body,$attachment){
//Simple unix mail sender..  nothing fancy, assumes mail set up on server.  Probably won't work outside of noaa.
//Body should be simple text
    $tmpfname = tempnam("/tmp", "FOO");
    $handle = fopen($tmpfname, "w");
    fwrite($handle, $body);
    fclose($handle);
    $a=($attachment)?"-a $attachment":"";
    $cmd="cat $tmpfname | mail -s '$subject' $a $to";
    #var_dump($cmd);
    #$cmd=escapeshellcmd($cmd);#messed up pipe
    $result=shell_exec($cmd);
    unlink($tmpfname);

    #$result.="| $to $subject $body $cmd";#dbg
    return $result;

}
function getSearchFormSubmit($refresh=False,$trWrapper=True,$label='',$alignRight=false,$id=''){
    #standard search submit button for the left side search form
    #refresh=true if you want a little circular arrow refresh button for
    #forms that dynamically submit
    if(!$label)$label=($refresh)?"<img src='/inc/dbutils/images/refresh.png' width='12' height='12'/>":"Search";
    $title=($refresh)?"Reload search":"Submit search";
    if(!$id)$id=($refresh)?"refreshBtn":"searchFormBtn";
    $but=getJSButton($id,'i_loadList',$label,'','','','',$title);
    $align=($alignRight)?"align='right'":'';
    if($trWrapper) return "<tr><td></td><td $align>".$but."</td></tr>";
    else return $but;
}
function getRefreshButton($trWrapper=false,$url='index.php',$text=''){
    #Button to reload index.php or passed url.
    #If no text, then we use a refresh image
    $label=($text)?$text:"<img src='/inc/dbutils/images/refresh.png' width='12' height='12'/>";
    $title="Reload";
    $id="refreshBtn";
    $but="<a href='$url'>$label</a>";
    if($trWrapper) return "<tr><td></td><td>".$but."</td></tr>";
    else return $but;
}

if (!function_exists('split')) {/*Removed in php7.  Adding shim for compatibility.*/
    function split($pattern, $string, $limit = -1) {
        $regex = '/' . str_replace('/', '\/', $pattern) . '/';
        return preg_split($regex, $string, $limit);
    }
}
function strContains($haystack,$needle,$caseinsensitive=True){
    #Returns true if haystack contains needle.  There is a php8 builtin for this
    if($caseinsensitive)return (stripos($haystack,$needle)!==False);
    else return (strpos($haystack,$needle)!==False);
}
function highlightSearch($a,$searchTerm){
    /*Applies highlightSearchPhrase() to all values in $a.  See below.*/
    if($searchTerm=='')return $a;
    $b=array();
    foreach($a as $row){
       $nrow=array();
       foreach($row as $key=>$value){
            $nr[$key]=highlightSearchPhrase($value,$searchTerm);
       }
       $b[]=$nr;
    }
    return $b;
}
function highlightSearchPhrase($text, $phrase, $highlightClass = 'textHighlight') {
    #does a case insensitive find of phrase and highlights, maintaining case.
      $pos = stripos($text, $phrase); // Case-insensitive search for the position of the phrase in the text
      if ($pos !== false) { // If the phrase is found in the text
        $before = substr($text, 0, $pos); // Get the text before the phrase
        $matched = substr($text, $pos, strlen($phrase)); // Get the matched phrase
        $after = substr($text, $pos + strlen($phrase)); // Get the text after the phrase

        // Highlight the matched phrase while maintaining capitalization
    #    $highlighted = '<span class="'.$highlightClass.'">' . substr($matched, 0, 1) . '</span>' . substr($matched, 1);
        $highlighted = "<span class='$highlightClass'>$matched</span>";

        // Recursively call the function on the text after the phrase to find and highlight any additional occurrences
        $after_highlighted = highlightSearchPhrase($after, $phrase);

        // Return the highlighted text
        return $before . $highlighted . $after_highlighted;
      }
      else { // If the phrase is not found in the text
        return $text; // Return the original text
      }
}

function setTitleJS($title){
    #Returns javascript block to set the web page title from ajax html.
    return "<script>document.title=$title;</script>";

}


















?>
