FUNCTION GET_SITENAME,code,binby,bin,old=old
;
; Make the names of the binned sites
; Ex: CAR010, SCSN05
;
CASE binby OF
   'lat': BEGIN
      z1='0'
      z1=(bin GE 0) ? 'n' : 's'
      s=code+z1+STRCOMPRESS(STRING(FORMAT='(I2.2)',ABS(bin)),/RE)
      END
   'lon': BEGIN
      z1=(bin GE 0) ? 'e' : 'w'
      END
   'alt': BEGIN
      s = (KEYWORD_SET(old)) ? code+STRCOMPRESS(STRING(FORMAT='(I3.3)',FIX(bin/100.)),/RE) : code+STRCOMPRESS(STRING(FIX(bin)),/RE)
      END
   ELSE: BEGIN
      s=code
      END
ENDCASE
RETURN,s
END
PRO CHK4BINNING,$
   code=code,$
   project=project,$
   chk4binning=chk4binning,$
   res=res
   res=CREATE_STRUCT('start',0D,'stop',0D,'binby','',$
      'min',0.0,'max',0.0,'width',0.0,'target','')
;
; Does site need to be binned?
;
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
perlcode=dbdir+'ccg_binning.pl'
SPAWN, perlcode+" -site="+code+" -project="+project, bininfo

chk4binning=0

IF bininfo[0] EQ '' THEN RETURN

chk4binning=1

nbininfo=N_ELEMENTS(bininfo)

res=REPLICATE(res,nbininfo)

FOR i=0,nbininfo-1 DO BEGIN

   tmp=STRSPLIT(bininfo[i],'|',/EXTRACT)

   z=STRSPLIT(tmp[3],'-',/EXTRACT)
   CCG_DATE2DEC, yr=FIX(z[0]),mo=FIX(z[1]),$
   dy=FIX(z[2]),hr=12,mn=0,dec=dec
   res[i].start=dec

   z=STRSPLIT(tmp[4],'-',/EXTRACT)
   CCG_DATE2DEC, yr=FIX(z[0]),mo=FIX(z[1]),$
   dy=FIX(z[2]),hr=12,mn=0,dec=dec
   res[i].stop=dec

   res[i].binby=tmp[5]
   res[i].min=FLOAT(tmp[6])
   res[i].max=FLOAT(tmp[7])
   res[i].width=FLOAT(tmp[8])
   res[i].target=tmp[9]
ENDFOR
END

PRO IADV_DRIVER,$
   no_ts=no_ts,$
   no_sc=no_sc,$
   no_fi=no_fi,$
   no_vp=no_vp,$
   dev=dev
;
; This procedure loops through all available
; time series data sets and calls
;      1. IADV_TS_SG.PRO
;      2. IADV_SC_SG.PRO
;      3. 
;
; October 2005 - dyc
; November 2002 - kam
;
;
lsite='' & lcode='' & lproj_abbr=''

srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
ddir=srcdir+'tmp/'
perlcode=dbdir+'ccg_query.pl'
tmpfile=CCG_TMPNAM('/tmp/')
;
; Get a list of ALL available data sets from MySQL
;
perlcode=srcdir+'iadv_datasum.pl -project=ccg_surface,ccg_aircraft,ccg_obs'
SPAWN, perlcode,site_info
nsite_info=N_ELEMENTS(site_info)

FOR i=0,nsite_info-1 DO BEGIN

   tmp=STRSPLIT(site_info[i],'|',/EXTRACT)

   IF N_ELEMENTS(tmp) NE 15 THEN BEGIN
      CCG_MESSAGE, "Missing info: "+site_info[i]
      CONTINUE
   ENDIF

   ; Old data
   ; 0|  1|             2|     3|    4|     5|   6|     7|
   ; 2|ALT|Alert, Nunavut|Canada|82.45|-62.52|10.0|200.00|1|co2|1|Flask|Network Flask|1985|2005

   ; New data
   ; 0|  1|             2|     3|      4|       5|   6|     7|
   ; 2|ALT|Alert, Nunavut|Canada|82.4500|-62.5200|10.0|200.00|1|co2|1|ccg_surface|Carbon Cycle Surface Flasks|1985|2006
   usn=tmp[0]
   code=STRLOWCASE(tmp[1])
   name=tmp[2]
   country=tmp[3]
   lat=CCG_ROUND(FLOAT(tmp[4]),0)
   lon=CCG_ROUND(FLOAT(tmp[5]),0)
   intake_ht=FLOAT(tmp[6])
   elev=FLOAT(tmp[7])
   IF ( elev EQ -9999.90 OR intake_ht EQ -9999.90 ) THEN BEGIN
      alt=-9999.90
   ENDIF ELSE BEGIN
      alt=elev+intake_ht
   ENDELSE
   param_num=STRLOWCASE(tmp[8])
   param=STRLOWCASE(tmp[9])
   proj_num=STRLOWCASE(tmp[10])
   proj_abbr=STRLOWCASE(tmp[11])
   proj_name=tmp[12]

   ;
   ;Skip binned sites
   ;
   IF STRLEN(code) GT 3 THEN CONTINUE
   ;
   ; TEMPCODE
   ; Skip OBS CO data
   ;
   IF ( proj_abbr EQ 'ccg_obs' AND param EQ 'co' ) THEN CONTINUE
   ;
   ;Get data extension path
   ;
   perlcode=dbdir+'ccg_query.pl'
   sql="SELECT t2.extension FROM gmd.parameter AS t1, parameterinfo AS t2 WHERE t1.num = t2.parameter_num AND t1.formula = '"+param+"'"
   SPAWN, perlcode+' "'+sql+'"',extdir

   ;
   ; Does site need to be binned?
   ;
   CHK4BINNING,code=code,project=proj_abbr,chk4binning=chk4binning,res=bininfo

   IF proj_abbr EQ 'ccg_aircraft' AND (code NE lcode OR proj_abbr NE lproj_abbr) AND NOT KEYWORD_SET(no_vp) THEN BEGIN
      ;
      ; Get list of profile dates and the prefix of the pfp ID
      ;
      perlcode=dbdir+'ccg_vplist.pl'
      SPAWN, perlcode+" -site="+code, vp

      FOR ivp=0,N_ELEMENTS(vp)-1 DO BEGIN

         dttmp = STRSPLIT(vp[ivp],' ',/EXTRACT)

         datetime1 = STRSPLIT(dttmp[0],'|',/EXTRACT)

         projstr = STRSPLIT(proj_abbr[0],'_',/EXTRACT)

         ; Get lst2utc
         CCG_SITEDESCINFO,site=code[0],$
                          proj_abbr=proj_abbr[0],$
                          lst2utc=lst2utc

         IF ( lst2utc NE -99 ) THEN BEGIN
            datetmp = STRSPLIT(datetime1[0],'-',/EXTRACT)
            timetmp = STRSPLIT(datetime1[1],':',/EXTRACT)

            CCG_DATE2DEC,yr=datetmp[0],mo=datetmp[1],dy=datetmp[2],$
                         hr=timetmp[0],mn=timetmp[1],sc=timetmp[2],dec=decdate

            HOUR=0.00011416D

            ;
            ;convert from UTC to LST
            ;
            decdate = decdate-(HOUR*lst2utc)
            CCG_DEC2DATE,decdate,yr,mo,dy,hr,mn,sc

            datestr = STRCOMPRESS(STRING(FORMAT='(I4.4,A1,I2.2,A1,I2.2)',yr,'-',mo,'-',dy))
            timestr = STRCOMPRESS(STRING(FORMAT='(I2.2,A1,I2.2,A1,I2.2)',hr,':',mn,':',sc))
         ENDIF ELSE BEGIN
            datestr = datetime1[0]
            timestr = datetime1[1]
         ENDELSE

         ; sgp_multi-gas_vppanel_aircraft_2007-08-08-16:48:30.pdf
         saveas=ddir+code+'_multi-gas_vppanel_'+projstr[1]+'_'+datestr+'-'+timestr+'.ps'

         PRINT,datestr," ",timestr

         IADV_VP,$
         site=code[0],$
         datetime=dttmp[0]+"~"+dttmp[1],$
         sp=['co2','ch4','co','h2','n2o','sf6'],$
         project=MAKE_ARRAY(6,/STR,VALUE=proj_abbr[0]),$
         /norej,$
         /nopi,$
         datafound=datafound,$
         saveas=tmpfile,$
         dev=dev

         IF datafound GT 0 THEN BEGIN
            SPAWN,'mv '+tmpfile+' '+saveas
            PRINT,'mv '+tmpfile+' '+saveas
         ENDIF
      ENDFOR
   ENDIF

   FOR ibin=0,N_ELEMENTS(bininfo)-1 DO BEGIN
      width=(bininfo[ibin].width NE 0) ? bininfo[ibin].width : 1
      FOR bin=bininfo[ibin].min,bininfo[ibin].max,width DO BEGIN
         ;
         ; This is a bit of ugly code.
         ; Needs to be fixed.
         ; The altitude of flask sites should not be divided by 100.
         ;
         old = (proj_abbr EQ 'ccg_aircraft') ? 1 : 0
         site=GET_SITENAME(code,bininfo[ibin].binby,bin, old = old)

         alt=(bininfo[ibin].binby EQ 'alt') ? FIX(bin) : alt
         IF ( alt EQ -9999.90 ) THEN BEGIN
            samp_ht = 'variable'
         ENDIF ELSE BEGIN
            samp_ht=STRCOMPRESS(STRING(FORMAT='(I5.5)',FIX(alt)),/RE)
         ENDELSE
         savecode=(bininfo[ibin].binby EQ 'alt') ? code : site

          ; !!!!!!!!! Time series
         IF NOT KEYWORD_SET(no_ts) THEN BEGIN

            projstr = STRSPLIT(proj_abbr[0],'_',/EXTRACT)
            saveas=ddir+savecode+'_'+param+'_ts_'+projstr[1]+'_'+samp_ht+'.ps'

            IADV_TS,$
            site=site[0],$
            sp=param[0],$
            project=proj_abbr[0],$
            datafound=datafound,$
            saveas=tmpfile,$
            /norej,$
            /noproid,$
            dev=dev

            IF datafound GT 0 THEN BEGIN
               SPAWN,'mv '+tmpfile+' '+saveas
               PRINT,'mv '+tmpfile+' '+saveas
            ENDIF

            IF site NE lsite OR proj_abbr NE lproj_abbr THEN BEGIN
               projstr = STRSPLIT(proj_abbr[0],'_',/EXTRACT)
               saveas=ddir+savecode+'_multi-gas_ts_'+projstr[1]+'_'+samp_ht+'.ps'

               ; TEMPCODE
               ; Do not show OBS co data
               z = (proj_abbr EQ 'ccg_obs') ? ['co2','ch4'] : ['co2','co2c13','ch4','co']
               ;z = (proj_abbr EQ 'obs') ? ['co2','ch4','co'] : ['co2','co2c13','ch4','co']

               IADV_TS,$
               site=site[0],$
               sp=z,$
               project=MAKE_ARRAY(N_ELEMENTS(z),/STR,VALUE=proj_abbr[0]),$
               nyrs=5,$
               saveas=tmpfile,$
               /norej,$
               /noproid,$
               dev=dev

               IF datafound GT 0 THEN SPAWN,'mv '+tmpfile+' '+saveas

            ENDIF
         ENDIF

          ; !!!!!!!!! Flask in-situ comparison
         IF proj_abbr EQ 'ccg_obs' AND NOT KEYWORD_SET(no_fi) THEN BEGIN

            projstr = STRSPLIT(proj_abbr[0],'_',/EXTRACT)
            saveas=ddir+savecode+'_'+param+'_fi_'+projstr[1]+'_'+samp_ht+'.ps'

            IF param[0] NE 'n2o' THEN BEGIN
               IADV_FI_SG,$
               site=code[0],$
               sp=param[0],$
               datafound=datafound,$
               saveas=tmpfile,$
               /noproid,$
               /showstats,$
               dev=dev

               IF datafound GT 0 THEN BEGIN
                  SPAWN,'mv '+tmpfile+' '+saveas
                  PRINT,'mv '+tmpfile+' '+saveas
               ENDIF
            ENDIF
         ENDIF

          ; !!!!!!!!! seasonal cycles
         IF NOT KEYWORD_SET(no_sc) THEN BEGIN

            projstr = STRSPLIT(proj_abbr[0],'_',/EXTRACT)
            saveas=ddir+savecode+'_'+param+'_sc_'+projstr[1]+'_'+samp_ht+'.ps'

            old = (proj_abbr EQ 'ccg_aircraft') ? 1 : 0
            z=(bininfo[ibin].binby EQ 'alt') ? GET_SITENAME(code,bininfo[ibin].binby,bin,old=old) : site
            ;
            ; Temporary code
            ;
            extfile=extdir+z+'*D*_ext.'+param
            ;print, 'extfile=', extfile

            IADV_SC_SG,$
            sp=param[0],$
            site=site[0],$
            project=proj_abbr[0],$
            extfile=extfile,$
            datafound=datafound,$
            saveas=tmpfile,$
            /noproid,$
            dev=dev

            IF datafound GT 0 THEN BEGIN
               SPAWN,'mv '+tmpfile+' '+saveas
               PRINT,'mv '+tmpfile+' '+saveas
            ENDIF
         ENDIF
      ENDFOR
      lsite=site[0]
      lcode=code[0]
      lproj_abbr=proj_abbr[0]
   ENDFOR
ENDFOR
;
; Clean up
;
SPAWN,"rm -f "+tmpfile
END
