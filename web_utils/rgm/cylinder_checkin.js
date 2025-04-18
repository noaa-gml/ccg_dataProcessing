var dataaarr = [];

$(document).ready(function()
{
  $("input[type=text], select").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $.trim($(this).val()));
     }
  );

  $("input[type=text], select").change(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $.trim($(this).val()));
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

function SubmitCB()
{
   var f = document.mainform;

   cylinder_count = 0;
   var cylinder_name_patt=/^cylinder[0-9]+$/;
   for (var name in dataaarr)
   {
      if (name.match(cylinder_name_patt) == null) continue;

      //alert(name);

      cylinder_id = dataaarr[name];
 
      if ( dataaarr[name] != '' )
      {
         if ( CYLINDER_ID_PATTERN.test(dataaarr[name]) )
         {
            cylinder_count++;
         }
         else
         {
            alert("Please provide a valid for "+name+".");
            cylinder_element = document.getElementById(name);
            cylinder_element.focus();
            return false;
         }
      }
   }

   if ( cylinder_count == 0 )
   {
      alert("Please provide a cylinder ID.");
      return false;
   }

   // Location comments are required if not INSTAAR
   if ( f.location_num.value != '7' )
   {
      var comment_value_patt = /[A-Za-z0-9]/;
      if ( ! comment_value_patt.test(dataaarr['location_comments']))
      {
         alert("Please provide valid additional location information.");
         f.location_comments.focus();
         return false;
      }
   }

   SetValue('task', 'submit');

   f.submit();
}
