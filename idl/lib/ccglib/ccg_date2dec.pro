;+
; NAME:
;	CCG_DATE2DEC
;
; PURPOSE:
;	Convert date from yr mo dy hr mn sc to decimal date. 
;	Leap years are considered.
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_DATE2DEC,	yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
;	CCG_DATE2DEC,	yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,sc=sc,dec=dec
;
; INPUTS:
;	yr:  2-digit year array.
;	mo:  2-digit month array.
;	dy:  2-digit day array.
;	hr:  2-digit hour array.
;	mn:  2-digit minute array.
;	sc:  2-digit second array.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	dec:	Returned decimal date double array
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
;		IDL> CCG_DATE2DEC, yr=1992,mo=1,dy=26,hr=2,mn=00,sc=58,dec=dec
;		IDL> PRINT, FORMAT = '(F)', dec
;		IDL> 
;
;		IDL> CCG_DEC2DATE, dec, yr, mo, dy, hr, mn, sc
;		IDL> PRINT, yr, mo, dy, hr, mn, sc
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;	Modified, KAM, August 1994.
;	Modified, KAM, June 2006.
;-
;
PRO 	CCG_DATE2DEC, $
	yr = yr, $
	mo = mo, $
	dy = dy, $
	hr = hr, $
	mn = mn, $
	sc = sc, $
	dec = dec, $
	help = help
;
;**************************************
;
;Return to caller if an error occurs
;
ON_ERROR,2
;
;Check input parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(yr) THEN yr = 0
;
n = N_ELEMENTS(yr)
;
IF N_ELEMENTS(mo) EQ 0 THEN mo = MAKE_ARRAY(n, /INT, VALUE=1)
IF N_ELEMENTS(dy) EQ 0 THEN dy=MAKE_ARRAY(n,/INT,VALUE=1)
IF N_ELEMENTS(hr) EQ 0 THEN hr=MAKE_ARRAY(n,/INT,VALUE=0)
IF N_ELEMENTS(mn) EQ 0 THEN mn = MAKE_ARRAY(n, /INT, VALUE=0)
IF N_ELEMENTS(sc) EQ 0 THEN sc = MAKE_ARRAY(n, /INT, VALUE=0)
;
siy = [31536000D, 31622400D]

CCG_YMD2JUL, yr, mo, dy, yrdoy
doy = yrdoy - LONG(yr) * 1000

leap = CCG_LEAPYEAR(yr)

soy = (doy - 1) * 86400D + hr * 3600D + mn * 60D + sc

dec = yr + DOUBLE(soy) / siy[leap]

dec = (n EQ 1) ? dec[0] : REFORM(dec, n)
END
