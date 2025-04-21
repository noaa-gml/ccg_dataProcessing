function OkayCB()
{
	f = document.mainform;
	if (f.id.value)  { f.submit(); }
}

function CancelCB()
{
	document.location = 'pfp_blank.php';
}
