;+
;	reprocess_nl_curves.pro
;
;	REPROCESS_NL_CURVES
;
;	Procedure to reprocess NL curves two differnt ways to compare the fit results.
;             	The terms original and new are arbitrary, both fits can have all options
;		changed.
;
;	reprocess_nl_curves, sp = 'co', inst = 'LGR2', rawfile = '2010-08-03.1024.co', $
;			new_refgas = '/home/ccg/co/temp_refgas.tab'
;
;		sp =  species 
;		system = system, $
;		inst = instrument code
;		rawfile = rawfile name
;		ddir = directory if the rawfile is not in the normal /ccg file structure
;
;		org_nlpro = version of nlpro to use for the original fit 
;		new_nlpro = version of nlpro to use for the new fit 
;			Default for both is /ccg/bin/nlpro
;
;		org_refgas = refgas table to use for the original plot
;		new_refgas = refgas table to use for the new plot 
;			Default for both is current DB table 
;
;		org_nulltanks = tanks to drop from the fit for the original plot
;		new_nulltanks = tanks to drop from the fit for the new plot 
;			ex. new_nulltanks = 'FB1234,FB5678,FB890'
;			Default for both is none
;
;		org_func = function type to use for the original fit (options are polynomial (default) or power)
;		new_func = function type to use for the new fit 
;			Options are 'poly' (default except for CH4 on H5), or 'power'
;
;		org_use_var = set to 1 to use 1/variance for weighting in ODR fit in original plot 
;		new_use_var = set to 1 to use 1/variance for weighting in ODR fit in new plot 
;			Default for both is to use 1/sigma as the weight.
;
;		org_use_zero = set to 1 to use a point at zero in the original plot 
;		new_use_zero = set to 1 to use a point at zero in the new plot
;
;		org_use_ref = set to 1 to use a point at the reference tank in the original plot
;		new_use_ref = set to 1 to use a point at the reference tank in the new plot
;
;		org_npoly = set the order of the original fit 
;		new_npoly = set the order of the new fit 
;			Options: 1 = linear, 2 = quad, 3 = cubic,  etc
;			Defaut is 2 (Quad.)
;
;		org_scale = set the scale to use for the original fit
;		new_scale = set the scale to use for the new fit 
;			ex. new_scale = CO_X2004 
;			Default is current scale for both
;
;		org_moddate = set the modification date for the original fit 
;		new_moddate = set the modification date for the new fit 
;			Default is current for both
;
;		org_peaktype = set the peak type to use for the original fit 
;		new_peaktype = set the peak type to use for the new fit 
;			ex. new_peaktype = 'height'
;			Default is species dependent and is coded in nlpro
;
;		org_no_odr = set to 1 to force nlpro to NOT use a ODR fit for the original fit
;		new_no_odr = set to 1 to force nlpro to NOT use a ODR fit for the new fit
;
;		org_no_x_wt = set to 1 to force nlpro to NOT use weighting on the x axis data in the original fit
;		new_no_x_wt = set to 1 to force nlpro to NOT use weighting on the x axis data in the new fit
;		org_no_y_wt = set to 1 to force nlpro to NOT use weighting on the y axis data in the original fit
;		new_no_y_wt = set to 1 to force nlpro to NOT use weighting on the y axis data in the new fit
;
;		org_extra_option = extra options for the original fit 
;		new_extra_option = extra options for the new fit
;			Use for any extra options that should be passed to nlpro.  Use when
;			new offline version of nlpro is used that has more options.  Pass
;			as string exactly as nlpro expects it.
;
;		plot_3 =  set to plot curves, residuals, and curve difference
;		plot_2 = set to plot curves and rediduals
;		plot_curves = set to plot curves and data points
;		plot_resid = set to plot curve residuals
;		x_molefraction = set to plot residuals vs mole fraction rather than resp_ratio
;		plot_norm_resp = set to plot norm resp (resp / ppb), $
;		plot_curve_diff = set to 1 to plot the curve differences
;		no_new_plot = set to 1 to NOT plot the new fit
;		no_org_plot = set to 1 to NOT plot the original fit
;		norm_resp_ratio = set to 1 to plot the normalized response ratios (resp_ratio per ppb)
;
;		result   Use to capture the new fit results for use in other IDL applications
;
;		diff_plot_yaxis = diff_plot_yaxis, $  ; diff_plot_axis = [-5,5,5,1]
;		notimestamp = notimestamp, $
;		presentation = presentation, $
;		win = win, $
;		save = save, $
;		help   Set to 1 to print help message
;
;
;-
;
;
; Get Utility functions
@ccg_utils.pro
@ccg_graphics.pro




PRO	REPROCESS_NL_CURVES, $
		sp = sp, $
		system = system, $
		inst = inst, $
		rawfile = rawfile, $
		ddir = ddir, $
		org_nlpro = org_nlpro, $
		new_nlpro = new_nlpro, $
		org_refgas = org_refgas, $
		new_refgas = new_refgas, $
		org_nulltanks = org_nulltanks, $
		new_nulltanks = new_nulltanks, $
		org_func = org_func, $
		new_func = new_func, $
		org_use_var = org_use_var, $
		new_use_var = new_use_var, $
		org_use_zero = org_use_zero, $
		new_use_zero = new_use_zero, $
		org_use_ref = org_use_ref, $
		new_use_ref = new_use_ref, $
		org_npoly = org_npoly, $
		new_npoly = new_npoly, $
		org_scale = org_scale, $
		new_scale = new_scale, $
		org_moddate = org_moddate, $
		new_moddate = new_moddate, $
		org_peaktype = org_peaktype, $
		new_peaktype = new_peaktype, $
		org_no_odr = org_no_odr, $
		new_no_odr = new_no_odr, $
		org_no_x_wt = org_no_x_wt, $
		new_no_x_wt = new_no_x_wt, $
		org_no_y_wt = org_no_y_wt, $
		new_no_y_wt = new_no_y_wt, $
		org_extra_option = org_extra_option, $ 
		new_extra_option = new_extra_option, $

		plot_3 = plot_3, $
		plot_2 = plot_2, $
		plot_all = plot_all, $
		plot_curves = plot_curves, $
		plot_resid = plot_resid, $
		plot_norm_resp = plot_norm_resp, $
		plot_curve_diff = plot_curve_diff, $
		print_reassigned = print_reassigned, $
		no_new_plot = no_new_plot, $
		no_org_plot = no_org_plot, $
		x_molefraction = x_molefraction, $  ; set to plot residuals vs mole fraction rather than resp_ratio
		resid_yaxis = resid_yaxis, $   ; yaxis for resid plot
		result, $

        xpixels = xpixels, $
        ypixels = ypixels, $
        curve_xaxis = curve_xaxis, $
        curve_yaxis = curve_yaxis, $
		diff_plot_yaxis = diff_plot_yaxis, $  ; diff_plot_axis = [-5,5,5,1]
		notimestamp = notimestamp, $
		orientation = orientation, $		
		notitle = notitle, $
		noannotation = noannotation, $
		presentation = presentation, $
		win = win, $
		save = save, $
		help = help, $
		dev = dev


; set keywords
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(sp) THEN sp = 'co'
;IF NOT KEYWORD_SET(inst) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(system) THEN system = 'cocal-1'
IF NOT KEYWORD_SET(inst) THEN inst = 'LGR2'
;IF NOT KEYWORD_SET(rawfile) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(rawfile) THEN rawfile = '2010-08-03.1024.co'
IF NOT KEYWORD_SET(win) THEN win = 0
IF KEYWORD_SET(save) AND NOT KEYWORD_SET(dev) THEN dev = 'psc'
IF NOT KEYWORD_SET(dev) THEN dev = ''
IF NOT KEYWORD_SET(org_nlpro) THEN org_nlpro = '/ccg/bin/nlpro.py'
IF NOT KEYWORD_SET(new_nlpro) THEN new_nlpro = '/ccg/bin/nlpro.py'

IF NOT KEYWORD_SET(orientation) THEN orientation = 'default'

IF NOT KEYWORD_SET(plot_curves) AND NOT KEYWORD_SET(plot_resid) AND $
	NOT KEYWORD_SET(plot_norm_resp) AND NOT KEYWORD_SET(plot_curve_diff) AND $
	NOT KEYWORD_SET(plot_2) AND NOT KEYWORD_SET(plot_3) AND $
	NOT KEYWORD_SET(plot_all) THEN plot_2 = 1	

IF KEYWORD_SET(plot_2) THEN BEGIN
	plot_curves = 1
	plot_resid = 1
	plot_norm_resp = 0
	plot_curve_diff = 0
ENDIF	

IF KEYWORD_SET(plot_3) THEN BEGIN
	plot_curves = 1
	plot_resid = 1
	plot_norm_resp = 0
	plot_curve_diff = 1
ENDIF	

IF KEYWORD_SET(plot_all) THEN BEGIN
	plot_curves = 1
	plot_resid = 1
	plot_norm_resp = 1
	plot_curve_diff = 1
ENDIF	

	

;IF npoly EQ 3 THEN new_nlpro = '/home/ccg/crotwell/programing/python/nlpro/cubic/cubic_nlpro.py'

; setup
CCG_GASINFO, sp = sp, gasdata
today = CCG_SYSDATE()
default = -999.999
IF KEYWORD_SET(no_new_plot) THEN col_arr = [11,12,4,13,6,3] ELSE col_arr = [12,11,12,4,13,6,3]
sym_arr = [1,2,3,4,5,6]

syr = FIX(STRMID(rawfile, 0, 4))
smo = FIX(STRMID(rawfile, 5, 2))
sdy = FIX(STRMID(rawfile, 8, 2))
filedate = DateObject( idate = [syr, smo, sdy])

;;;;;;;;;;
; Setup plotting keywords
IF KEYWORD_SET (presentation) THEN BEGIN
        ; plot settings for psc files
                presentation    = 1
                charsize        = 1.5
                xcharsize        = 0.8
                ycharsize        = 0.8
                leg_charsize    = 1.0
                charthick       = 5.5
                thin_charthick  = 2.0
                symsize         = 2.0
                symthick        = 7.0
                linethick       = 9.5
                axis_thick      = 9.5
                gridstyle       = 0
                ticklen         = -0.02
                df_xpixels         = 650
                df_ypixels         = 800

ENDIF ELSE BEGIN
        ; plot settings for screen
                presentation    = 0
                charsize        = 1.3
                xcharsize        = 1.0
                ycharsize        = 1.0
                leg_charsize    = 1.0
                charthick       = 1.0
                thin_charthick  = 1.0
                symsize         = 1.5
                symthick        = 1.5
                linethick       = 1.5
                axis_thick      = 1.0
                gridstyle       = 0
                ticklen         = -0.02
                df_xpixels         = 780
                df_ypixels         = 960

ENDELSE
;;;;;;;;;

; overwrite x and y pixels if provided
IF NOT KEYWORD_SET(xpixels) THEN xpixels = df_xpixels
IF NOT KEYWORD_SET(ypixels) THEN ypixels = df_ypixels

; construct path and filename for original raw file
yr = STRMID(rawfile, 0, 4)
sp = STRUPCASE(sp)
IF STRLOWCASE(system) EQ 'magicc3' THEN system = 'magicc-3'
IF STRLOWCASE(system) EQ 'magicc2' THEN system = 'magicc-2'
IF STRLOWCASE(system) EQ 'magicc1' THEN system = 'magicc-1'
IF STRLOWCASE(system) EQ 'magicc_3' THEN system = 'magicc-3'
IF STRLOWCASE(system) EQ 'magicc_2' THEN system = 'magicc-2'
IF STRLOWCASE(system) EQ 'magicc_1' THEN system = 'magicc-1'
;IF STRLOWCASE(STRMID(inst, 0, 2)) EQ 'ma' THEN inst = STRLOWCASE(inst) ELSE inst = STRUPCASE(inst)
;inst = STRUPCASE(inst)
IF NOT KEYWORD_SET(ddir) THEN ddir = '/ccg/' + STRLOWCASE(sp) + '/nl/' + STRLOWCASE(system) + '/raw/' + yr + '/'
rawfile = ddir + '/' + rawfile
print,"Rawfile:  ", rawfile




; process original raw file with nlpro.pl to get response curve
cmd = org_nlpro 
IF KEYWORD_SET(org_refgas) THEN cmd = cmd + ' --refgasfile=' + org_refgas
IF KEYWORD_SET(org_nulltanks) THEN cmd = cmd + ' --nulltanks=' + org_nulltanks
IF KEYWORD_SET(org_func) THEN cmd = cmd + ' --functype=' + org_func
IF KEYWORD_SET(org_use_var) THEN cmd = cmd + ' --use_variance'
IF KEYWORD_SET(org_use_zero) THEN cmd = cmd + ' --addzero' 
IF KEYWORD_SET(org_use_ref) THEN cmd = cmd + ' --addnormal' 
IF KEYWORD_SET(org_npoly) THEN cmd = cmd + ' --order=' + ToString(org_npoly)
IF KEYWORD_SET(org_scale) THEN cmd = cmd + ' --scale=' + org_scale
IF KEYWORD_SET(org_moddate) THEN cmd = cmd + ' --moddate=' + org_moddate
IF KEYWORD_SET(org_peaktype) THEN cmd = cmd + ' --peaktype=' + org_peaktype
IF KEYWORD_SET(org_no_odr) THEN cmd = cmd + ' --leastsq'
IF KEYWORD_SET(org_extra_option) THEN cmd = cmd + ' ' + org_extra_option
IF KEYWORD_SET(org_no_x_wt) THEN cmd = cmd + ' --use_x_weights=false'
IF KEYWORD_SET(org_no_y_wt) THEN cmd = cmd + ' --use_y_weights=false'
org_cmd = cmd + ' ' 
print,"org cmd:  ", org_cmd

cmd = org_cmd + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str_original_curve
PRINT, str_original_curve

; LGR2 2010 08 04 00 00    -5.431   112.888    -0.216   0.666     7  2010-08-03.1024.co
;LGR2 2018 04 25 07 23          -1.70578155         116.98743462           0.98786528    0.74300    11 power Ref_Divide 2018-04-24.1619.co
s = STRSPLIT(str_original_curve[0], /EXTRACT)
original_curve = [FLOAT(s[6]), FLOAT(s[7]), FLOAT(s[8])]
original_curve_function = s[11]
original_curve_ref_op = s[12]

; reformat string equation
;org_equation = 'coeff0=' + s[6] + '  coeff1=' + s[7] + '  coeff2=' + s[8] + s[9] + s[10]  
org_equation = str_original_curve[0]

; process original raw file with nlpro.pl to get assigned values and corresponding resp ratio 
cmd = org_cmd + ' -i ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
PRINT, str
n = N_ELEMENTS(str)
original_assigned = FINDGEN(2,n) * 0.0
org_resp_ratio_per_ppb = DINDGEN(n) * 0.0
org_resp_ratio = FINDGEN(n) * 0.0
FOR i = 0, n - 1 DO BEGIN
	;print,"org:  ",str[i]
	s = STRSPLIT(str[i], /EXTRACT)
	original_assigned[0,i] = FLOAT(s[2]) ; assigned value
	original_assigned[1,i] = FLOAT(s[0]) ; corresponding resp ratio
	org_resp_ratio[i] = FLOAT(s[0]) 
	IF STRUPCASE(original_curve_ref_op) EQ "REF_DIVIDE" THEN org_resp_ratio_per_ppb[i] = (DOUBLE(s[0]) / DOUBLE(s[2])) * 1000.0D ELSE $
		org_resp_ratio_per_ppb[i] = (DOUBLE(s[0]) / DOUBLE(s[2]))

ENDFOR


; process original with --ratio to get list of mole fractions for curve
j = WHERE(org_resp_ratio GT 0.0)
xmin = MIN(org_resp_ratio) * 0.9
xmax = MAX(org_resp_ratio) * 1.1
;xmax = MAX(org_resp_ratio) * 1.5
cmd = org_cmd + ' --ratios ' + ' --xrange=' + ToString(xmin) + ',' + ToString(xmax) + ' ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
n = N_ELEMENTS(str)
org_line_x = FINDGEN(n) 
org_line_y = org_line_x
org_fit_norm_ratio = DOUBLE(org_line_x) * 0.0

FOR i = 0, n - 1 DO BEGIN
	t = STRSPLIT(str[i], ' ', /EXTRACT)
	org_line_x[i] = FLOAT(t[0])
	org_line_y[i] = FLOAT(t[1])
	IF STRUPCASE(original_curve_ref_op) EQ "REF_DIVIDE" THEN org_fit_norm_ratio[i] = (DOUBLE(t[0]) / DOUBLE(t[1])) * 1000.0D ELSE $
		org_fit_norm_ratio[i] = (DOUBLE(t[0]) / DOUBLE(t[1])) 
ENDFOR

; process original raw file with nlpro.pl to get residuals 
cmd = org_cmd + ' --resid -v ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
PRINT, str
n = N_ELEMENTS(str)
original_residuals = FINDGEN( 2, n) * 0.0
original_reassigned_value = FINDGEN(n) * 0.0
original_value = FINDGEN(n) * 0.0
FOR i = 0, n - 1 DO BEGIN
	s = STRSPLIT(str[i], /EXTRACT)
	original_residuals[ 0, i] = FLOAT(s[0])
	original_residuals[ 1, i] = FLOAT(s[1])
	IF i EQ 0 THEN original_sn = [s[3]] ELSE original_sn = [original_sn, s[3]]
	original_value[i] = FLOAT(s[4])
	original_reassigned_value[i] = (FLOAT(s[4]) - FLOAT(S[1]))
 
ENDFOR


;print_reassigned = print_reassigned, $
IF KEYWORD_SET(print_reassigned) THEN BEGIN
	PRINT, "Re-assigned values from original fit"
	PRINT, "SN   ORG_VALUE   RESIDUAL    REASSIGNED_VALUE"
	FOR i = 0, n - 1 DO BEGIN
		PRINT,original_sn[i],' ',original_value[i], original_residuals[1,i], original_reassigned_value[i]
	ENDFOR
ENDIF



; process new raw file with nlpro.pl to get response curve. Use new refga.tab if requested
cmd = new_nlpro 
IF KEYWORD_SET(new_refgas) THEN cmd = cmd + ' --refgasfile=' + new_refgas
IF KEYWORD_SET(new_nulltanks) THEN cmd = cmd + ' --nulltanks=' + new_nulltanks
IF KEYWORD_SET(new_func) THEN cmd = cmd + ' --functype=' + new_func
IF KEYWORD_SET(new_use_var) THEN cmd = cmd + ' --use_variance'
IF KEYWORD_SET(new_use_zero) THEN cmd = cmd + ' --addzero' 
IF KEYWORD_SET(new_use_ref) THEN cmd = cmd + ' --addnormal' 
IF KEYWORD_SET(new_npoly) THEN cmd = cmd + ' --order=' + ToString(new_npoly)
IF KEYWORD_SET(new_scale) THEN cmd = cmd + ' --scale=' + new_scale
IF KEYWORD_SET(new_moddate) THEN cmd = cmd + ' --moddate=' + new_moddate
IF KEYWORD_SET(new_peaktype) THEN cmd = cmd + ' --peaktype=' + new_peaktype
IF KEYWORD_SET(new_no_odr) THEN cmd = cmd + ' --leastsq'
IF KEYWORD_SET(new_extra_option) THEN cmd = cmd + ' ' + new_extra_option
IF KEYWORD_SET(new_no_x_wt) THEN cmd = cmd + ' --use_x_weights=false'
IF KEYWORD_SET(new_no_y_wt) THEN cmd = cmd + ' --use_y_weights=false'
new_cmd = cmd + ' ' 
print,"new cmd:  ", new_cmd

cmd = new_cmd + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str_new_curve
PRINT, str_new_curve
s = STRSPLIT(str_new_curve[0], /EXTRACT)

; reformat new str equations
;new_equation = 'coeff0=' + s[6] + '  coeff1=' + s[7] + '  coeff2=' + s[8] + s[9] + s[10]  
new_equation = str_new_curve[0]
new_curve_function = s[11]
new_curve_ref_op = s[12]



; process new raw file with nlpro.pl to get assigned values 
cmd =  new_cmd + ' -i ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
PRINT, str
n = N_ELEMENTS(str)
new_assigned = FINDGEN(2, n) * 0.0
new_resp_ratio_per_ppb = DINDGEN(n) * 0.0
new_resp_ratio = FINDGEN(n) * 0.0
FOR i = 0, n - 1 DO BEGIN
	;print,"new:  ",str[i]
	s = STRSPLIT(str[i], /EXTRACT)
	new_assigned[0,i] = FLOAT(s[2])  ; assigned vale
	new_assigned[1,i] = FLOAT(s[0])  ; corresponding resp ratio
	new_resp_ratio[i] = FLOAT(s[0])  
	IF STRUPCASE(new_curve_ref_op) EQ "REF_DIVIDE" THEN new_resp_ratio_per_ppb[i] = (DOUBLE(s[0]) / DOUBLE(s[2])) *1000.0D ELSE $
		new_resp_ratio_per_ppb[i] = (DOUBLE(s[0]) / DOUBLE(s[2]))  
	;new_resp_ratio_per_ppb[i] = (DOUBLE(s[0]) / DOUBLE(s[2])) * 1000.0D 
 
ENDFOR

; process new with --ratio to get list of mole fractions for curve
xmin = MIN(org_resp_ratio) * 0.9
xmax = MAX(org_resp_ratio) * 1.1
cmd = new_cmd + ' --ratios ' + ' --xrange=' + ToString(xmin) + ',' + ToString(xmax) + ' ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
n = N_ELEMENTS(str)
new_line_x = FINDGEN(n) 
new_line_y = new_line_x
new_fit_norm_ratio = DOUBLE(new_line_x)
FOR i = 0, n - 1 DO BEGIN
	t = STRSPLIT(str[i], ' ', /EXTRACT)
	new_line_x[i] = FLOAT(t[0])
	new_line_y[i] = FLOAT(t[1])
	IF STRUPCASE(new_curve_ref_op) EQ "REF_DIVIDE" THEN new_fit_norm_ratio[i] = (DOUBLE(t[0]) / DOUBLE(t[1])) *1000.0D ELSE $
		new_fit_norm_ratio[i] = (DOUBLE(t[0]) / DOUBLE(t[1])) 
ENDFOR


; process new raw file with nlpro.pl to get residuals. Use new refgas.tab if requested
cmd = new_cmd + ' --resid -v ' + rawfile
PRINT, "working on: ", cmd
SPAWN, cmd, str
PRINT, str
n = N_ELEMENTS(str)
new_residuals = FINDGEN( 2, n) * 0.0
new_reassigned_value = FINDGEN(n) * 0.0
new_value = FINDGEN(n) * 0.0

FOR i = 0, n - 1 DO BEGIN
	s = STRSPLIT(str[i], /EXTRACT)
	new_residuals[ 0, i] = FLOAT(s[0])
	new_residuals[ 1, i] = FLOAT(s[1])
	IF i EQ 0 THEN new_sn = [s[3]] ELSE new_sn = [new_sn, s[3]]
	new_value[i] = FLOAT(s[4])
	new_reassigned_value[i] = (FLOAT(s[4]) - FLOAT(S[1]))
 
ENDFOR

;print_reassigned = print_reassigned, $
IF KEYWORD_SET(print_reassigned) THEN BEGIN
	PRINT, "Re-assigned values from new fit"
	PRINT, "SN   ORG_VALUE   RESIDUAL    REASSIGNED_VALUE"
	FOR i = 0, n - 1 DO BEGIN
		PRINT,new_sn[i],' ',new_value[i], new_residuals[1,i], new_reassigned_value[i]
	ENDFOR
ENDIF





	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;   Plots
	;initialize data attribute array and
	   ; the plot attribute array

	   plot_attr_arr = 0
	   np = 0



		; set plot positions
	;plot_curves = 1
	;plot_resid = 1
	;plot_norm_resp = 1
	;plot_curve_diff = 0
	
	num_plots = 0
	IF KEYWORD_SET(plot_curves) THEN num_plots = num_plots + 1
	IF KEYWORD_SET(plot_resid) THEN num_plots = num_plots + 1
	IF KEYWORD_SET(plot_norm_resp) THEN num_plots = num_plots + 1
	IF KEYWORD_SET(plot_curve_diff) THEN num_plots = num_plots + 1

	IF KEYWORD_SET(plot_curves) THEN BEGIN
	

		; Top plot:  Original and New response curves
		   ;initialize the data attribute array
		   data_attr_arr = 0
		   nd = 0



		;x_steps = ( (MAX(original_residuals[0,*]) * 1.1 ) - (MIN(original_residuals[0,*])*0.9 ) ) / 100.0
		;x_lines = (FINDGEN(100) * x_steps) + (MIN(original_residuals[0,*]) * 0.91) 
	;org_line_x[i] = FLOAT(t[0])
	;org_line_y[i] = FLOAT(t[1])

		IF NOT KEYWORD_SET(no_org_plot) THEN BEGIN
			; data set 1, Original response curve LINE
			;y = original_curve[0] + original_curve[1] * x_lines + original_curve[2] * x_lines^2
			label = 'Orig:  ' + org_equation
			d = DATA_ATTRIBUTES(org_line_x, org_line_y, $
				LINESTYLE = 0, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMCOLOR = col_arr[0], $
				LINECOLOR = col_arr[0], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			; data set 2, Original response curve DATA POINTS 
			x = original_assigned[1,*]
			y = original_assigned[0,*]
			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = -1, $
				SYMSTYLE = sym_arr[0], $
				SYMCOLOR = col_arr[0], $
				SYMSIZE = symsize, $
				;SYMFILL = 1, $
				SYMFILL = (KEYWORD_SET(no_new_plot)) ? 1 : 0, $
				SYMTHICK = symthick)
;IF KEYWORD_SET(no_new_plot) THEN col_arr = [11,12,4,13,6,3] ELSE col_arr = [12,11,12,4,13,6,3]

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)
		ENDIF

		;no_new_plot = no_new_plot, $
		IF NOT KEYWORD_SET(no_new_plot) THEN BEGIN

			label = 'New:  ' + new_equation 

			d = DATA_ATTRIBUTES(new_line_x, new_line_y, $
				LINESTYLE = 0, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMCOLOR = col_arr[1], $
				LINECOLOR = col_arr[1], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			; data set 4, New response curve DATA POINTS 
			x = new_assigned[1,*]
			y = new_assigned[0,*]
			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = -1, $
				SYMSTYLE = sym_arr[1], $
				SYMCOLOR = col_arr[1], $
				SYMFILL = 1, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			atext1 = 'Org Curve: ' + org_cmd 
			atext2 = 'New Curve: ' + new_cmd 
			a1 = ANNOTATION_ATTRIBUTES(text = atext1, position = 'BL', charsize = 1.0, color = 3)
			a2 = ANNOTATION_ATTRIBUTES(text = atext2, position = 'BL', charsize = 1.0, color = 3)
			annotation = {a1:a1, a2:a2}

		ENDIF

            ; temp position statement
            position1 = [0.20, 0.70, 0.95, 0.95]
			title = STRUPCASE(sp) + ' Response Curves ( ' + inst +': ' + rawfile + ' )'
		       p = PLOT_ATTRIBUTES(data = data_attr_arr, $
				POSITION = position1, $
				TITLE = KEYWORD_SET(notitle) ? ' ' : title, $
				;ANNOTATION = annotation, $
				ANNOTATION = KEYWORD_SET(noannotation) ? ' ' : annotation, $
				CHARSIZE = charsize, $
				CHARTHICK = charthick, $
                XAXIS = KEYWORD_SET(curve_xaxis) ? curve_xaxis: '', $
                YAXIS = KEYWORD_SET(curve_yaxis) ? curve_yaxis: '', $
			;       XAXIS = [-1,-1,4,1], $
		        ;        YAXIS = [0, 250, 5, 1], $
				PLOTTHICK = axis_thick,$
				XCHARSIZE = (num_plots EQ 1) ? xcharsize : 0.001, $
				YCHARSIZE = ycharsize, $
				;YCHARTHICK = charthick, $
				YTITLE = gasdata.title, $
				XTITLE = (num_plots EQ 1) ? 'Response Ratio' : '', $
				XCUSTOM= xcustom, $
				LEGEND = (KEYWORD_SET(noannotation)) ? '' : "TL")
				;LEGEND =  "TL")

			z = 'p' + ToString(np++)
			plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)

	ENDIF



	;plot_curves = 1
	;plot_resid = 1
	;plot_norm_resp = 1
	;plot_curve_diff = 0
	IF KEYWORD_SET(plot_resid) THEN BEGIN
		; Bottom plot:  Original and New residuals
		   ;initialize the data attribute array
		   data_attr_arr = 0
		   nd = 0

		IF NOT KEYWORD_SET(no_org_plot) THEN BEGIN
			; data set 1, Original residuals
			x = KEYWORD_SET(x_molefraction) ? original_value : original_residuals[0,*]
			;d = DATA_ATTRIBUTES(original_residuals[0,*], original_residuals[1,*], $
			;d = DATA_ATTRIBUTES(original_value, original_residuals[1,*], $
			d = DATA_ATTRIBUTES(x, original_residuals[1,*], $
				LINESTYLE = -1, $
				;LABEL = 'Original ' , $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : 'Original', $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMSTYLE = sym_arr[0], $
				SYMCOLOR = col_arr[0], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				;SYMFILL = (KEYWORD_SET(no_new_plot)) ? 1 : 0, $
				SYMFILL = 1, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)
		ENDIF

		;no_new_plot = no_new_plot, $
		IF NOT KEYWORD_SET(no_new_plot) THEN BEGIN
			; data set 2, New residuals
			x = KEYWORD_SET(x_molefraction) ? new_value : new_residuals[0,*]
 	
			;d = DATA_ATTRIBUTES(new_residuals[0,*], new_residuals[1,*], $
			;d = DATA_ATTRIBUTES(new_value, new_residuals[1,*], $
			d = DATA_ATTRIBUTES(x, new_residuals[1,*], $
				LINESTYLE = -1, $
				;LABEL = 'New ' , $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : 'New', $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMSTYLE = sym_arr[1], $
				SYMCOLOR = col_arr[1], $
				LINETHICK = linethick, $
				SYMFILL = 1, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

		ENDIF

		; make dummy data set for line at 0
                dx = [ -9999, 9999 ]
                dy = [0.0, 0.0]
                d = DATA_ATTRIBUTES( dx, dy, $
				/noscale, $
                                LINESTYLE = 0, $
                                LINETHICK = linethick, $
                                LINECOLOR = 1)

                z = 'd' + ToString(nd++)
                data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			IF NOT KEYWORD_SET(PLOT_CURVES) AND NOT KEYWORD_SET(PLOT_CURVE_DIFF) THEN position = [0.2,0.2,0.9,0.9] ELSE $
				position = ""

		       xtitle = KEYWORD_SET(x_molefraction) ? gasdata.title : 'Resp Ratio'
		       p = PLOT_ATTRIBUTES(data = data_attr_arr, $
				POSITION = position, $
				;*****TITLE = 'Residuals', $
			;       XAXIS = [-1,-1,4,1], $
		                ;YAXIS = [-0.10,0.10,4,5], $ ; for pc1 primary 626
		                ;YAXIS = [-0.010,0.010,4,5], $ ; for pc1 primary 626
				YAXIS = (KEYWORD_SET(resid_yaxis)) ? resid_yaxis : '', $
				CHARSIZE = charsize, $
				XCHARSIZE = xcharsize, $
				YCHARSIZE = ycharsize, $
				CHARTHICK = charthick, $
				XTITLE = xtitle, $
				PLOTTHICK = axis_thick,$
				;XTITLE = 'Response Ratio', $
				;YTITLE = '!4D!3' + gasdata.title, $
				YTITLE = '!4D!X ' + gasdata.title, $
				XCUSTOM= xcustom, $
				/nogrid, $
				SLEGEND = (KEYWORD_SET(noannotation)) ? '' : "TL")
				;SLEGEND = "TL")

			z = 'p' + ToString(np++)
			plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)

	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Plot RespRatio per ppb if asked for.  Else plot new vs old response curves
	;plot_curves = 1
	;plot_resid = 1
	;plot_norm_resp = 1
	;plot_curve_diff = 0
	IF KEYWORD_SET(plot_norm_resp) THEN BEGIN
 
		   ;initialize the data attribute array
		   data_attr_arr = 0
		   nd = 0

		   ; set paper to landscape if orientation not set
		   CASE STRUPCASE(orientation) OF
			'PORTRAIT': portrait = 1
			'LANDSCAPE': portrait = 0
		   ELSE: portrait = 0
		   ENDCASE



		IF NOT KEYWORD_SET(no_org_plot) THEN BEGIN
			; data set 1, Original resp_ratio/ppb vs assigned
			x = original_assigned[0,*]
			y = org_resp_ratio_per_ppb 
			label = 'Data'
			;FOR iiii =0, N_ELEMENTS(x) - 1 DO PRINT,label,x[iiii],y[iiii]


			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = -1, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMSTYLE = sym_arr[0], $
				SYMCOLOR = col_arr[0], $
				SYMFILL = 1, $
				LINECOLOR = col_arr[0], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			x = org_line_y
			y = org_fit_norm_ratio


			label = 'Orig:  ' + org_equation
	;new_fit_norm_ratio = FLOAT(t[0]) / FLOAT(t[1])
		;notitle = notitle, $
		;noannotation = noannotation, $
			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = 0, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				;SYMSTYLE = sym_arr[0], $
				;SYMCOLOR = col_arr[0], $
				;SYMFILL = 1, $
				LINECOLOR = col_arr[0], $
				LINETHICK = linethick ) ;, $
				;SYMSIZE = symsize, $
				;SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)


		ENDIF


		;no_new_plot = no_new_plot, $
		IF NOT KEYWORD_SET(no_new_plot) THEN BEGIN
			; data set 2, New resp_ratio/ppb vs assigned
			x = new_assigned[0,*]
			y = new_resp_ratio_per_ppb
			label = 'Data'
			;FOR iiii =0, N_ELEMENTS(x) - 1 DO PRINT,label,x[iiii],y[iiii]

			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = -1, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMSTYLE = sym_arr[1], $
				SYMCOLOR = col_arr[1], $
				SYMFILL = 1, $
				LINECOLOR = col_arr[1], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			x = new_line_y
			y = new_fit_norm_ratio 
			label = 'New:  ' + new_equation 
	;new_fit_norm_ratio = FLOAT(t[0]) / FLOAT(t[1])
			d = DATA_ATTRIBUTES(x, y, $
				LINESTYLE = 0, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				;SYMSTYLE = sym_arr[1], $
				;SYMCOLOR = col_arr[1], $
				;SYMFILL = 1, $
				LINECOLOR = col_arr[1], $
				LINETHICK = 1+ linethick ) ;, $
				;SYMSIZE = symsize, $
				;SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)


		ENDIF

			atext1 = 'Org Curve: ' + org_cmd 
			atext2 = 'New Curve: ' + new_cmd 
			a1 = ANNOTATION_ATTRIBUTES(text = atext1, position = 'BL', charsize = 1.0, color = 3)
			a2 = ANNOTATION_ATTRIBUTES(text = atext2, position = 'BL', charsize = 1.0, color = 3)
			annotation = {a1:a1, a2:a2}


			title = STRUPCASE(sp) + ' Normalized Response Ratio ( ' + inst +': ' + rawfile + ' )'
	       p = PLOT_ATTRIBUTES(data = data_attr_arr, $
			;POSITION = [0.20, 0.20, 0.90, 0.90], $
			TITLE = KEYWORD_SET(notitle) ? ' ' : title, $
			ANNOTATION = KEYWORD_SET(noannotation) ? ' ' : annotation, $
			CHARSIZE = charsize, $
			CHARTHICK = charthick, $
		;       XAXIS = [-1,-1,4,1], $
	;               YAXIS = [1850,2175,6,1], $
			PLOTTHICK = axis_thick,$
			XCHARSIZE = xcharsize, $
		       ; XCHARTHICK = charthick, $
			YCHARSIZE = ycharsize, $
			;YCHARTHICK = charthick, $
			XTITLE = gasdata.title, $
			YTITLE = "Resp. per " + gasdata.units , $
			XCUSTOM= xcustom, $
			LEGEND = (KEYWORD_SET(noannotation)) ? '' : "TL")
			;LEGEND =  "TL")

		z = 'p' + ToString(np++)
		plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)


	ENDIF  ; end plotting of normalized resp ratios

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Start plotting of curve differences if asked for
	;plot_curves = 1
	;plot_resid = 1
	;plot_norm_resp = 1
	;plot_curve_diff = 0
	IF KEYWORD_SET(plot_curve_diff) THEN BEGIN

		   ;initialize the data attribute array
		   data_attr_arr = 0
		   nd = 0



			; data set  New response curve - Original response curve 
			diff_y = new_line_y - org_line_y
			label = 'New Curve - Original Curve'
;new_residuals[0,*]

			;j = WHERE(org_line_x GE MIN([new_residuals[0,*],original_residuals[0,*]]) AND org_line_x LE MAX([new_residuals[0,*],original_residuals[0,*]]))
			;j = WHERE(org_line_x GE MIN(new_residuals[0,*]) AND org_line_x LE MAX([new_residuals[0,*]))
			j = WHERE(org_line_x GE MIN(original_residuals[0,*]) AND org_line_x LE MAX(original_residuals[0,*]))

			;d = DATA_ATTRIBUTES(org_line_x, diff_y, $
			d = DATA_ATTRIBUTES(org_line_x[j], diff_y[j], $
				LINESTYLE = 0, $
				;LABEL = label, $
				LABEL = KEYWORD_SET(noannotation) ? ' ' : label, $
				CHARTHICK = charthick, $
				CHARSIZE = leg_charsize, $
				SYMCOLOR = col_arr[0], $
				LINECOLOR = col_arr[0], $
				LINETHICK = linethick, $
				SYMSIZE = symsize, $
				SYMTHICK = symthick)

			z = 'd' + ToString(nd++)
			data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)

			title = 'Curve Difference'
		       p = PLOT_ATTRIBUTES(data = data_attr_arr, $
				;POSITION = position3, $
				TITLE = KEYWORD_SET(notitle) ? ' ' : title, $
			;       XAXIS = [-1,-1,4,1], $
		                YAXIS = (KEYWORD_SET(diff_plot_yaxis)) ? diff_plot_yaxis : '', $
				PLOTTHICK = axis_thick,$
				CHARSIZE = charsize, $
				XCHARSIZE = xcharsize, $
				YCHARSIZE = ycharsize, $
				CHARTHICK = charthick, $
				XTITLE = xtitle, $
				YTITLE = gasdata.title, $
				LLEGEND = (KEYWORD_SET(noannotation)) ? '' : "TL", $
				;LLEGEND = "TL", $
				XCUSTOM= xcustom)

			z = 'p' + ToString(np++)
			plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)





		ENDIF  ; end plotting of curve differences 







	; submit to Graphics routine
	   CASE STRUPCASE(orientation) OF
		'PORTRAIT': portrait = 1
		'LANDSCAPE': portrait = 0
	   ELSE: portrait = 1
	   ENDCASE


print,'portrait = ', portrait
	   CCG_GRAPHICS, graphics = plot_attr_arr, dev = dev, $
                /allxrange, $
		portrait = portrait, window = win, $
		col = 1, row = num_plots, $
		xpixels = xpixels, ypixels = ypixels, notimestamp = notimestamp




PRINT,' '
PRINT,'Original:  ' + org_equation
PRINT,'New:       ' + new_equation

; result is returned to caller
result = str_new_curve[0]

END
