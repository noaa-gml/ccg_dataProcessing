;+
; NAME:
;	CCG_VDEF	
;
; PURPOSE:
; 	Determine if the passed variable name is defined.
;
;	Returns zero (0) if variable name IS NOT defined.
;	Returns one (1) if variable name IS defined.
;
;	This procedure is similar to the IDL command KEYWORD_SET
;	except that KEYWORD_SET returns a one (1) if the keyword
;	is non-zero and a zero (0) if the keyword is not set OR is
;	set to zero (0).  This is a problem if the user wants to assign
;	the value zero (0) to a keyword.  CCG_VDEF will return a
;	one (1) if the keyword is defined regardless of its value
;	and zero (0) if the keyword variable is undefined.
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	defined=CCG_VDEF(x)
;	defined=CCG_VDEF(variablename)
;
; INPUTS:
;	variable name:	
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
;			PRO EX,int_x=int_x,str=str,flt_y=flt_y
;			.
;			.
;			.
;			IF CCG_VDEF(int_x) THEN PRINT, 'Integer int_x is  defined'
;			IF CCG_VDEF(str) THEN PRINT, 'String str is  defined'
;			IF CCG_VDEF(flt_y) THEN PRINT, 'Float flt_y is  defined'
;			.
;			.
;			.
;		
; MODIFICATION HISTORY:
;	Written, KAM, December 1996.
;-
;
FUNCTION	CCG_VDEF, $
		v, $
		help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;Verify that file is passed
;
a=SIZE(v)
IF a(1) EQ 0 THEN RETURN,0 ELSE RETURN, 1
END
