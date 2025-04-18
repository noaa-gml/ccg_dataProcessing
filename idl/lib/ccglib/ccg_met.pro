;+
; NAME:
;
;   CCG_MET
;
; PURPOSE:
;
;    General procedure to read MET quasi-continuous high-frequency data.
;
; CATEGORY:
;
;   DB Query.
;
; CALLING SEQUENCE:
;
;   CCG_MET,site='chs',data='date:2010-01-01,2010-01-03',average='minute',z
;   CCG_MET,site='brw',event='date:2010-01-01,2010-01-03',average='hour',z
;
; INPUTS:
;
;  site:          Site code.
;
;                 (ex) site='brw'
;                 (ex) site='chs'
;
; OPTIONAL INPUT PARAMETERS:
;
; average:        Time-Average Resolution.  This may be either "minute" or
;                 "hour" (default). Note: Only minute data are currently available for
;                 site='chs' (Cherskii).
;
; data:           Analysis constraint(s).
;                 Specify the DATA (e.g., measurement or analysis) constraints
;                 The format of this argument is <attribute name>:<min>,<max>
;                 where attribute name may include value, unc, flag, inst, date, time, ...
;                 Multiple bin conditions delimited by the tilda (~) may be
;                 specified. This procedure will pass this argument thru to
;                 the Perl script.
;
;                 (ex) data='date:2000-01,2000-01'
;
;                 PLEASE NOTE:  data and event constraints are equivalent.
;                 Both are supported to provide some consistency with the
;                 CCG_INSITU.PRO and CCG_FLASK.PRO.
;
; event:          Sample Collection constraint(s).
;                 Specify the EVENT (e.g., sample collection) constraints
;                 The format of this argument is <attribute name>:<min>,<max>
;                 where attribute name may include date, intake_ht, ...
;                 Multiple bin conditions delimited by the tilda (~) may be
;                 specified. This procedure will pass this argument thru to
;                 the Perl script.
;
;                 (ex) event='date:2000-01,2000-01~wind_dir:20,110~wind_speed:2,1000'
;
;                 PLEASE NOTE:  data and event constraints are equivalent.
;                 Both are supported to provide some consistency with the
;                 CCG_INSITU.PRO and CCG_FLASK.PRO.
;
; OUTPUTS:
;
; Data Object:    Type: anonymous structure array.  The structure tags depend
;                 on user input.
;
;                 site=chs
;
;                 arr[].site      -> site code
;                 arr[].dd        -> UTC date/time in decimal format
;                 arr[].yr        -> sample year
;                 arr[].mo        -> sample month
;                 arr[].dy        -> sample day
;                 arr[].hr        -> sample hour
;                 arr[].mn        -> sample minute (only if average='minute')
;                 arr[].sc        -> sample second (only if average='minute')
;                 arr[].ws        -> wind speed (m/s)
;                 arr[].wd        -> wind direction (deg)
;                 arr[].press     -> barometric pressure (mbar)
;                 arr[].flag      -> 4-character flag
;
;                 site=[all others]
;
;                 arr[].site      -> site code
;                 arr[].dd        -> UTC date/time in decimal format
;                 arr[].yr        -> sample year
;                 arr[].mo        -> sample month
;                 arr[].dy        -> sample day
;                 arr[].hr        -> sample hour
;                 arr[].mn        -> sample minute (only if average='minute')
;                 arr[].sc        -> sample second (only if average='minute')
;                 arr[].ws_10m    -> wind speed at 10 magl (m/s)
;                 arr[].wd_10m    -> wind direction at 10 magl (deg)
;                 arr[].press     -> barometric pressure (mbar)
;                 arr[].rh        -> relative humidity (%)
;                 arr[].temp_2m   -> temperature at 2 magl (deg C)
;                 arr[].temp_10m  -> temperature at 10 magl (deg C)
;                 arr[].temp_top  -> temperature at 20 magl (deg C)
;                 arr[].precip    -> precipitation (mm)
;                 arr[].wind_steadiness -> wind steadiness factor
;
; COMMON BLOCKS:
;
;   None.
;
; SIDE EFFECTS:
;
;   None.
;
; RESTRICTIONS:
;
;   None.
;
; PROCEDURE:
;
;      (ex)
;      IDL> CCG_MET, site='chs', data='date:2010-01', z
;
;      IDL> help,z,/str
;      ** Structure <48a2ff8>, 12 tags, length=64, data length=64, refs=1:
;         SITE            STRING    'CHS'
;         YR              INT           2010
;         MO              INT              1
;         DY              INT              1
;         HR              INT              0
;         MN              INT              0
;         SC              INT              0
;         WS              FLOAT           3.00000
;         WD              FLOAT           166.230
;         PRESS           FLOAT           9999.00
;         FLAG            STRING    '0000'
;         DD              DOUBLE           2010.0000
;
;      (ex)
;      IDL> CCG_MET, site='mlo', data='date:2010-01', z
;
;      IDL> help,z,/str
;      ** Structure <48a9fa8>, 21 tags, length=104, data length=100, refs=1:
;         SITE            STRING    'MLO'
;         YR              INT           2010
;         MO              INT              2
;         DY              INT              1
;         HR              INT              0
;         MN              INT              0
;         SC              INT              0
;         WS_10M          FLOAT           2.20000
;         WD_10M          FLOAT           358.000
;         PRESS           FLOAT           675.300
;         RH              FLOAT           62.0000
;         TEMP_2M         FLOAT           6.70000
;         TEMP_10M        FLOAT           5.80000
;         TEMP_TOP        FLOAT           4.40000
;         PRECIP          FLOAT           0.00000
;         WIND_STEADINESS FLOAT           -9
;         DD              DOUBLE          2010.0849               
;
;      IDL> PLOT, z.dd, z.ws_10m
;      
; MODIFICATION HISTORY:
;
;   Written, KAM, February 2011
;   Modified to accommodate changes to tables in met db. 2012-10-25 (kam)
;   Modified to access hourly tables in met db. 2012-11-13 (kam)
;-
@ccg_utils.pro

FUNCTION GET_MET, perl, site, average

   ; Define data structure
   ; Format is defined in Perl script

   CASE 1 OF 

      site EQ 'chs': BEGIN

         IF STRLOWCASE( average ) EQ "hour" THEN CCG_FATALERR, "Only minute data are currently available for Cherskii."

         ; result: site=chs
         ; site year month day hr min sec wind_speed wind_dir bar_press flag
         ; CHS 2010 01 01 00 00 00      3.0   166.23 9999.0 0000

         obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, ws:0.0, wd:0.0, press:0.0, flag:'',dd:0D }
         format = '(A3,6I0,3F0,1X,A4,F0)'

      END

      ELSE: BEGIN

         ; result: site=brw
         ; minute

         ; site year month day hr min sec wind_speed_10m wind_dir_10m bar_press rh temp_2m
         ; temp_10m temp_top precip wind_steadiness flag

         ; BRW 2010 01 01 00 00 00      2.3       54   1024.6       79      -29    -25.9   -999.9      -99       -9

         ; result: site=brw
         ; hour

         ; site year month day hr wind_speed_10m wind_dir_10m bar_press rh temp_2m temp_10m temp_top precip wind_steadiness
         ; BRW 2003 02 01 00     3.12       40  1013.91       79   -28.91    -26.8   -999.9        0      100

         IF STRLOWCASE( average ) EQ "minute" THEN BEGIN

            obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, ws_10m:0.0, wd_10m:0.0, press:0.0, $
                    rh:0.0, temp_2m:0.0, temp_10m:0.0, temp_top:0.0, precip:0.0, wind_steadiness:0.0, dd:0D }
            format = '(A3,6I0,10F0)'

         ENDIF

         IF STRLOWCASE( average ) EQ "hour" THEN BEGIN

            obj = { site:'', yr:0, mo:6, dy:15, hr:12, ws_10m:0.0, wd_10m:0.0, press:0.0, $
                    rh:0.0, temp_2m:0.0, temp_10m:0.0, temp_top:0.0, precip:0.0, wind_steadiness:0.0, dd:0D }
            format = '(A3,4I0,10F0)'

         ENDIF


      END

   ENDCASE

   ; Extract data

   SPAWN, perl, res
   IF res[0] EQ "" THEN RETURN, 0

   data_obj = [obj]

   nres = N_ELEMENTS( res )
   IF nres LT 1 THEN RETURN, 0

   data_obj = REPLICATE( obj, nres )

   READS, FORMAT=format, res, data_obj

   RETURN, data_obj

END
 
PRO   CCG_MET, $
      site=site, $
      event=event, $
      average=average, $
      data=data, $
      help=help, $
      data_obj
   ;
   ;-----------------------------------------------check input information 
   ;
   IF KEYWORD_SET( help ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( site ) THEN CCG_SHOWDOC
    
   ; Initialization
  
   perldir = "/ccg/src/db/"
   data_obj = 0

   site = STRLOWCASE( site )
   average = KEYWORD_SET( average ) ? average : "hour"

   ; Build argument list

   args = ''

   args += ' -stdout -dd'
   args += ' -site=' + site
   args += ' -average=' + average
   IF KEYWORD_SET( data ) THEN args += ' -data=' + data
   IF KEYWORD_SET( event ) THEN args += ' -event=' + event

   ; Call appropriate DB extraction function

   data_obj = GET_MET( perldir + 'ccg_met.pl' + args, site, average )

END
