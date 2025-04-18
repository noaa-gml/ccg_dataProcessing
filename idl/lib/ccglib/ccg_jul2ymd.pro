;+
; NAME:
;	CCG_JUL2YMD
;
; PURPOSE:
;	Convert from a julian date to yr, mo, dy 
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_JUL2YMD,	julian,yr,mo,dy
;
; INPUTS:
;	julian:	5 or 7-digit julian date, i.e., 84154 or 1984154
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	yr:  	2-digit year.
;	mo:  	2-digit month.
;	dy:  	2-digit day.
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
;		IDL> CCG_JUL2YMD,1994344,yr,mo,dy
;		IDL> PRINT,yr,mo,dy
;		IDL> 1994 12 10
;
;		IDL> CCG_JUL2YMD,84060,yr,mo,dy
;		IDL> PRINT,yr,mo,dy
;		IDL> 84 2 29 
;
;		IDL> CCG_JUL2YMD,jularr,yrarr,moarr,dyarr
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1994.
;-
;
PRO	CCG_JUL2YMD, $
	julian, yr, mo, dy, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;**************************************
;
;Return to caller if an error occurs
;
ON_ERROR,2
;
diy = [[-9, 0, 31, 59, 90,120,151,181,212,243,273,304,334,999], $
       [-9, 0, 31, 60, 91,121,152,182,213,244,274,305,335,999]]
;
yr=MAKE_ARRAY(N_ELEMENTS(julian),/INT)
mo=MAKE_ARRAY(N_ELEMENTS(julian),/INT)
dy=MAKE_ARRAY(N_ELEMENTS(julian),/INT)
;
FOR i=0L,N_ELEMENTS(julian)-1 DO BEGIN
	tyr=FIX(julian(i)/1000)
	doy=julian(i) MOD 1000;
	;
	leap=(tyr MOD 4 EQ 0 AND tyr MOD 100 NE 0) OR tyr MOD 400 EQ 0
	;
	tmo=0
	REPEAT tmo=tmo+1 UNTIL (tmo EQ 13 OR diy(tmo,leap) GE doy)
	tmo=tmo-1
	tdy=doy-diy(tmo,leap)
	;
	yr(i)=tyr
	mo(i)=tmo
	dy(i)=tdy
ENDFOR
;
IF N_ELEMENTS(julian) EQ 1 THEN BEGIN
	yr=yr(0)
	mo=mo(0)
	dy=dy(0)
ENDIF ELSE BEGIN
	yr=yr(0:i-1)
	mo=mo(0:i-1)
	dy=dy(0:i-1)
ENDELSE
END
