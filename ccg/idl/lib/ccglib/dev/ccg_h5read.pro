;+
; NAME:
;	CCG_H5READ
;
; PURPOSE:
;	Read H5 files and return data in structure format.
;
; CATEGORY:
;	File Manipulation
;
; CALLING SEQUEH5E:
;	CCG_H5READ, file=file, z
;	CCG_H5READ, file=file, /quiet
;	CCG_H5READ, file=file, /quiet, z
;
; INPUTS:
;	file:	Input file (H5)
;	
; OPTIONAL INPUT PARAMETERS:
;  quiet:   If keyword set to 1, file description will be suppressed
;  silent:  If keyword set to 1, file description will be suppressed
;
; OUTPUTS:
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
;	(ex) ccg_h5read, file='/model/carbontracker/2007b/ct07b2f/output/20061230/stations.h5', z
;
; MODIFICATION HISTORY:
;	Written, KAM, February 2009.
;-

@ccg_utils.pro

PRO CCG_H5READ, file=file, quiet=quiet, silent=silent, desc=desc, help=help, h5

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(file) THEN CCG_SHOWDOC

   quiet = KEYWORD_SET(quiet) OR KEYWORD_SET(silent) ? 1 : 0
   h5 = N_PARAMS() NE 0 ? 1 : 0
   desc = [""]

   out = 0

   IF ( NOT H5F_IS_HDF5(file) ) THEN CCG_FATALERR, '"' + file + '" is not a valid HDF5 file.'

   h5 = H5F_OPEN( file )

z = H5_PARSE( file, /READ_DATA )
stop

   ;###############################
   ; Dimensions
   ;###############################

   dz=0 
   desc = [desc, ""]

   n = 'datasets'
   ;v = datasets

   dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, n, v) : CREATE_STRUCT(n, v)
   desc = [ desc, "dimensions:" + n + "=" + ToString(v) ]

   n = 'attributes'
   ;v = attributes

   dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, n, v) : CREATE_STRUCT(n, v)
   desc = [ desc, "dimensions:" + n + "=" + ToString(v) ]

   IF h5 EQ 1 THEN out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, 'dim', dz) : CREATE_STRUCT('dim', dz)

   ;###############################
   ; Attributes
   ;###############################


   dz=0 
   desc = [desc, ""]

   FOR i=0, attributes-1 DO BEGIN

      H5_SD_ATTRINFO, fid, i, name=name, data=data

      name = CleanName(name)

      dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, name, data) : CREATE_STRUCT(name, data)

      desc = [ desc, "attribute:" + name + " = " + STRJOIN( ToString(data), ' ' ) ]

   ENDFOR

   IF h5 EQ 1 THEN out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, 'attr', dz) : CREATE_STRUCT('attr', dz)

   ;###############################
   ; Global Attributes
   ;###############################

   desc = [desc, ""]

   FOR i=0, datasets-1 DO BEGIN

      dz=0
      sds = H5_SD_SELECT(fid, i)
      H5_SD_GETINFO, sds, name=name
      H5_SD_GETDATA, sds, data

      IF h5 EQ 1 THEN BEGIN

         dz = SIZE(dz, /TYPE) EQ 8 ? CREATE_STRUCT(dz, 'data', data) : CREATE_STRUCT('data', data)
          
         ; does name already exist?

         j = WHERE(STREGEX(TAG_NAMES(out), '^' + name, /FOLD_CASE, /BOOLEAN) EQ 1)
         IF j[0] NE -1 THEN name = name + "_" + STRING(FORMAT='(I4.4)', N_ELEMENTS(j))

         out = SIZE(out, /TYPE) EQ 8 ? CREATE_STRUCT(out, name, dz) : CREATE_STRUCT(name, dz)

      ENDIF

      HELP, data, output=strout
      desc = [ desc, "global:" + name + " = " + strout ]

   ENDFOR

   H5_SD_END, fid

   h5 = out

   IF quiet EQ 1 THEN RETURN

   FOR i=1, N_ELEMENTS(desc)-1 DO PRINT, desc[i]

END
