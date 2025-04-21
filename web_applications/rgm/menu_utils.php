<?PHP

require_once "DB_CalServiceManager.php";

function CreateMenu(DB $input_database_object, DB_User $input_user_obj)
{
   #echo $input_database_object->database;
?>

  <noscript>
  Menu requires JavaScript to work properly.
  </noscript>
  <script>
    if ( window.jQuery )
    {
       if ( ! jQuery.ui )
       {
          document.write("Menu require jQUery UI to work properly.");
       }
    }
    else
    { document.write("Menu requires jQuery to work properly."); }

    $(function() {
     // Make all ul elements that end with '_menu' in their ID menu items
     $( "#main_menu" ).menu();

     // Make all ul elements that end with '_menu' in their ID display the menu offest
     $( "#main_menu" ).menu( "option", "position", { my: "left top", at: "left+60 bottom" } );
  });
  </script>
  <style>
   .ui-menu { width: 200px; }
  </style>
  <TABLE style='background-color:#78C7C7' width='100%'>
   <TR>
    <TD align='center'>
     <FONT style='font-size:2em; font-weight:bold;'>Refgas Manager</FONT>
    </TD>
   <TR>
   <TR>
    <TD>
     <TABLE width='100%'>
      <TR>
       <TD width='30px'>
        <A href='index.php'>
         <IMG src='images/home.png' width='30px' height='30px'>
        </A>
       </TD>
       <TD align='left'>
        <!--
           Only display this on a desktop as it can interfere with the
           other input controls
        -->
        <ul id="main_menu" class='desktop_view'>
         <li>
          <a href='#'>Menu</a>
          <ul>
            <li>
             <a href="#" style='background-color:#C7FFC1'>Cylinder Location</a>
             <ul>
              <li><a href="cylinder_checkin.php">- Check-In</a></li>
              <li><a href="cylinder_checkin_file.php">- Check-In by file</a></li>
              <li><a href="cylinder_ship.php">- Ship</a></li>
              <li><a href="cylinder_ship_file.php">- Ship by file</a></li>
              <li><a href="cylinder_find.php">- Find</a></li>
              <li><a href="index.php?mod=cylinderLocations">- Cylinder Locations</a></li>

             </ul>
            </li>
            <li>
             <a href="#" style='background-color:#CED6FF'>Cylinder Inventory</a>
             <ul>
              <li><a href="cylinder_update.php">- Update Cylinder</a></li>
              <li><a href="cylinder_update_file.php">- Update by File</a></li>
              <li><a href="cylinder_edit.php?action=add">- Add Cylinder</a></li>
              <li><a href="cylinder_add_file.php">- Add by File</a></li>
             </ul>
            </li>
            <li>
             <a href="#" style='background-color:#CEF6EC'>Calibrations</a>
             <ul>
                <li><a href='todo_list2.php'>- Todo List</a></li>
             
<?PHP
/*Removing for above todo_list2.php-jwm 8/16
try
{ $calservice_objects = DB_CalServiceManager::searchByUser($input_database_object, $input_user_obj); }
catch ( Exception $e )
{ $calservice_objects = array(); }

foreach ( $calservice_objects as $calservice_object )
{
   echo "<li><a href='todo_list.php?cs_num=".$calservice_object->getNum()."&showresults=1'>- Todo Task > ".$calservice_object->getAbbreviation()."</a></li>\n";
   echo "<li><a href='todo_list.php?cs_num=".$calservice_object->getNum()."&showresults=0'>- Todo View > ".$calservice_object->getAbbreviation()."</a></li>\n";
}
*/
?>
              <!--<li><a href="cylinder_fill.php">- Cylinder fill</a></li>-->
              <li><a href="index.php?mod=fill">- Cylinder fill</a></li>
              <li><a href="index.php?mod=orders">- Orders</a></li>
              <!--<li><a href="orders_details.php">- Orders details</a></li>
              <li><a href="orders_overview.php">- Orders overview</a></li>
              <li><a href="orders_overview.php?type=pending">- Pending Orders</a></li>
              <li><a href="order_creation.php">- Create Order</a></li>-->
              <li><a href="product_extras.php">- Product Extras</a></li>
              <!--<li><a href="orders_search.php">- Search Orders</a></li>-->
             </ul>
            </li>
            <li>
             <a href="#" style='background-color:#FFCECE'>Location</a>
             <ul>
              <li><a href="location_update.php">- Update Location</a></li>
              <li><a href="location_edit.php">- Add Location</a></li>
             </ul>
            </li>
            <li>
             <a href="#" style='background-color:#FFF0CE'>Account</a>
             <ul>
              <li><a href="account.php">- Update Password</a></li>
             </ul>
            </li>
            <li><a href="help.html" style='background-color:#FFCC66'>Help</a></li>
          </ul>
         </li>
        </ul>
       </TD>
       <TD align='right'>
        <A href='logout.php'>
         <INPUT type='button' value='Logout' onClick='if ( ! confirm("Are you sure you want to logout?") ) { return false;}'>
        </A>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
  </TABLE>
<?PHP
}
function createMenu2($showHome=true)
{ #This makes the jquery ui drop down menu
  $list=getMenuList();
  $html='
  <noscript>
  Menu requires JavaScript to work properly.
  </noscript>
  <script>
    if ( window.jQuery )
    {
       if ( ! jQuery.ui )
       {
          document.write("Menu require jQUery UI to work properly.");
       }
    }
    else
    { document.write("Menu requires jQuery to work properly."); }

    $(function() {
     // Make all ul elements that end with "_menu" in their ID menu items
     $( "#main_menu" ).menu();

     // Make all ul elements that end with "_menu" in their ID display the menu offest
     $( "#main_menu" ).menu( "option", "position", { my: "left top", at: "left+60 bottom" } );
  });
  </script>
  <style>
   .ui-menu { width: 200px; }
   .ui-menu a {display:block;}
  </style>
  
  <table width="100%">
   <tr>';
   if($showHome)$html.='<td><A href="index.php"><img src="images/home.png" width="20px" height="20px"></a></td>';
   $html.='
      <td align="left">        
         '.$list.'        
      </td>
      
   </tr>
  </table>
  ';
  return $html;
}
function getMenuList(){
  $html='<ul id="main_menu" class="desktop_view">
         <li>
          <a href="#">Menu</a>
          <ul>
            <li><A href="index.php">Home</a></li>
            <li>
             <a href="#" style="background-color:#C7FFC1">Cylinder Location</a>
             <ul>
              <li><a href="cylinder_checkin.php">- Check-In</a></li>
              <li><a href="cylinder_checkin_file.php">- Check-In by file</a></li>
              <li><a href="cylinder_ship.php">- Ship</a></li>
              <li><a href="cylinder_ship_file.php">- Ship by file</a></li>
              <li><a href="cylinder_find.php">- Find</a></li>
              <li><a href="index.php?mod=cylinderLocations">- Cylinder Locations</a></li>

             </ul>
            </li>
            <li>
             <a href="#" style="background-color:#CED6FF">Cylinder Inventory</a>
             <ul>
              <li><a href="cylinder_update.php">- Update Cylinder</a></li>
              <li><a href="cylinder_update_file.php">- Update by File</a></li>
              <li><a href="cylinder_edit.php?action=add">- Add Cylinder</a></li>
              <li><a href="cylinder_add_file.php">- Add by File</a></li>
             </ul>
            </li>
            <li>
             <a href="#" style="background-color:#CEF6EC">Calibrations</a>
             <ul>
              <li><a href="todo_list2.php">- Todo List</a></li>
              <!--<li><a href="cylinder_fill.php">- Cylinder fill</a></li>-->
              <li><a href="index.php?mod=fill">- Cylinder fill</a></li>
              <li><a href="index.php?mod=orders">- Orders</a></li>
              <!--<li><a href="orders_details.php">- Orders details</a></li>
              <li><a href="orders_overview.php">- Orders overview</a></li>
              <li><a href="orders_overview.php?type=pending">- Pending Orders</a></li>
              <li><a href="order_creation.php">- Create Order</a></li>-->
              <li><a href="product_extras.php">- Product Extras</a></li>
              <!--<li><a href="orders_search.php">- Search Orders</a></li>-->
             </ul>
            </li>
            <li>
             <a href="#" style="background-color:#FFCECE">Location</a>
             <ul>
              <li><a href="location_update.php">- Update Location</a></li>
              <li><a href="location_edit.php">- Add Location</a></li>
             </ul>
            </li>
            <li>
             <a href="#" style="background-color:#FFF0CE">Account</a>
             <ul>
              <li><a href="account.php">- Update Password</a></li>
             </ul>
            </li>
            
          </ul>
         </li>
        </ul>';
  return $html;
        
}
?>
