var siteinfo;
var sitelist = new Array();

function SubmitCB()
{
   f = document.mainform;
   f.code.value = f.selectsite[f.selectsite.selectedIndex].value;
   f.proj_num.value = f.selectproject[f.selectproject.selectedIndex].value;
   f.strat_num.value = f.selectstrategy[f.selectstrategy.selectedIndex].value;

   if ( f.code.value == '' ) return;
   if ( f.selectproject[f.selectproject.selectedIndex].value == '' ) return;
   if ( f.selectstrategy[f.selectstrategy.selectedIndex].value == '' ) return;
   if ( f.selectstrategy.disabled == true ) return;
   if ( f.selectsite.disabled == true ) return;

   f.action = 'om_tables_list_siteinfo.php';
   //window.open('om_tables_list_siteinfo.php','','scrollbars=yes,menubar=yes,resizeable=yes,width=600,height=800');
   f.submit();
}

function ResetCB()
{
   f = document.mainform;

   f.code.value = '';
   f.proj_num.value = '';
   f.strat_num.value = '';
   f.selectproject.selectedIndex = 0;
   f.selectstrategy.selectedIndex = 0;
   f.selectsite.selectedIndex = 0;

   SelectProjectCB();

}

function SelectProjectCB()
{
   var f = document.mainform;

   // f.code.value = '';
   f.proj_num.value = f.selectproject[f.selectproject.selectedIndex].value;

   num1 = f.proj_num.value;

   if ( sitelist[num1] == undefined )
   {
      f.selectstrategy.disabled = true;
      f.selectsite.disabled = true;
   }
   else
   {
      f.selectstrategy.disabled = false;
      f.selectsite.disabled = false;
      for ( i=0; i<f.selectstrategy.length; i++ )
      {
         num2 = f.selectstrategy[i].value;
         // alert(sitelist[num1][num2].length);
         if ( sitelist[num1][num2] == undefined )
         { f.selectstrategy.options[i].className = 'LargeLightGrayN'; }
         else
         { f.selectstrategy.options[i].className = 'LargeBlackN'; }
      }

      for ( i=0; i<f.selectstrategy.length; i++ )
      {
         if ( f.selectstrategy.options[i].className == 'LargeBlackN' )
         {
            f.selectstrategy.options[i].selected = true;
            break;
         }
      }

      SelectStrategyCB();
   }
}

function SelectStrategyCB()
{
   f = document.mainform;

   num = f.selectstrategy.selectedIndex;
   if ( f.selectstrategy.options[num].className == 'LargeLightGrayN' )
   {
      for ( i=0; i<f.selectstrategy.length; i++ )
      {
         if ( f.selectstrategy[i].value == f.strat_num.value )
         { f.selectstrategy.options[i].selected = true; }
      }
      return false;
   }

   f.proj_num.value = f.selectproject[f.selectproject.selectedIndex].value;
   f.strat_num.value = f.selectstrategy[f.selectstrategy.selectedIndex].value;

   f.selectsite.options.length = 0;

   num1 = f.proj_num.value;
   num2 = f.strat_num.value;

   for ( i=0; i<sitelist[num1][num2].length; i++ )
   {
      // num|code|name|country|project_num|strategy_num
      tmp = sitelist[num1][num2][i].split("\|");
      outtxt = tmp[1]+" ("+tmp[0]+") - "+tmp[2]+", "+tmp[3];
      outval = tmp[1];

      f.selectsite[f.selectsite.length] = new Option(outtxt, outval);

      if ( f.code.value == outval )
      {
         f.selectsite[f.selectsite.length-1].selected = true;
      }
   }
}

function SelectSiteCB()
{
   f = document.mainform;

   f.code.value = f.selectsite[f.selectsite.selectedIndex].value;

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

