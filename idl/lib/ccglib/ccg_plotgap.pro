;+
; NAME:
;	CCG_PLOTGAP
;
; PURPOSE:
;	Plot the passed x and y arrays with
;	a solid line.  Do not connect adjacent
;	points if they are different by more
;	than 'gap' hours.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_PLOTGAP,x,y,gap=24,color=pen(2)
;
; INPUTS:
;	x:   		decimal date vector.
;	y:   		value vector.
;	gap: 		integer specifying
;	     		number of hours in gap.
;	color: 		color [0-255].
;
; OPTIONAL INPUT PARAMETERS:
;	linestyle:	specify IDL line types (default 0).
;	thick:		specify IDL line thicknesses (default 1).
;	noclip:		If set, plot lines are allowed beyond axis borders.
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
;	None.
;
; PROCEDURE:
;	
;	Example:
;
;		PLOT,	x,y,psym=6
;		
;		CCG_PLOTGAP,x,y,gap=31*24,color=pen(2)
;
;		Plot x,y with open squares.
;		Overlay x,y with a solid
;		line.  If adjacent x
;		values differ by more
;		than 31 days (31*24 hours) 
;		then do not connect points.
;
; MODIFICATION HISTORY:
;	Written, KAM, October 1993.
;-
;
PRO    	CCG_PLOTGAP, $
	x, y, $
	gap = gap, $
	color = color, $
	noclip = noclip, $
	linestyle = linestyle, $
	thick = thick, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;**************************************
;
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
;If keywords are not set then assign
;default values
;
IF NOT KEYWORD_SET(thick) THEN thick=1
IF NOT KEYWORD_SET(linestyle) THEN linestyle=0
IF NOT KEYWORD_SET(noclip) THEN noclip=0
;
dechour=0.000115
decgap=dechour*gap

n=N_ELEMENTS(x)
	
FOR i=0,n-2 DO BEGIN
	IF x(i+1)-x(i) LE decgap THEN BEGIN
		OPLOT, 	x(i:i+1),y(i:i+1),$
			COLOR=color,$
			LINESTYLE=linestyle,$
			NOCLIP=noclip,$
			THICK=thick
	ENDIF
ENDFOR
END
