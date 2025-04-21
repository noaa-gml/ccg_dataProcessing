;+
;test_all_target_icp.pro
;
;-

@ccg_utils
@ccg_graphics
@ccg_magicc_icp_utils.pro



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROCEDURE TO WRITE DATA TO FILE FOR ARCHIVING
;	SAVE_TANK_DATA_FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	SAVE_TARGET_TANK_DATA_FILE, $
		data	= data, $
		ddir 	= ddir, $
		system = system, $
		first = first, $
		sp 	= sp

; Write target tank data to a text file for archiving.  One
; file for each system.
; Filenames are ddir/composite-target_"system"_"gas".txt   
; Ex.  composite-target_magicc1_ch4.txt

	nvalues = N_ELEMENTS(data)

	; create file and write 1 line header info.  
	;			
	filename = ddir + 'composite-target_' + system + $
			 '_' +STRLOWCASE(sp) + '.txt'

	format = '(A12, A8, A5, A12, A12, A8, A12, A12)'
	header = ["ID","GAS","INST","ADATE","VALUE","FLAG","ASSIGNED","SYSTEM"]


	; if first time procedure called then open new file and print header 
	; else open file to append data
	IF KEYWORD_SET(first) THEN BEGIN
		OPENW, fp1, filename, /GET_LUN
		PRINTF, fp1, FORMAT = format, header
	ENDIF ELSE OPENW, fp1, filename, /APPEND, /GET_LUN

	first = 0

	FOR j = 0, nvalues - 1 DO BEGIN
		; write values and assigned_values to file "id"_"gas"_"inst".txt
		PRINTF, fp1, FORMAT = '(A12, A8, A5, F12.5, F12.3, A8, F12.3, A12)', $

		data[j].id, data[j].parameter, data[j].inst,  data[j].dd, $
		data[j].value,  data[j].flag, data[j].tg, data[j].system
	ENDFOR

	FREE_LUN, fp1

	PRINT,'data saved as ', filename 

END
; End SAVE_WRKDATA_FILES  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to find "system" from analysis date,
; sp, and inst code.
FUNCTION	DETERMINE_SYSTEM, $
		inst = inst, $
		sp = sp, $
		analysis_date = analysis_date, $
		system_file_structure = system_file_structure		

	system = 'none'
	v = WHERE( STRUPCASE(system_file_structure.field1) EQ STRUPCASE(inst) AND $
			STRLOWCASE(system_file_structure.field2) EQ STRLOWCASE(sp) AND $
			system_file_structure.field3 LE analysis_date AND $
			system_file_structure.field4 GE analysis_date)

	IF v[0] NE -1 THEN system = system_file_structure[v].field5  

	RETURN, system

END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start main procedure   TEST_ALL_TARGET_ICP
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO	TEST_ALL_TARGET_ICP, $
	id = id, $
	sp = sp, $
	system = system, $
	date = date, $
	nofix = nofix, $
	save            = save, $
        ddir            = ddir, $
        nolabid         = nolabid, $
        noproid         = noproid, $
	presentation = presentation, $
	win = win, $
	dev = dev


;
; Misc initialization
;
today = CCG_SYSDATE()
default = -999.999
first = 1

col_arr = [11,12,4,13,6,11,12,4,13,6,11,12,4,13,6,11,12,4,13,6,11,12,4,13,6,11,12,4,13,6,11,12,4,13,6]
sym_arr = [1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9]

;;;;;;;;;;
; Setup plotting keywords
IF KEYWORD_SET (presentation) THEN BEGIN
        ; plot settings for psc files
                presentation    = 1
                charsize        = 1.4
                leg_charsize    = 1.3
                charthick       = 3.5
                thin_charthick  = 2.0
                symsize         = 1.2
                symthick        = 5.0
                linethick       = 3.5
                axis_thick      = 5.0
                gridstyle       = 0
                ticklen         = -0.02
                xpixels         = 800
                ypixels         = 600

ENDIF ELSE BEGIN
        ; plot settings for screen
                presentation    = 0
                charsize        = 1.4
                leg_charsize    = 1.2
                charthick       = 1.0
                thin_charthick  = 1.0
                symsize         = 1.0
                symthick        = 1.0
                linethick       = 1.0
                axis_thick      = 1.0
                gridstyle       = 0
                ticklen         = -0.02
                xpixels         = 800
                ypixels         = 600

ENDELSE
;;;;;;;;;





IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(system) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(win) THEN win = 0
IF KEYWORD_SET(save) AND NOT KEYWORD_SET(dev) THEN dev = 'psc'
IF NOT KEYWORD_SET(dev) THEN dev = ''
IF NOT KEYWORD_SET(ddir) THEN ddir = GETENV("HOME")+'/'
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(std_changes) THEN std_changes = 0

; set case of variables used in case or if statements
dev = STRLOWCASE(dev)
sp = STRUPCASE(sp)
CCG_GASINFO, sp = sp, gasdata


; format "system" keyword
CASE STRLOWCASE(system) OF
	'magicc_1' : system = 'magicc1'
	'magicc1'  : system = 'magicc1'
	'magicc_2' : system = 'magicc2'
	'magicc2'  : system = 'magicc2'
	'cal'	   : system = 'cal'
	'cals'     : system = 'cal'
ELSE: CCG_FATALERR, 'Passed System ' + system + ' not valid'

ENDCASE


  ; Initialize data attribute array and
   ; the plot attribute array

   plot_attr_arr = 0
   np = 0

   data_attr_arr = 0
   nd = 0



; set species dependent variables
CASE sp OF
	'CO2': BEGIN
		ymin = -0.2
		ymax = 0.3		
		END	

	'CH4':  BEGIN
		ymin = -5.0
		ymax = 5.0		

		END

	'CO':  BEGIN
		ymin = -10.0
		ymax = 10.0		

		END

	'H2':  BEGIN
		ymin = -20.0
		ymax = 60.0		

		END

	'N2O':  BEGIN
		ymin = -1.0
		ymax = 1.0		

		END

	'SF6':  BEGIN
		ymin = -0.2
		ymax = 0.3		

		END
ELSE: CCG_FATALERR, 'species ' + sp + ' not valid'

ENDCASE



; format date range passed
;if no date passed, use today's date and process current month 
IF NOT KEYWORD_SET(date) THEN date = LONG(STRMID(today.s1, 0, 6))    
ndate = N_ELEMENTS(date)
IF ndate EQ 1 THEN date = [LONG(date), LONG(date)]
startdate = DateObject(date = date[0])
enddate = DateObject(date = date[1], /ed)


; use SetTScustom to set xcustom for the given date range
ts_daterange = [startdate.dd, enddate.dd]
xcustom = SetTScustom( ts_daterange )
xcustom = STRLOWCASE(xcustom)


; make dummy data attributes array to prevent crashes if no data


; Read instrument codes file to allow data to be sorted by system
fn = '/home/ccg/crotwell/idl/ccg_icp/system_instrument_codes'
CCG_READ, file = fn, skip = 1, inst_codes


; read in target tank lookup table
CYLINDER_VALUES, sp = sp, $
	filename = '/ccg/' + STRLOWCASE(sp) + '/cals/magicc_target.tab', $
	cyln_values = cyln_values

; decide if should use all target tanks or a passed subset
IF KEYWORD_SET(id) THEN id = STRUPCASE(id) ELSE id = STRUPCASE(cyln_values.tank)

; Loop through each target tank
FOR itank = 0, N_ELEMENTS(id) - 1 DO BEGIN
	; initialize "data"
	data = ''

	; extract data from database for current target tank id
	str_date = startdate.DBdate + ',' + enddate.DBdate
	CCG_CAL,  id = id[itank], sp = sp, date = str_date, tmpdata

	; test returned values, if no data returned then continue with next tank
	IF (SIZE( tmpdata, /TYPE) NE 8) THEN CONTINUE

	; remove flagged results
	j = WHERE(tmpdata.flag EQ '.')
	IF (j[0] EQ -1) THEN CONTINUE
	tmpdata = tmpdata[j]

	; Loop through each result for current target tank id
	FOR i = 0, N_ELEMENTS(tmpdata) - 1  DO BEGIN

		; determine "system"
		a = DateObject(dd = tmpdata[i].dd)
		analysis_system = DETERMINE_SYSTEM( inst = tmpdata[i].inst, $
                	sp = tmpdata[i].parameter, $
                	analysis_date = a.longdate, $
                	system_file_structure = inst_codes )


		; determine assigned value at analysis time
		j = WHERE( cyln_values.tank EQ id[itank]) 

		IF j[0] EQ -1 THEN BEGIN
			tg_value = default
		ENDIF ELSE BEGIN
			tmp_cyln_values = cyln_values[j]
	                tg_value = CYLINDER_VALUES_BY_DATE( tmpdata[i].dd, tmp_cyln_values, default)
		ENDELSE


		; add new tag names to tmpdata structure for assigned value and system
		tmp = CREATE_STRUCT(tmpdata[i], 'tg', tg_value, 'system', analysis_system)
                data = (SIZE(data, /TYPE) NE 8) ? [tmp] : [data, tmp]

	ENDFOR ; end loop through each result for current target tank id


	; only keep data for the specified system
	j = WHERE( STRLOWCASE(data.system) EQ STRLOWCASE(system))
	IF j[0] EQ -1 THEN CONTINUE  ; if no data for system then continue with next tank
	data = data[j]

	; Save the data for archive
	IF KEYWORD_SET(save) THEN SAVE_TARGET_TANK_DATA_FILE, $
		data = data, $
		system = system, $
		first = first, $
		ddir = ddir, $
		sp = sp


	; make a data attributes array for current target tank (itank) 
	; make label for legend
	s_label = id[itank] + '  ' + ToString( STRING( FORMAT = '(F12.1)', $
		CCG_ROUND( data[0].tg, -1)))
	
	; normalized results vs time
	j = WHERE(data.value-1 GT default AND data.tg-1 GT default)
	IF N_ELEMENTS(j) EQ 1 THEN j = [j,j]
	IF j[0] EQ -1 THEN CONTINUE
        x = data[j].dd
        y = data[j].value - data[j].tg
        d = DATA_ATTRIBUTES(x, y, $
		YUNC = data[j].sd, $
                LINESTYLE = -1, $
                LABEL = s_label , $
                CHARTHICK = charthick, $
                CHARSIZE = leg_charsize, $
                SYMSTYLE = sym_arr[itank], $
                SYMCOLOR = col_arr[itank], $
		SYMFILL = 1, $
                LINETHICK = linethick, $
                SYMSIZE = symsize, $
                SYMTHICK = symthick)

        z = 'd' + ToString(nd++)
        data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : CREATE_STRUCT(z, d)



ENDFOR  ; End loop through each target tank	




; make data attribute array to plot line at 0
	        x = [startdate.dd, enddate.dd]
	        y = [0, 0]
	        d = DATA_ATTRIBUTES(x, y, $
	                LINESTYLE = 0, $
	                LINETHICK = linethick, $
			LINECOLOR = 1 )
	
	        z = 'd' + ToString(nd++)
	        data_attr_arr = SIZE(data_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(data_attr_arr, z, d) : $
					CREATE_STRUCT(z, d)

; make plot attributes array for normalized results vs time
	; set y axis range
	IF NOT KEYWORD_SET(nofix) THEN yaxis = [ymin, ymax, 0, -1] ELSE $
			yaxis = ''

        p = PLOT_ATTRIBUTES(data = data_attr_arr, $
		POSITION = [0.20, 0.15, 0.95, 0.95], $
                TITLE = STRUPCASE(system) + ' Target Tanks', $
                XAXIS = [startdate.dd, enddate.dd, 0, 0], $
                YAXIS = yaxis, $
                PLOTTHICK = axis_thick,$
                CHARSIZE = charsize, $
                CHARTHICK = charthick, $
                ;XTITLE = xtitle, $
                YTITLE = 'Measured - Assigned!c' + gasdata.title, $
                XCUSTOM= xcustom, $
                SLEGEND = 'TL')

        z = 'p' + ToString(np++)
        plot_attr_arr = SIZE(plot_attr_arr, /TYPE) EQ 8 ? CREATE_STRUCT(plot_attr_arr, z, p) : CREATE_STRUCT(z, p)






; submit to Graphics routine
; set filename for saving plot (ex.  cc71583_ch4.ps)
	file_extension = (dev EQ 'psc') ? 'ps' : dev
	IF KEYWORD_SET(save) THEN saveas = ddir + 'composite_' + STRLOWCASE(system) + $
                          '_' + STRLOWCASE(sp) + '.' + file_extension $
		ELSE saveas = ''

   	CCG_GRAPHICS, graphics = plot_attr_arr, dev = dev, $
                window = win, notimestamp = notimestamp, $
		portrait = 0, saveas = saveas, xpixels = xpixels, $
		ypixels = ypixels




END
