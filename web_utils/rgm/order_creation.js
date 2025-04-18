var orderinfo = [];

function SubmitCB(task)
{
   var f = document.mainform;

   if ( task == 'submit' ||
        task == 'pending' )
   {
      if ( ! confirm('Are you sure you want to '+task+'?') )
      { return false; }
   }
   else if ( task === 'product_add' )
   {
      if ( ! ValidInt($('#product_add_number').val()) )
      {
         alert("Please provide valid integer\nfor number of products to add.");
          $('#product_add_number').val('1');
         return false;
      } 
      else
      {
         if ( $('#product_add_number').val() < 1 ||
              $('#product_add_number').val() > 100 )
         {
            alert("Number of products to add must be between 1 and 100.");
             $('#product_add_number').val('1');
            return false;
         }
      }
   }

   f.orderinfostr.value = php_urlencode(php_serialize(orderinfo));
   f.task.value = task;
   f.submit();
}

function SetValue(id, value, info)
{
   var f = document.mainform;

   // If the user passed in an ID that doesn't currently exist,
   //   SetValue() should not be successful. The structure
   //   should already exist before the call into SetValue().

   var idarr = id.split('_');

   var tmpid = idarr.shift();

   var newid = idarr.join('_');

   var tmpinfo;

   //alert(id+' '+value);

   if ( tmpid.match(/^product[0-9]+$/) )
   {
      var productnum = tmpid.replace(/^product/, '');
      tmpinfo = info['products'][productnum];

      SetValue(newid, value, tmpinfo);
   }
   else if ( tmpid.match(/^calrequest[0-9]+$/) )
   {
      var calrequestnum = tmpid.replace(/^calrequest/, '');
      tmpinfo = info['calrequests'][calrequestnum];

      SetValue(newid, value, tmpinfo);
   }
   else
   {
      info[id] = value;
   }
}

function ProductDelete(element)
{
   var f = document.mainform;

   var idarr = element.id.split('_');

   var tmpid = idarr.shift();

   var productnum = tmpid.replace(/^product/, '');
   productnum = productnum.replace(/_delete$/, '');

   if ( orderinfo['products'].length > 1 )
   {
      // Remove this element from the array
      orderinfo['products'].splice(productnum, 1);

      SubmitCB('');
   }
}

function CalServiceSelect(chkbox_element)
{
   var idarr = chkbox_element.id.split('_');

   var tmpidarr = idarr.splice(0,2);
   var tmpid = tmpidarr.join('_');

   var disabled;

   //alert(tmpid);
   if ( $(chkbox_element).prop("checked") == true )
   {
      SetValue(chkbox_element.id, '1', orderinfo);
      disabled = false;
   }
   else
   {
      SetValue(chkbox_element.id, '0', orderinfo);
      disabled = true;
   }

   $('input[type=text][id^='+tmpid+'_], input[type=hidden][id^='+tmpid+'_], input[type=radio][id^='+tmpid+'_], select[id^='+tmpid+'_]').each(
      function ()
      {
         $(this).prop('disabled', disabled);
         //alert($(this).attr('id'));

         $(this).trigger('blur');
      }
   );

   // Process this after input type=text boxes because in the Target Value,
   //   the Ambient radio button is before the target-value textbox
   //   so if we processed the textbox last then we would never get the
   //   target value of 'ambient'
   $('input[type=radio][id^='+tmpid+'_]').each(
      function ()
      {
         $(this).prop('disabled', disabled);
         //alert($(this).attr('id'));

         // Only fire if the option is selected
         if ( $(this).prop("checked") == true )
         { $(this).trigger('click') ;}
      }
   );
}
