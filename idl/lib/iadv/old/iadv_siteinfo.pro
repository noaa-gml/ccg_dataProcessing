PRO IADV_SITEINFO, site=site,$
         proj_abbr=proj_abbr,$
         title=title,$
         position=position,$
         sample_ht=sample_ht,$
         lst2utc=lst2utc
;
;Return to caller if an error occurs
;
;ON_ERROR, 2
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(site) THEN CCG_FATALERR,"'site' code must be specified.  Exiting ..."
IF NOT KEYWORD_SET(proj_abbr) THEN CCG_FATALERR,"'proj_abbr' name must be specified.  Exiting ..."
;
; Get Project name
;
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
perlcode=dbdir+'ccg_query.pl'
sql='SELECT name FROM gmd.project WHERE abbr="'+proj_abbr+'"'
SPAWN, perlcode+" '"+sql+"'", proj_name
;
; Read MySQL CCG db
;
perlcode=dbdir+'ccg_siteinfo.pl'
SPAWN, perlcode+' -site='+site+' -project='+proj_abbr, res

IF NOT KEYWORD_SET(res[0]) THEN res[0] = '0|XXX|XXX|XXX|||||'
;IF ( res[0] EQ "" ) THEN CCG_FATALERR,"No site information found for site '"+site+"' and project '"+proj_abbr+"'. Exiting ..."

tmp=STRSPLIT(res[0],'|',/EXTRACT,/PRESERVE_NULL)

code=tmp[1]
title=(STRPOS(tmp[3],"N/A") EQ -1) ? tmp[2]+', '+tmp[3] : tmp[2]
lat=FLOAT(tmp[4])
lon=FLOAT(tmp[5])
intake=FLOAT(tmp[6])
elev=FLOAT(tmp[7])
lst2utc=FLOAT(tmp[8])

IF ( N_ELEMENTS(tmp) EQ 14 ) THEN BEGIN
   binby = tmp[11]
   bmin=FLOAT(tmp[12])
   bmax=FLOAT(tmp[13])
ENDIF ELSE binby = 'none'

;
; If the latitude is -99.99 (default) then display "Variable Lat" in the
;    title
;
IF binby EQ 'lat' THEN BEGIN
   lonstr = STRCOMPRESS('Variable Lon');
ENDIF ELSE BEGIN
   slon=(lon GE 0) ? 'E' : 'W'
   lonstr = STRCOMPRESS(STRING(FORMAT='(I3)',ABS(lon)),/RE)+slon
ENDELSE

;
; If the longitude is -999.99 (default) then display "Variable Lon" in the
;    title
;
IF binby EQ 'lon' THEN BEGIN
   latstr = STRCOMPRESS('Variable Lat'); 
ENDIF ELSE BEGIN
   slat=(lat GE 0) ? 'N' : 'S'
   latstr = STRCOMPRESS(STRING(FORMAT='(I3)',ABS(lat)),/RE)+slat
ENDELSE

;
; If the altitude is -9999.90 (default) then display "Variable Alt" in the
;    title
;
IF binby EQ 'alt' THEN BEGIN
   elevstr = STRCOMPRESS('Variable Alt')
ENDIF ELSE BEGIN
   elevstr = STRCOMPRESS(STRING(FORMAT='(I5)',elev),/RE)+' masl'
ENDELSE

position=code+' ('+latstr+'; '+lonstr+'; '+elevstr+')'

IF ( elev EQ -9999.90 OR intake EQ -9999.9 ) THEN BEGIN
   sample_str = STRCOMPRESS('Variable')
ENDIF ELSE BEGIN
   sample_str=STRCOMPRESS(STRING(FIX(intake+elev)),/RE)+' masl'
ENDELSE

sample_ht=proj_name+' Data (Sample Intake Height: '+sample_str+')'

IF N_ELEMENTS(tmp) EQ 14 THEN BEGIN
   binby = tmp[11]
   bmin=FLOAT(tmp[12])
   bmax=FLOAT(tmp[13])
   CASE binby OF
   'lat': BEGIN
      z1=(bmin GE 0) ? 'N' : 'S'
      z2=(bmax GE 0) ? 'N' : 'S'
      position=code+' ('+$
      STRCOMPRESS(STRING(FORMAT='(I3)',ABS(bmin)),/RE)+z1+'-'+$
      STRCOMPRESS(STRING(FORMAT='(I3)',ABS(bmax)),/RE)+z2+'; '+$
      lonstr+'; '+elevstr+')'
      END
   'lon': BEGIN
      z1=(bmin GE 0) ? 'E' : 'W'
      z2=(bmax GE 0) ? 'E' : 'W'
      position=code+' ('+latstr+'; '+$
      STRCOMPRESS(STRING(FORMAT='(I3)',ABS(bmin)),/RE)+z1+'-'+$
      STRCOMPRESS(STRING(FORMAT='(I3)',ABS(bmax)),/RE)+z2+'; '+$
      elevstr+')'
      END
   'alt': BEGIN
      IF bmin LT 0 THEN bmin = 0
      z1=STRCOMPRESS(STRING(FIX(bmin)),/RE)
      z2=STRCOMPRESS(STRING(FIX(bmax)),/RE)
      IF ( z1 EQ -9999 OR z2 EQ -9999 ) THEN BEGIN
         z_str = STRCOMPRESS('Variable')
      ENDIF ELSE BEGIN
         z=(z1 EQ z2) ? z1 : z1+'-'+z2
         z_str = z+'masl'
      ENDELSE
      sample_ht=proj_name+' Data (Sample Intake Height: '+z+')'
      END
   ENDCASE
ENDIF
END
