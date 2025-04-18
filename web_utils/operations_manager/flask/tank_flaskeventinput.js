var nflasks;
var infoaarr = new Array();

function OkayCB()
{
   var f = document.mainform;

   GetInfo();

   if ( infoaarr['path'] == undefined ||
        infoaarr['path'] == '' )
   {
      if ( ! confirm("No measurement path set. Are you sure?") )
      { return; }
   }

   f.infostr.value = php_serialize(infoaarr);

   f.task.value = 'ok';
   f.submit();
}

function EditCB()
{
   var f = document.mainform;

   dateobj = document.getElementById('date');
   timeobj = document.getElementById('time');
   commentobj = document.getElementById('comment');
   dateobj.disabled = false;
   timeobj.disabled = false;
   commentobj.disabled = false;
}

function CancelCB()
{
   document.location = 'tank_flaskcheckin.php';
}

function GetInfo()
{
   var f = document.mainform;

   dateobj = document.getElementById('date');
   timeobj = document.getElementById('time');
   methodobj = document.getElementById('method');
   commentobj = document.getElementById('comment');
   var pathid = new RegExp("path:");
   //alert(dateobj.value);
   //alert(timeobj.value);

   patharr = new Array();
   var count = 0;
   for ( jj=0; jj<f.elements.length; jj++ )
   {
      if ( f.elements[jj].id.match(pathid) == null ) continue;

      if ( f.elements[jj].selectedIndex > 0 )
      {
         for ( kk=0; kk < f.elements[jj].length; kk++ )
         {
            if ( f.elements[jj].options[kk].selected )
            {
               patharr[count] = f.elements[jj].options[kk].value;
               count++;
            }
         }
      }
   }


   infoaarr['date'] = dateobj.value;
   infoaarr['time'] = timeobj.value;
   infoaarr['method'] = methodobj.value;
   infoaarr['path'] = patharr.join(',');
   infoaarr['comment'] = commentobj.value;
}
