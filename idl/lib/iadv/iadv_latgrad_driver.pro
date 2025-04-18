PRO IADV_LATGRAD_DRIVER,$ 
   nomovie=nomovie,$
   yr1_=yr1_,$
   yr2_=yr2_,$
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
dev = (NOT KEYWORD_SET(dev)) ? '' : dev

tdev = (dev EQ 'psc') ? 'ps' : dev
;
;**********************************************
; Get list of parameters with available data
;**********************************************
;
sql = "SELECT t1.formula FROM gmd.parameter AS t1 LEFT JOIN parameterinfo AS t2 ON (t1.num = t2.parameter_num) WHERE t2.extension IS NOT NULL";
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

   CCG_DIRLIST,    dir=extdir+'init.'+params[ig]+'*',initfile
   initfile=initfile[0]
   ;
   ;**********************************************
   ;Use span dates if yr1 and yr2 not specified
   ;**********************************************
   ;
   CCG_READINIT,file=initfile,/nomessages,init
   yr1 = (NOT KEYWORD_SET(yr1_)) ? CEIL(init.sync1) : yr1_
   yr2 = (NOT KEYWORD_SET(yr2_)) ? FIX(init.sync2-1) : yr2_
   yr1 = (yr2-yr1 GT 9) ? yr2-11 : yr1
   ;;
   ;;**********************************************
   ;; Determine if any data should be excluded
   ;; Determine preliminary date
   ;;**********************************************
   ;;
   ;perlcode=srcdir+'iadv_pi.pl'
   ;SPAWN, perlcode+' -g'+params[ig]+' -p flask',tmp
   ;pi_info=STRSPLIT(tmp[0],'|',/EXTRACT)
   ;
   ;preliminary=pi_info[5]
   ;tmp=STRSPLIT(preliminary,'-',/EXTRACT)
   ;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
   ;dy=FIX(tmp[2]),hr=12,mn=0,dec=preliminary
   ;
   ;exclusion=(N_ELEMENTS(pi_info) EQ 7) ? pi_info[6] : '9999-12-31'
   ;tmp=STRSPLIT(exclusion,'-',/EXTRACT)
   ;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
   ;dy=FIX(tmp[2]),hr=12,mn=0,dec=exclusion
   ;
   ;**********************************************
   ;First construct monthly mean file
   ;**********************************************
   ;

   IADV_LATGRAD,$
   initfile=initfile,$
   datafile=tmpfile,$
   /prep,$
   sp=params[ig]

   IF NOT KEYWORD_SET(nomovie) THEN BEGIN
      ;
      ;**********************************************
      ;Read monthly mean file
      ;**********************************************
      ;
      arr = 0
      CCG_READ,file=tmpfile,arr
      ; 0.99 1 1986 05  353.143    0.072 04    ALT
      ;
      ;**********************************************
      ;Construct animation
      ;**********************************************
      ;
      j = WHERE(arr.field3 GE yr1 AND arr.field3 LE yr2)
      ymin = FLOOR(MIN(arr[j].field5))
      ymax = CEIL(MAX(arr[j].field5))

      yaxis=[ymin,ymax,0,0]

      FOR iyr = yr1, yr2 DO BEGIN

         j = WHERE(arr.field3 EQ iyr)
         IF j[0] EQ -1 THEN CONTINUE

         yrarr = arr[j]

         FOR imo = 1,12 DO BEGIN
            ;
            ; Excluded data if necessary
            ;
            CCG_DATE2DEC,yr=iyr,mo=imo,dy=1,dec=dec
            ;
            j = WHERE(yrarr.field4 EQ imo)
            IF j[0] EQ -1 OR N_ELEMENTS(j) LT 6 THEN CONTINUE

            CCG_SWRITE,file=tmpfile,yrarr[j].str

            saveas = ddir + 'all_' + params[ig] + '_lg_surface_' + $
            STRCOMPRESS(STRING(FORMAT='(I4.4,I2.2)',iyr,imo),/RE) + $
            '.' + tdev

            IADV_LATGRAD,$
            initfile=initfile,$
            datafile=tmpfile,$
            yaxis=yaxis,$
            yr1=iyr,$
            mo1=imo,$
            sp=params[ig],$
            saveas=saveas,$
            dev=dev
         ENDFOR
      ENDFOR
   ENDIF
ENDFOR
;
;------------------------------------------------close up shop 
;
SPAWN,'rm -f '+tmpfile
END
