;+
; NAME:
;	CCG_STRRPOS	
;
; PURPOSE:
;	This FUNCTION returns the position of the
;	LAST occurrence of the passed key in the
;	passed string.  If the key is not found in
;	the string then (-1) is returned.
;
;
; CATEGORY:
;	String Manipulation.
;
; CALLING SEQUENCE:
;	z=CCG_STRRPOS(str,key)
;	z=CCG_STRRPOS(strarr,key)
;	z=CCG_STRRPOS('/projects/ch4/in-situ/brw_data/month/brw199512.ch4','/')
;	z=CCG_STRRPOS('mlomlomlomlomlo','mlo')
;
; INPUTS:
;	string:	  	Search string or string vector.
;	key:		Search key.
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
;
;		Example:
;			IDL> s='/projects/ch4/in-situ/mlo_data/month/mlo199512.ch4'
;			IDL> z=CCG_STRRPOS(s,'/')
;			IDL> PRINT,STRMID(s,z+1,100)
;			IDL> mlo199512.ch4
;			
;			IDL> s='mlomlomlomlomlomlo'
;			IDL> z=CCG_STRRPOS(s,'mlo')
;			IDL> PRINT,z
;			IDL> 15
;		
;			IDL> s='mlomlomlomlomlomlo'
;			IDL> z=CCG_STRRPOS(s,'brw')
;			IDL> PRINT,z
;			IDL> -1
;		
; MODIFICATION HISTORY:
;	Written, KAM, December 1994.
;-
;
FUNCTION	CCG_STRRPOS, $
		str, sub, $
		help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC

n=N_ELEMENTS(str)
result=INTARR(n)

FOR i=0,n-1 DO BEGIN
	l=STRLEN(str(i))
	WHILE (l GE 0 AND ((j=STRPOS(str(i),sub,l))) EQ -1) DO l=l-1
	result(i)=l
ENDFOR

IF n EQ 1 THEN result=result(0)

RETURN,result
END
