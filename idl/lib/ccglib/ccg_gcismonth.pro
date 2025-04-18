;+
; NAME:
;	CCG_GCISMONTH	
;
; PURPOSE:
;	This FUNCTION reads GC in situ month files. 
;	If the source file does not exist then
;	the function returns zero (0) otherwise
;	the function returns one (1).
;
;	User may suppress messages.
;
;
; CATEGORY:
;	CCG Gas Chromatographic In situ.
;
; CALLING SEQUENCE:
;	z=CCG_GCISMONTH(file=filename,armr=armr,flag=flag)
;	z=CCG_GCISMONTH,(file='.../in-situ/brw_data/month/brw199512.ch4',$
;			gmt=gmt,htmr=htmr,armr=armr,flag=flag)
;	z=CCG_GCISMONTH(file=filename,armr=armr,flag=flag,port=port,/nomessages)
;
; INPUTS:
;	file:	  	Source file name. File must have GC IS monthly format.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;
; OUTPUTS:
;	gmt:		A double precision vector containing GMT of ambient sample.
;
;	gmf:		A double precision vector containing the fractional component
;			only of the GMT of ambient sample.  This is useful when
;			making plots with resolution greater than 1 month. 
;
;	htmr:		A single precision vector containing mixing ratio 
;			determined using peak heights.
;
;	armr:		A single precision vector containing mixing ratio 
;			determined using peak areas.
;
;	port:		An integer vector containing the ambient port values.
;
;	flag:		A string vector containing the single flag assigned by
;			during raw file processing.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Source file must have the GC in situ monthly file format.
;
; PROCEDURE:
;
;		Example:
;			z=CCG_GCISMONTH(file=file,gmt=a,armr=c,flag=d,/nomessages)
;			IF NOT z THEN RETURN
;			.
;			j=WHERE(flag NE '*')
;			.
;			.
;			IF j(0) EQ -1 THEN RETURN
;			
;			PLOT, a,c
;			.
;			.
;			.
;			END
;
;		
; MODIFICATION HISTORY:
;	Written,  KAM, December 1995.
;-
;
FUNCTION	CCG_GCISMONTH,	file=file,$
				gmt=gmt,$
				gmf=gmf,$
				htmr=htmr,$
				armr=armr,$
				port=port,$
				inst=inst,$
				flag=flag,$
				nomessages=nomessages
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"File name must be specified.  Exiting ..."
	CCG_MESSAGE,"(ex) CCG_GCISMONTH,file='/projects/ch4/in-situ/mlo_data/month/mlo199512.ch4',gmt=gmt,htmr=htmr,armr=armr"
	RETURN,0
ENDIF
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
;Determine number of
;lines in file.
;
nl=CCG_LIF(file=file)

IF nl EQ 0 THEN RETURN,0
;
;dimension arrays
;
gmt=DBLARR(nl)
gmf=DBLARR(nl)
htmr=FLTARR(nl)
armr=FLTARR(nl)
port=INTARR(nl)
inst=STRARR(nl)
flag=STRARR(nl)

format='(I4,4(1X,I2),2(1X,F8.2),1X,I2,1X,A2,1X,A)'
a=INTARR(5)
b=FLTARR(2)
c=0
d=''
e=''
 
OPENR, 	unit,file,ERROR=err, /GET_LUN
 
IF (err NE 0) THEN BEGIN
	CCG_MESSAGE,'Cannot open '+file+' ...'
	RETURN,0
ENDIF ELSE BEGIN
	IF NOT nomessages THEN CCG_MESSAGE,'Reading '+file+' ...'
	;
	;Read data
	;
	i=0
	WHILE NOT EOF(unit) DO BEGIN
		READF,unit,FORMAT=format,a,b,c,d,e
		CCG_DATE2DEC,yr=a(0),mo=a(1),dy=a(2),hr=a(3),mn=a(4),dec=dec
		gmt(i)=dec
		CCG_DATE2DEC,yr=a(0)-FIX(a(0)),mo=a(1),dy=a(2),hr=a(3),mn=a(4),dec=dec
		gmf(i)=dec
		htmr(i)=b(0)
		armr(i)=b(1)
		port(i)=c
		inst(i)=d
		flag(i)=e
		i=i+1
	ENDWHILE
	FREE_LUN, unit
	;
	IF NOT nomessages THEN CCG_MESSAGE,'Done reading '+file+' ...'
	RETURN,1
ENDELSE
END
