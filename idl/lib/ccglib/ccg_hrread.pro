;+
; NAME:
;	CCG_HRREAD	
;
; PURPOSE:
; 	Read a CCG files containing in situ hourly average data.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_HRREAD,file='filename',arr
;	CCG_HRREAD,file='/projects/co/in-situ/brw_data/brw1996.co',/nomessages,arr
;	CCG_HRREAD,file='~joe/hr.dat',structarr,/nodefault
;
; INPUTS:
;	Filename:  File must conform to CCG hourly average format.
;		   (ex)  BRW 2002 12 31 14  1843.46   0.72 .C.
;
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;
;	nodefault:	If non-zero, DEFAULT values will be excluded from the 
;			returned structure vector.
;
;	met:		If non-zero, GMD met data, if available, will be included.
;			Met data are read from /ftp/met/hourlymet/<site>/.  See
;			/met/hourlymet/README for details.
;
;			Met parameters include wd (999), ws (99.9), sf (0),
;			press (9999.9), temp (99.9), dp (99.9), and precip (999).
;
; OUTPUTS:
;	Data:   Type: anonymous structure
;
;		arr[].str	-> all parameters joined into a string constant
;		arr[].code	-> site code
;		arr[].x		-> UTC date/time in decimal format (obsolete)
;		arr[].date	-> UTC date/time in decimal format
;		arr[].yr	-> sample year
;		arr[].mo	-> sample month
;		arr[].dy	-> sample day
;               arr[].hr        -> sample hour
;               arr[].y         -> mixing ratio (obsolete)
;               arr[].value     -> mixing ratio
;               arr[].sd        -> standard deviation of hourly average
;               arr[].flag      -> selection flag
;
; 		If 'met' keyword is non-zero, the following additional
;		tags are included ...
;
;		arr[].wd        -> wind direction (deg)
;               arr[].ws        -> wind speed (m/s)
;               arr[].sf        -> wind steadiness factor
;               arr[].press     -> station pressure (mbars)
;               arr[].temp      -> air temperature (deg C)
;               arr[].dp        -> dew point temperature (deg C)
;               arr[].precip    -> precipitation amount (mm)
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a CCG in situ hourly average file format.
;
; PROCEDURE:
;	Once the hourly average file is read into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the file.  
;		Example:
;			CCG_HRREAD,file='/projects/co2/in-situ/brw_data/brw1996.ch4',arr
;			.
;			.
;			.
;			PLOT,arr.x,arr.y
;			.
;			.
;
;		
; MODIFICATION HISTORY:
;	Written, KAM, June 1998.
;	Modified, KAM, May 2004.
;	Modified, KAM, August 2005.
;	Modified, KAM, September 2006 (include met option).
;-
@ccg_utils.pro

PRO CCG_HRREAD,	file = file, $
		nomessages = nomessages, $
		nodefault = nodefault, $
		met = met, $
		help = help, $
		arr
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(file) THEN CCG_SHOWDOC
;
arr = 0
DEFAULT = (-999.999)

nomessages = KEYWORD_SET(messages) ? 1: 0
nodefault = KEYWORD_SET(nodefault) ? 1: 0
met = KEYWORD_SET(met) ? 1 : 0
;
;Does file exist?
;
z = FILE_SEARCH(file, COUNT = count)
IF count EQ 0 THEN RETURN
;
; Create data structure
; Retain 'x' and 'y' for backwards compatability
;
z = CREATE_STRUCT($
'str',          '', $
'code',		'', $
'yr',           0, $
'mo',           0, $
'dy',           0, $
'hr',           0, $
'x', 		0D, $
'y', 		0.0, $
'date', 	0D, $
'value',	0.0, $
'sd', 		0.0, $
'flag',		'')

IF met THEN z = CREATE_STRUCT(z, 'wd', 999, 'ws', 99.9, 'sf', 0, 'press', 9999.9, 'temp', 99.9, 'dp', 99.9, 'precip', 999)

CCG_READ, file = file, nomessages = nomessages, data

n = N_ELEMENTS(data)
arr = REPLICATE(z, n)

arr.str = data.str
arr.code = data.field1

arr.yr = data.field2
arr.mo = data.field3
arr.dy = data.field4
arr.hr = data.field5

CCG_DATE2DEC, yr = arr.yr, mo = arr.mo, dy = arr.dy, hr = arr.hr, dec = dec
arr.date = dec
arr.x = dec

arr.y = data.field6
arr.value = data.field6
arr.sd = data.field7
arr.flag = data.field8
;
;Exclude default values?
;
arr = (KEYWORD_SET(nodefault)) ? arr(WHERE(arr.y - 1 GT DEFAULT)) : arr
;
; Met data?
;
IF met THEN BEGIN
	;
	; Build file name.  Read from FTP server
	;
	exception = (STRCMP(arr[0].code, 'BRW', /FOLD_CASE) NE 0) ? '/rtd/' : '/'

	f = '/ftp/met/hourlymet/' + STRLOWCASE(arr[0].code) + exception
	f = f + STRLOWCASE(arr[0].code) + ToString(arr[0].yr)
	;
	;Does met file exist?
	;
	z = FILE_SEARCH(f, COUNT = count)
	IF count EQ 0 THEN RETURN

        idldir = '/ccg/idl/lib/ccglib/'
	RESTORE,file=idldir + 'data/cmdl_met_hr_template'

        IF NOT nomessages THEN CCG_MESSAGE, 'Reading ' + f + ' ...'
        met = READ_ASCII(f, template = template)
        IF NOT nomessages THEN CCG_MESSAGE, 'Done reading ' + f + '.'
	;
	; Loop through gas array (it may be smaller!)
	;
	FOR i = 0, N_ELEMENTS(arr) - 1 DO BEGIN
		j = WHERE(met.yr EQ arr[i].yr AND met.mo EQ arr[i].mo AND met.dy EQ arr[i].dy AND met.hr EQ arr[i].hr)
		IF j[0] EQ -1 THEN CONTINUE
		
		arr[i].ws = met.ws[j[0]]
		arr[i].wd = met.wd[j[0]]
		arr[i].sf = met.sf[j[0]]
		arr[i].press = met.pressure[j[0]]
		arr[i].temp = met.temp[j[0]]
		arr[i].dp = met.dwpt[j[0]]
		arr[i].precip = met.precip[j[0]]
	ENDFOR
ENDIF
END
