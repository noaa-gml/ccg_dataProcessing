var siteinfo;

function SubmitCB()
{
	f = document.mainform;

	f.code.value = f.selectsite[f.selectsite.selectedIndex].value;
	f.project.value = f.selectproject[f.selectproject.selectedIndex].text;

	if (f.code.value == '') return;
	if (f.selectproject[f.selectproject.selectedIndex].value == '') return;

        f.task.value = 'showinfo';

        f.submit();
}

function ListSelectCB(list)
{
   alert(list.value);
}

function ResetCB()
{
	f = document.mainform;

	f.code.value = '';
	f.project.value = '';
	f.submit();
}

function SelectProjectCB()
{
	f = document.mainform;
	f.project.value = f.selectproject[f.selectproject.selectedIndex].text;

	f.submit();
}

function SetOptions()
{
   f = document.mainform;
                                                                                          
   allow.level = GetAccessLevel(allow.user, allow.ccg);
                                                                                          
   if ( !allow.level )
   {
      var offarr = new Array(3)
      offarr[0] = 'site_coop';
      offarr[1] = 'site_shipping';

      for ( i = 0; i < offarr.length; i++ )
      {
         a = ''
         key = new RegExp(offarr[i],'i');
                                                                                          
         for (ii=0,jj=0; ii<f.elements.length; ii++)
         {
            if (f.elements[ii].value.match(key) == null) continue;

            f.elements[ii].checked = false;
            f.elements[ii].disabled = true;
         }
      }
   }
}
