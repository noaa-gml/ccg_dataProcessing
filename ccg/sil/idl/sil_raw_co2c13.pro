;;
; NAME: sil_raw_co2c13.pro		 
;
; PURPOSE:  		
;	Creates raw files from Spock, TPol, Picard, or even Kirk (CO2C13) from .o1 or .csv files
; (from MS)
;	
;	GENERAL OUTLINE:
;		1) Read a mass spec file from the transfer directory
;			( eg.  /projects/co2c13/flask/o1/transfer )
;		2) Parse mass spec file into a 'rawfile' format
 ;		3) Write raw file	
 ;	
 ; CATEGORY:
 ;	Data maintainance
 ;	
 ; CALLING SEQUENCE:  	
 ;	Can be executed from the command line or evoked from Ken's SQL web-world.
 ;	Typically runs are 'crunched' by calling transfer_co2c13.pro, file = 'xxxx'
 ;	which calls sil_raw_co2c13 (this code here) to make a raw file. 
 ;	Then it calls sil_proc_co2c13.pro to do the heavy lifting.
 ;	sil_proc_co2c13.pro then calls sil_diag_co2c13.pro to do the plots & diagnostic.
 ;	The diagnositic program updates files which can be viewed with a Ghost script Viewer
 ;	on a PC in the lab (via ssh file transfer). s
 ;	
 ; INPUTS:		
 ;	file : mass spec file name in comma delimited format in the s
 ;		form of XXXXXX.o1 (for SPOCK) or XXXXXX.i2 (for T'POL) or 
 ;		XXXXXX.i4 (for Picard).
 ;		As of May, 2008, flasks from Kirk can also be run - these are xxxxxx.s1 files.
 ;		Kirk also runs carbs, which end up with different formatting - these will be xxxxxx.crb files.
 ;   		  The run numbers for Kirk will remain sequential: if you run 001053.crb one day and then run flasks
 ;		  the next, its run number would be 001054.r1.  
 ;		;note, s1 changed to r1 04/21/11
 ; OPTIONAL INPUT PARAMETERS:	
 ;	NONE.
 ;		 
 ; OUTPUTS:	
 ;	Text file containing all of the data from a single run
 ;
 ; COMMON BLOCKS:
 ;	None.
 ;
 ; SIDE EFFECTS:
 ;	None.
 ;
 ; RESTRICTIONS:
 ;	None that can be thought of now....however, future
 ;	applications should probably require password protection.
 ;
 ; PROCEDURE:
 ;	Example:
 ;		.
 ;		.
 ;		.
 ;		.
 ;		
 ; MODIFICATION HISTORY:
 ;	Written, BHV, November, 2003
 ;   	Updated, BHV and VAC, April, 2004
 ;	To be put into use 8/30/04 first run number 001749.o1 and 000001.i2
 ;	Updated to include T'pol, VAC February, 2005
 ;	Modified SIL code May 2006, SRE
 ;	o1 code modified May 2009 SEM to accomodate new ourfin (excel) routine,
 ;		original ourfin C program died and this was the solution.
 ;	modified 2.21.11 to add 'BOG' for bogus sample codes - so that bad data (unopened flasks, etc)
 ;        can be left in for drift correcting but not go anywhere.
 
 
 ;-----INITIALIZATION -------------------------------------------------------------------
 PRO SIL_RAW_CO2C13,  $ 
        file = file, $
 	rawfile,     $
 	rawinst
 
 	
 ; ----- IDENTIFY THE INSTRUMENT AND RUN NUMBER FOR THE INCOMING FILE ----------------------
 ; NOTE file in this case is the file name that has been transferred from one of 2 (or more)
 ; instruments.  It will take the form of:  xxxxxx.yy where xxxxxx is run number and yy is 
 ; the instrument identification 
 ;			 "o1" = Spock co2c13
 ;			 "r1" = Kirk  co2c13
 ;			 "i2" = Tpol co2c13 (PFP's)
 ;                       "i4" = Picard co2c13 (a calibration machine to run air, carbs, and water)
 ;                       "i6" = Amos
 inst = STRMID(file,7,2) 
 runum = STRMID(file,0,6)
 spec = 'co2c13'
 
 
 
 ;-----SET VERBOSE ON/OFF--------------------------------------------------------------------
 ; non zero = "on", zero = "off"
 verbose=0
 
 
 CASE inst OF
 'o1' : BEGIN
 	;----- READ FILE AND SET UP ARRAYS FOR INCOMING DATA----------------------------------------
 	transdir= '/projects/' + spec + '/flask/' + inst + '/transfer/'
 	msfile = transdir + file
 	CCG_READ, file = msfile, delimiter=',', nomessages=0, msdata

 	print, 'reading the msfile'
	nlines = N_ELEMENTS(msdata)

	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF

 	msarr=REPLICATE ({code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0},	$
 			nlines)
	

	IF FIX(runum) LE 2886 THEN BEGIN   ;************old code starts here
	
 		;-----READ FILE FROM MASS SPEC AND PARSE DATA INTO NORMAL FIELDS, COMMA DELIMITED ---------------
 		IF (verbose EQ 1) THEN PRINT,msfile,' Contains ',  nlines, ' lines'
 		FOR i = 0, nlines-1 DO BEGIN
 		CASE STRMID(msdata[i].field6,1,3) OF   ; accounts for quotation mark
 			'REF':	BEGIN
 				msarr[i].code = 'REF'
 				msarr[i].evnum = msdata[i].field7   ; ISN'T THIS THE FLASK ID!!!???? (NOT EVENT #!)
 			END ; case 'REF'
 			'STD':	BEGIN
 				msarr[i].code = 'STD'
 				msarr[i].evnum = msdata[i].field7
 			END ; case 'STD' 
 			'TRP':	BEGIN
 				msarr[i].code = 'TRP'
 				msarr[i].evnum = msdata[i].field7
 			END ; case 'TRP'
			'SRF':	BEGIN
 				msarr[i].code = 'SRF'
 				msarr[i].evnum = msdata[i].field7
 			END ; case 'TRP'
			'BOG':	BEGIN
 				msarr[i].code = 'BOG'
 				msarr[i].evnum = 99999999
 			END ; case 'TRP'
 			'SIL':	BEGIN
 				msarr[i].code = 'SIL'
					;print, 'i =', i
 				CCG_READ, file='/home/ccg/sil/silflasks/sil_eventnum.txt', $
 					delimiter=' ', /nomessages, silevnum
 				last = N_ELEMENTS(silevnum)
			
 			;	exists = WHERE(STRCOMPRESS(STRING(msdata[i].field7),/REMOVE_ALL) EQ STRCOMPRESS(STRING(silevnum.field3),/REMOVE_ALL) AND $       ; flask number
 			;		FIX(STRMID(msdata[i].field8,0,4)) EQ FIX(silevnum.field5) AND $  ; year
 			;		FIX(STRMID(msdata[i].field8,4,2)) EQ FIX(silevnum.field6) AND $  ; month
 			;		FIX(STRMID(msdata[i].field8,6,2)) EQ FIX(silevnum.field7))       ; day			
 			;				
 			;	IF exists[0] EQ -1 THEN BEGIN
			;			; *********NOTE: previous code(below) works only for SIL #'s less than 1000
			;			; sre and ajd insterted 5/24/06
 			;		num=FIX(STRMID(silevnum[last].field1,3,5))+1
			;		IF num GT 0 AND num LT 10 THEN silnum = 'SIL0000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;		IF num GT 9 AND num LT 100 THEN silnum = 'SIL000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)		
			;		IF num GT 99 AND num LT 1000 THEN silnum = 'SIL00'+STRCOMPRESS(STRING(num), /REMOVE_ALL)	
			;		IF num GT 999 AND num LT 10000 THEN silnum = 'SIL0'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;		IF num GT 9999 AND num LT 100000 THEN silnum = 'SIL'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
 			;		
			;		;previous
			;		;msarr[i].evnum = STRCOMPRESS('SIL0'+STRING((FIX(STRMID(silevnum[last].field1,3,5))+1)),/REMOVE_ALL)
 			;		;current
			;		msarr[i].evnum=silnum
			;		silco2=360.0
			;		siln2o=314.0
			;		silformat = '(A9, A4, A9, A3,1x,I5, 1X,I3,1X, I3,1X,F8.2,1X,F8.2)'
			;		;;silformat = '(A9, A4, A9, I5.1, I3.1, I3.1,F5.2,F5.2)'
 			;		;print, msarr[i].evnum
 			;		OPENU, u, '/home/ccg/isotopes/idl/prgms/proc/sil_eventnum.txt', /APPEND, /GET_LUN
 			;		PRINTF, u, FORMAT= silformat, msarr[i].evnum, 'SIL', $
 			;			STRCOMPRESS(msdata[i].field7,/REMOVE_ALL), $
 			;			FIX(STRCOMPRESS(STRMID(msdata[i].field2,12,4),/REMOVE_ALL)), $
 			;			FIX(STRCOMPRESS(STRMID(msdata[i].field2,9,2),/REMOVE_ALL)), $
 			;			FIX(STRCOMPRESS(STRMID(msdata[i].field2,7,2),/REMOVE_ALL),$
			;			silco2,siln2o)
 			;		FREE_LUN, u
 			;	ENDIF ELSE BEGIN
 			;			msarr[i].evnum = silevnum[exists].field1	 					
			;	ENDELSE
			
				msarr[i].evnum = STRMID(msdata[i].field8,0,8)		
			END
 			ELSE:	BEGIN
 					msarr[i].code = 'SMP'
 					msarr[i].evnum = STRMID(msdata[i].field8,0,8)
 			END ; case ELSE
 		ENDCASE

		msarr[i].ayr    = STRMID(msdata[i].field2,12,4)
 		msarr[i].amo    = STRMID(msdata[i].field2,9,2)
 		msarr[i].ady    = STRMID(msdata[i].field2,6,2)
 		; extract the time from the msfile:
 		colon1 = STRPOS(msdata[i].field3,':')
        	 IF (colon1 EQ 2) THEN msarr[i].ahr = STRMID(msdata[i].field3,1,1) ELSE $
 			msarr[i].ahr    = STRMID(msdata[i].field3,1,2)
 		msarr[i].amn    = STRMID(msdata[i].field3,(colon1+1),2)
 		msarr[i].asc    = '00'
 		msarr[i].num    = msdata[i].field4
 		msarr[i].port   = STRMID(msdata[i].field5,1,2)
 		msarr[i].pres   = ABS(msdata[i].field9)
		;  changed to accomodate ournewfin
		; 		msarr[i].refion = STRMID(msdata[i].field10,8,7)
		;	msarr[i].samion = STRMID(msdata[i].field10,29,7)
	 	msarr[i].refion = STRMID(msdata[i].field10,7,8)
		msarr[i].samion = STRMID(msdata[i].field10,28,8)
	 	msarr[i].sambeam= msdata[i].field11
	 	msarr[i].d45    = msdata[i].field12
	 	msarr[i].prec45 = msdata[i].field14
	 	msarr[i].rej45  = msdata[i].field15
	 	msarr[i].d46    = msdata[i].field13
		msarr[i].prec46 = msdata[i].field16
	 	msarr[i].rej46  = msdata[i].field17
		ENDFOR
		

	ENDIF ELSE BEGIN
	;**************************new code starts here runnum GE 2886

		
 	;-----READ FILE FROM MASS SPEC AND PARSE DATA INTO NORMAL FIELDS, COMMA DELIMITED ---------------
 	IF (verbose EQ 1) THEN PRINT,msfile,' Contains ',  nlines, ' lines'

 		FOR i = 0, nlines-1 DO BEGIN
 		CASE STRMID(msdata[i].field6,0,3) OF
 			'REF':	BEGIN
 				msarr[i].code = 'REF'
 				msarr[i].evnum = STRMID(msdata[i].field6,4,8) 
 			END ; case 'REF'
 			'STD':	BEGIN
 				msarr[i].code = 'STD'
				
				idstr1=STRPOS(msdata[i].field6,';')
				idstr2=STRPOS(msdata[i].field6,';',/REVERSE_SEARCH)
				msarr[i].evnum = STRMID(msdata[i].field6,idstr1+1,idstr2-idstr1-1)
				
 			END ; case 'STD' 
 			'TRP':	BEGIN
 				msarr[i].code = 'TRP'
 				msarr[i].evnum = STRMID(msdata[i].field6,4,8) 
 			END ; case 'TRP'
			'BOG':	BEGIN
 				msarr[i].code = 'BOG'
 				msarr[i].evnum = 99999999
 			END ; case 'BOG'
 			'SIL':	BEGIN
 				msarr[i].code = 'SIL'
				lenid=STRLEN(msdata[i].field6)
	 			idstr1=STRPOS(msdata[i].field6,';')
				idstr2=STRPOS(msdata[i].field6,';',/REVERSE_SEARCH)
				msarr[i].evnum = STRMID(msdata[i].field6,idstr2+1,lenid-idstr2)	
			END
	 		ELSE:	BEGIN
	 			 msarr[i].code = 'SMP'
				lenid=STRLEN(msdata[i].field6)
	 			idstr1=STRPOS(msdata[i].field6,';')
				idstr2=STRPOS(msdata[i].field6,';',/REVERSE_SEARCH)
				msarr[i].evnum = STRMID(msdata[i].field6,idstr2+1,lenid-idstr2)
	 		END ; case ELSE
		
	 	ENDCASE
		
		lenadate=STRLEN(msdata[i].field2)

	
	 	adatestr1=STRPOS(msdata[i].field2,'-')
		
		IF adatestr1 NE -1 THEN BEGIN
		
			adatestr2=STRPOS(msdata[i].field2,'-',/REVERSE_SEARCH)
	 		msarr[i].ayr    = STRMID(msdata[i].field2,adatestr2+1,4)
	 		msarr[i].amo    = STRMID(msdata[i].field2,adatestr1+1,adatestr2-adatestr1-1)
			IF STRLEN(msarr[i].amo) LT 2 THEN msarr[i].amo='0'+msarr[i].amo
			msarr[i].ady    = STRMID(msdata[i].field2,0,adatestr1)
			IF STRLEN(msarr[i].ady) LT 2 THEN msarr[i].ady='0'+msarr[i].ady
		ENDIF ELSE BEGIN
			;if '-' is not in the string, date must be delimited by '/'. This is due to variable excel formatting.
			;added 8/6/2009 by SEM and AES
			adatestr1=STRPOS(msdata[i].field2,'/')
			adatestr2=STRPOS(msdata[i].field2,'/',/REVERSE_SEARCH)
	 		msarr[i].ayr    = STRMID(msdata[i].field2,adatestr2+1,4)
			IF STRLEN(msarr[i].ayr) LT 4 THEN msarr[i].ayr='20'+msarr[i].ayr

	 		msarr[i].amo    = STRMID(msdata[i].field2,adatestr1+1,adatestr2-adatestr1-1)
			IF STRLEN(msarr[i].amo) LT 2 THEN msarr[i].amo='0'+msarr[i].amo
		
	 		msarr[i].ady    = STRMID(msdata[i].field2,0,adatestr1)
			IF STRLEN(msarr[i].ady) LT 2 THEN msarr[i].ady='0'+msarr[i].ady
		ENDELSE
			
		msarr[i].ahr    = STRMID(msdata[i].field3,0,2)
		msarr[i].amn    = STRMID(msdata[i].field3,3,2)
	 	msarr[i].asc    = '00'
	 	msarr[i].num    = msdata[i].field4
	 	msarr[i].port   = msdata[i].field5
	 	msarr[i].pres   = msdata[i].field7
	 	msarr[i].sambeam = msdata[i].field8
		msarr[i].samion = msdata[i].field10
	 	msarr[i].refion = msdata[i].field9
		
	 	msarr[i].d45    = msdata[i].field11
	 	msarr[i].prec45 = msdata[i].field13
	 	msarr[i].rej45  = msdata[i].field14
	 	msarr[i].d46    = msdata[i].field12
		msarr[i].prec46 = msdata[i].field15
	 	msarr[i].rej46  = msdata[i].field16

		ENDFOR	

	ENDELSE
	
 END  ;case 'o1'

 'i2' : BEGIN
 	;----- READ FILE AND SET UP ARRAYS FOR INCOMING DATA----------------------------------------
 	transdir= '/projects/' + spec + '/flask/' + inst + '/transfer/csv_files/'
 	msfile = transdir + file
	;sread file to get rid of commas
	tempi2='/home/ccg/sil/tempfiles/i2rawtemp'
	CCG_SREAD, file=msfile,msdatastr,/nomessages


	
	
	yesdata=WHERE(STRMID(msdatastr,0,1) NE ',')
	msdatastr=msdatastr[yesdata]
	CCG_SWRITE,file=tempi2,msdatastr,/nomessages

 	CCG_READ, file = tempi2, delimiter=',', /nomessages, skip=1, msdata ;skips header line
	keep=WHERE(STRMID(msdata.field2,0,4) NE 'warm') ;filters warmups
	msdata=msdata[keep]
	
 	nlines = N_ELEMENTS(msdata)	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF
   	
	IF FIX(runum) GE 3950 THEN BEGIN
		CCG_SWRITE,file='/projects/co2c13/flask/i2/newtransfer/csv_files/'+file,msdatastr,/nomessages

	ENDIF
 	
 	msarr=REPLICATE ({	code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0,	$
 			flaskpres:0.0,	$
 			refbellows:0, 	$
 			sambellows:0,	$
 			refbeam:0, 	$
 			refdepltn:0.0,	$
 			samdepltn:0.0,	$
 			misbalance:0.0},$
 			nlines)



 	;-----READ FILE FROM MASS SPEC AND PARSE DATA INTO NORMAL FIELDS, COMMA DELIMITED ---------------
 	IF (verbose EQ 1) THEN PRINT,msfile,' Contains ',  nlines, ' lines'
 	FOR i = 0, nlines-1 DO BEGIN
 		CASE STRMID(msdata[i].field2,0,3) OF
 		'REF':	BEGIN
 			msarr[i].code = 'REF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		 END ; case 'REF'
 		'STD':	BEGIN
			;if internal std
			IF STRMID(msdata[i].field2,8,1) EQ '-' THEN BEGIN
				msarr[i].code = 'STD'
 				msarr[i].evnum = STRMID(msdata[i].field2,4,8)
			;if external std
			ENDIF ELSE BEGIN
 				msarr[i].code = 'STD'
 				;msarr[i].evnum = STRMID(msdata[i].field2,4,7)
				
				idstr1=STRPOS(msdata[i].field2,'_')
				idstr2=STRPOS(msdata[i].field2,'_',/REVERSE_SEARCH)
				firstpart=STRMID(msdata[i].field2,0,idstr2-1)
				idstr3=STRPOS(firstpart,'_',/REVERSE_SEARCH)
				
				msarr[i].evnum = STRMID(firstpart,idstr1+1,idstr3-idstr1-1)
	
			ENDELSE
 		END ; case 'STD' 
 		'TRP':	BEGIN
 			msarr[i].code = 'TRP'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'TRP'
		'SRF':	BEGIN
 			msarr[i].code = 'SRF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'SRF'
		'ETA':	BEGIN
 			msarr[i].code = 'ETA'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'ETA'
		'BOG':	BEGIN
 			msarr[i].code = 'BOG'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'BOG'
		
		'SIL':	BEGIN
	
 			msarr[i].code = 'SIL'
				;print, 'i =', i
 			;CCG_READ, file='/home/ccg/sil/silflasks/sil_eventnum.txt', $
 			;	delimiter=' ', /nomessages, silevnum
			CCG_READ, file='/projects/co2c13/flask/sb/sil_eventnum.txt', $
 				delimiter=' ', /nomessages, silevnum
			
			;separate the session-built identifier into usable info
			allminus1=strarr(nlines)
			allminus1and2=strarr(nlines)
			len1=strarr(nlines)
			strpos1=strarr(nlines)
			len2=strarr(nlines)
			strpos2=strarr(nlines)				
			FOR s=0,nlines-1 DO BEGIN
				len1[s]=STRLEN(msdata[s].field2)
				strpos1[s]=STRPOS(msdata[s].field2,'_')
				allminus1[s]=STRMID(msdata[s].field2,strpos1[s]+1,len1[s]-(strpos1[s]+1))
				len2[s]=STRLEN(allminus1[s])
				strpos2[s]=STRPOS(allminus1[s],'_')
				allminus1and2[s]=STRMID(allminus1[s],strpos2[s]+1,len2[s]-(strpos2[s]+1))
			ENDFOR 			
			
			;last = N_ELEMENTS(silevnum)-1
			;	flaskid=STRMID(allminus1[i],0,strpos2[i])
		 	;	exists = WHERE(flaskid EQ STRCOMPRESS(silevnum.field3,/REMOVE_ALL) AND $ ; flask number
 			;	FIX(STRMID(allminus1and2[i],0,4)) EQ $
			;	     silevnum.field5 AND $ ;year
 			;	FIX(STRMID(allminus1and2[i],4,2)) EQ $
			;	    silevnum.field6 AND $ ;mo
			;	FIX(STRMID(allminus1and2[i],6,2)) EQ $
			;	    silevnum.field7) ;dy
			;
			;this will be obsolete after Ken incorporates sil numbers into session builder. 
 			;IF exists[0] EQ -1 THEN BEGIN
			;		; *********NOTE: previous code(below) works only for SIL #'s less than 1000
			;		; sre and ajd insterted 5/24/06
			;
			;	num=FIX(STRMID(silevnum[last].field1,3,5))+1
			;	IF num GT 0 AND num LT 10 THEN silnum = 'SIL0000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;	IF num GT 9 AND num LT 100 THEN silnum = 'SIL000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)		
			;	IF num GT 99 AND num LT 1000 THEN silnum = 'SIL00'+STRCOMPRESS(STRING(num), /REMOVE_ALL)	
			;	IF num GT 999 AND num LT 10000 THEN silnum = 'SIL0'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;	IF num GT 9999 AND num LT 100000 THEN silnum = 'SIL'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
 			;	
			;	;previous
			;	;msarr[i].evnum = STRCOMPRESS('SIL0'+STRING((FIX(STRMID(silevnum[last].field1,3,5))+1)),/REMOVE_ALL)
 			;	;current
			;	msarr[i].evnum=silnum
			;	
			;	;silformat = '(A9, A4, 1x, A7, I5.1, I3.1, I3.1)'
 			;	
			;	silformat = '(A9, A4, A9, A3,1x,I5, 1X,I3,1X, I3,1X,F8.2,1X,F8.2)'
			;	;;silformat = '(A9, A4, A9, I5.1, I3.1, I3.1,F5.2,F5.2)'
 			;	;print, msarr[i].evnum
 			;	;OPENU, u, '/home/ccg/isotopes/idl/prgms/proc/sil_eventnum.txt', /APPEND, /GET_LUN
 			;	PRINTF, u, FORMAT= silformat, msarr[i].evnum, 'SIL', $
 			;		STRCOMPRESS(msdata[i].field7,/REMOVE_ALL), $
 			;		FIX(STRCOMPRESS(STRMID(msdata[i].field2,12,4),/REMOVE_ALL)), $
 			;		FIX(STRCOMPRESS(STRMID(msdata[i].field2,9,2),/REMOVE_ALL)), $
 			;		FIX(STRCOMPRESS(STRMID(msdata[i].field2,7,2),/REMOVE_ALL),$
			;		silco2,siln2o)
 			;	FREE_LUN, u
			;	
			;	PRINTF, u, FORMAT= silformat, msarr[i].evnum, 'SIL', $
 			;		flaskid,'u'm
			;		STRCOMPRESS(STRMID(msdata[i].field2,4,6)), $
 			;		FIX(STRMID(STRCOMPRESS(STRING(msdata[i].field6), /REMOVE_ALL),0,4)), $
 			;		FIX(STRMID(STRCOMPRESS(STRING(msdata[i].field6), /REMOVE_ALL),4,2)),  $
 			;		FIX(STRMID(STRCOMPRESS(STRING(msdata[i].field6), /REMOVE_ALL),6,2))  
 			;	FREE_LUN, u
 			;ENDIF ELSE BEGIN
 			;		msarr[i].evnum = silevnum[exists].field1
 			;ENDELSE
			
		msarr[i].evnum = STRMID(allminus1and2[i],0,8)

 		END ; case 'SIL'
		
 		ELSE:	BEGIN
 		;*******
 				msarr[i].code = 'SMP'
 				oureventpos = STRPOS (msdata[i].field2,'_', /REVERSE_SEARCH)
 				msarr[i].evnum = STRMID(msdata[i].field2,oureventpos -8,8)
 				;old logic:msarr[i].evnum = STRMID(msdata[i].field2,12,8)
 		END ; case ELSE
 		ENDCASE
 		msarr[i].ayr    = STRMID(STRTRIM(msdata[i].field6,2),0,4)
 		msarr[i].amo    = STRMID(STRTRIM(msdata[i].field6,2),4,2)
 		msarr[i].ady    = STRMID(STRTRIM(msdata[i].field6,2),6,2)
 		msarr[i].ahr    = STRMID(STRTRIM(msdata[i].field6,2),8,2)
 		msarr[i].amn    = STRMID(STRTRIM(msdata[i].field6,2),10,2)
 		msarr[i].asc    = '00' ;STRMID(STRTRIM(msdata[i].field6,2),12,2)
 		msarr[i].num    = msdata[i].field1
 		msarr[i].port   = STRCOMPRESS(STRING(msdata[i].field5),/REMOVE_ALL) ; +'-'+ msdata[i].field24
 		msarr[i].pres   = msdata[i].field8
 		msarr[i].refion = msdata[i].field11
 		msarr[i].samion = msdata[i].field12
 		msarr[i].sambeam= msdata[i].field14
 		msarr[i].d45    = msdata[i].field20
 		msarr[i].prec45 = msdata[i].field18
 		msarr[i].rej45  = msdata[i].field19
 		msarr[i].d46 = msdata[i].field21
 		msarr[i].prec46 = msdata[i].field22
 		msarr[i].rej46  = msdata[i].field23
 		msarr[i].flaskpres = msdata[i].field7
 		msarr[i].refbellows = msdata[i].field9
 		msarr[i].sambellows = msdata[i].field10
 		msarr[i].refbeam = msdata[i].field13
 		msarr[i].refdepltn = msdata[i].field15
 		msarr[i].samdepltn = msdata[i].field16
 		msarr[i].misbalance = msdata[i].field17
 		
 	ENDFOR

END ;case 'i2'


'r1' : BEGIN
;sre added this Jan 07
print,'inst=Kirk'
	transdir= '/projects/' + spec + '/flask/' + inst + '/transfer/'
 	msfile = transdir + file
 
	CCG_READ, file = msfile, delimiter=',', /nomessages, msdata
 	print, 'reading the msfile'
	nlines = N_ELEMENTS(msdata)
	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF


s1type=strarr(nlines)
s1id=strarr(nlines)
s1evn=strarr(nlines)


msarr=REPLICATE ({	code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0},	$
 			nlines)

	FOR S=0,nlines-1 DO BEGIN
		delim=STRPOS(msdata[s].field7,'_', /REVERSE_SEARCH)
		shorter=STRMID(msdata[s].field7,0,delim)
		nextdelim=STRPOS(shorter,'_', /REVERSE_SEARCH)
		len=strlen(shorter)
		stillshorter=STRMID(msdata[s].field7,0,nextdelim)
		s1evn[s]=STRMID(shorter,nextdelim+1,len-nextdelim)
		s1id[s]=STRMID(shorter,5,nextdelim-5)
	ENDFOR

;;;;;******************BELOW is copied from 'o1' ******** must change for kirk formatting!
	FOR i = 0, nlines-1 DO BEGIN
 	CASE STRMID(msdata[i].field6,1,3) OF
 		'REF':	BEGIN
 			msarr[i].code = 'REF'
 			msarr[i].evnum = msdata[i].field7   
 		END ; case 'REF'
 		'STD':	BEGIN
 			msarr[i].code = 'STD'
 			msarr[i].evnum = msdata[i].field7   
 		END ; case 'STD' 
 		'TRP':	BEGIN
 			msarr[i].code = 'TRP'
 			msarr[i].evnum = msdata[i].field7   
 		END ; case 'TRP'
 		'SIL':	BEGIN
 			msarr[i].evnum = msdata[i].field7   
				;print, 'i =', i
 			CCG_READ, file='/home/ccg/sil/silflasks/sil_eventnum.txt', $
 				delimiter=' ', /nomessages, silevnum
 			last = N_ELEMENTS(silevnum)
		
 			exists = WHERE(msdata[i].field7 EQ silevnum.field3 AND $       ; flask number
 				FIX(STRMID(msdata[i].field2,12,4)) EQ silevnum.field5 AND $  ; year
 				FIX(STRMID(msdata[i].field2,9,2)) EQ silevnum.field6 AND $  ; month
 				FIX(STRMID(msdata[i].field2,7,2)) EQ silevnum.field7)       ; day			
 			
 			msarr[i].evnum = silevnum[exists].field1
 			
 		END
		ELSE:	BEGIN
 				msarr[i].code = 'SMP'
 				msarr[i].evnum = s1evn[i]
 		END ; case ELSE
 	ENDCASE
	
	
 	msarr[i].ayr    = STRMID(msdata[i].field2,12,4)
 	msarr[i].amo    = STRMID(msdata[i].field2,9,2)
 	msarr[i].ady    = STRMID(msdata[i].field2,6,2)
 	; extract the time from the msfile:
 	colon1 = STRPOS(msdata[i].field3,':')
         IF (colon1 EQ 2) THEN msarr[i].ahr = STRMID(msdata[i].field3,1,1) ELSE $
 		msarr[i].ahr    = STRMID(msdata[i].field3,1,2)
 	msarr[i].amn    = STRMID(msdata[i].field3,(colon1+1),2)
 	msarr[i].asc    = '00'
 	msarr[i].num    = msdata[i].field5
 	msarr[i].port   =msdata[i].field5
 	msarr[i].pres   = ABS(msdata[i].field8)
 	msarr[i].refion = STRMID(msdata[i].field9,7,7)
 	msarr[i].samion = STRMID(msdata[i].field9,29,7)  ;check this!
 	msarr[i].sambeam= msdata[i].field11
 	msarr[i].d45    = msdata[i].field12
 	msarr[i].prec45 = msdata[i].field14
 	msarr[i].rej45  = msdata[i].field15
 	msarr[i].d46    = msdata[i].field13
	msarr[i].prec46 = msdata[i].field16
 	msarr[i].rej46  = msdata[i].field17
	
	
	ENDFOR



END ;case 'r1'

'cr' : BEGIN
;sre added this May 08 to run 'crb' files
print,'inst=Kirk-carbs'
	transdir= '/projects/' + spec + '/flask/r1/transfer/'
 	msfile = transdir + file
 
	CCG_READ, file = msfile, delimiter=',', /nomessages, msdata
 	print, 'reading the msfile'
	nlines = N_ELEMENTS(msdata)
	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF



msarr=REPLICATE ({	code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0},	$
 			nlines)

	
	FOR i = 0, nlines-1 DO BEGIN
 	CASE STRMID(msdata[i].field7,1,3) OF
 		'REF':	BEGIN
 			msarr[i].code = 'REF'
 			msarr[i].evnum = STRMID(msdata[i].field7,5,8)   
 		END ; case 'REF'
 		'STD':	BEGIN
 			msarr[i].code = 'STD'
 			msarr[i].evnum = STRMID(msdata[i].field7,5,8)   
 		END ; case 'STD' 
 		'TRP':	BEGIN
 			msarr[i].code = 'TRP'
 			msarr[i].evnum = STRMID(msdata[i].field7,5,8)   
 		END ; case 'TRP'
 		'SIL':	BEGIN
 			msarr[i].code = 'SIL'
 			msarr[i].evnum = STRMID(msdata[i].field7,5,8)   
 			
 		END
		ELSE:	BEGIN
 				msarr[i].code = 'SMP'
 				msarr[i].evnum = STRMID(msdata[i].field7,5,8)   
 		END ; case ELSE
 	ENDCASE
	
	
 	msarr[i].ayr    = STRMID(msdata[i].field2,12,4)
 	msarr[i].amo    = STRMID(msdata[i].field2,9,2)
 	msarr[i].ady    = STRMID(msdata[i].field2,6,2)
 	; extract the time from the msfile:
 	colon1 = STRPOS(msdata[i].field3,':')
         IF (colon1 EQ 2) THEN msarr[i].ahr = STRMID(msdata[i].field3,1,1) ELSE $
 		msarr[i].ahr    = STRMID(msdata[i].field3,1,2)
 	msarr[i].amn    = STRMID(msdata[i].field3,(colon1+1),2)
 	msarr[i].asc    = '00'
 	msarr[i].num    = msdata[i].field5
 	msarr[i].port   =msdata[i].field6
 	msarr[i].pres   = ABS(msdata[i].field8)
 	msarr[i].refion = STRMID(msdata[i].field9,7,7)
 	msarr[i].samion = STRMID(msdata[i].field9,29,7)  ;check this!
 	msarr[i].sambeam= msdata[i].field10
 	msarr[i].d45    = msdata[i].field12
 	msarr[i].prec45 = msdata[i].field14
 	msarr[i].rej45  = msdata[i].field15
 	msarr[i].d46    = msdata[i].field13
	msarr[i].prec46 = msdata[i].field16
 	msarr[i].rej46  = msdata[i].field17
	
	
	ENDFOR



END ;case 'cr'
'i4'  : BEGIN
 	;----- READ FILE AND SET UP ARRAYS FOR INCOMING DATA----------------------------------------
 	transdir= '/projects/' + spec + '/flask/' + inst + '/transfer/csv_files/'
 	msfile = transdir + file

	;sread file to get rid of commas
	tempi4='/home/ccg/sil/tempfiles/i4rawtemp'
	CCG_SREAD, file=msfile,msdatastr,/nomessages

	yesdata=WHERE(STRMID(msdatastr,0,1) NE ',')
	msdatastr=msdatastr[yesdata]
	CCG_SWRITE,file=tempi4,msdatastr,/nomessages

	CCG_READ, file = tempi4, delimiter=',', /nomessages, skip=1, msdata ;to skip headers
	sizemsdata=SIZE(msdata)

	keep=WHERE(STRMID(msdata.field2,0,4) NE 'warm')  ; filters warmups
	msdata=msdata[keep]

 	nlines = N_ELEMENTS(msdata)	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF
 
 	
	IF FIX(runum) GE 753 THEN BEGIN
		
		CCG_SWRITE,file='/projects/co2c13/flask/i4/newtransfer/csv_files/'+file,msdatastr,/nomessages

	ENDIF

	
 	msarr=REPLICATE ({	code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0,	$
 			flaskpres:0.0,	$
 			refbellows:0, 	$
 			sambellows:0,	$
 			refbeam:0.0, 	$
 			refdepltn:0.0,	$
 			samdepltn:0.0,	$
 			misbalance:0.0, $
			sampletemp:0.0},$
 			nlines)
 	

 	;-----READ FILE FROM MASS SPEC AND PARSE DATA INTO NORMAL FIELDS, COMMA DELIMITED ---------------
 	IF (verbose EQ 1) THEN PRINT,msfile,' Contains ',  nlines, ' lines'
 	FOR i = 0, nlines-1 DO BEGIN
 		CASE STRMID(msdata[i].field2,0,3) OF
 		'REF':	BEGIN
 			msarr[i].code = 'REF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		 END ; case 'REF'
 		'STD':	BEGIN
			;if internal std
			IF STRMID(msdata[i].field2,8,1) EQ '-' THEN BEGIN
				msarr[i].code = 'STD'
 				msarr[i].evnum = STRMID(msdata[i].field2,4,8)
			;if external std
			ENDIF ELSE BEGIN
 				msarr[i].code = 'STD'
 				;msarr[i].evnum = STRMID(msdata[i].field2,4,7)
				
				idstr1=STRPOS(msdata[i].field2,'_')
				idstr2=STRPOS(msdata[i].field2,'_',/REVERSE_SEARCH)
				firstpart=STRMID(msdata[i].field2,0,idstr2-1)
				idstr3=STRPOS(firstpart,'_',/REVERSE_SEARCH)
				
				msarr[i].evnum = STRMID(firstpart,idstr1+1,idstr3-idstr1-1)
				
				
			ENDELSE

 		END ; case 'STD' 
 		'TRP':	BEGIN
 			msarr[i].code = 'TRP'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'TRP'
		'SRF':	BEGIN
 			msarr[i].code = 'SRF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'SRF'
		'ETA':	BEGIN
 			msarr[i].code = 'ETA'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'ETA'
		'BOG':	BEGIN
 			msarr[i].code = 'BOG'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'BOG'
		
		
		'SIL':	BEGIN
 			msarr[i].code = 'SIL'
				;print, 'i =', i
 			CCG_READ, file='/home/ccg/sil/silflasks/sil_eventnum.txt', $
 				delimiter=' ', /nomessages, silevnum
			
			;separate the session-built identifier into usable info
			allminus1=strarr(nlines)
			allminus1and2=strarr(nlines)
			len1=strarr(nlines)
			strpos1=strarr(nlines)
			len2=strarr(nlines)
			strpos2=strarr(nlines)				
			FOR s=0,nlines-1 DO BEGIN
				len1[s]=STRLEN(msdata[s].field2)
				strpos1[s]=STRPOS(msdata[s].field2,'_')
				allminus1[s]=STRMID(msdata[s].field2,strpos1[s]+1,len1[s]-(strpos1[s]+1))
				len2[s]=STRLEN(allminus1[s])
				strpos2[s]=STRPOS(allminus1[s],'_')
				allminus1and2[s]=STRMID(allminus1[s],strpos2[s]+1,len2[s]-(strpos2[s]+1))
			ENDFOR 			
			
		msarr[i].evnum = STRMID(allminus1and2[i],0,8)

 		END ; case 'SIL'
		
		
		
		
		'CRF':	BEGIN
 			msarr[i].code = 'CRF'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case CRF
		'CRB':	BEGIN
 			msarr[i].code = 'CRB'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case CRB
		'HRF' : BEGIN
			msarr[i].code = 'HRF'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case HRF
		'H20' : BEGIN
			msarr[i].code = 'H2O'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case H2O
 		ELSE:	BEGIN
 		;*******INSERT BETTER LOGIC HERE TO CAPTURE EVENT # ****BHV
 				msarr[i].code = 'SMP'
 				oureventpos = STRPOS (msdata[i].field2,'_', /REVERSE_SEARCH)
 				msarr[i].evnum = STRMID(msdata[i].field2,oureventpos -8,8)
 				;old logic:msarr[i].evnum = STRMID(msdata[i].field2,12,8)
 		END ; case ELSE
 		ENDCASE
 		msarr[i].ayr    = STRMID(STRTRIM(msdata[i].field6,2),0,4)
 		msarr[i].amo    = STRMID(STRTRIM(msdata[i].field6,2),4,2)
 		msarr[i].ady    = STRMID(STRTRIM(msdata[i].field6,2),6,2)
 		msarr[i].ahr    = STRMID(STRTRIM(msdata[i].field6,2),8,2)
 		msarr[i].amn    = STRMID(STRTRIM(msdata[i].field6,2),10,2)
 		msarr[i].asc    = '00' ;STRMID(STRTRIM(msdata[i].field6,2),12,2)
 		msarr[i].num    = msdata[i].field1
 		msarr[i].port   = STRCOMPRESS(STRING(msdata[i].field5),/REMOVE_ALL) ; +'-'+ msdata[i].field24
 		msarr[i].pres   = msdata[i].field8
 		msarr[i].refion = msdata[i].field11
 		msarr[i].samion = msdata[i].field12
 		msarr[i].sambeam= msdata[i].field14
 		msarr[i].d45    = msdata[i].field20
 		msarr[i].prec45 = msdata[i].field18
 		msarr[i].rej45  = msdata[i].field19
 		msarr[i].d46 = msdata[i].field21
 		msarr[i].prec46 = msdata[i].field22
 		msarr[i].rej46  = msdata[i].field23
 		msarr[i].flaskpres = ABS(msdata[i].field7)
 		msarr[i].refbellows = msdata[i].field9
 		msarr[i].sambellows = msdata[i].field10
 		msarr[i].refbeam = msdata[i].field13
 		msarr[i].refdepltn = msdata[i].field15
 		msarr[i].samdepltn = msdata[i].field16
 		msarr[i].misbalance = msdata[i].field17
 		msarr[i].sampletemp = msdata[i].field24
 	ENDFOR

END ;case 'i4'
'i6'  : BEGIN
 	;----- READ FILE AND SET UP ARRAYS FOR INCOMING DATA----------------------------------------
 	transdir= '/projects/' + spec + '/flask/' + inst + '/transfer/csv_files/'
 	msfile = transdir + file

	;sread file to get rid of commas
	tempi6='/home/ccg/sil/tempfiles/i6rawtemp'
	CCG_SREAD, file=msfile,msdatastr,/nomessages

	yesdata=WHERE(STRMID(msdatastr,0,1) NE ',')
	msdatastr=msdatastr[yesdata]
	CCG_SWRITE,file=tempi6,msdatastr,/nomessages

	CCG_READ, file = tempi6, delimiter=',', /nomessages, skip=1, msdata ;skips header line
	sizemsdata=SIZE(msdata)

	keep=WHERE(STRMID(msdata.field2,0,4) NE 'warm')  ; filters out warmups
	msdata=msdata[keep]


 	nlines = N_ELEMENTS(msdata)	
 	IF (verbose EQ 1) THEN PRINT,'File length is: ',nlines,' long'
 	IF (verbose EQ 1) THEN BEGIN
 		PRINT,'Run num = ',runum
 		PRINT,'Instrument = ',inst
 	ENDIF
 
 	IF FIX(runum) GE 1572 THEN BEGIN
		
		CCG_SWRITE,file='/projects/co2c13/flask/i6/newtransfer/csv_files/'+file,msdatastr,/nomessages

	ENDIF

 	msarr=REPLICATE ({	code:'',	$
 			evnum:'',	$
 			ayr:'',		$
 			amo:'',		$
 			ady:'',		$
 			ahr:'',		$
 			amn:'',		$
 			asc:'',		$
 			num:0,		$
 			port:'',	$
 			pres:0.0,	$
 			refion:0.0,	$
 			samion:0.0,	$
 			sambeam:0.0,	$
 			d45:0.0,	$
 			prec45:0.0,	$
 			rej45:0,	$
 			d46:0.0,	$
 			prec46:0.0,	$
 			rej46:0,	$
 			flaskpres:0.0,	$
 			refbellows:0, 	$
 			sambellows:0,	$
 			refbeam:0.0, 	$
 			refdepltn:0.0,	$
 			samdepltn:0.0,	$
 			misbalance:0.0},$
 			nlines)
 	

 	;-----READ FILE FROM MASS SPEC AND PARSE DATA INTO NORMAL FIELDS, COMMA DELIMITED ---------------
 	IF (verbose EQ 1) THEN PRINT,msfile,' Contains ',  nlines, ' lines'
 	FOR i = 0, nlines-1 DO BEGIN
 		CASE STRMID(msdata[i].field2,0,3) OF
 		'REF':	BEGIN
 			msarr[i].code = 'REF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		 END ; case 'REF'
 		'STD':	BEGIN
			;if internal std
			IF STRMID(msdata[i].field2,8,1) EQ '-' THEN BEGIN
				msarr[i].code = 'STD'
 				msarr[i].evnum = STRMID(msdata[i].field2,4,8)
			;if external std
			ENDIF ELSE BEGIN
 				msarr[i].code = 'STD'
 				;msarr[i].evnum = STRMID(msdata[i].field2,4,7)
				
				idstr1=STRPOS(msdata[i].field2,'_')
				idstr2=STRPOS(msdata[i].field2,'_',/REVERSE_SEARCH)
				firstpart=STRMID(msdata[i].field2,0,idstr2-1)
				idstr3=STRPOS(firstpart,'_',/REVERSE_SEARCH)
				msarr[i].evnum = STRMID(firstpart,idstr1+1,idstr3-idstr1-1)		
			ENDELSE

 		END ; case 'STD' 
 		'TRP':	BEGIN
 			msarr[i].code = 'TRP'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'TRP'
 		'SRF':	BEGIN
 			msarr[i].code = 'SRF'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'SRF'
		'ETA':	BEGIN
 			msarr[i].code = 'ETA'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'ETA'
		'BOG':	BEGIN
 			msarr[i].code = 'BOG'
 			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
 		END ; case 'BOG'
		
		
		'SIL':	BEGIN
 			msarr[i].code = 'SIL'
				;print, 'i =', i
 			CCG_READ, file='/home/ccg/sil/silflasks/sil_eventnum.txt', $
 				delimiter=' ', /nomessages, silevnum
			
			;separate the session-built identifier into usable info
			allminus1=strarr(nlines)
			allminus1and2=strarr(nlines)
			len1=strarr(nlines)
			strpos1=strarr(nlines)
			len2=strarr(nlines)
			strpos2=strarr(nlines)				
			FOR s=0,nlines-1 DO BEGIN
				len1[s]=STRLEN(msdata[s].field2)
				strpos1[s]=STRPOS(msdata[s].field2,'_')
				allminus1[s]=STRMID(msdata[s].field2,strpos1[s]+1,len1[s]-(strpos1[s]+1))
				len2[s]=STRLEN(allminus1[s])
				strpos2[s]=STRPOS(allminus1[s],'_')
				allminus1and2[s]=STRMID(allminus1[s],strpos2[s]+1,len2[s]-(strpos2[s]+1))
			ENDFOR 			
			
		msarr[i].evnum = STRMID(allminus1and2[i],0,8)

 		END ; case 'SIL'
		
		'CRF':	BEGIN
 			msarr[i].code = 'CRF'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case CRF
		'CRB':	BEGIN
 			msarr[i].code = 'CRB'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case CRB
		'HRF' : BEGIN
			msarr[i].code = 'HRF'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case HRF
		'H20' : BEGIN
			msarr[i].code = 'H2O'
			msarr[i].evnum = STRMID(msdata[i].field2,4,8)
		END ; case H2O
 		ELSE:	BEGIN
 		;*******INSERT BETTER LOGIC HERE TO CAPTURE EVENT # ****BHV
 				msarr[i].code = 'SMP'
 				oureventpos = STRPOS (msdata[i].field2,'_', /REVERSE_SEARCH)
 				msarr[i].evnum = STRMID(msdata[i].field2,oureventpos -8,8)
 				;old logic:msarr[i].evnum = STRMID(msdata[i].field2,12,8)
 		END ; case ELSE
 		ENDCASE
 		msarr[i].ayr    = STRMID(STRTRIM(msdata[i].field6,2),0,4)
 		msarr[i].amo    = STRMID(STRTRIM(msdata[i].field6,2),4,2)
 		msarr[i].ady    = STRMID(STRTRIM(msdata[i].field6,2),6,2)
 		msarr[i].ahr    = STRMID(STRTRIM(msdata[i].field6,2),8,2)
 		msarr[i].amn    = STRMID(STRTRIM(msdata[i].field6,2),10,2)
 		msarr[i].asc    = '00' ;STRMID(STRTRIM(msdata[i].field6,2),12,2)
 		msarr[i].num    = msdata[i].field1
 		msarr[i].port   = STRCOMPRESS(STRING(msdata[i].field5),/REMOVE_ALL) ; +'-'+ msdata[i].field24
 		msarr[i].pres   = msdata[i].field8
 		msarr[i].refion = msdata[i].field11
 		msarr[i].samion = msdata[i].field12
 		msarr[i].sambeam= msdata[i].field14
 		msarr[i].d45    = msdata[i].field20
 		msarr[i].prec45 = msdata[i].field18
 		msarr[i].rej45  = msdata[i].field19
 		msarr[i].d46 = msdata[i].field21
 		msarr[i].prec46 = msdata[i].field22
 		msarr[i].rej46  = msdata[i].field23
 		msarr[i].flaskpres = ABS(msdata[i].field7)
 		msarr[i].refbellows = msdata[i].field9
 		msarr[i].sambellows = msdata[i].field10
 		msarr[i].refbeam = msdata[i].field13
 		msarr[i].refdepltn = msdata[i].field15
 		msarr[i].samdepltn = msdata[i].field16
 		msarr[i].misbalance = msdata[i].field17
 		
 	ENDFOR

END ;case 'i6'

ENDCASE 

 IF(verbose EQ 1) THEN PRINT, 'Reconfigured data'

 ; ----- CREATE/IDENTIFY FIELDS IN  ARRAY TO WORK FROM OUT OF msarr[]--------------------------- 
 ayear = STRTRIM(msarr[0].ayr,2)
 amon = STRTRIM(msarr[0].amo,2)
 aday = STRTRIM(msarr[0].ady,2)
 ahour = STRTRIM(msarr[0].ahr,2)
 amin = STRTRIM(msarr[0].amn,2)
 asec = STRTRIM(msarr[0].asc,2)
 ayear = STRTRIM(STRING(ayear),2)
 amon = STRTRIM(STRING(amon),2)
 aday = STRTRIM(STRING(aday),2)
 ahour = STRTRIM(STRING(ahour),2)
 amin = STRTRIM(STRING(amin),2)
 asec = STRTRIM(STRING(asec),2)
 headdate = ayear + ' ' + amon + ' ' + aday 
 adate = ayear + '-' + amon + '-' + aday
 ref = msarr[1].evnum
 random = '-999.999'

 ;-----WRITE DATA TO A RAW FILE FORMAT IN SAVED DIRECTORY---------------------------------------
 ; Spock files (Optima) = /projects/co2c13/flask/o1/xxxx/*.o1 (where xxxx is year)
 ; Tpol files (IsoPrime) = /projects/co2c13/flask/i2/xxxx/*.i2 (where xxxx is year)
 ; inst = i2, o1, etc.
 ; NOTE: Search to see if sub directory "xxxx" (year) already exists.  If not, create it. 
 ; If we want to use this code to process methane too, we could determine the species right here,
 ; by doing something like:  IF (inst EQ 'o1') OR (inst EQ 'i2') THEN spec = 'co2c13' ELSE spec = 'ch4c13'
 
 
 
 ;-----CREATE RAWFILE NAME AND DIRECTORY PATH TO IT---------------------------------------------
 rawfile = adate + '.' + ahour + amin + '.' + spec

 IF inst EQ 'cr' THEN inst='r1'
 rawpath = '/projects/co2c13/flask/' + inst + '/raw/' + ayear + '/' + rawfile
 rawheader = '* ' + runum + ' ' + headdate + ' ' + ahour + ' ' + amin + ' ' + asec $
 		+ ' ' + inst+ ' ' + ref + ' ' + random

 CASE inst OF
 'o1' : BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A3,E9.1,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3)' 
 END
 'r1' : BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A3,E8.1,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3)'
 END
 'cr' : BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A3,E8.1,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3)' 
 END
 'i2': BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A6,E8.1,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3,F6.1,2(I5),F6.1,3(F8.3))'
 END
 'i4': BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A6,1X,E8.1,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3,E8.1,2(I5),E9.2,4(F8.3))'
 END
  'i6': BEGIN
 	lineformat = '(A4,A10,A5,5(A3),I4.3,A6,1X,F5.2,2(E8.1),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3,F6.2,2(I5),E9.2,3(F8.3))'
 END

 ENDCASE
 
 OPENW, u, rawpath, /GET_LUN
 PRINTF, u, rawheader
 
 FOR i = 0,nlines-1 DO PRINTF, u, FORMAT = lineformat, msarr[i]
 FREE_LUN,u
 
 PRINT, '	Done constructing rawfile ',rawfile
 
 rawinst = inst

 END
 
