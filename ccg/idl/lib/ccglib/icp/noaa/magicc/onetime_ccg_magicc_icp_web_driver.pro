PRO	ONETIME_CCG_MAGICC_ICP_WEB_DRIVER, $
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
	co2_inst = 'L8,L10,L3,S2,L4'
	ch4_inst = 'H11,H6,H4'
	n2o_inst = 'H4,H6'
	sf6_inst = 'H4,H6'
	co_inst  = 'R5,V2,R6'
	h2_inst  = 'H11,H8,R5,R6'

	co2_current_inst = 'L8,L10'
	ch4_current_inst = 'H11,H6'
	n2o_current_inst = 'H4,H6'
	sf6_current_inst = 'H4,H6'
	co_current_inst  = 'R5,V2'
	h2_current_inst  = 'H11,H8'
	

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
	; CH4
	sp = 'CH4'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd



;	; N2O
	sp = 'N2O'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; SF6
	sp = 'SF6'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; CO
	sp = 'CO'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; H2
	sp = 'H2'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; CO2
	sp = 'CO2'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) +'.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd



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
	; CH4
	sp = 'CH4'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd


;	; N2O
	sp = 'N2O'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; SF6
	sp = 'SF6'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; CO
	sp = 'CO'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; H2
	sp = 'H2'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;	; CO2
	sp = 'CO2'
		; 12 month plot of test flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation

		; save copy of summary file so isn't overwritten on next calls to procedure
	sum_filename = ddir + STRLOWCASE(site) + '_summary_' + STRLOWCASE(sp) + '.txt'
	tmp_filename = ddir + 'temp_summary.txt'
	cmd = 'cp ' + sum_filename + ' ' + tmp_filename 
	SPAWN, cmd

		; 12 month zoom of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_normtst_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_normtst_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of norm_tst
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_tst, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

		; combine tmp summary file with current summary file
	cmd = 'cat ' + tmp_filename + ' >> ' + sum_filename
	SPAWN, cmd

;
;
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
	; CH4
	sp = 'CH4'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = ch4_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]


;	; N2O
	sp = 'N2O'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = n2o_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

 
;	; SF6
	sp = 'SF6'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = sf6_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

;
;	; CO
	sp = 'CO'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

;
;	; H2
	sp = 'H2'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = h2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]

;
;	; CO2
	sp = 'CO2'
		; 12 month plot of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation
 
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(site) + '_inst-inst1_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(site) + '_inst-inst1_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; 5 yr record of KUM flask results inst(n) normalized to inst(0)
	CCG_MAGICC_FLASK_ICP, project = project, strategy = strategy, site = site, sp = sp, $
		inst = co2_inst, /norm_inst1, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [five_yr_startdate, today.s1]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for target tank intercomparisons, Tank id CA05579
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'CA05579'
	tank_startdate = '20080501'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Target tank calibration results normalized to assigned values 
;					past 12 months (zoom12) and full target tank record
;   				2) Save the data used to make the plots in text files

	; CH4
	sp = 'CH4'
		; zoom 12, (past 12 months)
	CCG_MAGICC_TANK_ICP, id = id, sp = sp , $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; N2O
	sp = 'N2O'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; SF6
	sp = 'SF6'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; CO
	sp = 'CO'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; H2
	sp = 'H2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, date = [tank_startdate, today.s1]



	; CO2
	sp =  'CO2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for target tank intercomparisons, Tank id CC303036
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'CC303036'
	tank_startdate = '20100401'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Target tank calibration results normalized to assigned values 
;					past 12 months (zoom12) and full target tank record
;   				2) Save the data used to make the plots in text files

	; CH4
	sp = 'CH4'
		; zoom 12, (past 12 months)
	CCG_MAGICC_TANK_ICP, id = id, sp = sp , $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; N2O
	sp = 'N2O'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; SF6
	sp = 'SF6'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; CO
	sp = 'CO'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]



	; H2
	sp = 'H2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, date = [tank_startdate, today.s1]



	; CO2
	sp =  'CO2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, today.s1]






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for composite target tank comparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'composite'

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

;PRO     TEST_ALL_TARGET_ICP, $
;        id = id, $
;        sp = sp, $
;        system = system, $
;        date = date, $
;        nofix = nofix, $
;        save            = save, $
;        ddir            = ddir, $
;        nolabid         = nolabid, $
;        noproid         = noproid, $
;        presentation = presentation, $
;        win = win, $
;        dev = dev

; MAGICC_1
	system = 'magicc_1'
	ambient = ['cc71583','cc1824','ca05579','cc303036']

        ; CH4
        sp = 'CH4'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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


        ; N2O
        sp = 'N2O'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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



        ; SF6
        sp = 'SF6'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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

        ; CO 
        sp = 'CO' 
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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

        ; H2 
        sp = 'H2' 
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
                date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
                /save, /nolabid, /noproid, /presentation, /nofix

               ; rename plot file to "ambient" file
        cmd = 'mv ' + ddir + 'composite_' + STRLOWCASE(system) + '_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
              ddir + 'composite_' + STRLOWCASE(system) + '-ambient_' + STRLOWCASE(sp) + '.' + file_ext 
        SPAWN, cmd

                ; composite target tank plot, all target tanks
        TEST_ALL_TARGET_ICP, sp = sp, system = system, $
                date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
                /save, /nolabid, /noproid, /presentation, /nofix

        ; CO2
        sp = 'CO2'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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

; MAGICC_2
	system = 'magicc_2'
	ambient = ['cc71583','cc1824','ca05579','cc303036']

        ; CH4
        sp = 'CH4'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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


        ; N2O
        sp = 'N2O'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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



        ; SF6
        sp = 'SF6'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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

        ; CO 
        sp = 'CO' 
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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

        ; H2 
        sp = 'H2' 
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
                date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
                /save, /nolabid, /noproid, /presentation, /nofix

               ; rename plot file to "ambient" file
        cmd = 'mv ' + ddir + 'composite_' + STRLOWCASE(system) + '_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
              ddir + 'composite_' + STRLOWCASE(system) + '-ambient_' + STRLOWCASE(sp) + '.' + file_ext 
        SPAWN, cmd

                ; composite target tank plot, all target tanks
        TEST_ALL_TARGET_ICP, sp = sp, system = system, $
                date = [2005, LONG(today.s1)], ddir = ddir, dev = dev, $
                /save, /nolabid, /noproid, /presentation, /nofix

        ; CO2
        sp = 'CO2'
                ; composite target tank plot, ambient target tanks
        TEST_ALL_TARGET_ICP, id = ambient, sp = sp, system = system, $
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








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for target tank intercomparisons, Tank id CA05579
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'CC1824'
	tank_startdate = '20060701'
	tank_stopdate = '20110131'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Target tank calibration results normalized to assigned values 
;					past 12 months (zoom12) and full target tank record
;   				2) Save the data used to make the plots in text files

	; CH4
	sp = 'CH4'
		; zoom 12, (past 12 months)
	CCG_MAGICC_TANK_ICP, id = id, sp = sp , $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; N2O
	sp = 'N2O'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; SF6
	sp = 'SF6'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; CO
	sp = 'CO'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; H2
	sp = 'H2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, date = [tank_startdate, tank_stopdate]



	; CO2
	sp =  'CO2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; calls for target tank intercomparisons, Tank id CC303036
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	strategy = 'cals'
	id = 'CC71583'
	tank_startdate = '20030519'
	tank_stopdate = '20101231'

        ; directory path for saving files for web site
        ddir = d + STRLOWCASE(strategy) + '/' + STRLOWCASE(id) +'/' + today.s4 + '/'

        FILE_MKDIR, ddir
	FILE_CHMOD, ddir, '775'o

; Types of plots requested: 	1) Target tank calibration results normalized to assigned values 
;					past 12 months (zoom12) and full target tank record
;   				2) Save the data used to make the plots in text files

	; CH4
	sp = 'CH4'
		; zoom 12, (past 12 months)
	CCG_MAGICC_TANK_ICP, id = id, sp = sp , $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1
		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = ch4_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; N2O
	sp = 'N2O'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = n2o_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; SF6
	sp = 'SF6'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = sf6_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; CO
	sp = 'CO'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]



	; H2
	sp = 'H2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = h2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, /nofix, date = [tank_startdate, tank_stopdate]



	; CO2
	sp =  'CO2'
		; zoom 12
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, std_changes = 1

		; rename ps file to "zoom12" ps file 
	cmd = 'mv ' + ddir + STRLOWCASE(id) + '_norm_' + STRLOWCASE(sp) + '.' + file_ext + ' ' + $
		ddir + STRLOWCASE(id) + '_norm_zoom12_' + STRLOWCASE(sp) + '.' + file_ext
	SPAWN, cmd 

		; full record
	CCG_MAGICC_TANK_ICP, id = id, sp = sp, $
		inst = co2_inst, /norm_target, ddir = ddir, dev = dev, $
		/save, /nolabid, /noproid, /presentation, date = [tank_startdate, tank_stopdate]







END
