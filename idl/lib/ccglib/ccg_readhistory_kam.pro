;+
; NAME:
;   CCG_READHISTORY   
;
; PURPOSE:
;    Read a PFP history file.
;   
;   User may suppress messages.
;
; CATEGORY:
;   Text Files.
;
; CALLING SEQUENCE:
;   CCG_READHISTORY, file='/ccg/aircraft/car/history/archive/2011-02-15.1720.3068.arc', result
;   CCG_READHISTORY, file='/ccg/aircraft/car/history/2011-02-15.1720.3068.his', result
;
; INPUTS:
;   file:        source history file name.
;
; OPTIONAL INPUT PARAMETERS:
;   nomessages:   If non-zero, messages will be suppressed.
;
; OUTPUTS:
;   result:   Anonymous structure array.  The length of the
;             array is determined by the number of "taken" samples.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   Must be a PFP-formatted history file.
;
; PROCEDURE:
;
;      Example:
;         CCG_READHISTORY, file='/projects/aircraft/car/history/2010-05-23.1654.3032.his', result
;      
;         HELP,result,/STR     
;
;         .
;         .
;         .
;         END
;
;      
; MODIFICATION HISTORY:
;   Written,  July 12, 2006 (kam)
;   Modified, May 26, 2010 (kam)
;-

@ccg_utils.pro

PRO   CCG_READHISTORY, $
      file=file, $
      help=help, $
      res

   IF KEYWORD_SET( help ) THEN CCG_SHOWDOC
   ;
   ; This procedure reads a PFP history file and
   ; returns results in a structure
   ;
   DEFAULT0 = (-9)
   DEFAULT1 = (-999999D)
   DEFAULT2 = (-999999L)
   perl = "/projects/src/pfp/read_history_kam.pl"

   res = CREATE_STRUCT($
   'code',          '', $
   'id',            '', $
   'firmware',      '', $
   'nsamples',        0)

   s1 = CREATE_STRUCT($
   'id',                   DEFAULT0, $

   'alt_plan',             DEFAULT1, $
   'alt_start',            DEFAULT1, $
   'alt_end',              DEFAULT1, $
   'alt_min',              DEFAULT1, $
   'alt_max',              DEFAULT1, $
   'alt_mean',             DEFAULT1, $
        
   'pos_plan_lat',         DEFAULT1, $
   'pos_plan_lon',         DEFAULT1, $
   'pos_start_lat',        DEFAULT1, $
   'pos_start_lon',        DEFAULT1, $
   'pos_end_lat',          DEFAULT1, $
   'pos_end_lon',          DEFAULT1, $

   'time_plan_date',             '', $
   'time_plan_date_yr',    DEFAULT0, $
   'time_plan_date_mo',    DEFAULT0, $
   'time_plan_date_dy',    DEFAULT0, $
   'time_plan_time',             '', $
   'time_plan_time_hr',    DEFAULT0, $
   'time_plan_time_mn',    DEFAULT0, $
   'time_plan_time_sc',    DEFAULT0, $
   'time_plan_dd',         DEFAULT1, $
   'time_start_date',            '', $
   'time_start_date_yr',   DEFAULT0, $
   'time_start_date_mo',   DEFAULT0, $
   'time_start_date_dy',   DEFAULT0, $
   'time_start_time',            '', $
   'time_start_time_hr',   DEFAULT0, $
   'time_start_time_mn',   DEFAULT0, $
   'time_start_time_sc',   DEFAULT0, $
   'time_start_dd',        DEFAULT1, $
   'time_end_date',              '', $
   'time_end_date_yr',     DEFAULT0, $
   'time_end_date_mo',     DEFAULT0, $
   'time_end_date_dy',     DEFAULT0, $
   'time_end_time',              '', $
   'time_end_time_hr',     DEFAULT0, $
   'time_end_time_mn',     DEFAULT0, $
   'time_end_time_sc',     DEFAULT0, $
   'time_end_dd',          DEFAULT1, $

   'prefill_smp_flush',    DEFAULT1, $
   'prefill_man_flush',    DEFAULT1, $
   'prefill_vol',          DEFAULT1, $
   'prefill_press',        DEFAULT1, $
   'preflag_str',                '', $

   'prefill_each_time_plan_date',             '', $
   'prefill_each_time_plan_date_yr',    DEFAULT0, $
   'prefill_each_time_plan_date_mo',    DEFAULT0, $
   'prefill_each_time_plan_date_dy',    DEFAULT0, $
   'prefill_each_time_plan_time',             '', $
   'prefill_each_time_plan_time_hr',    DEFAULT0, $
   'prefill_each_time_plan_time_mn',    DEFAULT0, $
   'prefill_each_time_plan_time_sc',    DEFAULT0, $
   'prefill_each_time_plan_dd',         DEFAULT1, $
   'prefill_each_time_start_date',            '', $
   'prefill_each_time_start_date_yr',   DEFAULT0, $
   'prefill_each_time_start_date_mo',   DEFAULT0, $
   'prefill_each_time_start_date_dy',   DEFAULT0, $
   'prefill_each_time_start_time',            '', $
   'prefill_each_time_start_time_hr',   DEFAULT0, $
   'prefill_each_time_start_time_mn',   DEFAULT0, $
   'prefill_each_time_start_time_sc',   DEFAULT0, $
   'prefill_each_time_start_dd',        DEFAULT1, $
   'prefill_each_time_end_date',              '', $
   'prefill_each_time_end_date_yr',     DEFAULT0, $
   'prefill_each_time_end_date_mo',     DEFAULT0, $
   'prefill_each_time_end_date_dy',     DEFAULT0, $
   'prefill_each_time_end_time',              '', $
   'prefill_each_time_end_time_hr',     DEFAULT0, $
   'prefill_each_time_end_time_mn',     DEFAULT0, $
   'prefill_each_time_end_time_sc',     DEFAULT0, $
   'prefill_each_time_end_dd',          DEFAULT1, $

   'prefill_each_smp_flush',    DEFAULT1, $
   'prefill_each_man_flush',    DEFAULT1, $
   'prefill_each_vol',          DEFAULT1, $
   'prefill_each_press',        DEFAULT1, $
   'prefill_each_flag_str',           '', $

   'prefill_all_time_plan_date',             '', $
   'prefill_all_time_plan_date_yr',    DEFAULT0, $
   'prefill_all_time_plan_date_mo',    DEFAULT0, $
   'prefill_all_time_plan_date_dy',    DEFAULT0, $
   'prefill_all_time_plan_time',             '', $
   'prefill_all_time_plan_time_hr',    DEFAULT0, $
   'prefill_all_time_plan_time_mn',    DEFAULT0, $
   'prefill_all_time_plan_time_sc',    DEFAULT0, $
   'prefill_all_time_plan_dd',         DEFAULT1, $
   'prefill_all_time_start_date',            '', $
   'prefill_all_time_start_date_yr',   DEFAULT0, $
   'prefill_all_time_start_date_mo',   DEFAULT0, $
   'prefill_all_time_start_date_dy',   DEFAULT0, $
   'prefill_all_time_start_time',            '', $
   'prefill_all_time_start_time_hr',   DEFAULT0, $
   'prefill_all_time_start_time_mn',   DEFAULT0, $
   'prefill_all_time_start_time_sc',   DEFAULT0, $
   'prefill_all_time_start_dd',        DEFAULT1, $
   'prefill_all_time_end_date',              '', $
   'prefill_all_time_end_date_yr',     DEFAULT0, $
   'prefill_all_time_end_date_mo',     DEFAULT0, $
   'prefill_all_time_end_date_dy',     DEFAULT0, $
   'prefill_all_time_end_time',              '', $
   'prefill_all_time_end_time_hr',     DEFAULT0, $
   'prefill_all_time_end_time_mn',     DEFAULT0, $
   'prefill_all_time_end_time_sc',     DEFAULT0, $
   'prefill_all_time_end_dd',          DEFAULT1, $

   'prefill_all_smp_flush',    DEFAULT1, $
   'prefill_all_man_flush',    DEFAULT1, $
   'prefill_all_vol',          DEFAULT1, $
   'prefill_all_press',        DEFAULT1, $
   'prefill_all_flag_str',           '', $

   'fill_smp_flush',       DEFAULT1, $
   'fill_man_flush',       DEFAULT1, $
   'fill_vol',             DEFAULT1, $
   'fill_press',           DEFAULT1, $

   'flag_str',                   '', $

   'amb_temp',             DEFAULT1, $
   'amb_press',            DEFAULT1, $
   'amb_rh',               DEFAULT1, $
    
   'gps_alt',              DEFAULT1, $
   'gps_lat',              DEFAULT1, $
   'gps_lon',              DEFAULT1, $
   'gps_fix',              DEFAULT0, $
   'gps_prec',             DEFAULT1, $
   'gps_date',                   '', $
   'gps_date_yr',          DEFAULT0, $
   'gps_date_mo',          DEFAULT0, $
   'gps_date_dy',          DEFAULT0, $
   'gps_time',                   '', $
   'gps_time_hr',          DEFAULT0, $
   'gps_time_mn',          DEFAULT0, $
   'gps_time_sc',          DEFAULT0, $
   'gps_dd',               DEFAULT1, $

   'db_evn',               DEFAULT2, $
   'db_alt',               DEFAULT1, $
   'db_altflag',                 '', $
   'db_lat',               DEFAULT1, $
   'db_lon',               DEFAULT1, $
   'db_me',                      '', $
   'db_id',                      '', $
   'db_code',                    '', $
   'db_date',                    '', $
   'db_date_yr',           DEFAULT0, $
   'db_date_mo',           DEFAULT0, $
   'db_date_dy',           DEFAULT0, $
   'db_time',                    '', $
   'db_time_hr',           DEFAULT0, $
   'db_time_mn',           DEFAULT0, $
   'db_time_sc',           DEFAULT0, $
   'db_dd',                DEFAULT1, $
   'db_temp',              DEFAULT1, $
   'db_press',             DEFAULT1, $
   'db_rh',                DEFAULT1, $

   'iap_alt',              DEFAULT1, $
   'iap_lat',              DEFAULT1, $
   'iap_lon',              DEFAULT1, $
   'iap_date',                   '', $
   'iap_date_yr',          DEFAULT0, $
   'iap_date_mo',          DEFAULT0, $
   'iap_date_dy',          DEFAULT0, $
   'iap_time',                   '', $
   'iap_time_hr',          DEFAULT0, $
   'iap_time_mn',          DEFAULT0, $
   'iap_time_sc',          DEFAULT0, $
   'iap_dd',               DEFAULT1)

   tags = TAG_NAMES(s1)
   ;
   ;*****************************************
   ; Run Perl script
   ;*****************************************
   ;
   CCG_MESSAGE, "Reading " + file + " ..."
   SPAWN, perl + " -f" + file, data
   CCG_MESSAGE, "Done Reading " + file + "."
   ;
   ;*****************************************
   ; Parse Sample information
   ;*****************************************
   ;
   samplelines = data[WHERE(STRPOS(data, "sample") EQ 0)]
   nsamplelines = N_ELEMENTS( samplelines )
   
   ; Determine unique sample lines

   a = [0]
   FOR i=0, nsamplelines-1 DO BEGIN
      
      tmp = STRSPLIT(samplelines[i], "|", /EXTRACT)
      a = [a, FIX(tmp[1])]

   ENDFOR
   
   res.nsamples = N_ELEMENTS( UNIQ( a[1:*] ) )
   ;
   ; Dimension sample data array
   ;
   s2 = REPLICATE(s1, res.nsamples)
   s2.id = INDGEN( res.nsamples ) + 1
   ;
   ;*****************************************
   ; Parse Unit information
   ;*****************************************
   ;
   unit = data[WHERE(STRPOS(data, "unit") EQ 0)]


   FOR i = 0, N_ELEMENTS(unit) - 1 DO BEGIN

      tmp = STRSPLIT(unit[i], "|", /EXTRACT)

      CASE tmp[1] OF 
      'firmware':        res.firmware = tmp[2]
      'serial_number':   res.id = tmp[2]
      'site_code':       res.code = STRUPCASE(tmp[2])
      'id':              res.id = tmp[2]
      'sample':          res = CREATE_STRUCT(res, tmp[1], samplelines)
      ELSE:              res = CREATE_STRUCT(res, tmp[1], tmp[2])
           ENDCASE
   ENDFOR
   ;
   ;*****************************************
   ; Index into s2
   ;*****************************************
   ;
   idx = 0

   FOR i = 0, nsamplelines - 1 DO BEGIN
      
      tmp = STRSPLIT(samplelines[i], "|", /EXTRACT)

      IF N_ELEMENTS(tmp) NE 4 THEN CONTINUE

      id = FIX(tmp[1])
      tag = STRUPCASE(tmp[2])

      ; Remove date from db_yyyy-mm-dd_<> tag.

      IF (STREGEX(tag, '^DB', /BOOLEAN)) THEN BEGIN

         z = STRSPLIT(tag, "_", /EXTRACT)
         tag = STRJOIN( ["DB", z[2:N_ELEMENTS(z)-1] ], "_" )

      ENDIF

      value = (tmp[3] EQ "--") ? -888 : tmp[3]
      ;
      ; Determine index into s2
      ;
      j = (i EQ 0) ? idx : WHERE(s2.id EQ id)
      ii = (j[0] NE -1 ) ? j[0] : ++ idx

      s2[ii].id = id

      IF STRPOS(tag, "TIME") EQ -1 AND STRPOS(tag, "DATE") EQ -1 THEN BEGIN
         ;
         ; Deal with all info except date/time
         ;
         n = WHERE(tags EQ tag)

         s2[ii].(n) = (STRMATCH(value, '[-.0123456789]') EQ 0) ? value : DOUBLE(value)
         
      ENDIF ELSE BEGIN
         ;
         ; Deal with date/time info
         ;
         n = WHERE(tags EQ tag)

         IF (STREGEX(tag, 'DATE$', /BOOLEAN)) THEN BEGIN
            value = (FLOAT(value) LT 0) ? '9999-12-31' : value

            tmp = STRSPLIT(value, '-', /EXTRACT)
            yr = FIX(tmp[0])
            s2[ii].(WHERE(tags EQ tag + "_YR")) = yr
            mo = FIX(tmp[1])
            s2[ii].(WHERE(tags EQ tag + "_MO")) = mo
            dy = FIX(tmp[2])
            s2[ii].(WHERE(tags EQ tag + "_DY")) = dy
         ENDIF

         IF (STREGEX(tag, 'TIME$', /BOOLEAN)) THEN BEGIN
            value = (FLOAT(value) LT 0) ? '12:34:56' : value

            tmp = STRSPLIT(value, ':', /EXTRACT)
            hr = FIX(tmp[0])
            s2[ii].(WHERE(tags EQ tag + "_HR")) = hr
            mn = FIX(tmp[1])
            s2[ii].(WHERE(tags EQ tag + "_MN")) = mn
            sc = FIX(tmp[2])
            s2[ii].(WHERE(tags EQ tag + "_SC")) = sc
         ENDIF

         IF (STREGEX(tag, 'DD$', /BOOLEAN)) THEN BEGIN
            value = (STRMATCH(value, '[-.0123456789]') EQ 0) ? value : DOUBLE(value)
         ENDIF

         IF (STREGEX(tag, 'EVN$', /BOOLEAN)) THEN BEGIN
            value = (STRMATCH(value, '[-.0123456789]') EQ 0) ? value : LONG(value)
         ENDIF

      ;STAT_HISTORY_BYID, id = list[i], saveas = saveas
         s2[ii].(n) = value
      ENDELSE
   ENDFOR
   ;
   ; Build result structure
   ;
   res = CREATE_STRUCT(res, 'data', s2)
END
