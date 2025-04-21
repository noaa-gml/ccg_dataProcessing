;+
; NAME:
;
;   CCG_INSITU   
;
; PURPOSE:
;
;    General procedure to read CCGG quasi-continuous high-frequency data
;    and averaged data.
;
; CATEGORY:
;
;   DB Query.
;
; CALLING SEQUENCE:
;
;   CCG_INSITU,parameter='co2',site='mlo',project='ccg_obs',average='month',/nodef, z
;   CCG_INSITU,parameter='ch4',site='brw',project='ccg_obs',average='hour',/nodef, data='date:2011', z
;   CCG_INSITU,site='chs',sp='ch4',data='date:2010',project='ccg_obs',z, /nodef,event='intake_ht:16,17'
;   CCG_INSITU,site='mlo',sp='co2',data='date:2010',project='ccg_obs',z, /nodef
;   CCG_INSITU,site='wgc',parameter='co',project='ccg_tower',data='date:2011',z
;   CCG_INSITU,site='chs',parameter='ch4',project='ccg_obs',/target, z
;
; INPUTS:
;
;  site:          Site code.
;
;                 (ex) site='brw'
;
; sp|parameter:   Parameter formula.
;
;                 (ex) sp='co', parameter='ch4'
;
; project:        Project abbreviation.  surface (ccg_obs) or tower (ccg_tower).
;
;                 (ex) project='ccg_obs'
;
; OPTIONAL INPUT PARAMETERS:
;
; average:        If specified, averaged values will be return.  Valid options
;                 are month, day and hour.  If not specified, high-frequency data
;                 will be returned.
;
;                 (ex) average='month'
;
; data:           Analysis constraint(s).
;                 Specify the DATA (e.g., measurement or analysis) constraints
;                 The format of this argument is <attribute name>:<min>,<max>
;                 where attribute name may include value, unc, flag, inst, date, time, ...
;                 Multiple bin conditions delimited by the tilda (~) may be
;                 specified. This procedure will pass this argument thru to
;                 the Perl script.
;
;                 (ex) data='date:2000,2003'
;                 (ex) data='inst:H4'
;                 (ex) data='flag:..%'
;                 (ex) data='date:2000-02-01,2000-11-03~inst:H4'
;
;                 PLEASE NOTE:  data and event constraints are equivalent.
;                 Both are supported to provide some consistency with the
;                 discrete sample reader, CCG_FLASK.PRO.
;
; event:          Sample Collection constraint(s).
;                 Specify the EVENT (e.g., sample collection) constraints
;                 The format of this argument is <attribute name>:<min>,<max>
;                 where attribute name may include date, intake_ht, ...
;                 Multiple bin conditions delimited by the tilda (~) may be
;                 specified. This procedure will pass this argument thru to
;                 the Perl script.
;
;                 (ex) event='date:2000,2003'
;                 (ex) event='intake:30'
;                 (ex) event='date:2000-02-01,2000-11-03~intake_ht:29,31'
;
;                 PLEASE NOTE:  data and event constraints are equivalent.
;                 Both are supported to provide some consistency with the
;                 discrete sample reader, CCG_FLASK.PRO.
;
; nodef:          If non-zero, DEFAULT (-999.99) values will be excluded from the 
;                 returned structure vector.
;
; target:         If non-zero, data from <site>_<parameter>_target tables will be returned.
;
; OUTPUTS:
;
; Data Object:    Type: anonymous structure array.  The structure tags depend
;                 on user input.
;
;                 project=ccg_obs and average=<month|day|hour>
;
;                 arr[].site      -> site code
;                 arr[].dd        -> UTC date/time in decimal format
;                 arr[].yr        -> sample year
;                 arr[].mo        -> sample month
;                 arr[].dy        -> sample day (DAY and HOUR average only)
;                 arr[].hr        -> sample hour (HOUR average only)
;                 arr[].value     -> mole fraction
;                 arr[].unc       -> estimated uncertainty (method may vary by project)
;                 arr[].n         -> number of values used in average
;                 arr[].flag      -> selection flag
;                 arr[].intake_ht -> intake height in magl (HOUR average only)
;                 arr[].inst      -> detector Identification code (HOUR average only)
;
;                 project=ccg_obs and NO AVERAGE
;
;                 arr[].site      -> site code
;                 arr[].dd        -> UTC date/time in decimal format
;                 arr[].yr        -> sample year
;                 arr[].mo        -> sample month
;                 arr[].dy        -> sample day
;                 arr[].hr        -> sample hour
;                 arr[].mn        -> sample minutes
;                 arr[].sc        -> sample seconds
;                 arr[].value     -> mole fraction
;                 arr[].unc       -> estimated uncertainty (method may vary by project)
;                 arr[].n         -> number of values used in average
;                 arr[].flag      -> selection flag
;                 arr[].intake_ht -> intake height in magl
;                 arr[].inst      -> detector Identification code
;                 arr[].port      -> sample port number (GC only)
;
;                 project=ccg_tower and NO AVERAGE
;
;                 arr[].site          -> site code
;                 arr[].dd            -> UTC date/time in decimal format
;                 arr[].yr            -> sample year
;                 arr[].mo            -> sample month
;                 arr[].dy            -> sample day
;                 arr[].hr            -> sample hour
;                 arr[].mn            -> sample minutes
;                 arr[].sc            -> sample seconds
;                 arr[].value         -> mole fraction
;                 arr[].meas_unc      -> measurement uncertainty (method may vary by project)
;                 arr[].random_unc    -> estimated random uncertainty (method may vary by project)
;                 arr[].std_dev       -> standard deviation
;                 arr[].scale_unc     -> estimated scale uncertainty (method may vary by project)
;                 arr[].n             -> number of values used in average
;                 arr[].flag          -> selection flag
;                 arr[].intake_ht     -> intake height in magl
;                 arr[].inst          -> detector Identification code
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
;      IDL> CCG_INSITU, project='ccg_obs', site='mlo', parameter='co2', average='day', /nodef, z
;
;      IDL> HELP, z,/str
;      ** Structure <8260b84>, 9 tags, length=52, data length=50, refs=1:
;      SITE            STRING    'MLO'
;      YR              INT           1974
;      MO              INT              1
;      DY              INT              1
;      VALUE           FLOAT          -999.990
;      UNC             FLOAT          -99.9900
;      N               LONG                 0
;      FLAG            STRING    '*..'
;      DD              DOUBLE           1974.0014
;
;      PLOT, z.dd, z.value
;      
; MODIFICATION HISTORY:
;
;   Written, KAM, February 2011
;-
@ccg_utils.pro

FUNCTION GET_OBS_AVERAGE, perl, average

   ; Define data structure
   ; Format is defined in Perl script

   CASE average OF 

      'hour': BEGIN

      ; hour result
      ; site year month day hour value unc n flag intake_ht inst
      ; BRW 2010 01 01 00   1902.270      2.696   4 ...       0.00    HP1-3

      obj = { site:'', yr:0, mo:6, dy:15, hr:12, value:0.0, unc:0.0, n:0L, flag:'', intake_ht:0.0, inst:'', dd:0D }
      format = '(A3,4I0,2F0,I0,1X,A3,F0,1X,A8,F0)'

      END
      'day': BEGIN

      ; day result
      ; site year month day value unc n flag
      ; BRW 2010 01 01   1898.336      9.877  24 ...

      obj = { site:'', yr:0, mo:6, dy:15, value:0.0, unc:0.0, n:0L, flag:'', dd:0D }
      format = '(A3,3I0,2F0,I0,1X,A3,F0)'

      END
      'month': BEGIN
      ; month result
      ; site year month value unc n flag
      ; BRW 2010 01   1910.167     18.459  30 ...

      obj = { site:'', yr:0, mo:6, value:0.0, unc:0.0, n:0L, flag:'', dd:0D }
      format = '(A3,2I0,2F0,I0,1X,A3,F0)'
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

FUNCTION GET_TOWER_INSITU, perl

   ; Define data structure
   ; Format is defined in Perl script

   ; site yr mo dy hr min sec intake_ht value unc analunc n flag inst
   ; WGC 2010 01 01 00 29 55 30.00 403.2790 0.12 -999.99 1 ... L4

   obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, intake_ht:0.0, $
           value:0.0, meas_unc:0.0, random_unc:0.0, std_dev:0.0, scale_unc:0.0, n:0L, flag:'', inst:'', dd:0D }
;   format = '(A3,6I0,6F0,I0,1X,A3,2X,A2,F0)'
   format = '(A3,6I0,6F0,I0,1X,A3,5X,A3,F0)'

   ; Extract data

   SPAWN, perl, res

   print, perl
   IF res[0] EQ "" THEN RETURN, 0

   data_obj = [obj]

   nres = N_ELEMENTS( res )
   IF nres LT 1 THEN RETURN, 0

   data_obj = REPLICATE( obj, nres )

   READS, FORMAT=format, res, data_obj

   RETURN, data_obj

END

FUNCTION GET_OBS_INSITU, perl, site, parameter, target

   ; Define data structure
   ; Format is defined in Perl script

   CASE 1 OF 

      target EQ 1: BEGIN

         ; result: target
         ; site year month day hr min sec value unc n flag inst type
         ; CHS 2010 01 01 14 00 00  1830.9100       0.37 9 ...    LGR-1        TGT

         obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, value:0.0, unc:0.0, n:0L, flag:'', $
                 inst:'', type:'', dd:0D }
         format = '(A3,6I0,2F0,I0,1X,A3,1X,A8,1X,A10,F0)'

      END 

      site EQ 'chs': BEGIN

         ; result: site=chs
         ; site year month day hr min sec value unc analunc n flag intake_ht inst
         ; CHS 2010 01 01 00 00 00  1908.8000       0.50    -999.99   9 ..>      16.20    LGR-1

         obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, intake_ht:0.0, $
                 value:0.0, unc:0.0, n:0L, flag:'', inst:'', dd:0D }
         format = '(A3,6I0,3F0,I0,1X,A3,1X,A8,F0)'

      END

      parameter EQ 'ch4' OR parameter EQ 'co': BEGIn

         ; result: site!=chs and parameter = ch4|co
         ; site year month day hr min sec value unc n flag intake_ht inst port
         ; MLO 2010 01 01 00 09 00  1810.4100       0.00   1 ...       0.00    HP1-2        5

         obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, intake_ht:0.0, $
                 value:0.0, unc:0.0, n:0L, flag:'', inst:'', port:0, dd:0D }
         format = '(A3,6I0,3F0,I0,1X,A3,1X,A8,I0,F0)'

      END

      parameter EQ 'co2':BEGIN

         ; result: site!=chs and parameter = co2
         ; site year month day hr min sec value unc n flag intake_ht inst
         ; MLO 2010 01 01 00 00 00   387.5800       0.05 234 ...      40.00    LI1-4

         obj = { site:'', yr:0, mo:6, dy:15, hr:12, mn:30, sc:30, intake_ht:0.0, $
                 value:0.0, unc:0.0, n:0L, flag:'', inst:'', dd:0D }
         format = '(A3,6I0,3F0,I0,1X,A3,1X,A8,F0)'

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
 
PRO   CCG_INSITU, $
      project=project,$
      site=site, $
      average=average,$
      parameter=parameter,$
      sp=sp, $
      event=event, $
      data=data, $
      nodef=nodef, $
      target=target, $
      help=help, $
      data_obj
   ;
   ;-----------------------------------------------check input information 
   ;
   IF KEYWORD_SET( help ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( project ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( site ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( sp ) AND NOT KEYWORD_SET( parameter ) THEN CCG_SHOWDOC
   IF KEYWORD_SET( sp ) AND KEYWORD_SET( parameter ) THEN CCG_SHOWDOC
    
   ; Initialization
  
   perldir = "/ccg/src/db/"
   data_obj = 0
   target = KEYWORD_SET( target ) ? 1 : 0

   ; sp and parameter are equivalent
 
   parameter = KEYWORD_SET( sp ) ? sp : parameter

   parameter = STRLOWCASE( parameter )
   site = STRLOWCASE( site )

   ; Build argument list

   args = ''

   args += ' -stdout -dd'
   args += ' -site=' + site
   args += ' -parameter=' + parameter
   args += ' -project=' + project
   IF KEYWORD_SET( data ) THEN args += ' -data=' + data
   IF KEYWORD_SET( event ) THEN args += ' -event=' + event
   IF KEYWORD_SET( nodef ) THEN args += ' -nodef'
   IF KEYWORD_SET( average ) THEN args += ' -average=' + STRLOWCASE( average )

   IF target EQ 1 THEN args += ' -target'

   ; Call appropriate DB extraction function

   IF KEYWORD_SET( average ) THEN BEGIN

      CASE project OF 

      'ccg_obs':     data_obj = GET_OBS_AVERAGE( perldir + 'ccg_insitu.pl' + args, average )
      'ccg_surface': BEGIN
                     CCG_MESSAGE, 'Averaged surface data do not yet exist in the CCGG DB.'
                     RETURN
                     END
      'ccg_tower':   BEGIN
                     CCG_MESSAGE, 'Averaged tower data do not yet exist in the CCGG DB.'
                     RETURN
                     END

      ENDCASE

   ENDIF ELSE BEGIN

      CASE project OF 

      'ccg_obs':     data_obj = GET_OBS_INSITU( perldir + 'ccg_insitu.pl' + args, site, parameter, target )
      'ccg_surface': data_obj = GET_OBS_INSITU( perldir + 'ccg_insitu.pl' + args, site, parameter, target )
      'ccg_tower':   data_obj = GET_TOWER_INSITU( perldir + 'ccg_insitu.pl' + args )

      ENDCASE

   ENDELSE

END
