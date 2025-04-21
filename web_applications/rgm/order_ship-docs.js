var dataaarr = [];

function UploadCB()
{
   var f = document.mainform;

   if ( f.file1.value != '' ||
        f.file2.value != '' ||
        f.file3.value != '' )
   {
      SetValue('task', 'upload');

      f.submit();
   }
}

function RemoveFileCB(file)
{
   var f = document.mainform;

   if ( confirm("Are you sure you want to remove file\n '"+file+"'?\n\nIt will be permanently deleted.") )
   {
      SetValue('file', file);
      SetValue('task', 'remove');

      f.submit();
   }
}

function SetValue(name, value)
{
   var f = document.mainform;
   
   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

