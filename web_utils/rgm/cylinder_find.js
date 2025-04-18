$(document).ready(function()
{
  $('#cylinder_id').keydown(
     function (e)
     {
        var keyCode = e.keyCode || e.which;

        if (keyCode == 13)
        {
           $(this).trigger('blur');
           SubmitCB();
           return false;
        }
     }
  );
});

function SubmitCB()
{
   var f = document.mainform;

   if ( ! CYLINDER_ID_PATTERN.test(f.id.value) )
   {
      alert("Please input a valid cylinder ID.");
      f.id.focus();
      return false;
   }

   f.submit();
}
