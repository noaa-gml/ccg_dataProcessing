PRO PLOT_DATA, 	sp,nsp,data,site,x1,x2,y1,y2,ymin,ymax,ncols,nrows,$
		DEFAULT,range,xdatmin,xdatmax,dim,pen,highlight

title=STRUPCASE(site)


charsize=1.75-(nrows*ncols*.1)
charthick=charsize
xm1=xdatmin & xm2=xdatmax

IF xdatmax-xdatmin GT 0  AND xdatmax-xdatmin LT 1 THEN BEGIN
	CCG_DEC2DATE,xdatmin+15.0/365.0,yr,mo
	CCG_INT2MONTH,imon=mo,mon=mon,/full
	title=title+' - '+mon+' '+STRCOMPRESS(STRING(yr),/RE)
	xminor=1
	xlbl=STRCOMPRESS(STRING(INDGEN(dim)+1),/RE)
	xcharsize=charsize*0.75
ENDIF ELSE BEGIN
	xminor=4
	xm2=xm2+1
	xlbl=STRCOMPRESS(STRING(INDGEN(xm2-xm1)+xm1),/RE)
	xcharsize=charsize
ENDELSE

ERASE
FOR i=0,nsp-1 DO BEGIN

	x=data.(i+1).date
	y=data.(i+1).value
	f=data.(i+1).flag
	str=data.(i+1).str

	j=WHERE(x-1 LT DEFAULT)
	IF j(0) NE -1 THEN defaults=x(j)

	j=WHERE(x-1 GT DEFAULT)
	x=x(j)
	y=y(j)
	f=f(j)

	IF y1[i] EQ ymin THEN xchars=xcharsize ELSE xchars=0.01
	IF y2[i] EQ ymax THEN ptitle=title ELSE ptitle=''

	CCG_GASINFO,	sp = sp[i], title = ytitle
	;
	;Has user supplied y-range details?
	;
	IF range.(i).min NE DEFAULT THEN BEGIN 

		j=WHERE(y LT range.(i).min)
		IF j(0) NE -1 THEN y(j)=range.(i).min
		j=WHERE(y GT range.(i).max)
		IF j(0) NE -1 THEN y(j)=range.(i).max

		ystyle=0
		e = { 	YRANGE:[range.(i).min,range.(i).max], $
                       	YTICKS:FIX(range.(i).step), $
                       	YMINOR:FIX(range.(i).minor),$

			YTHICK:1.0,$
			CHARSIZE:charsize,$
			CHARTHICK:charthick,$
			YTITLE:ytitle,$
			YCHARSIZE:charsize,$
			TITLE:ptitle,$
			COLOR:pen(1)}

	ENDIF ELSE BEGIN
		ystyle=15
		e = {	YTHICK:1.0,$
			CHARSIZE:charsize,$
			CHARTHICK:charthick,$
			YTITLE:ytitle,$
			YCHARSIZE:charsize,$
			TITLE:ptitle,$
			COLOR:pen(1)}
	ENDELSE

	PLOT,		x,y,$
			POSITION=[x1[i],y1[i],x2[i],y2[i]],$
			/NODATA,$
			/NOERASE,$
			YSTYLE=1+4+ystyle,$

			_EXTRA = e,$

			XSTYLE=1+4,$
			XRANGE=[xm1,xm2]

	AXIS,		YAXIS=0,$
			YSTYLE=1+ystyle,$
			_EXTRA = e

	AXIS,		YAXIS=1,$
			YSTYLE=1+ystyle,$
			_EXTRA = e

	CCG_XLABEL,	x1=xm1,x2=xm2,$
			y1=!Y.CRANGE[0],y2=!Y.CRANGE[1],$
			tarr=xlbl,$
			COLOR=pen(1),$
			XTHICK=1.0,$
			XMINOR=xminor,$
			CHARSIZE=xchars

	;
	;Is there a flag in first column?
	;
	j=WHERE(STRMID(f,0,1) NE '.')
	IF j(0) NE -1 THEN BEGIN
		CCG_SYMBOL,	sym=11,fill=0
		OPLOT,		x(j),y(j),$
				PSYM=8,$
				COLOR=pen(2),$
				SYMSIZE=1
	ENDIF
	;
	;Is there a flag in second column?
	;
	j=WHERE(STRMID(f,1,1) NE '.')
	IF j(0) NE -1 THEN BEGIN
		CCG_SYMBOL,	sym=10,fill=0
		OPLOT,		x(j),y(j),$
				PSYM=8,$
				COLOR=pen(4),$
				SYMSIZE=1
	ENDIF
	;
	;No flag in either first or second column?
	;
	j=WHERE(STRMID(f,0,1) EQ '.' AND STRMID(f,1,1) EQ '.')
	IF j(0) NE -1 THEN BEGIN
		CCG_SYMBOL,	sym=1,fill=0
		OPLOT,		x(j),y(j),$
				PSYM=8,$
				COLOR=pen(3),$
				SYMSIZE=1
	ENDIF

	IF highlight NE -1 THEN BEGIN
		j=WHERE(x EQ highlight)
		IF j(0) NE -1 THEN BEGIN
			CCG_SYMBOL,	sym=2,fill=0
			OPLOT,		[x(j)],[y(j)],$
					PSYM=8,$
					COLOR=pen(13),$
					SYMSIZE=2.0
			CCG_PLOTGAP,	[x(j)],[y(j)],$
					COLOR=pen(13),$
					GAP=9999
			;
			;Send species analysis details 
			;
			FOR z=0,N_ELEMENTS(j)-1 DO CCG_MESSAGE,$
				STRING(FORMAT='(A6,1X,A)',sp(i),str(j(z)))
		ENDIF
	ENDIF
ENDFOR
END

PRO	CCG_FLASKVU_HELP
	CCG_MESSAGE," "
	CCG_MESSAGE,"CCG_FLASKVU help"
	CCG_MESSAGE," "
	CCG_MESSAGE,"ccg_flaskvu,sp='co2',site='brw',yr1=1985,yr2=1994"
	CCG_MESSAGE,"ccg_flaskvu,sp=['co2','co','n2o'],site='mhd',yr1=1992"
	CCG_MESSAGE," "
	CCG_MESSAGE,"ccg_flaskvu,sp=['co2','ch4'],site='mhd',yr1=1992,$"
	CCG_MESSAGE,"ccg_flaskvu,co2y=[350,380,3,5],ch4y=[1650,1850,3,5]"
	CCG_MESSAGE,"where <sp>y=[min,max,major ticks,minor tics]"
	CCG_MESSAGE," "
	CCG_MESSAGE,"ccg_flaskvu,sp=['all'],site='mhd'"
	CCG_MESSAGE,"ccg_flaskvu,site='mhd'"
	CCG_MESSAGE," "
	CCG_MESSAGE,"ccg_flaskvu,sp=['co2','ch4'],site='nwr',strategy='flask'"
	CCG_MESSAGE," "
	CCG_MESSAGE,"Use left mouse button to highlight a sampling event."
	CCG_MESSAGE,"Use right mouse button to toggle between ZOOM IN "
	CCG_MESSAGE,"(month resolution) and ZOOM OUT (initial plot resolution)."
	CCG_MESSAGE," "
	CCG_MESSAGE,"To exit.  Place cursor to right of initial plot area,"
	CCG_MESSAGE,"press left mouse button."
	CCG_FATALERR,''
END

PRO 	CCG_FLASKVU,$
	site=site,$
   strategy=strategy,$
	sp=sp,$
	dev=dev,$
	yr1=yr1,$
	yr2=yr2,$
	co2y=co2y,$
	coy=coy,$
	h2y=h2y,$
	ch4y=ch4y,$
	n2oy=n2oy,$
	sf6y=sf6y,$
	co2c13y=co2c13y,$
	co2o18y=co2o18y,$
	ch4c13y=ch4c13y
	
;
;-------------------------------------- help?
;
IF NOT KEYWORD_SET(site) THEN CCG_FLASKVU_HELP
;
;-------------------------------------- check site parameter
;
IF NOT KEYWORD_SET(site) THEN BEGIN
	CCG_MESSAGE,"Site, 'site', parameter must be set.  Exiting ..."
	CCG_MESSAGE,"ex:  CCG_FLASKVU, site='smo',sp=['co2','ch4'],ret,nb,rej"
	RETURN
ENDIF
;
;-------------------------------------- check species parameter
;
IF NOT KEYWORD_SET(sp) THEN BEGIN
	PRINT,STRING(7B)
	CCG_MESSAGE,"Species, 'sp', array was not set.  Default set to 'all' ..."
	CCG_MESSAGE,"ex:  CCG_FLASKVU, site='smo',sp=['co2','ch4','co']"
	CCG_MESSAGE,"ex:  CCG_FLASKVU, site='smo',sp=['all'],res=res"
	PRINT,STRING(7B)
	sp=['all']
ENDIF
;
;-------------------------------------- check messages entry
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
;-------------------------------------- misc initialization
;
DEFAULT=(-999.999)
netdir='/projects/network/flask/site/'
sitedir='/projects/'

strategy = KEYWORD_SET( strategy ) ? strategy : ""

sp=STRLOWCASE(sp)
IF sp(0) EQ 'all' THEN $
	sp=['co2','ch4','co','h2','n2o','sf6','co2c13','co2o18']
nsp=N_ELEMENTS(sp)

FOR i=0,nsp-1 DO BEGIN
	zz=CREATE_STRUCT('min',DEFAULT,'max',DEFAULT,'step',DEFAULT,'minor',DEFAULT)
	IF i EQ 0 THEN range=CREATE_STRUCT(sp(i),zz) ELSE range=CREATE_STRUCT(range,sp(i),zz)
ENDFOR
;
;Has the user provided y range values?
;
IF KEYWORD_SET(co2y) THEN BEGIN
	range.co2.min=co2y(0) & range.co2.max=co2y(1) 
	range.co2.step=co2y(2) & range.co2.minor=co2y(3)
ENDIF
IF KEYWORD_SET(ch4y) THEN BEGIN
	range.ch4.min=ch4y(0) & range.ch4.max=ch4y(1) 
	range.ch4.step=ch4y(2) & range.ch4.minor=ch4y(3)
ENDIF
IF KEYWORD_SET(coy) THEN BEGIN
	range.co.min=coy(0) & range.co.max=coy(1) 
	range.co.step=coy(2) & range.co.minor=coy(3)
ENDIF
IF KEYWORD_SET(h2y) THEN BEGIN
	range.h2.min=h2y(0) & range.h2.max=h2y(1) 
	range.h2.step=h2y(2) & range.h2.minor=h2y(3)
ENDIF
IF KEYWORD_SET(n2oy) THEN BEGIN
	range.n2o.min=n2oy(0) & range.n2o.max=n2oy(1) 
	range.n2o.step=n2oy(2) & range.n2o.minor=n2oy(3)
ENDIF
IF KEYWORD_SET(sf6y) THEN BEGIN
	range.sf6.min=sf6y(0) & range.sf6.max=sf6y(1) 
	range.sf6.step=sf6y(2) & range.sf6.minor=sf6y(3)
ENDIF
IF KEYWORD_SET(co2c13y) THEN BEGIN
	range.co2c13.min=co2c13y(0) & range.co2c13.max=co2c13y(1) 
	range.co2c13.step=co2c13y(2) & range.co2c13.minor=co2c13y(3)
ENDIF
IF KEYWORD_SET(co2o18y) THEN BEGIN
	range.co2o18.min=co2o18y(0) & range.co2o18.max=co2o18y(1) 
	range.co2o18.step=co2o18y(2) & range.co2o18.minor=co2o18y(3)
ENDIF
IF KEYWORD_SET(ch4c13y) THEN BEGIN
	range.ch4c13.min=ch4c13y(0) & range.ch4c13.max=ch4c13y(1) 
	range.ch4c13.step=ch4c13y(2) & range.ch4c13.minor=ch4c13y(3)
ENDIF

CCG_FLASK, site=site, strategy=strategy, ns
data=CREATE_STRUCT('net',ns)

FOR isp=0,nsp-1 DO BEGIN
	 
	; Get data

	CCG_FLASK, site=site, sp=sp[isp], nomessages = nomessages, strategy=strategy, zz
	data=CREATE_STRUCT(data,sp(isp),zz)
ENDFOR
;
xdatamax=(-9999)
xdatamin=(9999)
FOR i=0,nsp-1 DO BEGIN
	z=MAX(data.(i+1).date)
	IF z GT xdatamax THEN xdatamax=z
	z=MIN(data.(i+1).date)
	IF z LT xdatamin THEN xdatamin=z
ENDFOR
xdatamax=FIX(xdatamax)
xdatamin=FIX(xdatamin)

CCG_MESSAGE, 	'Range of data points:  '+$
		STRCOMPRESS(STRING(xdatamin),/RE)+' '+$
		STRCOMPRESS(STRING(xdatamax),/RE)

IF xdatamax-xdatamin GT 2 THEN xdatamin=xdatamax-2
IF KEYWORD_SET(yr1) THEN xdatamin=yr1
IF KEYWORD_SET(yr2) THEN xdatamax=yr2

CCG_MESSAGE, 	'Range of plots:  '+$
		STRCOMPRESS(STRING(xdatamin),/RE)+' '+$
		STRCOMPRESS(STRING(xdatamax),/RE)

nrows=4
IF FLOAT(nsp)/4.0 GT 1 THEN ncols=2 ELSE ncols=1
IF ncols EQ 1 THEN nrows=4-(4-nsp)

;x1=FLTARR(nsp)
x1=FLTARR(nrows * ncols)
x2=x1 & y1=x1 & y2=x1

xmin=0.20
xmax=0.80
xrange=xmax-xmin
ymin=0.10
ymax=0.90
yrange=ymax-ymin
gap=0.01

xinc=xrange/ncols
yinc=yrange/nrows

FOR i=1.0,ncols DO BEGIN
	FOR j=1.0,nrows DO BEGIN
		z=nrows*(i-1)+j-1
		x1[z]=gap*(i-1)+xmin+xrange*(i-1)/ncols
		x2[z]=gap*(i-1)+x1[z]+xinc
		y1[z]=ymin+yrange*(nrows-j)/nrows
		y2[z]=y1[z]+yinc
	ENDFOR
ENDFOR
;
;Set up graphics
;
IF NOT KEYWORD_SET(dev) THEN win=(-1) ELSE win=0
IF nsp GT 1 THEN portrait=1 ELSE portrait=0

CCG_OPENDEV,dev=dev,pen=pen,win=win,portrait=portrait
;
;Name graphics window
;
IF NOT KEYWORD_SET(dev) THEN WINDOW,2,XSIZE=625,YSIZE=800,TITLE='CCG_FLASKVU'
;
;try out cursor
;
xx1=xdatamin
xx2=xdatamax+1
percentage=0
forever=1
highlight=(-1D)

xdatmin=xdatamin
xdatmax=xdatamax
dim=0
mode = 'year'

IF KEYWORD_SET(dev) THEN BEGIN 
	PLOT_DATA, 	sp,nsp,data,site,x1,x2,y1,y2,ymin,ymax,ncols,nrows,$
			DEFAULT,range,xdatmin,xdatmax,dim,pen,highlight
ENDIF ELSE BEGIN
	WHILE forever DO BEGIN

		PLOT_DATA, 	sp,nsp,data,site,x1,x2,y1,y2,ymin,ymax,ncols,nrows,$
				DEFAULT,range,xdatmin,xdatmax,dim,pen,highlight

		CURSOR,	xd0,yd0,/DOWN,/DATA
		n0=CONVERT_COORD(xd0,yd0,/DATA,/TO_NORMAL)
		;
		;Need to treat multi-column figure
		;
		IF ncols GT 1 AND n0(0) LE xmin+(xrange+gap)/2.0 THEN BEGIN
			IF xdatmin EQ xdatamin AND xdatmax EQ xdatamax THEN adj=1 ELSE adj=0
			xd0=xdatmin+(xdatmax-xdatmin+adj)*(2.0*(n0(0)-xmin)/(xrange+gap))
		ENDIF

		IF !MOUSE.BUTTON EQ 1 THEN BEGIN

			IF xd0 GE !X.CRANGE[0] AND xd0 LE !X.CRANGE[1] THEN BEGIN
				FOR ii=0,N_TAGS(data)-1 DO BEGIN
					r=SIZE(data.(ii))
					IF (r[2] NE 8) THEN CONTINUE

					q=MIN(ABS(data.(ii).date-xd0),z)
					j=WHERE(data.(ii).date EQ data.(ii)[z].date)
					;
					;Send network site details if available
					;
					IF ii EQ 0 THEN BEGIN
						CCG_MESSAGE,' '
						FOR z=0,N_ELEMENTS(j)-1 DO $
							CCG_MESSAGE,$
							STRING(FORMAT='(A6,1X,A)',$
							'event',data.(ii)[j(z)].str)
					ENDIF
					highlight=data.(ii)[j(0)].date
				ENDFOR
			ENDIF ELSE BEGIN
				IF mode EQ 'year' THEN forever = 0
				IF mode EQ 'month' THEN BEGIN
				 	MONTH = 0.0328767D
					CASE (xd0 LT !X.CRANGE[0]) OF
					1:	BEGIN
						xd0 -= MONTH
						END
					ELSE:	BEGIN
						xd0 += MONTH
						END
					ENDCASE
					CCG_DEC2DATE,xd0,yr,mo
					CCG_DIM,yr,mo,dim
					CCG_DATE2DEC,yr=yr,mo=mo,dy=0,hr=0,mn=0,dec=xdatmin
					CCG_DATE2DEC,yr=yr,mo=mo,dy=dim,hr=24,mn=00,dec=xdatmax
				ENDIF
			ENDELSE
		ENDIF

		IF !MOUSE.BUTTON EQ 4 THEN BEGIN
			IF xdatmin EQ xdatamin AND xdatmax EQ xdatamax THEN BEGIN
				CCG_DEC2DATE,xd0,yr,mo
				CCG_DIM,yr,mo,dim
				CCG_DATE2DEC,yr=yr,mo=mo,dy=0,hr=0,mn=0,dec=xdatmin
				CCG_DATE2DEC,yr=yr,mo=mo,dy=dim,hr=24,mn=00,dec=xdatmax
				mode = 'month'
			ENDIF ELSE BEGIN
				xdatmin=xdatamin
				xdatmax=xdatamax
				mode = 'year'
			ENDELSE
		ENDIF

		IF NOT forever THEN BEGIN
			s=''
			WSHOW,0,0
			READ,s,PROMPT='Are you sure? (y/n)' 
			IF STRPOS(STRUPCASE(s),'N') NE -1 THEN BEGIN
				forever=1
				WSHOW,0,1
			ENDIF
		ENDIF
	ENDWHILE
ENDELSE
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID,y=0.01,full=1
CCG_CLOSEDEV,dev=dev
END
