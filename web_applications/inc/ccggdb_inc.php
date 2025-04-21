<?php
# ccggdb.inc
#
define("BG_COLOR","EEEEEE");

define("IADVDIR","./");
define("CCGDIR","../../webdata/ccgg/iadv/");
define("IADVGASES","co2,ch4,co,h2,n2o,sf6,co2c13,co2c14,co2o18,ch4c13");
define("IADVPARAMS","co2,ch4,co,h2,n2o,sf6,co2c13,co2c14,co2o18,ch4c13");
define("IADVTYPES","fi,lg,sc,rug,ts,vp,vppanel");

$url=array('defi'=>'ccggmdb_content.php?table=defi&title=DEFINITION',
           'desc'=>'ccggmdb_content.php?table=desc&title=DESCRIPTION',
           'coop'=>'ccggmdb_content.php?table=coop&title=COOPERATION',
           'spon'=>'ccggmdb_content.php?table=spon&title=SPONSOR',
           'ship'=>'ccggmdb_content.php?table=ship&title=SHIPPING',
           'note'=>'ccggmdb_content.php?table=note&title=NOTES');
#
# ccgg_db common functions
#
#
# Function wmorr_connect ########################################################
#
function wmorr_connect()
{var_dump("please contact john mund for access to ccggdb_inc.php->wmorr_connect()");exit();
   $db_c=mysql_connect("","","");
   if ($db_c && mysql_select_db("wmorr")) return($db_c);
   else return(FALSE);
}
#
# Function ccgg_connect ########################################################
#
function ccgg_connect()
{
   $db_c=mysql_connect("","","");
   if ($db_c && mysql_select_db("")) return($db_c);
   else return(FALSE);
}
#
# Function ccgg_insert ########################################################
#
function ccgg_insert($sql)
{
   #if (!mysql_query($sql)) return(mysql_error());
   if (!mysql_query($sql)) return("DB ERROR");
   else return("");
}
#
# Function ccgg_delete ########################################################
#
function ccgg_delete($sql)
{
   #if (!mysql_query($sql)) return(mysql_error());
   if (!mysql_query($sql)) return("DB ERROR");
   else return("");
}
#
# Function ccgg_query ########################################################
#
function ccgg_query($sql, $delimiter='|')
{
   $result=mysql_query($sql);

   #if (!$result) return(mysql_error());
   if (!$result) return("DB ERROR");

   $arr=array();
   while($row=mysql_fetch_row($result))
   {
      $z=array();
      for ($i=0,$str=""; $i<mysql_num_fields($result); $i++)
      {
         $z[]=$row[$i];
      }
      $arr[]=implode($delimiter,$z);
   }
   mysql_free_result($result);
   return($arr);
}
#
# Function ccgg_fields ########################################################
#
function ccgg_fields($db,$table,&$field_name,&$field_type,&$field_len)
{
   $result=mysql_list_fields($db,$table);

   if (!$result) return(FALSE);

   $num=mysql_num_fields($result);

   $field_len=array();
   $field_name=array();
   $field_type=array();

   for ($i=0; $i<$num; $i++)
   {
      $field_len[]=mysql_field_len($result,$i);
      $field_name[]=mysql_field_name($result,$i);
      $field_type[]=mysql_field_type($result,$i);
   }
   mysql_free_result($result);
   return(TRUE);
}
?>
