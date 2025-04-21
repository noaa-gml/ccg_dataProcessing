;+
; NAME:
;	CCG_LIF	
;
; PURPOSE:
; 	Determine the number of lines (rows) in
;	the passed file.
;
;	Returns the number of lines in the passed
;	file as an integer.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	result=CCG_LIF(file='filename')
;	result=CCG_LIF(file='/projects/co/flask/site/brw.co')
;
; INPUTS:
;	file:	Specified file.
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
;			.
;			.
;			.
;			nlines=CCG_LIF(file='projects/co2/flask/site/brw.co2')
;			array=MAKE_ARRAY(nlines,/STR,VALUE='')
;			.
;			.
;			.
;		
; MODIFICATION HISTORY:
;	Written, KAM, August 1994.
;-
;
FUNCTION	CCG_LIF,	file=file
    
   ;Verify that file is passed
    
   IF NOT KEYWORD_SET(file) THEN BEGIN

      CCG_MESSAGE,	'File name must be passed.  Exiting ...'
      CCG_MESSAGE,	"(ex)  nlines=CCG_LIF(file='/projects/co/flask/site/brw.co2')"
      RETURN,0

   ENDIF

   nlines = 0L

   ; Use this call in Linux environments

   IF FILE_SEARCH( file, /FOLD_CASE ) NE '' THEN BEGIN

      SPAWN,	'wc -l < '+file, s
      nlines = LONG( s[0] )

   ENDIF

   ; Use this call in non-Linux environments

   ; IF FILE_SEARCH( file, /FOLD_CASE ) NE '' THEN nlines = FILE_LINES( file )

   RETURN,	nlines

END
