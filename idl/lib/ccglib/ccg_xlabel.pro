;+
; NAME:
;	CCG_XLABEL
;
; PURPOSE:
;	Draw x axes (top and bottom) and
; 	place x axis labels BETWEEN tick
;	marks.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_XLABEL,	x1=x1,x2=x2,y1=y1,y2=y2,$
;			tarr=tarr
;
; INPUTS:
;	x1:		minimum x value
;	x2:		maximum x value
;	y1:		minimum y value
;	y2:		maximum y value
;	tarr:		text array used for x labels
;
; OPTIONAL INPUT PARAMETERS:
;	charsize:	size of x label characters
;	xminor:		number of minor x axis ticks
;	xtitle:		x axis title
;	xthick:		thickness of x axis lines
;	xticklen:	length of x tick marks.
;	charthick:	thickness of x label characters
;	mon:		If non-zero then 3-letter month labels
;	abbr:		If non-zero then 1-letter month labels
;	hour:		If non-zero then 0-23 hour labels
;	orientation:	Rotate text labels.  Angles in degree.
;	xgridstyle:	Specifies the linestyle of x grids if xticklen=1
;	noupper:	If set, suppress upper X axis.
;	t3d:		Set this keyword to indicate that the generalized
;			transformation matrix in !P.T is to be used.  If
;			not present, the user-supplied coordinates are simply
;			scaled to screen coordinates.  See the examples in the
;			description of the SAVE keyword in IDL manuals.	
; 	color:          [0-255]
;
; OUTPUTS:
;	Plots x axes to current display device.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Example1:
;
;		PRO example
;		.
;		.
;		.
;		ymin=-10
;		ymax=30
;		fyear=1983
;		lyear=1994
;		nyears=lyear-fyear+1
;		tarr=STRCOMPRESS(STRING(INDGEN(nyears)+fyear),/REMOVE_ALL)
;
;		PLOT, 	x,y, $
;			/NODATA, $
;
;			YRANGE = [ymin, ymax], $
;			YSTYLE = 1, $
;
;			XRANGE = [fyear,lyear], $
;			XSTYLE = 1+4
;
;		CCG_XLABEL,	x1=fyear,x2=lyear,y1=ymin,y2=ymax,$
;				xminor=2,charsize=3.0,xthick=2.0,charthick=2.0
;
;		OPLOT, 	x,y,LINESTYLE=0
;		.
;		.
;		.
;		END
;		
;	Example2:
;
;		PRO example
;		.
;		.
;		.
;		ymin=-10
;		ymax=30
;		fyear=1993
;		lyear=1994
;		nyears=lyear-fyear+1
;		tarr=STRCOMPRESS(STRING(INDGEN(nyears)+fyear),/REMOVE_ALL)
;
;		PLOT, 	x,y, $
;			/NODATA, $
;			COLOR=pen(1), $
;
;			YRANGE = [ymin, ymax], $
;			YSTYLE = 1, $
;
;			XRANGE = [fyear,lyear], $
;			XSTYLE = 1+4
;
;		CCG_XLABEL,	x1=fyear,x2=lyear,y1=y1,y2=y2,$
;				mon=1,charsize=2.0,xthick=2.0,charthick=2.0
;
;		OPLOT, 	x,y,LINESTYLE=0
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, March 1994.
;-
PRO 	CCG_XLABEL, 	x1=x1,x2=x2,y1=y1,y2=y2,$
			tarr=tarr,$
			mon=mon,$
			abbr=abbr,$
			hour=hour,$
			charsize=charsize,$
			orientation=orientation,$
			alignment=alignment,$
			xthick=xthick,$
			xticklen=xticklen,$
			xgridstyle=xgridstyle,$
			xtitle=xtitle,$
			xminor=xminor,$
			charthick=charthick,$
			noupper=noupper,$	
			color=color,$
			t3d=t3d, $
			help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
;If keywords are not set then assign
;default values
;
IF NOT KEYWORD_SET(charthick) THEN charthick=1
IF NOT KEYWORD_SET(xthick) THEN xthick=1
IF NOT KEYWORD_SET(xminor) THEN xminor=1
IF NOT KEYWORD_SET(xtitle) THEN xtitle=''
IF NOT KEYWORD_SET(xticklen) THEN xticklen=0.02
IF NOT KEYWORD_SET(xgridstyle) THEN xgridstyle=0
IF NOT KEYWORD_SET(charsize) THEN charsize=1
IF NOT KEYWORD_SET(orientation) THEN orientation=0
IF NOT KEYWORD_SET(alignment) THEN alignment=0.5
IF NOT KEYWORD_SET(t3d) THEN t3d=0 ELSE t3d=1
IF NOT KEYWORD_SET(noupper) THEN noupper=0 ELSE noupper=1
IF NOT KEYWORD_SET(abbr) THEN abbr=0
IF NOT KEYWORD_SET(hour) THEN hour=0
IF NOT KEYWORD_SET(mon) THEN mon=0
IF NOT KEYWORD_SET(color) THEN color=!P.COLOR
IF KEYWORD_SET(tarr) THEN nticks=N_ELEMENTS(tarr)-1
;
IF KEYWORD_SET(mon) THEN BEGIN

	tarr=[	'JAN','FEB','MAR','APR','MAY','JUN',$
		'JUL','AUG','SEP','OCT','NOV','DEC']
	xminor=1
ENDIF
;
IF KEYWORD_SET(abbr) THEN BEGIN

	tarr=[	'J','F','M','A','M','J',$
		'J','A','S','O','N','D']
	xminor=1
ENDIF

IF KEYWORD_SET(hour) THEN BEGIN

	tarr=STRCOMPRESS(STRING(INDGEN(24)),/RE)
	xminor=1
ENDIF
;
nticks=N_ELEMENTS(tarr);
xtl=(!x.window(1)-!x.window(0))/FLOAT(nticks)
;
yt=!y.window(0)-(.025*charsize)
null=MAKE_ARRAY(nticks+1,/STRING,VALUE=' ')
;
IF NOT noupper THEN $
AXIS, 	XRANGE = [x1,x2], $
	XAXIS=1,$
 	XSTYLE = 1, $
	XTHICK=xthick,$
 	XMINOR = xminor, $
	XTICKNAME = null, $
	XTICKLEN=xticklen,$
	XGRIDSTYLE=xgridstyle,$
	COLOR=color,$
	XTICKS = nticks,$
	T3D=t3d
;
AXIS, 	XRANGE = [x1,x2], $
	XAXIS=0,$
 	XSTYLE = 1, $
	XTHICK=xthick,$
 	XMINOR = xminor, $
	XTICKLEN=xticklen,$
	XTITLE=xtitle,$
	XCHARSIZE=charsize,$
	CHARTHICK=charthick,$
	XTICKNAME = null, $
	XGRIDSTYLE=xgridstyle,$
	COLOR=color,$
	XTICKS = nticks,$
	T3D=t3d
;
FOR i=0,nticks-1 DO BEGIN
	XYOUTS,	i*xtl+!x.window(0)+xtl/2.0,yt,$
		/NORMAL,$
		tarr(i),$
		ALI=alignment,$
		CHARSIZE=charsize,$
		ORIENTATION=orientation,$
		COLOR=color,$
		CHARTHICK=charthick,$
		T3D=t3d
ENDFOR
END
