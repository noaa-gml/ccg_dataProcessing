;+
; NAME:
;	CCG_FLASKKEY
;
; PURPOSE:
;	Extract flask event number from RDBMS if 
;	user supplies 'old-style' primary key
;
;	OR
;
;	Extract 'old-style' primary key if user 
;	supplies event number
;
; CATEGORY:
;	Data Retrieval
;
; CALLING SEQUENCE:
;
;	CCG_FLASKKEY,evn=182000,arr
;	CCG_FLASKKEY,key='LEF 2003 10 08 20 25 203-15 A',arr
;
; INPUTS:
;	evn:		Event Number
;
;	key:		Old-style primary key.  Must be in quotes
;			and include code, year, month, day, hour,
;			minute, flask Id, and collection method.
;
; OPTIONAL INPUT PARAMETERS:
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
; OUTPUTS:
;	data:		Returns an anonymous structure.  Structure
;			tags depend on passed parameters.
;
;			data.evn 	-> sample collection event number
;			data.code	-> 3-letter site code
;			data.date	-> UTC date/time in decimal format
;			data.yr		-> UTC sample collection year
;			data.mo		-> UTC sample collection month
;			data.dy		-> UTC sample collection day
;			data.hr		-> UTC sample collection hour 
;			data.mn		-> UTC sample collection minute
;			data.id		-> 8-character flask id
;			data.type	-> 2-character flask id suffix
;			data.meth	-> single character method
;
;			data.lat	-> sample collection latitude
;			data.lon	-> sample collection longitude
;			data.alt	-> sample collection altitude (masl)
;			data.lst2utc	-> LST to UTC conversion
;
;			data.comment	-> collection comments (when available)
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Data are returned in an anonymous structure.  Users
;	can employ SQL-type IDL commands to manipulate data.
;
;		Example:
;			CCG_FLASKKEY,evn='182000',data
;			.
;			.
;			.
;			PRINT, data.code, data.id, data.meth
;
; MODIFICATION HISTORY:
;	Written, KAM, August 2004.
;-
;
PRO 	CCG_FLASKKEY,$
	help=help,$
	key=key,$
	evn=evn,$
	res
;
;Return to caller if an error occurs
;
;ON_ERROR,	2
;
;
;check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF N_PARAMS() EQ 0 THEN CCG_FATALERR,"Return variable required (CCG_FLASKKEY,/HELP)."
;
;initialization
;
res = ''
dbdir = '/projects/src/db/'
perlsite = dbdir + 'ccg_getflaskkey.pl'
;
; Build argument list
;
args = ''
IF KEYWORD_SET(key) THEN args += ' -k="'+key+'"'
IF KEYWORD_SET(evn) THEN args += ' -e="'+STRING(evn)+'"'
args += ' -stdout'
;
; Retrieve data from DB
; 
tmp = perlsite+args
SPAWN,tmp,data

IF data[0] EQ '' THEN RETURN

res = CREATE_STRUCT($
'code','','yr',0,'mo',0,'dy',0,'hr',0,'mn',0,$
'date',0D,'id','','type','','meth','',$ 
'lat',0.0,'lon',0.0,'alt',0.0,'lst2utc',0.0,$
'comment','','evn',0L)

IF KEYWORD_SET(key) THEN BEGIN
	str = STRSPLIT(key,' ',/EXTRACT)
	res.code = str[0]
	res.yr = FIX(str[1])
	res.mo = FIX(str[2])
	res.dy = FIX(str[3])
	res.hr = FIX(str[4])
	res.mn = FIX(str[5])
	res.id = str[6]
	res.meth = str[7]
	res.evn = LONG(data[0])
ENDIF

IF KEYWORD_SET(evn) THEN BEGIN
	str = STRSPLIT(data[0],' ',/EXTRACT)
	res.evn = evn
	res.code = str[0]
	res.yr = FIX(str[1])
	res.mo = FIX(str[2])
	res.dy = FIX(str[3])
	res.hr = FIX(str[4])
	res.mn = FIX(str[5])
	res.id = str[6]
	res.meth = str[7]
	res.lat = FLOAT(str[8])
	res.lon = FLOAT(str[9])
	res.alt = FLOAT(str[10])
	res.lst2utc = FLOAT(str[11])
	res.comment = (N_ELEMENTS(str) EQ 13) ? str[12] : ''
ENDIF

thr = (res.hr EQ 99) ? 12 : res.hr
tmn = (res.mn EQ 99) ?  0 : res.mn
CCG_DATE2DEC,yr=res.yr,mo=res.mo,dy=res.dy,hr=thr,mn=tmn,dec=dec
res.date = dec

k = STRPOS(res.id,'-')
res.type = (k[0] NE -1) ? STRMID(res.id,k+1,2) : '??'

END
