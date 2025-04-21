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
menu[0][0] = new Menu(false, '', 5, 122, 25, 'blue', '#ADDDDD', '', 'pd_itemText');
//
// Notice how the targets are all set to nonzero values...
// The 'length' of each of these items is 40, and there is spacing of 10 to the next item.
// Most of the links are set to '#' hashes, make sure you change them to actual files.
//
menu[0][1] = new Item('  Project', '', '', 60, 20, 1);
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
down = {	flask: 'index.php?abbr=flask&name=Flask',
		pfp: 'index.php?abbr=pfp&name=Automated Flask',
		tower: 'index.php?abbr=tower&name=Tower',
		obs: 'index.php?abbr=obs&name=Observatory',
		done: 'index.php'};

menu[1][0] = new Menu(true, '>', 0, 22, 220, defOver, defBack, 'pd_itemBorder', 'pd_itemText');
menu[1][1] = new Item('Flask ...', down.flask, '', defLength, 0, 0);
menu[1][2] = new Item('Automated Flask ...', down.pfp, '', defLength, 0, 0);
menu[1][3] = new Item('Tower ...', down.tower, '',defLength, 0, 0);
menu[1][4] = new Item('Observatory ...', down.obs, '', defLength, 0, 0);
menu[1][5] = new Item('Done', down.done, '', defLength, 0, 0);
