function ClearChk(element)
{
   if ( element.value.search(/\`/i) > -1 ) element.value = '';
}

function ClearCB()
{
   var f = document.mainform;
   var ounitcomment = top.document.getElementById('unitcomment');
   ounitcomment.innerHTML = '--';

   f.okupdate.value = 'Ok';
}

function InventoryCB(select)
{
   var f = document.mainform;

   f.fm_comments.disabled = 0;
   f.fm_comments.blur();
   f.fm_comments.disabled = 1;

   f.task.value = select;

   ClearCB();

   f.id.focus();
   
   switch(select)
   {
     case 'Notes':
       if (f.id.value != '') { f.fm_comments.disabled = 0; f.fm_comments.focus(); }
       break;
     default:
       break;
        }
}

function OkayCB()
{
   var f = document.mainform;

   if (f.id.value == '') { return; }

   chk = f.okupdate.value;
   if ( chk == 'Update' )
   {
      if (!confirm("Are you sure?")) return;
      f.task.value = "Notes";
   }

   f.submit();

}

function CancelCB()
{
   var f = document.mainform;

   //
   // If we are updating the comment, then f.okupdate.value will be
   // "Update". If the user hits cancel in this mode, go back to
   // the beginning page. If we are at the beginning page
   // (f.okupdate.value will be 'Ok') then if the user hits
   // cancel, go to pfp_blank.php
   //

   chk = f.okupdate.value;
   if ( chk == 'Ok' )
   {
      document.location = omurl+'index2.php?invtype='+invtype;
   }
   InventoryCB("hi");
   f.searched.value = 1;
}

function FilterSelection()
{
   var f = document.mainform;
   f.filter.value = f.filterlist[f.filterlist.selectedIndex].value;
   f.submit();
}

function IdChangeCB()
{
   var f = document.mainform;
   f.fm_comments.value = '';
   f.searched.value = 0;
   f.fm_comments.disabled = true;
}
function SetBackground2(element,state)
{
   color = (state) ? 'paleturquoise' : '#DDDDDD';
   element.style.backgroundColor=color;
}

function EnableText()
{
   //
   // Make the element enabled for editing
   //
   var f = document.mainform;
   
   if ( f.searched.value == 1 )
   {
      f.okupdate.value = 'Update';
      f.fm_comments.disabled = false;
      f.fm_comments.focus();
   }
}

function ClearText()
{

   var f = document.mainform;

   if ( f.fm_comments.disabled == false )
   {
      f.fm_comments.value = '';
   }

}

function DateText()
{
   var f = document.mainform;

   if ( f.fm_comments.disabled == false )
   {
      var d = new Date();
      var dow = d.getDay();
      var day = d.getDate();
      var month = d.getMonth();
      var year = d.getFullYear();

      var weekday = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
      var monthname = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

      var hours = d.getHours();
      if ( hours < 10 ) { hours = '0' + hours; }
      var mins = d.getMinutes();
      if ( mins < 10 ) { mins = '0' + mins; }
      var secs = d.getSeconds();
      if ( secs < 10 ) { secs = '0' + secs; }

      f.fm_comments.value = f.fm_comments.value + weekday[dow] + " " + monthname[month] + " " + day + " " + hours + ":" + mins + ":" + secs + " " + year + ": ";

      f.fm_comments.focus();
   }
}
