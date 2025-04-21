function CounterCB(v)
{
	var f = document.mainform;

	var begin = parseInt(f.begin.value,10);
	var end = parseInt(f.end.value,10);
	var step = parseInt(f.step.value,10);
	var total = parseInt(f.total.value,10);

	switch(v)
	{
	case 'begin':
		begin = 1;
		break;
	case 'dec':
		i = begin - step - 1;
		begin = (i < 1) ? 1 : i;
		break;
	case 'inc':
		i = begin + step + 1;
		begin = (i >= total) ? total - step : i;
		break;
	case 'end':
		begin = total - step;
		break;
	}
	f.begin.value = (begin < 1) ? 1 : begin;

	i = parseInt(f.begin.value,10) + step;
	f.end.value = (i > total) ? total : i;

	f.submit();
}
function Search()
{
   var f = document.mainform;
                                                                                          
   f.submit();
}
function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}
