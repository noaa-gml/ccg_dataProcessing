
function SiteListCB()
{
   f = document.mainform;
   f.stacode.value = f.sitelist[f.sitelist.selectedIndex].value;
   f.proj_abbr.value = '';
   f.submit();
}

function ProjectListCB()
{
   f = document.mainform;
   f.proj_abbr.value = f.projlist[f.projlist.selectedIndex].value;
   f.submit();
}

function StatusListCB()
{
   var i,tstr;

   arr = statusinfo.split("~");

   tstr = "None:  Remove this project from this site.\n\n";

   for (i=0; i<arr.length; i++)
   {
      tmp = arr[i].split("\|");
      tstr = tstr + tmp[1] + ":  " + tmp[2] + "\n\n";
   }
   alert(tstr);
}

function SampleSheetCB()
{
   var tstr;

   tstr = "Indicate language used to prepare sample sheet,\n";
   tstr = tstr + "Available: english, spanish, french, german, russian, chinese, korean,simplified_chinese.\n\n";
   tstr = tstr + "Indicate if sample collector will be required\n";
   tstr = tstr + "to record latitude, longitude, and/or altitude.\n\n";
   tstr = tstr + "(ex) german\n\n";
   tstr = tstr + "(ex) english lat,lon\n\n";
   tstr = tstr + "(ex) spanish lat,lon\n\n";
   tstr = tstr + "(ex) english alt\n\n";

   alert(tstr);
}

function PathListCB()
{
   var i,tstr;

   arr = sysinfo.split("~");

   tstr = '(ex) 1,2,3\n\n';

   for (i=0; i<arr.length; i++)
   {
      tmp = arr[i].split("\|");
      tstr = tstr + tmp[0] + '  ' + tmp[1] + '\n';
   }
   alert(tstr);
}

function SearchCB()
{
   f = document.mainform;
   var c = f.search4code.value.toUpperCase();

   if (c == '') { return; }
   f.stacode.value = c;

   var key = new RegExp(c,'i');
   if (sites.match(key) == null)
   {
      if (!confirm(c + " not found in DB.\nDo you want to add "+c+" to DB?")) return;
      f.task.value = 'addsite';
   }
   f.proj_abbr.value = '';
   f.submit();
}

function DeleteCB(strategy)
{
   f = document.mainform;

   if (f.stacode.value == '') return;

   if (f.proj_abbr.value == '' && strategy != 'om') return;

   if (!confirm("Are you sure?\n"+
   "This action will delete "+f.stacode.value+" from all Site Manager tables.\n")) return;
   f.task.value = 'delete';
   f.submit();
}

function UpdateCB(strategy)
{
   f = document.mainform;

   if (f.stacode.value == '') return;

   if (f.proj_abbr.value == '' && strategy != 'om') return;

   switch (strategy)
   {
      case 'om':
         if (!confirm("Are you sure?")) return;
         tables = new Array('site');
         break;
      default:
         tables = new Array('site_desc','site_coop','site_shipping');
         if (f.status.selectedIndex == 0)
         {
            if (!confirm("Project Status is set to \"None\".\n" +
            "Updating will clear all entries\nexcept those under DEFINITION.")) return;
            f.task.value = 'delete';
            f.submit();
         }
         else
         {
            if (!confirm("Are you sure?")) return;
         }
         break;
   }


   for (i=0; i<tables.length; i++)
   {
      a = '';
      key = new RegExp(tables[i]+":",'i');
      for (ii=0,jj=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name.match(key) == null) continue;
         //
         // Disallow use of '~' and '|'
         //
         if (f.elements[ii].value.match(/\~/) != null)
         { f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return; }

         if (f.elements[ii].value.match(/\|/) != null)
         { f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return; }

         tmp = f.elements[ii].name.split(":");
         z = tmp[1] + "~" + f.elements[ii].value;
         a += (jj == 0) ? z : "|" + z;
         jj++;
      }
      if (tables[i] == 'site') f.site_info.value = a;
      if (tables[i] == 'site_desc')
      {
         prjchk = 0;incchk=0;//included_temp_rh is zero unless specifically checked (and checkbox exists)
         if ( f.default_project.checked ) { prjchk = 1; }
	 if(f.elements.namedItem("include_temp_rh")){if ( f.include_temp_rh.checked ) {incchk = 1;}}
         f.desc_info.value = "status_num~" + f.status.selectedIndex + "|" + "default_project~" + prjchk +"|" + "include_temp_rh~" + incchk + "|" + a;
      }
      if (tables[i] == 'site_coop') f.coop_info.value = a;
      if (tables[i] == 'site_shipping') f.ship_info.value = a;
   }
   f.task.value = 'update';

   f.submit();
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}
