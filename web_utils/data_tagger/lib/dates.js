	/*
	Generic date parser/validator for html forms.
	
        You set date part order for parsing/redisplay below. can be: 
		'mdy' 'dmy' 'ymd' 
	
		yyyymmdd (no seporators) is always recognized as is yyyy/mm/dd no matter what the date part order is.
	
        If time is allowed, formats accepted/parsed are:
		"24hm""24hms" "24hms" "hm" "hms" (hm is standard 12 hr am/pm)
		
	It will accept most punctuation as a seporators.  And will default the year if left off. 
	
        If "." is entered it will return today's date.
        If time is allowd, ".." will return today's date and time.
        You can also do ". 2p" for today at 2pm.
    jwm -4/17 - actually, this doesn't appear to be programmed anynmore.  The precursor to this code used to allow it, but I must have not kept that when updating...
    
        
	If dateValidate is called with allowTime=1 then time can be entered and parsed, otherwise time is not allowed.
	
                
                
	To Use:
		<input class='search_field ev_field' type='text' id='ev_sDate'  name='ev_sDate' size='20' onchange="return  validateDate('ev_sDate',true,-1);">
	

        */

function validateDate(inputID,allowTime,coerceDir) {
    //if coerceDir<0 we default month/day to 1 (where appropriate), >0 to last day of month/yr, ==0 none.
    var input=document.getElementById(inputID);
    var dateStr=input.value;
    input.value='';
    
    var success=false;
    var format='mdy';//default parse order.
    parseFormat=format;
    var timeFormat='hms';
    var gotTime=false;
    
    var now=new Date();
    var year,month,day,hour="0",minute="0",second="0",msec="0",ampm='';
    var parts=new Array("","","","","","","");//yr,mo,dy,hr,mn,sec,ampm
    var errMsg="Recognized formats are: m/d/y or yyyy/mm/dd";
    
    if (dateStr.length>0) {
        //Parse the different date parts
        var c=0,last=0,i=0,ch='';
        for(i=0;i<dateStr.length;i++){//Loop thru until hit a seporator or am/pm string
            ch=dateStr.substring(i,i+1);
            if (isSeporator(ch) || isAMPM(ch)) {
                parts[c]=dateStr.substring(last,i);//Pull the string to this point
                //If ch is a seporator, skip.  if it's ampm, we need to grab it still.
                if (isAMPM(ch)){
                    last=i;
                    timeFormat='hms';//We have a am/pm, so set time format to 12hr
                }else last=i+1;
                c++;
                //If this was a space, assume its the time seporator and set parts counter appropriately
                if (ch==" " && c<3) c=3;
            }
        }
        //Get the last bit (or whole bit if no separators);
        if (last<dateStr.length) {
            if (c>0 && parts[c-1]=="")c--;//If this is the last am/mp, don't count the last increment
            parts[c]=dateStr.substring(last,dateStr.length);
        }
        //Check for yyyymmdd format and override if so.
        if (parts[0].length==8 && isNumeric(parts[0]))parseFormat='yyyymmdd';
        if (parts[0].length==4 && isNumeric(parts[0]))parseFormat='ymd';
        switch (parseFormat) {
            case "mdy":
                month=parts[0];
                day=parts[1];
                year=parts[2];
                break;
            case "dmy":
                month=parts[1];
                day=parts[0];
                year=parts[2];
                break;
            case "ymd":
                month=parts[1];
                day=parts[2];
                year=parts[0];
                break;
            case "yyyymmdd":
                year=parts[0].substring(0,4);
                month=parts[0].substring(4,6);
                day=parts[0].substring(6,8);
                break;
        }
        
        //Clean input if needed
        year=(isNumeric(year))?year:"";
        month=(isNumeric(month))?month:"";
        day=(isNumeric(day))?day:"";

        if (month!="") {
            var n=Number(month);
            n--;//months are 0-11
            month=n.toString();
        }
        
        //Now fill in any missing parts with appropriate defaults
        if (year=="" && month!="") {//If year is missing, default to this year unless a passed month is in the future then default to last year.
            var yr=now.getFullYear();
            var m=Number(month);
            if (now.getMonth()<m) yr--;
            year=yr.toString();
        }
        if(year.length==2){
            var yr=Number(year);
            if(yr<50)year="20"+year;
            else year="19"+year;
        }else if(year.length==1)year="200"+year;
        if (year!="" && month=="") {
            if (coerceDir<0)month="0";
            if (coerceDir>0)month="11";
        }
        if (year!="" && month!="" && day=="") {
            if (coerceDir<0)day="1";
            if (coerceDir>0){
                switch (month) {
                    case "1":
                        day="28";//Ignore leap year.. we're just defaulting here, not doing something important.
                        break;
                    case "3":
                    case "5":
                    case "8":
                    case "10":
                        day="30";
                        break;
                    default:
                        day="31";
                        break;                        
                }
            }
        }
        
        //Parse time if needed.
        if(allowTime){
            if(isNumeric(parts[3])){//any time entered? note; time entries will start in parts[3] if present
                hour=parts[3];
                gotTime=true;
                minute=parts[4];
                second=parts[5];
                ampm=(isAMPM(parts[6]))?parts[6]:"";
                //See if all time parts were entered and default 0 if not.
                if(isAMPM(minute)){//Just hr passed
                    ampm=minute;
                    minute="0";
                    second="0";
                }
                if(isAMPM(second)){
                    ampm=second;
                    second="0";
                }
                if (ampm!=""){//If no ampm passed, we'll assume 24 hr input.  Other wise adjust passed hour to 24hr
                    ampm=ampm.substring(0,1).toLowerCase();
                    if (ampm=='a' && hour=="12")hour="0";
                    if (ampm=='p' && hour<12) {
                        h=Number(hour)+12;
                        hour=h.toString();
                    }
                }
                hour=(isNumeric(hour))?hour:"0";
                minute=(isNumeric(minute))?minute:"0";
                second=(isNumeric(second))?second:"0";

            }
        }
        //alert(year+" "+month+" "+day+" "+hour+" "+minute+" "+second);
        
        //Now attempt to build a date and set it.
        if (validateDatePart(year,"year") && validateDatePart(month,"month") && validateDatePart(day,"day") && validateDatePart(hour,"hour") && validateDatePart(minute,"minute") && validateDatePart(second,"second") ) {
            var d=new Date(year,month,day,hour,minute,second,msec);            
            if (d) {
                var str=createDateString(d,"ymd");
                if (str!="") {
                    success=true;
                    if (gotTime) {
                        var tstr=createTimeString(d,'24hms');
                        if (tstr!="") {
                            str=str+" "+tstr;
                        }
                    }
                    input.value=str;
                }
            }
            
            
        }else errMsg="Invalid date/time part"+"\n"+errMsg;
        
    }else success=true;//Empty string
    
    if (success) {
        return true;
    }else{
        alert(errMsg);
        setTimeout(inputID+".focus()",100);
    }
}

function validateDatePart(num,part){
    var ok=false;
    
    if (isNumeric(num)) {
        var n=Number(num);
        if (n>=0) {
            if (part=="year" && n>=1900 && n<=2100) {
                ok=true;
            }else if (part=="month" && n<=11 ) {
                ok=true;
            }else if(part=='day' && n<32){
                ok=true;
            }else if ((part=='minute' || part=='second') && n<60) {
                ok=true;
            }else if (part=='hour' && n<24) {
                ok=true;
            }
        }
        
    }    
    
    return ok;
}

function setFocus(inputName){//delay the focus to give everything a chance to run thru.  Had a nasty timing issue where tabbing out to next field occured after onChange script occured and we couldn't ever get the focus to stick.. This seems to solve the problme well.
	setTimeout(inputName+".focus()",100);
}
function formatNumber(num){
	if(num=="")num="00";
	else if(num=="0")num="00";
	else if(num<10 && num.length==1)num="0"+num;
	return num;
}

function isSeporator(ch){
	if(ch=="." ||ch=="," || ch=="-" || ch==":" || ch=="/" || ch==" ") return true;
	else return false;		
}
function isAMPM(ch){
	ch=ch.substring(0,1);
	ch=ch.toUpperCase();
	if(ch=="P" || ch=="A") return true;
	else return false;
}
function createTimeString(dDate,timeFormat){
	var ampm, h24;
	var h=dDate.getHours(),m=dDate.getMinutes(),s=dDate.getSeconds(),rtn="";
	h24=h;
	if(h>11) ampm="pm";
	else ampm="am";
	if(h>12)h=h%12;//convert to 12hr
	if(h==0)h=12;//change hour 0 to 12

	
	if(s<10) s="0"+s;
	if(h<10) h="0"+h;
	if(m<10) m="0"+m;
	switch(timeFormat){
		case "24hm":
			rtn=h24+":"+m; break;
		case "24hms": 
			rtn=h24+":"+m+":"+s; break;
		case "hm":
			rtn=h+":"+m+" "+ampm;
			break;
		case "hms": 
			rtn=h+":"+m+":"+s+" "+ampm; break;
	};
	return rtn;
}

function createDateString(dDate,datePartOrder){
	var m=dDate.getMonth()+1, d=dDate.getDate(), y=dDate.getFullYear(), rtn="";
	if(m<10) m="0"+m;
	if(d<10) d="0"+d;
    
	switch (datePartOrder){
		case "mdy":
			rtn=m+"/"+d+"/"+y; break;			
		case "dmy":
			rtn=d+"/"+m+"/"+y; break;
		case "ymd":
        case "yyyymmdd":
			rtn=y+"-"+m+"-"+d; break;	
	};
	return rtn;
}
function isNumeric(checkString){
    if (checkString=="")return false;
    var newString = "";  
	for (i = 0; i < checkString.length; i++) {
        ch = checkString.substring(i, i+1);
		if (ch=="0" || ch=="1" || ch=="2" || ch=="3" || ch=="4" || ch=="5" || ch=="6" || ch=="7" || ch=="8" || ch == "9") {
            newString += ch;
        }
    }
	if (checkString == newString) return true;
	else return false;
}
function validate24HrTime(inputID){
    //Parses entry in field and returns true if valid 24 hr time, clears and returns false on error
    var input=document.getElementById(inputID);
    var timeStr=input.value;
    input.value='';
    if(timeStr=='')return true;
    //Do a few obvious clean ups
    if(timeStr.length==1)timeStr="0"+timeStr;//pad zero on hr
    if(timeStr.length==2)timeStr+=":00:00";
    if(timeStr.length==5)timeStr+=":00";
    
    var valid = (timeStr.search(/^\d{2}:\d{2}:\d{2}$/) != -1) &&
            (timeStr.substr(0,2) >= 0 && timeStr.substr(0,2) < 24) &&
            (timeStr.substr(3,2) >= 0 && timeStr.substr(3,2) < 60) &&
            (timeStr.substr(6,2) >= 0 && timeStr.substr(6,2) < 60);
    if(valid){
        input.value=timeStr;
        return true;
    }else{
        alert("Invalid time format.  Enter 00:00:00 24hr.")
        input.focus();
        return false;
    }
}