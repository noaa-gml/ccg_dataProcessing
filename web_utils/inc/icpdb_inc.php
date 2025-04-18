<?php
# icpdb_inc.php
#

#
# icp_db common functions
#
#
# Function icp_connect ########################################################
#
function icp_connect()
{
   $db_c=mysql_connect("db.cmdl.noaa.gov","apache","");
   if ($db_c && mysql_select_db("icp")) return($db_c);
   else return(FALSE);
}
#
# Function icp_query ########################################################
#
function icp_query($sql)
{
   $result=mysql_query($sql);

   if (!$result) return(mysql_error());
   #if (!$result) return("DB ERROR");

   $arr=array();
   while($row=mysql_fetch_row($result))
   {
      $z=array();
      for ($i=0,$str=""; $i<mysql_num_fields($result); $i++)
      {
         $z[]=$row[$i];
      }
      $arr[]=implode("|",$z);
   }
   mysql_free_result($result);
   return($arr);
}
#
# Function icp_insert ########################################################
#
function icp_insert($sql)
{
   #if (!mysql_query($sql)) return(mysql_error());
   if (!mysql_query($sql)) return("DB ERROR");
   else return("");
}
#
# Function icp_fields ########################################################
#
function icp_fields($db,$table,&$field_name,&$field_type,&$field_len)
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
