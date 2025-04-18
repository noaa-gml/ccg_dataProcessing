<?PHP

# Requires must come before session_start()
# Please see http://stackoverflow.com/questions/1055728/php-session-with-an-incomplete-object

require_once "CCGDB.php";
require_once "DB_User.php";
require_once "utils.php";
require_once "Log.php";


session_start();

if ( ! isset($_SESSION['user']) )
{
   #`session_regenerate_id` sends a new cookie but doesn't overwrite the value stored
   # in `$_COOKIE`. After calling `session_destroy`, the open session ID is discarded,
   # so simply restarting the session with `session_start`(as done in Ben Johnson's
   # code) will re-open the original, though now empty, session for the current request
   # (subsequent requests will use the new session ID). Instead of
   # `session_destroy`+`session_start`, use the `$delete_old_session` parameter to
   # `session_regenerate_id` to delete the previous session data.

   # Delete old cookie
   #session_regenerate_id('true');
   #jwm 2021-01-15.  Not sure why this is needed and it's causing problems (index.php needs
   #to keep some state if session expires so it can continue after auth).  Commented out.
}

$user = ( isset($_POST['user']) ) ? $_POST['user'] : '';
$pw = ( isset($_POST['pw']) ) ? $_POST['pw'] : '';
$remember_me = ( isset($_POST['remember_me']) ) ? true : false;
$return_url = ( isset($_GET['url']) ) ? urldecode($_GET['url']) : 'index.php';#setting default to index.php because otherwise, the manual log in doesn't work(doesn't get redirected anywhere and then gets below 'email or pass wrong' message (erroniously).  Hopefully this doesn't cause issues
$mellon_uid=(isset($_SERVER['MELLON_uid']))?$_SERVER['MELLON_uid']:"";#SAML auth_mellon already authenticated if present.
if($mellon_uid)$user=$mellon_uid;#set to be same.

$database_object = new CCGDB();

try
{
   if (( $user != '' && $pw != '' )||$mellon_uid)
   {
      if ( ! isset($_SESSION['user']) ||
           ! ValidAuthentication($database_object, $_SESSION['user']) )
	
      {
         $tmp_user_obj = new DB_User($database_object, $user, '');
#var_dump($tmp_user_obj);
         if ( $tmp_user_obj->authenticate($pw, $remember_me, $mellon_uid) )
         { $_SESSION['user'] = $tmp_user_obj; }
         else
         { unset($_SESSION['user']); }

      }
   }
}
catch ( Exception $e )
{
   Log::update($e->__toString());
   echo "<DIV style='color:red'>".$e->getMessage()."</DIV>";
}

# Redirect once a user and authenticated status are set
if ( isset($_SESSION['user']) &&
     ValidAuthentication($database_object, $_SESSION['user']) )
{
   $path_aarr = pathinfo(__FILE__);

   $test_url = '/var/www/html/'.$return_url;
   #The following test is returning false because realpath doesn't work when query params are passed.
   #I'm disableing for now because it's not really needed (will fail if incorrect) and its causing problems on 
   #new omi server/icam auth system.  I think this code is getting triggered more because of a change in timeouts,
   # but it breaks basically any time a querystring is present I think (which is all the new j/lib funcs)
   #jwm 11/19
   /*
   if ( $return_url != '' &&
        realpath($test_url) != '' &&
        preg_match('/^'.preg_replace('/\//', '\\/', $path_aarr['dirname']).'/', realpath($test_url)) &&
        file_exists($test_url) )
   { */
   $cln_return_url = $return_url;
   /* }
   else
   { $cln_return_url = 'index.php'; }
   */

   #header("Location: index.php");
   #print $cln_return_url;
   header( 'Location: '.$cln_return_url ) ;
}
?>

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
  <SCRIPT language='JavaScript' src='login.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
 </HEAD>
 <BODY>



  <FORM name='mainform' method='POST' onsubmit="return false;">
   <TABLE>
    <tr><TD>
     <H2>Refgas Manager</H2>
     <br>
        <a href='/saml/login?ReturnTo=https://omi.cmdl.noaa.gov/rgm/index.php'>NOAA Login</a> (CAC&pin or email )
     <br><br><br>
     Exteranl Users login:
    </TD></tr>

<?PHP
if ( $user != '' && $pw == '' )
{
   echo "<TR>";
   echo " <TD>";
   echo "  <DIV style='color:red'>Please input your password.</DIV>";
   echo " </TD>";
   echo "</TR>";
}
elseif ( $user == '' && $pw != '' )
{
   echo "<TR>";
   echo " <TD>";
   echo "  <DIV style='color:red'>Please input your username.</DIV>";
   echo " </TD>";
   echo "</TR>";
}
elseif ( $user != '' && $pw != '' )
{
   # If a user and pw were provided but we were not redirected, then information
   #  must have been incorrect
   echo "<TR>";
   echo " <TD>";
   echo "  <DIV style='color:red'>The username or password you<BR> entered is incorrect. Please see the<br><a href='help.html'><input type='button' value='Help'></a>.</DIV>";
   echo " </TD>";
   echo "</TR>";
}
?>
    <TR>
     <TD align='center'>
         Username
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <INPUT type='text' id='user' size='15' name='user' value='<?PHP echo $user;?>'>
      <SCRIPT>$('#user').focus();</SCRIPT>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Password
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <INPUT type='password' id='pw' name='pw' size='15'>
     </TD>
    </TR>
    <TR class='desktop_view'>
     <TD align='center'>
      <INPUT type='checkbox' id='remember_me' name='remember_me' CHECKED>
      Remember me
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
         <INPUT type='button' value='Submit' onClick='SubmitCB();'>
        </TD>
        <TD align='right' width='50%'>
<?PHP #         <INPUT type='button' value='Back' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> ?>
<?PHP #         <A href='index.php'><INPUT type='button' value='Back'></A> ?>
        </TD>
       </TR>
       <TR>
        <TD align='left' width='50%'>
        </TD>
        <TD align='right' width='50%'>
        </TD>
       </TR>
      </TABLE>
      <?PHP # This is for the menu that pops up at the bottom of the android screen. ?>
      <BR>
      <BR>
      <BR>
      <BR>
      <BR>
     </TD>
    </TR>
   </TABLE>
  </FORM>
<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>
