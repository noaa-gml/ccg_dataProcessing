var dataaarr = [];

$(document).ready(function()
{
  $("input[type=text], input[type=hidden], select, textarea").blur(
     function()
     {
        //alert($(this).attr('id')+' '+$(this).val());
        SetValue($(this).attr('id'), $(this).val());
     }
  );
});

$(window).load(function()
{
   // Fire the onBlur event for all SELECT handles
   // on the page onece the page is done loading
   // This is so the value will be stored.
   $('input[type=text], input[type=hidden], select, textarea').each(function(){
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

   var cylinder_value_patt=/^[A-Za-z0-9\-]{3,}$/;
   if ( ! cylinder_value_patt.test(dataaarr['cylinder_id']) )
   {
      alert("Please input a valid cylinder ID.\nMust be at least three characters\nand may only contain\nalphanumerics and dashes.");
      f.cylinder_id.focus();
      return false;
   }

   fields = dataaarr['cylinder_recertification_date'].split('-',2);

   if ( fields[1] != undefined )
   {
      if ( parseInt(fields[1]) < 50 )
      { fields[1] = parseInt(fields[1])+2000; }
      else
      { fields[1] = parseInt(fields[1])+1900; }
   }

   if ( fields[0].length == 1 )
   {
      date_value = fields[1]+'-0'+fields[0]+'-01';
   }
   else
   {
      date_value = fields[1]+'-'+fields[0]+'-01';
   }

   var recertification_date_patt=/^[0-9]{2}\-[0-9]{2}$/;
   if ( ! recertification_date_patt.test(dataaarr['cylinder_recertification_date']) ||
        ( dataaarr['cylinder_recertification_date'] != '99-99' &&
        ! ValidDate(date_value) ) )
   {
      alert("Please input a valid DOT date.\nFormat: MM-YY.");
      f.cylinder_recertification_date.focus();
      return false;
   }

   SetValue('task', 'save');

   f.input_data.value = encodeURIComponent(php_serialize(dataaarr));

   f.submit();
}
