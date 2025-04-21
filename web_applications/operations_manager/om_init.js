//
// Determine user's level of access - kam
//
//alert(allow.user);
allow.level = GetAccessLevel(allow.user, allow.om);
//
//alert(allow.level);
// Syntaxes: *** START EDITING HERE, READ THIS SECTION CAREFULLY! ***
//
// Misc Initialization - dyc
//
now = new Date();
sec = now.getMilliseconds();
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
menu[0][1] = new Item('  Strategy', '#', '', 60, 20, 1);
menu[0][2] = new Item('  Equipment', '#', '', 80, 20, 2);
menu[0][3] = new Item('  View', '#', '', 60, 20, 3);
//
//****************************************************************
// PROJECT menu.
//
menu[1] = new Array();
//
// The PROJECT menu is positioned 0px across and 22 down from its trigger, and is 175 (was 80) wide.
// All text in this menu has the stylesheet class 'item' -- see the <style> section above.
// We've passed a 'greater-than' sign '>' as a popout indicator. Try an image...?
//
var down = {	flask: 'index.php?strat_abbr=flask&strat_name=Flask',
		pfp: 'index.php?strat_abbr=pfp&strat_name=PFP',
		insitu: 'index.php?strat_abbr=insitu&strat_name=InSitu',
		done: 'http://www.cmdl.noaa.gov/ccgg/'};
//		obs: 'index.php?strat_abbr=obs&strat_name=Observatory',

menu[1][0] = new Menu(true, '>', 0, 22, 220, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[1][1] = new Item('Flask ...', down.flask, '', defLength, 0, 0);
menu[1][2] = new Item('PFP ...', down.pfp, '', defLength, 0, 0);
menu[1][3] = new Item('In Situ ...', down.insitu, '',defLength, 0, 0);
menu[1][4] = new Item('', '', '', defLength, 0, 0);

var opt = 5;
//alert(allow.level);
if (allow.level == 1)
{
	menu[1][opt++] = new Item('Site Manager ...', omurl+'om_siteedit.php?strat_abbr=om','', defLength, 0, 0);
	menu[1][opt++] = new Item('', '', '', defLength, 0, 0);
}
menu[1][opt] = new Item('Done', down.done, '', defLength, 0, 0);
//
//****************************************************************
// EQUIPMENT menu.
//
menu[2] = new Array();

var down = {	pcp: 'index2.php?invtype=PCP',
		psu: 'index2.php?invtype=PSU'};

menu[2][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[2][1] = new Item('PCP ...', down.pcp, '', defLength, 0, 0);
menu[2][2] = new Item('PSU ...', down.psu, '', defLength, 0, 0);

//
//****************************************************************
// VIEW menu.
//
menu[3] = new Array();
menu[3][0] = new Menu(true, '>', 0, 22, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[3][1] = new Item('DB Query ...', omurl + 'om_dbquery.php?strat_abbr=om&dummy='+sec, '', defLength, 0, 0);
menu[3][2] = new Item('', '', '', defLength, 0, 0);
menu[3][3] = new Item('Site Data ...', omurl+'om_sites.php?strat_abbr=om', '', defLength, 0, 0);
menu[3][4] = new Item('Event Data ...', omurl+'om_events.php?strat_abbr=om', '', defLength, 0, 0);
menu[3][5] = new Item('Tables ...', omurl+'om_tables.php?strat_abbr=om', '', defLength, 0, 0);
menu[3][6] = new Item('Forms', '#', '', defLength, 0, 4);

//
//****************************************************************
// VIEW-Forms menu.
//
menu[4] = new Array();
menu[4][0] = new Menu(true, '>', 200, 0, 200, defOver, defBack, 'pd_itemBorder', 'pd_itemText');

menu[4][1] = new Item('Site and Equip Request', omurl+'siteequiprequest.html?dummy='+sec, '', defLength, 0, 0);
