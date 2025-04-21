;+
; NAME:
;	CCG_LABID
;
; PURPOSE:
; 	Place CCGG label and system
;	date or passed date in 
;	lower right of plot.
;
;	NOAA/ESRL/GMD Carbon Cycle
;	February 13, 1994
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_LABID
;	CCG_LABID,	full=1
;	CCG_LABID,	date=date,x=0.90,y=0.02
;	CCG_LABID,	full=1,orientation=90,alignment=0.5,charsize=1.0
;
; INPUTS:
;	None.
;
; OPTIONAL INPUT PARAMETERS:
;	date:		Date in any string format.
;			ex: 	date='January 19, 1999'
;				date='JAN 1990'
;				date='12-31-99'
;
;	x: y:		User-supplied coordinates for 
;			placement of lab label.
;			Specify in NORMAL coordinates	
;			i.e., bottom/left of plotting surface -> x=0,y=0 
;			      top/right of plotting surface   -> x=1,y=1 
;
;			Default position coordinates
;				x=0.950
;				y=0.030
;
;	full:		If non=zero then full date and time format
;			is used, Mon Sep 19 15:18:02 1994.
;
;	orientation:	The lab identification and date may be
;			rotated by any angle.  See IDL manual
;			for acceptable values.
;
;			Default: orientation=0 
;				
;	alignment:	Alignment (justification) of the lab identification 
;			and date may be	specified.  See IDL manual
;			for acceptable values.
;
;			Default: alignment=1
;				
;	charsize:	Character size of the lab identification 
;			and date may be	specified.  See IDL manual
;			for acceptable values.
;
;			Default: charsize=0.75
;
;	color:          [0-255]
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
;	Example:
;
;		PRO example,labid=labid
;		.
;		.
;		.
;		PLOT,[0,0],[1,1]
;		.
;		.
;		.
;		IF NOT KEYWORD_SET(labid) THEN CCG_LABID,date='February 1994'
;					or
;		IF NOT KEYWORD_SET(labid) THEN CCG_LABID,full=1
;		
;		note:
;			using the KEYWORD_SET with the variable 'labid'
;			allows the user to omit the label by specifying
;			labid=1 when the example procedure is invoked.
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, February 1994.
;	Modified, KAM, June 1996.
;-
;
PRO 	CCG_LABID, $
	date = date, $
	x = x, $
	y = y, $
	full = full, $
	charsize = charsize, $
	color = color, $
	orientation = orientation, $
	alignment = alignment, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
IF NOT KEYWORD_SET(x) THEN x=0.940
IF NOT KEYWORD_SET(y) THEN y=0.030
IF NOT KEYWORD_SET(alignment) THEN alignment=1
IF NOT KEYWORD_SET(orientation) THEN orientation=0
IF NOT KEYWORD_SET(charsize) THEN charsize=0.75
IF NOT KEYWORD_SET(color) THEN color=!P.COLOR

IF NOT KEYWORD_SET(date) THEN BEGIN
	;
	d=SYSTIME()
	;
	IF NOT KEYWORD_SET(full) THEN BEGIN
		mon=[	'N/A','January','February','March','April','May','June',$
			'July','August','September','October','November','December']
		yr=STRMID(d,20,4)
		mo=STRMID(d,4,3)
		dy=STRMID(d,8,2)
		i=0
		REPEAT BEGIN
			i=i+1
		ENDREP UNTIL STRPOS(mon(i),mo) NE -1
		date=mon(i)+' '+dy+', '+yr
	ENDIF ELSE BEGIN
		date=d
	ENDELSE
ENDIF

XYOUTS, x,y,$
	/NORMAL,$
	'!8NOAA/ESRL Carbon Cycle!C!8  '+date+'!3',$
	ALI=alignment,$
	COLOR=color,$
	ORI=orientation,$
	CHARSIZE=charsize
END
