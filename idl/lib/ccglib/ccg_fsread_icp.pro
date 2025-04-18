;+
; NAME:
;	CCG_FSREAD_ICP	
;
; PURPOSE:
; 	Extract discrete (flask or pfp) data from RDBMS
;	or read from an imported "site" file.
;
;  This version is used with laby/labx ICP.
;  "file" = "import"
;
;	User may suppress messages.
;
; CATEGORY:
;	Data Retrieval
;
; CALLING SEQUENCE:
;	CCG_FSREAD,site='brw',sp='co2',arr
;	CCG_FSREAD,site='car3000',sp='co2c13',project='pfp',arr
;	CCG_FSREAD,import='/users/ken/mlo.co2',structarr
;
;	CCG_FSREAD,file='/projects/co/flask/site/bme.co',data (obsolete)
;
; INPUTS:
;	site:		Site code.  May include bin specification,
;			e.g., brw, sgp610, pocn30, car3000.
;
;	sp:	 	Gas formula, e.g., co, co2, h2, n2o,
;			sf6, ch4, co2o18, co2c13, ch4c13.
;
;	project:	Project abbreviation.  May be either
;			flask [default] or pfp.
;
; OPTIONAL INPUT PARAMETERS:
;	file:  		file name must include the species name.
;		   	co,co2,h2,n2o,sf6,ch4,co2o18,co2c13,ch4c13.
;			NOTE:  This input option is supported but obsolete.
;			File path is ignored.
;
;	import:		Specify a text "site" file with no header.
;
;	nomessages:	If non-zero, messages will be suppressed.
;
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
;	all:		If non-zero, then returned structure will
;			contain all strings including those with
;			default mixing ratios.
;
; OUTPUTS:
;	data:		This array is of type anonymous structure:
;
;			data[].str 	-> entire site string
;			data[].x		-> UTC date/time in decimal format
;			data[].yr	-> UTC sample collection year
;			data[].mo	-> UTC sample collection month
;			data[].dy	-> UTC sample collection day
;			data[].hr	-> UTC sample collection hour 
;			data[].mn	-> UTC sample collection minute
;			data[].y	-> data value (mixing ratio, per mil)
;			data[].flag	-> 3-character selection flag
;			data[].code	-> 3-letter site code
;			data[].id	-> 8-character flask id
;			data[].type	-> 2-character flask id suffix
;			data[].meth	-> single character method
;			data[].inst	-> 2-character analysis instrument code
;			data[].adate	-> analysis date in decimal format
;			data[].ayr	-> sample analysis year (local time)
;			data[].amo	-> sample analysis month (local time)
;			data[].ady	-> sample analysis day (local time)
;			data[].ahr	-> sample analysis hour  (local time)
;			data[].amn	-> sample analysis minute (local time)
;
;			data[].lat	-> sample collection latitude (if available)
;			data[].lon	-> sample collection longitude (if available)
;			data[].alt	-> sample collection altitude (if available)
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;       Either sp and site OR import OR file must be specified.
;
;       When file keyword is set, name must be site site (see above).
;
; PROCEDURE:
;	Once the data are put into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the site file.  
;		Example:
;			CCG_FSREAD,sp='co2',site='brw',arr
;			.
;			.
;			.
;			PLOT, arr.x,arr.y
;			PLOT, arr(WHERE(arr.meth EQ 'P')).x, $
;			      arr(WHERE(arr.meth EQ 'P')).y
;			.
;			.
;			sub_structure=arr(WHERE(arr.meth EQ 'P' AND arr.x GE 1990))
;			.
;			.
;			.
;			n_butyl=arr(WHERE(arr.meth EQ 'N' AND arr.type EQ '60'))
;			.
;			.
;			CCG_FSWRITE,file='/home/ccg/ken/temp.co2',n_butyl
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;	Modified, KAM, October 1997.
;	Modified, KAM, August 2001.
;	Modified, KAM, June 2004.
;-
;
PRO CCG_FSREAD_ICP,$
	file=file,$
	import=import,$
	sp=sp,$
	site=site,$	
	project=project,$
	all=all,$
	help=help,$
	nomessages=nomessages,$
	arr
;
;Return to caller if an error occurs
;
;ON_ERROR,	2
;
;
;----------------------------------------------- initialization
;
arr = 0
data = 0
dbdir = '/projects/src/db/'
perlcode = dbdir + 'ccg_flask.pl'
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

project = (KEYWORD_SET(project)) ? project : 'flask'
IF KEYWORD_SET(file) THEN f = file
IF KEYWORD_SET(import) THEN f = import

;
; Force into "import" mode
;
import = f

IF KEYWORD_SET(f) THEN BEGIN
	j = STRSPLIT(f,'/',/EXTRACT)
	CCG_STRTOK,str=j[N_ELEMENTS(j)-1],delimiter='.',field
	site = field[0]
	sp = field[1]
ENDIF
;
nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
all = (KEYWORD_SET(all)) ? 1 : 0

IF KEYWORD_SET(import) THEN BEGIN
	;
	; if user specifies import then read data from import file
	; 
	CCG_SREAD,file=import,nomessages=nomessages,data
ENDIF ELSE BEGIN
	;
	; if user specifies sp/site or file then extract data from DB
	; 
	IF NOT KEYWORD_SET(sp) AND NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
	tmp = perlcode+' -s'+site+' -g'+sp+' -p'+project+' -tz'
	IF NOT nomessages THEN CCG_MESSAGE,'Extracting Data ...'
	SPAWN,tmp,data
	IF NOT nomessages THEN CCG_MESSAGE,'Done Extracting Data ...'
ENDELSE

IF data[0] EQ '' THEN RETURN

n = N_ELEMENTS(data)

CASE sp OF
'co2c13': 	BEGIN
		DEFAULT = (-999.999)
		dp = '3'
		END
'co2o18': 	BEGIN
		DEFAULT = (-999.999)
		dp = '3'
		END
'ch4c13': 	BEGIN
		DEFAULT = (-999.999)
		dp = '3'
		END
ELSE:		BEGIN
		DEFAULT = (-999.99)
		dp = '2'
		END
ENDCASE
;
;Format statement used to re-construct string.  see "str" tag.
;
sformat=$
'(A3,1X,I4.4,1X,4(I2.2,1X),A8,1X,A1,1X,F8.'+dp+',1X,A3,1X,A2,1X,I4.4,4(1X,I2.2))'
;
arr=REPLICATE({	str:	'',$
		x: 	0.0D,$
		y: 	0.0,$ 
		yr:	0,$
		mo:	0,$
		dy:	0,$
		hr:	0,$
		mn:	0,$
		code:	'',$
		id: 	'',$ 
		type: 	'',$ 
		meth: 	'',$ 
		lat:    0.0,$
		lon:    0.0,$
		alt:    0.0,$
		inst:	'',$ 
		adate:	0.0D,$
		ayr:	0,$
		amo:	0,$
		ady:	0,$
		ahr:	0,$
		amn:	0,$
		flag:	''},$ 
		n)

i=0
FOR j=0,n-1 DO BEGIN
	str = STRSPLIT(data[j],' ',/EXTRACT)

	code = str[0]
	yr = FIX(str[1])
	mo = FIX(str[2])
	dy = FIX(str[3])
	hr = FIX(str[4])
	mn = FIX(str[5])
	fi = str[6]
	me = str[7]
	mr = FLOAT(str[8])
	fg = str[9]
	in = str[10]
	ayr = FIX(str[11])
	amo = FIX(str[12])
	ady = FIX(str[13])
	ahr = FIX(str[14])
	amn = FIX(str[15])

	lat = 0. & lon = 0. & alt = 0.
	
	IF N_ELEMENTS(str) GT 16 THEN BEGIN
		lat = FLOAT(str[16])
		lon = FLOAT(str[17])
		alt = FLOAT(str[18])
	ENDIF

	use = (all EQ 0 AND mr-1 LT DEFAULT) ? 0 : 1

	IF use EQ 1 THEN BEGIN
 	 	arr[i].str = STRING(FORMAT=sformat,$
 	 	code,yr,mo,dy,hr,mn,fi,me,mr,fg,in,ayr,amo,ady,ahr,amn)

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
	 	arr[i].inst = in
	 	arr[i].flag = fg
		arr[i].lat = lat
		arr[i].lon = lon
		arr[i].alt = alt

		thr = (ahr EQ 99) ? 12 : ahr
		tmn = (amn EQ 99) ?  0 : amn
		CCG_DATE2DEC,yr=ayr,mo=amo,dy=ady,hr=thr,mn=tmn,dec=dec

 	 	arr[i].adate = dec 
		arr[i].ayr = ayr
		arr[i].amo = amo
		arr[i].ady = ady
		arr[i].ahr = ahr
		arr[i].amn = amn
	 	arr[i].y = mr 
	 	k = STRPOS(fi,'-')
		arr[i].type = (k[0] NE -1) ? STRMID(fi,k+1,2) : '??'
	 	i = i+1
	ENDIF
ENDFOR
;
arr = arr[0:i-1]
;
; sort by date
;
j = SORT(arr.x)
arr = arr[j]
END
