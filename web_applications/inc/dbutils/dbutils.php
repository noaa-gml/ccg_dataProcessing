<?php

if(! defined("BS_LIB_BEING_USED") || BS_LIB_BEING_USED==FALSE){#BS_ templates will load their own html utilities.
    require_once("dbutils_resultsOutput.php");
    require_once("dbutils_htmlUtilities.php");
}

/*This is a set of general db interaction utilities.  There are 2 main tools;
 *  -The bldsql_* query builder
 *      The bldsql builder can be used with public functions below once this file is included, or through the class interface if desired.
 *      You can build select, insert and update queries and it supports binding parameters
 *      Start any new query with bldsql_init();
 *      See below for details
 *  -doquery for selects(), doinsert() and doupdate().
 *      They can be used as class memebers or with the public functions below.
 *      These methods accept a string sql query to run or will use the above bldsql_ by default
 *      See comments on each for details
 *
 *
 *To Use:
 #include this file and make connection:  Can set config data in default file, pass file
 #or pass credentials.  At top of page:
    require_once("./dbutils.php");
    db_connect();

#and for printTable support (not required) in the html <head> section:
    echo get_dbutilsHeaderIncludes($dbutilsDirPath);


 Ex:

    bldsql_init();
    bldsql_from("gmd.site s");
    bldsql_where("upper(s.code) like ?","A%");
    bldsql_col("num");
    bldsql_col("name");
    bldsql_col("code");

    $a=doquery();
    if($a){
        foreach($a as $row){
            print_r($row);
        }
    }
    or:
    echo printTable(doquery());

Ex2:
    doquery("create temporary table temp (id int, name char(4))");
    bldsql_init();
    bldsql_insert("temp");
    bldsql_set("id=?","1");
    bldsql_set("name=?","asdf");

    doinsert();

    #insert another:
    bldsql_set("id=?","3");
    bldsql_set("name=?","thre");
    doinsert();

    #reset and update
    bldsql_init();
    bldsql_update("temp");
    bldsql_set("id=?","2");
    bldsql_set("name=?","sdf");
    bldsql_where("id=?","1");
    $a=doupdate();
    if($a)...

 *
 */


class dbutils{

    private $dbh; //Database handle
    private $user;
    private $password;
    private $host;
    private $database;
    private $errorMode;
    private $errorLog;
    private $dmlLog;
    private $auth_user_name;#This is the httpd based auth (if present)
    private $checkCCGGUserID;#whether to chk ccgg.contact for user
    private $auth_ccggContact_userID;#If httpd access auth and user is in ccgg.contact, this is the num.
    private $user_table;
    private $user_enabled;
    private $user_can_insert;
    private $user_can_edit;
    private $user_can_delete;

    private $bldsql_froms;
    private $bldsql_joins;
    private $bldsql_wheres;
    private $bldsql_cols;
    private $bldsql_distinct;
    private $bldsql_groupbys;
    private $bldsql_havings;
    private $bldsql_orderbys;
    private $bldsql_unions;
    private $bldsql_limit;
    private $bldsql_stmt;
    private $bldsql_setParameters;
    private $bldsql_parameters;
    private $bldsql_sets;
    private $bldsql_updateTable;
    private $bldsql_insertTable;
    private $bldsql_insertSelect;
    private $bldsql_intoTable;
    private $bldsql_intoTableIndex;

    private $debugLogFile;

    function __construct($configfile="dbutils_config.php",$user="",$password="",$host="",$database="",$errorLog="",$errorMode='exception') {

        /*To use db functions, you must either set connection info from configfile or pass in.
         *If passed dbutils_config.php (default), a ro connection is provided.
         *You can pass blank for non-db (bldsql_*) functionality.
         *
         *Config file must contain these variables:
         *  $dbutils_database = "";
         *  $dbutils_host = "";
         *  $dbutils_user = "";
         *  $dbutils_password = "";
         *
         *Optional
         *  $dbutils_error_log="";#If set then errors will be written to log file, if empty, then echo'd to screen.
         *  $dbutils_errorMode = "";#silent or exception (default)
         *  $dbutils_dml_log="";#If set then any insert/updates/deletes will get logged into this file.
         *  $dbutils_lookUpCCGGUser = true; #Defaults to true.  Looks up ccgg.contact user (if there) and sets into auth_ccggContact_userID for some callers.  Pass false to skip (if db user doesn't have read access to ccgg).  use db_getAuthUserID() to retrieve.
         *
         *  This part is super optional.  An attempt to have generic reusable authentication logic...
         *  $dbu_user_table="";#If set, then table must have contact_num, can_delete, can_edit, can_insert, enabled.
         *      contact_num joins to ccgg.contact.  ccgg.contact abbr column, by convention, is the user's nems login name which must match
         *      the php_auth_user (assumes using htaccess or mellon cac).
         *  -update- unfortunately, this was immeadiately insufficient granularity and the required granularity (for data tagger)
         *  is too complex to do genericly, so it's done in the application layer.  I left all the logic in because it's all been tested and
         *  could be used on future project if desired.
         20221129- using on atleast 1 project now (drierhist).  Note, the addedittable used with getPopUpForm_dyn will handle without further action, although could be enhanced to disable buttons when appropriate

         *
         *  Note there is a class implementation (this) as well as a functional implementation that does not require passing around an
         *  object.  See methods at the bottom of this file.
         *
         *  Note log directory permissions should be set to other: x only (like 771).
         *  log files should be set to other w only (like 662).
         */
        $dbu_dml_log="";$dbu_user_table="";$dbutils_errorLog="";$dmlLog="";$user_table="";$dbutils_lookUpCCGGUser=true; $dbutils_dml_log='';

        //Set the user name.  We'll use this for logging and if authentication is configured ($dbu_user_table), to get auth info.
        $u='unauthenticated user';
        if(isset($_SERVER['MELLON_uid']) && $_SERVER['MELLON_uid'])$u=$_SERVER['MELLON_uid'];
        else if(isset($_SERVER['REMOTE_USER']) && $_SERVER['REMOTE_USER']) $u=$_SERVER['REMOTE_USER'];
        else if(isset($_SERVER['PHP_AUTH_USER']) && $_SERVER['PHP_AUTH_USER']) $u=$_SERVER['PHP_AUTH_USER'];
        #if(strpos($u,"@")){#server head returns full email in auth mellon, so strip out end part to  normalize with ldap remote_user
        #actually, mellon_uid is the one I was looking for..
        #    $u=substr($u,0,strpos($u,"@"));
        #}
        $this->auth_user_name=$u;
        #echo "u:".$this->auth_user_name;

        if($configfile){
            if($configfile=="dbutils_config.php"){
                $d = dirname( __FILE__);
                $configfile="$d/$configfile";
            }

            if(file_exists($configfile)){
                include("$configfile");

                $user=$dbutils_user;
                $password=$dbutils_password;
                $host=$dbutils_host;
                $database=$dbutils_database;
                $errorLog=$dbutils_errorLog;
                $errorMode=$dbutils_errorMode;
                $dmlLog=$dbu_dml_log;
                if(!$dmlLog)$dmlLog=$dbutils_dml_log;#annoying mis labeling in comments/some configs and dbu_dml_log var... I will eventuallytrack down where it might have been used either way and fix them all up, but for now just using either to set...jwm 3/20
                $user_table=$dbu_user_table;
            }

        }

        $this->host=$host;
        $this->user=$user;
        $this->password=$password;
        $this->database=$database;
        $this->errorLog=$errorLog;
        $this->errorMode=$errorMode;
        $this->checkCCGGUserID=$dbutils_lookUpCCGGUser;

        $this->dbh=false;
        //$this->errorLog=$errorLog;
        $this->dmlLog=$dmlLog;
        $this->user_table=$user_table;
        #Default perms to allow all.  If authentication is configured, these will get set below.
        #Note, this is application layer security, subject to permissions granted via the database user
        $this->user_can_insert=true;
        $this->user_can_edit=true;
        $this->user_can_delete=true;
        $this->user_enabled=true;
        $this->auth_ccggContact_userID="";
        $this->debugLogFile="";
        #$this->debugLogFile="log/debugSQL.txt";#If set, this logs all queries to file.
        $this->debugLog();
        $this->logUsage();
        $this->bldsql_init();
        return $this;
    }
    function db_connect(){
        #Attempt login
        if($this->host && $this->user){
            try{
                $dsn="mysql:host=".$this->host.";dbname=".$this->database;
                $this->dbh=new PDO($dsn, $this->user,$this->password);
                $errorMode=($this->errorMode=="silent")?PDO::ERRMODE_SILENT:PDO::ERRMODE_EXCEPTION;
                $this->dbh->setAttribute( PDO::ATTR_ERRMODE, $errorMode );
                #var_dump($this->user);
                #if($this->user=='fin_trac_user')var_dump($this->dbh);
                #var_dump($this->checkCCGGUserID);
                if($this->checkCCGGUserID){
                    #get the user id if available.  This is used by some callers (datatag) to do custom security access.
                    #This could probably be cached in the $_session var (future proj).
                    bldsql_init();
                    bldsql_from("ccgg.contact");
                    bldsql_col("num");
                    bldsql_where("abbr=?",$this->auth_user_name);
                    $a=doquery();
                    if($a){$this->auth_ccggContact_userID=$a[0]['num'];}

                    if($this->user_table){
                        #Authentication is configured for this site.  Default to no permissions and do a lookup
                        #in the provided user table to see what the user's permissions are (if any).  Note; library is hardcoded
                        #to use ccgg.contact as a master subset list of all authenticated noaa users.
                        $can_insert=false;$can_edit=false;$can_delete=false;
                        bldsql_init();
                        bldsql_from($this->user_table." u");
                        bldsql_from("ccgg.contact c");
                        bldsql_where("c.num=u.contact_num");
                        bldsql_col("u.can_insert");
                        bldsql_col("u.can_edit");
                        bldsql_col("u.can_delete");
                        bldsql_col("u.contact_num");
                        bldsql_where("u.enabled=1");
                        bldsql_where("c.abbr=?",$this->auth_user_name);
                        $a=doquery();
                        #echo $this->bldsql_printableQuery();
                        $this->user_enabled=false;#Note we have to falsify this after doing the query (otherwise it can't run).

                        if($a){
                            extract($a[0]);
                            $this->user_can_insert=$can_insert;
                            $this->user_can_edit=$can_edit;
                            $this->user_can_delete=$can_delete;
                            $this->user_enabled=true;
                        }
                        #If we couldn't match an enabled user exit now.
                        if(!$this->user_enabled){
                            $html="<html><head></head><body><i>Sorry, you do not have permissions to access this site.</i></body></html>";
                            unset($this->dbh);
                            echo $html;
                            exit();
                        }
                    }
                }

            }catch(PDOException $e){
                #var_dump($e);
                $this->showError($e->getMessage());
            }

        }
    }
    function setDebugLogFile($file){
        $this->debugLogFile=$file;
        $this->debugLog(date('Y-m-d H:i:s').": Starting query logging.");
    }
    function isDemoServer(){
        /*Returns true if currently logged into a demo server (mund_dev or test).  This is so you
         *can print some visual cue to the user
         */
        return ($this->database=="mund_dev" || $this->database=="test");
    }

    #User permissions
    function userEnabled(){return ($this->user_enabled);}
    function userCanInsert(){return ($this->user_can_insert);}
    function userCanEdit(){return ($this->user_can_edit);}
    function userCanDelete(){return ($this->user_can_delete);}
    function getAuthUser(){return $this->auth_user_name;}
    function setAuthUser($user){$this->auth_user_name=$user;}//For logging if basic auth not used.
    function getAuthUserID(){return $this->auth_ccggContact_userID;}

    function doquery($sql="",$numRows=-1,$parameters=array()){
        if(!$this->userEnabled())return false;
        /*
         *This is used to issue a select query.
         *Returns an array of assoc row arrays,, empty array if no results and false on error
         *If $sql is passed "", this will call bldsql_cmd() to get the query && bldsql_parameters to get the params.
         *If $numRows=0, this returns the first value of the first row (convienence), false on no results
         *$parameters can contain bindparamers for the query.  They must be in same order as "?" in the query.
         *-1 for all, false for dml statement (like drop table.)
         *In general, if using the bldsql_* you don't need to pass any params to this.
         */
        $logQuery=$sql;
        $this->errorMssg="";#reset last error
        if($sql==""){
            $sql=$this->bldsql_cmd();
            $parameters=$this->bldsql_parameters;
            $logQuery=$this->bldsql_printableQuery();#this includes params
        }
        $this->debugLog($logQuery);#When logging, do it prior to actual call (and potential errors).

        if($this->dbh !== false){
            $a=false;
            $result=false;
            try{
                #Run the query
                $sth=$this->dbh->prepare($sql);
                if($sth){
                    if(count($parameters)){
                        $result=$sth->execute($parameters);
                    }else{
                        $result=$sth->execute();
                    }

                    if($result){
                        if($numRows===false)return $result;#DML statements have no result sets
                        elseif($numRows==0){
                            $sth->setFetchMode(PDO::FETCH_NUM);
                            $a=$sth->fetchall();
                            if(count($a)>0)
                                return $a[0][0];
                            else #jwm - 2/20/20 .  cleaned up no result logic (was just passing through, then returning empty array)
                                return false;
                        }else{
                            $sth->setFetchMode(PDO::FETCH_ASSOC);
                            $a=$sth->fetchall();
                            return $a;
                        }
                    }
                }
            }catch(PDOException $e){

                    $this->showError($e->getMessage());
                    return false;
            }
            return false;


        }else{
            $msg = "Error: database connection information not set.";
            $this->showError($msg);
            exit;
        }
    }
    function beginTransaction(){
        #Turns off autocommit and begins tran
        #table must support it too (no myisam)
        $this->dbh->beginTransaction();
        $this->logDML("Begin transaction");
    }
    function rollbackTransaction(){
        #Rolls back tran started with above
        $this->dbh->rollBack();
        $this->logDML("Rolling back transaction.  Entries since begin transaction have been undone.");
    }
    function commitTransaction(){
        #commits above tran
        $this->dbh->commit();
        $this->logDML("Commit transaction");
    }
    function doinsert($sql="",$parameters=array()){
        if(!$this->userEnabled() || !$this->userCanInsert())return false;
        /*Similar to doquery, this uses bldsql_ if $sql and parameters aren't passed.
         *Returns the last inserted id (for autoincrement cols) or false on error.
         *If no auto increment col in insert, It returns true so it's safe
         *to do:
         *if(doinsert()){...success}
         *
         **/
        return $this->runquery($sql,$parameters,0);
    }
    function doinsertSelect($sql="",$parameters=array()){
        if(!$this->userEnabled() || !$this->userCanInsert())return false;
        /*Similar to doinsert, but this does a insert [bldsql_insert table] select ...
         *This uses bldsql_ if $sql and parameters aren't passed.
         *Returns number of inserted rows or false
         *
         **/
        $this->bldsql_insertSelect=true;#set flag for cmd builder.
        return $this->runquery($sql,$parameters,1);
    }
    function doupdate($sql="",$parameters=array()){
        if(!$this->userEnabled() || !$this->userCanEdit())return false;
        /*Similar to doquery, this uses bldsql_ if $sql and parameters aren't passed.
         *Returns the number of affected rows (might be 0).
         *To check for success:
         *if(doupdate()!==false){...success}
         *
         **/
        return $this->runquery($sql,$parameters,1);
    }
    function doselectinto($sql=""){/*use with bldsql_into.  drops into tmp table and creates a new one with select stmt.*/
        if(!$this->userEnabled())return false;#Note we don't check for canInsert as this is only going into a temp table (which is likely being used for a select)
        /*Ditto above.  Returns number of inserted rows or false*/
        if($this->bldsql_intoTable){
            $this->doquery("drop temporary table if exists ".$this->bldsql_intoTable,false);
            return $this->runquery($sql,array(),1,true);
        }else{
            var_dump("Error: no into table");
            exit;
        }
    }
    function dodml($sql){
        //for running dml statements like drop table, create index...
        //equivalent to doquery($sql,false);
        //uses bldsql query if none passed.
        #$this->dbh->setAttribute(PDO::MYSQL_ATTR_MULTI_STATEMENTS, true);
        $ret=$this->doquery($sql,false);
        #$this->dbh->setAttribute(PDO::MYSQL_ATTR_MULTI_STATEMENTS, false);
        return $ret;
    }

    /*bldsql_ family of functions for query building*/

    function bldsql_init(){
        /*Use to initialize or reset the query builder.  Must be called at beggining of each new query.*/
        $this->bldsql_froms=array();
        $this->bldsql_joins=array();
        $this->bldsql_wheres=array();
        $this->bldsql_cols=array();
        $this->bldsql_distinct="";
        $this->bldsql_groupbys=array();
        $this->bldsql_havings=array();
        $this->bldsql_orderbys=array();
        $this->bldsql_unions=array();
        $this->bldsql_limit="";
        $this->bldsql_stmt=false;
        $this->bldsql_parameters=array();
        $this->bldsql_setParameters=array();
        $this->bldsql_sets=array();
        $this->bldsql_updateTable="";
        $this->bldsql_insertTable="";
        $this->bldsql_insertSelect=false;
        $this->bldsql_intoTable="";
        $this->bldsql_intoTableIndex="";
    }
    function bldsql_col($col){
        /*Can be just the col or with an alias ("col as 'name'")
        Duplicates are ignored.  If using with doquery, col names (or alais) will become the assoc array keys.
        */
        if(in_array($col,$this->bldsql_cols)==false)$this->bldsql_cols[]=$col;
    }
    function bldsql_set($col,$val){
        /*For use in insert/update statements;
         *Pass 'col name=?' and the unquoted value to set it to.
         *Bind parameters will be used to replace the ?
         *This can be called repeatedly to update the binded parameter value so that the statement can be
         *re-used on inserts/updates.  Build the query, do first insert/update,
         *call this with new param and do insert/upate, rinse repeat
         *Note if this is going to be a lot of inserts, it'd be worth writing a multiinsert method to take advantage
         *of a prepared statemnt.
         *#NOTE, null values are not actually supported by current inplementation see runquery for comments.
         */
        $i=array_search($col,$this->bldsql_sets,true);
        $val=($val==="null"||$val==="NULL")?null:$val;
        if($i!==false){
            $this->bldsql_setParameters[$i]=$val;
        }else{
            $this->bldsql_sets[]="$col";
            $this->bldsql_setParameters[]=$val;
        }

    }

    function bldsql_update($table){#use with bldsql_set
        $this->bldsql_updateTable=$table;
    }
    function bldsql_insert($table){#use with bldsql_set and doinsert for 1 row or with doinsertSelect for ++
        $this->bldsql_insertTable=$table;
    }
    function bldsql_into($table,$index=''){
        #Index can be passed to be created on new table like:
        #'index_name (col1,col2)' or 'i(site_num)'

        $this->bldsql_intoTable=$table;
        $this->bldsql_intoTableIndex=$index;
    }
    function bldsql_from($table){
        /*Dups ignored.  Can pass left join as one $table (ie: "table1 t1 left join table2 t2 on t1.num=t2.num")
         */
        if(in_array($table,$this->bldsql_froms)==false)$this->bldsql_froms[]=$table;
    }
    function bldsql_join($table,$on,$joinType=''){
        /*Build a join clause without having to pass whole thing in above.  Let's you use joins
        for whole query instead of mixing.
        $table; table name, $on; on clause conditions (don't pass 'on'), $joinType; '' for straight, 'left'/'right'
        Must pass base table using bldsql_from above. Must pass in desired order.
        ex:
        bldsql_from("ccgg.flask_event e");
        bldsql_join("ccgg.flask_data d","e.num=d.event_num");
        bldsql_join("ccgg.flask_event_detail d","e.num=d.event_num","left");
        */
        $t="$joinType join $table on $on";
        if(in_array($t,$this->bldsql_joins)==false)$this->bldsql_joins[]=$t;

    }
    function bldsql_where($where,$bind_parameter='',$replace=false){
        /*Pass single conditional of a where clause like 'num=2' or num=$key.  You can bundle clauses into an or statement
         *too like '(name like '$site' or num=$site_num)'  All passed condtionals will be and'd together.
         *If $bind_parameter passed, where must be like "num=?"
         *Date binds should not be quoted: where date=?
         *If $bind_parameter passed, you can also use $replace=true to change the value (like in a loop)
         *!!!NOTE replace doesn't work yet.. $key is not the same for wheres and parameters (if not all wheres have a param).  Will need to program another array to store corresponding param key for each where or something.
         */
        $bp=($bind_parameter!=="");
        $bind_parameter=($bind_parameter==="null"||$bind_parameter==="NULL")?null:$bind_parameter;
        $key=array_search($where,$this->bldsql_wheres);
        if($key!==false && $replace){
            $this->bldsql_wheres[$key]=$where;
            if($bp)$this->bldsql_parameters[$key]=$bind_parameter;
        }else{
            $this->bldsql_wheres[]=$where;
            if($bp)$this->bldsql_parameters[]=$bind_parameter;
        }

    }
    function bldsql_mwhere($where,$bindArr){
        /*pass a where clause with multiple binded vales in bindArr
        NOT tested... decided not to use, but should work.*/
        $this->bldsql_wheres[]=$where;
        foreach($bindArr as $val){$this->bldsql_parameters[]=$val;}
    }
    function bldsql_wherein($where,$bindArr){
        /*pass where like 'id_num in ' or 'num not in '.  This will append '(?,?,?...)' for each $bindArr[] and add them as params*/
        $where.="(";
        $t="";
        foreach($bindArr as $val){
             $t=$this->appendToList($t,'?');
             $this->bldsql_parameters[]=$val;
        }
        $where.="$t)";
        $this->bldsql_wheres[]=$where;
    }
    function bldsql_orderby($col){//Dups ignored
        if(in_array($col,$this->bldsql_orderbys)==false)$this->bldsql_orderbys[]=$col;
    }
    function bldsql_groupby($col){//Dups ignored
        if(in_array($col,$this->bldsql_groupbys)==false)$this->bldsql_groupbys[]=$col;
    }
    function bldsql_having($cond){#does not currently support binding
        $this->bldsql_havings[]=$cond;
    }
    function bldsql_distinct(){
        $this->bldsql_distinct="distinct";
    }
    function bldsql_limit($numRows){
        $this->bldsql_limit=($numRows);
    }
    function bldsql_cmd(){//Get the final sql.
        $cols=""; $froms="";$wheres="";$groupbys="";$orderbys="";$sets="";$havings='';
        foreach ($this->bldsql_cols as $col){$cols=$this->appendToList($cols,$col);}
        foreach ($this->bldsql_sets as $set){$sets=$this->appendToList($sets,$set);}
        foreach ($this->bldsql_froms as $from){$froms=$this->appendToList($froms,$from);}
        foreach ($this->bldsql_joins as $join){$froms=$this->appendToList($froms,$join,' ');}
        foreach ($this->bldsql_wheres as $where){$wheres=$this->appendToList($wheres,$where," and ");}
        foreach ($this->bldsql_groupbys as $col){$groupbys=$this->appendToList($groupbys,$col);}
        foreach ($this->bldsql_havings as $cond){$havings=$this->appendToList($havings,$cond," and ");}
        foreach ($this->bldsql_orderbys as $col){$orderbys=$this->appendToList($orderbys,$col);}

        #fork based on type of query.
        if($this->bldsql_insertTable && (!$this->bldsql_insertSelect)){
            #the set col=...syntax (1 at a time).
            $sql="insert ".$this->bldsql_insertTable." set $sets ";
        }elseif ($this->bldsql_updateTable){
            #in mysql, you can only have one updateable table reference open, so see if the update table is in the froms already
            $tables=(in_array($this->bldsql_updateTable,$this->bldsql_froms))?$froms:$this->appendToList($this->bldsql_updateTable,$froms);
            $sql="update $tables set $sets where $wheres";
        }else{
            $wheres=($wheres!="")?"where $wheres":"";
            $groupbys=($groupbys!="")?"group by $groupbys":"";
            $havings=($havings!='')?"having $havings":"";
            $orderbys=($orderbys!="")?"order by $orderbys":"";
            $limit=($this->bldsql_limit!="")?"limit $this->bldsql_limit":"";

            $sql="select $this->bldsql_distinct $cols from $froms $wheres $groupbys $havings $orderbys $limit";

            if($this->bldsql_intoTable){
                #create temp table with select.  note not all select syntax is supported.
                $index=($this->bldsql_intoTableIndex)?"(index ".$this->bldsql_intoTableIndex.")":"";
                $sql="create temporary table ".$this->bldsql_intoTable." $index as ($sql)";
            }elseif($this->bldsql_insertSelect){#insert table select...
                $sql="insert ".$this->bldsql_insertTable." $sql";
            }
        }
        return $sql;

    }
    function bldsql_printableQuery(){
        //Returns query and params for debug purposes.
        $sql=$this->bldsql_cmd();
        $params=array_merge($this->bldsql_setParameters,$this->bldsql_parameters);
        foreach($params as $p)$sql=$this->appendToList($sql,$p,"|");
        #var_dump($params);
        return htmlspecialchars($sql);
    }
    function bldsql_getParameters(){
        return $this->bldsql_parameters;
    }
    function bldsql_quote($str) {
        /*safe quoting for database use*/
        return $this->dbh->quote($str);

    }
    function bldsql_getQueryHash($salt=""){
        /*Returns a md5 hash of the current query + params. Salt is optional, can be number of rows returned though.*/
        $sql=$this->bldsql_cmd();
        $params=array_merge($this->bldsql_setParameters,$this->bldsql_parameters);
        foreach($params as $p)$sql=$this->appendToList($sql,$p,"|");
        return md5($sql.$salt);
    }
    function appendToList($a,$b,$delim=","){//util to append comma when needed.
        if($a!=="" && $b!=="")return $a.$delim.$b;
        return $a.$b;
    }




    function get_dbutilsHeaderIncludes($dbutilsDirPath,$includeExtraCharts=false,$includeLeafletMap=false){
        /*Returns <script... & <link... text for html header includes for printTable js & css
         *and graphing functions
         *This is only useful if you plan to call printTable or printGraph, it's not needed otherwise.*
         *NOTE graphing functions require recent version of jquery to be already linked
         *$dbutilsDirPath is the same path used to include this file.
         *ie if you included this file with include_once("../inc/dbutils/dbutils.php");
         *pass "../inc/dbutils/" to this method.
         *$includeExtraCharts loads other chart libraries
         */

        $html="";
        $dbutilsDirPath=rtrim($dbutilsDirPath,"/");//Remove slash if present
        $css=$dbutilsDirPath."/dbutils.css";
        $js=$dbutilsDirPath."/dbutils.js";
        $graphjs=$dbutilsDirPath."/graphing/flot/jquery.flot.js";
        $graphTimejs=$dbutilsDirPath."/graphing/flot/jquery.flot.time.min.js";
        $graphSymbolsjs=$dbutilsDirPath."/graphing/flot/jquery.flot.symbol.min.js";
        $graphNavjs=$dbutilsDirPath."/graphing/flot/jquery.flot.navigate.js";
        $graphSeljs=$dbutilsDirPath."/graphing/flot/jquery.flot.selection.js";
        $graphPiejs=$dbutilsDirPath."/graphing/flot/jquery.flot.pie.min.js";
        #$graphResize=$dbutilsDirPath."/graphing/flot/jquery.flot.resize.min.js";
        $graphStackedBar=$dbutilsDirPath."/graphing/flot/jquery.flot.stack.min.js";
        $errorBars=$dbutilsDirPath."/graphing/flot/jquery.flot.errorbars.min.js";
        $navigate=$dbutilsDirPath."/graphing/flot/jquery.flot.navigate.min.js";
        #saveAsImage (all 4 needed); Note; this doesn't save the legend (which is html), which sucks and why the 2nd solution below which does and is called from a button.
        $base64=$dbutilsDirPath."/graphing/flot/saveAsImage/base64.js";
        $canvas2Image=$dbutilsDirPath."/graphing/flot/saveAsImage/canvas2image.js";
        $saveAsImage=$dbutilsDirPath."/graphing/flot/saveAsImage/jquery.flot.saveAsImage.js";
        $canvas=$dbutilsDirPath."/graphing/flot/jquery.flot.canvas.min.js";
        #htmltocanvas (2nd try, saves legend)
        $html2Canvas=$dbutilsDirPath."/js/html2canvas.min.js";
        #color picker
        $spectrumjs=$dbutilsDirPath."/js/spectrum.js";
        $spectrumcss=$dbutilsDirPath."/template/resources/spectrum.css";
        $floattheadjs=$dbutilsDirPath."/js/jquery.floatThead.min.js";


        $html.=get_HeaderIncludeText($js);
        $html.=get_HeaderIncludeText($graphjs);
        $html.=get_HeaderIncludeText($graphTimejs);
        $html.=get_HeaderIncludeText($graphNavjs);
        $html.=get_HeaderIncludeText($graphSeljs);
        #$html.=get_HeaderIncludeText($graphResize);

        #$html.='<script src="//cdnjs.cloudflare.com/ajax/libs/dygraph/2.1.0/dygraph.min.js"></script>
        #    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/dygraph/2.1.0/dygraph.min.css" />';
         ##dygraph
        $dygraphjs=$dbutilsDirPath."/graphing/dygraph/dygraph.min.js";
        $dygraphcss=$dbutilsDirPath."/graphing/dygraph/dygraph.css";

        $html.=get_HeaderIncludeText($dygraphjs);
        $html.=get_HeaderIncludeText($dbutilsDirPath."/graphing/dygraph/smooth-plotter.js");
        $html.=get_HeaderIncludeText($dygraphcss,'css');

        $html.=get_HeaderIncludeText($floattheadjs);

        #Saving to img. what a pia
        $html.=get_HeaderIncludeText($base64);
        $html.=get_HeaderIncludeText($canvas2Image);
        $html.=get_HeaderIncludeText($saveAsImage);
        $html.=get_HeaderIncludeText($canvas);

        $html.=get_HeaderIncludeText($html2Canvas);

        if($includeExtraCharts){
            $html.=get_HeaderIncludeText($graphPiejs);
            $html.=get_HeaderIncludeText($graphStackedBar);
            $html.=get_HeaderIncludeText($errorBars);
            $html.=get_HeaderIncludeText($navigate);
        }
        $html.=get_HeaderIncludeText($css,'css');
        $html.=get_HeaderIncludeText($spectrumjs);
        $html.=get_HeaderIncludeText($spectrumcss,'css');
        if($includeLeafletMap){#Include directly (without stamp as these are remote and they manage cacheing)
            $html.='
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
          integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
          crossorigin=""/>

            <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
          integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
          crossorigin=""></script>
	        <script src="https://unpkg.com/esri-leaflet@2.5.1/dist/esri-leaflet.js"
          integrity="sha512-q7X96AASUF0hol5Ih7AeZpRF6smJS55lcvy+GLWzJfZN+31/BQ8cgNx2FGF+IQSA4z2jHwB20vml+drmooqzzQ=="
          crossorigin=""></script>';
          $html.=get_HeaderIncludeText($dbutilsDirPath."/js/leafletMapping.js");

        }
        return $html;
    }



    function logDML($sql){
        if($this->dmlLog){
            $user=$this->auth_user_name;

            $out=date(DATE_ATOM)." - $user -  $sql\n";
            if(!$handle = fopen($this->dmlLog, 'a')){//attempt to open file
                #echo ("Cannot open writable log file");
                #var_dump("Error writing log file.  Please contact John Mund.");
                #exit;
                #var_dump($this->dmlLog);
            }
            if (fwrite($handle, $out) === FALSE) {//attempt to write to it.
                #echo ("Cannot write to file ($this->dmlLog)");
                #exit;
            }
            fclose($handle);
        }
    }
    protected function runquery($sql,$parameters,$returnMode,$skipLog=false){
        /*Set return mode to 1 for num rows affected, 0 for last inserted id
            Returns ===FALSE on error.
            if $skipLog then we won't try to log the dml statement (when applicable).  This is for the create temp table statements

        #NOTE, null values are not actually supported by current inplementation.  It's because we are not explicitly binding values/variables
        to the query placeholders, we cheat (because it would be a pain to track the var types) and call execute with just a param array,
        which by default, binds as a string which mysql happily converts for us... except for nulls (atleast with time data types), which
        don't get set as a null.  We could update the logic to loop through the array and either default to stirng unless otherwise specified,
        or try to determine the type.  Since our whole db avoids null columns anyway, I'm putting this off and succombing to the -999
        null proxy. jwm.5/17
        */
        $logQuery='';

        if($sql==""){# use bldsql
            $sql=$this->bldsql_cmd();
            $logQuery=$this->bldsql_printableQuery();#this includes params
        }else{
            $logQuery=$sql;
            if($parameters)foreach($parameters as $p)$logQuery=$this->appendToList($logQuery,$p,"|");
        }

        #use bldsql_params if needed.  Make sure to put the setParams first.
        #jwm-4/6/2021 - this seems like it could cause an issue if you use bldsql first then again without (extra params).
        #I don't want to mess with it at the moment because I'm not sure how all the callers (of this) pass parameters and
        #don't want to do testing..  in theory, it should cause an immediate error (too many params), if that happened, well.. then
        #it should be fixed.  Should trace all callers and then move this up into above if block.
        if(count($parameters)==0)$parameters=array_merge($this->bldsql_setParameters,$this->bldsql_parameters);

        $this->debugLog($logQuery);#When logging, do it prior to actual call (and potential errors).

        if($this->dbh){
            $result=false;

            try{
                #Run the query
                $sth=$this->dbh->prepare($sql);
                if($sth){
                    if(count($parameters)){
                        $result=$sth->execute($parameters);
                    }else{
                        $result=$sth->execute();
                    }

                    if($result){
                        if(!$skipLog)$this->logDML($logQuery);
                        if($returnMode==0){
                            $a=$this->dbh->lastInsertID();
                            if($a==0)$a=true;//no id, return true (success)
                            else if(!$skipLog)$this->logDML("Last inserted id: $a");
                            return $a;
                        }else return $sth->rowCount();
                    }
                }
            }catch(PDOException $e){
                    $this->showError($e->getMessage(),$logQuery);
                    debug_print_backtrace();
                    return false;
            }
            return false;


        }else{
            $msg = "Error: database connection information not set.";
            $this->showError($msg);
            exit;
        }
    }

    protected function debugLog($sql=""){
        if($this->debugLogFile){
            if($sql=='')$out="\n".date(DATE_ATOM)."\n";#Start new login session with date marker
            else $out="$sql\n";
            if(!$handle = fopen($this->debugLogFile, 'a')){//attempt to open file
                echo ("Cannot open writable log file");
                #exit;
            }
            if (fwrite($handle, $out) === FALSE) {//attempt to write to it.
                echo ("Cannot write to file ($this->dmlLog)");
                #exit;
            }
            fclose($handle);
        }
    }
    protected function showError($msg,$query=""){
        #Log to file if error log set and we aren't on dev db
        if($this->errorLog && !$this->isDemoServer()){//Log to file
            //write this out to logs.
            $out=date(DATE_ATOM)." - $msg\n  $query\n";
            if(!$handle = fopen($this->errorLog, 'a')){//attempt to open file
                echo ("Cannot open writable log file");
                #exit;
            }
            if (fwrite($handle, $out) === FALSE) {//attempt to write to it.
                echo ("Cannot write to file ($this->errorLog)");
                #exit;
            }
            fclose($handle);

        }else{
            echo $this->appendToList($msg,$query,'<br>Query: ');

        }
        exit;
    }
    protected function logUsage(){#simple log of user/page
    #Not so simple it seems..  I think it's getting called multiple times.  Need user auth to be useful.  Session may be autostarted, which
    #on this version of php seems to get a new sess everytime (maybe unless you use it?)I'll see if this produces anything useful for a bit.
        $sessStarted=False;

        if(!session_status() === PHP_SESSION_NONE){
            $sessStarted=True;
            session_start();
        }

        if(isset($_SESSION['session_logged']) && $_SESSION['session_logged']){
            return true; #already logged.
        }else{
            $f="/var/www/html/mund/useage.log";
            if(is_writable($f)){
                $user=$this->auth_user_name;
                #$user=db_getAuthUser();
                $page=isset($_SERVER['REQUEST_URI'])?$_SERVER['REQUEST_URI']:"cmdline";
                if(strpos($page,"doWhat=keepAlive")!==False)return True;#skip these.
                $out=date(DATE_ATOM)." - $user -  $page\n";
                if(!$handle = fopen($f, 'a')){//attempt to open file
                    return false;
                }
                if (fwrite($handle, $out) === FALSE) {//attempt to write to it.
                    fclose($handle);
                    return false;
                }
                fclose($handle);
                $_SESSION['session_logged']=True;
            }
        }
        if($sessStarted)session_write_close();
    }

}


/*Result set utilities*/

function arrayFromCol($a,$col){
    #Convience function to reformat results.
    #Returns all values in result set $a for '$col' in an array.
    $ret=array();
    if($a){
        if(isset($a[0][$col])){
            foreach($a as $row){
                $ret[]=$row[$col];
            }
        }
    }
    return $ret;
}
function firstFromRS($a,$col){
    #Convience funtion
    #Returns the first value of $col from result set, or false
    $val=false;
    if($a){
        $row=$a[0];
        if(isset($row[$col]))$val=$row[$col];
    }
    return $val;
}
function valExistsInRS($a,$val,$col){
    #Checks to see if passed value exists in the passed result set col
    #Returns false if not, val if so.
    $ret=false;
    if($a){
        $arr=arrayFromCol($a,$col);
        if(in_array($val,$arr))$ret=$val;
    }
    return $ret;
}
function getDirAsRS($dir,$files=true,$directories=false,$filter='',$sortDesc=false){
    #Returns contents of dir as a dbutils results
    #Pass files or directories true to show them in rs
    #uses getInputSelect() naming (value=>display_name).  You can add optional if needed elsewhere.
    #filter is simple match (no wildcards)
    $t=scandir($dir);
    if($sortDesc)rsort($t);
    $a=array();
    foreach($t as $d){
        $td=$dir."/".$d;
        if((is_dir($td) && $directories || is_file($td) && $files) && $d!='.' && $d!='..'){
            if(!$filter ||(strpos($d,$filter)!==false)){
                $a[]=array('value'=>$d,'display_name'=>$d);#turn into a db result set as func expects
            }
        }
    };
    return $a;
}




function get_HeaderIncludeText($file,$type='js'){
        #Returns the html head text for passed js or css file, adding a mod time to the url to force reloads.
        #$type is js or css.  $file is relative path to file.
        #Note, for js and css files we could (and maybe should?) allow passing relative (to web root) file locations, which
        #would make some things easier, but since the new template mechanism makes this pretty easy now, we won't because
        #the advantage of being able to stat the file for mod time/version and force cache updates is pretty valuable and that would
        #be hard with relative file paths...
        if(file_exists($file)){
            $t=filemtime($file);
            if($t)$file.="?ver=$t";#This forces a reload when the file is modified.
            if($type=='js')$file="<script src='$file' type='text/javascript' language='JavaScript'></script>\n";
            else $file="<link rel='stylesheet' href='$file' type='text/css'>\n";
        }else{
            var_dump("Invalid path name passed to get_HeaderIncludes:$file");exit;
        }
        return $file;
}



#There is one global object to support the public functions.  The functions are just wrappers for the class methods.
#See the class def below for details.
$dbu_dbutils_global_obj=new dbutils();//Default is appropriate for non-db use.  Must call dbu_connect for db access.  This is our 1 global variable

#Configure and init
function db_connect($configfile="dbutils_config.php",$user="",$password="",$host="",$database="",$errorLog="") {
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj=new dbutils($configfile,$user,$password,$host,$database,$errorLog);
    $dbu_dbutils_global_obj->db_connect();
}
function db_connect_ro($database='',$host=''){
    db_connect('','','',$host,$database);
}

function db_isDemoServer(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->isDemoServer();
}
function bldsql_init(){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_init();
}
function setDebugLogFile($file="/tmp/dbutils_log.txt"){//Call to turn on logging.
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->setDebugLogFile($file);
}
#Select, insert & update
function doquery($sql="",$numRows=-1,$parameters=array()){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->doquery($sql,$numRows,$parameters);
    return $a;
}
function doinsert($sql="",$parameters=array()){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->doinsert($sql,$parameters);
    return $a;
}
function doinsertSelect($sql="",$parameters=array()){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->doinsertSelect($sql,$parameters);
    return $a;
}
function doupdate($sql="",$parameters=array()){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->doupdate($sql,$parameters);
    return $a;
}
function doselectinto($sql=""){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->doselectinto($sql);
    return $a;
}
function dodml($sql=''){
    global $dbu_dbutils_global_obj;
    $a=$dbu_dbutils_global_obj->dodml($sql);
    return $a;
}
function beginTransaction(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->beginTransaction();
}
function rollbackTransaction(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->rollbackTransaction();
}
function commitTransaction(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->commitTransaction();
}

#set tables
function bldsql_from($table){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_from($table);
}
function bldsql_join($table,$on,$joinType=''){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_join($table,$on,$joinType);
}
function bldsql_update($table){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_update($table);
}
function bldsql_insert($table){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_insert($table);
}
function bldsql_into($table,$index=""){
    #Index can be passed to be created on new table like:
    #'index_name (col1,col2)' or 'i(site_num)'
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_into($table,$index);
}

#for update/inserts, set col=value
function bldsql_set($col,$val){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_set($col,$val);
}

#for selects
function bldsql_col($col){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_col($col);
}
function bldsql_where($where,$bind_parameter='',$replace=false){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_where($where,$bind_parameter,$replace);
}
function bldsql_mwhere($where,$bindArr){
     global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_mwhere($where,$bind_parameter);
}
function bldsql_wherein($where,$bindArr){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_wherein($where,$bindArr);
}
#optional select params
function bldsql_orderby($col){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_orderby($col);
}
function bldsql_groupby($col){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_groupby($col);
}
function bldsql_having($cond){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_having($cond);
}
function bldsql_distinct(){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_distinct();
}
function bldsql_limit($numRows){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->bldsql_limit($numRows);
}
#Safe quote
function bldsql_quote($str) {
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->bldsql_quote($str);
}

#return the full statement if needed (to build a larger query).
function bldsql_cmd(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->bldsql_cmd();
}
function bldsql_printableQuery(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->bldsql_printableQuery();
}
function bldsql_getQueryHash(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->bldsql_getQueryHash();
}
function bldsql_getParameters(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->bldsql_getParameters();
}
#html header includes for printTable support
function get_dbutilsHeaderIncludes($dbutilsDirPath,$includePieCharts=false,$includeLeafletMap=false){
    /*Returns <script... & <link... text for html header includes for printTable js & css
    *This is only useful if you plan to call printTable, it's not needed otherwise.*
    *$dbutilsDirPath is the same path used to include this file.
    *ie if you included this file with include_once("../inc/dbutils/dbutils.php");
    *pass "../inc/dbutils/" to this method.
    */
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->get_dbutilsHeaderIncludes($dbutilsDirPath,$includePieCharts,$includeLeafletMap);
}

#User permissions (if configured, otherwise these all return true)
function db_userEnabled(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->userEnabled();
}
function db_userCanInsert(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->userCanInsert();
}
function db_userCanEdit(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->userCanEdit();
}
function db_userCanDelete(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->userCanDelete();
}
function db_getAuthUser(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->getAuthUser();
}
function db_setAuthUser($user){
    global $dbu_dbutils_global_obj;
    $dbu_dbutils_global_obj->setAuthUser($user);
}
function db_getAuthUserID(){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->getAuthUserID();
}

function dumpTable($table){
    #returns printTable of $table.  for dev.  Don't use in prod if $table isn't known safe.
    var_dump(printTable(doquery("select * from $table")));
}
#If log file configured
function logDML($text){
    global $dbu_dbutils_global_obj;
    return $dbu_dbutils_global_obj->logDML($text);
}

#utils
#NOTE, null values are not actually supported by current inplementation see runquery for comments.
function nullIfBlank($val){
    return ($val==="")?null:$val;
}
$toLogFile_first=true;
function toLogFile($obj){#Dumps obj to /home/ccg/mund/tmp/phpdebug.txt for, debugging ajax stuff...
    global $toLogFile_first;
    ob_start();
    var_dump($obj);
    $out="\n".ob_get_clean()."\n";
    $mode=($toLogFile_first)?"w":"a";
    if(!$handle = fopen('/home/ccg/mund/tmp/phpdebug.txt', $mode)){//attempt to open file
        echo ("Cannot open writable log file");
        var_dump("Error writing log file.  Please contact John Mund.");
        exit;
    }
    if (fwrite($handle, $out) === FALSE) {//attempt to write to it.
        echo ("Cannot write to file ($this->dmlLog)");
        exit;
    }
    fclose($handle);
    $toLogFile_first=false;
}


?>
