;+
; NAME:
;	CCG_SREAD	
;
; PURPOSE:
; 	Read strings from the specified	file.
;
;	User may specify 'skip' lines to 
;	skip at the beginning of file.
;
;	User may suppress messages.
;
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_SREAD,file=filename,skip=3,/nomessages,arr
;	CCG_SREAD,file='/projects/ch4/in-situ/mlo_data/month/mlo199512.ch4',result
;	CCG_SREAD,file='readme',/nomessages,skip=20,result
;
; INPUTS:
;	file:	  	source file name.
;
; OPTIONAL INPUT PARAMETERS:
;	skip:		integer specifying the number
;			of lines to skip at the beginning 
;			of the file. 
;
;	nomessages:	If non-zero, messages will be suppressed.
;
;  comment:  Skip lines that begin with the single character comment
;            identifier (e.g., ";", "#").
;
;
; OUTPUTS:
;	result:		The string vector containing contents (by line)
;			from the file,e.g., result(number of lines read).
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
;			CCG_SREAD,file='testfile',skip=2,result
;			.
;			.
;			PRINT,result
;			.
;			.
;			.
;			END
;
;		
; MODIFICATION HISTORY:
;	Written,  KAM, December 1995.
;-
;
PRO	CCG_SREAD, $
	file = file, $
	skip = skip, $
	nomessages = nomessages, $
   comment = comment, $
	arr, $
	help = help
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"File  must be specified.  Exiting ..."
	CCG_MESSAGE,"(ex) CCG_SREAD,file='/users/ken/test',arr"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(skip) THEN skip=0
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0
 
; Does file exist?
 
arr=''
IF FILE_TEST( file ) EQ 0 THEN RETURN
;
;dimension array
;
n = FILE_LINES( file )
arr = STRARR( n )
s = ''
;
OPENR, unit, file, /GET_LUN
;
IF NOT nomessages THEN CCG_MESSAGE, 'Reading ' + file + ' ...'
;
;Skip [skip] number of lines
;
IF KEYWORD_SET(skip) THEN FOR i=0, skip-1 DO READF, unit, s
;
;Read data
;
i = 0L
WHILE NOT EOF(unit) DO BEGIN
	READF, unit, s
 	arr[i ++] = s
ENDWHILE
FREE_LUN, unit
arr = arr[0: i - 1]

IF KEYWORD_SET(comment) THEN BEGIN 

   j = WHERE(STRMID(arr, 0, 1) NE comment)
   arr = arr[j]

ENDIF

;
IF NOT nomessages THEN CCG_MESSAGE, 'Done reading ' + file + ' ...'
END
