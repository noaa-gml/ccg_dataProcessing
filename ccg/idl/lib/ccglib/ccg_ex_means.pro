;+
PRO 	CCG_EX_MEANS,	dev=dev,ccg=ccg,$
			year=year,month=month,day=day
;
;-------------------------------------- procedure description
;
;provides examples of the use of
;	(1)	ccg_opendev
;	(2)	ccg_message
;	(3) 	ccg_fread
;	(4)	ccg_date2dec
;	(5)	ccg_means
;	(6)	ccg_symbol
;	(7)	ccg_plotgap
;	(8)	ccg_errplot
;	(9)	ccg_labid
;	(10) 	ccg_closedev
;
;Data reside in .../data/brw94.ch4
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;-------------------------------------- check input parameters
;
IF 	NOT KEYWORD_SET(year) AND $
	NOT KEYWORD_SET(month) AND $
	NOT KEYWORD_SET(day) THEN BEGIN
	CCG_MESSAGE,"Either 'year', 'month', or 'day' must be set.  Exiting ..."
	CCG_MESSAGE,"(ex) CCG_EX_MEANS,	month=1"
	RETURN
ENDIF
;
;-------------------------------------- setup graphics device 
;
CCG_OPENDEV,	dev=dev,pen=pen
;
;-------------------------------------- misc initialization
;
DEFAULT=(-999.99)
;
;-------------------------------------- read ch4 in-situ data
;
CCG_FREAD,	file=dir+'data/brw94.ch4',nc=6,var
;
;-------------------------------------- convert date to decimal date
;
CCG_DATE2DEC,	yr=var(1,*),mo=var(2,*),dy=var(3,*),hr=var(4,*),dec=dec
;
;-------------------------------------- remove default values 
;
i=WHERE(var(5,*)-1 GT DEFAULT)
dec=dec(i)
y=var(5,i)

;
;-------------------------------------- create annual averages
;
IF KEYWORD_SET(year) THEN BEGIN
	CCG_MEANS,	xarr=dec,yarr=y,year=1,xyr,yyr,sd,n
	PRINT,		xyr,yyr,sd,n
ENDIF
;
;-------------------------------------- create monthly averages
;
IF KEYWORD_SET(month) THEN BEGIN
	CCG_MEANS,	xarr=dec,yarr=y,month=1,xmo,ymo,sd,n
 	PRINT,		xmo,ymo,sd,n
ENDIF
;
;-------------------------------------- create daily averages
;
IF KEYWORD_SET(day) THEN BEGIN
	;
	;Use only a subset of yearly file
	;
	dec=dec(WHERE(dec GE 94.50 AND dec LE 94.75))
	y=y(WHERE(dec GE 94.50 AND dec LE 94.75))
	;
	CCG_MEANS,	xarr=dec,yarr=y,day=1,xdy,ydy,sd,n
	PRINT,		xdy,ydy,sd,n
ENDIF
;
;Plot hourly average data
;
PLOT,		dec,y,$
		/NODATA,$
		COLOR=pen(1),$
		CHARSIZE=2.0,$
		TITLE='BARROW IN SITU',$
		XCHARSIZE=1.0,$
		XTITLE='DECIMAL DATE',$
		YTITLE='CH!D4!n (ppb)',$
		YCHARSIZE=1.0, $
		YRANGE=[1750,1950],$
		YSTYLE=1

CCG_PLOTGAP,	dec,y,GAP=1,COLOR=pen(2)

IF KEYWORD_SET(year) THEN BEGIN
	CCG_SYMBOL,	sym=2,fill=1
	OPLOT,		xyr,yyr,$
			COLOR=pen(3),$
			SYMSIZE=2.0,$
			PSYM=8

	CCG_ERRPLOT,	xyr,yyr+sd,yyr-sd,$
			COLOR=pen(3)
ENDIF

IF KEYWORD_SET(month) THEN BEGIN
	CCG_SYMBOL,	sym=1,fill=1
	OPLOT,		xmo,ymo,$
			COLOR=pen(4),$
			SYMSIZE=2.0,$
			PSYM=8

	CCG_ERRPLOT,	xmo,ymo+sd,ymo-sd,$
			COLOR=pen(4)
ENDIF

IF KEYWORD_SET(day) THEN BEGIN
	CCG_SYMBOL,	sym=3,fill=1
	OPLOT,		xdy,ydy,$
			COLOR=pen(5),$
			SYMSIZE=2.0,$
			PSYM=8

	CCG_ERRPLOT,	xdy,ydy+sd,ydy-sd,$
			COLOR=pen(5)
ENDIF
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
