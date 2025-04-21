;+
; NAME:
;	CCG_MSREAD	
;
; PURPOSE:
; 	Read a species-dependent CCG moving flask 
;	site file.  At this time, file may only be
;	from the aircraft project.  Intended to be 
;	used with CCG_MSWRITE.
;
;	User may suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_MSREAD,file='filename',arr
;	CCG_MSREAD,file='/projects/co/aircraft/site/car.co',data
;
; INPUTS:
;	Filename:  file name must include the species name.
;		   co,co2,h2,ch4,n2o,c13,o18.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;
; OUTPUTS:
;	Data:   This array is of type 'ccgmoving' structure:
;
;		arr().str 	-> entire site string
;		arr().x		-> GMT date/time in decimal format
;		arr().y		-> arr value (mixing ratio, per mil)
;		arr().code	-> 3-letter site code
;		arr().id	-> 8-character flask id
;		arr().type	-> 2-character flask id suffix
;		arr().meth	-> single character method
;		arr().inst	-> 2-character analysis instrument code
;		arr().adate	-> analysis date in decimal format
;		arr().source	-> 6-character raw file name
;		arr().flag	-> 3-character selection flag
;		arr().lat	-> decimal latitude position 
;		arr().lon	-> decimal longitude position 
;		arr().alt	-> altitude in km above sea level
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a site file format.  File name must
;	contain species name (see INPUTS).
;
; PROCEDURE:
;	Once the site file is read into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the site file.  
;		Example:
;			CCG_MSREAD,file='aircraft/site/car.co2',arr
;			.
;			.
;			.
;			PLOT, arr.x,arr.y
;			PLOT, arr(WHERE(arr.meth EQ 'P')).x, $
;			      arr(WHERE(arr.meth EQ 'P')).y
;			.
;			.
;			.
;			MSWRITE,n_butyl,file='/users/ken/temp.co2'
;
;		
; MODIFICATION HISTORY:
;	Written, KAM, February 1996.
;-
;
PRO CCG_MSREAD,	file=file,$
		nomessages=nomessages,$
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
	CCG_MESSAGE,"(ex) CCG_MSREAD,file='/projects/ch4/aircraft/site/car.ch4',arr"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
;
DEFAULT=(-999.99)
;
CASE 1 OF

(STRPOS(file,"o18") NE -1): 	BEGIN
					DEFAULT=(-999.999)
					header=0
				END
(STRPOS(file,"c13") NE -1): 	BEGIN
					DEFAULT=(-999.999)
					header=0
				END
(STRPOS(file,"co2") NE -1): 	BEGIN
					header=0
				END
(STRPOS(file,"ch4") NE -1): 	BEGIN
					header=0
				END
(STRPOS(file,"n2o") NE -1): 	BEGIN
					header=0
				END
(STRPOS(file,"co") NE -1): 	BEGIN
					header=0
				END
(STRPOS(file,"h2") NE -1): 	BEGIN
					header=0
				END
ELSE:				BEGIN
					CCG_MESSAGE,$
					"Source file must include species code."
					CCG_MESSAGE,$
					"Codes include co2,ch4,co,h2,n2o,c13,o18."
					RETURN
				END
ENDCASE
;
;Determine number of lines
;in file.
;
nlines=CCG_LIF(file=file)-header
IF nlines LE 0 THEN BEGIN
	arr=0
	RETURN
ENDIF
;
arr=REPLICATE({	ccgmoving,		$		 
	 		str:	'',		$
	 		x: 	0.0D,           $
 		  	y: 	0.0, 		$ 
 			code:	'',		$
 		  	id: 	'',		$ 
 		  	type: 	'',		$ 
 		 	meth: 	'', 		$ 
 			inst:	'',		$ 
 			adate:	0.0D,   	$
 			source: '',		$
			lat:	0.0,		$
			lon:	0.0,		$
			alt:	0.0,		$
 			flag:	'   '},		$ 
 			nlines)


sformat='(A3,1X,I4.4,1X,4(I2.2,1X),A8,1X,A1,1X,F8.3,'+$
		'1X,A3,1X,A2,1X,I4.4,1X,2(I2.2,1X),A6,1X,F9.0,2(1X,F9.2))'

yr=0  & mo=0  & dy=0  & hr=0  & mn=0
st='' & fi='' & me='' & fl='' & in='' 
ad='' & fg='' & sc='' & mr=0.
ayr=0 & amo=0 & ady=0 & mn=0
lat=0. & long=0. & alt=0.
dummy=''

OPENR, unit, file,/GET_LUN

IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Opening '+file+' ...'

i=0 & j=0
WHILE NOT EOF(unit) DO BEGIN
	IF (j EQ 0) AND (header EQ 1) THEN BEGIN
		READF,unit,dummy 
	ENDIF ELSE BEGIN
		READF, unit, FORMAT=sformat,  $
			st,yr,mo,dy,hr,mn,fi,me,mr,$
			fg,in,ayr,amo,ady,sc,$
			alt,lat,long

		IF (hr EQ 99) THEN hr=12
		IF (mn EQ 99) THEN mn=0 

		IF (mr NE DEFAULT) THEN BEGIN	
 		 	arr(i).str=STRING(FORMAT=sformat,$
 		 	st,yr,mo,dy,hr,mn,fi,me,mr,$
			fg,in,ayr,amo,ady,sc,$
			alt,lat,long)
			CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
 		 	arr(i).x=dec
		 	arr(i).code=st
		 	arr(i).id=fi 
		 	arr(i).meth=me 
		 	arr(i).inst=in
		 	arr(i).flag=fg
			CCG_DATE2DEC,yr=ayr,mo=amo,dy=ady,hr=12,mn=00,dec=dec
 		 	arr(i).adate=dec 
		 	arr(i).source=sc 
			arr(i).alt=alt/1000.
			arr(i).lon=long
			arr(i).lat=lat
		 	arr(i).y=mr 
		 	k=STRPOS(fi,'-')
		 	arr(i).type=STRMID(fi,k+1,2)
		 	i=i+1
		ENDIF
	ENDELSE
		j=j+1
ENDWHILE
FREE_LUN, unit
;
arr=arr(0:i-1)
;
IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Done reading '+file+' ...'
END
