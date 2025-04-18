;+
;help
; NAME:  
;	CCG_MAGICC_ICP
;
; PURPOSE:
;	Allow comparison of CCGG instruments.  Compares results in the
;	RDBMS for two or more instruments for a single species at a single
;	site.  Primarily used to compare performance of the Magicc_1 and 
;	Magicc_2 analysis systems through intercomparisons with test flasks,
;	network flasks collected at KUM, pfp's from RTA, and target tank 
;	calibrations.
;	
;
; CATEGORY:
;
; CALLING SEQUENCE:
; 	CCG_MAGICC_ICP, project = 'ccg_surface', strategy = 'flask', site= 'tst', $
;			sp='co2', inst= 'l3,s2,l8', date = [20040101,20061231], $
;			/mixing_ratio
;
; 	CCG_MAGICC_ICP, project = 'ccg_surface', strategy = 'flask', site= 'tst', $
;			sp= 'co2', inst= 'l3,s2', date = [20040101,20041231], $
;			/norm_tst
;
; 	CCG_MAGICC_ICP, project = 'ccg_surface', strategy = 'flask', site= 'tst', $ 
;			sp= 'co2', inst= 'l3,s2', date = [20040101,20041231], $
;			inst='l3,s2', /norm_inst1
;
; 	CCG_MAGICC_ICP, project = 'ccg_surface', strategy = 'flask', sp='co2', $
;			site='tst', date=[20040101,20041231], inst='l3,s2', $
;			/mixing_ratio, /norm_inst1, /norm_inst1
;
; 	CCG_MAGICC_ICP, project = 'ccg_surface', strategy = 'flask', sp = 'co2', $
;			site='kum', date=[2006,2007], inst='l3,l8', /norm_inst1
;
; 	CCG_MAGICC_ICP, project = 'ccg_aircraft', strategy = 'pfp', site='rta', $
;			sp = 'co2', date = [2006,2007], inst = 'l3,l8', $
;			/norm_inst1
;
;
; INPUTS:
;	project:	Project abbreviation.  May only specify one project.
;			(ex) project = 'ccg_surface'
;			(ex) project = 'ccg_aircraft'
;
;	strategy:	Strategy abbreviation.  May only specify one strategy.
;			(ex) strategy = 'flask'
;			(ex) strategy = 'pfp'
;
;       site:           Site code.  May only specify a single code per call.
;                       (ex) site='tst'
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
;	a_time		If keyword set, plot mixing ratios verses analysis date rather than 
;			sample date.
;
;	norm_inst1	If keyword set, request a plot of inst(n) minus inst(0) for each sample
;			run on both instruments.  Results are always normalized to the first
;			instrument listed.  If more than two instruments listed, plot
;			will contain instruments 2 through n normalized to the first instrument 
;			listed.  This is a 2 panel plot with the mixing ratios in the top 
;			panel and the Inst(n) -Inst(0) data in the bottom panel.
;			(ex) inst = 'L3,L8', /norm_inst1  	Plot of results from L8 minus L3
;			(ex) isnt = 'L3,S2,L8', /norm_inst1  	Plot of results from L8 and from 
;								S2 minus L3
;
;	norm_tst	If keyword set, request a plot of test flask results from each instrument 
;			normalized to the assigned values of the test gas cylinders.  Must 
;			specify site = 'tst' for this plot.  This is a two panel plot with the 
;			mixing ratios in the top panel and the normalized test flask data in 
;			the bottom panel.
;			(ex) site = 'tst', /norm_tst
;
;	ccgvu		If keyword set, request plot of a CCGVU curve fit to the results from each 
;			instrument.
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
;			(site)_(sp).txt   	  	Data from all instruments organized
;			(ex) tst_ch4.txt	  	by event number.
;
;			(site)_(inst)_(sp).txt    	Data from one instrument.
;			(ex) tst_H4_ch4.txt
;
;			(site)_summary_(sp).txt   	Summary statistics.
;			(ex) tst_summary_ch4.txt
;	
;	Plot filenames:
;			(site)_(sp).(dev) 		Time series of mixing ratios.
;			(ex) kum_ch4.ps			
;
;			(site)_inst-inst1_(sp).(dev)	Time series of inst(n) minus inst(0).
;			(ex) kum_inst-inst1_ch4.ps
;
;			tst_normtst_(sp).(dev)		Time series of normalized test flasks.
;			(ex) tst_normtst_ch4.ps
;			
;			(site)_ccgvu_(sp).(dev)		CCGVU curve fit to each instrument results.
;			(ex) kum_ccgvu_ch4.ps
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
;               CCG_MAGICC_ICP,$
;			       project='ccg_surface', $
;               strategy='flask', $
;               site='tst',$
;               sp='co2',$
;               inst='L3,L8'
;               date=[20060101,20070401],$
;               /mixing_ratio,/norm_inst1,/norm_tst
;
;
; MODIFICATION HISTORY:
;       Written, AMC and KAM, April 2007.
;
;
;
;-





;
; Get Utility functions

@ccg_utils.pro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION        ConvertDate,d
        z = STRCOMPRESS(STRING(d),/RE)
        CASE STRLEN(z) OF
        4:      z = STRMID(z,0,4)+'-'+STRMID(z,4,2)+'-'+STRMID(z,6,2)
        6:      z = STRMID(z,0,4)+'-'+STRMID(z,4,2)
        ELSE:
        ENDCASE
        RETURN, z
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to convert long formatted date (20060101) to dec
FUNCTION	LongDate2Dec, date

	yr = LONG(date / 10000)
	tmp = date - (yr * 10000)
	mo = FIX(tmp / 100)
	dy = FIX(tmp - (mo * 100))
	CCG_DATE2DEC, yr = yr, mo = mo, dy = dy, hr = 0, mn = 0, dec = dec
	RETURN, dec
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to return a list of months between two passed dates
;	Returns yyyymm of each month starting with first month and 
; 	ending with 1 past last month.  Returns yyyymm
;	Ex. pass 20060408,20070408  Returns array year and month
; 		200604 
;		200605 
;		    .
;		    .
;		200704 
;		200705
FUNCTION Month_List, date

	yrmo = date / 100
	yr = yrmo / 100
	mo = yrmo - (yr*100)

	nyears = yr[1] - yr[0]
	nmonths = (nyears * 12) + (mo[1] - mo[0])

	date_time = TIMEGEN(nmonths +2, UNIT='Months', $
	        START=JULDAY((yrmo[0] - (yr[0]*100)),01,yr[0]))

	CALDAT, date_time, month, day, year
	month = STRING(month, FORMAT = '(I02)')

	list = ToString(year) + ToString(month) 
	RETURN, list 
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to determine the analysis number from the event number
;               and the analysis_date
; Returns an integer of the analysis number
;		ex. 1 for first analysis, 2 for second, 3 for 3rd,etc.
FUNCTION        ANALYSIS_NUMBER,$
		default,$
                data,$
                evn,$
                analysis_date

	
	num=FIX(default)	
        j=WHERE(data.evn EQ evn)
	If j[0] EQ -1 THEN RETURN, num
        temp=data[j].adate
        temp=temp(SORT(temp))
        k=WHERE(temp EQ analysis_date)
	IF k[0] EQ -1 THEN RETURN, num
        num=k[0]+1
        RETURN, num


END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTION to find test gas value by date, date is dec
FUNCTION        TESTGAS_VALUE_BY_DATE,$
        date,$
        testgas,$
        default

	value=DOUBLE(default)
	j=WHERE(testgas.start_date LE date)
	IF j[0] EQ -1 THEN RETURN, value
	tank_index=j[N_ELEMENTS(j)-1]
	IF (testgas[tank_index].parameters[0]-1) LE default THEN RETURN, value
	value=0.0
	FOR i=0, testgas[tank_index].num_para-1 DO BEGIN
	value=value + testgas[tank_index].parameters[i]*(date-testgas[tank_index].time_zero)^(i)
	ENDFOR
	RETURN, value

END
; end DETERMINE_TESTGAS_VALUE_BY_DATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extract test gas calibration values for site = TST
PRO     TEST_GAS, sp=sp, testgas=testgas

	filename = '/projects/' + STRLOWCASE(sp) + '/flask/tstgas.tab'
	CCG_SREAD,file=filename,skip=18,str_testgas
	ntestgas=N_ELEMENTS(str_testgas)


	; create structure template for test gas data
	z=CREATE_STRUCT($
	'start_date',   0D,$
	'tank',         '',$
	'fill',         '',$
	'num_para',     0,$
	'time_zero',    0D,$
	'parameters',   DBLARR(5))

	;initialize structure for testgas data
	testgas=[z]


	FOR i=0,ntestgas-1 DO BEGIN
	        CCG_STRTOK,str=str_testgas[i],delimiter=' ',temp
	        CCG_DATE2DEC,yr=temp[0],mo=temp[1],dy=temp[2],hr=temp[3],dec=dec

	        z.start_date=dec
	        z.tank=temp[4]
	        z.fill=temp[5]
	        z.num_para=FIX(temp[6])
	        z.parameters[*]=0.0D
	        z.time_zero=DOUBLE(temp[7])

	        IF z.num_para NE 0 THEN BEGIN
	                FOR j=0,z.num_para-1 DO z.parameters[j] = DOUBLE(temp[8+j])
	        ENDIF ELSE BEGIN
	                z.parameters[0]=DOUBLE(temp[8])
	        ENDELSE

	        ; Concatenate current record to structure array
	        testgas=[testgas,z]

	ENDFOR

	testgas=testgas[1:*]
END
; END TEST_GAS.PRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Procedure to write instrument specific data to files
PRO	SAVE_WRKDATA_FILES, $
		wrkdata	= wrkdata, $
		ddir 	= ddir, $
		site 	= site, $
		ninst 	= ninst, $
		sp 	= sp
; For flasks write results to a file, one file for each instrument.
; If site is 'tst', find testgas values and write test gas calibration
; values to the file also.  One file for each instrument.  File names are stored in array
; "sitefilename".    Ex. sitefilename(0) is the filename for inst(0).  
; Filenames are ddir/"site"_"gas"_"inst".txt   Ex.  tst_ch4_h4.txt


inst_id = TAG_NAMES(wrkdata)
sitefilename=STRARR(ninst)

;loop through each instrument's results
FOR i=0,ninst-1 DO BEGIN

	nvalues=N_ELEMENTS(wrkdata.(i).value)

	; create file and write 1 line header info. If site = 'tst' then 
	;	add column for tg_value in the header, otherwise don't		
	;	If site NE tst, then writes null value for tg and no header
	sitefilename[i]=ddir + STRLOWCASE(site) + '_' + inst_id[i] + $
			 '_' +STRLOWCASE(sp) + '.txt'

	format = '(A12,A5,A10,A4,A5,A10,A5,A12,A5,A15,A15)'
	header = ["EVN","SITE","SMPL_DATE","GAS","INST","ADATE","ANUM","VALUE","FLAG"]

	IF site EQ 'tst' THEN header = [header, 'TST_GAS_VALUE']

	OPENW, fp1, sitefilename[i], /GET_LUN
	PRINTF, fp1, FORMAT = format, header

	FOR j=0,nvalues-1 DO BEGIN
		; write values and tg_values to file "site"_"gas"_"inst".txt
		PRINTF, fp1, FORMAT = '(I12,A5,G12.8,A5,A4,G12.8,I5,F12.4,A5,A)', $

		wrkdata.(i)[j].evn,  wrkdata.(i)[j].code,  wrkdata.(i)[j].date, $
		wrkdata.(i)[j].parameter,  wrkdata.(i)[j].inst,  wrkdata.(i)[j].adate, $
		wrkdata.(i)[j].anum,  wrkdata.(i)[j].value,  wrkdata.(i)[j].flag, $
		STRING(wrkdata.(i)[j].tg)
	ENDFOR
	FREE_LUN, fp1

	PRINT,'data saved as ', sitefilename[i] 

ENDFOR

END
; End SAVE_WRKDATA_FILES  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Procedure to save file of results organized by each unique EVN number
;
PRO	SAVE_EVN_FILE, $
		wrkdata	= wrkdata, $
		data 	= data, $
		inst 	= inst, $
		ddir 	= ddir, $
		site 	= site, $
		ninst 	= ninst, $
		sp 	= sp, $
		unq_evn = unq_evn, $
		default = default
	
; For each individual flask (each unique evn) find the results from each instrument
; write a file of flask and each instrument results.  If multiple runs on an 
; instrument the average is written to the file.

; filename stored in variable "evnfilname"
evnfilename=ddir + STRLOWCASE(site) + '_' + STRLOWCASE(sp) + '.txt'

;  Create file evnfilename and write 1 line header with "inst", 
;	"adate","value","anum" columns for each inst specified in main call
OPENW, fp2, evnfilename, /GET_LUN

fmt ="(A8,A10,A4"
header = ["EVN","SMPL_DATE","GAS"]

FOR i = 0, ninst -1 DO BEGIN
	
	fmt = fmt + ',A5,A10,A5,A10'	
	header = [header,"INST","ADATE","ANUM","VALUE"]

ENDFOR

fmt = fmt +")"

PRINTF, fp2, FORMAT = fmt, header

		
; loop through each inst file to find results for each unique evn number	
FOR i=0, N_ELEMENTS(unq_evn)-1 DO BEGIN

	m = WHERE(data.evn EQ unq_evn[i])
	IF m[0] EQ -1 THEN CONTINUE
				
	; Use str_output to hold the sample info and results from each instrument 
	;	file.  Then str_output is written to a file so that the sample info
	; 	and each instrument results are on a single line in the file.	

	; write sample info into str_output
	str_output = STRCOMPRESS(unq_evn[i]) + ' ' + $
		STRCOMPRESS(data[m[0]].date) + ' ' + STRCOMPRESS(data[m[0]].parameter)

	;Loop through each instruments data structure
	;	Find the unique evn in each inst data structure 
	;	If mulitple entries, average results and record 1st
	;	analysis data and anum

       	FOR j=0,ninst-1 DO BEGIN
		
		k = WHERE(wrkdata.(j).evn EQ unq_evn[i])
				
		; If the sample (unq_evn[i]) was not run on the instrument then 
		; 	assign default values
		IF k[0] EQ -1 THEN BEGIN			
			avg_values = default
			min_adate = default
			min_anum = FIX(default)
		
		ENDIF ELSE BEGIN
			;  If the sample was run assign average value of all runs
			; 	and 1st adate and anum
			avg_values = CCG_MEAN(wrkdata.(j)[k].value)	
			min_adate = MIN(wrkdata.(j)[k].adate)
			min_anum = MIN(wrkdata.(j)[k].anum)
		ENDELSE
				
		; Add results from each instrument to the end of the str_output 
		;	line created for the uni_evn[i] above
		str_output=str_output + ' ' + inst[j] + ' ' + STRCOMPRESS(min_adate) + $
			' ' + STRCOMPRESS(min_anum) + ' ' + STRCOMPRESS(avg_values)
	ENDFOR	

	splt_str_output = STRSPLIT(str_output,/EXTRACT)

	; Write the str_output to the end of the file evnfilename
	PRINTF, fp2, FORMAT = fmt, splt_str_output 

ENDFOR
FREE_LUN, fp2

PRINT,'data saved as ', evnfilename

END
;  End save_evn_file procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE TO PLOT MIXING RATIOS
;	PLOT_MIXING_RATIO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	PLOT_MIXING_RATIOS, $
	site = site, $
	date = date, $
	sp = sp, $
	inst = inst, $
	dev = dev, $
	wrkdata	= wrkdata, $
	a_time = a_time, $
	ninst = ninst, $
	testgas	= testgas, $
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


	;set filename for saving plot (ex.  tst_ch4.ps)
file_extension = (dev EQ 'psc') ? 'ps' : dev
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(site) + $
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
FOR i=0,ninst-1 DO BEGIN
	tmp = wrkdata.(i).value
	data = (i EQ 0) ? [tmp] : [data, tmp]
	tmp_time = (a_time EQ 1) ? wrkdata.(i).adate : wrkdata.(i).date
	time = (i EQ 0) ? [tmp_time] : [time, tmp_time]
ENDFOR

; expand the y axis from the min and max for each gas to keep plots looking good and keep
;	legend readable.  Legend in top left corner of plot so expand ymax more than ymin
CASE STRUPCASE(sp) OF
        'N2O': BEGIN
                expand_ymin = 0.995
                expand_ymax = 1.01
		units = 'ppb'
               END

        'SF6': BEGIN
                expand_ymin = 0.985
                expand_ymax = 1.03
		units = 'ppt'
               END

        'CO': BEGIN
                expand_ymin = 0.87
                expand_ymax = 1.12
		units = 'ppb'
               END

        'H2': BEGIN
                expand_ymin = 0.88
                expand_ymax = 1.08
		units = 'ppb'
               END

        'CH4': BEGIN
                expand_ymin = 0.993 
                expand_ymax = 1.010
		units = 'ppb'
               END

        'CO2': BEGIN
                expand_ymin = 0.999
                expand_ymax = 1.005
		units = 'ppm'
               END
ENDCASE

ymin = MIN(data) * expand_ymin
ymax = MAX(data) * expand_ymax


; set up plot
IF KEYWORD_SET(half_plot) THEN BEGIN
;  Plot setup for half page
	t1 = STRUPCASE(site)+':  '+gasdata.formula
	t_unit = (a_time EQ 1) ? 'Analysis Date' : 'Sample Date'
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
	t1 = site+', '+gasdata.title
	t_unit = (a_time EQ 1) ? 'Analysis Date' : 'Sample Date'
	PLOT, time, data, /NODATA, COLOR=pen(1),$
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
FOR i=0,ninst-1 DO BEGIN

	time = (a_time EQ 1) ? wrkdata.(i).adate : wrkdata.(i).date
	k = WHERE(wrkdata.(i).anum EQ 1)  ;  index of first analysis
	l = WHERE(wrkdata.(i).anum NE 1)  ;  index of non first analysis
	IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
	IF k[0] NE -1 THEN BEGIN ; plot first analysis results with solid symbol
		CCG_SYMBOL, sym = sym_arr[i], fill = 1, thick = symthick
		OPLOT, time[k], wrkdata.(i)[k].value, PSYM = 8, COLOR = pen(col_arr[i]),$
			 SYMSIZE = symsize
	ENDIF

	IF N_ELEMENTS(l) EQ 1 THEN l = [l,l]
	IF l[0] NE -1 THEN BEGIN ; plot other analysis results with open symbol
		CCG_SYMBOL, sym = sym_arr[i], fill=0, thick = symthick
		OPLOT, time[l], wrkdata.(i)[l].value, PSYM = 8, COLOR = pen(col_arr[i]),$
			 SYMSIZE = symsize
	ENDIF
	
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
	t = 'Filled symbols indicate 1st analysis of flask'
	XYOUTS, x_out, y_out, t, /NORMAL, COLOR = pen[1], $
 		CHARSIZE = leg_charsize - 0.2, CHARTHICK = thin_charthick 

ENDIF


;if site=tst, plot testgas values as line
IF STRUPCASE(site) EQ 'TST' THEN BEGIN
	plot_range = !X.CRANGE
	ndiv = 2000
	div = (plot_range(1) - plot_range(0)) / ndiv
	x = FINDGEN(ndiv) * div + plot_range(0)
	lasty = 0

	FOR i=0,ndiv-1 DO BEGIN
		y = TESTGAS_VALUE_BY_DATE(x[i],testgas,default)

		IF y GT default THEN BEGIN
			continue_ = (i EQ 0 OR lasty-1 LT default) ? 0 : 1
			PLOTS, x[i], y, COLOR = pen[1], THICK = linethick, continue = continue_
		ENDIF

		lasty = y
	ENDFOR
ENDIF

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;

IF NOT KEYWORD_SET(half_plot) THEN CCG_CLOSEDEV, dev=dev, saveas = saveas

; update win so get all plots asked for on screen
win = win + 1

END
;  End PLOT_MIXING_RATIOS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  PROCEDURE TO CALCULATE SPECIAL TST STATS
;	stats on tst results - assigned values
PRO	SPECIAL_TST_STATS, $
		fp 	= fp, $ 
		date 	= date, $
		data_set= data_set, $
		time_set = time_set, $
		today 	= today, $
		project = project, $
		gasdata = gasdata, $
		site 	= site, $
		title 	= title, $
		testgas = testgas, $
		default = default


	; format start and end date to look right in table
	tmp = DateDB(date)
	str_date_range = tmp[0] + ' --> ' + tmp[1]		

	; Print Header info
	PRINTF, fp,''
	PRINTF, fp ,' ****************************************************************'
	PRINTF, fp, " NOAA Instrument Comparison:   TEST FLASK " 
	PRINTF, fp, ''
	PRINTF, fp, ' PROCESS DATE   ' + today.s0
	PRINTF, fp, ''
	PRINTF, fp, ' ' + title 
	PRINTF, fp, ''
	PRINTF, fp, ''
	
	fmt ="(A18,A21,A10,A10,A6)"
	header = ["DATE RANGE","CYLINDER", "MEAN", "STDEV", "#"]
	PRINTF, fp,  FORMAT = fmt, header


	; First calculate avg and stddev for whole dataset passed
	k = WHERE(data_set -1 GT default)
	IF k[0] EQ -1 THEN BEGIN
		avg = default
		std = default
		number = 0

	ENDIF ELSE BEGIN  
		avg = CCG_MEAN(data_set[k])
		std = STDDEV(data_set[k])
		number = N_ELEMENTS(data_set[k])
		
	ENDELSE

	; print whole data set stats
	fmt ="(A26,A13,F10.3,F10.3,I6)"
	PRINTF, fp, FORMAT = fmt, str_date_range, ' All', avg, std, number 	
	PRINTF, fp, ' '

	; determine indexs of test gas cyinders used during time period
	ntanks = N_ELEMENTS(testgas.start_date)
	first_index = MAX(WHERE(testgas.start_date LE LongDate2Dec(date[0])))	
	last_index = MIN(WHERE(testgas.start_date GT LongDate2Dec(date[1]))) - 1
	IF last_index[0] LE -1 THEN last_index = ntanks -1 ; if last tank then assign ntanks-1

	; For each cylinder calculate avg and stddev of results - assigned
	FOR i = last_index, first_index, -1  DO BEGIN

		; get formatted tank startdate
		CCG_DEC2DATE, testgas[i].start_date, tmpyr, tmpmo, tmpdy
		tmpmo = STRING(tmpmo, FORMAT = '(I02)')
		tmpdy = STRING(tmpdy, FORMAT = '(I02)')
		tg_start_date = ToString(tmpyr) + tmpmo + tmpdy
		
		IF LONG(tg_start_date) LT date[0] THEN tg_start_date = date[0]
		tg_start_date = DateDB(tg_start_date) ; formated cylinder start date or formated date[0] 

		; Get index of samples filled during cylinder use dates
		IF i EQ ntanks-1 THEN BEGIN
			; if last cylinder in tank list then get all data after tank start date
			k = WHERE( time_set GE testgas[i].start_date AND $
				   data_set -1 GT default)
			tg_end_date = DateDB(date[1])  ; if last tank in list assign enddate as date(1)
			
		ENDIF ELSE BEGIN  
			; if not last sylinder get samples from tank start date until next tank start date
			k = WHERE( time_set GE testgas[i].start_date AND $
				   time_set LT testgas[i+1].start_date  AND $
				   data_set -1 GT default)
			CCG_DEC2DATE, testgas[i+1].start_date - 0.00274, tmpyr, tmpmo, tmpdy
			tmpmo = STRING(tmpmo, FORMAT = '(I02)')
			tmpdy = STRING(tmpdy, FORMAT = '(I02)')
			tg_end_date = ToString(tmpyr) + tmpmo + tmpdy
			IF LONG(tg_end_date) GT date[1] THEN tg_end_date = date[1]
			tg_end_date = DateDB(tg_end_date)   ; formatted cylinder end date
			
		ENDELSE		
	
		; calculate avg and stddev	
		IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
		IF k[0] EQ -1 THEN BEGIN
			; if no data then assign default
	                avg = default
	                std = default
	                number = 0

	        ENDIF ELSE BEGIN
	                avg = CCG_MEAN(data_set[k])
	                std = STDDEV(data_set[k])
	                number = N_ELEMENTS(data_set[k])

	        ENDELSE
	
		; write stats to summary file or screen	
		tg_date_range = tg_start_date + ' --> ' + tg_end_date
		PRINTF, fp, FORMAT = fmt, tg_date_range, testgas[i].tank, avg, std, number

	ENDFOR

	PRINTF, fp ,' ****************************************************************'
	PRINTF, fp, ' '
	PRINTF, fp, ' '
	PRINTF, fp, ' '

END
;
;   END SPECIAL_TST_STATS.PRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  procedure to plot normalized test flask data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	PLOT_NORM_TST, $
	dev = dev, $
	wrkdata = wrkdata, $
	a_time = a_time, $
	site = site, $
	date = date, $
	sp = sp, $
	inst = inst, $
	ninst = ninst, $
	testgas = testgas, $
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
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(site) + '_normtst_' + $
		STRLOWCASE(sp) + '.' + file_extension 
			


CCG_OPENDEV, dev=dev, pen=pen, win = win , portrait = 1, saveas = saveas

!P.MULTI = [0,1,2]  ; creating multi panel plot

; get valid inst id's for plot labels
inst_id = TAG_NAMES(wrkdata)


;
; Call procedure plot_mixing_ratios to create top panel of plot
; 
PLOT_MIXING_RATIOS, $
        site = site, $
        date = date, $
        sp = sp, $
        inst = inst, $
        dev = dev, $
        wrkdata = wrkdata, $
        a_time = a_time, $
        ninst = ninst, $
        testgas = testgas, $
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
;;;;  start plotting of normalized TST data in botttom panel
;

; find the max difference to set y scale for auto scaling (/nofix)
FOR i=0,ninst-1 DO BEGIN
	k = WHERE(wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) 
	tmp = wrkdata.(i)[k].value - wrkdata.(i)[k].tg
	diff = (i EQ 0) ? [tmp] : [diff, tmp]
	tmp_time = (a_time EQ 1) ? wrkdata.(i)[k].adate : wrkdata.(i)[k].date
	time = (i EQ 0) ? [tmp_time] : [time, tmp_time]
ENDFOR
max_diff = MAX(ABS(diff))

; Set y scale range based on fixed range for each gas
;  	also set units for summary tables
CASE STRUPCASE(sp) OF
	'N2O': BEGIN
		fix_ymin = -3.0
		fix_ymax = 3.5
		units = 'ppb'
	       END	

	'SF6': BEGIN
		fix_ymin = -0.30
		fix_ymax = 0.45 
		units = 'ppt'
	       END	

	'CO': BEGIN
		fix_ymin = -10.0
		fix_ymax = 15.0
		units = 'ppb'
	       END	

	'H2': BEGIN
		fix_ymin = -30.0
		fix_ymax = 50.0
		units = 'ppb'
	       END	

	'CH4': BEGIN
		fix_ymin = -7.0
		fix_ymax = 9.0
		units = 'ppb'
	       END	

	'CO2': BEGIN
		fix_ymin = -0.3
		fix_ymax = 0.4 
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
t_unit = (a_time EQ 1) ? 'Analysis Date' : 'Sample Date'  ; if set /a_time, plotting verses analysis date
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

	ytitle = 'Flask - Assigned!C   ' + gasdata.units   
	XYOUTS, x_out, y_out, ytitle, COLOR = pen(1), /NORMAL, $
		CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 90	


; loop through results from each inst and plot and write summary info
FOR i=0,ninst-1 DO BEGIN
	time = (a_time EQ 1) ? wrkdata.(i).adate : wrkdata.(i).date

	j = WHERE(wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) ; index of valid data
	
; 	write statistics on tst results - assigned values for all valid inst[i] 
	title= STRUPCASE(sp) + ' (' + units + ')      ALL FLASKS:  [' + $
		STRUPCASE(inst_id[i]) + ' MINUS ASSIGNED]'

	SPECIAL_TST_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = wrkdata.(i)[j].value - wrkdata.(i)[j].tg, $
		time_set = wrkdata.(i)[j].date, $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		testgas = testgas, $
		default = default



	k = WHERE(wrkdata.(i).anum EQ 1 AND wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) ; index of valid 1st analysis
	l = WHERE(wrkdata.(i).anum NE 1 AND wrkdata.(i).value - 1 GT default AND wrkdata.(i).tg - 1 GT default) ; indes of valid other analysis

	; plot data from 1st analysis of the flask and write summary of 1st analysis results
	IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
	IF k[0] NE -1 THEN BEGIN 
		first_results = wrkdata.(i)[k].value - wrkdata.(i)[k].tg
		clipped_results = ClipOnYRange(first_results)
		CCG_SYMBOL, sym = sym_arr[i], fill = 1, THICK = symthick
		OPLOT, time[k], clipped_results, PSYM = 8, COLOR = pen(col_arr[i]), SYMSIZE = symsize, /NOCLIP
	ENDIF

	; write statistics on tst results - assigned values for first analysis of flask on inst[i] 
	title= STRUPCASE(sp) + ' (' + units + ')      FIRST ANALYSIS OF FLASK:  [' + $
			STRUPCASE(inst_id[i]) + ' MINUS ASSIGNED]'

	SPECIAL_TST_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = wrkdata.(i)[k].value - wrkdata.(i)[k].tg, $
		time_set = wrkdata.(i)[k].date, $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		testgas = testgas, $
		default = default




	; plot data from other analysis of the flask 
	IF N_ELEMENTS(l) EQ 1 THEN l = [l,l]
	IF l[0] NE -1 THEN BEGIN
		other_results = wrkdata.(i)[l].value - wrkdata.(i)[l].tg
		clipped_results = ClipOnYRange(other_results)
		CCG_SYMBOL, sym = sym_arr[i], fill = 0, THICK = symthick
		OPLOT, time[l], clipped_results, PSYM = 8, COLOR = pen(col_arr[i]), SYMSIZE = symsize, /NOCLIP
	ENDIF

	; write statistics on tst results - assigned values for other analysis of flask on inst[i] 
	title= STRUPCASE(sp) + ' (' + units + ')      OTHER ANALYSIS OF FLASK:  [' + $
			STRUPCASE(inst_id[i]) +  ' MINUS ASSIGNED]'

	SPECIAL_TST_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = wrkdata.(i)[l].value - wrkdata.(i)[l].tg, $
		time_set = wrkdata.(i)[l].date, $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		testgas = testgas, $
		default = default



ENDFOR


;  Plot vertical lines when test gas cylinder changed
ncylinders = N_ELEMENTS(testgas.start_date)
plot_range = !X.CRANGE
FOR i=0, ncylinders-1 DO BEGIN
	IF testgas(i).start_date LE plot_range(0) OR testgas(i).start_date GE plot_range(1) THEN CONTINUE
	x = [testgas(i).start_date, testgas(i).start_date]
	y = [-10000.0, 10000.0]
	OPLOT, x, y, COLOR = pen(1), THICK = linethick
ENDFOR


;  Plot line at y=0 
plot_range = !X.CRANGE
ndiv = 500
div = (plot_range(1) - plot_range(0)) / ndiv
x = FINDGEN(ndiv) * div + plot_range(0)
y = x * 0.0
OPLOT, x, y, COLOR = pen(1), THICK = linethick


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
		x_leg = 0.23
		y_leg = 0.485
		x_out = 0.225
		y_out = 0.125

	; plot legend
	CCG_SLEGEND, x = x_leg, y = y_leg, tarr = tarr, $
		sarr = sarr, carr = carr, CHARSIZE = leg_charsize, CHARTHICK = charthick, THICK = symthick
	XYOUTS, x_out, y_out, 'Filled symbols indicate 1st analysis of flask', $
			/NORMAL, COLOR = pen[1], CHARSIZE = leg_charsize - 0.2, CHARTHICK = thin_charthick
	
ENDIF

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;

CCG_CLOSEDEV, dev = dev, saveas = saveas

; update win so get all plots asked for on screen
win = win + 1

END
; end PLOT_NORM_TST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	PROCEDURE TO PRODUCE COMMON FLASK AND PFP STATISTICS
;		ON PASSED DATASET
;		avg of whole date range and monthly avgerages
;		of inst - inst data
PRO	COMMON_FLASK_PFP_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = data_set, $
		time_set = time_set, $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		default = default


	; format start and end date to look right in table
	tmp = DateDB(date)
	str_date_range = tmp[0] + ' --> ' + tmp[1]		

	; Print Header info
	PRINTF, fp,' '
	PRINTF, fp ,' ****************************************************************'
	PRINTF, fp, " NOAA Instrument Comparison, "+ STRUPCASE(project) + ':  ' +STRUPCASE(site)
;	PRINTF, fp, " " + STRUPCASE(site)  
	PRINTF, fp,''
	PRINTF, fp,' PROCESS DATE   ' + today.s0
	PRINTF, fp,''
	PRINTF, fp, " " + title 
	PRINTF, fp,''
	PRINTF, fp,''
	
	fmt ="(A26,A12,A12,A10)"
	header = ["MONTH", "MEAN", "STDEV", "#"]
	PRINTF, fp,  FORMAT = fmt, header

	; First calculate avg and stddev for whole dataset passed
	k = WHERE(data_set -1 GT default)
	IF k[0] EQ -1 THEN BEGIN
		avg = default
		std = default
		number = 0

	ENDIF ELSE BEGIN  
		avg = CCG_MEAN(data_set[k])
		std = STDDEV(data_set[k])
		number = N_ELEMENTS(data_set[k])
		
	ENDELSE

	; print whole data set stats
	fmt ="(A26,F12.3,F12.3,I10)"
	PRINTF, fp, FORMAT = fmt, str_date_range, avg, std, number 	
	PRINTF, fp, ' '


	; get list of months, start month - end month+1
	list = Month_List(date)
	
	; Loop through each month and get averages for that month and print	
	nmonth = N_ELEMENTS(list)
	FOR i = nmonth-2, 0, -1  DO BEGIN

		sm = StartDate(list[i])  ; start month string
		sm_dec = LongDate2Dec(sm) ; start month dec
		
		em = StartDate(list[i+1])   ; end month string
		em_dec = LongDate2Dec(em) ; end month dec

		; get index of samples within the month (sm - em)
		k = WHERE(time_set GE sm_dec AND time_set LT em_dec AND $
				data_set -1 GT default)

		; avg and stddev of data for the month, if none then assing default
		IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
		IF k[0] EQ -1 THEN BEGIN
	                avg = default
	                std = default
	                number = 0 

	        ENDIF ELSE BEGIN
	                avg = CCG_MEAN(data_set[k])
	                std = STDDEV(data_set[k])
	                number = N_ELEMENTS(data_set[k])

	        ENDELSE
	
		; write to summary file
        	list_output =  STRMID(list[i], 0, 4) + '-' + STRMID(list[i], 4, 2)
		PRINTF, fp, FORMAT = fmt, list_output, avg, std, number


	ENDFOR	
	PRINTF, fp ,' ****************************************************************'
	PRINTF, fp, ' '
	PRINTF, fp, ' '
	PRINTF, fp,' '


END
;
; 	END common_flask_pfp_stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure to plot difference between each inst and the 1st inst
;  listed.  for each unique event number
PRO	PLOT_INST_MINUS_INST1, $
		site = site, $
		sp = sp, $
		date = date, $
		dev = dev, $
		default = default, $
		ninst = ninst, $
		testgas = testgas, $
		wrkdata = wrkdata, $
        	a_time = a_time, $
		sym_arr = sym_arr, $
		col_arr = col_arr, $
		win = win, $
		save = save, $
		ddir = ddir, $
		today = today, $
		project = project, $
		nolabid = nolabid, $
        	noproid = noproid, $
		gasdata = gasdata, $

	        presentation= presentation, $ 
		fp = fp, $ 
		legend = legend, $
		xmin = xmin, $
		xmax = xmax, $
		nofix = nofix, $
                charsize= charsize, $
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


	;set filename for saving plot (ex. tst_inst-inst1_ch4.ps  )
file_extension = (dev EQ 'psc') ? 'ps' : dev
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(site) + '_inst-inst1_' $
		+ STRLOWCASE(sp) + '.' + file_extension 


CCG_OPENDEV, dev = dev, pen = pen, win = win, portrait = 1, saveas = saveas

!P.MULTI = [0,1,2]  ; creating multi panel plot

; get valid inst id's for plot labels
inst_id = TAG_NAMES(wrkdata)

;
; Call procedure plot_mixing_ratios to create top panel of plot
; 
PLOT_MIXING_RATIOS, $
        site = site, $
        date = date, $
        sp = sp, $
        inst = inst, $
        dev = dev, $
        wrkdata = wrkdata, $
        a_time = a_time, $
        ninst = ninst, $
        testgas = testgas, $
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





;  Normalize results for each sample to the result from inst1


nevn = N_ELEMENTS(wrkdata.(0).evn) ; number of evn numbers in inst1 wrkdata structure
delta = DINDGEN(ninst-1,nevn) * 0.0 ; multidimensional array for differences (inst(n) - inst(0))
				    ;  one column for each inst normalized to first instrument	
time = DINDGEN(ninst-1,nevn) * 0.0  ; time correlating to differences array

FOR i = 1, ninst -1 DO BEGIN

	cnt = i + 1
	;  Loop through each evn number in inst1 wrkdata stucture, find matches in 
	;  inst(i) wrkdata structure. 
	FOR ii=0,nevn-1 DO BEGIN
		k=WHERE(wrkdata.(i).evn EQ wrkdata.(0)[ii].evn) 
		; If the sample was not run on the instrument then 
		; 	assign default values
		IF k[0] EQ -1 THEN BEGIN
			avg_values = default
			min_adate = default
		ENDIF ELSE BEGIN
		;  If the sample was run assign average value of all runs
		; 	and 1st adate 
			avg_values = CCG_MEAN(wrkdata.(i)[k].value)	
			min_adate = MIN(wrkdata.(i)[k].adate)
		ENDELSE
	; Put avg_values and min_adate into delta and time arrays	
	delta[i-1,ii] =  (avg_values-1 LE default) ? default : avg_values - wrkdata.(0)[ii].value
	time[i-1,ii] = wrkdata.(0)[ii].date
	
	ENDFOR	
	
ENDFOR




;; find the max difference to set y scale for auto scaling (/nofix)
k=WHERE(delta - 1 GT default AND time - 1 GT default) 
max_diff = MAX(ABS(delta[k]))

; Set y scale range based on fixed range for each gas
; 	and set units for summary table
CASE STRUPCASE(sp) OF
	'N2O': BEGIN
		fix_ymin = -3.0
		fix_ymax = 3.5
		units = 'ppb'
	       END	

	'SF6': BEGIN
		fix_ymin = -0.30
		fix_ymax = 0.45 
		units = 'ppt'
	       END	

	'CO': BEGIN
		fix_ymin = -10.0
		fix_ymax = 15.0
		units = 'ppb'
	       END	

	'H2': BEGIN
		fix_ymin = -30.0
		fix_ymax = 50.0
		units = 'ppb'
	       END	

	'CH4': BEGIN
		fix_ymin = -7.0
		fix_ymax = 9.0
		units = 'ppb'
	       END	

	'CO2': BEGIN
		fix_ymin = -0.3
		fix_ymax = 0.4 
		units = 'ppm'
	       END	

ENDCASE

;  Set y range
IF KEYWORD_SET(nofix) THEN BEGIN
	ymin = max_diff*(-1.0) 
	ymax = max_diff
ENDIF ELSE BEGIN
	ymin = fix_ymin
	ymax = fix_ymax	
ENDELSE


; print avg and std dev for whole date range and for each month
;  	for each inst minus inst(0)
FOR i = 0, ninst-2 DO BEGIN 

	title= STRUPCASE(sp) + ' (' + units + ')      ALL FLASKS:  [' + STRUPCASE(inst_id[i+1]) + $
			 ' MINUS ' + STRUPCASE(inst_id[0]) + ']'

	COMMON_FLASK_PFP_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = delta[i,*], $
		time_set = time[i,*], $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		default = default

ENDFOR


; initialize plot
t1 = gasdata.title+' results from each instrument normalized to '+inst_id[0]
t_unit = 'Sample Date'

PLOT,time,delta,/NODATA,COLOR=pen(1),$
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
		y_out = 0.20

	ytitle = 'Instrument Difference!C     ' + gasdata.units
	XYOUTS, x_out, y_out, ytitle, COLOR = pen(1), /NORMAL, $
		CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 90	


;  plot delta values for each instrument
;  	Loop through delta columns (each column represents an instrument)
FOR i = 0, ninst-2 DO BEGIN
	
	; plot with filled symbols, flasks run first on inst(i) 
	k = WHERE(delta[i,*] -1 GT default AND wrkdata.(0).anum EQ 1) ; index of valid samples run first on inst(0)
	IF N_ELEMENTS(k) EQ 1 THEN k = [k,k]
	IF k[0] EQ -1 THEN CONTINUE
	clipped_results = ClipOnYRange(delta[i,k])
	CCG_SYMBOL, sym = sym_arr[i+1], fill = 1, THICK = symthick
	OPLOT, time[i,k], clipped_results, PSYM = 8, COLOR = pen[col_arr[i+1]], SYMSIZE = symsize, /NOCLIP
	
	; produce summary table of flask results run first on inst(i)
	title= STRUPCASE(sp) + ' (' + units + ')      FLASKS RUN FIRST ON ' + STRUPCASE(inst_id[i+1]) + $
			 ':  [' + STRUPCASE(inst_id[i+1]) + ' MINUS ' + STRUPCASE(inst_id[0]) + ']'

	COMMON_FLASK_PFP_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = delta[i,k], $
		time_set = time[i,k], $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		default = default


	; plot with open symbols, flasks run first on inst(0) 
	IF N_ELEMENTS(l) EQ 1 THEN l = [l,l]
	k=WHERE(delta[i,*] -1 GT default AND wrkdata.(0).anum GT 1) ; index of valid samples run first on inst(n)
	IF k[0] EQ -1 THEN CONTINUE
	clipped_results = ClipOnYRange(delta[i,k])
	CCG_SYMBOL, sym = sym_arr[i+1], fill = 0, THICK = symthick 
	OPLOT, time[i,k], clipped_results, PSYM = 8, COLOR = pen[col_arr[i+1]], SYMSIZE = symsize, /NOCLIP

	; produce summary table of flask results run first on inst(i)
	title= STRUPCASE(sp) + ' (' + units + ')      FLASKS RUN FIRST ON ' + STRUPCASE(inst_id[0]) + $
			 ':  [' + STRUPCASE(inst_id[i+1]) + ' MINUS ' + STRUPCASE(inst_id[0]) + ']'

	COMMON_FLASK_PFP_STATS, $
		fp = fp, $ 
		date = date, $
		data_set = delta[i,k], $
		time_set = time[i,k], $
		today = today, $
		project = project, $
		gasdata = gasdata, $
		site = site, $
		title = title, $
		default = default

ENDFOR


;  Plot line at y=0 
plot_range = !X.CRANGE
ndiv = 500
div = (plot_range(1) - plot_range(0)) / ndiv
x = FINDGEN(ndiv) * div + plot_range(0)
y = x * 0.0
OPLOT, x, y, COLOR = pen(1), THICK = linethick



; create legend
IF KEYWORD_SET(legend) THEN BEGIN ; only create legend if specified
	inst_id = TAG_NAMES(wrkdata)
	tarr = STRARR(ninst-1)
	sarr = FINDGEN(ninst-1)
	carr = FINDGEN(ninst-1)
	farr = FINDGEN(ninst-1)
	FOR i=0,ninst -2 DO BEGIN
		tarr[i] = inst_id[i+1]+' minus '+inst_id[0]	
		sarr[i] = sym_arr[i+1]
		carr[i] = col_arr[i+1]

	ENDFOR

	; set location for legend and XYOUTS
	;    positioned for bottom panel of two panel plot
		x_leg = 0.23
		y_leg = 0.485
		x_out = 0.225
		y_out = 0.125
	
	CCG_SLEGEND,x = x_leg, y = y_leg, tarr = tarr, sarr = sarr, $
			carr = carr, CHARSIZE = leg_charsize, CHARTHICK = charthick, THICK = symthick
	t = 'Filled symbols indicate 1st analysis on ' + inst_id[0]
	XYOUTS, x_out, y_out, t, $
		/NORMAL, COLOR = pen[1], CHARSIZE = leg_charsize - 0.2, CHARTHICK = thin_charthick

ENDIF

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;


CCG_CLOSEDEV, dev = dev, saveas = saveas
		
; update win so get all plots asked for on screen
win = win + 1

END
;end PLOT_INST_MINUS_INST1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Procedure to use CCGVU to fit a curve to the data from each 
;	instrument
;
PRO     CCG_ICP_CCGVU, $
                site = site, $
                date = date, $
                sp = sp, $
                inst = inst, $
                wrkdata = wrkdata, $
		a_time = a_time, $
                ninst = ninst, $
		testgas = testgas, $
                sym_arr = sym_arr, $
                col_arr = col_arr, $
                default = default, $
                gasdata = gasdata, $
		save = save, $
		win = win, $
		ddir = ddir, $
                nolabid = nolabid, $
                noproid = noproid, $
                dev = dev, $

	        presentation = presentation, $ 
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


	;set filename for saving plot (ex. tst_ccgvu_ch4.ps  )
file_extension = (dev EQ 'psc') ? 'ps' : dev
IF KEYWORD_SET(save) THEN saveas = ddir + STRLOWCASE(site) + '_ccgvu_' $
		+ STRLOWCASE(sp) + '.' + file_extension

CCG_OPENDEV, dev = dev, pen = pen, win = win, portrait = 1, saveas = saveas

!P.MULTI = [0,1,2]  ; creating multi panel plot

; get valid inst id's for plot labels
inst_id = TAG_NAMES(wrkdata)

;
; Call procedure plot_mixing_ratios to create top panel of plot
; 
PLOT_MIXING_RATIOS, $
        site = site, $
        date = date, $
        sp = sp, $
        inst = inst, $
        dev = dev, $
        wrkdata = wrkdata, $
        a_time = a_time, $
        ninst = ninst, $
        testgas = testgas, $
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





; find the min and max values of all wrkdata structures to set y scale
;  and prodeuce time array for the x axis
;  this keeps the plot from scaling off of other instruments that would be included
;       in the data structure but would not be in the wrkdata structures since they were
;       not specified in the call
FOR i=0,ninst-1 DO BEGIN
        tmp = wrkdata.(i).value
        data = (i EQ 0) ? [tmp] : [data, tmp]
        tmp_time =  wrkdata.(i).date
        time = (i EQ 0) ? [tmp_time] : [time, tmp_time]
ENDFOR

; expand the y axis from the min and max for each gas to keep plots looking good and keep
;	legend readable.  Legend in top left corner of plot so expand ymax more than ymin
CASE STRUPCASE(sp) OF
        'N2O': BEGIN
                expand_ymin = 0.995
                expand_ymax = 1.02
		units = 'ppb'
               END

        'SF6': BEGIN
                expand_ymin = 0.99
                expand_ymax = 1.05
		units = 'ppt'
               END

        'CO': BEGIN
                expand_ymin = 0.95
                expand_ymax = 1.10
		units = 'ppb'
               END

        'H2': BEGIN
                expand_ymin = 0.95
                expand_ymax = 1.15
		units = 'ppb'
               END

        'CH4': BEGIN
                expand_ymin = 0.995 
                expand_ymax = 1.02
		units = 'ppb'
               END

        'CO2': BEGIN
                expand_ymin = 0.999
                expand_ymax = 1.003
		units = 'ppm'
               END
ENDCASE

ymin = MIN(data) * expand_ymin
ymax = MAX(data) * expand_ymax




;  Setup bottom panel plot
t1 = site+', '+gasdata.title
t_unit =  'Sample Date'
PLOT, time, data, /NODATA, COLOR=pen(1), $
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
		y_out = 0.20

	ytitle =  gasdata.title   
	XYOUTS, x_out, y_out, ytitle, COLOR = pen(1), /NORMAL, $
		CHARSIZE = charsize, CHARTHICK = charthick, ORIENTATION = 90	



; loop through results form each inst and use CCGVU to fit a function and smoothed curve
;       to each inst results.  Plot each instrument function or smoothed curve.  Use
;       default values for CCGVU parameters
FOR i=0,ninst-1 DO BEGIN

        time =  wrkdata.(i).date

        ; Fit inst results using CCGVU
        CCG_CCGVU, x = wrkdata.(i).date, y = wrkdata.(i).value, $
                        ftn = ftn, residf = residf, sc = sc, residsc = residsc

        CCG_SYMBOL, sym = sym_arr[i], fill = 1
        ;OPLOT,ftn[0,*],ftn[1,*],PSYM=8,COLOR=pen(col_arr[i])
        OPLOT, ftn[0,*], ftn[1,*], COLOR = pen(col_arr[i]), THICK = linethick
        ;OPLOT,sc[0,*],sc[1,*],PSYM=8,COLOR=pen(col_arr[i])


ENDFOR

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
	;    positioned for bottom panel of two panel plot
		x_leg = 0.23
		y_leg = 0.485
		x_out = 0.225
		y_out = 0.430
	
	CCG_SLEGEND,x = x_leg, y = y_leg, tarr = tarr, sarr = sarr, $
			carr = carr, CHARSIZE = leg_charsize, CHARTHICK = charthick, THICK = symthick
;	t = ' ' 
;	XYOUTS, x_out, y_out, t, $
;		/NORMAL, COLOR = pen[1], CHARSIZE = leg_charsize - 0.2, CHARTHICK = thin_charthick

ENDIF

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;

CCG_CLOSEDEV, dev=dev, saveas = saveas

; update win so get all plots asked for on screen
win = win + 1

END
;end CCG_ICP_CCGVU
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Start main procedure
;
PRO	CCG_MAGICC_ICP,$
	project 	= project, $
	strategy 	= strategy, $	
	site 		= site,$
        sp 		= sp,$
        inst 		= inst,$
        date 		= date,$
        help 		= help,$
        dev 		= dev, $
	a_time 		= a_time, $
	mixing_ratio 	= mixing_ratio, $
	norm_tst 	= norm_tst, $
	norm_inst1 	= norm_inst1, $
	win 		= win, $
	ccgvu 		= ccgvu, $
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

col_arr = [11,12,4,13,6,3]
sym_arr = [1,2,3,4,5,6]


IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(win) THEN win = 0
IF KEYWORD_SET(save) AND NOT KEYWORD_SET(dev) THEN dev = 'psc'
IF NOT KEYWORD_SET(dev) THEN dev = ''
IF NOT KEYWORD_SET(ddir) THEN ddir = GETENV("HOME")+'/'
IF NOT KEYWORD_SET(strategy) THEN strategy = ''
IF NOT KEYWORD_SET(project) THEN project = ''
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(inst) THEN CCG_SHOWDOC
inst = STRSPLIT(STRUPCASE(inst),',',/EXTRACT,COUNT=ninst)
IF NOT KEYWORD_SET(a_time) THEN a_time=0

; set case of variables used in case or if statements
dev = STRLOWCASE(dev)
sp = STRUPCASE(sp)
site = STRUPCASE(site)
;

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




; call test_gas.pro to read test gas calibration tables for TST flasks
IF site EQ 'TST' THEN TEST_GAS, sp = sp, testgas = testgas

; Extract data from DB
CCG_FLASK, strategy = strategy, project = project, site = site, $
		sp = sp, date = date, /ret, tmpdata

; Insert new tag into data structure, called anum, holds the analysis
;	number for the flask.  Ex, 1 for first run of the flask, 2 for
;	second run of flask etc.
FOR i = 0, N_ELEMENTS(tmpdata) - 1 DO BEGIN
	; run function to determine analysis number
	num = ANALYSIS_NUMBER( default, tmpdata, tmpdata[i].evn, tmpdata[i].adate)
	
	IF site EQ 'TST' THEN BEGIN
		; run function to get the test gas value based on fill date
		tg_value = TESTGAS_VALUE_BY_DATE( tmpdata[i].date, testgas, default)

	ENDIF ELSE BEGIN
		; if not site = TST, assign ' ' to tg_value
		tg_value = ' ' 

	ENDELSE


	tmp = CREATE_STRUCT(tmpdata[i], 'anum', num, 'tg', tg_value)
	data = (i EQ 0) ? [tmp] : [data, tmp] 	
ENDFOR	

; Construct pointers to instrument-specific data
; End up with a structure containing a structure for each instrument
FOR i=0,ninst-1 DO BEGIN
        j = WHERE(data.inst EQ inst[i])

        IF j[0] EQ -1 THEN CONTINUE

        wrkdata = (i EQ 0) ? CREATE_STRUCT(inst[i],data[j]) : CREATE_STRUCT(wrkdata,inst[i],data[j])
ENDFOR

; Determine the number of valid instruments from the input list for this time period
ninst = N_TAGS(wrkdata)


; Create list of all unique EVN numbers in the data retrived from CCG_FLASK
;	unq_evn = array of unique EVN numbers
evn=data.evn[*]
unq_evn=evn(UNIQ(evn,SORT(evn)))


;  Set output for summary text.  Either screen or file
summary_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
IF KEYWORD_SET(save) THEN OPENW, fp, summary_filename, /GET_LUN ELSE fp = -1



; plot mixing ratios
IF KEYWORD_SET(mixing_ratio) THEN PLOT_MIXING_RATIOS, $
	site = site, $
	date = date, $
	sp = sp, $
	inst = inst, $
	dev = dev, $
	wrkdata = wrkdata, $
	a_time = a_time, $
	ninst = ninst, $
	testgas = testgas, $
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



IF KEYWORD_SET(norm_tst) THEN PLOT_NORM_TST, $
	dev = dev, $
	wrkdata = wrkdata, $
	a_time = a_time, $
	site = site, $
	date = date, $
	sp = sp, $
	inst = inst, $
	ninst = ninst, $
	testgas = testgas, $
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


;  Plot difference between inst(i) and inst(0) for each evn number
IF KEYWORD_SET(norm_inst1) THEN	PLOT_INST_MINUS_INST1	,$
		site = site, $
		sp = sp, $
		date = date, $
		dev = dev, $
		default = default, $
		ninst = ninst, $
		testgas = testgas, $
		wrkdata = wrkdata, $
        	a_time = a_time, $
		sym_arr = sym_arr, $
		col_arr = col_arr, $
		win = win, $
		gasdata = gasdata, $
		save = save, $
		ddir = ddir, $
		today = today, $
		project = project, $
		nolabid = nolabid, $
        	noproid = noproid, $

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
IF KEYWORD_SET(save) THEN SAVE_WRKDATA_FILES, $
		wrkdata = wrkdata, $
		ddir = ddir, $
		site = site, $
		ninst = ninst, $
		sp = sp

IF KEYWORD_SET(save) THEN SAVE_EVN_FILE, $
		wrkdata = wrkdata, $
		data = data, $
		inst = inst, $
		ddir = ddir, $
		site = site, $
		ninst = ninst, $
		sp = sp, $
		unq_evn = unq_evn, $
		default = default

; If keyword "ccgvu" set then use CCGVU to fit a curve to each instrument's data 
IF KEYWORD_SET(ccgvu) THEN CCG_ICP_CCGVU, $
                site = site, $
                date = date, $
                sp = sp, $
                inst = inst, $
                wrkdata = wrkdata, $
		a_time = a_time, $
                ninst = ninst, $
		testgas = testgas, $
                sym_arr = sym_arr, $
                col_arr = col_arr, $
                default = default, $
                gasdata = gasdata, $
                dev = dev, $
		save = save, $
		ddir = ddir, $
		win = win, $
		nolabid = nolabid, $
        	noproid = noproid, $

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


	

IF KEYWORD_SET(save) THEN FREE_LUN, fp

END



