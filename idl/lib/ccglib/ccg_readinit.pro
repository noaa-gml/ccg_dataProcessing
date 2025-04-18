;+
; NAME:
;   CCG_READINIT
;
; PURPOSE:
;    Read a DATA EXTENSION initialization file.
;
;   These init files can be used in a variety of
;   applications.  Each init file is species-dependent
;   and contains a list of sites and their positions, 
;   and acceptable CCGVU curve fitting parameters as 
;   determined by each PI.  Also included are parameters
;   specific to the DATA EXTENSION procedure.
;
;   This procedure calls CCG_SITEINFO
;
; CATEGORY:
;   CCG.
;
; CALLING SEQUENCE:
;   CCG_READINIT,file='init.co2.flask.1997',/nomessages,arr
;   CCG_READINIT,file='/projects/dei/ext/co/results.flask.1997/init.co.flask.1997',a
;
; INPUTS:
;   Filename:     Expects a DATA EXTENSION-formatted initialization file.
;
; OPTIONAL INPUT PARAMETERS:
;   nomessages:   If non-zero, messages will be suppressed.
;
;   extonly:   If non-zero, only site records with 'ext' field set to 1 will be
;              returned.  Keep in mind that if 'ext' field is not included in the
;              initialization file, all site records will be returned.
;
; OUTPUTS:
;   r:           Returned result is a structure defined as follows:
;
;   r.sync1                 ->   Synchronization start date (decimal year).
;                                DATA EXTENSION only.
;   r.sync2                      Synchronization end date (decimal year).
;                                DATA EXTENSION only.
;   r.rlm                   ->   Measurement record minimum length criterium.
;                                DATA EXTENSION only.
;   r.fillgap               ->   Internal FILL gap criteria (weeks).  Interruptions 
;                                in MBL or non-MBL records that exceed 'gap' 
;                                weeks will be filled with interpolated values 
;                                derived from the data extension procedure.
;                                DATA EXTENSION only.
;   r.mblgap                ->   Internal MBL gap criteria (weeks).  Interruptions 
;                                in MBL records that exceed 'gap' weeks will be
;                                filled with interpolated S(t) values only for 
;                                the purpose of constructing the reference
;                                MBL matrix.
;                                DATA EXTENSION only.
;   r.init[].str            ->   Complete string of parameters by site.
;   r.init[].site           ->   Passed site descriptor.
;   r.init[].npoly          ->   # of poly terms to be used in 'ccgvu' fit.
;   r.init[].nharm          ->   #  of harm. terms to be used in 'ccgvu' fit.
;   r.init[].interval       ->   Interval (in days) used by 'ccgvu' routines.
;   r.init[].cutoff1        ->   Short-term cutoff used by 'ccgvu' routines.
;   r.init[].cutoff2        ->   Long-term cutoff used by 'ccgvu' routines.
;
;   r.init[].mbl            ->   Marine Boundary Layer specification. 
;                                1=yes, 0=no.
;
;   r.init[].ext            ->   Use when performing data extension.
;                                1=yes, 0=no. Default is 1
;
;   r.init[].ftp_event      ->   If included in source file.
;                                Include in FTP event data distribution.
;                                1=yes, 0=no. Default is 1
;
;   r.init[].ftp_month      ->   If included in source file.
;                                Include in FTP monthly mean distribution.
;                                1=yes, 0=no. Default is 1
;
;   r.init[].f_sigmafactor  ->   If included in source file.
;                                Sigmafactors used in ccg_filter.pro.
;                                (ex) 3 or [3,2.5] or [3,3] (default)
;   r.init[].f_npoly        ->   # of poly terms to be used in ccg_filter.pro.
;   r.init[].f_nharm        ->   #  of harm. terms to be used in ccg_filter.pro.
;   r.init[].f_interval     ->   Interval (in days) to be used in ccg_filter.pro.
;   r.init[].f_cutoff1      ->   Short-term cutoff to be used in ccg_filter.pro.
;   r.init[].f_cutoff2      ->   Long-term cutoff to be used in ccg_filter.pro.
;
;  **** CCG_SITEINFO RESULTS ****
;
;       r.desc[].str            -> "site" string passed
;       r.desc[].site_num       -> site number
;       r.desc[].site_code      -> site code
;       r.desc[].site_name      -> site name
;       r.desc[].site_country   -> site country
;       r.desc[].strategy_name  -> sampling strategy
;                                  e.g., flask, in situ
;       r.desc[].strategy_code  -> sampling strategy code
;       r.desc[].platform_name  -> sampling platform name
;                                  e.g., Single Fixed Position, Ship, Aircraft
;       r.desc[].platform_num   -> sampling platform number
;       r.desc[].lab_num        -> measurement laboratory number
;       r.desc[].lab_name       -> name of measurement laboratory
;       r.desc[].lab_country    -> country in which laboratory resides
;       r.desc[].lab_abbr       -> laboratory acronym
;       r.desc[].lab_logo       -> laboratory logo
;       r.desc[].agency_name    -> cooperating agency name
;       r.desc[].agency_abbr    -> cooperating agency acroynm
;
;       r.desc[].lat            -> site position degree latitude
;       r.desc[].sinlat         -> site position sine of latitude
;       r.desc[].lon            -> site position degree longitude
;       r.desc[].elev           -> site elevation (masl)
;       r.desc[].intake_ht      -> site intake height (magl)
;       r.desc[].position       -> IDL formatted position string
;       r.desc[].lst2utc        -> hour conversion from LST to UTC
;
;
;       NOTE:   The returned structure name is determined by user.
;
;               Type 'HELP, <structure name>, /str' at IDL prompt for
;               a description of the structure.
;
;   NOTE:   Elements in the structure arrays r.desc[] and r.sites[] are matched.
;
;
;   NOTE:   For a complete description of ccgvu curve fitting parameters, see
;         Thoning, K.W., P.P. Tans, and W.D. Komhyr,
;         Atmospheric carbon dioxide at Mauna Loa Observatory, 2,
;         Analysis of the NOAA/GMCC data, 1974-1985,
;         J. Geophys. Res., 94, 8549-8565, 1989.
; COMMON BLOCKS:
;   None.
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   Expects a DATA EXTENSION-formatted initialization file.
;
; PROCEDURE:
;      Example:
;         CCG_READINIT,file='.../init.co2.flask.1997',arr
;         .
;         .
;         .
;         FOR i=0,N_ELEMENTS(arr.init)-1 DO BEGIN
;            .
;            .
;            .
;            CCG_FLASKAVE,    file=file,sp=sp,xret,yret
;
;            CCG_CCGVU,    x=xret,y=yret,/even,$
;                  interval=arr.sites(i).interval,$
;                  npoly=arr.sites(i).npoly,$
;                  nharm=arr.sites(i).nharm,$
;                  cutoff1=arr.sites(i).cutoff1,$
;                  cutoff2=arr.sites(i).cutoff2,$
;            .
;            .
;            .
;         ENDFOR
;      
; MODIFICATION HISTORY:
;   Written, KAM, May 1997.
;   Modified, KAM, November 1997.
;   Modified, KAM, June 1999.
;   Modified, KAM, May 2000.
;   Modified, KAM, August 2010 to read ccg_siteinfo instead of ccg_sitedesc.
;   Modified, KAM, September 2012 to include additional fields (e.g., ext,ftp_event,ftp_month,sigmafactor).
;-
;
PRO  CCG_READINIT, $
     file=file, $
     nomessages=nomessages, $
     extonly=extonly, $
     addl_siteinfo_file=addl_siteinfo_file, $
     result, $
     help = help

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC

   IF NOT KEYWORD_SET(file) THEN CCG_FATALERR,$
      "Initialization file must be specified, e.g., file='init.co2.flask.1997'."

   nomessages = KEYWORD_SET(nomessages) ? 1 : 0
   extonly = KEYWORD_SET( extonly ) ? 1 : 0

   IF NOT KEYWORD_SET( addl_siteinfo_file ) THEN addl_siteinfo_file = ""
    
   ; Misc initialization
    
   DEFAULT = (-999.999)
   NUMHEADERS = 3
   UNK = 'unknown'
   result = 0

   ; Does file exist?

   IF FILE_TEST( file ) EQ 0 THEN BEGIN

      CCG_MESSAGE, file + " does not exist."
      RETURN

   ENDIF

   ; Read file

   CCG_SREAD, file=file, /nomessages, comment='#', lines

   ; Parse header information

   headers = lines[0:NUMHEADERS-1]

   tmp = STRSPLIT( headers[1], /EXTRACT )
   ntmp = N_ELEMENTS( tmp )
   sync1 = DOUBLE( tmp[0] )
   sync2 = DOUBLE( tmp[1] )
   IF ntmp GT 1 THEN rlm = FLOAT( tmp[2] )
   IF ntmp GT 2 THEN fillgap = FLOAT( tmp[3] )
   IF ntmp GT 3 THEN mblgap = FLOAT( tmp[4] )

   sitelist = lines[NUMHEADERS:*]

   nsitelist = N_ELEMENTS( sitelist )

   z = REPLICATE( {  ccg_readinit,$
              str:            UNK,$
              site:           UNK,$
              npoly:      DEFAULT,$
              nharm:      DEFAULT,$
              interval:   DEFAULT,$
              cutoff1:    DEFAULT,$
              cutoff2:    DEFAULT,$
              lat:        DEFAULT,$
              sinlat:     DEFAULT,$
              long:       DEFAULT,$
              mbl:        DEFAULT,$
              ext:              1,$
              ftp_event:        1,$
              ftp_month:        1,$
              f_npoly:      DEFAULT,$
              f_nharm:      DEFAULT,$
              f_interval:   DEFAULT,$
              f_cutoff1:    DEFAULT,$
              f_cutoff2:    DEFAULT,$
              f_sigmafactor:  [3.0,3.0] }, $
              nsitelist )

   ; What fields can we expect?

   fields_in_header = STRSPLIT( headers[2], /EXTRACT )

   FOR i=0, nsitelist-1 DO BEGIN
      
      fields = STRSPLIT( sitelist[i], /EXTRACT )

      z[i].str = sitelist[i]

      j = WHERE( STRMATCH( fields_in_header, "site", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].site = STRTRIM( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "poly", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].npoly = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "harm", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].nharm = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "int", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].interval = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "short", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].cutoff1 = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "long", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].cutoff2 = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "mbl", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].mbl = FIX( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "ext", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].ext = FIX( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "ftp_event", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].ftp_event = FIX( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "ftp_month", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].ftp_month = FIX( fields[j[0]] )

      ; Filter information

      j = WHERE( STRMATCH( fields_in_header, "f_poly", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].f_npoly = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "f_harm", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].f_nharm = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "f_int", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].f_interval = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "f_short", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].f_cutoff1 = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "f_long", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN z[i].f_cutoff2 = FLOAT( fields[j[0]] )

      j = WHERE( STRMATCH( fields_in_header, "f_sigmafactor", /FOLD_CASE ) EQ 1 )
      IF j[0] NE -1 THEN BEGIN

         zz = STRSPLIT( fields[j[0]], "[|,|]", /EXTRACT )
         z[i].f_sigmafactor = N_ELEMENTS( zz ) EQ 1 ? [ FLOAT( zz[0] ), FLOAT( zz[0] ) ] : [ FLOAT( zz[0] ), FLOAT( zz[1] ) ]
      
      ENDIF

   ENDFOR

   IF NOT nomessages THEN CCG_MESSAGE,'Done reading '+file+' ...'
    
   ; Get site description information
    
   CCG_SITEINFO, site=STRJOIN( z.site, ',' ), addl_siteinfo_file=addl_siteinfo_file, zz

   ; Is 'extonly' keyword set?

   IF extonly EQ 1 THEN BEGIN

      j = WHERE( z.ext EQ 1 )
      z2 = z[j]
      zz2 = zz[j]

   ENDIF ELSE BEGIN

      z2 = z
      zz2 = zz

   ENDELSE
   
   ; Create returning structure
    
   result = CREATE_STRUCT( 'sync1',sync1,$
                           'sync2',sync2,$
                           'rlm',rlm,$
                           'fillgap',fillgap,$
                           'mblgap',mblgap,$
                           'init',z2,$
                           'desc',zz2)

END
