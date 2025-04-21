;+
PRO 	CCG_EX_XLABEL2,$
	dev=dev
;
;-----------------------------------------------procedure description 
;
;This example describes the
;differences between using
;and NOT using the CCG_XLABEL
;procedure.
;
;Data reside in .../data/csiro_cmdl.c13
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
CCG_OPENDEV,	dev=dev,pen=pen,portrait=1
;
;----------------------------------------------- misc initialization 
;
!P.MULTI=[0,1,2,0]
;
;----------------------------------------------- X and Y range and labels
;
fyear=1991
lyear=1995
nyears=lyear-fyear+1
year=STRCOMPRESS(STRING(INDGEN(nyears)+fyear),/REMOVE_ALL)
;
ystep=4
ymin=(-0.5)
ymax=(0.5)
ylabl=[' ','-0.25','0','0.25',' ']
title='!4d!e!313!nC (!10(!3)'
;
;Read data file
;
CCG_FREAD,file=dir+'data/csiro_cmdl.c13',nc=4,dat
;
;Plot using CCG_XLABEL
;
PLOT,			[0],[0],$
			/NODATA,$
			CHARSIZE=1.5,$
			CHARTHICK=2.0,$
			YTITLE=title,$
			YSTYLE=1,$
			YMINOR=2,$
			YRANGE=[ymin,ymax],$
			YTICKS=ystep,$
			YTHICK=2.0,$
			YCHARSIZE=1.0,$
			YTICKNAME=ylabl,$
			COLOR=pen(1),$
;
;>>>>Differences begin here>>>>
;
                        XSTYLE=1+4,$
                        XRANGE=[fyear,lyear+1]

CCG_XLABEL,             x1=fyear,x2=lyear+1,$
                        y1=ymin,y2=ymax,$
                        tarr=year,$
                        XTHICK=2.0,$
			XTITLE='YEAR',$
			CHARTHICK=2.0,$
                        CHARSIZE=1.5
;
;<<<<Differences end here<<<<
;
CCG_SYMBOL,		sym=2,fill=1

OPLOT,			dat(0,*),dat(3,*),$
			SYMSIZE=0.75,$
			COLOR=pen(6),$
			PSYM=8

OPLOT,			[fyear,lyear+1],[0,0],LINESTYLE=1
;
;Plot NOT using CCG_XLABEL
;
PLOT,			[0],[0],$
			/NOERASE,$
			/NODATA,$
			CHARSIZE=1.5,$
			CHARTHICK=2.0,$
			YTITLE=title,$
			YSTYLE=1,$
			YMINOR=2,$
			YRANGE=[ymin,ymax],$
			YTICKS=ystep,$
			YTHICK=2.0,$
			YCHARSIZE=1.0,$
			YTICKNAME=ylabl,$
			COLOR=pen(1),$
;
;>>>>Differences begin here>>>>
;
                        XSTYLE=1,$
                        XRANGE=[fyear,lyear+1],$
			XTICKS=nyears,$
			XTICKNAME=year,$
                        XTHICK=2.0,$
			XTITLE='YEAR',$
                        XCHARSIZE=1.0
;
;<<<<Differences end here<<<<
;
CCG_SYMBOL,		sym=2,fill=1

OPLOT,			dat(0,*),dat(3,*),$
			SYMSIZE=0.75,$
			COLOR=pen(6),$
			PSYM=8

OPLOT,			[fyear,lyear+1],[0,0],LINESTYLE=1
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,		dev=dev
END
;-
