function ListSelectCB(list)
{
   f = document.mainform;

   //
   // If the user selects from the unit list, then clear the selected
   //    component value and store the information server side
   //
   if ( list.name == 'unitlist' )
   {
      f.prev_unitid.value = f.unitid.value;
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.compnum.value = '';
   }

   //
   // If the user selects from the component list, then clear the
   //    selected unit value and store the information server side
   //
   if ( list.name == 'complist' )
   {
      f.prev_compnum.value = f.compnum.value;
      f.unitid.value = '';
      f.compnum.value = f.complist[f.complist.selectedIndex].value;
   }

   f.submit();
}

function TypeNum(number,type_num)
{
   //
   //
   //
   f = document.mainform;

   arr = typecomps.split("\|");
   unit_typenum = new Array();
   unit_id = new Array();

   //
   // Create two arrays, one is an array of unit_type numbers that are linked to
   //    units associated with the component. The other array is an array of the
   //    unit ids associated with the component
   //
   for (i=0; i<arr.length; i++)
   {
      tmp = arr[i].split("~");
      unit_typenum[i] = tmp[0];
      unit_id[i] = tmp[1];
   }
   var key = new RegExp(number,'i');
   for (i=0; i<arr.length; i++)
   {
      //
      // If there is no obstacle for the change and we are actually
      //    comparing an unit_type against the unit_type_num that the
      //    user wants to change to
      //
      if (unit_typenum[i].match(key) == null && unit_typenum[0] > 0 )
      {
         key = new RegExp("pfp_comp:",'i');
 
         //
         // Loop through all the elements in the page, looking for
         //    comp:pfp_unit_type_num.
         //    The reason we have to do it this way is because
         //    accessing comp:pfp_unit_type_num results in an error.
         //    It errors because it misinterprets the ":"
         //
         for (ii=0,jj=0; ii<f.elements.length; ii++)
         {
            if (f.elements[ii].name.match(key) == null) continue;

            tmp = f.elements[ii].name.split(":");

            //
            // Since the component is linked to an active unit, do not
            //    allow the user to make the component inactive
            //
            if ( tmp[1] == 'pfp_unit_type_num' )
            {
               alert('Component unit_type cannot be changed because it is part of units(s): '+unit_id[i]);
               f.elements[ii].value = type_num;
               return;
            }
         }
      }
   }
}


function ActiveStatus(number)
{
   //
   // Used for checking if the user is trying to make a component inactive when
   //    it is linked to a active component
   //
   f = document.mainform;

   arr = activecomps.split("\|");
   active_comp = new Array();
   active_unit = new Array();

   //
   // Create two arrays, one is an array of active components that are linked to
   //    active units. The other array is an array of the active units that
   //    the component is linked to.
   //
   for (i=0; i<arr.length; i++)
   {
      tmp = arr[i].split("~");
      active_comp[i] = tmp[0];
      active_unit[i] = tmp[1];
   }
   var key = new RegExp(number,'i');
   for (i=0; i<arr.length; i++)
   {
      //
      // If the user is trying to change the status of a component and
      //    it is linked to at least one active unit
      //
      if (active_comp[i].match(key) != null)
      {
         key = new RegExp("pfp_comp:",'i');
 
         //
         // Loop through all the elements in the page, looking for
         //    comp:active_status_num or unit:active_status_num.
         //    The reason we have to do it this way is because
         //    accessing comp:active_status_num results in an error.
         //    It errors because it misinterprets the ":"
         //
         for (ii=0,jj=0; ii<f.elements.length; ii++)
         {
            if (f.elements[ii].name.match(key) == null) continue;

            tmp = f.elements[ii].name.split(":");

            //
            // Since the component is linked to an active unit, do not
            //    allow the user to make the component inactive
            //
            if ( tmp[1] == 'active_status_num' )
            {
               alert('Component cannot be made inactive because it is \npart of unit(s): '+active_unit[i]);
               f.elements[ii].value = 1;
               return;
            }
         }
      }
   }
}

function AddCB(type)
{
   f = document.mainform;

   if (!confirm("Are you sure?")) return;

   if (SaveData(type))
   {

      f.task.value = 'add';

      f.submit();
   }
}

function BackCB()
{
   //
   // If the user clicks on the Back button
   //
   f = document.mainform;

   f.task.value = '';
   f.unitid.value = '';
   f.compnum.value = '';
   f.unitlist.selectedIndex = -1;
   f.complist.selectedIndex = -1;
   
   f.submit();
   
}

function ClearCB(type)
{
   //
   // Clears the form
   //
   f = document.mainform;

   key = new RegExp(type+":",'i');
   //alert(key);
   for (ii=0,jj=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;

      f.elements[ii].value = '';
      jj++;
   }
}

function UpdateCB(type)
{
   f = document.mainform;

   if (f.unitid.value == '' && f.compnum.value == '') return;

   if (!confirm("Are you sure?")) return;

   if (SaveData(type))
   {
      f.task.value = 'update';
      f.submit();
   }
}

function SaveData(type)
{
   //
   // Saves the data server side so that we can access it after the page submits
   //
   f = document.mainform;

   if (f.unitid.value == '' && f.compnum.value == '') return;
                                                                                          
   a = '';
   key = new RegExp(type+":",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      //
      // Disallow use of '~' and '|'
      //
      if (f.elements[ii].value.match(/\~/) != null)
      { f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return; }                                                                                           
      if (f.elements[ii].value.match(/\|/) != null)
      { f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return; }
                                                                                          
      tmp = f.elements[ii].name.split(":");

      if ( tmp[1] == 'id' && f.elements[ii].value == '' )
      {
         alert("No Equipment ID specified");
         return 0;
      }

      z = tmp[1] + "~" + f.elements[ii].value;
      a += (a == '') ? z : "|" + z;
   }

   //
   // Depending on if the user selected an unit or component, save
   //    the data in the appropriate place
   //
   f.comp_info.value = "";
   f.unit_info.value = "";
   switch (type)
   {
      case 'pfp_unit':
         f.unit_info.value = a;
         break;
      case 'pfp_comp':
         f.comp_info.value = a;
         break;
      default:
         return 0;
         break;
   }

   return 1;
}

function SetBackground(element,state)
{
	color = (state) ? 'paleturquoise' : 'white';
	element.style.backgroundColor=color;
}

