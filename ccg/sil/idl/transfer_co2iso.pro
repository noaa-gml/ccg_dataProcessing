
PRO TRANSFER_CO2ISO,$
file=file,thispause=thispause,gofast=gofast,secref=secref,all=all,twptcorr=twptcorr

; things to check:
;calsdir
;jrasfile
;printsitefiles
;ddir
;printtanks
;uncertainty
;twptcorr  (line 275)
;secref
;trackfile


;;; CHECK ON UNCERTAINTY. set to zero in ccg_flaskupdate



;Calls just one file at a time normally. If keyword set 'all' then will run all files ever run against DEWY
;; NOTE. Secpos flags is 0. Could add P flag back in, ignore trap flags. ..

IF NOT KEYWORD_SET(thispause) THEN thispause=1
IF NOT KEYWORD_SET(gofast) THEN gofast=0
IF NOT KEYWORD_SET(secref) THEN secref='youdecide'
IF NOT KEYWORD_SET(twptcorr) THEN twptcorr=1
IF NOT KEYWORD_SET(file) THEN all=1
IF  KEYWORD_SET(file) THEN all=0
;jrasfile='reference.lsj62.co2c13'
;jrasfile='reference.j62.co2c13' 
;jrasfile='reference.lj62.co2c13'

;jrasfile='reference.scen2.co2c13'
;jrasfile='reference.jras06.co2c13'   ; this is it. official. or so I thought
;jrasfile='ref.jras06.co2c13'   ; this is it. official. hopefully for the last time
				; fall 2020 version saved as ref.07123030.jras06.co2c13
				; now working with 2016,2019,2020 measurements of HDL compiled. 
; for testing!!
;jrasfile='reference.co2c13' 
jrasfile='ref.sieg.co2c13' ;KB: using this one and calsieg2 8/16/24
;jrasfile='ref.sieg.co2c13.062824'  ;; 5/13/21. Trying Sieg, again, to fix offset from mpi

;secref='HUEY-001'
thisupdate=1
;PRINT,'----------------------------------------------------------------'
;PRINT,'----------------------------------------------------------------'
;PRINT,'SLY doing test - please do not process data today. Hit control-c to stop'
;PRINT,'----------------------------------------------------------------'
;PRINT,'----------------------------------------------------------------'
;wait, 3

IF gofast EQ 1 THEN thispause=0
twptcorr=1
printsitefiles=0
;;;; all means run everything that has been run with DEWY as ref.
IF all EQ 0 THEN BEGIN
	print,file
	IF STRMID(file,7,2) EQ 'o1' THEN file=file ELSE file=file+'.csv'
	print, 'calling sil_raw_co2c13.pro'
		printsitefiles=1
	SIL_RAW_CO2C13, file = file, rawfile, rawinst

	print, 'calling sil_proc_co2iso.pro'
	SIL_PROC_CO2ISO, file = rawfile, thispause=thispause,inst = rawinst, update=thisupdate, $
	uncertainty=0,secposflags=0,DIAGNOSTICS=0,reprintsil=1,log_data=1,secref=secref, $
	twptcorr=twptcorr,jrasfile=jrasfile,printsitefiles=0


ENDIF ELSE BEGIN	
	
	inst=['r1','o1','i2','i6','i4']
	;insttag=['.r1','.o1','_i2.csv','_i6.csv','_i4.csv']
	ninst=N_ELEMENTS(inst)
;************************************************


;refstatarr=[$
;'refstatDESI-001.co2c13.r1',$
;'refstatFRED-001.co2c13.r1',$
;'refstatLUCY-002.co2c13.r1',$
;'refstatRIKI-001.co2c13.r1',$
;'refstatTAVI-001.co2c13.r1',$
;'refstatETHL-002.co2c13.o1',$
;'refstatNAGH-001.co2c13.o1',$
;'refstatDESI-003.co2c13.o1',$
;'refstatNAGH-002.co2c13.o1',$
;'refstatDESI-004.co2c13.o1',$
;'refstatBRUN-003.co2c13.o1',$
;'refstatFRED-002.co2c13.o1',$
;'refstatDESI-005.co2c13.o1',$
;'refstatNAGH-003.co2c13.o1',$
;'refstatBIGG-001.co2c13.o1',$
;'refstatHERM-001.co2c13.o1',$
;'refstatODIN-002.co2c13.o1',$
;'refstatCARR-002.co2c13.o1',$
;'refstatNAGH-004.co2c13.o1',$
;'refstatBRUN-004.co2c13.i4',$ 
;'refstatGEOR-001.co2c13.i2',$
;'refstatELAI-001.co2c13.i2',$
;'refstatJERR-001.co2c13.i2',$
;'refstatCALV-001.co2c13.i2'] ;,$
;'refstatCARR-001.co2c13.i2',$
;'refstatHAGR-001.co2c13.i2',$
;'refstatDUMB-001.co2c13.i2',$
;'refstatCALV-002.co2c13.i2',$
;'refstatODIN-003.co2c13.i2',$
;'refstatJELL-003.co2c13.i6',$
;'refstatBRUN-005.co2c13.i6',$
;'refstatCHIC-002.co2c13.i6',$
;'refstatHERM-002.co2c13.i4',$
;'refstatCALV-003.co2c13.i2',$
;'refstatOLVR-002.co2c13.i6',$
;'refstatDEWY-001.co2c13.o1',$  
;'refstatDEWY-001.co2c13.i6',$  
;'refstatDEWY-001.co2c13.i2',$  
;'refstatDEWY-001.co2c13.i4']  


;need to rerun CALV-001 from 220

;nreffiles=N_ELEMENTS(refstatarr)


FOR i=0,0 DO BEGIN   ; inst not in use.


	FOR n=0,nreffiles-1 DO BEGIN
		
		IF n EQ 0 THEN f=0 ELSE f=0   ; if sarting mid ref
		;IF n EQ 0 THEN f=167 ELSE f=0   ; if sarting mid ref
		
		refstatfile='/projects/co2c13/calsieg2/internal_cyl/'+refstatarr[n]
		
		inst=strmid(refstatarr[n],23,2)
		
		IF inst EQ 'o1' THEN insttag= '.o1'
		IF inst EQ 'i2' THEN insttag= '_i2.csv'
		IF inst EQ 'i6' THEN insttag= '_i6.csv'
		IF inst EQ 'i4' THEN insttag= '_i4.csv'
		IF inst EQ 'r1' THEN insttag= '.r1'
		
		CCG_READ,file=refstatfile,dewy
		uruns=UNIQ(dewy.field5)  
		dewy=dewy[uruns]             
		ndewy=N_ELEMENTS(dewy)
	
	;******************************************************************************
		
		
		FOR j=f,ndewy-1 DO BEGIN  ;ndewy-1 DO BEGIN	
		
		print,refstatfile
		print,j,' of ',ndewy, ' files'
		run=STRCOMPRESS(STRING(dewy[j].field5),/REMOVE_ALL)

			IF STRLEN (run) LE 1 THEN run='00000' + run
			IF STRLEN (run) LE 2 THEN run='0000' + run
			IF STRLEN (run) LE 3 THEN run='000' + run
			IF STRLEN (run) LE 4 THEN run='00' + run
		
			runfile=run+insttag
			print,runfile
			
			IF inst[i] EQ 'r1' THEN runfilepath='/projects/co2c13/flask/r1/transfer/'+runfile 
			IF inst[i] EQ 'o1' THEN runfilepath='/projects/co2c13/flask/o1/transfer/'+runfile 
			IF inst[i] EQ 'i2' THEN runfilepath='/projects/co2c13/flask/i2/transfer/csv_files/'+runfile 
			IF inst[i] EQ 'i4' THEN runfilepath='/projects/co2c13/flask/i4/transfer/csv_files/'+runfile 
			IF inst[i] EQ 'i6' THEN runfilepath='/projects/co2c13/flask/i6/transfer/csv_files/'+runfile 
			
			runfileexist = FILE_TEST(runfilepath)
			IF runfileexist EQ 1 THEN BEGIN
				;print, 'calling sil_raw_co2iso.pro'

				SIL_RAW_CO2C13, file = runfile, rawfile, rawinst

				print, 'calling sil_proc_co2iso.pro'
				SIL_PROC_CO2ISO, file = rawfile, thispause=0,inst = rawinst, update=thisupdate, $
				uncertainty=1,secposflags=0,DIAGNOSTICS=0,reprintsil=0,log_data=0,secref=secref,$
				twptcorr=twptcorr,jrasfile=jrasfile,printsitefiles=printsitefiles
		
				;print, 'calling sil_proc_co2c13.pro'
				;SIL_PROC_CO2C13, file = rawfile, thispause=0,inst = rawinst, update=thisupdate, $
				;uncertainty=1,secposflags=1,DIAGNOSTICS=0,reprintsil=0,log_data=0,$
				;printsitefiles=printsitefiles,flagall=0
				
				goto,nextfor
		
			ENDIF ELSE BEGIN
			;*******************
			ayrst=STRCOMPRESS(STRING(dewy[j].field7),/REMOVE_ALL)
				amost=STRCOMPRESS(STRING(dewy[j].field8),/REMOVE_ALL)
				IF STRLEN(amost) LT 2 THEN amost='0'+amost
				adyst=STRCOMPRESS(STRING(dewy[j].field9),/REMOVE_ALL);
				IF STRLEN(adyst) LT 2 THEN adyst='0'+adyst
				rawmaybe=ayrst+'-'+amost+'-'+adyst
				
				lookdir='/projects/co2c13/flask/'+inst[i]+'/raw/'+ayrst+'/'
				CCG_DIRLIST, dir=lookdir,/omitdir,looklist
				ourfile=WHERE(STRMID(looklist,0,10) EQ rawmaybe,nours)
	
				IF ourfile[0] NE -1 THEN BEGIN
					FOR f=0,nours-1 DO BEGIN
		
					print,'yes rawmaybe = ',rawmaybe
				
					CCG_SREAD,file=lookdir+looklist[ourfile[f]], $
						/NOMESSAGES,evnlookstr
			
					foundit=WHERE(STRMID(evnlookstr[0],2,6) EQ run)	
	
						IF foundit[0] NE -1 THEN BEGIN	
						; found the rawfile
						rawfile=looklist[ourfile[f]]
						GOTO,runtherawfile			
						ENDIF 
					ENDFOR
			
					GOTO, tryagainplease
		
				ENDIF ELSE BEGIN
					print,'not rawmaybe'
					GOTO, tryagainplease
				ENDELSE
		
				tryagainplease:			
	
				CCG_DATE2DEC, yr=dewy[j].field7,mo=dewy[j].field8,dy=dewy[j].field9, $
					hr=dewy[j].field10,mn=dewy[j].field11,dec=daydec
					trythisday=daydec-(1.00/365.00)

					CCG_DEC2DATE,trythisday,newyr,newmo,newdy

					newayrst=STRCOMPRESS(STRING(newyr),/REMOVE_ALL)
		
					newamost=STRCOMPRESS(STRING(newmo),/REMOVE_ALL)
					IF STRLEN(newamost) LT 2 THEN newamost='0'+newamost
			
					newadyst=STRCOMPRESS(STRING(newdy),/REMOVE_ALL)
					IF STRLEN(newadyst) LT 2 THEN newadyst='0'+newadyst
			
					newrawmaybe=newayrst+'-'+newamost+'-'+newadyst
			
					lookdir='/projects/co2c13/flask/'+inst[i]+'/raw/'+ayrst+'/'
					CCG_DIRLIST, dir=lookdir,/omitdir,looklist
					ourfile=WHERE(STRMID(looklist,0,10) EQ newrawmaybe,nours)
					IF ourfile[0] NE -1 THEN BEGIN					
						FOR g=0,nours-1 DO BEGIN
			
						print,'newrawmaybe = ',newrawmaybe
					
						CCG_SREAD,file=lookdir+looklist[ourfile[g]], $
							/NOMESSAGES,evnlookstr
				
						foundit=WHERE(STRMID(evnlookstr[0],2,6) EQ run)	
			
							IF foundit[0] NE -1 THEN BEGIN
								rawfile=looklist[ourfile[g]]
								GOTO,runtherawfile			
							
							ENDIF ELSE BEGIN
								;GOTO, tryonemoretimeplease	
							ENDELSE		
						ENDFOR
					ENDIF ELSE BEGIN
						print,'not newrawmaybe'
						GOTO,tryonemoretimeplease
					ENDELSE
			
				tryonemoretimeplease:
	
				;look for day after analysis date - would be caused by using 2nd or 3rd set refs as first		

				CCG_DATE2DEC, yr=dewy[j].field7,mo=dewy[j].field8,dy=dewy[j].field9, $
					hr=dewy[j].field10,mn=dewy[j].field11,dec=daydec
					cloogeadate=daydec+(1.00/365.00)
					CCG_DEC2DATE,cloogeadate,cnewyr,cnewmo,cnewdy
	
					cnewayrst=STRCOMPRESS(STRING(cnewyr),/REMOVE_ALL)
			
					cnewamost=STRCOMPRESS(STRING(cnewmo),/REMOVE_ALL)
					IF STRLEN(cnewamost) LT 2 THEN cnewamost='0'+cnewamost
			
					cnewadyst=STRCOMPRESS(STRING(cnewdy),/REMOVE_ALL)
					IF STRLEN(cnewadyst) LT 2 THEN cnewadyst='0'+cnewadyst
			
					cnewrawmaybe=cnewayrst+'-'+cnewamost+'-'+cnewadyst
				
					lookdir='/projects/co2c13/flask/'+inst[i]+'/raw/'+ayrst+'/'
					CCG_DIRLIST, dir=lookdir,/omitdir,looklist
					ourfile=WHERE(STRMID(looklist,0,10) EQ cnewrawmaybe,nours)	
					
					IF ourfile[0] NE -1 THEN BEGIN
						FOR s=0,nours-1 DO BEGIN
						print,'cnewrawmaybe = ', cnewrawmaybe
					
							CCG_SREAD,file=lookdir+looklist[ourfile[s]], $
							/NOMESSAGES,evnlookstr
	
							foundit=WHERE(STRMID(evnlookstr[0],2,6) EQ run)		
		
							IF foundit[0] NE -1 THEN BEGIN
								rawfile=looklist[ourfile[s]]
								GOTO,runtherawfile			
							
							ENDIF ELSE BEGIN
								GOTO,skipthisone
							ENDELSE
						ENDFOR
				
					ENDIF ELSE BEGIN
						PRINT,'cannot find this data. .. skipping'
						GOTO,skipthisone
								
					ENDELSE
					
			
			ENDELSE
			runtherawfile:
			print, 'calling sil_proc_co2iso.pro'
			print, 'inst= ',inst[i]
			print, 'run = ',run
			print, 'rawfile = ',rawfile
				
				SIL_PROC_CO2ISO, file = rawfile, thispause=0,inst = inst[i], update=thisupdate, $
				uncertainty=1,secposflags=0,DIAGNOSTICS=0,reprintsil=0,log_data=0,secref=secref,$
				twptcorr=twptcorr,jrasfile=jrasfile,printsitefiles=printsitefiles
		
			skipthisone:
		
			
			;********************
			nextfor:
			today=systime()
			trackformat='(I4,1X,I4,1X,A25,1X,A25, 1X, A20, 1x, A30)'		 
				trackfile='/home/ccg/sil/tempfiles/'+jrasfile+'.102424.txt'
				OPENU, u, trackfile, /APPEND, /GET_LUN
				PRINTF, u, FORMAT=trackformat, j,ndewy,today,jrasfile,runfile, refstatfile
				FREE_LUN, u	 
		ENDFOR  ;files

	ENDFOR  ;file
ENDFOR  ;inst
ENDELSE


;email_string = 'bash /home/ccg/sil/idl/email.sh'+' '+ stryear +' '+ string(mo) +' '+ string(day)
 ;       spawn, email_string



;DEWY!
	;refstatfile='refstatDEWY-001.co2c13'+'.'+inst[i]
	
       ;refstatfile='refstatBIGG-001.co2c13'+'.o1'
       ;refstatarr=['refstatODIN-002.co2c13.o1','refstatNAGH-003.co2c13.o1','refstatHERM-001.co2c13.o1']
	;refstatarr=['refstatDESI-005.co2c13.o1','refstatDESI-004.co2c13.o1','refstatBRUN-003.co2c13.o1']
	;refstatarr=['refstatNAGH-002.co2c13.o1','refstatETHL-002.co2c13.o1','refstatDESI-003.co2c13.o1']
	;refstatfile='refstatCARR-002.co2c13.o1'
	;refstatarr=['refstatDESI-004.co2c13.o1','refstatBRUN-003.co2c13.o1','refstatCARR-002.co2c13.o1','refstatNAGH-004.co2c13.o1']
	;refstatarr=['refstatJELL-003.co2c13.i6','refstatBRUN-005.co2c13.i6']
	;refstatfile='refstatHERM-001.co2c13.o1'
	;refstatfile='refstatCHIC-002.co2c13.i6'
	;refstatfile='refstatNAGH-004.co2c13.o1'
	;refstatfile='refstatJELL-003.co2c13.i6'
	;refstatfile='refstatBRUN-005.co2c13.i6'
	;refstatfile='refstatCALV-003.co2c13.i2'
	;refstatfile='refstatCHIC-002.co2c13.i6'
	;refstatfile='refstatODIN-003.co2c13.i2'
	
; DESI-001 r1 1990  1 26 1990  6 21   1990.0685   1990.4685    -7.840    -7.872    -7.325    -7.341    -7.354     0.032     0.042     0.016     0.010    -0.000    -0.000    -0.005     0.006     0.136
;  FRED-001 r1 1990  6 22 1993  9  6   1990.4712   1993.6795    -8.180    -8.188    -7.656    -7.672    -7.667     0.008     0.022    -0.380    -0.478    -0.397    -0.396    -0.494     0.098     0.027
;  LUCY-002 r1 1993  9  7 1994 12 20   1993.6822   1994.9671    -7.738    -7.741    -7.284    -7.295    -7.288     0.003     0.018    -1.555    -1.604    -1.570    -1.569    -1.618     0.049     0.026
;  RIKI-001 r1 1994 12 22 1996  3 14   1994.9726   1996.1995    -7.757    -7.761    -7.266    -7.280    -7.270     0.004     0.018    -0.515    -0.557    -0.531    -0.530    -0.572     0.042     0.022
;  TAVI-001 r1 1996  3 14 1997  5 14   1996.1995   1997.3644    -7.974    -7.998    -7.489    -7.502    -7.513     0.024     0.018    -1.100    -1.161    -1.116    -1.115    -1.176     0.061     0.021

;refstatarr=['refstatDESI-001.co2c13',$
;'refstatFRED-001.co2c13',$
;'refstatLUCY-002.co2c13',$
;'refstatRIKI-001.co2c13',$
;'refstatTAVI-001.co2c13']

;refstatarr=['refstatNAGH-001.co2c13', $
;'refstatFRED-002.co2c13',
;'refstatETHL-002.co2c13',
;'refstatDESI-003.co2c13',
;'refstatNAGH-002.co2c13',
;'refstatDESI-004.co2c13',
;'refstatBRUN-003.co2c13',
;'refstatDESI-005.co2c13',
;'refstatNAGH-003.co2c13',
;'refstatBIGG-001.co2c13',
;'refstatHERM-001.co2c13',
;'refstatODIN-002.co2c13',
;'refstatCARR-002.co2c13',
;'refstatNAGH-004.co2c13']

	
END
