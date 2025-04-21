;+
; NAME:
;   CCG_FLASKUPDATE
;
; PURPOSE:
;
;   ************************** WARNING ****************************
;   This procedure modifies a U.S. Government Scientific Database.
;   Contact Ken Masarie (kenneth.masarie@noaa.gov) before using.
;   ***************************************************************
;   
;   Process flask/pfp measurement results. If the 'update' keyword
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
;   or
;
;   Export 'old-style' strings to "site" files
;
; CATEGORY:
;   Data Storage
;
; CALLING SEQUENCE:
;   CCG_FLASKUPDATE,arr=arr,error=error,/value,/flag,/comment,/unc,/update
;   CCG_FLASKUPDATE,file=resultsfile,/nomessages,/value,/flag,error=error,/update
;   CCG_FLASKUPDATE,file=resultsfile,/nomessages,/flag, error=error
;   CCG_FLASKUPDATE,file=resultsfile,/nomessages, ddir = '/home/ccg/ken/tmp/, error=error
;   CCG_FLASKUPDATE,/help
;
; INPUTS:
;   Either 'arr' or 'file' must be specified.
;
;   arr:      String array containing measurement results.
;
;   file:      File containing measurement results.
;
;      The contents of the arr or file must contain...
;
;       One record, line or row per measurement result.
;
;        Required name:value pairs ...
;         Event number (evn), parameter formula (param),
;         2-character instrument Id (inst), analysis
;         year (yr), month (mo), day (dy), hour (hr),
;         minute (mn) and seconds (sc). Please note that
;         the analysis date and time are in local time.
;
;        Optional name:value pairs ...
;         Measurement value (value), QC flag (flag), analysis
;         comment (comment), and uncertainty (unc).
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
;   evn:159040|param:ch4|value:1801.17|flag:...|inst:H4|yr:2004|mo:03|dy:22|hr:09|mn:11
;   (ex)
;   evn:105424|param:co2o18|value:0.5670|flag:...|inst:o1|yr:2003|mo:05|dy:21|hr:18|mn:26
;
;        Note:  Array/file may include records/lines/rows containing
;               measurements results for one or more parameters.
;
; OPTIONAL INPUT PARAMETERS:
;   comment:      If keyword set, the analysis comment
;                    name:value pair will be processed in
;                    each record/line/row.
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
;   value:        If keyword set, the mixing/isotope ratio
;                    name:value pair will be processed in each
;                    record/line/row.
;
;   update:       If keyword set, CCGG DB will be updated.
;
; OUTPUTS:
;   error:      User may capture return errors.
;         Errors may occur if 
;         1) event number is not found in DB
;         2) parameter formula is not found in DB
;         3) fields are missing within a record
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
;   Written, KAM, August 2004.
;   Modified, KAM, August 2005.
;   Modified, DYC, January 2007.
;   Modified, DYC, November 2008.
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

PRO    CCG_FLASKUPDATE, $
   arr = arr, $
   comment = comment, $
   file = file, $
   flag = flag, $
   nomessages = nomessages, $
   nopreserve = nopreserve, $
   value = value, $
   ddir = ddir, $
   unc = unc, $
   update = update, $
   error = error, $
   help = help
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
nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
nopreserve = (KEYWORD_SET(nopreserve)) ? 1 : 0
update = (KEYWORD_SET(update)) ? 1 : 0

updatenames = ['']
if KEYWORD_SET(comment) THEN updatenames = [updatenames, 'comment']
if KEYWORD_SET(flag) THEN updatenames = [updatenames, 'flag']
if KEYWORD_SET(value) THEN updatenames = [updatenames, 'value']
if KEYWORD_SET(unc) THEN updatenames = [updatenames, 'unc']
;
;initialization
;
error = ['']
perlsite = '/projects/src/db/ccg_flaskupdate.pl'
tmpfile = CCG_TMPNAM()
format = '(A32, 1X, F10.3, 1X, A3, 1X, A2, 1X, I4.4, 4(1X, I2.2))'
format = '(A32, 1X, F10.3, 1X, A3, 1X, A2, 1X, I4.4, 4(1X, I2.2),F8.3,A10)'   ;new format. Accomodates uncertainty and event number

f = (KEYWORD_SET(file)) ? file : tmpfile
;
;If specified, save contents of string array to temporary file
;
IF KEYWORD_SET(arr) THEN CCG_SWRITE, /nomessages, file = f, arr

IF NOT update AND KEYWORD_SET(ddir) THEN BEGIN
   ;
   ; Construct "old-style" site strings
   ;
   CCG_READ, file = f , delimiter='|', /nomessages, arr_

   n = N_ELEMENTS(arr_)

   FOR i = 0, n - 1 DO BEGIN

      z = PARSE_NVSTR(str=arr_[i].str)

      CCG_FLASK, /nomessages, evn = z.evn, event
      data = STRING(FORMAT = format, STRMID(event.str, 0, 32), $
      z.value, z.flag, z.inst, z.yr, z.mo, z.dy, z.hr, z.mn,z.unc,z.evn)   ;Sylvia added .unc and z.evn
      param = STRLOWCASE(z.param)

      ;
      ; Export
      ;
      ;perl = '/home/ccg/ken/idllib/ccglib/dbms/merge_ss.pl'
      ;jwm - 2/29/16 - this path no longer exists.. switching to local merge_ss.pl.  I'm not sure if there 
      ;were differences between the one in this directory and the one in ken's old directory though.
      perl = '/ccg/idl/lib/ccglib/dbms/merge_ss.pl'

      IF CCG_STRRPOS(ddir, '/') NE STRLEN(ddir) - 1 THEN ddir = TEMPORARY(ddir) + '/'

      
       SPAWN, 'echo "' + data + '" | ' + perl + ' -d' + ddir  + ' -g' + param + ' -u'

   ENDFOR

ENDIF ELSE BEGIN
   ;
   ; Call perl script
   ;

   arg = ""
   FOR i = 0, N_ELEMENTS(updatenames)-1 DO BEGIN
      IF ( updatenames[i] NE '' ) THEN BEGIN
         arg = ( arg EQ "" ) ? " -"+updatenames[i] : arg+" -"+updatenames[i]
      ENDIF
   ENDFOR

   tmp = perlsite+' -verbose -file=' + f + arg

   IF nopreserve THEN tmp = tmp+" -nopreserve"

   IF update THEN BEGIN
      tmp = tmp+" -update"
      IF NOT nomessages THEN CCG_MESSAGE,'Updating DB ...'
   ENDIF

   SPAWN, tmp, r, error
   ; Must do looping so that the empty lines show up
   ;jwm 4/16.  Hit limit of default short int (32000), so changed for i = 0.. to for i=0L to force long.  Here and below.
   IF r[0] NE '' THEN BEGIN
      FOR i = 0L, N_ELEMENTS(r) - 1 DO BEGIN
         IF NOT nomessages THEN print, r[i]
      ENDFOR
   ENDIF

   IF NOT nomessages AND update THEN CCG_MESSAGE,'Done Updating DB ...'

   IF NOT KEYWORD_SET(error) THEN BEGIN
      IF error[0] NE '' THEN BEGIN
         FOR i = 0L, N_ELEMENTS(error) - 1 DO BEGIN
            print, error[i]
         ENDFOR
      ENDIF
   ENDIF

ENDELSE

SPAWN, "rm -f "+tmpfile
END
