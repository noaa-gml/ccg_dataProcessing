function SiteListCB()
{
	f = document.mainform;
	f.code.value = f.sitelist[f.sitelist.selectedIndex].value;
	f.submit();
}
