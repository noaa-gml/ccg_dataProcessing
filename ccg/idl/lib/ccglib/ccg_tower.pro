;+
; NAME:
;   CCG_TOWER
;
; PURPOSE:
;    Extract quasi-continuous tower data from RDBMS
;   
;   WARNING:  Use caution when calling this procedure.
;
;   For example...
;
;       IDL>  ccg_tower, sp = 'all', arr 
;
;   will extract quasi-continuous data from all tower sites
;   for all parameters from the RDBMS.  This takes time!
;
; CATEGORY:
;   Data Retrieval
;
; CALLING SEQUENCE:
;   CCG_TOWER, site='sct',sp='co2',arr
;   CCG_TOWER, site='wgc', sp='co2', event='intake_ht:30', z
;   CCG_TOWER, site='lef', sp='co2', data='date:2008-1,2008-3', z
;   CCG_TOWER, site='lef', sp='co2', event='date:2008-1,2008-3~intake_ht:122', z
;
; INPUTS:
; site:       Site code.  May specify a single code or
;             a list of sites.
;             (ex) site='wgc'
;             (ex) site='wgc,sct'
;
; sp:         Parameter formula.  May specify a single sp or
;             a list of species.
;             (ex) sp='co'
;             (ex) sp='co2,co'
;
; OPTIONAL INPUT PARAMETERS:
; data:       Analysis constraint(s).
;             Specify the DATA (e.g., measurement or analysis) constraints
;             The format of this argument is <attribute name>:<min>,<max>
;             where attribute name may be value, unc, nonrandom_unc, random_unc,
;             std_dev, flag, inst, date, time, ...
;             Multiple bin conditions delimited by the tilda (~) may be
;             specified. This procedure will pass this argument thru to 
;             the Perl script.
;
;             (ex) data='date:2000,2003'
;             (ex) data='inst:H4'
;             (ex) data='flag:..%'
;             (ex) data='date:2000-02-01,2000-11-03~inst:H4'
;
;
; event:      Sample Collection constraint(s).
;             Specify the EVENT (e.g., sample collection) constraints
;             The format of this argument is <attribute name>:<min>,<max>
;             where attribute name may be date, alt, intake_ht, ...
;             Multiple bin conditions delimited by the tilda (~) may be
;             specified. This procedure will pass this argument thru to 
;             the Perl script.
;
;             (ex) event='date:2000,2003'
;             (ex) event='intake:30'
;             (ex) event='date:2000-02-01,2000-11-03~intake_ht:29,31'
;
;
; exclusion:  If keyword set, all data to be excluded will be removed
;             from the data structure.
;
; nomessages: If non-zero, messages will be suppressed.
;
; help:       If non-zero, the procedure documentation is displayed to STDOUT. 
;
; OUTPUTS:
;   data:     Returns an anonymous structure array.  Structure
;             tags depend on passed parameters.
;
;             data[].str           -> all parameters joined into a string constant
;             data[].code          -> 3-letter site code
;             data[].yr            -> UTC sample/analysis year
;             data[].mo            -> UTC sample/analysis month
;             data[].dy            -> UTC sample/analysis day
;             data[].hr            -> UTC sample/analysis hour 
;             data[].mn            -> UTC sample/analysis minute
;             data[].sc            -> UTC sample/analysis second
;             data[].dd            -> UTC date/time in decimal format
;             data[].intake_ht     -> meters above ground level
;             data[].value         -> data value (mole fraction)
;             data[].meas_unc      -> measurement uncertainty
;             data[].random_unc    -> random uncertainty estimate
;             data[].std_dev       -> standard deviation
;             data[].scale_unc     -> scale uncertainty
;             data[].flag          -> 3-character selection flag
;             data[].inst          -> n-character analysis instrument code
;
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
;   Data are returned in an anonymous structure array.  Users
;   can employ SQL-type IDL commands to manipulate data.
;
;      Example:
;         CCG_TOWER, sp='co2', site='wgc', data
;         .
;         .
;         j = WHERE( data.value GT 0 AND data.intake_ht EQ 30 )
;         PLOT, data[j].dd, data[j].value, psym=4
;
; MODIFICATION HISTORY:
;   Written, KAM, December 2010.
;-
;
;
; Get Utility functions
;
@ccg_utils.pro
;

PRO   CCG_TOWER, $

   site=site, $   
   sp=sp, $
   event=event, $
   data=data, $

   nomessages = nomessages, $
   help = help, $
   result
   ;
   ;check input information 
   ;
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF N_PARAMS() EQ 0 THEN CCG_FATALERR,"Return variable required (CCG_TOWER,/HELP)."
   IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC

   nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
    
   ;initialization
    
   result = 0
   dbdata = 0
   dbdir = '/projects/src/db/'
   perl = dbdir + 'ccg_tower.pl'
    
   ; Build argument list
    
   args = " -stdout"
   args += " -site=" + site
   args += " -parameter=" + sp

   ; *******************************************
   ; Constraints
   ; *******************************************
   
   IF KEYWORD_SET(event) THEN args += ' -event=' + event
   IF KEYWORD_SET(data) THEN args += ' -data=' + data

   ; Extract data from DB
     
   tmp = perl + args
   IF NOT nomessages THEN CCG_MESSAGE,'Extracting Data ...'
   SPAWN,tmp,dbdata
   IF NOT nomessages THEN CCG_MESSAGE,'Done Extracting Data ...'

   IF dbdata[0] EQ '' THEN RETURN

   ; site_code year month day hour minute seconds intake_height analysis_value measurement_uncertainty random_uncertainty standard_deviation scale_uncertainty n_samples analysis_flag analysis_instrument
   ; AMT 2010 01 01 00 14 55     107.00    393.616      0.023      0.015      0.060      0.070   1 ...  L4


   struct = { str:'', site:'', yr:0, mo:0, dy:0, hr:0, mn:0, sc:0, dd:0D, $
              intake_ht:0.0, value:0.0, meas_unc:0.0, random_unc:0.0, $
              std_dev:0.0, scale_unc:0.0, n:0, flag:'', inst:'' }

   ndbdata = N_ELEMENTS( dbdata )

   result = REPLICATE( struct, ndbdata )

   FOR i=0L, ndbdata-1 DO BEGIN

      tmp = STRSPLIT( dbdata[i], /EXTRACT)

      result[i].str = dbdata[i]
      result[i].site = tmp[0]
      result[i].yr = FIX( tmp[1] )
      result[i].mo = FIX( tmp[2] )
      result[i].dy = FIX( tmp[3] )
      result[i].hr = FIX( tmp[4] )
      result[i].mn = FIX( tmp[5] )
      result[i].sc = FIX( tmp[6] )

      CCG_DATE2DEC, yr=result[i].yr, mo=result[i].mo, dy=result[i].dy, $
                    hr=result[i].hr, mn=result[i].mn, sc=result[i].sc, dec=dec

      result[i].dd = dec
      result[i].intake_ht = FLOAT( tmp[7] )
      result[i].value = FLOAT( tmp[8] )
      result[i].meas_unc = FLOAT( tmp[9] )
      result[i].random_unc = FLOAT( tmp[10] )
      result[i].std_dev = FLOAT( tmp[11] )
      result[i].scale_unc = FLOAT( tmp[12] )
      result[i].n = LONG( tmp[13] )
      result[i].flag = tmp[14]
      result[i].inst = tmp[15]

   ENDFOR

END
