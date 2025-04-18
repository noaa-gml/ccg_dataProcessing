//
// Determine user's level of access - kam
//
allow.level = GetAccessLevel(allow.user, allow.pfp);
//
// Misc Initialization - kam
//
now = new Date();
sec = now.getMilliseconds();
yr = now.getFullYear();
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
//
menu[1][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

var opt = 1;

if (allow.level == 1)
{
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
	menu[1][opt++] = new Item('To Prep ...', omurl+'pfp/pfp_toprep.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check Out ...', omurl+'pfp/pfp_checkout.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Check In ...', omurl+'pfp/pfp_checkin.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Event Editing ...', omurl+'pfp/pfp_eventedit.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Inventory ...', omurl+'pfp/pfp_inventory.php?dummy='+sec, '', defLength, 0, 0);
	menu[1][opt++] = new Item('Site Manager ...', omurl+'om_siteedit.php?strat_name=PFP&strat_abbr=pfp', '', defLength, 0, 0);
	menu[1][opt++] = new Item('Equipment Manager', '#', '', defLength, 0, 3);
	menu[1][opt++] = new Item('Field Manager', '#', '', defLength, 0, 8);
}
menu[1][opt] = new Item('Done', omurl+'index.php', '', defLength, 0, 0);
//
//****************************************************************
// VIEW menu.
//
menu[2] = new Array();
menu[2][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[2][1] = new Item('PFP', '#', '', defLength, 0, 5);
menu[2][2] = new Item('Shipping', '#', '', defLength, 0, 6);
menu[2][3] = new Item('Log', '#', '', defLength, 0, 4);
menu[2][4] = new Item('Diagnostics', '#', '', defLength, 0, 7);
menu[2][5] = new Item('History File...', omurl+'pfp/pfp_viewhistory.php?dummy='+sec, '', defLength, 0, 0);
menu[2][6] = new Item('', '', '', defLength, 0, 0);
menu[2][7] = new Item('DB Query ...', omurl+'om_dbquery.php?strat_name=PFP&strat_abbr=pfp&dummy='+sec, '', defLength, 0, 0);
menu[2][8] = new Item('Site Data ...', omurl+'om_sites.php?strat_name=PFP&strat_abbr=pfp&dummy='+sec, '', defLength, 0, 0);
menu[2][9] = new Item('Event Data ...', omurl+'om_events.php?strat_name=PFP&strat_abbr=pfp&dummy='+sec, '', defLength, 0, 0);
//menu[2][8] = new Item('Event Data ...', omurl+'pfp/pfp_events.php', '', defLength, 0, 0);
menu[2][10] = new Item('Tables ...', omurl+'om_tables.php?strat_abbr=pfp&strat_name=PFP&dummy='+sec, '', defLength, 0, 0);
//
//****************************************************************
// Task - Equipment Manager menu
//
menu[3] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[3][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
url = omurl+'pfp/pfp_viewer.php?task=';

menu[3][1] = new Item('Add ...', omurl + 'pfp/pfp_comp_add.php?dummy='+sec, '', defLength, 0, 0);
menu[3][2] = new Item('Status ...', omurl + 'pfp/pfp_comp_status.php?dummy='+sec, '', defLength, 0, 0);
menu[3][3] = new Item('Log ...', omurl + 'pfp/pfp_comp_log.php?dummy='+sec, '', defLength, 0, 0);
//
// View-Log menu
//
menu[4] = new Array();
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[4][0] = new Menu(true, '>', 200, 0, 60, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
url = omurl+'pfp/pfp_viewer.php?file='+omdir+'log/pfp.';
//
// Add seconds to URL to ensure page "reloads" in Mozilla - kam
//
for (i=0; i<3; i++) { menu[4][i+1] = new Item(yr-i, url+(yr-i)+'&dummy='+sec, '', defLength, 0, 0); }
//
// View-Flasks menu
//
menu[5] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[5][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
url = omurl+'pfp/pfp_viewer.php?task=';

menu[5][1] = new Item('In Analysis', url+'in_analysis&dummy='+sec, '', defLength, 0, 0);
menu[5][2] = new Item('In Prep', url+'in_prep&dummy='+sec, '', defLength, 0, 0);
menu[5][3] = new Item('Out By Site ...', omurl+'pfp/pfp_outbysite.php', '', defLength, 0, 0);
menu[5][4] = new Item('With Notes', url+'notes&dummy='+sec, '', defLength, 0, 0);
menu[5][5] = new Item('In Repair', url+'in_repair&dummy='+sec, '', defLength, 0, 0);
menu[5][6] = new Item('Retired', url+'retired&dummy='+sec, '', defLength, 0, 0);
menu[5][7] = new Item('In Testing', url+'in_testing&dummy='+sec, '', defLength, 0, 0);
menu[5][8] = new Item('Reserved', url+'reserved&dummy='+sec, '', defLength, 0, 0);
//
// View-Shipping menu
//
menu[6] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[6][0] = new Menu(true, '>', 200, 0, 100, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
menu[6][1] = new Item('By Site ...', omurl+'pfp/pfp_shipbysite.php?dummy='+sec, '', defLength, 0, 0);
menu[6][2] = new Item('By PFP ...', omurl+'pfp/pfp_shipbyid.php?dummy='+sec, '', defLength, 0, 0);

//
// View-Diagnostics menu
//
menu[7] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[7][0] = new Menu(true, '>', 200, 0, 150, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
menu[7][1] = new Item('Checkin To Prep', omurl+'pfp/pfp_pfpstat.php?dummy='+sec, '', defLength, 0, 0);
menu[7][2] = new Item('Site Supply', omurl+'pfp/pfp_supplysum.php?dummy='+sec, '', defLength, 0, 0);
menu[7][3] = new Item('Sample Frequency', omurl+'/om_samplefreq.php?strat_name=PFP&strat_abbr=pfp&dummy='+sec, '', defLength, 0, 0);

//
// Task-Field Manager menu
//
menu[8] = new Array();
//
// This is across but not down... a horizontal popout (with crazy stylesheets :)...
//
menu[8][0] = new Menu(true, '>', 200, 0, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
//
// These items are lengthier than normal, and have extra spacing due to the fancy borders.
//
menu[8][1] = new Item('Current Configuration ...', omurl + 'om_siteconfig.php?strat_name=PFP&strat_abbr=pfp&dummy='+sec, '', defLength, 0, 0);
menu[8][2] = new Item('Field Log ...', omurl + 'pfp/ac_history.php?dummy='+sec, '', defLength, 0, 0);
menu[8][3] = new Item('Keyword Manager ...', omurl + 'pfp/ac_keyword.php?dummy='+sec, '', defLength, 0, 0);
