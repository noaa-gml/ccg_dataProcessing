function OkayCB()
{
   var f = document.mainform;
   if ( f.id.value ) { f.submit(); }
}

function CancelCB()
{
   document.location = 'flask_blank.php';
}
