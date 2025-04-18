@iadv_clnlib.pro
@ccg_utils.pro

PRO IADV_TS,$

      sp=sp,$
      project=project,$
      site=site,$

      ccggdb=ccggdb,$
      open=open,$
      import=import,$

      nyrs=nyrs,$
      date=date,$

      datafound=datafound,$

      title=title,$
      subtitle=subtitle,$
      postitle=postitle,$
      xaxis=xaxis,$
      yaxis=yaxis,$
      ccgvu=ccgvu,$

      charsize=charsize,$
      charthick=charthick,$

      symtype=symtype,$
      symsize=symsize,$
      symthick=symthick,$
      symfill=symfill,$
      symcolor=symcolor,$

      trtype=trtype,$
      trthick=trthick,$
      trcolor=trcolor,$

      sctype=sctype,$
      scthick=scthick,$
      sccolor=sccolor,$

      showall=showall,$

      linethick=linethick,$
      nonb=nonb,$
      noret=noret,$
      norej=norej,$
      nosc=nosc,$
      notr=notr,$

      grid=grid,$

      saveas=saveas,$
      nolabid=nolabid,$
      noproid=noproid,$
      nopiid=nopiid,$
      noposition=noposition,$
      dev=dev
;
;##############################################
; Procedure Description
;##############################################
;
;Plot variable panel plot of time series data 
;
;##############################################
; Initialization
;##############################################
;
DEFAULT=(-999.999)
datafound=0
npanels=N_ELEMENTS(sp)

sitechk = CLEANSITE(site=site)
IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."

srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'

IF NOT KEYWORD_SET(project) THEN project=MAKE_ARRAY(npanels,/STR,VALUE='ccg_surface')

FOR i=0,npanels-1 DO BEGIN
   spchk = CLEANSP(sp=sp[i])
   IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."
   projectchk = CLEANPROJECT(project=project[i])
   IF ( projectchk NE 1 ) THEN CCG_FATALERR, "Invalid 'project' specified. Exiting ..."
ENDFOR

IF N_ELEMENTS(project) NE npanels THEN CCG_FATALERR,"Sizes of 'sp' and 'project' do not match"

IF KEYWORD_SET(date) THEN BEGIN
   IF N_ELEMENTS(date) EQ 1 THEN date = [date, date]
                                                                                          
   date = LONG(date)
   date[0] = StartDate(date[0])
   date[1] = EndDate(date[1])
ENDIF ELSE BEGIN
   r=CCG_SYSDATE()
                                                                                          
   date = MAKE_ARRAY(2, /LONG)
   date[0] = '19000101'
   date[1] = '99991231'
ENDELSE

showall = (KEYWORD_SET(showall)) ? 1 : 0

xret=0 & yret=0
xnb=0 & ynb=0
xrej=0 & yrej=0
;
;##############################################
; Graphics
;##############################################
;
dev=(KEYWORD_SET(dev)) ? dev : ''

CCG_OPENDEV,dev=dev,pen=pen,saveas=saveas,/portrait, font='Helvetica'

IF KEYWORD_SET(grid) THEN BEGIN
   ticklen=1
   gridstyle=1
ENDIF ELSE BEGIN
   ticklen=(-0.01) 
   gridstyle=0
ENDELSE

IF NOT KEYWORD_SET(noret) THEN noret=0
IF NOT KEYWORD_SET(symtype) THEN symtype=1
IF NOT KEYWORD_SET(symsize) THEN symsize=0.65
IF NOT KEYWORD_SET(symthick) THEN symthick=3.0
IF NOT KEYWORD_SET(symfill) THEN symfill=0
IF NOT KEYWORD_SET(symcolor) THEN symcolor=3

IF NOT KEYWORD_SET(notr) THEN notr=0
IF NOT KEYWORD_SET(trtype) THEN trtype=0
IF NOT KEYWORD_SET(trwidth) THEN trwidth=1
IF NOT KEYWORD_SET(trcolor) THEN trcolor=1

IF NOT KEYWORD_SET(nosc) THEN nosc=0
IF NOT KEYWORD_SET(sctype) THEN sctype=0
IF NOT KEYWORD_SET(scwidth) THEN scwidth=1
IF NOT KEYWORD_SET(sccolor) THEN sccolor=1
IF NOT KEYWORD_SET(xaxis) THEN xaxis=0
IF NOT KEYWORD_SET(yaxis) THEN yaxis=0

IF NOT KEYWORD_SET(charsize) THEN charsize=1.35
IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(linethick) THEN linethick=5.0

IF NOT KEYWORD_SET(grid) THEN grid=0

IF NOT KEYWORD_SET(saveas) THEN saveas=''

CCG_SITEDESCINFO,site=site[0],$
      proj_abbr=project[0],$
      title=t,$
      position=p,$
      sample_ht=s

IF NOT KEYWORD_SET(title) THEN title=t
IF NOT KEYWORD_SET(postitle) THEN postitle=p
IF NOT KEYWORD_SET(subtitle) THEN subtitle=s

pp = REPLICATE({pos:FLTARR(4,4),pi:FLTARR(4),prel:FLTARR(4),logo:0.0,xyz:0.0},4)

pp[0] = {pos:[[0.10,0.15,0.99,0.75],$
      [0.00,0.00,0.00,0.00],$
      [0.00,0.00,0.00,0.00],$
      [0.00,0.00,0.00,0.00]],$
   pi:[0.725,0,0,0],$
   prel:[0.165,0,0,0],$
   logo:0.20,xyz:0.725}

pp[1] = {pos:[[0.10,0.51,0.99,0.99],$
      [0.10,0.01,0.99,0.49],$
      [0.00,0.00,0.00,0.00],$
      [0.00,0.00,0.00,0.00]],$
   pi:[0.965,0.465,0,0],$
   prel:[0.525,0.025,0,0],$
   logo:0.060,xyz:0.965}

pp[2] = {pos:[[0.10,0.68,0.99,0.99],$
      [0.10,0.35,0.99,0.66],$
      [0.10,0.02,0.99,0.33],$
      [0.00,0.00,0.00,0.00]],$
   pi:[0.965,0.635,0.305,0],$
   prel:[0.695,0.365,0.035,0],$
   logo:0.070,xyz:0.965}

pp[3] = {pos:[[0.10,0.76,0.99,0.99],$
      [0.10,0.51,0.99,0.74],$
      [0.10,0.26,0.99,0.49],$
      [0.10,0.01,0.99,0.24]],$
   pi:[0.965,0.715,0.465,0.215],$
   prel:[0.775,0.525,0.275,0.025],$
   logo:0.060,xyz:0.965}

IF dev NE '' THEN BEGIN

   LOADCT,0

   xpos=0.86
   ypos=pp[npanels-1].logo

   noaa_height=0.085
   height=noaa_height
   portrait_ratio=1.294
   ratio=1.00

   width=portrait_ratio*ratio*height

   READ_JPEG, srcdir + 'logos/noaa_color.jpg', /true, a
   TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height

   sil=0
   FOR i=0,npanels-1 DO BEGIN
      j=WHERE(['co2c13','co2c14','co2o18','ch4c13'] EQ sp[i])
      IF j[0] NE -1 THEN sil=1
   ENDFOR

   IF sil GT 0 THEN BEGIN

      ratio=1.243
      height=noaa_height
      width=portrait_ratio*ratio*height
      xpos=xpos-0.005-width

      READ_JPEG, srcdir + 'logos/instaar_logo_white_bg.jpg', /true, a
      TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height
   ENDIF
   ;
   ; Plot cooperating and sponsoring agency logos
   ;
   perlcode=srcdir+'iadv_logos.pl -site='+site+' -project='+project
   SPAWN, perlcode,z
                                                                                          
   logos=STRSPLIT(z,'|',/EXTRACT)

   FOR ilogos=0,N_ELEMENTS(logos)-1 DO BEGIN

      image=STRSPLIT(logos[ilogos],' ',/EXTRACT)

      ; If it is a sil plot, then the instaar logo is already on the plot.
      ;    Skip over it if we are trying to put it on the plot again.
      IF ( image[0] EQ 'instaar_logo_white_bg.jpg' AND sil GT 0 ) THEN CONTINUE       

      IF image[0] NE 'NA' THEN BEGIN

         ; ratio = (logo width)/(logo height)
         ratio=FLOAT(image[1])
         height=noaa_height
         width=portrait_ratio*height

         IF ratio GE 1 THEN height=width/(ratio*portrait_ratio)
         IF height LT 0.6*noaa_height THEN BEGIN
            height=0.6*noaa_height
            width=ratio*portrait_ratio*height
         ENDIF

         IF ratio LT 1 THEN  width=height*ratio*portrait_ratio

         xpos=xpos-0.005-width

         READ_JPEG, srcdir + 'logos/' + image[0], /true, a
         TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height
      ENDIF
   ENDFOR
ENDIF

CCG_RGBLOAD,file=idldir + 'data/color_comb1'

FOR ip=0,npanels-1 DO BEGIN

   IF STRLOWCASE(project[ip]) EQ 'ccg_tower' THEN CONTINUE
   ;
   ;##############################################
   ; Retrieve Data
   ;##############################################
   ;
   SWITCH STRLOWCASE(project[ip]) OF
      'ccg_aircraft':
      'ccg_surface': BEGIN
         CCG_FLASK,$
         site = site, sp = sp[ip],$
         project = project[ip], $
         date = date, $
         /preliminary, /exclusion, data
         BREAK
      END
      'ccg_obs': BEGIN
         IADV_OBS,$
         site = site, sp = sp[ip],$
         date = date, data
         BREAK
      END
   ENDSWITCH

   xret = 0 & yret = 0 & fret = 0
   xnb = 0 & ynb = 0 & fnb = 0
   xrej = 0 & yrej = 0 & frej = 0

   typ = size(data);
   chk = typ(typ(0)+1);

   ; chk
   ;   0:       type = 'Undefined'
   ;   1:       type = 'Byte'
   ;   2:       type = 'Integer'
   ;   4:       type = 'Float'
   ;   3:       type = 'Long'
   ;   5:       type = 'Double'
   ;   6:       type = 'Complex'
   ;   7:       type = 'String'
   ;   8:       type = 'Structure' 
   ; if chk == 8, then data is a structure
   ; data = ((r = SIZE(data, /TYPE)) NE 8)

   IF ( chk EQ 8 ) THEN BEGIN
      ;
      ; Subset of retained data
      ;
      j = WHERE(STRMID(data.flag, 0, 2) EQ "..")
      IF j[0] NE -1 THEN BEGIN
         xret = data[j].date
         yret = data[j].value
         fret = data[j].flag
      ENDIF
      ;
      ; Subset of non-background data
      ;
      j = WHERE(STRMID(data.flag, 1, 1) NE ".")
      IF j[0] NE -1 THEN BEGIN
         xnb = data[j].date
         ynb = data[j].value
         fnb = data[j].flag
      ENDIF
      ;
      ; Subset of rejected data
      ;
      j = WHERE(STRMID(data.flag, 0, 1) NE ".")
      IF j[0] NE -1 THEN BEGIN
         xrej = data[j].date
         yrej = data[j].value
         frej = data[j].flag
      ENDIF
   ENDIF
   ;;
   ;; Determine if any data should be excluded
   ;; Determine preliminary date
   ;;
   ;perlcode=srcdir+'iadv_pi.pl'
   ;SPAWN, perlcode+' -g'+sp[ip]+' -p'+project[ip],tmp
   ;pi_info=STRSPLIT(tmp[0],'|',/EXTRACT)
   ;
   ;;
   ;; TEMPCODE
   ;; Temporary code to grey out all data from LEF, WKT, and AMT
   ;; Note: This only works for flask, because when we are doing
   ;;       PFP sites, the site name is similar to LEF050
   ;;
   ;IF ( STRUPCASE(site) EQ 'LEF' OR STRUPCASE(site) EQ 'WKT' OR STRUPCASE(site) EQ 'AMT' ) THEN BEGIN
   ;   preliminary = '1900-01-01'
   ;ENDIF ELSE BEGIN
   ;   preliminary=pi_info[5]
   ;ENDELSE
   ;
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

   IF KEYWORD_SET(nyrs) THEN BEGIN
      j=WHERE(xret GE MAX(FIX(xret))-nyrs)
      IF j[0] NE -1 THEN BEGIN
         xret=xret[j]
         yret=yret[j]
         fret=fret[j]
      ENDIF
   ENDIF

   IF N_ELEMENTS(xret) GT 1 THEN datafound=datafound+1

   IF KEYWORD_SET(ccgvu) THEN BEGIN
      npoly=ccgvu[0]
      nharm=ccgvu[1]
      interval=ccgvu[2]
      cutoff1=ccgvu[3]
      cutoff2=ccgvu[4]
   ENDIF ELSE BEGIN
      IF sp[ip] EQ 'co2c14' THEN BEGIN
         npoly=2
         nharm=2
         interval=7
         cutoff1=180
         cutoff2=667
      ENDIF ELSE BEGIN
         npoly=3
         nharm=4
         interval=7
         cutoff1=80
         cutoff2=650
      ENDELSE
   ENDELSE
   ;
   ; Don't fit a curve if there are too few data
   ;
   toofew = (N_ELEMENTS(xret) LT 104 OR xret[N_ELEMENTS(xret)-1]-xret[0] LE 2) ? 1 : 0
   ;
   ; Filter published and preliminary data.
   ; Fit a curve to entire record.
   ; Exclude preliminary values that are 3 sigma
   ; from s(t).
   ;
   IF NOT toofew THEN BEGIN
      IADV_QUICKFILTER,x=xret,y=yret,ptr
      j=WHERE(ptr EQ 1)
      xret=xret[j]
      yret=yret[j]
      fret=fret[j]
   ENDIF

   IF NOT toofew THEN CCG_CCGVU, x=xret,y=yret,$
      npoly=npoly,nharm=nharm,$
      interval=interval,$
      cutoff1=cutoff1,cutoff2=cutoff2,$
      even=1,sc=sc,tr=tr
   CCG_GASINFO,sp=sp[ip], title=ytitle, /tt_font

   IF SIZE(yaxis,/DIMENSION) EQ 4 THEN BEGIN
      ey = {  YSTYLE:1,$
         YRANGE:[yaxis[0],yaxis[1]], $
         YTICKS:yaxis[2], $
         YMINOR:yaxis[3]}
   ENDIF ELSE BEGIN
      ey = {  YSTYLE:16}
   ENDELSE
   ;
   ; Prescribe X axis if time span is LE one year
   ;
   IF xret[N_ELEMENTS(xret)-1]-xret[0] LE 1 THEN BEGIN
      xmin=FIX(xret[0])
      xmax=FIX(xret[N_ELEMENTS(xret)-1])+1
      xticks=xmax-xmin
      xminor=(xticks EQ 1) ? 12 : 1
      xaxis=[xmin,xmax,xticks,xminor]
   ENDIF
   ;
   ; Use X axis determined for panel1
   ;
   IF ip NE 0 THEN xaxis=[!X.CRANGE,!X.TICKS,!X.MINOR]

   IF SIZE(xaxis,/DIMENSION) EQ 4 THEN BEGIN
      ex = {  XSTYLE:1,$
         XRANGE:[xaxis[0],xaxis[1]], $
         XTICKS:xaxis[2], $
         XMINOR:xaxis[3]}
   ENDIF ELSE BEGIN
      ex = {  XSTYLE:16}
   ENDELSE

   e=CREATE_STRUCT(ex,ey)

   _title=(ip EQ 0) ? '!n'+title+'!C!D'+subtitle+'!n' : ''
   xcharsize=(ip EQ npanels-1) ? 1.0 : 0.01

   PLOT, [xret],[yret],$
      /NOERASE,$
      POSITION=[pp[npanels-1].pos[*,ip]],$
      /NODATA,$
      COLOR=pen(1),$
      CHARSIZE=charsize,$
      CHARTHICK=charthick,$
      TITLE=_title,$

      _EXTRA=e,$

      YGRIDSTYLE=gridstyle,$
      YTICKLEN=ticklen,$
      YTHICK=linethick,$
      YCHARSIZE=1.0,$

      XGRIDSTYLE=gridstyle,$
      XCHARSIZE=xcharsize,$
      XTICKLEN=ticklen,$
      XTHICK=linethick,$
      XMINOR=xminor,$
      XTITLE='YEAR'

   XYOUTS,$
   !X.CRANGE[0]-0.25*(!X.CRANGE[1]-!X.CRANGE[0])/2.0,$
   !Y.CRANGE[0]+(!Y.CRANGE[1]-!Y.CRANGE[0])/2.0,$
   ytitle,$
   /DATA,$
   ALI=0.5,$
   ORI=90,$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   COLOR=pen(1)

   IF N_ELEMENTS(xret) EQ 1 THEN BEGIN
      XYOUTS,$
      !X.CRANGE[0]+(!X.CRANGE[1]-!X.CRANGE[0])/2.0,$
      !Y.CRANGE[0]+(!Y.CRANGE[1]-!Y.CRANGE[0])/2.0,$
      STRMID(ytitle,0,STRPOS(ytitle,'(')-1)+' measurements from '+STRUPCASE(site)+' are unavailable.',$
      /DATA,$
      ALI=0.5,$
      CHARSIZE=0.75,$
      CHARTHICK=0.75*charthick,$
      COLOR=pen(1)
   ENDIF

   IF noret EQ 0 THEN BEGIN
      j=WHERE(yret GT !Y.CRANGE[1])
      IF j(0) NE -1 THEN yret(j)=!Y.CRANGE[1]
      j=WHERE(yret LT !Y.CRANGE[0])
      IF j(0) NE -1 THEN yret(j)=!Y.CRANGE[0]

      CCG_SYMBOL,   sym=symtype,fill=symfill,thick=symthick

      j=WHERE((r = STRMID(fret, 2, 1)) NE "P")

      IF j[0] NE -1 THEN BEGIN

         OPLOT, xret[j],yret[j],$
            COLOR=pen(3),$
            PSYM=8,$
            SYMSIZE=symsize
      ENDIF

      j=WHERE((r = STRMID(fret, 2, 1)) EQ "P")

      IF j[0] NE -1 THEN BEGIN

         OPLOT, xret[j],yret[j],$
            COLOR=pen(140),$
            PSYM=8,$
            SYMSIZE=symsize

         XYOUTS, 0.12,pp[npanels-1].prel[ip],$
            /NORMAL,$
            '(Preliminary Data shown in GRAY)',$
            COLOR=pen(1),$
            CHARSIZE=0.75,$
            CHARTHICK=0.75*charthick
      ENDIF
   ENDIF

   IF xnb(0) NE 0 AND NOT KEYWORD_SET(nonb) THEN BEGIN

      j=WHERE(ynb GT !Y.CRANGE[1])
      IF j(0) NE -1 THEN ynb(j)=!Y.CRANGE[1]
      j=WHERE(ynb LT !Y.CRANGE[0])
      IF j(0) NE -1 THEN ynb(j)=!Y.CRANGE[0]

      CCG_SYMBOL, sym=10,fill=0,thick=symthick

      j=WHERE((r = STRMID(fnb, 2, 1)) NE "P")

      IF j[0] NE -1 THEN BEGIN
         OPLOT, xnb[j],ynb[j],$
            COLOR=pen(4),$
            PSYM=8,$
            SYMSIZE=symsize
      ENDIF

      j=WHERE((r = STRMID(fnb, 2, 1)) EQ "P")

      IF j[0] NE -1 THEN BEGIN
         OPLOT, xnb[j],ynb[j],$
            COLOR=pen(140),$
            PSYM=8,$
            SYMSIZE=symsize
      ENDIF
   ENDIF

   IF xrej(0) NE 0 AND NOT KEYWORD_SET(norej) THEN BEGIN

      j=WHERE(yrej GT !Y.CRANGE[1])
      IF j(0) NE -1 THEN yrej(j)=!Y.CRANGE[1]
      j=WHERE(yrej LT !Y.CRANGE[0])
      IF j(0) NE -1 THEN yrej(j)=!Y.CRANGE[0]

      CCG_SYMBOL, sym=11,fill=0,thick=symthick

      j=WHERE((r = STRMID(frej, 2, 1)) NE "P")

      IF j[0] NE -1 THEN BEGIN
         OPLOT, xrej[j],yrej[j],$
            COLOR=pen(2),$
            PSYM=8,$
            SYMSIZE=symsize
      ENDIF

      j=WHERE((r = STRMID(frej, 2, 1)) EQ "P")

      IF j[0] NE -1 THEN BEGIN
         OPLOT, xrej[j],yrej[j],$
            COLOR=pen(140),$
            PSYM=8,$
            SYMSIZE=symsize
      ENDIF
   ENDIF

   IF nosc EQ 0 AND NOT toofew THEN BEGIN

      OPLOT, sc(0,*),sc(1,*),$
         COLOR=pen(sccolor),$
         LINESTYLE=sctype,$
         THICK=scthick

      ;j=WHERE(sc(0,*) GE preliminary)
      ;
      ;IF j[0] NE -1 THEN OPLOT, sc(0,j),sc(1,j),$
      ;   COLOR=pen(140),$
      ;   LINESTYLE=sctype,$
      ;   THICK=scthick
   ENDIF

   IF notr EQ 0 AND NOT toofew THEN BEGIN

      OPLOT, tr(0,*),tr(1,*),$
         COLOR=pen(trcolor),$
         LINESTYLE=trtype,$
         THICK=trthick

      ;j=WHERE(tr(0,*) GE preliminary)
      ; 
      ;IF j[0] NE -1 THEN OPLOT, tr(0,j),tr(1,j),$
      ;   COLOR=pen(140),$
      ;   LINESTYLE=trtype,$
      ;   THICK=trthick
   ENDIF

   IF (NOT KEYWORD_SET(nopiid) AND N_ELEMENTS(xret) GT 1) THEN BEGIN
      z=IADV_PROJECTPI(project=project[ip],sp=sp[ip],site=site)

      CCG_PIID, x=0.12,y=pp[npanels-1].pi[ip],$
         name=[z],$
         color=pen(1),$
         charthick=0.75*charthick
   ENDIF

ENDFOR


IF NOT KEYWORD_SET(noposition) THEN BEGIN
   XYOUTS, 0.97,pp[npanels-1].xyz,$
      postitle,$
      /NORMAL,$
      ALI=1.0,$
      COLOR=pen(1),$
      CHARSIZE=0.75,$
      CHARTHICK=0.75*charthick
ENDIF

IF NOT KEYWORD_SET(noproid) THEN CCG_PROID,y=(-0.05)
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev,saveas=saveas
END
