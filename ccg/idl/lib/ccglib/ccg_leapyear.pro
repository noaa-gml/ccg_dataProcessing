;+
; NAME:
;	CCG_LEAPYEAR	
;
; PURPOSE:
;	Determine if passed year is a leap year.
;	If passed year is not a leap year then function returns 0
;	If passed year is a leap year then function returns 1
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	leap=CCG_LEAPYEAR(1994)
;	leap=CCG_LEAPYEAR(94)
;	leap=CCG_LEAPYEAR(2000)
;
; INPUTS:
;	Year:	Passed year may be 2 or 4 digit year.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
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
;		Example:
;			leap=CCG_LEAPYEAR(1994)
;			.
;			.
;			.
;			ndays=365+leap
;			.
;			.
;			.
;
;		
; MODIFICATION HISTORY:
;	Written, KAM, March 1994.
;-
FUNCTION	CCG_LEAPYEAR, $
		yr, $
		help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
 
RETURN,	(yr MOD 4 EQ 0 AND yr MOD 100 NE 0) OR yr MOD 400 EQ 0
END
