var dataaarr = [];

function SetValue(name, value)
{
   var f = document.mainform;

   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

function SubmitCB()
{
   var f = document.mainform;

   var productnumarr = [];
   var idfields;

   $("input[type=checkbox][id^='product'][id$='_selection']").each( function ()
   {
      idfields = $(this).attr('id').split('_');
      productnum = idfields[0].replace('product', '');

      if ( $(this).prop("checked") == true )
      { productnumarr.push(productnum); }
   });

   // Throw an error if there are no selections
   if ( productnumarr.length == 0 )
   {
      alert("Please make at least one selection.");
      return false;
   }

   SetValue('productnumarr', productnumarr);

   SetValue('task', 'submit');

   f.submit();
}
