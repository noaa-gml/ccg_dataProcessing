;+
;
; No help.
;
;-
PRO 	CCG_COLORBAR,$
	colorarr=colorarr,$
	tarr=tarr,$

	position=position,$
	charsize=charsize,$
	charthick=charthick,$
	ticklen=ticklen,$
	minor=minor,$
	labelcolor=labelcolor,$

   center=center,$

   axis=axis, $

	noaxis=noaxis,$
	t3d=t3d,$

	title=title,$
	orientation=orientation,$
	cells=cells

ymin=0
ymax=10
xmin=0
xmax=10

thick=2

IF NOT KEYWORD_SET(orientation) THEN orientation='horizontal'
IF NOT KEYWORD_SET(title) THEN title='Units'
IF NOT KEYWORD_SET(cells) THEN cells=10

axis = KEYWORD_SET(axis) ? axis : 0

IF NOT KEYWORD_SET(center) THEN center = 0

IF NOT KEYWORD_SET(labelcolor) THEN labelcolor=!P.COLOR
IF NOT KEYWORD_SET(charthick) THEN charthick=1.5
IF NOT KEYWORD_SET(charsize) THEN charsize=0.75
IF NOT KEYWORD_SET(ticklen) THEN ticklen=(-0.5)
IF NOT KEYWORD_SET(minor) THEN minor=1
IF KEYWORD_SET(t3d) THEN t3d=1 ELSE t3d=0
IF NOT KEYWORD_SET(tarr) THEN $
	tarr=MAKE_ARRAY(cells+1,/STR,VALUE=' ')

IF N_ELEMENTS(tarr) GT 60 THEN BEGIN
	CCG_MESSAGE,$
	"Warning:  'tarr' may not have more than 60 elements",$
	/bell
	tarr=tarr[0:59]
ENDIF

IF KEYWORD_SET(noaxis) THEN noaxis=1 ELSE noaxis=0

IF NOT KEYWORD_SET(colorarr) THEN BEGIN
	TVLCT,r,g,b,/GET
	colorarr=INDGEN(N_ELEMENTS(r))+1
ENDIF

;zz=colorarr(SORT(colorarr))
;zz=zz(UNIQ(zz))
zz=colorarr
nzz=N_ELEMENTS(zz)

ntarr = N_ELEMENTS(tarr)
tickv = (center) ?  FINDGEN(ntarr)*xmax/ntarr + (xmax/ntarr)*0.5 : FINDGEN(ntarr) * xmax/(ntarr-1)

IF orientation EQ 'horizontal' THEN BEGIN

	IF NOT KEYWORD_SET(position) THEN position=[0.20,0.35,0.80,0.40]
	e = {   XSTYLE:1,$
		XAXIS:axis,$
		XTHICK:thick,$
      XTICKV:tickv, $
		XCHARSIZE:charsize, $
		XTICKS:N_ELEMENTS(tarr)-1,$
		XTICKLEN:ticklen,$
		XTICKNAME:tarr,$
		XMINOR:minor,$
		XTITLE:title}

ENDIF
IF orientation EQ 'vertical' THEN BEGIN

	IF NOT KEYWORD_SET(position) THEN position=[0.35,0.20,0.40,0.80]
	e = {   YSTYLE:1,$
		YAXIS:axis,$
		YTHICK:thick,$
      YTICKV:tickv, $
		YCHARSIZE:charsize, $
		YTICKLEN:ticklen,$
		YTICKNAME:tarr,$
		YTICKS:N_ELEMENTS(tarr)-1,$
		YMINOR:minor,$
		YTITLE:title}

ENDIF

PLOT,           [0],[0],$
 		POSITION=position,$
		/NOERASE,$
                /NODATA,$
		T3D=t3d,$

                YRANGE=[ymin,ymax],$
                YSTYLE=1+4,$

                XRANGE=[xmin,xmax],$
                XSTYLE=1+4

IF NOT noaxis THEN BEGIN
	AXIS,           COLOR=labelcolor,$
			CHARTHICK=charthick,$
			CHARSIZE=charsize,$
			T3D=t3d,$
			_EXTRA=e
ENDIF

CASE orientation OF
'horizontal':	BEGIN
		del=xmax-xmin
		inc=FLOAT(del)/FLOAT(cells)
		FOR i=0.0,cells-1 DO BEGIN
			POLYFILL,	[xmin+(inc*i),xmin+inc*(i+1),xmin+inc*(i+1),xmin+inc*i],$
					[ymin,ymin,ymax,ymax],$
					col=zz[i*nzz/cells]
;			print,zz[i*nzz/cells],i*nzz/cells,i
		ENDFOR
		END
'vertical':	BEGIN
		del=ymax-ymin
		inc=FLOAT(del)/FLOAT(cells)
		FOR i=0.0,cells-1 DO BEGIN
			POLYFILL,	[xmin,xmin,xmax,xmax],$
			           	[ymin+(inc*i),ymin+inc*(i+1),ymin+inc*(i+1),ymin+inc*i],$
					col=zz[i*nzz/cells]
;			print,zz[i*nzz/cells],i*nzz/cells,i
		ENDFOR
		END
ENDCASE
END
