;+
; NAME:
;	CCG_NSREAD	
;
; PURPOSE:
;       Extract discrete (flask or pfp) collection details
;	from RDBMS.
;
;       User may suppress messages.
;
; CATEGORY:
;	Data Retrieval
;
; CALLING SEQUENCE:
;	CCG_NSREAD,site='brw',arr
;	CCG_NSREAD,site='sgp610',arr
;	CCG_NSREAD,site='car030',strategy='pfp',arr
;	CCG_NSREAD,site='pocn25',/nomessages,arr
;	CCG_NSREAD,file='/strategys/network/flask/site/brw',arr (obsolete)
;
; INPUTS:
;       site:           Site code.  May include bin specification,
;                       e.g., brw, sgp610, pocn30, car3000.
;
;       strategy:        Project abbreviation.  May be either
;                       flask [default] or pfp.
;
; OPTIONAL INPUT PARAMETERS:
;       file:           file name must be a site code (e.g.,
;			/home/ccg/ken/brw, car030).
;                       NOTE:  This input option is supported but 
;			obsolete.  File path is ignored.
;
;       nomessages:     If non-zero, messages will be suppressed.
;
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
; OUTPUTS:
;	data:		This array is of type anonymous structure:
;
;		data[].str 	-> entire site string
;		data[].x	-> sample date/time (UTC) in decimal format
;		data[].yr	-> sample year
;		data[].mo	-> sample month
;		data[].dy	-> sample day
;		data[].hr	-> sample hour
;		data[].mn	-> sample minute
;		data[].code	-> 3-letter site code
;		data[].id	-> 8-character flask id
;		data[].type	-> 2-character flask id suffix
;		data[].meth	-> single character method
;               data[].lat      -> decimal latitude position
;               data[].lon      -> decimal longitude position
;               data[].alt      -> altitude in m above sea level
;
;		data[].wd	-> wind direction (deg, FLASK only)
;		data[].ws	-> wind speed (m/s, FLASK only)
;
;		data[].temp	-> air temperature (deg C, PFP only)
;		data[].press	-> ambient pressure (mbar, PFP only)
;		data[].rh	-> relative humidity (%, PFP only)
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;       Either site OR file must be specified.
;
;       When file keyword is set, name must be site code (see above).
;
; PROCEDURE:
;	Once the collection details are put into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the network site file.  
;		Example:
;			CCG_NSREAD,site='brw',arr
;			.
;			.
;			.
;			n_butyl=arr(WHERE(arr.meth EQ 'N' AND arr.type EQ '60'))
;			.
;			.
;			CCG_SWRITE,file='/users/ken/temp.n_butyl',n_butyl.str
;
; MODIFICATION HISTORY:
;	Written, KAM, March 1996.
;	Modified, KAM, June 2004.
;-
PRO CCG_NSREAD,$
	file=file,$
	site=site,$
	strategy=strategy,$
	help=help,$
	nomessages=nomessages,$
	arr
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;Check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF KEYWORD_SET(file) THEN BEGIN
        field = STRSPLIT(file,'/',/EXTRACT)
        site = field[N_ELEMENTS(field)-1]
ENDIF
;
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
strategy = (KEYWORD_SET(strategy)) ? strategy : 'flask'
;
;Misc initialization
;
arr = 0
data = 0
dbdir = '/ccg/src/db/'
perlcode = dbdir + 'ccg_flask.pl'
;
;Extract event history
;
tmp = perlcode+' -site='+site+' -strategy='+strategy+' -stdout'

IF NOT nomessages THEN CCG_MESSAGE,'Extracting Data ...'
SPAWN,tmp,data
IF NOT nomessages THEN CCG_MESSAGE,'Done Extracting Data ...'

IF data[0] EQ '' THEN RETURN

n = N_ELEMENTS(data)

arr=REPLICATE({	str:	'',$
	 	x: 	0.0D,$
		yr:	0,$
		mo:	0,$
		dy:	0,$
		hr:	0,$
		mn:	0,$
 		code:	'',$
 		id: 	'',$ 
 		type: 	'-1',$ 
 		meth: 	'',$ 
		lat:	-99.99,$
		lon:	-999.99,$
		alt:	-99999.9,$
		wd:	999,$
		ws:	-9.9,$
		press:  -999.9,$
		temp:   -999.9,$
		rh:     -999.9,$
		evn:	0L},$
 		n)

sformat='(A3,1X,I4.4,4(1X,I2.2),1X,A8,1X,A1,1X,F6.2,1X,F7.2,1X,F7.1,1X,A,1X,I8)'

FOR i=0,n-1 DO BEGIN
	str = STRSPLIT(data[i],' ',/EXTRACT)

	code = str[0]
	yr = FIX(str[1])
	mo = FIX(str[2])
	dy = FIX(str[3])
	hr = FIX(str[4])
	mn = FIX(str[5])
	fi = str[6]
	me = str[7]

	lat = FLOAT(str[8])
	lon = FLOAT(str[9])
	alt = FLOAT(str[10])

	evn = LONG(str[N_ELEMENTS(str)-1])

	CASE strategy OF
	'flask':	BEGIN
			ws = FLOAT(str[11])
			wd = FIX(str[12])
			add = STRING(FORMAT='(F4.1,1X,I3)',ws,wd)
			arr[i].wd = wd
			arr[i].ws = ws
			END
	'pfp':		BEGIN
			temp = FLOAT(str[11])
			press = FLOAT(str[12])
			rh = FLOAT(str[13])
			add = STRING(FORMAT='(1X,F6.1,1X,F7.1,1X, F6.1)',$
			temp,press,rh)
			arr[i].temp = temp 
			arr[i].press = press
			arr[i].rh = rh
			END
	ENDCASE

 	arr[i].str = STRING(FORMAT=sformat,$
 	code,yr,mo,dy,hr,mn,fi,me,lat,lon,alt,add,evn)

	thr = (hr EQ 99) ? 12 : hr
	tmn = (mn EQ 99) ?  0 : mn
	CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=thr,mn=tmn,dec=dec

 	arr[i].x = dec
	arr[i].yr = yr
	arr[i].mo = mo
	arr[i].dy = dy
	arr[i].hr = hr
	arr[i].mn = mn
	arr[i].code = code
	arr[i].id = fi 
	arr[i].meth = me 
	arr[i].lat = lat
	arr[i].lon = lon
	arr[i].alt = alt
	arr[i].evn = evn

	k = STRPOS(fi,'-')
	arr[i].type = (k[0] NE -1) ? STRMID(fi,k+1,2) : '??'
ENDFOR
END
