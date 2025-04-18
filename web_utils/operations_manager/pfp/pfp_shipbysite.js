function SiteListCB()
{
   var f = document.mainform;
   f.code.value = f.sitelist[f.sitelist.selectedIndex].value;
   f.submit();
}

function ProjListCB()
{
   var f = document.mainform;
   var j = f.projlist.selectedIndex;
   f.proj_abbr.value = f.projlist[j].value;
   f.code.value = '';
                                                                                          
   f.submit();
}
