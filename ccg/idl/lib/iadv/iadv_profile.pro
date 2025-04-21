@iadv_clnlib.pro
@ccg_utils.pro

PRO EXTRACT_PLOTINFO,$
   data=data,$
   xval=xval,$
   yval=yval,$
   zval=zval,$
   fval=fval

   IF (r = SIZE(data, /TYPE)) EQ 8 THEN BEGIN
      yr=FIX(data.field2)
      mo=FIX(data.field3)
      dy=FIX(data.field4)
      hr=FIX(data.field5)
      mn=FIX(data.field6)
      sc=FIX(data.field7)

      CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec

      xval=data.field10
      yval=data.field20/1000.
      zval=dec
      fval=data.field11

      j=SORT(xval)
      xval=xval[j]
      yval=yval[j]
      zval=zval[j]
      fval=fval[j]
   ENDIF ELSE BEGIN
      xval=0 & yval=0 & zval = 0D & fval = ""
   END
END

PRO IADV_PROFILE,$
   site=site,$
   project=project,$
   parameter=parameter,$
   sp=sp,$
   datetime=datetime,$
   xret=xret,$
   yret=yret,$
   zret=zret,$
   fret=fret,$
   xnb=xnb,$
   ynb=ynb,$
   znb=znb,$
   fnb=fnb,$
   xrej=xrej,$
   yrej=yrej,$
   zrej=zrej,$
   frej=frej,$
   nomessages=nomessages

ex="IADV_PROFILE,site='car',sp='co2',parameter='alt',project='ccg_aircraft',date='2002-01-11~15:26:00',xret=xret,yret=yret,xnb=xnb,ynb=ynb"

IF NOT KEYWORD_SET(site) THEN CCG_FATALERR, ex
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR, ex
IF NOT KEYWORD_SET(project) THEN CCG_FATALERR, ex
IF NOT KEYWORD_SET(parameter) THEN CCG_FATALERR, ex
IF NOT KEYWORD_SET(datetime) THEN CCG_FATALERR, ex
sitechk = CLEANSITE(site=site)
IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."
spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."
projectchk = CLEANPROJECT(project=project)
IF ( projectchk NE 1 ) THEN CCG_FATALERR, "Invalid 'project' specified. Exiting ..."

dbdir='/projects/src/db/'

tmpfile=CCG_TMPNAM('/tmp/');

; Separate first date and time
tmp=STRSPLIT(datetime,'~',/EXTRACT)

dttmp=STRSPLIT(tmp[0],'|',/EXTRACT)

;
IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Extracting '+site+' '+sp+' data ...'
;
;##############################################
; Query DB for retained flask data
;##############################################
;
;str=code+' -1 -2 -s'+site+' -g'+sp+' -d'+date+' -o'+tmpfile

code=dbdir+'ccg_flask.pl'
str=code+' -data=flag:.._ -site='+site+' -parameter='+sp
str=str+' -event=vp:'+dttmp[0]+','+dttmp[1]
str=str+' -outfile='+tmpfile+' -preliminary -exclusion'
SPAWN,str

CCG_READ,file=tmpfile,/nomessages,z

EXTRACT_PLOTINFO,data=z,xval=xret,yval=yret,zval=zret,fval=fret

;
;##############################################
; Query DB for nb flask data
;##############################################
;
;str=code+' -i -2 -s'+site+' -g'+sp+' -d'+date+' -o'+tmpfile
code=dbdir+'ccg_flask.pl'
str=code+' -not -data=flag:_._ -site='+site+' -parameter='+sp
str=str+' -event=vp:'+dttmp[0]+','+dttmp[1]
str=str+' -outfile='+tmpfile+' -preliminary -exclusion'
SPAWN,str

CCG_READ,file=tmpfile,/nomessages,z

EXTRACT_PLOTINFO,data=z,xval=xnb,yval=ynb,zval=znb,fval=fnb

;
;##############################################
; Query DB for rejected flask data
;##############################################
;
;str=code+' -i -1 -s'+site+' -g'+sp+' -d'+date+' -o'+tmpfile
code=dbdir+'ccg_flask.pl'
str=code+' -not -data=flag:.__ -site='+site+' -parameter='+sp
str=str+' -event=vp:'+dttmp[0]+','+dttmp[1]
str=str+' -outfile='+tmpfile+' -preliminary -exclusion'
SPAWN,str

CCG_READ,file=tmpfile,/nomessages,z

EXTRACT_PLOTINFO,data=z,xval=xrej,yval=yrej,zval=zrej,fval=frej

IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Done extracting '+site+' '+sp+' data ...'
;
;CLEAN UP
;
SPAWN,"rm -f "+tmpfile
END
