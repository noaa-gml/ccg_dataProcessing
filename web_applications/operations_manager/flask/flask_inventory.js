var flaskcomments = new Array();

function ClearChk(element)
{
   if ( element.value.search(/\`/i) > -1 ) element.value = '';
}

function ClearCB()
{
   var f = document.mainform;
   var oflaskcomment = top.document.getElementById('flaskcomment');
   oflaskcomment.innerHTML = '--';
   var ocoldetails = top.document.getElementById('coldetails');
   ocoldetails.innerHTML = '';

   f.okupdate.value = 'Ok';
}

function InventoryCB(select)
{
   var f = document.mainform;

   f.fm_note.disabled = 0;
   f.fm_note.blur();
   f.fm_note.disabled = 1;

   f.fm_print.disabled = 1;
   f.task.value = select;

   ClearCB();

   f.flask_id.focus();
   
   switch(select)
   {
     case 'Add':
       f.fm_print.disabled = 0;
       break;
     case 'Notes':
       if (f.flask_id.value != '') { f.fm_note.disabled = 0; f.fm_note.focus(); }
       break;
     default:
       break;
        }
}

function OkayCB()
{
   var f = document.mainform;

   if (f.flask_id.value == '') { return; }
   f.fm_notes.value = f.fm_note.value; 
   f.print.value = f.fm_print.checked;

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
      document.location = 'flask_blank.php';
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
   var oflasknote = top.document.getElementById('flasknote');
   oflasknote.innerHTML = ' ';
   f.fm_note.value = '';
   f.searched.value = 0;
   f.fm_note.disabled = true;
   
   //var oflaskcomment = top.document.getElementById('flaskcomment');
   //oflaskcomment.innerHTML = '--';
   //var ocoldetails = top.document.getElementById('coldetails');
   //ocoldetails.innerHTML = '';
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
      f.fm_note.disabled = false;
      f.fm_note.focus();
   }
}

function ClearText()
{

   var f = document.mainform;

   if ( f.fm_note.disabled == false )
   {
      f.fm_note.value = '';
   }

}

function DateText()
{
   var f = document.mainform;

   if ( f.fm_note.disabled == false )
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

      f.fm_note.value = f.fm_note.value + weekday[dow] + " " + monthname[month] + " " + day + " " + hours + ":" + mins + ":" + secs + " " + year + ": ";

      f.fm_note.focus();
   }
}
