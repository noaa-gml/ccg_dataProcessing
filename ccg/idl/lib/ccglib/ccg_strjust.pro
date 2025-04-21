;+
; NAME:
;	CCG_STRJUST
;
; PURPOSE:
;	Right, left, or center justify passed
;	string(s) into specified field width.
;
;	Returns justified string(s).
;	
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	PRINT,	CCG_STRJUST('test',40,1)
;	r=CCG_STRJUST('TITLE',80,0)
;	rarr=CCG_STRJUST(sarr)
;
; INPUTS:
;	str:	String constant or vector
;
; OPTIONAL INPUT PARAMETERS:
;	field width:	Specifies the field width.
;			If not specified then field width
;			is defined by the maximum string
;			length of the passed string vector
;			or constant.
;
;	justification:
;			-1	-> left justification (default)
;			 0	-> center justification
;			 1	-> right justification
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	If field width is less than the string length of any passed
;	string then the string(s) will be truncated.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	CCG_STRJUST may be called from the IDL command line or
;	from an IDL procedure.
;	Example:
;		IDL>a=['a','ab','abc','abcd']
;
;		IDL>r=CCG_STRJUST(a)
;		IDL> for i=0,3 do print,r(i)
;		a   
;		ab  
;		abc 
;		abcd
;
;		IDL>r=CCG_STRJUST(a,10,1)
;		IDL> for i=0,3 do print,r(i)
;		          a   
;		         ab  
;		        abc 
;		       abcd
;
;		IDL>r=CCG_STRJUST(a,MAX(STRLEN(a)),0)
;		IDL> for i=0,3 do print,r(i)
;		  a   
;		 ab  
;		 abc 
;		abcd
;		
; MODIFICATION HISTORY:
;	Written, KAM, March 1996.
;-
;
FUNCTION	CCG_STRJUST, $
		in, len, ali, $
		help = help
;
;Check input parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

CASE N_PARAMS() OF
0:	BEGIN
		CCG_MESSAGE,'A character string must be specified.  Exiting ...
		CCG_MESSAGE,"(ex) newstring=CCG_STRJUST(oldstring,20,-1)
		RETURN,''
	END
1:	BEGIN
		len=MAX(STRLEN(in))
		ali=(-1)
	END
2:	BEGIN
		ali=(-1)
	END
ELSE:
ENDCASE

n=N_ELEMENTS(in)
l_out=MAKE_ARRAY(n,/INT,VALUE=len)
l_in=STRLEN(in)
sformat=STRCOMPRESS('(A'+STRING(len)+')')
out=MAKE_ARRAY(n,/STR,VALUE=STRING(FORMAT=sformat,' '))
 
CASE ali OF
-1:	just=INTARR(n)
0:	just=l_out/2-l_in/2
1:	just=l_out-l_in
ENDCASE

FOR i=0,n-1 DO BEGIN
	temp=STRING(FORMAT=sformat,' ')
	STRPUT,temp,in(i),just(i)
	out(i)=temp
ENDFOR

IF n EQ 1 THEN RETURN,out(0) ELSE RETURN,out
END
