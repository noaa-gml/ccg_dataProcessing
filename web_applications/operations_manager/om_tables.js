function SubmitCB()
{
	f = document.mainform;
	f.action = 'om_tables_list_siteinfo.php';

	for (i=0; i<f.radio.length; i++) { if (f.radio[i].checked) break;};
	z = f.radio[i].value.split('|');

	f.project.value = f.projectlist[f.projectlist.selectedIndex].value;
	f.strategy.value = f.strategylist[f.strategylist.selectedIndex].value;
	f.param.value = f.paramlist[f.paramlist.selectedIndex].value;
	f.action = z[0]+'?project='+f.project.value+'&strategy='+f.strategy.value+'&param='+f.param.value;

	f.submit();
}

function DetailCB(s)
{
	f = document.mainform;

	f.table.value = s;

	f.strategy.value = f.strategylist[f.strategylist.selectedIndex].value;
	f.param.value = f.paramlist[f.paramlist.selectedIndex].value;

	f.submit();
}
