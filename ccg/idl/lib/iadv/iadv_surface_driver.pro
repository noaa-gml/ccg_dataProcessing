PRO 	IADV_SURFACE_DRIVER,$ 
	dev=dev
;
;**********************************************
; Misc Initialization
;**********************************************
;
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
perlcode = dbdir+'ccg_query.pl'
tmpfile = CCG_TMPNAM('/tmp/')
ddir = srcdir+'tmp/'

r = CCG_SYSDATE()
cyr = r.yr
dev = (NOT KEYWORD_SET(dev)) ? '' : dev

tdev = (dev EQ 'psc') ? 'ps' : dev
;
;**********************************************
; Get list of parameters with available data
;**********************************************
;
sql = "SELECT t1.formula FROM gmd.parameter AS t1 LEFT JOIN parameterinfo AS t2 ON (t1.num = t2.parameter_num) WHERE t2.extension IS NOT NULL"
SPAWN, perlcode+' "'+sql+'"',params
nparams=N_ELEMENTS(params)

FOR ig=0,nparams-1 DO BEGIN
   ;
   ;**********************************************
   ;Get Data Extension path-> init file
   ;**********************************************
   ;
   perlcode = dbdir+'ccg_query.pl'
   sql="SELECT t2.extension FROM gmd.parameter AS t1, parameterinfo AS t2 WHERE t1.num = t2.parameter_num AND t1.formula = '"+params[ig]+"'"
   SPAWN, perlcode+' "'+sql+'"',extdir

   ; iadv_datasum.pl returns a list of strings, each looks like:
   ; 137|ZEP|Ny-Alesund, Svalbard|Norway and Sweden|78.9067|11.8889|5.0|474.00|1|co2|1|ccg_surface|Carbon Cycle Surface|1994|2016

   perlcode=srcdir+'iadv_datasum.pl -project=ccg_surface'
;perlcode=srcdir+'iadv_datasum.pl -project=ccg_surface -site=mlo -parameter=co2'
   SPAWN, perlcode, site_info
   nsite_info=N_ELEMENTS(site_info)

   code_lower = ''
   prev_code = '@@@'

   FOR i=0,nsite_info-1 DO BEGIN

      tmp=STRSPLIT(site_info[i],'|',/EXTRACT)

      code_lower = STRLOWCASE(tmp[1])
      IF ( code_lower NE prev_code ) THEN BEGIN
         prev_code = code_lower

         ;
         ;Here's a bit of temporary code
         ;
         code_lower = (code_lower EQ 'poc000') ? 'pocn00' : code_lower

         intake_ht=FIX(tmp[6])
         elev=FIX(tmp[7])

         ;
         ; This is to skip SGP because flasks are measured at different
         ;    altitudes, so the intake_ht is -9999 (Variable)
         ; Also added check for elev (kwt 2016-2-16)
         ;
         IF intake_ht EQ -9999 THEN CONTINUE
         IF elev EQ -9999 THEN CONTINUE

         alt=elev+intake_ht
;print, "alt is ", alt, " elev is ", elev, " intake_ht is ", intake_ht

         samp_ht=STRCOMPRESS(STRING(FORMAT='(I5.5)',FIX(alt)),/RE)
         saveas=ddir+code_lower+'_'+params[ig]+'_rug_surface_'+samp_ht+'.ps'
;print, "saveas is", saveas

         s_info = STRJOIN(tmp[[0,1,2,3,4,5,6,7,8]],'|');

         IADV_SURFACE,$
         sp=params[ig],$
         srfcfile=extdir+'surface.mbl.'+params[ig],$
         saveas=saveas,$
         site=code_lower,$
         s_info=s_info,$
         dev=dev
      ENDIF

   ENDFOR

ENDFOR
;
;------------------------------------------------close up shop 
;
SPAWN,'rm -f '+tmpfile
END
