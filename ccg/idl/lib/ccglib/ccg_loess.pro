;+
; NAME:
;	CCG_LOESS	
;
; PURPOSE:
;	Perform LOcal regrESSion fit to passed arrays.
;
;	Source...
;
; 		Private communication with William Cleveland (ptans)
;		
;		A Package of C and Fortran Routines for Fitting
;		Local Regression Models
;
;		William S. Cleveland
;		Eric Grosse
;		Ming-Jen Shyu
;		
;		August 20, 1992
;
;	Source downloaded from:
;
;		netlib.att.com
;
;	WARNING:
;		Outcome depends on assigned weight values.
;		Refer to LOESS manual for additional 
;		information on assigning weights.
;
; CATEGORY:
;	Models.
;
; CALLING SEQUENCE:
;   	CCG_LOESS,	xarr=xarr,yarr=yarr,narr=narr,npred=npred
;
;	CCG_LOESS,	xarr=xarr,yarr=yarr,narr=narr,npred=npred,$
;			wts=wtarr,degree=1,span=0.5
;			yfit=yfit,resid=resid,$
;			xpred=xpred,ypred=ypred,$
;			drop_square=drop_square,$
;			parametric=parametric,$
;			family=family,$
;			surface=surface,$
;			statistics=statistics,$
;			trace_hat=trace_hat,$
;			iterations=iterations,$
;			normalize=normalize,$
;			se_fit=se_fit
;
; INPUTS:
;	xarr:		Array of abscissa values.
;	yarr:		Array of ordinate values.
;	narr:		Number of elements in xarr (must be same as yarr)
;	npred:		Number of numeric predictors. 
;
; OPTIONAL INPUT PARAMETERS:
;	wts:		Weights assigned to ordinate values.
;	span:		Smoothing parameter (default:  0.75).
;	degree:		Degree of locally-fitted polynomial (default:  2).
;	xpred:		Array of abscissa values used to predict ordinate values;
;
;			For an explanation of these optional parameters
;			refer to the above-mentioned source.
;	drop_square:	
;	parametric:
;	family:
;	surface:
;	statistics:
;	trace_hat:
;	iterations:
;	normalize:
;	se_fit:
;
; OUTPUTS:
;	yfit:		Array values from the LOESS curve fit at every 'xarr' value.
;	resid:		Array of calculated residuals - yarr-yfit.
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
;			narr=N_ELEMENTS(x)
;			xpred=FINDGEN(41)*0.05-1
;			;
;			CCG_LOESS,$
;			xarr=x,yarr=y,wts=wt,narr=narr,npred=1,xpred=xpred,ypred=ypred
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
;	Written, KAM, September 1994.
;-
PRO 	CCG_LOESS,	xarr=xarr,yarr=yarr,$
			narr=narr,npred=npred,wts=wts,$
			span=span,degree=degree,$
			yfit=yfit,resid=resid,$
			xpred=xpred,ypred=ypred,$
 			drop_square=drop_square,$
 			parametric=parametric,$
 			family=family,$
			iterations=iterations,$
 			normalize=normalize,$
 			se_fit=se_fit, $
			help = help
;
;----------------------------------------------- check parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(xarr) AND NOT KEYWORD_SET(yarr) THEN BEGIN
	CCG_MESSAGE,'Both x and y arrays must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_LOESS,xarr=xarr,yarr=yarr,narr=N_ELEMENTS(xarr),npred=1'
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(narr) THEN BEGIN
	CCG_MESSAGE,'The number of elements in yarr must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_LOESS,xarr=xarr,yarr=yarr,narr=N_ELEMENTS(yarr),npred=1'
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(npred) THEN BEGIN
	CCG_MESSAGE,'The number of numeric predictors (factors) must be specified.  Exiting ...'
	CCG_MESSAGE,'(ex) CCG_LOESS,xarr=xarr,yarr=yarr,narr=N_ELEMENTS(yarr),npred=1'
	RETURN
ENDIF
;
IF N_ELEMENTS(xarr)/npred NE N_ELEMENTS(yarr) THEN BEGIN
	CCG_MESSAGE,'xarr/npred and N_ELEMENTS(yarr) must be equal.  Exiting ...'
	RETURN
ENDIF
;
IF KEYWORD_SET(drop_square) THEN BEGIN
	IF N_ELEMENTS(drop_square) NE npred THEN BEGIN
		CCG_MESSAGE,"'Drop_square must have 'npred' array size.  Exiting ..."
		RETURN
	ENDIF
ENDIF
;
IF KEYWORD_SET(parametric) THEN BEGIN
	IF N_ELEMENTS(parametric) NE npred THEN BEGIN
		CCG_MESSAGE,"'Parametric must have 'npred' array size.  Exiting ..."
		RETURN
	ENDIF
ENDIF
;
;***IMPORTANT***
;
;Set all unspecified keywords to 
;their LOESS default values. 
;
IF NOT KEYWORD_SET(xpred) THEN xpred=xarr
IF NOT KEYWORD_SET(wts) THEN wts=MAKE_ARRAY(narr,/FLOAT,VALUE=1)
IF NOT KEYWORD_SET(span) THEN span=0.75
IF NOT KEYWORD_SET(degree) THEN degree=2
IF NOT KEYWORD_SET(drop_square) THEN drop_square=MAKE_ARRAY(npred,/FLOAT,VALUE=0)
IF NOT KEYWORD_SET(parametric) THEN parametric=MAKE_ARRAY(npred,/FLOAT,VALUE=0)
IF NOT KEYWORD_SET(family) THEN family="gaussian"
IF NOT KEYWORD_SET(iterations) THEN iterations=0
IF NOT KEYWORD_SET(normalize) THEN normalize=1
IF NOT KEYWORD_SET(surface) THEN surface="interpolate"
IF NOT KEYWORD_SET(statistics) THEN statistics="approximate"
IF NOT KEYWORD_SET(trace_hat) THEN trace_hat="wait.to.decide"
IF NOT KEYWORD_SET(cell) THEN cell=0.2
IF NOT KEYWORD_SET(se_fit) THEN se_fit=0
;
;----------------------------------------------- misc initialization 
;
;
DEFAULT=(-999.99)
homedir=GETENV("HOME")

datfile=homedir+'/.ccg_loess.data'
fitfile=homedir+'/.ccg_loess.fit'
tempfile=homedir+'/.ccg_loess.temp'
reportfile=homedir+'/.ccg_loess.report'
;
;Write data to temporary file.
;Data file will be read by 
;C program 'ccg_loess'.
;
CCG_FWRITE,file=datfile,nc=3,double=1,/nomessages,xarr,yarr,wts
;
;Write x fit data to temporary
;file.  File will be read by 
;C program 'ccg_loess'.
;
CCG_FWRITE,file=fitfile,nc=1,double=1,/nomessages,xpred
;
;Write drop_square and parametric
;arrays to temporary file.
;Data file will be read by 
;C program 'ccg_loess'.
;
CCG_FWRITE,file=tempfile,nc=2,double=1,/nomessages,drop_square,parametric
;
;Run 'c' routine which calls
;LOESSPACK routines.
;
idldir = '/ccg/idl/lib/ccglib/'
ccode=idldir + 'src/loess/ccg_loess'
;
SPAWN,	ccode+' '+$
	' -a'+datfile+$
	' -b'+STRING(narr)+$
	' -c'+STRING(npred)+$
	' -d'+STRING(span)+$
	' -e'+STRING(degree)+$
	' -f'+family+$
	' -g'+STRING(normalize)+$
	' -h'+surface+$
	' -i'+statistics+$
	' -j'+trace_hat+$
	' -k'+STRING(cell)+$
	' -l'+STRING(iterations)+$
	' -m'+STRING(se_fit)+$
	' -n'+tempfile+$
	' -o'+tempfile+$
	' -p'+fitfile
;
;Retrieve x/y prediction results
;
IF KEYWORD_SET(xpred) THEN BEGIN
	;
	;Read  x fit and response
	;results file.  File was 
	;generated by the C program
	;'ccg_loess'.
	;
	CCG_FREAD,file=fitfile,nc=2,/nomessages,var
	xpred=REFORM(var(0,*))
	ypred=REFORM(var(1,*))
ENDIF
;
;Retrieve y fit and residuals
;
CCG_FREAD,file=datfile,nc=4,/nomessages,var
yfit=REFORM(var(2,*))
resid=REFORM(var(3,*))
;
;Remove temporary files.
;
SPAWN,	'/bin/rm -f '+' '+reportfile+' '+fitfile+' '+datfile+' '+tempfile
END
