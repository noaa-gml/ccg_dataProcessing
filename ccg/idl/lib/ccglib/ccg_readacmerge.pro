;+
; NAME:
;	CCG_READACMERGE	
;
; PURPOSE:
; 	Read a CCGG merged aircraft site file or 
;	similarly formatted file.  
;
;	FORMAT=A3,1X,I4,4(1X,I2),1X,A8,1X,A1,1X,F6.2,1X,F7.2,1X,F7.1,1X,A2,1X,F6.1,1X,F6.1,1X,F6.1,
;		<#>(1X,F8.3,1X,A3)
;
;	where <#> is the number of measurement values
;	and associated flags.  
;
;	These files contain ...
;
;	1.  The sample collection details
;		+ 31-character key (primary key)
;		+ Position information
;		+ Meteorological information
;	2.  Analysis summary for all species
;		+ The mixing/isotope ratio
;		+ The 3-character 'qualifier' flag
;
;	CCGG aircraft merged files are automatically re-constructed weekly.
;	Returned structure array contains default values when
;	no mixing ratios are found.
;	
;	User may suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_READACMERGE,file='filename',/nomessages,s
;	CCG_READACMERGE,file='/projects/aircraft/car/history/1999/1999-07-07.1641.mrg',a
;
; INPUTS:
;	file:  		Expects CCG aircraft merged file format.
;			File path must be included with file name.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;	header:		If non-zero, the procedure will assume first
;			record in file contains an information header.
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
;	r().x		-> UTC date/time in decimal year format
;	r().yr		-> sample collection year (UTC)
;	r().mo		-> sample collection month (UTC)
;	r().dy		-> sample collection day (UTC)
;	r().hr		-> sample collection hour (UTC)
;	r().mn		-> sample collection minute (UTC)
;	r().code	-> 3-letter site code
;	r().id		-> 8-character flask id
;	r().type	-> 2-character flask id suffix
;	r().meth	-> single character collection method
;       r().lat		-> decimal latitude position
;       r().lon		-> decimal longitude position
;       r().alt		-> altitude in m above sea level
;	r().altflg	-> altitude flag
;	r().temp	-> air temperature (deg C)
;	r().press	-> air pressure (mbar)
;	r().rh		-> relative humidity (%)
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
;		speed).  If the user reads a file from the CCG aircraft
;		project then 
;
;			v1=co2
;			v2=ch4
;			v3=co
;			v4=h2
;			v5=n2o
;			v6=sf6
;			v7=co2c13
;			v8=co2o18
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a CCG aircraft merged file format.
;
; PROCEDURE:
;	Once the network merge file is read into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the file.  
;		Example:
;			CCG_READACMERGE,$
;			file='/projects/aircraft/car/history/1999/1999-07-07.1641.mrg',$
;			arr
;			.
;			.
;			.
;			PLOT,arr.v1,arr.alt,PSYM=4
;			.
;			.
;			.
;		
; MODIFICATION HISTORY:
;	Written, KAM, July 1999.
;-
PRO CCG_READACMERGE,	file=file,$
			nomessages=nomessages,$
			header=header,$
			nvals=nvals,$
			arr
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(file) THEN CCG_FATALERR,$
	"Source file name with path must be specified.  Exiting ..."
;
;If no directory path is included in 'file'
;input parameter then report error.
;
IF STRPOS(file,'/') EQ -1 THEN $
	CCG_FATALERR,"directory path must be included in file name."
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
IF KEYWORD_SET(header) THEN header=1 ELSE header=0
IF NOT KEYWORD_SET(nvals) THEN nvals=8
;
;Determine number of lines in file.
;
nlines=CCG_LIF(file=file)-header
IF nlines LE 0 THEN BEGIN
	arr=0
	RETURN
ENDIF
;
DEFAULT=(-999.999)
WS_DEFAULT=(-9.9)
WD_DEFAULT=(999)
LAT_DEFAULT=(-99.99)
LON_DEFAULT=(-999.99)
ALT_DEFAULT=(-9999.9)

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
		'altflg','',		$
		'temp',	LAT_DEFAULT,	$
		'press',LAT_DEFAULT,	$
		'rh',LAT_DEFAULT)

zz=CREATE_STRUCT(zz,			$
		'co2',DEFAULT,		$
		'co2flag','',		$
		'ch4',DEFAULT,		$
		'ch4flag','',		$
		'co',DEFAULT,		$
		'coflag','',		$
		'h2',DEFAULT,		$
		'h2flag','',		$
		'n2o',DEFAULT,		$
		'n2oflag','',		$
		'sf6',DEFAULT,		$
		'sf6flag','',		$
		'co2c13',DEFAULT,	$
		'co2c13flag','',	$
		'co2o18',DEFAULT,	$
		'co2o18flag','')

arr=REPLICATE(zz,nlines)
sformat1='(A3,1X,I4,4(1X,I2),1X,A8,1X,A1,1X,F6.2,1X,F7.2,1X,F7.1,1X,A2,1X,F6.1,1X,F6.1,1X,F6.1)'
sformat2='(1X,F8.3,1X,A3)'

yr=0  & mo=0  & dy=0  & hr=0  & mn=0
st='' & fi='' & me='' & fl='' & in=''
lat=0. & long=0. & alt=0. & altflg=''
te=0. & pr=0. & rh=0.

v=0. & vf=''

CCG_SREAD,file=file,nomessages=nomessages,skip=header,str
FOR i=0,nlines-1 DO BEGIN

 	READS,str(i),$
 	FORMAT=sformat1,st,yr,mo,dy,hr,mn,fi,me,lat,long,alt,altflg,te,pr,rh

	IF hr EQ 99 THEN hr=12
	IF mn EQ 99 THEN mn=00

	CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
 	arr(i).x=dec
	arr(i).yr=yr
	arr(i).mo=mo
	arr(i).dy=dy
	arr(i).hr=hr
	arr(i).mn=mn
 	arr(i).code=st
    	arr(i).id=fi
 	arr(i).meth=me
 	arr(i).lat=lat
 	arr(i).lon=long
 	arr(i).alt=alt
 	arr(i).altflg=altflg
 	arr(i).temp=te
 	arr(i).press=pr
 	arr(i).rh=rh
 	k=STRPOS(fi,'-')
        IF k NE -1 THEN arr(i).type=STRMID(fi,k+1,2)

	arr(i).str=STRING(FORMAT=sformat1,st,yr,mo,dy,hr,mn,fi,me,lat,$
		long,alt,altflg,te,pr,rh)

	FOR j=0,nvals-1 DO BEGIN
		z=STRMID(str(i),78+13*j,13)
		arr(i).str=arr(i).str+z
 		READS,z,FORMAT=sformat2,v,vf
                arr(i).(19+j*2)=v
                arr(i).(19+j*2+1)=vf
	ENDFOR
ENDFOR
END 
