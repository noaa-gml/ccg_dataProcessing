;+
; NAME:
;	CCG_HEADER	
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
;	result=CCG_HEADER(file='filename')
;	result=CCG_HEADER(file='/projects/co/flask/site/brw.co')
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
;			nlines=CCG_HEADER(file='projects/co2/flask/site/brw.co2')
;			array=MAKE_ARRAY(nlines,/STR,VALUE='')
;			.
;			.
;			.
;		
; MODIFICATION HISTORY:
;	Written, KAM, November 2010.
;-
;
PRO  CCG_HEADER, $
     sp=sp, $
     project=project, $
     strategy=strategy, $
     site=site, $
     header=header
    
   ;Verify critical keywords
    
   IF NOT KEYWORD_SET( project ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( strategy ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( sp ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( site ) THEN CCG_SHOWDOC

   perl = '/ccg/src/db/ccg_dataheader.pl'
   
   SPAWN, perl + $
          " -project=" + project + $
          " -strategy=" + strategy + $
          " -site=" + site + $
          " -parameter=" + sp, header

END
