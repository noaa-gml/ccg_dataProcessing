function ListSelectCB(list)
{
   //
   // Different actions based on which list the user selects
   //

   f = document.mainform;
                                                                                          
   if ( list.name == 'sitelist' )
   {
      f.sitecode.value = f.sitelist[f.sitelist.selectedIndex].value;
   }
   if ( list.name == 'datelist' )
   {
      f.date.value = f.datelist[f.datelist.selectedIndex].value;
   }

   if ( list.name == 'imagelist' )
   {
      f.images.value = '';
      for ( i = 0; i < f.imagelist.length; i++ )
      {
         if ( f.imagelist[i].checked )
         {
            if ( f.images.value == '' ) { f.images.value = f.imagelist[i].value; }
            else { f.images.value = f.images.value + "|" + f.imagelist[i].value; }
         }
      }

      //
      // If the user clicks on an image checkbox, something must have changed
      //
      f.changed.value = '1';
   }

   if ( list.name != 'imagelist' )
   {
      f.submit();
   }
}

function EditCB()
{
   //
   // When the user clicks on Edit, go into edit mode
   //
   f = document.mainform;

   f.editmode.value = '1';

   f.submit();
}

function UpdateCB()
{
   //
   // Set the task to update and send the user back to the current configuration page
   //
   f = document.mainform;

   if ( f.changed.value != '0' )
   {
      f.task.value = 'update';
      f.editmode.value = '0';

      f.submit();
   }
}

function ShowImageCB(image)
{
   //
   // Open the picture up through ac_images.php
   //
   var load = window.open('om_images.php?image='+image,'','scrollbars=yes,menubar=yes,height=600,width=800,resizable=yes,toolbar=yes,location=no,status=yes');
}

function DoneCB()
{
   //
   // If the user clicked done, send them back to the current configuration
   //    Prompt the user if there have been changes made to the page
   //
   f = document.mainform;

   if ( f.changed.value != '0' )
   {
      if (!confirm("Unsaved data will be lost. Okay?")) return;
   }

   f.editmode.value = '0';

   f.submit();
}

function BackCB()
{
   //
   // Send the user back to the page to select sites
   //
   f = document.mainform;

   f.sitecode.value = '';

   f.submit();
}
