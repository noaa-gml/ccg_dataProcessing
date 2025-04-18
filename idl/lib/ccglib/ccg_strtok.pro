;+
; NAME:
;	CCG_STRTOK
;
; PURPOSE:
;	This PROCEDURE splits a passed string into tokens delimited
;	by the user-provided delimiter.  The result is a vector of tokens.
;	If no tokens are found then the result is a null string constant.
;
; CATEGORY:
;	String Manipulation.
;
; CALLING SEQUENCE:
;	CCG_STRTOK,str='ALT 1993 11 11 15 30  6909-66 P',delimiter=' ',r
;	CCG_STRTOK,str='ALT 1993 11 11 15 30  6909-66 P',res
;	CCG_STRTOK,str='88,1,1,200,352.7436,2.637807E-02,"V"',delimiter=',',result
;
; INPUTS:
;	str:	  	String constant.
;	delimiter:	Single or multiple-character delimiter.  If no 
;			delimiter is specified then a blank character 
;			(' ') is assumed.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	Result:		String vector of tokens.  If no tokens are found
;			then the result is a null string constant.
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
;	Example 1:
;			IDL> s='ALT 1993 11 04 15 28  6211-66 P'
;			IDL> CCG_STRTOK,str=s,delimiter=' ',r
;			IDL> HELP,r
;			IDL> R               STRING    = Array(8)
;			IDL> PRINT, r(0)
;			IDL> ALT
;			IDL> PRINT, r(6)
;			IDL> 6211-66
;	Example 2:
;			IDL> s='88,1,1,200,352.7436,2.637807E-02,"V"'
;			IDL> CCG_STRTOK,str=s,delimiter=',',r
;			IDL> HELP,r
;			IDL> R               STRING    = Array(7)
;
;			IDL> CCG_STRTOK,str=s,delimiter=' ',r
;			IDL> HELP,r
;			IDL> R               STRING    = ''
;
;	Example 3:
;			IDL> CCG_STRTOK,str='testctestctestgtest',delimiter='test',r
;			IDL> PRINT,r
;			IDL> c c g
;		
; MODIFICATION HISTORY:
;	Written, KAM, May 1997.
;-
;
PRO	CCG_STRTOK, $
	str = str, $
	delimiter = delimiter, $
	res, $
	help = help
;
;Check input parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(str) THEN CCG_FATALERR, "'str' must be specified."

IF NOT KEYWORD_SET(delimiter) THEN delimiter=' '

res=['***']
cnt=0
tmp=str
n=STRLEN(str)
ndel=STRLEN(delimiter)

i=0
REPEAT BEGIN
	j=STRMID(STRCOMPRESS(str),i,ndel)
	CASE 1 OF
	j EQ '': 	IF N_ELEMENTS(res) GT 1 THEN $
				res=[res,STRMID(tmp,0,cnt)]
	j NE delimiter:	BEGIN
			STRPUT,tmp,j,cnt
			cnt=cnt+1
			END
	j EQ delimiter:	BEGIN
			res=[res,STRMID(tmp,0,cnt)]
			cnt=0
			tmp=str
			i=i+ndel-1
			END
	ENDCASE
	res=res(WHERE(res NE ''))
	i=i+1
ENDREP UNTIL j EQ ''
n=N_ELEMENTS(res)
IF n EQ 1 THEN res='' ELSE res=res(1:N_ELEMENTS(res)-1)
END
