function CloseCB()
{
   //
   // If the user clicks back, clear all information
   //
   f = document.mainform;

   if ( f.changed.value == 1 )
   {
      if (!confirm("Unsaved changes will be lost. Okay?")) return;
   }

   window.close();
}

function ClearCB()
{
   //
   // If the user clicks clear, clear all information
   //
   f = document.mainform;

   if ( f.comments.value != '' )
   {
      f.changed.value = '1';
   }

   f.comments.value = '';
}

function SaveCB()
{
   f = document.mainform;

   if ( f.changed.value == 1 )
   {
      f.task.value = 'save';
      f.submit();
   }
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}
