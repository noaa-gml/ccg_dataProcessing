;+
; NAME:
;	CCG_ROUND
;
; PURPOSE:
;	Return the passed value rounded to the
;	passed power of ten.  value and power
;	may be arrays of equal size.
;
; CATEGORY:
;	Math.
;
; CALLING SEQUENCE:
;	result=CCG_ROUND(345.6901,-2)
;	resarr=CCG_ROUND(valarr,powarr)
;
; INPUTS:
;	value:	Numeric to be rounded.
;	power:	Power of ten integer.	
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	result:	Numeric result of rounding
;		passed value to passed power
;		of ten.	
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
;		IDL> r=CCG_ROUND(1994344,3)
;		IDL> PRINT,r
;		IDL> 1994000
;
;		IDL> r=CCG_ROUND,345.5967,-3)
;		IDL> PRINT,r
;		IDL> 345.597
;
;		IDL> rarr=CCG_ROUND(valarr,powarr)
;
; MODIFICATION HISTORY:
;	Written, KAM, November 1994.
;-
;
FUNCTION	CCG_ROUND, $
		val, power, $
		help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;Return to caller if an error occurs
;
ON_ERROR,2
;
n=N_ELEMENTS(val)

;---- Ajout peylin...
np = N_ELEMENTS(power)
p  = power
IF (np EQ 1 AND n GT 1) THEN p=MAKE_ARRAY(n,/DOUBLE,VALUE=power(0))

p=DOUBLE(p)
v=val
t=DOUBLE(v*10.^(-p))
t1=ROUND(t)

r=t1*10.^(p)
IF n EQ 1 THEN r=r(0)

RETURN,r

END
