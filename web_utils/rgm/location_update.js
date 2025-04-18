var dataaarr = [];

$(document).ready(function()
{
  $("input[type=text], select").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $(this).val());
     }
  );

  $('#search_string').keydown(
     function (e)
     {
        var keyCode = e.keyCode || e.which;

        if (keyCode == 13)
        {
           SetValue($(this).attr('id'), $(this).val());
           SearchCB();
           return false;
        }
     }
  );

});

function SetValue(name, value)
{
   var f = document.mainform;

   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

function SearchCB()
{
   var f = document.mainform;

   var search_string_patt=/[A-Za-z0-9]/;
   if ( dataaarr['search_string'] == '' )
   {
      alert("Please input a valid search string.");
      f.search_string.focus();
      return false;
   }

   SetValue('task', 'search');

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));

   f.submit();
}
