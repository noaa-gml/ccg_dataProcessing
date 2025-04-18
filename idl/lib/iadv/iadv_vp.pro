@iadv_clnlib.pro
@ccg_utils.pro

PRO   IADV_VP,$

      sp=sp,$
      project=project,$
      site=site,$

      ccggdb=ccggdb,$
      open=open,$
      import=import,$

      datetime=datetime,$

      datafound=datafound,$

      title=title,$
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
      nodot2dot=nodot2dot,$

      grid=grid,$

      saveas=saveas,$
      nolabid=nolabid,$
      noproid=noproid,$
      nopiid=nopiid,$
      noposition=noposition,$
      notitle=notitle,$
      nosubtitle=nosubtitle,$
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
srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'
npanels=N_ELEMENTS(sp)

ex="iadv_vp, sp='co2',site='car',project='ccg_aircraft',datetime='2002-01-11|15:26:00~2002-01-11|16:15:00'"

IF NOT KEYWORD_SET(datetime) THEN CCG_FATALERR,ex
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR,ex
IF NOT KEYWORD_SET(site) THEN CCG_FATALERR,ex
IF NOT KEYWORD_SET(project) THEN project='ccg_aircraft'

IF N_ELEMENTS(datetime) EQ 1 THEN datetime=MAKE_ARRAY(npanels,/STR,VALUE=datetime)
IF N_ELEMENTS(site) EQ 1 THEN site=MAKE_ARRAY(npanels,/STR,VALUE=site)
IF N_ELEMENTS(project) EQ 1 THEN project=MAKE_ARRAY(npanels,/STR,VALUE=project)

FOR i=0,npanels-1 DO BEGIN
   spchk = CLEANSP(sp=sp[i])
   IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."
   sitechk = CLEANSITE(site=site[i])
   IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."
   projectchk = CLEANPROJECT(project=project[i])
   IF ( projectchk NE 1 ) THEN CCG_FATALERR, "Invalid 'project' specified. Exiting ..."
ENDFOR

r=CCG_SYSDATE()
IF NOT KEYWORD_SET(yr1) THEN yr1=(r.yr-5)
IF NOT KEYWORD_SET(yr2) THEN yr2=(9999)

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
   ticklen=(-0.02) 
   gridstyle=0
ENDELSE

IF NOT KEYWORD_SET(noret) THEN noret=0
IF NOT KEYWORD_SET(nonb) THEN nonb=0
IF NOT KEYWORD_SET(norej) THEN norej=0

IF NOT KEYWORD_SET(symtype) THEN symtype=1
IF NOT KEYWORD_SET(symsize) THEN symsize=0.65
IF NOT KEYWORD_SET(symthick) THEN symthick=3.0
IF NOT KEYWORD_SET(symfill) THEN symfill=0
IF NOT KEYWORD_SET(symcolor) THEN symcolor=3

IF NOT KEYWORD_SET(xaxis) THEN xaxis=0
IF NOT KEYWORD_SET(yaxis) THEN yaxis=0

IF NOT KEYWORD_SET(charsize) THEN charsize=1.5-(0.15*(npanels-1))
IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(linethick) THEN linethick=5.0

IF NOT KEYWORD_SET(grid) THEN grid=0

IF NOT KEYWORD_SET(saveas) THEN saveas=''

maxpanels=6

pp = REPLICATE(   {pos:FLTARR(4,maxpanels),$
      pi:FLTARR(2,maxpanels),$
      prel:FLTARR(2,maxpanels),$
      xyz:FLTARR(2,maxpanels),$
      logo:0.0},$
      maxpanels)

pp[0] = {pos:[[0.10,0.01,0.99,0.99],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00]],$
         pi:[[0.12,0.965], [0,0], [0,0], [0,0], [0,0], [0,0]],$
    prel:[[0.12,0.025], [0,0], [0,0], [0,0], [0,0], [0,0]],$
    xyz:[[0.97,0.965],[0,0],[0,0],[0,0],[0,0],[0,0]],$
    logo:0.060}

pp[1] = {pos:[[0.10,0.01,0.50,0.99],$
              [0.59,0.01,0.99,0.99],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00]],$
         pi:[[0.12,0.965], [0.61,0.965], [0,0], [0,0], [0,0], [0,0]],$
    prel:[[0.12,0.025], [0.61,0.025], [0,0], [0,0], [0,0], [0,0]],$
    xyz:[[0.48,0.965],[0.97,0.965],[0,0],[0,0],[0,0],[0,0]],$
    logo:0.060}


pp[2] = {pos:[[0.10,0.54,0.50,0.99],$
              [0.59,0.54,0.99,0.99],$
              [0.10,0.01,0.50,0.46],$
              [0.59,0.01,0.99,0.46],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00]],$
         pi:[[0.12,0.965], [0.61,0.965], [0.12,0.435], [0,0], [0,0], [0,0]],$
    prel:[[0.12,0.560], [0.61,0.560], [0.12,0.025], [0,0], [0,0], [0,0]],$
    xyz:[[0.48,0.965],[0.97,0.965],[0.48,0.435],[0,0],[0,0],[0,0]],$
    logo:0.060}

pp[3] = {pos:[[0.10,0.54,0.50,0.99],$
              [0.59,0.54,0.99,0.99],$
              [0.10,0.01,0.50,0.46],$
              [0.59,0.01,0.99,0.46],$
              [0.00,0.00,0.00,0.00],$
              [0.00,0.00,0.00,0.00]],$
         pi:[[0.12,0.965], [0.61,0.965], [0.12,0.435], [0.61,0.435], [0,0], [0,0]],$
    prel:[[0.12,0.560], [0.61,0.560], [0.12,0.025], [0.61,0.025], [0,0], [0,0]],$
    xyz:[[0.48,0.965],[0.97,0.965],[0.48,0.435],[0.970,0.435],[0,0],[0,0]],$
    logo:0.060}

pp[4] = {pos:[[0.10,0.54,0.363,0.99],$
              [0.413,0.54,0.676,0.99],$
              [0.726,0.54,0.99,0.99],$
              [0.10,0.01,0.36,0.46],$
              [0.41,0.01,0.67,0.46],$
              [0.72,0.01,0.99,0.46]],$
         pi:[[0.12,0.965], [0.43,0.965], [0.74,0.965],[0.12,0.435], [0.43,0.435], [0.74,0.435]],$
    prel:[[0.12,0.560], [0.43,0.560], [0.74,0.560], [0.12,0.025], [0.43,0.025], [0.74,0.025]],$
    xyz:[[0.343,0.965],[0.656,0.965],[0.97,0.965],[0.343,0.435],[0.656,0.435],[0.970,0.435]],$
    logo:0.060}

pp[5] = {pos:[[0.10,0.54,0.363,0.99],$
              [0.413,0.54,0.676,0.99],$
              [0.726,0.54,0.99,0.99],$
              [0.10,0.01,0.36,0.46],$
              [0.41,0.01,0.67,0.46],$
              [0.72,0.01,0.99,0.46]],$
         pi:[[0.12,0.965], [0.43,0.965], [0.74,0.965],[0.12,0.435], [0.43,0.435], [0.74,0.435]],$
    prel:[[0.12,0.560], [0.43,0.560], [0.74,0.560], [0.12,0.025], [0.43,0.025], [0.74,0.025]],$
    xyz:[[0.343,0.965],[0.656,0.965],[0.97,0.965],[0.343,0.435],[0.656,0.435],[0.970,0.435]],$
    logo:0.060}

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
ENDIF

CCG_RGBLOAD,file=idldir + 'data/color_comb1'

FOR ip=0,npanels-1 DO BEGIN

   CCG_SITEDESCINFO,site=site[ip],$
                    proj_abbr=project[ip],$
                    title=title,$
                    position=postitle,$
                    sample_ht=subtitle,$
                    lst2utc=lst2utc

   tmp=STRSPLIT(datetime[ip],'~',/EXTRACT)

   ; Extract first datetime
   dt1tmp=STRSPLIT(tmp[0],'|',/EXTRACT)

   ; Extract date from first datetime
   d1tmp=STRSPLIT(dt1tmp[0],'-',/EXTRACT)

   ; Create the date string
   CCG_INT2MONTH,imon=FIX(d1tmp[1]),mon=mon,/full
   strdate=mon+' '+d1tmp[2]+', '+d1tmp[0]

   ;
   ;##############################################
   ; Retrieve Data
   ;##############################################
   ;
   ;/projects/src/db/ccg_flask.pl -event="vp:2006-07-15,15:42:00" -site=vaa
   ; -parameter=co2 -preliminary -exclusion -stdout

   ;ccg_flask,site='rta',sp='co2',$
   ;vp='2007-08-05,20:46:00',/preliminary,$
   ;/exclusion,data

   IF STRLOWCASE(project[ip]) NE 'ccg_aircraft' THEN CONTINUE

   CCG_FLASK,$
   site = site[ip], sp = sp[ip],$
   vp = dt1tmp[0]+','+dt1tmp[1],$
   project = project[ip], $
   /preliminary, /exclusion, data

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
      ; Determine unique instrument IDs
      ;
      instarr = data.inst
      instarr = instarr[uniq(instarr[sort(instarr)])]
      ;
      ; Subset of retained data
      ;
      j = WHERE(STRMID(data.flag, 0, 2) EQ "..")
      IF j[0] NE -1 THEN BEGIN
         xret = data[j].value
         yret = data[j].alt / 1000.
         zret = data[j].hr
         fret = data[j].flag 
      ENDIF 
      ;
      ; Subset of non-background data
     ;
      j = WHERE(STRMID(data.flag, 1, 1) NE ".")
      IF j[0] NE -1 THEN BEGIN
         xnb = data[j].value
         ynb = data[j].alt / 1000.
         znb = data[j].hr
         fnb = data[j].flag
      ENDIF
      ;
      ; Subset of rejected data
      ;
      j = WHERE(STRMID(data.flag, 0, 1) NE ".")
      IF j[0] NE -1 THEN BEGIN
         xrej = data[j].value
         yrej = data[j].alt / 1000.
         zrej = data[j].hr
         frej = data[j].flag
      ENDIF
   ENDIF

   ;print, site[ip]
   ;print, sp[ip]
   ;print, datetime[ip]
   ;print, project[ip]

   j=SORT(yret)
   xret=xret[j]
   yret=yret[j]

   IF N_ELEMENTS(xret) GT 1 THEN datafound=datafound+1

   tmin = (9999D) & tmax = (-9999D)

   CCG_GASINFO, sp=sp[ip], title=ytitle, /tt_font

   IF SIZE(yaxis,/DIMENSION) EQ 4 THEN BEGIN
      ey = {  YSTYLE:1,$
         YRANGE:[yaxis[0],yaxis[1]], $
         YTICKS:yaxis[2], $
         YMINOR:yaxis[3]}
   ENDIF ELSE BEGIN
      ey = {  YSTYLE:1,$
         YRANGE:[0,12], $
         YTICKS:6, $
         YMINOR:2}
   ENDELSE

   IF SIZE(xaxis,/DIMENSION) EQ 4 THEN BEGIN
      ex = {  XSTYLE:1,$
         XRANGE:[xaxis[0],xaxis[1]], $
         XTICKS:xaxis[2], $
         XMINOR:xaxis[3]}
   ENDIF ELSE BEGIN
      ex = {  XSTYLE:16}
   ENDELSE

   e=CREATE_STRUCT(ex,ey)

   _title=(ip EQ 0) ? title : ''
   _subtitle=(ip EQ npanels-1) ? subtitle : ''

   _ytitle=(pp[npanels-1].pos[0,ip] EQ MIN(pp[npanels-1].pos[0,0:npanels-1])) ? 'Altitude (km)' : ''

   _title = (KEYWORD_SET(notitle)) ? '' : _title
   _subtitle = (KEYWORD_SET(nosubtitle)) ? '' : _subtitle

   PLOT, [xret],[yret],$
         /NOERASE,$
         POSITION=[pp[npanels-1].pos[*,ip]],$
         /NODATA,$
         COLOR=pen(1),$
         CHARSIZE=charsize,$
         CHARTHICK=charthick,$
;         TITLE=_title,$
;         SUBTITLE=_subtitle,$

         _EXTRA=e,$

         YGRIDSTYLE=gridstyle,$
         YTICKLEN=ticklen,$
         YTHICK=linethick,$
         YCHARSIZE=1.0,$
         YTITLE=_ytitle,$

         XGRIDSTYLE=gridstyle,$
         XCHARSIZE=0.75,$
         XTICKLEN=ticklen,$
         XTHICK=linethick,$
         XMINOR=xminor,$
         XTITLE=ytitle

   IF N_ELEMENTS(xret) EQ 1 AND N_ELEMENTS(xnb) EQ 1 THEN BEGIN
      XYOUTS,$
      !X.CRANGE[0]+(!X.CRANGE[1]-!X.CRANGE[0])/2.0,$
      !Y.CRANGE[0]+(!Y.CRANGE[1]-!Y.CRANGE[0])/2.0,$
      STRMID(ytitle,0,STRPOS(ytitle,'(')-1)+' measurements from!C'+STRUPCASE(site)+' are unavailable.',$
      /DATA,$
      ALI=0.5,$
      COLOR=pen(1),$
      CHARSIZE=0.75,$
      CHARTHICK=0.25*charthick
      ; When the text is put in the middle of the plot,
      ; the convert messes up the character thickness
   ENDIF


   FOR iinst=0,N_ELEMENTS(instarr)-1 DO BEGIN

      inst = instarr[iinst]

      typ = size(data);
      chk = typ(typ(0)+1);

      IF ( chk EQ 8 ) THEN BEGIN
         ;
         ; Subset of retained data
         ;
         j = WHERE(STRMID(data.flag, 0, 2) EQ ".." AND data.inst EQ inst)
         IF j[0] NE -1 THEN BEGIN
            xret = data[j].value
            yret = data[j].alt / 1000.
            zret = data[j].hr
            fret = data[j].flag 
         ENDIF 
         ;
         ; Subset of non-background data
         ;
         j = WHERE(STRMID(data.flag, 1, 1) NE "." AND data.inst EQ inst)
         IF j[0] NE -1 THEN BEGIN
            xnb = data[j].value
            ynb = data[j].alt / 1000.
            znb = data[j].hr
            fnb = data[j].flag
         ENDIF
         ;
         ; Subset of rejected data
         ;
         j = WHERE(STRMID(data.flag, 0, 1) NE "." AND data.inst EQ inst)
         IF j[0] NE -1 THEN BEGIN
            xrej = data[j].value
            yrej = data[j].alt / 1000.
            zrej = data[j].hr
            frej = data[j].flag
         ENDIF
      ENDIF

      IF noret EQ 0 AND N_ELEMENTS(xret) GT 1 THEN BEGIN

         j=WHERE(xret GT !X.CRANGE[1])
         IF j(0) NE -1 THEN xret(j)=!X.CRANGE[1]
         j=WHERE(xret LT !X.CRANGE[0])
         IF j(0) NE -1 THEN xret(j)=!X.CRANGE[0]

         j=WHERE(yret GT !Y.CRANGE[1])
         IF j(0) NE -1 THEN yret(j)=!Y.CRANGE[1]
         j=WHERE(yret LT !Y.CRANGE[0])
         IF j(0) NE -1 THEN yret(j)=!Y.CRANGE[0]

         CCG_SYMBOL, sym=symtype,fill=symfill,thick=symthick

         FOR i = 0, N_ELEMENTS(xret)-1 DO BEGIN
            ; Color code preliminary data correctly
            color = ((r = STRMID(fret[i], 2, 1)) NE "P") ? pen(ip+1) : pen(140)

            PLOTS, xret[i], yret[i], COLOR=color, PSYM=8, SYMSIZE=symsize
         ENDFOR

         IF NOT KEYWORD_SET(nodot2dot) THEN BEGIN
            FOR i = 0, N_ELEMENTS(xret)-1 DO BEGIN
               ; Color code preliminary data correctly
               color = ((r = STRMID(fret[i], 2, 1)) NE "P") ? pen(ip+1) : pen(140)

                IF i EQ 0 THEN BEGIN
                   PLOTS, xret[i], yret[i], COLOR=color, THICK=plotthick, LINESTYLE=0
                ENDIF ELSE BEGIN
                   PLOTS, xret[i], yret[i], /CONTINUE, COLOR=color, $
                   LINESTYLE=0, THICK=plotthick
                ENDELSE
            ENDFOR
         ENDIF

         showprestr = 0
         FOR i=0,N_ELEMENTS(fret)-1 DO $
            IF (r = STRMID(fret[i], 2, 1)) EQ "P" THEN showprestr = 1
         IF showprestr THEN $

            XYOUTS,pp[npanels-1].prel[0,ip],$
               pp[npanels-1].prel[1,ip],$
               /NORMAL,$
               '(Preliminary Data in GRAY)',$
               COLOR=pen(1),$
               CHARSIZE=0.75,$
               CHARTHICK=0.75*charthick

         tmin = (tmin > MIN(zret)) ? MIN(zret) : tmin
         tmax = (tmax < MAX(zret)) ? MAX(zret) : tmax
      ENDIF

      IF nonb EQ 0 AND N_ELEMENTS(xnb) GT 1 THEN BEGIN

         j=WHERE(xnb GT !X.CRANGE[1])
         IF j(0) NE -1 THEN xnb(j)=!X.CRANGE[1]
         j=WHERE(xnb LT !X.CRANGE[0])
         IF j(0) NE -1 THEN xnb(j)=!X.CRANGE[0]

         j=WHERE(ynb GT !Y.CRANGE[1])
         IF j(0) NE -1 THEN ynb(j)=!Y.CRANGE[1]
         j=WHERE(ynb LT !Y.CRANGE[0])
         IF j(0) NE -1 THEN ynb(j)=!Y.CRANGE[0]

         CCG_SYMBOL,sym=10,fill=0,thick=symthick

         FOR i = 0, N_ELEMENTS(xnb)-1 DO BEGIN
            ; Color code preliminary data correctly
            color = ((r = STRMID(fnb[i], 2, 1)) NE "P") ? pen(ip+1) : pen(140)

            PLOTS, xnb[i], ynb[i], COLOR=color, PSYM=8, SYMSIZE=symsize
         ENDFOR

         tmin = (tmin > MIN(znb)) ? MIN(znb) : tmin
         tmax = (tmax < MAX(znb)) ? MAX(znb) : tmax
      ENDIF

      IF norej EQ 0 AND N_ELEMENTS(xrej) GT 1 THEN BEGIN

         j=WHERE(xrej GT !X.CRANGE[1])
         IF j(0) NE -1 THEN xrej(j)=!X.CRANGE[1]
         j=WHERE(xrej LT !X.CRANGE[0])
         IF j(0) NE -1 THEN xrej(j)=!X.CRANGE[0]

         j=WHERE(yrej GT !Y.CRANGE[1])
         IF j(0) NE -1 THEN yrej(j)=!Y.CRANGE[1]
         j=WHERE(yrej LT !Y.CRANGE[0])
         IF j(0) NE -1 THEN yrej(j)=!Y.CRANGE[0]

         CCG_SYMBOL, sym=11,fill=0,thick=symthick

         FOR i = 0, N_ELEMENTS(xrej)-1 DO BEGIN
            ; Color code preliminary data correctly
            color = ((r = STRMID(frej[i], 2, 1)) NE "P") ? pen(ip+1) : pen(140)

            PLOTS, xrej[i], yrej[i], COLOR=color, PSYM=8, SYMSIZE=symsize
         ENDFOR

         tmin = (tmin > MIN(zrej)) ? MIN(zrej) : tmin
         tmax = (tmax < MAX(zrej)) ? MAX(zrej) : tmax
      ENDIF
   ENDFOR

   IF (NOT KEYWORD_SET(nopiid) AND (N_ELEMENTS(xret) GT 1 OR N_ELEMENTS(xnb) GT 1)) THEN BEGIN
      z=IADV_PROJECTPI(project=project[ip],param=sp[ip],site=site)

      CCG_PIID, x=pp[npanels-1].pi[0,ip],$
            y=pp[npanels-1].pi[1,ip],$
            name=[z],$
            color=pen(1),$
            charthick=0.75*charthick
   ENDIF

   IF NOT KEYWORD_SET(noposition) THEN BEGIN

      HOUR=0.00011416D
      ;
      ;convert from UTC to LST
      ;
      ;tmin = tmin-(HOUR*lst2utc)
      ;CCG_DEC2DATE,tmin,yr,mo,dy,hr1
      ;
      ;tmax = tmax-(HOUR*lst2utc)
      ;CCG_DEC2DATE,tmax,yr,mo,dy,hr2

      IF ( lst2utc NE -99 ) THEN BEGIN
         tmin = tmin - lst2utc
         tmax = tmax - lst2utc

         lst = STRING(FORMAT='(I2.2,A1,I2.2,1X,A5)',tmin,'-',tmax,'(LST)')
      ENDIF ELSE BEGIN
         lst = STRING(FORMAT='(I2.2,A1,I2.2,1X,A5)',tmin,'-',tmax,'(UTC)')
      ENDELSE
      
      XYOUTS, pp[npanels-1].xyz[0,ip],$
         pp[npanels-1].xyz[1,ip],$
         postitle+'!C'+strdate+'!C'+lst,$
         /NORMAL,$
         ALI=1.0,$
         COLOR=pen(1),$
         CHARSIZE=0.75,$
         CHARTHICK=0.75*charthick
   ENDIF

ENDFOR
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev,saveas=saveas
END
