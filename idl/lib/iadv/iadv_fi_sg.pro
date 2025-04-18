@iadv_clnlib.pro
@ccg_utils.pro

PRO   IADV_FI_SG,$

      sp=sp,$
      site=site,$

      datafound=datafound,$

      showmethod = showmethod, $
      showstats = showstats, $
      custom = custom, $

      str_xaxis = str_xaxis, $
      str_yaxis = str_yaxis, $
      str_dyaxis = str_dyaxis, $

      xaxis=xaxis,$
      yaxis=yaxis,$
      dyaxis=dyaxis,$

      title=title,$
      postitle=postitle,$
      ccgvu=ccgvu,$

      charsize=charsize,$
      charthick=charthick,$

      symsize=symsize,$

      trtype=trtype,$
      trthick=trthick,$
      trcolor=trcolor,$

      sctype=sctype,$
      scthick=scthick,$
      sccolor=sccolor,$

      showall=showall,$

      linethick=linethick,$
      noposition=noposition,$
      nolegend=nolegend,$
      noret=noret,$
      norej=norej,$
      nosc=nosc,$
      notr=notr,$

      grid=grid,$

      saveas=saveas,$
      nolabid=nolabid,$
      noproid=noproid,$
      nopiid=nopiid,$
      dev=dev
;
;##############################################
; Procedure Description
;##############################################
;
;Plot flask and in situ hourly averages, and differences
;
;##############################################
; Initialization
;##############################################
;
datafound=0
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
perlcode=dbdir+'ccg_query.pl'
tmpfile=CCG_TMPNAM('/tmp/');

IF NOT KEYWORD_SET(site) THEN CCG_FATALERR, "'site' must be specified, i.e., site='spo'.  Exiting ..."
site=STRLOWCASE(site)
sitechk = CLEANSITE(site=site)
IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."

IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR, "'sp' must be specified, i.e., sp='co'.  Exiting ..."
spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."

r=CCG_SYSDATE()

IF NOT KEYWORD_SET(noret) THEN noret=0

showmethod = (KEYWORD_SET(showmethod)) ? 1 : 0
showstats = (KEYWORD_SET(showstats)) ? 1 : 0
custom = (KEYWORD_SET(custom)) ? 'CUSTOM GRAPH' : ''

showall = (KEYWORD_SET(showall)) ? 1 : 0

IF NOT KEYWORD_SET(xaxis) THEN xaxis=0
IF NOT KEYWORD_SET(yaxis) THEN yaxis=0
IF NOT KEYWORD_SET(dyaxis) THEN dyaxis=0

IF KEYWORD_SET(str_xaxis) THEN BEGIN
   tmp=STRSPLIT(str_xaxis,',',/EXTRACT)
   xaxis=[FLOAT(tmp[0]),FLOAT(tmp[1]),FIX(tmp[2]),FIX(tmp[3])]
ENDIF

IF KEYWORD_SET(str_yaxis) THEN BEGIN
   tmp=STRSPLIT(str_yaxis,',',/EXTRACT)
   yaxis=[FLOAT(tmp[0]),FLOAT(tmp[1]),FIX(tmp[2]),FIX(tmp[3])]
ENDIF

IF KEYWORD_SET(str_dyaxis) THEN BEGIN
   tmp=STRSPLIT(str_dyaxis,',',/EXTRACT)
   dyaxis=[FLOAT(tmp[0]),FLOAT(tmp[1]),FIX(tmp[2]),FIX(tmp[3])]
ENDIF


IF SIZE(xaxis,/DIMENSION) EQ 4 THEN BEGIN
   xmin = xaxis[0]
   xmax = xaxis[1]
   xticks = xaxis[2]
   xminor = xaxis[3]
ENDIF ELSE BEGIN
   xmin = r.yr - 3
   xmax = r.yr
ENDELSE

IF NOT KEYWORD_SET(symsize) THEN symsize=1.0
IF NOT KEYWORD_SET(charsize) THEN charsize=1.35
IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(linethick) THEN linethick=5.0

IF NOT KEYWORD_SET(grid) THEN grid=0

IF NOT KEYWORD_SET(saveas) THEN saveas=''

CCG_SITEDESCINFO,  site=site,$
                   proj_abbr='obs',$
                   title=t,$
                   position=p,$
                   sample_ht=s

IF NOT KEYWORD_SET(title) THEN title=t
IF NOT KEYWORD_SET(subtitle) THEN subtitle=''
IF NOT KEYWORD_SET(postitle) THEN postitle=p
;;
;; Determine if any data should be excluded
;; Determine preliminary date
;;
;perlcode=srcdir+'iadv_pi.pl'
;SPAWN, perlcode+' -g'+sp+' -pobs',tmp
;pi_info=STRSPLIT(tmp[0],'|',/EXTRACT)
;
;preliminary=pi_info[5]
;tmp=STRSPLIT(preliminary,'-',/EXTRACT)
;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
;dy=FIX(tmp[2]),hr=12,mn=0,dec=preliminary
;
;preliminary = (showall EQ 1) ? 9999.9 : preliminary
;
;exclusion=(N_ELEMENTS(pi_info) EQ 7) ? pi_info[6] : '9999-12-31'
;tmp=STRSPLIT(exclusion,'-',/EXTRACT)
;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
;dy=FIX(tmp[2]),hr=12,mn=0,dec=exclusion
;
;##############################################
; Query DB for matched flask and in situ data
;##############################################
;
code=srcdir+'iadv_flask_insitu.pl'
str=code+' -all -site='+site+' -parameter='+sp
str=str+' -date='+STRCOMPRESS(STRING(xmin),/RE)+','+STRCOMPRESS(STRING(xmax-1),/RE)
str=str+' -outfile='+tmpfile
print, str
SPAWN,str

; 2007.103704338 2007-02-07 20:27:00 1994-99 S 2007-03-02 11:45:00 383.7700 ..P L3 383.460 0.060 ..P

CCG_READ,file=tmpfile,z

IF SIZE(z, /TYPE) NE 8 THEN CCG_FATALERR,"No flask insitu data for site '"+site+"' and gas '"+sp+"'. Exiting..."

x_comp = z.field1
fl_me_comp = z.field5
fl_y_comp = z.field8
fl_f_comp = z.field9
is_y_comp = z.field11
is_f_comp = z.field13
;
;##############################################
; Query DB for flask data
;##############################################
;
CCG_FLASK,$
site=site, sp=sp,$
project='ccg_surface',$
/preliminary,/exclusion,$
date=[xmin,xmax-1], fl_data

fl_x = 0 & fl_y = 0 & fl_f = ''
IF ( SIZE(fl_data,/TYPE) EQ 8 ) THEN BEGIN
   j=WHERE(STRMID(fl_data.flag, 0, 2) EQ "..")
   fl_x=REFORM(fl_data[j].date);
   fl_y=REFORM(fl_data[j].value);
   fl_f=REFORM(fl_data[j].flag);
ENDIF

;
;##############################################
; Query DB for in situ data
;##############################################
;
code=srcdir+'iadv_getobs.pl'
str=code+' -site='+site+' -parameter='+sp+' -timeres=hr'
str=str+' -date='+STRCOMPRESS(STRING(xmin),/RE)+','+STRCOMPRESS(STRING(xmax-1),/RE)
str=str+' -outfile='+tmpfile+' -flag=.._ -all'

print, str
SPAWN, str

is_x = 0 & is_y = 0 & is_f = ''

CCG_READ,file=tmpfile,z
is_x=REFORM(z.field1)
is_y=REFORM(z.field4)
is_f=REFORM(z.field6)

IF N_ELEMENTS(is_x) EQ 1 AND N_ELEMENTS(fl_x) EQ 1 THEN RETURN
;
;----------------------------------------------- set up plot device 
;
dev=(KEYWORD_SET(dev)) ? dev : ''

CCG_OPENDEV,dev=dev,pen=pen,saveas=saveas,/portrait, font='Helvetica'
DEFAULT=(-999.999)

IF KEYWORD_SET(grid) THEN BEGIN
   ticklen=1
   gridstyle=1
ENDIF ELSE BEGIN
   ticklen=(-0.02)
   gridstyle=0
ENDELSE

CCG_GASINFO,   sp=sp, title=ytitle, /tt_font

IF SIZE(yaxis,/DIMENSION) EQ 4 THEN BEGIN
   ey = {  YSTYLE:1,$
      YRANGE:[yaxis[0],yaxis[1]], $
      YTICKS:yaxis[2], $
      YMINOR:yaxis[3]}
ENDIF ELSE BEGIN
   ey = {  YSTYLE:16}
ENDELSE

IF SIZE(xaxis,/DIMENSION) EQ 4 THEN BEGIN
   ex = {  XSTYLE:1, $
           XRANGE:[xmin, xmax], $
           XTICKS:xticks, $
           XMINOR:xminor}
ENDIF ELSE BEGIN
   ex = {  XSTYLE : 16 }
ENDELSE

e=CREATE_STRUCT(ex,ey)
;
;**********************************
;Place logo
;**********************************
;
IF dev NE '' THEN BEGIN
   READ_JPEG, srcdir + 'logos/noaa_color.jpg', dither=1, a
   TVSCL,a,/true,0.860,0.02,/normal,xsize=0.10999,ysize=0.085
ENDIF
;
;**********************************
;First Frame
;**********************************
;
PLOT,    [MIN(is_x),MAX(is_x),MIN(fl_x),MAX(fl_x)],$
         [MIN(is_y),MAX(is_y),MIN(fl_y),MAX(fl_y)],$
   /NOERASE,$
   /NODATA, $
   POSITION=[0.10,0.51,0.99,0.99],$

   CHARTHICK=charthick,$
   CHARSIZE=charsize,$
   COLOR=pen(1), $
   TITLE=title, $

   _EXTRA=e,$

   YCHARSIZE=1.0, $
   YTHICK=linethick,$
   YTICKLEN=ticklen,$
   YTITLE=ytitle,$

   XTICKLEN=ticklen,$
   XCHARSIZE=0.01, $
   XTHICK=linethick

IF NOT KEYWORD_SET(noret) THEN BEGIN

   j=WHERE((r = STRMID(is_f, 2, 1)) EQ "P")
   IF j[0] NE -1 THEN BEGIN

     CCG_SYMBOL, sym=10,fill=0,thick=2
     OPLOT,      is_x[j],is_y[j],$
                 COLOR=pen(140),$
                 PSYM=8,$
                 SYMSIZE=0.4*symsize
   ENDIF

   j=WHERE((r = STRMID(is_f, 2, 1)) NE "P")
   IF j[0] NE -1 THEN BEGIN

     CCG_SYMBOL, sym=10,fill=0,thick=2
     OPLOT,      is_x[j],is_y[j],$
                 COLOR=pen(5),$
                 PSYM=8,$
                 SYMSIZE=0.4*symsize
   ENDIF
ENDIF

IF NOT KEYWORD_SET(noret) AND N_ELEMENTS(fl_x) GT 1 THEN BEGIN

   j=WHERE((r = STRMID(fl_f, 2, 1)) EQ "P")
   IF j[0] NE -1 THEN BEGIN

     CCG_SYMBOL, sym=2,fill=0,thick=2
     OPLOT,      fl_x[j],fl_y[j],$
                 COLOR=pen(140),$
                 PSYM=8,$
                 SYMSIZE=0.4*symsize
   ENDIF

   j=WHERE((r = STRMID(fl_f, 2, 1)) NE "P")
   IF j[0] NE -1 THEN BEGIN

     CCG_SYMBOL, sym=2,fill=0,thick=2
     OPLOT,      fl_x[j],fl_y[j],$
                 COLOR=pen(2),$
                 PSYM=8,$
                 SYMSIZE=0.4*symsize
   ENDIF
ENDIF

CCG_SLEGEND,   x=0.13,y=0.965,$
      tarr=['Flask','In Situ'],$
      carr=[pen(2),pen(5)],$
      sarr=[2,10],$
      thick = 2, $
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick
;
;**********************************
;Second Frame
;**********************************
;
IF SIZE(dyaxis,/DIMENSION) EQ 4 THEN BEGIN
   ey = {  YSTYLE:1,$
           YRANGE:[dyaxis[0],dyaxis[1]], $
           YTICKS:dyaxis[2], $
           YMINOR:dyaxis[3]}
ENDIF ELSE BEGIN
   ey = {  YSTYLE:16}
ENDELSE

e=CREATE_STRUCT(ex,ey)

; Compute differences

diff = fl_y_comp - is_y_comp

r = MOMENT(diff)
sd = SQRT(r[1])

; Exclude differences exceeding 3 * sd when autoscaling

j = WHERE(ABS(diff) LE (3 * sd))

PLOT,x_comp[j], diff[j],$
   /NODATA, $
   /NOERASE,$
   POSITION=[0.10,0.01,0.99,0.49],$

   /NOCLIP, $

   CHARTHICK=charthick,$
   CHARSIZE=charsize,$
   COLOR=pen(1), $

   _EXTRA=e,$

   YCHARSIZE=1.0, $
   YTHICK=linethick,$
   YTICKLEN=(-0.01),$
   YTITLE = '!7D!3' + ytitle,$

   XTICKLEN=(-0.01),$
   XCHARSIZE=1.0, $
   XTHICK=linethick,$
   XTITLE='YEAR'

   OPLOT,   !X.CRANGE,[0,0],$
   LINESTYLE=1,$
   COLOR=pen(1)

   CCG_SYMBOL,   sym=10,fill=0,thick=2

   ; Plot differences exceeding +/- 3*sigma at ymin and ymax

   j = WHERE(diff LT !Y.CRANGE[0])
   IF j[0] NE -1 THEN diff[j] = !Y.CRANGE[0]

   j = WHERE(diff GT !Y.CRANGE[1])
   IF j[0] NE -1 THEN diff[j] = !Y.CRANGE[1]

   ; non-preliminary data in color 

   j=WHERE((r = STRMID(fl_f_comp, 2, 1)) NE "P" AND (s = STRMID(is_f_comp, 2, 1)) NE "P")

   IF j[0] NE -1 THEN BEGIN

      IF showmethod THEN BEGIN
         FOR ii = 0, N_ELEMENTS(j) - 1 DO BEGIN

            XYOUTS,  x_comp[j[ii]], diff[j[ii]], $
               fl_me_comp[j[ii]], $
               /DATA, $
               ALI = 0.5, $
               COLOR=pen[3], $
               /NOCLIP, $
               CHARSIZE=0.55*charsize,$
               CHARTHICK=0.75*charthick
         ENDFOR
      ENDIF ELSE BEGIN

         OPLOT,   x_comp[j], diff[j],$
                  COLOR=pen(3),$
                  /NOCLIP, $
                  PSYM=8,$
                  SYMSIZE=0.75*symsize
      ENDELSE
   ENDIF

   ; preliminary data in gray

   j=WHERE((r = STRMID(fl_f_comp, 2, 1)) EQ "P" OR (s = STRMID(is_f_comp, 2, 1)) EQ "P")

   IF j[0] NE -1 THEN BEGIN
      IF showmethod THEN BEGIN
         FOR ii = 0, N_ELEMENTS(j) - 1 DO BEGIN

            XYOUTS,  x_comp[j[ii]], diff[j[ii]], $
               fl_me_comp[j[ii]], $
               /DATA, $
               ALI = 0.5, $
               COLOR=pen[8], $
               /NOCLIP, $
               CHARSIZE=0.55*charsize,$
               CHARTHICK=0.75*charthick
         ENDFOR
      ENDIF ELSE BEGIN

         OPLOT,   x_comp[j], diff[j],$
               COLOR=pen(140),$
               /NOCLIP, $
               PSYM=8,$
               SYMSIZE=0.75*symsize
      ENDELSE
   ENDIF

j=WHERE((r = STRMID(fl_f_comp, 2, 1)) EQ "P" AND (s = STRMID(is_f_comp, 2, 1)) EQ "P")
IF j[0] NE -1 THEN BEGIN
   XYOUTS,   0.12,0.025,$
      /NORMAL,$
      '(Preliminary Data shown in GRAY)',$
      COLOR=pen(1),$
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick
ENDIF

IF showstats THEN BEGIN
   ; Look at difference by year

   dx = xmax - xmin
   IF dx LT 5 THEN fract = 0.85
   IF dx GE 5 AND dx LT 10 THEN fract = 0.50
   IF dx GE 10 THEN fract = 0.25

   FOR i = xmin, xmax DO BEGIN
       
      ; Exclude differences exceeding 3 * sd (fliers)

      j = WHERE(FIX(x_comp) EQ i AND ABS(diff) LT (3 * sd))
      IF j[0] EQ -1 THEN CONTINUE

      r = MOMENT(diff[j])

      XYOUTS, i + 0.5, 0.40 * !Y.CRANGE[0], /DATA, $
         ToString(STRING(FORMAT = '(F5.2, A, F5.2, 1X, A1,I,A1)', r[0], '!9+!3', SQRT(r[1]))) + $
         ' (' + ToString(N_ELEMENTS(j)) + ')', $
         ALI=0.5, $
         CHARSIZE=fract*charsize,$
         CHARTHICK=0.75*charthick
   ENDFOR
ENDIF

IF NOT KEYWORD_SET(noposition) THEN BEGIN
   XYOUTS,   0.97,0.965,$
      postitle,$
      /NORMAL,$
      ALI=1.0,$
      COLOR=pen(1),$
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick
ENDIF

XYOUTS,   0.12,0.465,$
   /NORMAL,$
   'Flask minus In Situ',$
   COLOR=pen(3),$
   CHARSIZE=0.75*charsize,$
   CHARTHICK=0.75*charthick

IF NOT KEYWORD_SET(nopiid) THEN BEGIN
   z1=IADV_PROJECTPI(project='ccg_surface',sp=sp,site=site)
   z2=IADV_PROJECTPI(project='ccg_obs',sp=sp,site=site)
   z=(z1 EQ z2) ? z1 : [z1,z2]

   CCG_PIID,    x=0.97,y=0.465,$
         ALI=1.0,$
         name=z,$
         color=pen(1),$
         charthick=0.75*charthick
ENDIF

IF custom NE '' THEN BEGIN
   XYOUTS,   0.97,0.525,$
      /NORMAL,$
      ALI=1.0,$
      custom, $
      COLOR=pen(1),$
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick
ENDIF
   
;
;------------------------------------------------ labels
;
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID,y=(-0.05)
;
;----------------------------------------------- close up shop 
;
SPAWN,"rm -f "+tmpfile
datafound=datafound+1
CCG_CLOSEDEV,   dev=dev,saveas=saveas
END
