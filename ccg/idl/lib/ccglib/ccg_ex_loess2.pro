;+
PRO 	CCG_EX_LOESS2,	dev=dev,ccg=ccg,span=span,degree=degree,weight=weight
;
;-------------------------------------- procedure description
;
;provides examples of the use of
;	(1)	ccg_opendev
;	(2) 	ccg_fread
;	(3)	ccg_symbol
;	(4)	ccg_loess
;	(5)	ccg_labid
;	(6) 	ccg_closedev
;
;
;Data reside in .../data/loess.dat
;Data reside in .../data/loess2.dat
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;User passed options
;
IF NOT KEYWORD_SET(degree) THEN degree=2
IF NOT KEYWORD_SET(span) THEN span=0.01
;
;
;-------------------------------------- setup graphics device 
;
CCG_OPENDEV,	dev=dev,pen=pen
;
;**************************************
;		FIGURE a
;**************************************
;
;
;-------------------------------------- read data
;
CCG_FREAD,	file=dir+'data/loess2.dat',nc=2,var
;
;Re-assign variables
;
x=REFORM(var(0,*))
mr=REFORM(var(1,*))
narr=N_ELEMENTS(var(0,*))
;
PLOT,		x,mr,$
		/NODATA,$
		COLOR=pen(1),$
		CHARSIZE=2.0,$
		XCHARSIZE = 1.0, $
		XTITLE='DATE',$
		YTITLE='CO!D2!n (ppm)',$
		YCHARSIZE = 1.0, $
		YRANGE=[310,370],$
		YTICKS=5,$
		YMINOR=2,$
		XMINOR=2,$
		XSTYLE=1,$
		YSTYLE=1

CCG_SYMBOL,	sym=2,fill=0
OPLOT,		x,mr,PSYM=8,SYMSIZE=0.5,COLOR=pen(3)
;
;Prepare for loess fit
;
xpred=x
;
;Make call to CCG_LOESS
;
CCG_LOESS,	xarr=x,yarr=mr,$
		narr=narr,npred=1,$
		span=span,degree=degree,$
		yfit=yfit,resid=resid,$
		xpred=xpred,ypred=ypred
;
OPLOT,		xpred,ypred,LINESTYLE=0,THICK=2.0,COLOR=pen(2)
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID
;
;**************************************
;		FIGURE b
;**************************************
;
;Evaluate loess fit
;
IF NOT KEYWORD_SET(dev) THEN WINDOW,	1,YSIZE=250
;
PLOT,		x,resid,$
		/NODATA,$
		COLOR=pen(1),$
		CHARSIZE=2.0,$
		TITLE='y minus yfit',$
		XCHARSIZE = 1.0, $
		YTITLE='CO!i2!n (ppm)',$
		YCHARSIZE = 1.0, $
		YMINOR=2,$
		XMINOR=2,$
		XSTYLE=1,$
		YSTYLE=1

CCG_SYMBOL,	sym=2,fill=0
OPLOT,		x,resid,PSYM=8,SYMSIZE=0.5,COLOR=pen(3)

OPLOT,		[MIN(x),MAX(x)],[0,0],LINESTYLE=2,THICK=2.0,COLOR=pen(1)
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
