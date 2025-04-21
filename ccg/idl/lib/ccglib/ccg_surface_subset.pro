;+
; z=ccg_surface_subset(infile='/ccg/dei/ext/co2/results.flask.2011/surface.mbl.co2',sp='co2',lat='-30,0')
; z=ccg_surface_subset(infile='/ccg/dei/ext/co2/results.flask.2011/surface.mbl.co2',sp='co2',lat='0,90',date='2007,2008')
; z=ccg_surface_subset(infile='/ccg/dei/ext/co2/results.flask.2011/surface.mbl.co2',sp='co2',reference_type='meridional',date='2007,2008')
; z=ccg_surface_subset(infile='/ccg/dei/ext/co2/results.flask.2012/surface.mbl.co2',sp='co2',slat='0.8,1')
;-

@ccg_utils.pro

PRO PLOT_SURFACE_SUBSET, $
   surface=surface, $
   subset=subset, $
   sp=sp, $
   dev=dev

   CASE sp OF
      'co2': range=2
      'ch4': range=20
      ELSE:  range=0.2
   ENDCASE

   ;----------------------------------------------- set up plot device 
    
   CCG_OPENDEV,dev=dev,pen=pen
    
   ;----------------------------------------------- misc initialization 
    
   DEFAULT=(-999.99)
   plotcolor=pen(1)
   ticklen=(-0.02)

   plotthick=2.0
   charthick=2.0
   charsize=2.0

   ;----------------------------------------------- plotting ranges

   yr1 = FIX( MIN( surface.data.dd ) )
   yr2 = CEIL( MAX( surface.data.dd ) )

   ymin=(-1.0)
   ymax=(1.0)
   yticks=4

   lat=   [' -1','-.5','  0',' .5','  1']
   deg=['90!eo!nS', '30!eo!nS', 'EQ', '30!eo!nN', '90!eo!nN']
   degv=[-1,-0.5,0, 0.5,1] 

   PLOT,	[0],[0],$
      position=[0.10, 0.20, 0.90, 0.90],$
      /NOERASE,$
      /NODATA,$
      XSTYLE=1,$
      YSTYLE=1+4,$
      XRANGE=[yr1,yr2],$
      XTICKLEN=ticklen,$
      XMINOR=2,$
      YRANGE=[ymin,ymax],$
      COLOR=plotcolor,$
      CHARSIZE=charsize,$
      CHARTHICK=charthick,$
      XTHICK=plotthick,$
      XCHARSIZE=0.55,$
      TITLE=title,$
      XTITLE="YEAR"

   AXIS,           YRANGE=[ymin,ymax], $
                   YAXIS=0,$
                   YMINOR=5, $
                   YTICKS=4, $
                   YTICKLEN=(-0.01), $
                   YTICKNAME=lat, $
                   YCHARSIZE=1.0, $
                   YTHICK=plotthick,$
                   YTITLE='SINE LATITUDE', $
                   CHARTHICK=charthick,$
                   CHARSIZE=charsize

   AXIS,           YRANGE=[ymin,ymax], $
                   YAXIS=1,$
                   YTHICK=plotthick,$
                   YTITLE='DEGREE LATITUDE',$
                   CHARTHICK=charthick,$
                   CHARSIZE=charsize,$
                   YTICKV=degv, $
                   YMINOR=1, $
                   YTICKS=4, $
                   YTICKLEN=(-0.01), $
                   YTICKNAME=deg, $
                   YCHARSIZE=1.0

   CCG_SYMBOL,	sym=17
   CCG_RGBLOAD, file='/home/ccg/ken/idl/color/color_CT'
   maxcolors = 9

   data_range = FINDGEN( maxcolors ) * range/(maxcolors-1) - range/2.0
   color_range = [1,64,80,112,255,144,192,224,240]

   FOR i=0,N_ELEMENTS(surface.sinelat)-1 DO BEGIN

      FOR j=0,N_ELEMENTS(subset.data.dd)-1 DO BEGIN
         OPLOT, [ surface.data[j].dd ], [ surface.sinelat[i] ], $
         PSYM=8,$
         SYMSIZE=0.85,$
         COLOR=109
      ENDFOR

   ENDFOR

   FOR i=0,N_ELEMENTS(subset.sinelat)-1 DO BEGIN

      IF subset.sinelat[i] LT DEFAULT+1 THEN CONTINUE

      FOR j=0,N_ELEMENTS(subset.data.dd)-1 DO BEGIN

         IF subset.data[j].value[i] LT DEFAULT+1 THEN CONTINUE

         OPLOT, [ subset.data[j].dd ], [ subset.sinelat[i] ], $
         PSYM=8,$
         SYMSIZE=0.85,$
         COLOR=color_range[2]

      ENDFOR

   ENDFOR

   CCG_GASINFO,sp=sp,gasinfo
   
   CCG_COLORBAR,$
   colorarr=color_range, $
   tarr = ToString( data_range ), $
   title=gasinfo.title, $
   charsize = charsize * 0.40, $
   charthick = 1, $
   position=[0.2, 0.07, 0.8, 0.09],$
   cells=maxcolors, $
   /center, $
   labelcolor=0

   CCG_CLOSEDEV,dev=dev

END

FUNCTION CCG_SURFACE_SUBSET, $
   infile=infile, $
   saveas=saveas, $
   sp=sp, $
   lat=lat, $
   slat=slat, $
   date=date, $
   reference_type=reference_type, $
   error=error, $
   nographics=nographics, $
   dev=dev, $
   help=help

   ; Note, in this code...

   ; surface0 is original surface from infile.
   ; surface1 is surface0 with time constraint is applied.
   ; surface2 is surface0 with BOTH time and latitude constraint is applied.

   IF KEYWORD_SET( help ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( infile ) THEN CCG_SHOWDOC

   ;***************************************************
   ; Initialization 

   DEFAULT=(-999.999)
   DEG2RAD=!PI/180.0
   RAD2DEG=180.0/!PI

   nsinebands=41

   sinelat = FINDGEN( nsinebands )*0.05-1

   reference_type = KEYWORD_SET( reference_type ) ? reference_type : 'zonal'
   nographics = KEYWORD_SET( nographics ) ? 1 : 0
   error = [""]
    
   ;***************************************************
   ; Does infile exist?

   IF FILE_TEST( infile ) EQ 0 THEN BEGIN

      error = [ error, "File " + infile + " does not exist." ]
      RETURN, 1

   ENDIF

   ;***************************************************
   ; Read surface input file

   CCG_READ, file=infile, comment='#', data

   ndd = N_ELEMENTS( data.field1 )

   a = { dd:0D, dd2:0D, value:FLTARR( nsinebands ) }
   surface0 = { data:REPLICATE( a, ndd ), sinelat:FINDGEN( nsinebands ) *0.05 - 1 }

   FOR i=0,ndd-1 DO BEGIN

      tmp = STRSPLIT( data[i].str, /EXTRACT )
      surface0.data[i].dd = DOUBLE( tmp[0] )
      surface0.data[i].value = FLOAT( tmp[1:*] )

   ENDFOR

   surface0.data.dd2 = surface0.data.dd

   ; Note, in this code...

   ; surface0 is original surface from infile.
   ; surface1 is surface0 with time constraint is applied.
   ; surface2 is surface0 with BOTH time and latitude constraint is applied.

   surface1 = surface0

   ;***************************************************
   ; Set date_ and lat_ default values (derived from original surface)

   min = MIN( surface0.data.dd, MAX=max )
   date_ = [ DateObject( isodate=ToString( min ) ), DateObject( isodate=ToString( max ) ) ]

   lat_ = REPLICATE( { sine:0.0, deg:0.0 }, 2 )
   lat_[0].sine = -1 & lat_[0].deg = -90
   lat_[1].sine = 1 & lat_[1].deg = 90

   ;***************************************************
   ; Apply DATE Constraint ONLY if date KEYWORD is set

   IF KEYWORD_SET( date ) THEN BEGIN

      ; Overwrite default date_ values

      tmp = STRSPLIT( ToString( date ), ",", /EXTRACT)
      date_ = N_ELEMENTS( tmp ) EQ 1 ? [ tmp[0],tmp[0] ]: tmp
      date_ = [ DateObject( isodate=ToString(date_[0]) ), DateObject( isodate=ToString(date_[1]), /ed ) ]

      IF date_[1].dd LT date_[0].dd THEN BEGIN

         error = [ error, "Date range must be 'date1,date2' with date2 greater than date1." ]
         RETURN, 1

      END

      ; Find the time steps bounding the MINIMUM input date range.
      ; The minimum input date must be bounded by timesteps from the surface
      ; or must exactly equal a timestep of the surface

      j = WHERE( surface0.data.dd LE date_[0].dd, COMPLEMENT=k )

      IF j[0] EQ -1 THEN BEGIN

         z = date_[0].dbdate
         date_[0] = DateObject( dd=MIN( surface0.data.dd ) )

         error = [ error, "There are no time steps in source reference file that provide a lower bound for " + $
                   z + ". Using " + date_[0].dbdate + "." ]

         j = WHERE( surface0.data.dd LE date_[0].dd, COMPLEMENT=k )

      ENDIF

      IF surface0.data[j[N_ELEMENTS(j)-1]].dd NE date_[0].dd AND k[0] EQ -1 THEN BEGIN

         z = date_[0].dbdate
         date_[0] = DateObject( dd=MIN( surface0.data.dd ) )

         error = [ error, "There are no time steps in source reference file that provide an upper bound for " + $
                   z + ". Using " + date_[0].dbdate + "." ]

         j = WHERE( surface0.data.dd LE date_[0].dd, COMPLEMENT=k )

      ENDIF
      
      ; For each sine latitude linearly interpolate between t1 and t2

      pt1 = j[N_ELEMENTS(j)-1]
      pt2 = k[0]

      t1 = surface0.data[pt1].dd
      t2 = surface0.data[pt2].dd
      v1 = surface0.data[pt1].value
      v2 = surface0.data[pt2].value
      tnot = date_[0].dd

      print,t1,tnot,t2

      m = ( v2-v1 )/( t2-t1 )
      b = v1 - ( m * t1 )
      surface1.data[pt1].value = b + ( m * tnot )
      surface1.data[pt1].dd = tnot

      IF ( pt1 GT 0 ) THEN BEGIN 

         surface1.data[0:pt1-1].value = DEFAULT
         surface1.data[0:pt1-1].dd2 = DEFAULT

      ENDIF

      ; Find the time steps bounding the MAXIMUM input date range.
      ; The maximum input date must be bounded by timesteps from the surface
      ; or must exactly equal a timestep of the surface

      j = WHERE( surface0.data.dd GE date_[1].dd, COMPLEMENT=k )

      IF j[0] EQ -1 THEN BEGIN

         z = date_[1].dbdate
         date_[1] = DateObject( dd=MAX( surface0.data.dd ) )

         error = [ error, "There are no time steps in source reference file that provide an upper bound for " + $
                   z + ". Using " + date_[1].dbdate + "." ]

         j = WHERE( surface0.data.dd GE date_[1].dd, COMPLEMENT=k )

      ENDIF

      IF surface0.data[j[0]].dd NE date_[1].dd AND k[0] EQ -1 THEN BEGIN

         z = date_[1].dbdate
         date_[1] = DateObject( dd=MAX( surface0.data.dd ) )

         error = [error, "There are no time steps in source reference file that provide a lower bound for " + $
                  z + ". Using " + date_[1].dbdate + "." ]

         j = WHERE( surface0.data.dd GE date_[1].dd, COMPLEMENT=k )

      ENDIF
      
      ; For each sine latitude linearly interpolate between t1 and t2

      pt1 = k[N_ELEMENTS(k)-1]
      pt2 = j[0]

      t1 = surface0.data[pt1].dd
      t2 = surface0.data[pt2].dd
      v1 = surface0.data[pt1].value
      v2 = surface0.data[pt2].value
      tnot = date_[1].dd

      print,t1,tnot,t2

      m = ( v2-v1 )/( t2-t1 )
      b = v1 - ( m * t1 )
      surface1.data[pt2].value = b + ( m * tnot )
      surface1.data[pt2].dd = tnot

      IF ( pt2 LT N_ELEMENTS( surface0.data )-1 ) THEN BEGIN 

         surface1.data[pt2+1:*].value = DEFAULT
         surface1.data[pt2+1:*].dd2 = DEFAULT

      ENDIF

   ENDIF

   ; Note, in this code...

   ; surface0 is original surface from infile.
   ; surface1 is surface0 with time constraint is applied.
   ; surface2 is surface0 with BOTH time and latitude constraint is applied.

   surface2 = surface1

   ;***************************************************
   ; Apply a LATITUDE Constraint regardless of "lat" keyword

   CASE 1 OF 

   CCG_VDEF( lat ): BEGIN

      tmp = STRSPLIT( ToString( lat ), ",", /EXTRACT)

      lat_.deg = N_ELEMENTS( tmp ) EQ 1 ? FLOAT( [tmp[0], tmp[0]] ) : FLOAT( tmp )
      lat_.sine = SIN( DEG2RAD * lat_.deg )

   END

   CCG_VDEF( slat ): BEGIN

      tmp = STRSPLIT( ToString( slat ), ",", /EXTRACT)

      lat_.sine = N_ELEMENTS( tmp ) EQ 1 ? FLOAT( [tmp[0], tmp[0]] ) : FLOAT( tmp )
      lat_.deg = RAD2DEG * ASIN( lat_.sine )

   END

   ELSE: BEGIN

      tmp = [-1,1]
      lat_.sine = N_ELEMENTS( tmp ) EQ 1 ? FLOAT( [tmp[0], tmp[0]] ) : FLOAT( tmp )
      lat_.deg = RAD2DEG * ASIN( lat_.sine )

   END

   ENDCASE

   IF lat_[1].sine LT lat_[0].sine THEN BEGIN

      error = [ error, "Latitude range must be 'lat1,lat2' with lat2 greater than lat1." ]
      RETURN, 1

   END

   ; Find the latitudes bounding the MINIMUM INPUT LATITUDE range.
   ; The minimum input latitude must be bounded by latitudes from the surface
   ; or must exactly equal a latitude of the surface

   j = WHERE( surface1.sinelat LE lat_[0].sine, COMPLEMENT=k )

   IF j[0] EQ -1 THEN BEGIN
      error = [ error, "There are no latitude steps in source reference file that provide a lower bound for " + ToString( lat_[0].deg ) + "." ]
      RETURN, 1
   ENDIF

   IF surface1.sinelat[j[N_ELEMENTS(j)-1]] NE lat_[0].sine AND k[0] EQ -1 THEN BEGIN
      error = [ error, "There are no latitude steps in source reference file that provide an upper bound for " + ToString( lat_[0].deg ) + "." ]
      RETURN, 1
   ENDIF
   
   ; For each time step linearly interpolate between l1 and l2

   pl1 = j[N_ELEMENTS(j)-1]
   pl2 = k[0] NE -1 ? k[0] : pl1

   l1 = surface1.sinelat[pl1]
   l2 = surface1.sinelat[pl2]
   v1 = surface1.data.value[pl1]
   v2 = surface1.data.value[pl2]
   lnot = lat_[0].sine

   print,l1,lnot,l2

   surface2.sinelat[pl1] = lnot

   IF l2-l1 NE 0 THEN BEGIN

      m = ( v2-v1 )/( l2-l1 )
      b = v1 - ( m * l1 )
      surface2.data.value[pl1] = b + ( m * lnot )

   ENDIF ELSE surface2.data.value[pl1] = v2


   IF pl1-1 GE 0 THEN BEGIN
      surface2.data.value[0:pl1-1] = DEFAULT
      surface2.sinelat[0:pl1-1] = DEFAULT
   ENDIF

   ; Find the latitudes bounding the MAXIMUM INPUT LATITUDE range.
   ; The maximum input latitude must be bounded by latitudes from the surface
   ; or must exactly equal a latitude of the surface

   j = WHERE( surface1.sinelat GE lat_[1].sine, COMPLEMENT=k )

   IF j[0] EQ -1 THEN BEGIN
      error = [ error, "There are no latitude steps in " + infile + " that provide an upper bound for " + ToString( lat_[1].deg ) + "." ]
      RETURN, 1
   ENDIF

   IF surface1.sinelat[j[0]] NE lat_[1].sine AND k[0] EQ -1 THEN BEGIN
      error = [ error, "There are no latitude steps in " + infile + " that provide a lower bound for " + ToString( lat_[1].deg ) + "." ]
      RETURN, 1
   ENDIF
   
   ; For each time step linearly interpolate between l1 and l2

   pl2 = j[0]
   pl1 = k[0] NE -1 ? k[N_ELEMENTS(k)-1] : pl2

   l1 = surface1.sinelat[pl1]
   l2 = surface1.sinelat[pl2]
   v1 = surface1.data.value[pl1]
   v2 = surface1.data.value[pl2]
   lnot = lat_[1].sine

   print,l1,lnot,l2

   surface2.sinelat[pl2] = lnot

   IF l2-l1 NE 0 THEN BEGIN

      m = ( v2-v1 )/( l2-l1 )
      b = v1 - ( m * l1 )
      surface2.data.value[pl2] = b + ( m * lnot )

   ENDIF ELSE surface2.data.value[pl2] = v2

   IF pl2 LT nsinebands-1 THEN BEGIN
      surface2.data.value[pl2+1:*] = DEFAULT
      surface2.sinelat[pl2+1:*] = DEFAULT
   ENDIF

   IF nographics EQ 0 THEN PLOT_SURFACE_SUBSET, surface=surface0, subset=surface2, sp=sp, dev=dev

   ;***************************************************
   ; Create surface subset based on DATE and LATITUDE constraints

   print,surface2.sinelat
   subset0 = { data:surface2.data[ WHERE( surface2.data.dd2 GT DEFAULT) ], sinelat:surface2.sinelat }

   ndd = N_ELEMENTS( subset0.data.dd )

   j = WHERE( subset0.sinelat GT DEFAULT )
   latsubset_idx = lat_[0].sine EQ lat_[1].sine ? j[0] : j
   latsubset = subset0.sinelat[latsubset_idx]

   a = { dd:0D, int_value:0.0, value:FLTARR( N_ELEMENTS( latsubset ) ) }
   subset = { data:REPLICATE( a, ndd ), sinelat:latsubset, int_value:FLTARR( N_ELEMENTS( latsubset ) )  }

   FOR i=0,ndd-1 DO BEGIN

      subset.data[i].dd = subset0.data[i].dd
      subset.data[i].value = subset0.data[i].value[latsubset_idx]

   ENDFOR

   error = N_ELEMENTS( error ) GT 1 ? error[1:*] : ""

   IF STREGEX( reference_type, "surface", /FOLD_CASE, /BOOLEAN ) EQ 1 THEN BEGIN

         result = { sinelat:subset.sinelat, data:subset.data, date:date_, lat:lat_, original:surface0, errors:error }
         RETURN, result

   ENDIF

   ;***************************************************
   ; Use Simpson's Rule derived from the midpoint rectangle 
   ; rule to compute numerical integration

   ;***************************************************
   ; Integrate over latitude

   IF STREGEX( reference_type, "zonal", /FOLD_CASE, /BOOLEAN ) EQ 1 THEN BEGIN

      IF nographics EQ 0 THEN BEGIN
         WINDOW,1
         !p.multi=[0,4,4,0]
      ENDIF

      ; latitude range of subset 

      lat_range = MAX( subset.sinelat ) - MIN( subset.sinelat )

      IF lat_range EQ 0 THEN BEGIN

         subset.data.int_value = subset.data.value[0]

      ENDIF ELSE BEGIN

         ; step through time and integrate latitudes 

         FOR i=0, N_ELEMENTS( subset.data.dd )-1 DO BEGIN

            integrated_value = 0.0
         
            FOR ii=0, N_ELEMENTS( subset.sinelat )-2 DO BEGIN

                  ybar = 0.5*( subset.data[i].value[ii] + subset.data[i].value[ii+1] )
                  dl = ABS( subset.sinelat[ii+1] - subset.sinelat[ii] )

                  integrated_value += ( ybar*dl ) / lat_range

            ENDFOR

            subset.data[i].int_value = integrated_value

            IF nographics EQ 0 THEN BEGIN
               plot,[subset.sinelat], [subset.data[i].value],title=ToString( subset.data[i].dd ), ystyle=16,psym=4
               oplot, !X.CRANGE, [integrated_value, integrated_value], linestyle=0
            ENDIF

         ENDFOR

      ENDELSE

      IF nographics EQ 0 THEN BEGIN 
         WINDOW,2
         !p.multi=0
         plot,[subset.data.dd], [subset.data.int_value],ystyle=16,psym=4
      ENDIF

      result = { data: TRANSPOSE( [[subset.data.dd], [subset.data.int_value]] ), date:date_, lat:lat_, errors:error }
      RETURN, result

   ENDIF

   ;***************************************************
   ; Integrate over time

   IF STREGEX( reference_type, "meridional", /FOLD_CASE, /BOOLEAN ) EQ 1 THEN BEGIN

      ; time range of subset 

      time_range = MAX( subset.data.dd ) - MIN( subset.data.dd )

      ; step through latitude and integrate times

      IF nographics EQ 0 THEN BEGIN
         WINDOW,1
         !p.multi=[0,4,4,0]
      ENDIF

      FOR i=0, N_ELEMENTS( subset.sinelat )-1 DO BEGIN

         integrated_value = 0.0
         
         FOR ii=0, N_ELEMENTS( subset.data.dd )-2 DO BEGIN

               ybar = 0.5*( subset.data[ii].value[i] + subset.data[ii+1].value[i] )
               dt = ABS( subset.data[ii+1].dd - subset.data[ii].dd )

               integrated_value += ( ybar*dt ) / time_range

         ENDFOR

         subset.int_value[i] = integrated_value
         
         IF nographics EQ 0 THEN BEGIN
            plot,title=ToString(subset.sinelat[i]), subset.data.dd, subset.data.value[i],ystyle=16,psym=4
            oplot, !X.CRANGE, [integrated_value, integrated_value], linestyle=0
         ENDIF

      ENDFOR

         IF nographics EQ 0 THEN BEGIN
            WINDOW,2
            !p.multi=0
            plot,subset.sinelat, subset.int_value,ystyle=16,psym=4
         ENDIF
         
         result = { data: TRANSPOSE( [[subset.sinelat], [subset.int_value]] ), date:date_, lat:lat_, errors:error }
         RETURN, result

   ENDIF

   RETURN, 0
END
