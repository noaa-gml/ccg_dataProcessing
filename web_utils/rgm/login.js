$(document).ready(function()
{
  $('#pw').keydown(
     function (e)
     {
        var keyCode = e.keyCode || e.which;

        if (keyCode == 13)
        {
           SubmitCB();
           return false;
        }
     }
  );
});

function SubmitCB()
{
   var f = document.mainform;

   f.submit();
}
