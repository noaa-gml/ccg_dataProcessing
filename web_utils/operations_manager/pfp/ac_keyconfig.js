function ListSelectCB(list)
{
   //
   // Different actions based on which list the user selects
   //

   f = document.mainform;
                                                                                          
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
   // Sends the user to edit mode
   //
   f = document.mainform;

   f.editmode.value = '1';

   f.submit();
}

function ShowImageCB(image)
{
   //
   // Open the picture up through ac_images.php
   //
   var load = window.open('ac_images.php?image='+image,'','scrollbars=yes,menubar=yes,height=600,width=800,resizable=yes,toolbar=yes,location=no,status=yes');
}

function UpdateCB()
{
   f = document.mainform;

   if ( f.changed.value != '0' )
   {
      f.task.value = 'update';
      f.editmode.value = '0';

      f.submit();
   }
}

function DoneCB()
{
   f = document.mainform;

   if ( f.changed.value != '0' )
   {
      if (!confirm("Unsaved data will be lost. Okay?")) return;
   }

   f.task.value = '';
   f.editmode.value = '0';

   f.submit();
}
