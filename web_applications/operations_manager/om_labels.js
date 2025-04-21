function PrintCB()
{
   //
   // If the user selects from the test list, grab all of the selected values
   // and put them into an array
   //

   f = document.mainform;

   selectedArray = new Array();
   var i;
   var count = 0;
   for (i=0; i < f.printlist.length; i++) {
      if ( f.printlist[i].checked )
      {
         selectedArray[count] = f.printlist[i].value;
         count++;
      }
   }

   if ( count == 0 ) return;
   //
   // Note: When you set an array to a non-array element, all the entries
   // are put into the non-array element deliminated by commas
   //
   f.printids.value = selectedArray;

   f.submit();
}

