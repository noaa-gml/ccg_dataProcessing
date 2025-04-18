;+
; NAME:
;	CCG_SWRITE	
;
; PURPOSE:
; 	Write an array of strings to the specified file.
;
;	User may optionally suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_SWRITE,file=filename,str
;	CCG_SWRITE,file='/users/ken/temp',['a','b','c']
;
; INPUTS:
;	file:  		destination file name.
;
;	vector:		must pass one-dimensional string array.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:		If non-zero messages will be suppressed.
;
;	append:			If non-zero, strings are appended to 
;				destination file.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Will write over an existing file.
;
; RESTRICTIONS:
;	Vector must be a one-dimensional string array.
;
; PROCEDURE:
;
;	Example:
;		CCG_SREAD,file='temp',str
;		str=str(WHERE(STRPOS(str,'...') NE -1))
;		.
;		.
;		.
;		CCG_SWRITE,file='temp',str
;		.
;		.
;		.
;		
;		END
;
; MODIFICATION HISTORY:
;	Written, KAM, February 1996
;-
;
PRO 	CCG_SWRITE, $
	file = file, $
	nomessages = nomessages, $
	append = append, $
	s1, $
	help = help
;
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"File name  must be specified.  Exiting ..."
	CCG_MESSAGE,"(EX) ccg_swrite,file='/users/ken/temp',sarr"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
n=N_ELEMENTS(s1)
;
;Open file for writing or appending.
;
IF KEYWORD_SET(append) THEN BEGIN
	OPENU, unit, file, /GET_LUN,/APPEND,WIDTH=10000
	IF NOT nomessages THEN CCG_MESSAGE,'Appending to '+file+' ...'
ENDIF ELSE BEGIN
	OPENW, unit, file, /GET_LUN,WIDTH=10000
	IF NOT nomessages THEN CCG_MESSAGE,'Writing to '+file+' ...'
ENDELSE

format='(A)'

FOR i=0L,n-1 DO PRINTF,unit,FORMAT=format,s1(i)
FREE_LUN, unit
IF NOT nomessages THEN CCG_MESSAGE,'Done writing to '+file+' ...'
END
