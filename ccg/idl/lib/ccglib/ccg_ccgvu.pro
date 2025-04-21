;+
; NAME:
;	CCG_CCGVU	
;
; PURPOSE:
;	Perform a fit to passed x and y arrays using the curve fitting
;	techniques developed by the NOAA/CMDL Carbon Cycle Group and
;	documented in 
;
;		Thoning, K.W., P.P. Tans, and W.D. Komhyr,
;		Atmospheric carbon dioxide at Mauna Loa Observatory, 2,
;		Analysis of the NOAA/GMCC data, 1974-1985,
;		J. Geophys. Res., 94, 8549-8565, 1989.
;
;	This procedure calls a 'c' driver which calls the Fortran filter
;	routines developed by Mr. Kirk Thoning of the Carbon Cycle Group.
;
;	WARNING:
;		Outcome depends on most input keywords.
;
; CATEGORY:
;	Models.
;
; CALLING SEQUENCE:
;	CCG_CCGVU,      x=x, y=y, $
;			npoly=npoly, nharm=nharm, tzero=tzero, $
;			interval=interval, cutoff1=cutoff1, cutoff2=cutoff2, $
;			even=even, $
;        poly=poly, $
;			ftn=ftn, sc=sc, tr=tr, gr=gr, $
;			fsc=fsc, ssc=ssc, $
;			residf=residf, residsc=residsc, $
;        residtr=residtr, $
;			coef=coef, $
;			phase=phase, $
;			predfile=predfile, $
;			summary=summary
;
; INPUTS:
;    x:	 	Array of abscissa values.  This vector must have dates in
;		decimal notation, e.g., 1996.011234 or 96.011234.
;
;    y:	 	Array of ordinate values.  This vector contains values
;		to be fitted.
;
; OPTIONAL INPUT PARAMETERS:
;    even:     	If specified then returned arrays (except residuals) will have
;		evenly spaced values beginning at the first data value and 
;		stepping one interval or time-step as specified with keyword
;		'x'.  If not specified, selected return arrays have identical 
;		resolution to source data.
;
;    npoly:    	This keyword is used to specify the number of polynomial
;		terms used in the function f(t).  Note that a default value of 
;		three (3) is used if the source file contains more than two
;		(2) years of data, and a value of two (2) is assigned if less
;		than two (2) years of data are supplied.   Keep in mind that
;		neither default may be appropiate for the supplied data.
;
;    nharm:    	This keyword is used to specify the number of harmonic terms
;		used in the function f(t).  Note that a default value of 
;		four (4) is used .  Keep in mind that this default assignment
;		may not be appropiate for the supplied data.
;
;    interval: 	This keyword is used to specify the resolution or time-step 
;		interval (in days) of the supplied data.  Note that software
;		will assign a default value if none is specified.  Keep in 
;		mind that this default assignment may not be appropiate for 
;		the supplied data.
;
;    cutoff1:  	This keyword is used to specify the short term filter cutoff 
;		used in constructing the smooth curve S(t).  Note that a 
;		default value of eighty (80) is assigned if none is specified.
;		Keep in mind that this default assignment may not be appropiate
;		for the supplied data.
;
;    cutoff2:  	This keyword is used to specify the long term filter cutoff 
;		used in constructing the smooth trend curve T(t).  Note that a 
;		default value of 667 is assigned if none is specified.  Keep
;		in mind that this default assignment may not be appropiate
;		for the supplied data.
;
;    tzero:    	This keyword is used to specify the date (in decimal notation
;		at t=0.  Note that if none is specified then the decimal date
;		at t=0 is set to be the minimum decimal date in the supplied
;		data file.
;
; predfile:    	This keyword names a file that contains a single column of
;		time steps (in decimal years) from which values will be predicted
;		(extracted) from the various fits.  When specified, this procedure 
;		will add 6 columns of predicted values from S(t), f(t), T(t) dT/dt,
;		harmonic components of f(t), and S(t)-T(t) to the input file.
;
; OUTPUTS:
;    ftn:	This keyword is used to capture the function, f(t), fitted
;		to the passed 'x' and 'y' arrays.  The returned array contains
;		two (2) columns.  The first column contains the date in decimal
;		notation and the second column contains values of the function
;		determined at each step.
;
;    sc:	This keyword is used to capture the smooth curve, S(t), fitted
;		to the passed 'x' and 'y' arrays.  The returned array contains
;		two (2) columns.  The first column contains the date in decimal
;		notation and the second column contains values of the smooth
;		curve determined at each step.
;
;    tr:	This keyword is used to capture the smooth trend, T(t).
;		The returned array contains two (2) columns.  The first column
;		contains the date in decimal notation and the second column
;		contains values of the smooth trend curve determined at each
;		time step.
;
;    gr:	This keyword is used to capture the growth rate, dT/dt.
;		The returned array contains two (2) columns.  The first column
;		contains the date in decimal notation and the second column
;		contains values of the growth rate determined at each time step.
;
;    poly: This keyword is used to capture the polynomial component of f(t).
;		The returned array contains two (2) columns.  The first column
;		contains the date in decimal notation and the second column
;		contains values of the polynomial components of f(t) determined
;		at each time step.
;
;    fsc: This keyword is used to capture the harmonic component of f(t).
;		The returned array contains two (2) columns.  The first column
;		contains the date in decimal notation and the second column
;		contains values of the harmonic components of f(t) determined
;		at each time step.
;
;    ssc: This keyword is used to capture the smooth seasonal cycle,
;		S(t)-T(t).  The returned array contains two (2) columns.  The
;		first column contains the date in decimal notation and the
;		second column contains values of the smooth seasonal cycle
;		determined at each time step.
;
;    residf:   	This keyword is used to capture the function residuals,
;		c(t)-f(t).  The returned array will contain two (2) columns.
;		The first column contains the date in decimal notation and
;		the second column contains values of the function residuals
;		determined at each data value time step.
;
;    residsc:  	This keyword is used to capture the smooth curve residuals,
;		c(t)-S(t).  The returned array contains two (2)	columns.  The
;		first column contains the date in decimal notation and the
;		second column contains values of the smooth curve residuals
;		determined at each data value time step.
;
;    residtr:  	This keyword is used to capture the long-term trend in the
;     residuals. The returned array contains two (2)	columns.  The
;		first column contains the date in decimal notation and the
;		second column contains values of the long-term trend in the residuals
;		determined at each data value time step.
;
;    coef:	This keyword is used to capture the function f(t) coefficients 
;		and their uncertainities as defined by Thoning et al.  The
;		returned array contains two (2)	columns.  The first column 
;		contains the coefficient of each term in the function f(t)
;		and the second column contains values of the coefficient
;		uncertainty.  The number of rows in the matrix is determined
;		by the values of npoly and nharm, e.g., rows=npoly+2*nharm.
;
;    phase:	This keyword is used to capture the amplitude and phase of
;		the harmonic terms.  The returned array contains two (2) 
;		columns.  The first column contains the amplitude of the
;		harmonic (sine plus cosine) and the second collumn contains 
;		the phase in degrees.  The number of rows in the matrix is
;		determined by the value 'nharm', e.g., rows=nhars/2.
;
;    summary:  	This keyword is used to produce a summary array.  The 
;		returned string array summarizes all parameters used
;		in the curve fit.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	'x' vector must have decimal date notation, 
;	e.g., 1996.011234 or 96.011234.
;
; PROCEDURE:
;	Example:
;		.
;		.
;		.
;		CCG_FLASKAVE,sp='co2',site='bme',xret,yret
;		;
;	        CCG_CCGVU,$
;			x=xret,y=yret,$
;			npoly=3,nharm=4,$
;			interval=7,cutoff1=80,cutoff2=650,$
;			even=1,$
;			sc=sc,tr=tr,gr=gr,$
;			fsc=fsc,ssc=ssc,$
;			residf=residf,$
;        residsc,residsc,$
;        residtr,residtr
;		;
;		CCG_SYMBOL,sym=1,fill=0
;
;		PLOT,	xret,yret,PSYM=8,COLOR=pen(2)
;		OPLOT,	sc(0,*),sc(1,*),LINESTYLE=0,COLOR=pen(3)
;		OPLOT,	tr(0,*),tr(1,*),LINESTYLE=1,COLOR=pen(4)
;		.
;		.
;		.
;		END
;		
;		
; MODIFICATION HISTORY:
;	Written, KAM, January 1996.
;	Modified, KAM, December 1997.
;	Modified, KAM, June 1998.
;	Modified, KAM, November 2000.  Calls ccgcrv.
;-
PRO	 CCG_CCGVU,	x = x, y = y,$
			npoly = npoly, nharm = nharm, tzero = tzero,$
			interval = interval, cutoff1 = cutoff1, cutoff2 = cutoff2, $
			even = even, $
         poly = poly, $
			ftn = ftn, sc = sc, tr = tr, gr = gr, $
			fsc = fsc, ssc = ssc, $
			residf = residf, residsc = residsc, $
         residtr=residtr, $
			coef = coef, $
			phase = phase, $
			predfile = predfile, $
			summary = summary, $
			help = help
;
;----------------------------------------------- check parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(x) AND NOT KEYWORD_SET(y) THEN BEGIN
	CCG_MESSAGE, 'Both x and y arrays must be specified.  Exiting ...'
	CCG_MESSAGE, '(ex) CCG_CCGVU, x = x, y = y'
	RETURN
ENDIF
;
IF N_ELEMENTS(x) NE N_ELEMENTS(y) THEN BEGIN
	CCG_MESSAGE, 'x and y must be the same size.  Exiting ...'
	RETURN
ENDIF
;
;----------------------------------------------- misc initialization 
;
DEFAULT = (-999.999)
tmpfile1 = CCG_TMPNAM('/tmp/')
tmpfile2 = CCG_TMPNAM('/tmp/')
srcfile = CCG_TMPNAM('/tmp/')

x_ = x
y_ = y

j = SORT(x_)
x_ = x_[j]
y_ = y_[j]

CCG_FWRITE, file = srcfile, nc = 2, /nomessages, /double, x_, y_

ccode = '/ccg/bin/ccgcrv'
;
;Build argument list for C code
;
arg = ' -all -stats -sample -s '+tmpfile1

IF CCG_VDEF(npoly) NE 0 THEN arg = TEMPORARY(arg)+' -npoly '+STRCOMPRESS(STRING(npoly), /RE)
IF CCG_VDEF(nharm) NE 0 THEN arg = TEMPORARY(arg)+' -nharm '+STRCOMPRESS(STRING(nharm), /RE)
IF CCG_VDEF(interval) NE 0 THEN $
	arg = TEMPORARY(arg)+' -interv '+STRCOMPRESS(STRING(interval), /RE)
IF CCG_VDEF(cutoff1) NE 0 THEN $
	arg = TEMPORARY(arg)+' -short '+STRCOMPRESS(STRING(cutoff1), /RE)
IF CCG_VDEF(cutoff2) NE 0 THEN $
	arg = TEMPORARY(arg)+' -long '+STRCOMPRESS(STRING(cutoff2), /RE)
IF CCG_VDEF(tzero) NE 0 THEN $
	arg = TEMPORARY(arg)+' -timez '+STRCOMPRESS(STRING(tzero), /R)
IF CCG_VDEF(predfile) NE 0 THEN $
	arg = TEMPORARY(arg)+' -user '+predfile+' -f '+tmpfile2
IF CCG_VDEF(even) NE 0 THEN $
	arg = TEMPORARY(arg)+' -equal -f '+tmpfile2

arg = TEMPORARY(arg)+' '+srcfile
;
;Run C program to create fits
;
;print, ccode+arg
SPAWN, 	ccode+arg, summary
;
;Capture results
;
CCG_FREAD, file = tmpfile1, /nomessages, nc = 14, v

data = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(1,*))]])
ftn = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(2,*))]])
poly = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(3,*))]])
sc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(4,*))]])
tr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(5,*))]])
detr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(6,*))]])
ssc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(7,*))]])
fsc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(8,*))]])
residf = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(9,*))]])
residtr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(11,*))]])
residsc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(12,*))]])
gr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(13,*))]])
;
;If the keyword "even" has been set then use instead the
;following results (maintain the above data and residual
;arrays).
;
IF KEYWORD_SET(even) THEN BEGIN
	CCG_FREAD, file = tmpfile2, /nomessages, nc = 10, v

	ftn = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(1,*))]])
	poly = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(2,*))]])
	sc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(3,*))]])
	tr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(4,*))]])
	ssc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(5,*))]])
	fsc = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(6,*))]])
	gr = TRANSPOSE([[REFORM(v(0,*))], [REFORM(v(9,*))]])
ENDIF
;
;If the keyword "predfile" has been set then use then
;save following results to "predfile".
;
IF KEYWORD_SET(predfile) THEN BEGIN
	CCG_FREAD, file = tmpfile2, /nomessages, nc = 10, v
	CCG_FWRITE, file = predfile, /nomessages, nc = 7, $
	v[0,*], v[3,*], v[1,*], v[4,*], v[9,*], v[6,*], v[5,*]
ENDIF
;
;Coefficients
;
j = WHERE(STRPOS(summary, "Total Number of parameters") NE -1)
CCG_STRTOK, str = summary[j[0]], z
nc = FIX(z[4])
coef = FLTARR(2, nc)
FOR i = 0, nc - 1 DO BEGIN
	CCG_STRTOK, str = summary[j[0]+3+i], z
	coef[0,i] = FLOAT(z[1])
	coef[1,i] = FLOAT(z[2])
ENDFOR

SPAWN,	'/bin/rm -f '+tmpfile1+' '+tmpfile2+' '+srcfile
END
