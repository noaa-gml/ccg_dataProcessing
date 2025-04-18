;+
;  iadv_sc_sg,sp='co2c13',project='ccg_surface', site='alt',extfile='/ccg/dei/ext/co2c13/results.flask.2010/alt_01D0_ext.co2c13',dev='png'
;-

@iadv_clnlib.pro
@ccg_utils.pro

PRO IADV_SC_SG,$

   sp=sp,$
   project=project,$
   site=site,$

   extfile=extfile,$

   datafound=datafound,$

   title=title,$
   subtitle=subtitle,$
   postitle=postitle,$
   yaxis=yaxis,$
   ccgvu=ccgvu,$

   charsize=charsize,$
   charthick=charthick,$

   linethick=linethick,$
   noposition=noposition,$

   saveas=saveas,$
   noproid=noproid,$
   nopiid=nopiid,$
   dev=dev
;
;##############################################
; Procedure Description
;##############################################
;      
;Changed:  January, 2007 - kam
;Written:  November 22, 2002 - kam
;
;1. Fit a detrended smooth curve, S(t)-T(t) to the observations, C(t)
;2. Compute monthly means.
;3. Monthly means for all Januarys, Februarys, etc. are aggregated.
;4. Statistics are computed with monthly resolution.
;5. Std error is an estimate of how well the monthly mean is determined.
;6. Std deviation is an estimate of the variability in the monthly mean.
;
;7. Determine average seasonal cycle of the latitude reference curve
;   In the top panel, show the average seasonal cycle of the reference.
;   When plotting 2-6 results, add average offset of difference climatology.
;   In bottom panel, show average seasonal cycle difference (data minus mbl).
;
;##############################################
; Initialization
;##############################################
;
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR,"Species must be specified, i.e., sp='co2'."
sp=STRLOWCASE(sp)
spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."

IF NOT KEYWORD_SET(project) THEN project='ccg_surface'
projectchk = CLEANPROJECT(project=project)
IF ( projectchk NE 1 ) THEN CCG_FATALERR, "Invalid 'project' specified. Exiting ..."

IF NOT KEYWORD_SET(extfile) THEN extfile=''

IF NOT KEYWORD_SET(yaxis) THEN yaxis=0

IF NOT KEYWORD_SET(charsize) THEN charsize=1.45
IF NOT KEYWORD_SET(charthick) THEN charthick=4.0
IF NOT KEYWORD_SET(linethick) THEN linethick=5.0

IF NOT KEYWORD_SET(saveas) THEN saveas=''

IF KEYWORD_SET(grid) THEN BEGIN
   ticklen=1
   gridstyle=1
ENDIF ELSE BEGIN
   ticklen=(-0.01)
   gridstyle=0
   grid=0
ENDELSE


CCG_SITEDESCINFO,site=site,$
   proj_abbr=project,$
   title=t,$
   position=p,$
   sample_ht=s

IF NOT KEYWORD_SET(title) THEN title=t
IF NOT KEYWORD_SET(postitle) THEN postitle=p
IF NOT KEYWORD_SET(subtitle) THEN subtitle=s

dev=(KEYWORD_SET(dev)) ? dev : ''

datafound=0
DEFAULT=(-999.999)
SKIP=16
srcdir='/projects/src/web/iadv/'
idldir='/ccg/idl/lib/ccglib/'
;
;***************************************
;Work with data first
;***************************************
;
SWITCH STRLOWCASE(project) OF
   'ccg_aircraft': BEGIN
         CCG_FLASK,$
         site = site, sp = sp, project = project, $
         /preliminary, /exclusion, data
         BREAK
      END
   'ccg_surface': BEGIN
         CCG_FLASK,$
         site = site, sp = sp, project = project, strategy = 'flask', $
         /preliminary, /exclusion, data
         BREAK
      END
   'ccg_obs': BEGIN
         IADV_OBS,$
         site = site, sp = sp, data
         BREAK
      END
   'tower': BEGIN
         data = 0
         BREAK
      END
ENDSWITCH

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
   ENDIF ELSE BEGIN
      xret=[0] & yret=[0] & fret=[0]
   ENDELSE
ENDIF ELSE BEGIN
   xret=[0] & yret=[0] & fret=[0]
ENDELSE

;
; Return if there are too few data

IF ( N_ELEMENTS(xret) LT 104 OR xret[N_ELEMENTS(xret)-1]-xret[0] LE 2) THEN RETURN

IADV_QUICKFILTER,x=xret,y=yret,ptr
j=WHERE(ptr EQ 1)
xret=xret[j]
yret=yret[j]
fret=fret[j]

;
;Define tzero
;
tzero=FIX(CCG_MEAN(xret))
;
;Fit curve to data
;
npoly=3
nharm=4
interval=7
cutoff1=80
cutoff2=650

IF KEYWORD_SET(ccgvu) THEN BEGIN
   npoly=ccgvu[0]
   nharm=ccgvu[1]
   interval=ccgvu[2]
   cutoff1=ccgvu[3]
   cutoff2=ccgvu[4]
ENDIF

CCG_CCGVU,x=xret,y=yret,$
   /even,$
   npoly=npoly,$
   nharm=nharm,$
   interval=interval,$
   cutoff1=cutoff1,$
   cutoff2=cutoff2,$
   tzero=tzero,$
   fsc=data_fsc,ssc=ssc

j=WHERE(FIX(data_fsc[0,*]) EQ FIX(CCG_MEAN(data_fsc[0,*])))

xdata_fsc=REFORM(data_fsc[0,j]-FIX(CCG_MEAN(data_fsc[0,*])))
ydata_fsc=REFORM(data_fsc[1,j])

CCG_MEANS,      xarr=ssc[0,*],yarr=ssc[1,*],/month,xres,yres,sd,n
CCG_DEC2DATE,   xres,yr,mo,dy

mm=FLTARR(12) & sd=mm & se=mm & n=mm 
xmm=FINDGEN(12)/12.+1/24.

FOR i=1,12 DO BEGIN
   j=WHERE(mo EQ i)
   mm[i-1]=CCG_MEAN(yres[j])
   n[i-1]=N_ELEMENTS(j)
   sd[i-1]=(n[i-1] GT 1) ? STDEV(yres[j]) : 0
   se[i-1]=(n[i-1] GT 2) ? sd[i-1]/SQRT(n[i-1]) : 0
ENDFOR
;
;For plotting purposes, get value from average seasonal cycle
;at time steps of xmm.
;
CCG_DATASYNC,refarr=TRANSPOSE([[xdata_fsc],[ydata_fsc]]),$
      inputarr=TRANSPOSE([[xmm],[mm]]),$
      resarr=mm_data_sync
;
;***************************************
;Now get data extension results
;***************************************
;
; Does extension file exist;
;
;mbl_exist=FILE_TEST(extfile)
ext_file = FILE_SEARCH(extfile,COUNT=mbl_exist)

IF mbl_exist EQ 1 THEN BEGIN

   CCG_READ, file=ext_file[0], comment="#", v

   xmbl = v.field1
   ymbl = v.field3

   j = WHERE( v.field2-1 GT DEFAULT )
   xdiff = v[j].field1
   ydiff = v[j].field4
   ysc = v[j].field2
   ; 
   ;Determine average seasonal cycle of mbl REF(t)
   ;
   CCG_CCGVU,x=xmbl,y=ymbl,$
      npoly=npoly,$
      nharm=nharm,$
      interval=7,$
      cutoff1=cutoff1,$
      cutoff2=cutoff2,$
      tzero=tzero,$
      fsc=mbl_fsc

   j=WHERE(FIX(mbl_fsc[0,*]) EQ FIX(CCG_MEAN(mbl_fsc[0,*])))

   xmbl_fsc=REFORM(mbl_fsc[0,j]-FIX(CCG_MEAN(mbl_fsc[0,*])))
   ymbl_fsc=REFORM(mbl_fsc[1,j])
   ;
   ;Determine average seasonal cycle difference by synchronizing
   ;the average s.c. of the data with the average s.c. of the mbl
   ;reference, i.e., get values from mbl at timesteps of data.
   ;
   CCG_DATASYNC,refarr=TRANSPOSE([[xmbl_fsc],[ymbl_fsc]]),$
      inputarr=TRANSPOSE([[xdata_fsc],[ydata_fsc]]),$
      resarr=data_mbl_sync
   ;
   ;data_mbl_sync contains xdata_fsc, ydata_fsc, and the synched values
   ;extracted from mbl_fsc.
   ;
   ;
   ;Determine average offset of difference climatology
   ;S(t) - REF(t)
   ;
   CCG_CCGVU,x=xdiff,y=ydiff,$
      npoly=1,$
      nharm=4,$
      interval=7,$
      cutoff1=cutoff1,$
      cutoff2=cutoff2,$
      tzero=tzero,$
      coef=coef

   dc_offset=coef(0,0)

ENDIF ELSE dc_offset=0

;
;***************************************
;Graphics
;***************************************
;

CCG_GASINFO,sp=sp,title=ytitle, /tt_font

IF SIZE(yaxis,/DIMENSION) EQ 4 THEN BEGIN
   ey = {  YSTYLE:1,$
      YRANGE:[yaxis[0],yaxis[1]], $
      YTICKS:yaxis[2], $
      YMINOR:yaxis[3]}
ENDIF ELSE BEGIN
   ey = {  YSTYLE:16}
ENDELSE

CCG_OPENDEV,dev=dev,pen=pen,saveas=saveas,/portrait, font='Helvetica'

; #######################################################
; START LOGOS

LOADCT,0

xpos=0.90
ypos=0.13

noaa_height=0.085
noaa_height=0.105
height=noaa_height
portrait_ratio=1.294
ratio=1.00

width=0.105

file = srcdir + 'logos/noaa_color.jpg'
PLOT_LOGO, xpos,ypos-(height/2.0), xsize = width, ysize = height, page = 'portrait', $
file = file, dev = dev, pen = pen

j=WHERE(['co2c13','co2c14','co2o18','ch4c13'] EQ sp)

IF j[0] NE -1 THEN BEGIN

   ratio=1.0
   height=noaa_height
   width=portrait_ratio*ratio*height
   xpos=xpos-0.025-width

   file = srcdir + 'logos/instaar_logo_white_bg.jpg'
   PLOT_LOGO, xpos,ypos-(height/2.0), xsize = width, ysize = height, page = 'portrait', $
   file = file, dev = dev, pen = pen

ENDIF
;
; Plot cooperating and sponsoring agency logos
;
perlcode=srcdir+'iadv_logos.pl -site='+site+' -project='+project
SPAWN, perlcode,z

logos=STRSPLIT(z,'|',/EXTRACT)

FOR ilogos=0,N_ELEMENTS(logos)-1 DO BEGIN
                                                                                       
   image=STRSPLIT(logos[ilogos],' ',/EXTRACT)
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
                                                                                       
      xpos=xpos-0.065-width

      file = srcdir + 'logos/' + image[0]
      PLOT_LOGO, xpos,ypos-(height/2.0), xsize = width, ysize = height, page = 'portrait', $
      file = file, dev = dev, pen = pen
                                                                                       
   ENDIF
ENDFOR

; END LOGOS
; #######################################################

CCG_RGBLOAD,file=idldir + 'data/color_comb1'

xmin=0 & xmax=1
;
;**********************************
;First Frame
;**********************************
;
xtmp=(mbl_exist) ? [xmm,xmm,xmbl_fsc] : [xmm,xmm]
ytmp=(mbl_exist) ? [mm-sd+dc_offset,mm+sd+dc_offset,ymbl_fsc] : [mm-sd+dc_offset,mm+sd+dc_offset]


; plot average monthly means
PLOT,[xtmp],[ytmp],$
   /NODATA,$
   /NOERASE,$
   POSITION=[0.10,0.51,0.99,0.99],$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   COLOR=pen(1),$
   TITLE= '!n'+title+'!C!D'+subtitle+'!n',$
   YTITLE=ytitle,$
   YCHARSIZE=1.0*charsize,$
   YTICKLEN=ticklen,$
   YTHICK=linethick,$

   _EXTRA=ey,$

   XSTYLE=1+4,$
   XRANGE=[xmin,xmax]

; label axis
CCG_XLABEL,x1=xmin,x2=xmax,$
   y1=!Y.CRANGE[0],y2=!Y.CRANGE[1],$
   mon=1,/abbr,$
   CHARSIZE=0.01,$
   CHARTHICK=charthick,$
   COLOR=pen(1),$
   XTITLE='MONTH',$
   XTICKLEN=ticklen,$
   XTHICK=linethick

; horizontal dashed line at y = 0
OPLOT,[!X.CRANGE],[0,0],$
   LINESTYLE=1,$
   THICK=linethick,$
   COLOR=pen(1)

; average mbl seasonal cycle
IF mbl_exist THEN OPLOT,xmbl_fsc,ymbl_fsc,$
   LINESTYLE=2,$
   THICK=linethick,$
   COLOR=pen(3)

; average seasonal cycle line
OPLOT,xdata_fsc,ydata_fsc+dc_offset,$
   LINESTYLE=0,$
   THICK=linethick,$
   COLOR=pen(1)

; error bar plot of monthly mean standard deviations
CCG_ERRPLOT,xmm,mm_data_sync[2,*]+sd+dc_offset,mm_data_sync[2,*]-sd+dc_offset,$
   THICK=linethick,$
   COLOR=pen(2)

; error bar plot of monthly mean standard errors
CCG_ERRPLOT,xmm,mm_data_sync[2,*]+se+dc_offset,mm_data_sync[2,*]-se+dc_offset,$
   THICK=4*linethick,$
   COLOR=pen(2)

XYOUTS,0.12,0.965,$
   /NORMAL,$
   "Average Seasonal Cycle",$
   ALI=0.0,$
   COLOR=pen(1),$
   CHARSIZE=0.95*charsize,$
   CHARTHICK=0.75*charthick

lat=STRMID(postitle,STRPOS(postitle,'(')+1,STRPOS(postitle,';')-STRPOS(postitle,'(')-1)

tarr=(mbl_exist) ? [STRUPCASE(site),'MBL Reference at '+lat] : [STRUPCASE(site)]
ypos=(mbl_exist) ? 0.560 : 0.535

CCG_LLEGEND,x=0.12,y=ypos,$
   tarr=tarr,$
   carr=[pen(1),pen(3)],$
   larr=[0,0],$
   thick=linethick,$
   CHARSIZE=0.75*charsize,$
   CHARTHICK=0.75*charthick


IF NOT KEYWORD_SET(noposition) THEN BEGIN
   XYOUTS,0.97,0.965,$
      postitle,$
      /NORMAL,$
      ALI=1.0,$
      COLOR=pen(1),$
      CHARSIZE=0.95*charsize,$
      CHARTHICK=0.75*charthick
ENDIF
;
;**********************************
;Second Frame
;**********************************
;
xtmp=(mbl_exist) ? [data_mbl_sync[0,*]] : 0
ytmp=(mbl_exist) ? [data_mbl_sync[1,*]-data_mbl_sync[2,*]+dc_offset] : 0

PLOT,[xtmp],[ytmp],$
   /NODATA,$
   /NOERASE,$
   POSITION=[0.10,0.01,0.99,0.49],$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   COLOR=pen(1),$
   YTITLE=ytitle,$
   YCHARSIZE=1.0*charsize,$
   YTHICK=linethick,$
   YTICKLEN=ticklen,$
   YSTYLE=16,$

   XSTYLE=1+4,$
   XRANGE=[xmin,xmax]

CCG_XLABEL,x1=xmin,x2=xmax,$
   y1=!Y.CRANGE[0],y2=!Y.CRANGE[1],$
   mon=1,/abbr,$
   CHARSIZE=charsize,$
   CHARTHICK=charthick,$
   COLOR=pen(1),$
   XTITLE='MONTH',$
   XTICKLEN=ticklen,$
   XTHICK=linethick

OPLOT,[!X.CRANGE],[0,0],$
   LINESTYLE=1,$
   THICK=linethick,$
   COLOR=pen(1)

IF mbl_exist THEN BEGIN
   OPLOT,  [data_mbl_sync[0,*]],[data_mbl_sync[1,*]-data_mbl_sync[2,*]+dc_offset],$
      LINESTYLE=0,$
      THICK=linethick,$
      COLOR=pen(4)
ENDIF ELSE BEGIN
   XYOUTS,(!X.CRANGE[1]-!X.CRANGE[0])/2.0,$
      (!Y.CRANGE[1]-!Y.CRANGE[0])/2.0,$
      ALI=0.5,$
      "Reference data are currently unavailable",$
      COLOR=pen(1),$
      CHARSIZE=1.25*charsize,$
      CHARTHICK=charthick
ENDELSE


z=(mbl_exist) ?  STRCOMPRESS(STRING(FORMAT='(F8.3)',dc_offset),/RE) : 'N/A'

XYOUTS,0.12,0.465,$
   /NORMAL,$
   "Seasonal Cycle Difference (data minus reference): "+z,$
   ALI=0.0,$
   COLOR=pen(1),$
   CHARSIZE=0.95*charsize,$
   CHARTHICK=charthick

IF NOT KEYWORD_SET(noproid) THEN CCG_PROID,y=(-0.05)

datafound=datafound+1
CCG_CLOSEDEV,dev=dev,saveas=saveas
END
