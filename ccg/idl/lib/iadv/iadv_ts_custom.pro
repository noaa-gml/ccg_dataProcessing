@iadv_clnlib.pro
@ccg_utils.pro

PRO IADV_TS_CUSTOM,$

      frame1=frame1,$
      frame2=frame2,$
      frame3=frame3,$
      frame4=frame4,$

      data1=data1,$
      data2=data2,$
      data3=data3,$
      data4=data4,$

      yr1=yr1,$
      yr2=yr2,$

      datafound=datafound,$

      title=title,$
      subtitle=subtitle,$
      postitle=postitle,$
      xaxis=xaxis,$
      yaxis=yaxis,$
      ccgvu=ccgvu,$

      charsize=charsize,$
      charthick=charthick,$

      nodata=nodata,$
      nosc=nosc,$
      notr=notr,$

      saveas=saveas,$
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
;ex.
;iadv_ts_custom,data1='tap,flask,co2',frame1='a,0,0,0,0,a,0,0,0,0'
;
;##############################################
; Initialization
;##############################################
;
DEFAULT=(-999.999)
datafound=0
srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'

nframes=4
frames=STRARR(nframes)
data=STRARR(nframes)

frames[0] = (KEYWORD_SET(frame1)) ? frame1 : ''
frames[1] = (KEYWORD_SET(frame2)) ? frame2 : ''
frames[2] = (KEYWORD_SET(frame3)) ? frame3 : ''
frames[3] = (KEYWORD_SET(frame4)) ? frame4 : ''

REPEAT nframes=nframes-1 UNTIL frames[nframes] NE ''
nframes=nframes+1

data[0] = (KEYWORD_SET(data1)) ? data1 : ''
data[1] = (KEYWORD_SET(data2)) ? data2 : ''
data[2] = (KEYWORD_SET(data3)) ? data3 : ''
data[3] = (KEYWORD_SET(data4)) ? data4 : ''

r=CCG_SYSDATE()
IF NOT KEYWORD_SET(yr1) THEN yr1=(-9999)
IF NOT KEYWORD_SET(yr2) THEN yr2=(9999)

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

IF NOT KEYWORD_SET(nodata) THEN nodata=0
IF NOT KEYWORD_SET(notr) THEN notr=0
IF NOT KEYWORD_SET(nosc) THEN nosc=0

IF NOT KEYWORD_SET(xaxis) THEN xaxis=0
IF NOT KEYWORD_SET(yaxis) THEN yaxis=0

IF NOT KEYWORD_SET(charsize) THEN charsize=1.35
IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(linethick) THEN linethick=5.0

IF NOT KEYWORD_SET(grid) THEN grid=0

IF NOT KEYWORD_SET(saveas) THEN saveas=''

pp = REPLICATE({pos:FLTARR(4,4),pi:FLTARR(4),prel:FLTARR(4),xyz:FLTARR(4),logo:0.0},4)

pp[0] = {pos:[[0.10,0.15,0.99,0.75],$
   [0.00,0.00,0.00,0.00],$
   [0.00,0.00,0.00,0.00],$
   [0.00,0.00,0.00,0.00]],$
   pi:[0.725,0,0,0],$
   prel:[0.165,0,0,0],$
   xyz:[0.725,0.000,0.000,0.000],$
   logo:0.20}

pp[1] = {pos:[[0.10,0.51,0.99,0.99],$
   [0.10,0.01,0.99,0.49],$
   [0.00,0.00,0.00,0.00],$
   [0.00,0.00,0.00,0.00]],$
   pi:[0.965,0.465,0,0],$
    prel:[0.525,0.025,0,0],$
   xyz:[0.965,0.465,0.000,0.000],$
   logo:0.060}

pp[2] = {pos:[[0.10,0.68,0.99,0.99],$
   [0.10,0.35,0.99,0.66],$
   [0.10,0.02,0.99,0.33],$
   [0.00,0.00,0.00,0.00]],$
   pi:[0.965,0.635,0.305,0],$
   prel:[0.695,0.365,0.035,0],$
   xyz:[0.965,0.635,0.305,0.000],$
   logo:0.070}

pp[3] = {pos:[[0.10,0.76,0.99,0.99],$
   [0.10,0.51,0.99,0.74],$
   [0.10,0.26,0.99,0.49],$
   [0.10,0.01,0.99,0.24]],$
   pi:[0.965,0.715,0.465,0.215],$
   prel:[0.775,0.525,0.275,0.025],$
   xyz:[0.965,0.715,0.465,0.215],$
   logo:0.060}

IF dev NE '' THEN BEGIN

   LOADCT,0

   xpos=0.86
   ypos=pp[nframes-1].logo

   noaa_height=0.085
   height=noaa_height
   portrait_ratio=1.294
   ratio=1.00

   width=portrait_ratio*ratio*height

   READ_JPEG, srcdir + 'logos/noaa_color.jpg', /true, a
   TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height

   sil=0
   FOR i=0,nframes-1 DO BEGIN
      IF STRPOS(data[i],'co2c13') NE -1 THEN sil=1
      IF STRPOS(data[i],'co2c14') NE -1 THEN sil=1
      IF STRPOS(data[i],'co2o18') NE -1 THEN sil=1
      IF STRPOS(data[i],'ch4c13') NE -1 THEN sil=1
   ENDFOR

   IF sil NE 0 THEN BEGIN

      ratio=1.243
      height=noaa_height
      width=portrait_ratio*ratio*height
      xpos=xpos-0.005-width

      READ_JPEG, srcdir + 'logos/instaar_logo_white_bg.jpg', /true, a
      TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height
   ENDIF
ENDIF

; Do not display cooperating agency logos because the user can add
;    many many other dataset and we could end up with tons of
;    logos on the plot

CCG_RGBLOAD,file=idldir + 'data/color_comb1'

FOR fn=0,nframes-1 DO BEGIN

   if frames[fn] EQ '' THEN CONTINUE

   frame_info = STRSPLIT(frames[fn],',',/EXTRACT)
   xaxis = (frame_info[0] EQ 'a') ? '' : FLOAT(frame_info[1:4])
   yaxis = (frame_info[5] EQ 'a') ? '' : FLOAT(frame_info[6:9])

   data_arr = STRSPLIT(data[fn],'~',/EXTRACT)

   FOR dn=0,N_ELEMENTS(data_arr)-1 DO BEGIN

      data_info = STRSPLIT(data_arr[dn],',',/EXTRACT)

      n = N_ELEMENTS(data_info)

      site = data_info[0]
      project = 'ccg_'+STRCOMPRESS(data_info[1],/RE)
      sp = data_info[2]

      symtype = (n GT 3) ? FIX(data_info[3]) : dn+1
      symsize = (n GT 3) ? FLOAT(data_info[4]) : 0.5
      symwidth = (n GT 3) ? FIX(data_info[5]) : 1
      symcolor = (n GT 3) ? FIX(data_info[6]) : dn+1
      symfill = (n GT 3) ? FIX(data_info[7]) : 0
      sctype = (n GT 3) ? FIX(data_info[8]) : 0
      scwidth = (n GT 3) ? FIX(data_info[9]) : 1
      sccolor = (n GT 3) ? FIX(data_info[10]) : dn+1
      trtype = (n GT 3) ? FIX(data_info[11]) : 0
      trwidth = (n GT 3) ? FIX(data_info[12]) : 1
      trcolor = (n GT 3) ? FIX(data_info[13]) : dn+1
      ;;
      ;; Determine if any data should be excluded
      ;; Determine preliminary date
      ;;
      ;perlcode=srcdir+'iadv_pi.pl'
      ;SPAWN, perlcode+' -g'+gas+' -p'+project,tmp
      ;pi_info=STRSPLIT(tmp[0],'|',/EXTRACT)
      ;
      ;tmp=STRSPLIT(preliminary,'-',/EXTRACT)
      ;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
      ;dy=FIX(tmp[2]),hr=12,mn=0,dec=preliminary
      ;
      ;exclusion=(N_ELEMENTS(pi_info) EQ 7) ? pi_info[6] : '9999-12-31'
      ;tmp=STRSPLIT(exclusion,'-',/EXTRACT)
      ;CCG_DATE2DEC, yr=FIX(tmp[0]),mo=FIX(tmp[1]),$
      ;dy=FIX(tmp[2]),hr=12,mn=0,dec=exclusion
      ;
      ;##############################################
      ; Retrieve Data
      ;##############################################
      ;

      SWITCH STRLOWCASE(project) OF
         'ccg_aircraft':
         'ccg_surface': BEGIN
            CCG_FLASK,$
            site = site, sp = sp,$
            project = project, $
            date = date, $
            /preliminary, /exclusion, pdata
            BREAK
         END
         'ccg_obs': BEGIN
            IADV_OBS,$
            site = site, sp = sp,$
            date = date, pdata
            BREAK
         END
         'ccg_tower':
      ENDSWITCH

      xnb = 0 & ynb = 0 & fnb = 0
      xrej = 0 & yrej = 0 & frej = 0

      typ = size(pdata);
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
         j = WHERE(STRMID(pdata.flag, 0, 2) EQ "..")
         IF j[0] NE -1 THEN BEGIN
            xret = pdata[j].date
            yret = pdata[j].value
            fret = pdata[j].flag
         ENDIF
         ;
         ; Subset of non-background pdata
         ;
         j = WHERE(STRMID(pdata.flag, 1, 1) NE ".")
         IF j[0] NE -1 THEN BEGIN
            xnb = pdata[j].date
            ynb = pdata[j].value
            fnb = pdata[j].flag
         ENDIF
         ;
         ; Subset of rejected pdata
         ;
         j = WHERE(STRMID(pdata.flag, 0, 1) NE ".")
         IF j[0] NE -1 THEN BEGIN
            xrej = pdata[j].date
            yrej = pdata[j].value
            frej = pdata[j].flag
         ENDIF
      ENDIF

      IF N_ELEMENTS(xret) GT 1 THEN datafound=datafound+1
      ;;
      ;;Exclude data?
      ;;
      ;j=WHERE(xret LT exclusion)
      ;IF j[0] NE -1 THEN BEGIN
      ;   xret=xret[j]
      ;   yret=yret[j]
      ;ENDIF
      ;
      ;j=WHERE(xnb LT exclusion)
      ;IF j[0] NE -1 THEN BEGIN
      ;   xnb=xnb[j]
      ;   ynb=ynb[j]
      ;ENDIF
      ;
      ;j=WHERE(xrej LT exclusion)
      ;IF j[0] NE -1 THEN BEGIN
      ;   xrej=xrej[j]
      ;   yrej=yrej[j]
      ;ENDIF

      IF KEYWORD_SET(ccgvu) THEN BEGIN
         npoly=ccgvu[0]
         nharm=ccgvu[1]
         interval=ccgvu[2]
         cutoff1=ccgvu[3]
         cutoff2=ccgvu[4]
      ENDIF ELSE BEGIN
         IF sp EQ 'co2c14' THEN BEGIN
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

      sc = [[0],[0]]
      tr = [[0],[0]]

      IF NOT toofew THEN CCG_CCGVU,x=xret,y=yret,$
         npoly=npoly,nharm=nharm,$
         interval=interval,$
         cutoff1=cutoff1,cutoff2=cutoff2,$
         even=1,sc=sc,tr=tr

      CCG_SITEDESCINFO,site=site,$
             proj_abbr=project,$
             title=title,$
             position=postitle,$
             sample_ht=subtitle

      s = CREATE_STRUCT('site',site,'project',project,$
            'title',title,'pos',postitle,'sub',subtitle,$
            'data',TRANSPOSE([[xret],[yret]]),'flag',TRANSPOSE([fret]),$
             'sc',sc,'tr',tr,$
            'symtype',symtype,'symsize',symsize,'symwidth',symwidth,$
            'symcolor',symcolor,'symfill',symfill, 'toofew', toofew, $
            'sctype',sctype,'scwidth',scwidth,'sccolor',sccolor,$
            'trtype',trtype,'trwidth',trwidth,'trcolor',trcolor)
      
      tag = 'd'+STRCOMPRESS(STRING(dn),/RE)
      data_struct = (dn EQ 0) ? CREATE_STRUCT(tag,s) : CREATE_STRUCT(data_struct,tag,s)
   ENDFOR

   CCG_GASINFO,sp=sp,title=ytitle, /tt_font

   xtmp=[0D]
   ytmp=[0.0]

   FOR j=0,N_ELEMENTS(data_arr)-1 DO BEGIN
      xtmp=[xtmp,REFORM(data_struct.(j).data[0,*])]
      ytmp=[ytmp,REFORM(data_struct.(j).data[1,*])]
   ENDFOR

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
   IF xtmp[N_ELEMENTS(xtmp)-1]-xtmp[0] LE 1 THEN BEGIN
      xmin=FIX(xtmp[0])
      xmax=FIX(xtmp[N_ELEMENTS(xtmp)-1])+1
      xticks=xmax-xmin
      xminor=(xticks EQ 1) ? 12 : 1
      xaxis=[xmin,xmax,xticks,xminor]
   ENDIF

   IF SIZE(xaxis,/DIMENSION) EQ 4 THEN BEGIN
      ex = {  XSTYLE:1,$
         XRANGE:[xaxis[0],xaxis[1]], $
         XTICKS:xaxis[2], $
         XMINOR:xaxis[3]}
   ENDIF ELSE BEGIN
      ex = {  XSTYLE:16}
   ENDELSE
   ;
   ; Use X axis determined for frame 1
   ;
   IF fn NE 0 AND SIZE(xaxis,/DIMENSION) EQ 0 THEN ex = {XSTYLE:1,XRANGE:!X.CRANGE}

   e=CREATE_STRUCT(ex,ey)

   xcharsize=(fn EQ nframes-1) ? 1.0 : 0.001

   title = (fn EQ 0) ? "NOAA ESRL - Custom Graph" : ""

   PLOT,xtmp[1:*],ytmp[1:*],$
      /NOERASE,$
      POSITION=[pp[nframes-1].pos[*,fn]],$
      /NODATA,$
      COLOR=pen(1),$
      CHARSIZE=charsize,$
      CHARTHICK=charthick,$
      TITLE=title,$

      _EXTRA=e,$

      YGRIDSTYLE=gridstyle,$
      YTICKLEN=ticklen,$
      YTHICK=linethick,$
      YCHARSIZE=1.0,$

      XGRIDSTYLE=gridstyle,$
      XCHARSIZE=xcharsize,$
      XTICKLEN=ticklen,$
      XTHICK=linethick,$
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


   FOR dn=0,N_ELEMENTS(data_arr)-1 DO BEGIN
      ;
      ; Plot data
      ;
      textcolor=(0)

      IF data_struct.(dn).symtype GT 0 THEN BEGIN

         x=REFORM(data_struct.(dn).data[0,*])
         y=REFORM(data_struct.(dn).data[1,*])
         f=REFORM(data_struct.(dn).flag[0,*])

         j=WHERE((r = STRMID(f, 2, 1)) NE "P")

         CCG_SYMBOL,sym=data_struct.(dn).symtype,$
               thick=data_struct.(dn).symwidth,$
               fill=data_struct.(dn).symfill

         IF j[0] NE -1 THEN OPLOT,x[j],y[j],$
            COLOR=pen[data_struct.(dn).symcolor],$
            PSYM=8,$
            SYMSIZE=data_struct.(dn).symsize

         j=WHERE((r = STRMID(f, 2, 1)) EQ "P")

         IF j[0] NE -1 THEN BEGIN

            OPLOT,x[j],y[j],$
               COLOR=pen(140),$
               PSYM=8,$
               SYMSIZE=data_struct.(dn).symsize

            XYOUTS,0.12,pp[nframes-1].prel[fn],$
               /NORMAL,$
               '(Preliminary Data shown in GRAY)',$
               COLOR=pen(1),$
               CHARSIZE=0.75,$
               CHARTHICK=0.75*charthick
         ENDIF

         textcolor=data_struct.(dn).symcolor
      ENDIF
      ;
      ; Plot smooth curve
      ;
      IF data_struct.(dn).sctype GE 0 AND NOT data_struct.(dn).toofew THEN BEGIN

         x=REFORM(data_struct.(dn).sc[0,*])
         y=REFORM(data_struct.(dn).sc[1,*])

         OPLOT,x,y,$
            COLOR=pen(data_struct.(dn).sccolor),$
            LINESTYLE=data_struct.(dn).sctype,$
            THICK=data_struct.(dn).scwidth

         ;j=WHERE(x LT data_struct.(dn).preliminary)

         ;IF j[0] NE -1 THEN OPLOT,x[j],y[j],$
         ;   COLOR=pen(data_struct.(dn).sccolor),$
         ;   LINESTYLE=data_struct.(dn).sctype,$
         ;   THICK=data_struct.(dn).scwidth
         ;
         ;j=WHERE(x GE data_struct.(dn).preliminary)
         ;
         ;IF j[0] NE -1 THEN BEGIN
         ;
         ;   OPLOT,x[j],y[j],$
         ;      COLOR=pen(140),$
         ;      LINESTYLE=data_struct.(dn).sctype,$
         ;      THICK=data_struct.(dn).scwidth
         ;
         ;   XYOUTS,0.12,pp[nframes-1].prel[fn],$
         ;      /NORMAL,$
         ;      '(Preliminary Data shown in GRAY)',$
         ;      COLOR=pen(1),$
         ;      CHARSIZE=0.75,$
         ;      CHARTHICK=0.5*charthick
         ;ENDIF

         IF textcolor EQ 0 THEN textcolor = data_struct.(dn).sccolor
      ENDIF
      ;
      ; Plot trend curve
      ;
      IF data_struct.(dn).trtype GE 0 AND NOT data_struct.(dn).toofew THEN BEGIN

         x=REFORM(data_struct.(dn).tr[0,*])
         y=REFORM(data_struct.(dn).tr[1,*])

         OPLOT,x,y,$
            COLOR=pen(data_struct.(dn).trcolor),$
            LINESTYLE=data_struct.(dn).trtype,$
            THICK=data_struct.(dn).trwidth

         ;j=WHERE(x LT data_struct.(dn).preliminary)
         ;
         ;IF j[0] NE -1 THEN OPLOT,x[j],y[j],$
         ;   COLOR=pen(data_struct.(dn).trcolor),$
         ;   LINESTYLE=data_struct.(dn).trtype,$
         ;   THICK=data_struct.(dn).trwidth
         ;
         ;j=WHERE(x GE data_struct.(dn).preliminary)
         ;
         ;IF j[0] NE -1 THEN BEGIN
         ;   OPLOT,x[j],y[j],$
         ;      COLOR=pen(140),$
         ;      LINESTYLE=data_struct.(dn).trtype,$
         ;      THICK=data_struct.(dn).trwidth
         ;
         ;   XYOUTS,0.12,pp[nframes-1].prel[fn],$
         ;      /NORMAL,$
         ;      '(Preliminary Data shown in GRAY)',$
         ;      COLOR=pen(1),$
         ;      CHARSIZE=0.75,$
         ;      CHARTHICK=0.5*charthick
         ;ENDIF

         IF textcolor EQ 0 THEN textcolor = data_struct.(dn).trcolor
      ENDIF

      IF NOT KEYWORD_SET(noposition) THEN BEGIN

         XYOUTS,0.97,pp[nframes-1].xyz[fn]-(dn*0.035),$
            data_struct.(dn).pos+'!C'+data_struct.(dn).sub,$
            /NORMAL,$
            ALI=1.0,$
            COLOR=pen(textcolor),$
            CHARSIZE=0.75,$
            CHARTHICK=0.75*charthick
      ENDIF
   ENDFOR

   IF (NOT KEYWORD_SET(nopiid) AND N_ELEMENTS(xret) GT 1) THEN BEGIN
      z=IADV_PROJECTPI(project=project,sp=sp,site=site)

      CCG_PIID, x=0.12,y=pp[nframes-1].pi[fn],$
         name=[z],$
         color=pen(1),$
         charthick=0.75*charthick
   ENDIF

ENDFOR
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,dev=dev,saveas=saveas
END
