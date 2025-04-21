var string_value_patt=/[^ \n\r]/;
var dataaarr = [];

$(document).ready(function()
{
  $("input[type=text], select, textarea").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $(this).val());
     }
  );
});

$(window).load(function()
{
   // Fire the onBlur event for all SELECT handles
   // on the page onece the page is done loading
   // This is so the value will be stored.
   $('input[type=text], select, textarea').each(function(){
     $(this).trigger('blur');
   });
});

function SetValue(name, value)
{
   var f = document.mainform;

   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

function SubmitCB()
{
   var f = document.mainform;

   if ( ! string_value_patt.test(dataaarr['location_name']) )
   {
      alert("Please input a location name.");
      f.location_name.focus();
      return false;
   }

   if ( ! string_value_patt.test(dataaarr['location_abbr']) )
   {
      alert("Please input a location abbreviation.");
      f.location_abbr.focus();
      return false;
   }

   if ( ! string_value_patt.test(dataaarr['location_address']) )
   {
      alert("Please input a location address.");
      f.location_address.focus();
      return false;
   }

   SetValue('task', 'save');

   f.submit();
}
