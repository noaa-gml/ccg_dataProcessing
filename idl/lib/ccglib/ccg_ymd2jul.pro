;+
; NAME:
;	CCG_YMD2JUL
;
; PURPOSE:
;	Convert from year, month, day to
;	julian date.  If passed yr, mo, and dy
;       are arrays then returned array is of
;	equal size.
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_YMD2JUL,	yr,mo,dy,julian
;
; INPUTS:
;	yr:  	2-digit year.
;	mo:  	2-digit month.
;	dy:  	2-digit day.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	julian:	5 or 7-digit julian date, i.e., 84154 or 1984154
;	Array size is same as passed yr, mo, and dy arrays.
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
;		IDL> CCG_YMD2JUL,1994,12,10,julian
;		IDL> PRINT,julian
;		IDL> 1994344
;
;		IDL> CCG_YMD2JUL,84,2,29,julian
;		IDL> PRINT,julian
;		IDL> 84060
;
;		IDL> CCG_YMD2JUL,yrarr,moarr,dyarr,jularr
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1994.
;-
;
PRO	CCG_YMD2JUL, $
	yr, mo, dy, julian, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;**************************************
;
ON_ERROR,2			; Return to caller if an error occurs
;
;Define julian as long array.
;
julian=LONARR(N_ELEMENTS(yr))
;
diy = [[-9, 0, 31, 59, 90,120,151,181,212,243,273,304,334], $
       [-9, 0, 31, 60, 91,121,152,182,213,244,274,305,335]]

leap=(yr MOD 4 EQ 0 AND yr MOD 100 NE 0) OR yr MOD 400 EQ 0

julian=(1000L*yr)+diy(mo,leap)+dy

IF N_ELEMENTS(yr) EQ 1 THEN julian=julian(0)
END
