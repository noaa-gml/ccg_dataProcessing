;+
; NAME:
;	CCG_DEC2DATE
;
; PURPOSE:
;	Convert date from decimal date to year, 
;	month, day, hour, and second.  If passed decimal
;	date is an array then returned variables
;	are arrays of equal size.  Leap year is
;	considered.
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_DEC2DATE,	decimal,yr,mo,dy,hr,mn
;	CCG_DEC2DATE,	decimal,yr,mo,dy,hr,mn,sc
;
; INPUTS:
;	decimal:  decimal date array (double precision).
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	Returns year, month, day, hour, minute, and
;	second array.  Array size is same as passed
;	decimal date array. 
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	If decimal date may contain
;	second information, the procedure
;	may return a time that is affected
;	by hardware precision.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;
;	Example:
;		IDL> CCG_DEC2DATE,	92.068534,yr,mo,dy,hr
;		IDL> PRINT,yr,mo,dy,hr
;		IDL> 92 01 26 02
;
;		IDL> CCG_DEC2DATE,	1984.161202,yr,mo,dy,hr,mn,sc
;
;		IDL> CCG_DEC2DATE,	decarr,yarr,marr,darr,harr
;
; MODIFICATION HISTORY:
;	Written, September 1993 - kam.
;	Modified, July 1997 - kam.
;	Modified, June 2006 - kam.
;-
PRO	CCG_DEC2DATE, $
	decimal, yr, mo, dy, hr, mn, sc, $
	help = help
;
;************************************************
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

decimal = REFORM(decimal)

n = N_ELEMENTS(decimal)
 
yr = INTARR(n)
mo = INTARR(n)
dy = INTARR(n)
hr = INTARR(n)
mn = INTARR(n)
sc = INTARR(n)

dyr = FIX(decimal)
fyr = decimal - dyr

leap = CCG_LEAPYEAR(dyr)

nsc = LONG(fyr * (365 + leap) * 86400D)

ndy = nsc / 86400

doy = ndy + 1

CCG_JUL2YMD, dyr * 1000L + doy, yr, mo, dy

nscs = nsc - (ndy * 86400)

hr = nscs / 3600

mn = (nscs - (hr * 3600)) / 60

sc = (fyr * (365 + leap) * 86400D) - (ndy * 86400) - (hr * 3600.0) - (mn * 60.0)
sc = FIX(CCG_ROUND(sc, 0))
;
; If rounding second to 60, adjust day, hour, minute, and second
;
j = WHERE(sc EQ 60)
IF j[0] NE -1 THEN BEGIN
	sc[j] = 0 & mn[j] ++
	;
	; If minute to 60, adjust day, hour, and minute
	;
	k = WHERE(mn[j] EQ 60)
	IF k[0] NE -1 THEN BEGIN
		mn[j[k]] = 0 & hr[j[k]] ++
		;
		; If hour to 24, adjust day and hour
		;
		m = WHERE(hr[j[k]] EQ 24)
		IF m[0] NE -1 THEN BEGIN
			hr[j[k[m]]] = 0 & doy[j[k[m]]] ++
			CCG_JUL2YMD, dyr[j[k[m]]] * 1000L + doy[j[k[m]]], a, b, c
			yr[j[k[m]]] = a & mo[j[k[m]]] = b & dy[j[k[m]]] = c
		ENDIF
	ENDIF
ENDIF

; If n equals 1, set hr, mn, sc to integer constant.
; yr, mo, dy are set to integer constant by the call to ccg_jul2ymd
; 2010-03-08 (kam)

IF n EQ 1 THEN BEGIN

   hr = FIX( hr[0] )
   mn = FIX( mn[0] )
   sc = FIX( sc[0] )

ENDIF
END
