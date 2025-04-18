;+
; NAME:
;        CCG_SITEINFO
;
; PURPOSE:
;        Returns an IDL structure containing a brief site 
;        and program description for the specified site(s).
;        Data is extracted from GMD and CCGG DBs.
;
;        See OUTPUTS for a complete description.
;
; CATEGORY:
;
; CALLING SEQUENCE:
;        CCG_SITEINFO,site='brw', res
;        CCG_SITEINFO,site='brw,lef,nwr', res
;        CCG_SITEINFO,site='brw_01D0,brw_01C0,brw_04D0', res
;
; INPUTS:
;
; OPTIONAL INPUT PARAMETERS:
;
;   site:               Site code.  May specify a single code or a list of sites.
;                       If omitted, all sites in the GMD site table are returned
;
;                       (ex) site='brw'
;                       (ex) site='alt_01D0,brw_01D0,cba'
;
; OUTPUTS:
;   desc:               This array is a structure:
;
;                       desc[].err           -> error status  
;                                                1 if an error is detected
;                                                0 if no error is detected
;                       desc[].str           -> "site" string passed 
;                       desc[].site_code     -> site code 
;                       desc[].site_name     -> site name
;                       desc[].site_country  -> country in which site resides
;                       desc[].strategy_name -> sampling strategy
;                                                e.g., discrete, quasi-continuous
;                       desc[].strategy_code -> sampling strategy code
;                       desc[].platform_name -> sampling platform name, e.g., fixed, ship, aircraft
;                       desc[].platform_num  -> sampling platform number
;                       desc[].lab_name      -> name of measurement laboratory
;                       desc[].lab_num       -> laboratory identification number
;                                                e.g., 00, 01, 23
;                       desc[].lab_abbr      -> laboratory acronym
;                       desc[].lab_country   -> laboratory country
;                       desc[].lab_logo      -> file found in /projects/web/logos/
;                       desc[].agency_name   -> cooperating agency name
;                       desc[].agency_abbr   -> cooperating agency acronym
;                       desc[].lat           -> site position degree latitude
;                       desc[].sinlat        -> site position sine of latitude
;                       desc[].lon           -> site position degree longitude
;                       desc[].elev          -> site position elevation (masl)
;                       desc[].intake_ht     -> sample intake height (magl, meters above ground level)
;                       desc[].position      -> formatted lat/lon string (e.g., [14!eoN, 124!eoW])
;                       desc[].lst2utc       -> hour conversion from LST to UTC
;
;        NOTE: The returned structure name is determined by user.
;
;        Type 'HELP, <structure name>, /str' at IDL prompt for
;        a description of the structure.
;
; COMMON BLOCKS:
;        None.
;
; SIDE EFFECTS:
;        None.
;
; RESTRICTIONS:
;        None.
;
; PROCEDURE:
;
;        Example:
;                IDL> CCG_SITEINFO,site='brw',arr
;                IDL> PRINT,arr.lat,arr.sinlat
;                IDL> 71.3200     0.947322
;
;                IDL> CCG_SITEINFO,site=['asc','ryo_19'],r
;                IDL> PRINT,r.agency
;                IDL> DOD/U.S.A.F. and Pan American World Airways
;                IDL> Japan Meteorological Agency (JMA)
;
;                IDL> CCG_SITEINFO,site=sitevector,result
;                        where sitevector is a string vector containing 
;                        site codes with or without laboratory extensions.
;
; MODIFICATION HISTORY:
;        Written, KAM, April 1997.
;        Modified, KAM, May 2000.
;        Modified, KAM, June 2007.
;-
;

@ccg_utils.pro

PRO   CCG_SITEINFO, $
      site=site, $ 
      addl_siteinfo_file=addl_siteinfo_file, $
      help=help, $
      info

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( addl_siteinfo_file ) THEN addl_siteinfo_file = ""

   DEFAULT = (-999.999)
   UNK = 'Unknown'
   dbdir = '/projects/src/db/'
   perl = dbdir + 'ccg_siteinfo.pl'
   info = 0

   ; Call Perl script

   args = " -site=" + site
   IF addl_siteinfo_file NE "" THEN args += " -addl_siteinfo_file=" + addl_siteinfo_file
   SPAWN, perl + args, db

   IF db[0] EQ '' THEN RETURN

   n = N_ELEMENTS(db)

   info = REPLICATE({ err:                 0, $
                      str:                 UNK, $
                      site_num:            DEFAULT, $
                      site_code:           UNK, $
                      site_name:           UNK, $
                      site_country:        UNK, $
                      lat:                 DEFAULT, $
                      sinlat:              DEFAULT, $
                      lon:                 DEFAULT, $
                      elev:                DEFAULT, $
                      position:            UNK, $
                      lst2utc:             DEFAULT, $

                      strategy_name:       UNK, $
                      strategy_code:       UNK, $
                      platform_name:       UNK, $
                      platform_num:        DEFAULT, $
                      lab_num:             DEFAULT, $
                      lab_name:            UNK, $
                      lab_abbr:            UNK, $
                      lab_country:         UNK, $
                      lab_logo:            UNK, $
                      agency_name:         UNK, $
                      agency_abbr:         UNK, $
                      intake_ht:           DEFAULT }, $
                      n)

   FOR i = 0, n - 1 DO BEGIN

      tmp = STRSPLIT(db[i], "|", /EXTRACT, /PRESERVE_NULL)

      ; site_num, site_code, site_name, site_country, site_lat, site_lon, site_elev, site_lst2utc

      ; If the GLOBALVIEW standard is used, the following additional fields are provided.

      ; lab_num, lab_name, lab_country, lab_abbr, lab_logo
      ; sampling_strategy_abbr, sampling_strategy_name
      ; platform_num, platform_name.
      
      info[i].str = db[i] 
      info[i].site_num = FIX(tmp[0])
      info[i].site_code = tmp[1]
      info[i].site_name = tmp[2]
      info[i].site_country = tmp[3]
      info[i].lat = FLOAT(tmp[4])
      info[i].lon = FLOAT(tmp[5])
      info[i].elev = FLOAT(tmp[6])
      info[i].lst2utc = FLOAT(tmp[7])

      info[i].sinlat = SIN(info[i].lat * !PI / 180.)
       
      ;prepare formatted position string
       
      h1 = (info[i].lat GE 0) ? 'N' : 'S'
      h2 = (info[i].lon GE 0) ? 'E' : 'W'

      info[i].position = '[' + ToString(FIX(ABS(CCG_ROUND(info[i].lat,0)))) + '!eo!n' + h1 + ', ' + $
      ToString(FIX(ABS(CCG_ROUND(info[i].lon,0)))) + '!eo!n' + h2 + ']'

      ; case if site information is coming from an additional site information text file.
      IF N_ELEMENTS(tmp) EQ 9 THEN info[i].intake_ht = FLOAT(tmp[8])

      ; case if site information is coming from DB and GV-style information is provided.
      IF N_ELEMENTS(tmp) GT 9 THEN BEGIN

         info[i].lab_num = FIX(tmp[8])
         info[i].lab_name = tmp[9]
         info[i].lab_country = tmp[10]
         info[i].lab_abbr = tmp[11]
         info[i].lab_logo = tmp[12]
         info[i].strategy_code = tmp[13]
         info[i].strategy_name = tmp[14]
         info[i].platform_num = FIX(tmp[15])
         info[i].platform_name = tmp[16]

         ; case if site information is coming from DB and a CCG project exists.
         IF N_ELEMENTS(tmp) GE 18 THEN BEGIN

            info[i].agency_name = tmp[17]
            info[i].agency_abbr = tmp[18]
            info[i].intake_ht = FLOAT(tmp[19])

         ENDIF

      ENDIF

   ENDFOR
END
