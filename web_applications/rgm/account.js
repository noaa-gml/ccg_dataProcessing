var dataaarr = [];

$(document).ready(function()
{
  $("input[type=text], input[type=password], select, textarea").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $(this).val());
     }
  );
});

$(window).load(function()
{
   // Fire the onBlur event for all specified handles
   // on the page onece the page is done loading
   // This is so the value will be stored.
   $('input[type=text], input[type=password], select, textarea').each(function(){
     $(this).trigger('blur');
   });
});

function SetValue(name, value)
{
   var f = document.mainform;

   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

function ChangePasswordCB()
{
   // Function to save the details in order to change
   //  user password
   var f = document.mainform;

   // Current password is required
   if ( dataaarr['curpwd'] == '' )
   {
      alert("Please provide your current password");
      f.curpwd.focus();
      return false;
   }

   // New password is required
   if ( dataaarr['newpwd1'] == '' )
   {
      alert("Please provide a new password");
      f.newpwd1.focus();
      return false;
   }

   // New password a second time
   if ( dataaarr['newpwd2'] == '' )
   {
      alert("Please provide a verification new password");
      f.newpwd2.focus();
      return false;
   }

   // Set the task
   SetValue('task', 'change_password');

   // Save the input data
   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));

   // Submit the page
   f.submit();
}
