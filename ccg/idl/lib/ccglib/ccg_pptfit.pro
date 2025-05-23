;+
; NAME:
;	CCG_PPTFIT	
;
; PURPOSE:
;	Perform a fit to passed x and y array using the curve fitting
;	method developed by Pieter Tans and described in 
;
;		Tans, P.P., T.J. Conway, and T. Nakazawa,
;		Latitudinal distribution of the sources and sinks
;		of atmospheric carbon dioxide derived from surface
;		observations and an atmospheric	transport model, 
;		J. Geophys. Res., 94, 5151-5172, 1989. 
;
;	Return values predicted for Y.
;
;	WARNING:
;		Outcome depends on assigned weight values.
;
; CATEGORY:
;	Models.
;
; CALLING SEQUENCE:
;   	CCG_PPTFIT,	xarr=xarr,yarr=yarr,$
;			xpred=xpred,ypred=ypred
;
; INPUTS:
;	xarr:		Array of abscissa values.
;	yarr:		Array of ordinate values.
;	xpred:		Array of abscissa values used to predict ordinate values.
;			If NOT specified, xpred=xarr.
;
; OPTIONAL INPUT PARAMETERS:
;	wts:		Weights assigned to ordinate values.
;
; OUTPUTS:
;	ypred:		Array of predicted ordinate values from passed 'xpred' array.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	xarr, yarr, wts must all have
;	same dimensions.
;
; PROCEDURE:
;	Example:
;			.
;			.
;			.
;			CCG_FREAD,$
;			file='/users/ken/temp',nc=3,skip=1,data
;			;
;			x=data(0,*)
;			y=data(2,*)
;			wt=data(3,*)
;			xpred=FINDGEN(41)*0.05-1
;			;
;			CCG_PPTFIT,$
;			xarr=x,yarr=y,wts=wt,xpred=xpred,ypred=ypred
;			;
;			PLOT,	x,y,LINESTYLE=0,COLOR=pen(2)
;			OPLOT,	xpred,ypred,LINESTYLE=0,COLOR=pen(3)
;			.
;			.
;			.
;			END
;			
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1995.
;-

@ccg_utils.pro

PRO 	CCG_PPTFIT, $
	xarr = xarr, $
	yarr = yarr, $
	wts = wts, $
	dx = dx, $
	xpred = xpred, $
	ypred = ypred, $
	help = help
;
;----------------------------------------------- check parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(xarr) AND NOT KEYWORD_SET(yarr) THEN BEGIN
	CCG_MESSAGE,'Both x and y arrays must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_PPTFIT,xarr=xarr,yarr=yarr'
	RETURN
ENDIF
;
IF N_ELEMENTS(xarr) NE N_ELEMENTS(yarr) THEN BEGIN
	CCG_MESSAGE,'xarr and yarr must be the same size.  Exiting ...'
	RETURN
ENDIF
;
;***IMPORTANT***
;
;Set all unspecified keywords to 
;their default values. 
;
narr=N_ELEMENTS(yarr)
IF NOT KEYWORD_SET(wts) THEN wts=MAKE_ARRAY(narr,/FLOAT,VALUE=1)
IF NOT KEYWORD_SET(xpred) THEN xpred=xarr
IF NOT KEYWORD_SET(dx) THEN dx=0.15
npred=N_ELEMENTS(xpred)
;
;----------------------------------------------- misc initialization 
;
;
DEFAULT=(-999.99)

; Modified temporary files to includes a random number
; March 2, 2012 (kam)

rn = ToString( LONG( 10E6*RANDOMU(seed, /DOUBLE) +systime(/seconds) ) )
home = GETENV( "HOME" )
datafile = home + '/.ccg_pptfit.data.' + rn 
predfile = home +'/.ccg_pptfit.pred.' + rn
;
;Write data to temporary file.
;Data file will be read by 
;FORTRAN program 'pptfit'.
;
OPENW,out,datafile,/GET_LUN
FOR i=0,narr-1 DO PRINTF,out,FORMAT='(3(F12.6))',xarr(i),yarr(i),wts(i)
FREE_LUN,out
;
IF KEYWORD_SET(xpred) THEN BEGIN
	;
	;Write x fit data to temporary
	;file.  File will be read by 
	;FORTRAN program 'pptfit'.
	;
	OPENW,out,predfile,/GET_LUN
	FOR i=0,npred-1 DO PRINTF,out,FORMAT='(F12.6)',xpred(i)
	FREE_LUN,out
ENDIF
;
;Run Pieter's curve fitting routine.
;
idldir = '/ccg/idl/lib/ccglib/'
ccode=idldir + 'src/pptfit/pptfit'
SPAWN,	ccode+$
	' '+datafile+$
	' '+STRING(narr)+$
	' '+predfile+$
	' '+STRING(npred)+$
	' '+STRING(FORMAT='(F5.3)',dx)
;
;Retrieve x/y prediction results
;
IF KEYWORD_SET(xpred) THEN BEGIN
	;
	;Read x fit and response
	;results file.  File was 
	;generated by the FORTRAN 
	;program 'pptfitf'.
	;
	CCG_FREAD,file=predfile,nc=2,/nomessages,var
	xpred=REFORM(var(0,*))
	ypred=REFORM(var(1,*))
ENDIF
;
;Remove temporary files.
;
SPAWN,	'/bin/rm -f '+predfile+' '+datafile
END
