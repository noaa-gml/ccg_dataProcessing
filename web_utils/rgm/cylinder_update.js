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

  $('#cylinder_id').keydown(
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

   if ( ! CYLINDER_ID_PATTERN.test(dataaarr['cylinder_id']) )
   {
      alert("Please input a valid cylinder ID.");
      f.cylinder_id.focus();
      return false;
   }

   SetValue('task', 'search');

   f.submit();
}
