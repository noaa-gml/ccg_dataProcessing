;+
PRO 	ccg_ex_ccgvu,dev=dev
;
;-------------------------------------- procedure description
;
;Procedure showing the use of CCG_CCGVU
;
;provides examples of the use of
;
;	(1)	ccg_opendevp
;	(2) 	ccg_flaskave
;	(3)	ccg_ccgvu
;	(4)	ccg_xlabel
;	(5)	ccg_symbol
;	(6)	ccg_tlegend
;	(7)	ccg_llegend
;	(8)	ccg_slegend
;	(9) 	ccg_closedev
;
;Data reside in .../data/shm.co2
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;----------------------------------------------- set up plot device 
;
CCG_OPENDEV,	dev=dev,pen=pen,xpixels=600,ypixels=800,portrait=1
;
;----------------------------------------------- misc initialization 
;
srcfile=dir+'data/shm.co2'
;
;----------------------------------------------- read data
;
CCG_FLASKAVE,	sp='co2',site='shm', file=srcfile,xret,yret
;
;Call to CCG_CCGVU
;
CCG_CCGVU,	x=xret,y=yret,$
		nharm=4,npoly=3,interval=7,$
		cutoff1=80,cutoff2=667,$
		ftn=ftn,sc=sc,tr=tr,gr=gr,$
		fsc=fsc,ssc=ssc,$
		residf=residf,residsc=residsc,$
		coef=coef,$
		summary=summary
;
;Print summary
;
FOR i=0,N_ELEMENTS(summary)-1 DO PRINT,summary(i)
;
;Define X/Y labels
;
fyear=1985
lyear=1996
nyears=lyear-fyear+1

ymin=330
ymax=370
ystep=4
co2=[' ','  340','  350','  360','  ']
;
;----------------------------------------------- panel 1
;

PLOT, 		[0],[0],$
		POSITION=[0.1,0.77,0.90,1.02],$
		/NODATA,$
		/NOERASE,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
		TITLE=srcfile,$
	
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

CCG_SYMBOL,	sym=2,fill=0

OPLOT, 		xret,yret,$
		PSYM=8,$
		SYMSIZE=0.5,$
		COLOR=pen(2)

OPLOT, 		ftn(0,*),ftn(1,*),$
		LINESTYLE=0,$
		THICK=2.0,$
		COLOR=pen(5)

OPLOT, 		sc(0,*),sc(1,*),$
		LINESTYLE=0,$
		THICK=2.0,$
		COLOR=pen(3)

OPLOT, 		tr(0,*),tr(1,*),$
		LINESTYLE=0,$
		THICK=2.0,$
		COLOR=pen(4)
;
;Text legend
;
CCG_TLEGEND,	x=0.82,y=0.87,$
		tarr=['c(t)','f(t)','S(t)','T(t)'],$
		carr=[pen(2),pen(5),pen(3),pen(4)],$
		CHARSIZE=1.0,$
		CHARTHICK=1.0
;
;----------------------------------------------- panel 2
;
ymin=(-20)
ymax=20
ystep=4
co2=['  ','  -10','   0','   10',' ']

PLOT, 		[0],[0],$ 
		POSITION=[0.1,0.52,0.90,0.77],$
		/nodata,$
		/noerase,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
	
		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=5,$
		YTICKS=ystep,$
		YTITLE='CO!D2!n (ppm)',$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
		YTICKNAME=co2,$
	
		XRANGE=[fyear,lyear+1],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=MAKE_ARRAY(nyears,/STR,VALUE=' '),$
		XMINOR=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		fsc(0,*),fsc(1,*),$
		COLOR=pen(2),$
		LINESTYLE=0,$
		THICK=2

OPLOT,		ssc(0,*),ssc(1,*),$
		COLOR=pen(3),$
		LINESTYLE=0,$
		THICK=2

OPLOT, 		[fyear,lyear+1],[0,0],COLOR=pen(1),LINESTYLE=1,THICK=1
;
;Line legend
;
CCG_LLEGEND,	x=0.15,y=0.73,$
		tarr=[	'harmonic component of f(t)',$
			'harmonic component of S(t)'],$
		larr=[0,0],$
		carr=[pen(2),pen(3)],$
		CHARSIZE=1.0,$
		CHARTHICK=1.0
;
;----------------------------------------------- panel 3
;
ymin=(-10)
ymax=10
ystep=4
co2=['  ','   -5','    0','    5',' ']

PLOT, 		[0],[0],$ 
		POSITION=[0.1,0.27,0.90,0.52],$
		/nodata,$
		/noerase,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
	
		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=5,$
		YTICKS=ystep,$
		YTITLE='CO!D2!n (ppm)',$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
		YTICKNAME=co2,$
	
		XRANGE=[fyear,lyear+1],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=MAKE_ARRAY(nyears,/STR,VALUE=' '),$
		XMINOR=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		XTHICK=2.0

CCG_SYMBOL,	sym=10,fill=0

OPLOT,		residf(0,*),residf(1,*),$
		COLOR=pen(2),$
		PSYM=8,$
		SYMSIZE=0.5

CCG_SYMBOL,	sym=2,fill=0

OPLOT,		residsc(0,*),residsc(1,*),$
		COLOR=pen(3),$
		PSYM=8,$
		SYMSIZE=0.5

OPLOT, 		[fyear,lyear+1],[0,0],COLOR=pen(1),LINESTYLE=1,THICK=1
;
;Symbol legend
;
CCG_SLEGEND,	x=0.15,y=0.48,$
		tarr=['residuals of f(t)','residuals of S(t)'],$
		sarr=[10,2],$
		farr=[0,0],$
		carr=[pen(2),pen(3)],$
		CHARSIZE=1.0,$
		CHARTHICK=1.0
;
;----------------------------------------------- panel 4
;
ymin=-5
ymax=5
ystep=4
co2=['  ',' -2.5','   0','  2.5',' ']

PLOT, 		[0],[0],$ 
		POSITION=[0.1,0.02,0.90,0.27],$
		/nodata,$
		/noerase,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
	
		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=2,$
		YTICKS=ystep,$
		YTITLE='CO!D2!n (ppm/yr)',$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
		YTICKNAME=co2,$
	
		XRANGE=[fyear,lyear+1],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear+1,y1=ymin,y2=ymax,$
		tarr=STRCOMPRESS(STRING(INDGEN(nyears)+fyear-1900),/R),$
		XMINOR=1,$
		CHARSIZE=1.5,$
		CHARTHICK=2.0,$
		XTHICK=2.0

OPLOT,		gr(0,*),gr(1,*),$
		COLOR=pen(4),$
		LINESTYLE=0,$
		THICK=5

OPLOT, 		[fyear,lyear+1],[0,0],COLOR=pen(1),LINESTYLE=1,THICK=1
;
;Text legend
;
CCG_TLEGEND,	x=0.78,y=0.05,$
		tarr=['dT(t)/dt'],$
		carr=[pen(4)],$
		CHARSIZE=1.0,$
		CHARTHICK=1.0
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev
END
;-
