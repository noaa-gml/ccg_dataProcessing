function ListSelectCB(list)
{
   var f = document.mainform;

   // alert(list.name);
   if ( list.name == 'type' )
   {
      //
      // If the user selects a type of keyword then we want to:
      //    Fill the keyword selection list
      //    Set the value of selecttype on the webpage
      //    Show the keyword selection list
      //    Hide the keyword information table
      //    Hide the Clear button
      //
      FillSelect(list.value);
      f.selecttype.value = list.value;
      Visible('show','keylistid');
      Visible('hide','keywordid');
      Visible('hide','clearbtn');

      //
      // Clear the previously saved information when we change types
      //
      f.prev_selectkey.value = '';
      f.selectkey.value = '';
   }
   else
   {
      //
      // If the user selects from the keyword selection list then
      // save their previous keyword selection then update the current one.
      //
      f.prev_selectkey.value = f.selectkey.value;
      f.selectkey.value = list[list.selectedIndex].value;

      //
      // Also, fill the keyword table with information and then make it visible
      //
      FillTable(list[list.selectedIndex].value);
      Visible('show','keywordid');
   }
}

function FillTable(num)
{
   //
   // Fills the keyword information table
   //
   var f = document.mainform;

   if ( num != "Add" )
   {
      //
      // If we are not updating, make sure the Clear button is hidden
      // and the addupdate button says "Update"
      //
      Visible('hide','clearbtn');
      f.addupdate.value = "Update";

      //
      // Get the data about the selected keyword
      //

      // 1|1|Buzzing|Buzzing from fans
      arr = keys.split(/~/);

      //
      // This relies heavily on the fact that there are continuous key numbers
      // 1 to n, otherwise an error will occur. For example, key numbers 1, 2, 3, 4
      // will work, but key numbers 1, 3, 4, 5 will cause an error or
      // unexpected results. Key numbers being the num field in the flask_log_keyword
      // table. The reason for this is because the key numbers are used as
      // their index in the key information array
      //
      values = arr[num-1].split(/\|/);
   }
   else
   {
      //
      // If the user wants to add a keyword, make the Clear button visible
      // and change the addupdate button to say "Add"
      //
      Visible('show','clearbtn');
      f.addupdate.value = "Add";

      //
      // If there is no previous selected keyword, then fill in the table
      // with blanks except for keep the selected keyword type the same.
      // Otherwise fill in the data but change 'num' to blank because
      // that auto-increments when inserted into the table
      //
      if ( f.prev_selectkey.value != '' )
      {
         values = arr[f.prev_selectkey.value-1].split(/\|/);
         values[0] = "";
      }
      else
      {
         values = new Array("",f.selecttype.value,"","");
      }
   }

   //
   // Check to see if the keyword is associated with any logs. If it is
   // associated with a log or many logs, then only allow the user to
   // change the comments of the keyword
   //
   configchk = 0;
   countarr = keyscount.split(/~/);
   for ( k = 0; k<countarr.length; k++ )
   {
      tmp = countarr[k].split(/\|/);
      if ( tmp[0] == values[0] && tmp[1] > 0 )
      {
         configchk = 1;
      }
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

      key = new RegExp("flask_log_keyword:",'i');
      for (ii=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name.match(key) == null) continue;

         // flask_log_keyword:num
         names = f.elements[ii].name.split(/:/);
         if ( names[1] == tmp[0] )
         {
            // alert(f.elements[ii].name);
            if ( values[i] == undefined ) { values[i] = ''; }
            f.elements[ii].value = values[i];
            if ( configchk )
            {
               //
               // If the keyword is associated with one or more logs
               // then disable the field and make it gray (for IE)
               //
               if ( names[1] == 'comment_type_num' || names[1] == 'name')
               {
                  f.elements[ii].disabled = true;
                  f.elements[ii].style.backgroundColor='#E6E6E6';
               }
            }
            else
            {
               //
               // If the keyword is not associated with any log
               // then allow everything to be changed but the num
               //
               if ( names[1] != 'num' )
               {
                  f.elements[ii].disabled = false;
                  f.elements[ii].style.backgroundColor='#FFFFFF';
               }
            }
         }
      }
   }
}

function FillSelect(typenum)
{
   //
   // Fill the keyword selection list
   //
   var f = document.mainform;
   // alert(typenum);

   //
   // First, make sure that the selection list is empty
   //
   for ( j=0; j<f.keylist.length; j++ )
   {
      f.keylist.options[j] = null;
   }

   arr = keys.split(/~/);

   //
   // Always create the first option as "Add Keyword" 
   //
   f.keylist[0] = new Option("Add Keyword","Add",false,false);

   //
   // Add the rest of the keywords that have the same type as the
   // type of keyword selected by the user
   //
   count = 1;
   for ( i=0; i<arr.length; i++ )
   {
      tmp = arr[i].split(/\|/);
      if ( tmp[1] == typenum )
      {
         f.keylist[count] = new Option(tmp[2],tmp[0],false,false);
         f.keylist.options[count].className = 'MediumBlackN';
         count++;
      }
   }


}

function Execute(type)
{
   //
   // Determine if the user is trying to add or update
   //
   if ( f.addupdate.value == "Add" )
   {
      AddCB(type);
   }
   else
   {
      UpdateCB(type);
   }
   // alert(f.addupdate.value);
}

function AddCB(type)
{
   var f = document.mainform;

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
   var f = document.mainform;

   //
   // Reset the radio buttons too
   //
   for (counter = 0; counter < f.type.length; counter++)
   {
      if (f.type[counter].checked)
         f.type[counter].checked = false; 
   }

   //
   // Clear all the variables
   //
   f.task.value = '';
   f.prev_selectkey.value = '';
   f.selectkey.value = '';
   f.selecttype.value = '';

   //
   // Hide all the selection windows, tables, and buttons
   //
   Visible('hide','keylistid');
   Visible('hide','keywordid');
   Visible('hide','clearbtn');


}

function ClearCB(type)
{
   //
   // Clears the form
   //
   var f = document.mainform;

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
   var f = document.mainform;

   if ( f.selectkey.value == '' ) return;

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
   var f = document.mainform;
                                                                                          
   if ( f.selectkey.value == '' ) return;
                                                                                          
   a = '';
   key = new RegExp(type+":",'i');
   for (ii=0,jj=0; ii<f.elements.length; ii++)
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

      z = tmp[1] + "~" + f.elements[ii].value;
      a += (jj == 0) ? z : "|" + z;
      jj++;
   }

   f.key_info.value = a;

   return 1;
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}

function Visible(mode,name)
{
   //
   // Controls the visibility of items that have class "Hidden"
   //
   if ((navigator.appName.indexOf("Netscape") != -1 && parseInt(navigator.appVersion) < 5) ||(navigator.appName.indexOf("Microsoft") != -1 && parseInt(navigator.appVersion) < 4))
   { ; return; }
                                                                                          
   if (mode == 'show') { document.getElementById(name).style.visibility='visible'; }
   else { document.getElementById(name).style.visibility='hidden'; }
}

