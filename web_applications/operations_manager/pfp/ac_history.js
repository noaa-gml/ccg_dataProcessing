function ListSelectCB(list)
{
   //
   // Different actions based on which list the user selects
   //

   f = document.mainform;
                                                                                          
   if ( list.name == 'sitelist' )
   {
      f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
      f.casenum.value = '';
      f.datetime.value = '';
      f.newcomment.value = '';
   }
                                                                                          
   if ( list.name == 'caselist' )
   {
      f.casenum.value = f.caselist[f.caselist.selectedIndex].value;
      f.datetime.value = '';
      f.newcomment.value = '';

      //
      // If the user requests to add a case, let the program know that
      //    and set the task to 'add'
      //
      if ( f.casenum.value == 'Add' )
      {
         f.newcomment.value = '';
         f.newcase.value = '1';
         f.task.value = 'add';
      }
   }
                                                                                          
   f.submit();
}

function ShowEntryCB()
{
   //
   // Show the entry or entries that the user has selected from the loglist
   //
   f = document.mainform;

   if ( f.loglist.selectedIndex == -1 ) return;

   f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
   f.casenum.value = f.caselist[f.caselist.selectedIndex].value;

   selectedArray = new Array();
   var i;
   var count = 0;
   for (i=0; i < f.loglist.length; i++) {
      if ( f.loglist.options[i].selected )
      {
         selectedArray[count] = f.loglist.options[i].value;
         count++;
      }
   }

   //
   // When you set an array to a non-array element, all the entries
   // are put into the non-array element deliminated by commas
   //
   f.datetime.value = selectedArray;
   f.newcomment.value = '';

   f.submit();
}

function ShowImageCB(keyword, type)
{
   //
   // Popup another window with pictures shown based on the keyword and type
   //    of images. Keyword need not be specfied. Type can be 'all' [~ all images]
   //    or 'one' [~ one image]
   //

   f = document.mainform;

   site = f.sitelist[f.sitelist.selectedIndex].text.toLowerCase();
   date = f.caselist[f.caselist.selectedIndex].text;

   if ( keyword == '' && type != 'all' )
   {
      //
      // If a keyword was not specified and all images were not requested
      // then loop through and get the keyword that is currently selected
      //
      key = new RegExp("info:",'i');
      for (ii=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name.match(key) == null) continue;

         tmp = f.elements[ii].name.split(":");

         if ( tmp[1] == 'ac_log_key_num' )
         {
            //alert(f.elements[ii].value);
            keyword = f.elements[ii].options[f.elements[ii].selectedIndex].text;
            keyword = keyword.replace(/\s/g,'_');

            if ( f.elements[ii].selectedIndex == 0 )
            {
               return false;
            }
         }
      }
   }

   //
   // Opening new windows
   //

   path = '/projects/aircraft/'+site+'/images/log/'+date;

   if ( type == 'all' )
   {
      var load = window.open('ac_keyconfig.php?path='+path,'','scrollbars=yes,menubar=yes,height=600,width=800,resizable=yes,toolbar=yes,location=yes,status=yes');
   }
   else
   {
      var load = window.open('ac_keyconfig.php?path='+path+'&keyword='+keyword,'','scrollbars=yes,menubar=yes,height=600,width=800,resizable=yes,toolbar=yes,location=yes,status=yes');
   }
}

function NewLogCB()
{
   //
   // When the user clicks on "Add" beneath the list of log entries
   //
   f = document.mainform;

   f.datetime.value = '';
   f.newcase.value = '';
   f.newcomment.value = '1';

   f.submit();
}

function AddCB()
{
   //
   // When the user clicks on "Add" beneath the text fields,
   //    actually add the log entry to the database
   //
   f = document.mainform;

   if ( f.sitenum.value == '' && f.casenum.value == '' ) return;

   if (!(SaveData())) return;

   if (!confirm("Add comment?")) return;

   f.task.value = 'add';
   f.submit();
}

function BackCB()
{
   //
   // If the user clicks back, step backwards through the page
   //
   f = document.mainform;

   if ( f.datetime.value || f.newcomment.value != '' )
   {
      tmp = f.datetime.value.split(",");
      if ( ( tmp[0] != '' && tmp[1] == undefined ) || f.newcomment.value != '' )
      {
         if (!confirm("Unsaved data will be lost. Okay?")) return;
      }
      f.datetime.value = '';
      f.newcomment.value = '';
   }
   else
   {
      if ( f.casenum.value != '' )
      { 
         f.casenum.value = '';
      }
      else
      {
         f.sitenum.value = '';
      }
   }

f.submit();
}

function ClearCB()
{
	//
	// If the user clicks clear, clear all information
	//
	f = document.mainform;

	if ( f.sitenum.value == '' || f.casenum.value == '' ) return;

	if (!confirm("Unsaved data will be lost. Okay?")) return;

	key = new RegExp("info:",'i');
	for (ii=0; ii<f.elements.length; ii++)
	{
		if (f.elements[ii].name.match(key) == null) continue;
		f.elements[ii].value = '';
	}
}

function UpdateCB()
{
	//
	// If the user clicks update
	//
	f = document.mainform;

	if ( f.sitenum.value == '' || f.casenum.value == '' ) return;

	if (!(SaveData())) return;

	if (!confirm("Update log entry?")) return;

	f.task.value = 'update';
	f.submit();
}

function DeleteCB()
{
	//
	// If the user clicks update
	//
	f = document.mainform;

	if ( f.sitenum.value == '' || f.casenum.value == '' ) return;

	if (!confirm("Delete log entry?")) return;

	f.task.value = 'delete';
	f.submit();
}

function SetBackground(element,state)
{
	color = (state) ? 'paleturquoise' : 'white';
	element.style.backgroundColor=color;
}

function SaveData()
{
	//
	// Saves the data server side so that we can access it after the page submits
	// Note: 0 - FALSE, 1 - TRUE
	//
	f = document.mainform;

	if (f.casenum.value == '' || f.sitenum.value == '' ) return 0;

	a = '';
	key = new RegExp("info:",'i');
	for (ii=0; ii<f.elements.length; ii++)
	{
		z = '';

		if (f.elements[ii].name.match(key) == null) continue;
		//
		// Disallow use of '~' and '|'
		//
		if (f.elements[ii].value.match(/\~/) != null)
		{ f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return 0; }

		if (f.elements[ii].value.match(/\|/) != null)
		{ f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return 0; }

		tmp = f.elements[ii].name.split(":");

		if ( tmp[1] == 'ac_log_key_num' && f.elements[ii].value == '' )
		{
			alert('Please select a keyword');
         return 0;
      }

      z = tmp[1] + "~" + f.elements[ii].value;

      if ( z != '' )
      {
         a += (a == '') ? z : "|" + z;
      }
   }
   
   //
   // Write the data to the webpage
   //
   f.saveinfo.value = a;

   return 1;
}
