<?PHP

if ( ! isset($argv[1]) ||
     ! file_exists($argv[1]) )
{
   exit(1);
}

try
{
   $text = file_get_contents($argv[1]);

   $shipping_data = new SimpleXMLElement($text);

}
catch ( Exception $e )
{
   exit(1);
}
#print_r($shipping_data);

?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
 <STYLE>
body
{
   font-size: 12pt;
   font-family:"Times New Roman", Times, serif;
}
pre
{
   font-size: 12pt;
   padding: 10;
   font-family: "Courier New", Courier, monospace;
}
table
{
   border-collapse: collapse;
   border: 1px solid black;
   border-spacing: 0;
}
table td, table th
{
   padding: 0;
}
.header1
{
   font-size: 16pt;
}
.header2
{
   font-size: 13pt;
   padding: 5;
}
.header3
{
   font-size: 9pt;
}
.header4
{
   font-size: 8pt;
}
.data
{
   font-size: 12pt;
   font-family: "Courier New", Courier, monospace;
}
.bold
{
   font-weight: bold;
}
.underline
{
   text-decoration: underline;
}
 </STYLE>
 </HEAD>

<?PHP

# Put the HTML BODY in a try statement, throwing any errors that may occur
#   (like missing data)

try
{

?>
 <BODY>
  <TABLE height='684' width='1000'>
   <TR>
    <TD valign='top'>
     <TABLE width='100%' height='100%'>
      <TR>
       <TD width='25%' valign='top' align='left'>
        <FONT class='header4 bold'>
MASC Form 50<BR>
(REV. 5-13)
        </FONT>
       </TD>
       <TD width='50%' align='center'>
        <FONT class='header1 bold'>
U.S. GOVERNMENT SHIPPING DOCUMENT
        </FONT>
       </TD>
       <TD width='25%' valign='top' align='right'>
        <FONT class='header4 bold'>
U.S. Department of Commerce<BR>
Mountain Administrative Support Center<BR>
Boulder, Colorado
        </FONT>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD align='center'>
     <TABLE width='100%' height='100%'>
      <TR>
       <TD width='25%' class='header2 bold'>
<FONT style='outline: 1px solid black;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</FONT> NIST
       </TD>
       <TD width='25%' class='header2 bold'>
<FONT style='outline: 1px solid black;'>&nbsp;X&nbsp;</FONT> NOAA
       </TD>
       <TD width='25%' class='header2 bold'>
<FONT style='outline: 1px solid black;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</FONT> NTIA
       </TD>
       <TD width='25%' class='header2 bold'>
<FONT style='outline: 1px solid black;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</FONT> OTHER
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <TABLE width='100%' height='100%'>
      <TR>
       <TD width='45%'>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD valign='top'>
<DIV class='header2 bold underline'>SHIP TO:</DIV>
<PRE>
<?PHP
if ( isset($shipping_data->ship_to) )
{ echo $shipping_data->ship_to; }
else
{ throw new Exception("Missing required information."); }
?>
</PRE>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD width='30%'>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD valign='top'>
<DIV class='header2 bold'>SHIP FROM:</DIV>
<PRE>
<?PHP
if ( isset($shipping_data->ship_from) )
{ echo $shipping_data->ship_from; }
else
{ throw new Exception("Missing required information."); }
?>
</PRE>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD width='25%'>
        <TABLE width='100%' height='100%'>
         <TR style='outline: 1px solid black;'>
          <TD valign='top'>
<DIV class='header2 bold'>AUTHORIZED BY</DIV>
<DIV class='data' style='padding: 10;'>Pieter Tans</DIV>
          </TD>
         </TR>
         <TR style='outline: 1px solid black;'>
          <TD valign='top'>
<DIV class='header2 bold'>PREPARED BY</DIV>
<DIV class='data' style='padding: 10;'>
Duane Kitzis<BR>
ROOM: DSRC 2D133<BR>
EXTENSION: 6675
</DIV>
          </TD>
         </TR>
         <TR style='outline: 1px solid black;'>
          <TD valign='top'>
<DIV class='header2 bold'>PURPOSE</DIV>
<DIV class='data' style='padding: 10;'>
COOPERATIVE ATMOSPHERIC STANDARDS
</DIV>
          </TD>
         </TR>
        </TABLE>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <TABLE width='100%' height='100%'>
      <TR>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>DATE SHIPPED</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
           &nbsp;
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>COST</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
           &nbsp;
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>BILL OF LADING</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
           &nbsp;
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>TOTAL PIECES</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
<?PHP
if ( isset($shipping_data->total_pieces) )
{ echo $shipping_data->total_pieces; }
else
{ throw new Exception("Missing required information."); }
?>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>TOTAL WEIGHT</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
           &nbsp;
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>VALUE</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
<?PHP
if ( isset($shipping_data->value) )
{ echo $shipping_data->value; }
else
{ throw new Exception("Missing required information."); }
?>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>SHIP BY</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
<?PHP
if ( isset($shipping_data->ship_by) )
{ echo $shipping_data->ship_by; }
else
{ echo "&nbsp;"; }
?>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>DIVISION/ORG. CODE</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
<?PHP
if ( isset($shipping_data->org_code) )
{ echo $shipping_data->org_code; }
else
{ throw new Exception("Missing required information."); }
?>
          </TD>
         </TR>
        </TABLE>
       </TD>
       <TD>
        <TABLE width='100%' height='100%'>
         <TR>
          <TD align='center' class='header3 bold'>PROJECT/TASK NUMBER</TD>
         </TR>
         <TR>
          <TD align='center' class='data'>
<?PHP
if ( isset($shipping_data->project_number) )
{ echo $shipping_data->project_number; }
else
{ throw new Exception("Missing required information."); }
?>
          </TD>
         </TR>
        </TABLE>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
   <TR>
    <TD>
     <TABLE width='100%' height='100%'>
      <TR>
       <TD valign='top'>
<DIV class='header2 bold'>DESCRIPTION</DIV>
<PRE>
<?PHP
if ( isset($shipping_data->description) )
{ echo $shipping_data->description; }
else
{ throw new Exception("Missing required information."); }
?>
<PRE>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
  </TABLE>
 </BODY>

<?PHP

}
catch ( Exception $e )
{
   # If there ARE problems then exit with status 1
   exit(1);
}

?>
</HTML>

<?PHP
# If there are no problems, then exit with status 0
exit(0);
?>


