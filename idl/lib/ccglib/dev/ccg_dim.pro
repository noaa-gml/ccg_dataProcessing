;+
; NAME:
;	CCG_DIM
;
; PURPOSE:
;	Convert date from yr mo dy hr mn to decimal date. 
;	Leap years are considered.
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_DIM,	yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
;
; INPUTS:
;	yr:  2-digit year array.
;	mo:  2-digit month array.
;	dy:  2-digit day array.
;	hr:  2-digit hour array.
;	mn:  2-digit minute array.
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
;		IDL> CCG_DIM,	yr=92,mo=01,dy=26,hr=02,mn=00,dec=dec
;		IDL> PRINT,dec
;		IDL> 92.068534
;
;		IDL> CCG_DIM,	yr=1984,mo=02,dy=29,dec=dec
;		IDL> PRINT,dec
;		IDL> 1984.162568
;
;		IDL> CCG_DIM,	yr=yrarr,mo=moarr,dy=dyarr,hr=hrarr,dec=dec
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;	Modified, KAM, August 1994.
;-
;
PRO 	CCG_DIM,	yr,mo,dim
;
;**************************************
;
;Return to caller if an error occurs
;
ON_ERROR,2
;
;Check input parameters
;
IF N_PARAMS() NE 3 THEN $
	CCG_FATALERR, "Incorrect # of arguments. (ex) ccg_dim,yr,mo,dy' 
;
n=N_ELEMENTS(yr)
dim=INTARR(n)
;
days_in_month=[-9,31,28,31,30,31,30,31,31,30,31,30,31]

FOR i=0,n-1 DO BEGIN
	IF mo[i] EQ 2 	THEN dim[i]=days_in_month[mo[i]]+CCG_LEAPYEAR(yr) $
	                ELSE dim[i]=days_in_month[mo[i]]
ENDFOR

IF n EQ 1 THEN dim=dim(0)
IF n GT 1 THEN dim=REFORM(dim,n)
END
