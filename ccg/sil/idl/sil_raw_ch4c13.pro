;
; NAME: sil_raw_ch4c13.pro		
;
; PURPOSE:  		
;	Processes raw files from TROI (CH4C13) code to read in .csv file 
;	created by Mark Dreier's excel macro from MassLynx '.xls' file
;	GENERAL OUTLINE:
;		1) Read a mass spec file from the isotopes/transfer directory
;		2) Parse mass spec file into a 'rawfile' format
;		3) Write raw file	
;	
; CATEGORY:
;	Data maintainance
;	
; CALLING SEQUENCE:  	
;	Can be executed from the command line
;	or evoked from Ken's SQL web-world.
;	
; INPUTS:		
;	file : mass spec file name in the format of a .csv file in the 
;		form of ch4nnnnntemp.csv
;	
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
;			None that can be thought of now....however, future
;			applications should probably require password protection.
;
; PROCEDURE:
;	Example:
;		.
;		.
;		.
;		.
;		
; MODIFICATION HISTORY:
;	Written, JM
;   	Updated, VAC, August, 2004
;	modified, SEM, March 20,2010 to get rid of warmup data
;	modified, JPW, Jan 07, 2011 to make rawfiles from runs w/ 2 or more .csv files of the same name but different data


; ----- INITIALIZATION --------------------------------------------------------------------
PRO sil_raw_ch4c13, $
	file = file,  $
	rawfile
	;testmode = testmode, $
	;csvgood = csvgood

; ----- IDENTIFY THE INSTRUMENT AND RUN NUMBER FOR THE INCOMING FILE ----------------------
inst = 'i1'  ;this is hardcoded?
runum = STRMID(file,3,5)
spec = 'ch4c13'

; ----- READ FILE -------------------------------------------------------------------------

;IF testmode EQ 1 THEN BEGIN
;	IF csvgood EQ 1 THEN BEGIN
;		;dir = '/projects/' + spec + '/flask/' + inst + '/transfer/cordel1/' ;<--01.07.2011 JPW & SEM added this conditional "directory-director" for fetching "good" and "bad" versions of .csv files to compare the diff. in final data.
;		 dir = '/home/ccg/isotopes/Jason/cordel1/csv_files/'
;	ENDIF ELSE BEGIN
;		;dir = '/projects/' + spec + '/flask/' + inst + '/transfer/rawdel1/'
;		 dir = '/home/ccg/isotopes/Jason/rawdel1/csv_files/'
;	ENDELSE
;		 
;ENDIF ELSE BEGIN
		 dir = '/projects/' + spec + '/flask/' + inst + '/transfer/csv_files/'

;ENDELSE


;dir = '/projects/' + spec + '/flask/' + inst + '/transfer/suspect_csv_files/rawdel1500_csv/'  ;<--"JPW 01.06.2011"
;dir = '/projects/' + spec + '/flask/' + inst + '/transfer/suspect_csv_files/rawdel1600_csv/' ;<--"JPW 01.06.2011"
msfile = dir+file
print,'reading file from:', msfile
CCG_READ, file=msfile, delimiter=',', /nomessages, skip=1, origdata
nlines = N_ELEMENTS(origdata)

; filter out bullshit peaks

goodpeak=WHERE(origdata.field18 GE 0.5, nlines)

origdata=origdata[goodpeak]


; ----- PARSE OUT SAMPLE IDENTIFICATION --------------------------------------------------
;   parse field2 into:
;1. type/sampling site
;2. flask #/tank name+fill#
;3. fill date

;SEM taking out warmups. They are not refs, so why call them such?

realdata=WHERE(STRLOWCASE(STRMID(origdata.field2,0,4)) NE 'warm',nlines)
data=origdata[realdata]

site_type = STRARR(nlines)
flask_tank_num = STRARR(nlines)
evnum = STRARR(nlines)

ayr = STRARR(nlines)
amo = STRARR(nlines)
ady = STRARR(nlines)
ahr = STRARR(nlines)
amn = STRARR(nlines)

FOR i=0, nlines-1 DO BEGIN
	;parse out field2 (the "primary key")
	CCG_STRTOK, str=data[i].field2, result, delimiter=';'
	site_type[i] = result[0]
	flask_tank_num[i] = result[1]
	evnum[i] = result[2]

	;second parse field6 into separate components
	ayr[i]=STRMID(STRCOMPRESS(data[i].field6,/REMOVE_ALL),0,4)
	amo[i]=STRMID(STRCOMPRESS(data[i].field6,/REMOVE_ALL),4,2)
	ady[i]=STRMID(STRCOMPRESS(data[i].field6,/REMOVE_ALL),6,2)
	ahr[i]=STRMID(STRCOMPRESS(data[i].field6,/REMOVE_ALL),8,2)
	amn[i]=STRMID(STRCOMPRESS(data[i].field6,/REMOVE_ALL),10,2) 
ENDFOR


; ----- WRITE TO RAW FILE ---------------------------------------------------------
;each raw file corresponds to an individual analysis session
;each line of a raw file contains the primary key **(EVNUM)** + adate and time + all analysis
;information for a given aliquot

;first, create array structure with format of raw file

rawarr = REPLICATE ({   code:'',	$
			evnum:'', 	$
			ayr:'',		$
			amo:'',		$
			ady:'',		$
			ahr:'',		$
			amn:'',		$
			idx:0,		$
			samarea1:0.0,	$
			samarea2:0.0,	$
			samarea3:0.0,	$
			rettime:0.0,	$
			refarea1:0.0,	$
			refarea2:0.0,	$
			refarea3:0.0,	$
			refheight:0.0,	$
			refratio1:0.0,	$
			samht:0.0,	$
			samratio1:0.0,	$
			corrdelta1:0.0,	$
			corrdelta2:0.0,$
			port:''},$
			nlines)
;now, fill it up...
FOR i=0, nlines-1 DO BEGIN
	CASE site_type[i] OF
		'REF':	BEGIN
			rawarr[i].code = 'REF'
			rawarr[i].evnum = flask_tank_num[i]
		END
		'STD':	BEGIN
			rawarr[i].code = 'STD'
			rawarr[i].evnum = flask_tank_num[i]
		END
		'LIN':	BEGIN
			rawarr[i].code = 'LIN'
			rawarr[i].evnum = flask_tank_num[i]
		END
		'TRP':	BEGIN
			rawarr[i].code = 'TRP'
			rawarr[i].evnum = flask_tank_num[i]
		END
		'BOG':	BEGIN
			rawarr[i].code = 'BOG'
			rawarr[i].evnum =999999
		END
		'SIL':	BEGIN
		;stop
			;rawarr[i].code = 'SIL'
			;CCG_READ, file='/projects/co2c13/flask/sb/sil_eventnum.txt', $
			;	delimiter=' ', /nomessages, silevnum
			;	stop
			;last = N_ELEMENTS(silevnum)
			;exists = WHERE(STRCOMPRESS(flask_tank_num[i],/REMOVE_ALL) EQ $
			;		STRCOMPRESS(silevnum.field3,/REMOVE_ALL) AND $
			;	FIX(STRCOMPRESS(STRMID(evnum[i],0,4),/REMOVE_ALL)) EQ silevnum.field5 AND $
			;	FIX(STRCOMPRESS(STRMID(evnum[i],4,2),/REMOVE_ALL)) EQ silevnum.field6 AND $
			;	FIX(STRCOMPRESS(STRMID(evnum[i],6,2),/REMOVE_ALL)) EQ silevnum.field7);

			;IF exists[0] EQ -1 THEN BEGIN
			;	num=FIX(STRMID(silevnum[last-1].field1,3,5))+1
			;	print, num
			;		IF num GT 0 AND num LT 10 THEN silnum = 'SIL0000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;		IF num GT 9 AND num LT 100 THEN silnum = 'SIL000'+STRCOMPRESS(STRING(num), /REMOVE_ALL)		
			;		IF num GT 99 AND num LT 1000 THEN silnum = 'SIL00'+STRCOMPRESS(STRING(num), /REMOVE_ALL)	
			;		IF num GT 999 AND num LT 10000 THEN silnum = 'SIL0'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;		IF num GT 9999 AND num LT 100000 THEN silnum = 'SIL'+STRCOMPRESS(STRING(num), /REMOVE_ALL)
			;	print,silnum
			;		rawarr[i].evnum=silnum
		;	
		;		OPENU, u, '/home/ccg/isotopes/idl/prgms/proc/sil_eventnum.txt', /APPEND, /GET_LUN
		;		PRINTF, u, FORMAT= silformat, rawarr[i].evnum, 'SIL', $
		;			STRCOMPRESS(flask_tank_num[i],/REMOVE_ALL), $
		;			STRCOMPRESS(STRMID(evnum[i],0,4),/REMOVE_ALL), $
		;			STRCOMPRESS(STRMID(evnum[i],4,2),/REMOVE_ALL), $
		;			STRCOMPRESS(STRMID(evnum[i],6,2),/REMOVE_ALL)
		;		FREE_LUN, u
		;	ENDIF ELSE BEGIN
		;			rawarr[i].evnum = silevnum[exists].field1
		;	ENDELSE
				rawarr[i].code = 'SIL' 
				rawarr[i].evnum = evnum[i]
		END
		ELSE:	BEGIN   ;ccg negwork flask
				rawarr[i].code = 'SMP' 
				rawarr[i].evnum = evnum[i]
		END
	ENDCASE
	rawarr[i].ayr = ayr[i]
	rawarr[i].amo = amo[i]
	rawarr[i].ady = ady[i]
	rawarr[i].ahr = ahr[i]
	rawarr[i].amn = amn[i]
	rawarr[i].idx = data[i].field1
	rawarr[i].port = STRCOMPRESS(data[i].field5, /REMOVE_ALL)
	;rawarr[i].port = data[i].field5

	rawarr[i].samarea1 = data[i].field9
	rawarr[i].samarea2 = data[i].field10
	rawarr[i].samarea3 = data[i].field11
	rawarr[i].rettime= data[i].field12
	rawarr[i].refarea1= data[i].field13 
	rawarr[i].refarea2  = data[i].field14
	rawarr[i].refarea3 = data[i].field15
	rawarr[i].refheight= data[i].field16
	rawarr[i].refratio1  = data[i].field17
	rawarr[i].samht = data[i].field18
	rawarr[i].samratio1 = data[i].field19
	rawarr[i].corrdelta1 = data[i].field20
	rawarr[i].corrdelta2 = data[i].field21
ENDFOR

;******************************	MODIFIED OUTPUT 01.06.2011!!!!!!!!!!!!!!!!!!!!!
;now, write it out!
;rawdir = '/projects/' + spec + '/flask/' + inst + '/raw/' + ayr[0] + '/'
rawfile = ayr[0]+'-'+amo[0]+'-'+ady[0]+'.'+ahr[0]+amn[0]+'.'+'ch4c13'
;outfile = rawdir+rawfile
;outfile='/home/ccg/isotopes/Jason/RawDelta1csvfilelist/testch4c13/' + rawfile ;JPW modified 01.06.2011


;IF testmode EQ 1 THEN BEGIN
;	IF csvgood EQ 1 THEN BEGIN
;		;rawdir = '/home/ccg/isotopes/Jason/cordel1rawfiles/'
;		 rawdir = '/home/ccg/isotopes/Jason/cordel1/rawfiles/'
;		 outfile = rawdir+rawfile
;	ENDIF ELSE BEGIN
;		;rawdir = '/home/ccg/isotopes/Jason/rawdel1rawfiles/'
;		 rawdir = '/home/ccg/isotopes/Jason/rawdel1/rawfiles/'
;		 outfile = rawdir+rawfile	
;	ENDELSE
		
;ENDIF ELSE BEGIN
		rawdir = '/projects/' + spec + '/flask/' + inst + '/raw/' + ayr[0] + '/'
		outfile = rawdir+rawfile	
;ENDELSE	


print,'file located at:', outfile

rawheader = '* Run Number: ' + origdata[0].field3
;lineformat = '(A4,A9,I5.4,4(I3.2),I3,A3,I9,2(F16.7),F10.1,I10,I10,F14.5,F16.12,F16.12,F10.6,F16.12,F10.4,F10.4)'
lineformat = '(A4,A10,I5.4,4(I3.2),I3,3(I12),1X,F5.1,3(I11),3(F10.4),F11.8,2(F10.4),A3)'

OPENW, u, outfile, /GET_LUN
PRINTF, u, rawheader
FOR i = 0, nlines-1 DO begin
	PRINTF, u, FORMAT = lineformat, rawarr[i]
ENDFOR

FREE_LUN,u

PRINT, 'Done constructing rawfile ', rawfile

END
