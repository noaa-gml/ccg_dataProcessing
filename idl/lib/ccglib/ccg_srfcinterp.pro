;+
; NAME:
;	CCG_SRFCINTERP
;
; PURPOSE:
;	Linear interpolate values from a CCG-formatted
;	surface (time by latitude by mixing/isotope 
;	ratio) at time and/or latitude values specified
;	by the user.
;
;	In order to produce an interpolated value, the
;	input time and latitude must be bracketed by 
;	surface values in both time and latitude.
;	If this condition is not satisfied, an interpolated
;	value is not returned and the input time step and 
;	latitude are excluded from the output vectors.
;
;	Warning:  	Before using a surface file, know the
;			conditions in which the surface is 
;			constructed.  
;
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	CCG_SRFCINTERP,	srfcfile='favorite_surface',site='cgo',saveas='~ken/temp'
;	CCG_SRFCINTERP,	srfcfile='~ken/tmp/surface.c13',lat=82.45,x=x,y=y,z=z
;	CCG_SRFCINTERP,	srfcfile='surface.mbl.ch4',inputfile='~ken/mylats',struct=s
;
; INPUTS:
;	srfcfile:	Surface file.  Surface file must have a single header 
;			line containing "FORMAT='(F12.6,41(1X,F12.4))'".  Data
;			records following header must be formatted according to
;			FORMAT.
;
;	NOTE:		User may specify one of the following input keywords:
;
;	site:   	If the user wants interpolated values from the surface
;			at the latitude of one or more sampling sites and at 
;			the time steps of the surface itself then this keyword is
;			specified.  'site' may be a vector or a string constant, 
;			e.g., site=['brw','spo','mlo'] or site='brw'.
;
;	lat:		If the user wants interpolated values from the surface
;			at one or more latitudes and at the time steps of the surface
;			itself then this keyword is specified.  'lat' may be a 
;			vector or a constant, e.g., lat=[15.08,-7.95] or lat=15.08.
;
;	inputfile:	If the user wants interpolated values from the surface at 
;			specified times and latitudes (e.g., discrete sampling
;			times and locations) then an input file must be provided.  
;			The file must have the following format:
;
;				1990.5123	15.08
;				1990.5225	15.08
;				1990.6122	15.08
;				1990.5123	-45.24
;				1990.5225	-45.24
;				1990.6122	-45.24
;
;			where column 1 contains decimal years and column 2
;			contains latitude in decimal degrees.
;
; OPTIONAL INPUT PARAMETERS:
;       saveas:         String constant specifying pathname where resulting
;			x,y,z vectors should be saved.  See OUTPUTS for
;			an explanation of x, y, and z vectors.
;
; OUTPUTS:
;	x:		Vector containing time in decimal years.  
;			The vector will correspond to time steps provided
;			by the user when 'inputfile' is specified or will
;			contain the time steps from the surface file.
;
;	y:		Vector containing latitude in decimal degrees.  The
;			vector will correspond to latitudes provided by
;			the user when 'inputfile', 'lat', or 'site' is specified.
;
;	z:		Vector containing the interpolated mixing or isotope ratio
;			from the surface at corresponding 'x' and 'y' values.
;
;	NOTE:		If either 'lat' or 'site' is specified as a vector then
;			the lat[0] or latitude of site[0] will appear first in 
;			the vectors 'x', 'y', and 'z' followed by lat[1] or latitude
;			of site[1], etc.
;
;			For example, if lat=['brw','mlo'] and a surface spans
;			the period 1979-1998 with 'n' time steps then 
;
;			x=[1979.00000, 1979.020833 ... 1997.979167,
;			   1979.00000, 1979.020833 ... 1997.979167]
;
;			y=[71.32,      71.32,      ... 71.32,
;			   19.53,      19.53,      ... 19.53]
;
;			z=[340.026,    340.342,    ... 368.705,
;			   336.875,    337.180,    ... 365.382]
;			
;	struct:		Structure array containing time (in decimal years),
;			latitude (decimal degrees), and interpolated value.  
;			This structure is available only when either the keyword
;			'lat' or 'site' is specified.  The structure is defined
;			as follows:
;
;			struct.x 	time
;			struct.y1	latitude from lat[0] or site[0]
;			struct.z1	interpolated value at lat[0] or site[0]
;			struct.y2	latitude from lat[1] or site[1]
;			struct.z2	interpolated value at lat[1] or site[1]
;			struct.y3	latitude from lat[2] or site[2]
;			struct.z3	interpolated value at lat[2] or site[2]
;			.
;			.
;			.
;			struct.y<n>	latitude from lat[n-1] or site[n-1]
;			struct.z<n>	interpolated value at lat[n-1] or site[n-1]
;
;			where each structure tag is a vector corresponding in size
;			to the number of time steps in the surface.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Example:
;		IDL> CCG_SRFCINTERP,$
;		IDL> srfcfile='/projects/dei/ext/co2/results.ccg.1998/ref_mbl.mtx',$
;		IDL> site=['brw','spo'],struct=s
;		IDL> HELP,s,/str
;		** Structure <402db800>, 5 tags, length=29184, refs=1:
;		   X               DOUBLE    Array[912]
;		   Y1              DOUBLE    Array[912]
;                  Z1              FLOAT     Array[912]
;                  Y2              DOUBLE    Array[912]
;                  Z2              FLOAT     Array[912]
;
;		IDL> PLOT,s.x,s.z1,psym=4
;		IDL> OPLOT,s.x,s.z2,psym=3
;
; MODIFICATION HISTORY:
;	Written, KAM, April 1995.
;	Modified, KAM, March 1999.
;-
;
PRO 	CCG_SRFCINTERP, $
	srfcfile = srfcfile, $
	lat = lat, $
	site = site,$
	inputfile = inputfile, $
	x = x, y = y, z = z, $
	struct = struct, $
	saveas = saveas, $
   debug = debug, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC

debug = KEYWORD_SET( debug ) ? 1 : 0

ON_ERROR,       2
;
;----------------------------------------------- procedure description 
;
;
;misc initialization 
;
DEFAULT=(-999.999)
DEG2RAD=!PI/180.0
RAD2DEG=180.0/!PI

IF NOT CCG_VDEF(lat) AND NOT KEYWORD_SET(site) AND NOT KEYWORD_SET(inputfile) THEN $
	CCG_FATALERR,"'lat' or 'site' or 'inputfile' must be set.'

IF (CCG_VDEF(lat) AND KEYWORD_SET(site)) OR $
   (CCG_VDEF(lat) AND KEYWORD_SET(inputfile)) OR $
   (CCG_VDEF(site) AND KEYWORD_SET(inputfile)) THEN $
	CCG_FATALERR,"Specify only 1 of the following keywords: 'lat','site','inputfile'."

sinebands=41
npts=CCG_LIF(file=srfcfile)-1

srfc_x=DBLARR(npts)
srfc_y=DBLARR(sinebands)
srfc_z=DBLARR(npts,sinebands)
;
;Read surface file
;
i=0 & s='' & a=0D & b=DBLARR(sinebands)
CCG_FREAD,file=srfcfile,nc=42,skip=1,v
srfc_x = REFORM( v[0,*] )
srfc_y = DINDGEN(sinebands)/20.0 - 1.0
srfc_z = TRANSPOSE( v[1:*,*] )
;
;Initialize interpolation matrices.
;
IF CCG_VDEF(lat) THEN BEGIN
	interp_x=[0D]
	interp_y=[0D]
	;
	;User has supplied latitude value(s).
	;
	FOR i=0,N_ELEMENTS(lat)-1 DO BEGIN
		;
		;Interpolate values from the surface at the time
		;steps of the surface and the sine of the latitude(s)
		;provided by user.
		;
		interp_x=[interp_x,srfc_x]
		interp_y=[interp_y,MAKE_ARRAY(npts,/DOUBLE,VALUE=SIN(lat[i]*DEG2RAD))]
	ENDFOR
	interp_x=interp_x[1:*]
	interp_y=interp_y[1:*]
ENDIF

IF KEYWORD_SET(site) THEN BEGIN
	interp_x=[0D]
	interp_y=[0D]
	lat=[0D]
	;
	;User has supplied site name(s).
	;
	FOR i=0,N_ELEMENTS(site)-1 DO BEGIN
		;
		;Interpolate values from the surface at the time
		;steps of the surface and the sine of the latitude
		;of the site(s) provided by user.
		;
		interp_x=[interp_x,srfc_x]

		CCG_SITEINFO,site=site[i],sitedesc
		lat=[lat,sitedesc.lat]
		interp_y=[interp_y,MAKE_ARRAY(npts,/DOUBLE,VALUE=SIN(sitedesc.lat*DEG2RAD))]
	ENDFOR
	interp_x=interp_x[1:*]
	interp_y=interp_y[1:*]
	lat=lat[1:*]
ENDIF

IF KEYWORD_SET(inputfile) THEN BEGIN
	;
	;User has supplied an input file.
	;
	;Interpolate values from the surface at the time steps and
	;sine of the latitude provided by the user via the input
	;file.
	;
	CCG_FREAD,file=inputfile,nc=2,var
	interp_x=REFORM(var(0,*))
	interp_y=REFORM(SIN(DEG2RAD*var(1,*)))
ENDIF

ninterp=N_ELEMENTS(interp_x)
;
;Adjust extreme latitudes 
;
j=WHERE(interp_y LE -1)
IF j(0) NE -1 THEN interp_y(j)=(-0.9999999)
j=WHERE(interp_y GE +1)
IF j(0) NE -1 THEN interp_y(j)=(+0.9999999)

interp_z=MAKE_ARRAY(ninterp,/FLOAT,VALUE=DEFAULT)

IF debug EQ 1 THEN OPENW,fpdebug,GETENV("HOME") + '/ccg_srfcinterp.debug',/GET_LUN
;
;Loop through the arrays of time and latitude
;
FOR i=0,ninterp-1 DO BEGIN
	;
	;Get values from surface that
	;bracket the user-provided time
	;and latitude values.
	;
	px1=WHERE(srfc_x LE interp_x(i))
	px2=WHERE(srfc_x GT interp_x(i))
	py1=WHERE(srfc_y LE interp_y(i))
	py2=WHERE(srfc_y GT interp_y(i))
	;
	;Perform interpolation only if the
	;user-provided time and latitude
	;values are bracketed by surface
	;values.
	IF px1(0) NE -1 AND px2(0) NE -1 AND py1(0) NE -1 AND py2(0) NE -1 THEN BEGIN
		px1=px1(N_ELEMENTS(px1)-1)
		x1=srfc_x(px1)
		px2=px2(0)
		x2=srfc_x(px2)
		py1=py1(N_ELEMENTS(py1)-1)
		y1=srfc_y(py1)
		py2=py2(0)
		y2=srfc_y(py2)

      IF debug EQ 1 THEN BEGIN
         PRINTF,fpdebug, " "
         PRINTF,fpdebug, "NEW TIME STEP"
         PRINTF,fpdebug,FORMAT='(3(A26))','x1', 'xinterp','x2'
         PRINTF,fpdebug,FORMAT='(3(F26.6))',x1,interp_x(i),x2
         PRINTF,fpdebug,FORMAT='(3(A26))','y1', 'yinterp','y2'
         PRINTF,fpdebug,FORMAT='(3(F26.4))',y1,interp_y(i),y2
         PRINTF,fpdebug,FORMAT='(4(A26))','z_at_x1y1', 'z_at_x1y2', 'z_at_x2y1','z_at_x2y2'
         PRINTF,fpdebug,FORMAT='(4(F26.4))',srfc_z(px1,py1),$
         	srfc_z(px1,py2),srfc_z(px2,py1),srfc_z(px2,py2)
      ENDIF
		;
		;This APPROACH determines an intercept at t=0.
		;This approach is valid as long as there are no
		;instrument precision limitations.
		;
		;There are two methods of interpolation, both yield the same result.
		;
		;METHOD 1 - Find the point between x1 and x2 then interpolate ynot.
		;
		m=(srfc_z(px2,py1)-srfc_z(px1,py1))/(x2-x1)
		b=srfc_z(px2,py1)-x2*m
		z_at_xnot_y1=interp_x(i)*m+b
		m=(srfc_z(px2,py2)-srfc_z(px1,py2))/(x2-x1)
		b=srfc_z(px2,py2)-x2*m
		z_at_xnot_y2=interp_x(i)*m+b
		m=(z_at_xnot_y2-z_at_xnot_y1)/(y2-y1)
		b=z_at_xnot_y2-y2*m
		z_at_xnot_ynot=interp_y(i)*m+b
		;
		;METHOD 2 - Find the point between y1 and y2 then interpolate xnot.
		;
		m=(srfc_z(px1,py2)-srfc_z(px1,py1))/(y2-y1)
		b=srfc_z(px1,py2)-y2*m
		z_at_ynot_x1=interp_y(i)*m+b
		m=(srfc_z(px2,py2)-srfc_z(px2,py1))/(y2-y1)
		b=srfc_z(px2,py2)-y2*m
		z_at_ynot_x2=interp_y(i)*m+b
		m=(z_at_ynot_x2-z_at_ynot_x1)/(x2-x1)
		b=z_at_ynot_x2-x2*m
		z_at_ynot_xnot=interp_x(i)*m+b

      IF debug EQ 1 THEN BEGIN
         PRINTF,fpdebug, "Approach 1"
         PRINTF,fpdebug,FORMAT='(2(A26))','z_at_xinterp_yinterp', 'z_at_yinterp_xinterp'
         PRINTF,fpdebug,FORMAT='(2(F26.4))',z_at_xnot_ynot,z_at_ynot_xnot
      ENDIF
		;
		;This APPROACH is computationally better than 
		;the above method because I am not determining 
		;an intercept with t=0.
		;
		;There are two methods of interpolation, both yield the same result.
		;
		;METHOD 1 - Find the point between x1 and x2 then interpolate ynot.
		;
		m=(srfc_z(px2,py1)-srfc_z(px1,py1))/(x2-x1)
		z_at_xnot_y1=srfc_z(px1,py1)+m*(interp_x(i)-x1)

		m=(srfc_z(px2,py2)-srfc_z(px1,py2))/(x2-x1)
		z_at_xnot_y2=srfc_z(px1,py2)+m*(interp_x(i)-x1)

		m=(z_at_xnot_y2-z_at_xnot_y1)/(y2-y1)
		z_at_xnot_ynot=z_at_xnot_y1+m*(interp_y(i)-y1)
		;
		;METHOD 2 - Find the point between y1 and y2 then interpolate xnot.
		;
		m=(srfc_z(px1,py2)-srfc_z(px1,py1))/(y2-y1)
		z_at_ynot_x1=srfc_z(px1,py1)+m*(interp_y(i)-y1)

		m=(srfc_z(px2,py2)-srfc_z(px2,py1))/(y2-y1)
		z_at_ynot_x2=srfc_z(px2,py1)+m*(interp_y(i)-y1)

		m=(z_at_ynot_x2-z_at_ynot_x1)/(x2-x1)
		z_at_ynot_xnot=z_at_ynot_x1+m*(interp_x(i)-x1)

		IF debug EQ 1 THEN BEGIN
         PRINTF,fpdebug, "Approach 2"
         PRINTF,fpdebug,FORMAT='(2(A26))','z_at_xinterp_yinterp', 'z_at_yinterp_xinterp'
         PRINTF,fpdebug,FORMAT='(2(F26.4))',z_at_xnot_ynot,z_at_ynot_xnot
      ENDIF
		;
		;Save results to z vector
		;
		interp_z(i)=z_at_xnot_ynot
	ENDIF
ENDFOR
IF debug EQ 1 THEN FREE_LUN,fpdebug

j=WHERE(interp_z-1 GT DEFAULT)
x=interp_x(j)
y=RAD2DEG*ASIN(interp_y(j))
z=interp_z(j)

dummy=x(SORT(x))
struct=CREATE_STRUCT('x',dummy(UNIQ(dummy)))

IF CCG_VDEF(lat) THEN BEGIN
	FOR i=0, N_ELEMENTS(lat)-1 DO BEGIN
		j=WHERE(CCG_ROUND(y,-3) EQ CCG_ROUND(lat[i],-3))
		IF j[0] NE -1 THEN struct=CREATE_STRUCT(struct,$
			'y'+STRCOMPRESS(STRING(i+1),/RE),y[j],$
			'z'+STRCOMPRESS(STRING(i+1),/RE),z[j])
	ENDFOR
ENDIF
;
;Save results?
;
IF KEYWORD_SET(saveas) THEN CCG_FWRITE,file=saveas,nc=3,double=1,x,CCG_ROUND(y,-3),z
END
