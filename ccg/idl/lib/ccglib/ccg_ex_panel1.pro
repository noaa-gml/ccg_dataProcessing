;+
PRO 	CCG_EX_PANEL1,$
	year=year,$
	site=site,$
	flask=flask,$
	dev=dev,$
	nolabid=nolabid
;
;Illustrates how to pass keywords to a procedure
;and check that the required keywords have been
;passed.

;The following keywords are set to default only
;for this example procedure. 

	year=1994
	site='brw'
	flask=1
;
;Data reside in .../data/brw94.ch4
;Data reside in .../data/brw.ch4
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;-----------------------------------------------check site information 
;
IF NOT KEYWORD_SET(site) THEN BEGIN
	CCG_MESSAGE,"'site' must be specified, i.e., site='spo'.  Exiting ..."
	RETURN
ENDIF

site=STRLOWCASE(site)
;
;-----------------------------------------------check year information 
;
IF NOT KEYWORD_SET(year) THEN BEGIN
	CCG_MESSAGE,"'year' must be specified, i.e., year=1993.  Exiting ..."
	RETURN
ENDIF

year=year MOD 100
;
;----------------------------------------------- set up plot device 
;
CCG_OPENDEV,	dev=dev,pen=pen
;
;----------------------------------------------- misc initialization 
;
DEFAULT=(-999.99)
;
;----------------------------------------------- read in-situ data
;
file=STRCOMPRESS(dir+'data/'+site+STRING(year)+'.ch4',/RE)
CCG_FREAD,file=file,nc=6,var
iyr=REFORM(var(1,*))
imo=REFORM(var(2,*))
idy=REFORM(var(3,*))
ihr=REFORM(var(4,*))
;
CCG_DATE2DEC,	yr=iyr,mo=imo,dy=idy,hr=ihr,dec=dec
xis=dec+1900
yis=REFORM(var(5,*))
xis=xis(WHERE(yis NE DEFAULT))
yis=yis(WHERE(yis NE DEFAULT))
;
cmdl=['mlo','brw']
ymin=[ 1650, 1750]
ymax=[ 1850, 1950]
ystep=[   4,    4]
;
PLOT, 		[0],[0],$
		/NODATA,$
		/NOERASE,$
		CHARTHICK=2.0,$
		CHARSIZE=2.0,$
		COLOR=pen(1), $
		TITLE=STRUPCASE(site),$
	
		YRANGE=[ymin(WHERE(cmdl EQ site)),ymax(WHERE(cmdl EQ site))],$
		YSTYLE=1,$
		YMINOR=2,$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
 		YTITLE='CH!D4!n (ppb)',$
	
		XRANGE=[1900+year,1900+year+1],$
		XSTYLE=1+4

CCG_XLABEL,	x1=1990+year,x2=1900+year+1,$
		y1=ymin(WHERE(cmdl EQ site)),y2=ymax(WHERE(cmdl EQ site)),$
		mon=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		XTHICK=2.0,$
		XTITLE=STRCOMPRESS('19'+STRING(year),/RE)

CCG_SYMBOL,	sym=10,fill=0
OPLOT,		xis,yis,COLOR=pen(2),PSYM=8,SYMSIZE=0.4 
;
;----------------------------------------------- read flask data
;
IF KEYWORD_SET(flask) THEN BEGIN

	CCG_FLASKAVE,file=dir+'data/brw.ch4',sp='ch4',xret,yret,xnb,ynb

	i=WHERE(xret GE year AND xret LT year+1)
	IF i(0) NE -1 THEN BEGIN
		xret=xret(i)
		yret=yret(i)
	ENDIF

	i=WHERE(xnb GE year AND xnb LT year+1)
	IF i(0) NE -1 THEN BEGIN
		xnb=xnb(i)
		ynb=ynb(i)
	ENDIF

	CCG_SYMBOL,	sym=2,fill=1
	OPLOT,		xret,yret,COLOR=pen(3),PSYM=8,SYMSIZE=1.0 

	CCG_SYMBOL,	sym=4,fill=1
	OPLOT,		xnb,ynb,COLOR=pen(4),PSYM=8,SYMSIZE=1.0 
ENDIF
;
;------------------------------------------------ lab id label
;
IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
