;+
; NAME:
;	CCG_TLEGEND
;
; PURPOSE:
;	Create a text-only legend 
;	and place it on the plotting 
;	surface.
;
;	Type 'ccg_ex_legend' for a legend example.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_TLEGEND,x=x,y=y,tarr=tarr,carr=carr
;
; INPUTS:
;	x: y:	upper left corner of legend.
;		Specify in NORMAL coordinates	
;		i.e., bottom/left of plotting surface -> x=0,y=0 
;		      top/right of plotting surface   -> x=1,y=1 
;
;	tarr:  	text vector
;	carr:	color vector (values [0-255])
;
;	NOTE:	Vectors must be the same length
;
; OPTIONAL INPUT PARAMETERS:
;	charsize:	text size (default: 1)
;	charthick:	text thickness (default: 1)
;	frame:		If set to 1 - draw legend frame
;			If set to 0 - no legend frame	
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Vectors must be the same length
;
; PROCEDURE:
;	
;	Example:
;
;		PRO 	example,dev=dev
;		;
;		CCG_OPENDEV,dev=dev,pen=pen
;		.
;		.
;		.
;		;
;		;draw initial plot.
;		;
;		PLOT,	[0,0],[1,1]
;		;
;		;define vectors to be passed to CCG_TLEGEND.
;		;
;		tarr=[	'SQUARE','CIRCLE','TRIANGLE 1','TRIANGLE 2',$
;			'DIAMOND','STAR 1','STAR 2','HOURGLASS',$
;			'BOWTIE','PLUS','ASTERISK','CIRCLE/PLUS',$
;			'CIRCLE/X']
;
;		carr=[	pen(1),pen(2),pen(3),pen(4),pen(5),pen(6),$
;			pen(7),pen(8),pen(9),pen(10),pen(11),pen(12),$
;			pen(1)]
;		;
;		;call to CCG_TLEGEND
;		;
;		CCG_TLEGEND,	x=.2,y=.8,$
;				tarr=tarr,$
;				carr=carr,$
;				charthick=2.0,$
;				charsize=1.0,$
;				frame=1
;		.
;		.
;		.
;		CCG_CLOSEDEV,dev=dev
;		END
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1994.
;-
;
PRO    	CCG_TLEGEND, $
	x = x, $
	y = y, $
	tarr = tarr, $
	carr = carr, $
	charsize = charsize, $
	charthick = charthick, $
	data = data, $
	device = device, $
	normal = normal, $
	t3d = t3d, $
	frame = frame, $
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
IF NOT KEYWORD_SET(charsize) THEN charsize=1
IF NOT KEYWORD_SET(carr) THEN carr=MAKE_ARRAY(N_ELEMENTS(tarr),/INT,VALUE=!P.COLOR)
IF NOT KEYWORD_SET(t3d) THEN t3d=0
IF NOT KEYWORD_SET(x) THEN x=0.5
IF NOT KEYWORD_SET(y) THEN y=0.5
IF NOT KEYWORD_SET(normal) THEN normal=0
IF NOT KEYWORD_SET(device) THEN device=0
IF NOT KEYWORD_SET(data) THEN data=0
IF normal+device+data EQ 0 THEN normal=1
;
;determine number of lines
;
n=N_ELEMENTS(tarr)
;
;determine length of longest text
;
tlen=MAX(STRLEN(tarr))+1
;
;y increment for text
;
yinc=.025*charsize
;
FOR i=0,n-1 DO BEGIN
	XYOUTS, 	x,y-(yinc*i),$
			normal=normal,$
			data=data,$
			device=device,$
			tarr(i),$
			ALI=0,$
			CHARTHICK=charthick,$
			CHARSIZE=charsize,$
			T3D=t3d,$
			COLOR=carr(i)
ENDFOR
;
;build legend frame
;
IF KEYWORD_SET(frame) THEN BEGIN

	PLOTS,	x-(.02*charsize),$
		y+(.03*charsize),$
		normal=normal,$
		data=data,$
		device=device

	PLOTS,	x-(.02*charsize),$
		y-(n*.025*charsize),$
		normal=normal,$
		data=data,$
		device=device,$
		/CONTINUE
	PLOTS,	x+(charsize*.001)+(charsize*tlen*.0095)+(charsize*.012),$
		y-(n*.025*charsize),$
		normal=normal,$
		data=data,$
		device=device,$
		/CONTINUE
	PLOTS,	x+(charsize*.001)+(charsize*tlen*.0095)+(charsize*.012),$
		y+(.03*charsize),$
		normal=normal,$
		data=data,$
		device=device,$
		/CONTINUE
	PLOTS,	x-(.02*charsize),$
		y+(.03*charsize),$
		normal=normal,$
		data=data,$
		device=device,$
		/CONTINUE
ENDIF
END
