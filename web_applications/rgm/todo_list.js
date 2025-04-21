var dataaarr = [];

function SubmitCB()
{
   var f = document.mainform;

   var size = 0;
   var key;

   // Count the number of elements in the dataaarr
   //  We have to use a special count because
   //  it is an object not an array
   for (key in dataaarr) {
       if (dataaarr.hasOwnProperty(key)) size++;
   }

   if ( size > 0 )
   {
      SetValue('task', 'complete', dataaarr);

      //
      // Unset the beforeunload function as we are submitting the page
      //
      $(window).unbind('beforeunload');

      f.submit();
   }
   else
   {
      alert("Please provide at least one analysis results to be submitted.");
      return false;
   }
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

   // alert(id+' '+value);

   if ( tmpid.match(/^calrequest[0-9]+$/) )
   {
      var calrequestnum = tmpid.replace(/^calrequest/, '');

      if ( info[calrequestnum] == undefined )
      {
         info[calrequestnum] = [];
      }

      tmpinfo = info[calrequestnum];

      SetValue(newid, value, tmpinfo);
   }
   else
   {
      info[id] = value;
   }

   f.input_data.value = encodeURIComponent(php_serialize(info));
}

