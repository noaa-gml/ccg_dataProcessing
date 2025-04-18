;+
; NAME:
;	CCG_INT2MONTH
;
; PURPOSE:
;	Convert month integer (1-12) to month name (JAN-DEC or January-December). 
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_INT2MONTH,	imon=imon,mon=mon,three=1
;	CCG_INT2MONTH,	imon=imon,mon=mon,full=1
;
; INPUTS:
;	imon:  month integer array.
;
; OPTIONAL INPUT PARAMETERS:
;	one=1		   single character month names are returned, e.g. J-D.	
;	three=1		3-character month names are returned, e.g. JAN-DEC (default).
;	full=1		full month names are returned, e.g. January-December.	
;
; OUTPUTS:
;	mon:	Returned character month array
;		of equal size.
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
;		IDL> CCG_INT2MONTH,	imon=1,mon=mon
;		IDL> PRINT,mon
;		IDL> JAN 
;
;		IDL> CCG_INT2MONTH,	imon=5,mon=mon,full=1
;		IDL> PRINT,mon
;		IDL> May
;
;		IDL> CCG_INT2MONTH,	imon=INDGEN(12)+1,mon=mon,one=1
;		IDL> PRINT,mon
;		IDL> J F M A M J J A S O N D
;
;		IDL> CCG_INT2MONTH,	imon=imonarr,mon=monarr
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1995.
;-
PRO	CCG_INT2MONTH, $
	imon = imon, $
	mon = mon, $
	one = one, $
	three = three, $
	full = full, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2	

char = 3

IF KEYWORD_SET(one) 	THEN char=1
IF KEYWORD_SET(three) 	THEN char=3
IF KEYWORD_SET(full) 	THEN char=9

n=N_ELEMENTS(imon)
mon=MAKE_ARRAY(n,/STRING,VALUE='')

IF char EQ 1 THEN month=[	'N/A','J','F','M','A','M','J',$
		      		'J','A','S','O','N','D']

IF char EQ 3 THEN month=[	'N/A','JAN','FEB','MAR','APR','MAY','JUN',$
			 	'JUL','AUG','SEP','OCT','NOV','DEC']
	 
IF char EQ 9 THEN month=[	'N/A','January','February','March','April',$
				'May','June','July','August','September',$
				'October','November','December']
	 
FOR i=0,n-1 DO mon(i)=month(imon(i))
IF n EQ 1 THEN mon=mon(0)
END
