@iadv_clnlib.pro
@ccg_utils.pro

PRO IADV_SURFACE,$
   sp=sp,$
   site=site,$
   s_info=s_info,$
   yr1=yr1,$
   yr2=yr2,$
   xaxis=xaxis,$
   zaxis=zaxis,$
   str_zaxis=str_zaxis,$

   xrot=xrot,$
   zrot=zrot,$

   charsize=charsize,$
   charthick=charthick,$

   linecolor=linecolor,$
   linethick=linethick,$
   thick=thick,$

   noinset=noinset,$
   shade=shade,$

   custom=custom,$

   srfcfile=srfcfile,$

   position=position,$
   title=title,$
   xcharsize=xcharsize,$
   yparam=yparam,$
   saveas=saveas,$
   dev=dev
;
;----------------------------------------------- procedure description 
;
;
;-----------------------------------------------check species
;
;
;##############################################
; Check critical keywords
;##############################################
;
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR,$
   "Species must be specified, e.g., sp='co2'"
   spchk = CLEANSP(sp=sp)
   IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."
;
;-----------------------------------------------check surface file
;
IF NOT KEYWORD_SET(srfcfile) THEN CCG_FATALERR,$
   "Surface file must be specified, e.g., srfcfile='.../surface.mbl.co2'"

tmpsrfcfile = FILE_SEARCH(srfcfile, COUNT=srfc_exist)
   
IF srfc_exist NE 1 THEN BEGIN
   tmp = STRSPLIT(srfcfile, '/', /EXTRACT)
   
   srfcfile = STRCOMPRESS('/data/webdata/ccgg/iadv/mbl/'+tmp[N_ELEMENTS(tmp)-1],/REMOVE_ALL)

   tmpsrfcfile = FILE_SEARCH(srfcfile, COUNT=chk)

   IF chk NE 1 THEN CCG_FATALERR, "Surface file not found."

ENDIF

srfcfile = tmpsrfcfile

;
;##############################################
; Initialization
;##############################################
;
srcdir='/projects/src/web/iadv/'
dbdir='/projects/src/db/'
idldir='/ccg/idl/lib/ccglib/'
DEFAULT=(-9999)
CCG_GASINFO,sp=sp,title=ztitle,name=gasname, /tt_font
yr1 = (KEYWORD_SET(yr1)) ? yr1 : DEFAULT
yr2 = (KEYWORD_SET(yr2)) ? yr2 : -DEFAULT
xrot = (CCG_VDEF(xrot)) ? xrot : -1
zrot = (CCG_VDEF(zrot)) ? zrot : -1

custom = (KEYWORD_SET(custom)) ? 'CUSTOM GRAPH' : ''

saveas = (KEYWORD_SET(saveas)) ? saveas : ''

charsize = (KEYWORD_SET(charsize)) ? charsize : 1.75
charthick = (KEYWORD_SET(charthick)) ? charthick : 4.0
linethick = (KEYWORD_SET(linethick)) ? linethick : 1.5
thick = (KEYWORD_SET(thick)) ? thick : 5.0
noinset = (KEYWORD_SET(noinset)) ? noinset : 1.0

sinebands=41
npts=CCG_LIF(file=srfcfile)-1
lat=FLTARR(npts,sinebands)
mr=FLTARR(npts,sinebands)
decimal=DBLARR(npts)
;
;check site information 
;
site = (KEYWORD_SET(site)) ? site : ''

IF (( site NE '' ) AND (NOT KEYWORD_SET(s_info))) THEN BEGIN
   sitechk = CLEANSITE(site=site)
   IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."

   ;perlcode=dbdir+'ccg_siteinfo.pl -project=ccg_surface -site='+site
   perlcode=dbdir+'ccg_siteinfo.pl -site='+site
   SPAWN, perlcode,s_info
ENDIF

IF NOT KEYWORD_SET(s_info) THEN site='' ELSE site_info=STRSPLIT(s_info,'|',/EXTRACT)

;
;##############################################
; Read Surface File to compare dates
;##############################################
;
; There is a bug if the year range is greater than the data range. So, we must
; make sure that the year range is always equal to or less than the data range.
;
CCG_READ,file=srfcfile,skip=1,srfcdata
yrmin = FIX(MIN(srfcdata.field1))
yrmax = FIX(MAX(srfcdata.field1))

;
; If the user specifies one or zero year constraints, then only show 9 years of
; data. If both year constraints are set, do not change them.
;
IF ( yr1 EQ DEFAULT ) THEN BEGIN
   IF ( yr2 EQ -DEFAULT ) THEN BEGIN
      ; yr1 not set, yr2 not set
      yr2 = yrmax-1
      yr1 = (yr2-yrmin GT 9) ? yr2-9 : yrmin
   ENDIF ELSE BEGIN
      ; yr1 not set, yr2 set
      yr1 = (yr2-yrmin GT 9) ? yr2-9 : yrmin
   ENDELSE
ENDIF ELSE BEGIN
   IF ( yr2 EQ -DEFAULT ) THEN BEGIN
      ; yr1 set, yr2 not set
      yr2 = (yrmax-yr1 GT 9) ? yr1+9 : yrmax
   ENDIF ELSE BEGIN
      ; Both set, do nothing
   ENDELSE
ENDELSE

;
; If the year constraint is outside of the data range, change the constraint
;  so that it is in the data range otherwise the x-axis is incorrect
;
yr1 = ( yr1 LT yrmin ) ? yrmin : yr1
yr2 = ( yr2 GT yrmax ) ? (yrmax-1) : yr2

;
;##############################################
; Read Surface File
;##############################################
;
npts=0 & f=0. & s=''
x0=FLTARR(sinebands)
;
OPENR,unit,srfcfile,/GET_LUN
READF,unit,s
WHILE NOT EOF(unit) DO BEGIN
   READF,unit,FORMAT='(F12.6,41(1X,F12.4))',f,x0
   IF f GE yr1 AND f LE yr2+1 THEN BEGIN
      decimal[npts]=f
      lat[npts,*]=FINDGEN(sinebands)/20.0 - 1.0
      mr[npts,*]=x0
      npts=npts+1
   ENDIF
ENDWHILE
FREE_LUN,unit
;
yr1 = (yr1 EQ DEFAULT) ? FIX(decimal[0]) : yr1
yr2 = (yr2 EQ -DEFAULT) ? FIX(decimal[npts-2]) : yr2
nyrs=yr2-yr1+1 
;
;##############################################
; Transform Matrix (sine to degree latitude)
;##############################################
;
latbands=19               ;latitude bands every 10 degrees
latgrid=FLTARR(npts,latbands)         ;created degree/time/mr matrix

FOR i=0,npts-1 DO BEGIN
   coeff=SVDFIT(REFORM(lat[i,*]), REFORM(mr[i,*]), 10)
   l=(-90)
   FOR j=0,18 DO BEGIN
      k=sin(l*(!PI/180.))
      latgrid[i,j]= coeff[0]*k^0 + coeff[1]*k^1 + coeff[2]*k^2 + $
            coeff[3]*k^3 + coeff[4]*k^4 + coeff[5]*k^5 + $
            coeff[6]*k^6 + coeff[7]*k^7 + coeff[8]*k^8 + $
            coeff[9]*k^9; + coeff[10]*k^10
      l=l+10 
   ENDFOR 
ENDFOR
;
;##############################################
; Prepare Labels
;##############################################
;
lat=['90!eo!nS', '60!eo!nS', '30!eo!nS', '0!eo!n', '30!eo!nN', '60!eo!nN', ' ']

xcharsize = (KEYWORD_SET(xcharsize)) ? xcharsize : 0.45-0.10*(nyrs GE 10)

z=INDGEN(nyrs)+yr1
IF nyrs GT 10 THEN BEGIN
   z = TEMPORARY(z)-1900
   j=WHERE(z GE 100)
   IF j[0] NE -1 THEN z[j]=z[j]-100
   xlbl=STRCOMPRESS(STRING(FORMAT='(I2.2)',z),/RE)
ENDIF ELSE xlbl=STRCOMPRESS(STRING(FORMAT='(I4.4)',z),/RE)

xmin=0
xmax=npts-1
xminor = (nyrs EQ 1) ? 12 : 1

ymin=0
ymax=latbands-1
ystep=6
yminor=3

IF KEYWORD_SET(str_zaxis) THEN BEGIN
   tmp=STRSPLIT(str_zaxis,',',/EXTRACT)
   zaxis=[FLOAT(tmp[0]),FLOAT(tmp[1]),FIX(tmp[2]),FIX(tmp[3])]
ENDIF

IF SIZE(zaxis,/DIMENSION) EQ 4 THEN BEGIN
   ez = {  ZSTYLE:1,$
      ZRANGE:[zaxis[0],zaxis[1]], $
      ZTICKS:zaxis[2], $
      ZMINOR:zaxis[3]}
ENDIF ELSE BEGIN
   ez = {  ZSTYLE:16}
ENDELSE

e=CREATE_STRUCT(ez)

CASE sp OF 
'co2c13':BEGIN
   xrot0 = (xrot NE -1) ? xrot : 45
   zrot0 = (zrot NE -1) ? zrot : 15
   shade_position=[0.086,0.312,0.099,0.695]
   END
'co2o18':BEGIN
   xrot0 = (xrot NE -1) ? xrot : 45
   zrot0 = (zrot NE -1) ? zrot : 15
   shade_position=[0.086,0.312,0.099,0.695]
   END
'ch4c13':BEGIN
   xrot0 = (xrot NE -1) ? xrot : 45
   zrot0 = (zrot NE -1) ? zrot : 15
   shade_position=[0.086,0.312,0.099,0.695]
   END
ELSE:   BEGIN
   xrot0 = (xrot NE -1) ? xrot : 30
   zrot0 = (zrot NE -1) ? zrot : 20
   shade_position=[0.085,0.232,0.098,0.705]
   END
ENDCASE
;
x1=0.17 & x2=0.98 & y1=0.1 & y2=0.95
;
;##############################################
; Graphics
;##############################################
;
dev = (KEYWORD_SET(dev)) ? dev : ''
CCG_OPENDEV,dev=dev,pen=pen,/portrait,saveas=saveas, font='Helvetica'
;
;##############################################
; Determine Z range if not specified
;##############################################
;
IF KEYWORD_SET(shade) THEN BEGIN
   ;
   ;Define zrange
   ;
   tmp = e
   tmp.zstyle=tmp.zstyle+4
   SURFACE,latgrid,$
   /nodata,$   
   XSTYLE=1+4,$
   YSTYLE=1+4,$
   _EXTRA = tmp
   ERASE
ENDIF
;
;##############################################
; Logos
;##############################################
;
IF dev NE '' THEN BEGIN
   LOADCT,0

   xpos=0.86
   ypos=0.23

   noaa_height=0.085
   height=noaa_height
   portrait_ratio=1.294
   ratio=1.00

   width=portrait_ratio*ratio*height

   READ_JPEG, srcdir + 'logos/noaa_color.jpg', /true, a
   TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height

   j=WHERE(['co2c13','co2c14','co2o18','ch4c13'] EQ sp)
   IF j[0] NE -1 THEN BEGIN
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
   IF site NE '' THEN BEGIN
      perlcode=srcdir+'iadv_logos.pl -site='+site+' -project=ccg_surface'
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

            xpos=xpos-0.005-width

            READ_JPEG, srcdir + 'logos/' + image[0], /true, a
            TV,a,/true,xpos,ypos-(height/2.0),/normal,xsize=width,ysize=height
         ENDIF
      ENDFOR
   ENDIF
ENDIF

IF KEYWORD_SET(shade) THEN BEGIN
   site=''
   CCG_RGBLOAD,file=idldir + 'data/colortable4'
   MAX_COLOR=217

   range = !Z.CRANGE[1]-!Z.CRANGE[0]
   ref_values=FINDGEN((range)*100)/100.0+!Z.CRANGE[0]
   ref_bytescale=1.0*BYTSCL(ref_values,TOP=MAX_COLOR)
   shadearr=latgrid

   shadearr=MAKE_ARRAY(npts,latbands,/FLOAT,VALUE=0)

   FOR i=1,N_ELEMENTS(ref_values)-1 DO BEGIN
      j=WHERE(latgrid GE ref_values[i-1] AND latgrid LE ref_values[i])
      IF j[0] NE -1 THEN shadearr[j]=ref_bytescale[i-1]
   ENDFOR
ENDIF ELSE BEGIN
   CCG_RGBLOAD,file=idldir + 'data/color_comb1'
   shadearr=MAKE_ARRAY(npts,latbands,/FLOAT,VALUE=pen(3))
   
   IF site NE '' THEN BEGIN
      i=0
      l=(-90) 
      REPEAT BEGIN
         l=l+10 
         i=i+1
      ENDREP UNTIL SIN(l*(!PI/180.)) GT SIN(site_info[4]*(!PI/180.))
      IF i LT 18 THEN shadearr(*,i-1:i-1)=pen(2) ELSE shadearr(*,i-1:i)=pen(2)
      x1=0.1 & x2=0.9 & y1=0.1 & y2=0.9
   ENDIF
ENDELSE

x1=0.10 & y1=0.15 & x2=0.99 & y2=0.75
;
;----------------------------------------------- draw surface 
;
zticklen=(KEYWORD_SET(shade)) ? -0.035 : -0.02

SURFACE, latgrid, $
      POSITION=[x1,y1,x2,y2],$
      /NOERASE,$
      SHADE=shadearr,$

      _EXTRA = e,$
      ZTICKLEN=zticklen, $
      ZTHICK=thick,$
      ZTITLE=ztitle,$

      YSTYLE=1 + 4, $
      YRANGE=[ymin,ymax], $

      XSTYLE=1 + 4, $
      XRANGE=[xmin,xmax], $
      CHARTHICK=charthick,$
      CHARSIZE=charsize,$
      THICK=linethick,$
      AZ=zrot0, $
      AX=xrot0,$
      /SAVE

AXIS, YRANGE=[0,0], $
      YAXIS=0, $
      YMINOR=yminor, $
      YTICKS=ystep, $
      YTICKLEN=-0.02, $
      YTICKNAME=lat, $
      YTHICK=thick,$
      CHARTHICK=charthick,$
      YCHARSIZE=charsize*1.5, $
      YTITLE='LATITUDE', $
      /T3D

CCG_XLABEL, x1=xmin,x2=xmax,$
      y1=ymin,y2=ymax,$
      tarr=xlbl,$
      XMINOR=xminor, $
      XTHICK=thick,$
      XTITLE='YEAR', $
      XTICKLEN=-0.02,$
      CHARTHICK=0.75*charthick,$
      CHARSIZE=4.0*xcharsize,$
      noupper=1,$
      T3D=1

z = CCG_SYSDATE()

XYOUTS, xmin+(xmax-xmin)*0.02,ymin+0.5,$
      Z=!Z.CRANGE[0],$
      /DATA,$
      z.s9,$
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick,$
      ALI=0,$
      /T3D

XYOUTS, xmax-(xmax-xmin)*0.02,ymin+0.5,$
      Z=!Z.CRANGE[0],$
      /DATA,$
      custom,$
      CHARSIZE=0.75*charsize,$
      CHARTHICK=0.75*charthick,$
      ALI=1.0,$
      /T3D

XYOUTS, 0.5, 0.80,$
      /NORMAL,$
      'Global Distribution of '+gasname,$
      CHARSIZE=charsize,$
      CHARTHICK=0.75*charthick,$
      ALI=0.5

IF site NE '' THEN BEGIN

str ='[10!eo!n latitude band in which '+site_info[2]+', '+site_info[3]+' resides is highlighted]'

XYOUTS, 0.5, 0.78,$
      /NORMAL,$
      str,$
      CHARSIZE=0.55*charsize,$
      CHARTHICK=0.75*charthick,$
      ALI=0.5

ENDIF

IF KEYWORD_SET(shade) AND xrot+zrot EQ -2 THEN BEGIN

   cells=56
   tarr=STRCOMPRESS(STRING($
   INDGEN(!Z.TICKS+1)*(!Z.CRANGE[1]-!Z.CRANGE[0])/!Z.TICKS+!Z.CRANGE[0]),/RE)

   CCG_COLORBAR, position=shade_position,$
         colorarr=ref_bytescale,$
         cells=cells,$
         tarr=tarr,$

         charsize=charsize,$
         charthick=charthick,$
         orientation='vertical',$
         /noaxis,$

         minor=1,$
         ticklen=(-0.25),$
         title=ztitle
ENDIF
;
;------------------------------------------------ close up shop 
;
CCG_CLOSEDEV,dev=dev,saveas=saveas
END
