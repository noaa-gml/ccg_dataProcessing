function ListSelectCB(list)
{
   f = document.mainform;
                                                                                          
   if ( list.name == 'sitelist' )
   {
      f.sitecode.value = f.sitelist[f.sitelist.selectedIndex].value;
      f.task.value = '';
   }

   f.submit();
}

function ViewFile(file)
{
   f = document.mainform;

   f.filename.value = file;
   f.task.value = 'view';
   f.submit();
   
}

function BackCB()
{
   f = document.mainform;
   f.filename.value = '';
   f.task.value = '';
   f.submit();
}
