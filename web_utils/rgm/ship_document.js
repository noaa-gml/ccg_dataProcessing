var request;
var inputdataaarr = [];

$(document).ready(function()
{
   $("#location_num").change(
      function()
      {

       var datastring = "num="+encodeURIComponent($(this).val());

       // fire off the request to /form.php
       request = $.ajax({
           url: "./location_get_address.php",
           type: "get",
           data: datastring,
           success: function(data) {
              //alert(data+ 'worked');//     does nothing
              $("#ship_to").html(data);
           }
       });
      }
   );
});

$(window).load(function()
{
   $("#location_num").trigger('change');
});

$(function() {
   $ ( "#date_shipped" ).datepicker( { dateFormat: "mm/dd/y" });
});

function SubmitCB()
{
   var f = document.mainform;
   $("input[type=text], select, textarea").each(
      function()
      {
         if ( $(this).val() != '' )
         {
            inputdataaarr[$(this).attr('id')] = $(this).val();
         }
         else
         {
//            alert($(this).attr('title')+' must be provided.');
//            $(this).focus();
//            return false;
         }
      }
   );

   inputdataaarr['task'] = 'submit';

   $('#inputdatastr').val(encodeURIComponent(php_serialize(inputdataaarr)));

   f.submit();
}


