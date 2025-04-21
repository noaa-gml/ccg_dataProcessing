var sites;
var npaths;
var nsamples;

function AcceptCB()
{
	f = document.mainform;
	if (confirm('Are you sure?')) { f.task.value = 'accept'; f.submit(); }
}

function ByPassCB()
{
	f = document.mainform;
	z = 'Are you sure?\n';
	z = z + 'This action will check out the PFP\n';
	z = z + 'without uploading a sample plan.\n';
	if (confirm(z)) { f.task.value = 'bypass'; f.submit(); }
}

function UploadCB()
{
	f = document.mainform;

	if (confirm('Are you sure?'))
 	{
		f.serialport.value = f.sp[f.sp.selectedIndex].value;
		f.task.value='upload';
		MessageAlert('show');
		f.submit();
	}
}

function PrepareCB()
{
	f = document.mainform;

	if (confirm('Are you sure?'))
 	{ if (ChkEntries()){ f.task.value='prepare'; f.submit(); } }
}

function EditCB()
{
	var f = document.mainform;
	var key = new RegExp('plan_','i');

	for (var i=0; i<f.elements.length; i++)
	{
		if (f.elements[i].name.match(key) == null) continue;
		f.elements[i].disabled = false;
	}
}

function GetPlanCB()
{
	f = document.mainform;

	f.template.value = f.planlist[f.planlist.selectedIndex].value;
	f.submit();
}

function CancelCB()
{
   document.location = 'pfp_checkout.php';
}

function SetDefaultsCB()
{
	f = document.mainform;
	var i,ele,row;

	for (i=0,row=1; i<nsamples; i++,row++)
	{
		row = (row < 10) ? '0'+row : row;

		ele = 'plan_date'+row;
		if (f.elements[ele].value == '')  f.elements[ele].value = defaults2.date;

		ele = 'plan_time'+row;
		if (f.elements[ele].value == '')  f.elements[ele].value = defaults2.time;

		ele = 'his_lat'+row;
		if (f.elements[ele].value == '')  f.elements[ele].value = defaults2.lat;

		ele = 'his_lon'+row;
		if (f.elements[ele].value == '')  f.elements[ele].value = defaults2.lon;

		ele = 'his_alt'+row;
		if (f.elements[ele].value == '')  f.elements[ele].value = defaults2.alt;
	}
}

function ChkCode(element)
{
	f = document.mainform;
	t_s = element.value;
	var key = new RegExp(t_s,'i');
	if (sites.match(key) == null) { return false; }
	return true;
}

function ChkDate(element)
{
	f = document.mainform;
	t_s = element.value;

	if (t_s == defaults2.date) { return true; }

	tmp = t_s.split("-");
	yr = tmp[0]; mo = tmp[1]; dy = tmp[2];

	if (yr.length != 4) { return false; }

	if (mo.length < 2) {mo = '0'+mo; }
	if (dy.length < 2) {dy = '0'+dy; }

	t_s = yr+'-' + mo+'-'+dy;

	element.value = t_s;

	if (!(ChkReal(yr))) { return false; }
	if (!(ChkReal(mo))) { return false; }
	if (!(ChkReal(dy))) { return false; }

	dy = parseFloat(dy);
	if (dy < 1 || dy > 31) { return false; }
	mo = parseFloat(mo);
	if (mo < 1 || mo > 12) { return false; }
	yr = parseFloat(yr);
	if (yr < 0) { return false; }
	//
	// Future date?
	//JWM - 2/17 - removed this check so we can schedule them out in advance.
	//
	//dec = Date2Dec(yr,mo,dy,12,0);
	//now = new Date();
	//yr = now.getFullYear();
	//mo = now.getMonth();
	//dy = now.getDate();
	//today = Date2Dec(yr,mo+1,dy,12,0);
	//if (dec > today) { return false; }
	return true;
}

function ChkTime(element)
{
	t_s = element.value;

	if (t_s == defaults2.time) { return true; }

	tmp= t_s.split(":");
	hr = tmp[0]; mn = tmp[1]; sc = tmp[2];

	if (hr.length < 2) {hr = '0'+hr; }
	if (mn.length < 2) {mn = '0'+mn; }
	if (sc.length < 2) {sc = '0'+sc; }

	t_s = hr+':'+mn+':'+sc;

	element.value = t_s;

	if (!(ChkReal(hr))) { return false; }
	if (!(ChkReal(mn))) { return false; }
	if (!(ChkReal(sc))) { return false; }
	//
	//valid time?
	//
	hr = parseFloat(hr);
	mn = parseFloat(mn);
	sc = parseFloat(sc);

	if (hr > 23 || mn > 59 || sc > 59) { return false; }
	return true;
}

function ChkMethod(element)
{
	t_s = element.value;

	if (t_s == '?') { return false; }
	return true;
}

function ChkPress(element)
{
	var t_s = element.value;

	if (t_s == defaults2.press) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	if (parseFloat(t_s) < 0) { return false; }
	return true;
}

function ChkTemp(element)
{
	var t_s = element.value;

	if (t_s == defaults2.temp) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	return true;
}

function ChkRH(element)
{
	var t_s = element.value;
	//
	// -1 because default RH for version 2 is -99.0
	// and -99.9 version 3
	//
	if (t_s-1 <= defaults2.rh) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	if (parseFloat(t_s) < 0) { return false; }
	return true;
}

function ChkLat(element)
{
	var t_s = element.value;

	if (t_s == defaults2.lat) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	if (parseFloat(t_s) < -90 || parseFloat(t_s) > 90) { return false; }
	return true;
}

function ChkLon(element)
{
	var t_s = element.value;

	if (t_s == defaults2.lon) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	if (parseFloat(t_s) < -180 || parseFloat(t_s) > 180) { return false; }
	return true;
}

function ChkAlt(element)
{
	var t_s = element.value;

	if (t_s == defaults2.alt) { return true; }

	if (!(ChkReal(t_s))) { return false; }

	return true;
}

function ChkReal(item)
{
	//
	//Allowable characters are 0-9,.,-
	//
	if (item == '' || (isNaN(item))) { return false; } else { return true; }
}

function ChkEntries()
{
	f = document.mainform;
	var i,ii,j,jj,key,p;
	var col,row;
	var str,sum;


	for (i=0,row=1,sum=''; i<nsamples; i++,row++)
	{
		str = '';
		smpno = 'Sample '+row+':  ';

		row = (row < 10) ? '0'+row : row;

		ele = 'plan_control'+row;
		if (f.elements[ele].checked == false) continue;
		str = row;

		ele = 'plan_alt'+row;
		if (!(ChkAlt(f.elements[ele])))
		{ f.elements[ele].focus(); alert(smpno+'Improper Altitude'); return false; }
		str += '|'+f.elements[ele].value;

		ele = 'plan_lat'+row;
		if (!(ChkLat(f.elements[ele])))
		{ f.elements[ele].focus(); alert(smpno+'Improper Latitude'); return false; }
		str += '|'+f.elements[ele].value;

		ele = 'plan_lon'+row;
		if (!(ChkLon(f.elements[ele])))
		{ f.elements[ele].focus(); alert(smpno+'Improper Longitude'); return false; }
		str += '|'+f.elements[ele].value;

		ele = 'plan_date'+row;
		if (!(ChkDate(f.elements[ele])))
		{ f.elements[ele].focus(); alert(smpno+'Improper Date'); return false; }
		str += '|'+f.elements[ele].value;

		ele = 'plan_time'+row;
		if (!(ChkTime(f.elements[ele])))
		{ f.elements[ele].focus(); alert(smpno+'Improper Time'); return false; }
		str += '|'+f.elements[ele].value;
		//
		// Prepare sample plan information
		//
		sum = (sum == '') ? str : sum+'~'+str;
	}
	f.sampleplan.value = sum;
	return true;
}

function Date2Dec(yr,mo,dy,hr,mn)
{
	var i,d,leap;

	dim_noleap = new Array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	dim_leap = new Array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

	if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0)) 
	{
		dim=dim_leap;
		leap=1;
	}
	else
	{
		dim=dim_noleap;
		leap=0;
	}

	for (i=1,d=dy; i<mo; i++) { d += dim[i]; }
	return yr+((d-1)*24.0+hr+(mn/60.0))/((365+leap)*24.0);
}
