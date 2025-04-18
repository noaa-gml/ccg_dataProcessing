var comp_notes = new Array();
var unit_notes = new Array();

function doSingle() {
   f = document.mainform;

   //
   // Make sure that a component was actually selected
   //
   if ( f.availablelist.value != '' )
   {
      //
      // Send both the component num and "type - name" to CompSelection()
      //

      one = f.availablelist[f.availablelist.selectedIndex].value;
      two = f.availablelist.options[f.availablelist.selectedIndex].text;
      CompSelection(one,two,'single');
   }
}

function doDouble() {
   f = document.mainform;

   //
   // Make sure that a component was actually selected
   //
   if ( f.availablelist.value != '' )
   {
      //
      // Send both the component num and "type - name" to CompSelection()
      //

      one = f.availablelist[f.availablelist.selectedIndex].value;
      two = f.availablelist.options[f.availablelist.selectedIndex].text;
      CompSelection(one,two,'double');
      AvailableListCB();
   }
}

function CompSelection(num, name, click)
{
   //
   // This function controls what happens when a component is selected
   //

   //
   // Define variables
   //
   f = document.mainform;
   tstr = '';
   var ocomp_notes = top.document.getElementById('comp_notes');
   var i;

   //
   // Strip whitespace from the component number
   //
   num = num.replace(/\s+/g,'');

   if (num == '') return;
   //
   // Cannot assume selectedIndex of availablelist has been set 
   // 
   for (i=0,availablelistindex=(-1); i<f.availablelist.length; i++)
   {
      if (f.availablelist[i].value == num)
      {
         availablelistindex = i;
         //alert(f.availablelist[i].text);
      }
   }
   //alert(availablelistindex);

   //
   // Make sure that the availablelist selected index is a valid one
   //
   if (availablelistindex < 0) 
   { 
      alert(num+' '+name+' not found in available comp list.');
      return;
   }
   else
   {

      if ( click == 'double' )
      {
         //
         // If the selected component was already selected (MediumRedB)
         //    then make in unselected by making it unselected (MediumBlackN).
         //    Otherwise make it selected (MediumRedB)
         //
         optionclass = f.availablelist.options[availablelistindex];
         if ( optionclass.className == 'MediumBlackN')
         {
            optionclass.className = 'MediumRedB';
         }
        else
         {
            optionclass.className = 'MediumBlackN';
         }
         //alert(optionclass);
      }
   }

   //
   // If we are selecting an index in the availablelist
   //
   //f.availablelist[availablelistindex].selected = 1;

   //
   // Are there components comments?
   //
   if (comp_notes[availablelistindex] != "NULL" && comp_notes[availablelistindex] != "")
   { ocomp_notes.innerHTML = "** COMPONENT **<BR>"+name+"<BR>"+comp_notes[availablelistindex]; }
   else { ocomp_notes.innerHTML = ' '; }

   //
   // Make a string list of all the selected (MediumRedB) components
   //    deliminated by ~'s
   //
   for (i=0; i<f.availablelist.length; i++)
   {
      selectedc = f.availablelist.options[i];
      if ( selectedc.className == 'MediumRedB' )
      {
         tstr += (tstr == '') ? selectedc.value : "~" + selectedc.value;
      }
   }
   f.selectedcomps.value = tstr;

   //
   // Set focus to flask scan text field
   //
   // f.flaskscan.focus();
}


function EquipListCB()
{
   //
   // If an unitment is selected in the unitlist
   //

   //
   // Initialize variables
   //
   f = document.mainform;
   var i = f.unitlist.selectedIndex;

   //
   // Store the value of the unitment selected
   //
   if ( f.unitlist.selectedIndex != -1 )
   {
      f.unit_id.value = f.unitlist[i].value;

      //
      // Clear the list of selected components
      //
      f.selectedcomps.value = '';

      //
      // Write out the component comments if there are any
      //
      if (unit_notes[i] != "NULL" && unit_notes[i] != "")
      {
         //alert(unit_notes[i]);
         f.unit_notes.value = "** EQUIPMENT **<BR>"+unit_notes[i];
      }
      else { f.unit_notes.value = ''; }

      f.submit();
   }
}

function AvailableListCB()
{
   f = document.mainform;

   //
   // Make sure that a component was actually selected
   //
   if ( f.availablelist.value != '' )
   {
      //
      // Section for sorting the available list. The problem is that we need to
      //    sort the selected component list and the unselected component list
      //    separately. We also need to keep the component notes in the right order.
      //    The component notes are attached to the value and text deliminated by
      //    |'s. Then we sort the lists and split the information up back into
      //    separate arrays.
      //
      var selectedlist = new Array();
      var notselectedlist = new Array();
      var newcomp_notes = new Array();

      //
      // If the component is selected, add it to selectedlist otherwise add it
      //    to notselectedlist.
      //
      for (var i=0; i<f.availablelist.length; i++)
      {
         selectedc = f.availablelist.options[i];
         sdata = selectedc.text;
         sdata += "|" + selectedc.value + "|" + comp_notes[i];
         if ( selectedc.className == 'MediumRedB' )
         {
            selectedlist[selectedlist.length] = sdata;
         }
         else
         {
            notselectedlist[notselectedlist.length] = sdata;
         }
      }

      //
      // Sort the lists
      //
      selectedlist = selectedlist.sort();
      notselectedlist = notselectedlist.sort();

      //
      // Clear the availablelist select list on the site
      //
      f.availablelist.length = 0;

      //
      // Loop through selectedlist and add them to availablelist, making
      //    them selected components (MediumRedB)
      //
      for (var i=0; i<selectedlist.length; i++)
      {
         info = selectedlist[i].split("|");
         num = f.availablelist.length;
         f.availablelist[num] = new Option(info[0],info[1],false,false);
         f.availablelist.options[num].className = 'MediumRedB';
         newcomp_notes[newcomp_notes.length] = info[2];
      }

      //
      // Loop through notselectedlist and add them to availablelist, making
      //    them unselected components (MediumBlackN)
      //
      for (var i=0; i<notselectedlist.length; i++)
      {
         info = notselectedlist[i].split("|");
         num = f.availablelist.length;
         f.availablelist[num] = new Option(info[0],info[1],false,false);
         f.availablelist.options[num].className = 'MediumBlackN';
         newcomp_notes[newcomp_notes.length] = info[2];
      }

      //
      // Save the component notes, reordered
      //
      comp_notes = newcomp_notes;
   }
}

function OkayCB()
{
   //
   // Okay function (when "Ok" is clicked)
   //

   //
   // Initialize the variables
   //
   f = document.mainform;
   diff = 0;
   tstr = '';

   //
   // Takes a string delimited by ~'s and makes it into an array
   //
   var orig_array=f.originalcomps.value.split("~");
   var sele_array=f.selectedcomps.value.split("~");

   //
   // Loop through the orig_array (array of original components)
   //    and determine if that array element is in the
   //    concatenated string selectedcomps.value (string of selected components).
   //    The result will be the components that need to be "removed" from the
   //    current list of components for a given unitment
   //
   for (var i=0; i<orig_array.length; i++)
   {
      if (f.selectedcomps.value.indexOf(orig_array[i]) == -1)
      {
         tstr += (tstr == '') ? orig_array[i] : "~" + orig_array[i];
      }
   }
   f.remcomps.value = tstr;
                                                                                          
   tstr = '';

   //
   // Loop through the sele_array (array of selected components)
   //    and determine if that array element is in the
   //    concatenated string originalcomps.value (string of original components).
   //    The result will be the components that need to be "added" from the
   //    current list of components for a given unitment
   //
   for (var i=0; i<sele_array.length; i++)
   {
      if (f.originalcomps.value.indexOf(sele_array[i]) == -1)
      {
         tstr += (tstr == '') ? sele_array[i] : "~" + sele_array[i];
      }
   }
   f.addcomps.value = tstr;
   
   //
   // If both lists are empty, then nothing was changed.
   //
   if ( (f.remcomps.value == '') && (f.addcomps.value == '') )
   {
      alert("No changes made.");
      return;
   }

   //
   // Confirm the changes
   //
   if (confirm('Are you sure?')) 
   {
      f.task.value='Ok';
      f.submit();
   }
   else { return; }
}

function CancelCB()
{
   //
   // Cancel function (when "Cancel" is clicked)
   //

   f = document.mainform;

   //
   // If an unit_id is selected, then clear all the variables
   //
   if (f.unit_id.value)
   {
      f.unit_id.value = '';
      f.selectedcomps.value = '';
      f.unit_notes.value = '';
      f.submit();
   }
   else { document.location = 'pfp_blank.php'; }
}

