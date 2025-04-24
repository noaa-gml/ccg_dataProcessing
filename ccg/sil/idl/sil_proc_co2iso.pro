;;; run with file='004344.o1



;  BE AWARE:
;    twptcorr gets turned off and on. Currently OFF
;    must choose which reference.co2c13 file to use. Currently reference.J6.co2c13 = JRAS values
;    can choose d4546 or regular cal files
;    refstats file is currently not working (only prints current values)
;    trap files have also been tricky (printing refs)
;
; NAME: sil_proc_co2iso.pro
;
;
;
;
; PURPOSE:  	
;	Processes co2c13 raw files from Spock (CO2C13) and T'POL and PICARD
;	 also old and new data from Kirk (just co2 in air data so far).
;	THIS IS THE NEW CODE (11/09/06) that was used to reprocess all of the data
;	since 1990 to our new o18 scale. It replaces the old code
;	sil_proc_co2c13.nov06.pro. This code was previously named
;	sil_proc_co2o18.pro and was run from the scale.pro program.
;	EVEN NEWER version (2/13/07) allows you to crunch carbs, water, 
; 	and even use these as refs. This development is for the launching of Picard,
;	the super-calibrator. In addition to accomodating carbs and water, it has a 
;	new and improved drift correct and flagging scheme (in fact, the old scheme 
;	used in reprocessing didn't flag everything it should have. . .)
;	
;	GENERAL OUTLINE:
;		1) Read a raw file from the projects/co2c13/o1/raw/year or 
;		   i2/raw/year directory
;		2) Process the run
;		3) Calculate c13 and o18 values
;		4) QA/QC for data and flag when neccessary
;		5) Generate a file (or array) of event numbers +
;		   final values to be appended to CCG file.
;		6) Generate data/stats for diagnostic use by user
;		7) Update diagnostic files, do plots etc.
;	
; CATEGORY: 
;	Data processing
;	
; CALLING SEQUENCE: 
;	Can be executed from the command line
;	or evoked from Ken's SQL web-world.
;
; INPUTS:
;	Will require the name of the raw file, 
;	which is the compiled data from the mass spec
; 	produced by sil_raw_co2c13.pro
;
; OPTIONAL INPUT PARAMETERS:
;	printtanks - for reprocessing purposes, you may or may not want to write
;		to cylinder files
;.	reprintsil - you may or may not want to print sil flasks to the silflask
;		file (which does not look to see if it already exists
;	update - if 1, will go to the database
;		 if 0, it will look for printsitefile keyword
;		 	if printsitefile=1, will print to sitefiles in specified
;			dir
;			if printsitefile=0, won't do anything 
;			(if you're reprocessing to generate tank files, this is
;			faster)
;	uncertainty - will calculate stdev of last 10 runs of trap
;	pause - allows you to look at data to see if you want to proceed with
;		upload to database. (turn off when running in bulk)
;	log_data - allows you to print arrays as they are processed. useful when
;		tinkering with corrections
;	secposflags - applies a 'T' flag if the run had aberrant trap values
;			applies a P if precision was high
;			appies a third pos flag 'o' if there was no trap, or if the target value of
;			the trap wasn't available.
; OUTPUTS:
;	Originally written to generate reduced data to be
;	merged into site files and updates to files for tanks 
;	(stds + others).  Now an update program sends the 
;	network data to the data base with its unique event number.
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
;	YES!!! Run structure must have four references in every 
;	set and the trap tank must have four references and MUST
;	follow the second set of references.
;	HA! This is no longer the case as of 8/06! Mo betta!
;
; PROCEDURE:
;	Example:
;		. sil_proc_co2c13,d file =  '2005-01-01.1245.co2c13',/diagnostics
;		.
;		.
;
; MODIFICATION HISTORY:
;	Written, BHV, November, 2003
;   	Updated, BHV and VAC, April, 2004
;	To be put into use 8/30/04 first run number 001749.o1 and 000001.i2
;	Updated, VAC, March 2005 to correct calculations for flasks not followed 
;		by refs as in 001856.o1 and reran for 001856 only, next run number 
;		will be 001928.o1
;	Major overhaul by BHV and SRE fall 2006 to reprocess all data in the data base to an o18 scale
;	 	change. Improvements include any-length any-variety run structures, better
;		drift correction, better N2O and CO2 estimates for flasks without these
; 		data. . . in general, a heroic effort.
;	For the reprocessing, we looked up old flags to see if there was any information 
;		there that needed to be preserved. For instance, L flags in 3rd position 
;		or C flags from CBA in first position. Ken M. made us a special version of
;		CCG_FLASKUPDATE in order to do this. After reprocessing, we'll go back to the
;		regular version and take out (archive/comment out) this bit of code.	
;	Modified for general usage, Nov 10,2006 SRE. I changed the special 
;		ccg_flaskupdate_sil routine back to the conventional
;		ccg_flaskupdate. I also commented out the procedure to look up
;		old flags from site files (it is still in this code, but commented out.)
;	Changed ccg_flaskupdate to ccggdev_flaskupdate as per Dan Chao's request.
;		Jan 2007.
;	Changed back to ccg_flaskupdate June 2007 when cccgdev switch was completed. 
;	Features added to run carbs and waters, and also to use these as refs. Drift correct
;		and flagging modifications made. SRE 2/07	
;	Incorporated place to add temperature data for running carbs and waters Nov 2007 SREM.
;	Changed to new version of ccg_flaskupdate: enters parameter:value, instead of just a string. 11/2008 SREM
;
;	Added optional uncertainty measurement - can be turned on and off, but will mostly be off.. ..
;		in progress, June 2009
;	Updated old Craig correction (based on 1957 paper and measurements of 13R and 17R of pdb) to Brand,
;		Coplen, Assonov 2008 paper. Changes d13C values by about 0.02 permil (more negative). All of data
;		reprocessed from scale_17O program, 9/3/09. 
;	Added reprintsil keyword to have the option of not ammending sil data to silflasks.co2c13 file
;       Added uncertainty measurements and second position flags: 10/16/10 
;		second position flags include a 'P', if a sample has high internal precision
;					      a 'H', if the trap average is high for a run
;					      a 'L', if the trap value is low for a run
;					      a 'T', if the trap has high standard deviation
;		uncertainty is calculated as the standard deviation of the current run (whatever the flag) and the previous 9
;			unflagged (in first or second position) runs.			      
;		data now handled in the following order:
;			trap data
;			 -- uncertainty calculated
;			 trapstat files
;			 sil flasks
;			 carbs
;			 waters
;			 tank data
;			 ref data
;			 refstat files
;			 samples
;			 
;			 all of these have places for uncertainty to go, except for the ref, trap, refstat, and trapstat files
;	For cylinders, reprocessed data now overwrites old version of the data. It used to be that if the data existed for a run,
;		it would not be rewritten. Now it is overwritten, as in the database. This is NOT the case for silflasks or carb
;		files.			 		
;	July 2017 SLY added 2 pt correction capability. Eventually can be written instead of c13, or in addition to. .. maybe with
;	indication of which is used. HOWEVER, ALSO noticed slight error. .. 17O corrected values are not exactly what they should be! 
;	   There was a problem with the undo 17O correction code (still on Craig!) 
;	
;        now trying HUEY - using secref variable (but still call everything "lou")
;		cylinder data now printing to /projects/co2c13/calsJ6L  or */calsJ6H (depending on keyword) or */cals if twpt not available.
;	added ability to write 17O uncorrected files. To do this, had to move scale correction before correction to vpdb (thus, correcting
; 	to d45 and d46 of first and second refs, slope correcting, and then doing 17O correction to that
;	Made knobs so they can be tighter for data overhaul (thisc13knob)

;************************ VARIABLE DEFINITIONS ***********************
;			(in no particular order ...)
;	
;	nlines 			Total number of lines in the raw file to be processed
;*	nrefs			An integer that = the total number of REF's in a run.
;	refsets			DBLARR(ngroups)
;*	rlength			Number of total REF's, based on WHERE (type EQ 'REF', rlength)
;	refpos			A vector in a WHERE statement used to dimesnion nrefs with total # of refs in run
;	refs			Array [refpos]
;	refarr			Array of size nrefs. Contains all ref data needed, including flags...
;	refnum			refsets [i], where i = 
;*	refcount		Total number of refs
;	grouparr		Integer array, same length as nrefs that holds index number of the REF's
;				So, for 11 refs in one run, it might look like:(1,1,1,2,2,2,2,3,3,3,3)
;	ngroups			Integer number of ref sets (n_elements(UNIQ(grouparr))
;	cluster			Holds the number of REF's in each group. So,(3,4,4) in above example.
;
;
;
; *********************************************************************
; ----- INITIALIZATION ----------------------------------------------------------

PRO SIL_PROC_CO2ISO,     	$
	file = file, 		$
	inst = inst, 		$
	nomessages = nomessages,$
	diagnostics = diagnostics,$
	update = update,	$
	printsitefiles=printsitefiles,$
	printtanks=printtanks,	$
	log_data = log_data,	$
	thispause=thispause,		$
	uncertainty=uncertainty,$
	reprintsil=reprintsil,	$
	secposflags=secposflags,$
	secref=secref,		$
	twptcorr=twptcorr,	$
	jrasfile=jrasfile

extras=1

IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE, 'File must be specified'
	CCG_MESSAGE, "EXAMPLE : sil_proc_co2c13, file = '2005-01-01.1245.co2c13'"
ENDIF

PRINT,'-----------in reproc mode-------------------------------------------'

; ----- SET GLOBAL VARIBLES -----------------------------------------------------
; verbose : non zero = "on", zero = "off"
verbose = 0
error = 0
twptcorr=1
secref='youdecide'


sofp=0D
;important info that needs to be correct

noflasks=0 ; if zero, just reprocessing tanks. With noflasks=1, will go much faster. Will not update flasks or sitefiles
update=1  ; if one, data goes to DB
year=STRMID(file,0,4)
IF FIX(year) LT 2024 THEN reprocmode=1 ELSE reprocmode=0 ; will look for old flags
flagitall=0 ;USE THIS CAREFULLY!!! This allows you to flag all data in a run. Bad Amod data from 2019 are flagged automatically. See below. 	
calsdir='calsieg3'  ; important that you know where the tank data are going to! 
d4546tankfiles=0    ; allows you to remove n2o correction
; site file directories?
;calsdir='calsDH'

; some logic . ..
IF noflasks EQ 1 THEN update=0
IF noflasks EQ 1 THEN printsitefiles=0
IF NOT KEYWORD_SET(log_data) THEN log_data = 0
IF NOT KEYWORD_SET(reprintsil) THEN reprintsil = 0 
IF NOT KEYWORD_SET(uncertainty) THEN uncertainty=1
IF NOT KEYWORD_SET(printtanks) THEN printtanks=1


print,'twptcorr= ',twptcorr





getpressures=0  ; this gets the pressures from the raw data and sends them into tank files
		; if you want to use this, search for getpressures keywords and make small adjustments to arrays
	IF getpressures EQ 1 THEN calsdir=calsdir+'/pressure'


	;IF jrasfile EQ 'reference.j6.co2c13'THEN calsdir='calstst' 
	;IF jrasfile EQ 'reference.j62.co2c13'THEN calsdir='calstst2'   ;;;
	;IF jrasfile EQ 'reference.lj62.co2c13'THEN calsdir='calstst3' 
	;IF jrasfile EQ 'reference.sj62.co2c13'THEN calsdir='calstst4' 
	;IF jrasfile EQ 'reference.lsj62.co2c13'THEN calsdir='calstst5' 
	;;; as of 2/28/19
	;IF jrasfile EQ 'reference.scen1.co2c13' THEN calsdir='calscen1' 
	;IF jrasfile EQ 'reference.scen2.co2c13' THEN calsdir='calscen2' 
	;IF jrasfile EQ 'reference.scen3.co2c13' THEN calsdir='calscen3' 
	;IF jrasfile EQ 'reference.scen4.co2c13' THEN calsdir='calscen4' 
	;IF jrasfile EQ 'reference.co2c13'THEN calsdir='cals' 
	;IF jrasfile EQ 'rseference.jras06.co2c13' THEN calsdir='jrascals'  ;jcals should be exactly the same
	;;IF jrasfile EQ 'ref.jras06.co2c13' THEN calsdir='calsjras'
	;IF jrasfile EQ 'ref.jras06.co2c13' THEN calsdir='calsjras06'
	;IF jrasfile EQ 'ref.sieg.co2c13' THEN calsdir='calsieg2'      ; changed 09/22/23
	;IF jrasfile EQ 'ref.sieg.co2c13.062824' THEN calsdir='calsieg2'
	
print,'^^^^jrasfile = ',jrasfile
print,'^^^^calsdir = ',calsdir



IF d4546tankfiles EQ 1 THEN print,'***********17O CORRECTION IS TURNED OFF!!! PRINTING TO DIFFERENT FILES***************'

IF d4546tankfiles EQ 1 THEN BEGIN
	update=0   
	reprintsil=0
	calsdir='d4546'+calsdir
	
	thisc13knob=0.03
	thiso18knob=0.06
ENDIF ELSE BEGIN
	thisc13knob=0.04
	thiso18knob=0.08
ENDELSE




; ----- "KNOBS" that can be twiddled for global variables in this program ------
; Pair difference criteria:
; prior to 2004, limits were 0.09 and 0.15 for c13 and o18 respectively)

pdyear=FIX(STRMID(file,0,4))


CASE inst OF
	'r1': BEGIN
		c13pdlimit = 0.09
		o18pdlimit = 0.15
		c13reflimit = 0.075   ;   ******these values set 11-2-06 by BHV, SRE, &  JWCW !!!!
		o18reflimit = 0.14
	END
	'o1': BEGIN
		c13pdlimit = 0.06
		o18pdlimit = 0.12
		c13reflimit = thisc13knob
		o18reflimit = thiso18knob
	END	
	'i2': BEGIN
		c13pdlimit = 0.06
		o18pdlimit = 0.12
		c13reflimit = thisc13knob
		o18reflimit = thiso18knob
	END
	'i4': BEGIN
		c13pdlimit = 0.06
		o18pdlimit = 0.12
		c13reflimit = thisc13knob
		o18reflimit = thiso18knob
	END
	'i6': BEGIN
		c13pdlimit = 0.06
		o18pdlimit = 0.12
		c13reflimit = thisc13knob
		o18reflimit = thiso18knob
	END

ENDCASE	

; ----- READ IN RAW FILE -------------------------------------------------------
year = STRMID(file,0,4)
rawdir = '/projects/co2c13/flask/' + inst + '/raw/' + year + '/'
rawfile = rawdir + file

;missedfiles = '/home/ccg/isotopes/idl/prgms/proc/o18o17test/missedfiles'

; -----CHECK TO SEE IF THE FIRST LINE IS A REF - IF NOT, THEN DO NOT  PROCESS AND ABORT TO ERROR MSG -----
CCG_SREAD, file = rawfile, skip = 1, /nomessages, check
checktype=STRMID(check[0],1,3) 


CCG_READ, file = rawfile, skip = 1, /nomessages, arraw

nlines = N_ELEMENTS(arraw)
CCG_SREAD, file = rawfile, /nomessages, head
runnum = STRMID(head[0], 2, 6)
runnumber=FIX(runnum)
IF runnum EQ '9999' THEN BEGIN
	print, 'Kerstin, you are running the wrong code!'
	stop
ENDIF 

IF inst EQ 'i6' THEN BEGIN

	IF runnumber GE 643 and runnumber LE 680 THEN flagitall=1
	IF runnumber GE 643 AND runnumber LE 680 THEN donotask=1

ENDIF





; ----- READ IN TANK FILE INFORMATION FOR FUTURE USE ----------------------------
; INTERNAL TANKS

;; NOW reading JRAS version of reference.j6.co2c13'

PRINT, '**** using ',jrasfile
jtankfileI = '/projects/co2c13/flask/sb/'+jrasfile
tankfileI = '/projects/co2c13/flask/sb/reference.co2c13

temptankfileI = '/home/ccg/sil/tempfiles/tanktempI.'+inst+'.txt'

CCG_SREAD, file = tankfileI, skip = 0, stdarr, /nomessages
; Now get rid of all non-data lines in the file, and save it
m = WHERE(STRMID(stdarr,0,1) NE '#')
saved = stdarr[m]
CCG_SWRITE, file=temptankfileI, saved, /nomessages

CCG_READ, file=temptankfileI, refvals, /nomessages
CCG_READ, file=jtankfileI, jrefvals, /nomessages
; EXTERNAL TANKS   ( NO need to change this as it contains only co2 and n20 mixing ratios - no c13 or o18

;------- note!!! This is confusing:
;--------
;--------- 
	;We have a historical file that is full of wrong serial numbers and fill dates. This is reference_external.co2c13.091224
	;However, these 'WRONG' data have corresponding data in old files. These are the files in /flask/inst/transfer/*
	;The data MUST MATCH the reference_external file. 
	;The file reference_external.co2c13 now has correct info
	;Correct tank info are also in /flask/inst/newtransfer/csv_files
	; and /flask/inst/newraw/*

	; HOWEVER, if you are reprocessing old data using sil_proc_co2iso, you need the old tank info! This is confusing. 
	; I am going to get around this by either having old data in reference_external.co2c13 (I added the old ALtank info, for instance)
	; or I can point to a different tank file based on the year. 

IF fix(year) GT 2024 THEN BEGIN
	tankfileII = '/projects/co2c13/flask/sb/reference_external.co2c13'     ;****original file
ENDIF ELSE BEGIN
	tankfileII = '/projects/co2c13/flask/sb/reference_external.co2c13.091224'     ;****original file with incorrect tank names
ENDELSE

;temptankfileII = '/home/ccg/isotopes/idl/prgms/proc/tanktempII' 
temptankfileII = '/home/ccg/sil/tempfiles/tanktempII.'+inst+'.txt'

CCG_SREAD, file = tankfileII, skip = 2, stdarr, /nomessages
m = WHERE(STRMID(stdarr,0,1) NE '#')
saved = stdarr[m]
CCG_SWRITE, file = temptankfileII, saved, /nomessages
CCG_READ, file=temptankfileII, tankvals, /nomessages

;CARBONATES
;;crbfile = '/projects/co2c13/flask/sb/carbs.co2c13'
;tempcarbfile = '/home/ccg/isotopes/idl/prgms/proc/carbtemp' 
;tempcarbfile = '/home/ccg/sil/tempfiles/carbtemp.txt'

;CCG_SREAD, file = crbfile, skip = 2, stdarr, /nomessages
;m = WHERE(STRMID(stdarr,0,1) NE '#')
;saved = stdarr[m]
;CCG_SWRITE, file = tempcarbfile, saved, /nomessages
;CCG_READ, file=tempcarbfile, carbvals, /nomessages
 

 ;WATERS
;h2ofile = '/projects/co2c13/flask/sb/waters.co2c13'
;temph2ofile = '/home/ccg/isotopes/idl/prgms/proc/h2otemp' 
;CCG_SREAD, file = h2ofile, skip = 2, stdarr, /nomessages
;m = WHERE(STRMID(stdarr,0,1) NE '#')
;saved = stdarr[m]
;CCG_SWRITE, file = temph2ofile, saved, /nomessages
;CCG_READ, file=temph2ofile, h2ovals, /nomessages

; first take out ETA lines. They will mess up drift correction, assumption of where sample pos are.
 etafile='/home/ccg/sil/etacalcs/eta_'+inst+'.txt'
lineformat = '(A8, A4,A10,I5,6(I3),E9.2,F10.3,F10.3,I3,F10.3,F10.3,I3,F6.1,2(I5))'

heretheyare=WHERE(arraw.field1 EQ 'ETA',neta)
IF heretheyare[0] NE -1 THEN BEGIN
	;first move the data
	
	 OPENW, u, etafile, /GET_LUN,/append
 		
 		; this doesn't look to see if you've run this before. can either make this smarter or clean up later ...
		
 		FOR i = 0,neta-1 DO PRINTF, u, FORMAT = lineformat, runnum, arraw[heretheyare[i]].field1, arraw[heretheyare[i]].field2, arraw[heretheyare[i]].field3,$
		arraw[heretheyare[i]].field4, arraw[heretheyare[i]].field5, arraw[heretheyare[i]].field6,$
		arraw[heretheyare[i]].field7, arraw[heretheyare[i]].field9, arraw[heretheyare[i]].field10,$
		arraw[heretheyare[i]].field14, $   ;beam size
		arraw[heretheyare[i]].field15, arraw[heretheyare[i]].field16, arraw[heretheyare[i]].field17, $
		arraw[heretheyare[i]].field18, arraw[heretheyare[i]].field19,arraw[heretheyare[i]].field20, $
		arraw[heretheyare[i]].field21,arraw[heretheyare[i]].field22, arraw[heretheyare[i]].field23				
 	FREE_LUN,u
	
	; if it starts with eta, chop
	FOR j=0,nlines-1 DO BEGIN
		IF arraw[0].field1 EQ 'ETA' THEN BEGIN
			arraw=arraw[1:nlines-1]
			nlines=N_ELEMENTS(arraw)
		ENDIF ELSE BEGIN
			j=j+nlines
		ENDELSE	
	ENDFOR
	nlines=N_ELEMENTS(arraw)
	
	;now remove any ETA's within the run and replace with BOG	
	heretheyare=WHERE(arraw.field1 EQ 'ETA')
	IF heretheyare[0] NE -1 THEN arraw[heretheyare].field1='BOG'
ENDIF 



; ----- MAPPING SINGLE FIELD ARRAYS ---------------------------------------------
type	  = STRARR(nlines)	; Sample type (SMP, REF, STD,TRP, SIL )
enum	  = STRARR(nlines)	; Event number
site   	  = STRARR(nlines)	; Three letter site code
yr	  = DBLARR(nlines)	; Sample year
mo        = DBLARR(nlines)	; Sample month
dy        = DBLARR(nlines)	; Sample dayOPENR, unit, file, /GET_LUN
hr        = DBLARR(nlines)	; Sample hour
mn        = DBLARR(nlines)	; Sample minute
id        = STRARR(nlines)	; Flask id 
meth      = STRARR(nlines)	; Sample method
num       = INTARR(nlines)	; Sample number in the run 
d45       = DBLARR(nlines)	; Delta 45 value
prec45    = DBLARR(nlines) 	; Stdev on Delta 45
d46       = DBLARR(nlines)	; Delta 46 value
prec46    = DBLARR(nlines)	; Stdev on Delta 46
samtemp   = DBLARR(nlines)	; temp of carbs
strategy  = STRARR(nlines)	; strategy (pfp or flask)
airpressure  = DBLARR(nlines)	; strategy (pfp or flask)
co2pressure  = DBLARR(nlines)	; strategy (pfp or flask)
tagarr    = STRARR(nlines)


; -----------------FILL SINGLE FIELD ARRAYS WITH DATA FROM arr.*----------------
FOR i=0, nlines-1 DO BEGIN
	type[i]= arraw[i].field1
	;enum[i] = STRMID(arraw[i].str, 8,6)
	enum[i]= arraw[i].field2
	;print, 'Event number is: ',enum[i]
;-------- TYPE = 'SMP' ----------------------	
	IF type[i] EQ 'SMP' THEN BEGIN
		IF noflasks EQ 1 THEN BEGIN   ; this just gives bogus flask values so you save time. Not normally in use.
			site[i]   = 'xxx'
			yr[i]     = 1988
			mo[i]     = 01
			dy[i]     = 01
			hr[i]     = 01
			mn[i]     = 01
			id [i]    = 01
			meth[i]   = 'x'
			strategy[i] = 'flask'
		
		ENDIF ELSE BEGIN
			CCG_FLASK, evn=enum[i], strategy='flask',/nomessages,arr

			goodenum = SIZE(arr)
			IF goodenum[0] NE 0 THEN BEGIN
				site[i]   = arr.code 
				yr[i]     = arr.yr
				mo[i]     = arr.mo
				dy[i]     = arr.dy
				hr[i]     = arr.hr
				mn[i]     = arr.mn
				id [i]    = arr.id
				meth[i]   = arr.meth
				strategy[i] = 'flask'
			ENDIF ELSE BEGIN
			CCG_FLASK, evn=enum[i], strategy='pfp',/nomessages,arr
			goodenum = SIZE(arr)
				IF goodenum[0] NE 0 THEN BEGIN
					site[i]   = arr.code 
					yr[i]     = arr.yr
					mo[i]     = arr.mo
					dy[i]     = arr.dy
					hr[i]     = arr.hr
					mn[i]     = arr.mn
					id [i]    = arr.id
					meth[i]   = arr.meth
					strategy[i] = 'pfp'
			
				ENDIF ELSE BEGIN
				
					Print,'Missing valid event numbers. Skipping: ', file 
					OPENU, u, missedfiles, /APPEND,/GET_LUN		
					PRINTF, u, file,'   ...Missing valid event numbers'
					FREE_LUN, u
					GOTO, bomb
				ENDELSE	
			ENDELSE
		ENDELSE
	ENDIF			
	
	IF type[i] EQ 'BOG' THEN BEGIN
			site[i]   = 'BOG'
			yr[i]     = 9999	
			mo[i]     = 99
			dy[i]     = 99
			hr[i]     = 99
			mn[i]     = 99
			id [i]    = 'xx'
			meth[i]   = 'x'
			strategy[i] = 'nuthin'
		
	ENDIF	
;-------- TYPE = 'SIL' ----------------------	

       IF type[i] EQ 'SIL' THEN BEGIN    
		CCG_READ, file='/projects/co2c13/flask/sb/sil_eventnum.txt', $
				delimiter=' ', /nomessages, silevnum
				;sil eventnum in file will match what is in the raw file.
				
			samdata = WHERE(silevnum.field1 EQ enum[i])
			IF samdata[0] NE -1 THEN BEGIN ; YES -ITS IN THE sil_eventnum.txt - GET THE DATES
				type[i]	='SIL' 
				site[i]	=silevnum[samdata].field2
				yr[i]	=silevnum[samdata].field5
				mo[i]	=silevnum[samdata].field6
				dy[i]	=silevnum[samdata].field7
				mn[i] 	=0
				id[i]	=silevnum[samdata].field3
				meth[i]	=silevnum[samdata].field4
				strategy[i] = 'sil'
			ENDIF ELSE BEGIN    ;------NOPE, NOT IN sil_eventnum.txt ....SO SET TO ZEROS ?
				PRINT,'NOT in list. '  ; I don't want this to happen, so
				goto, justskip
						
				type[i]	='SIL' 
				site[i]	='UNK'
				yr[i]	=0
				mo[i]	=0
				dy[i]	=0
				mn[i] 	=0
				id[i]	=0-00
				meth[i]	='u'
				justskip:
			ENDELSE	
	ENDIF
;-------- TYPE = 'STD' 'REF' or 'TRP' or 'SRF'   ----------------------	
       IF (type[i] EQ 'STD') OR (type[i] EQ 'REF') OR  (type[i] EQ 'TRP') OR  (type[i] EQ 'SRF') THEN BEGIN

		count = WHERE(refvals.field1 EQ enum[i]) ; ---FOR INTERNAL TANKS (reads reference.co2c13)
	
		IF (count[0] NE -1) THEN BEGIN
	
			site[i]   = 'STD' 
			yr[i]     = refvals[count].field3
			mo[i]     = refvals[count].field4
			dy[i]     = refvals[count].field5
			hr[i]     = 00
			mn[i]     = 00
			id [i]    = enum[i]
			meth[i]   = refvals[count].field6
			strategy[i] = 'tank'
		ENDIF ELSE BEGIN 
		
			count = WHERE(tankvals.field1 EQ enum[i],ncount); ----FOR EXTERNAL TANKS  (reads reference_external.co2c13)
			
			IF (count[0] NE -1)THEN BEGIN	
			ourtanks=tankvals[count]	
				;--this is where we have to deal with a cylinder that has multiple fill dates. 
				;--turn the cylinder fill date information and compare them to the analysis date.
				
				IF ncount GT 1 THEN BEGIN
				
				;--------create an array with ncount positions
				filldatechart=findgen(ncount)
				
					FOR fill=0,ncount-1 DO BEGIN
					;--------fill the positions with the dates
						;filldatechart(0,fill) = fill	
						CCG_DATE2DEC, yr=ourtanks[fill].field2,mo=ourtanks[fill].field3,$
						dy=ourtanks[fill].field4,mn=00,dec=filldate 
						filldatechart[fill] = filldate
					ENDFOR
					
					; make sure the dates are in order
					order=SORT(filldatechart)
					filldatechart=filldatechart[order]
					;now reorder ourtanks to the same order
					ourtanks=ourtanks[order]
					CCG_DATE2DEC, yr=arraw[i].field3,mo=arraw[i].field4,dy=arraw[i].field5,mn=00,dec=adate
				
				; SRE's method was to count backward on filldatechart (using ncount-1-0, ncount-1-1, etc)
				; to find the tank that is earlier than your adate (which is why dates need to
				; be sorted)
					FOR time=0, ncount-1 DO BEGIN
						IF adate GT filldatechart[ncount-1-time] THEN BEGIN
							truefilldate =filldatechart[ncount-1-time]
							correcttank=ncount-1-time
							time=time+10 ; bumps you out of loop
						ENDIF 
					ENDFOR
			
					site[i]   = 'STD' 
					yr[i]     = ourtanks[correcttank].field2
					mo[i]     = ourtanks[correcttank].field3
					dy[i]     = ourtanks[correcttank].field4
					hr[i]     = 00
					mn[i]     = 00
					id [i]    = enum[i]
					meth[i]   = ourtanks[correcttank].field5
					strategy[i] = 'tank'
					
				
				ENDIF ELSE BEGIN
				
				
				; if ncount=1 do this:
					site[i]   = 'STD' 
					yr[i]     = tankvals[count].field2
					mo[i]     = tankvals[count].field3
					dy[i]     = tankvals[count].field4
					hr[i]     = 00
					mn[i]     = 00
					id [i]    = enum[i]
					meth[i]   = tankvals[count].field5
					strategy[i] = 'tank'
				ENDELSE

			ENDIF ELSE BEGIN
			
			ENDELSE		
		ENDELSE
		
	ENDIF

	;------- ALL TYPES GET THEIR MS DATA LOADED UP
	num[i]    = arraw[i].field9  
	d45[i]    = arraw[i].field15
	prec45[i] = arraw[i].field16
	d46[i]    = arraw[i].field18
	prec46[i] = arraw[i].field19
	;airpressure[i]=arraw[i].field21
	;co2pressure[i]=arraw[i].field11

ENDFOR  ;  (i loop for all lines )


IF(verbose EQ 1) THEN PRINT, 'Processing:  ', file 
IF (log_data EQ 1) THEN BEGIN
	
	logc13=REPLICATE({name:'',$
	raw:0.0,$
	n2o:0.0,$
	co2:0.0,$
	coef1:0.0,$
	coef2:0.0,$
	coef3:0.0,$
	ie:0.0,$
	ncorfact:0.0,$
	ncorvals:0.0,$
	dcorvals:0.0,$
	pdbvals:0.0,$
	twptpdbvals:0.0,$
	newccorvals:0.0,$
	twptnewccorvals:0.0,$
	unc:0.0,$
	newunc:0.0},nlines)
	
	logo18=logc13
	
	
	clogfile='/home/ccg/sil/tempfiles/c13datalog_jras'+file
	ologfile='/home/ccg/sil/tempfiles/o18datalog_jras'+file
	
	logc13.name=arraw.field2
	logo18.name=arraw.field2
	logc13.raw=d45
	logo18.raw=d46

ENDIF

; ----- CREATE/IDENTIFY FIELDS IN  ARRAY TO WORK FROM ---------------------------
ayear = arraw[0].field3   ; WE'RE GETTING THE TIME FROM THE FIRST LINE ONLY...
amon = arraw[0].field4
aday = arraw[0].field5
ahour = arraw[0].field6
amin = arraw[0].field7
asec = arraw[0].field8

; ----- OUTLINE OF NEXT SECTIONS FOR PROCESSING FILES ---------------------------
; 1.) Find CO2 and N2O values for each sample, and REF
; 2.) Determine correction factors 
; 3.) Apply N2O/CO2 correction factors to each analysis
; 4.) Identify  REF gas analyses
	; discard 1st of each set
	; ave & stdev of each set + all. 
; 5.) Drift correction. (determine factor, and apply)
; 6.) Apply 17O Correction 
; 7.) Convert to PDB values
; 8.) Determine if run meets QA/QC criteria, flag as needed.
; 9.) Determine pairs, their pair agreement, flag as needed. 
; 10.) Data now ready for ingestion by CCG.  
; 11.) Diagnostics and plots for run and ref tank....
; 12.) Relax and have beer...

 
 
; ------------------- FIND N2O AND CO2 MIXING RATIOS FOR THE REF TANK IN THE RUN ------------
;
; For n2o/co2 corrections the equations look like...
; for d45, =((d45/1000+1)/(n2o correction factor/1000-1))*1000
; for d46, =((d46/1000+1)/(n2o correction factor/1000-1))*1000
; resulting in an array called *ncorvals*
; Default values will be used where actual values are not available
;	See "Knob section" above

ncorvals = REPLICATE ({d45:0.0D,d46:0.0D},nlines)
;IF (verbose EQ 1) THEN PRINT ,'Finding N2O and CO2 values...'
			
;---Work around for when REF's are not run first. 
;find where refs in the run are.  match with tanks in refval. then get n2o and co2 values.
; and assign IF they already don't have values.
refpos = WHERE(type EQ 'REF', rlength,complement=otherthanref)
IF otherthanref[0] EQ -1 THEN goto,bailout

;IF type[0] EQ 'CRF' THEN refpos = WHERE(type EQ 'CRF', rlength)
;IF type[0] EQ 'HRF' THEN refpos = WHERE(type EQ 'HRF', rlength)
	IF refpos[0] EQ -1 THEN goto, getout
	IF (refpos[0] NE -1) THEN refs = arraw[refpos] ; now refs has just the ref data

CASE type[refpos[0]] OF
	'REF' : BEGIN
	rcount = WHERE(jrefvals.field1 EQ refs[0].field2)
		refn2o = jrefvals[rcount].field9
		refco2 = jrefvals[rcount].field8

		IF refco2 LT 0 THEN BEGIN
			print, 'running default co2 for ref tank'
			DEFAULTCO2, site='nwr',yr=refs[0].field3, mo=refs[0].field4, dy=refs[0].field5, co2temp
		    	refco2 = co2temp
		ENDIF	
		
		IF refn2o LT 0 THEN BEGIN
		print,'getting n2o for ref tank'
			DEFAULTN2O, site='nwr',yr=refs[0].field3, mo=refs[0].field4, dy=refs[0].field5, n2otemp
		    	refn2o = n2otemp
		ENDIF	
		
			
		ref = refs[0].field2
		;keep this critical ref data for later 
		ourref = jrefvals[rcount]
		print,'our ref = ',ourref.field1
		refd45 = ourref.field10   ;pre-Craig corrected value)
		refd46 = ourref.field11
		
		IF ref EQ 'CARR-002' THEN BEGIN
			driftstart=2018.6
			;find the date
			; starting with 4091
			lastslash=STRPOS(rawfile,'/',/REVERSE_SEARCH)
			runyr=STRMID(rawfile,lastslash+1,4)
			runmo=STRMID(rawfile,lastslash+6,2)
			rundy=STRMID(rawfile,lastslash+9,2)
			CCG_date2dec,yr=runyr,mo=runmo,dy=rundy,dec=dec

			IF dec GT driftstart THEN BEGIN
			ccarrfile='/home/ccg/michel/refgas/carrdrift.co2c13
			ocarrfile='/home/ccg/michel/refgas/carrdrift.co2o18
			CCG_READ,file=ccarrfile,ccarrdrift
				refd13 = ourref.field12   
				refd18 = ourref.field13
			
			adddriftc=WHERE(dec GT ccarrdrift.field1,nadd)
			cadjust=ccarrdrift[adddriftc[nadd-1]].field2
			adjustedc=refd13-ccarrdrift[adddriftc[nadd-1]].field2
		
			CCG_READ,file=ocarrfile,ocarrdrift
			
			adddrifto=WHERE(dec GT ocarrdrift.field1,naddo)
			oadjust=ocarrdrift[adddrifto[naddo-1]].field2
			
			adjustedo=refd18-ocarrdrift[adddrifto[naddo-1]].field2
			
			; now get adjusted d45 and d46 values
				thirteenRvpdb=0.011180D
			seventeenRvpdb=0.0003931D
			eighteenRvpdb=0.00208835D
			lamda=0.528D
			fortyfiveR=0.0119662   ;r13+2r17
			fortysixR=0.00418564   ;2r18+2r13r17+r17^2
			k_factor=seventeenRvpdb/(eighteenRvpdb^lamda)
			
				r13 = ((adjustedc/1000)+1)*(thirteenRvpdb)   ; turning delta value into ratio			
				r18 = ((adjustedo/1000)+1)*(eighteenRvpdb)   ; turning delta value into ratio		
				ratio46=r18*2D
				
				r17=k_factor*(r18^lamda)
				ratio45=r13+(2D*r17)
				ratio46=r18*2D
				
			v=0
			trial=1D
			WHILE ABS(trial) GT 0.0000000001 DO BEGIN
				
				;trial=(-3.0D * k_factor^2 * (eighteenRvpdb^(2*lamda)))+(2.0D * k_factor * ratio45 * eighteenRvpdb^lamda)+(2.0D*eighteenRvpdb)-(ratio46)
				trial=(-3.0D * k_factor^2 * (r18^(2*lamda)))+(2.0D * k_factor * ratio45 * r18^lamda)+(2.0D*r18)-(ratio46)
				ratio46=ratio46+trial/2
			v=v+1
			print,v
			ENDWHILE
		refd45=((ratio45/fortyfiveR)-1.0) * 1000.0
		refd46=((ratio46/fortysixR)-1.0)*1000.0
		
			ENDIF
	
		ENDIF


		IF refd45 LT -900 THEN stop  ;;;goto, notthisref
		END
	
	'CRF' : BEGIN
		rcount = WHERE(carbvals.field1 EQ refs[0].field2)
			refn2o = 0
			refco2 = 0
			ref = refs[0].field2
			ourref = carbvals[rcount]
			refc13 = ourref.field9    ; this is basically obsolete for now
			refo18 = ourref.field10
	END
	;'HRF' : BEGIN
	;	rcount = WHERE(h2ovals.field1 EQ refs[0].field2)
	;	IF (rcount NE -1) THEN BEGIN
	;		refn2o = 0
	;		refco2 = 0
	;		ref = refs[0].field2
	;		ourref = h2ovals[rcount]
	;		refc13 = ourref.field9
	;		refo18 = ourref.field10
	;	ENDIF
	;END
	
ENDCASE		
	
; --------------------------- Loop through the whole analysis list, -----------------------------------
; ------------------- Determine REF/STD/'other' 3 letter code, act accordingly ------------------------
;
co2list=DBLARR(nlines)
n2olist=DBLARR(nlines)
ncorfactarr45=DBLARR(nlines)
ncorfactarr46=DBLARR(nlines)


FOR i=0,nlines-1 DO BEGIN ; (eg. REF, TRP, STD, SIL, SMP)
	n2ocorr=1   ; assume that you're doing n2o correction   ; it will get changed if not. But really we are always doing it ...
	CASE site[i] OF 
	; ----- Find n2o and co2 values for the all tanks in the run -------------
	;'REF':  BEGIN
	;	co2=refco2
	;	n2o=refn2o
	;END 
	'STD':  BEGIN ; -- Looking in files for external tank values------

		count = WHERE(tankvals.field1 EQ id[i] AND $
		   tankvals.field2 EQ yr[i] AND $
		   tankvals.field3 EQ mo[i] AND $
		   tankvals.field4 EQ dy[i])
		
		;used to be 8,9 below, now 7, 8. fixed 8/3/05 sre
		IF (count[0] NE -1)THEN BEGIN	
		   co2 = tankvals[count].field7
		   n2o = tankvals[count].field8
		
			; if the values are  -999 or 0, then use default values
			IF (co2 LT 1) THEN BEGIN
		          
			   ; can look it up in data base
				
			;CCG_CAL, id=id[i],sp='co2',/ret,co2vals
			;here=size(co2vals) 
			here=0   ;(skipping this for now)
			IF here[0] EQ 0 THEN goto, nexttryco2
				
				nco2=N_ELEMENTS(co2vals)
				co2dates=FLTARR(nco2)
				FOR c=0,nco2-1 DO BEGIN
					CCG_DATE2DEC,yr=co2vals[c].yr,co2vals[c].mo,co2vals[c].dy,dec=dec
					co2dates[c]=dec
				ENDFOR
				CCG_DATE2DEC, yr=tankvals[count].field2,mo=tankvals[count].field3,dy=tankvals[count].field4,dec=dec
					filldate=dec	
					this=WHERE(co2vals GT filldate,nthisco2)
				IF nthisco2 EQ 1 THEN BEGIN
					IF (co2dates[0]-filldate) LT 1 THEN co2=co2vals[0].value ELSE goto,nexttryco2   ; if the tank was measured within a year of fill, use this. otherwise use default
				ENDIF ELSE BEGIN			
					co2mo=MOMENT(co2vals[this].value,sdev=sdev)
					co2=co2mo[0]
					IF sdev LT 2 then GOTO, ontonext
				ENDELSE
				
				nexttryco2:
				   print,'getting co2 for tank = ',id[i]
		   		DEFAULTCO2, site='nwr',yr=yr[i], mo=mo[i], dy=dy[i], co2temp
		    		co2 = co2temp
				IF co2 LT 0 THEN stop
		   	ENDIF
		   	ontonext:
		   
		   	IF (n2o LT 2) THEN BEGIN
		   	;print,enum[i]
		
		   	print,'getting n2o for tank = ',id[i]
			;CCG_CAL, id=id[i],sp='n2o',/ret,n2ovals
			;here=size(n2ovals) 
			
			here=0   ;(skipping this for now)
			IF here[0] EQ 0 THEN goto, nexttryn2o
				
				nn2o=N_ELEMENTS(n2ovals)
				n2odates=FLTARR(nn2o)
				FOR c=0,nn2o-1 DO BEGIN
					CCG_DATE2DEC,yr=n2ovals[c].yr,mo=n2ovals[c].mo,dy=n2ovals[c].dy,dec=dec
					n2odates[c]=dec
				ENDFOR
				CCG_DATE2DEC, yr=tankvals[count].field2,mo=tankvals[count].field3,dy=tankvals[count].field4,dec=dec
					filldate=dec	
					this=WHERE(n2odates GT filldate,nthisn2o)
				IF nthisn2o EQ 1 THEN BEGIN
					IF (n2odates[0]-filldate) LT 1 THEN n2o=n2ovals[0].value ELSE goto,nexttryn2o   ; if the tank was measured within a year of fill, use this. otherwise use default
				ENDIF ELSE BEGIN
					n2omo=MOMENT(n2ovals[this].value,sdev=sdev)
					n2o=n2omo[0]
					print, 'got n2o from ccg_cal'
					print,'n2o = ',n2o
					IF sdev LT 2 then GOTO, ontonextone
					stop  ; if sdev is not low then you might have multiple tankfills
				ENDELSE
				
				
				nexttryn2o:
				
		   		DEFAULTN2O, site='nwr',yr=yr[i], mo=mo[i], dy=dy[i], n2otemp
		   		n2o = n2otemp
		   	ENDIF 
		   	ontonextone:
		   	IF(verbose EQ 1) THEN PRINT, 'Co2/n2o values for: ', $
		   	id[i],co2,n2o
		ENDIF ELSE BEGIN  ; TANK is not found in external tank files, so it must be internal tank
		   	count = WHERE(refvals.field1 EQ id[i] AND $
		   	refvals.field3 EQ yr[i] AND $
		   	refvals.field4 EQ mo[i] AND $
		   	refvals.field5 EQ dy[i])
		
		   	IF (count[0] NE -1)THEN BEGIN	
				co2 = refvals[count].field8
				n2o = refvals[count].field9
				; if the values are  -999 or 0, then use default values  
				IF (co2 LT 1) THEN BEGIN
					
				print,'getting co2 for internal std tank'
		   		print,id[i]
				
				DEFAULTCO2, site='nwr',yr=yr[i], mo=mo[i], dy=dy[i], co2temp
		    		co2 = co2temp
				IF co2 LT 0 THEN stop
		   	ENDIF
			IF (n2o LT 2) THEN BEGIN
		   		print,id[i]
				print,'getting n2o for internal std tank'
				
				DEFAULTN2O, site='nwr',yr=yr[i], mo=mo[i], dy=dy[i], n2otemp
		   		n2o = n2otemp
		
			ENDIF
			
		   ENDIF ELSE BEGIN
			PRINT, 'Error locating values n2o and co2 for STD tank ', id[i]
 	      		errorflag = 1
		   ENDELSE
		ENDELSE

	 	
	END  ; case 'STD'
	
	; -------------------------------
	'BOG' : BEGIN
		n2o=100
		co2=100
	END
	
	'CRB' : BEGIN
		n2o=0
		co2=0
	END
	
	
	'CRF' : BEGIN
		n2o=0
		co2=0
	END
	
	'H2O' : BEGIN
		n2o=0
		co2=0
	END
	
	'HRF' : BEGIN
		n2o=0
		co2=0
	END
	ELSE:	BEGIN   ;flask
		
		IF type[i] NE 'SIL' THEN BEGIN
			
			IF noflasks EQ 1 THEN BEGIN
				n2o=320
				co2=400 ;; default values for faster processing of tankfiles
				
			ENDIF ELSE BEGIN	
				; N2O bit -------------------------
				CCG_FLASK, sp='n2o', evn=[enum[i]],/ret, /nomessages, n2oarr
				n2oexist = SIZE(n2oarr)
				        IF n2oexist[0] NE 0 THEN BEGIN
					nn2o= N_ELEMENTS(n2oarr)
					IF nn2o GT 1 THEN BEGIN   ;  looks like there is more than one n2o value
						goodn2o = MOMENT(n2oarr.value)
						n2o = goodn2o[0]
					ENDIF ELSE BEGIN  ; just one, so take that n2o value
						n2o = n2oarr.value
					ENDELSE
				ENDIF ELSE BEGIN
	
				;print,'running defaultN2O code for flask number ',id[i]
				
					;print,'getting n2o for network flask'
					DEFAULTN2O, site=site[i],yr=yr[i], mo=mo[i], dy=dy[i], n2otemp
	   				n2o = n2otemp
				ENDELSE
			
				;;FOR MSC sites which do not have N2O, do this.	
				;	IF site[i] EQ 'MSC' THEN BEGIN
				;		n2o=0
				;	ENDIF 
			
		
				; CO2 bit -------------------------
			
				CCG_FLASK, sp='co2', evn=[enum[i]],/ret, /nomessages, co2arr
				co2exist = SIZE(co2arr)
			        IF co2exist[0] NE 0 THEN BEGIN
					nco2= N_ELEMENTS(co2arr)
					IF nco2 GT 1 THEN BEGIN   ;  looks like there is more than one co2 value
						goodco2 = MOMENT(co2arr.value)
						co2 = goodco2[0]
					ENDIF ELSE BEGIN  ; just one, so take that co2 value
						co2 = co2arr.value
					ENDELSE
				ENDIF ELSE BEGIN
					;print,'running defaultCO2 code for flask ',id[i]
					DEFAULTCO2, site=site[i],yr=yr[i], mo=mo[i], dy=dy[i], co2temp
		  				co2 = co2temp
						IF co2 LT 0 THEN stop
				ENDELSE
			ENDELSE
			
		ENDIF ELSE BEGIN ; must be SIL flask
			IF reprintsil EQ 1 THEN BEGIN
			
				IF samdata[0] NE -1 THEN BEGIN
					IF silevnum[samdata].field4  EQ 'c' THEN isitpure=1 ELSE isitpure=0
					IF isitpure EQ 1 THEN BEGIN
						n2o=0
						co2=400 ;this is a bogus number 
						goto, skiptherest
					ENDIF 
					
					;IF n2ocorr EQ 0 THEN BEGIN
					;	n2o=0
					;	goto, skipn2ocorr
					;ENDIF
					silco2=silevnum[samdata].field8	
						
					IF silco2 GE 0.0 THEN BEGIN
						co2=silco2
					ENDIF ELSE BEGIN
						print, 'running default co2 for SIL flask',id[i]
						
						DEFAULTCO2,site='NWR',yr=yr[i], mo=mo[i], dy=dy[i], co2temp
						co2=co2temp
					ENDELSE
					siln2o=silevnum[samdata].field9
				
					IF siln2o GE 0.0 THEN BEGIN
						n2o=siln2o
					ENDIF ELSE BEGIN
						
						print, 'running default n2o for SIL flask'
						print,id[i]
						print,'getting n2o for sil flask'
						DEFAULTN2O,site='NWR',yr=yr[i], mo=mo[i], dy=dy[i], n2otemp
						n2o=n2otemp
					ENDELSE
					;skipn2ocorr:
				ENDIF ELSE BEGIN
					print,id[i], 'is not in the sil flask list'
					
					DEFAULTCO2,site='NWR',yr=yr[i], mo=mo[i], dy=dy[i], co2temp
					co2=co2temp
					print, 'running default co2'
					print,id[i]
					DEFAULTN2O,site='NWR',yr=yr[i], mo=mo[i], dy=dy[i], n2otemp
					n2o=n2otemp
					print, 'running default n2o - sil flask not found in file'
				
				ENDELSE
			ENDIF ELSE BEGIN
				n2ocorr=0
				n2o=320
				co2=400
			ENDELSE
		ENDELSE
		skiptherest:
	
	END  ; case 'ELSE'
	
	ENDCASE
	;********* These were the original terms in equations that looked like this:
	;corfactd45=(((1+coef1*n2o/co2)/(1+coef2*n2o/co2))/ $                   
		;			((1+coef1*refn2o/refco2)/(1+coef2*refn2o/refco2))-1)*1000        ;					
	;coef1=0.0004965D    ; these are the 'original' values.. "coefficient of iso abundance" times ie. 
	;coef2=0.0007585D    ; these are the 'original' values	
	;coef3=0.0003822D       ; these are the 'original' values
	;Now I'm going to separate probability term from ie.
	;corfactd45=(((1+coef1*ie*n2o/co2)/(1+coef2*ie*n2o/co2))/ $                   
	;				((1+coef1*ie*refn2o/refco2)/(1+coef2*ie*refn2o/refco2))-1)*1000        ;	
	; ie=0.7644D this is the 'assumed' ie based on coefficients and data used for probability
	ie=0.75 ;(some lower bound)
	;coef1=coef1/ie
	;coef2=coef2/ie
	;coef3=coef3/ie   ; test to make sure code works.
	
	coef1=0.000663404218D   ; these are new values based on logic that Pieter confirmed; Dewy as standard used in probability calculations
	coef2=0.00100728011D
	coef3=0.0005D

	
		IF n2ocorr EQ 1 THEN BEGIN   ; this looks for the c in the sil_eventnumfile
			
			;	corfactd45=(((1+coef1*n2o/co2)/(1+coef2*n2o/co2))/ $                     ; these are the 'original' values
			;		((1+coef1*refn2o/refco2)/(1+coef2*refn2o/refco2))-1)*1000        
			
				corfactd45=(((1+coef1*ie*n2o/co2)/(1+coef2*ie*n2o/co2))/ $                   
					((1+coef1*ie*refn2o/refco2)/(1+coef2*ie*refn2o/refco2))-1)*1000 
				ncorvals[i].d45=((d45[i]/1000+1)/(corfactd45/1000+1)-1)*1000
			
				; Do calculations for d46:
			;	corfactd46=(((1+coef3*n2o/co2)/(1+coef2*n2o/co2))/ $
			;		((1+coef3*refn2o/refco2)/(1+coef2*refn2o/refco2))-1)*1000
					
				corfactd46=(((1+coef3*ie*n2o/co2)/(1+coef2*ie*n2o/co2))/ $
					((1+coef3*ie*refn2o/refco2)/(1+coef2*ie*refn2o/refco2))-1)*1000
			
			 
				ncorvals[i].d46=((d46[i]/1000+1)/(corfactd46/1000+1)-1)*1000
		ENDIF ELSE BEGIN
				ncorvals[i].d45=d45[i]
				ncorvals[i].d46=d46[i]
				corfactd45=0
				corfactd46=0
		ENDELSE
	
co2list[i]=co2
n2olist[i]=n2o


ncorfactarr45[i]=corfactd45
ncorfactarr46[i]=corfactd46


ENDFOR


IF (log_data EQ 1) THEN BEGIN
	logc13.n2o=n2olist
	logc13.co2=co2list
	logc13.ncorfact=ncorfactarr45
	logc13.ncorvals=ncorvals.d45
	logo18.n2o=n2olist
	logo18.co2=co2list
	logo18.ncorfact=ncorfactarr46
	logo18.ncorvals=ncorvals.d46
	logc13.coef1=coef1
	logc13.coef2=coef2
	logc13.ie=ie
	logo18.coef3=coef3
	logo18.coef1=coef1
	logo18.ie=ie
ENDIF


; ----------END SECTION TO FIND N2O AND CO2 VALUES AND CALC d45 d46 ------------------------

; ----------
; So, n2o/co2 corrected values are now in the array: "ncorvals" (n2o corrected 
; values). Now we start the drift correction. First,determine format of run file, 
; (ie. Spock's 4 ref, 20 sam, 4 ref, 4 trap, 20 sam, 4 ref, or Tpol's other...?).
; Identify the position of the refs and how many are in each group, and then determine
; how many samples are between the refs. Then get the group averages and standard 
; deviations of the refs. Finally, calculate drift correction factors and then apply to 
; the n2o corrected delta values(ncorvals), resulting in an array *dcorvals*

; -------- DETERMINE RUN STRUCTURE -------------------------------------------------
; -------- REFERENCE STRUCTURE -----------------------------------------------------

; ------ Get the REF's out of the main array:
IF type[0] EQ 'REF' THEN refpos = WHERE(type EQ 'REF', rlength)
IF type[0] EQ 'CRF' THEN refpos = WHERE(type EQ 'CRF', rlength)
IF type[0] EQ 'HRF' THEN refpos = WHERE(type EQ 'HRF', rlength)

IF (refpos[0] NE -1) THEN refs = arraw[refpos]  ; ------Potential bomb later if refpos[0] = -1, then refs variable not loaded

; ----- separate into groups
grouparr=INTARR(rlength)
grouparr[0]=1
nrefs=1

; ---- Loop through the array and find where the refs are.
FOR i=0,rlength-2 DO BEGIN  ; remember, 'refpos' is a vector of index values !
	diff=refpos[i+1]-refpos[i] ; Value minus the previous value
	IF diff EQ 1 THEN nrefs=nrefs+0 ELSE nrefs=nrefs+1
	grouparr[i+1]=nrefs
ENDFOR
;------ NOTE- nrefs variable left with the last index number of refsets (ie. usually 3)
;------ The variable "grouparr" now contains the index number of all the REF's  -----
;------ such as 1,1,1,1,2,2,2,2,3,3,3,3 or in our 1st case of 1990: (1,1,1,2,2,2,2,3,3,3,3)
 
ngroups=n_elements(uniq(grouparr))  ; In the above example, ngroups would = 3

; ---set up a variable to collect index number for each REF
cluster =INTARR(ngroups)
FOR c = 0, ngroups-1 DO BEGIN
	thisgroup= WHERE(grouparr EQ c+1,thisgroupnum)
	cluster[c] = thisgroupnum
ENDFOR	

;--- NOW, variable cluster[index for group of refsets] holds the number of REFs in each group.


IF verbose EQ 1 THEN PRINT, 'refsets dimentioned to ngroups = ', ngroups
IF(verbose EQ 1) THEN PRINT, 'nrefs= ', nrefs
refsets = intarr(ngroups)
ct = 0

;-----------------THIS LOOP CAPTURES THE POSITION OF THE LAST REF IN EACH GROUP OF REFS AND PUTS THEM IN REFSETS.
FOR i = 0, nrefs-2 DO BEGIN ;  -------------MAY BOMB HERE... IF NUMBER OF SAMPLES BETWEEN REFS IS ONE
	REPEAT BEGIN
		ct = ct + 1
	ENDREP UNTIL (refpos[ct] - refpos[ct-1] NE 1)
	refsets[i] = refpos[ct-1]
ENDFOR
n = N_ELEMENTS(refpos)
refsets[nrefs-1]= refpos[n-1]	; last ref position
IF(verbose EQ 1) THEN PRINT, 'refsets = ', refsets

; -------- WHERE WE ARE NOW, AND THE STATUS OF SOME VARIBLES... -----------------
;    Now refsets array of (nrefs dimensions) contains the index number (within original array "type") of the 
;    last ref in each set of refs.
;    AND, cluster[*] contains the number of REF's in each group (where * is ngroups dimension)
;    Calc stats on each set of (nrefs) refs
;    Evaluate refsets array for QA/QC on REFs: (ie.  Max stdev, or Max drift )
;    Make array to store retained reference values for peformance files, etc.
;    **NEW FOR 2005: to be able to process all sorts of raw file run structures,
;    **create logic to not get hung up on runs with sparse REF's,  or oddly spaced REF's.

;-------------------- DETERMINE REPRESENTATIVE (MEAN VALUE) FOR EACH SET OF REFERENCES --------------

refarr = REPLICATE ({   dav45:0.0D, 	$
			stdev45:0.0,	$
			dav46:0.0D,	$
			stdev46:0.0,	$
			avec13:0.0D,	$
			aveo18:0.0D,	$
			stdevc13:0.0,	$
			stdevo18:0.0, 	$
			c13reflag:'', 	$
			o18reflag:''}, nrefs)   ;  Note: nrefs us usually = 3, for 3 sets of refs.
;;; AT SOME POINT in this code below I could check the stderr of each of these refs - to make sure there's not one bad ref value.  But I'm not exactly sure how
; to do this . ..			
stderrknob=0.02

IF thispause EQ 1 THEN BEGIN
	FOR j = 0,rlength-1 DO BEGIN  
	stderrref45=prec45[refpos[j]]
	stderrref46=prec46[refpos[j]]

	IF stderrref45 GT stderrknob THEN BEGIN	
		keepgoing=DIALOG_MESSAGE('stderr 45 GT thisc13knob. Stop and check your data!', title = 'Continue',/Question, /cancel)
		IF keepgoing EQ 'No' THEN goto,bailout
		IF keepgoing EQ 'Yes' THEN goto,whocares
	ENDIF 
	IF stderrref46 GT stderrknob THEN BEGIN
		keepgoing46=DIALOG_MESSAGE('stderr 46 GT knob. Stop and check your data!', title = 'Continue',/Question, /cancel)	
		IF keepgoing46 EQ 'No' THEN goto,bailout
		IF keepgoing46 EQ 'Yes' THEN goto,whocares
	ENDIF
	whocares:
	ENDFOR
ENDIF
FOR j = 0,nrefs-1 DO BEGIN   ; THIS IS THE SOLUTION TO THE PROBLEM MENTIONED ~ 40 LINES BELOW...

	last1 = refsets[j] ; (last1 = the address of the last ref in the set)
	
	; THE LOGIC HERE IS WE USE THE LAST REF VALUE ONLY, UNTIL WE HAVE MORE THAN 2 REFS, THEN USE
	; THE AVERAGE OF THE LAST 2 (FOR 3 REFS); THE LAST 3 (FOR 4 REFS)
	; DO THIS FOR DELTA 45 & 46 STUFF AND...? 

	 IF cluster[j] EQ 1 THEN BEGIN
	 	refarr[j].dav45 = d45[last1]
		refarr[j].stdev45 = -99.0
		refarr[j].dav46 = d46[last1]
		refarr[j].stdev46 = -99.0
		d45stdev = -99.0
		d46stdev = -99.0
		refarr[j].stdev46 = -99.0
	 ENDIF
	 IF cluster[j] EQ 2 THEN BEGIN
	 	refarr[j].dav45 = d45[last1]
		refarr[j].stdev45 = -99.0
		refarr[j].dav46 = d46[last1]
		refarr[j].stdev46 = -99.0
		d45stdev = -99.0
		d46stdev = -99.0
	 ENDIF 
	 
	 IF cluster[j] GT 2 THEN BEGIN      
	    ncluster= cluster[j]
	    cfarr45 = DBLARR(ncluster-1)   
	    cfarr46 = DBLARR(ncluster-1) 
	        FOR r=0,ncluster-2 DO BEGIN      ; So if ncluster = 3, r=0,1, and (last1- ncluster+2+r)= 
	    				      ; last1 -3+2+0, or -> [last1-1 and last1 -0]
	     	   cfarr45[r]= d45(last1 - ncluster+2+r)
	 	   cfarr46[r]= d46(last1 - ncluster+2+r)
	        ENDFOR
		result = MOMENT(cfarr45,SDEV= d45stdev)
		refarr[j].dav45 = result[0]
		refarr[j].stdev45 = d45stdev
		result = MOMENT(cfarr46,SDEV = d46stdev)
		refarr[j].dav46 = result[0]
		refarr[j].stdev46 = d46stdev                                      

	  ENDIF ; (GT 2 loop)
	
	; THIS NEXT BIT IS QUESTIONABLE- WE FLAG A REF SET THAT IS >2 IF THE STDEV IS GREATER THAN THE REFLIMIT 
	; HOWEVER, IF THERE ARE ONLY ONE OR TWO REFS, THEY ARE NEVER FLAGGED.... MAY BE OKAY, BUT....
	
		IF (refarr[j].stdev45 GT c13reflimit) THEN refarr[j].c13reflag = 'a' ELSE refarr[j].c13reflag = '.'
		IF (refarr[j].stdev46 GT o18reflimit) THEN refarr[j].o18reflag = 'a' ELSE refarr[j].o18reflag = '.'
		
ENDFOR

c13poop = WHERE(refarr.c13reflag EQ 'a',nc13poop,complement=c13flagok) ; remember: c13poop is a VECTOR! (not an array!)
o18poop = WHERE(refarr.o18reflag EQ 'a',no18poop,complement=o18flagok);      and   o18poop is a VECTOR! (not an array!)


; -------- SAMPLE STRUCTURE ----------------
; Loop through the array, how many samples in each set, and their address:
; Including SMP, SIL, and all tanks besides REF
; these assume that 
IF type[0] EQ 'REF' THEN sampos = WHERE(type NE 'REF', slength) 
IF type[0] EQ 'CRF' THEN sampos = WHERE(type NE 'CRF', slength)
IF type[0] EQ 'HRF' THEN sampos = WHERE(type NE 'HRF', slength)
                                            
IF (sampos[0] NE -1) THEN samarr = arraw[sampos]
IF nrefs GT 1 THEN samsets = DBLARR(2,nrefs-1) ELSE samsets = DBLARR(2,1)

;---CHECK TO SEE IF LAST & FIRST LINE ARE REFs OR NOT, SET FLAG ACCORDINGLY, SO DRIFT CORRECTION CAN BE DONE CORRECTLY LATER
firstlineref = 1
lastlineref = 1
IF type[0] NE 'REF' THEN firstlineref = 0
IF type[nlines-1] NE 'REF' THEN lastlineref = 0

; samsets(0,*)=last sample of set,and samsets(1,*)= number in set 

; Now there are nrefs-1 sets of samples between refs. Find their analysis number

ct=0
;  ---IF nrefs IS ONLY ONE, THIS NEXT BIT WILL NOT WORK. TRY...
IF (nrefs EQ 1) OR (nrefs EQ 2) THEN xy = 0	; only one or two set of refs, so look at all the samples
IF nrefs GT 2 THEN xy = nrefs - 2		; three or more sets of refs, so look at two or more sets of samples

IF slength GT 1 THEN BEGIN
    FOR i=0,xy DO BEGIN   ; SO IF 3 SETS OF REFS, THEN ITS: i=0,1, or LOOPING THROUGH THE TWO SETS OF SAMPLES
	nums=0
	REPEAT BEGIN
		ct= ct + 1
		nums = nums + 1
	ENDREP UNTIL (sampos[ct]  - sampos[ct-1] NE 1) OR (ct EQ slength-1) ; LOOKING FOR JUMPS BETWEEN SAMPLE SETS -AROUND THE REFS
	samsets[0,i] = sampos[ct-1]  ; (LAST SAMPLE OF THE SET)
	samsets[1,i] = nums   ; (TOTAL NUMBER OF SAMPLES IN SET)                                                  
    ENDFOR
ENDIF ELSE BEGIN  ; ONLY ONE SAMPLE BETWEEN REFS THEN... SO JUST REMEMBER THAT POSITION...
	samsets[0,0] = sampos[ct]  ; (LAST SAMPLE OF THE SET)
	samsets[1,0] = 1   ; (TOTAL NUMBER OF SAMPLES IN SET)                                                  
ENDELSE	

; --- NOTE-samsets could be dimensioned to be as little as 1 x 2 {(0,0) and (1,0)}
; ----------THE NEXT 2 LINES ADD ONE SAMPLE POSITION AND ONE SAMPLE NUMBER TO LAST SET. CLOOGE, BUT OK.
samsets[0,xy] = samsets[0,xy] + 1 ; corrected for ending one before end
samsets[1,xy] = samsets[1,xy] + 1
; ----------Now samsets array of contains the analysis number of the last sample in each 
;	    sample set (including trap tank) and the total number of samples


; ----- CALCULATE DRIFT CORRECTION FACTOR AND APPLY IT TO DELTA VALUES ----------
; equation looks like this...
; for i which is the number of the sample set (1st, 2nd, 3rd, etc)
; =(-refave1+refave2)*((anaylsis number-(index in that drift-set)/
;	total number in the set)+refave1)


dcorvals = REPLICATE({d45:0.0D,d46:0.0D},nlines)
;dcorfactd45=DBLARR(nlines)
;dcorfactd46=DBLARR(nlines)

; ---- DRIFT CORRECTION FOR ALL SAMPLES INCLUDING TRAP TANK --------------------
; ---- modified to accept different numbers of ref-sets ------------
;*********************************************************************************************
ddcorfactd45=DBLARR(nlines);
ddcorfactd46=DBLARR(nlines);

IF nrefs GT 1 THEN BEGIN 
;DRIFT CORRECT RUNS WITH VARIOUS RUN STRUCTURES WHICH HAVE GT 1 SET OF REFS
; ACCOMODATE ANCHOR POINTS FOR DRIFT CORRECTIONS USING CLUSTER ARRAY
	
	
;normal drift correct between each set
   FOR i=0, nrefs-2  DO BEGIN
	
	j = i + 1
	
	anchorpoint1 = cluster[i]/2;  Get mid point position within prvious group of stds
	anchorpoint2 = cluster[j]/2;  Get mid point position within post group of stds
	prrefavd45 = refarr[i].dav45 ; previous reference set d45
	porefavd45 = refarr[j].dav45 ; post reference set d45
	
	prrefavd46 = refarr[i].dav46 ; previous reference set d46
	porefavd46 = refarr[j].dav46 ; post reference set d46
		
	refnum = refsets[i] ; last analysis number of the previous reference set
	samnum = samsets[1,i] ; number of analysis in the sample set
	FOR k=0,samnum-1 DO BEGIN  ; LOOP THROUGH THE SAMPLE SET AND DO CORRECTIONS
	   samspos = ((refnum+1)+k)
		
	   ; ---FOR delta 45 ----------------
	   
	    ddcorfactd45[samspos] = (((porefavd45 - prrefavd45)*(samspos-refnum+anchorpoint1))/ $
	   	(samnum+anchorpoint1+ anchorpoint2)) + prrefavd45
	   dcorfactd45 = (((porefavd45 - prrefavd45)*(samspos-refnum+anchorpoint1))/ $
	   	(samnum+anchorpoint1+ anchorpoint2)) + prrefavd45
		slopefive= (porefavd45 - prrefavd45)/ $
			 	(samnum+anchorpoint1+ anchorpoint2)
	   dcorvals[samspos].d45 = (((ncorvals[samspos].d45/1000+1)/ $
	   	(dcorfactd45/1000+1))-1)*1000
		
	   ; ---FOR delta 46 ---------------
	   ddcorfactd46[samspos] = (((porefavd46 - prrefavd46)*(samspos-refnum+anchorpoint1))/ $
	   	(samnum+anchorpoint1+ anchorpoint2)) + prrefavd46

	   dcorfactd46 = (((porefavd46 - prrefavd46)*(samspos-refnum+anchorpoint1))/ $
	   	(samnum+anchorpoint1+ anchorpoint2)) + prrefavd46
		
		slopesix=((porefavd46 - prrefavd46))/ $
			       (samnum+anchorpoint1+ anchorpoint2)
	   dcorvals[samspos].d46 = (((ncorvals[samspos].d46/1000+1)/ $
	   	(dcorfactd46/1000+1))-1)*1000
		
		
	
	ENDFOR

    ENDFOR
ENDIF

;IF THE MIDDLE SECTION IS BAD, THEN DRIFT CORRECT FROM THE FIRST SET TO THE LAST SET AND IGNORE
;THE MIDDLE. AS IT IS WRITTEN NOW, IT ONLY ACCOMMODATES RUNS WITH 3 REFSETS.
IF nrefs GT 2 THEN BEGIN
	IF nc13poop EQ 1 THEN BEGIN
		IF (c13poop[0] EQ 1) THEN BEGIN 
			print,'Second ref set is bad for c13. Drift correcting from first to last ref sets.'
		  
			anchorpoint1 = cluster[0]/2;  Get mid point position within prvious group of stds
			anchorpoint2 = cluster[nrefs-1]/2;  Get mid point position within post group of stds
			prrefavd45 = refarr[0].dav45 ; previous reference set d45
			porefavd45 = refarr[2].dav45 ; post reference set d45
			refnum = refsets[0] ; last analysis number of the previous reference set
			samnum = samsets[1,nrefs-2] ; number of analysis in the sample set
			numfirsthalf=samsets[1,0]
			numsechalf=samsets[1,1]
			numsecsetrefs=cluster[1]
			totaldc=numfirsthalf+numsechalf+numsecsetrefs
			FOR k=0,totaldc-1 DO BEGIN  ; LOOP THROUGH THE SAMPLE SET AND DO CORRECTIONS
			   samspos = ((refnum+1)+k)
			   ; ---FOR delta 45 ----------------
		       	   ddcorfactd45[samspos] = (((porefavd45 - prrefavd45)*(samspos-refnum+anchorpoint1))/ $
			   	(totaldc+anchorpoint1+ anchorpoint2)) + prrefavd45
			  
			   dcorfactd45 = (((porefavd45 - prrefavd45)*(samspos-refnum+anchorpoint1))/ $
			   	(totaldc+anchorpoint1+ anchorpoint2)) + prrefavd45
			   dcorvals[samspos].d45 = (((ncorvals[samspos].d45/1000+1)/ $
			   	(dcorfactd45/1000+1))-1)*1000
			ENDFOR
		ENDIF 	
	ENDIF
	
	;---o18 
	IF no18poop EQ 1 THEN BEGIN
		IF (o18poop[0] EQ 1) THEN BEGIN 
			print,'Second ref set is bad for o18. Drift correcting from first to last ref sets.'
		  
			anchorpoint1 = cluster[0]/2;  Get mid point position within prvious group of stds
			anchorpoint2 = cluster[nrefs-1]/2;  Get mid point position within post group of stds
			prrefavd46 = refarr[0].dav46 ; previous reference set d46
			porefavd46 = refarr[2].dav46 ; post reference set d46
			
			refnum = refsets[0] ; last analysis number of the previous reference set
			samnum = samsets[1,nrefs-2] ; number of analysis in the sample set
			numfirsthalf=samsets[1,0]
			numsechalf=samsets[1,1]
			numsecsetrefs=cluster[1]
			totaldc=numfirsthalf+numsechalf+numsecsetrefs
			FOR k=0,totaldc-1 DO BEGIN  ; LOOP THROUGH THE SAMPLE SET AND DO CORRECTIONS
			   samspos = ((refnum+1)+k)
			   ; ---FOR delta 46 ----------------
		       	   ddcorfactd46[samspos] = (((porefavd46 - prrefavd46)*(samspos-refnum+anchorpoint1))/ $
			   	(totaldc+anchorpoint1+ anchorpoint2)) + prrefavd46
				
			   dcorfactd46 = (((porefavd46 - prrefavd46)*(samspos-refnum+anchorpoint1))/ $
			   	(totaldc+anchorpoint1+ anchorpoint2)) + prrefavd46
			   dcorvals[samspos].d46 = (((ncorvals[samspos].d46/1000+1)/ $
			   	(dcorfactd46/1000+1))-1)*1000
			ENDFOR
			
		ENDIF 	
	ENDIF
ENDIF

; ----- DRIFT CORRECTED REFERENCES - really normalized to averages --------------
;  
; REVIEW VARIABLES:  nrefs = the number of ref sets in the run (usually 2 or 3, but could be more)
;                
FOR i=0,nrefs-1  DO BEGIN    ; ----LOOPING THROUGH ALL THE REF SETS (typically 2 or 3...)
	refavd45 = refarr[i].dav45 ; previous reference set d45
	refavd46 = refarr[i].dav46 ; previous reference set d46
	lastrefnum = refsets[i] ; last analysis number of the previous reference set
	refquant = cluster[i]
	FOR m=1,  cluster[i] DO BEGIN  ; ----------looping through the ref-set 
	   
	   dcorfactd45 = refavd45
	   ddcorfactd45[(lastrefnum-refquant+m)] = refavd45
	
	   dcorvals[(lastrefnum-refquant + m)].d45 = (((ncorvals[(lastrefnum-refquant + m)].d45/1000+1)/ $
	   	(dcorfactd45/1000+1))-1)*1000
   	    ;-- For d46   
	   dcorfactd46 = refavd46
	  
	   ddcorfactd46[(lastrefnum-refquant+m)] = refavd46
	  
	   dcorvals[(lastrefnum-refquant + m)].d46 = (((ncorvals[(lastrefnum-refquant + m)].d46/1000+1)/ $
	   	(dcorfactd46/1000+1))-1)*1000	
			   
	ENDFOR   ; --- (m)
ENDFOR		;  --- (i)

;---IF YOU HAVE SAMPLES BEFORE THE FIRST SET OF REFS, USE THE CORRECTION FACTOR FOR THE FIRST SET OF REFS
; is this used? since we have to have a ref in the first line or else we bomb??
IF firstlineref EQ 0 THEN BEGIN
	FOR r=0,refsets[0]-cluster[0] DO BEGIN
	   dcorfactd45 = refarr[0].dav45
	   dcdorfactd45[r] = refarr[0].dav45

	   dcorvals[r].d45 = (((ncorvals[r].d45/1000+1)/ $
	   	(dcorfactd45/1000+1))-1)*1000
   	   dcorfactd46 = refarr[0].dav46
	   cdorfactd46[r] = refarr[0].dav46

	   dcorvals[r].d46 = (((ncorvals[r].d46/1000+1)/ $
	   	(dcorfactd46/1000+1))-1)*1000
				
	ENDFOR
ENDIF

;---IF YOU HAVE SAMPLES AFTER YOUR LAST SET OF REFS, USE THE CORRECTION FACTOR FOR THE LAST SET OF REFS OR INTERPOLATE

IF lastlineref EQ 0 THEN BEGIN
	; this is where we can interpolate the refs.
	;interpolate=0
	;goto,moveon
	;;; not turning this feature on just yet. 
	IF nrefs EQ 1 THEN BEGIN 
		interpolate=0
		goto, moveon
	ENDIF
	IF nrefs GT 1 AND ABS(slopefive) GT 0.005 THEN interpolate=0 ELSE interpolate=1
	IF thispause EQ 1 THEN BEGIN
		;dialog for yes no 
		qinterpolate=DIALOG_MESSAGE ('Would you like to interpolate drift on the second set of samples?', title = 'Continue',/Question, /cancel)
			IF qinterpolate EQ 'Yes' THEN interpolate=1
			IF qinterpolate EQ 'No' THEN interpolate=0
			IF qinterpolate EQ 'Cancel' THEN goto,bailout
	ENDIF
	moveon:
	IF interpolate EQ 0 THEN BEGIN
		FOR r=refsets[nrefs-1],nlines-1 DO BEGIN
		   dcorfactd45 = refarr[nrefs-1].dav45
		   ddcorfactd45[r] = refarr[nrefs-1].dav45
		   dcorvals[r].d45 = (((ncorvals[r].d45/1000+1)/ $
		   	(dcorfactd45/1000+1))-1)*1000
	   	   dcorfactd46 = refarr[nrefs-1].dav46
		     ddcorfactd46[r] = refarr[nrefs-1].dav46
		   dcorvals[r].d46 = (((ncorvals[r].d46/1000+1)/ $
		   	(dcorfactd46/1000+1))-1)*1000
			
			;;;add tags	
		ENDFOR
	ENDIF ELSE BEGIN
		; question - would you like to interpolate refs? stop
		; could have limits - if slope too high, don't proceed. 
		
		;;;think about this.
		;;add tags
		FOR r=refsets[nrefs-1],nlines-1 DO BEGIN  ;
	   		dist=r-refsets[nrefs-1]
		   ; ---FOR delta 45 ----------------
	   
		    dcorfactd45 = (slopefive* dist)+refarr[nrefs-1].dav45
		     ddcorfactd45[r] = (slopefive* dist)+refarr[nrefs-1].dav45
		   	dcorvals[r].d45 = (((ncorvals[r].d45/1000+1)/ $
		   	(dcorfactd45/1000+1))-1)*1000
		
		   ; ---FOR delta 46 ---------------
		   dcorfactd46 = (slopesix* dist)+refarr[nrefs-1].dav46
	 
			ddcorfactd46[r]=(slopesix* dist)+refarr[nrefs-1].dav46
		   	dcorvals[r].d46 = (((ncorvals[r].d46/1000+1)/ $
		   	(dcorfactd46/1000+1))-1)*1000
		ENDFOR
	ENDELSE
	
ENDIF


;IF (log_data EQ 1) THEN BEGIN
;	logc13.dcorvals=dcorvals.d45
;	logo18.dcorvals=dcorvals.d46
;ENDIF

	
IF extras EQ 1 THEN BEGIN
cextrafile='/home/ccg/sil/tempfiles/extra/c13.'+file
oextrafile='/home/ccg/sil/tempfiles/extra/o18.'+file
refarrformat='(F8.3,1X,F8.3,1X,F8.3,1X,F8.3)'
	OPENW, u, cextrafile, /GET_LUN
	PRINTF, u ,'ref array, avg and stdev'
	FOR z=0, nrefs-1 DO PRINTF,u,format=refarrformat,refarr[z].dav45 
	FOR z=0, nrefs-1 DO PRINTF,u,format=refarrformat,refarr[z].stdev45 

	FREE_LUN, u
	OPENW, u, oextrafile, /GET_LUN
	PRINTF, u ,'ref array, avg and stdev'
	FOR z=0, nrefs-1 DO PRINTF,u,format=refarrformat,refarr[z].dav46 
	FOR z=0, nrefs-1 DO PRINTF,u,format=refarrformat,refarr[z].stdev46
	FREE_LUN, u
;
ENDIF

;;;;**************************************************************************8
;NOW find secondref data *(in LOUARR, named after second ref of choice in 2017) and then fix data to d45 and d46 values of both primary and secondary reference
; (initially this happened last, but now I want to get d45 and d46 values for tanks, so I have to do this first. It doesn't make a difference when you stretch the slope)
; make pdb vals: fill with 2 pt corrected data or one pt, based on what you have. ..

pdbvals = REPLICATE ({d45:0.0D,	$     
			d46:0.0D,	$
			twptd45:0.0D,	$
			twptd46:0.0D},	$
			nlines)


;now find lou data 

IF secref EQ 'youdecide' THEN BEGIN
	; see if LOUI is there
	; see if HTWO is there
	; figure out what is the cylinder after the first ref
	

	findsecref=WHERE(type EQ 'SRF',nsecrefs)
	
	IF findsecref[0] NE -1 THEN BEGIN
		secref=enum[findsecref[0]] 
		goto,secreffound
	ENDIF
	
	louhere=WHERE(enum EQ 'LOUI-001')
	IF louhere[0] NE -1 THEN BEGIN
		secref='LOUI-001'
		goto,secreffound
	ENDIF
	hueyhere=WHERE(enum EQ 'HUEY-001')
	IF hueyhere[0] NE -1 THEN BEGIN
		secref='HUEY-001'
		goto,secreffound
	ENDIF
	
	htwohere=WHERE(enum EQ 'HTWO-001')
	IF htwohere[0] NE -1 THEN BEGIN
		secref='HTWO-001'
		goto,secreffound
	ENDIF
	
	bb88here=WHERE(enum EQ 'BB88-001')
	IF bb88here[0] NE -1 THEN BEGIN
		secref='BB88-001'
		goto,secreffound
	ENDIF
	mnkyhere=WHERE(enum EQ 'MNKY-001')
	IF mnkyhere[0] NE -1 THEN BEGIN
		secref='MNKY-001'
		goto,secreffound
	ENDIF

	twptcorr=0
	;secref='HUEY-001'
ENDIF	
secreffound:
IF twptcorr EQ 1 THEN print,'secref=',secref ELSE print,'no scale correction applied'
IF twptcorr EQ 1 THEN BEGIN
	; find a first set and a second set; compare to first and second refsets. drift is already corrected for.

	loupos=WHERE(enum EQ secref AND site NE 'BOG',nlou)
	;written with the assumption that secref is LOUI-001,but can be anything.
	
	IF loupos[0] NE -1 THEN BEGIN
		; ----- separate into groups
		lougrouparr=INTARR(nlou)
		lougrouparr[0]=1
		nlous=1

		; ---- Loop through the array and find where the refs are.
		FOR i=0,nlou-2 DO BEGIN  ; remember, 'loupos' is a vector of index values !
			diff=loupos[i+1]-loupos[i] ; Value minus the previous value
			IF diff EQ 1 THEN nlous=nlous+0 ELSE nlous=nlous+1
			lougrouparr[i+1]=nlous
		ENDFOR
		;------ NOTE- nrefs variable left with the last index number of refsets (ie. usually 3)
		;------ The variable "grouparr" now contains the index number of all the REF's  -----
		;------ such as 1,1,1,1,2,2,2,2,3,3,3,3 or in our 1st case of 1990: (1,1,1,2,2,2,2,3,3,3,3)
 
		nlougroups=n_elements(uniq(lougrouparr))  ; In the above example, ngroups would = 3

		; ---set up a variable to collect index number for each LOU
		loucluster =INTARR(nlougroups)
		FOR c = 0, nlougroups-1 DO BEGIN
			thislougroup= WHERE(lougrouparr EQ c+1,thislougroupnum)
			loucluster[c] = thislougroupnum
		ENDFOR	
	
		;--- NOW, variable loucluster[index for group of refsets] holds the number of LOUIs in each group.
	
		IF verbose EQ 1 THEN PRINT, 'lousets dimentioned to nglouroups = ', nlougroups
		lousets = intarr(nlougroups)
		louposarr = FIX(loupos)
	
		;-----------------THIS LOOP CAPTURES THE POSITION OF THE LAST REF IN EACH GROUP OF REFS AND PUTS THEM IN LOUSETS.
		n=0
		FOR i = 0, nlou-2 DO BEGIN ;  -------------MAY BOMB HERE... IF NUMBER OF SAMPLES BETWEEN REFS IS ONE
			loudiff=louposarr[i+1]-louposarr[i]
			IF loudiff NE 1 THEN BEGIN
				lousets[n]=louposarr[i]
				n=n+1	
			ENDIF 
			lousets[nlous-1]=loupos[nlou-1]   ;cloogey way to get last lou position into lousets
		ENDFOR
	
		louarr = REPLICATE ({	aved45:0.0D,	$
					aved46:0.0D,	$
					stdev45:0.0,	$
					stdev46:0.0,	$
					avec13:0.0D,	$   ; might not need this anymore - data not available yet
					aveo18:0.0D,	$     ;might not need this anymore
					stdevc13:0.0,	$     ;might not need this anymore
					stdevo18:0.0,	$
					c13reflag:'',	$
					o18reflag:''},nlougroups);might not need this anymore	
		
		FOR j=0,nlougroups-1 DO BEGIN	
	
		lastlou1 = lousets[j]	
		IF loucluster[j] GT 2 THEN BEGIN
			lou45=DBLARR(loucluster[j]-1)
			lou46=DBLARR(loucluster[j]-1)
			;lougroup13=DBLARR(loucluster[j]-1)
			;lougroup18=DBLARR(loucluster[j]-1)
			nloucluster=loucluster[j]
			  FOR l =1, nloucluster-1 DO BEGIN ; skip the first lou (so start at 1, not zero)
				lou45[l-1]=dcorvals[lastlou1-nloucluster+1+l].d45
				lou46[l-1]=dcorvals[lastlou1-nloucluster+1+l].d46
			;	lougroup13[l-1] = finalvals[lastlou1-nloucluster+1+l].c13
			;	lougroup18[l-1] = finalvals[lastlou1-nloucluster+1+l].o18
			
			  ENDFOR  
			  
			result = MOMENT(lou45,SDEV=crawstdev)
			louarr[j].aved45 = result[0]
			louarr[j].stdev45 = crawstdev
			IF louarr[j].stdev45 GT thisc13knob THEN louarr[j].c13reflag='a'  
			
			result = MOMENT(lou46,SDEV=orawstdev)
			louarr[j].aved46 = result[0]
			louarr[j].stdev46 = orawstdev
			IF louarr[j].stdev46 GT thisc13knob THEN louarr[j].o18reflag='a'  
			
			;result = MOMENT(lougroup13,SDEV=c13stdev)
			;louarr[j].avec13 = result[0]
			;louarr[j].stdevc13 = c13stdev
			;result = MOMENT(lougroup18,SDEV=o18stdev)
			;louarr[j].aveo18 = result[0]
			;louarr[j].stdevo18 = o18stdev
		ENDIF 
		ENDFOR
		
		louc13poop = WHERE(louarr.c13reflag EQ 'a',nlouc13poop,complement=louc13flagok) ; remember: these are vectors
		louo18poop = WHERE(louarr.o18reflag EQ 'a',nlouo18poop,complement=louo18flagok)
		
		; IF secref is bad you need to get out of this
		
		FOR m=0,nlougroups-1 DO BEGIN
			IF louarr[m].stdev45 GT 0.04 THEN BEGIN
				PRINT,'stdev of secref is too high. If you continue, data will single-point correct'

				twptcorr=0
				
				
				GOTO, skipsecref
				
			ENDIF
		ENDFOR	
		
		
		;;ok, have LOU data and have written it to file for diagnostic purposes (or maybe that happens below)
		;; now calculate slope and intercept
		;;apply to data
		;; write to alt directory	

		louposinrefvals=WHERE(jrefvals.field1 EQ secref)   
		;truerefd45=ourref.field10
		truerefd45=refd45
		trueloud45=jrefvals[louposinrefvals].field10
		;truerefd46=ourref.field11
		truerefd46=refd46
		
		trueloud46=jrefvals[louposinrefvals].field11
		
		;measrefd45mo=0       ; by definition in dcorvals! 
		measrefd45=0  
		
		;measrefd46mo=0         ; by definition!
		measrefd46=0  
		
		loud45mo=MOMENT(louarr[louc13flagok].aved45,sd=sd)  
		measloud45=loud45mo[0]
		
		loud46mo=MOMENT(louarr[louo18flagok].aved46,sd=sd)  
		measloud46=loud46mo[0]
		
		;m=(trueref-truelou)/(measref-measlou)
		d45m=(truerefd45-trueloud45)/(measrefd45-measloud45)
		d45b=truerefd45-(d45m*measrefd45)				

		d45b=trueloud45-(d45m*measloud45)		
		d46m=(truerefd46-trueloud46)/(measrefd46-measloud46)
		d46b=truerefd46-(d46m*measrefd46)

		IF secref EQ 'HUEY-001' THEN slopefile='/home/ccg/sil/tempfiles/slopetrackH.txt' 
		IF secref EQ 'LOUI-001' THEN slopefile='/home/ccg/sil/tempfiles/slopetrackL.txt' 
		IF secref EQ 'HTWO-001' THEN slopefile='/home/ccg/sil/tempfiles/slopetrack.HTWO.txt' 
		IF secref EQ 'BB88-001' THEN slopefile='/home/ccg/sil/tempfiles/slopetrack.bb88.txt' 
		IF secref EQ 'MNKY-001' THEN slopefile='/home/ccg/sil/tempfiles/slopetrack.mnky.txt' 
		
		slopeformat='(A4,1X,A19,1X,F8.3,1X,F8.3,1X,F8.3,1X,F8.3)'		 
				OPENU, u, slopefile, /APPEND, /GET_LUN
			PRINTF, u, FORMAT=slopeformat, inst,file,d45m,d45b,d46m,d46b
			FREE_LUN, u
	
		;NOW correcting scale contraction into pdbvals array (twpt). ..keeping pdbvals as name because these are moved onto the vpdb scale for d45 and d46
		; (no 17O correction yet)

			
		; now apply to all data.	

		FOR t=0,nlines-1 DO BEGIN
	
	
			pdbvals[t].d45= ((refd45/1000.0 +1.0)*(dcorvals[t].d45/1000.0 +1.0)-1.0)*1000.0
			pdbvals[t].d46= ((refd46/1000.0+1.0)*(dcorvals[t].d46/1000.0+1.0)-1.0)*1000.0
			
			pdbvals[t].twptd45=(dcorvals[t].d45*d45m)+d45b
			pdbvals[t].twptd46=(dcorvals[t].d46*d46m)+d46b


		ENDFOR
	
	ENDIF ELSE BEGIN ; loupos=-1
		GOTO, skipsecref
	ENDELSE	
	IF extras EQ 1 THEN BEGIN
		extraformat='(F8.3,1X,F8.3,1X,F8.3,1X,F8.3,1X,F8.3,1X,F8.3)'
		OPENW, u, cextrafile, /GET_LUN,/APPEND
		PRINTF, u ,'secref array: avg, stdev, m, b'
		PRINTF,u,format=extraformat,louarr.aved45, louarr.stdev45, d45m,d45b	
		FREE_LUN, u
		OPENW, u, oextrafile, /GET_LUN
		PRINTF, u ,'secref array: avg, stdev, m, b'
		PRINTF,u,format=extraformat,louarr.aved46, louarr.stdev46, d45m,d45b	
		FREE_LUN, u
	ENDIF

ENDIF ELSE BEGIN ;twptcorr
skipsecref:		
	FOR t=0,nlines-1 DO BEGIN

		pdbvals[t].d45= ((refd45/1000.0 +1.0)*(dcorvals[t].d45/1000.0 +1.0)-1.0)*1000.0
		pdbvals[t].d46= ((refd46/1000.0+1.0)*(dcorvals[t].d46/1000.0+1.0)-1.0)*1000.0
	ENDFOR
ENDELSE



;*****************************************************
;SLY MOVED finalvals correction to before Craig correction as per recommendations of Brand, Coplen, Assonov 2008 (new and improved 17O correction)
;August 2009
;THIS means that we are correcting to an UN-Craig-corrected reference value. 
;******************
			

IF (log_data EQ 1) THEN BEGIN
	logc13.pdbvals=pdbvals.d45
	logo18.pdbvals=pdbvals.d46

	logc13.twptpdbvals=pdbvals.twptd45
	logo18.twptpdbvals=pdbvals.twptd46

ENDIF

;----- 17O CORRECTION ---------------------------------------------------------
; apply 17O correction to pdb corrected values resulting in array newccorvals
; As of Aug 2009 we follow Brand, Coplen, Assonov 2008 using new R values, lamda=0.528, new calculation.
; old code is preserved below as ccorvals - it followed 1957 Craig correction.
; note that 17O correction is applied to all samples, including references. ..
; we had fixed data to a pre-Craig corrected value (obtained by running Craig in reverse undo17Obca.. code)

newccorvals = REPLICATE ({c13:0.0D,	$
			o18:0.0D,	$
			twptc13:0.0D,	$   
			twpto18:0.0D,	$	
			flagc13:'',	$
			flago18:'',	$
			pdc13:0.0,	$
			pdo18:0.0},	$
			nlines)

IF d4546tankfiles EQ 0 THEN BEGIN    ;proceed normally to do 17O correction

	; variables
	dfortyfivein=  0.0D
	dfortysixin=  0.0D
	dfortyfivein=0.0D
	dfortysixin=0.0D

	thirteenRvpdb=0.0D
	lamda=0.0D
	seventeenRvpdb=0.0D
	dthirteenCsam=0.0D
	deighteenOsam=0.0D
	deighteenCtwptsam=0.0D
	deighteenOtwptsam=0.0D

	;brand,coplen,assonov recommended values
	thirteenRvpdb=0.01118028D
	lamda=0.528D
	seventeenRvpdb=0.00039319D
	
	FOR i=0,nlines-1 DO BEGIN

	
		dfortyfivein=pdbvals[i].d45
		dfortysixin=pdbvals[i].d46
		dfortyfivetwptin=pdbvals[i].twptd45
		dfortysixtwptin=pdbvals[i].twptd46
       
		
		; try the Newton Raphson way to do this:
		;Colin's variables
		
		thirteenRvpdb=0.011180D
		seventeenRvpdb=0.0003931D
		eighteenRvpdb=0.00208835D
		lamda=0.528D
		fortyfiveR=0.0119662   ;r13+2r17
		fortysixR=0.00418564   ;2r18+2r13r17+r17^2
	

		trial=1
			
		k_factor=seventeenRvpdb/(eighteenRvpdb^lamda)
		
		ratio45 = ((dfortyfivein/1000)+1)*(fortyfiveR)   ; turning delta value into ratio
		ratio46 = ((dfortysixin/1000)+1)*(fortysixR)   ; turning delta value into ratio
		r18=ratio46/2 ;   <-- first guess
			
			trial=1D  ; start with a high number
			WHILE ABS(trial) GT 0.0000000001 DO BEGIN
				
				;trial=(-3 * k_factor^2 * (eighteenRvpdb^(2*lamda)))+(2.0D * k_factor * ratio45 * eighteenRvpdb^lamda)+(2.0D*eighteenRvpdb)-(ratio46)
				trial=(-3 * k_factor^2 * (r18^(2*lamda)))+(2.0D * k_factor * ratio45 * r18^lamda)+(2.0D*r18)-(ratio46)
				r18=r18-trial/2

			ENDWHILE
			
		
		newccorvals[i].o18=((r18/eighteenRvpdb)-1)*1000    ; turn correct r18 back into delta value
		r17=k_factor*(r18^lamda)
		r13=ratio45-(2*r17)    ; find r13
		newccorvals[i].c13=((r13/thirteenRvpdb)-1)*1000   ; turn correct r13 back into delta value 
		
		;;;  now for two point data
		IF twptcorr EQ 1 THEN BEGIN
		ratio45 = ((dfortyfivetwptin/1000)+1)*(fortyfiveR)   ; turning delta value into ratio
		ratio46 = ((dfortysixtwptin/1000)+1)*(fortysixR)   ; turning delta value into ratio
		r18=ratio46/2 ;   <-- first guess
			
			trial=1D  ; start with a high number
			WHILE ABS(trial) GT 0.0000000001 DO BEGIN
				
				;trial=(-3 * k_factor^2 * (eighteenRvpdb^(2*lamda)))+(2.0D * k_factor * ratio45 * eighteenRvpdb^lamda)+(2.0D*eighteenRvpdb)-(ratio46)
				trial=(-3 * k_factor^2 * (r18^(2*lamda)))+(2.0D * k_factor * ratio45 * r18^lamda)+(2.0D*r18)-(ratio46)
				r18=r18-trial/2
			ENDWHILE
			
		
		newccorvals[i].twpto18=((r18/eighteenRvpdb)-1)*1000    ; turn correct r18 back into delta value
		r17=k_factor*(r18^lamda)
		r13=ratio45-(2*r17)    ; find r13
		newccorvals[i].twptc13=((r13/thirteenRvpdb)-1)*1000   ; turn correct r13 back into delta value 		
		ENDIF
	ENDFOR

ENDIF ELSE BEGIN

     ;***** THIS GIVES you the option to print un-17O-corrected data to different directories. FOR DATA OVERHAUL.
	FOR i=0,nlines-1 DO BEGIN
		newccorvals[i].c13=pdbvals[i].d45
		newccorvals[i].o18=pdbvals[i].d46
	
		newccorvals[i].twptc13=pdbvals[i].twptd45
		newccorvals[i].twpto18=pdbvals[i].twptd46
	ENDFOR
ENDELSE


;****************
IF (log_data EQ 1) THEN BEGIN
	logc13.newccorvals=newccorvals.c13
	logc13.twptnewccorvals=newccorvals.twptc13
		
	logo18.newccorvals=newccorvals.o18
	logo18.twptnewccorvals=newccorvals.twpto18
	

ENDIF


;**********GET ARRAYS STRAIGHTENED OUT!!

finalvals=newccorvals
;working with new Brand, Coplen, Assonov corrected data.
;ccorvals is obsolete.
;; 

;---------- This next bit fills the reference array (refarr[*]) with stats (ave & stev) of each ref set. 
;**********************************************************************************************

FOR j = 0,nrefs-1 DO BEGIN
	last1= refsets[j]
	IF cluster[j] GT 2 THEN BEGIN ;(cluster holds the number of REF's in each group. ie.(3,4,4) 
		group13 = DBLARR(cluster[j]-1)  ; make array to hold ref data for stats later -c13
		group18 = DBLARR(cluster[j]-1)  ; make array to hold ref data for stats later -018
		  FOR limp = 1, cluster[j]-1 DO BEGIN ; skip the first ref (so start at 1, not zero)
			;PRINT,'limp= ',limp, '    cluster[j] =',cluster[j]
			group13[limp-1] = finalvals[last1-(limp-1)].c13
			group18[limp-1] = finalvals[last1-(limp-1)].o18
		  ENDFOR  ; ---limp ...
		;PRINT, 'group13 =', group13
		;PRINT, 'group18 =', group18
		result = MOMENT(group13,SDEV=c13stdev)
		refarr[j].avec13 = result[0]
		refarr[j].stdevc13 = c13stdev
		
		result = MOMENT(group18,SDEV = o18stdev)
		refarr[j].aveo18 = result[0]
		refarr[j].stdevo18 = o18stdev	
				
	ENDIF ELSE BEGIN  ; --ONLY ONE OR TWO REFERNCES, SO TAKE LAST ONE..
	
		 refarr[j].avec13 = finalvals[last1].c13
		 refarr[j].stdevc13 = -9.999
		 refarr[j].aveo18 = finalvals[last1].o18
		 refarr[j].stdevo18 = -9.999
        END

ENDFOR




; ----- QA/QC ON RUN DATA, DECIDE FOR FLAGS -------------------------------------
; flag, position one, will be set here for c13 and o18
; possible flag choices
;   *.. = unanalyzable sample (no valid working reference gas data for a raw file)
;   A.. = problems in analysis or data reduction
;   N.. = Known problem with sampling
;   C.. = flagged for CO2 mixing ratio (by NOAA CO2 measurement lab)
;   +.. = bad pair agreement, high member
;   -.. = bad pair agreement, low member
;   ... = good flask
; result: c13flag and o18flag to be inserted in the finalvals


; ----- PAIR DIFFERENCE FLAG ----------------------------------------------------
; Find flask pairs, evalate aginst pair agreement criteria, 
; then flag accordingly for flag bad pair agreement and single flasks
; Pair difference criteria defined in global variable section at the top 
; - see "Knobs" section.


; ----- pairdifference flag for c13 ----------------------------------------------
refcount = 0

FOR i=0, nlines-1 DO BEGIN
	IF strategy[i] EQ 'pfp' THEN BEGIN
		finalvals[i].pdc13 = -999.99
      	   	finalvals[i].flagc13 = '...'
		finalvals[i].pdo18 = -999.99
               	finalvals[i].flago18 = '...'
	ENDIF ELSE BEGIN

		IF (type[i] EQ 'SMP') OR (type[i] EQ 'SIL') THEN BEGIN
				;this should be obsolete. ..
			If meth[i] EQ 'A' THEN BEGIN  ;  this was added when samples from different pfps from same site were
			; getting labeled as pairs
		
				flaskpair = WHERE(site EQ site[i] AND $
	               			STRMID(id,0,4) EQ STRMID(id[i],0,4) AND $ 
					yr EQ yr[i] AND $
	                	        mo EQ mo[i] AND $
	                	        dy EQ dy[i] AND $
	                        	hr EQ hr[i] AND $
	                        	mn EQ mn[i] AND $
	                        	meth EQ meth[i], npair)
	
	
	
			ENDIF ELSE BEGIN
		        	flaskpair = WHERE(site EQ site[i] AND $
	               			yr EQ yr[i] AND $
	                	        mo EQ mo[i] AND $
	                	        dy EQ dy[i] AND $
	                        	hr EQ hr[i] AND $
	                        	mn EQ mn[i] AND $
	                        	meth EQ meth[i], npair)
	
	        	ENDELSE
			
			IF npair EQ 1 THEN BEGIN	
		               	finalvals[i].pdc13 = -999.99
       		         	finalvals[i].flagc13 = '..S'
				finalvals[i].pdo18 = -999.99
        	        	finalvals[i].flago18 = '..S'
				
				IF (site[i] EQ 'TST')OR (site[i] EQ 'BLD')OR (site[i] EQ 'SIL') OR (site[i] EQ 'TST')THEN BEGIN
						finalvals[i].flagc13='...'
						finalvals[i].flago18='...'		
				ENDIF
			ENDIF ELSE BEGIN	
				IF npair EQ 2 THEN BEGIN ;normal pair
		        		finalvals[i].pdc13 = finalvals[flaskpair[0]].c13 - $
						finalvals[flaskpair[1]].c13   
		                	IF (ABS(finalvals[i].pdc13) GT c13pdlimit) THEN BEGIN
						IF (finalvals[i].pdc13 GT 0) THEN BEGIN
							finalvals[flaskpair[0]].flagc13 = '+..' 
							finalvals[flaskpair[1]].flagc13 = '-..'
						ENDIF ELSE BEGIN
							finalvals[flaskpair[0]].flagc13 = '-..' 
							finalvals[flaskpair[1]].flagc13 = '+..'
						ENDELSE
					ENDIF ELSE BEGIN
        	        			finalvals[flaskpair[0]].flagc13 = '...' 
						finalvals[flaskpair[1]].flagc13 = '...'
					ENDELSE
					;---NO PAIR DIFF FLAGS FOR TEST FLASKS---
					IF (site[i] EQ 'TST')OR (site[i] EQ 'BLD')OR (type[i] EQ 'SIL')THEN BEGIN
						finalvals[flaskpair[0]].flagc13 = '...' 
						finalvals[flaskpair[1]].flagc13 = '...'
						
				ENDIF
			
				; ----- pairdifference flag for o18 ----------------------------------------------
                			finalvals[i].pdo18 = finalvals[flaskpair[0]].o18 - $
						finalvals[flaskpair[1]].o18   
                			IF (ABS(finalvals[i].pdo18) GT o18pdlimit) THEN BEGIN
						IF (finalvals[i].pdo18 GT 0) THEN BEGIN
							finalvals[flaskpair[0]].flago18 = '+..' 
							finalvals[flaskpair[1]].flago18 = '-..'
						ENDIF ELSE BEGIN
							finalvals[flaskpair[0]].flago18 = '-..' 
							finalvals[flaskpair[1]].flago18 = '+..'
						ENDELSE
					ENDIF ELSE BEGIN
                				finalvals[flaskpair[0]].flago18 = '...' 
						finalvals[flaskpair[1]].flago18 = '...'
					ENDELSE
					;---NO PAIR DIFF FLAGS FOR TEST FLASKS---
					IF (site[i] EQ 'TST')OR (site[i] EQ 'BLD') OR (type[i] EQ 'SIL')THEN BEGIN
						finalvals[flaskpair[0]].flago18 = '...' 
						finalvals[flaskpair[1]].flago18 = '...'
					ENDIF
				;------ in case you run more than one pair from the same 'batch' (filled same yr,mo,dy,hr,mn,meth)
        			ENDIF ELSE BEGIN 
			
					IF (site[i] EQ 'TST')OR (site[i] EQ 'BLD')OR (site[i] EQ 'SIL')THEN BEGIN
						finalvals[i].flagc13='...'
						finalvals[i].flago18='...'			
					ENDIF ELSE BEGIN
						;;this should never happen. error??
						;print, 'nflaskpair is greater than 2, but is not a pair flask. ERROR!'
						finalvals[i].flagc13='...'
						finalvals[i].flago18='...'
					ENDELSE    
				ENDELSE				
			ENDELSE
		ENDIF
	ENDELSE
	
	IF enum[i] EQ '00470226' THEN stop
	  ; (ENDIF type EQ "SMP" or "SIL")

        ; ----- insert ref set standard devations in place of pair difference -----------
        ;--------this is just filler data - it is not used for anything.
	IF (type[i] EQ 'CRF') OR (type[i] EQ 'REF') OR (type[i] EQ 'HRF') THEN BEGIN
				   finalvals[i].pdc13 = refarr[nrefs-1].stdev45
				   finalvals[i].pdo18 = refarr[nrefs-1].stdev46
	ENDIF ELSE BEGIN
	        ;for all tanks and carbs and h2o do these routines
		IF ((site[i] EQ 'STD') OR (site[i] EQ 'TRP') OR (site[i] EQ 'CRB') OR $
			(site[i] EQ 'H2O')) THEN BEGIN
			tankset = WHERE(site EQ site[i] AND $
					id EQ id[i] AND $ 
               				yr EQ yr[i] AND $
                		        mo EQ mo[i] AND $
                		        dy EQ dy[i] AND $
                	        	hr EQ hr[i] AND $
                	        	mn EQ mn[i] AND $
					type EQ type[i] AND $
                	        	meth EQ meth[i], ntankset)
			; sre added "id EQ id" - otherwise tanks filled on same day were calculated as a
		  	;	single tank set (=bad)
			tankfinalvals = finalvals(tankset)

        		IF tankset[0] EQ -1 THEN BEGIN
                		finalvals[i].pdc13 = -999.99
                		finalvals[i].flagc13 = '..S'
				finalvals[i].pdo18 = -999.99
                		finalvals[i].flago18 = '..S'
	
        		ENDIF ELSE BEGIN
				IF N_ELEMENTS(tankfinalvals.c13) GT 1 THEN BEGIN
					tankavec13 = MOMENT(tankfinalvals.c13,sdev=c13stdevtank)
					finalvals[i].pdc13 = c13stdevtank
                		ENDIF
				finalvals[i].flagc13 = '...' 
				finalvals[i].flagc13 = '...'
				
				; ----- pairdifference flag for o18 ------------------------------
                		IF N_ELEMENTS(tankfinalvals.o18) GT 1 THEN BEGIN ;used to say (tankaveo18)
					tankaveo18 = MOMENT(tankfinalvals.o18,sdev=o18stdevtank)
					finalvals[i].pdo18 = o18stdevtank   
                		ENDIF
				finalvals[i].flago18 = '...' 
				finalvals[i].flago18 = '...'
        		ENDELSE
		ENDIF
	ENDELSE
ENDFOR

; ----- ANALYSIS ERROR FLAG -----------------------------------------------------
;  In this section of code, we analyze the standard deviation of the refs and judge whether the samples
; associated with each set should be flagged. Limits on the standard deviation of the refs are declared above
; under the knobs section. SRE re-evaluated this section in 2/07
; CASE 1: Any time more than 2 sets of refs are bad, the whole run is flagged.
; CASE 2: If the 2nd set of a 3 or higher ref set is bad, then the drift correction will ignore the second set and 
;       drift correct from the first to the 3rd set. This is designed for the 3 refset run (it can't drift correct 
;       from the 2nd to 4th refset, as of yet.) If the 2nd refset is ignored in the drift correction, samples do not 
;  	need to be flagged.
;CASE 3: The first refset is bad, in which the samples between the first and second refsets are flagged
;CASE 4: The third refset is bad, in which case the samples between the second and third refsets are flagged.
;	If there are more than 3 refsets, the samples between the third and fourth refsets are flagged. This handles any
;	length of ref-sam-ref-sam-ref-sam-ref situations. 
;   *** Refs are flagged separately. They are flagged based on the standard deviation of that set of refs.
;   ***	There may be run structures that are confused by this new logic. .. good luck reprocessing! 

IF nc13poop GE 1 THEN BEGIN
	IF nc13poop GT 1 THEN BEGIN
	print,'nc13poop GT 1'
		FOR i=0, nlines-1 DO finalvals[i].flagc13 = 'A' + STRMID(finalvals[i].flagc13,1,2)
	ENDIF ELSE BEGIN  ;nc13poop EQ 1
		IF nrefs GT 2 THEN BEGIN
			IF c13poop[0] EQ 1 THEN BEGIN
				; do nothing - you already drift corrected from beginning to end, so middle set is ignored
			ENDIF ELSE BEGIN
				IF (c13poop[0] EQ 0) THEN BEGIN ; ;flag just first half
					firstsam=samsets[0,0]-samsets[1,0]+1
					numsam = samsets[1,0] ; last sample position to flag
					FOR i=firstsam, firstsam+numsam-1 DO finalvals[i].flagc13 = 'A' + STRMID(finalvals[i].flagc13,1,2)
				ENDIF ELSE BEGIN 
					FOR k=2,nrefs DO BEGIN
						IF c13poop EQ k THEN BEGIN
							firstsam=samsets[0,k-1]-samsets[1,k-1]+1
							numsam=samsets[1,k-1]
							FOR i = firstsam, firstsam+numsam-1 DO BEGIN
								finalvals[i].flagc13 = 'A' + STRMID(finalvals[i].flagc13,1,2)
							ENDFOR
							IF nrefs GT (k+1) THEN BEGIN 
							;if more than 3 sets of refs, have to flag before and after your bad refs.
							;this is a bad "second middle set" that is not handled by the more specific drift
							;correction get-around of a normal middle set.
								thisfirstsam=FIX(samsets[0,k]-samsets[1,k]+1)
								thisnumsam=FIX(samsets[1,k])
								FOR g = thisfirstsam,(thisnumsam + thisfirstsam - 1) DO BEGIN
									finalvals[g].flagc13 = 'A' + STRMID(finalvals[g].flagc13,1,2)
								ENDFOR
							ENDIF
						ENDIF
					ENDFOR
				ENDELSE	
			ENDELSE
		ENDIF ELSE BEGIN ;(only 2 nrefs)
			FOR i=0, nlines-1 DO finalvals[i].flagc13 = 'A' + STRMID(finalvals[i].flagc13,1,2)
		ENDELSE
	ENDELSE
ENDIF
	

IF no18poop GE 1 THEN BEGIN
	IF no18poop GT 1 THEN BEGIN

		FOR i=0, nlines-1 DO finalvals[i].flago18 = 'A' + STRMID(finalvals[i].flago18,1,2)
	ENDIF ELSE BEGIN  ;no18poop EQ 1
		IF nrefs GT 2 THEN BEGIN
			IF o18poop[0] EQ 1 THEN BEGIN
				
				; do nothing - you already drift corrected from beginning to end, so middle set is ignored
			ENDIF ELSE BEGIN
				IF (o18poop[0] EQ 0) THEN BEGIN ; ;flag just first half
					firstsam=samsets[0,0]-samsets[1,0]+1
					numsam = samsets[1,0] ; last sample position to flag
					FOR i=firstsam, firstsam+numsam-1 DO finalvals[i].flago18 = 'A' + STRMID(finalvals[i].flago18,1,2)
				ENDIF ELSE BEGIN 
					FOR k=2,nrefs DO BEGIN
						IF o18poop EQ k THEN BEGIN
							firstsam=samsets[0,k-1]-samsets[1,k-1]+1
							numsam=samsets[1,k-1]
							FOR i = firstsam, firstsam+numsam-1 DO BEGIN
								finalvals[i].flago18 = 'A' + STRMID(finalvals[i].flago18,1,2)
							ENDFOR
							IF nrefs GT (k+1) THEN BEGIN 
							;if more than 3 sets of refs, have to flag before and after your bad refs.
							;this is a bad "second middle set" that is not handled by the more specific drift
							;correction get-around of a normal middle set. 
								thisfirstsam=FIX(samsets[0,k]-samsets[1,k]+1)
								thisnumsam=FIX(samsets[1,k])
								FOR g = thisfirstsam,(thisnumsam + thisfirstsam - 1) DO BEGIN
									finalvals[g].flago18 = 'A' + STRMID(finalvals[g].flago18,1,2)
								ENDFOR
							ENDIF
						ENDIF
					ENDFOR
				ENDELSE	
			ENDELSE
		ENDIF ELSE BEGIN ;(only 2 nrefs)
			FOR i=0, nlines-1 DO finalvals[i].flago18 = 'A' + STRMID(finalvals[i].flago18,1,2)
		ENDELSE
	ENDELSE
ENDIF

;flag bad refs	
FOR j=0,nrefs-1 DO BEGIN
		badref=WHERE(grouparr EQ (j+1))
		startbadref=refpos[badref[0]]
		endbadref=refpos[badref[cluster[j]-1]]
	;---flag bad c13 refs	
	IF (refarr[j].c13reflag EQ 'a') THEN BEGIN
		FOR i=startbadref, endbadref DO finalvals[i].flagc13 = 'A..' 	
	ENDIF ELSE BEGIN
		FOR i=startbadref, endbadref DO finalvals[i].flagc13 = '...' 
	ENDELSE
	;---flag bad o18 refs
	IF (refarr[j].o18reflag EQ 'a') THEN BEGIN
		FOR i=startbadref, endbadref DO finalvals[i].flago18 = 'A..' 	
	ENDIF ELSE BEGIN
		FOR i=startbadref, endbadref DO finalvals[i].flago18 = '...' 
	ENDELSE
ENDFOR


; ADD THIRD POSITION FLAG HERE FOR WHEN INTERNAL PRECISION IS HIGH
; (used to be second position, hence the keyword "secposflag"
; Added 4/22/10
IF secposflags EQ 1 THEN BEGIN
	c13pknob=0.02
	o18pknob=0.03

	FOR p=0,nlines-1 DO BEGIN
		IF prec45[p] GE c13pknob THEN BEGIN	
			;finalvals[p].flagc13 = STRMID(finalvals[p].flagc13,0,1)+'P'+$
			;	STRMID(finalvals[p].flagc13,2,1) 
			finalvals[p].flagc13 = STRMID(finalvals[p].flagc13,0,2)+'P'
				
				;for a while in 2008-2009, precision value was high for spock, but data was ok. .. unflag this	  	
			IF inst EQ 'o1' THEN BEGIN
				ccg_date2dec,yr=arraw[p].field3,mo=arraw[p].field4,dy=arraw[p].field5,dec=dec
				IF (dec GE 2008.6885) and (dec LE 2009.0959) THEN BEGIN
					;take out p flag; data was good
					;finalvals[p].flagc13 = STRMID(finalvals[p].flagc13,0,1)+'.'+$
					;	STRMID(finalvals[p].flagc13,2,1) 	
					finalvals[p].flagc13 = STRMID(finalvals[p].flagc13,0,2)+'.'
				ENDIF
			ENDIF
		ENDIF
		IF prec46[p] GT o18pknob THEN BEGIN	
			;finalvals[p].flago18 = STRMID(finalvals[p].flago18,0,1)+'P'+$
			;	STRMID(finalvals[p].flago18,2,1) 	
			finalvals[p].flago18 = STRMID(finalvals[p].flago18,0,2)+'P'
			IF inst EQ 'o1' THEN BEGIN
				ccg_date2dec,yr=arraw[p].field3,mo=arraw[p].field4,dy=arraw[p].field5,dec=dec
				IF (dec GE 2008.6885) and (dec LE 2009.0959) THEN BEGIN
					;take out p flag; data was good
					;finalvals[p].flago18 = STRMID(finalvals[p].flago18,0,1)+'.'+$
					;	STRMID(finalvals[p].flago18,2,1) 	
					finalvals[p].flago18 = STRMID(finalvals[p].flago18,0,2)+'.'
				ENDIF
			ENDIF	  	
		ENDIF
	ENDFOR
ENDIF



;HERE IS WHERE WE GET THE AVERAGE TRAP VALUE AND COMPARE IT TO A LONG-TERM MEAN
; IF IT IS A CERTAIN DISTANCE AWAY FROM THAT MEAN, GIVE IT A SECOND POSITION FLAG.
;THIS COULD CHANGE TO FIRST.
; OR TO THIRD!! This is what we decided 10/17/12


;First, find average trap values. This used to be farther below, with refstat code.
;The raw values for traparr used to be calculated above ~line 900. 
;seems that they should be done together.
;furthermore, traparr averages used to include all 4 traps - 
;  SLY CHANGED THIS 4/22/10 to exclude first trap of every run.

; ----- TRAP TANK STRUCTURE -----------------------------------------------------
; WE HAVE NOT ALWAYS USED THE 'TRP' CONVENTION.  SOME RUNS HAVE ONLY SMP AND REF LINES. 
; SO, WE MUST ACCOUNT FOR THAT. 
; we could potentially use the last position of the second set of references to determine the 
;	beginning and the next four sample positions as the trap tank...

trappos = WHERE(type EQ 'TRP',ntrap)	
IF trappos[0] NE -1 THEN BEGIN
	ourtraps = id(trappos)
	trap = ourtraps[0]
 	traparr = REPLICATE ({	aved45:0.0,	$
				aved46:0.0,	$
				stdev45:0.0,	$
				stdev46:0.0,	$
				avec13:0.0,	$
				aveo18:0.0,	$
				stdevc13:0.0,	$
				stdevo18:0.0,	$
				twptc13:0.0,	$
				twpto18:0.0},1)
	
	IF ntrap GT 2 THEN BEGIN
		tr45=DBLARR(ntrap-1)
		tr46=DBLARR(ntrap-1)
		trgroup13=DBLARR(ntrap-1)
		trgroup18=DBLARR(ntrap-1)
		  FOR l =1, ntrap-1 DO BEGIN ; skip the first trap (so start at 1, not zero)
			tr45[l-1]=d45[trappos[l]]
			tr46[l-1]=d46[trappos[l]]
			trgroup13[l-1] = finalvals[trappos[l]].c13
			trgroup18[l-1] = finalvals[trappos[l]].o18
		  ENDFOR  
		result = MOMENT(tr45,SDEV=crawstdev)
		traparr.aved45 = result[0]
		traparr.stdev45 = crawstdev
		result = MOMENT(tr46,SDEV=orawstdev)
		traparr.aved46 = result[0]
		traparr.stdev46 = orawstdev
		result = MOMENT(trgroup13,SDEV=c13stdev)
		traparr.avec13 = result[0]
		traparr.stdevc13 = c13stdev
		result = MOMENT(trgroup18,SDEV=o18stdev)
		traparr.aveo18 = result[0]
		traparr.stdevo18 = o18stdev
	ENDIF ELSE BEGIN
		traparr.aved45 = d45[trappos[ntrap-1]] 
		traparr.stdev45 = -9
		traparr.aved46 = d46[trappos[ntrap-1]] 
		traparr.stdev46 = -9
		traparr.avec13 = finalvals[trappos[ntrap-1]].c13 
		traparr.stdevc13 = -9
		traparr.aveo18 = finalvals[trappos[ntrap-1]].o18 
		traparr.stdevo18 = -9
	ENDELSE
		
	;now figure out if our value for a trap is within the expected range (3 sigma)
	;trapfile='/projects/co2c13/cals/internal_cyl/stats/co2c13.trapstatfile.txt'
	;CCG_READ, file=trapfile, /nomessages,truetrap
	;thistrap=WHERE(enum[trappos[0]] EQ truetrap.field1)
	;thisref=WHERE(truetrap[thistrap].field3 EQ ref)
	;thistrapdat=truetrap[thistrap[thisref]]
	;stop	
	;ou
	IF secposflags EQ 1 THEN BEGIN
		;trapfile='/projects/co2c13/flask/sb/trap.co2c13'
		;CCG_READ, file=trapfile, /nomessages,truetrap
		


		IF thistrap NE -1 THEN BEGIN
			ctruetrapval=truetrap[thistrap].field5
			otruetrapval=truetrap[thistrap].field6

			ctruetraphigh=ctruetrapval+0.045
			ctruetraplow=ctruetrapval-0.045
			otruetraphigh=otruetrapval+0.09	
			otruetraplow=otruetrapval-0.09
			cbadtrapflag=0	
			obadtrapflag=0

			cveryhigh=ctruetrapval+0.15
			cverylow=ctruetrapval-0.15
			overyhigh=otruetrapval+0.3	
			overylow=otruetrapval-0.3
			
	
			IF traparr.avec13 GT ctruetraphigh THEN cbadtrapflag=1
			IF traparr.avec13 LT ctruetraplow THEN cbadtrapflag=2
			IF traparr.avec13 GT cveryhigh THEN cbadtrapflag=3
			IF traparr.avec13 LT cverylow THEN cbadtrapflag=4
			
			
			IF traparr.aveo18 GT otruetraphigh THEN  obadtrapflag=1
			IF traparr.aveo18 LT otruetraplow THEN  obadtrapflag=2
			IF traparr.aveo18 GT overyhigh THEN  obadtrapflag=3
			IF traparr.aveo18 LT overylow THEN  obadtrapflag=4
			IF cbadtrapflag GE 1 THEN BEGIN
				CASE cbadtrapflag OF	
					1: FOR t=0,nlines-1 DO finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'H'
					2: FOR t=0,nlines-1 DO finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'L'			
					3: FOR t=0,nlines-1 DO finalvals[t].flagc13 = 'H'+ STRMID(finalvals[t].flagc13,1,2)		
					4: FOR t=0,nlines-1 DO finalvals[t].flagc13 = 'H'+ STRMID(finalvals[t].flagc13,1,2)			
				ENDCASE 
			ENDIF
	
			IF obadtrapflag GE 1 THEN BEGIN
				CASE obadtrapflag OF
					1: FOR t=0,nlines-1 DO finalvals[t].flago18 = STRMID(finalvals[t].flago18,0,2)+'H'
					2: FOR t=0,nlines-1 DO finalvals[t].flago18 = STRMID(finalvals[t].flago18,0,2)+'L'			
					3: FOR t=0,nlines-1 DO finalvals[t].flago18 = 'H'+ STRMID(finalvals[t].flago18,1,2)		
					4: FOR t=0,nlines-1 DO finalvals[t].flago18 = 'H'+ STRMID(finalvals[t].flago18,1,2)	
				ENDCASE	
			ENDIF
			
			
			
		;now figure out if our value for a trap has high variance
			IF traparr.stdevc13 GT 0.08 THEN BEGIN
				FOR t=0,nlines-1 DO BEGIN
					
					finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'T'
				ENDFOR		
			ENDIF ELSE BEGIN
			
				IF traparr.stdevc13 LT -90 THEN BEGIN
					FOR t=0,nlines-1 DO BEGIN
						finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'o'
					ENDFOR
				ENDIF
			ENDELSE
			
			IF traparr.stdevo18 GT 0.16 THEN BEGIN
				FOR t=0,nlines-1 DO BEGIN
					finalvals[t].flago18 = STRMID(finalvals[t].flago18,0,2)+'T'
				ENDFOR
			ENDIF ELSE BEGIN
				IF traparr.stdevo18 LT -90 THEN BEGIN
					FOR t=0,nlines-1 DO BEGIN
						finalvals[t].flago18 =STRMID(finalvals[t].flago18,0,2)+'o'
					ENDFOR
				ENDIF
			ENDELSE
			
		ENDIF ELSE BEGIN
			IF secposflags EQ 1 THEN BEGIN
			PRINT, 'No true trap data to compare this trap to!'
				FOR t=0,nlines-1 DO BEGIN
					finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'o'
					finalvals[t].flago18 = STRMID(finalvals[t].flago18,0,2)+'o'
				ENDFOR
			ENDIF
		ENDELSE
	ENDIF
ENDIF ELSE BEGIN
	IF secposflags EQ 1 THEN BEGIN
		FOR t=0,nlines-1 DO BEGIN
			finalvals[t].flagc13 = STRMID(finalvals[t].flagc13,0,2)+'o'
			finalvals[t].flago18 = STRMID(finalvals[t].flago18,0,2)+'o'
			PRINT, 'no trap tank . ..'
		ENDFOR
	ENDIF
ENDELSE	
IF reprocmode EQ 1 THEN BEGIN
;***THIS BIT LOOKS FOR FIRST POSITION FLAGS - other than the +,-,A, and C flags assigned here - THAT WE WANT TO PRESERVE 
;**** WHEN WE REPROCESS OLD DATA 
;**** (for example, CBA data from bad times that looked ok on our analysis but had leaky inlet during sampling.)
;**** Until 2006 we inherited C flags from NOAA. See archived versions of code if you're curious.
FOR i = 0, nlines-1 DO BEGIN
	IF type[i] EQ 'SMP' THEN BEGIN
		cweirdflagfile = '/home/ccg/sil/tempfiles/oct24.checktheseflags.co2c13.txt'
		weirdflagformat='(A10,I5,I10,A5,A20)';;

		oweirdflagfile = '/home/ccg/sil/tempfiles/oct24.checktheseflags.co2o18.txt';;

		
		readstyle=1
		IF readstyle EQ 1 THEN BEGIN
			csitefile='/home/ccg/michel/co2c13/instaar_archive_2024/'+strlowcase(site[i])+'.co2c13'
			ositefile='/home/ccg/michel/co2o18/instaar_archive_2024/'+strlowcase(site[i])+'.co2o18'
			CCG_READ, file=csitefile,colddata,/nomessages
			CCG_READ, file=csitefile,oolddata,/nomessages
		
			foundc=WHERE(enum[i] EQ colddata.field18 AND $
				arraw[i].field3 EQ colddata.field13 AND $
				arraw[i].field4 EQ colddata.field14 AND $
				arraw[i].field5 EQ colddata.field15 AND $
				arraw[i].field6 EQ colddata.field16 AND $
				arraw[i].field7 EQ colddata.field17 AND $
				inst EQ colddata.field12,nfoundc)  
			
		ENDIF ELSE BEGIN
			csitefile='/home/ccg/michel/co2c13/instaar_archive_2024/'+strlowcase(site[i])+'.co2c13.sav'
			ositefile='/home/ccg/michel/co2o18/instaar_archive_2024/'+strlowcase(site[i])+'.co2o18.sav'
			RESTORE,filename=csitefile
			RESTORE,filename=ositefile
			foundc=WHERE(enum[i] EQ colddata.evn AND $
				arraw[i].field3 EQ colddata.ayr AND $
				arraw[i].field4 EQ colddata.amo AND $
				arraw[i].field5 EQ colddata.ady AND $
				arraw[i].field6 EQ colddata.ahr AND $
				arraw[i].field7 EQ colddata.amn AND $
				inst EQ colddata.inst,nfoundc)  
			
		ENDELSE
		
		IF nfoundc GT 1 THEN BEGIN ;; do something
				OPENU, u, cweirdflagfile, /APPEND,/GET_LUN
				PRINTF, u, format=weirdflagformat, runnum, i, enum[i], finalvals[i].flagc13, 'multiple entries'
				FREE_LUN, u
		ENDIF 
		
		IF readstyle EQ 1 THEN fpos=STRMID(colddata[foundc].field11,0,1) ELSE fpos=STRMID(colddata[foundc].flag,0,1)
		IF readstyle EQ 1 THEN thrpos=STRMID(colddata[foundc].field11,2,1) ELSE thrpos=STRMID(colddata[foundc].flag,2,1) 
		
		IF fpos NE '.' THEN BEGIN
			;look at 1st pos flags for special flags. ..
			CASE fpos OF 
			
			'*': BEGIN 
				;flags an un-analyzable sample
				finalvals[i].flagc13='!.'+STRMID(finalvals[i].flagc13,2,1)
			END
			'!': BEGIN 
				;flags an un-analyzable sample
				finalvals[i].flagc13='!.'+STRMID(finalvals[i].flagc13,2,1)
			END
			'N': BEGIN
				;known sampling problem
				 finalvals[i].flagc13 = 'N.'+STRMID(finalvals[i].flagc13,2,1)
				 ; give them N. plus whatever you were going to give them in the 3rd pos (S or .)
			END
			'W': BEGIN
				;wet flasks (actually, not currently in use, but a future useful flag)
				 finalvals[i].flagc13 = 'W.'+STRMID(finalvals[i].flagc13,2,1)
			END
			
			ELSE: BEGIN	
			print,i
			print,fpos
				;IF fpos NE '+' OR '-' OR 'A' OR 'H' OR 'L' OR 'T' OR 'N' or 'n' THEN BEGIN
				;	
				;	;print to a file of weird flags that we might want to consider. 
				;	;stop   ;;;

				;	OPENU, u, cweirdflagfile, /APPEND,/GET_LUN
				;	PRINTF, u,format=weirdflagformat, runnum, i, enum[i], colddata[foundc].field11, 'weird flags' 
				;	FREE_LUN, u
				;ENDIF
				
			END
			ENDCASE
		
		ENDIF ; fpos not '.' 
			 
		 IF thrpos NE '.' THEN BEGIN
			CASE thrpos OF 
			'L':  BEGIN	
			;"linked" 0.5 L flasks, all were eventually determined to be bad
				IF arraw[i].field3 LT 2004 THEN finalvals[i].flagc13 = '!.L'
			END
			'I': BEGIN
			;indicates that an aliquot was taken to be analyzed at another lab
				finalvals[i].flagc13 = STRMID(finalvals[i].flagc13,0,2)+'I'
			END
			'i': BEGIN
			; same as I, but this flag displaced a previous flag in this field.
				finalvals[i].flagc13 = STRMID(finalvals[i].flagc13,0,2)+'i'
			END	
			ELSE: BEGIN
			;	IF fpos EQ 'S' OR 'o' OR 'H' OR 'L' OR 'T' OR 'N' OR 'n' THEN BEGIN
			;		; ignore!
			;	ENDIF ELSE BEGIN;;;;
			;
			;		OPENU, u, cweirdflagfile, /APPEND,/GET_LUN
			;		PRINTF, u,  format=weirdflagformat,runnum, i, enum[i], colddata[foundc].field11, 'weird flags' 
			;		FREE_LUN, u
			;	ENDELSE 
			END		
			ENDCASE
		ENDIF	 
	
	
	
	;;; now oxygen
			IF readstyle EQ 1 THEN BEGIN
				foundo=WHERE(enum[i] EQ oolddata.field18 AND $
				arraw[i].field3 EQ oolddata.field13 AND $
				arraw[i].field4 EQ oolddata.field14 AND $
				arraw[i].field5 EQ oolddata.field15 AND $
				arraw[i].field6 EQ oolddata.field16 AND $
				arraw[i].field7 EQ oolddata.field17 AND $
				inst EQ oolddata.field12,nfoundo)  
			ENDIF ELSE BEGIN
				foundo=WHERE(enum[i] EQ oolddata.evn AND $
				arraw[i].field3 EQ oolddata.ayr AND $
				arraw[i].field4 EQ oolddata.amo AND $
				arraw[i].field5 EQ oolddata.ady AND $
				arraw[i].field6 EQ oolddata.ahr AND $
				arraw[i].field7 EQ oolddata.amn AND $
				inst EQ oolddata.inst,nfoundo)  

			ENDELSE
		IF nfoundo GT 1 THEN BEGIN ;; do something
				OPENU, u, oweirdflagfile, /APPEND,/GET_LUN
				PRINTF, u, format=weirdflagformat, runnum, i, enum[i], oolddata[foundc].field11, 'multiple entries'
				FREE_LUN, u
		ENDIF 
		
		IF readstyle EQ 1 THEN fpos=STRMID(oolddata[foundo].field11,0,1) ELSE fpos=STRMID(oolddata[foundo].flag,0,1)
		IF readstyle EQ 1 THEN thrpos=STRMID(oolddata[foundo].field11,2,1) ELSE thrpos=STRMID(oolddata[foundo].flag,2,1)
		
		IF fpos NE '.' THEN BEGIN
			;look at 1st pos flags for special flags. ..
			CASE fpos OF 
			
			'*': BEGIN 
				;flags an un-analyzable sample
				finalvals[i].flago18='!.'+STRMID(finalvals[i].flago18,2,1)
			END
			'!': BEGIN 
				;flags an un-analyzable sample
				finalvals[i].flago18='!.'+STRMID(finalvals[i].flago18,2,1)
			END
			'N': BEGIN
				;known sampling problem
				 finalvals[i].flago18 = 'N.'+STRMID(finalvals[i].flago18,2,1)
				 ; give them N. plus whatever you were going to give them in the 3rd pos (S or .)
			END
			'W': BEGIN
				;wet flasks (actually, not currently in use, but a future useful flag)
				 finalvals[i].flago18 = 'W.'+STRMID(finalvals[i].flago18,2,1)
			END
			
			ELSE: BEGIN	
				;print to a file of weird flags that we might want to consider. 
			;	IF fpos EQ '+' OR '-' OR 'A' OR 'H' OR 'L' OR 'T' THEN BEGIN
			;		; ignore!
			;	ENDIF ELSE BEGIN
			;		;;

				;	OPENU, u, oweirdflagfile, /APPEND,/GET_LUN
				;	PRINTF, u, format=weirdflagformat, runnum, i, enum[i], oolddata[foundc].field11, 'weird flags' 
				;	FREE_LUN, u
				;ENDELSE
			END
			ENDCASE
		
		ENDIF ; fpos not '.' 
			 
		 IF thrpos NE '.' THEN BEGIN
			CASE thrpos OF 
			'L':  BEGIN	
			;"linked" 0.5 L flasks, all were eventually determined to be bad
				IF arraw[i].field3 LT 2004 THEN finalvals[i].flago18 = '!.L'
			END
			'I': BEGIN
			;indicates that an aliquot was taken to be analyzed at another lab
				finalvals[i].flago18 = STRMID(finalvals[i].flago18,0,2)+'I'
			END
			'i': BEGIN
			; same as I, but this flag displaced a previous flag in this field.
				finalvals[i].flago18 = STRMID(finalvals[i].flago18,0,2)+'i'
			END	
			ELSE: BEGIN
			
			;	IF fpos EQ 'S' OR 'o' OR 'H' OR 'L' OR 'T' THEN BEGIN
					; ignore!
			;	ENDIF ELSE BEGIN;;

				;	OPENU, u, oweirdflagfile, /APPEND,/GET_LUN
				;	PRINTF, u, format=weirdflagformat, runnum, i, enum[i], oolddata[foundc].field11, 'weird flags' 
				;	FREE_LUN, u
			;	ENDELSE
			END		
			ENDCASE
		ENDIF	 
	
	
	

	ENDIF

ENDFOR ;loop to flag-check
ENDIF

IF flagitall EQ 1 THEN BEGIN
		IF donotask EQ 0 THEN BEGIN
			areyasure=DIALOG_MESSAGE ('YOU ARE ! FLAGGING ALL SAMPLES!! IS THIS WHAT YOU WANT TO DO?', title = 'Continue',/Question, /cancel)
			IF areyasure EQ 'Cancel' THEN goto,bailout
			IF areyasure EQ 'No' THEN goto,bailout
		ENDIF
		FOR i=0, nlines-1 DO BEGIN	
			 finalvals[i].flagc13='!'+STRMID(finalvals[i].flagc13,1,2)
			 finalvals[i].flago18='!'+STRMID(finalvals[i].flagc13,1,2)
		ENDFOR
ENDIF



; ----- GET ALL DATA INTO ONE HAPPY ARRAY ---------------------------------------
farr = REPLICATE ({ 	enum:'',	$
			site:'',	$
			yr:0,		$
			mo:0,		$
			dy:0,		$
			hr:0,		$
			mn:0,		$
			id:'',		$
			meth:'',	$
			c13:0.0D,	$
			c13flag:'',	$
			o18:0.0D,	$
			o18flag:'',	$
			twptc13:0.0D,	$
			twpto18:0.0D,	$
			inst:'',	$
			ayr:0,		$
			amo:0,		$
			ady:0,		$
			ahr:0,		$
			amn:0,		$
			asc:0,		$
			run:'',		$
			num:0,		$
			d45:0.0,	$
			prec45:0.0,	$
			d46:0.0,	$
			prec46:0.0,	$
			ref:'',		$
			samtemp:0.0,	$
			airpressure:0.0,$
			co2pressure:0.0},	$
			nlines)			
FOR i = 0, nlines-1 DO BEGIN 
	farr[i].enum   = enum[i]
	farr[i].site =  site[i]  
	farr[i].yr = yr[i]
	farr[i].mo = mo[i]  
	farr[i].dy = dy[i]
	farr[i].hr = hr[i]
	farr[i].mn = mn[i]
	farr[i].id = id[i]  
	farr[i].meth = meth[i]   
	farr[i].ayr = arraw[i].field3
	farr[i].amo = arraw[i].field4
	farr[i].ady = arraw[i].field5
	farr[i].ahr = arraw[i].field6
	farr[i].amn = arraw[i].field7
	farr[i].asc = arraw[i].field8
	farr[i].c13 = finalvals[i].c13
	farr[i].twptc13 = finalvals[i].twptc13
	farr[i].c13flag = finalvals[i].flagc13
	farr[i].o18 = finalvals[i].o18
	farr[i].twpto18 = finalvals[i].twpto18
	farr[i].o18flag = finalvals[i].flago18
	farr[i].run = runnum
	farr[i].inst = inst
	farr[i].d45 = d45[i]
	farr[i].prec45 = prec45[i]
	farr[i].d46 = d46[i]
	farr[i].prec46 = prec46[i]
	farr[i].ref = ref
	farr[i].num = num[i]
	farr[i].airpressure = airpressure[i]
	farr[i].co2pressure = co2pressure[i]
	
	IF samtemp[i] EQ 0.00 THEN BEGIN
		farr[i].samtemp=-99
	ENDIF ELSE BEGIN 
		farr[i].samtemp=samtemp[i]
	ENDELSE


ENDFOR


;first, deal with trap data, and from that, calculate uncertainty
; ----- WRITE TO PERFORMANCE FILE FOR TRAP TANK ---------------------------------
IF trappos[0] NE -1 THEN BEGIN
	trapformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),2(F10.3,1X,F8.3),2(F10.3,A4),A9,2F10.3)'
	trapfile = '/projects/co2c13/'+calsdir+'/internal_cyl/trap' + trap + '.co2c13'   
	;trapfile = '/projects/co2c13/'+calsdir+'/internal_cyl/test/trap' + trap + '.co2c13' -----BHV MOD
	trapfileexist = FILE_TEST(trapfile)
	
	
	IF trapfileexist EQ 0 THEN BEGIN
		OPENW, u, trapfile, /GET_LUN
		FOR i = 0, ntrap-1 DO PRINTF, u, FORMAT = trapformat, farr[trappos[i]].id, $
			farr[trappos[i]].yr, farr[trappos[i]].mo, farr[trappos[i]].dy, $
			farr[trappos[i]].run, farr[trappos[i]].inst, farr[trappos[i]].ayr, $
			farr[trappos[i]].amo, farr[trappos[i]].ady, farr[trappos[i]].ahr, $
			farr[trappos[i]].amn, farr[trappos[i]].asc, farr[trappos[i]].d45, $
			farr[trappos[i]].prec45, farr[trappos[i]].d46, farr[trappos[i]].prec46, $
			farr[trappos[i]].c13, farr[trappos[i]].c13flag, farr[trappos[i]].o18, $
			farr[trappos[i]].o18flag, farr[trappos[i]].ref,farr[trappos[i]].twptc13,farr[trappos[i]].twpto18
	ENDIF ELSE BEGIN

		CCG_READ, file = trapfile, /nomessages, trapfilearr ; comment out for new file
		
		exists = WHERE (trapfilearr.field5 EQ farr[trappos[0]].run,complement=othervals)

		IF othervals[0] NE -1 THEN BEGIN
			othervalarr=trapfilearr[othervals]
			nother=N_ELEMENTS(othervals) 
					
			newrunarr=STRARR(nother)
			FOR n=0,nother-1 DO BEGIN
				IF othervalarr[n].field5 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
			ENDFOR
			
		ENDIF ELSE BEGIN
			 nother=0
		ENDELSE		
		 
		IF (exists[0] EQ -1) THEN BEGIN 
		OPENU, u, trapfile, /APPEND, /GET_LUN
			FOR i = 0, ntrap -1 DO PRINTF, u, FORMAT = trapformat, farr[trappos[i]].id, $
				farr[trappos[i]].yr, farr[trappos[i]].mo, farr[trappos[i]].dy, $
				farr[trappos[i]].run, farr[trappos[i]].inst, farr[trappos[i]].ayr, $
				farr[trappos[i]].amo, farr[trappos[i]].ady, farr[trappos[i]].ahr, $
				farr[trappos[i]].amn, farr[trappos[i]].asc, farr[trappos[i]].d45, $
				farr[trappos[i]].prec45, farr[trappos[i]].d46, farr[trappos[i]].prec46, $
				farr[trappos[i]].c13, farr[trappos[i]].c13flag, farr[trappos[i]].o18, $
				farr[trappos[i]].o18flag, farr[trappos[i]].ref,farr[trappos[i]].twptc13,farr[trappos[i]].twpto18
			FREE_LUN,u
		ENDIF ELSE BEGIN
			newtraparr = REPLICATE({	id:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					run:'',		$
					inst:'',	$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					d45:0.0,	$
					prec45:0.0,	$
					d46:0.0,	$
					prec46:0.0,	$
					c13:0.0,	$
					c13flag:'',	$
					o18:0.0,	$
					o18flag:'',	$
					ref:'',		$
					twptc13:0.0,	$
					twpto18:0.0},	$
					nother +ntrap)
				
				FOR v=0, ntrap-1 DO BEGIN
					newtraparr[v].id=farr[trappos[v]].id
					newtraparr[v].yr=farr[trappos[v]].yr
					newtraparr[v].mo=farr[trappos[v]].mo
					newtraparr[v].dy=farr[trappos[v]].dy
					newtraparr[v].run=farr[trappos[v]].run
					newtraparr[v].inst=farr[trappos[v]].inst
					newtraparr[v].ayr=farr[trappos[v]].ayr
					newtraparr[v].amo=farr[trappos[v]].amo
					newtraparr[v].ady=farr[trappos[v]].ady
					newtraparr[v].ahr=farr[trappos[v]].ahr
					newtraparr[v].amn=farr[trappos[v]].amn
					newtraparr[v].asc=farr[trappos[v]].asc
					newtraparr[v].d45=farr[trappos[v]].d45
					newtraparr[v].prec45=farr[trappos[v]].prec45
					newtraparr[v].d46=farr[trappos[v]].d46
					newtraparr[v].prec46=farr[trappos[v]].prec46
					newtraparr[v].c13=farr[trappos[v]].c13
					newtraparr[v].c13flag=farr[trappos[v]].c13flag
					newtraparr[v].o18=farr[trappos[v]].o18
					newtraparr[v].o18flag=farr[trappos[v]].o18flag
					newtraparr[v].ref=farr[trappos[v]].ref
					newtraparr[v].twptc13=farr[trappos[v]].twptc13
					newtraparr[v].twpto18=farr[trappos[v]].twpto18
					ENDFOR
					
				FOR h=0, nother-1 DO BEGIN
					newtraparr[h+ntrap].id=othervalarr[h].field1
					newtraparr[h+ntrap].yr=othervalarr[h].field2
					newtraparr[h+ntrap].mo=othervalarr[h].field3
					newtraparr[h+ntrap].dy=othervalarr[h].field4
					newtraparr[h+ntrap].run=newrunarr[h]
					newtraparr[h+ntrap].inst=othervalarr[h].field6
					newtraparr[h+ntrap].ayr=othervalarr[h].field7
					newtraparr[h+ntrap].amo=othervalarr[h].field8
					newtraparr[h+ntrap].ady=othervalarr[h].field9
					newtraparr[h+ntrap].ahr=othervalarr[h].field10
					newtraparr[h+ntrap].amn=othervalarr[h].field11
					newtraparr[h+ntrap].asc=othervalarr[h].field12
					newtraparr[h+ntrap].d45=othervalarr[h].field13
					newtraparr[h+ntrap].prec45=othervalarr[h].field14
					newtraparr[h+ntrap].d46=othervalarr[h].field15
					newtraparr[h+ntrap].prec46=othervalarr[h].field16
					newtraparr[h+ntrap].c13=othervalarr[h].field17
					newtraparr[h+ntrap].c13flag=othervalarr[h].field18
					newtraparr[h+ntrap].o18=othervalarr[h].field19
					newtraparr[h+ntrap].o18flag=othervalarr[h].field20
					newtraparr[h+ntrap].ref=othervalarr[h].field21
					newtraparr[h+ntrap].twptc13=othervalarr[h].field22
					newtraparr[h+ntrap].twpto18=othervalarr[h].field23					
				ENDFOR
						
			nnew=nother+ntrap		
			adate = DBLARR(nnew)
			FOR b=0, nnew -1 DO BEGIN
				CCG_DATE2DEC, YR=newtraparr[b].ayr, $
					MO=newtraparr[b].amo, DY=newtraparr[b].ady, $
					HR=newtraparr[b].ahr,MN=newtraparr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newtraparr=newtraparr[SORT(adate)]
			
			OPENW, u, trapfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=trapformat,newtraparr[a]
			FREE_LUN, u
		ENDELSE
	ENDELSE
	FREE_LUN, u
ENDIF

;************* UNCERTAINTY CODE GOES HERE!************** 

IF uncertainty EQ 1 THEN BEGIN
	; back story: this was written in ~2010 (?) to assess our medium-term repeatability. We will start using it now
	;(2019) in combination with other sources of uncertainty (ie, unc in propagation of scale, etc. It is a stdev of 10
	;runs' worth of data, but not just the stdev of ~30 samples; it's the summed difference in value from the day's average trap
	;value, divided by n-10. N is usually 30. 
	
	;to solve for varA (see more in unc below)
	;(varA)^0.5=sum[di^2]/(n-10)
	
	; Figure out which file I want. Usually this will be whatever trap file I'm working with - but for data overhaul 2019 I
	;have to read the trap file that's generally in use...
	IF trappos[0] NE -1 THEN BEGIN
	
		thistrap='/projects/co2c13/'+calsdir+'/internal_cyl/trap'+trap+'.co2c13'
		CCG_READ,file=thistrap,thistrapdat

		ctrapn=INTARR(10)
		ctrapmean=FLTARR(10)
		ctrapsd=FLTARR(10)
		ctrapnums=FLTARR(8,10)

		index=0
		t=0 ; how many positions filled
		j=0  ; how many runnums tried
		x=0
		workwiththisref=ref
		
		WHILE t LT 10 DO BEGIN
		print,t
		thisrunnum=runnum-j
		starthere=WHERE(FIX(thistrapdat.field5) EQ FIX(thisrunnum),numthis) 

		fixstart=FIX(starthere[0])

			IF starthere[0] EQ -1 THEN BEGIN

			;this could be because of no trap tank this run - that would happen if t=0
			;or it could happen later on because we ran out of data for this file
				IF t EQ 0 THEN BEGIN ; no trap data for this run but getting previous data
					j=j+1   ; but what about beginning of traptank??
					x=x+1
					IF x EQ 3 THEN GOTO,bump
				ENDIF ELSE BEGIN
					;WE have reached the beginning of the trap tank file. MUST get out of here and work with data we have
					; wait. what if the previous run didn't have trap. Or we missed a run. let's have a three strikes rule
					x=x+1
					IF x EQ 3 THEN GOTO,bump
				ENDELSE
			
			ENDIF ELSE BEGIN
				; does this run have the appropriate ref and inst?
				checkref= thistrapdat[starthere[0]].field21 
				IF checkref EQ workwiththisref THEN BEGIN
			
					IF numthis GT 2 THEN BEGIN 
						IF STRMID(thistrapdat[starthere[0]].field18,0,1) EQ '.' THEN BEGIN
							FOR d=0,numthis-2 DO ctrapnums[d,t]=thistrapdat[starthere[numthis-d-1]].field17
							t=t+1
							j=j+1
						ENDIF ELSE BEGIN
							j=j+1				
						ENDELSE
					ENDIF ELSE BEGIN
						IF numthis GT 1 THEN BEGIN
							FOR d=0,numthis-1 DO ctrapnums[d,t]=thistrapdat[starthere[numthis-d-1]].field17
							t=t+1
							j=j+1
						ENDIF ELSE BEGIN
							j=j+1
						ENDELSE
					ENDELSE
				ENDIF ELSE BEGIN		
					j=j+1
					
				ENDELSE
			ENDELSE
		ENDWHILE
	
		bump:
		IF t NE 0 THEN BEGIN
			ctrapnums=ctrapnums[*,0:t-1]   ; in case you couldn't fill up whole array
			;now do stats on your ctrapnums but take out any blanks
			arrlen=N_ELEMENTS(ctrapnums[0,*])
		
			FOR t=0,arrlen-1 DO BEGIN
				okcnum=WHERE(ctrapnums[*,t] NE 0,chowmanytrapsthisday)
				ctrapn[t]=chowmanytrapsthisday
				ctrapsd[t]=STDEV(ctrapnums[okcnum,t])	
				ctrapmean[t]=MEAN(ctrapnums[okcnum,t])	
			ENDFOR
									
				sofj=FLTARR(arrlen)     
				sumnoms=FLTARR(arrlen)
				sumdenoms=FLTARR(arrlen)
				FOR u=0,arrlen-1 DO BEGIN
					
					poolarr=DBLARR(ctrapn[u])
					addthem=0.0
						FOR v=0,ctrapn[u]-1 DO BEGIN
							poolarr[v]=(ctrapnums[v,u]-ctrapmean[u])^2
							addthem=addthem+poolarr[v]
							
						ENDFOR
					
					sofj[u]=(addthem/(ctrapn[u]-1))^0.5
					; by the way. sofj is the same as stdev
				ENDFOR
						
				addnoms=0.0
				adddenoms=0.0
				
				FOR u=0,arrlen-1 DO BEGIN
					sumnoms[u]=sofj[u]^2*(ctrapn[u]-1)
					addnoms=addnoms+sumnoms[u]
					sumdenoms[u]=ctrapn[u]-1
					adddenoms=adddenoms+sumdenoms[u]
				ENDFOR
			
				SOFP=(addnoms/adddenoms)^0.5
				uncc=sofp  ; now using pooled variance	;
		ENDIF ELSE BEGIN
				refmo=MOMENT(refarr[c13flagok].stdevc13,sdev=sdev)
				uncc=refmo[0]
	
		ENDELSE
		
		;**now do the same for oxygen
	
		otrapn=INTARR(10)
		otrapmean=FLTARR(10)
		otrapsd=FLTARR(10)
		otrapnums=FLTARR(8,10)
	
		index=0
		t=0 ; how many positions filled
		j=0  ; how many runnums tried
		x=0
		workwiththisref=ref
		
		WHILE t LT 10 DO BEGIN
		thisrunnum=runnum-j
		starthere=WHERE(thistrapdat.field5 EQ thisrunnum,numthis) 
		
		fixstart=FIX(starthere[0])
		
		
			IF starthere[0] EQ -1 THEN BEGIN 
			;this could be because of no trap tank this run - that would happen if t=0
			;or it could happen later on because we ran out of data for this file
				IF t EQ 0 THEN BEGIN ; no trap data for this run but getting previous data
					j=j+1   ; but what about beginning of traptank??
					x=x+1
					IF x EQ 3 THEN BEGIN
					
					;	print,'out of options, bumping out, t=0'
						GOTO,bumpo
					ENDIF
				ENDIF ELSE BEGIN
					;WE have reached the beginning of the trap tank file. MUST get out of here and work with data we have
					; wait. what if the previous run didn't have trap. Or we missed a run. let's have a three strikes rule
					x=x+1
					IF x EQ 3 THEN BEGIN
					
					;print,'out of options, bumping out'
					GOTO,bumpo
					ENDIF
				ENDELSE
			ENDIF ELSE BEGIN
				; does this run have the appropriate ref and inst?
				checkref= thistrapdat[starthere[0]].field21 
				IF checkref EQ workwiththisref THEN BEGIN
					IF numthis GT 2 THEN BEGIN
						IF STRMID(thistrapdat[starthere[0]].field20,0,1) EQ '.' THEN BEGIN
				
							FOR d=0,numthis-2 DO otrapnums[d,t]=thistrapdat[starthere[numthis-d-1]].field19
							t=t+1
							j=j+1
						ENDIF ELSE BEGIN
							j=j+1				
						ENDELSE
					ENDIF ELSE BEGIN
						IF numthis GT 1 THEN BEGIN
							FOR d=0,numthis-1 DO otrapnums[d,t]=thistrapdat[starthere[numthis-d-1]].field19
							t=t+1
							j=j+1
						ENDIF ELSE BEGIN	
							j=j+1
						ENDELSE
					ENDELSE
				ENDIF ELSE BEGIN
					j=j+1
				ENDELSE		
			ENDELSE
		ENDWHILE
	
		bumpo:
	
		IF t NE 0 THEN BEGIN
			otrapnums=otrapnums[*,0:t-1]   ; in case you couldn't fill up whole array
			;now do stats on your otrapnums but take out any blanks
			arrlen=N_ELEMENTS(otrapnums[0,*])
			
			FOR t=0,arrlen-1 DO BEGIN
				okonum=WHERE(otrapnums[*,t] NE 0,ohowmanytrapsthisday)
				otrapn[t]=ohowmanytrapsthisday
				otrapsd[t]=STDEV(otrapnums[okonum,t])	
				otrapmean[t]=MEAN(otrapnums[okonum,t])	
			ENDFOR	
									
				sofj=FLTARR(arrlen)     
				sumnoms=FLTARR(arrlen)
				sumdenoms=FLTARR(arrlen)
				FOR u=0,arrlen-1 DO BEGIN
					
					poolarr=DBLARR(otrapn[u])
					addthem=0.0
						FOR v=0,otrapn[u]-1 DO BEGIN
							poolarr[v]=(otrapnums[v,u]-otrapmean[u])^2
							addthem=addthem+poolarr[v]
							
						ENDFOR
				
					sofj[u]=(addthem/(otrapn[u]-1))^0.5
					; by the way. sofj is the same as stdev
				ENDFOR
						
				addnoms=0.0
				adddenoms=0.0
				
				FOR u=0,arrlen-1 DO BEGIN
					sumnoms[u]=sofj[u]^2*(otrapn[u]-1)
					addnoms=addnoms+sumnoms[u]
					sumdenoms[u]=otrapn[u]-1
					adddenoms=adddenoms+sumdenoms[u]
				ENDFOR
			
				sofpo=(addnoms/adddenoms)^0.5
			
			unco=sofpo
			ENDIF ELSE BEGIN			
				refmoo=MOMENT(refarr[o18flagok].stdevo18,sdev=sdev)
				unco=refmoo[0]
			ENDELSE
				
	ENDIF ELSE BEGIN
			;without a trap, need some assessment of run
			; use stdev of three refsets. 	
;***
		goodrefs=refarr[c13flagok]
		goodstdevs=WHERE(goodrefs.stdevc13 GT 0)
		IF goodstdevs[0] NE -1 THEN BEGIN
			refmo=MOMENT(goodrefs[goodstdevs].stdevc13,sdev=sdev)
			uncc=refmo[0]
		ENDIF ELSE BEGIN
			uncc=0.04
		ENDELSE
		
		
		ogoodrefs=refarr[o18flagok]
		ogoodstdevs=WHERE(goodrefs.stdevo18 GT 0)
		IF ogoodstdevs[0] NE -1 THEN BEGIN
			refmoo=MOMENT(ogoodrefs[ogoodstdevs].stdevo18,sdev=sdev)
			unco=refmoo[0]
		ENDIF ELSE BEGIN
			unco=0.06
		ENDELSE

	ENDELSE
	movingalong:
ENDIF


;;;;********* bit here to apply uncertainty to slope correction (with help from Pieter. 4/16/19)
; How do we do this if there is no second point? 
IF twptcorr EQ 1 THEN BEGIN
;goto,skipthisfornow

	IF loupos[0] NE -1 THEN BEGIN
		;;error is minimized when
		;varC=(varA+[(1/4)*varA1]+[1/4*(varA2)])*((C2-C1)^2)/((A2-A1)^2)

		IF uncc GT 0 THEN varA= uncc^2 ELSE varA=0.025^2 			; variance in sample signal .. over what time period?  (0.015)^2
		varA1= mean(refarr[c13flagok].stdev45)^2    			;;mean(pdbvals[refpos].stdevd45)	;;(0.017)^2 	; variance in DEWY d18O=0.056
		varA2 =mean(louarr[louc13flagok].stdev45)^2   			;; mean(pdbvals[loupos].stdev45)     ;;;(0.009)^2	; variance in LOUI d18O=0.035
		C2= trueloud45   ; -13.235  					;d13C= -13.712  d46= -12.234 d18O= -12.217; LOUI true values
		C1=truerefd45    ; -8.179  					;(d13C=8.625)  d46=-3.494 (d18O=-3.479)
		A2=mean(pdbvals[loupos].d45)  					; LOUI raw valuein d45 space
		A1= mean(pdbvals[refpos].d45)					; DEWY raw value in d45 space
		;A=pdbvals[i].d45   						; sample raw value
		varc=FLTARR(nlines)
			
		IF unco GT 0 THEN ovarA= unco^2 ELSE ovarA=0.04^2 			; variance in sample signal .. over what time period?  (0.015)^2
		ovarA1= mean(refarr[o18flagok].stdev46)^2    			 ;;mean(pdbvals[refpos].stdevd45)	;;(0.017)^2 			; variance in DEWY d18O=0.056
		ovarA2 =mean(louarr[louo18flagok].stdev46)^2   			 ;; mean(pdbvals[loupos].stdev45)     ;;;(0.009)^2				; variance in LOUI d18O=0.035
		oO2= trueloud46   						
		oO1= truerefd46 							
		oA2=mean(pdbvals[loupos].d46)  					; LOUI raw valuein d45 space
		oA1= mean(pdbvals[refpos].d46)					; DEWY raw value in d45 space
		;oA=pdbvals[i].d45   						; sample raw value
		varo=FLTARR(nlines)


		FOR c=0,nlines-1 DO BEGIN
			varc[c]=[varA  +  ((((pdbvals[c].d45-A2)^2)/((A2-A1)^2))*varA1)  + ((((pdbvals[c].d45-A1)^2)/((A2-A1)^2))*varA2)] * ((C2-C1)^2)/((A2-A1)^4)
			varo[c]=[ovarA  +  ((((pdbvals[c].d46-oA2)^2)/((oA2-oA1)^2))*ovarA1)  + ((((pdbvals[c].d46-oA1)^2)/((oA2-oA1)^2))*ovarA2)] * ((oO2-oO1)^2)/((oA2-oA1)^4)
			
		ENDFOR
	
		;; I may want to add other bits of uncertainty here too. For instance, the "given" uncertainty in Dewy and Loui? Or, if I'm using a daily standard, the
		;;uncertainty of it relative to D/L? 


		newuncc=(varc)^0.5
		newunco=varo^0.5


		; below plots - useful for visualizing
		test=FLTARR(31)	
		testline=FLTARR(31)
		otest=FLTARR(31)
		otestline=FLTARR(31)

		FOR x=0,30 DO test[x]=(((A1-A2)/30)*x)+A2
		FOR x=0,30 DO otest[x]=(((oA1-oA2)/30)*x)+oA2

		FOR c=0,30 DO BEGIN
			testline[c]=[varA  +  ((((test[c]-A2)^2)/((A2-A1)^2))*varA1)  + ((((test[c]-A1)^2)/((A2-A1)^2))*varA2)] * ((C2-C1)^2)/((A2-A1)^4)
			otestline[c]=[ovarA  +  ((((otest[c]-oA2)^2)/((oA2-oA1)^2))*ovarA1)  + ((((otest[c]-oA1)^2)/((oA2-oA1)^2))*ovarA2)] * ((oO2-oO1)^2)/((oA2-oA1)^4)
		ENDFOR

		;testplot=plot(pdbvals.d45,(varC)^0.5,symbol='circle',color='blue',linestyle=6)
		;testplot.ytitle='uncertainty'
		;testplot.xtitle='d45'
		;testlineplot=plot(test,(testline^0.5),color='red',symbol='circle',linestyle=6,/overplot)
		
		;otestplot=plot(pdbvals.d46,(varO)^0.5,symbol='circle',color='blue',linestyle=6)
		;otestplot.ytitle='uncertainty'
		;otestplot.xtitle='d46'

		;testlineplot=plot(otest,(otestline^0.5),color='red',symbol='circle',linestyle=6,/overplot)


	ENDIF ELSE BEGIN
		; no second ref 
		newuncc=FLTARR(nlines)-0.99
		newunco=FLTARR(nlines)-0.99

	ENDELSE
	;skipthisfornow:
	;newuncc=FLTARR(nlines)-0.99
	;newunco=FLTARR(nlines)-0.99
skipthisfornow:


ENDIF ELSE BEGIN
	;no twptcorr
	;just for now
	newuncc=FLTARR(nlines)-0.99
	newunco=FLTARR(nlines)-0.99

ENDELSE


;; NOW need to combine uncertainties: all of them

; open error file.
; add up the bits in quadrature
; 
;
cerrfile='/projects/co2c13/flask/sb/sieg.error.co2c13'
oerrfile='/projects/co2c13/flask/sb/sieg.error.co2o18'

CCG_READ,file=cerrfile,skip=0,cerror  ; 5 info columns, 6 potential errors
CCG_READ,file=oerrfile,skip=0,oerror

findref=WHERE(cerror.field1 EQ ref)
cerrarr=FLTARR(8)
cerrarr[0]=cerror[findref].field2
cerrarr[1]=cerror[findref].field3
cerrarr[2]=cerror[findref].field4
cerrarr[3]=cerror[findref].field5
cerrarr[4]=cerror[findref].field6
cerrarr[5]=cerror[findref].field7

keeperr=WHERE(cerrarr NE 0.0,nerr)
totalerr=0D

FOR h=0,nerr-1 DO BEGIN
	totalerr=totalerr+(cerrarr[keeperr[h]]^2)
ENDFOR

totalerr=totalerr+(uncc^2) 
;IF twptcorr EQ 0 THEN totalerr=totalerr+(uncc^2) ELSE $ ;stop  ; (add newuncc?)
;totalerr=totalerr+newuncc^2
ccomberr=totalerr^0.5

findref=WHERE(oerror.field1 EQ ref)
oerrarr=FLTARR(6)
oerrarr[0]=oerror[findref].field2
oerrarr[1]=oerror[findref].field3
oerrarr[2]=oerror[findref].field4
oerrarr[3]=oerror[findref].field5
oerrarr[4]=oerror[findref].field6
oerrarr[5]=oerror[findref].field7

okeeperr=WHERE(oerrarr NE 0.0,onerr)
ototalerr=0D
FOR h=0,onerr-1 DO BEGIN
	ototalerr=ototalerr+(oerrarr[okeeperr[h]]^2)
ENDFOR

ototalerr=ototalerr+(unco^2) 
;IF twptcorr EQ 0 THEN ototalerr=ototalerr+(unco^2) ELSE $
	;totalerr=ototalerr+newunco^2
ocomberr=ototalerr^0.5

;********************** there you have it. Combined errors live in ccomberr and ocomberr

	;open file where you print trap data
	sofpfile='/home/ccg/sil/tempfiles/siegerror.'+inst+'.txt'
	
	; print inst, ref, first analysis date, last a date, runnum, cpooledvar, opooledvar, ccombunc,ocombunc
	sofpformat='(A4,A9,I7, F12.6, F12.6, F8.3, F8.3,F8.3, F8.3)'
	
	;inst,ref,adate0,adatelast,runnum,sofpc, sofpo
	
	CCG_DATE2DEC,yr=farr[0].ayr,mo=farr[0].amo,dy=farr[0].ady,hr=farr[0].ahr,mn=farr[0].amn,dec=dec
	firstdate=dec
	CCG_DATE2DEC,yr=farr[nlines-1].ayr,mo=farr[nlines-1].amo,dy=farr[nlines-1].ady,hr=farr[nlines-1].ahr,mn=farr[nlines-1].amn,dec=dec
	lastdate=dec

		OPENW, u, sofpfile,  /GET_LUN,/APPEND
		PRINTF, u,$
		format=sofpformat,inst,ref,runnum,firstdate,lastdate,uncc,unco,ccomberr,ocomberr
		FREE_LUN,u


IF log_data EQ 1 THEN BEGIN
	logc13.unc=uncc
	IF twptcorr EQ 1 THEN logc13.newunc=newuncc

	logo18.unc=unco
	IF twptcorr EQ 1 THEN logo18.newunc=newunco
	
	logheader= ' name raw n2o co2 coef1 coef2 coef3 ncorfact ncorvals dcorvals pdbvals pdbvals2pt nrcorvals nrcorvals2pt unc newunc'

	logformat='(A10,(3(F12.5,1x)),3(E13.6,1X),(F5.2),6(F12.5),(3(F14.7,1X)))'
	OPENW, u,clogfile, /GET_LUN
	PRINTF,u,logheader
	FOR k=0,nlines-1 DO PRINTF,u,format=logformat, logc13[k]
	FREE_LUN,u

	OPENW, u,ologfile, /GET_LUN
	PRINTF,u,logheader
	FOR k=0,nlines-1 DO PRINTF,u,format=logformat, logo18[k]
	FREE_LUN,u

ENDIF 

; ----- WRITE TO STATISTICS FILE FOR TRAP TANK ----------------------------------
IF trappos[0] NE -1 THEN BEGIN
	trapstatformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),6(F8.3),F8.3,A4,3(F8.3),A4,A9,2(F8.3))'	
			
	trapstatfile = '/projects/co2c13/'+calsdir+'/internal_cyl/trapstat' + trap + '.co2c13.' + inst 
		trapstatfileexist = FILE_TEST(trapstatfile)
		
		; will need to calculate 2-pt correction for trap data. ..
		IF ntrap GT 2 THEN BEGIN
		trcorrc13=DBLARR(ntrap-1)
		trcorro18=DBLARR(ntrap-1)
		  FOR l =1, ntrap-1 DO BEGIN ; skip the first trap (so start at 1, not zero)
			trcorrc13[l-1]=finalvals[trappos[l]].twptc13
			trcorro18[l-1]=finalvals[trappos[l]].twpto18
		  ENDFOR  
		result = MOMENT(trcorrc13,SDEV=ccorrstdev)
		traparr.twptc13 = result[0]
		result = MOMENT(trcorro18,SDEV=ocorrstdev)
		traparr.twpto18 = result[0]
		ENDIF ELSE BEGIN
		traparr.twptc13 = finalvals[trappos[ntrap-1]].twptc13
		traparr.twpto18= finalvals[trappos[ntrap-1]].twpto18
	ENDELSE
	
	
	IF trapstatfileexist EQ 0 THEN BEGIN  ; new file...write away with new info
		
		
		
		
		
		OPENW, u, trapstatfile, /GET_LUN
	
			PRINTF, u, FORMAT = trapstatformat, farr[trappos[0]].id, $
			farr[trappos[0]].yr, farr[trappos[0]].mo, farr[trappos[0]].dy, $
			farr[trappos[0]].run, farr[trappos[0]].inst, farr[trappos[0]].ayr, $
			farr[trappos[0]].amo, farr[trappos[0]].ady, farr[trappos[0]].ahr, $
			farr[trappos[0]].amn, farr[trappos[0]].asc, traparr.aved45, $
			traparr.stdev45, traparr.aved46, traparr.stdev46, traparr.avec13, $
			traparr.stdevc13, uncc,farr[trappos[0]].c13flag,traparr.aveo18, $			;used to be uncc and unco
			traparr.stdevo18, unco,farr[trappos[0]].o18flag, farr[trappos[0]].ref,$
			traparr.twptc13,traparr.twpto18
			
			FREE_LUN,u
			
	ENDIF ELSE BEGIN  ;  file already exists, check for existence of data for this run number
	
		CCG_READ, file = trapstatfile, /nomessages, trapstatfilearr ; comment out for new file
		
		exists = WHERE (trapstatfilearr.field5 EQ farr[trappos[0]].run,complement=othervals) ; comment out for new file
		
		
		;  catcharr here  *************************
		
		IF othervals[0] NE -1 THEN BEGIN
			othervalarr=trapstatfilearr[othervals]
			nother=N_ELEMENTS(othervals) 
					
			newrunarr=STRARR(nother)
			FOR n=0,nother-1 DO BEGIN
				IF othervalarr[n].field5 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
			ENDFOR
		ENDIF ELSE BEGIN
			 nother=0
		ENDELSE		
		

		IF (exists[0] EQ -1) THEN BEGIN 
			OPENU, u, trapstatfile, /APPEND, /GET_LUN
		
			PRINTF, u, FORMAT = trapstatformat, farr[trappos[0]].id, $
				farr[trappos[0]].yr, farr[trappos[0]].mo, farr[trappos[0]].dy, $
				farr[trappos[0]].run, farr[trappos[0]].inst, farr[trappos[0]].ayr, $
				farr[trappos[0]].amo, farr[trappos[0]].ady, farr[trappos[0]].ahr, $
				farr[trappos[0]].amn, farr[trappos[0]].asc, traparr.aved45, $
				traparr.stdev45, traparr.aved46, traparr.stdev46, traparr.avec13, $
				traparr.stdevc13, uncc,farr[trappos[0]].c13flag,traparr.aveo18, traparr.stdevo18, $
				unco,farr[trappos[0]].o18flag,farr[trappos[0]].ref,traparr.twptc13,traparr.twpto18	
			FREE_LUN,u
		ENDIF ELSE BEGIN
		
			newtrapstatarr = REPLICATE({	id:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					run:'',		$
					inst:'',	$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					d45:0.0,	$
					prec45:0.0,	$
					d46:0.0,	$
					prec46:0.0,	$
					c13:0.0,	$
					stdevc13:0.0,	$
					uncertc:0.0,	$
					c13flag:'',	$
					o18:0.0,	$
					stdevo18:0.0,	$
					uncerto:0.0,	$
					o18flag:'',	$
					ref:'',		$
					twptc13:0.0,	$
					twpto18:0.0},	$
					nother +1)

					newtrapstatarr[0].id=farr[trappos[0]].id
					newtrapstatarr[0].yr=farr[trappos[0]].yr
					newtrapstatarr[0].mo=farr[trappos[0]].mo
					newtrapstatarr[0].dy=farr[trappos[0]].dy
					newtrapstatarr[0].run=farr[trappos[0]].run
					newtrapstatarr[0].inst=farr[trappos[0]].inst
					newtrapstatarr[0].ayr=farr[trappos[0]].ayr
					newtrapstatarr[0].amo=farr[trappos[0]].amo
					newtrapstatarr[0].ady=farr[trappos[0]].ady
					newtrapstatarr[0].ahr=farr[trappos[0]].ahr
					newtrapstatarr[0].amn=farr[trappos[0]].amn
					newtrapstatarr[0].asc=farr[trappos[0]].asc
					newtrapstatarr[0].d45=traparr.aved45
					newtrapstatarr[0].prec45=traparr.stdev45
					newtrapstatarr[0].d46=traparr.aved46
					newtrapstatarr[0].prec46=traparr.stdev46
					newtrapstatarr[0].c13=traparr.avec13
					newtrapstatarr[0].stdevc13=traparr.stdevc13
					newtrapstatarr[0].uncertc=uncc
					newtrapstatarr[0].c13flag=farr[trappos[0]].c13flag
					newtrapstatarr[0].o18=traparr.aveo18
					newtrapstatarr[0].stdevo18=traparr.stdevo18
					newtrapstatarr[0].uncerto=unco
					newtrapstatarr[0].o18flag=farr[trappos[0]].o18flag
					newtrapstatarr[0].ref=farr[trappos[0]].ref
					newtrapstatarr[0].twptc13=traparr.twptc13
					newtrapstatarr[0].twpto18=traparr.twpto18
				
				FOR h=0, nother-1 DO BEGIN
					newtrapstatarr[h+1].id=othervalarr[h].field1
					newtrapstatarr[h+1].yr=othervalarr[h].field2
					newtrapstatarr[h+1].mo=othervalarr[h].field3
					newtrapstatarr[h+1].dy=othervalarr[h].field4
					newtrapstatarr[h+1].run=newrunarr[h]
					newtrapstatarr[h+1].inst=othervalarr[h].field6
					newtrapstatarr[h+1].ayr=othervalarr[h].field7
					newtrapstatarr[h+1].amo=othervalarr[h].field8
					newtrapstatarr[h+1].ady=othervalarr[h].field9
					newtrapstatarr[h+1].ahr=othervalarr[h].field10
					newtrapstatarr[h+1].amn=othervalarr[h].field11
					newtrapstatarr[h+1].asc=othervalarr[h].field12
					newtrapstatarr[h+1].d45=othervalarr[h].field13
					newtrapstatarr[h+1].prec45=othervalarr[h].field14
					newtrapstatarr[h+1].d46=othervalarr[h].field15
					newtrapstatarr[h+1].prec46=othervalarr[h].field16
					newtrapstatarr[h+1].c13=othervalarr[h].field17
					newtrapstatarr[h+1].stdevc13=othervalarr[h].field18
					newtrapstatarr[h+1].uncertc=othervalarr[h].field19
					newtrapstatarr[h+1].c13flag=othervalarr[h].field20
					newtrapstatarr[h+1].o18=othervalarr[h].field21
					newtrapstatarr[h+1].stdevo18=othervalarr[h].field22
					newtrapstatarr[h+1].uncerto=othervalarr[h].field23
					newtrapstatarr[h+1].o18flag=othervalarr[h].field24
					newtrapstatarr[h+1].ref=othervalarr[h].field25
					newtrapstatarr[h+1].twptc13=othervalarr[h].field26
					newtrapstatarr[h+1].twpto18=othervalarr[h].field27
				ENDFOR
			
			nnew=nother+1		
			adate = DBLARR(nnew)
			FOR b=0, nnew -1 DO BEGIN
				CCG_DATE2DEC, YR=newtrapstatarr[b].ayr, $
					MO=newtrapstatarr[b].amo, DY=newtrapstatarr[b].ady, $
					HR=newtrapstatarr[b].ahr,MN=newtrapstatarr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newtrapstatarr=newtrapstatarr[SORT(adate)]

			OPENW, u, trapstatfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=trapstatformat,newtrapstatarr[a]
			FREE_LUN, u
			ENDELSE
	ENDELSE
	FREE_LUN, u

ENDIF

;;plottank_byref,errbars=1,tank=farr[trappos[0]].id,plotuncertainty=0,inst=inst,savegraphs=0,sp='co2c13',trap=1



IF(verbose EQ 1) THEN PRINT, 'refsets = ', refsets
	
	IF twptcorr EQ 0 THEN GOTO,skipsplit
 	IF loupos[0] EQ -1 THEN GOTO,skipsplit

	splitformat = '(A9,A4,I5.1,5(I3.1),8(F8.3))'	
	splitfile='/projects/co2c13/'+calsdir+'/internal_cyl/splitfile.'+ref+'.'+secref+'.txt'
	splitfileexist = FILE_TEST(splitfile)
			
		
IF (splitfileexist EQ 0) THEN BEGIN  ;------NEW FILE...WRITE AWAY WITH NEW INFO...
	OPENW, u, splitfile, /GET_LUN 
	FOR i=0, nlougroups-1 DO BEGIN  ; LOOP THROUGH LOUSETS (TYPICALLY 2)
		lastlou = lousets[i]  ;  this = the position of the last REF in each (current) set.
		loucount = loucluster[i] ;  this = the number of REF's in the i-th (current) set of refs.
		first = lastlou - loucount +1  ; now first = position of 1st ref of the current set of refs.
		
		IF i EQ 0 then whichref=0 ELSE whichref=nrefs-1
		
		;maybe print c13 also??
		
		PRINTF, u, FORMAT = splitformat, $
			farr[first].run, farr[first].inst, farr[first].ayr, $
			farr[first].amo, farr[first].ady, farr[first].ahr, $
			farr[first].amn, farr[first].asc, louarr[i].aved45, $
			louarr[i].stdev45, louarr[i].aved46, louarr[i].stdev46, $
			refarr[whichref].dav45, refarr[whichref].stdev45, refarr[whichref].dav46, $
			refarr[whichref].stdev46
			
			
	ENDFOR
	FREE_LUN,u
ENDIF ELSE BEGIN   ; ---------  The file already exists, so let's add to it....
	CCG_READ, file = splitfile, /nomessages, splitfilearr 

		exists = WHERE (splitfilearr.field1 EQ farr[refpos[0]].run,complement=othervals)
		IF othervals[0] NE -1 THEN BEGIN
			othervalarr=splitfilearr[othervals]
			nother=N_ELEMENTS(othervals) 
					
			newrunarr=STRARR(nother)
			FOR n=0,nother-1 DO BEGIN
				IF othervalarr[n].field5 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
			ENDFOR
		ENDIF ELSE BEGIN
			 nother=0
		ENDELSE		
		
		
		IF (exists[0] EQ -1) THEN BEGIN ;(check to see if data for the run number already exists)
			OPENU, u, splitfile, /APPEND, /GET_LUN
			FOR i=0, nlougroups-1 DO BEGIN
				last = lousets[i]  ;  this = the position of the last REF in each (current) set.
				loucount = loucluster[i] ;  this = the number of REF's in the i-th (current) set of refs.
				first = last - loucount +1  ; now first = position of 1st ref of the current set of refs.
				IF i EQ 0 then whichref=0 ELSE whichref=nrefs-1
		
				PRINTF, u, FORMAT = splitformat, $
				farr[first].run, farr[first].inst, farr[first].ayr, $
				farr[first].amo, farr[first].ady, farr[first].ahr, $
				farr[first].amn, farr[first].asc, louarr[i].aved45, $
				louarr[i].stdev45, louarr[i].aved46, louarr[i].stdev46, $
				refarr[whichref].dav45, refarr[whichref].stdev45, refarr[whichref].dav46, $
				refarr[whichref].stdev46
			

			ENDFOR
				FREE_LUN,u
		ENDIF ELSE BEGIN

		ENDELSE
		skipsplit:
ENDELSE



;; ----- PRINT SIL FLASKS TO FILE --------------------------------------------------
silflasks = WHERE(type EQ 'SIL',nsilflasks)
IF reprintsil EQ 0 THEN BEGIN
	print,'not reprinting sil flask data'
ENDIF ELSE BEGIN
	IF silflasks[0] NE -1 THEN BEGIN
		
		silflaskfile = '/home/ccg/sil/silflasks/silflasks.jras06.co2c13'
		
		silarr=farr[silflasks]
		;finformat = '(A8,A5,A9,A3,I5.1,2(I3.1),I5.1,4(I3.1),F10.3,A5,F10.3,A5,1X,A3,A8,A9)'
		finformat = '(A8,A5,A12,A3,I5.1,2(I3.1),I5.1,4(I3.1),F12.3,F12.3,F7.3,A5,F12.3,F12.3,F7.3,A5,1X,A3,A9,A9)'
	
			OPENW, u, silflaskfile, /GET_LUN, /APPEND

			PRINT, 'Writing SIL flasks to file..'
			FOR i = 0, nsilflasks-1 DO PRINTF, u, FORMAT = finformat, silarr[i].enum, $
				silarr[i].site,silarr[i].id, $
				silarr[i].meth,silarr[i].yr, silarr[i].mo, silarr[i].dy, $
				silarr[i].ayr, silarr[i].amo, silarr[i].ady, $
				silarr[i].ahr, silarr[i].amn, $
				silarr[i].c13, silarr[i].twptc13,ccomberr,silarr[i].c13flag, silarr[i].o18,silarr[i].twpto18, ocomberr,$
				silarr[i].o18flag, silarr[i].inst, silarr[i].run,ref
			FREE_LUN,u
	ENDIF
ENDELSE


; ----- PUT CARB DATA SOMEWHERE TO BE PARSED OUT INTO PROPER PLACE -------------------
; final array of just crbs called carbfinalarr
; remember, this is just carb samples, not carb refs. CRF carb refs will be handled elsewhere.

carbs = WHERE(type EQ 'CRB',ncarbs)
IF carbs[0] NE -1 THEN BEGIN
	carbfinalarr = farr[carbs]

	carbco2c13arr = REPLICATE({	enum:'',$
				yr:0,		$
				mo:0,		$
				dy:0,		$
				spec:'', 	$
				run:'',		$
				ayr:0,		$
				amo:0,		$
				ady:0,		$
				ahr:0,		$
				amn:0,		$
				asc:0,		$
				c13:0.0,	$
				uncertc:0.0,	$
				c13flag:'',	$
				o18:0.0,	$
				uncerto:0.0,	$
				o18flag:'',	$
				ref:'',		$
				inst:'',	$
				samtemp:0.0},	$
				ncarbs)
	FOR i=0, ncarbs-1 DO BEGIN
		carbco2c13arr[i].enum	= carbfinalarr[i].enum
		carbco2c13arr[i].yr	= carbfinalarr[i].yr
		carbco2c13arr[i].mo	= carbfinalarr[i].mo
		carbco2c13arr[i].dy	= carbfinalarr[i].dy
		carbco2c13arr[i].spec	= 'co2c13'
		carbco2c13arr[i].run	= carbfinalarr[i].run
		carbco2c13arr[i].ayr	= carbfinalarr[i].ayr
		carbco2c13arr[i].amo	= carbfinalarr[i].amo
		carbco2c13arr[i].ady	= carbfinalarr[i].ady
		carbco2c13arr[i].ahr	= carbfinalarr[i].ahr
		carbco2c13arr[i].amn	= carbfinalarr[i].amn
		carbco2c13arr[i].asc	= carbfinalarr[i].asc
		carbco2c13arr[i].c13	= carbfinalarr[i].c13
		carbco2c13arr[i].uncertc= uncc
		carbco2c13arr[i].c13flag = carbfinalarr[i].c13flag
		carbco2c13arr[i].o18	= carbfinalarr[i].o18
		carbco2c13arr[i].uncerto= unco
		carbco2c13arr[i].o18flag= carbfinalarr[i].o18flag
		carbco2c13arr[i].ref	= ref
		carbco2c13arr[i].inst	= inst
		carbco2c13arr[i].samtemp= carbfinalarr[i].samtemp
		
	ENDFOR

	; ----- TRANSFER PROCESSED CARB DATA INTO CARB FILES -----------------------
	FOR i=0, ncarbs-1 DO BEGIN
		thecarb = WHERE(carbco2c13arr[i].enum EQ carbco2c13arr.enum)
		thecarbvalues = carbco2c13arr[thecarb]
		nthecarb = N_ELEMENTS(thecarbvalues)
	
			;carbformat = '(A8, I5, 2(I3), A7, A9, I5, 5(I3), 2(F10.4, A4), A10, A3,F8.3)'
			carbformat = '(A8, I5, 2(I3), A7, A9, I5, 5(I3), 2(F10.4, F8.3, A4), A10, A3,F8.3)'
		
			;change format to include temps
			carbdir = '/projects/co2c13/carbs/' 
			carbfile = carbdir + carbco2c13arr[i].enum + '.co2c13'
			carbfileexist = FILE_TEST(carbfile)
			OPENU, u, carbfile, /APPEND, /GET_LUN			
			IF carbfileexist EQ 0 THEN BEGIN
				FOR j=0, nthecarb-1 DO PRINTF, u, FORMAT=carbformat, thecarbvalues[j]
			ENDIF ELSE BEGIN
				CCG_READ, file = carbfile, /nomessages, carbfilearr
				exists = WHERE (carbfilearr.field6 EQ carbco2c13arr[i].run AND $
					carbfilearr.field20 EQ carbco2c13arr[i].inst) 
				IF (exists[0] EQ -1) THEN FOR j=0, nthecarb-1 DO PRINTF, u, FORMAT=carbformat, thecarbvalues[j]
			ENDELSE
			FREE_LUN, u
			CCG_SREAD, file=carbfile, carbdata, /nomessages
			ncarbdata=N_ELEMENTS(carbdata)
			adate = DBLARR(1,ncarbdata)
			FOR b=0, ncarbdata-1 DO BEGIN
				CCG_DATE2DEC, YR=STRMID(carbdata[b],36,4), $
					MO=STRMID(carbdata[b],41,2), DY=STRMID(carbdata[b],44,2), $
					HR=STRMID(carbdata[b],47,2), MN=STRMID(carbdata[b],50,2), DEC=dec
				adate[b]=dec
			ENDFOR
			carbdata=carbdata[SORT(adate)]
			OPENU, u, carbfile, /GET_LUN
			FOR a=0, ncarbdata-1 DO PRINTF, u, carbdata[a]
			FREE_LUN, u
	ENDFOR	
ENDIF
;*************************



;put h2o data sort here

;*************************


; ----- PUT TANK DATA SOMEWHERE TO BE PARSED OUT INTO PROPER PLACE -------------------
; final array of just tank called tankfinalarr

IF printtanks EQ 1 THEN BEGIN

tanks = WHERE(type EQ 'STD',ntanks)

IF tanks[0] NE -1 THEN BEGIN
	tankfinalarr = farr[tanks]    ;includes all tank data

	tankco2c13arr = REPLICATE({	enum:'',$
				yr:0,		$
				mo:0,		$
				dy:0,		$
				spec:'', 	$
				run:'',		$
				ayr:0,		$
				amo:0,		$
				ady:0,		$
				ahr:0,		$
				amn:0,		$
				asc:0,		$
				c13:0.0,	$
				c13unc:0.0,	$
				c13flag:'',	$
				o18:0.0,	$
				o18unc:0.0,	$
				o18flag:'',	$
				ref:'',		$
				inst:'',$
				twptc13:0.0,	$
				twpto18:0.0},$
				ntanks)
				
				;IF getpressures EQ 1 THEN add to above array:
				;airpressure:0.0,$
				;co2pressure:0.0
				
			
	FOR i=0, ntanks-1 DO BEGIN
		tankco2c13arr[i].enum	= tankfinalarr[i].enum
		tankco2c13arr[i].yr	= tankfinalarr[i].yr
		tankco2c13arr[i].mo	= tankfinalarr[i].mo
		tankco2c13arr[i].dy	= tankfinalarr[i].dy
		tankco2c13arr[i].spec	= 'co2c13'
		tankco2c13arr[i].run	= tankfinalarr[i].run
		tankco2c13arr[i].ayr	= tankfinalarr[i].ayr
		tankco2c13arr[i].amo	= tankfinalarr[i].amo
		tankco2c13arr[i].ady	= tankfinalarr[i].ady
		tankco2c13arr[i].ahr	= tankfinalarr[i].ahr
		tankco2c13arr[i].amn	= tankfinalarr[i].amn
		tankco2c13arr[i].asc	= tankfinalarr[i].asc
		tankco2c13arr[i].c13	= tankfinalarr[i].c13
		
		tankco2c13arr[i].c13unc	= uncc
		tankco2c13arr[i].c13flag = tankfinalarr[i].c13flag
		tankco2c13arr[i].o18	= tankfinalarr[i].o18
		tankco2c13arr[i].o18unc	= unco
		tankco2c13arr[i].o18flag= tankfinalarr[i].o18flag
		tankco2c13arr[i].ref	= ref
		tankco2c13arr[i].inst	= inst

		tankco2c13arr[i].twptc13= tankfinalarr[i].twptc13
		tankco2c13arr[i].twpto18= tankfinalarr[i].twpto18
		;if getpressures EQ 1uncomment these
		;tankco2c13arr[i].airpressure= tankfinalarr[i].airpressure
		;tankco2c13arr[i].co2pressure= tankfinalarr[i].co2pressure
		
	ENDFOR

	sortedtanks=SORT(tankco2c13arr.enum)
	sorttankarr=tankco2c13arr[sortedtanks]
	uniqtanks=UNIQ(sorttankarr.enum)
	nuniq=N_ELEMENTS(uniqtanks)	
	uniqtankarr=sorttankarr[uniqtanks]

	; ----- TRANSFER PROCESSED TANK DATA INTO TANK FILES -----------------------
	FOR i=0, nuniq-1 DO BEGIN
		internal = STRPOS(uniqtankarr[i].enum,'-')
		IF d4546tankfiles EQ 1 THEN BEGIN

			IF internal NE 4 THEN goto,skipexternals
		ENDIF
		
		thetank = WHERE(uniqtankarr[i].enum EQ tankco2c13arr.enum,nthetank)
		thetankvalues = tankco2c13arr[thetank]
		
		IF thetankvalues[0].enum EQ secref THEN BEGIN
		 	thetankvalues.asc=1     ; this is a way to indicate that the tank was used as a second reference.
		
	
		ENDIF
		
		;----Add first position 'F' flag to first aliquot of the tank for that day (sre 4/5/06)
		;----this flag used to be applied in the tank_view program
		thetankvalues[0].c13flag='F'+ STRMID(thetankvalues[0].c13flag,1,2)
		thetankvalues[0].o18flag='F'+ STRMID(thetankvalues[0].o18flag,1,2)
		
		;tankformat = '(A10, I5, 2(I3), A7, A9, I5, 5(I3), 2(F10.4, F8.3, A4), A10, A3)'
		tankformat = '(A10, I5, 2(I3), A7, A9, I5, 5(I3), 2(F10.4, F8.3, A4), A10, A3,2(F10.4))'   ; with a place for 2 pt corrected data
		;if getpressures EQ1 choose this one
		;tankformat = '(A10, I5, 2(I3), A7, A9, I5, 5(I3), 2(F10.4, F8.3, A4), A10, A3,2(F10.4),2(F9.3))'   ; with a place for 2 pt corrected data
		
		
		IF internal EQ 4 THEN BEGIN
			tankdir = '/projects/co2c13/'+calsdir+'/internal_cyl/' 
			revtankdir = '/projects/co2c13/'+calsdir+'/internal_cyl/' ;KB: changed from '/projects/co2c13/calsieg2/internal_cyl/' 8/16/24
			;revtankdir = '/projects/co2c13/calsieg2/internal_cyl/' ; sly turned back to calsieg2 for reprocessing 10/24/24
	
		ENDIF ELSE BEGIN
			tankdir = '/projects/co2c13/'+calsdir+'/external_cyl/' 
			revtankdir = '/projects/co2c13/'+calsdir+'/external_cyl/' ;KB: changed from '/projects/co2c13/calsieg2/internal_cyl/' 8/16/24
			;revtankdir = '/projects/co2c13/calsieg2/external_cyl/' ;KB: changed from '/projects/co2c13/calsieg2/internal_cyl/' 8/16/24
		ENDELSE
		
		tankfile = tankdir + uniqtankarr[i].enum + '.co2c13'
		checktankfile = revtankdir + uniqtankarr[i].enum + '.co2c13'
		
		tankfileexist = FILE_TEST(tankfile)
		
		;put in some print statement here. ...
		
		print, 'tank = ',uniqtankarr[i].enum

		;then continue with printing data to file
		; First check to see if there is flagging on this cylinder in the normal 'cals' directory. 
		;IF firstdate GT 2023.8 THEN GOTO,skipcatch 
		;GOTO,skipcatch
		IF tankfileexist EQ 0 THEN GOTO,skipcatch   ; sly added 1/5/23
		
		CCG_READ, file = checktankfile, /nomessages, revtankfilearr
			exists = WHERE (FIX(revtankfilearr.field6) EQ FIX(uniqtankarr[i].run) AND $
				revtankfilearr.field20 EQ uniqtankarr[i].inst,complement=othervals) 
			;catch exclpt or B flags
	
			;if internal NE 4 THEN stop
			;IF inst EQ 'r1' THEN goto,skipcatch
			IF exists[0] EQ -1 THEN goto, skipcatch  ; usually cals file will have data! but this allows you to not worry if it doesn't
			
			catcharrc=STRARR(nthetank)
			catcharro=STRARR(nthetank)
		
			FOR c=0,nthetank-1 DO BEGIN
				catcharrc[c]='.'
				catcharro[c]='.'
				
				CASE STRMID(revtankfilearr[exists[c]].field15,0,1) OF
				 'B' : BEGIN
				 
				 	catcharrc[c]=STRMID(revtankfilearr[exists[c]].field15,0,1)
				END
				 '!': BEGIN
				 	 catcharrc[c]=STRMID(revtankfilearr[exists[c]].field15,0,1)
				END	
				 '#': BEGIN								;sly added this after adding flags to calsieg2
				 	 catcharrc[c]=STRMID(revtankfilearr[exists[c]].field15,0,1)
				END	
				ELSE: BEGIN 
					catcharrc[c]=STRMID(thetankvalues[c].c13flag,0,1)
				END
				ENDCASE
				
				
				CASE STRMID(revtankfilearr[exists[c]].field18,0,1) OF
				 'B' : BEGIN
				 
				 	catcharro[c]=STRMID(revtankfilearr[exists[c]].field18,0,1)
				 END
				 '!': BEGIN
				 	 catcharro[c]=STRMID(revtankfilearr[exists[c]].field18,0,1)
				 END	
				  '#': BEGIN
				 	 catcharro[c]=STRMID(revtankfilearr[exists[c]].field18,0,1)
				 END
				ELSE: BEGIN 
					catcharro[c]=STRMID(thetankvalues[c].o18flag,0,1)
				END
				ENDCASE
				
			ENDFOR


		
		FOR j=0,nthetank-1 DO BEGIN
				
			 IF catcharrc[j] EQ '.' THEN thetankvalues[j].c13flag = thetankvalues[j].c13flag ELSE $
						thetankvalues[j].c13flag=catcharrc[j]+STRMID(thetankvalues[j].c13flag,1,2)
						
			IF catcharro[j] EQ '.' THEN thetankvalues[j].o18flag = thetankvalues[j].o18flag ELSE $
						thetankvalues[j].o18flag=catcharro[j]+STRMID(thetankvalues[j].o18flag,1,2)

		ENDFOR
		skipcatch:
		print,tankfile
		
		
		IF tankfileexist EQ 0 THEN BEGIN
			OPENU, u, tankfile, /APPEND, /GET_LUN
			FOR j=0, nthetank-1 DO PRINTF, u, FORMAT=tankformat, thetankvalues[j]
			FREE_LUN,u
		
		ENDIF ELSE BEGIN
			
			CCG_READ, file = tankfile, /nomessages, tankfilearr
			exists = WHERE (FIX(tankfilearr.field6) EQ FIX(uniqtankarr[i].run) AND $
				tankfilearr.field20 EQ uniqtankarr[i].inst,complement=othervals) 
				
			IF othervals[0] NE -1 THEN BEGIN
				othervalarr=tankfilearr[othervals]
				nother=N_ELEMENTS(othervals) 
					
				newrunarr=STRARR(nother)
				FOR n=0,nother-1 DO BEGIN
					IF othervalarr[n].field6 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
				ENDFOR
				
			ENDIF ELSE BEGIN
				 nother=0
			ENDELSE
				
			IF (exists[0] EQ -1) THEN BEGIN
				OPENU, u, tankfile, /APPEND, /GET_LUN
				FOR j=0, nthetank-1 DO PRINTF, u, FORMAT=tankformat, thetankvalues[j]
				FREE_LUN,u
					
			ENDIF ELSE BEGIN
			
			
				
			;;;; HERE IS WHERE YOU COULD OVERWRITE OLD DATA . ..
			;;;; AS YOU WOULD IN THE DATABASE
			
				newtankco2c13arr = REPLICATE({	enum:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					spec:'', 	$
					run:'',		$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					c13:0.0,	$
					uncertc:0.0,	$
					c13flag:'',	$
					o18:0.0,	$
					uncerto:0.0,	$
					o18flag:'',	$
					ref:'',		$
					inst:'',	$
					twptc13:0.0,	$
					twpto18:0.0},	$
					;airpressure:0.0,$
					;co2pressure:0.0},$
					nother +nthetank)
					
					;if getpressure EQ 1 add these
					;airpressure:0.0,$
					;co2pressure:0.0
				
				FOR v=0, nthetank-1 DO BEGIN
					newtankco2c13arr[v].enum = thetankvalues[v].enum
					newtankco2c13arr[v].yr	= thetankvalues[v].yr
					newtankco2c13arr[v].mo	= thetankvalues[v].mo
					newtankco2c13arr[v].dy	= thetankvalues[v].dy
					newtankco2c13arr[v].spec = thetankvalues[v].spec
					newtankco2c13arr[v].run	= thetankvalues[v].run
					newtankco2c13arr[v].ayr	= thetankvalues[v].ayr
					newtankco2c13arr[v].amo	= thetankvalues[v].amo
					newtankco2c13arr[v].ady	= thetankvalues[v].ady
					newtankco2c13arr[v].ahr	= thetankvalues[v].ahr
					newtankco2c13arr[v].amn	= thetankvalues[v].amn
					newtankco2c13arr[v].asc	= thetankvalues[v].asc
					newtankco2c13arr[v].c13	= thetankvalues[v].c13
					newtankco2c13arr[v].uncertc= uncc
					newtankco2c13arr[v].c13flag = thetankvalues[v].c13flag
					newtankco2c13arr[v].o18	= thetankvalues[v].o18
					newtankco2c13arr[v].uncerto= unco
					newtankco2c13arr[v].o18flag= thetankvalues[v].o18flag
					newtankco2c13arr[v].ref	= thetankvalues[v].ref
					newtankco2c13arr[v].inst = thetankvalues[v].inst
					newtankco2c13arr[v].twptc13= thetankvalues[v].twptc13
					newtankco2c13arr[v].twpto18 = thetankvalues[v].twpto18
					;if GETPRESSURES EQ 1
					;newtankco2c13arr[v].airpressure= thetankvalues[v].airpressure
					;newtankco2c13arr[v].co2pressure = thetankvalues[v].co2pressure

				ENDFOR
					
				FOR h=0, nother-1 DO BEGIN
					newtankco2c13arr[h+nthetank].enum= othervalarr[h].field1
					newtankco2c13arr[h+nthetank].yr	= othervalarr[h].field2
					newtankco2c13arr[h+nthetank].mo	= othervalarr[h].field3
					newtankco2c13arr[h+nthetank].dy	= othervalarr[h].field4
					newtankco2c13arr[h+nthetank].spec = othervalarr[h].field5
					newtankco2c13arr[h+nthetank].run = newrunarr[h]
					newtankco2c13arr[h+nthetank].ayr = othervalarr[h].field7
					newtankco2c13arr[h+nthetank].amo = othervalarr[h].field8
					newtankco2c13arr[h+nthetank].ady = othervalarr[h].field9
					newtankco2c13arr[h+nthetank].ahr = othervalarr[h].field10
					newtankco2c13arr[h+nthetank].amn = othervalarr[h].field11
					newtankco2c13arr[h+nthetank].asc = othervalarr[h].field12
					newtankco2c13arr[h+nthetank].c13 = othervalarr[h].field13
					newtankco2c13arr[h+nthetank].uncertc = othervalarr[h].field14
					newtankco2c13arr[h+nthetank].c13flag = othervalarr[h].field15
					newtankco2c13arr[h+nthetank].o18 = othervalarr[h].field16
					newtankco2c13arr[h+nthetank].uncerto = othervalarr[h].field17
					newtankco2c13arr[h+nthetank].o18flag= othervalarr[h].field18
					newtankco2c13arr[h+nthetank].ref = othervalarr[h].field19
					newtankco2c13arr[h+nthetank].inst = othervalarr[h].field20
					newtankco2c13arr[h+nthetank].twptc13 = othervalarr[h].field21
					newtankco2c13arr[h+nthetank].twpto18 = othervalarr[h].field22
					;if GETPRESSURES EQ 1
					;newtankco2c13arr[h+nthetank].airpressure= othervalarr[h].field23
					;newtankco2c13arr[h+nthetank].co2pressure = othervalarr[h].field24
				ENDFOR
						
			nnew=nother+nthetank
			adate = DBLARR(nnew)
			FOR b=0, nnew -1 DO BEGIN
				CCG_DATE2DEC, YR=newtankco2c13arr[b].ayr, $
					MO=newtankco2c13arr[b].amo, DY=newtankco2c13arr[b].ady, $
					HR=newtankco2c13arr[b].ahr,MN=newtankco2c13arr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newtankco2c13arr=newtankco2c13arr[SORT(adate)]
		
			OPENW, u, tankfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=tankformat,newtankco2c13arr[a]
			FREE_LUN, u
	
			ENDELSE  ;exists NE -1; data for that run already exists and needs to be rewritten
							
		ENDELSE	 ;tankfileexists
		FREE_LUN, u	
	
		IF internal EQ 4 THEN BEGIN
		
			;IF pause EQ 1 THEN TANK_VIEW2, spec='co2c13', tank=uniqtankarr[i].enum,savegraphs=0
		ENDIF ELSE BEGIN
			;need filldate as mmddyyyy
			
			ourmo=STRCOMPRESS(STRING(uniqtankarr[i].mo),/REMOVE_ALL)
			IF uniqtankarr[i].mo LT 10 THEN ourmo='0'+ourmo
			
			ourdy=STRCOMPRESS(STRING(uniqtankarr[i].dy),/REMOVE_ALL)
			IF uniqtankarr[i].dy LT 10 THEN ourdy='0'+ourdy
			ouryr=STRCOMPRESS(STRING(uniqtankarr[i].yr),/REMOVE_ALL)
			ourfilldate=ourmo+ourdy+ouryr
			
			
			;IF pause EQ 1 THEN TANK_VIEW,spec='co2c13',tank=uniqtankarr[i].enum,filldate=ourfilldate,savegraphs=0
			
		ENDELSE
		
	
		skipexternals:
	ENDFOR	;loop of uniq tanks, i
tankbailout:
ENDIF  ;tank[0] EQ -1
ENDIF  ;printtanks EQ 1
IF (verbose EQ 1) THEN PRINT, 'Writing final values', file

; ----- COLLECT ALL OF THE FINAL VALUES AND PUT INTO PROPER ARRAYS --------------
; Drift corrected averages and standard deviation of reference tank and 
;	store in refarr[i]

; ----- WRITE TO PERFORMANCE FILE FOR REFERENCE TANK ----------------------------


;distinguish between ref and crf and hrf
whatisit=farr[refpos[0]].site
CASE whatisit of
'STD': BEGIN
refformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),2(F10.3,1X,F8.3),2(F10.3,A4))'
reffile = '/projects/co2c13/'+calsdir+'/internal_cyl/ref' + ref  + '.co2c13.' + inst   
refstatfile = '/projects/co2c13/'+calsdir+'/internal_cyl/refstat' + ref  + '.co2c13.' + inst  
END

'CRB' : BEGIN
refformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),2(F10.3,1X,F8.3),2(F10.3,A4),F10.3)'
reffile = '/projects/co2c13/carbs/ref' + ref  + '.co2c13.' + inst   
refstatfile = '/projects/co2c13/carbs/refstat' + ref  + '.co2c13.' + inst  
END

'H2O' : BEGIN
refformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),2(F10.3,1X,F8.3),2(F10.3,A4,F10.3))'
reffile = '/projects/co2c13/h2o/ref' + ref  + '.co2c13.' + inst   
refstatfile = '/projects/co2c13/h2o/refstat' + ref  + '.co2c13.' + inst  
END
ENDCASE

reffileexist = FILE_TEST(reffile)

CASE whatisit of 
'STD': BEGIN

	IF reffileexist EQ 0 THEN BEGIN
		OPENU, u, reffile, /APPEND, /GET_LUN

		FOR i = 0, (rlength)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
			farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
			farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
			farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
			farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].d45, $
			farr[refpos[i]].prec45, farr[refpos[i]].d46, farr[refpos[i]].prec46, $
			farr[refpos[i]].c13, farr[refpos[i]].c13flag,farr[refpos[i]].o18, $
			farr[refpos[i]].o18flag	
		FREE_LUN,u
	ENDIF ELSE BEGIN
	
		CCG_READ, file = reffile, /nomessages, reffilearr
		exists = WHERE (reffilearr.field5 EQ farr[refpos[0]].run,complement=othervals)
		IF othervals[0] NE -1 THEN BEGIN
			othervalarr=reffilearr[othervals]
			nother=N_ELEMENTS(othervals) 
					
			newrunarr=STRARR(nother)
			FOR n=0,nother-1 DO BEGIN
				IF othervalarr[n].field5 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
			ENDFOR
		ENDIF ELSE BEGIN
			 nother=0
		ENDELSE		
		 
		IF (exists[0] EQ -1) THEN BEGIN 
			OPENU, u, reffile, /APPEND, /GET_LUN

			FOR i = 0, (rlength)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
				farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
				farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
				farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
				farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].d45, $
				farr[refpos[i]].prec45, farr[refpos[i]].d46, farr[refpos[i]].prec46, $
				farr[refpos[i]].c13, farr[refpos[i]].c13flag,farr[refpos[i]].o18, $
				farr[refpos[i]].o18flag	
			FREE_LUN,u				
		ENDIF ELSE BEGIN
			;;;; HERE IS WHERE YOU OVERWRITE OLD DATA . ..
			;;;; AS YOU WOULD IN THE DATABASE
			
				newfinalrefarr = REPLICATE({	id:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					run:'',		$
					inst:'',	$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					d45:0.0,	$
					prec45:0.0,	$
					d46:0.0,	$
					prec46:0.0,	$
					c13:0.0,	$
					c13flag:'',	$
					o18:0.0,	$
					o18flag:''},	$
					nother +rlength)
				
				FOR v=0, rlength-1 DO BEGIN
					newfinalrefarr[v].id=farr[refpos[v]].id
					newfinalrefarr[v].yr=farr[refpos[v]].yr
					newfinalrefarr[v].mo=farr[refpos[v]].mo
					newfinalrefarr[v].dy=farr[refpos[v]].dy
					newfinalrefarr[v].run=farr[refpos[v]].run
					newfinalrefarr[v].inst=farr[refpos[v]].inst
					newfinalrefarr[v].ayr=farr[refpos[v]].ayr
					newfinalrefarr[v].amo=farr[refpos[v]].amo
					newfinalrefarr[v].ady=farr[refpos[v]].ady
					newfinalrefarr[v].ahr=farr[refpos[v]].ahr
					newfinalrefarr[v].amn=farr[refpos[v]].amn
					newfinalrefarr[v].asc=farr[refpos[v]].asc
					newfinalrefarr[v].d45=farr[refpos[v]].d45
					newfinalrefarr[v].prec45=farr[refpos[v]].prec45
					newfinalrefarr[v].d46=farr[refpos[v]].d46
					newfinalrefarr[v].prec46=farr[refpos[v]].prec46
					newfinalrefarr[v].c13=farr[refpos[v]].c13
					newfinalrefarr[v].c13flag=farr[refpos[v]].c13flag
					newfinalrefarr[v].o18=farr[refpos[v]].o18
					newfinalrefarr[v].o18flag=farr[refpos[v]].o18flag
					ENDFOR
					
				FOR h=0, nother-1 DO BEGIN
					newfinalrefarr[h+rlength].id=othervalarr[h].field1
					newfinalrefarr[h+rlength].yr=othervalarr[h].field2
					newfinalrefarr[h+rlength].mo=othervalarr[h].field3
					newfinalrefarr[h+rlength].dy=othervalarr[h].field4
					newfinalrefarr[h+rlength].run=newrunarr[h]
					newfinalrefarr[h+rlength].inst=othervalarr[h].field6
					newfinalrefarr[h+rlength].ayr=othervalarr[h].field7
					newfinalrefarr[h+rlength].amo=othervalarr[h].field8
					newfinalrefarr[h+rlength].ady=othervalarr[h].field9
					newfinalrefarr[h+rlength].ahr=othervalarr[h].field10
					newfinalrefarr[h+rlength].amn=othervalarr[h].field11
					newfinalrefarr[h+rlength].asc=othervalarr[h].field12
					newfinalrefarr[h+rlength].d45=othervalarr[h].field13
					newfinalrefarr[h+rlength].prec45=othervalarr[h].field14
					newfinalrefarr[h+rlength].d46=othervalarr[h].field15
					newfinalrefarr[h+rlength].prec46=othervalarr[h].field16
					newfinalrefarr[h+rlength].c13=othervalarr[h].field17
					newfinalrefarr[h+rlength].c13flag=othervalarr[h].field18
					newfinalrefarr[h+rlength].o18=othervalarr[h].field19
					newfinalrefarr[h+rlength].o18flag=othervalarr[h].field20
					
				ENDFOR
						
			nnew=nother+rlength
			adate = DBLARR(nnew)
			FOR b=0, nnew -1 DO BEGIN
				CCG_DATE2DEC, YR=newfinalrefarr[b].ayr, $
					MO=newfinalrefarr[b].amo, DY=newfinalrefarr[b].ady, $
					HR=newfinalrefarr[b].ahr,MN=newfinalrefarr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newfinalrefarr=newfinalrefarr[SORT(adate)]
			
			OPENW, u, reffile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=refformat,newfinalrefarr[a]
			FREE_LUN, u
	
		ENDELSE  ;exists NE -1; data for that run already exists and needs to be rewritten
			;******************

	ENDELSE  ;reffile exist ne 0
END
ELSE: BEGIN    
; not overwriting non gas refs yet!! change this once you start using carbs/waters as standards!
;***********************!!!!!!!!!!!!!!!!!!!!!!!***********************************	
	IF reffileexist EQ 0 THEN BEGIN

		FOR i = 0, (rlength)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
			farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
			farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
			farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
			farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].d45, $
			farr[refpos[i]].prec45, farr[refpos[i]].d46, farr[refpos[i]].prec46, $
			farr[refpos[i]].c13, farr[refpos[i]].c13flag,farr[refpos[i]].o18, $
			farr[refpos[i]].o18flag,farr[refpos[i]].samtemp	
			FREE_LUN, u	
	ENDIF ELSE BEGIN
		exists = WHERE (reffilearr.field5 EQ farr[refpos[0]].run) 
		IF (exists[0] EQ -1) THEN BEGIN 
			FOR i = 0, (rlength)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
				farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
				farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
				farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
				farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].d45, $
				farr[refpos[i]].prec45, farr[refpos[i]].d46, farr[refpos[i]].prec46, $
				farr[refpos[i]].c13, farr[refpos[i]].c13flag,farr[refpos[i]].o18, $
				farr[refpos[i]].o18flag,farr[refpos[i]].samtemp		
				FREE_LUN, u			
		ENDIF 
	ENDELSE
END
ENDCASE



; ----- WRITE TO STATISTICS FILE FOR REFERENCE TANK -----------------------------
refstatformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),4(F10.3,1X,F8.3))'

refstatfileexist = FILE_TEST(refstatfile)
;statlines = CCG_LIF(file = refstatfile)   ; ---CHECK TO SEE IF THE FILE HAS DATA---


IF (refstatfileexist EQ 0) THEN BEGIN  ;------NEW FILE...WRITE AWAY WITH NEW INFO...
	OPENW, u, refstatfile, /GET_LUN 
	FOR i=0, nrefs-1 DO BEGIN  ; LOOP THROUGH REFSETS (TYPICALLY nrefs=3)
		IF(verbose EQ 1) THEN PRINT, 'refsets[',i,']', '= ',refsets[i]
		last = refsets[i]  ;  this = the position of the last REF in each (current) set.
		refcount = cluster[i] ;  this = the number of REF's in the i-th (current) set of refs.
		first = last - refcount +1  ; now first = position of 1st ref of the current set of refs.
		IF(verbose EQ 1) THEN PRINT, 'First: ', first,'Last: ',last,'Refcount: ',refcount  ; --------FIX TO ALLOW LESS REFS!!!!
		
		PRINTF, u, FORMAT = refstatformat, farr[first].id, $   ; BOMBS HERE - BECAUSE FIRST = -1  
			farr[first].yr, farr[first].mo, farr[first].dy, $
			farr[first].run, farr[first].inst, farr[first].ayr, $
			farr[first].amo, farr[first].ady, farr[first].ahr, $
			farr[first].amn, farr[first].asc, refarr[i].dav45, $
			refarr[i].stdev45, refarr[i].dav46, refarr[i].stdev46, $
			refarr[i].avec13, refarr[i].stdevc13, refarr[i].aveo18, $
			refarr[i].stdevo18
	ENDFOR
	FREE_LUN,u
ENDIF ELSE BEGIN   ; ---------  The file already exists, so lets add to it....

	CCG_READ, file = refstatfile, /nomessages, refstatfilearr 

		exists = WHERE (refstatfilearr.field5 EQ farr[refpos[0]].run,complement=othervals)
		IF othervals[0] NE -1 THEN BEGIN
			othervalarr=refstatfilearr[othervals]
			nother=N_ELEMENTS(othervals) 
					
			newrunarr=STRARR(nother)
			FOR n=0,nother-1 DO BEGIN
				IF othervalarr[n].field5 LT 100000 THEN newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
				IF othervalarr[n].field5 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field5),/REMOVE_ALL)
			ENDFOR
		ENDIF ELSE BEGIN
			 nother=0
		ENDELSE		
		
		IF (exists[0] EQ -1) THEN BEGIN ;(check to see if data for the run number already exists)
			OPENU, u, refstatfile, /APPEND, /GET_LUN
			FOR i=0, nrefs-1 DO BEGIN
				last = refsets[i]  ;  this = the position of the last REF in each (current) set.
				refcount = cluster[i] ;  this = the number of REF's in the i-th (current) set of refs.
				first = last - refcount +1  ; now first = position of 1st ref of the current set of refs.
				PRINTF, u, FORMAT = refstatformat, farr[first].id, $
					farr[first].yr, farr[first].mo, farr[first].dy, $
					farr[first].run, farr[first].inst, farr[first].ayr, $
					farr[first].amo, farr[first].ady, farr[first].ahr, $
					farr[first].amn, farr[first].asc, refarr[i].dav45, $
					refarr[i].stdev45, refarr[i].dav46, refarr[i].stdev46, $
					refarr[i].avec13, refarr[i].stdevc13, refarr[i].aveo18, $
					refarr[i].stdevo18
			ENDFOR
			FREE_LUN,u
		ENDIF ELSE BEGIN

			;;;; HERE IS WHERE YOU OVERWRITE OLD DATA . ..
			;;;; AS YOU WOULD IN A DATABASE
			
				newrefstatarr = REPLICATE({	id:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					run:'',		$
					inst:'',	$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					av45:0.0,	$
					stdev45:0.0,	$
					av46:0.0,	$
					stdev46:0.0,	$
					avec13:0.0,	$
					stdevc13:'',	$
					aveo18:0.0,	$
					stdevo18:''},	$
					nother +nrefs)
				
				FOR v=0, nrefs-1 DO BEGIN
				
				last = refsets[v]  ;  this = the position of the last REF in each (current) set.
				refcount = cluster[v] ;  this = the number of REF's in the i-th (current) set of refs.
				first = last - refcount +1  ; now first = position of 1st ref of the current set of refs.
				
					newrefstatarr[v].id=farr[first].id
					newrefstatarr[v].yr=farr[first].yr
					newrefstatarr[v].mo=farr[first].mo
					newrefstatarr[v].dy=farr[first].dy
					newrefstatarr[v].run=farr[first].run
					newrefstatarr[v].inst=farr[first].inst
					newrefstatarr[v].ayr=farr[first].ayr
					newrefstatarr[v].amo=farr[first].amo
					newrefstatarr[v].ady=farr[first].ady
					newrefstatarr[v].ahr=farr[first].ahr
					newrefstatarr[v].amn=farr[first].amn
					newrefstatarr[v].asc=farr[first].asc
					newrefstatarr[v].av45=refarr[v].dav45
					newrefstatarr[v].stdev45=refarr[v].stdev45
					newrefstatarr[v].av46=refarr[v].dav46
					newrefstatarr[v].stdev46=refarr[v].stdev46
					newrefstatarr[v].avec13=refarr[v].avec13
					newrefstatarr[v].stdevc13=refarr[v].stdevc13
					newrefstatarr[v].aveo18=refarr[v].aveo18
					newrefstatarr[v].stdevo18=refarr[v].stdevo18
				ENDFOR
					
				FOR h=0, nother-1 DO BEGIN
					newrefstatarr[h+nrefs].id=othervalarr[h].field1
					newrefstatarr[h+nrefs].yr=othervalarr[h].field2
					newrefstatarr[h+nrefs].mo=othervalarr[h].field3
					newrefstatarr[h+nrefs].dy=othervalarr[h].field4
					newrefstatarr[h+nrefs].run=newrunarr[h]
					newrefstatarr[h+nrefs].inst=othervalarr[h].field6
					newrefstatarr[h+nrefs].ayr=othervalarr[h].field7
					newrefstatarr[h+nrefs].amo=othervalarr[h].field8
					newrefstatarr[h+nrefs].ady=othervalarr[h].field9
					newrefstatarr[h+nrefs].ahr=othervalarr[h].field10
					newrefstatarr[h+nrefs].amn=othervalarr[h].field11
					newrefstatarr[h+nrefs].asc=othervalarr[h].field12
					newrefstatarr[h+nrefs].av45=othervalarr[h].field13
					newrefstatarr[h+nrefs].stdev45=othervalarr[h].field14
					newrefstatarr[h+nrefs].av46=othervalarr[h].field15
					newrefstatarr[h+nrefs].stdev46=othervalarr[h].field16
					newrefstatarr[h+nrefs].avec13=othervalarr[h].field17
					newrefstatarr[h+nrefs].stdevc13=othervalarr[h].field18
					newrefstatarr[h+nrefs].aveo18=othervalarr[h].field19
					newrefstatarr[h+nrefs].stdevo18=othervalarr[h].field20
					
				ENDFOR
				
			nnew=nother+nrefs
			adate = DBLARR(nnew)
			FOR b=0, nnew -1 DO BEGIN
				CCG_DATE2DEC, YR=newrefstatarr[b].ayr, $
					MO=newrefstatarr[b].amo, DY=newrefstatarr[b].ady, $
					HR=newrefstatarr[b].ahr,MN=newrefstatarr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newrefstatarr=newrefstatarr[SORT(adate)]
			
			OPENW, u, refstatfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=refstatformat,newrefstatarr[a]
			FREE_LUN, u
	

		ENDELSE
ENDELSE


; ------------Looks like this next bit re-visits the data in refstatfile, then sorts it based on decimal dates calc
;-------------from tankdata(b) dates, then writes it back to file, leaving the pointer at the end, ready for the
;-------------the next 'write' with the current data (??). 

;CCG_SREAD, file=refstatfile, tankdata, /nomessages
;ntankdata=N_ELEMENTS(tankdata)
;IF ntankdata GT 0 THEN BEGIN
;	adate = DBLARR(1,ntankdata)
;		FOR b=0, ntankdata-1 DO BEGIN
;			CCG_DATE2DEC, YR=STRMID(tankdata[b],34,4), $
;			MO=STRMID(tankdata[b],39,2), DY=STRMID(tankdata[b],42,2), $
;			HR=STRMID(tankdata[b],45,2), MN=STRMID(tankdata[b],48,2), DEC=dec
;			adate[b]=dec
;		ENDFOR
;	tankdata=tankdata[SORT(adate)]
;	OPENU, u, refstatfile, /GET_LUN
;	FOR a=0, ntankdata-1 DO PRINTF, u, tankdata[a]
;	FREE_LUN, u
;ENDIF


; ----- PUT SAMPLE DATA SOMEWHERE TO BE PARSED OUT INTO PROPER PLACE -------------------
; final array of just samples called finalarr

samples = WHERE(type EQ 'SMP',nsamples)

IF samples[0] NE -1 THEN BEGIN
	finalarr = farr[samples]
	finalco2c13arr = STRARR(nsamples)
	finalco2o18arr = STRARR(nsamples)
	
;	print,'           '
;	print,'           '
	
	;this is the old version of ccg_flaskupdate. retained only for printing to screen.
	FOR i=0, nsamples-1 DO BEGIN
		finalco2c13arr[i] = [string(finalarr[i].enum)+$
			' co2c13'+string(finalarr[i].c13)+$
			' '+string(finalarr[i].c13flag)+$
			' '+string(finalarr[i].inst)+$
			' '+string(finalarr[i].ayr)+$
			' '+string(finalarr[i].amo)+$
			' '+string(finalarr[i].ady)+$
	
			' '+string(finalarr[i].ahr)+$
			' '+string(finalarr[i].amn)]
;		print, finalco2c13arr[i]	
	ENDFOR
;	print,'           '
;	print,'           '
	
	FOR i=0, nsamples-1 DO BEGIN
		finalco2o18arr [i] = [string(finalarr[i].enum)+$
			' co2o18'+string(finalarr[i].o18)+$
			' '+string(finalarr[i].o18flag)+$
			' '+string(finalarr[i].inst)+$
			' '+string(finalarr[i].ayr)+$
			' '+string(finalarr[i].amo)+$
			' '+string(finalarr[i].ady)+$
			' '+string(finalarr[i].ahr)+$
			' '+string(finalarr[i].amn)]
			print, finalco2o18arr[i]
		
	ENDFOR
;	print,'           '
;	print,'           '
	
	;new version of ccg_flaskupdate requires this, courtesy Dan Chao:
	
	
	FOR i=0, nsamples-1 DO BEGIN
 		nvpairs = ['evn:'+STRING(finalarr[i].enum)]
 		nvpairs = [nvpairs,'param:co2c13']
 		;IF finalarr[i].c13 NE 0.00 THEN nvpairs = [nvpairs,'value:'+STRING(finalarr[i].twptc13,format='(f10.4)')] ELSE $
		nvpairs = [nvpairs,'value:'+STRING(finalarr[i].c13,format='(f10.4)')]
		
 		nvpairs = [nvpairs,'flag:'+STRING(finalarr[i].c13flag)]
 		nvpairs = [nvpairs,'inst:'+STRING(finalarr[i].inst)]
 		nvpairs = [nvpairs,'yr:'+STRING(finalarr[i].ayr)]
 		nvpairs = [nvpairs,'mo:'+STRING(finalarr[i].amo)]
 		nvpairs = [nvpairs,'dy:'+STRING(finalarr[i].ady)]
 		nvpairs = [nvpairs,'hr:'+STRING(finalarr[i].ahr)]
 		nvpairs = [nvpairs,'mn:'+STRING(finalarr[i].amn)] 
 		nvpairs = [nvpairs,'sc:0'] 
		nvpairs = [nvpairs,'program:SIL'] 
		;IF update EQ 1 THEN BEGIN
		IF (uncertainty EQ 1) THEN nvpairs = [nvpairs,'unc:'+STRING(ccomberr)] 
		;ENDIF
 		z = STRJOIN(nvpairs, '|')
 		finalco2c13arr[i] = z
	ENDFOR	
	

	print,finalco2c13arr
	FOR i=0, nsamples-1 DO BEGIN
 		nvpairs = ['evn:'+STRING(finalarr[i].enum)]
 		nvpairs = [nvpairs,'param:co2o18']
		;IF finalarr[i].o18 NE 0.00 THEN nvpairs = [nvpairs,'value:'+STRING(finalarr[i].twpto18,format='(f10.4)')] ELSE $
 		nvpairs = [nvpairs,'value:'+STRING(finalarr[i].o18,format='(f10.4)')]
 		nvpairs = [nvpairs,'flag:'+STRING(finalarr[i].o18flag)]
 		nvpairs = [nvpairs,'inst:'+STRING(finalarr[i].inst)]
 		nvpairs = [nvpairs,'yr:'+STRING(finalarr[i].ayr)]
 		nvpairs = [nvpairs,'mo:'+STRING(finalarr[i].amo)]
 		nvpairs = [nvpairs,'dy:'+STRING(finalarr[i].ady)]
 		nvpairs = [nvpairs,'hr:'+STRING(finalarr[i].ahr)]
 		nvpairs = [nvpairs,'mn:'+STRING(finalarr[i].amn)] 
 		nvpairs = [nvpairs,'sc:0'] 
		nvpairs = [nvpairs,'program:SIL'] 
		;IF update EQ 1 THEN BEGIN
		IF (uncertainty EQ 1) THEN nvpairs =[nvpairs,'unc:'+STRING(ocomberr)] 
		;ENDIF
 		x = STRJOIN(nvpairs, '|')
 		finalco2o18arr[i] = x
	ENDFOR	
;stop
	; ----- TRANSFER PROCESSED SAMPLE DATA INTO DATABASE -----------------------
	;
	; NOTE - THIS IS THE PLACE TO PUT LOGIC THAT CHOSES BETWEEN UPDATING 
	;        THE DATABASE, OR OUTPUT TO A USER SPECIFIED SITE FILE DIRECTORY 
	;        OR SIMILAR, TO ALLOW TESTING WITHOUT CORRUPTING THE DATABASE.
	;                                                        BHV 8-4-05
;***********************************************************************************************	
	;changed from CCG_FLASKUPDATE_SIL to CCG_FLASKUPDATE because we don't need to overwrite flags
	;THEN changed to CCGGDEV_FLASKUPDATE Jan 2007 when CCG_FLASKUPDATE became obsolete.
	; THEN changed back to CCG_FLASKUPDATE June 2007 when Danlei Chao
	; updated database.	
;***********************************************************************************************

	IF update EQ 0 THEN BEGIN  

		IF printsitefiles EQ 1 THEN BEGIN ; -----Stream output to user specified directory
			;Note: this is for 'SMP' data only. Ref's and SIL's treated elsewhere.
			;IF jrasfile EQ 'reference.j6.co2c13'THEN BEGIN
			;	c13_dir = '/home/ccg/sil/co2c13/j6sitefiles/' 
			;	o18_dir = '/home/ccg/sil/co2o18/j6sitefiles/'
			;ENDIF
			;IF jrasfile EQ 'reference.j62.co2c13'THEN BEGIN
			;	c13_dir = '/home/ccg/sil/co2c13/j62sitefiles/' 
			;	o18_dir = '/home/ccg/sil/co2o18/j62sitefiles/'
			;	
			;ENDIF
			;IF jrasfile EQ 'reference.lsj62.co2c13'THEN BEGIN
			;	c13_dir = '/home/ccg/sil/co2c13/lsj62sitefiles/' 
			;	o18_dir = '/home/ccg/sil/co2o18/lsj62sitefiles/'
			;
			;ENDIF
			
				c13_dir='/home/ccg/sil/co2c13/sitefiles_jras06/' 	  ; final data check
				o18_dir='/home/ccg/sil/co2o18/sitefiles_jras06/' 		
		
			PRINT,'Updating site files to ',c13_dir

			CCG_FLASKUPDATE, arr=finalco2c13arr,/nomessages,ddir= c13_dir,error=error
	 		CCG_FLASKUPDATE, arr=finalco2o18arr,/nomessages,ddir= o18_dir,error=error
	
		ENDIF 
					
	ENDIF ELSE BEGIN ; -----Update the data base for real -------
		;add message here: proceed with data transfer?

		IF thispause EQ 1 THEN BEGIN
			 keepgoing=DIALOG_MESSAGE ('Proceed with data transfer?', title = 'Continue',/Question, /cancel)
			IF keepgoing EQ 'Cancel' THEN goto,bailout
			IF keepgoing EQ 'No' THEN goto,bailout
		ENDIF		
		
		PRINT, "Updating the data base with the data above..."
		CCG_FLASKUPDATE, arr=finalco2c13arr, /update,/value,/flag,/unc,nopreserve=1,error=error
		print,error
		CCG_FLASKUPDATE, arr=finalco2o18arr, /update,/value,/flag,/unc, nopreserve=1,error=error
		print,error
		
	ENDELSE
ENDIF
PRINT, '--------------------------------------------------'
PRINT, 'done processing file: ',file


 ;----- RUN DIAGNOSTICS PROGRAM -------------------------------------------------
;SAVE, /variables, filename = '/home/ccg/isotopes/idl/prgms/proc/diagnostics.co2c13.sav' 
;IF (N_ELEMENTS(trapfilearr) LT 10) OR (N_ELEMENTS(trapstatfilearr) LT 10) THEN BEGIN
;	;BHV MODIFIED NEXT LINE FOR CO2O18 SCALE RE-PROCESSING:
;	;IF (KEYWORD_SET(diagnostics)) THEN SIL_DIAG_CO2C13, ref=ref, trap=trap
;	IF (KEYWORD_SET(diagnostics)) THEN SIL_DIAG_CO2O18, ref=ref, trap=trap
;	PRINT, 'New REF and TRAP, No graphs yet!'
;ENDIF ELSE BEGIN
;	; BHV MODIFIED NEXT LINE.... 
;	;IF (KEYWORD_SET(diagnostics)) THEN SIL_DIAG_CO2C13, ref=ref, trap=trap, graphing=1
;	IF (KEYWORD_SET(diagnostics)) THEN SIL_DIAG_CO2O18, ref=ref, trap=trap, graphing=1
;ENDELSE
GOTO, skip
bomb: 
PRINT, 'Problem with file: ',file 
notthisref:
skip:
close
bailout:
getout:
print,'done.'
END
