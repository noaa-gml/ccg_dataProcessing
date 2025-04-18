;+
; NAME:
;	CCG_ODR	
;
; PURPOSE:
;	Perform Orthogonal Distance Regression.
;
;	CCG_ODR will reduce to a least squares fit when
;	ywts=(-1) and xwts>>1 
;
;	Source...
;
; 		ODRPACK Version 2.01
;		Software for Weighted Orthogonal
;		Distance Regression
;	
;		Paul T. Boggs, Richard H. Byrd,
;		Janet E. Rogers and Robert B. Schnabel
;
;		Applied and Computational Mathematics Division
;		June 1992.
;
;	WARNING:
;		Outcome depends on assigned weight values.
;		Suggested weights are related to the 
;		(variance of x)E-1 and (variance of y)E-1.
;
;		Refer to ODRPACK manual for additional 
;		information on assigning weights.
;
; CATEGORY:
;	Models.
;
; CALLING SEQUENCE:
;   	CCG_ODR,	xarr=xarr,yarr=yarr,$
;			xwts=xwts,ywts=ywts,$
;			npoly=2,results=results
;
; INPUTS:
;	xarr:		Array of abscissa values.
;	yarr:		Array of ordinate values.
;	xwts:		Array of abscissa weights (related to errors).
;	ywts:		Array of ordinate weights (related to errors).
;	npoly:		Integer value of number of polynomial terms in fit. 
;			NOTE:
;				npoly=2 -> linear
;				npoly=3 -> quadratic
;
; OPTIONAL INPUT PARAMETERS:
;	xret:		Calculate y values using ODR-
;			determined coefficients given the
;			passed x values.
;
;       nomessages:     If non-zero, messages will be suppressed.
;
; OUTPUTS:
;	results:	Double precision  array containing
;			coefficients and associated 
;			coefficient uncertainties. Array will
;			have dimensions results(2,npoly)
;
;	summary:	ODRPACK summary information.
;
;	yret:		Calculated values using determined
;			coefficients and passed xret array
;			values.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	xarr, yarr, xwts, and ywts must all have
;	same dimensions.
;
; PROCEDURE:
;	Example:
;			.
;			.
;			.
;			CCG_FREAD,$
;			file='/projects/co/maps/csiro/csiro.cal',nc=4,skip=1,data
;			;
;			x=data(0,*)
;			xwt=1.0/data(1,*)
;			y=data(2,*)
;			ywt=1.0/data(3,*)
;			;
;			CCG_ODR,$
;			xarr=x,yarr=y,xwts=xwt,ywts=ywt,npoly=3,results=results
;			;
;			PRINT,results
;			.
;			.
;			.
;			END
;			
;		
; MODIFICATION HISTORY:
;	Written, KAM, September 1994.
;	Modified, KAM, November 1996.
;-
PRO 	CCG_ODR,	xarr=xarr,yarr=yarr,$
			xwts=xwts,ywts=ywts,$
			xret=xret,yret=yret,$
			nomessages=nomessages,$
			npoly=npoly,$
			results=results,summary=summary, $
			help = help
;
;Polynomial curve fits with uncertainty
;in both x and y.  Calls FORTRAN routine
;'odrfit.c and odrfit.f' which uses ODR.
;
;----------------------------------------------- check parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(xarr) AND NOT KEYWORD_SET(yarr) THEN BEGIN
	CCG_MESSAGE,'Both x and y arrays must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_ODR,xarr=xarr,yarr=yarr,xwts=xwtarr,ywts=ywtarr,npoly=2'
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(npoly) THEN BEGIN
	CCG_MESSAGE,'The number of polynomial terms must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_ODR,xarr=xarr,yarr=yarr,xwts=xwtarr,ywts=ywtarr,npoly=2'
	RETURN
ENDIF
;
IF N_ELEMENTS(x) NE N_ELEMENTS(y) THEN BEGIN
	CCG_MESSAGE,'xarr and yarr arrays must have same dimension.  Exiting ...'
	RETURN
ENDIF
;
IF ((KEYWORD_SET(xwts) AND NOT KEYWORD_SET(ywts)) OR $
    (KEYWORD_SET(ywts) AND NOT KEYWORD_SET(xwts))) THEN BEGIN 
	CCG_MESSAGE,'Weights must be specified for all or no variables.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_ODR,xarr=xarr,yarr=yarr,xwts=xwtarr,ywts=ywtarr,npoly=2'
	CCG_MESSAGE,'(ex) CCG_ODR,xarr=xarr,yarr=yarr,npoly=2'
	RETURN
ENDIF
;
n=N_ELEMENTS(xarr)
;
;When ywts=(-1) and xwts>>1 
;then result is comparable
;to a least squares fit.
;
IF NOT KEYWORD_SET(xwts) AND NOT KEYWORD_SET(ywts) THEN BEGIN 
   IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'No weights assigned, assuming a least squares fit ...'
	xwts=MAKE_ARRAY(n,/FLOAT,VALUE=(999999))
	ywts=MAKE_ARRAY(n,/FLOAT,VALUE=(-1))
;	xwts=MAKE_ARRAY(n,/FLOAT,VALUE=(1))
;	ywts=MAKE_ARRAY(n,/FLOAT,VALUE=(1))
ENDIF
;
;----------------------------------------------- misc initialization 
;
DEFAULT=(-999.99)
tempfile=STRCOMPRESS(GETENV("HOME")+'/.ccg_odr.temp',/REMOVE_ALL)
tempfile2=STRCOMPRESS(GETENV("HOME")+'/.ccg_odr.temp2',/REMOVE_ALL)
reportfile=STRCOMPRESS(GETENV("HOME")+'/.ccg_odr.report',/REMOVE_ALL)
;
;Estimate the coefficients using POLY_FIT.
;This is crucial!!
;
result=POLY_FIT(xarr,yarr,npoly-1)
;
;Write data to temporary file.
;Data file will be read by 
;FORTRAN odrfit.f routine.
;
OPENW,unit,tempfile,/GET_LUN
FOR i=0,npoly-1 DO PRINTF,unit,FORMAT='(F)',result(i)
FREE_LUN,unit
CCG_FWRITE,file=tempfile,nc=4,double=1,/nomessages,append=1,xarr,xwts,yarr,ywts
;
;Run FORTRAN routine which calls ODRPACK routines.
;
idldir = '/ccg/idl/lib/ccglib/'
;ccode=idldir + 'src/odr/odrfit'
ccode=idldir + 'src/odr/odrfit.py'

SPAWN,	ccode+' '+$
	'-s'+tempfile+' '+$
	'-d'+reportfile+' '+$
	'-o'+STRING(npoly)
;
;read odrfit results file
;
CCG_SREAD,file=reportfile, /nomessages, sarr
;
;Pass ODRPACK summary back. 
;
summary=sarr
;
j=WHERE(STRPOS(sarr,"BETA      S.D. BETA") NE -1)
si=j(0)+2
sarr=sarr(si:si+npoly-1)
;
;write these strings to a temporary
;file, then read the file.  This is
;to avoid special formats.
;
OPENW,unit,tempfile2,/GET_LUN
FOR j=0,N_ELEMENTS(sarr)-1 DO BEGIN
	i=STRPOS(sarr(j),"DROPPED")
	IF i(0) NE -1 THEN BEGIN
		PRINTF,unit,FORMAT='(A26,1X,F13.3)',sarr(j),DEFAULT
	ENDIF ELSE BEGIN
		PRINTF,unit,FORMAT='(A40)',sarr(j)
	ENDELSE
ENDFOR
FREE_LUN,unit
;
;
;now read temporary file
;
CCG_FREAD,file=tempfile2, /nomessages, nc=3,var
;
np=N_ELEMENTS(var(0,*))
results=MAKE_ARRAY(2,np,/DOUBLE,VALUE=0)
results(0,*)=var(1,*)
results(1,*)=var(2,*)
;
;print results
;
IF NOT KEYWORD_SET(nomessages) THEN BEGIN
	PRINT,FORMAT='(/,A10,1X,A10,1X,A10)','#','coef','stdev'

	FOR i=0,np-1 DO BEGIN
		PRINT,FORMAT='(I10,1X,F14.6,1X,F14.6)',i,results(0,i),results(1,i)
	ENDFOR
ENDIF
;
;If user passes 'xret' array
;then determine 'yret'.
;
IF KEYWORD_SET(xret) THEN BEGIN
	nret=N_ELEMENTS(xret)
	yret=MAKE_ARRAY(nret,/DOUBLE,VALUE=0)
	;
	FOR i=0,nret-1 DO BEGIN
		FOR j=0,np-1 DO yret(i)=TEMPORARY(yret(i))+results(0,j)*(xret(i)^j)
	ENDFOR
ENDIF
;
;Remove temporary files.
;
SPAWN,	'/bin/rm -f '+tempfile+' '+reportfile
END
