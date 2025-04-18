function ListSelectCB(list)
{
   //
   // If the user selects a query from the query list
   //
   f = document.mainform;

   f.query.value = f.querylist[f.querylist.selectedIndex].value;
   
   f.submit();
}

function RunCB()
{
   //
   // Run the SQL command
   //
   f = document.mainform;

   //
   // Check to make sure that the command area is not blank
   //
   key = new RegExp("query:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
                                                                                          
      tmp = f.elements[ii].name.split(":");
      if ( tmp[1] == 'command' && f.elements[ii].value == '' )
      {
         alert("Must specify a SQL Query");
         return;
      }
   }

   // if (!confirm("Are you sure?")) return;
                                                                                          
   if (!SaveData()) return;

   f.task.value = 'run';
   f.submit();
}


function AddCB()
{
   //
   // Add query to the database
   //
   f = document.mainform;

   //
   // Check to make sure that there is a name for the query
   //    as well as a non-blank command
   //
   key = new RegExp("query:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;

      tmp = f.elements[ii].name.split(":");
      if ( tmp[1] == 'name' &&  f.elements[ii].value == '' )
      {
         alert("Must specify a Query Name");
         return;
      }
      if ( tmp[1] == 'command' && f.elements[ii].value == '' )
      {
         alert("Must specify a SQL Query");
         return;
      }
   }

   // if (!confirm("Are you sure?")) return;

   if ( f.user.value != f.username.value )
   {
      if (!confirm("A copy of this query will be saved under your username.")) return;
   }

   key = new RegExp("query:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if  (f.elements[ii].name.match(key) == null) continue;

      tmp = f.elements[ii].name.split(":");
      if ( tmp[1] == 'name' &&  f.elements[ii].value != '' )
      {
         if ( f.elements[ii].value != '' )
	 {
            queryname = f.elements[ii].value;
	 }
	 else
	 {
            queryname = "XXzXX3XXX3X5X6X";
	 }
	 continue;
      }
   }

   querieslist = queries.split("|");
   for (ii=0; ii<querieslist.length; ii++)
   {
      field = querieslist[ii].split(",");
      if ( queryname == field[0] && f.user.value == field[1] )
      {
         if (!confirm("Overwrite existing query?")) return;
      }
   }

   if (!SaveData()) return;

   f.task.value = 'add';
   f.submit();
}

function BackCB()
{
   //
   // If the user clicks back, clear all information
   //
   f = document.mainform;

   // if (!confirm("Are you sure?")) return;

   if ( f.query.value != '' )
   {
      ClearCB();
      f.task.value = '';
      //f.unitid.value = '';
      //f.unitlist.selectedIndex = -1;
      f.query.value = '';
      f.querylist.selectedIndex = -1;
      f.submit();
   }
   else { document.location = 'index.php'; }

   
}

function ClearCB()
{
   //
   // If the user clicks clear, clear all information
   //
   f = document.mainform;

   //if (!confirm("Are you sure?")) return;
   
   key = new RegExp("query:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      f.elements[ii].value = '';
   }

   f.query.value = '';

   f.submit();
                                                                                          
}

function DeleteCB()
{
   //
   // Deletes a query from the database
   //
   f = document.mainform;

   if ( f.user.value != f.username.value )
   {
      alert("Cannot delete a query created by another user");
      return;
   }
   //
   // Check to make sure that a query name was specified
   //
   key = new RegExp("query:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
                                                                                          
      tmp = f.elements[ii].name.split(":");
      if ( tmp[1] == 'name' &&  f.elements[ii].value == '' )
      {
         alert("Must specify a Query Name");
         return;
      }
   }

   if (!confirm("Are you sure?")) return;

   if (!SaveData()) return;

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
   //
   f = document.mainform;

   a = '';
   runquery = '';
   key = new RegExp("query:",'i');
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
                                                                                          
      tmp = f.elements[ii].name.split(":");
      if ( tmp[0] == 'name' && tmp[1] == '' )
      {
         alert("Must specify a Query Name");
         return 0;
      }
      else
      {
         name = tmp[0];
      }
      if ( tmp[1] == 'command' )
      {
         if ( f.elements[ii].value == '' )
         {
            alert("Must specify a SQL Query");
            return 0;
         }
         else
         {
            command = f.elements[ii].value;
         }
      }

      z = tmp[1] + "~" + f.elements[ii].value;
      a += (a == '') ? z : "|" + z;
      jj++;
   }

   //
   // List of unallowed SQL commands
   //
   var unusable = new Array();
   unusable[0] = 'drop';
   unusable[1] = 'delete';
   unusable[2] = 'update';
   unusable[3] = 'replace';
   unusable[4] = 'create';
   unusable[5] = 'alter';
   unusable[6] = 'grant';
   unusable[7] = 'flush';
   unusable[8] = 'kill';
   unusable[9] = 'load';
   unusable[10] = 'optimize';
   unusable[11] = 'lock';
   unusable[12] = 'revoke';
   unusable[13] = 'insert';

   //
   // Loop through all the unallowed SQL commands to see if any are in the
   //    input command string. If there are, then we should alert the user
   //    and return
   //
   for (ii=0; ii<unusable.length; ii++)
   {
      key = new RegExp(unusable[ii],'i');
      if (command.match(key) != null)
      {
         alert("Not a valid SQL query command");
         return 0;
      }
   }

   //
   // List of allowed SQL commands
   //
   var usable = new Array();
   usable[0] = 'describe';
   usable[1] = 'explain';
   usable[2] = 'select';
   usable[3] = 'show';
   usable[4] = 'use';

   //
   // Loop through the allowed SQL commands, we need to make sure that at
   //    least one of them were used in the query
   //
   j = 0;
   for (ii=0; ii<usable.length; ii++)
   {
      key = new RegExp(usable[ii],'i');
      if (command.match(key) != null)
      {
        j = j + 1;
      }
   }

   //
   // If none of the allowed SQL commands were in the SQL query, then
   //    alert and return
   //
   if ( j == 0 )
   {
      alert("Not a valid SQL query command");
      return 0;
   }

                                                                                          
   //
   // After making sure that the data is safe, save the date in
   //    the appropriate place
   //
   f.newqueryinfo.value = a;
   f.query.value = name;

   return 1;
}
