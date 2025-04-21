;+
; NAME:
;   CCG_INSITUUPDATE
;
; PURPOSE:
;
;   ************************** WARNING ****************************
;   This procedure modifies a U.S. Government Scientific Database.
;   Contact Ken Masarie (kenneth.masarie@noaa.gov) before using.
;   ***************************************************************
;   
;    Add or modify in situ data. If the 'update' keyword
;    is specified, then UPDATE or INSERT the results into the NOAA
;    ESRL CCGG RDBMS. The procedure uses the required name:value
;    pairs (described below) to identify a unique entry in the
;    database. If a unique entry is found, then UPDATE the results
;    in the database. If no entry is found, then INSERT the
;    results into the database. When the results are being sent
;    to the database ('update' keyword is set), the interactions
;    are followed by a 'Y'. For example, 'UPDATE Y' means that
;    the results were UPDATEd in the database. If the 'update'
;    keyword is not set, then process the results and print the
;    expected interaction with the database (e.g., UPDATE or 
;    INSERT). Expected interactions with the database are followed
;    by an 'N'.
;
; CATEGORY:
;   Data Storage
;
; CALLING SEQUENCE:
;   CCG_INSITUUPDATE,project='obs',arr=arr,error=error,/value,/flag,/comment,/unc,/update
;   CCG_INSITUUPDATE,project='obs',file=resultsfile,/nomessages,/value,/flag,error=error,/update
;   CCG_INSITUUPDATE,project='obs',file=resultsfile,/nomessages,/flag, error=error
;   CCG_INSITUUPDATE,project='obs',file=resultsfile,/nomessages, ddir = '/home/ccg/ken/tmp/, error=error
;   CCG_INSITUUPDATE,/help
;
; INPUTS:
;   Either 'arr' or 'file' must be specified.
;
;   arr:      String array containing measurement results.
;
;   project:  CCGG project must be specified.
;
;   file:     File containing measurement results.
;
;      The contents of the arr or file must contain...
;
;       One record, line or row per measurement result.
;
;        Required name:value pairs ...
;         Site Code (site), parameter formula (param),
;         2-character instrument Id (inst), intake height (intake_ht),
;         analysis year (yr), month (mo), day (dy), hour (hr),
;         minute (mn) and seconds (sc). 
;
;        Optional name:value pairs ...
;         Measurement value (value), QC flag (flag), 
;         uncertainty (unc), non-random uncertainty (nonrandom_unc), 
;         random uncertainty (random_unc), and standard deviation (std_dev).
;
;        Each record, line or row must be made up of name:value 
;        pairs delimited by pipes ('|'). Each name:value pair
;        is separated by a colon (':').
;
;        If an optional name:value pair is in the record/line/row
;        and the corresponding optional input parameter
;        (described below) IS set, then the optional name:value
;        pair will be processed.
;
;        If an optional name:value pair is in the record/line/row
;        and the corresponding optional input parameter IS NOT set,
;        then the optional name:value pair is ignored. 
;
;        If an optional name:value pair is NOT in the record/line/row
;        and the corresponding optional input parameter IS set,
;        then a warning will be generated.
;
;   (ex)
;        param:co2|site:BAO|inst:L4|yr:2010|mo:12|dy:31|hr:19|mn:14|sc:55|intake_ht:300.00000|flag:.L.
;
; OPTIONAL INPUT PARAMETERS:
;
;   ddir:         If specified, old-style site strings will
;                    be exported to 'ddir'.
;
;   flag:         If keyword set, the QC flag name:value pair
;                    will be processed in each record/line/row.
;
;   help:         If keyword set, the procedure documentation is
;                    displayed to STDOUT.
;
;   nomessages:   If keyword set, messages will be suppressed.
;
;   nopreserve:   If keyword set and 'flag' keyword also set,
;                 use the value of the QC flag name:value
;                 pair but DO NOT apply flag logic.
;
;                 If keyword not set but 'flag' keyword set,
;                 use the value of the QC flag name:value
;                 pair and DO apply flag logic.
;
;                 Flag logic:
;                  Overwrite an existing 1st column flag if an
;                     existing 1st column flag is '*' OR '.'
;                     OR the new flag has an '*' in the 1st
;                     column.
;                  Never overwrite an existing 2nd column flag
;                  Never overwrite an existing 3rd column flag
;
;   unc:          If keyword set, the uncertainty name:value pair
;                    will be processed in each record/line/row.
;
;   random_unc:   If keyword set, the random uncertainty name:value pair
;                    will be processed in each record/line/row.
;
;   nonrandom_unc: If keyword set, the non-random uncertainty name:value pair
;                    will be processed in each record/line/row.
;
;   value:        If keyword set, the mixing/isotope ratio
;                    name:value pair will be processed in each
;                    record/line/row.
;
;   update:       If keyword set, CCGG DB will be updated.
;
; OUTPUTS:
;   error:      User may capture return errors.
;         Errors may occur if 
;         1) parameter formula is not found in DB
;         2) fields are missing within a record
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   None.
;
; PROCEDURE:
;   No example provided.
;
; MODIFICATION HISTORY:
;   Adapted from CCG_FLASKUPDATE.PRO, KAM, February 2013.
;-
;
FUNCTION    PARSE_NVSTR, str=str

   result = ''

   tmparr = STRSPLIT(str, '|', /EXTRACT)

   FOR i = 0, N_ELEMENTS(tmparr) -1 DO BEGIN

      colon_idx = STRPOS(tmparr[i], ':')

      name = STRCOMPRESS(STRMID(tmparr[i], 0, colon_idx))
      value = STRMID(tmparr[i], colon_idx+1)

      IF SIZE(result, /TYPE) EQ 8 THEN BEGIN
         result = CREATE_STRUCT( result, name, value )
      ENDIF ELSE BEGIN
         result = CREATE_STRUCT( name, value )
      ENDELSE

   ENDFOR

   RETURN, result

END

PRO CCG_INSITUUPDATE, $
   arr=arr, $
   project=project, $
   average=average,$
   file=file, $
   flag=flag, $
   nomessages=nomessages, $
   nopreserve=nopreserve, $
   value=value, $
   ddir=ddir, $
   unc=unc, $
   random_unc=random_unc, $
   nonrandom_unc=nonrandom_unc, $
   update=update, $
   error=error, $
   help=help
   ;
   ;Return to caller if an error occurs
   ;
   ;ON_ERROR,   2
   ;
   ;check input information 
   ;
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(arr) AND NOT KEYWORD_SET(file) THEN CCG_SHOWDOC
   IF KEYWORD_SET(arr) AND KEYWORD_SET(file) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(project) THEN CCG_SHOWDOC
   nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
   nopreserve = (KEYWORD_SET(nopreserve)) ? 1 : 0
   update = (KEYWORD_SET(update)) ? 1 : 0
   average = (KEYWORD_SET(average)) ? average : ""

   updatenames = ['']
   if KEYWORD_SET(flag) THEN updatenames = [updatenames, 'flag']
   if KEYWORD_SET(value) THEN updatenames = [updatenames, 'value']
   if KEYWORD_SET(unc) THEN updatenames = [updatenames, 'unc']
   if KEYWORD_SET(random_unc) THEN updatenames = [updatenames, 'random_unc']
   if KEYWORD_SET(nonrandom_unc) THEN updatenames = [updatenames, 'nonrandom_unc']
    
   ; initialization
    
   error = ['']
   perlsite = '/projects/src/db/ccg_insituupdate.pl'
   tmpfile = CCG_TMPNAM()
   format = '(A32, 1X, F10.3, 1X, A3, 1X, A2, 1X, I4.4, 4(1X, I2.2))'

   f = (KEYWORD_SET(file)) ? file : tmpfile
    
   ; If specified, save contents of string array to temporary file
    
   IF KEYWORD_SET(arr) THEN CCG_SWRITE, /nomessages, file = f, arr

   ; Call perl script

   arg = ""
   FOR i = 0, N_ELEMENTS(updatenames)-1 DO BEGIN
      IF ( updatenames[i] NE '' ) THEN BEGIN
         arg = ( arg EQ "" ) ? " -"+updatenames[i] : arg+" -"+updatenames[i]
      ENDIF
   ENDFOR

   tmp = perlsite+' -verbose -file=' + f + arg

   tmp = tmp + " -project=" + project

   IF average NE "" THEN tmp = tmp+" -average="+average

   IF nopreserve THEN tmp = tmp+" -nopreserve"

   IF update THEN BEGIN
      tmp = tmp+" -update"
      IF NOT nomessages THEN CCG_MESSAGE,'Updating DB ...'
   ENDIF

   SPAWN, tmp, r, error

   ; Must do looping so that the empty lines show up
   IF r[0] NE '' THEN BEGIN
      FOR i = 0, N_ELEMENTS(r) - 1 DO BEGIN
         IF NOT nomessages THEN print, r[i]
      ENDFOR
   ENDIF

   IF NOT nomessages AND update THEN CCG_MESSAGE,'Done Updating DB ...'

   IF NOT KEYWORD_SET(error) THEN BEGIN
      IF error[0] NE '' THEN BEGIN
         FOR i = 0, N_ELEMENTS(error) - 1 DO BEGIN
            print, error[i]
         ENDFOR
      ENDIF
   ENDIF

   SPAWN, "rm -f "+tmpfile
END
