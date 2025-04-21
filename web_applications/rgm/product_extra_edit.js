var productinfo = [];

function SubmitCB(task)
{
   var f = document.mainform;

   if ( ! confirm('Are you sure you want to '+task+'?') )
   { return false; }

   f.productinfostr.value = encodeURIComponent(php_serialize(productinfo));
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

   if ( tmpid.match(/^calrequest[0-9]+$/) )
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

function CalServiceSelect(chkbox_element)
{
   var idarr = chkbox_element.id.split('_');

   var tmpidarr = idarr.splice(0,1);
   var tmpid = tmpidarr.join('_');

   var disabled;

   //alert(tmpid);
   if ( $(chkbox_element).prop("checked") == true )
   {
      SetValue(chkbox_element.id, '1', productinfo);
      disabled = false;
   }
   else
   {
      SetValue(chkbox_element.id, '0', productinfo);
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
