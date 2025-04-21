function ClearChk(element)
{
   if ( element.value.search(/\`/i) > -1 ) element.value = '';
}

function SearchCB()
{

   var f = document.mainform;

   if ( f.id.value == '' && f.sitelist.selectedIndex == -1 && f.search4code.value == '' ) return false;

   if ( f.search4code.value != '' )
   {
      f.sitelist.selectedIndex = -1;
      str = f.search4code.value.toUpperCase();

      for ( i=0; i<f.sitelist.length; i++ )
      {
         if ( f.sitelist[i].value == str )
         { f.sitelist.selectedIndex=i; }
      }

      if ( f.sitelist.selectedIndex == -1 )
      {
         alert("No site match");
         return false;
      }
   }

   f.code.value = f.sitelist[f.sitelist.selectedIndex].value;

   f.submit();

}

function EditCB(info)
{
   var f = document.mainform;

   var tmp = info.split(/\|/);

   f.id.value = tmp[0];
   f.code.value = tmp[1];
   f.date_out.value = tmp[2];
   f.date_in.value = tmp[3];

   f.action = omurl+'gen/gen_shipinfo.php?invtype='+f.invtype.value;
   f.submit();
}
