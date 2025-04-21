;+
PRO 	CCG_EX_PANEL2,$
	dev=dev,$
	ccg=ccg
;
;Make a two-panel figure
;with a common X axis.
;
;Data reside in .../data/zone_gl.co2
;Data reside in .../data/zone_gltr.co2
;Data reside in .../data/zone_glgr.co2
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;
;----------------------------------------------- set up plot device 
;
CCG_OPENDEV,	dev=dev,pen=pen,portrait=1,xpixels=600,ypixels=800
;
;----------------------------------------------- misc initialization 
;
fyear=1981
lyear=1994
nyears=lyear-fyear+1
;
;----------------------------------------------- read data
;
CCG_FREAD,file=dir+'data/zone_gl.co2',nc=2,var
xgl=REFORM(var(0,*))
ygl=REFORM(var(1,*))

CCG_FREAD,file=dir+'data/zone_gltr.co2',nc=2,var
xtr=REFORM(var(0,*))
ytr=REFORM(var(1,*))

CCG_FREAD,file=dir+'data/zone_glgr.co2',nc=2,var
xgr=REFORM(var(0,*))
ygr=REFORM(var(1,*))
;
;Don't plot the last 1/2 year
;of a growth rate curve
;
j=WHERE(xgr LE 1994.5)
xgr=xgr(j)
ygr=ygr(j)
;
;Define Y range and labels
;
ymin=330
ymax=370
ystep=4
co2=[' ','340','350','360','  ']

PLOT, 		[0],[0],$
		POSITION=[0.18,0.55,0.94,0.95],$
		/NODATA,$
		/NOERASE,$
 		TITLE='NOAA/CMDL CO!D2!n Measurements',$
		CHARSIZE=2.0,$
		CHARTHICK=2.0,$
		COLOR=pen(1), $
	
		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=2,$
		YTITLE='CO!D2!n (ppm)',$
		YTICKS=ystep,$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
		YTICKNAME=co2,$
	
		XRANGE=[fyear,lyear+1],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=MAKE_ARRAY(nyears,/STR,VALUE=' '),$
		XTHICK=2.0

OPLOT, 		xgl,ygl, $
		COLOR=pen(3),$
		LINESTYLE=0,$
		THICK=5.0

OPLOT, 		xtr,ytr, $
		COLOR=pen(2),$
		LINESTYLE=0,$
		THICK=5.0

XYOUTS,		1982,360,$
		'GLOBALLY AVERAGED',$
		CHARTHICK=2.0,$
		CHARSIZE=1.4
;
;----------------------------------------------- panel 2
;
ymin=(-1)
ymax=4
ystep=5
co2=['  ','   0','   1','  2','  3',' ']

PLOT, 		[0],[0], $ 
		POSITION=[0.18,0.15,0.94,0.55], $
		/nodata,$
		/noerase,$
		CHARSIZE=2.0,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
	
		YRANGE=[ymin,ymax], $
		YSTYLE=1,$
		YMINOR=5,$
		YTICKS=ystep,$
		YTITLE='CO!i2!n (ppm/yr)',$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
		YTICKNAME=co2,$
	
		XRANGE=[fyear,lyear+1],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=STRCOMPRESS(STRING(INDGEN(nyears)+fyear-1900),/REMOVE_ALL),$
		XMINOR=1, $
		XTITLE='YEAR',$
		CHARSIZE=1.5, $
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		xgr,ygr,$
		COLOR=pen(13),$
		LINESTYLE=0,$
		THICK=5

OPLOT, 		[fyear,lyear+1],[0,0],COLOR=pen(1),LINESTYLE=2,THICK=1

XYOUTS,		1982,3,$
		'GLOBAL GROWTH RATE',$
		CHARTHICK=2.0,$
		CHARSIZE=1.4
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev
END
;-
