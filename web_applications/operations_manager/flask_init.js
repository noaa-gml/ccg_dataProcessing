//
// Determine user's level of access - kam
//
allow.level = GetAccessLevel(allow.user, allow.flask);
// 
// Misc Initialization - kam
//
var now = new Date();
var sec = now.getMilliseconds();
var yr = now.getFullYear();
//
// Syntaxes: *** START EDITING HERE, READ THIS SECTION CAREFULLY! ***
//
// menu[menuNumber][0] = new Menu(Vertical menu? (true/false), 'popout indicator', left, top,
// width, 'mouseover colour', 'background colour', 'border stylesheet', 'text stylesheet');
//
// Left and Top are measured on-the-fly relative to the top-left corner of its trigger, or
// for the root menu, the top-left corner of the page.
//
// menu[menuNumber][itemNumber] = new Item('Text', 'URL', 'target frame', length of menu item,
//  additional spacing to next menu item, number of target menu to popout);
//
// If no target menu (popout) is desired, set it to 0. Likewise, if your site does not use
// frames, pass an empty string as a frame target.
//
// Something that needs explaining - the Vertical Menu setup. You can see most menus below
// are 'true', that is they are vertical, except for the first root menu. The 'length' and
// 'width' of an item depends on its orientation -- length is how long the item runs for in
// the direction of the menu, and width is the lateral dimension of the menu. Just look at
// the examples and tweak the numbers, they'll make sense eventually :).
//
var menu = new Array();
//
// Default colours passed to most menu constructors (just passed to functions, not
// a global variable - makes things easier to change later in bulk).
//
var defOver = 'blue', defBack = 'midnightblue';
//
// Default 'length' of menu items - item height if menu is vertical, width if horizontal.
//
var defLength = 25;
//
// Menu 0 is the special, 'root' menu from which everything else arises.
//
menu[0] = new Array();
//
// A non-vertical menu with a few different colours and no popout indicator, as an example.
// *** MOVE ROOT MENU AROUND HERE ***  it's positioned at (5, 0) and is 17px high now.
// menu[0][0] = new Menu(false, '', 5, 0, 17, '#669999', '#006666', '', 'itemText');
//
// menu[0][0] = new Menu(false, '', 5, 122, 25, 'blue', '#ADDDDD', '', 'pd_itemText');
menu[0][0] = new Menu(false, '', 5, 81, 25, 'blue', '#ADDDDD', '', 'pd_itemText');
//
// Notice how the targets are all set to nonzero values...
// The 'length' of each of these items is 40, and there is spacing of 10 to the next item.
// Most of the links are set to '#' hashes, make sure you change them to actual files.
//
menu[0][1] = new Item('  Task', '#', '', 40, 20, 1);
menu[0][2] = new Item('  View', '#', '', 40, 20, 2);
//
//****************************************************************
// TASK menu.
//
menu[1] = new Array();
//
// The TASK menu is positioned 0px across and 22 down from its trigger, and is 175 (was 80) wide.
// All text in this menu has the stylesheet class 'item' -- see the <style> section above.
// We've passed a 'greater-than' sign '>' as a popout indicator. Try an image...?

menu[1][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

var opt = 1;

if (allow.level == 1)
{
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
	menu[1][opt++] = new Item('To Prep ...', omurl+'flask/flask_prep.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check Out ...', omurl+'flask/flask_checkout.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check In ...', omurl+'flask/flask_checkin.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Event Details ...', omurl+'flask/flask_eventinput.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Event Editing ...', omurl+'flask/flask_eventedit.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Inventory ...', omurl+'flask/flask_inventory.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Site Manager ...', omurl+'om_siteedit.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Log Manager', '#', '', defLength, 0, 9);
	menu[1][opt++] = new Item('Site Configuration ...', omurl+'om_siteconfig.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
}
menu[1][opt] = new Item('Done', omurl+'index.php', '', defLength, 0, 0);
//
//****************************************************************
// VIEW menu.
//
menu[2] = new Array();
menu[2][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[2][1] = new Item('Flask', '#', '', defLength, 0, 5);
menu[2][2] = new Item('Shipping', '#', '', defLength, 0, 6);
menu[2][3] = new Item('Log', '#', '', defLength, 0, 4);
menu[2][4] = new Item('Diagnostics', '#', '', defLength, 0, 7);
menu[2][5] = new Item('', '', '', defLength, 0, 0);
menu[2][6] = new Item('DB Query ...', omurl + 'om_dbquery.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
menu[2][7] = new Item('Site Data ...', omurl+'om_sites.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
menu[2][8] = new Item('Event Data ...', omurl+'om_events.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
menu[2][9] = new Item('Forms', '#', '', defLength, 0, 8);
//
//****************************************************************
// HELP menu
//
menu[3] = new Array();
menu[3][0] = new Menu(true, '<', 0, 22, 80, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[3][1] = new Item('Contents', '#', '', defLength, 0, 0);
menu[3][2] = new Item('Index', '#', '', defLength, 0, 0);
menu[3][3] = new Item('About', '#', '', defLength, 0, 0);
//
// View-Log menu
//
menu[4] = new Array();
menu[4][0] = new Menu(true, '>', 200, 0, 60, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

var url = omurl+'flask/flask_viewer.php?file='+omdir+'log/flask.';
//
// Add seconds to URL to ensure page "reloads" in Mozilla - kam
//
var i;
for (i=0; i<3; i++) { menu[4][i+1] = new Item(yr-i, url+(yr-i)+'&dummy='+sec, '', defLength, 0, 0); }
//
// View-Flasks menu
//
menu[5] = new Array();
menu[5][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

url = omurl+'flask/flask_viewer.php?task=';

menu[5][1] = new Item('In Analysis', url+'in_analysis&dummy='+sec, '', defLength, 0, 0);
menu[5][2] = new Item('In Flask Prep', url+'in_prep&dummy='+sec, '', defLength, 0, 0);
menu[5][3] = new Item('Out By Site ...', omurl+'flask/flask_outbysite.php', '', defLength, 0, 0);
menu[5][4] = new Item('With Notes', url+'notes&dummy='+sec, '', defLength, 0, 0);
menu[5][5] = new Item('Not in Use', url+'not_in_use&dummy='+sec, '', defLength, 0, 0);
menu[5][6] = new Item('Retired', url+'retired&dummy='+sec, '', defLength, 0, 0);
//
// View-Shipping menu
//
menu[6] = new Array();
menu[6][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[6][1] = new Item('By Site ...', omurl+'flask/flask_shipbysite.php?dummy='+sec, '', defLength, 0, 0);
menu[6][2] = new Item('By Flask ...', omurl+'flask/flask_shipbyid.php?dummy='+sec, '', defLength, 0, 0);
//
// Diagnostics menu
//
menu[7] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[7][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
menu[7][1] = new Item('Site Supply', omurl+'flask/flask_flaskstat.php?dummy='+sec, '', defLength, 0, 0);
menu[7][2] = new Item('Sample Frequency', omurl+'/om_samplefreq.php?strat_name=Flask&strat_abbr=flask&dummy='+sec, '', defLength, 0, 0);
//
// Forms menu
//
menu[8] = new Array();
menu[8][0] = new Menu(true, '>', 200, 0, 175, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[8][1] = new Item('Sample Sheets ...', omurl + 'flask/flask_samplesheets.php?dummy=' + sec, '', defLength, 0, 0);
menu[8][2] = new Item('General ...', omurl+'om_tables.php?strat_name=Flask&strat_abbr=flask', '', defLength, 0, 0);
//
// Task-Log Manager Menu
//
menu[9] = new Array();
menu[9][0] = new Menu(true, '>', 200, 0, 175, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[9][1] = new Item('Flask Log ...', omurl + 'flask/flask_testlog.php?dummy='+sec, '', defLength, 0, 0);
menu[9][2] = new Item('Keyword Manager ...', omurl + 'flask/flask_keyword.php?dummy='+sec, '', defLength, 0, 0);
