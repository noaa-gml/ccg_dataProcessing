;+
; NAME:
;	CCG_NCREAD
;
; PURPOSE:
;	Read NetCDF files and return data in
;  structure format.
;
; CATEGORY:
;	File Manipulation
;
; CALLING SEQUENCE:
;	CCG_NCREAD, file=file, z
;	CCG_NCREAD, file=file, /quiet
;	CCG_NCREAD, file=file, /quiet, z
;
; INPUTS:
;	file:	Input file (NetCDF)
;	
; OPTIONAL INPUT PARAMETERS:
;	quiet:	If keyword set to 1, file description will be suppressed
;	silent:	If keyword set to 1, file description will be suppressed
;
; OPTIONAL OUTPUTS:
;          File content as a named variable structure
;  desc:   File description
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
;	(ex) ccg_ncread, file='/ftp/ccg/co2/carbontracker/molefractions/CT2007B_molefrac_nam1x1_2005-07.nc', z
;	(ex) ccg_ncread, file='/model/carbontracker/2007b/release_candidate/analysis/data_mr/ice_01d0_forecast.co2.nc', z
;
; MODIFICATION HISTORY:
;	Written, KAM, January 2007.
;-

@ccg_utils.pro

PRO CCG_NCREAD, file=file, quiet=quiet, silent=silent, desc=desc, help=help, nc

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(file) THEN CCG_SHOWDOC

   quiet = KEYWORD_SET(quiet) OR KEYWORD_SET(silent) ? 1 : 0
   nc = N_PARAMS() NE 0 ? 1 : 0
   desc = [""]

   out = 0

   fid = NCDF_OPEN( file, /NOWRITE )
   ncdf = NCDF_INQUIRE( fid )

   ;###############################
   ; Dimensions
   ;###############################

   dz=0 

   desc = [desc, ""]

   FOR i = 0, ncdf.ndims - 1 DO BEGIN

      NCDF_DIMINQ, fid, i, n, v

      n = CleanName(n)

      dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, n, v) : CREATE_STRUCT(n, v)
      desc = [desc, "dimensions:" + n + "=" + ToString(v)]

   ENDFOR

   IF nc EQ 1 THEN out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, 'dim', dz) : CREATE_STRUCT('dim', dz)

   ;###############################
   ; Variables
   ;###############################

   desc = [desc, ""]

   FOR i = 0, ncdf.nvars - 1 DO BEGIN

      sds = NCDF_VARINQ( fid, i )
      NCDF_VARGET, fid, i, data

      IF SIZE(data, /TYPE) EQ 1 THEN data = STRING(data)
      
      dz=0 
      FOR ii = 0, sds.natts - 1 DO BEGIN

         n = NCDF_ATTNAME( fid, i, ii )
         NCDF_ATTGET, fid, i, n, v

         n = CleanName(n)

         desc = [desc, "variables:" + sds.name + "." + n + "=" + STRING(v)]
         IF nc EQ 1 THEN dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, n, STRING(v)) : CREATE_STRUCT(n, STRING(v))

      ENDFOR

      IF nc EQ 1 THEN BEGIN

         dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, 'data', data) : CREATE_STRUCT('data', data)
         out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, sds.name, dz) : CREATE_STRUCT(sds.name, dz)

      ENDIF

   ENDFOR

   ;###############################
   ; Global Attributes
   ;###############################

   dz = 0
   desc = [desc, ""]

   FOR i = 0, ncdf.ngatts - 1 DO BEGIN

      n = NCDF_ATTNAME( fid, /GLOBAL, i )
      NCDF_ATTGET, fid, /GLOBAL, n, v
      type = NCDF_ATTINQ( fid, /GLOBAL, n )

      v = SIZE( type.datatype, /TYPE ) EQ 7 ? STRING( v ) : v

      n = CleanName(n)

      desc = [desc, "global:" + n + "=" + v]

      IF nc EQ 1 THEN dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, n, STRING(v)) : CREATE_STRUCT(n, STRING(v))

   ENDFOR

   IF nc EQ 1 THEN out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, 'global', dz) : CREATE_STRUCT('global', dz)

   NCDF_CLOSE, fid

   nc = out

   IF quiet EQ 1 THEN RETURN

   FOR i=1, N_ELEMENTS(desc)-1 DO PRINT, desc[i]

END
