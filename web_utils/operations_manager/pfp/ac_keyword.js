function ListSelectCB(list)
{
   f = document.mainform;

   if ( list.name == 'keylist' )
   {
      f.selectkey.value = list[list.selectedIndex].value;

      FillTable(list[list.selectedIndex].value);
   }
}

function FillTable(num)
{
   //
   // Fills the keyword information table
   //
   f = document.mainform;

   if ( num != "Add" )
   {
      //
      // If we are not updating, make sure the Clear button is hidden
      // and the addupdate button says "Update"
      //
      f.addupdate.value = "Update";

      //
      // Get the data about the selected keyword
      //

      // 1|1|Buzzing|Buzzing from fans
      arr = keys.split(/~/);

      for ( i=0; i<arr.length; i++ )
      {
         tmp = arr[i].split(/\|/);
         if ( tmp[0] == num )
         {
            values = tmp;
         }
      }
   }
   else
   {
      f.addupdate.value = "Add";
      values = new Array();
   }

   //
   // Loop through all the elements of the webpage looking
   // for the table elements so that we can assign their
   // value to the information we want.
   //
   fields = tablefields.split(/~/);
   for ( i=0; i<fields.length; i++ )
   {
      // num|smallint|5
      tmp = fields[i].split(/\|/);

      key = new RegExp("info:",'i');
      for (ii=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name.match(key) == null) continue;

         // psu_log_key:num
         names = f.elements[ii].name.split(/:/);
         if ( names[1] == tmp[0] )
         {
            // alert(f.elements[ii].name);
            if ( values[i] == undefined ) { values[i] = ''; }
            f.elements[ii].value = values[i];

            if ( names[1] != 'num' )
            {
               f.elements[ii].disabled = false;
               f.elements[ii].style.backgroundColor='#FFFFFF';
            }
         }
      }
   }
}

function ExecuteCB()
{
   f = document.mainform;

   //
   // Determine if the user is trying to add or update
   //
   if ( f.addupdate.value == "Add" )
   {
      AddCB();
   }
   else
   {
      UpdateCB();
   }
   // alert(f.addupdate.value);
}

function AddCB()
{
   f = document.mainform;

   f.selectkey.value = "Add";

   if (SaveData())
   {
      if (!confirm("Are you sure?")) return;

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

   if ( f.task.value == '' && f.selectkey.value == '' )
   {
      document.location = 'pfp_blank.php'; 
   }
   else
   {
      //
      // Clear all the variables
      //
      f.task.value = '';
      f.selectkey.value = '';

   }
   f.submit();
}

function ClearCB()
{
   //
   // Clears the form
   //
   f = document.mainform;

   key = new RegExp("info:",'i');
   //alert(key);
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;

      if ( !(f.elements[ii].disabled) )
      {
         f.elements[ii].value = '';
      }
   }
}

function UpdateCB()
{
   f = document.mainform;

   if ( f.selectkey.value == '' ) return;

   if (SaveData())
   {
      if (!confirm("Are you sure?")) return;
      f.task.value = 'update';
      f.submit();
   }
}

function SaveData()
{
   //
   // Saves the data server side so that we can access it after the page submits
   //
   f = document.mainform;

   if ( f.selectkey.value == '' ) return;
                                                                                          
   a = '';
   key = new RegExp("info:",'i');
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
                                                                                          
      tmp = f.elements[ii].name.split(/:/);

      if ( tmp[1] == 'num' ) continue;

      if ( tmp[1] == 'name' )
      {
         field = f.elements[ii].value.replace(/\s+/, "");
         if ( field == '' )
         {
            alert("Please input a keyword name");
            f.elements[ii].value = '';
            return;
         }
      }

      z = tmp[1] + "~" + f.elements[ii].value;
      a += ( a == '' ) ? z : "|" + z;
   }

   
   f.key_info.value = a;

   return 1;
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}
