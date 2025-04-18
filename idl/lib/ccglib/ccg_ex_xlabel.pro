;+
PRO 	CCG_EX_XLABEL,$
	dev=dev,ccg=ccg
;
;-------------------------------------- procedure description
;
;provides examples of the use of
;	(1)	ccg_opendev
;	(2) 	ccg_fread
;	(3)	ccg_xlabel
;	(4)	ccg_labid
;	(5)	ccg_closedev
;
;Data reside in .../data
;
;Ignore this line of code.
;Required only for example
;procedure.
;
dir='/ccg/idl/lib/ccglib/'
;
;----------------------------------------------- set up plot device 
;
CCG_OPENDEV,	dev=dev,pen=pen
;
;----------------------------------------------- misc initialization 
;
fyear=1990
lyear=1991
;
!P.MULTI=[0,1,2]
;
;----------------------------------------------- read data
;
CCG_FREAD,	file=dir+'data/alt_gr.ch4',nc=2,var
xaltgr=var(0,*)
yaltgr=var(1,*)

CCG_FREAD,	file=dir+'data/mbc_gr.ch4',nc=2,var
xmbcgr=var(0,*)
ymbcgr=var(1,*)

CCG_FREAD,	file=dir+'data/cba_gr.ch4',nc=2,var
xcbagr=var(0,*)
ycbagr=var(1,*)

CCG_FREAD,	file=dir+'data/brw_gr.ch4',nc=2,var
xbrwgr=var(0,*)
ybrwgr=var(1,*)
;
;----------------------------------------------- first figure
;
ymin=-10
ymax=30
ystep=8
ch4=[' ','-5','0','5','10','15','20','25',' ']

PLOT, 		[0],[0],$
		/NODATA,$
		TITLE='Northern Hemisphere Flask Sites',$
		CHARSIZE=2.0,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$
	
		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=1,$
		YTICKS=ystep,$
		YTITLE='ppb/yr',$
		YTICKNAME=ch4,$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$
	
		XRANGE=[fyear,lyear],$
		XSTYLE=1+4
	
CCG_XLABEL,	x1=fyear,x2=lyear,y1=ymin,y2=ymax,$
		abbr=1,$
		charsize=3.0,$
		xthick=2.0,$
		charthick=2.0

OPLOT, 		xaltgr,yaltgr,COLOR=pen(2),LINESTYLE=0,THICK=3
OPLOT, 		xmbcgr,ymbcgr,COLOR=pen(3),LINESTYLE=0,THICK=3
OPLOT, 		xcbagr,ycbagr,COLOR=pen(4),LINESTYLE=0,THICK=3
OPLOT, 		xbrwgr,ybrwgr,COLOR=pen(5),LINESTYLE=0,THICK=3
;
;----------------------------------------------- second figure
;
fyear=1983
lyear=1995
;
;----------------------------------------------- set up labels for axes 
;
ymin=-10
ymax=30
ystep=8
ch4=[' ','-5','0','5','10','15','20','25',' ']

PLOT, 		xaltgr,yaltgr,$
		/NODATA,$
		TITLE='Northern Hemisphere Flask Sites',$
		CHARSIZE=2.0,$
		CHARTHICK=2.0,$
		COLOR=pen(1),$

		YRANGE=[ymin,ymax],$
		YSTYLE=1,$
		YMINOR=1,$
		YTICKS=ystep,$
		YTITLE='ppb/yr',$
		YTICKNAME=ch4,$
		YCHARSIZE=1.0,$
		YTHICK=2.0,$

 		XRANGE=[fyear, lyear],$
 		XSTYLE=1+4


CCG_XLABEL,	x1=fyear,x2=lyear,y1=ymin,y2=ymax,$
		tarr=STRCOMPRESS(STRING(indgen(lyear-fyear)+fyear),/REMOVE_ALL),$
		xthick=2.0,$
		xminor=2,$
		xtitle='YEAR',$
		charsize=1.4,$
		charthick=2.0

OPLOT, 		xaltgr,yaltgr,COLOR=pen(2),LINESTYLE=0,THICK=3
OPLOT, 		xmbcgr,ymbcgr,COLOR=pen(3),LINESTYLE=0,THICK=3
OPLOT, 		xcbagr,ycbagr,COLOR=pen(4),LINESTYLE=0,THICK=3
OPLOT, 		xbrwgr,ybrwgr,COLOR=pen(5),LINESTYLE=0,THICK=3
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID,full=1
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
