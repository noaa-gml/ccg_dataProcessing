@iadv_clnlib.pro
@ccg_utils.pro

PRO IADV_LATPREP,$ 
   sp=sp,$
   initfile=initfile,$
   datafile=datafile

;
;**********************************************
; Misc Initialization
;**********************************************
;
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
idldir='/ccg/idl/lib/ccglib/'
perlcode = dbdir+'ccg_query.pl'

IF KEYWORD_SET(datafile) THEN OPENW,fpout,datafile,/GET_LUN ELSE fpout=(-1)

CCG_READINIT,file=initfile,arr
nsites=N_ELEMENTS(arr.desc.site_code)

FOR i=0,nsites-1 DO BEGIN

   IF ( arr.desc[i].lab_num NE '01' AND arr.desc[i].lab_num NE '00' ) THEN CONTINUE
   ;
   ;**********************************************
   ; Read Data
   ;**********************************************
   ;
   CCG_FLASK,$
   site = STRLOWCASE(arr.desc[i].site_code), $
   sp = sp, project = 'ccg_surface', strategy = 'flask',$
   /preliminary, /exclusion, data
   ;
   ; Subset of retained data
   ;
   xret = [0] & yret = [0]

   typ = size(data);
   chk = typ(typ(0)+1);
                                                                                          
   ; chk
   ;   0:       type = 'Undefined'
   ;   1:       type = 'Byte'
   ;   2:       type = 'Integer'
   ;   3:       type = 'Long'
   ;   4:       type = 'Float'
   ;   5:       type = 'Double'
   ;   6:       type = 'Complex'
   ;   7:       type = 'String'
   ;   8:       type = 'Structure'
   ; if chk == 8, then data is a structure

   IF ( chk EQ 8 ) THEN BEGIN
      j = WHERE(STRMID(data.flag, 0, 2) EQ "..")
      IF j[0] NE -1 THEN BEGIN
         xret = data[j].date
         yret = data[j].value
      ENDIF
   ENDIF

   ;
   ; Don't fit a curve if there are too few data
   ;
   if (N_ELEMENTS(xret) LT 104 OR xret[N_ELEMENTS(xret)-1]-xret[0] LE 2) THEN CONTINUE
   ;;
   ;;**********************************************
   ;; Are there data exclusions?
   ;;**********************************************
   ;;
   ;perlcode=srcdir+'iadv_pi.pl'
   ;SPAWN, perlcode+' -g'+sp+' -pflask',tmp
   ;pi_info=STRSPLIT(tmp[0],'|',/EXTRACT)
   ;
   ;exclusion=(N_ELEMENTS(pi_info) EQ 7) ? pi_info[6] : '9999-12-31'
   ;tmp=STRSPLIT(exclusion,'-',/EXTRACT)
   ;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
   ;dy=FIX(tmp[2]),hr=12,mn=0,dec=exclusion
   ;
   ;j = WHERE(xret LT exclusion)
   ;xret=xret[j]
   ;yret=yret[j]

   ;
   ; Filter final and preliminary data.
   ;
   ; Fit a curve to entire record.
   ; Exclude preliminary values that are 3 sigma
   ; from s(t).
   ;
   IADV_QUICKFILTER,x=xret,y=yret,ptr
   j=WHERE(ptr EQ 1)
   xret=xret[j]
   yret=yret[j]
   ;
   CCG_CCGVU,$
   x=xret,y=yret, $
   npoly=arr.init[i].npoly,$
   nharm=arr.init[i].nharm,$
   interval=arr.init[i].interval,$
   cutoff1=arr.init[i].cutoff1,$
   cutoff2=arr.init[i].cutoff2,$
   even=1,$
   sc=sc,$
   summary=summary
   
   CCG_MEANS,xarr=sc(0,*),yarr=sc(1,*),month=1,xres,yres,sdres,nres
   CCG_DEC2DATE,xres,yr,mo

   FOR j=0,N_ELEMENTS(xres)-1 DO BEGIN
      ; If any flag in the month is preliminary, then plot the whole month as
      ;    preliminary
      f = WHERE(data.yr EQ yr[j] AND data.mo EQ mo[j])
      IF f[0] NE -1 THEN BEGIN
         flags = data[f].flag

         chk = WHERE(STRMID(flags, 2, 1) EQ "P")
         IF chk[0] NE -1 THEN prelim = 1 ELSE prelim = 0
      ENDIF ELSE BEGIN
         ; If the site has no data for the year + site combination,
         ;    then skip it
         CONTINUE
         ;print, STRLOWCASE(arr.desc[i].site_code)
         prelim = 0
      ENDELSE

      PRINTF,fpout,FORMAT='(F9.2,1X,I1,1X,I4.4,1X,I2.2,1X,F8.3,1X,F8.3,1X,I2.2,1X,A6,1X,I1)',$
      arr.desc[i].sinlat,arr.init[i].mbl,$
      yr[j],mo[j],yres[j],sdres[j],nres[j],arr.desc[i].site_code,prelim
   ENDFOR
ENDFOR
IF KEYWORD_SET(datafile) THEN FREE_LUN,fpout
END

PRO IADV_LATGRAD,$ 
   initfile=initfile,$
   prep=prep,$
   sp=sp,$
   yr1=yr1,$
   nologo=nologo,$
   mo1=mo1,$
   yaxis=yaxis,$
   datafile=datafile,$
   saveas=saveas,$
   dev=dev

spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."

srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'
IF KEYWORD_SET(prep) THEN BEGIN
   IADV_LATPREP,sp=sp,initfile=initfile,datafile=datafile
   RETURN
ENDIF

r = CCG_SYSDATE()
mo1 = (NOT KEYWORD_SET(mo1)) ? 1 : mo1
yr1 = (NOT KEYWORD_SET(yr1)) ? r.yr : yr1

yaxis = (NOT KEYWORD_SET(yaxis)) ? '' : yaxis
;
;----------------------------------------------- misc initialization 
;
tmpfile=CCG_TMPNAM()

IF NOT KEYWORD_SET(title) THEN title='Annual Averages!C(CMDL NETWORK MEASUREMENTS)'
IF NOT KEYWORD_SET(legend_coords) THEN legend_coords=[0.20,0.85]
legend_offset=0.035
;
;----------------------------------------------- set up plot device 
;
dev=(KEYWORD_SET(dev)) ? dev : ''

CCG_OPENDEV,dev=dev,pen=pen,/portrait,saveas=saveas, font='Helvetica'

NBINS=41
xpred=FINDGEN(NBINS)*0.05-1

sin=[' ', '-1.0', '-0.8', '-0.6', '-0.4', '-0.2', '0.0', $
       '0.2', '0.4', '0.6', '0.8', '1.0', ' ']
deg=['90!eo!nS', '30!eo!nS', 'EQ', '30!eo!nN', '90!eo!nN']
degv=[-1, -.5, 0, .5, 1]

IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(charsize) THEN charsize=1.5
IF NOT KEYWORD_SET(plotthick) THEN plotthick=5.0
IF NOT KEYWORD_SET(linethick) THEN linethick=4.0

CCG_GASINFO,sp=sp,title=ytitle,/tt_font

ytitle=(KEYWORD_SET(normal2site)) ? '!7D!3'+ytitle : ytitle

label_nudge=(KEYWORD_SET(label_nudge)) ? label_nudge : [1.0,1.0]

format='(F9.2,1X,I4,1X,F8.3,1X,F8.3,1X,I2.2,1X,A6,1X,I1)'
DEFAULT=(-999.999)
;
;**********************************************
;Read monthly mean file
;**********************************************
;
CCG_SREAD,file=datafile,arr

;     0.99 1 1985 06  350.106    1.047 02    ALT

prelim = [0]
site = ['']
slat = [0.0]
mbl  = [0]
yr   = [0]
mo   = [0]
mr   = [0.0]
sd   = [0.0]
n    = [0]

FOR i=0,N_ELEMENTS(arr)-1 DO BEGIN
   CCG_STRTOK,str=arr[i],fields

   j=WHERE((FIX(fields[2]) EQ yr1 AND FIX(fields[3]) EQ mo1))
   IF j[0] EQ -1 THEN CONTINUE

   slat=[slat,FLOAT(fields[0])]
   mbl=[mbl,FIX(fields[1])]
   yr=[yr,FIX(fields[2])]
   mo=[mo,FIX(fields[3])]
   mr=[mr,FLOAT(fields[4])]
   sd=[sd,FLOAT(fields[5])]
   n=[n,FIX(fields[6])]
   site=[site,fields[7]]
   prelim=[prelim,FIX(fields[8])]
ENDFOR
prelim = prelim[1:*]
site = site[1:*]
slat = slat[1:*]
mbl  = mbl[1:*]
yr   = yr[1:*]
mo   = mo[1:*]
mr   = mr[1:*]
sd   = sd[1:*]
n    = n[1:*]
;
;Sort by sine of latitude
;
j=SORT(slat)
prelim = prelim[j]
site = site[j]
slat = slat[j]
mbl  = mbl[j]
yr   = yr[j]
mo   = mo[j]
mr   = mr[j]
sd   = sd[j]
n    = n[j]
;
;----------------------------------------------- draw figure 
;

IF SIZE(yaxis,/DIMENSION) EQ 4 THEN BEGIN
   ey = {  YSTYLE:1,$
      YRANGE:[yaxis[0],yaxis[1]], $
      YTICKS:yaxis[2], $
      YMINOR:yaxis[3]}
ENDIF ELSE BEGIN
   ey = {  YSTYLE:16}
ENDELSE

e = [ey]

IF dev NE '' AND NOT KEYWORD_SET(nologo) THEN BEGIN

   LOADCT,0

   xpos=0.86
   ypos=0.20

   noaa_height=0.085
   height=noaa_height
   portrait_ratio=1.294
   ratio=1.00

   width=portrait_ratio*ratio*height

   READ_JPEG, srcdir+'logos/noaa_color.jpg', /true, a
   TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height

   j=WHERE(['co2c13','co2c14','co2o18','ch4c13'] EQ sp)
   sil = (j[0] NE -1) ? 1 : 0

   IF sil GT 0 THEN BEGIN

      ratio=1.243
      height=noaa_height
      width=portrait_ratio*ratio*height
      xpos=xpos-0.005-width

      READ_JPEG, srcdir+'logos/instaar_logo_white_bg.jpg', /true, a
      TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height
   ENDIF
ENDIF

CCG_RGBLOAD,file=idldir+'data/color_comb1'

PLOT, [slat],[mr], $ 
   POSITION=[0.10,0.15,0.99,0.75],$
   /NODATA, $
   /NOERASE, $
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$

   _EXTRA=e,$

   YTHICK=plotthick,$
   YCHARSIZE=1.0, $
   YTICKLEN = (-0.02),$
   YTITLE=ytitle,$

   XRANGE=[-1.2,1.2], $
   XSTYLE=9, $
   XMINOR=2, $
   XTICKS=12, $
   XTICKLEN = (-0.02),$
   XTHICK=plotthick,$
   XTICKNAME=sin, $
   XCHARSIZE=0.7, $
   XTITLE='SINE LATITUDE'

AXIS, XAXIS=1, $
   XRANGE=[-1.2,1.2], $
   XSTYLE=1, $
   XMINOR=1, $
   XTICKLEN = (-0.02),$
   XTICKV=degv, $
   CHARTHICK=charthick,$
   XTHICK=plotthick,$
   CHARSIZE =charsize*0.70, $
   XTICKNAME=deg

XYOUTS, 0.56, 0.80,$
   'Latitude Distribution',$
   /NORMAL,$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   ALI='0.5'

CCG_DATE2DEC,yr=yr1,mo=mo1,dec=dec

j=WHERE(mbl EQ 1)
;pencolor = (dec LT preliminary) ? pen[3] : pen[140]

IF j[0] NE -1 THEN BEGIN
   FOR jnum = 0, N_ELEMENTS(j)-1 DO BEGIN
      jidx = j[jnum]
      pencolor = (prelim[jidx] EQ 0) ? pen[3] : pen[140]

      CCG_SYMBOL, sym=2,fill=0,thick=3
      PLOTS, slat[jidx],mr[jidx],$
         PSYM=8,$
         SYMSIZE=symsize,$
         COLOR=pencolor
   ENDFOR

   IF NOT KEYWORD_SET(nofit) THEN BEGIN

      f = WHERE(prelim[j] EQ 1)
      pencolor = (f[0] EQ -1) ? pen[3] : pen[140]

      CCG_PPTFIT, xarr=slat[j],$
         yarr=mr[j],$
         xpred=xpred,$
         ypred=ypred

      OPLOT, xpred,ypred,$
         LINESTYLE=0,$
         THICK=linethick,$
         COLOR=pencolor
   ENDIF
ENDIF

j=WHERE(mbl NE 1)
;pencolor = (dec LT preliminary) ? pen[2] : pen[140]

IF j[0] NE -1 THEN BEGIN
   FOR jnum = 0, N_ELEMENTS(j)-1 DO BEGIN
      jidx = j[jnum]
      pencolor = (prelim[jidx] EQ 0) ? pen[2] : pen[140]

      CCG_SYMBOL, sym=10,fill=0,thick=3
      PLOTS, slat[jidx],mr[jidx],$
         PSYM=8,$
         SYMSIZE=symsize,$
         COLOR=pencolor
   ENDFOR
ENDIF

z=IADV_PROJECTPI(project='ccg_surface',sp=sp,site='all')

CCG_PIID, x=0.12,y=0.725,$
      name=[z],$
      color=pen(1),$
      charthick=0.75*charthick

CCG_INT2MONTH,imon=mo1,mon=mon
z = mon + ' ' + STRCOMPRESS(STRING(yr1),/RE)

XYOUTS,0.97,0.715,$
   /NORMAL,$
   z,$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   ALI=1.0
;
;------------------------------------------------close up shop 
;
CCG_CLOSEDEV,dev=dev,saveas=saveas

SPAWN,'rm -f '+tmpfile
END
