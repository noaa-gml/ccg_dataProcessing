;+
; compare_response_curves.pro
;
; compare_response_curves, sp = 'co', system='cocal-1', inst = 'lgr2', rawfile=['2014-01-08.0644.co','2014-02-05.0736.co']
;
;rawfile = ['2011-11-29.0935.co2','2011-11-30.0840.co2','2011-12-01.0940.co2']
; if set date range then will compare all nl raw files in that date range
; set primary to compare primary response curves, otherwise will compare normal
;  RESIDUALS IS NOT WORKING YET
;  PLOTTING RESP_RATIO DIFFERENCES DOES NOT WORK FOR PRIMARIES SINCE ORDER CHANGES
;
;	program = '/abc/abc/nlpro.py'  Allows different version of nlpro to be used. (optional)
;
;  ddir set different directory for files.  default is normal path.  Don't use ddir with date range
;
;
;line_arr = [1,1,1,5,5,5,0,0]
;
;-

; GET UTILITIES
@ccg_utils.pro
@ccg_graphics.pro


PRO 	COMPARE_RESPONSE_CURVES, $
	sp = sp, $
	system = system, $
	inst = inst, $    ; limit to one inst at a time
	rawfile = rawfile, $
	program = program, $
	date = date, $
	ddir = ddir, $
	primary = primary, $
	dilution = dilution, $
    ;n_standards = n_standards, $  ; use to filter out co2 curves vs high or low range or primary runs on other inst's n_standards = [12,16]
	year = year, $
	plot_curves = plot_curves, $
	plot_diff = plot_diff, $
	plot_resp_ratio = plot_resp_ratio, $
	plot_residuals = plot_residuals, $
    x_molefraction = x_molefraction, $  ; set to plot residuals vs mole fraction rather than resp_ratio
	refgas = refgas, $
	scale = scale, $
	moddate = moddate, $
	functype = functype, $
	nulltanks = nulltanks, $
	npoly = npoly, $
	extra_option = extra_option, $
	nolegend = nolegend, $
	xmin = xmin, $
	xmax = xmax, $
	xaxis = xaxis, $
	yaxis = yaxis, $
	no_title = no_title, $
	col_arr = col_arr, $
	line_arr = line_arr, $
    position = position, $
	dev = dev, $
	presentation = presentation, $
	orientation = orientation, $
	win = win

;rawfile = ['2011-11-29.0935.co2','2011-11-30.0840.co2','2011-12-01.0940.co2']
; if set date range then will compare all nl raw files in that date range
; set primary to compare primary response curves, otherwise will compare normal

;sp = 'CO2'
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR, 'Species required for this procedure.  Exiting ...'
IF NOT KEYWORD_SET(system) AND NOT KEYWORD_SET(ddir) THEN CCG_FATALERR, 'System required for this procedure.  Exiting ...'
IF NOT KEYWORD_SET(system) THEN system = ' '
IF NOT KEYWORD_SET(n_standards) THEN n_standards = [0,999]
CCG_GASINFO, sp = sp, gasdata
;IF NOT KEYWORD_SET(refgas) THEN refgas = ''
IF NOT KEYWORD_SET(program) THEN program = '/ccg/bin/nlpro.py'
IF KEYWORD_SET(refgas) THEN program = program + ' --refgasfile=' + refgas
IF KEYWORD_SET(functype) THEN program = program + ' --functype=' + functype
IF KEYWORD_SET(nulltanks) THEN program = program + ' --nulltanks=' + nulltanks
IF KEYWORD_SET(npoly) THEN program = program + ' --order=' + ToString(npoly)
IF KEYWORD_SET(scale) THEN program = program + ' --scale=' + ToString(scale)
IF KEYWORD_SET(moddate) THEN program = program + ' --moddate=' + ToString(moddate)
IF KEYWORD_SET(extra_option) THEN program = program + ' ' + extra_option

;;;;;;;;;;
; Setup plotting keywords
; use for plotting all in various colors
IF NOT KEYWORD_SET(col_arr) THEN $
	col_arr = [3,11,12,4,13,6,3,7,11,12,4,13,6,3,11,12,4,13,6,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6]
	;col_arr = [1,1,1,1,1,1,3,11,12,4,13,6,3,7,11,12,4,13,6,3,11,12,4,13,6,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6] ; gray first 6 results

; use for plotting in bw with 4th parent in red.  LGR
;col_arr = [1,1,1,1,1,1,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6]
; use for plotting in bw with 4th parent in red.  V3
;col_arr = [1,1,1,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6]
; use for old vs new ch 
;col_arr = [3,3,3,3,3,3,3,6,6,6,6,6,4,1,12,4,13,6,3,11,12,4,13,6,11,12,4,13,6,3,3,11,12,4,13,6,3,11,12,4,13,6]

;yaxis = ''
; yaxis for lgr dilution stds
;yaxis = [-4, 8, 6, 1]
; yaxis for lgr primary stds
;yaxis = [-2.0, 2.0, 4, 1]
; yaxis for vurf dilution stds
;yaxis = [-2.0, 2.0, 4, 1]

; yaxis for ch4 primary
;yaxis = [-10, 10, 5, 1]
; yaxis for co2 primary
;yaxis = [-0.10, 0.10, 5, 1]
;xaxis = [250, 550, 6, 1]


sym_arr = [1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6]
sym_arr = [4,5,6,1,2,3,4,5,6,2,3,4,5,6,1,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6]

IF KEYWORD_SET (presentation) THEN BEGIN
        ; plot settings for psc files
                presentation    = 1
                charsize        = 1.3
                xcharsize        = 1.0
                ycharsize        = 1.0
                leg_charsize    = 1.0
                charthick       = 5.5
                thin_charthick  = 2.0
                ;symsize         = 1.5
                symsize         = 2.5
                symthick        = 0.5
                linethick       = 5.5
                axis_thick      = 7.5
                gridstyle       = 0
                ticklen         = -0.02
                xpixels         = 675
                ypixels         = 900

ENDIF ELSE BEGIN
        ; plot settings for screen
                presentation    = 0
                charsize        = 1.3
                xcharsize        = 1.0
                ycharsize        = 1.0
                leg_charsize    = 1.2
                charthick       = 1.0
                thin_charthick  = 1.0
                symsize         = 1.5
                symthick        = 1.0
                linethick       = 1.0
                axis_thick      = 1.0
                gridstyle       = 0
                ticklen         = -0.02

ENDELSE
;;;;;;;;;

       ; Initialize data attribute array and
        ; the plot attribute array
        plot_attr_arr = 0
        np = 0

        data1_attr_arr = 0 ; curves
        data2_attr_arr = 0 ; curve diff
        data3_attr_arr = 0 ; ratios
        data4_attr_arr = 0 ; residuals
        nd1 = 0
        nd2 = 0
        nd3 = 0
        nd4 = 0


IF NOT KEYWORD_SET(win) THEN win = 0
max_diff = 0.0

; plot positions
	;plot_curves = plot_curves            data1_attr_arr
	;plot_diff = plot_diff   	      data2_attr_arr
	;plot_resp_ratio = plot_resp_ratio    data3_attr_arr
	;plot_residuals = plot_residuals      data4_attr_arr
nplots = 0
IF KEYWORD_SET(plot_curves) THEN nplots = nplots + 1
IF KEYWORD_SET(plot_diff) THEN nplots = nplots + 1
IF KEYWORD_SET(plot_resp_ratio) THEN nplots = nplots + 1
IF KEYWORD_SET(plot_residuals) THEN nplots = nplots + 1

IF NOT KEYWORD_SET(position) THEN BEGIN
    IF nplots EQ 1 THEN position = [0.2, 0.15, 0.9, 0.9] ELSE position = ''
ENDIF


;	;plot_resp_ratio = plot_resp_ratio, $
;IF KEYWORD_SET(plot_resp_ratio) THEN BEGIN
;	position1 = [0.2, 0.69, 0.9, 0.89]
;	position2 = [0.2, 0.42, 0.9, 0.62]
;	position3 = [0.2, 0.15, 0.9, 0.35]
;ENDIF ELSE BEGIN
;	position1 = [0.2, 0.57, 0.9, 0.9]
;	position2 = [0.2, 0.15, 0.9, 0.48]
;	position3 = [0.2, 0.75, 0.9, 0.9]
;ENDELSE

; if set date range then get all NL rawfiles within the date range.  Overwrites any
; files passed in by rawfile keyword.
IF KEYWORD_SET(date) THEN BEGIN

        ; check to see if date range passed in as a string (ex. '20130101,20131231')
        ndate = N_ELEMENTS(date)
        IF ndate EQ 1 THEN date = STRSPLIT(date, ',', /EXTRACT)

        ; if only one date passed in then use as start and end dates
        ndate = N_ELEMENTS(date)
        IF ndate EQ 1 THEN date = [date, date]

        ; remove dashed (ex 2013-01-01 to 20130101)
        date[0] = STRJOIN(STRSPLIT(date[0], '-', /EXTRACT))
        date[1] = STRJOIN(STRSPLIT(date[1], '-', /EXTRACT))

        ; set startdate and enddate objects.
        startdate = DateObject(date = date[0])
        enddate = DateObject(date = date[1], /ed)



	rawfile = 1
	; get list of rawfile names

    CASE STRUPCASE(system) OF
        'MLO': BEGIN
                searchdir = '/ccg/' + STRLOWCASE(sp) + '/in-situ/mlo_data/pic/nl/????/'
                search_tail = STRLOWCASE(sp)
                END

        'BRW': BEGIN
                searchdir = '/ccg/' + STRLOWCASE(sp) + '/in-situ/brw_data/lgr/nl/????/'
                search_tail = STRLOWCASE(sp)
                END

        ELSE:  BEGIN
                searchdir = '/ccg/' + STRLOWCASE(sp) + '/nl/' + STRLOWCASE(system) + '/raw/????/'
                search_tail = KEYWORD_SET(inst) ? STRLOWCASE(inst) + '.' + STRLOWCASE(sp) : '*.' + STRLOWCASE(sp)
                END
    ENDCASE

    search = searchdir + '????-??-??.[0-9]???.' + search_tail
    IF KEYWORD_SET(primary) THEN search = searchdir + '????-??-??.PRIM.' + search_tail
    IF KEYWORD_SET(dilution) THEN search = searchdir + '????-??-??.DILU.' + search_tail
	print,search
    
	CCG_DIRLIST, dir = search, list
    


	; loop through each rawfile, add to list if date is within range
	FOR i = 0, N_ELEMENTS(list) - 1 DO BEGIN
		name = FILE_BASENAME(list[i])
		tmp = STRSPLIT(name, '.', /EXTRACT)  ; split on '.' to remove hhmm.inst.sp

		t = STRSPLIT( tmp[0], '-', /EXTRACT) 

		f_date = DateObject( idate = [t[0], t[1], t[2]]) 

		IF (f_date.longdate GE startdate.longdate AND f_date.longdate LE enddate.longdate) THEN BEGIN $
			rawfile = (SIZE( rawfile, /TYPE) NE 7) ? [name] : [rawfile, name]
		ENDIF
	ENDFOR

ENDIF


; set dir for file 1   /ccg/co/nl/cocal-1/raw/2012/
IF KEYWORD_SET(ddir) THEN directory = ddir ELSE BEGIN 
	f1_yr = (KEYWORD_SET(year)) ? year : STRMID(rawfile[0], 0, 4)
    CASE STRUPCASE(system) OF
        'MLO':  directory = '/ccg/' + STRLOWCASE(sp) + '/in-situ/mlo_data/pic/nl/' + ToString(f1_yr) + '/'
        'BRW':  directory = '/ccg/' + STRLOWCASE(sp) + '/in-situ/brw_data/lgr/nl/' + ToString(f1_yr) + '/'
        ELSE:   directory = '/ccg/' + STRLOWCASE(sp) + '/nl/' + STRLOWCASE(system) + '/raw/' + ToString(f1_yr) + '/'
    ENDCASE
    
ENDELSE

f1_fn = directory + rawfile[0]

; process file 1 with -i to get the resp ratios 
cmd = program + ' -i ' + f1_fn
SPAWN, cmd, r1
; spit r1 to get resp ratios (need for scaling x-axis in plot)
FOR i = 0, N_ELEMENTS(r1) -1 DO BEGIN
	temp = STRSPLIT(r1[i], /EXTRACT)
	r1_resp_ratio = (SIZE(r1_resp_ratio, /TYPE) EQ 0) ? [FLOAT(temp[0])] : [r1_resp_ratio, FLOAT(temp[0])] 
	r1_unc_resp_ratio = (SIZE(r1_unc_resp_ratio, /TYPE) EQ 0) ? [FLOAT(temp[1])] : [r1_unc_resp_ratio, FLOAT(temp[1])] 
	r1_assigned = (SIZE(r1_assigned, /TYPE) EQ 0) ? [FLOAT(temp[2])] : [r1_assigned, FLOAT(temp[2])]
ENDFOR

; process r1 to get response curve
cmd = program + ' ' + f1_fn
SPAWN, cmd, r1 
; LGR6 2016 01 05 17 46          -0.00710000           1.62210000           0.00000000    0.00100    11 poly Ref_Divide 2016-01-05.0858.co2o18
r1_resp_curve = STRSPLIT( r1[0], /EXTRACT)


; get an array of resp ratios for plotting
;IF NOT KEYWORD_SET(xaxis) THEN xaxis = ''
nsteps = 200
IF NOT KEYWORD_SET(xmin) THEN xmin = MIN(r1_resp_ratio)
IF NOT KEYWORD_SET(xmax) THEN xmax = MAX(r1_resp_ratio)
;IF NOT KEYWORD_SET(xmin) THEN xmin = MIN(r1_resp_ratio) * 0.95
;IF NOT KEYWORD_SET(xmax) THEN xmax = MAX(r1_resp_ratio) * 1.05

x_interval = (xmax - xmin) / nsteps
x = FINDGEN(nsteps) * x_interval + xmin




; loop through remaining rawfiles, compare to file 1
FOR i = 0, N_ELEMENTS(rawfile) - 1 DO BEGIN
	; reset resp_ratio structure
	resp_ratio = ''
	unc_resp_ratio = ''
	resp_ratio_assigned = ''
	residuals = ''
	resid_assigned = ''

	; set dir for file i   /ccg/co/nl/LGR2/raw/2012/
	IF KEYWORD_SET(ddir) THEN directory = ddir ELSE BEGIN
		f_yr = (KEYWORD_SET(year)) ? year : STRMID(rawfile[i], 0, 4)
        CASE STRUPCASE(system) OF
            'MLO': directory = '/ccg/' + STRLOWCASE(sp) + '/in-situ/mlo_data/pic/nl/' + ToString(f_yr) + '/'
            'BRW': directory = '/ccg/' + STRLOWCASE(sp) + '/in-situ/brw_data/lgr/nl/' + ToString(f_yr) + '/'
        ELSE:   directory = '/ccg/' + STRLOWCASE(sp) + '/nl/' + STRLOWCASE(system) + '/raw/' + ToString(f_yr) + '/'
        ENDCASE

	ENDELSE

	fn = directory + rawfile[i]

	; process file[i] to get response curve
	cmd = program + ' ' + fn
	SPAWN, cmd, r

	; LGR2 2012 02 16 00 00    -3.976   129.024    -0.891   0.296     9  2012-02-15.0843.co
; LGR6 2016 01 05 17 46          -0.00710000           1.62210000           0.00000000    0.00100    11 poly Ref_Divide 2016-01-05.0858.co2o18
	PRINT, r
	resp_curve = STRSPLIT( r[0], /EXTRACT)
	date_label = resp_curve[N_ELEMENTS(resp_curve)-1]
	func_type =  resp_curve[N_ELEMENTS(resp_curve)-3]
	n_stds =  resp_curve[N_ELEMENTS(resp_curve)-4]
    ;IF n_stds LT n_standards[0] OR n_stds GT n_standards[1] THEN CONTINUE

	; make a data attribute array of the response curve
	IF STRUPCASE(func_type) EQ "POWER" THEN y = FLOAT(resp_curve[6]) + FLOAT(resp_curve[7])*x^FLOAT(resp_curve[8]) $
	ELSE  y = FLOAT(resp_curve[6]) + FLOAT(resp_curve[7])*x + FLOAT(resp_curve[8])*x^2
		
	upper_ymin = (SIZE(upper_ymin,/TYPE) EQ 0) ? MIN(y) : MIN([upper_ymin,y])
	upper_ymax = (SIZE(upper_ymax,/TYPE) EQ 0) ? MAX(y) : MAX([upper_ymax,y])


        d = DATA_ATTRIBUTES(x, y, $
                LINESTYLE = 0, $
                ;CHARTEXT = rawfile[i], $
                ;CHARTEXT = r[0], $
                CHARTEXT = (KEYWORD_SET(nolegend)) ? '' : date_label, $
                CHARTHICK = charthick, $
                CHARSIZE = leg_charsize, $
                ;SYMSTYLE = sym_arr[i], $
                LINECOLOR = col_arr[i], $
                LINETHICK = linethick) ;, $
                ;SYMSIZE = symsize, $
                ;SYMTHICK = symthick)

        ; add data attributes to data_attributes_array
        z = 'd' + ToString(nd1++)
        data1_attr_arr = SIZE(data1_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data1_attr_arr, z, d) : CREATE_STRUCT(z, d)



	; make a data attribute array of this respone curve minus the first response curve	
	IF STRUPCASE(func_type) EQ "POWER" THEN BEGIN 
		y1 = FLOAT(r1_resp_curve[6]) + FLOAT(r1_resp_curve[7])*x ^ FLOAT(r1_resp_curve[8])
		y = FLOAT(resp_curve[6]) + FLOAT(resp_curve[7])*x ^ FLOAT(resp_curve[8])
	ENDIF ELSE BEGIN
		y1 = FLOAT(r1_resp_curve[6]) + FLOAT(r1_resp_curve[7])*x + FLOAT(r1_resp_curve[8])*x^2
		y = FLOAT(resp_curve[6]) + FLOAT(resp_curve[7])*x + FLOAT(resp_curve[8])*x^2
	ENDELSE
	;y1 = r1_resp_curve[6] + r1_resp_curve[7]*x + r1_resp_curve[8]*x^2
	;y = resp_curve[6] + resp_curve[7]*x + resp_curve[8]*x^2
	diff = y - y1	

       ;x_plot = KEYWORD_SET(x_molefraction) ? original_value : original_residuals[0,*] 

        d = DATA_ATTRIBUTES(x, diff, $
                LINESTYLE = (KEYWORD_SET(line_arr)) ? line_arr[i] : 0, $
                ;CHARTEXT = rawfile[i], $
                ;CHARTEXT = (KEYWORD_SET(nolegend)) ? '' : r[0], $
                CHARTHICK = charthick, $
                CHARSIZE = leg_charsize, $
                ;SYMSTYLE = sym_arr[i], $
                LINECOLOR = col_arr[i], $
                LINETHICK = linethick) ;, $
                ;SYMSIZE = symsize, $
                ;SYMTHICK = symthick)

        ; add data attributes to data_attributes_array
        z = 'd' + ToString(nd2++)
        data2_attr_arr = SIZE(data2_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data2_attr_arr, z, d) : CREATE_STRUCT(z, d)



	; process file with -i to get the resp ratios 
	cmd = program +  ' -i ' + fn
	SPAWN, cmd, r

	; spit r to get resp ratios 
	FOR ii = 0, N_ELEMENTS(r) -1 DO BEGIN
		temp = STRSPLIT(r[ii], /EXTRACT)
		resp_ratio = (SIZE(resp_ratio, /TYPE) EQ 7) ? [FLOAT(temp[0])] : [resp_ratio, FLOAT(temp[0])] 
		unc_resp_ratio = (SIZE(unc_resp_ratio, /TYPE) EQ 7) ? [FLOAT(temp[1])] : [unc_resp_ratio, FLOAT(temp[1])] 
		resp_ratio_assigned = (SIZE(resp_ratio_assigned, /TYPE) EQ 7) ? [FLOAT(temp[2])] : [resp_ratio_assigned, FLOAT(temp[2])]
	ENDFOR


	; make a data attribute array of the response ratios to overplot on the response curve plot
        d = DATA_ATTRIBUTES(resp_ratio, resp_ratio_assigned, $
		YUNC = unc_resp_ratio, $
                LINESTYLE = -1, $
                SYMSTYLE = sym_arr[i], $
                SYMCOLOR = col_arr[i], $
                SYMSIZE = symsize, $
		SYMFILL = 1, $
                SYMTHICK = symthick)

        ; add data attributes to data_attributes_array
        z = 'd' + ToString(nd1++)
        data1_attr_arr = SIZE(data1_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data1_attr_arr, z, d) : CREATE_STRUCT(z, d)


	

;	; make a data attribute array of the response ratios minus the first rawfile response ratios
	IF KEYWORD_SET(plot_resp_ratio) THEN BEGIN
		diff = resp_ratio - r1_resp_ratio	
	
		md = MAX(ABS(diff))
		IF (md GT max_diff) THEN max_diff = md

	        d = DATA_ATTRIBUTES(resp_ratio_assigned, diff, $
			YUNC = unc_resp_ratio, $
	                LINESTYLE = -1, $
	                ;CHARTEXT = rawfile[i], $
                	;CHARTEXT = (KEYWORD_SET(nolegend)) ? '' : r[0], $
	                CHARTHICK = charthick, $
	                CHARSIZE = leg_charsize, $
	                SYMSTYLE = sym_arr[i], $
	                SYMCOLOR = col_arr[i], $
	                LINETHICK = linethick, $
	                SYMSIZE = symsize, $
			SYMFILL = 1, $
	               SYMTHICK = symthick)
	
	        ; add data attributes to data_attributes_array
	        z = 'd' + ToString(nd3++)
	        data3_attr_arr = SIZE(data3_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data3_attr_arr, z, d) : CREATE_STRUCT(z, d)
	ENDIF

	; process file with --resid to get the residuals 
	cmd = program + ' -v --resid ' + fn
	print, "cmd:  ", cmd
	SPAWN, cmd, r

	; spit r to get residuals
	FOR ii = 0, N_ELEMENTS(r) -1 DO BEGIN
		temp = STRSPLIT(r[ii], /EXTRACT)
		residuals = (SIZE(residuals, /TYPE) EQ 7) ? [FLOAT(temp[1])] : [residuals, FLOAT(temp[1])] 
		resid_assigned = (SIZE(resid_assigned, /TYPE) EQ 7) ? [FLOAT(temp[4])] : [resid_assigned, FLOAT(temp[4])]
	ENDFOR


	; make a data attribute array of the residuals
        d = DATA_ATTRIBUTES(resid_assigned, residuals, $
                CHARTEXT = (KEYWORD_SET(nolegend)) ? '' : date_label, $
                CHARTHICK = charthick, $
                CHARSIZE = leg_charsize, $
                LINESTYLE = -1, $
                SYMSTYLE = sym_arr[i], $
                SYMCOLOR = col_arr[i], $
                SYMSIZE = symsize, $
                SYMFILL = 1, $
                SYMTHICK = symthick)

        ; add data attributes to data_attributes_array
        z = 'd' + ToString(nd4++)
        data4_attr_arr = SIZE(data4_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data4_attr_arr, z, d) : CREATE_STRUCT(z, d)


ENDFOR ; end looping through raw files



	;plot_curves = plot_curves            data1_attr_arr
	;plot_diff = plot_diff   	      data2_attr_arr
	;plot_resp_ratio = plot_resp_ratio    data3_attr_arr
	;plot_residuals = plot_residuals      data4_attr_arr



; Make plot attributes for upper plot of curves
IF KEYWORD_SET(plot_curves) THEN BEGIN
	IF KEYWORD_SET(inst) THEN t = STRUPCASE(system) + '  ' + STRUPCASE(inst) ELSE t = STRUPCASE(system)
       p = PLOT_ATTRIBUTES(data = data1_attr_arr, $
                TITLE = (KEYWORD_SET(no_title)) ? ' ' : t + ':  Response Curves', $
		POSITION = position, $
                XAXIS = [xmin, xmax ,0,0], $
		YAXIS = KEYWORD_SET(yaxis) ? yaxis : [upper_ymin, upper_ymax, 0, 0], $
                PLOTTHICK = axis_thick,$
                CHARSIZE = charsize, $
                XCHARSIZE = xcharsize, $
                YCHARSIZE = ycharsize, $
                CHARTHICK = charthick, $
                XTITLE = xtitle, $
                YTITLE = gasdata.title, $
                XCUSTOM= xcustom, $
                LEGEND = 'TL')

        ; add plot attributes to plot_attributes_array
        z = 'p' + ToString(np++)
        plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)
ENDIF

; Make plot attributes for lower plot of differences
IF KEYWORD_SET(plot_diff) THEN BEGIN
	IF KEYWORD_SET(inst) THEN t = STRUPCASE(system) + '  ' + STRUPCASE(inst) ELSE t = STRUPCASE(system)
	p = PLOT_ATTRIBUTES(data = data2_attr_arr, $
		TITLE = (KEYWORD_SET(no_title)) ? ' ' : t + ':  Response Curve Differences', $
		POSITION = position, $
		;XAXIS = [-1,-1,4,1], $
		XAXIS = [xmin, xmax ,0,0], $
		YAXIS = KEYWORD_SET(yaxis) ? yaxis : '', $
		;YAXIS = [1800,2450,0,0], $
		PLOTTHICK = axis_thick,$
		CHARSIZE = charsize, $
		XCHARSIZE = xcharsize, $
		YCHARSIZE = ycharsize, $
		CHARTHICK = charthick, $
		XTITLE = xtitle, $
		YTITLE = gasdata.title, $
		XCUSTOM= xcustom, $
		LEGEND = 0)

	; add plot attributes to plot_attributes_array
	z = 'p' + ToString(np++)
	plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)
ENDIF

; Make plot attributes for third plot of resp_ratio differences
IF KEYWORD_SET(plot_resp_ratio) THEN BEGIN
	IF KEYWORD_SET(inst) THEN t = STRUPCASE(system) + '  ' + STRUPCASE(inst) ELSE t = STRUPCASE(system)
       p = PLOT_ATTRIBUTES(data = data3_attr_arr, $
		TITLE = (KEYWORD_SET(no_title)) ? ' ' : t + ':  Response Ratio Differences', $
		POSITION = position, $
		;XAXIS = [-1,-1,4,1], $
		;YAXIS = [1800,2450,0,0], $
		YAXIS = KEYWORD_SET(yaxis) ? yaxis : [-max_diff, max_diff, 0, 0], $
		PLOTTHICK = axis_thick,$
		CHARSIZE = charsize, $
		XCHARSIZE = xcharsize, $
		YCHARSIZE = ycharsize, $
		CHARTHICK = charthick, $
		XTITLE = gasdata.title, $
		YTITLE = 'Resp_ratio difference', $
		XCUSTOM= xcustom, $
		LEGEND = 'TL')

	; add plot attributes to plot_attributes_array
	z = 'p' + ToString(np++)
	plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)

ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IF KEYWORD_SET(plot_residuals) THEN BEGIN

	; make a data attribute array for line at 0 for the residuals plot
	;x = [MIN(resid_assigned), MAX(resid_assigned)]
	x = [-999, 9999]
	;x = [245, 525]
	y = [0, 0]
        d = DATA_ATTRIBUTES(x, y, $
                ;CHARTEXT = (KEYWORD_SET(nolegend)) ? '' : date_label, $
                ;CHARTHICK = charthick, $
                ;CHARSIZE = leg_charsize, $
                /NOSCALE, $
                LINETHICK = linethick, $
                LINESTYLE = 0, $
                LINECOLOR = 1 )
                ;SYMSTYLE = sym_arr[i], $
                ;SYMCOLOR = col_arr[i], $
                ;SYMSIZE = symsize, $
                ;SYMFILL = 1, $
                ;SYMTHICK = symthick)

        ; add data attributes to data_attributes_array
        z = 'd' + ToString(nd4++)
        data4_attr_arr = SIZE(data4_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data4_attr_arr, z, d) : CREATE_STRUCT(z, d)

	IF KEYWORD_SET(refgas) THEN BEGIN
		tmp=STRSPLIT(refgas,'/',/EXTRACT)
		ntmp=N_ELEMENTS(tmp)
		reffilename=tmp[ntmp-1]
	ENDIF ELSE BEGIN
		IF KEYWORD_SET(scale) THEN reffilename='scale: ' + scale ELSE reffilename = 'current_scale'
		IF KEYWORD_SET(moddate) THEN reffilename = reffilename + ', moddate: ' + ToString(moddate)
	ENDELSE		

	IF KEYWORD_SET(inst) THEN t = STRUPCASE(system) + '  ' + STRUPCASE(inst) ELSE t = STRUPCASE(system)
	p = PLOT_ATTRIBUTES( data = data4_attr_arr, $
                TITLE = (KEYWORD_SET(no_title)) ? ' ' : t + ':  Residuals!c'+ reffilename, $
                POSITION = position, $
                ;POSITION = [0.2, 0.40, 0.9, 0.70], $
                XAXIS = KEYWORD_SET(xaxis) ? xaxis : '', $
                YAXIS = KEYWORD_SET(yaxis) ? yaxis : '', $
                /NOGRID, $
                PLOTTHICK = axis_thick,$
                CHARSIZE = charsize, $
                XCHARSIZE = xcharsize, $
                YCHARSIZE = ycharsize, $
                CHARTHICK = charthick, $
                XTITLE = gasdata.title, $
                YTITLE = gasdata.title, $
                XCUSTOM= xcustom, $
                SLEGEND = 'TL')

        ; add plot attributes to plot_attributes_array
        z = 'p' + ToString(np++)
        plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)

ENDIF

IF NOT KEYWORD_SET(orientation) THEN BEGIN
	IF nplots GE 2 THEN orientation = "portrait" ELSE orientation = "landscape"
ENDIF

IF STRLOWCASE(orientation) EQ "portrait" THEN BEGIN
	portrait = 1 
	xpixels         = 675
	ypixels         = 900
ENDIF ELSE BEGIN
	portrait = 0
	xpixels         = 900
	ypixels         = 675
ENDELSE

row = nplots
column = 1


;; Submit to Graphics routine
CCG_GRAPHICS, graphics = plot_attr_arr, dev=dev, $
                window = win, portrait = portrait, xpixels = xpixels, ypixels = ypixels, $
		row = row, col = column




END
