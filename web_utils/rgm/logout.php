<?php
session_start();
session_destroy();
?> 

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
You have successfully logged out.
<BR>
Click to <A href='login.php'><INPUT type='button' value='Log In'></A>
 </BODY>
</HTML>
