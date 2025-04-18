//
// Determine user's level of access - kam
//
allow.level = GetAccessLevel(allow.user, allow.pcp);
// 
// Misc Initialization - kam
//
var invtype = 'PCP';
var strat_name = 'PFP';
var strat_abbr = 'pfp';
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
	menu[1][opt++] = new Item('Make Available ...', omurl+'gen/gen_mkavail.php?invtype='+invtype, '', defLength, 0, 0);
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check Out ...', omurl+'gen/gen_checkout.php?invtype='+invtype+'&strat_name='+strat_name+'&strat_abbr='+strat_abbr, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check In ...', omurl+'gen/gen_checkin.php?invtype='+invtype+'&strat_name='+strat_name+'&strat_abbr='+strat_abbr, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Shipping Details ...', omurl+'gen/gen_shipping.php?invtype='+invtype+'&strat_name='+strat_name+'&strat_abbr='+strat_abbr, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Inventory ...', omurl+'gen/gen_inventory.php?invtype='+invtype, '', defLength, 0, 0);
	menu[1][opt++] = new Item(invtype+' Manager ...', omurl+'gen/gen_unit.php?invtype='+invtype, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Config Manager', '#', '', defLength, 0, 7);
	menu[1][opt++] = new Item('Log Manager', '#', '', defLength, 0, 5);
	menu[1][opt++] = new Item('Test Log Manager', '#', '', defLength, 0, 6);
	//menu[1][opt++] = new Item('Site Manager ...', omurl+'om_siteedit.php?strat_name=Flask&strat_abbr=flask', '', defLength, 0, 0);
}
menu[1][opt] = new Item('Done', omurl+'index.php', '', defLength, 0, 0);
//
//****************************************************************
// VIEW menu.
//
menu[2] = new Array();
menu[2][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

var opt = 1;

menu[2][opt++] = new Item(invtype, '#', '', defLength, 0, 4);
menu[2][opt++] = new Item('Log', '#', '', defLength, 0, 3);
menu[2][opt++] = new Item('', '', '', defLength, 0, 0);
menu[2][opt++] = new Item('DB Query ...', omurl + 'gen/gen_dbquery.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
//menu[2][opt++] = new Item('Site Data ...', omurl+'om_sites.php?strat_name=Flask&strat_abbr=flask', '', defLength, 0, 0);
//
//****************************************************************
// View-Log menu
//
menu[3] = new Array();
menu[3][0] = new Menu(true, '>', 200, 0, 60, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

var lcinvtype = invtype.toLowerCase();
var url = omurl+'gen/gen_viewer.php?file='+omdir+'log/'+lcinvtype+'.';
//
// Add seconds to URL to ensure page "reloads" in Mozilla - kam
//
var i;
for (i=0; i<3; i++) { menu[3][i+1] = new Item(yr-i, url+(yr-i)+'&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0); }
//
//****************************************************************
// View-invtype menu
//
menu[4] = new Array();
menu[4][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

url = omurl+'gen/gen_viewer.php?task=';

menu[4][1] = new Item('In Testing', url+'in_testing&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[4][2] = new Item('Available', url+'available&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[4][3] = new Item('Out By Site ...', omurl+'gen/gen_outbysite.php?invtype='+invtype+'&strat_name='+strat_name+'&strat_abbr='+strat_abbr, '', defLength, 0, 0);
menu[4][4] = new Item('With Notes', url+'notes&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[4][5] = new Item('In Repair', url+'in_repair&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[4][6] = new Item('Retired', url+'retired&invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
//
//****************************************************************
// Task-ELog Manager Menu
//
menu[5] = new Array();
menu[5][0] = new Menu(true, '>', 200, 0, 175, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[5][1] = new Item('Electronic Log ...', omurl + 'gen/gen_elog.php?invtype='+invtype+'&strat_name='+strat_name+'&strat_abbr='+strat_abbr+'&dummy='+sec, '', defLength, 0, 0);
menu[5][2] = new Item('Keyword Manager ...', omurl + 'gen/gen_elog_keyword.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
//
//****************************************************************
// Task-TLog Manager Menu
//
menu[6] = new Array();
menu[6][0] = new Menu(true, '>', 200, 0, 175, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[6][1] = new Item('Test Log ...', omurl + 'gen/gen_testlog.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[6][2] = new Item('Keyword Manager ...', omurl + 'gen/gen_tlog_keyword.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
//
//****************************************************************
// Task-Config Manager Menu
//
menu[7] = new Array();
menu[7][0] = new Menu(true, '>', 200, 0, 175, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[7][1] = new Item('Configuration ...', omurl + 'gen/gen_config.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
menu[7][2] = new Item('Component Manager ...', omurl + 'gen/gen_comp.php?invtype='+invtype+'&dummy='+sec, '', defLength, 0, 0);
