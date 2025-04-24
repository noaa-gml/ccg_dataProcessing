; 


;;; NOTES 7/22/21

;;;; SLY is testing a linearity fix.
;;; assumelinearity=0
;;; printing to site files
;;; linvalshere is turned off

;NAME: sil_proc_ch4isotopes.pro		
;
; PURPOSE:  	
;	Processes raw files from TROI (CH4C13) and CRUSHER (ch4h2)
;	
;	GENERAL OUTLINE:
;		1) Read a raw file from projects/sp/inst/year
;		2) Process the run
;		3) Calculate delta values
;		4) QA/QC for data and flag when neccessary
;		5) upload flask data to database
;		6) parse out silflask, std data to proper files
;		7) Generate data/stats for diagnostic use by user
;		8) Update diagnostic files, do plots etc.
;	
; CATEGORY: 
;	Data processing
;	
; CALLING SEQUENCE:
;	Can be executed from the command line
;	or evoked from Ken's SQL web-world.
;
; INPUTS:	Will require the name of the raw file, 
;		which contains the raw data from the PC running the 
;		mass spectrometer.
;		
; OPTIONAL INPUT PARAMETERS:
;	Future versions may have options that will 
;	allow the user to select diagnostic plots
;	from a pull-down list; or choose to plot
;	performance of standard or trap tanks, etc.		 
;
; OUTPUTS:
;	Originally written to generate reduced data to be
;	merged into site files - now updates to mySQL database
;	Tank and silflask data written to files.
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
;
; MODIFICATION HISTORY:
;	Written,           JBM: sil_proc_ch4c13.pro
;   	Updated, VAC, August, 2004
;	To be put into use 8/30/04
;	Modified VAC June 2005 to put "N" flag in middle column for "new extraction
;		system" on lines 365 to 451
;	Modified SRE March 2006 to salvage parts of a run if only one set of refs is bad
;		lines 441-497
;	Modified SRE March 2006 to get rid of the N flag
;	Modified SRE 7/06 to use only 2nd, 3rd, and 4th refs in each set to calculate averages 
; 		and standard deviations.
;	Modified SRE 7/06 to remove ref samples whose sample peak is significantly lower than
;		the rest. How much lower is a knob called peakdiff - not used.	
;	Modified SREM 11/08 to accommodate new ccg_flaskupdate
;	Modified 3/20/09 to manage different run structures. .. follows sil_proc_co2c13
;	Modified 4/17/10 to run both ch4c13 and ch4h2 isotopes . .. will rename sil_proc_ch4isotopes.pro
;	Modified 2/1/11 to overwrite tank data. 
;	Modified sometime winter 10/11 to have uncertainty
;	Modified 2/9/11 to add secpos flags
;	Modified 1/4/13 to move secpos flags to thirdpos.
;       Modified 4/23/14 to add flags for too drifty runs and too-short peaks
;	Also tightened trap limits - hard flags for trap GT or LT 0.3 from mean
;	6/8/17 changed 'a' to 'A' so that A flags would actually be applied. 
;	added search for ! or B flags so that hand flags would be retained with reprocessing
;       7/15/17 reprocessing data so need a way to keep track: quick print statement
;        Added ability to adjust data to the trap tank. trapadjust keyword=1. If this is on, trapstat value will equal the long term values of the traps; ref values will not agree with the
;	ref. Done at the recommendation of Pieter Tans, 7/17/2020. Applied 8/13/2020. Use carefully!


; ----- INITIALIZATION ---------------------------------------------------------
PRO sil_proc_ch4isotopes,	$
	file = file,		$
	inst = inst,		$
	nomessages = nomessages,$
	diagnostics = diagnostics,$
	update = update,	$
	reprintsil=reprintsil,	$
	pause=pause,		$
	printtanks=printtanks,  $
	log_data=log_data,	$
	uncertainty=uncertainty,$
	printsitefiles=printsitefiles,	$
	secposflags=secposflags,	$
	sp=sp,			$
	adjusttotrap=adjusttotrap

IF NOT KEYWORD_SET(log_data) THEN log_data = 0 
IF NOT KEYWORD_SET(reprintsil) THEN reprintsil = 1 
IF NOT KEYWORD_SET(update) THEN update=0 
IF NOT KEYWORD_SET(printtanks) THEN printtanks=0
sacredfile='reference.'+sp
mras = 0
;print, 'YOU ARE PROCESSING DATA TO MRAS, not INSTAAR, scale' 
IF mras EQ 1 THEN sacredfile='ref.mras.ch4c13'
IF mras EQ 1 THEN secposflags=0
unc=-0.09


;nov2024_testfiles2
flagpeakhtdiffs=1.5
addhardflags=0
IF flagpeakhtdiffs EQ 1 THEN PRINT, 'FLAGGING PEAK HEIGHT DIFFERENCES'


fileyr=FIX(STRMID(file,0,4))

correctforlinearity=0
IF fileyr EQ 2018 THEN correctforlinearity=1
IF fileyr EQ 2019 THEN correctforlinearity=1
IF fileyr EQ 2020 THEN correctforlinearity=1

;IF NOT KEYWORD_SET(uncertainty) THEN uncertainty=1
;IF NOT KEYWORD_SET(pause) THEN pause=0
IF NOT KEYWORD_SET(printsitefiles) THEN printsitefiles=1
IF NOT KEYWORD_SET(secposflags) THEN secposflags=0
IF NOT KEYWORD_SET(adjusttotrap) THEN adjusttotrap=0

new17O=0

assumelinearity=1  ; whether you should use 'best-guess linearity'
mcmethod=1   ; monte carlo method? if 0, just standard lincorr
;if LIN samples are in the run, they will be used instead
;next step: use most-recent lin correction

;seconddot=STRPOS(file,'.',/REVERSE_SEARCH)
;sp=STRMID(file,seconddot+1,6)
IF sp EQ 'ch4c13' THEN inst='i1'  ;; but with old data, could be 'o1'.
IF sp EQ 'ch4h2' THEN inst='i3'
	
IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE, 'File must be specified'
	CCG_MESSAGE, "EXAMPLE : sil_proc_ch4c13, file = 'ch400XXX.i1'"
ENDIF

;IF testmode EQ 1 THEN BEGIN
;	reprintsil=1
;	printtanks=0
;	update=0
;	logdata=1
;ENDIF

; ----- SET GLOBAL VARIABLES -------------------------------------------------
IF NOT KEYWORD_SET(nomessages) THEN verbose = 0 ELSE verbose = 1


; ----- "KNOBS" that can be adjusted -----------------------------------------
; maximum pair difference allowed and maximum standard deviation of references
; peakdiff is the difference from the mean peak height that a ref peak has to be 
; for it to be dropped from the analysis	
IF sp EQ 'ch4c13' THEN BEGIN
	pdlimit = 0.15
	reflimit =0.10
	peakdiff = 0.5 
ENDIF ELSE BEGIN
	pdlimit = 4.0  ; for testing 2/10/22. Originally 3.0
	reflimit = 4.0  ; for testing 2/7/22/  2.0
	peakdiff = 0.5 
ENDELSE

; ----- READ IN RAW FILE -----------------------------------------------------
year = STRMID(file,0,4)
	rawdir = '/projects/'+sp+'/flask/' + inst + '/raw/' + year + '/'
	rawfile = rawdir+file


CCG_SREAD, file = rawfile, /nomessages, head

IF sp EQ 'ch4c13' THEN BEGIN
;; figure out if it's an old run

	dash=STRPOS(head[0],'-')
	IF dash[0] EQ -1 THEN BEGIN 
		runnum = '0'+STRMID(head[0], 17, 5)
		olddata=0
	ENDIF ELSE BEGIN
		runnum = '0'+STRMID(head[0], dash+1, 3)
		olddata=1
	ENDELSE
ENDIF ELSE BEGIN
	olddata=0
	runnum = STRMID(head[0], 14, 6)
ENDELSE

runnumber=FIX(runnum)

flagitall=0   ;USE THIS CAREFULLY!!! Will flag all samples in run. 

autoflag=0 ; will change to 1 for these runs:
;3033-3036
;3044-3046
;3063-3068
;3080

IF addhardflags EQ 1 THEN BEGIN
; should add sp here also
IF runnumber  EQ 3033 THEN flagitall=1 
IF runnumber  EQ 3034 THEN flagitall=1
IF runnumber  EQ 3035 THEN flagitall=1
IF runnumber  EQ 3036 THEN flagitall=1
IF runnumber  EQ 3044 THEN flagitall=1
IF runnumber  EQ 3045 THEN flagitall=1
IF runnumber  EQ 3046 THEN flagitall=1
IF runnumber  EQ 3063 THEN flagitall=1
IF runnumber  EQ 3064 THEN flagitall=1
IF runnumber  EQ 3065 THEN flagitall=1
IF runnumber  EQ 3066 THEN flagitall=1
IF runnumber  EQ 3067 THEN flagitall=1 
IF runnumber  EQ 3068 THEN flagitall=1
IF runnumber  EQ 3080 THEN flagitall=1 
IF runnumber  EQ 3033 THEN autoflag=1 
IF runnumber  EQ 3034 THEN autoflag=1
IF runnumber  EQ 3035 THEN autoflag=1
IF runnumber  EQ 3036 THEN autoflag=1
IF runnumber  EQ 3044 THEN autoflag=1
IF runnumber  EQ 3045 THEN autoflag=1
IF runnumber  EQ 3046 THEN autoflag=1
IF runnumber  EQ 3063 THEN autoflag=1
IF runnumber  EQ 3064 THEN autoflag=1
IF runnumber  EQ 3065 THEN autoflag=1
IF runnumber  EQ 3066 THEN autoflag=1
IF runnumber  EQ 3067 THEN autoflag=1 
IF runnumber  EQ 3068 THEN autoflag=1
IF runnumber  EQ 3080 THEN autoflag=1 

ENDIF

IF olddata EQ 1 THEN secposflags=0
IF olddata EQ 1 THEN calsdir='cals_old' ELSE calsdir='cals'   ;;; cals is now cals_dir
;IF sp EQ 'ch4h2' THEN calsdir ='cals_new'
;revcalsdir='cals_archive'
;print,'------------------WARNING---------------------'
;print,' reprocessing ch4h2 to DB; checking old data to retain flags'
;print,'---------turn this off when process complete --------------------
If adjusttotrap EQ 1 THEN calsdir='calstest2'
;IF correctforlinearity EQ 1 THEN calsdir='cals_lin' ELSE calsdir='cals'
;calsdir='calz'

IF mras EQ 1 THEN calsdir='cals_mras'

PRINT,'****************printing cylinders to ',calsdir
; might need to do this by analysis date.
IF olddata EQ 1 THEN inst='o1'    ;;; THiS MIGHT CHANGE!! not sure when we switched


IF sp EQ 'ch4c13' THEN BEGIN
	;THIS is to account for warmups
	;Warmups used to be renamed to REF - which was a bad idea!
	;May eventually re-create rawfiles, in which all files will be read with skip=1
	;but for now, leave as is and skip 3 for old ch4c13 files.
	; no warmups in old data (so far as I can tell)
	IF olddata EQ 0 THEN BEGIN
		IF runnum LT 1540 THEN BEGIN
			CCG_READ, file=rawfile, skip=3, data, /nomessages
		ENDIF ELSE BEGIN
			CCG_READ, file=rawfile, skip=1, data, /nomessages
		END
	ENDIF ELSE BEGIN
		CCG_READ, file=rawfile, skip=1, data, /nomessages
	ENDELSE	

ENDIF ELSE BEGIN

; ch4h2 raw files recreated, so this isn't necessary!
	CCG_READ, file=rawfile, skip=1, data, /nomessages
ENDELSE	
ntot = N_ELEMENTS(data)

;;;;;*****************************************************
;*********************************************************
; THIS IS WHERE WE'RE AT 
;*********************************************************
; ----- MAPPING SINGLE FIELD ARRAYS
type   	  = STRARR(ntot)
enum 	  = STRARR(ntot)
site      = STRARR(ntot)	
yr        = FLTARR(ntot)
mo        = FLTARR(ntot)   ; sample info
dy        = FLTARR(ntot)
hr        = FLTARR(ntot)
mn        = FLTARR(ntot)
id        = STRARR(ntot)
meth      = STRARR(ntot)
num       = INTARR(ntot)
oval     = FLTARR(ntot)
rawval    = FLTARR(ntot)     ; original code worked with Craig corrected raw data
d13C      = FLTARR(ntot)     ; now I'm calling "raw" data d13C
d18O	  = FLTARR(ntot)     ; and I'll need d18O
d45	  = FLTARR(ntot)     ; so that I can un-Craig correct, to get d45
d46       = FLTARR(ntot)     ; and d46.   Then I'll do a Brand et al 2010 correction
peakht    = FLTARR(ntot)
strategy  = STRARR(ntot)
peakhtdiff=FLTARR(ntot)

FOR i=0, ntot-1 DO BEGIN
	type[i]= data[i].field1
	enum[i]= data[i].field2
	CASE type[i] OF
		'SMP':	BEGIN
			CCG_FLASK, evn=enum[i],strategy='flask', arr, /NOMESSAGES
			goodenum = SIZE(arr)
			IF goodenum[0] NE 0 THEN BEGIN
				site[i]=arr.code
				yr[i]=arr.yr
				mo[i]=arr.mo
				dy[i]=arr.dy
				hr[i]=arr.hr
				mn[i]=arr.mn
				id[i]=arr.id
				meth[i]=arr.meth
				strategy[i]='flask'
			ENDIF ELSE BEGIN
				CCG_FLASK, evn=enum[i], strategy='pfp',/nomessages,arr
				goodenum = SIZE(arr)
				IF goodenum[0] NE 0 THEN BEGIN
					site[i]=arr.code
					yr[i]=arr.yr
					mo[i]=arr.mo
					dy[i]=arr.dy
					hr[i]=arr.hr
					mn[i]=arr.mn
					id[i]=arr.id
					meth[i]=arr.meth
					strategy[i]='pfp'
				ENDIF ELSE BEGIN

					Print,'Missing valid event numbers!'

				ENDELSE
			ENDELSE
			END
			'BOG':	BEGIN
				site[i]='BOG'
				yr[i]=9999
				mo[i]=99
				dy[i]=99
				hr[i]=99
				mn[i]=99
				id[i]='xx'
				meth[i]='x'
				strategy[i]='flask'
			END
		'SIL':  BEGIN		
			CCG_READ, file='/projects/co2c13/flask/sb/sil_eventnum.txt',  $  ;'/home/ccg/isotopes/idl/prgms/proc/sil_eventnum.txt', $
			delimiter=' ', /nomessages, silevnum
			samdata = WHERE(silevnum.field1 EQ enum[i])
			IF samdata[0] NE -1 THEN BEGIN
				type[i]	='SIL' 
				site[i]	='sil'
				yr[i]	=silevnum[samdata].field5
				mo[i]	=silevnum[samdata].field6
				dy[i]	=silevnum[samdata].field7
				mn[i] 	=0
				id[i]	=silevnum[samdata].field3
				meth[i]	=silevnum[samdata].field4
				strategy[i] = 'sil'
			ENDIF ELSE BEGIN
				type[i]	='SIL' 
				site[i]	='UNK'
				yr[i]	=0
				mo[i]	=0
				dy[i]	=0
				mn[i] 	=0
				id[i]	=0-00
				meth[i]	='u'
			ENDELSE	
		END
		ELSE:  BEGIN  ;TYPE IS STD FOR ALL CYLS
			tankfileIV = '/projects/co2c13/flask/sb/reference.'+sp
			sacredvalues = '/projects/co2c13/flask/sb/'+sacredfile

			temptankfileIV = '/home/ccg/sil/tempfiles/tanktempIV'
			CCG_SREAD, file = tankfileIV, skip = 2, stdarr, /nomessages
			m = WHERE(STRMID(stdarr,0,1) NE '#',eor)
			saved = stdarr[m]
			CCG_SWRITE, file = temptankfileIV, saved, /nomessages
		
			
			CCG_READ, file=temptankfileIV, refvals, /nomessages
			IF mras EQ 0 THEN BEGIN
				sacrrefvals=refvals
			ENDIF ELSE BEGIN
				CCG_READ, file=sacredvalues, sacrrefvals, /nomessages
			ENDELSE 
			
			count = WHERE(refvals.field1 EQ enum[i])
			IF (count[0] NE -1)THEN BEGIN	
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
				tankfileV ='/projects/co2c13/flask/sb/reference_external.'+sp
				temptankfileV = '/home/ccg/sil/tempfiles/tanktempV'
				CCG_SREAD, file = tankfileV, skip = 2, stdarr, /nomessages
				m = WHERE(STRMID(stdarr,0,1) NE '#')
				saved = stdarr[m]
				CCG_SWRITE, file = temptankfileV, saved, /nomessages
				CCG_READ, file=temptankfileV, tankvals, /nomessages
				count = WHERE(tankvals.field1 EQ enum[i],ncount)
				IF (count[0] NE -1)THEN BEGIN
				;sre inserted logic here for cylinders which have been refilled
				ourtanks=tankvals[count]
					IF ncount GT 1 THEN BEGIN
					;--this is where we have to deal with a cylinder that has multiple fill dates. 
					;--turn the cylinder fill date information and compare them to the analysis date.
					;--------create an array with ncount positions
					filldatechart=findgen(ncount)
					
						FOR fill=0,ncount-1 DO BEGIN
						;--------fill the positions with the dates
							CCG_DATE2DEC, yr=ourtanks[fill].field2,mo=ourtanks[fill].field3,$
							dy=ourtanks[fill].field4,mn=00,dec=filldate 
							filldatechart[fill] = filldate
						ENDFOR
						
						; make sure the dates are in order
						order=SORT(filldatechart)
						filldatechart=filldatechart[order]
						;now reorder ourtanks to the same order
						ourtanks=ourtanks[order]
						CCG_DATE2DEC, yr=data[i].field3,mo=data[i].field4,$
						dy=data[i].field5,mn=00,dec=adate
					
					;----here's where the tricky logic goes. 
					; SRE's method was to count backward on filldatechart (using ncount-1-0, ncount-1-1, etc)
					; to find the tank that is earlier than your adate. 
					
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
				ENDIF		
			ENDELSE
		END
		
		ENDCASE
		IF type[i] EQ 'LIN' THEN site[i] = 'LIN'
		
		num[i] = data[i].field8
		IF sp EQ 'ch4c13' THEN BEGIN
			oval[i] = data[i].field21
			rawval[i] = data[i].field20
			peakht[i]=data[i].field18
			
			IF new17O EQ 1 THEN BEGIN
				; undo craig correction here. 
			
				crP=1.0676
				crQ=0.0338
				crS=1.0010
				crT=0.0021
				;d13C=P*d45-Q*d46
				;d18O= S*d46 - T*d46
			
				d13C[i]=data[i].field20    ; these are already in here as rawval and oval, but we'll name them again. ..
				d18O[i]=data[i].field21
			
				;now do some math! 2 equations and 2 unknowns
			
			
			
				d46[i]=[d18O[i]+(crT/crP)*((d13C[i]))]/(crS-(crT*crQ)/crP)
				d45[i]=(d13C[i]+(crQ*d46[i]))/crP
			ENDIF
			
		ENDIF ELSE BEGIN
			rawval[i] = data[i].field14
			peakht[i]=data[i].field12
		
		ENDELSE
ENDFOR

IF (log_data EQ 1) THEN BEGIN

	logfile='/home/ccg/sil/tempfiles/'+sp+'.'+file

	OPENW, u, logfile, /GET_LUN
	PRINTF, u ,'rawval'
	FOR z=0, ntot-1 DO PRINTF, u, rawval[z]
	FREE_LUN, u
ENDIF

; ----- DETERMINE RUN STRUCTURE AND ANALYSIS TYPES -----------------------------
;group analyses into:

;for safety, convert all id's to upper case
data.field2 = STRUPCASE(data.field2)

refpos = WHERE(type EQ 'REF', nrefs)
nrefpos=N_ELEMENTS(refpos)   ; this seems redundant
IF refpos[0] NE -1 THEN refs = data[refpos]
ref=enum[refpos[0]]
findrefvalue=WHERE(sacrrefvals.field1 EQ STRUPCASE(ref))

IF mras EQ 1 THEN BEGIN
IF ref EQ 'DEWY-001' THEN goto, skipahead
ENDIF
IF sp EQ 'ch4h2' THEN BEGIN
	IF findrefvalue NE -1 THEN ourrefvalue=sacrrefvals[findrefvalue].field11
	
ENDIF ELSE BEGIN
	IF findrefvalue NE -1 THEN BEGIN
		IF new17O EQ 0 THEN ourrefvalue=sacrrefvals[findrefvalue].field10 ELSE ourrefvalue=sacrrefvals[findrefvalue].field9
	ENDIF	
ENDELSE

IF ourrefvalue LT -200.0 THEN goto, skipahead
sampos = WHERE(type NE 'REF', nsams)
IF sampos[0] NE -1 THEN samples = data[sampos]

trappos=WHERE(type EQ 'TRP',ntrap)

; get average peak ht for refs
refpeaks=peakht[refpos]
meanrefpeakht=MEAN(refpeaks)


IF olddata EQ 0 THEN BEGIN  ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^new data drift correction starts here


	;-------------------------------------------------------------------------------
	;separate refs into n groups (typically 3) and calculate ref gas averages for each group,
	;throwing out the first two of the first group
	
	;separate into groups
	grouparr = INTARR(nrefs)
	grouparr[0] = 1
	group = 1
	
	FOR i=0, nrefs-2 DO BEGIN
		diff = refpos[i+1]-refpos[i]
		IF diff EQ 1 THEN group = group+0 ELSE group = group+1
		grouparr[i+1] = group
	ENDFOR
	ngroups = N_ELEMENTS(UNIQ(grouparr))
	
	;set up a variable to collect index number for each ref
	cluster=INTARR(ngroups)
	
	FOR c=0,ngroups-1 DO BEGIN
		thisgroup=WHERE(grouparr EQ (c+1),nthisgroup)
		cluster[c]=nthisgroup
		
	ENDFOR

	;now need to capture the position of the last ref in each group of refs
	; put into array called refsets

	refsets=INTARR(ngroups)
	ct=0

	FOR i=0,ngroups-2 DO BEGIN
		REPEAT BEGIN
			ct=ct+1
		ENDREP UNTIL (refpos[ct]-refpos[ct-1] NE 1)
		refsets[i]=refpos[ct-1]
	
	ENDFOR


	refsets[ngroups-1]= refpos[nrefs-1]	; last ref position

	;--------------------------------------------------
	;calculate group averages and s.d.'s
	
	refgroupave = FLTARR(ngroups)
	refgroupsd = FLTARR(ngroups)
	refgroupflag=STRARR(ngroups)

	; Before July, 2006, all 4 refs were used for refgroupave and refgroupsd. We only want to use 2,3,and 4th. 
	FOR j=0,ngroups-1 DO BEGIN
		last1=refsets[j]
		
		IF cluster[j] EQ 1 THEN BEGIN
			refgroupave[j]=rawval[last1]
			refgroupsd[j]=-99
			
		
		ENDIF
		IF cluster[j] EQ 2 THEN BEGIN
			refgroupave[j]=rawval[last1]
			refgroupsd[j]=-99
		
		ENDIF
		IF cluster[j] GT 2 THEN BEGIN
			ncluster=cluster[j]
			rawvalarr=fltarr(ncluster-1)
			FOR r=0,ncluster-2 DO BEGIN
				rawvalarr[r]=rawval(last1-ncluster+2+r)
			ENDFOR
			rawresult=MOMENT(rawvalarr,SDEV=rawvalstdev)
			refgroupave[j]=rawresult[0]
			refgroupsd[j]=rawvalstdev
			
		ENDIF
	
		IF refgroupsd[j] GT reflimit THEN refgroupflag[j] = 'A' ELSE refgroupflag[j] = '.'
	
	ENDFOR

	
	badref=WHERE(refgroupflag EQ 'A',nbadref) ;this is a vector   ; this was 'a' until 5/31/17. 
	
	;NOW I'm using sil_proc_co2c13.pro as a guide to make drift correcting more
	; robust

	IF ngroups GT 1 THEN samsets = FLTARR(2,ngroups-1) ELSE samsets=FLTARR(2,1)
	;need to know if run begins and ends with refs
	
	IF type[0] NE 'REF' THEN firstlineref=0 ELSE firstlineref=1
	IF type[ntot-1] NE 'REF' THEN lastlineref=0 ELSE lastlineref=1
	
	;samsets(0,*) = last sample of set
	;samsets(1,*)= number in set
	
	
	ct=0
	IF ngroups EQ 1 OR ngroups EQ 2 THEN z=0
	IF ngroups GT 2 THEN z=ngroups-2
	
	IF nsams GT 1 THEN BEGIN
		FOR i=0,z DO BEGIN
			nums=0
			REPEAT BEGIN
				ct=ct+1
				nums=nums+1
			ENDREP UNTIL (sampos[ct]-sampos[ct-1] NE 1 OR ct EQ nsams-1)	
	
	
			samsets[0,i]=sampos[ct-1]
			samsets[1,i]=nums
		ENDFOR
	ENDIF ELSE BEGIN
		samssets[0,0]=sampos[ct]
		samsets[1,0]=1
	ENDELSE
	
	;this is a cloogey way to add one sample number to last set.
	samsets[0,z]=samsets[0,z]+1
	samsets[1,z]=samsets[1,z]+1
	
	dcorvals=FLTARR(ntot)
	ddcorfact=FLTARR(ntot)
	driftflagarr=STRARR(ntot)
	driftflagarr(*)='.'
	IF sp EQ 'ch4c13' THEN driftknob=0.3 ELSE driftknob=5  ; 0.25
	IF ngroups GT 1 THEN BEGIN
		FOR i=0,ngroups-2 DO BEGIN
			j=i+1
			anchorpoint1=cluster[i]/2   ;midpoint of previous set
			anchorpoint2=cluster[j]/2   ;midpoint next set
			prerefav=refgroupave[i]   ;prev ref avg
			porefav=refgroupave[j]
	
			refnum=refsets[i]	    ;last analysis number of prev ref set
			samnum=samsets[1,i]         ;number of analyses in sam set
		
			FOR k=0,samnum-1 DO BEGIN
			    thissample=refnum+1+k
			    ddcorfact[thissample]=(((porefav-prerefav)*(thissample-refnum+anchorpoint1))/ $
			    	(samnum+anchorpoint1+anchorpoint2))+prerefav
		               dcorfact=(((porefav-prerefav)*(thissample-refnum+anchorpoint1))/ $
			    	(samnum+anchorpoint1+anchorpoint2))+prerefav
				
			    dcorvals[thissample]=(((rawval[thissample]/1000+1)/ $
			    	(dcorfact/1000+1))-1)*1000
				
				drift=refgroupave[i+1]-refgroupave[i]
				
				IF abs(drift) GT driftknob THEN BEGIN
					driftflagarr[thissample]='D'
				
				ENDIF

			ENDFOR
		
		ENDFOR
		
	ENDIF

ENDIF ELSE BEGIN
	
	; deal with weird run structure from old runs. ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^old run drift correct here

	weirdrefgroups=FLTARR(nrefs)
	FOR y=0,nrefs-1 DO BEGIN
		IF y EQ 0 THEN weirdrefgroups[y]=-1
		IF y EQ 1 THEN weirdrefgroups[y]=1
		;IF y EQ 2 THEN weirdrefgroups[y]=1
		counter=0
		IF y GT 1 THEN BEGIN
			IF refpos[y]-refpos[y-1] EQ 1 THEN weirdrefgroups[y]=weirdrefgroups[y-1]
			IF refpos[y]-refpos[y-1] EQ 2 THEN BEGIN
	
				IF counter EQ 0 THEN BEGIN
					weirdrefgroups[y]=weirdrefgroups[y-1]
					counter=counter+1
					GOTO,gobackwards
				ENDIF
			ENDIF
		ENDIF
			
	ENDFOR
	gobackwards:
	; now we'll start at end of refpos
	FOR y=0,nrefs-1 DO BEGIN
		IF y EQ 0 THEN weirdrefgroups[nrefs-[1+y]]=3
		counter=0
		IF y GT 0 THEN BEGIN
			print,'y = ',y
	
			IF ABS(refpos[nrefs-(1+y)]-refpos[nrefs-y]) EQ 1 THEN weirdrefgroups[nrefs-(y+1)]=weirdrefgroups[nrefs-y]
			IF ABS(refpos[nrefs-(1+y)]-refpos[nrefs-y]) EQ 2 THEN BEGIN
			
				IF counter EQ 0 THEN BEGIN
					weirdrefgroups[nrefs-(y+1)]=weirdrefgroups[nrefs-(y)]
					counter=counter+1
					GOTO,fillin
				ENDIF
			ENDIF
		ENDIF
	ENDFOR	

	fillin:	   ; fill in the middle 
		midsection=WHERE(weirdrefgroups EQ 0)
		weirdrefgroups[midsection]=2
	
	; now, find averages and stdev of these sets
	
	ngroups=3
	refgroupave = FLTARR(3)
	refgroupsd = FLTARR(3)
	refgroupflag=STRARR(3)
	
	cluster=intarr(ngroups)
	anchorpt=INTARR(ngroups)
	;;last1=intarr(nrefs)   ; do we need this??
	;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%here
	; Before July, 2006, all 4 refs were used for refgroupave and refgroupsd. We only want to use 2,3,and 4th. 
	FOR j=0,2 DO BEGIN
		thisset=WHERE(weirdrefgroups EQ (j+1),nthis)
		thisbatch=rawval[refpos[thisset]]
		cluster[j]=nthis
		IF j EQ 0 THEN anchorpt[j]=refpos[thisset[0]]+FIX(cluster[j]/2)
		IF j EQ 2 THEN anchorpt[j]=refpos[thisset[0]]+FIX(cluster[j]/2)-2
		IF j EQ 1 THEN anchorpt[j]=refpos[nrefs/2+1]-3 ; this is super cloogey

		IF cluster[j] EQ 1 THEN BEGIN
			refgroupave[j]=thisbatch[0]
			refgroupsd[j]=-99
		ENDIF
	
		IF cluster[j] GT 1 THEN BEGIN
			refgroupmo=MOMENT(thisbatch,sdev=sdev)    ; note, this method does not drop first
			refgroupave[j]=refgroupmo[0]
			refgroupsd[j]=sdev
		ENDIF
	
		IF refgroupsd[j] GT reflimit THEN refgroupflag[j] = 'A' ELSE refgroupflag[j] = '.'
	
	ENDFOR
	badref=WHERE(refgroupflag EQ 'A',nbadref) ;this is a vector   ; this was 'a' until 5/31/17. 
	print,anchorpt
	
	m1=(refgroupave[1]-refgroupave[0])/(anchorpt[1]-anchorpt[0])
	b1=refgroupave[1]-(m1*anchorpt[1])
	m2=(refgroupave[2]-refgroupave[1])/(anchorpt[2]-anchorpt[1])
	b2=refgroupave[2]-(m2*anchorpt[2])
	ddcorfact=FLTARR(ntot)
	dcorvals=FLTARR(ntot)
	driftflagarr=STRARR(ntot)
	driftflagarr(*)='.'           ;;;;;;;  how do we deal with drift in old data???
	
	FOR n=0,ntot-1 DO BEGIN
		IF n LT anchorpt[1] THEN ddcorfact[n]=(m1*n)+b1
		IF n EQ anchorpt[1] THEN ddcorfact[n]=refgroupave[1]
		IF n GT anchorpt[1] THEN ddcorfact[n]=(m2*n)+b2
			

	    dcorvals[n]=(((rawval[n]/1000+1)/ $
		    	(ddcorfact[n]/1000+1))-1)*1000

	ENDFOR

ENDELSE

;now 'drift correcting' the refs - really normalizing to averages

IF olddata EQ 0 THEN BEGIN
	FOR i=0,ngroups-1 DO BEGIN
		
		dcorfact=refgroupave[i]
		lastrefnum=refsets[i]
		numref=cluster[i]
		FOR l=0,cluster[i]-1 DO BEGIN
			dcorvals[lastrefnum-numref+1+l]=(((rawval[lastrefnum-numref+1+l]/1000+1)/   $
				(dcorfact/1000+1))-1)*1000
			ddcorfact[lastrefnum-numref+1+l]=dcorfact
		ENDFOR
	ENDFOR
	
	
	;THIS IS WHERE, IF SECOND REF SET IS BAD, WE DRIFT CORRECT FROM BEGINNING TO END REF SETS
	IF ngroups GT 2 THEN BEGIN
		IF nbadref EQ 1 THEN BEGIN
			IF badref[0] EQ 1 THEN BEGIN
				print, 'Second ref set is bad. Drift correcting from first to last refs'
				
				anchorpoint1=cluster[0]/2
				anchorpoint2=cluster[ngroups-1]/2
				prerefav=refgroupave[0]
				porefav=refgroupave[2]
				refnum=refsets[0]
				samnum=samsets[1,ngroups-2]
				numfirsthalf=samsets[1,0]
				numsechalf=samsets[1,1]
				numsecrefset=cluster[1]
				totaldc=numfirsthalf+numsechalf+numsecrefset
	
				FOR k=0,totaldc-1 DO BEGIN
		         	    	thissample=refnum+1+k
				    	ddcorfact[thissample]=(((porefav-prerefav)*(thissample-refnum+anchorpoint1))/ $
			    			(numfirsthalf+numsechalf+numsecrefset+anchorpoint1+anchorpoint2))+prerefav
		                   	dcorfact=(((porefav-prerefav)*(thissample-refnum+anchorpoint1))/ $
			    			(numfirsthalf+numsechalf+numsecrefset+anchorpoint1+anchorpoint2))+prerefav
				
					    dcorvals[thissample]=(((rawval[thissample]/1000+1)/ $
			    			(dcorfact/1000+1))-1)*1000	
						
						newdrift=refgroupave[2]-refgroupave[0]
					
						
						driftflagarr[thissample]='.'
					IF newdrift GT (2*driftknob) THEN driftflagarr[thissample]='D'
				
				ENDFOR
				
			ENDIF
		ENDIF
		;;;;;;;-----TAG
	ENDIF	

	;if you have samples after the last ref (out of ln2, etc) correct to last set of refs (no drift corr'n)
	; this doesn't look to see if last set is flagged or not . ..
	IF lastlineref EQ 0 THEN BEGIN
		FOR r=refsets[ngroups-1],ntot-1 DO BEGIN
			dcorfact=refgroupave[ngroups-1]
			ddcorfact[r]=refgroupave[ngroups-1]
			dcorvals[r]=(((rawval[r]/1000+1)/(dcorfact/1000+1))-1)*1000
			;----TAG
		ENDFOR
		
		;OR, drift correct using refsets 1 and 2. 
		; how to choose which way to go?? 
		;---- DIFFERENT TAG
	ENDIF
ENDIF 

; no elseif for old data?
	
IF (log_data EQ 1) THEN BEGIN
	
	OPENW, u, logfile, /GET_LUN,/APPEND
	PRINTF, u ,'ddcorfact'
	FOR z=0, ntot-1 DO PRINTF, u, ddcorfact[z]
	PRINTF, u ,'dcorvals'
	FOR z=0, ntot-1 DO PRINTF, u, dcorvals[z]
	
	FREE_LUN, u
ENDIF


;;; now look at linearity
;; added 6/15/2020, starting with run ch403140

IF correctforlinearity EQ 0 THEN GOTO,skipthiscorrection 
; can decide later if this goes to DB or not... 
; Here we either use what's in the run, or the most recent calculation of it.


linrefvals=FLTARR(ntot)   ; array of what stds would be if they were shorter peak ht
lincorrectedvals=FLTARR(ntot)   ; values corrected for linearity, but not yet on vpdb
linvalshere=WHERE(type EQ 'LIN', nlins)

;;; testing 'bulk' lin testing, so skip this

;IF linvalshere[0] NE -1 THEN BEGIN
;	linvals=WHERE(type EQ 'LIN' or type EQ 'REF', nlins)
;	;; now find relationship between peak ht and d13C
;	thisy=dcorvals[linvals]
;	thisx=peakht[linvals]
;	minpkht=MIN(thisx)  ; min and max of all peaks used to get slope
;	maxpkht=MAX(thisx)
;	
;	refpkht=MEAN(peakht[refpos]) ; mean or refpeaks
;	;IF maxpkht-refpkht GT 1 THEN 
;	;old plotting:
;	ccg_symbol,sym=1
;	plot,thisx,thisy,psym=8
;	
;	
;	;;newplotting
;	;linplot=PLOT(thisx,thisy,dimensions=[1000,600],xtitle='beam (nA)',ytitle='normalized d13C-CH4',symbol='circle',sym_size=1.2,sym_filled=1,$
;	;font_size=16,linestyle=6,color='red')
;	;stop
;	;now need to loook up chisq result in table
;	CCG_READ,file='/home/ccg/michel/tempfiles/chisqprobs.txt',chisq,skip=1
;	
;	; OPENR,u,'/home/ccg/michel/tempfiles/chisqprobs.txt',/GET_LUN
;	; array=0.0
;	; line=''
;	;;; READU,u,probs
;	; FREE_LUN,u
;	; hmmm that's not working. Here's my cloogey way to read in an array
; 
;	probs=FLTARR(12,38)
;	df=INTARR(38)
;	df[0]=0
;	FOR d=1,37 DO df[d]=chisq[d].field1
;	FOR b=0,37 DO BEGIN
;	 	probs[0,b]=chisq[b].field2
;		probs[1,b]=chisq[b].field3
;		probs[2,b]=chisq[b].field4
;		probs[3,b]=chisq[b].field5
;		probs[4,b]=chisq[b].field6
;		probs[5,b]=chisq[b].field7
	;	probs[6,b]=chisq[b].field8
	;	probs[7,b]=chisq[b].field9
	;	probs[8,b]=chisq[b].field10
	;	probs[9,b]=chisq[b].field11
;		probs[10,b]=chisq[b].field12
;		probs[11,b]=chisq[b].field13
;	ENDFOR
;	stdevs=FLTARR(nlins)+0.06 ;for now!
;	result=SVDFIT(thisx,thisy,a=[0.],measure_errors=stdevs,chisq=chisq1,sigma=sigma1,yfit=yfit1)	
;	result2=SVDFIT(thisx,thisy,a=[0.,0.],measure_errors=stdevs,chisq=chisq2,sigma=sigma2,yfit=yfit2)	
;	oplot,thisx,yfit1
;	oplot,thisx,yfit2
;	
;	; find degrees freedom
;		thisline=WHERE(probs[0,*] EQ nlins-1)
;		; now go see on that line where the chisq falls;
;
;		; find degrees freedom
;		thisline=WHERE(df EQ nlins-1)
;		; now go see on that line where the chisq falls;
;
;		FOR i=0,10 DO BEGIN
;			; go through each line
;			IF probs[i+1,thisline] GT chisq1 THEN BEGIN
;				match=i   ; will give you a vector
;				GOTO,out
;			ENDIF ELSE BEGIN
;				match=11
;			ENDELSE
;		ENDFOR
;		out:
;		thisprob=probs[match,0]
;		IF match EQ 11 THEn thisprob2=probs[match,0] ELSE thisprob2=probs[match+1,0]
;		print,'thisprob = ',thisprob
;		;
;
;	
;	; get some statistics on this...
;	; record them to a file
;	newformat='(A10, I5,I3,I3,F14.3,1x,F8.3,1x,F8.3,1x,I3,F8.3,1x,F8.3,F11.3,F11.3,F11.3)'
;	;header = ' run  ayr   amo    ady   chisq1    slope intercept  sigma1  prob  df '   this is wrong, see real order below
;	header= ' runnum ayr amo ady chisq sigma1 prob df slope int minpkht maxpkht refpkht'
;	;;;; we are running an svdfit test assuming NO relationship between peak height and d13C. But, also trying a linear fit y=mx+b. So, if prob of 0 slope is low,
;	;;; look at slope and intercept of result2, which is an svdfit with a=[0.,0.]
;	ayr = data[0].field3
;	amo = data[0].field4
;	ady = data[0].field5
;	newfile='/projects/ch4c13/cals/internal_cyl/stats/linearity.081621.txt
;	newexist=FILE_TEST(newfile)
;	
;	IF newexist EQ 0 THEN BEGIN;
;
;		OPENW, u,newfile, /GET_LUN
;		PRINTF,u,header
;		PRINTF,u,format=newformat,  $
;		runnum, ayr, amo, ady, chisq1, sigma1,thisprob, nlins-1,result2[1], result2[0],minpkht,maxpkht,refpkht 
;		FREE_LUN,u
;	ENDIF ELSE BEGIN
;		OPENU, u,newfile, /GET_LUN,/APPEND
;		PRINTF,u,format=newformat,  $
;		runnum, ayr, amo, ady, chisq1, sigma1,thisprob, nlins-1,result2[1], result2[0],minpkht,maxpkht,refpkht
;		FREE_LUN,u
;	ENDELSE
;	
;	
;;	correction would be based on y=mx+b where y=result2[1] and b=result2[0]
;	;print,chisq;;
;
;	IF thisprob LE 0.10 THEN BEGIN
;		
;		
;		;y=mx+b
;		FOR l=0,ntot-1 DO linrefvals[l]=(result2[1]*peakht[l])+result2[0]
;		
;		lincorrectedvals=FLTARR(ntot)
;		FOR i=0,ntot-1 DO BEGIN
;		;for c13
;		lincorrectedvals[i]= ((linrefvals[i]/1000.0 +1.0)* $
;		(dcorvals[i]/1000.0 +1.0)-1.0)*1000.0
;		
;		ENDFOR			;
;
;		
;;	ENDIF ELSE BEGIN
;		lincorrectedvals=dcorvals
;	ENDELSE 
;	
;ENDIF ELSE BEGIN

	IF assumelinearity EQ 1 THEN BEGIN
		;use a 'stock' linearity from some time period. 

		;load the file of past runs. Should this be the same field as above?? 
		;newfile='/projects/ch4c13/cals/internal_cyl/stats/linearity.txt'
		;CCG_READ,file=newfile,linstats,skip=1
		;meanslope=MEAN(linstats.field9)
		;meanint=MEAN(linstats.field10)  ;but I don't think I want this
		;meanslope=-0.04   ; now using quasi mean of offline tests before May 2021
		;meanslope=-0.047   ; this is a better mean, based on RC tests
		; we could read a file of recent linearity corrections and take the average of the last few. ..
		;meanslope=-0.025
		meanslope=-0.019
		slopesdev=0.048
		
		;OR, use a monte carlo method based on a random distribution
		
		IF mcmethod EQ 1 THEN BEGIN 
			numit=100
			 ; this was my first try, which ended up in mcmethod019 and lin_dei
			;create random normal distribution
		
			;randomslopelist = (RANDOMN(seed, 10000)) ; (mean of zero, sdev of 1)
			;randomslopelist=randomslopelist*slopesdev
			;randomslopelist=randomslopelist+meanslope
			;meanslope=randomslopelist
			
			; now I'm choosing randomly from all of the lins
			
			meanslope=FLTARR(numit)
			newfile='/projects/ch4c13/cals/internal_cyl/stats/linearity.081621.txt'
			CCG_READ,file=newfile,linstats,skip=1
			keep=WHERE(linstats.field9 GT -1,nstats)
			linstats=linstats[keep]
			randomlist=randomu(seed,numit)
			thisindex=FIX(nstats*randomlist)
			
			FOR i=0,numit-1 DO meanslope[i]=linstats[thisindex[i]].field9
			

		ENDIF ELSE BEGIN
			numit=1
		ENDELSE
		
		linrefvals=FLTARR(numit,ntot)
		lincorrectedvals=FLTARR(numit,ntot)
		;y=mx+b
		
		FOR k=0,numit-1 DO BEGIN
			
			FOR l=0,ntot-1 DO linrefvals[k,l]=(mean(dcorvals[refpos])+(meanslope[k]*(meanrefpeakht-peakht[l])))
	
	
			FOR i=0,ntot-1 DO lincorrectedvals[k,i]= ((linrefvals[k,i]/1000.0 +1.0)* $
				(dcorvals[i]/1000.0 +1.0)-1.0)*1000.0
		
	
		ENDFOR
		IF mcmethod EQ 1 THEN BEGIN
			linmean=FLTARR(ntot)
			linsd=FLTARR(ntot)
			FOR t=0,ntot-1 DO BEGIN
				linmo=MOMENT(lincorrectedvals[*,t],sdev=sdev)
				linmean[t]=linmo[0]
				linsd[t]=sdev
		
			ENDFOR	
			lincorrectedvals=linmean
			;;; -----TAG
		ENDIF ELSE BEGIN
			lincorrectedvals=lincorrectedvals[0,*]	
			;----TAG??
		ENDELSE		
	ENDIF ELSE BEGIN
		lincorrectedvals=dcorvals  ; we have to have something, otherwise you'll have datafiles with 0 values
	ENDELSE

;ENDELSE
skipthiscorrection:

;need to correct to pdb value

lincorrvals=FLTARR(ntot)
corrvals=FLTARR(ntot)

FOR i=0,ntot-1 DO BEGIN
	
	corrvals[i]= ((ourrefvalue/1000.0 +1.0)* $
	(dcorvals[i]/1000.0 +1.0)-1.0)*1000.0
	
	IF correctforlinearity EQ 1 THEN BEGIN
		
		lincorrvals[i]= ((ourrefvalue/1000.0 +1.0)* $
		(lincorrectedvals[i]/1000.0 +1.0)-1.0)*1000.0
	ENDIF
ENDFOR			

IF (log_data EQ 1) THEN BEGIN
	
	OPENW, u, logfile, /GET_LUN,/APPEND
	PRINTF, u ,'corrvals'
	FOR z=0, ntot-1 DO PRINTF, u, corrvals[z]
	FREE_LUN, u
ENDIF


IF new17O EQ 1 THEN BEGIN
	newcorrvalsc13=FLTARR(ntot)
	newcorrvalso18=FLTARR(ntot)
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
	;*************
	FOR i=0,nlines-1 DO BEGIN

		;** BCA correction
		dfortyfivein=d45[i]
		dfortysixin=d46[i]
		
	        dthirteenCsam=dfortyfivein+ (((2*seventeenRvpdb) *(dfortyfivein- (lamda*dfortysixin)))/thirteenRvpdb)	
		deighteenOsam=(dfortysixin-(0.0021*dthirteenCsam))/0.99904
	
	
		newcorrvalsc13=(dthirteenCsam)
		newcorrvalso18=(deighteenOsam)
	
		
	ENDFOR
	corrvals=newcorrvalsc13

ENDIF



;--------------------YOU NOW HAVE CORRECTED isotopevalues!


; Now we start flaggin. 
flagarr=STRARR(ntot)
pairdiff=FLTARR(ntot)

;--------------------------------------------------------------------------------------
IF olddata EQ 0 THEN BEGIN
	;calculate pair averages and pair differences for all samples
	;also flag bad pairs and single flasks
	FOR i=0,ntot-1 DO BEGIN
	
		IF strategy[i] EQ 'pfp' THEN BEGIN
				pairdiff[i] = -999
				flagarr[i] = '...'	
		ENDIF ELSE BEGIN
	
			IF type[i] EQ 'SMP' or type[i] EQ 'SIL' THEN BEGIN
				CASE meth[i] OF
				'A' : BEGIN
					; added for pfps
					flaskpair =  WHERE(site EQ site[i] and $
						STRMID(id,0,4) EQ STRMID(id[i],0,4) AND $ 
						yr EQ yr[i] and mo EQ mo[i] and $
						dy EQ dy[i] and hr EQ hr[i] and $
						mn EQ mn[i] and meth EQ meth[i], nflaskpair)	
				
				END
				'H' : BEGIN
					pairdiff[i] = -999
					flagarr[i] = '...'
					GOTO, moveon	
				END
				
				ELSE: BEGIN
					flaskpair = WHERE(site EQ site[i] and $
						yr EQ yr[i] and mo EQ mo[i] and $
						dy EQ dy[i] and hr EQ hr[i] and $
						mn EQ mn[i] and meth EQ meth[i], nflaskpair)
				END
				ENDCASE
					
				IF nflaskpair EQ 1 THEN BEGIN
					pairdiff[i] = -999
					flagarr[i] = '..S'		
					
					IF site[i] EQ 'TST' OR site[i] EQ 'BLD' OR type[i] EQ 'SIL' THEN BEGIN	
						flagarr[flaskpair[0]] = '...' 
					ENDIF
				ENDIF
				
				IF nflaskpair GT 2 THEN BEGIN 
					;more than one pair of test flasks filled on the same date.
					IF site[i] EQ 'TST' OR site[i] EQ 'BLD' OR type[i] EQ 'SIL' THEN BEGIN
						flagarr[i]='...'			
					ENDIF ELSE BEGIN
						;;this should never happen. error??
						print, 'nflaskpair is greater than 2, but is not a pair flask. ERROR!'
						
						flagarr[i]='...'	
					ENDELSE
				ENDIF
				
				IF nflaskpair EQ 2 THEN BEGIN
					;a normal pair
					pairdiff[i] =corrvals[flaskpair[0]]-corrvals[flaskpair[1]]	
					;note that pairdiff always defined as first-second
					bonkerslimit=50.0
					IF ABS(pairdiff[i]) GT pdlimit THEN BEGIN 
						;adding logic so that if the pairdifference is enormous, hand flag the flier and keep the flask that is 'reasonable'
						IF ABS(pairdiff[i]) GT bonkerslimit THEN BEGIN
							; see which one has a raw value closer to the standard, meaning, which dcorvals value is closer to 0
								
								IF (ABS(dcorvals[flaskpair[0]]) LT ABS(dcorvals[flaskpair[0]])) THEN BEGIN
									IF (ABS(dcorvals[flaskpair[0]]) LT 20) THEN BEGIN
										flagarr[flaskpair[0]] = '..s' 
										print,'preserving data for ',corrvals[flaskpair[0]]
									ENDIF ELSE BEGIN
									flagarr[flaskpair[0]] = '!..' 
										print,'handflag being applied to ',corrvals[flaskpair[0]]
									ENDELSE
									flagarr[flaskpair[1]] = '!..'
									print,'handflag being applied to ',corrvals[flaskpair[1]]
									
									wait,1
								ENDIF ELSE BEGIN
									IF (ABS(dcorvals[flaskpair[1]]) LT 20) THEN BEGIN
										flagarr[flaskpair[1]] = '..s' 
										print,'preserving data for ',corrvals[flaskpair[1]]
									ENDIF ELSE BEGIN
										flagarr[flaskpair[1]] = '!..' 
										print,'handflag being applied to ',corrvals[flaskpair[0]]
									ENDELSE
									flagarr[flaskpair[0]] = '!..'
									
									print,'handflag being applied to ',corrvals[flaskpair[0]]
									
									wait,1
								
								ENDELSE
						
							;trapdiff=	
						ENDIF ELSE BEGIN
								
					
							IF (pairdiff[i] GT 0) THEN BEGIN
								flagarr[flaskpair[0]] = '+..' 
								flagarr[flaskpair[1]] = '-..'
							ENDIF ELSE BEGIN
								flagarr[flaskpair[0]] = '-..' 
								flagarr[flaskpair[1]] = '+..'
							ENDELSE
						ENDELSE
					ENDIF ELSE BEGIN
						flagarr[i] = '...' 
					ENDELSE
					;unflag TST or BLD or SIL flasks		
					
					IF site[i] EQ 'TST' OR site[i] EQ 'BLD' OR type[i] EQ 'SIL' THEN BEGIN	
						flagarr[flaskpair[0]] = '...' 
						flagarr[flaskpair[1]] = '...'
					ENDIF
				ENDIF
			
			ENDIF ELSE BEGIN
			flagarr[i] = '...' 
				
			ENDELSE
		ENDELSE

	moveon:
	ENDFOR	

	;if linearity is high, and refs are quite different than samples, go ahead and flag
	IF correctforlinearity EQ 1 THEN BEGIN                                                                       

		;IF linvalshere[0] NE -1 THEN BEGIN  ; for now. with 'default' lin can do otherwise
		;	print,'linvalshere'
		;	IF thisprob GE 0.5 THEN BEGIN
		;		print,'slope = ',result2[1]
		;		IF ABS(result2[1]) GT 0.02 THEN BEGIN
		;		
		;				FOR a=0,ntot-1 DO BEGIN
		;				peakhtdiff[a]=peakht[a]-meanrefpeakht
		;				print,peakhtdiff[a]
		;				IF ABS(peakhtdiff[a]) GT 2.5 THEN BEGIN
		;					; this added 4/5/2021 to catch linearity problems
		;					 flagarr[a]='M'+STRMID(flagarr[a],1,2)
		;					 print,flagarr[a]
		;				ENDIF
		;				print,peakhtdiff[a]
		;			
		;			ENDFOR
		;		ENDIF
		;	ENDIF
		;ENDIF ELSE BEGIN
			
	
		;ENDELSE
	ENDIF

	;; I don't have peak heights for the old data, so take this out
	;create flag of peak heights
	pkhtflag=STRARR(ntot)
	pkhtflag[*]='.'
	IF sp EQ 'ch4c13' THEN peakknob=2 ELSE peakknob=1    ; this is to unflag some dD data, add flags based on peak height difference . 1/26/22	
	FOR x=0,ntot-1 DO BEGIN
		IF peakht[x] LT peakknob THEN pkhtflag[x]='P'
		IF peakht[x] GT 18 THEN pkhtflag[x]='Y'
		
	ENDFOR
	
	IF flagpeakhtdiffs EQ 1 THEN BEGIN
	;print, 'adding first position flag to peakhtdiffs REGARDLESS of analysis date change (sly test, Nov 2024)'

	peakdiffknob=1.0
	CCG_DATE2DEC,yr=data[0].field3, mo=data[0].field4, dy=data[0].field5,dec=dec
		IF dec GT 2021.0 THEN BEGIN
		;;;;if statement above commented out for sly NOV 2024 changes 	 
		
		FOR a=0,ntot-1 DO BEGIN
			peakhtdiff[a]=peakht[a]-meanrefpeakht
			print,peakhtdiff[a]
			IF ABS(peakhtdiff[a]) GT peakdiffknob THEN BEGIN
				; this added 4/5/2021 to catch linearity problems
				print, 'adding Z flags'
				 flagarr[a]='Z'+STRMID(flagarr[a],1,2)
			 print,flagarr[a]
			 
			 ;--TAG
			ENDIF
			print,peakhtdiff[a]
		ENDFOR
		ENDIF	
	ENDIF
	
	IF correctforlinearity EQ 1 THEN BEGIN
	FOR a=0, ntot-1 DO BEGIN
		; add a third pos info flag if peak height is different than std? 
		peakhtdiff[a]=peakht[a]-meanrefpeakht	
		flagarr[a]=STRMID(flagarr[a],0,2)+'r'
		IF ABS(peakhtdiff[a]) GT 2.5 THEN BEGIN
			; this added 4/5/2021 to catch linearity problems
			flagarr[a]=STRMID(flagarr[a],0,2)+'R'
			 print,flagarr[a]
			 ;---TAG
		ENDIF
	ENDFOR
	ENDIF

	; apply A flags
	IF nbadref GE 1 THEN BEGIN
		IF nbadref GT 1 THEN BEGIN
			print,'more than one set of bad refs (nbadref GT 1)'
			FOR i=0, ntot-1 DO flagarr[i]= 'A' + STRMID(flagarr[i],1,2)   ;-TAG
		ENDIF ELSE BEGIN  ;nbadref=1
			IF ngroups GT 2 THEN BEGIN
				IF badref[0] EQ 1 THEN BEGIN
					; do nothing - you already drift corrected from beginning to end, so middle set is ignored
				ENDIF ELSE BEGIN
					IF (badref[0] EQ 0) THEN BEGIN ; ;flag just first half
						firstsam=samsets[0,0]-samsets[1,0]+1
						numsam = samsets[1,0] ; last sample position to flag
						FOR i=firstsam, firstsam+numsam-1 DO flagarr[i] = 'A' + STRMID(flagarr[i],1,2)
					ENDIF ELSE BEGIN 
						FOR k=2,ngroups DO BEGIN
							IF badref EQ k THEN BEGIN
								firstsam=samsets[0,k-1]-samsets[1,k-1]+1
								numsam=samsets[1,k-1]
								FOR i = firstsam, firstsam+numsam-1 DO BEGIN
									flagarr[i] = 'A' + STRMID(flagarr[i],1,2)
								ENDFOR
								IF ngroups GT (k+1) THEN BEGIN 
									;if more than 3 sets of refs, have to flag before and after your bad refs.
									;this is a bad "second middle set" that is not handled by the more specific drift
									;correction get-around of a normal middle set.
									thisfirstsam=FIX(samsets[0,k]-samsets[1,k]+1)
									thisnumsam=FIX(samsets[1,k])
									FOR g = thisfirstsam,(thisnumsam + thisfirstsam - 1) DO BEGIN
										flagarr[g] = 'A' + STRMID(flagarr[g],1,2)
									ENDFOR
								ENDIF
							ENDIF
						ENDFOR
					ENDELSE	
				ENDELSE
			ENDIF ELSE BEGIN ;(only 2 nrefs)
				FOR i=0, ntot-1 DO flagarr[i] = 'A' + STRMID(flagarr[i],1,2)
			ENDELSE
		ENDELSE
	ENDIF

	;*** assign E flags (E for extraction) to flasks and tanks run between 11/18/05 and 4/30/06
	;*** New manifold (maybe helium back fill) was causing noisy, ugly data that we didn't pick up with the diagnostics
	;sre added, 6/20/06

	IF sp EQ 'ch4c13' THEN BEGIN
		CCG_DATE2DEC,yr=data[0].field3, mo=data[0].field4, dy=data[0].field5,dec=dec
		IF dec GT 2005.8808 AND dec LT 2006.3274 THEN BEGIN
		 	FOR i=0, ntot-1 DO BEGIN
				flagarr[i]='E'+STRMID(flagarr[i],1,2)   ;-TAG
			ENDFOR
		ENDIF
		;IF dec GT 2008.4 AND dec LT 2009.5 THEN BEGIN
		; 	FOR i=0, ntot-1 DO BEGIN
		;		flagarr[i]='!'+STRMID(flagarr[i],1,2)
		;	ENDFOR
		;ENDIF
	ENDIF

	
	FOR d=0,ntot-1 DO BEGIN
		IF driftflagarr[d] NE '.' THEN BEGIN
			flagarr[d]=driftflagarr[d]+STRMID(flagarr[d],1,2)   ;TAG
		ENDIF
	ENDFOR

	FOR d=0,ntot-1 DO BEGIN
		IF pkhtflag[d] NE '.' THEN BEGIN
			flagarr[d]=pkhtflag[d]+STRMID(flagarr[d],1,2)  ;TAG
		ENDIF
	ENDFOR
	
	IF correctforlinearity EQ 1 THEN BEGIN
		linflagarr=flagarr  ;TAG
		;; linearity flags
		IF linvalshere[0] NE -1 THEN BEGIN
			;correction would be based on y=mx+b where m=result2[1] and b=result2[1]
	
			;IF thisprob GT 0 THEN STRMID(linflagarr,1,1)='+' ELSE STRMID(linflagarr,1,1)='-' 
			
			;IF ABS(result2[1]) GT 0.02 THEN  STRMID(linflagarr,2,1)='2'
			;IF ABS(result2[1]) GT 0.03 THEN  STRMID(linflagarr,2,1)='3'
			;IF ABS(result2[1]) GT 0.04 THEN  STRMID(linflagarr,2,1)='4'
			;IF ABS(result2[1]) GT 0.05 THEN  STRMID(linflagarr,2,1)='5'
			;IF ABS(result2[1]) GT 0.06 THEN  STRMID(linflagarr,2,1)='6' 
			;IF ABS(result2[1]) GT 0.07 THEN  STRMID(linflagarr,2,1)='7'
			;IF ABS(result2[1]) GT 0.08 THEN  STRMID(linflagarr,2,1)='8'
			;IF ABS(result2[1]) GT 0.09 THEN  STRMID(linflagarr,2,1)='9';
	
		ENDIF	
	ENDIF
ENDIF ELSE BEGIN   ;old data flagging

	; for flask data, look up flags - there are weird ones that John applied that should be preserved.
	; for standards, use some logic to flag for bad refs.
	; peak data not available
	; drift??
	flagarr[*]='...'
	FOR i=0,nsams-1 DO BEGIN
		CCG_DATE2DEC,yr=data[sampos[i]].field3,mo=data[sampos[i]].field4,dy=data[sampos[i]].field5,dec=dec
	
		CCG_FLASK, evn=enum[sampos[i]],sp=sp,dbdata
		sizedb=SIZE(dbdata)
		IF sizedb[0] NE 0 THEN BEGIN
			ndb=N_ELEMENTS(dbdata)
			
			right=WHERE(dbdata.adate LE dec+0.0015 and $
			dbdata.adate GE dec-0.0015)
			nright=N_ELEMENTS(right)
			IF right[0] EQ -1 THEN BEGIN ;
				print, 'cannot find old data'
			
			ENDIF
			IF nright EQ 1 THEN flagarr[sampos[i]]=dbdata[right].flag
			IF nright EQ 2 THEN flagarr[sampos[i]]=dbdata[right[0]].flag   ; just guess
			IF nright GT 2 THEN stop  ; wtf
			
			;;TAG
	
		ENDIF	
		
	ENDFOR	
	IF nbadref GE 1 THEN BEGIN
		FOR i=0,ntot-1 DO BEGIN
		 	IF i LT anchorpt[1] THEN BEGIN
				IF refgroupsd[0] GT reflimit THEN flagarr[i]='A..'    ;TAG
				IF refgroupsd[1] GT reflimit THEN flagarr[i]='A..'
			ENDIF ELSE BEGIN
				IF refgroupsd[1] GT reflimit THEN flagarr[i]='A..' 
				IF refgroupsd[2] GT reflimit THEN flagarr[i]='A..' 
			ENDELSE
		ENDFOR	

	ENDIF


ENDELSE

;;;;;
; this code used to be below, with other std stuff.
; but to apply 2nd pos flags, need to know trap value
; Drift corrected averages and standard deviations of trap tank 

IF (trappos[0] NE -1) THEN BEGIN

	traparr = REPLICATE ({	avedelta:0.0,	$
			sddelta:0.0,	$
			averaw:0.0,	$
			sdraw:0.0,	$
			sd18O:0.0},	$
			1)

	goodtraps=WHERE(STRMID(flagarr[trappos],0,1) NE ('P') $
		AND (STRMID(flagarr[trappos],0,1) NE 'D'))
	lasttrap = MAX(trappos[goodtraps])
	
		
		;this will cut out P and D flags from trap calculations, but
		;allow for stats on A and other flags
	ngoodtraps=N_ELEMENTS(goodtraps)
	IF ngoodtraps EQ 1 THEN BEGIN
		traparr.averaw=rawval[lasttrap]
		traparr.sdraw=-99
		traparr.avedelta=corrvals[lasttrap]
		traparr.sddelta=-99
		traparr.sd18O=-99
	ENDIF
	;IF ntrap EQ 2 THEN BEGIN
	;	traparr.averaw=rawval[lasttrap]
	;	traparr.sdraw=-99
	;	traparr.avedelta=corrvals[lasttrap]
	;	traparr.sddelta=-99
	;	traparr.sd18O=-99
	;ENDIF
	;IF ntrap GT 2 THEN BEGIN
	;	rawtraparr=FLTARR(ntrap-1)
	;	trapvalarr=FLTARR(ntrap-1)
	;	trap18Oarr=FLTARR(ntrap-1)
	;	FOR r=0,ntrap-2 DO BEGIN
	;		rawtraparr[r]=rawval[trappos[ntrap-1-r]]
	;		trapvalarr[r]=corrvals[trappos[ntrap-1-r]]
	;		trap18Oarr[r]=oval[trappos[ntrap-1-r]]
	;	ENDFOR
		;fixed this 1/15/15 - used to assume traps all continuous; not necessarily so
	
	If ngoodtraps GT 1 THEN BEGIN
	rawtraparr=FLTARR(ngoodtraps)
		trapvalarr=FLTARR(ngoodtraps)
		trap18Oarr=FLTARR(ngoodtraps)
		FOR r=0,ngoodtraps-1 DO BEGIN
			rawtraparr[r]=rawval[trappos[goodtraps[r]]]
			trapvalarr[r]=corrvals[trappos[goodtraps[r]]]
			trap18Oarr[r]=oval[trappos[goodtraps[r]]]
		ENDFOR
		
		rawtrapresult=MOMENT(rawtraparr,SDEV=rawtrapsd)
		traparr[0].averaw=rawtrapresult[0]
		traparr[0].sdraw=rawtrapsd
		trapvalresult=MOMENT(trapvalarr,SDEV=trapdeltastdev)
		traparr[0].avedelta=trapvalresult[0]
		traparr[0].sddelta=trapdeltastdev
		trap18Ovalresult=MOMENT(trap18Oarr,SDEV=trap18Ostdev)
		traparr[0].sd18O=trap18Ostdev
	
	ENDIF
;stop
	;secpos flags and unc went live 10/11/11
	IF secposflags EQ 1 THEN BEGIN
		IF sp EQ 'ch4c13' THEN BEGIN
			ourtrapfile='/projects/co2c13/flask/sb/trap.ch4c13'
			;changed from -47.12 to -47.11
			trapknob =0.24  ;3  ;for real! test at 0.36=unc4   ;first test: 0.3
			trapvarknob=0.20 ;for real. test at 0.24=unc4   ;first test:0.2
			trap18Oknob=0.3 ;for real. test at 0.24=unc4   ;first test:0.2
		ENDIF ELSE BEGIN
			ourtrapfile='/projects/co2c13/flask/sb/trap.ch4h2'
			trapknob =6
			trapvarknob=4
		ENDELSE
		
		CCG_READ, file=ourtrapfile, /nomessages,truetrap
	
		thistrap=WHERE(enum[trappos[0]] EQ truetrap.field1)

		IF thistrap NE -1 THEN BEGIN
			wehaveatrapvalue=1
			truetrapval=truetrap[thistrap].field5
			
			truetraphigh=truetrapval+trapknob
			truetraplow=truetrapval-trapknob
			;truetrapveryhigh=truetrapval+(5*trapknob) 
			;truetrapverylow=truetrapval-(5*trapknob)    
			badtrapflag=0	
			
			IF traparr.avedelta GT truetraphigh THEN badtrapflag=3  ;1
			IF traparr.avedelta LT truetraplow THEN badtrapflag=4   ;2
			;IF traparr.avedelta GT truetrapveryhigh THEN badtrapflag=3
			;IF traparr.avedelta LT truetrapverylow THEN badtrapflag=4
			
			IF badtrapflag GE 1 THEN BEGIN
				CASE badtrapflag OF
					;1: FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,2)+'H'
					;2: FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,2)+'L'
					3: FOR t=0,ntot-1 DO flagarr[t] = 'H'+STRMID(flagarr[t],1,2)
					4: FOR t=0,ntot-1 DO flagarr[t] = 'L'+STRMID(flagarr[t],1,2)
					
				
				;  for now. ...
				;	1: FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,1)+'H'+STRMID(flagarr[t],2,1)
				;	2: FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,1)+'L'+STRMID(flagarr[t],2,1)
				ENDCASE
			 ENDIF
	;stop
 	;now figure out if our value for a trap has high variance
			IF traparr.sddelta GT trapvarknob THEN BEGIN
				FOR t=0,ntot-1 DO flagarr[t] = 'T'+STRMID(flagarr[t],1,2)	
			ENDIF ELSE BEGIN
			
				;IF traparr.sddelta LT -90 THEN BEGIN
				;	FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,2)+'t'
				;	FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,1)+'t'+STRMID(flagarr[t],2,1)
				;
				;ENDIF
			ENDELSE
			
			;IF traparr.sd18O GT trap18Oknob THEN BEGIN
			;	FOR t=0,ntot-1 DO flagarr[t] = 'O'+STRMID(flagarr[t],1,2)
			;ENDIF ELSE BEGIN
			
				;IF traparr.sddelta LT -90 THEN BEGIN
				;	FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,2)+'t'
				;	FOR t=0,ntot-1 DO flagarr[t] = STRMID(flagarr[t],0,1)+'t'+STRMID(flagarr[t],2,1)
				;
				;ENDIF
			;ENDELSE
			
		ENDIF ELSE BEGIN
			wehaveatrapvalue=0
			IF secposflags EQ 1 THEN BEGIN
			PRINT, 'No true trap data to compare this trap to. '
				
				FOR t=0,ntot-1 DO BEGIN
				
					IF sp NE 'ch4h2' THEN flagarr[t] = STRMID(flagarr[t],0,2)+'o'
				ENDFOR
			ENDIF
		ENDELSE
	ENDIF

	IF adjusttotrap EQ 1 THEN BEGIN
		; make sure you have a trap value to compare to
		; look at traparr
		; find difference betw traparr and true trap.
		; apply correction to data
		; record correction somewhere.
		IF wehaveatrapvalue EQ 1 THEN BEGIN
			trapadjust=truetrapval-traparr.avedelta
		
			FOR i=0,ntot-1 DO BEGIN
				;for c13
				corrvals[i]= corrvals[i]+trapadjust
			
			ENDFOR			
	
			trapadjustfile='/home/ccg/sil/ch4c13/trapadjustfile.txt
			; extract info re oxygen values
			trfileexist = FILE_TEST(trapadjustfile)
		
			trformat='(A8,F8.3)'
			trheader='runnum trapadjustval
			IF trfileexist EQ 0 THEN BEGIN
				OPENW, u, trapadjustfile, /GET_LUN 
				
				PRINTF, u, FORMAT =trformat,runnum, trapadjust
				
				FREE_LUN,u
			ENDIF ELSE BEGIN
				OPENU, u, trapadjustfile, /APPEND, /GET_LUN
				PRINTF, u, FORMAT =trformat,runnum,trapadjust
				
				FREE_LUN,u
			ENDELSE
	
	
		ENDIF
	ENDIF	
ENDIF ELSE BEGIN
	IF secposflags EQ 1 THEN BEGIN
		FOR t=0,ntot-1 DO BEGIN

			flagarr[t] = STRMID(flagarr[t],0,2)+'o'
			PRINT, 'no trap tank . ..'
		ENDFOR
	ENDIF
ENDELSE	




 ; oxygen data flagging

;  *************** code goes here
;mino=min(oval)
;maxo=max(oval)
;momento=MOMENT(oval,sdev=sdev)
;meano=momento[0]
;stdevo=sdev
;stderro=sdev/(ntot-1)
;IF trappos[0] NE -1 THEN o18trapsd=traparr.sd18O ELSE o18trapsd=-0.09;

;ovaluefile='/home/ccg/sil/ch4c13/oxygendatafile.txt
; extract info re oxygen values
;	ofileexist = FILE_TEST(ovaluefile)
;	
;	oformat='(A8,6(F8.3))'
;	oheader='runnum mino maxo meano stdevo stderro traparr.sd18'
	;IF ofileexist EQ 0 THEN BEGIN
		;OPENW, u, ovaluefile, /APPEND, /GET_LUN 
		;PRINTF,u,oheader
		;PRINTF, u, FORMAT =oformat,runnum,mino,maxo,meano,stdevo,stderro,o18trapsd
		
	;	FREE_LUN,u
	;ENDIF ELSE BEGIN
	;	OPENU, u, ovaluefile, /APPEND, /GET_LUN
	;	PRINTF, u, FORMAT = oformat, runnum,mino,maxo,meano,stdevo,stderro,o18trapsd
	;	FREE_LUN,u
	;ENDELSE

IF flagitall EQ 1 THEN BEGIN
	IF autoflag NE 1 THEN BEGIN
	
		areyasure=DIALOG_MESSAGE ('YOU ARE ! FLAGGING ALL SAMPLES!! IS THIS WHAT YOU WANT TO DO?', title = 'Continue',/Question, /cancel)
			IF areyasure EQ 'Cancel' THEN goto,bailout
			IF areyasure EQ 'No' THEN goto,bailout
	ENDIF	

		FOR i=0, ntot-1 DO BEGIN	
			flagarr[i]='!'+STRMID(flagarr[i],1,2)
			IF correctforlinearity EQ 1 THEN linflagarr[i]='!'+STRMID(flagarr[i],1,2)
		ENDFOR
	
ENDIF



;;; check for old flags. Useful for reprocessing. Taken from sil_proc_co2iso

FOR i = 0, ntot-1 DO BEGIN
	IF type[i] EQ 'SMP' THEN BEGIN
		
		CCG_FLASK,site=site[i],id=id[i],sp=sp,evn=enum[i],flaskdata
		sizeflask=SIZE(flaskdata)
		IF sizeflask[0] EQ 0 THEN goto, skipthischeck	
		goodflag=WHERE(id[i] EQ flaskdata.id AND $
			data[i].field3 EQ flaskdata.ayr AND $
			data[i].field4 EQ flaskdata.amo AND $
			data[i].field5 EQ flaskdata.ady AND $
			data[i].field6 EQ flaskdata.ahr AND $
			inst EQ flaskdata.inst AND $
			data[i].field7 EQ flaskdata.amn,ngood)  
		 IF ngood EQ 1 THEN BEGIN	
		 	oldflagarr=flaskdata[goodflag]
		
			fpos=STRMID(oldflagarr.flag,0,1)		
			thrpos=STRMID(oldflagarr.flag,2,1)
			print, 'oldflag = ',oldflagarr.flag
			print,'new flag = ',flagarr[i]
	
			IF fpos NE '.' THEN BEGIN
				;look at 1st pos flags for special flags. ..
				CASE fpos OF 
					'H': BEGIN 
					flagarr[i]='H.'+STRMID(flagarr[i],2,1)
					
					END
					'L': BEGIN 
					flagarr[i]='L.'+STRMID(flagarr[i],2,1)
					END
					'T': BEGIN 
					flagarr[i]='T.'+STRMID(flagarr[i],2,1)
					END
					'N': BEGIN
					;known sampling problem
					flagarr[i]='N.'+STRMID(flagarr[i],2,1)
					END
					'!': BEGIN
					flagarr[i]='!.'+STRMID(flagarr[i],2,1)
					END
					'B': BEGIN
					 flagarr[i]='B.'+STRMID(flagarr[i],2,1)
					END
					ELSE: BEGIN
					END
				ENDCASE
			ENDIF ; fpos not '.' 
	
		;	 
		; IF thrpos NE '.' THEN BEGIN
		;	;CASE thrpos OF 
		;	;'L':  BEGIN	
		;	;;"linked" 0.5 L flasks, all were eventually determined to be bad
		;	;	finalvals[i].flagc13 = '!.L'
		;	END
		;	'I': BEGIN
		;	;indicates that an aliquot was taken to be analyzed at another lab
		;		finalvals[i].flagc13 = STRMID(finalvals[i].flagc13,0,2)+'I'
		;	END
		;	'i': BEGIN
		;	; same as I, but this flag displaced a previous flag in this field.
		;		finalvals[i].flagc13 = STRMID(finalvals[i].flagc13,0,2)+'i'
		;	END	
		;	ELSE: BEGIN
		;		finalvals[i].flagc13 =	finalvals[i].flagc13 
		;	END		
		;	ENDCASE
		;ENDIF	 
		ENDIF ELSE BEGIN
		IF ngood EQ 2 THEN BEGIN
			finalvals[i].flagc13 =  '!.'+STRMID(finalvals[i].flagc13,2,1)    ;; for now!!
		
		ENDIF
	
		ENDELSE
		skipthischeck:
	ENDIF
ENDFOR ;loop to flag-check


;;;-- end of check old flags bit


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
			value:0.0,	$
			unc:0.0,	$
			flag:'',	$
			inst:'',	$
			ayr:0,		$
			amo:0,		$
			ady:0,		$
			ahr:0,		$
			amn:0,		$
			asc:0,		$
			run:'',		$
			num:0,		$
			rawval:0.0,	$
			ref:'',		$
			sp:''},	$
			ntot)
						
FOR i = 0, ntot-1 DO BEGIN 
	farr[i].enum   = enum[i]
	farr[i].site =  site[i]  
	farr[i].yr = yr[i]
	farr[i].mo = mo[i]  
	farr[i].dy = dy[i]
	farr[i].hr = hr[i]
	farr[i].mn = mn[i]
	farr[i].id = id[i]  
	farr[i].meth = meth[i]   
	farr[i].ayr = data[i].field3
	farr[i].amo = data[i].field4
	farr[i].ady = data[i].field5
	farr[i].ahr = data[i].field6
	farr[i].amn = data[i].field7
	farr[i].asc = data[i].field8
	farr[i].value = corrvals[i]
	farr[i].flag = flagarr[i]
	farr[i].run = runnum
	farr[i].inst = inst
	farr[i].rawval = rawval[i]
	farr[i].ref = ref
	farr[i].num = num[i]
	farr[i].sp=sp
ENDFOR



 ;IF flagitall EQ 1 THEN flagarr[i]='!..'

;****************** THIS IS WHERE I START MAKING CHANGES, 1.11.11 *****************8
;  data now handled in the following order:
;			calculate avgs for refs and trap (trap now above with flags)
;			trap data
;			 -- uncertainty calculated
;			 trapstat files
;			 sil flasks
;			 tank data
;			 ref data
;			 refstat files
;			 samples


;first deal with trap, to get uncertainty figured out


; ----- COLLECT ALL OF THE TANK FINAL VALUES AND PUT INTO PROPER ARRAYS --------------
; Drift corrected averages and standard deviation of reference tank, stored in refarr

refarr = REPLICATE ({	avedelta:0.0,	$
			sddelta:0.0,	$
			averaw:0.0,	$
			sdraw:0.0},	$
			ngroups)

refposarr=farr[refpos]

FOR j=0,ngroups-1 DO BEGIN
	refarr[j].averaw=refgroupave[j]
	refarr[j].sdraw=refgroupsd[j]
	
	IF olddata EQ 0 THEN BEGIN
	;now to get corrected avgs and stdevs of corrected values
	last1=refsets[j]
	
	IF cluster[j] EQ 1 THEN BEGIN
		refarr[j].avedelta=farr[last1].value
		refarr[j].sddelta=-99
	ENDIF
	IF cluster[j] EQ 2 THEN BEGIN
		refarr[j].avedelta=farr[last1].value
		refarr[j].sddelta=-99
	
	ENDIF
	IF cluster[j] GT 2 THEN BEGIN
		ncluster=cluster[j]
		deltaarr=fltarr(ncluster-1)
		FOR r=0,ncluster-2 DO BEGIN
			deltaarr[r]=farr[last1-ncluster+2+r].value
		ENDFOR
	
		refvalresult=MOMENT(deltaarr,SDEV=deltastdev)
		refarr[j].avedelta=refvalresult[0]
		refarr[j].sddelta=deltastdev
	ENDIF
	ENDIF ELSE BEGIN
		thisset=WHERE(weirdrefgroups EQ j+1,nweird)
		
		getcorrrefdata=farr[refpos[thisset]].value

		getcorr=MOMENT(getcorrrefdata,sdev=sdev)
		refarr[j].avedelta=getcorr[0]
		refarr[j].sddelta=sdev
		
	ENDELSE
ENDFOR

;GOTO,skipthisfornow
; ----- WRITE TO PERFORMANCE FILE FOR TRAP TANK ---------------------------------
; this happens whether or not printtanks=1

IF (trappos[0] NE -1) THEN BEGIN
	trap = enum[trappos[0]]
	
	trapformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),F10.3,1X,F10.3,A4,1X,A9)'
	trapfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/trap'+trap+'.'+sp+'.' + inst
	;testtrapfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/testtrap'+trap+'.'+sp+'.' + inst
	
	trapfileexist = FILE_TEST(trapfile)
	

	IF trapfileexist EQ 0 THEN BEGIN
		OPENW, u, trapfile, /APPEND, /GET_LUN 
	
	
		FOR i = 0, ntrap-1 DO PRINTF, u, FORMAT = trapformat, farr[trappos[i]].id, $	
			farr[trappos[i]].yr, farr[trappos[i]].mo, farr[trappos[i]].dy, $
			farr[trappos[i]].run, farr[trappos[i]].inst, farr[trappos[i]].ayr, $
			farr[trappos[i]].amo, farr[trappos[i]].ady, farr[trappos[i]].ahr, $
			farr[trappos[i]].amn, farr[trappos[i]].asc, farr[trappos[i]].rawval, $
			farr[trappos[i]].value, farr[trappos[i]].flag,farr[trappos[i]].ref

	ENDIF ELSE BEGIN
		CCG_READ, file = trapfile, /nomessages, trapfilearr
		exists = WHERE (trapfilearr.field5 EQ farr[trappos[0]].run,complement=othervals) 
	
		IF (othervals[0] NE -1) THEN BEGIN 
			othervalarr=trapfilearr[othervals]
			nother=N_ELEMENTS(othervalarr)
			
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
		
		IF exists[0] EQ -1 THEN BEGIN
			OPENU, u, trapfile, /APPEND, /GET_LUN
			FOR i = 0, ntrap-1 DO PRINTF, u, FORMAT = trapformat, farr[trappos[i]].id, $
				farr[trappos[i]].yr, farr[trappos[i]].mo, farr[trappos[i]].dy, $
				farr[trappos[i]].run, farr[trappos[i]].inst, farr[trappos[i]].ayr, $
				farr[trappos[i]].amo, farr[trappos[i]].ady, farr[trappos[i]].ahr, $
				farr[trappos[i]].amn, farr[trappos[i]].asc, farr[trappos[i]].rawval, $
				farr[trappos[i]].value, farr[trappos[i]].flag, $
				farr[trappos[i]].ref
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
					rawval:0.0,	$
					value:0.0,	$
					flag:'',	$
					ref:''},	$
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
					newtraparr[v].rawval=farr[trappos[v]].rawval
					newtraparr[v].value=farr[trappos[v]].value
					newtraparr[v].flag=farr[trappos[v]].flag
					newtraparr[v].ref=farr[trappos[v]].ref
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
					newtraparr[h+ntrap].rawval=othervalarr[h].field13
					newtraparr[h+ntrap].value=othervalarr[h].field14
					newtraparr[h+ntrap].flag= othervalarr[h].field15
					newtraparr[h+ntrap].ref=othervalarr[h].field16
					
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
		;;;	IF printtanks EQ 1 THEN BEGIN
			OPENW, u, trapfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=trapformat,newtraparr[a]
			FREE_LUN, u
		;;;	ENDIF
		
		ENDELSE
	ENDELSE
	FREE_LUN, u
	CCG_SREAD, file=trapfile, trapdata, /nomessages
	ntrapdata=N_ELEMENTS(trapdata)
	adate = DBLARR(1,ntrapdata)
	FOR b=0, ntrapdata-1 DO BEGIN
		CCG_DATE2DEC, YR=STRMID(trapdata[b],34,4), $
			MO=STRMID(trapdata[b],39,2), DY=STRMID(trapdata[b],42,2), $
			HR=STRMID(trapdata[b],45,2), MN=STRMID(trapdata[b],48,2), DEC=dec
		adate[b]=dec
	ENDFOR
	trapdata=trapdata[SORT(adate)]
	OPENU, u, trapfile, /GET_LUN
	FOR a=0, ntrapdata-1 DO PRINTF, u, trapdata[a]
	FREE_LUN, u




	;************* UNCERTAINTY CODE GOES HERE!************** 

	IF uncertainty EQ 1 THEN BEGIN
	;re-read trap file (wasn't getting this run and it took two tries

	CCG_READ, file=trapfile,trapfilearr
	;--- get data from just this instrument
	thisinst=WHERE(trapfilearr.field6 EQ inst)
	trapfilearr=trapfilearr[thisinst]
	nkeep=N_ELEMENTS(trapfilearr)
	;open file where you print trap data
	uncertaintyfile='/home/ccg/sil/tempfiles/uncertaintytemp.'+sp
	uncformat =  '(A9,I5.1,2(I3.1),I9,A4,I5.1,5(I3.1),F10.3,1X,F10.3,A4,1X,A9)'
	
		OPENW, u, uncertaintyfile,  /GET_LUN
		FOR m=1,nkeep-1 DO BEGIN   ;throw out first line of each run	
			IF trapfilearr[m].field5 EQ trapfilearr[m-1].field5 THEN BEGIN
				;keep this data
				
				PRINTF, u, format=uncformat,trapfilearr[m].field1,$
					trapfilearr[m].field2, $
					trapfilearr[m].field3, $
					trapfilearr[m].field4, $
					trapfilearr[m].field5, $
					trapfilearr[m].field6, $
					trapfilearr[m].field7, $
					FIX(trapfilearr[m].field8), $
					FIX(trapfilearr[m].field9), $
					FIX(trapfilearr[m].field10), $
					FIX(trapfilearr[m].field11), $
					FIX(trapfilearr[m].field12), $
					trapfilearr[m].field13, $
					trapfilearr[m].field14, $
					trapfilearr[m].field15, $
					trapfilearr[m].field16
	
			ENDIF
		ENDFOR	
		FREE_LUN, u	

		CCG_READ, file = uncertaintyfile, /nomessages, keeptrapdata ; comment out for new file

			runnumber=FIX(runnum)
			thisrun=WHERE(FIX(keeptrapdata.field5) EQ runnumber)
			;stop   ;
			IF thisrun[0] NE -1 THEN BEGIN
				thisrunarr=keeptrapdata[thisrun]
				nthis=N_ELEMENTS(thisrunarr)
				
				otherruns=WHERE(FIX(keeptrapdata.field5) LT runnumber)
				IF otherruns[0] NE -1 THEN BEGIN
					otherrunarr=keeptrapdata[otherruns]
					cotherrunarr=otherrunarr
					cmaxprevrun=MAX(FIX(cotherrunarr.field5))
					
				ENDIF	
	
				cuarr=FLTARR(100)
				crunnumarr=INTARR(100)		
				
				n=0
				c=0
						
				FOR h=0,nthis-1 DO BEGIN  ;no matter what 2nd pos flag is
				; also applies if this is first run of trap
					cuarr[n]=thisrunarr[h].field14
					crunnumarr[n]=thisrunarr[h].field5
					
					n=n+1
					
					
				ENDFOR
				
				;c data
				IF otherruns[0] NE -1 THEN BEGIN			
					REPEAT BEGIN
					;look at the data from the last run before this run
					;if it's not flagged, add it to list
					;increment counter
					;if it's not good, go to next one
					;don't increment counter c (c counts runs)
					; n counts position in cuarr, which will eventually have ~40 data pts
			
					clastrun = WHERE(keeptrapdata.field5 EQ cmaxprevrun,ncprevrun)
					clastrundata=keeptrapdata[clastrun]
						IF clastrundata[0].field15 EQ '...' THEN BEGIN
							FOR m=0,ncprevrun-1 DO BEGIN
								cuarr[n]=clastrundata[m].field14
								crunnumarr[n]=clastrundata[m].field5
								n=n+1
							ENDFOR
							
							c=c+1
						ENDIF ELSE BEGIN
							c=c
						ENDELSE
						;create new array with all runs less than this runnumber
						cotherruns=WHERE(FIX(cotherrunarr.field5) LT cmaxprevrun)
						IF cotherruns[0] NE -1 THEN BEGIN
							cotherrunarr=keeptrapdata[cotherruns]
							cmaxprevrun=MAX(FIX(cotherrunarr.field5))
						ENDIF
						
					
					ENDREP UNTIL (c EQ 9) OR (cotherruns[0] EQ -1)
				ENDIF
	
				cdatais=WHERE(crunnumarr NE 0,ncdatais)
				cuarr=cuarr[cdatais]
				
				cmotrap=MOMENT(cuarr,sdev=cstdevtrap)
						ncmo=ncdatais
				
				cuncflag=farr[trappos[0]].flag	
				
				unctestformat='(A8,1X,A15,F8.3,I3,A5)'
				;PRINT,'testing uncertainty code by printing uncertainty to a file'	
					;for testing, print run number and uncertainty to a file
					unctestfile='/home/ccg/sil/tempfiles/uncertaintytest1.'+sp+'.'+inst+'.txt'
					OPENU, u, unctestfile, /GET_LUN,/APPEND
					PRINTF, u, format=unctestformat,runnum,file,cstdevtrap,ncmo,cuncflag
					FREE_LUN,u
					
				unc=cstdevtrap	
				
			ENDIF ELSE BEGIN
			
				unc=-0.009
			
			ENDELSE
			
	ENDIF ELSE BEGIN
			
			unc=-0.009
	ENDELSE
		
		;*****************

ENDIF ELSE BEGIN
	IF uncertainty EQ 1 THEN BEGIN  ; have no trap but still want un value
		unc=-0.009
	ENDIF ELSE BEGIN
	unc=-0.009
	ENDELSE
ENDELSE
uncer=FLTARR(ntot)+unc ; need to make this an array to accomodate linunc
;skipthisfornow:

IF correctforlinearity EQ 1 THEN BEGIN
	IF mcmethod EQ 1 THEN BEGIN
		IF unc LT 0 THEN uncer=FLTARR(ntot+0.05) ; filler to make non-negative number
		totalunc=FLTARR(ntot)
		FOR z=0,ntot-1 DO totalunc[z]=(uncer[z]^2+linsd[z]^2)^0.5
	ENDIF 
		; if you want to add uncertainty from other LIN methods do so here		

ENDIF ELSE BEGIN
	totalunc=uncer
ENDELSE

; ----- WRITE TO STATISTICS FILE FOR TRAP TANK ----------------------------------
IF printtanks EQ 1 THEN BEGIN
IF (trappos[0] NE -1) THEN BEGIN
	;trapstatformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),4(F10.3),A4,A9)'
	trapstatformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),4(F10.3),F8.3,A4,A9)'
		;with room for uncertainty
	trapstatfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/trapstat'+trap+'.'+sp+'.' + inst
	;testtrapstatfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/testtrapstat'+trap+'.'+sp+'.' + inst
	
	trapstatfileexist = FILE_TEST(trapstatfile)

	
	CCG_READ, file = trapstatfile, /nomessages, trapstatfilearr
	IF trapstatfileexist EQ 0 THEN BEGIN
		OPENU, u, trapstatfile, /APPEND, /GET_LUN
	
		PRINTF, u, FORMAT = trapstatformat, farr[trappos[0]].id, $
			farr[trappos[0]].yr, farr[trappos[0]].mo, farr[trappos[0]].dy, $
			farr[trappos[0]].run, farr[trappos[0]].inst, farr[trappos[0]].ayr, $
			farr[trappos[0]].amo, farr[trappos[0]].ady, farr[trappos[0]].ahr, $
			farr[trappos[0]].amn, farr[trappos[0]].asc, traparr[0].averaw, $
			traparr[0].sdraw, traparr[0].avedelta, traparr[0].sddelta, unc,$
			farr[trappos[0]].flag, farr[trappos[0]].ref
		FREE_LUN,u
	ENDIF ELSE BEGIN
		exists = WHERE (FIX(trapstatfilearr.field5) EQ FIX(farr[trappos[0]].run),COMPLEMENT=othervals) 
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
				farr[trappos[0]].amn, farr[trappos[0]].asc, traparr[0].averaw, $
				traparr[0].sdraw, traparr[0].avedelta, traparr[0].sddelta, unc, $
				farr[trappos[0]].flag, farr[trappos[0]].ref
		ENDIF ELSE BEGIN
		; this is where we overwrite data
		
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
					raw:0.0,	$
					sdraw:0.0,	$
					value:0.0,	$
					sdvalue:0.0,	$
					uncert:0.0,	$
					flag:'',	$
					ref:''},	$
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
			newtrapstatarr[0].raw=traparr[0].averaw
			newtrapstatarr[0].sdraw=traparr[0].sdraw
			newtrapstatarr[0].value=traparr[0].avedelta
			newtrapstatarr[0].sdvalue=traparr[0].sddelta
			newtrapstatarr[0].uncert=unc
			newtrapstatarr[0].flag=farr[trappos[0]].flag
			newtrapstatarr[0].ref=farr[trappos[0]].ref
					
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
				newtrapstatarr[h+1].raw=othervalarr[h].field13
				newtrapstatarr[h+1].sdraw=othervalarr[h].field14
				newtrapstatarr[h+1].value=othervalarr[h].field15
				newtrapstatarr[h+1].sdvalue=othervalarr[h].field16
				newtrapstatarr[h+1].uncert=othervalarr[h].field17
				newtrapstatarr[h+1].flag=othervalarr[h].field18
				newtrapstatarr[h+1].ref=othervalarr[h].field19
				
			ENDFOR
					
			nnew=nother+1
			adate = DBLARR(nnew)
			FOR b=0, nnew-1 DO BEGIN
				CCG_DATE2DEC, YR=newtrapstatarr[b].ayr, $
					MO=newtrapstatarr[b].amo, DY=newtrapstatarr[b].ady, $
					HR=newtrapstatarr[b].ahr,MN=newtrapstatarr[b].amn,DEC=dec
				adate[b]=dec
			ENDFOR
			newtrapstatarr=newtrapstatarr[SORT(adate)]
	
			OPENW, u, trapstatfile, /GET_LUN
				FOR a=0, nnew-1 DO PRINTF, u, format=trapstatformat,newtrapstatarr[a]
			FREE_LUN, u

			;***	
		ENDELSE	 ;data exists for that run	
	ENDELSE ;tankfile exists
	FREE_LUN, u
	
	
	CCG_READ, file=trapstatfile, trapstatdata, /nomessages
		
		ntrapstatdata=N_ELEMENTS(trapstatdata)
		adate = DBLARR(ntrapstatdata)

		FOR b=0, ntrapstatdata-1 DO BEGIN		
			CCG_DATE2DEC, YR=trapstatdata[b].field7,MO=trapstatdata[b].field8, $  
				DY=trapstatdata[b].field9,HR=trapstatdata[b].field10,  $   
				MN=trapstatdata[b].field11,DEC=dec    
			adate[b]=dec
		ENDFOR
		
		trapstatdata=trapstatdata[SORT(adate)]
		OPENU, u, trapstatfile, /GET_LUN
		FOR a=0, ntrapstatdata-1 DO PRINTF, u, trapstatdata[a].str  
		FREE_LUN, u
ENDIF	


; ----- PUT TANK DATA SOMEWHERE TO BE PARSED OUT INTO PROPER PLACE -------------------
; final array of just tank called tankarr

;; NOTE FOR REPROCESSING - keep a copy of old tanks. Can apply hand flags later. It's too hard to do here.

tankpos=WHERE(type EQ 'STD',ntank)

IF tankpos[0] NE -1 THEN BEGIN
	tankarr = farr[tankpos]
	ntanks = N_ELEMENTS(tankarr)


	; ----- TRANSFER PROCESSED TANK DATA INTO TANK FILES ----------------------------
	FOR i=0, ntanks-1 DO BEGIN
		internal = STRPOS(tankarr[i].enum,'-')
		thetank = WHERE(tankarr[i].enum EQ tankarr.enum,nthetank)
		thetankvalues = tankarr[thetank]
		
		;;Add F flag to first aliquot of each tank. this used to happen in tank_view (sre 4/5/06)
		thetankvalues[0].flag='F'+STRMID(thetankvalues[0].flag,1,2)
		
		
		IF (internal EQ 4) THEN BEGIN
			tankdir = '/projects/'+sp+'/'+calsdir+'/internal_cyl/'
			revtankdir = tankdir  ;'/projects/'+sp+'/'+revcalsdir+'/internal_cyl/'
		ENDIF ELSE BEGIN
			tankdir = '/projects/'+sp+'/'+calsdir+'/external_cyl/'	
			revtankdir = tankdir ;'/projects/'+sp+'/'+revcalsdir+'/external_cyl/'	
		ENDELSE
		
		;tankformat = '(A8, I5, 2(I3), A7, A9, I5, 5(I3), F10.4, A4, A10, A3)'
		; with uncertainty. ..
		tankformat = '(A10, I5, 2(I3), A7, A9, I5, 5(I3), F10.4, F8.3,A4, A10, A3)'
			
		tankfile = tankdir + tankarr[i].enum + '.'+sp
		revtankfile= revtankdir + tankarr[i].enum + '.'+sp
		;testtankfile = tankdir + 'test'+tankarr[i].enum + '.'+sp
		
		tankfileexist = FILE_TEST(tankfile)
		;;;
		print,revtankfile
		
		;;;
		IF tankfileexist EQ 0 THEN BEGIN
			
			OPENU, u, tankfile, /APPEND, /GET_LUN
			FOR j=0, nthetank-1 DO PRINTF, u, FORMAT=tankformat, thetankvalues[j].enum,$
			thetankvalues[j].yr, thetankvalues[j].mo,thetankvalues[j].dy,thetankvalues[j].sp,$
			thetankvalues[j].run,thetankvalues[j].ayr,thetankvalues[j].amo,thetankvalues[j].ady,$
			thetankvalues[j].ahr,thetankvalues[j].amn,thetankvalues[j].asc,$
			thetankvalues[j].value,unc,thetankvalues[j].flag,thetankvalues[j].ref,$
			thetankvalues[j].inst
			FREE_LUN,u
		ENDIF ELSE BEGIN
			
			CCG_READ, file = tankfile, /nomessages, tankfilearr
			exists = WHERE (FIX(tankfilearr.field6) EQ FIX(tankarr[i].run),COMPLEMENT=othervals)
		
		
			CCG_READ, file = revtankfile, /nomessages, revtankfilearr
	
			
			revexists = WHERE (FIX(revtankfilearr.field6) EQ FIX(thetankvalues[0].run) AND $
				revtankfilearr.field17 EQ thetankvalues[0].inst,complement=othervals) 
			
			;catch exclpt or B flags
			IF revexists[0] EQ -1 THEN goto, skipcatch  ; usually cals file will have data! but this allows you to not worry if it doesn't
			
			catcharrc=STRARR(nthetank)
		
			FOR c=0,nthetank-1 DO BEGIN
				catcharrc[c]='.'
				
				CASE STRMID(revtankfilearr[exists[c]].field15,0,1) OF
				 'B' : BEGIN
				 
				 	catcharrc[c]=STRMID(revtankfilearr[exists[c]].field15,0,1)
				END
				 '!': BEGIN
				 	 catcharrc[c]=STRMID(revtankfilearr[exists[c]].field15,0,1)
				END	
				ELSE: BEGIN 
					catcharrc[c]=STRMID(thetankvalues[c].flag,0,1)
				END
				ENDCASE
				
			
			ENDFOR
	
		
		
			FOR j=0,nthetank-1 DO BEGIN
				
			 IF catcharrc[j] EQ '.' THEN thetankvalues[j].flag = thetankvalues[j].flag ELSE $
						thetankvalues[j].flag=catcharrc[j]+STRMID(thetankvalues[j].flag,1,2)
						
			
			ENDFOR
			skipcatch:
		
		
		
			IF othervals[0] NE -1 THEN BEGIN
				othervalarr=tankfilearr[othervals]
				nother=N_ELEMENTS(othervals)
				newrunarr=STRARR(nother)
				FOR n=0,nother-1 DO BEGIN
					IF othervalarr[n].field6 LT 100000 THEN	newrunarr[n]='0'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 10000 THEN newrunarr[n]='00'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 1000 THEN newrunarr[n]='000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 100 THEN newrunarr[n]='0000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
					IF othervalarr[n].field6 LT 10 THEN newrunarr[n]='00000'+STRCOMPRESS(STRING(othervalarr[n].field6),/REMOVE_ALL)
				ENDFOR
				
			ENDIF ELSE BEGIN
				nother=0
				
			ENDELSE
			
				nnew=nother+nthetank
			IF (exists[0] EQ -1) THEN BEGIN
				OPENU, u, tankfile, /APPEND, /GET_LUN
			
				FOR j=0, nthetank-1 DO PRINTF, u, FORMAT=tankformat, thetankvalues[j].enum,$
				thetankvalues[j].yr, thetankvalues[j].mo,thetankvalues[j].dy,thetankvalues[j].sp,$
				thetankvalues[j].run,thetankvalues[j].ayr,thetankvalues[j].amo,thetankvalues[j].ady,$
				thetankvalues[j].ahr,thetankvalues[j].amn,thetankvalues[j].asc,$
				thetankvalues[j].value,unc,thetankvalues[j].flag,thetankvalues[j].ref,$
				thetankvalues[j].inst
				FREE_LUN, u
			ENDIF ELSE BEGIN
			; here is where you overwrite old data
				newtankarr=REPLICATE({enum:'',$
					yr:0,		$
					mo:0,		$
					dy:0,		$
					sp:'',	$
					run:'',		$
					ayr:0,		$
					amo:0,		$
					ady:0,		$
					ahr:0,		$
					amn:0,		$
					asc:0,		$
					value:0.0,	$
					uncert:0.0,	$
					flag:'',	$
					ref:'',		$
					inst:''},	$
					nother+nthetank)
					
				FOR v=0,nthetank-1 DO BEGIN
					newtankarr[v].enum=thetankvalues[v].enum
					newtankarr[v].yr=thetankvalues[v].yr
					newtankarr[v].mo=thetankvalues[v].mo
					newtankarr[v].dy=thetankvalues[v].dy
					newtankarr[v].sp=thetankvalues[v].sp
					newtankarr[v].run=thetankvalues[v].run
					newtankarr[v].ayr=thetankvalues[v].ayr
					newtankarr[v].amo=thetankvalues[v].amo
					newtankarr[v].ady=thetankvalues[v].ady
					newtankarr[v].ahr=thetankvalues[v].ahr
					newtankarr[v].amn=thetankvalues[v].amn
					newtankarr[v].asc=thetankvalues[v].asc
					newtankarr[v].value=thetankvalues[v].value
					newtankarr[v].uncert=unc
					newtankarr[v].flag=thetankvalues[v].flag
					newtankarr[v].ref=thetankvalues[v].ref
					newtankarr[v].inst=thetankvalues[v].inst
				ENDFOR
				
				FOR h=0,nother-1 DO BEGIN
					newtankarr[h+nthetank].enum=othervalarr[h].field1
					newtankarr[h+nthetank].yr=othervalarr[h].field2
					newtankarr[h+nthetank].mo=othervalarr[h].field3
					newtankarr[h+nthetank].dy=othervalarr[h].field4
					newtankarr[h+nthetank].sp=othervalarr[h].field5
					newtankarr[h+nthetank].run=newrunarr[h]
					newtankarr[h+nthetank].ayr=othervalarr[h].field7
					newtankarr[h+nthetank].amo=othervalarr[h].field8
					newtankarr[h+nthetank].ady=othervalarr[h].field9
					newtankarr[h+nthetank].ahr=othervalarr[h].field10
					newtankarr[h+nthetank].amn=othervalarr[h].field11
					newtankarr[h+nthetank].asc=othervalarr[h].field12
					newtankarr[h+nthetank].value=othervalarr[h].field13
					newtankarr[h+nthetank].uncert=othervalarr[h].field14
					newtankarr[h+nthetank].flag=othervalarr[h].field15
					newtankarr[h+nthetank].ref=othervalarr[h].field16
					newtankarr[h+nthetank].inst=othervalarr[h].field17
				ENDFOR

				nnew=nother+nthetank	
							
				OPENW,u,tankfile,/GET_LUN
					FOR a=0,nnew-1 DO PRINTF, u, format=tankformat,newtankarr[a]
				FREE_LUN,u
				
			ENDELSE  ;data exists for that file		
		
		
		
		CCG_READ, file=tankfile, tankdata, /nomessages
		
		ntankdata=N_ELEMENTS(tankdata)
		adate = DBLARR(ntankdata)

		FOR b=0, ntankdata-1 DO BEGIN		
			CCG_DATE2DEC, YR=tankdata[b].field7,MO=tankdata[b].field8, $  
				DY=tankdata[b].field9,HR=tankdata[b].field10,  $   
				MN=tankdata[b].field11,DEC=dec    
			adate[b]=dec
		ENDFOR
		
		tankdata=tankdata[SORT(adate)]
		OPENU, u, tankfile, /GET_LUN
		FOR a=0, ntankdata-1 DO PRINTF, u, tankdata[a].str  
		FREE_LUN, u
		
		
					
		ENDELSE		;tankfileexists
	ENDFOR
ENDIF

IF (verbose EQ 1) THEN PRINT, 'Finished processing ', file

;; ----- WRITE TO PERFORMANCE FILE FOR REFERENCE TANK ----------------------------
refformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),F10.3,1X,F10.3,A4)'
reffile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/ref'+ref+'.'+sp+'.' + inst

reffileexist = FILE_TEST(reffile)

IF reffileexist EQ 0 THEN BEGIN
	OPENU, u, reffile, /APPEND, /GET_LUN
	FOR i = 0, (nrefpos)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
		farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
		farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
		farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
		farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].rawval, $
		farr[refpos[i]].value, farr[refpos[i]].flag
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
		FOR i = 0, (nrefpos)-1 DO PRINTF, u, FORMAT = refformat, farr[refpos[i]].id, $
			farr[refpos[i]].yr, farr[refpos[i]].mo, farr[refpos[i]].dy, $
			farr[refpos[i]].run, farr[refpos[i]].inst, farr[refpos[i]].ayr, $
			farr[refpos[i]].amo, farr[refpos[i]].ady, farr[refpos[i]].ahr, $
			farr[refpos[i]].amn, farr[refpos[i]].asc, farr[refpos[i]].rawval, $
			farr[refpos[i]].value, farr[refpos[i]].flag				
	ENDIF ELSE BEGIN
		;overwriting old data
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
					raw:0.0,	$
					value:0.0,	$
					flag:''},	$
					nother +nrefs)
				
		FOR v=0, nrefs-1 DO BEGIN
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
			newfinalrefarr[v].raw=farr[refpos[v]].rawval
			newfinalrefarr[v].value=farr[refpos[v]].value
			newfinalrefarr[v].flag=farr[refpos[v]].flag
					
		ENDFOR
		
		FOR h=0, nother-1 DO BEGIN
			newfinalrefarr[h+nrefs].id=othervalarr[h].field1
			newfinalrefarr[h+nrefs].yr=othervalarr[h].field2
			newfinalrefarr[h+nrefs].mo=othervalarr[h].field3
			newfinalrefarr[h+nrefs].dy=othervalarr[h].field4
			newfinalrefarr[h+nrefs].run=newrunarr[h]
			newfinalrefarr[h+nrefs].inst=othervalarr[h].field6
			newfinalrefarr[h+nrefs].ayr=othervalarr[h].field7
			newfinalrefarr[h+nrefs].amo=othervalarr[h].field8
			newfinalrefarr[h+nrefs].ady=othervalarr[h].field9
			newfinalrefarr[h+nrefs].ahr=othervalarr[h].field10
			newfinalrefarr[h+nrefs].amn=othervalarr[h].field11
			newfinalrefarr[h+nrefs].asc=othervalarr[h].field12
			newfinalrefarr[h+nrefs].raw=othervalarr[h].field13
			newfinalrefarr[h+nrefs].value=othervalarr[h].field14
			newfinalrefarr[h+nrefs].flag=othervalarr[h].field15
			
		ENDFOR
						
		nnew=nother+nrefs
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
		

	ENDELSE  ;exists NE -1; data for that run already exists and needs to be rew
ENDELSE
FREE_LUN, u

CCG_READ, file=reffile, reftankdata, /nomessages
nreftankdata=N_ELEMENTS(reftankdata)
adate = DBLARR(1,nreftankdata)


FOR b=0, nreftankdata-1 DO BEGIN
	CCG_DATE2DEC, YR=reftankdata[b].field7, $
		MO=reftankdata[b].field8, DY=reftankdata[b].field9,$
		HR=reftankdata[b].field10,MN=reftankdata[b].field11, DEC=dec
	adate[b]=dec
ENDFOR

reftankdata=reftankdata[SORT(adate)]
OPENU, u, reffile, /GET_LUN
FOR a=0, nreftankdata-1 DO PRINTF, u, reftankdata[a].str
FREE_LUN, u

; ----- WRITE TO STATISTICS FILE FOR REFERENCE TANK -----------------------------

; only for new data. I can't deal with old data
IF olddata EQ 0 THEN BEGIN
refstatformat = '(A9,I5.1,2(I3.1),A9,A4,I5.1,5(I3.1),2(F10.3,1X,F8.3))'
refstatfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/refstat'+ref+'.'+sp+'.' + inst
;testrefstatfile = '/projects/'+sp+'/'+calsdir+'/internal_cyl/testrefstat'+ref+'.'+sp+'.' + inst

refstatfileexist = FILE_TEST(refstatfile)
CCG_READ, file = refstatfile, /nomessages, refstatfilearr 

IF refstatfileexist EQ 0 THEN BEGIN
	OPENU, u, refstatfile, /APPEND, /GET_LUN
	FOR i=0, ngroups-1 DO BEGIN

		first = refsets[i]-cluster[i]+1
		PRINTF, u, FORMAT = refstatformat, farr[first].id, $
			farr[first].yr, farr[first].mo, farr[first].dy, $
			farr[first].run, farr[first].inst, farr[first].ayr, $
			farr[first].amo, farr[first].ady, farr[first].ahr, $
			farr[first].amn, farr[first].asc, refarr[i].averaw, $
			refarr[i].sdraw, refarr[i].avedelta, refarr[i].sddelta
	ENDFOR
ENDIF ELSE BEGIN
	exists = WHERE (refstatfilearr.field5 EQ farr[refpos[0]].run,COMPLEMENT=othervals)
	IF othervals[0] NE -1 THEN BEGIN
		othervalarr=refstatfilearr[othervals]
		nother=N_ELEMENTS(othervalarr) 
					
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

	IF (exists[0] EQ -1) THEN BEGIN  ;data from this run dne
		OPENU, u, refstatfile, /APPEND, /GET_LUN

		FOR i=0, ngroups-1 DO BEGIN
			first = refsets[i]-cluster[i]+1
			PRINTF, u, FORMAT = refstatformat, farr[first].id, $
				farr[first].yr, farr[first].mo, farr[first].dy, $
				farr[first].run, farr[first].inst, farr[first].ayr, $
				farr[first].amo, farr[first].ady, farr[first].ahr, $
				farr[first].amn, farr[first].asc, refarr[i].averaw, $
				refarr[i].sdraw, refarr[i].avedelta, refarr[i].sddelta
		ENDFOR
		FREE_LUN,u
	ENDIF ELSE BEGIN
	
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
					averaw:0.0,	$
					sdraw:0.0,	$
					avevalue:0.0,	$
					sdvalue:0.0},	$
					nother +ngroups)
		FOR v=0, ngroups-1 DO BEGIN
			IF olddata EQ 0 THEN BEGIN	
			last = refsets[v]  ;  this = the position of the last REF in each (current) set.
			refcount = cluster[v] ;  this = the number of REF's in the i-th (current) set of refs.
			first = last - refcount +1  ; now first = position of 1st ref of the current set of refs.
			ENDIF ELSE BEGIN
			thisfirst=WHERE(weirdrefgroups EQ j+1)
			first=refpos[thisfirst[0]]
			ENDELSE
				
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
			newrefstatarr[v].averaw=refarr[v].averaw
			newrefstatarr[v].sdraw=refarr[v].sdraw
			newrefstatarr[v].avevalue=refarr[v].avedelta
			newrefstatarr[v].sdvalue=refarr[v].sddelta
			
		ENDFOR
					
		FOR h=0, nother-1 DO BEGIN
			newrefstatarr[h+ngroups].id=othervalarr[h].field1
			newrefstatarr[h+ngroups].yr=othervalarr[h].field2
			newrefstatarr[h+ngroups].mo=othervalarr[h].field3
			newrefstatarr[h+ngroups].dy=othervalarr[h].field4
			newrefstatarr[h+ngroups].run=newrunarr[h]
			newrefstatarr[h+ngroups].inst=othervalarr[h].field6
			newrefstatarr[h+ngroups].ayr=othervalarr[h].field7
			newrefstatarr[h+ngroups].amo=othervalarr[h].field8
			newrefstatarr[h+ngroups].ady=othervalarr[h].field9
			newrefstatarr[h+ngroups].ahr=othervalarr[h].field10
			newrefstatarr[h+ngroups].amn=othervalarr[h].field11
			newrefstatarr[h+ngroups].asc=othervalarr[h].field12
			newrefstatarr[h+ngroups].averaw=othervalarr[h].field13
			newrefstatarr[h+ngroups].sdraw=othervalarr[h].field14
			newrefstatarr[h+ngroups].avevalue=othervalarr[h].field15
			newrefstatarr[h+ngroups].sdvalue=othervalarr[h].field16
			
		ENDFOR
				
		nnew=nother+ngroups
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
FREE_LUN, u

CCG_READ, file=refstatfile, refstatdata, /nomessages
nrefstatdata=N_ELEMENTS(refstatdata)
adate = DBLARR(1,nrefstatdata)


FOR b=0, nrefstatdata-1 DO BEGIN
	CCG_DATE2DEC, YR=refstatdata[b].field7, $
		MO=refstatdata[b].field8, DY=refstatdata[b].field9, $
		HR=refstatdata[b].field10, MN=refstatdata[b].field11, DEC=dec
	adate[b]=dec
ENDFOR

refstatdata=refstatdata[SORT(adate)]
OPENU, u, refstatfile, /GET_LUN
FOR a=0, nrefstatdata-1 DO PRINTF, u, refstatdata[a].str
FREE_LUN, u
ENDIF  ;; old data 
ENDIF ;printtanks



	;*************

;; ----- PRINT SIL FLASKS TO FILE --------------------------------------------------

IF reprintsil EQ 1 THEN BEGIN  ; gives you option to not append silflask file
	silflasks = WHERE(type EQ 'SIL',nsilflasks)
	IF silflasks[0] NE -1 THEN BEGIN
		silflaskfile = '/home/ccg/sil/silflasks/silflasks.'+sp
		PRINT,'printing silflasks to file. . .'
		silarr=farr[silflasks]
		finformat = '(A12,A12,I5.1,2(I3.1),I5.1,5(I3.1),F10.3,F10.3,A4,1X,A3,A8,1x,A8)'
		OPENU, u, silflaskfile, /APPEND, /GET_LUN
		FOR i = 0, nsilflasks-1 DO PRINTF, u, FORMAT = finformat, silarr[i].enum, $
			silarr[i].id, silarr[i].yr, silarr[i].mo, silarr[i].dy, $
			silarr[i].ayr, silarr[i].amo, silarr[i].ady, $
			silarr[i].ahr, silarr[i].amn, silarr[i].asc, $
			silarr[i].value, unc,silarr[i].flag, silarr[i].inst, $
			silarr[i].run,ref
		FREE_LUN,u
	ENDIF
ENDIF


; ----- PUT SAMPLE DATA SOMEWHERE TO BE PARSED OUT INTO PROPER PLACE -------------------
; final array of just samples called finalarr
samples = WHERE(type EQ 'SMP',nsamples)


IF samples[0] NE -1 THEN BEGIN	
	finalarr = farr[samples]
	
	finalarrstr = STRARR(nsamples)
	; THIS shpeel below is about preserving hand flags when you need to reprocess data. 1/30/15 sem
	FOR s=0,nsamples-1 DO BEGIN
		CCG_FLASK, sp=sp,evn=finalarr[s].enum,prevdata
		datasize=size(prevdata)
		IF datasize[0] GT 0 THEN BEGIN   ; if data exists for this event num
			adate=DBLARR(1)
			CCG_DATE2DEC,yr=finalarr[s].ayr,mo=finalarr[s].amo,dy=finalarr[s].ady,hr=finalarr[s].ahr,$
				mn=finalarr[s].amn,dec=dec
			adate=dec    ; this is the analysis date of this data processing
		
			heretis=WHERE(adate EQ prevdata.adate,nhere)
			IF nhere GT 1 THEN stop
			IF heretis[0] NE -1 THEN BEGIN
			  ;prevdata[0].adate EQ adate THEN BEGIN     ; if it is the same measurement
		
				IF STRMID(prevdata[heretis].flag,0,1) EQ '!' THEN BEGIN    ; if the measurement has been hand flagged
					finalarr[s].flag='!'+STRMID(finalarr[s].flag,1,2)
					;IF correctforlinearity EQ 1 THEN finallinarr[s].flag='!'+STRMID(finallinarr[s].flag,1,2)
				ENDIF 
				
				
			ENDIF
		ENDIF
	
	ENDFOR
	uncertainty=1
	;this was the old style string created for ccg_flaskupdate. Kept only for printing to screen	
	FOR i=0, nsamples-1 DO BEGIN
		IF uncertainty EQ 1 THEN BEGIN
		finalarrstr[i] = [string(finalarr[i].enum)+$
			' '+string(finalarr[i].sp)+$
			' '+string(finalarr[i].value)+$
			' '+string(finalarr[i].flag)+$
			' '+string(finalarr[i].inst)+$
			' '+string(finalarr[i].ayr)+$
			' '+string(finalarr[i].amo)+$
			' '+string(finalarr[i].ady)+$
			' '+string(finalarr[i].ahr)+$
			' '+string(finalarr[i].amn)+$
			' '+string(totalunc[i])]
			print, finalarrstr[i]
		ENDIF ELSE BEGIN
		finalarrstr[i] = [string(finalarr[i].enum)+$
			' '+string(finalarr[i].sp)+$
			' '+string(finalarr[i].value)+$
			' '+string(finalarr[i].flag)+$
			' '+string(finalarr[i].inst)+$
			' '+string(finalarr[i].ayr)+$
			' '+string(finalarr[i].amo)+$
			' '+string(finalarr[i].ady)+$
			' '+string(finalarr[i].ahr)+$
			' '+string(finalarr[i].amn)]
		ENDELSE
	ENDFOR	

	FOR i=0, nsamples-1 DO BEGIN
	 	nvpairs = ['evn:'+STRING(finalarr[i].enum)]
 		nvpairs = [nvpairs,'param:'+STRING(finalarr[i].sp)]
 		nvpairs = [nvpairs,'value:'+STRING(finalarr[i].value)]
 		nvpairs = [nvpairs,'flag:'+STRING(finalarr[i].flag)]
 		nvpairs = [nvpairs,'inst:'+STRING(finalarr[i].inst)]
 		nvpairs = [nvpairs,'yr:'+STRING(finalarr[i].ayr)]
 		nvpairs = [nvpairs,'mo:'+STRING(finalarr[i].amo)]
 		nvpairs = [nvpairs,'dy:'+STRING(finalarr[i].ady)]
 		nvpairs = [nvpairs,'hr:'+STRING(finalarr[i].ahr)]
 		nvpairs = [nvpairs,'mn:'+STRING(finalarr[i].amn)] 
 		nvpairs = [nvpairs,'sc:0'] 
 		nvpairs = [nvpairs,'program:SIL'] 
 			
 		IF uncertainty EQ 1 THEN nvpairs = [nvpairs,'unc:'+STRING(totalunc[i])] 
 		z = STRJOIN(nvpairs, '|')
 		finalarrstr[i] = z
	 
	 ENDFOR	
	
	 IF correctforlinearity EQ 1 THEN BEGIN
	 
	; If assumelinearity EQ 1 then goto, skipthislin
	 ;IF linvalshere[0] NE -1 THen BEGIN
		; IF thisprob GE 0.9 THEN BEGIN
			 linfarr=farr
			linfarr.value=lincorrvals
			linfarr.flag=linflagarr
			linfarr.unc=totalunc
			finallinarr=linfarr[samples]
			finallinarrstr= STRARR(nsamples)
		
 		
			 FOR i=0, nsamples-1 DO BEGIN
 				nvpairs = ['evn:'+STRING(finallinarr[i].enum)]
 				nvpairs = [nvpairs,'param:'+STRING(finallinarr[i].sp)]
 				nvpairs = [nvpairs,'value:'+STRING(finallinarr[i].value)]
 				nvpairs = [nvpairs,'flag:'+STRING(finallinarr[i].flag)]
 				nvpairs = [nvpairs,'inst:'+STRING(finallinarr[i].inst)]
 				nvpairs = [nvpairs,'yr:'+STRING(finallinarr[i].ayr)]
 				nvpairs = [nvpairs,'mo:'+STRING(finallinarr[i].amo)]
 				nvpairs = [nvpairs,'dy:'+STRING(finallinarr[i].ady)]
 				nvpairs = [nvpairs,'hr:'+STRING(finallinarr[i].ahr)]
 				nvpairs = [nvpairs,'mn:'+STRING(finallinarr[i].amn)] 
 				nvpairs = [nvpairs,'sc:0'] 
 				nvpairs = [nvpairs,'program:SIL'] 
 				;nvpairs = [nvpairs,'unc:'+STRING(finallinarr[i].unc)] 
 			
 				IF uncertainty EQ 1 THEN nvpairs = [nvpairs,'unc:'+STRING(finallinarr[i].unc)] 
 				z = STRJOIN(nvpairs, '|')
 				finallinarrstr[i] = z
				
			ENDFOR	
			
	;;;;;	;ENDIF
	;ENDIF ELSE BEGIN
	; not yet in use. .. 
	;skipthislin:
	;IF assumelinearity EQ 1 THEN BEGIN
	 ;	; consider flagging ...
	;	 linfarr=farr
		;linfarr.value=lincorrvals
	;	
	;	finallinarr=linfarr[samples]
	;	finallinarrstr= STRARR(nsamples)
	;	
 	;	
	;	 FOR i=0, nsamples-1 DO BEGIN
	;;	 	nvpairs = ['evn:'+STRING(finallinarr[i].enum)]
	;	 	nvpairs = [nvpairs,'param:'+STRING(finallinarr[i].sp)]
	;	 	nvpairs = [nvpairs,'value:'+STRING(finallinarr[i].value)]
	;	 	nvpairs = [nvpairs,'flag:'+STRING(finallinarr[i].flag)]
	;	; 	nvpairs = [nvpairs,'inst:'+STRING(finallinarr[i].inst)]
 	;		;nvpairs = [nvpairs,'yr:'+STRING(finallinarr[i].ayr)]
 	;		nvpairs = [nvpairs,'mo:'+STRING(finallinarr[i].amo)]
 	;		nvpairs = [nvpairs,'dy:'+STRING(finallinarr[i].ady)]
 	;		nvpairs = [nvpairs,'hr:'+STRING(finallinarr[i].ahr)]
 	;		nvpairs	 = [nvpairs,'mn:'+STRING(finallinarr[i].amn)] 
 	;		nvpairs	 = [nvpairs,'sc:0'] 
 	;		nvpairs 	= [nvpairs,'program:SIL'] 
 	;		;nvpairs = [nvpairs,'unc:'+STRING(unc)] 
 	;	
 	;		IF uncertainty EQ 1 THEN nvpairs = [nvpairs,'unc:'+STRING(unc)] 
 	;		z = STRJOIN(nvpairs, '|')
 	;		finallinarrstr[i] = z
	;	ENDFOR	
	;	
	;ENDIF
	;ENDELSE
	ENDIF

	 IF olddata EQ 1 THEN BEGIN
		 IF nsamples LE 2 THEN goto, skipplot
		 dbarr=FLTARR(nsamples)
		 samindex=FINDGEN(nsamples)
		 FOR j=0,nsamples-1 DO BEGIN
 		CCG_DATE2DEC, yr=finalarr[j].ayr,$
		mo=finalarr[j].amo,$
		dy=finalarr[j].ady,$
		hr=finalarr[j].ahr,$
		mn=finalarr[j].amn,dec=dec
		CCG_FLASK, evn=finalarr[j].enum,sp=finalarr[j].sp,dbdata
		thisone=WHERE(dbdata.adate EQ dec)
		
		dbarr[j]=dbdata[thisone].value
		ENDFOR
		diffarr=dbarr-finalarr.value
		badones=WHERE(ABS(diffarr) GT 0.04,nbadones)
		IF badones[0] NE -1 THEN BEGIN
			FOR b=0,nbadones-1 DO BEGIN
				badflag=finalarr[badones[b]].flag
				IF STRMID(badflag,0,1) EQ '.' THEN BEGIN
				 	print,'check this run!'
					checkthisformat='(A25)'		 
					checkthisfile='/home/ccg/sil/tempfiles/checkthese_oldch4files.txt'
					OPENU, u, checkthisfile, /APPEND, /GET_LUN
					PRINTF, u, FORMAT=checkthisformat, runnum
					FREE_LUN, u		
					goto, skiprest
				ENDIF
			ENDFOR
		ENDIF
		skiprest:		
		CCG_OPENDEV,dev=dev	
		PLOT, samindex,dbarr,$
			POSITION=[0.18,0.25,0.94,0.95],$    ;x1,y1,x2,y2 
			/NODATA,$
			/NOERASE,$
			;YRANGE=[ymin,ymax],$
			YSTYLE=1,$
			YMINOR=2,$
			;YTITLE=gas.formula + ', site flask ('+gas.units+')',$
			CHARTHICK=howthick,$
			YTHICK=2.0,$
			;XRANGE=[xmin,xmax],$
			;XCHARSIZE=0,$
			XSTYLE=1
			;XTICKNAME=nullarr
			;YTICKS=ystep,$
			;YTICKNAME=,$
			
		CCG_SYMBOL, sym=1
		OPLOT,samindex,dbarr,$
			THICK=0,$
       	         PSYM=8,  $  (use 8 if using ccg_symbol)                 
       	         COLOR=16        
		CCG_SYMBOL, sym=1
		OPLOT,samindex,finalarr.value,$
			THICK=0,$
       	         PSYM=8,  $  (use 8 if using ccg_symbol)                 
       	         COLOR=22
		 CCG_CLOSEDEV
		skipplot:
	 ENDIF		
		 
	; ----- TRANSFER PROCESSED SAMPLE DATA INTO DATABASE -----------------------------
	
	
	;x=PLOT(peakht[samples],finalarr.value,symbol='circle',linestyle=6,color='black',dimensions=[1200,600])
	;x.ytitle='d13C'
	;x.xtitle='peakht'
	;y=PLOT(peakht[samples],finallinarr.value,symbol='circle',linestyle=6,color='red',/overplot)
	
	
	;z=PLOT(peakht[samples],finalarr.value-finallinarr.value,symbol='circle',linestyle=6,color='black',dimensions=[1200,600])

	;update=0
IF sp EQ 'ch4h2' THEN update=0 	
	IF update EQ 0 THEN BEGIN  ; -----Stream output to user specified directory
		IF printsitefiles EQ 1 THEN BEGIN
			
				;ch4c13_dir ='/home/ccg/sil/ch4c13/linadjustfiles'   ;-0.025 permil/nA slope
				;ch4c13_dir ='/home/ccg/sil/ch4c13/linadjust047files'   ;-0.047 permil/nA slope
			
				;ch4c13_dir ='/home/ccg/sil/ch4c13/linadjustmc019files'
				;ch4c13_dir ='/home/ccg/sil/ch4c13/flagpeakdiffs'	
				;ch4c13_dir ='/home/ccg/sil/ch4c13/newlinadjmcreal'	
				;ch4c13_dir ='/home/ccg/sil/ch4c13/addsomeflags_lin'	
				;ch4c13_dir ='/home/ccg/sil/ch4c13/finallincorr'	
				ch4c13_dir ='/home/ccg/sil/ch4c13/nopflags'	
									
				;ch4c13_dir ='/home/ccg/sil/ch4c13/zflags'	
				;
				;ch4c13_dir='/home/ccg/sil/ch4h2/newcal_refsd4_pd5'
				;ch4c13_dir='/home/ccg/sil/ch4c13/nov2022_testfiles'
				ch4c13_dir='/home/ccg/sil/ch4c13/nov2024_testfiles2'
				
				;print, finalarrstr
				;ch4h2dir='/home/ccg/sil/ch4h2/2024_tests'
			IF correctforlinearity EQ 1 THEN BEGIN
				CCG_FLASKUPDATE, arr=finallinarrstr, unc=1,update=0,ddir= ch4c13_dir, error=error
			ENDIF ELSE BEGIN
		
				CCG_FLASKUPDATE, arr=finalarrstr, update=0,ddir= ch4c13_dir, error=error
		
			ENDELSE	
		ENDIF 
	
	ENDIF ELSE BEGIN
		;updating database


		IF pause EQ 1 THEN BEGIN
			keepgoing=DIALOG_MESSAGE ('Proceed with data transfer?', title = 'Continue',/Question, /cancel)
				IF keepgoing EQ 'Cancel' THEN goto,bailout
				IF keepgoing EQ 'No' THEN goto,bailout
				print, 'updating database'
		ENDIF

		IF uncertainty EQ 1 THEN BEGIN
			IF correctforlinearity EQ 1 THEN BEGIN
				CCG_FLASKUPDATE, arr=finallinarrstr, unc=1,update=1,/value,/flag,/nopreserve,error=error
			ENDIF ELSE BEGIN
			
		  		CCG_FLASKUPDATE, arr=finalarrstr,update=1,/value,/flag,/unc,/nopreserve,error=error
			ENDELSE
		ENDIF ELSE BEGIN
		   	CCG_FLASKUPDATE, arr=finalarrstr,update=1,/value,/flag,/nopreserve,error=error
		ENDELSE	
		
		; even if you're updating database, put linearity-corrected data into a sitefile
		
		;IF linvalshere[0] NE -1 THEN BEGIN
		;	IF thisprob LE 0.1 THEN BEGIN
		;		lindir='/home/ccg/sil/ch4c13/linadjfiles'
		;		
		;		 CCG_FLASKUPDATE, arr=finallinarrstr,update=0,/value,/flag,/unc,ddir= lindir,/nopreserve,error=error
		; 	
		;	ENDIF
		;ENDIF 
	ENDELSE

ENDIF   ;you have samples

skipahead:

; ----- RUN DIAGNOSTICS PROGRAM -------------------------------------------------
;SAVE, /variables, filename = '/home/ccg/isotopes/idl/prgms/proc/diagnostics.'+sp+'.sav' 
;IF (N_ELEMENTS(trapfilearr) LT 10) OR (N_ELEMENTS(trapstatfilearr) LT 10) THEN BEGIN
;	IF (KEYWORD_SET(diagnostics)) THEN SIL_DIAG_CH4C13, ref=ref, trap=trap
;	PRINT, 'New REF and TRAP, No graphs yet!'
;ENDIF ELSE BEGIN
;	IF (KEYWORD_SET(diagnostics)) THEN BEGIN
;
;		IF sp EQ 'ch4c13' THEN SIL_DIAG_CH4C13, ref=ref, trap=trap, graphing=1
;		IF sp EQ 'ch4h2' THEN SIL_DIAG_CH4H2, ref=ref, trap=trap, graphing=1
;	ENDIF
;ENDELSE
bailout:
END
