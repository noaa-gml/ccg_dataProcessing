;+
; NAME:
;	CCG_MEAN
;
; PURPOSE:
;	Compute arithmetic mean.  This function is to replace
;	the IDL user function 'MEAN' which was dropped from 
;	recent distributions.  The mean is computed as follows:
;
;		TOTAL(x)/N_ELEMENTS(x)
;
; CATEGORY:
;	Math.
;
; CALLING SEQUENCE:
;	mean=CCG_MEAN(x)
;
; INPUTS:
;	x:   Vector or array.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	result:		Returned double precision arithmetic mean.
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
;		IDL> PRINT,CCG_MEAN(FINDGEN(100))
;		IDL> 49.5000
;
;		IDL> result=CCG_MEAN(x)
;
;		IDL> PRINT, CCG_MEAN([1,2,3,4,5,6])
;		IDL> 3.5000
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1996.
;-
;
FUNCTION	CCG_MEAN,	x
;
;**************************************
;
;Return to caller if an error occurs
;
ON_ERROR,2
;
;Check input parameter
;
IF N_PARAMS() NE 1 THEN BEGIN
	CCG_MESSAGE,'Array must be passed.  Exiting ...'
	CCG_MESSAGE,'(ex) PRINT, CCG_MEAN([1,2,3,4,5,6,7])'
	RETURN,-1
ENDIF

IF N_ELEMENTS(x) EQ 1 THEN RETURN,x ELSE RETURN,TOTAL(x)/N_ELEMENTS(x)
END
