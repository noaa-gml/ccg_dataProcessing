PRO	CCG_MAGICC_ICP_WEB_DRIVER, $
		dev = dev

;  Procedure to run ccg_icp idl script to produce plots for the ccg_icp
;	intercomparison web site

	today	= CCG_SYSDATE()
	five_yr_startdate = LONG(today.s1) - 50000
   	d = '/ccg/web/icp/noaa/magicc/' 
   	;d = '/home/ccg/crotwell/idl/ccg_icp/test_web/' 

	IF NOT KEYWORD_SET(dev) THEN dev = 'psc'
	dev = STRLOWCASE(dev)
	file_ext = (dev EQ 'psc') ? 'ps' : dev

;;;;;;  Setup instrument lists for each gas  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	co2_inst = 'L8,L10,L3,S2,L4'
;	ch4_inst = 'H11,H6,H4'
;	n2o_inst = 'H4,H6'
;	sf6_inst = 'H4,H6'
;	co_inst  = 'V3,V4,V2,R5,R6'
;	h2_inst  = 'H11,H8,R5,R6'
;	co2c13_inst = 'o1,i2'
;	co2o18_inst = 'o1,i2'
;	ch4c13_inst = 'i1'

	inst_list = CREATE_STRUCT('co2', 'L8,L10,L3,S2,L4', $
	'ch4', 'H11,H6,H4', $
	'n2o', 'H4,H6', $
	'sf6', 'H4,H6', $
	'co',  'V3,V4,V2,R5,R6', $
	'h2',  'H11,H8,R5,R6', $
	'co2c13', 'o1,i2', $
	'co2o18', 'o1,i2', $
	'ch4c13', 'i1')

;	co2_current_inst = 'L8,L10'
;	ch4_current_inst = 'H11,H6'
;	n2o_current_inst = 'H4,H6'
;	sf6_current_inst = 'H4,H6'
;	co_current_inst  = 'V3,V4'
;	h2_current_inst  = 'H11,H8'
	
	current_inst = CREATE_STRUCT('co2', 'L8,L10', $
	'ch4', 'H11,H6', $
	'n2o', 'H4,H6', $
	'sf6', 'H4,H6', $
	'co',  'V3,V4', $
	'h2',  'H11,H8')

;;;;;  List Target tanks to use ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
all_target_tanks = ['CC71583', 'CC1824', 'CA05579', 'CC303036', 'CB08834', 'ALMX067998']
current_target_tanks = ['CC303036', 'CB08834', 'ALMX067998']
current_target_startdate = ['20100401','20111020','20160212']



;;;;;  Species ;;;;;;;;;;;;;;;;;;;;;;;;;;
all_species = ['CO2','CH4','CO','H2','N2O','SF6','CO2C13','CO2O18','CH4C13']


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for test flask intercomparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	project = 'ccg_surface'
	strategy = 'flask'
	site = 'tst'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(site) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Test flask results normalized to assigned values 
;					12 month zoom and 5 year record
;   				2) Test flask results inst(n) normalized to inst(0)
;   				3) Save the data used to make the plots in text files

	sp_arr = TAG_NAMES(inst_list)
	FOR i = 0, N_ELEMENTS(sp_arr) - 1 DO BEGIN
		sp = sp_arr[i]
		inst = inst_list.(i)

		PRINT,'----  ', project, '  ', strategy, '  ', site, '  ', sp

		IF STRUPCASE(sp) NE 'CO2C13' AND STRUPCASE(sp) NE 'CO2O18' AND STRUPCASE(sp) NE 'CH4C13' THEN BEGIN
				; 12 month plot of test flask results inst(n) normalized to inst(0)
			CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
				inst = inst, /norm_inst1, ddir = ddir, dev = dev, $
				/save, /nolabid, /noproid, /presentation

			; save copy of summary file so isn't overwritten on next calls to procedure
			sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
			tmp_filename = ddir + 'temp_summary.txt'
			cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
			SPAWN, cmd
		ENDIF

			; 12 month zoom of norm_tst
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_tst, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation
	 
			; rename ps file to "zoom12" ps file 
		cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
			ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
		SPAWN, cmd 

			; 5 yr record of norm_tst
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_tst, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		IF STRUPCASE(sp) NE 'CO2C13' AND STRUPCASE(sp) NE 'CO2O18' AND STRUPCASE(sp) NE 'CH4C13' THEN BEGIN
			; combine tmp summary file with current summary file
			cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
			SPAWN, cmd
		ENDIF

	ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calls for test pfp intercomparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	project = 'ccg_surface'
	strategy = 'pfp'
	site = 'tst'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(site) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Test flask results normalized to assigned values 
;					12 month zoom and 5 year record
;   				2) Test flask results inst(n) normalized to inst(0)
;   				3) Save the data used to make the plots in text files
	sp_arr = TAG_NAMES(inst_list)
	FOR i = 0, N_ELEMENTS(sp_arr) - 1 DO BEGIN
		sp = sp_arr[i]
		inst = inst_list.(i)

		PRINT,'----  ', project, '  ', strategy, '  ', site, '  ', sp

		IF STRUPCASE(sp) NE 'CO2C13' AND STRUPCASE(sp) NE 'CO2O18' AND STRUPCASE(sp) NE 'CH4C13' THEN BEGIN
				; 12 month plot of test flask results inst(n) normalized to inst(0)
			CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
				inst = inst, /norm_inst1, ddir = ddir, dev = dev, $
				/save, /nolabid, /noproid, /presentation

			; save copy of summary file so isn't overwritten on next calls to procedure
			sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
			tmp_filename = ddir + 'temp_summary.txt'
			cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
			SPAWN, cmd
		ENDIF

			; 12 month zoom of norm_tst
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_tst, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation
	 
			; rename ps file to "zoom12" ps file 
		cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
			ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
		SPAWN, cmd 

			; 5 yr record of norm_tst
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_tst, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		IF STRUPCASE(sp) NE 'CO2C13' AND STRUPCASE(sp) NE 'CO2O18' AND STRUPCASE(sp) NE 'CH4C13' THEN BEGIN
			; combine tmp summary file with current summary file
			cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
			SPAWN, cmd
		ENDIF
	ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; calls for KUM flask intercomparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	project = 'ccg_surface'
	strategy = 'flask'
	site = 'kum'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(site) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	 
;   				1) Test flask results inst(n) normalized to inst(0)
;					12 month zoom and 5 year record
;   				2) Save the data used to make the plots in text files
	sp_arr = TAG_NAMES(inst_list)
	FOR i = 0, N_ELEMENTS(sp_arr) - 1 DO BEGIN
		sp = sp_arr[i]

		PRINT,'----  ', project, '  ', strategy, '  ', site, '  ', sp

		IF STRUPCASE(sp) EQ 'CO2C13' OR STRUPCASE(sp) EQ 'CO2O18' OR STRUPCASE(sp) EQ 'CH4C13' THEN CONTINUE

		inst = inst_list.(i)

			; 12 month plot of KUM flask results inst(n) normalized to inst(0)
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_inst1, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation
	 
			; rename ps file to "zoom12" ps file 
		cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
			ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
		SPAWN, cmd 

			; 5 yr record of KUM flask results inst(n) normalized to inst(0)
		CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
			inst = inst, /norm_inst1, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

	ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for current target tank intercomparisons, 
;current_target_tanks = ['CC303036', 'CB08834', 'ALMX067998']
;current_target_startdate = ['20100401','20111020','20160212']
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	strategy = 'cals'

; Types of plots requested: 	1) Target tank calibration results normalized to assigned values 
;					past 12 months (zoom12) and full target tank record
;   				2) Save the data used to make the plots in text files

FOR itank = 0, N_ELEMENTS(current_target_tanks) - 1 DO BEGIN	
	id = current_target_tanks[itank]
	tank_startdate = current_target_startdate[itank]

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'
        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

	sp_arr = TAG_NAMES(inst_list)
	FOR i = 0, N_ELEMENTS(sp_arr) - 1 DO BEGIN
		sp = sp_arr[i]

		PRINT,'----  ', strategy, '  ', id, '  ', sp

		IF STRUPCASE(sp) EQ 'CO2C13' OR STRUPCASE(sp) EQ 'CO2O18' OR STRUPCASE(sp) EQ 'CH4C13' THEN CONTINUE

		inst = inst_list.(i)

		; zoom 12, (past 12 months)
		CCG_MAGICC_TANK_ICP, id = id, sp = sp , $
			inst = inst, /norm_target, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, std_changes = 1
		; rename ps file to "zoom12" ps file 
		cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
			ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
		SPAWN, cmd 

		; full record
		CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
			inst = inst, /norm_target, ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]

	ENDFOR

ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for composite target tank comparisons
;all_target_tanks = ['CC71583', 'CC1824', 'CA05579', 'CC303036', 'CB08834', 'ALMX067998']
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'composite'
	system_list = ['magicc1','magicc2']

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Target tank composite normalized to assigned values 
;				   on each system (Magicc_1 and Magicc_2)
;					ambient short term target tanks only
;					all target tanks (including long term target tanks) past month
;					all target tanks, full record since 2005
;   				2) Save the data used to make the plots in text files

FOR isys = 0, N_ELEMENTS(system_list) - 1 DO BEGIN

	system = system_list[0]

	sp_arr = TAG_NAMES(inst_list)
	FOR i = 0, N_ELEMENTS(sp_arr) - 1 DO BEGIN
		sp = sp_arr[i]
		PRINT,'----  ', strategy, '  ', id, '  ', system, '  ', sp

		IF STRUPCASE(sp) EQ 'CO2C13' OR STRUPCASE(sp) EQ 'CO2O18' OR STRUPCASE(sp) EQ 'CH4C13' THEN CONTINUE

		; composite target tank plot, ambient target tanks
		TEST_ALL_TARGET_ICP, id = all_target_tanks, sp = sp, system = system, $
			date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation

	       ; rename plot file to "ambient" file
		cmd = 'mv ' + ddir + 'composite_' + STRLOWCASE(system) + '_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		      ddir + 'composite_' + STRLOWCASE(system) + '-ambient_' + STRLOWCASE(sp) + '.' + file_ext 
		SPAWN, cmd

		; composite target tank plot, all target tanks
		TEST_ALL_TARGET_ICP, sp = sp, system = system, $
			date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
			/save, /nolabid, /noproid, /presentation, /nofix

	ENDFOR
ENDFOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


END
