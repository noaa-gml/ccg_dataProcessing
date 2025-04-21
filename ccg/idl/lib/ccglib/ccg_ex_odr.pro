;+
PRO 	CCG_EX_ODR,$
	dev=dev,$
	summary=summary,$
	nolabid=nolabid,$
	noproid=noproid
;
;-------------------------------------- procedure description
;
;Procedure showing the use of CCG_ODR
;
;ORTHOGONAL DISTANCE REGRESSION
;
;provides examples of the use of
;
;       (1)     ccg_opendev
;       (2)     ccg_fread
;       (3)     ccg_errplot
;       (4)     ccg_odr
;       (5)     ccg_symbol
;       (6)     ccg_tlegend
;       (7)     ccg_nolabid
;       (8)     ccg_noproid
;       (9)     ccg_closedev
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
CCG_OPENDEV,dev=dev,pen=pen,xpixels=800,ypixels=600
;
;----------------------------------------------- read sample file
;
CCG_FREAD,file=dir+'data/ccg_ex_odr.dat',nc=4,skip=1,var

x=REFORM(var(0,*))
xunc=REFORM(var(1,*))
xwt=1.0/xunc

y=REFORM(var(2,*))
yunc=REFORM(var(3,*))
ywt=1.0/yunc

PLOT,	x,y,$
	/NODATA,$
	TITLE='CCG_EX_ODR',$
	XSTYLE=16,$
	YSTYLE=16,$
	XMINOR=2,$
	YMINOR=2,$
	YTHICK=2.0,$
	XTHICK=2.0,$
	COLOR=pen(1),$
	CHARSIZE=1.5,$
	CHARTHICK=2.0,$
	YCHARSIZE=1.0,$
	XCHARSIZE=1.0,$
	XTITLE='CO (LAB X, ppbv)',$
	YTITLE='CO (LAB Y, ppbv)'
		
CCG_ERRPLOT,x,y-yunc,y+yunc,COLOR=pen(2)
CCG_ERRPLOT,y,x-xunc,x+xunc,COLOR=pen(2),y=1

xfit=FINDGEN((MAX(x)-MIN(x))*50)*.05+MIN(x)
;
;Compute a linear ODR fit
;
CCG_ODR, xarr=x,yarr=y,xwts=xwt,ywts=ywt,npoly=2,results=coef,summary=summary
;
;Print summary?
;
IF KEYWORD_SET(summary) THEN BEGIN
	FOR i=0,N_ELEMENTS(summary)-1 DO PRINT, summary(i)
ENDIF

OPLOT,	xfit,$
	coef(0,0)+$
	coef(0,1)*xfit,$
	LINESTYLE=0,$
	COLOR=pen(4)
;
;build legend
;
tarr=[	'y = a!i0!n + a!i1!nx',$
      	' ',$
      	'a!i0!n = '+STRING(FORMAT='(F10.6)',coef(0,0))+' !9+!3 '$
	+STRING(FORMAT='(F10.6)',coef(1,0)),$
      	'a!i1!n = '+STRING(FORMAT='(F10.6)',coef(0,1))+' !9+!3 '$
	+STRING(FORMAT='(F10.6)',coef(1,1))]

CCG_TLEGEND,	tarr=tarr,$
		carr=MAKE_ARRAY(N_ELEMENTS(tarr),/INT,VALUE=pen(1)),$
		charsize=1.2,$
		x=0.30,$
		y=0.85,$
		frame=0
;
;Compute a quadratic ODR fit
;
CCG_ODR, xarr=x,yarr=y,xwts=xwt,ywts=ywt,npoly=3,results=coef,summary=summary
;
;Print summary?
;
IF KEYWORD_SET(summary) THEN BEGIN
	FOR i=0,N_ELEMENTS(summary)-1 DO PRINT, summary(i)
ENDIF

OPLOT,	xfit,$
	coef(0,0)+$
	coef(0,1)*xfit+$
	coef(0,2)*xfit*xfit,$
	LINESTYLE=0,$
	COLOR=pen(3)
;
;build legend
;
tarr=[	'y = a!i0!n + a!i1!nx + a!i2!nx!e2!n',$
      	' ',$
      	'a!i0!n = '+STRING(FORMAT='(F10.6)',coef(0,0))+' !9+!3 '$
	+STRING(FORMAT='(F10.6)',coef(1,0)),$
      	'a!i1!n = '+STRING(FORMAT='(F10.6)',coef(0,1))+' !9+!3 '$
	+STRING(FORMAT='(F10.6)',coef(1,1)),$
      	'a!i2!n = '+STRING(FORMAT='(F10.6)',coef(0,2))+' !9+!3 '$
	+STRING(FORMAT='(F10.6)',coef(1,2))]

CCG_TLEGEND,	tarr=tarr,$
		carr=MAKE_ARRAY(N_ELEMENTS(tarr),/INT,VALUE=pen(1)),$
		charsize=1.2,$
		x=0.50,$
		y=0.32,$
		frame=0
;
;------------------------------------------------ lab id
;
IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
;
;------------------------------------------------ procedure id
;
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev
END
;-
