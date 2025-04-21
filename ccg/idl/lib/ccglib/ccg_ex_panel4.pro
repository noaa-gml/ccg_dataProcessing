;+
PRO 	CCG_EX_PANEL4,$
	dev=dev
;
;Make a 4-panel figure
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
;----------------------------------------------- set up plot device 
;
CCG_OPENDEV,dev=dev,pen=pen,portrait=1
;
;----------------------------------------------- misc initialization 
;
DEFAULT=(-999.999)

;
;-----------------------------------------------plot data and smooth curve 
;
fyear=1990
lyear=1994
nyears=lyear-fyear+1

year=STRCOMPRESS(STRING(INDGEN(nyears)+fyear),/REMOVE_ALL)
nyear=MAKE_ARRAY(nyears,/STR,VALUE=' ')
;
;panel a
;
ymin=50
ymax=125
ystep=3
ylbl=[' ','75','100',' ']

CCG_FREAD,file=dir+'data/zone_gl.co',nc=2,var
xsc=REFORM(var(0,*))
ysc=REFORM(var(1,*))

PLOT,		[0],[0],$
		POSITION = [0.1,0.77,0.90,1.02], $
		YSTYLE=1,$
		CHARSIZE=1.5,$
		TITLE='ZONAL AVERAGES',$
		CHARTHICK=2.0,$
		YTHICK=2.0,$
		YMINOR=2,$
		YTICKS=ystep,$
		YRANGE=[ymin,ymax],$
		YTICKNAME=ylbl,$
		COLOR=pen(1),$
		YCHARSIZE=1.0,$

		XRANGE=[fyear,lyear+1], $
		XSTYLE=1+4

CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=nyear,$
		XMINOR=1, $
		CHARSIZE=1.5, $
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		xsc,ysc,$
		LINESTYLE=0,$
		THICK=5.0,$
		COLOR=pen(3)

XYOUTS,		1990.25,110,'GL',CHARSIZE=1.5,CHARTHICK=2.0
;
;panel b
;
ymin=50
ymax=250
ystep=4
ylbl=[' ','100','150','200',' ']

CCG_FREAD,file=dir+'data/zone_hnh.co',nc=2,var
xsc=REFORM(var(0,*))
ysc=REFORM(var(1,*))

PLOT,		[0],[0],$
		POSITION = [0.1,0.52,0.90,0.77], $
		/NODATA,$
		/NOERASE,$
		YSTYLE=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		YTHICK=2.0,$
		YMINOR=2,$
		YTICKS=ystep,$
		YRANGE=[ymin,ymax],$
		YTICKNAME=ylbl,$
		COLOR=pen(1),$
		YCHARSIZE=1.0,$

		XRANGE=[fyear,lyear+1], $
		XSTYLE=1+4

CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=nyear,$
		XMINOR=1, $
		CHARSIZE=1.5, $
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		xsc,ysc,$
		LINESTYLE=0,$
		THICK=5.0,$
		COLOR=pen(3)

XYOUTS,		1990.25,210,'HNH',CHARSIZE=1.5,CHARTHICK=2.0
;
;panel c
;
ymin=50
ymax=150
ystep=4
ylbl=[' ','75','100','125',' ']

CCG_FREAD,file=dir+'data/zone_lnh.co',nc=2,var
xsc=REFORM(var(0,*))
ysc=REFORM(var(1,*))

PLOT,		[0],[0],$
		POSITION = [0.1,0.27,0.90,0.52], $
		/NODATA,$
		/NOERASE,$
		YSTYLE=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		YTHICK=2.0,$
		YMINOR=2,$
		YTICKS=ystep,$
		YRANGE=[ymin,ymax],$
		YTICKNAME=ylbl,$
		COLOR=pen(1),$
		YCHARSIZE=1.0,$

		XRANGE=[fyear,lyear+1], $
		XSTYLE=1+4

CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=nyear,$
		XMINOR=1, $
		CHARSIZE=1.5, $
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		xsc,ysc,$
		LINESTYLE=0,$
		THICK=5.0,$
		COLOR=pen(3)

XYOUTS,		1990.25,130,'LNH',CHARSIZE=1.5,CHARTHICK=2.0
;
;panel d
;
ymin=25
ymax=100
ystep=3
ylbl=[' ','50','75',' ']

CCG_FREAD,file=dir+'data/zone_lsh.co',nc=2,var
xsc=REFORM(var(0,*))
ysc=REFORM(var(1,*))

PLOT,		[0],[0],$
		POSITION = [0.1,0.02,0.90,0.27], $
		/NODATA,$
		/NOERASE,$
		YSTYLE=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		YTHICK=2.0,$
		YMINOR=2,$
		YTICKS=ystep,$
		YRANGE=[ymin,ymax],$
		YTICKNAME=ylbl,$
		COLOR=pen(1),$
		YCHARSIZE=1.0,$

		XRANGE=[fyear,lyear+1], $
		XSTYLE=1+4

CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=year,$
		XMINOR=1, $
		XTITLE='YEAR',$
		CHARSIZE=1.5, $
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		xsc,ysc,$
		LINESTYLE=0,$
		THICK=5.0,$
		COLOR=pen(3)


XYOUTS,		1990.25,85,'LSH',CHARSIZE=1.5,CHARTHICK=2.0
;
;y title
;
XYOUTS,		0.00,0.52,/NORMAL,'CO (ppb)',$
		ORIENTATION=90, ALIGNMENT=0.5,$
		CHARSIZE=2.0,CHARTHICK=2.0
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev
END
;-
