var dataaarr = [];

$(document).ready(function()
{
  $("#due-date_string1, #creation-date_string1").blur(
     function()
     {
        if ( $(this).val() == '' )
        { $(this).val('1900-01-01'); }
     }
  );

  $("#due-date_string2, #creation-date_string2").blur(
     function()
     {
        if ( $(this).val() == '' )
        { $(this).val('9999-12-31'); }
     }
  );

  $("input[type=text], select").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $(this).val());
     }
  );

  // Submit the page if the user presses the carriage return in a text box
  $("input[type='text']").keydown(
     function (e)
     {
        var keyCode = e.keyCode || e.which;
      
        if (keyCode == 13)
        {
           $(this).trigger('blur');
           SearchCB();
           return false;
        }
     }
  );

});

$(window).load(function()
{
   // Fire the onBlur event for all SELECT handles
   // on the page onece the page is done loading
   // This is so the value will be stored.
   $('input[type=text], select').each(function(){
     $(this).trigger('blur');
   });
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

   if ( dataaarr['num_string'] == '' &&
        dataaarr['customer_string'] == '' &&
        dataaarr['organization_string'] == '' &&
        dataaarr['cylinder_string'] == '' &&
        dataaarr['calservice_num'] == '' &&
        dataaarr['due-date_string1'] == '1900-01-01' &&
        dataaarr['due-date_string2'] == '9999-12-31' &&
        dataaarr['creation-date_string1'] == '1900-01-01' &&
        dataaarr['creation-date_string2'] == '9999-12-31' &&
        dataaarr['comments_string'] == '' )
   {
      alert("Please input at least one constraint.");

      return false;
   }

   SetValue('task', 'search');

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));

   f.submit();
}
