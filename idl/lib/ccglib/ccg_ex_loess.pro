;+
PRO 	CCG_EX_LOESS,$
	dev=dev,$
	nolabid=nolabid,$
	noproid=noproid,$
	span=span,$
	degree=degree,$
	weight=weight
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
;User passed options
;
;degree=1 or 2		<-degree of local polynomial (default:  2).
;span=0.6		<-amount of smoothing (default:  0.75).
;weight=1		<-assigned weights to the test data should be used (default: 0).
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
CCG_FREAD,	file=dir+'data/loess.dat',nc=4,var
;
;Re-assign variables
;
sinlat=REFORM(var(0,*))
mr=REFORM(var(2,*))
wt=REFORM(var(3,*))
narr=N_ELEMENTS(var(0,*))
;
PLOT,		sinlat,mr,$
		/NODATA,$
		COLOR=pen(1),$
		CHARSIZE=2.0,$
		TITLE='Methane 1990',$
		XCHARSIZE = 1.0, $
		XTITLE='SINE LATITUDE',$
		YTITLE='CH!D4!n (ppb)',$
		YCHARSIZE = 1.0, $
		YRANGE=[1620,1820],$
		YTICKS=5,$
		XRANGE=[-1.2,1.2],$
		YMINOR=2,$
		XMINOR=2,$
		XSTYLE=1,$
		YSTYLE=1

CCG_SYMBOL,	sym=2,fill=0
OPLOT,		sinlat,mr,PSYM=8,SYMSIZE=1.0,COLOR=pen(3)
;
;Prepare for loess fit
;
xpred=FINDGEN(41)*.05-1
;
;should the loess
;fit be weighted?
;
IF NOT KEYWORD_SET(weight) THEN wt=MAKE_ARRAY(narr,/FLOAT,VALUE=1)
;
CCG_LOESS,	xarr=sinlat,yarr=mr,wts=wt,$
		narr=narr,npred=1,$
		span=span,degree=degree,$
		yfit=yfit,resid=resid,$
		xpred=xpred,ypred=ypred
;
OPLOT,		xpred,ypred,LINESTYLE=0,COLOR=pen(4)
;
;------------------------------------------------ lab label
;
IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
;
;------------------------------------------------ procedure label
;
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;
;**************************************
;		FIGURE b
;**************************************
;
;Evaluate loess fit
;
IF NOT KEYWORD_SET(dev) THEN WINDOW,	1,YSIZE=250
;
PLOT,		sinlat,resid,$
		/NODATA,$
		COLOR=pen(1),$
		CHARSIZE=2.0,$
		TITLE='y minus yfit',$
		XCHARSIZE = 1.0, $
		XTITLE='SINE LATITUDE',$
		YTITLE='CH!D4!n (ppb)',$
		YCHARSIZE = 1.0, $
		YRANGE=[-40,40],$
		YTICKS=8,$
		XRANGE=[-1.2,1.2],$
		YMINOR=2,$
		XMINOR=2,$
		XSTYLE=1,$
		YSTYLE=1

CCG_SYMBOL,	sym=2,fill=0
OPLOT,		sinlat,resid,PSYM=8,SYMSIZE=1.0,COLOR=pen(3)

OPLOT,		[-1.2,1.2],[0,0],LINESTYLE=1,COLOR=pen(1)
;
;------------------------------------------------ lab label
;
IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
;
;------------------------------------------------ procedure label
;
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
