;+
; NAME:
;	CCG_PIID
;
; PURPOSE:
; 	Place a "Data Provided by" label with
;	passed PI name array and system date or 
;	passed date in upper left of plot.
;
;	ex 1
;
;	Provided by Thomas J. Conway
;		    Pieter P. Tans
;		    NOAA ESRL GMD
;                   September 24, 2002
;
;	ex 2 (if name array is not passed)
;
;	Provided by NOAA ESRL GMD
;                   September 24, 2002
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_PIID
;	CCG_PIID,	name=['Thomas J. Conway', 'Pieter P. Tans'], full=1
;	CCG_PIID,	name=['Joe Schmo'], date=date,x=0.90,y=0.02
;	CCG_PIID,	full=1,orientation=90,alignment=0.5,charsize=1.0
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
;				x=0.25
;				y=0.95
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
;	charthick:	Character thickness of the lab identification 
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
;		PRO example,nopiid=nopiid
;		.
;		.
;		.
;		PLOT,[0,0],[1,1]
;		.
;		.
;		.
;		IF NOT KEYWORD_SET(nopiid) THEN CCG_PIID,name=['Tom Conway']
;		
;		note:
;			using the KEYWORD_SET with the variable 'nopiid'
;			allows the user to omit the label by specifying
;			nopiid=1 when the example procedure is invoked.
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, September 2002.
;-
;
PRO 	CCG_PIID,$
	date=date,$
	name=name,$
	x=x,y=y,$
	full=full,$
	charsize=charsize,$
	charthick=charthick,$
	color=color,$
	orientation=orientation,$
	alignment=alignment
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
IF NOT KEYWORD_SET(x) THEN x=0.25
IF NOT KEYWORD_SET(y) THEN y=0.95
IF NOT KEYWORD_SET(alignment) THEN alignment=0
IF NOT KEYWORD_SET(orientation) THEN orientation=0
IF NOT KEYWORD_SET(charsize) THEN charsize=0.75
IF NOT KEYWORD_SET(charthick) THEN charthick=1
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

text='Data provided by:!C!C'
IF KEYWORD_SET(name) THEN BEGIN
	FOR i=0,N_ELEMENTS(name)-1 DO text=text+name[i]+'!C'
ENDIF ELSE text=text+'NOAA ESRL GMD!C'
text=text+'!C'+date

XYOUTS, x,y,$
	/NORMAL,$
	text,$
	ALI=alignment,$
	COLOR=color,$
	ORI=orientation,$
	CHARSIZE=charsize,$
	CHARTHICK=charthick
END
