var productinfos = [];

function SubmitCB(task)
{
   var f = document.mainform;

   f.productinfosstr.value = php_serialize(productinfos);
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
      tmpinfo = info[productnum];

      SetValue(newid, value, tmpinfo);
   }
   else
   {
      info[id] = value;
   }

   f.productinfosstr.value = php_serialize(productinfos);
}
