;+
;help
; NAME:  
;	CCG_MAGICC_TANK_ICP
;
; PURPOSE:
;	Allow comparison of tank calibrations on CCGG instruments.  Compares 
;	the results for two or more instruments for a single species for a 
;	single cylinder.  Primarily used to compare performance of the 
;	Magicc_1 and Magicc_2 analysis systems using target tanks. 
;	
;
; CATEGORY:
;
; CALLING SEQUENCE:
; 	CCG_MAGICC_TANK_ICP, id= 'cc71583', sp='co2', inst= 'l3,s2,l8', $
;			 date = [20040101,20061231], /mixing_ratio
;
; 	CCG_MAGICC_TANK_ICP, id= 'CC71583', sp= 'co2', inst= 'l3,L8', $
;			date = [20060101,20061231], /norm_target, /std_changes
;
; 	CCG_MAGICC_TANK_ICP, sp = 'co2', id='CC71583', inst='l3,l8', $
;			date=[2006,2007], /mixing_ratio, $
;			/norm_target, std_changes = 2
;
; 	CCG_MAGICC_TANK_ICP, sp = 'co2', id='CC71583', inst='l3,l8', $
;			date=[2007], /mixing_ratio, /norm_target
;
; INPUTS:
;       id:           Cylinder id number.  May only specify a single tank per call.
;                       (ex) id='CC71583'
;                      
;       sp:             Gas formula.  May only specify a single sp per call.
;                       (ex) sp='co2'
;
;	inst:		Instrument codes.  May specifiy 1 to 6 instrument codes per call. 
;			(ex) inst = 'h4,h6'
;			(ex) inst = 'l3,s2,l8'
;                       
;	
;
; OPTIONAL INPUT PARAMETERS:
;	date 		Date Range.  May specify date range.  If no date range passed, 
;			procedure returns previous year ending on today's date.  If only 
;			one date passed, procedure uses it as end date and returns 
;			previous year from that date.  If only year entered, procedure 
;			starts on 0101 and ends on 1231.  If only year month entered, 
;			procedure starts on 1st of month and ends on last day of month.
;			(ex) date = [20050101,20061231]
;			(ex) date = [2006]   Same date range as [20051231 - 20061231]
;			(ex) date = [20060601]   Same date range as [20050601 - 20060630]
;			(ex) date = [200601,200606]  Same date range as [20060101,20060630]
;
;	mixing_ratio	If keyword set, request a landscape plot of mixing ratios time series.
;
;
;	norm_target	If keyword set, request a plot of results from each instrument 
;			normalized to the assigned values of the target gas cylinders.  This 
;			is a two panel plot with the mixing ratios in the top panel and the 
;			normalized data in the bottom panel.  Assigned values are stored in
;			lookup table /ccg/'sp'/cals/magicc_target.tab
;			(ex) id = 'CC71583', /norm_tst
;
;	std_changes	If set to 1, plots vertical bars for each standard change on each instrument.  
;			The standard changes are indicated only on the normalized target tank plot 
;			(/norm_target).
;			If set to 2, plots vertical bars for each standard change and writes standard
;			cylinder ID's on the normalized target tank plot.
;
;	nofix		If keyword set, let the yaxis autoscale in the norm_inst1 and norm_tst plots.  
;			Otherwise axis scale is fixed and data that is outside the plot range 
;			is plotted on the plot boarders.
;
;	save		If keyword set, save plots, text files of data, and text files of summary 
;			statistics.
;
;	dev		Sets the file type for the saved plots.  
;
;	presentation	If keyword set, make plots in presentation quality.  Gives thick lines 
;			and text that show up well in psc, png, and pdf files.
;
;	ddir		Directory where plots and files are saved.  Default is users home 
;			directory.
;			(ex) ddir = '/home/user/directory/'		
;
;	win		IDL window number for plot. Default win = 0 
;			(ex) win = 2	
;
;	nolabid		If keyword set, do not print lab id on bottom of plots
;
;	noproid		If keyword set, do not print procedure id on bottom of plots
;
;	help		If keyword set, print help file
;
;
;
; OUTPUTS:
;	Saved data filenames:
;			(id)_(inst)_(sp).txt    	Data from one instrument.
;			(ex) cc71583_H4_ch4.txt
;
;			(id)_summary_(sp).txt   	Summary statistics.
;			(ex) cc71583_summary_ch4.txt
;	
;	Plot filenames:
;			(id)_(sp).(dev) 		Time series of mixing ratios.
;			(ex) cc71583_ch4.ps			
;
;			(id)_norm_(sp).(dev)		Time series of normalized target
;			(ex) cc71583_norm_ch4.ps	tank results.
;			
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;               Example:
;
;               CCG_MAGICC_TANK_ICP,$
;	                id='cc71583',$
;       	        sp='co2',$
;               	inst='L3,L8'
;          	     	date=[20060101,20070401],$
;               	/mixing_ratio,/norm_target
;
;
; MODIFICATION HISTORY:
;       Written, AMC and KAM, July 2007.
;
;
;
;-






; Get Utility functions
@ccg_utils.pro
@ccg_magicc_icp_utils.pro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE TO WRITE INSTRUMENT SPECIFIC DATA TO FILES FOR ARCHIVING
;	SAVE_TANK_WRKDATA_FILES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	SAVE_TANK_WRKDATA_FILES, $
		wrkdata	= wrkdata, $
		ddir 	= ddir, $
		id 	= id, $
		ninst 	= ninst, $
		sp 	= sp

; Write tank calibration results to a text file for archiving.  One
; file for each instrument.
;     Ex. idfilename(0) is the filename for inst(0).  
; Filenames are ddir/"id"_"gas"_"inst".txt   Ex.  cc71583_ch4_h4.txt


inst_id = TAG_NAMES(wrkdata)
idfilename=STRARR(ninst)

;loop through each instrument's results
FOR i=0,ninst-1 DO BEGIN

	nvalues=N_ELEMENTS(wrkdata.(i).value)

	; create file and write 1 line header info.  
	;			
	idfilename[i]=ddir + STRLOWCASE(id) + '_' + inst_id[i] + $
			 '_' +STRLOWCASE(sp) + '.txt'

	format = '(A15,A12,A10,A5,A12,A12,A5,A12)'
	header = ["ID","FILL_DATE","GAS","INST","ADATE","VALUE","FLAG","ASSIGNED"]

	OPENW, fp1, idfilename[i], /GET_LUN
	PRINTF, fp1, FORMAT = format, header

	FOR j=0,nvalues-1 DO BEGIN
		; write values and assigned_values to file "id"_"gas"_"inst".txt
		PRINTF, fp1, FORMAT = '(A15,F12.4,A10,A5,F12.3,G12.8,A5,F12.4)', $

		wrkdata.(i)[j].id, 0.0, $ ; wrkdata.(i)[j].dd,  $
		wrkdata.(i)[j].parameter, wrkdata.(i)[j].inst,  wrkdata.(i)[j].dd, $
		wrkdata.(i)[j].value,  wrkdata.(i)[j].flag, wrkdata.(i)[j].tg
	ENDFOR
	FREE_LUN, fp1

	PRINT,'data saved as ', idfilename[i] 

ENDFOR

END
; End SAVE_WRKDATA_FILES  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE TO PLOT MIXING RATIOS
;	PLOT_MIXING_RATIO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	PLOT_TANK_MIXING_RATIOS, $
	id = id, $
	date = date, $
	sp = sp, $
	inst = inst, $
	dev = dev, $
	wrkdata	= wrkdata, $
	ninst = ninst, $
	cyln_values	= cyln_values, $
	sym_arr	= sym_arr, $
	col_arr	= col_arr, $
	default	= default, $
	win = win, $
	save = save, $
	ddir = ddir, $
	nolabid	= nolabid, $
        noproid	= noproid, $
	gasdata	= gasdata, $

        presentation = presentation, $ 
	fp = fp, $ 
	legend = legend, $
	xmin = xmin, $
	xmax = xmax, $
	nofix = nofix, $
	half_plot = half_plot, $
	pen = pen, $
        charsize = charsize, $
        leg_charsize = leg_charsize, $
        charthick = charthick, $
        thin_charthick = thin_charthick, $
        symsize = symsize, $
        symthick = symthick, $
        linethick = linethick, $
        axis_thick = axis_thick, $
        gridstyle = gridstyle, $
        ticklen = ticklen, $
        xpixels = xpixels, $
        ypixels = ypixels


;set filename for saving plot (ex.  cc71583_ch4.ps)
file_extension = (dev EQ 'psc') ? 'ps' : dev
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(id) + $
			 '_' +STRLOWCASE(sp) + '.' + file_extension 
;			

; keyword half_plot sets the plotting routine to work with other plotting routines to produce
;	multi panel plots
IF NOT KEYWORD_SET(half_plot) THEN CCG_OPENDEV,dev = dev,win = win,pen = pen, $
					xpixels = 800, ypixels = 600, saveas = saveas


inst_id = TAG_NAMES(wrkdata)

; find the min and max values of all wrkdata structures to set y scale
;  and produce time array for the x axis
;  this keeps the plot from scaling off of other instruments that would be included 
;  	in the data structure but would not be in the wrkdata structures since they were
;	not specified in the call
FOR i=0, ninst-1 DO BEGIN
	tmp = wrkdata.(i).value
	data = (i EQ 0) ? [tmp] : [data, tmp]
	tmp_time = wrkdata.(i).dd 
	time = (i EQ 0) ? [tmp_time] : [time, tmp_time]
ENDFOR

; expand the y axis from the min and max for each gas to keep plots looking good and keep
;	legend readable.  Legend in top left corner of plot so expand ymax more than ymin
CASE STRUPCASE(sp) OF
        'N2O': BEGIN
                expand_ymin = 0.998
                expand_ymax = 1.002
		units = 'ppb'
               END

        'SF6': BEGIN
                expand_ymin = 0.980
                expand_ymax = 1.020
		units = 'ppt'
               END

        'CO': BEGIN
                expand_ymin = 0.95
                expand_ymax = 1.05
		units = 'ppb'
               END

        'H2': BEGIN
                expand_ymin = 0.95
                expand_ymax = 1.05
		units = 'ppb'
               END

        'CH4': BEGIN
                expand_ymin = 0.995 
                expand_ymax = 1.005
		units = 'ppb'
               END

        'CO2': BEGIN
                expand_ymin = 0.9995
                expand_ymax = 1.0005
		units = 'ppm'
               END
ENDCASE

ymin = MIN(data) * expand_ymin
ymax = MAX(data) * expand_ymax


; set up plot
IF KEYWORD_SET(half_plot) THEN BEGIN
;  Plot setup for half page
	t1 = STRUPCASE(id) + ':  ' + gasdata.formula
	t_unit = 'Analysis Date' 
	PLOT, time, data, /NODATA, COLOR=pen(1), $
		POSITION = [0.20, 0.55, 0.94, 0.95], $
	        TITLE = t1, $
	        CHARSIZE = charsize, $
	        CHARTHICK = charthick, $
	
	        YSTYLE = 1, $
	        YGRIDSTYLE = gridstyle, $
	        YTICKLEN = ticklen, $
	        YTHICK = axis_thick, $
	        YRANGE = [ymin, ymax], $
	        YCHARSIZE = charsize, $
	
	        XSTYLE = 1, $
	        XGRIDSTYLE = gridstyle, $
	        XTICKLEN = ticklen, $
	        XTHICK = axis_thick, $
	        XRANGE = [xmin, xmax], $
	        XCHARSIZE = 0.01

	; xyout y axis title
	; set location for xyouts on half page plot
		x_out = 0.07
		y_out = 0.65

	XYOUTS, x_out, y_out, gasdata.title, COLOR = pen(1), /NORMAL, $
		CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 90	

	
ENDIF ELSE BEGIN
;  Plot setup for full screen
	t1 = id + ', ' + gasdata.title
	t_unit = 'Analysis Date'
	PLOT, time, data, /NODATA, COLOR = pen(1),$
		TITLE = t1, $
		CHARSIZE = charsize, $
		CHARTHICK = charthick, $
	
		YTITLE = gasdata.units, $
		YSTYLE = 1, $
		YGRIDSTYLE = gridstyle, $
		YTICKLEN = ticklen, $
		YTHICK = axis_thick, $
	        YRANGE = [ymin, ymax], $
		
		XTITLE = t_unit, $
		XSTYLE = 1, $
		XGRIDSTYLE = gridstyle, $
		XTICKLEN = ticklen, $
		XTHICK = axis_thick, $
	        XRANGE = [xmin, xmax] 

ENDELSE

; loop through results form each inst and plot
FOR i=0, ninst-1 DO BEGIN

	k = WHERE(wrkdata.(i).value - 1 GT default ) ; index of valid data
	IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
	IF k[0] EQ -1 THEN CONTINUE	

	time = wrkdata.(i)[k].dd 
	yvalue = wrkdata.(i)[k].value
	yunc = wrkdata.(i)[k].sd

	CCG_SYMBOL, sym = sym_arr[i], fill = 1, thick = symthick
	OPLOT, time, yvalue, PSYM = 8, COLOR = pen(col_arr[i]),$
		SYMSIZE = symsize

	; Add error bars	
	pos_err = yvalue + yunc
        neg_err = yvalue - yunc
        CCG_ERRPLOT, time, neg_err, pos_err, thick = linethick, COLOR = pen(col_arr[i])

ENDFOR


IF KEYWORD_SET(legend) THEN BEGIN ; only create legend if specified

	; create legend
	inst_id = TAG_NAMES(wrkdata)
	tarr = STRARR(ninst)
	sarr = FINDGEN(ninst)
	carr = FINDGEN(ninst)
	farr = FINDGEN(ninst)
	FOR i=0,ninst -1 DO BEGIN
		tarr[i] = inst_id[i]	
		sarr[i] = sym_arr[i]
		carr[i] = col_arr[i]

	ENDFOR

	IF NOT KEYWORD_SET(half_plot) THEN BEGIN  ; position legend for landscape plot on screen

		x_leg = 0.13
                y_leg = 0.91
                x_out = 0.125
                y_out = 0.150

	ENDIF ELSE BEGIN  ; position legend for top panel of two panel plot

		x_leg = 0.23
                y_leg = 0.93
                x_out = 0.225
                y_out = 0.570
	ENDELSE

	CCG_SLEGEND, x = x_leg, y = y_leg, tarr = tarr, sarr = sarr, $
		carr = carr, CHARSIZE = leg_charsize, CHARTHICK = charthick, THICK = SYMTHICK

ENDIF


;  plot cyln_values values as line
	plot_range = !X.CRANGE
	ndiv = 2000
	div = (plot_range(1) - plot_range(0)) / ndiv
	x = FINDGEN(ndiv) * div + plot_range(0)
	lasty = 0

	FOR i=0,ndiv-1 DO BEGIN
		y = CYLINDER_VALUES_BY_DATE(x[i],cyln_values,default)

		IF y GT default THEN BEGIN
			continue_ = (i EQ 0 OR lasty-1 LT default) ? 0 : 1
			PLOTS, x[i], y, COLOR = pen[1], THICK = linethick, continue = continue_
		ENDIF

		lasty = y
	ENDFOR

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID


IF NOT KEYWORD_SET(half_plot) THEN CCG_CLOSEDEV, dev=dev, saveas = saveas

; update win so get all plots asked for on screen
win = win + 1

END
;  End PLOT_TANK_MIXING_RATIOS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE TO PLOT NORMALIZED RESULTS FOR TARGET TANKS
; 	PLOT_NORM_TARGET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	PLOT_NORM_TARGET, $
	dev = dev, $
	wrkdata = wrkdata, $
	id = id, $
	date = date, $
	sp = sp, $
	inst = inst, $
	ninst = ninst, $
	cyln_values = cyln_values, $
	sym_arr = sym_arr, $
	col_arr = col_arr, $
	default = default,$
	win = win, $
	save = save, $
	ddir = ddir, $
	today = today, $
	nolabid = nolabid, $
        noproid = noproid, $
	gasdata = gasdata, $
	target_flag = target_flag, $
	std_changes 	= std_changes, $
	std_ddate = std_ddate, $
	std_id = std_id, $
	std_inst = std_inst, $

        presentation= presentation, $ 
	fp = fp, $ 
	legend = legend, $
	xmin = xmin, $
	xmax = xmax, $
	nofix = nofix, $
        charsize = charsize, $
        leg_charsize = leg_charsize, $
        charthick = charthick, $
        thin_charthick = thin_charthick, $
        symsize = symsize, $
        symthick = symthick, $
        linethick = linethick, $
        axis_thick = axis_thick, $
        gridstyle = gridstyle, $
        ticklen = ticklen, $
        xpixels = xpixels, $
        ypixels = ypixels


;set filename for saving plot (ex. tst_normtst_ch4.ps )
file_extension = (dev EQ 'psc') ? 'ps' : dev
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(id) + '_norm_' + $
		STRLOWCASE(sp) + '.' + file_extension 
			


CCG_OPENDEV, dev=dev, pen=pen, win = win , portrait = 1, saveas = saveas

!P.MULTI = [0,1,2]  ; creating multi panel plot

; get valid inst id's for plot labels
inst_id = TAG_NAMES(wrkdata)


;
; Call procedure plot_mixing_ratios to create top panel of plot
; 
PLOT_TANK_MIXING_RATIOS, $
        id = id, $
        date = date, $
        sp = sp, $
        inst = inst, $
        dev = dev, $
        wrkdata = wrkdata, $
        ninst = ninst, $
        cyln_values = cyln_values, $
        sym_arr = sym_arr, $
        col_arr = col_arr, $
        default = default, $
	win = win, $
        nolabid = nolabid, $
        noproid = noproid, $
        gasdata = gasdata, $

        presentation = presentation, $
	legend = 1, $
	xmin = xmin, $
	xmax = xmax, $
	pen = pen, $
        nofix = nofix, $
        half_plot = 1, $  ;  Sets plot up for top panel of two panel plot
        charsize = charsize, $
        leg_charsize = leg_charsize, $
        charthick = charthick, $
        thin_charthick = thin_charthick, $
        symsize = symsize, $
        symthick = symthick, $
        linethick = linethick, $
        axis_thick = axis_thick, $
        gridstyle = gridstyle, $
        ticklen = ticklen, $
        xpixels = xpixels, $
        ypixels = ypixels




;
;;;;  start plotting of normalized data in botttom panel 
;	if target_tank flag = 0 (ie no entry for the cylinder
;	in the target tank lookup table) do not make bottom plot
;

IF target_flag EQ 1 THEN BEGIN
	; find the max difference to set y scale for auto scaling (/nofix)
	FOR i=0, ninst-1 DO BEGIN
		k = WHERE(wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) 

		IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
		IF k[0] NE -1 THEN BEGIN
			tmp = wrkdata.(i)[k].value - wrkdata.(i)[k].tg
			tmp_time = wrkdata.(i)[k].dd 
		ENDIF ELSE BEGIN
			tmp = default
			tmp_time = default	
		ENDELSE

		diff = (i EQ 0) ? [tmp] : [diff, tmp]
		time = (i EQ 0) ? [tmp_time] : [time, tmp_time]

	ENDFOR

	k = WHERE(diff - 1.0 GT default)
	IF (N_ELEMENTS(k) EQ 1) THEN k = [k,k]
	max_diff = (k[0] EQ -1) ? ABS(default) : MAX( ABS( diff[k]) )
	diff = (k[0] EQ -1) ? [default, ABS(default)] : diff[k]
	time = (k[0] EQ -1) ? [default, ABS(default)] : time[k]
	

	; Set y scale range based on fixed range for each gas
	;  	also set units for summary tables
	CASE STRUPCASE(sp) OF
		'N2O': BEGIN
			fix_ymin = -2.0
			fix_ymax = 2.5
			units = 'ppb'
		       END	
	
		'SF6': BEGIN
			fix_ymin = -0.15
			fix_ymax = 0.20 
			units = 'ppt'
		       END	

		'CO': BEGIN
			fix_ymin = -5.0
			fix_ymax = 5.2
			units = 'ppb'
		       END	

		'H2': BEGIN
			fix_ymin = -20.0
			fix_ymax = 20.0
			units = 'ppb'
		       END	

		'CH4': BEGIN
			fix_ymin = -5.0
			fix_ymax = 5.2
			units = 'ppb'
		       END	

		'CO2': BEGIN
			fix_ymin = -0.2
			fix_ymax = 0.25 
			units = 'ppm'
		       END	

	ENDCASE

	;  Set y range
	IF KEYWORD_SET(nofix) THEN BEGIN
		ymin = max_diff * (-1.0) 
		ymax = max_diff
	ENDIF ELSE BEGIN
		ymin = fix_ymin
		ymax = fix_ymax	
	ENDELSE


	; initialize plot for bottom panel
	t_unit = 'Analysis Date' 
	PLOT, time, diff, /NODATA, COLOR = pen(1), $
		POSITION = [0.20, 0.10, 0.94, 0.50], $
		CHARSIZE = charsize, $
		CHARTHICK = charthick, $

		XTITLE = t_unit, $
		XSTYLE = 1, $
		XTHICK = axis_thick, $
		XTICKLEN = ticklen, $
		XRANGE = [xmin, xmax], $

		YSTYLE = 1, $
		YTHICK = axis_thick, $
		YTICKLEN = ticklen, $
		YRANGE = [ymin, ymax] 


	; xyout y axis title
	; set location for xyouts 
	x_out = 0.07
	y_out = 0.22

	ytitle = 'Value - Assigned!C   ' + gasdata.units   
	XYOUTS, x_out, y_out, ytitle, COLOR = pen(1), /NORMAL, $
	CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 90	

	; set variables to hold stats
	avg_diff = FINDGEN(ninst) * 0.0
	stddev_diff = FINDGEN(ninst) * 0.0
	avg_stddev = FINDGEN(ninst) * 0.0
	number = INDGEN(ninst) * 0

	; loop through results from each inst and plot and write summary info
	FOR i=0, ninst-1 DO BEGIN

		k = WHERE(wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) ; index of valid data
		IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
		IF k[0] NE -1 THEN BEGIN	
	
			time = wrkdata.(i)[k].dd 
			norm_results = wrkdata.(i)[k].value - wrkdata.(i)[k].tg
			clipped_results = ClipOnYRange(norm_results)
			CCG_SYMBOL, sym = sym_arr[i], fill = 1, THICK = symthick
			OPLOT, time, clipped_results, PSYM = 8, COLOR = pen(col_arr[i]), SYMSIZE = symsize, /NOCLIP
				
			; Add error bars	
			pos_err = norm_results + wrkdata.(i)[k].sd
		        neg_err = norm_results - wrkdata.(i)[k].sd
		        CCG_ERRPLOT, wrkdata.(i)[k].dd, neg_err, pos_err, thick = linethick, COLOR = pen(col_arr[i])
		ENDIF

		; Calculate mean difference
	        IF k[0] EQ -1 THEN BEGIN
	                avg_diff[i] = default
	                stddev_diff[i] = default
	                avg_stddev[i] = default
	                number[i] = 0

	        ENDIF ELSE BEGIN
	                avg_diff[i] = CCG_MEAN(norm_results)
	                stddev_diff[i] = STDDEV(norm_results)
	                avg_stddev[i] = CCG_MEAN(wrkdata.(i).sd)
	                number[i] = N_ELEMENTS(norm_results)

	        ENDELSE
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; if std_chagnes = 1 plot vertical bars for standard changes, and std_chagnes = 2 also add cylinder id's
		IF KEYWORD_SET(std_changes) THEN BEGIN
	
			j = WHERE( STRUPCASE(std_inst) EQ STRUPCASE(inst[i]) AND std_ddate GE xmin AND std_ddate LE xmax)	
					
			IF  j[0] NE -1 THEN BEGIN
				; test to see if the std prior to j[0] is on this inst, if so then add it
				IF j[0] GT 0 THEN BEGIN ;prevents crashing on first record in standard change table
					IF std_inst[j[0] - 1] EQ inst[i] THEN j = [ (j[0] - 1), j]
				ENDIF

			ENDIF ELSE BEGIN
				j = MAX( WHERE( STRUPCASE(std_inst) EQ STRUPCASE(inst[i]) AND std_ddate LE xmin ))	
			ENDELSE

			IF  j[0] NE -1 THEN BEGIN
				; loop through each std_ddate, plot vertical line with inst color
				nj = N_ELEMENTS(j)
				FOR ii = 0, nj - 1 DO BEGIN
					IF std_ddate[j[ii]] GT !Y.CRANGE[0] THEN $
						OPLOT, [std_ddate[j[ii]], std_ddate[j[ii]]], [!Y.CRANGE[0], !Y.CRANGE[1] ], $
							 COLOR = pen(col_arr[i]), THICK = linethick, LINESTYLE = 1

					; if std_changes > 1 then write std id's on plot
					IF std_changes GT 1 THEN BEGIN  
						; xyout standard cylinder ID's 
						; set location for xyouts 
						IF (i MOD 2) EQ 0 THEN y_out = !Y.CRANGE[1] * 0.60 ELSE $
							y_out = !Y.CRANGE[0] * 0.90 

						IF std_ddate[j[ii]] LT !X.CRANGE[0] THEN BEGIN
							x_out = !X.CRANGE[0] 
						ENDIF ELSE IF ii EQ (nj - 1) THEN BEGIN
							x_out = (std_ddate[j[ii]] + !X.CRANGE[1] ) / 2.0  
						ENDIF ELSE BEGIN
							x_out = (std_ddate[j[ii]] + std_ddate[j[ii + 1]]) / 2.0  
						ENDELSE
						IF STRUPCASE(sp) EQ 'CO2' THEN charsize_ = leg_charsize * 0.7 ELSE $
							charsize_ = leg_charsize * 0.8
						XYOUTS, x_out, y_out, std_id[j[ii]], COLOR = pen(col_arr[i]), /DATA, $
							CHARSIZE = charsize_, CHARTHICK = thin_charthick,$
							 ORIENTATION = 45	
					ENDIF
					 
				ENDFOR
			ENDIF ELSE BEGIN
				x_out = !X.CRANGE[0] 
				y_out = !Y.CRANGE[1] * 0.60
				XYOUTS, x_out, y_out, 'No Standard Information!cavailable', COLOR = pen(col_arr[i]), $
					 /DATA, CHARSIZE = leg_charsize * 0.6, CHARTHICK = thin_charthick, $
					ORIENTATION = 45	
				
			ENDELSE

		ENDIF
		; end plot std changes
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ENDFOR


	;  Plot line at y=0 

	OPLOT, !X.CRANGE, [0, 0], COLOR = pen(1), THICK = linethick

	; create legend
	IF KEYWORD_SET(legend) THEN BEGIN ; only create legend if specified
		inst_id = TAG_NAMES(wrkdata)
		tarr = STRARR(ninst)
		sarr = FINDGEN(ninst)
		carr = FINDGEN(ninst)
		farr = FINDGEN(ninst)
	
		FOR i=0,ninst -1 DO BEGIN

			tarr[i] = inst_id[i]	
			sarr[i] = sym_arr[i]
			carr[i] = col_arr[i]

		ENDFOR

		; set location for legend and XYOUTS
		;	positioned for bottom panel of two panel plot
		IF std_changes GT 1 THEN BEGIN
			x_leg = 0.07
			y_leg = 0.480
		ENDIF ELSE BEGIN
			x_leg = 0.23
			y_leg = 0.485
		ENDELSE
		;x_out = 0.225
		;y_out = 0.125

		; plot legend
		CCG_SLEGEND, x = x_leg, y = y_leg, tarr = tarr, $
			sarr = sarr, carr = carr, CHARSIZE = leg_charsize, $
			CHARTHICK = charthick, THICK = symthick


	
	ENDIF

	IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
	IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;

	CCG_CLOSEDEV, dev = dev, saveas = saveas

	; update win so get all plots asked for on screen
	win = win + 1


	; Write summary stats, either to screen or to summary file if /save
        ; format start and end date to look right in table
        tmp = DateDB(date)
        str_date_range = tmp[0] + ' --> ' + tmp[1]

        ; Print Header info
        PRINTF, fp,''
        PRINTF, fp ,' ******************************************************************'
        PRINTF, fp, ' NOAA Instrument Comparison:   TARGET TANK ' + STRUPCASE(id)
        PRINTF, fp, ''
        PRINTF, fp, ' PROCESS DATE   ' + today.s0
        PRINTF, fp, ''
        PRINTF, fp, ' ' + STRUPCASE(sp) + ' Normalized to cylinder assigned value ' 
        PRINTF, fp, ''
        PRINTF, fp, ''

        fmt ="(A18, A13, A10, A10, A10, A6)"
        header = ["DATE RANGE","INST", "MEAN", "SD_MEAN", "AVG_SD", "#"]
        PRINTF, fp,  FORMAT = fmt, header

	; print results from each instrument
	FOR i=0,ninst-1 DO BEGIN
	        fmt ="(A26, A5, F10.3, F10.3, F10.3, I6)"
	        PRINTF, fp, FORMAT = fmt, str_date_range, inst[i], avg_diff[i], stddev_diff[i], $
				avg_stddev[i], number[i]
	      
	ENDFOR

        PRINTF, fp ,' ******************************************************************'
        PRINTF, fp, ' '
        PRINTF, fp, ' '
        PRINTF, fp, ' '

ENDIF ELSE BEGIN
	; if target_flag = 0 then no plot available
	; write error message on plot

	; set location for xyouts 
	x_out = 0.25
	y_out = 0.25

	err_message = 'Plot not available, no entry in magicc_target.tab'  
	XYOUTS, x_out, y_out, err_message, COLOR = pen(1), /NORMAL, $
	CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 0	


ENDELSE

END
; end PLOT_NORM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Start main procedure
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	CCG_MAGICC_TANK_ICP,$
	id 		= id,$
        sp 		= sp,$
        inst 		= inst,$
        date 		= date,$
        help 		= help,$
        dev 		= dev, $
	mixing_ratio 	= mixing_ratio, $
	norm_target 	= norm_target, $
	std_changes 	= std_changes, $
	win 		= win, $
	presentation 	= presentation, $
	nofix 		= nofix, $
	save 		= save, $
	ddir 		= ddir, $
	nolabid 	= nolabid, $
        noproid 	= noproid 




;
; Misc initialization
;
today = CCG_SYSDATE()
default = -999.999
target_flag = 1

col_arr = [11,12,4,13,6,3]
sym_arr = [1,2,3,4,5,6]


IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(id) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(win) THEN win = 0
IF KEYWORD_SET(save) AND NOT KEYWORD_SET(dev) THEN dev = 'psc'
IF NOT KEYWORD_SET(dev) THEN dev = ''
IF NOT KEYWORD_SET(ddir) THEN ddir = GETENV("HOME")+'/'
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(inst) THEN CCG_SHOWDOC
inst_ = STRSPLIT(STRUPCASE(inst), ',', /EXTRACT, COUNT=ninst)
IF NOT KEYWORD_SET(std_changes) THEN std_changes = 0
; set case of variables used in case or if statements
dev = STRLOWCASE(dev)
sp = STRUPCASE(sp)
id = STRUPCASE(id)


CCG_GASINFO, sp = sp, gasdata

;  Format date range
IF NOT KEYWORD_SET(date) THEN date = LONG(today.s1) ;if no date passed, use today's date as enddate
ndate = N_ELEMENTS(date)
IF ndate EQ 1 THEN date = [LONG(date), LONG(date)]

; if single date entered, then process one year from passed date
;	if no date passed will process previous year from today's date
IF ndate EQ 1 THEN BEGIN
	date[0] = ENDDATE(date[0])
	date = [date[0] - 10000, date[0]]  ; reverse so today's date is end date, start date is -1 year

ENDIF ELSE BEGIN 
	; if two dates passed, make sure they are correct format yyyymmdd
	date = [STARTDATE(date[0]), ENDDATE(date[1])]

ENDELSE



; Set x axis plotting range based on passed date
;    keeps all x axis the same for two panel plots	
;	xmin xmax
xmin = LongDate2Dec(date[0]) - 0.05
xmax = LongDate2Dec(date[1]) + 0.05



;;;;;;;;;;
; Setup plotting keywords
IF KEYWORD_SET (presentation) THEN BEGIN
	; plot settings for psc files
		presentation	= 1
		charsize 	= 1.2
		leg_charsize 	= 1.0
		charthick 	= 3.5
		thin_charthick 	= 2.0
		symsize 	= 1.2
		symthick 	= 5.0
		linethick 	= 3.5
		axis_thick 	= 5.0
		gridstyle 	= 0
		ticklen 	= -0.02
		xpixels 	= 800
		ypixels 	= 600	

ENDIF ELSE BEGIN
	; plot settings for screen
		presentation 	= 0
		charsize 	= 1.2
		leg_charsize 	= 1.0
		charthick 	= 1.0
		thin_charthick 	= 1.0
		symsize 	= 1.0
		symthick 	= 1.0
		linethick 	= 1.0
		axis_thick 	= 1.0
		gridstyle 	= 0
		ticklen 	= -0.02
		xpixels 	= 800
		ypixels 	= 600	

ENDELSE
;;;;;;;;;


; extract tank cal results using CCG_CAL
;CCG_CAL,  id = id, sp = sp, date = DateDB(date), tmpdata
str_date = DateDB(date[0]) + ',' +DateDB(date[1])
CCG_CAL,  id = id, sp = sp, date = str_date, tmpdata

; test returned value (tmpdata) if not a structure then no data was found, skip rest of 
; script without crashing
IF (SIZE(tmpdata, /TYPE) NE 8) THEN BEGIN
	PRINT,'**************  NO DATA RETURNED FROM CCG_CAL **************'

ENDIF ELSE BEGIN 

	; Remove flagged results
	k = WHERE(tmpdata.flag EQ '.')
	IF (k[0] EQ -1) THEN CCG_FATALERR, '*********** NO VALID DATA RETURNED FROM CCG_CAL ************'
	tmpdata = tmpdata[k]

	; Read lookup table for target tank assigned value
	CYLINDER_VALUES, sp = sp, $
		filename = '/projects/' + STRLOWCASE(sp) + '/cals/magicc_target.tab', $
		cyln_values = cyln_values


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Read standard changes table if asked for
	IF KEYWORD_SET(std_changes) THEN BEGIN
		; Read std history file
		std_fn = '/ccg/' + STRLOWCASE(sp) + '/magicc_std_changes.tab'
		CCG_SREAD, file = std_fn, r
		
		FOR i = 0 , N_ELEMENTS(r) - 1 DO BEGIN
			tmp = STRSPLIT(r[i], /EXTRACT)

			CCG_DATE2DEC, yr = FIX(tmp[1]), mo = FIX(tmp[2]), dy = FIX(tmp[3]), hr = FIX(tmp[4]), dec = dec

			std_ddate = (i EQ 0) ? dec : [std_ddate, dec]
		
			IF STRLOWCASE(sp) EQ 'co2' THEN BEGIN
				tmp_id = tmp[5] + ', ' + tmp[6] + ',!c' + tmp[7]
			ENDIF ELSE BEGIN
				tmp_id = tmp[5]
			ENDELSE
			std_inst = (i EQ 0) ? tmp[0] : [std_inst, tmp[0]]
			std_id = (i EQ 0) ? tmp_id : [std_id, tmp_id]
		
		ENDFOR

	ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	; Insert new tag into data structure containing cylinder assigned value
	;	if id is not a target tank assign default and set target_flag to 0
	;	target flag of 0 indicates not a target tank so no normalized plot available
	j = WHERE(STRUPCASE(cyln_values.tank) EQ STRUPCASE(id)) 

	IF j[0] NE -1 THEN cyln_values = cyln_values[j] ELSE target_flag = 0

		FOR i = 0, N_ELEMENTS(tmpdata) - 1 DO BEGIN
			; if id is a target tank, assign target tank value, else default	
			tg_value = (target_flag EQ 0) ? default : CYLINDER_VALUES_BY_DATE( tmpdata[i].dd, cyln_values, default)
			tmp = CREATE_STRUCT(tmpdata[i], 'tg', tg_value)
			data = (i EQ 0) ? [tmp] : [data, tmp]

		ENDFOR


	;  create structures for each instrument (wrkdata)
	;	This also reduces the inst list and ninst to only the valid instruments
	;	(ie those that have data) during this time period.
	INSTRUMENT_SPECIFIC_DATA, $
		data = data, $
		inst = inst_, $
		wrkdata = wrkdata, $
		ninst = ninst

	; protect from crashes if no data was found during date range for specified instruments
	IF STRLEN(inst_[0]) EQ 0 THEN BEGIN
		; prints error message if no data was available but does not crash.  Helps keep
		; web driver from crashing if nothing available for some runs
		PRINT, '********  NO DATA FOUND FOR DATE/INST PASSED ***********'

	ENDIF ELSE BEGIN

		;  Set output for summary text.  Either screen or file
		summary_filename = ddir + STRLOWCASE(id) + '_summary_' + STRLOWCASE(sp) + '.txt'
		IF KEYWORD_SET(save) THEN OPENW, fp, summary_filename, /GET_LUN ELSE fp = -1


		; plot mixing ratios
		IF KEYWORD_SET(mixing_ratio) THEN PLOT_TANK_MIXING_RATIOS, $
			id = id, $
			date = date, $
			sp = sp, $
			inst = inst_, $
			dev = dev, $
			wrkdata = wrkdata, $
			ninst = ninst, $
			cyln_values = cyln_values, $
			sym_arr = sym_arr, $
			col_arr = col_arr, $
			default = default, $
			win = win, $
			gasdata = gasdata, $
			save = save, $
			ddir = ddir, $
			nolabid = nolabid, $
			noproid = noproid , $

			presentation = presentation, $
			fp = fp, $ 
			legend = 1, $
			xmin = xmin, $
			xmax = xmax, $
			nofix = nofix, $
			charsize = charsize, $
			leg_charsize = leg_charsize, $
			charthick = charthick, $
			thin_charthick = thin_charthick, $
			symsize = symsize, $
			symthick = symthick, $
			linethick = linethick, $
			axis_thick = axis_thick, $
			gridstyle = gridstyle, $
			ticklen = ticklen, $
			xpixels = xpixels, $
			ypixels = ypixels


		;  Plot difference between measured test flask values and tank
		;       assigned values
		IF KEYWORD_SET(norm_target) THEN PLOT_NORM_TARGET, $
			dev = dev, $
			wrkdata = wrkdata, $
			id = id, $
			date = date, $
			sp = sp, $
			inst = inst_, $
			ninst = ninst, $
			cyln_values = cyln_values, $
			sym_arr = sym_arr, $
			col_arr = col_arr, $
			default = default, $
			win = win, $
			gasdata = gasdata, $
			save = save, $
			ddir = ddir, $
			today = today, $
			nolabid = nolabid, $
			noproid = noproid , $
			target_flag = target_flag, $
			std_changes 	= std_changes, $
			std_ddate = std_ddate, $
			std_id = std_id, $
			std_inst = std_inst, $

			presentation = presentation, $ 
			fp = fp, $ 
			legend = 1, $
			xmin = xmin, $
			xmax = xmax, $
			nofix = nofix, $
			charsize = charsize, $
			leg_charsize = leg_charsize, $
			charthick = charthick, $
			thin_charthick = thin_charthick, $
			symsize = symsize, $
			symthick = symthick, $
			linethick = linethick, $
			axis_thick = axis_thick, $
			gridstyle = gridstyle, $
			ticklen = ticklen, $
			xpixels = xpixels, $
			ypixels = ypixels



				
		; If keyword "save_data" specified then Write text file for each wrkdata structure
		IF KEYWORD_SET(save) THEN SAVE_TANK_WRKDATA_FILES, $
				wrkdata = wrkdata, $
				ddir = ddir, $
				id = id, $
				ninst = ninst, $
				sp = sp



		IF KEYWORD_SET(save) THEN FREE_LUN, fp

	ENDELSE

ENDELSE

END



