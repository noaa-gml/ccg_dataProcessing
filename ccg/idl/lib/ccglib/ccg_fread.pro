;+
; NAME:
;   CCG_FREAD   
;
; PURPOSE:
;    Read 'nc' columns of integers
;   or real numbers from the specified
;   file.
;
;   User may specify 'skip' lines to 
;   skip at the beginning of file.
;
;   User may suppress messages.
;
;
; CATEGORY:
;   Text Files.
;
; CALLING SEQUENCE:
;   CCG_FREAD,file=filename,nc=3,skip=3,/nomessages,var
;   CCG_FREAD,file='/projects/ch4/in-situ/brw_data/year/brw93.ch4',nc=6,var
;   CCG_FREAD,file='/users/ken/mlo.co2',nc=12,skip=20,result
;
; INPUTS:
; file:        source file name.
;
; nc:          number of columns in the file.
;              columns must contain integers
;              or real numbers.
;
; OPTIONAL INPUT PARAMETERS:
;
; skip:        integer specifying the number
;              of lines to skip at the beginning 
;              of the file. 
;
; set_nan:     All NaN will be replaced by set_nan.
;
; comment:     Skip lines that begin with the single character comment
;              identifier (e.g., ";", "#", "REM", "C").
;
; nomessages:  If non-zero, messages will be suppressed.
;
; OUTPUTS:
;   result:    The double precision array containing variables from file,
;              i.e., results(number of columns,number of lines read)
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   Column values of rows not skipped 
;   must be integer or real numbers.
;
; PROCEDURE:
;
;      Example:
;         CCG_FREAD,file='testfile',nc=2,res
;         .
;         .
;         .
;         PLOT, res(0,*),res(1,*)
;         .
;         .
;         .
;         END
;
;      
; MODIFICATION HISTORY:
;   Written,  KAM, January 1994.
;   Modified, KAM, April 1994.
;   Modified, KAM, December 2012. 
;     Introduced "comment" option to facililate use of "comment" option.
;-
;
PRO CCG_FREAD, $
   file=file, $
   nc=nc, $
   skip=skip, $
   set_nan=set_nan, $
   nomessages=nomessages, $
   comment=comment, $
   var, $
   help = help
    
   ;-----------------------------------------------check input information 
    
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC

   IF NOT KEYWORD_SET(file) OR NOT KEYWORD_SET(nc) THEN BEGIN
      CCG_MESSAGE,"File and number of columns must be specified.  Exiting ..."
      CCG_MESSAGE,"(ex) CCG_FREAD,file='/users/ken/test',nc=3,result"
      RETURN
   ENDIF
    
   IF NOT KEYWORD_SET(skip) THEN skip=0
   IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1

   comment = KEYWORD_SET( comment ) ? comment : ""
   var = 0

   ; First read file using ccg_sread

   CCG_SREAD, file=file, nomessages=nomessages, skip=skip, comment=comment, items
   IF items[0] EQ "" THEN RETURN

   nr = N_ELEMENTS( items )

    
   ; Dimension array
    
   var = DBLARR( nc, nr )
   v = DBLARR( nc )

   FOR i=0L, nr-1 DO BEGIN

      READS, items[i], v
      var[0:nc-1,i] = v

   ENDFOR

   IF KEYWORD_SET( set_nan ) THEN BEGIN

      j = WHERE( FINITE( var, /NAN ) EQ 1 )
      IF j[0] EQ -1 THEN RETURN
      var[j] = set_nan

   ENDIF

END
