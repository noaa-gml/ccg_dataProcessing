@iadv_clnlib.pro
@ccg_utils.pro

PRO BUILD_STR, data, sp=sp, ts=ts, met=met, tags, a
   ;
   ; Build the structure for a unmerged output
   ;
   ; hr
   ; code dd yr mo dy hr parameter value sdev flag
   ;
   ; mo/dy
   ; code dd yr mo dy parameter value sdev num flag
   ;
   ndata = LONG(N_ELEMENTS(data))
   IF KEYWORD_SET(sp) THEN BEGIN
      sp_ = STRSPLIT(sp, ',' , /EXTRACT)
      nsp_ = N_ELEMENTS(sp_)
   ENDIF ELSE nsp_ = 0

   IF ( ts EQ 'hr' ) THEN BEGIN
      z = CREATE_STRUCT('str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'date',0.0D,$
                        'parameter','','value','0.0','sdev','0.0','flag','')
   ENDIF ELSE BEGIN
      z = CREATE_STRUCT('str','','code','','yr',0,'mo',0,'dy',0,'date',0.0D,$
                        'parameter','','value','0.0','sdev','0.0','num',0,'flag','')
   ENDELSE

   ;
   ; Add user-defined tags?
   ;
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   ;
   ; Add met data
   ;
   IF ( met AND ts EQ 'hr' ) THEN z = CREATE_STRUCT(z, 'wd', 999, 'ws', 99.9, 'sf', 0, 'press', 9999.9, 'temp', 99.9, 'dp', 99.9, 'precip', 999)

   tags = TAG_NAMES(z)
   a = REPLICATE(z, ndata)
   
   FOR i=0L,ndata-1 DO BEGIN
      str = STRSPLIT(data[i],' ',/EXTRACT)
      a[i].str = data[i]
      a[i].code = str[0]
      a[i].date = DOUBLE(str[1])

      a[i].yr = FIX(str[2])
      a[i].mo = FIX(str[3])
      a[i].dy = FIX(str[4])

      IF ( ts EQ 'hr' ) THEN BEGIN
         a[i].hr = FIX(str[5])
         a[i].parameter = str[6]
         a[i].value = FLOAT(str[7])
         a[i].sdev = FLOAT(str[8])
         a[i].flag = str[9]
      ENDIF ELSE BEGIN
         a[i].parameter = str[5]
         a[i].value = FLOAT(str[6])
         a[i].sdev = FLOAT(str[7])
         a[i].num = FIX(str[8])
         a[i].flag = str[9]
      ENDELSE
   ENDFOR

   IF ( ts EQ 'hr' ) THEN BEGIN
      CCG_DATE2DEC, yr=a.yr, mo = a.mo, dy = a.dy, hr = a.hr, dec = dec
      a.date = dec
   ENDIF ELSE BEGIN
      CCG_DATE2DEC, yr=a.yr, mo = a.mo, dy = a.dy, dec = dec
      a.date = dec
   ENDELSE
END

PRO BUILD_MERGE, data, sp=sp, ts=ts, met=met, tags, a
   ;
   ; Build the structure for a merged output
   ;
   ; hr
   ; code dd yr mo dy hr <sp>_value <sp>_sdev <sp>_flag 
   ;
   ; mo/dy
   ; code dd yr mo dy <sp>_value <sp>_sdev <sp>_num <sp>_flag 
   ;
   ndata = LONG(N_ELEMENTS(data))
   IF KEYWORD_SET(sp) THEN BEGIN
      sp_ = STRSPLIT(sp, ',' , /EXTRACT)
      nsp_ = N_ELEMENTS(sp_)
   ENDIF ELSE nsp_ = 0

   IF ( ts EQ 'hr' ) THEN BEGIN
      z = CREATE_STRUCT('str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'date',0.0D)
      FOR i = 0, nsp_ - 1 DO $
         z = CREATE_STRUCT(z, sp_[i], 0.0, sp_[i]+'_sdev', 0.0, sp_[i]+'_flag', '')
   ENDIF ELSE BEGIN
      z = CREATE_STRUCT('str','','code','','yr',0,'mo',0,'dy',0,'date',0.0D)
      FOR i = 0, nsp_ - 1 DO $
         z = CREATE_STRUCT(z, sp_[i], 0.0, sp_[i]+'_sdev', 0.0, sp_[i]+'_num', 0,$
                           sp_[i]+'_flag', '')
   ENDELSE

   ;
   ; Add user-defined tags?
   ;
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   ;
   ; Add met data
   ;
   IF ( met AND ts EQ 'hr' ) THEN z = CREATE_STRUCT(z, 'wd', 999, 'ws', 99.9, 'sf', 0, 'press', 9999.9, 'temp', 99.9, 'dp', 99.9, 'precip', 999)

   tags = TAG_NAMES(z)
   a = REPLICATE(z, ndata)

   FOR i=0L,ndata-1 DO BEGIN
      str = STRSPLIT(data[i],' ',/EXTRACT)
      a[i].str = data[i]
      a[i].code = str[0]
      a[i].date = DOUBLE(str[1])

      a[i].yr = FIX(str[2])
      a[i].mo = FIX(str[3])
      a[i].dy = FIX(str[4])

      IF ( ts EQ 'hr' ) THEN BEGIN
         a[i].hr = FIX(str[5])
         offset = 5
         FOR j = 0, nsp_ - 1 DO BEGIN
            k = WHERE(tags EQ STRUPCASE(sp_[j]))
            a[i].(k[0]) = FLOAT(str[offset + (3.0 * j) + 1])
            a[i].(k[0] + 1) = FLOAT(str[offset + (3.0 * j) + 2])
            a[i].(k[0] + 2) = str[offset + (3.0 * j) + 3]
         ENDFOR
      ENDIF ELSE BEGIN
         offset = 4
         FOR j = 0, nsp_ - 1 DO BEGIN
            k = WHERE(tags EQ STRUPCASE(sp_[j]))
            a[i].(k[0]) = FLOAT(str[offset + (4.0 * j) + 1])
            a[i].(k[0] + 1) = FLOAT(str[offset + (4.0 * j) + 2])
            a[i].(k[0] + 2) = FIX(str[offset + (4.0 * j) + 3])
            a[i].(k[0] + 3) = str[offset + (4.0 * j) + 4]
         ENDFOR
      ENDELSE
   ENDFOR

   IF ( ts EQ 'hr' ) THEN BEGIN
      CCG_DATE2DEC, yr=a.yr, mo = a.mo, dy = a.dy, hr = a.hr, dec = dec
      a.date = dec
   ENDIF ELSE BEGIN
      CCG_DATE2DEC, yr=a.yr, mo = a.mo, dy = a.dy, dec = dec
      a.date = dec
   ENDELSE
END

PRO IADV_OBS,$
    site=site,$
    ts=ts,$
    sp=sp,$
    date=date,$
    merge=merge,$
    met = met,$
    tags=tags,$
    nomessages=nomessages,$
    arr

ex="IADV_OBS,site='brw',sp='co2',date=['19991231','20011231'],arr"

IF NOT KEYWORD_SET(site) THEN CCG_FATALERR, ex
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR, ex
sitechk = CLEANSITE(site=site)
IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."
spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."

tmpfile=CCG_TMPNAM('/tmp/');
IF KEYWORD_SET(date) THEN BEGIN
   IF N_ELEMENTS(date) EQ 1 THEN date = [date, date]
                                                                                          
   date = LONG(date)
ENDIF ELSE BEGIN
   r = CCG_SYSDATE()

   date = ['1900', STRING(r.yr)]
ENDELSE

date1 = DateDB((date[0] = StartDate(date[0])))
date2 = DateDB((date[1] = EndDate(date[1])))

IF NOT KEYWORD_SET(ts) THEN ts='dy'

met = KEYWORD_SET(met) ? 1 : 0
merge = KEYWORD_SET(merge) ? 1 : 0
nomessages = KEYWORD_SET(messages) ? 1: 0

arr=0
data=0

;
;##############################################
; Query DB for OBS data by day, hour, or month
;##############################################
;
srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'
code=srcdir+'ccg_obs_dd.pl'
str=code+' -site='+site+' -parameter='+sp+' -timeres='+ts+' -data=date:'+STRING(date1)+','+STRING(date2)+' -stdout -quiet -exclusion -preliminary'

print, str

IF merge THEN str=str+' -merge'

IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Extracting '+site+' '+sp+' data ...'
SPAWN,str,data
IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Done extracting '+site+' '+sp+' data ...'

IF data[0] EQ '' THEN RETURN

IF merge THEN BUILD_MERGE, data, sp=sp, ts=ts, met=met, tags, arr $
ELSE BUILD_STR, data, sp=sp, ts=ts, met=met, tags, arr

IF ( met AND ts EQ 'hr' ) THEN BEGIN
   ;
   ; Build file name.  Read from FTP server
   ;
   exception = (STRCMP(arr[0].code, 'BRW', /FOLD_CASE) NE 0) ? '/rtd/' : '/'

   yr_arr = arr[sort(arr[*].yr)].yr
   yr_arr = yr_arr[uniq(yr_arr)]

   FOR yr = 0, N_ELEMENTS(yr_arr) - 1 DO BEGIN
      f = '/ftp/met/hourlymet/' + STRLOWCASE(arr[0].code) + exception
      f = f + STRLOWCASE(arr[0].code) + ToString(yr_arr[yr])

      ;
      ;Does met file exist?
      ;
      z = FILE_SEARCH(f, COUNT = count)
      IF count EQ 0 THEN RETURN

      RESTORE,file=idldir + 'data/cmdl_met_hr_template'

      IF NOT nomessages THEN CCG_MESSAGE, 'Reading ' + f + ' ...'
      met = READ_ASCII(f, template = template)
      IF NOT nomessages THEN CCG_MESSAGE, 'Done reading ' + f + '.'
      ;
      ; Loop through gas array (it may be smaller!)
      ;
      FOR i = 0, N_ELEMENTS(arr) - 1 DO BEGIN
         j = WHERE(met.yr EQ arr[i].yr AND met.mo EQ arr[i].mo AND met.dy EQ arr[i].dy AND met.hr EQ arr[i].hr)
         IF j[0] EQ -1 THEN CONTINUE

         arr[i].ws = met.ws[j[0]]
         arr[i].wd = met.wd[j[0]]
         arr[i].sf = met.sf[j[0]]
         arr[i].press = met.pressure[j[0]]
         arr[i].temp = met.temp[j[0]]
         arr[i].dp = met.dwpt[j[0]]
         arr[i].precip = met.precip[j[0]]
      ENDFOR
   ENDFOR
ENDIF


END
