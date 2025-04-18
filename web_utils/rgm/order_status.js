var dataaarr = [];

function CompleteCB()
{
   var f = document.mainform;

   if ( ! confirm("Are you sure you want to complete order?") )
   { return false; }

   SetValue('task', 'complete');

   f.submit();
}

function SetValue(name, value)
{
   var f = document.mainform;
   
   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

