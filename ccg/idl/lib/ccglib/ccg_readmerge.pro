;+
; NAME:
;	CCG_READMERGE	
;
; PURPOSE:
; 	Read a CCG merged site file or similarly
;	formatted file.  See CCG_FSMERGE for an 
;	description of how the merged files are 
;	constructed.
;
;	FORMAT=A3,1X,I4,4(1X,I2),1X,A8,1X,1A,1X,F6.2,1X,F7.2,1X,I6,1X,I3,1X,F4.1,
;		<#>(1X,F8.3,1X,A3)
;
;	where <#> is the number of measurement values
;	and associated flags.  
;
;	These files contain ...
;
;	1.  The sample collection details
;		+ 31-character key
;		+ Position information
;		+ Meteorological information
;	2.  Analysis summary for all species
;		+ The mixing/isotope ratio
;		+ The 3-character 'qualifier' flag
;
;	CCG merged files are automatically re-constructed weekly.
;	Returned structure array contains default values when
;	no mixing ratios are found.
;	
;
;	User may suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_READMERGE,file='filename',arr
;	CCG_READMERGE,file='/projects/network/flask/merge/brw.mrg',/nomessages,arr
;
; INPUTS:
;	file:  		Expects CCG network merged file format.
;			If no path is specified with file name then
;			procedure assumes the default merged file directory.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;	skip:		Number of lines to skip.
;	nvals:		If non-zero, the procedure will assume there
;			are 'nvals' measurement results and flags.  Each
;			row in the file must still have all the data 
;			attributes appearing before the first measurement
;			value.
;
; OUTPUTS:
;	r:		Returned result is a structure array defined as follows:
;
;	r().str 	-> entire site string
;	r().x		-> GMT date/time in decimal year format
;	r().yr		-> sample collection year (GMT)
;	r().mo		-> sample collection month (GMT)
;	r().dy		-> sample collection day (GMT)
;	r().hr		-> sample collection hour (GMT)
;	r().mn		-> sample collection minute (GMT)
;	r().code	-> 3-letter site code
;	r().id		-> 8-character flask id
;	r().type	-> 2-character flask id suffix
;	r().meth	-> single character method
;       r().lat		-> decimal latitude position
;       r().lon		-> decimal longitude position
;       r().alt		-> altitude in m above sea level
;	r().wd		-> wind direction in degrees (0-360)
;	r().ws		-> wind speed (m/s).
;	r().v<#>	-> mixing/isotope ratio
;	r().v<#>flag	-> qualifying flag associated with derived value
;
;       NOTE:   The returned structure name is determined by user.
;
;               Type 'HELP, <structure name>, /str' at IDL prompt for
;               a description of the structure.
;
;	NOTE:	<#> is the number of the measurement value beyond the
;		meteorological parameters (i.e., wind direction and
;		speed).  If the user reads a file from the CCG network
;		then 
;			v1=co2
;			v2=ch4
;			v3=co
;			v4=h2
;			v5=n2o
;			v6=sf6
;			v7=co2c13
;			v8=co2o18
;
;		If the user reads the CSD merged file then v9=co2o17
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a CCG network merged file format.
;
; PROCEDURE:
;	Once the network merge file is read into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the file.  
;		Example:
;			CCG_READMERGE,file='/projects/network/flask/merge/brw.mrg',arr
;			.
;			.
;			.
;			j=WHERE(arr.v1flag EQ '...' AND arr.v2flag EQ '...')
;			PLOT,arr(j).v1,arr(j).v2,PSYM=4
;			.
;			.
;			.
;		
; MODIFICATION HISTORY:
;	Written, KAM, January 1998.
;	Modified, KAM, October 2005.
;-
PRO CCG_READMERGE,	file = file, $
			nomessages = nomessages, $
			skip = skip, $
			nvals = nvals, $
			arr
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"Source file name must be specified.  Exiting ..."
	CCG_MESSAGE,"(ex) CCG_READMERGE,file='projects/network/flask/merge/brw',arr"
	RETURN
ENDIF
;
;If no directory path is included in 'file'
;input parameter then assume default merged
;directory path.
;
mdir = '/projects/network/flask/merge/'
IF STRPOS(file, '/') EQ -1 THEN file = mdir + file
;
nomessages = KEYWORD_SET(nomessages) ? 1 : 0
IF NOT KEYWORD_SET(nvals) THEN nvals = 8

DEFAULT = (-999.999)
WS_DEFAULT = (-9.9)
WD_DEFAULT = (999)
LAT_DEFAULT = (-99.99)
LON_DEFAULT = (-999.99)
ALT_DEFAULT = (-99999.9)

zz=CREATE_STRUCT('str',	'',		$
	 	'x' ,	0D,             $
		'yr',	0,		$
		'mo',	0,		$
		'dy',	0,		$
		'hr',	0,		$
		'mn',	0,		$
 		'code', '',		$
 		'id',	'',		$ 
 		'type',	',-1',		$ 
 		'meth',	'', 		$ 
 		'inst',	'',		$ 
		'lat',	LAT_DEFAULT,	$
		'lon',	LON_DEFAULT,	$
		'alt',	ALT_DEFAULT,	$
		'wd',	WD_DEFAULT,	$
		'ws',	WS_DEFAULT)

FOR j = 0, nvals - 1 DO zz = CREATE_STRUCT(TEMPORARY(zz), $
			'v' + STRCOMPRESS(STRING(j + 1), /RE), DEFAULT, $
			'v' + STRCOMPRESS(STRING(j + 1), /RE) + 'flag', '')

CCG_SREAD, file = file, nomessages = nomessages, skip = skip, str
nstr = N_ELEMENTS(str)

arr = REPLICATE(zz, nstr)

FOR i = 0, nstr - 1 DO BEGIN

	tmp = STRSPLIT(str[i], /EXTRACT)

	yr = FIX(tmp[1])
	mo = FIX(tmp[2])
	dy = FIX(tmp[3])
	hr = (FIX(tmp[4] EQ 99)) ?  12 : FIX(tmp[4])
	mn = (FIX(tmp[5] EQ 99))  ? 0 : FIX(tmp[5])

	CCG_DATE2DEC, yr = yr, mo = mo, dy = dy, hr = hr, mn = mn, dec = dec

 	arr[i].x = dec
	arr[i].yr = yr
	arr[i].mo = mo
	arr[i].dy = dy
	arr[i].hr = hr
	arr[i].mn = mn
 	arr[i].code = tmp[0]
    	arr[i].id = tmp[6]
 	arr[i].meth = tmp[7]
 	arr[i].lat = FLOAT(tmp[8])
 	arr[i].lon = FLOAT(tmp[9])
 	arr[i].alt = FLOAT(tmp[10])
 	arr[i].wd = FIX(tmp[11])
 	arr[i].ws = FLOAT(tmp[12])

 	k = STRPOS(tmp[6], '-')
        IF k NE -1 THEN arr[i].type = STRMID(tmp[6], k + 1, 2)

	arr[i].str = str[i]

	tmp = tmp[13:*]
	FOR j = 0, nvals - 1 DO BEGIN
                arr[i].(17 + j * 2) = FLOAT(tmp[j * 2])
                arr[i].(17 + j * 2 + 1) = tmp[j * 2 + 1]
	ENDFOR
ENDFOR
END 
