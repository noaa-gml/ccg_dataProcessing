;+
; NAME:
;	CCG_LLEGEND
;
; PURPOSE:
;	Create a line and text legend 
;	and place it on the plotting 
;	surface.
;
;	Type 'ccg_ex_legend' for a legend example.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_LLEGEND,x=x,y=y,tarr=tarr,larr=larr,carr=carr
;
; INPUTS:
;	x: y:	upper left corner of legend.
;		Specify in NORMAL coordinates	
;		i.e., bottom/left of plotting surface -> x=0,y=0 
;		      top/right of plotting surface   -> x=1,y=1 
;
;	tarr:  	text vector
;	larr:	line type vector (see IDL for LINESTYLE)
;	carr:	color vector (values [0-255])
;
;	NOTE:	All vectors must be the same length
;
; OPTIONAL INPUT PARAMETERS:
;	charsize:	text size (default: 1)
;	charthick:	text thickness (default: 1)
;	thick:		line thickness. May be a constant 
;			or a vector (default:  1).
;	frame:		If set to 1 - draw legend frame
;			If set to 0 - no legend frame (default)	
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
;	All vectors must be the same length
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
;		;define vectors to be passed to CCG_LLEGEND.
;		;
;		tarr=[	'BRW','MLO','SMO','SPO']
;
;		larr=[1,2,3,4]
;
;		carr=[	pen(2),pen(3),pen(4),pen(5)]
;		;
;		;call to CCG_LLEGEND
;		;
;		CCG_LLEGEND,	x=.2,y=.8,$
;				tarr=tarr,$
;				larr=larr,$
;				carr=carr,$
;				charthick=2.0,$
;				thick=5.0,$
;				charsize=2.0,$
;				frame=1
;		.
;		.
;		.
;		CCG_CLOSEDEV,dev=dev
;		END
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1994.
;	Modified, KAM, October 1998.
;-
;
PRO    	CCG_LLEGEND, $
	x = x, $
	y = y, $
	tarr = tarr, $
	larr = larr, $
	carr = carr, $
	charsize = charsize, $
	charthick = charthick, $
	thick = thick, $
	frame = frame, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2
;
;
;If keywords are not set then assign
;default values
;
IF NOT KEYWORD_SET(charthick) THEN charthick=1
IF NOT KEYWORD_SET(charsize) THEN charsize=1
IF NOT KEYWORD_SET(tarr) THEN tarr=MAKE_ARRAY(N_ELEMENTS(larr),/STR,VALUE='')
IF NOT KEYWORD_SET(carr) THEN carr=MAKE_ARRAY(N_ELEMENTS(sarr),/INT,VALUE=!P.COLOR)
IF NOT KEYWORD_SET(x) THEN x=0.5
IF NOT KEYWORD_SET(y) THEN y=0.5

IF NOT KEYWORD_SET(thick) THEN thickarr=MAKE_ARRAY(N_ELEMENTS(larr),/INT,VALUE=1) $
ELSE thickarr=thick

IF N_ELEMENTS(thickarr) NE N_ELEMENTS(larr) THEN $
	thickarr=MAKE_ARRAY(N_ELEMENTS(larr),/INT,VALUE=thick)
;
;determine number of lines
;
n=N_ELEMENTS(tarr)
;
;determine length of longest text
;
tlen=MAX(STRLEN(tarr))
;
;y increment for text
;
yinc=.025*charsize
;
FOR i=0,n-1 DO BEGIN

	PLOTS,		[x,x+(.035*charsize)],$
			[y-(yinc*i)-(.002*charsize),y-(yinc*i)-(.002*charsize)],$
			LINESTYLE=larr(i),$
			THICK=thickarr[i],$
			COLOR=carr(i),$
			/NORMAL

	XYOUTS, 	x+.040*charsize,y-(yinc*i)-(.007*charsize),$
			/NORMAL,$
			tarr(i),$
			ALI=0,$
			CHARSIZE=charsize,$
			CHARTHICK=charthick,$
			COLOR=carr(i)
ENDFOR
;
;build legend frame
;
IF KEYWORD_SET(frame) THEN BEGIN

	PLOTS,	x-(.02*charsize),$
		y+(.03*charsize),$
		/NORMAL
	PLOTS,	x-(.02*charsize),$
		y-(n*.025*charsize),$
		/NORMAL,$
		/CONTINUE
	PLOTS,	x+(charsize*.04)+(charsize*tlen*.0095)+(charsize*.012),$
		y-(n*.025*charsize),$
		/NORMAL,$
		/CONTINUE
	PLOTS,	x+(charsize*.04)+(charsize*tlen*.0095)+(charsize*.012),$
		y+(.03*charsize),$
		/NORMAL,$
		/CONTINUE
	PLOTS,	x-(.02*charsize),$
		y+(.03*charsize),$
		/NORMAL,$
		/CONTINUE
ENDIF
END
