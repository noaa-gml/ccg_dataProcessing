;+
; NAME:
;	CCG_MONTH2INT
;
; PURPOSE:
;	Convert month name (JAN-DEC or January-December) to month integer (1-12). 
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_MONTH2INT,	mon=mon,imon=imon,three=1
;	CCG_MONTH2INT,	mon=mon,imon=imon,full=1
;
; INPUTS:
;	mon:  month character array.
;
; OPTIONAL INPUT PARAMETERS:
;	three=1		3-character month names are passed, e.g. JAN-DEC (default).
;	full=1		full month names are passed, e.g. January-December.	
;
; OUTPUTS:
;	imon:	Returned integer month array
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
;		IDL> CCG_MONTH2INT,	mon='DEC',imon=imon
;		IDL> PRINT,imon
;		IDL> 12
;
;		IDL> CCG_MONTH2INT,	mon='December',imon=imon,full=1
;		IDL> PRINT,imon
;		IDL> 12
;
;		IDL> CCG_MONTH2INT,	mon=['JAN','FEB','MAR'],imon=imon
;		IDL> PRINT,imon
;		IDL> 1   2   3
;
;		IDL> CCG_MONTH2INT,	mon=monarr,imon=imonarr
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1995.
;-
PRO	CCG_MONTH2INT, $
	mon = mon, $
	imon = imon, $
	three = three, $
	full = full, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
IF KEYWORD_SET(full) THEN three=0 ELSE three=1

IF three THEN month=[	'N/A','JAN','FEB','MAR','APR','MAY','JUN',$
			'JUL','AUG','SEP','OCT','NOV','DEC']

IF NOT three THEN month=['N/A','January','February','March','April','May','June',$
			'July','August','September','October','November','December']

n=N_ELEMENTS(mon)
imon=MAKE_ARRAY(n,/INT,VALUE=0)

FOR i=0,n-1 DO BEGIN
	;
	mo=0
	WHILE STRUPCASE(mon(i)) NE STRUPCASE(month(mo)) DO mo=mo+1
	imon(i)=mo
ENDFOR
IF n EQ 1 THEN imon=imon(0)
END
