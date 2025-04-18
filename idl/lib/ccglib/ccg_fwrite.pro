;+
; NAME:
;	CCG_FWRITE	
;
; PURPOSE:
; 	Write 'nc' columns of integers or real
;	numbers to the specified file. 'nc' 
;	must be <= 15.
;
;	User may optionally suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_FWRITE,file=filename,nc=1,x
;	CCG_FWRITE,file='/users/ken/temp',nc=4,a,b,c,d
;	CCG_FWRITE,file='temp',nc=3,var(0,*),var(1,*),var(2,*)
;
; INPUTS:
;	file:  		destination file name.
;
;	nc:		number of columns in the file.
;			columns must contain integers
;			or real numbers.
;
;	arrays:		must pass nc one-dimension arrays
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:		If non-zero messages will be suppressed.
;
;	double:			If non-zero, columns are stored as double precision.
;
;	append:			If non-zero, data is appended to destination file.
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
;	Column values must be integer
;	or real numbers.
;
; PROCEDURE:
;
;	Example:
;		CCG_FREAD,file='testfile',nc=5,var
;		.
;		.
;		.
;		PLOT, var(0,*),var(1,*)
;		.
;		.
;		.
;		CCG_FWRITE,file='temp',nc=2,var(3,*),var(4,*)
;		.
;		.
;		.
;		
;		END
;
; MODIFICATION HISTORY:
;	Written, KAM, January 1994
;-
;
PRO 	CCG_FWRITE, $
	file = file, $
	nc = nc, $
	double = double, $
	nomessages = nomessages, $
	append = append, $
	c1, c2, c3, c4, c5, c6, c7, $
	c8, c9, c10, c11, c12, c13, $
	c14, c15, $
	help = help
;
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(file) OR NOT KEYWORD_SET(nc) THEN BEGIN
	CCG_MESSAGE,"File name and number of columns must be specified.  Exiting ..."
	CCG_MESSAGE,"(EX) CCG_FWRITE,file='/users/ken/temp',nc=3,x,y,z"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
n=N_ELEMENTS(c1)
;
;Open file for writing or
;appending.
;
IF KEYWORD_SET(append) THEN BEGIN
	OPENU, unit, file, /GET_LUN,/APPEND,WIDTH=10000
	IF NOT nomessages THEN CCG_MESSAGE,'Appending to '+file+' ...'
ENDIF ELSE BEGIN
	OPENW, unit, file, /GET_LUN,WIDTH=10000
	IF NOT nomessages THEN CCG_MESSAGE,'Writing to '+file+' ...'
ENDELSE

format=''
IF KEYWORD_SET(double) THEN format=STRCOMPRESS('('+STRING(nc)+'(F,1X))',/RE)

CASE nc OF
1:	BEGIN
		FOR i=0L,n-1 DO PRINTF,unit,FORMAT=format,c1(i)
	END
2:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i)
		ENDFOR
	END
3:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i)
		ENDFOR
	END
4:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i)
		ENDFOR
	END
5:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i)
		ENDFOR
	END
6:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i)
		ENDFOR
	END
7:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),c7(i)
		ENDFOR
	END
8:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),c7(i),c8(i)
		ENDFOR
	END
9:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),c7(i),c8(i),c9(i)
		ENDFOR
	END
10:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),c7(i),c8(i),c9(i),c10(i)
		ENDFOR
	END
11:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),$
			c7(i),c8(i),c9(i),c10(i),c11(i)
		ENDFOR
	END
12:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),$
			c7(i),c8(i),c9(i),c10(i),c11(i),c12(i)
		ENDFOR
	END
13:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),$
			c7(i),c8(i),c9(i),c10(i),c11(i),c12(i),$
			c13(i)
		ENDFOR
	END
14:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),$
			c7(i),c8(i),c9(i),c10(i),c11(i),c12(i),$
			c13(i),c14(i)
		ENDFOR
	END
15:	BEGIN
		FOR i=0L,n-1 DO BEGIN
			PRINTF,unit,FORMAT=format,$
			c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),$
			c7(i),c8(i),c9(i),c10(i),c11(i),c12(i),$
			c13(i),c14(i),c15(i)
		ENDFOR
	END
ENDCASE
FREE_LUN, unit
IF NOT nomessages THEN CCG_MESSAGE,'Done writing to '+file+' ...'
END
