var dataaarr = [];

function SetValue(name, value)
{
   var f = document.mainform;

   dataaarr[name] = value;

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));
}

function GetValue(name)
{
   return dataaarr[name];
}

function SubmitCB()
{
   var f = document.mainform;
   var changecount = 0;

   // This handles the cases of:
   //   product<num>_calrequest<num>_selection
   //   product<num>_selection - when there are no calrequests
   //
   $("select[id^='product'][id$='_selection']").each( function ()
   {
      var idfields = $(this).attr('id').split('_');

      if ( $(this).val() != '' )
      {
         if ( $(this).val() == 'approve' ||
              $(this).val() == 'to_processing' )
         {
            // Set the status of the product
            //  if we are approving or sending
            //  back to processing.

            SetValue(idfields[0], $(this).val());
         }

         changecount++;
      }
   });

   // Throw an error if there are no selections
   if ( changecount == 0 )
   {
      alert("Please make at least one selection.");
      return false;
   }

   SetValue('task', 'submit');

   f.submit();
}
