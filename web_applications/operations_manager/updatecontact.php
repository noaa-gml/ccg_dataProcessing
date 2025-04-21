#!/usr/bin/php -q

<?php

include ("om_inc.php");
include ("ccgglib_inc.php");
                                                                                          
if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$ds = ldap_connect("ldaps://ldap-mountain.nems.noaa.gov:636/");

$r = ldap_bind($ds, "uid=CMDL.LDAPbind,ou=People,o=noaa.gov", "clb12345");

if ( $r )
{

   $select = " SELECT num, email";
   $from = " FROM contact";
   $sql = $select.$from;

   $z = ccgg_query($sql);

   for ( $i=0; $i<count($z); $i++ )
   {
      list($cnum, $cemail) = split("\|", $z[$i]);

      $sr = ldap_search($ds,"ou=People,o=noaa.gov","(&(ou=ESRL)(ou1=*GMD*)(mail=$cemail)(!(employeetype=Function)))");
      $info = ldap_get_entries($ds, $sr);

      $count = $info["count"];

      if ( $count > 0 )
      {

         $cname = (isset($info[0]["cn"][0])) ? $info[0]["cn"][0] : "";
         #$cemail = (isset($info[0]["mail"][0])) ? $info[0]["mail"][0] : "";
         $ctel = (isset($info[0]["telephonenumber"][0])) ? $info[0]["telephonenumber"][0] : "";

         $update = "UPDATE contact";
         $set = " SET name='$cname', tel='$ctel'";
         $where = " WHERE num = '$cnum'";

         $sql = $update.$set.$where;
         #JavaScriptAlert($sql);
         $res = ccgg_insert($sql);

         if (!empty($res)) { return(FALSE); }
      }
   }

   ldap_close($ds);
}
else
{
   echo "Unable to connect to LDAP (nems) server\n";
}

?>
