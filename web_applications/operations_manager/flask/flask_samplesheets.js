function SampleSheetCB()
{
   var f = document.mainform;
   var tmp = f.sitelist[f.sitelist.selectedIndex].value.split(/~/);
   f.code.value = tmp[0];
   f.proj_abbr.value = tmp[1];
   f.submit();
}
