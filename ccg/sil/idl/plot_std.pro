PRO plot_std,tank=tank,sp=sp,trap=trap,savegraphs=savegraphs,$
howmany=howmany, scenario=scenario,remote=remote,plotplease=plotplease,$    ;these keywords are for the plot_scenario.pro code
twptcal=twptcal,twptonly=twptonly,printstats=printstats,runboth=runboth,$
calsdir=calsdir,ref=ref,justref=justref


;;;;;;;
;things to check:
;calsdir
;twptcal
;twptonly
;runboth


;purpose to make graphs showing tank (perhaps trap) measured against different
;refs. This gives you one value and one stdev for each measurement episode (run)

;----------outputs
; a statsfile: contains the mean and stdev of each run. In *~calsdir~/internal_cyl/stats/~thisstats~/*stats.co2c13
;	thisstats is onept (no scale correction)
;		     twpt (mix of scale contraction and not, as is available)
;		     tpwtonly (only scale contracted data)
;allstatsfile: a file of all "good" data - passes stdev knobs per run, and pull out fliers more than 2 stdevs away from total mean. (not perfect but ok I think)
;sumfile: a file with the mean and stdev of that ref. The mean is the mean of means-of-each-run. Stdev is stdev of all runs. .		     


;

; **********key: tdat= all data from tank
; nt=total number tankdata
; dat= unflagged data

; ndat= number unflagged data
; keepdata=vector pointing to data with good stdev within a run 
; kdat= data with good stdev in run
; r1dat= data for a certain ref
; printdata=data within 3 sigma (or 2?)
; br1dat= bad data (outside 3 sigma)
; remote= when called from plot_scenarios
; includedewy = use Dewy data.
; onlyspock = just spockd data
; twptcal = check for a twptcal corrected version of the data
; runboth = get trap and nontrap data in the same file
; printstats = prints data onto plots
;writestats=writefiles
; showdata ?
;filterbaddies=a way to take out questionable runs that SLY identified by looking at tanks runs where multiple tanks were off
;repro - when we're trying to assess reproducibility we allow '#' flags. Added 9/19/23
;justoneref- so you can plot a tank relative to just one ref to show repeata/rrepro
;************** LOTS OF OPTIONS about how to run this code

IF NOT KEYWORD_SET(scenario) THEN scenario=0
IF NOT KEYWORD_SET(remote) THEN remote=0
IF remote EQ 0 THEN sparr=['co2c13','co2o18'] ELSE sparr=sp
writestats=1
IF NOT KEYWORD_SET(plotplease) THEN plotplease=0
;IF NOT KEYWORD_SET(tank) THEN plotplease=0 ELSE plotplease=1   ; maybe could use remote to turn off plotplease
IF KEYWORD_SET(ref) then plotplease=1
IF NOT KEYWORD_SET(twptcal) THEN twptcal=1
IF NOT KEYWORD_SET(twptonly) THEN twptonly=0
IF NOT KEYWORD_SET(remote) THEN remote=0
filterbaddies=1
forcexrange=0
plotbaddata=1
plotbadsddata=1
plottitle=0
errbars=1
repro=0
allonecolor=0

IF NOT KEYWORD_SET(printstats) THEN printstats=1   ; if you want averages, sd, n printed on the margin
threedot=0  ; whether or not you want to allow 3rd pos flags. 1 means only '...',0 means '..*'
IF NOT KEYWORD_SET(runboth) THEN runboth=0 ; should only be on for a single tank (working on making it more useful)
plotsecrefs=0
lookfordrift=0
justoneref=0
range=[2014.5,2015.5]
showdata=1
q=0
instsym=1
symarr=['thin diamond','circle','triangle','circle','pentagon','diamond','diamond']   ; options are 0,1,2,4,6


IF plotplease EQ 0 THEN onebyone=0
IF plotplease EQ 0 THEN showdata=0
IF plotplease EQ 0 THEN printstats=1

includedewy=1  ;from whatever file you are reading
IF remote EQ 1 THEN includedewy=1
IF remote EQ 1 THEN onlyspock=0 ELSE onlyspock=0

nsp=N_ELEMENTS(sparr)


;********* which directory are you reading from	


; calsdir:
;IF NOT KEYWORD_SET(remote) THEN calsdir='calsjras'
;calsdir='cals_archive'
;calsdir='calsjras06'
;calsdir='oldcalstests/calstst3'
;calsdir='calsieg/pressure'
getpressure=0
;pressuretype='air'
IF NOT KEYWORD_SET(calsdir) THEN calsdir='calsieg3' ;change to calsieg2?
;calsdir='calsDH'
;calsdir='cals'
IF getpressure EQ 1 THEN calsdir='calsieg/pressure'

;IF scenario EQ 1 THEN calsdir='cals' 
IF scenario EQ 1 THEN calsdir='calsieg3' 
IF scenario EQ 2 THEN calsdir='calsjras06'  ;calsjras = most current April 2020  
;IF scenario EQ 2 THEN calsdir='calsieg'  ;calsjras = most current April 2020  
IF scenario EQ 2 THEN calsdir='calsfinal'  ;calsjras = most current April 2020  

;IF scenario EQ 1 THEN calsdirstr='INSTAAR'
IF scenario EQ 1 THEN calsdirstr='old JRAS-06'

IF scenario EQ 2 THEN calsdirstr='JRAS-06'

IF calsdir EQ 'cals_archive' THEN includedewy=0 ELSE includedewy=1
IF calsdir EQ 'cals' THEN includedewy=0 ELSE includedewy=1
IF calsdir EQ 'cals_archive' THEN twptcal=0
IF calsdir EQ 'cals' THEN twptcal=0


;calsdir='calsieg3'
PRINT, '*******************************'
PRINT, 'using data from ',calsdir
PRINT, '********************************'
WAIT,1
IF twptonly EQ 1 THEN BEGIN
	PRINT, '*******************************'
	PRINT, 'twptonly is set to TRUE'
	PRINT, '********************************'
	WAIT,1
ENDIF



IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF savegraphs EQ 0 THEN onebyone=1 ELSE onebyone=0
CCG_READ, file='/home/ccg/sil/initfiles/refcodes.txt',refcodes     ; changedfrom refcodes2
;print,refcodes.field1


	IF NOT KEYWORD_SET(tank) THEN BEGIN
		alltanks=1
		;create array of refcodes by tanklist
		makearrays=1

	ENDIF ELSE BEGIN
		alltanks=0
		makearrays=0 ; don't bother writing arrays
	
	ENDELSE
	


;IF remote EQ 1 THEN BEGIN

;print, 'will need to change tanklist to new reference.co2c13 mode'

;	CCG_READ, file='/home/ccg/sil/initfiles/mscomptanklist.scenarios.txt',tanklist	
;	leg_charsize    = 1.3
;ENDIF ELSE BEGIN
	
;	CCG_READ, file='/home/ccg/sil/initfiles/mscomptanklist.means.txt',tanklist     ; this is the one you want for comparing means of tanks across many refs. 
;      but I have replaced this with a better way, using field 6 in the reference.co2c13 file. 


	tankfile='/projects/co2c13/flask/sb/reference.co2c13'
	temptankfileI= '/home/ccg/sil/tempfiles/tanktempI.txt'	
	CCG_SREAD, file = tankfile, skip = 0, temptanklist 
	; Now get rid of all non-data lines in the file, and save it
	m = WHERE(STRMID(temptanklist,0,1) NE '#')
	saved = temptanklist[m]
	CCG_SWRITE, file=temptankfileI, saved, /nomessages

	CCG_READ,file=temptankfileI,tanklist

	IF alltanks EQ 1 THEN BEGIN
		meanstanks=WHERE(tanklist.field6 GE 1,ntanks)
		tanklist=tanklist[meanstanks]
		;;CCG_READ, file='/home/ccg/sil/initfiles/mscomptanklist.means.txt',tanklist
	ENDIF

	IF alltanks EQ 1 THEN ntanks=N_ELEMENTS(tanklist) ELSE ntanks=1
	leg_charsize=1.4
	;IF calsdir EQ 'cals' THEN BEGIN
	;	CCG_READ, file='/home/ccg/sil/initfiles/refcodes3.txt',refcodes	; not sure this is necessary
	;ENDIF
	IF KEYWORD_SET(ref) THEN BEGIN
		tanksrunfile='/projects/co2c13/calsieg/internal_cyl/stats/tankreffiles/tanksrunby_'+ref+'.txt'
		CCG_READ,file=tanksrunfile,tanksrun
		ntanksrun=N_ELEMENTS(tanksrun)
		tanksrunarr=INTARR(ntanks)
		FOR t=0,ntanksrun-1 DO BEGIN
			here=WHERE(tanklist.field1 EQ tanksrun[t].field1)
			tanksrunarr[here]=1
			
		ENDFOR
		
		justthese=WHERE(tanksrunarr EQ 1)
		tanklist=tanklist[justthese]
		makearrays=0
		ntanks=N_ELEMENTS(tanklist)
		plotplease=1
		stop
	ENDIF		
;ENDELSE




nrefcodes=N_ELEMENTS(refcodes)

IF alltanks EQ 0 THEN BEGIN
	thistank=WHERE(tanklist.field1 EQ tank)
	IF thistank[0] NE -1 THEN BEGIN
		tanklist=tanklist[thistank]
		ntanks=1
		
	ENDIF ELSE BEGIN
	
	notthere=DIALOG_MESSAGE ('This tank is not in the tank list', title = 'Continue',/Question, /cancel)
	stop
			IF result EQ 'Cancel' THEN goto,bailout
			IF result EQ 'No' THEN goto,bailout
	ENDELSE
ENDIF

FOR s=0,nsp-1 DO BEGIN
	sp=sparr[s]
	IF makearrays EQ 1 THEN BEGIN
		meanarr=FLTARR(nrefcodes,ntanks)
		stdevarr=FLTARR(nrefcodes,ntanks)
		narr=INTARR(nrefcodes,ntanks)
	ENDIF
	
	FOR z=0,ntanks-1 DO BEGIN
		j=1 
		y1=0.9
		tank=tanklist[z].field1
		;print,z	
		print,tank
		
		IF runboth EQ 0 THEN BEGIN
			IF tanklist[z].field6 EQ 2 THEN trap=1 ELSE trap=0  
			
			;changed 
			nrb=1
			w=0
		ENDIF ELSE BEGIN
			nrb=2
			traparr=[0,1]
			w=0.5
		ENDELSE

		IF sp EQ 'co2c13' THEN sdknob=0.03 ELSE sdknob=0.06
		
		
			
		FOR q=0,nrb-1 DO BEGIN ; if you're running as both trap and non trap
	
			IF runboth EQ 1 then trap=traparr[q] 	
			;; trap/nottrap loop starts here
		
			IF trap EQ 1 THEN inst=tanklist[z].field14 
 			;IF trap EQ 1 THEN inst=STRCOMPRESS(STRING(inst),/REMOVE_ALL)
		
			IF trap EQ 1 THEN BEGIN
				tankfile='/projects/co2c13/'+calsdir[0]+'/internal_cyl/trapstat'+tank+'.co2c13.'+inst
			ENDIF ELSE BEGIN
				tankfile='/projects/co2c13/'+calsdir[0]+'/internal_cyl/'+tank+'.co2c13'
			ENDELSE

			thisstats='onept' ;default
			IF twptcal EQ 1 THEN thisstats='twpt' ; mix of onept and twpt
			if twptonly EQ 1 THEN thisstats='twptonly' ;twptonly
			
			IF runboth EQ 0 THEN BEGIN
				statsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+tank+'.stats.'+sp
				IF trap EQ 1 THEN statsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/trap'+tank+'.stats.'+sp
				
				allstatsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+tank+'.allstats.'+sp
			
				IF trap EQ 1 THEN allstatsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/trap'+tank+'.allstats.'+sp
			ENDIF ELSE BEGIN
				statsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+tank+'.stats.both.'+sp
				
				allstatsfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+tank+'.allstats.both.'+sp
			ENDELSE	
			
			PRINT, 'tankfile = ',tankfile
			tankfileexist = FILE_TEST(tankfile)
		
			IF tankfileexist NE 1 THEN GOTO,getout
			
			CCG_READ,file=tankfile,tdat

			IF onlyspock EQ 1 THEN BEGIN
				IF trap EQ 1 THEN spock=WHERE(tdat.field6 EQ 'o1') ELSE spock=WHERE(tdat.field20 EQ 'o1')
				IF spock[0] EQ -1 THEN GOTO, skipcompletely ELSE tdat=tdat[spock]
			ENDIF
			nt=N_ELEMENTS(tdat)
			IF plotsecrefs EQ 0 THEN BEGIN
				notusedassecref=INTARR(nt)
				FOR i=0,nt-1 DO BEGIN
					IF tdat[i].field20 EQ 'r1' THEN BEGIN
						notusedassecref[i]=1
						
					ENDIF ELSE BEGIN
						IF tdat[i].field12 EQ 0 THEN notusedassecref[i]=1
					ENDELSE
					
				ENDFOR
				keep=WHERE(notusedassecref EQ 1)
				tdat=tdat[keep]
			ENDIF
			
			IF tank EQ 'LOFN-001' THEN BEGIN
			
				keep=WHERE(tdat.field7 LE 2021)
				tdat=tdat[keep]
			ENDIF
			
			IF tank EQ 'GARB-001' THEN BEGIN
			
				keep=WHERE(tdat.field7 GE 2000)
				tdat=tdat[keep]
			ENDIF	
			
			IF tank EQ 'GARB-001' THEN BEGIN
			
				keep=WHERE(tdat.field7 LT 2023)
				tdat=tdat[keep]
			ENDIF		
			
			
			IF justoneref EQ 1 THEN BEGIN
				keep=WHERE(tdat.field25 EQ justref)
				tdat=tdat[keep]
			ENDIF
				
			nt=N_ELEMENTS(tdat)
			
			IF sp EQ 'co2c13' THEN BEGIN
				IF trap EQ 1 THEN BEGIN
					IF threedot EQ 1 THEN gooddat=WHERE(tdat.field20 EQ '...',ndat)
					IF threedot EQ 0 THEN gooddat=WHERE(STRMID(tdat.field20,0,2) EQ '..',ndat)
					IF repro EQ 1 THEN BEGIN
						checkflag=INTARR(ndat)
						FOR w=0,ndat-1 DO BEGIN
							IF (STRMID(tdat[w].field20,0,2) EQ '..') OR (STRMID(tdat[w].field20,0,2) EQ '#.') THEN checkflag[w]=1 ELSE checkflag[w]=0
						ENDFOR
						gooddat=WHERE(checkflag EQ 1,ndat)	
					ENDIF
					IF ndat LT 1 THEN goto,skipthis
					dat=tdat[gooddat]   ;dat = all unflagged
					print,'ndat=',ndat
					
					date=dblarr(ndat)
					FOR i=0,ndat-1 DO BEGIN
						CCG_DATE2DEC, yr=dat[i].field7,mo=dat[i].field8,dy=dat[i].field9,dec=dec
						date[i]=dec
					ENDFOR
					ndat=N_ELEMENTS(dat)
					
				
					print,'ndat=', ndat
					datesort=SORT(date)	
					date=date[datesort]	
					dat=dat[datesort]	
					twptarr=INTARR(ndat) ;in case you want to know who is twptcal corr
					data=FLTARR(ndat)
					IF twptcal EQ 1 THEN BEGIN
						FOR n=0,ndat-1 DO BEGIN
							IF ABS(dat[n].field26) GT 0.00111 THEN BEGIN
								data[n]=dat[n].field26 
								twptarr[n]=1
								
							ENDIF ELSE BEGIN
								data[n]=dat[n].field17
								twptarr[n]=0
							ENDELSE
						ENDFOR
					ENDIF ELSE BEGIN
						data=dat.field17
					ENDELSE
					
					ref=dat.field25
					instarr=dat.field6
					run=dat.field5

		
				ENDIF ELSE BEGIN
				
					IF threedot EQ 1 THEN gooddat=WHERE(tdat.field15 EQ '...',ndat)
					IF threedot EQ 0 THEN gooddat=WHERE(STRMID(tdat.field15,0,2) EQ '..',ndat)
					IF repro EQ 1 THEN BEGIN
						checkflag=INTARR(ndat)
						FOR y=0,ndat-1 DO BEGIN
							IF (STRMID(tdat[y].field15,0,2) EQ '..') OR (STRMID(tdat[y].field15,0,2) EQ '#.') THEN checkflag[y]=1 ELSE checkflag[y]=0
						ENDFOR
						gooddat=WHERE(checkflag EQ 1,ndat)	
					ENDIF
					print,'ndat=',ndat
				
					IF gooddat[0] NE -1 THEN dat=tdat[gooddat] ELSE goto, getout
				
					date=dblarr(ndat)	
					FOR i=0,ndat-1 DO BEGIN
						CCG_DATE2DEC, yr=dat[i].field7,mo=dat[i].field8,dy=dat[i].field9,dec=dec
						date[i]=dec
					ENDFOR
					
					
					ndat=N_ELEMENTS(dat)
					
					data=FLTARR(ndat)
					
					datesort=SORT(date)
					date=date[datesort]
					dat=dat[datesort]
					twptarr=INTARR(ndat) ;in case you want to know who is twptcal corr
					IF twptcal EQ 1 THEN BEGIN
						FOR n=0,ndat-1 DO BEGIN
						
							IF ABS(dat[n].field21) GT 0.00111 THEN BEGIN
								data[n]=dat[n].field21
								twptarr[n]=1
							
							ENDIF ELSE BEGIN
								data[n]=dat[n].field13
								twptarr[n]=0
								
							ENDELSE
						ENDFOR
						
					ENDIF ELSE BEGIN
						data=dat.field13
					ENDELSE
					
			
					ref=dat.field19
					instarr=dat.field20
					run=dat.field6
				
								
				ENDELSE
				
			ENDIF ELSE BEGIN   ;sp = 'co2o18'
				IF trap EQ 1 THEN BEGIN
					IF threedot EQ 1 THEN gooddat=WHERE(tdat.field24 EQ '...',ndat)
					IF threedot EQ 0 THEN gooddat=WHERE(STRMID(tdat.field24,0,2) EQ '..',ndat)
					IF repro EQ 1 THEN BEGIN
						checkflag=INTARR(ndat)
						FOR y=0,ndat-1 DO BEGIN
							IF (STRMID(tdat[y].field24,0,2) EQ '..') OR (STRMID(tdat[y].field24,0,2) EQ '#.') THEN checkflag[y]=1 ELSE checkflag[y]=0
						ENDFOR
						gooddat=WHERE(checkflag EQ 1,ndat)	
					ENDIF
					
					dat=tdat[gooddat]	
			
					date=fltarr(ndat)
					FOR i=0,ndat-1 DO BEGIN
						CCG_DATE2DEC, yr=dat[i].field7,mo=dat[i].field8,dy=dat[i].field9,dec=dec
						date[i]=dec
					ENDFOR
					;use=WHERE(date LT 2019.4)
					;dat=dat[use]
					;date=date[use]
					ndat=N_ELEMENTS(dat)
					twptarr=INTARR(ndat) ;in case you want to know who is twptcal corr
					data=FLTARR(ndat)
					
					datesort=SORT(date)
					date=date[datesort]
					dat=dat[datesort]
					IF twptcal EQ 1 THEN BEGIN
						FOR n=0,ndat-1 DO BEGIN
							IF ABS(dat[n].field27) GT 0.00111 THEN BEGIN
								data[n]=dat[n].field27 
								twptarr[n]=1
							ENDIF ELSE BEGIN
								data[n]=dat[n].field21
								twptarr[n]=0
							ENDELSE
						
						ENDFOR
				
					ENDIF ELSE BEGIN	
						data=dat.field21
					ENDELSE
					ref=dat.field25
					instarr=dat.field6
					run=dat.field5
				
				ENDIF ELSE BEGIN
					IF threedot EQ 1 THEN gooddat=WHERE(tdat.field18 EQ '...',ndat)
					IF threedot EQ 0 THEN gooddat=WHERE(STRMID(tdat.field18,0,2) EQ '..',ndat)
					
					IF repro EQ 1 THEN BEGIN
						checkflag=INTARR(ndat)
						FOR y=0,ndat-1 DO BEGIN
							IF (STRMID(tdat[y].field18,0,2) EQ '..') OR (STRMID(tdat[y].field18,0,2) EQ '#.') THEN checkflag[y]=1 ELSE checkflag[y]=0
						ENDFOR
						gooddat=WHERE(checkflag EQ 1,ndat)	
					ENDIF
					
					print,'ndat = ',ndat
					IF gooddat[0] EQ -1 THEN GOTO, skipthis
					dat=tdat[gooddat]
				
					date=fltarr(ndat)
					FOR i=0,ndat-1 DO BEGIN
						CCG_DATE2DEC, yr=dat[i].field7,mo=dat[i].field8,dy=dat[i].field9,dec=dec
						date[i]=dec
					ENDFOR	
					;use=WHERE(date LT 2019.4,ndat)
					;dat=dat[use]
					;date=date[use]
				
					twptarr=INTARR(ndat) ;in case you want to know who is twptcal corr
					data=FLTARR(ndat)
					IF twptcal EQ 1 THEN BEGIN
						FOR n=0,ndat-1 DO BEGIN
							IF ABS(dat[n].field22) GT 0.00111 THEN BEGIN
								data[n]=dat[n].field22
								twptarr[n]=1
							ENDIF ELSE BEGIN
								data[n]=dat[n].field16
								twptarr[n]=0
							ENDELSE
						ENDFOR
						
					ENDIF ELSE BEGIN
						data=dat.field16
					ENDELSE
					datesort=SORT(date)
					data=data[datesort]
					date=date[datesort]
					dat=dat[datesort]
					ref=dat.field19
					instarr=dat.field20
					run=dat.field6
					If getpressure EQ 1 THEN airpressure=dat.field23 ELSE airpressure=FLTARR(ndat)	
					If getpressure EQ 1 THEN co2pressure=dat.field24 ELSE co2pressure=FLTARR(ndat)		
				ENDELSE	
			ENDELSE				
			
			IF trap EQ 0 THEN BEGIN    ;getting average value for run
				mergecols=STRARR(ndat)
				FOR i=0,ndat-1 DO BEGIN
					mergecols[i]=STRCOMPRESS(run[i],/REMOVE_ALL)+'-'+STRCOMPRESS(instarr[i],/REMOVE_ALL)
				ENDFOR
				mergesort=SORT(mergecols)   ;alph vector
				mergesorted=mergecols[mergesort]  ;alphebetized merged run-inst
				uniqmerge=UNIQ(mergesorted)
				uniqmerged=mergesorted[uniqmerge]
				nuniq=N_ELEMENTS(uniqmerged)
			
				;;****** these are all the arrays of length nuniq - the  number of uniq runs. But they are in 'alphabetical' order, not by date
				thisinst=STRARR(nuniq)
				thisrun=STRARR(nuniq)
				thisco2press=FLTARR(nuniq)
				thisairpress=FLTARR(nuniq)
				
				sdarr=FLTARR(nuniq)	
				keepthis=intarr(nuniq)
				moarr=FLTARR(nuniq)	
				uniqref=STRARR(nuniq)
				uniqdate=FLTARR(nuniq)
				yestwpt=intarr(nuniq)
				howmanyper=INTARR(nuniq)	 ; this is here to make sure that two different versions of data are getting same number of samples
				co2press=FLTARR(nuniq)
				airpress=FLTARR(nuniq)
				
				
				; this was added 9/12/23 to cleanup bad runs. Refer to find_badstdruns.pro in michel
				
				IF filterbaddies EQ 1 THEN BEGIN
					goodies=INTARR(nuniq)
					
					newrunfile='/home/ccg/michel/tempfiles/badruns_co2c13.txt'
					CCG_READ,file=newrunfile,baddies
					baddies=baddies.field1
					FOR n=0,nuniq-1 DO BEGIN
						there=WHERE(uniqmerged[n] EQ baddies)
						IF there[0] EQ -1 THEN goodies[n]=1
					

					ENDFOR
					keep=WHERE(goodies EQ 1,nuniq)
					uniqmerged=uniqmerged[keep]
				ENDIF
				
				FOR n=0,nuniq-1 DO BEGIN
					dash=STRPOS(uniqmerged[n],'-')
					thislength=STRLEN(uniqmerged[n])
					thisinst[n]=STRMID(uniqmerged[n],dash+1,thislength-(dash+1))
					thisrun[n]=STRMID(uniqmerged[n],0,dash)
				ENDFOR
				
				dowekeepit=intarr(ndat)   ; can we fill this array with info on whether stdev is good? 
			
				FOR r=0,nuniq-1 DO BEGIN
				
					findthisrun=WHERE(run EQ FIX(thisrun[r]) AND instarr EQ thisinst[r],nthis)
					findthisrundata=data[findthisrun]
					findthisdate=date[findthisrun]
					findthisref=ref[findthisrun]
					findthisinst=instarr[findthisrun]
					;IF thisrun[r] EQ 1493 THEN stop
					
					mo=MOMENT(findthisrundata,sdev=sd)
					moarr[r]=mo[0]
					sdarr[r]=sd
					uniqref[r]=findthisref[0]
					uniqdate[r]=findthisdate[0]
					IF getpressure EQ 1 THEN co2press[r]=MEAN(dat[findthisrun].field24)
					IF getpressure EQ 1 THEN airpress[r]=MEAN(dat[findthisrun].field23)
					yestwpt[r]=twptarr[findthisrun[0]]
					
					IF sdarr[r] LE sdknob THEN BEGIN
						keepthis[r]=1
						dowekeepit[findthisrun]=1 
					ENDIF ELSE BEGIN
						keepthis[r]=0
						dowekeepit[findthisrun]=0 
					
					ENDELSE	
				
					IF nthis LT 2 then BEGIN
						keepthis[r]=0
						dowekeepit[findthisrun]=0 
					ENDIF
					IF nthis GT 10 then BEGIN
						;printthis run to a document, look it up later - not sure what I was doing with this...
						testfile='/home/ccg/sil/tempfiles/testruns.txt' ;testfile='/home/ccg/michel/tempfiles/testruns.txt'
						testformat='(A10,A3,I7,F11.4,I3)'					
						OPENU, u, testfile, /APPEND,/GET_LUN		
							PRINTF, u,format=testformat,tank, thisinst[r],thisrun[r],uniqdate[r],nthis
						FREE_LUN, u
					ENDIF
				;IF thisinst[r] EQ 'o1' THEN STOP
				ENDFOR

				;print,'keepthis ='
				;print,keepthis
				keepdata=WHERE(keepthis EQ 1,nkeep,COMPLEMENT=baddata)
		
				IF twptonly EQ 1 THEN BEGIN
					keepdata=WHERE(keepthis EQ 1 AND yestwpt EQ 1 AND uniqdate GT 2016,nkeep,COMPLEMENT=baddata)    ;this is for uniqruns
					;preservedata=WHERE(dowekeepit EQ 1 AND twptarr EQ 1 AND uniqdate GT 2016,nkeep,COMPLEMENT=baddata)    ;this is for allgood ndat
					baddata=WHERE(keepthis NE 1 AND yestwpt EQ 1 AND uniqdate GT 2016)  ; we don't want all the one pt data from this ref, just the bad twptonly data

				ENDIF
				
				IF keepdata[0] EQ -1 THEN print,'not enough good data to plot'
				;IF keepdata[0] EQ -1 THEN plotplease=0
				IF keepdata[0] EQ -1 THEN goto,skipthisone
				kruns=thisrun[keepdata]
				kdata=moarr[keepdata]
				ksdarr=sdarr[keepdata]
				kdate=uniqdate[keepdata]
				kref=uniqref[keepdata]
				kinst=thisinst[keepdata]
				
				kdat=dat[keepdata]
				IF getpressure EQ 1 THEN kco2press=co2press[keepdata]
				IF getpressure EQ 1 THEN kairpress=airpress[keepdata]
			
				bdata=moarr[baddata]
				bdate=uniqdate[baddata]
				bref=uniqref[baddata]	
				binst=thisinst[baddata]
		
			ENDIF ELSE BEGIN  ;yes it is a trap
	
				IF sp EQ 'co2c13' THEN keepdata=WHERE(ABS(dat.field18) LE sdknob,nkeep,COMPLEMENT=baddata)
				IF sp EQ 'co2o18' THEN keepdata=WHERE(ABS(dat.field22) LE sdknob,nkeep,COMPLEMENT=baddata)
		
				IF twptonly EQ 1 THEN BEGIN
					IF sp EQ 'co2c13' THEN BEGIN 
						keepdata=WHERE(dat.field18 LE sdknob AND twptarr EQ 1,nkeep)
						baddata=WHERE(dat.field18 GT sdknob AND twptarr EQ 1)
					ENDIF
					IF sp EQ 'co2o18' THEN BEGIN
						keepdata=WHERE(dat.field22 LE sdknob AND twptarr EQ 1,nkeep)
						baddata=WHERE(dat.field22 GT sdknob AND twptarr EQ 1)
					ENDIF
				;	preservedata=keepdata
				ENDIF 
				dowekeepit=INTARR(ndat)
				dowekeepit[keepdata]=1   ; filled with data to use
				IF keepdata[0] EQ -1 THEN goto,skipthisone
				nuniq=nkeep
				kdat=dat[keepdata]
				kdate=date[keepdata]
				IF sp EQ 'co2c13' THEN kdata=kdat.field17 ELSE kdata=kdat.field21
				IF sp EQ 'co2c13' THEN ksdarr=kdat.field18 ELSE ksdarr=kdat.field22
				y=WHERE(ksdarr LT 0)
				IF y[0] NE -1 THEN ksdarr[y]=0.04 ;; filler
				kref=ref[keepdata]	
				kinst=inst[keepdata]	
				kruns=run[keepdata]	
				bdata=data[baddata]
				bdat=dat[baddata]
				bdate=date[baddata]
				bref=ref[baddata]
				binst=inst[baddata]
				
			ENDELSE

			sortit=SORT(kref)          ; vector sorting the refs that measured this tank alphabetically
			sortedrefs=kref[sortit]   ; array sorted alphabetically
			refdate=kdate[sortit]   ; date array sorted by alph refs
		
			uniqrefsabc=UNIQ(sortedrefs)   ;vector of uniq refs, alphabetically
			urefsabcarr=sortedrefs[uniqrefsabc]
			;those dates. ..
			startrefdateabcarr=refdate[uniqrefsabc]   ;array of start dates in abc order
			sortrefdate=SORT(startrefdateabcarr)   ;vector
			refdate=startrefdateabcarr[sortrefdate] ;arr of start dates in date order
			reflist=urefsabcarr[sortrefdate]
			
			dewyishere=WHERE(reflist EQ 'DEWY-001',complement=notdewy)
			howmanyrefs=N_ELEMENTS(reflist)
			
			
			IF includedewy EQ 1 THEN BEGIN
				IF dewyishere[0] NE -1 THEN BEGIN
					IF howmanyrefs GT 1 THEN reflist=[reflist[notdewy],reflist[dewyishere]] ELSE reflist=reflist[notdewy]
				ENDIF
			ENDIF ELSE BEGIN
				reflist=reflist[notdewy]
			ENDELSE	
			
			nrefs=N_ELEMENTS(reflist)
			refinstr=STRARR(nrefs)
			refinstarr=INTARR(nrefs)
			refnumarr=intarr(nrefs)
	
			;now start going through refs
			
			FOR n=0,nrefs-1 DO BEGIN
				
				wheretis=WHERE(reflist[n] EQ refcodes.field1)
				IF wheretis NE -1 THEN BEGIN
   					refnumarr[n]=(refcodes[wheretis].field2)
   					refinst=refcodes[wheretis].field3
   				ENDIF ELSE BEGIN
  					refnumarr[n]=0	
   					refinst=1
   				ENDELSE
   				IF refinst EQ 0 THEN refinstr[n]='r1' 
   				IF refinst EQ 1 THEN refinstr[n]='o1' 
   				IF refinst EQ 2 THEN refinstr[n]='i2'
   				IF refinst EQ 4 THEN refinstr[n]='i4'
   				IF refinst EQ 6 THEN refinstr[n]='i6'
			ENDFOR	

			IF remote EQ 0 THEN BEGIN  ; call window from here
				IF savegraphs EQ 1 THEN BEGIN
					dev='png'
					IF runboth EQ 0 THEN BEGIN
						IF trap EQ 1 THEN BEGIN
							IF writestats EQ 1 THEN $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/trap'+tank+'.stats.'+sp+'.'+dev $
							ELSE $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/trap'+tank+'.nostats.'+sp+'.'+dev
						ENDIF ELSE BEGIN
							IF writestats EQ 1 THEN $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.stats.'+sp+'.'+dev $
							ELSE $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.nostats.'+sp+'.'+dev	
							ENDELSE	
					ENDIF ELSE BEGIN
						IF writestats EQ 1 THEN $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.statsboth.'+sp+'.'+dev $
							ELSE $
							savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.'+sp+'.both.'+dev
					ENDELSE
				ENDIF
				
			ENDIF ELSE BEGIN
				IF savegraphs EQ 1 THEN BEGIN
				dev='png'
					IF runboth EQ 0 THEN BEGIN
						IF trap EQ 1 THEN BEGIN	
						savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/trap'+tank+'.scen.'+sp+'.'+dev
						ENDIF ELSE BEGIN
						savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.scen.'+sp+'.'+dev
						ENDELSE	
					ENDIF ELSE BEGIN
						
						savename='/projects/co2c13/'+calsdir+'/internal_cyl/plots/'+thisstats+'/'+tank+'.scen.'+sp+'.'+dev
					ENDELSE
				ENDIF	
			ENDELSE	

			IF n_elements(data) LT 2 THEN GOTO,skipcompletely

	
			IF plotplease EQ 1 THEN BEGIN
				;plotting variables
				IF remote EQ 0 THEN symsize= 0.8 ELSE symsize=0.45
				IF nuniq GT 100 THEN symsize=symsize-0.1 ELSE symsize=symsize

				IF remote EQ 0 THEN fontsize= 18 ELSE fontsize=15
				xpixels = 1200
				ypixels  = 800 
				IF sp EQ 'co2c13' THEN ymin=MEDIAN(data)-0.15 ELSE  ymin=MEDIAN(data)-0.30
				IF sp EQ 'co2c13' THEN ymax=MEDIAN(data)+0.15 ELSE  ymax=MEDIAN(data)+0.30
				IF printstats EQ 1 THEN rightside=0.7 ELSE rightside=0.85
				IF remote EQ 0 THEN BEGIN
					top=0.87
					ry=0.4
					ourposition=[0.15,ry,rightside,top] 
					plotht=top-ry
				ENDIF ELSE BEGIN
					print,scenario
					top=0.9
					bottom=0.1
					plotht=(top-bottom)/howmany
					;plotht=0.28
				 	ry=top-(plotht*scenario)
					ourposition=[0.11,ry,rightside,ry+plotht]
				ENDELSE

				IF q EQ 0 THEN BEGIN
					xmin=FIX(date[0])
					xmax=FIX(date[ndat-1]+1)
				ENDIF
				IF q EQ 1 THEN BEGIN
					IF FIX(date[0]) LT xmin THEN xmin=FIX(date[0])
					IF FIX(date[ndat-1]+1) GT xmax THEN xmax=FIX(date[ndat-1]+1)
				ENDIF 
				nyrs=xmax-xmin+1
				xarr=INDGEN(nyrs)+xmin
				nullarr=REPLICATE(' ',nyrs)
				ourxmin=xmin
				ourxmax=xmax+0.5   ; if you need to call this from plot_scenarios it could be done, but shouldn't be necessary
			
				IF sp EQ 'co2c13' THEN ourytitle='$\delta$$^{13}$C - CO$_2$ ($\permil$)' ELSE ourytitle='$\delta$$^{18}$O - CO$_2$ ($\permil$)'
			
				 params={linestyle:6, $
				 font_name: 'Helvetica',$
				 sym_filled: 1,$
				 thick:3, $
				sym_size:symsize,$
				 
				font_size:15,$
				 ytickdir: 1}  	
		
				IF remote EQ 1 THEN BEGIN
					ourdimensions=[1200,900]
		
					IF scenario EQ 1 THEN thisplot=WINDOW(location=[100,100],dimensions=ourdimensions) 
					
					IF scenario EQ 1 THEN thiscurrent=1 ELSE thiscurrent=1   ; changed from 0,1
					IF scenario EQ howmany THEN ourxtitle='date' else ourxtitle=''
					IF scenario EQ howmany THEN xshow=1 else xshow=0

				ENDIF ELSE BEGIN
					ourdimensions=[1200,600]
					IF runboth EQ 0 THEN thisplot=WINDOW(location=[100,100],dimensions=ourdimensions) 
					IF runboth EQ 1 AND q EQ 0 THEN thisplot=WINDOW(location=[100,100],dimensions=ourdimensions) 
					thiscurrent=1  ;0
					ourxtitle='date'
					xshow=1
				ENDELSE
				
				If forcexrange EQ 1 THEN BEGIN
					ourxmin=2023
					PRINT,'********-----FORCING xrange to make plots ffor presentation''
				ENDIF	
				IF q EQ 0 THEN thisoverplot=0 ELSE thisoverplot=1
				
					thisplota=PLOT(date,data,$   	    ; this is everything, printed in white
					POSITION=ourposition,$
					xrange=[ourxmin,ourxmax],$   ; xrange should now be the same for all 3
					YRANGE=[ymin,ymax],$
					YSTYLE=1,$
					YMINOR=2 ,$
					symbol='dot',$
					color='white',$	
					;YTITLE=ourytitle,$
					XTITLE=ourxtitle,$
					current=thiscurrent,$
					overplot=thisoverplot,$
					_extra=params)
				
				thisplota['axis2'].transparency=100
				thisplota['axis3'].transparency=100
				IF plottitle EQ 1 THEN BEGIN
					IF trap EQ 1 THEN BEGIN
						IF scenario EQ 1 THEN titletext=TEXT(0.09,0.94,'trap ' + tank,/normal,$
						font_size=18,/current)
						ENDIF ELSE BEGIN
						titletext=TEXT(0.09,0.94, tank,/normal,$
						font_size=18,/current)
					 ENDELSE
				ENDIF
				IF remote EQ 1 THEN BEGIN
					IF xshow EQ 1 THEN BEGIN
						thisplota['axis0'].showtext='date'
						thisplota['axis2'].showtext=0
						thisplota['axis1'].title= ourytitle
					ENDIF ELSE BEGIN
						thisplota['axis0'].showtext=0
						thisplota['axis2'].showtext=0
						thisplota['axis1'].title=ourytitle
					ENDELSE
				ENDIF ELSE BEGIN
					thisplot['axis1'].showtext=1
					thisplot['axis1'].title= ourytitle
				ENDELSE
	
				IF remote EQ 0 THEN nametext=TEXT(0.14, top+0.02,'surveillance tank: ' + tank,font_size=20,/current)

				IF remote EQ 1 AND scenario EQ 1 THEN nametext=TEXT(0.14, top+0.25,'surveillance tank: ' + tank,font_size=20,/current)
			IF remote EQ 1 THEN BEGIN
			calsdirtxt=TEXT(0.9,0.6-((scenario-1)*0.5),calsdir)
		
			ENDIF ELSE BEGIN
			
			calsdirtxt=TEXT(0.9,0.1,calsdir)
			ENDELSE
			ENDIF ; plotplease. Because you might just want data

			j=0	
			carr=STRARR(nrefs)
			bigcarr=['green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
				'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue',$
				'light green','maroon','sky blue','plum','cadet blue','dark sea green','coral','firebrick','indigo','orange red',$
				'dodger blue','purple','forest green','light steel blue','tomato','hot pink',$
				'chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
				'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue','black','purple',$
				'green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown']
				
			IF allonecolor THEN BEGIN
				bigcarr=['black']
				for i=0,36 DO bigcarr=[bigcarr,'black']	
			ENDIF
			FOR i=0,nrefs-1 DO BEGIN
				
				PRINT,reflist[i]
	
		        	refnumspot=WHERE(refcodes.field1 EQ reflist[i])
				
				IF refnumspot[0] NE -1 THEN BEGIN
					refnum=refcodes[refnumspot].field2  ; could use refnumarr[i]
					instnum=refcodes[refnumspot].field3
					thiscarr=refcodes[refnumspot].field2  ;;not reading colors, just using index
					carr[i]=bigcarr[thiscarr]
					
					
					
				;print,'refnum =',refnum
				
				ENDIF ELSE BEGIN
				;print,'refnum=0'
					refnum=0
					instnum=1
				
					GOTO, skip
				ENDELSE
		
				r1=WHERE(kref EQ reflist[i],num1)

				r1dat=kdata[r1]
				;IF num1 EQ 1 THEN r1dat=[r1dat,r1dat]
				r1sd=ksdarr[r1]
				;IF num1 EQ 1 THEN r1sd=[r1sd,r1sd]
				r1date=kdate[r1]
				;IF num1 EQ 1 THEN r1date=[r1date,r1date]
				IF getpressure EQ 1 THEN r1co2press=kco2press[r1]
				IF getpressure EQ 1 THEN r1airpress=kairpress[r1]
				;print,num1
				;print,r1dat
				;print,r1sd
				;print,'keepdata = '
				
			
				IF baddata[0] NE -1 THEN BEGIN
					br1=WHERE(bref EQ reflist[i],numb1)
					IF br1[0] NE -1 THEN BEGIN
						br1dat=bdata[br1]
						br1date=bdate[br1]
					ENDIF
				ENDIF
				;print, '       '
				;print, 'baddata = '
				;print,thisrun[baddata[br1]]	
				;print,inst[baddata[br1]]	
		
			
				IF num1 GT 1 THEN BEGIN
				mo=MOMENT(r1dat,sdev=sd)
				;print,'sd =',sd
				uplimit=mo[0]+(2*sd)
				;print,'uplimit = ',uplimit
				downlimit=mo[0]-(2*sd)
				;print,'downlimit= ',downlimit
				;print,'range = ',uplimit-downlimit
				
				ENDIF ELSE BEGIN
				mo=MOMENT(r1dat)
				IF sp EQ 'co2c13' THEN sd=0.03 ELSE  sd=0.06
				uplimit=mo[0]+(2*sd)
				downlimit=mo[0]-(2*sd)
				
				ENDELSE
				
				;stop
				printdata=WHERE((r1dat GT downlimit AND r1dat LT uplimit),nprint,complement=outdata)   ; print data is stuff within "boundary"
				;print,'nprint = ',nprint
				IF printdata[0] NE -1 THEN BEGIN
					r1dategood=r1date[printdata]
					r1datgood=r1dat[printdata]
					r1sdgood=r1sd[printdata]
					r1runs=kruns[r1[printdata]]
					r1inst=kinst[r1[printdata]]
					IF getpressure EQ 1 THEN r1co2pressgood=r1co2press[printdata]
					IF getpressure EQ 1 THEN r1airpressgood=r1airpress[printdata]
				        r1datebad=r1date[outdata]
					
					r1datbad=r1dat[outdata]
					newmo=MOMENT(r1datgood,sdev=newsd)
					
				ENDIF
			

				;plotplease
				IF plotplease EQ 1 THEN BEGIN
					;IF remote EQ 1 THEN BEGIN
					;	IF i EQ 0 THEN thisr1overplot=1	
					IF q EQ 0 THEN symbol = 'circle' ELSE symbol = 'triangle'
					IF instsym EQ 1 THEN symbol=symarr[instnum]
					IF getpressure EQ 0 THEN BEGIN
						r1plot=PLOT(r1dategood,r1datgood,$
						THICK=0,$            
	        		        	color=carr[i],$
						 symbol= symbol,$
						_extra=params,$
						overplot=1) 
						;stop
					ENDIF ELSE BEGIN
				
					max=40 
					min=0
					
						scalestretch=255.0/(max-min)
						IF pressuretype EQ 'co2' then pressuredata=r1co2pressgood ELSE pressuredata=r1airpressgood
						pressurecolor=pressuredata*scalestretch
						datahere=WHERE(pressuredata NE 0,ndata)
						IF ndata GT 1 THEN thisfill=1 ELSE thisfill=0
						r1plot=PLOT(r1dategood,r1datgood,/overplot,rgb=13,vert_color=pressurecolor,symbol='circle',sym_filled=thisfill,linestyle=6)
						errbars=0
					;IF reflist[i] EQ 'CHIC-002' THEN stop
					
					ENDELSE
				
						IF errbars EQ 1 THEN BEGIN
							bars=ERRORPLOT(r1dategood,r1datgood,r1sdgood,/OVERPLOT,linestyle=6)	
							bars.errorbar_color=carr[i]
							bars.errorbar_capsize=0.06
							bars.errorbar_thick=0.8
							bars.errorbar_linestyle=0
						ENDIF	
					
					IF plotbaddata EQ 1 THEN BEGIN
						IF outdata[0] NE -1 THEN BEGIN  ;opposite of printdata
							IF N_ELEMENTS(outdata) EQ 1 THEN BEGIN
								r1datebad=[r1datebad,r1datebad]
								r1datbad=[r1datbad,r1datbad]
							ENDIF
							r1badplot=PLOT(r1datebad,r1datbad,$    ;2 sigma outside of mean
							THICK=0,$  
							symbol='x',$           
	        		        		color=carr[i],$
							_extra=params,$
							/overplot) 
						ENDIF
					ENDIF
					IF plotbadsddata EQ 1 THEN BEGIN
				
						IF baddata[0] NE -1 THEN BEGIN
							IF br1[0] NE -1 THEN BEGIN
								;CCG_SYMBOL, sym=10,fill=0
								br1plot=PLOT(br1date,br1dat,$        ;stdev bad         
		        				        COLOR=carr[i],$
								symbol='plus',$
								_extra=params,$
								/overplot) 
							ENDIF	
						ENDIF
					ENDIF
					;IF reflist[i] EQ 'DUMB-001' THEN stop
				ENDIF	  ;plotplease
		           
				;;stats files are NOW printing all data with good stdev(kdata) and within bounds to statsfile
				;; num1 is the number of that ref of kdata. used to be nprint, which was a mistake)
				;print,'figure out what you're printing'
				; now having runboth print to the same file. ..
				
				statsformat='(A9,A4,I7,I3,F12.5,F8.3,F8.3)'
				;;	ref, inst, runnum, trap, mean, stdev
				IF runboth EQ 0 THEN BEGIN
					IF j EQ 0 THEN newfile=1 ELSE newfile=0
				ENDIF ELSE BEGIN	
					IF q EQ 0 AND j EQ 0 THEN newfile=1 ELSE newfile=0
				ENDELSE
				IF writestats EQ 1 THEN BEGIN
					;print a mean and stdev of each run
					IF newfile eq 1 THEN BEGIN		
						OPENW, u, statsfile,/GET_LUN	
						;	ref, inst, runnum, trap, mean, stdev
						FOR t=0,nprint-1 DO PRINTF, u,format=statsformat, reflist[i],r1inst[t], STRTRIM(r1runs[t],2),trap,r1dategood[t],r1datgood[t],r1sdgood[t]
						FREE_LUN, u
						
					
					ENDIF ELSE BEGIN
						OPENU, u, statsfile, /APPEND,/GET_LUN		
						;	ref, inst, runnum, trap, mean, stdev
						FOR t=0,nprint-1 DO PRINTF, u,format=statsformat, reflist[i],r1inst[t], STRTRIM(r1runs[t],2),trap,r1dategood[t],r1datgood[t],r1sdgood[t]
						FREE_LUN, u
					ENDELSE
				ENDIF		
		
				; showdata
				IF plotplease EQ 1 THEN BEGIN
					IF showdata EQ 1 THEN BEGIN
						IF nrefs LT 10 THEN BEGIN
							x=0.22
							f=0.06
							h=0.027
						ENDIF ELSE BEGIN
							x=0.22 
							f=0.05
							h=0.021
						ENDELSE
					
						IF nrefs GE 15 THEN BEGIN
							x=0.23
							f=0.04
						ENDIF
						IF nrefs GT 20 THEN BEGIN
							x=0.26
							f=0.03
						ENDIF
						x1=rightside+0.02
					
						IF remote EQ 0 THEN BEGIN
							;y1=0.83-(j*f)-(q*w)  ; j=ref index; f=spacing;q=runboth,w="set"
							;y2=0.82-(j*f)-(q*w)
							
							;y1=0.86-(j*f*(q+1)) ;;-(q*w)  ; j=ref index; f=spacing;q=runboth,w="set"
							y1=y1-f
							
							;y2=0.82-runboth*(j*(f*(q+1))) ;;-(q*w)
							IF nrefs LT 10 THEN thisfontsize=18 ELSE thisfontsize=14   ;??
						
						ENDIF ELSE BEGIN
							IF nrefs LT 10 THEN BEGIN
								h=0.022
								thisfontsize=15
							ENDIF ELSE BEGIN
								 h=0.02
								thisfontsize=14
							ENDELSE
				
							IF nrefs GT 14 THEN BEGIN	
								h=0.012
								thisfontsize=11
							ENDIF
							
							IF printstats EQ 0 then thisfontsize=thisfontsize*1.5
							IF printstats EQ 0 then h=h*1.5
							y1=ry+plotht-((j+1)*h)
							y2=ry+plotht-((j+1)*h)
							;print,'j = ',j
						ENDELSE
						
						
						;kdata excludes br1dat (outliers) above. If you want avg and stdev including outliers, do something different
						IF printstats EQ 1 THEN BEGIN
							avg=STRCOMPRESS(STRING(newmo[0],FORMAT=('(F7.3)')),/REMOVE_ALL)
							stdevn=STRCOMPRESS(STRING(newsd,FORMAT='(F7.3)'),/REMOVE_ALL)
							IF runboth EQ 1 THEN leadingtr='tr' ELSE leadingtr=''
							IF trap EQ 0 THEN text1=TEXT(x1,y1, reflist[i] + ' : '+avg +'   sd= '+ stdevn $
								+'  n= '+ STRMID(STRCOMPRESS(STRING(nprint),/REMOVE_ALL),0,5),/current,font_size=thisfontsize,color=carr[i]) $
								ELSE $
								text1=TEXT(x1,y1, leadingtr+ reflist[i] + ' : '+avg +'   sd= '+ stdevn $
								+'  n= '+ STRMID(STRCOMPRESS(STRING(nprint),/REMOVE_ALL),0,5),/current,font_size=thisfontsize,color=carr[i])
						
						ENDIF ELSE BEGIN
							IF scenario EQ 1 THEN text1=TEXT(x1,y1, reflist[i],/current,font_size=thisfontsize,color=carr[i])
						ENDELSE	
				
					;create array to send to other programs (refs_j62.pro)			
					ENDIF ELSE BEGIN
						f=0.06
					ENDELSE	;showdata
					;IF remote EQ 0 THEN BEGIN
				
				ENDIF ELSE BEGIN
				f=9
				ENDELSE
				; make file of each ref for the tank. To put printstats data onto a table. 
				IF writestats EQ 1 THEN BEGIN
					sumformat='(A10,A4,F8.3,F8.3,I4,I3)'
					tanksumfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+tank+'.sum.'+sp
					thisheader='tank inst avg sd n'
					IF q EQ 0 AND i EQ 0 THEN BEGIN
						OPENW, u, tanksumfile,/GET_LUN	
						PRINTF,u, thisheader
						PRINTF, u,format=sumformat,reflist[i],refinst,newmo[0],newsd,nprint, trap
						FREE_LUN, u
					ENDIF ELSE BEGIN
						OPENW, u, tanksumfile,/GET_LUN,/APPEND
						PRINTF, u,format=sumformat,reflist[i],refinst,newmo[0],newsd,nprint, trap
						FREE_LUN, u
					
					ENDELSE	
					
					
					;change the way you do all statfile. 1/7/24
					IF i eq 0 THEN BEGIN
						OPENW, u, allstatsfile,/GET_LUN	
						;	ref, inst, runnum, trap, mean, stdev
						FOR t=0,nprint-1 DO PRINTF, u,format=statsformat, reflist[i],r1inst[t], STRTRIM(r1runs[t],2),trap,r1dategood[t],r1datgood[t],r1sdgood[t]
						;this is how it's printed below ...
						;IF trap EQ 0 THEN FOR t=0,nuse-1 DO PRINTF, u,format=statsformat,usethisdat[usedata[t]].field19, usethisdat[usedata[t]].field20,usethisdat[usedata[t]].field6,trap,usethisdate[usedata[t]],usethisdata[usedata[t]]
						;	
						;IF trap EQ 1 THEN FOR t=0,nuse-1 DO PRINTF, u,format=statsformat,usethisdat[usedata[t]].field25, usethisdat[usedata[t]].field6,usethisdat[usedata[t]].field5,trap,usethisdate[usedata[t]],usethisdata[usedata[t]]
						;	
						FREE_LUN, u
					
					
					ENDIF ELSE BEGIN
						OPENW, u, allstatsfile,/GET_LUN,/APPEND	
						;	ref, inst, runnum, trap, mean, stdev
						FOR t=0,nprint-1 DO PRINTF, u,format=statsformat, reflist[i],r1inst[t], STRTRIM(r1runs[t],2),trap,r1dategood[t],r1datgood[t],r1sdgood[t]
						FREE_LUN, u
					
					ENDELSE
				ENDIF	
				;make arrays used to go here.
				j=j+1
				skip: 
				
			ENDFOR  ; ref loop
			
			; also want all of the data in ndat that is good. ...
			; but this doesn't filter out fliers.
				;lookatdowekeepit
				justthegoodstdev=WHERE(dowekeepit EQ 1,nyesallstats)  ; same as keepdata
				usethisdata=data[justthegoodstdev]
				usethisdat=dat[justthegoodstdev]
				usethisdate=date[justthegoodstdev]
				totalmean=MOMENT(usethisdata,sdev=sdev)
				IF s EQ 0 THEN sdknob=sdev*3 ELSE sdknob=sdev*4     
				uplim=totalmean[0]+(sdknob)
				;print,'uplimit = ',uplim
				downlim=totalmean[0]-(sdknob)
				;print,'downlimit= ',downlim
				;print,'range = ',uplim-downlim
				;stop
				usedata=WHERE((usethisdata GT downlim AND usethisdata LT uplim),nuse,complement=donotuse)   ; print data is stuff within "boundary"
				;IF writestats EQ 1 THEN BEGIN
				;	OPENW, u, allstatsfile,/GET_LUN
				;	;	ref, inst, runnum, trap, date, mean, stdev
				;	IF trap EQ 0 THEN FOR t=0,nuse-1 DO PRINTF, u,format=statsformat,usethisdat[usedata[t]].field19, usethisdat[usedata[t]].field20,usethisdat[usedata[t]].field6,trap,usethisdate[usedata[t]],usethisdata[usedata[t]]
				;	IF trap EQ 1 THEN FOR t=0,nuse-1 DO PRINTF, u,format=statsformat,usethisdat[usedata[t]].field25, usethisdat[usedata[t]].field6,usethisdat[usedata[t]].field5,trap,usethisdate[usedata[t]],usethisdata[usedata[t]]
				;				
				;
				;FREE_LUN, u
				;ENDIF	
			IF getpressure EQ 1 THEN BEGIN
				IF plotplease EQ 1 THEN BEGIN
				IF pressuretype EQ 'co2' THEN colorbarname='sample co2 pressure (mbar)' ELSE colorbarname='sample air pressure (psi)'
					c=COLORBAR(target=thisplotdat,orientation=0,rgb_table=13,position=[0.13,0.1,0.9,0.18],title=colorbarname,range=[0,40])
					c.font_size=16
					c.tickdir=1
					c.textpos=0
				ENDIF
			ENDIF
			
			skipcompletely:
			skipthisone:
			skipthis:
			getout:
		ENDFOR  ; runboth loop  ; runboth should really only be on for a single tank
	
		f=0
		allsumdatfilehere=FILE_TEST(allstatsfile)
		sumdatfilehere=FILE_TEST(statsfile)
		
		IF allsumdatfilehere NE 0 THEN BEGIN
		print, '-------------tank is ', tank, '-------------'
		print,allstatsfile
				
			CCG_READ,file=allstatsfile,allsumdat

			IF remote EQ 0 THEN BEGIN
				IF printstats EQ 1 THEN y1=0.84-(j*f) ELSE y1=0.77
					
			ENDIF
			
			IF printstats EQ 1 THEN x2=0.8 ELSE x2=0.75
			totalmo=MOMENT(allsumdat.field6,sdev=sdev)  ; this is the average of all unflagged data - used for asessing success of bootstrapping
			
		
			PRINT, 'total reproducibility of '+tank+ ' = '+STRMID(STRCOMPRESS(STRING(sdev),/REMOVE_ALL),0,5)
			IF keepdata[0] NE -1 THEN BEGIN
				IF plotplease EQ 1 THEN BEGIN 
					IF remote EQ 0 THEN offset=0.06 ELSE offset=0.03
				
					alltext=TEXT(0.17,ry+plotht-offset,'mean =  '+STRMID(STRCOMPRESS(STRING(totalmo[0]),/REMOVE_ALL),0,6)+'   sd = '+ STRMID(STRCOMPRESS(STRING(sdev),/REMOVE_ALL),0,5),$
					 /current,font_size=fontsize)
					IF remote EQ 1 THEN BEGIN
				
						scentext=TEXT(0.17,ry+plotht-offset-0.03,STRCOMPRESS(STRING(calsdirstr),/REMOVE_ALL),/current,font_size=fontsize)
					ENDIF 
				
					IF remote EQ 0 THEN BEGIN			
						IF savegraphs EQ 1 THEN BEGIN
							dev='png'
							thisplot.save,savename
							print,'z = ',z

							thisplot.close
						
						ENDIF 
					ENDIF ELSE BEGIN
					 	IF savegraphs EQ 1 THEN BEGIN
					 		IF scenario EQ howmany THEN BEGIN
					 			
								thisplota.save,savename
					 			thisplota.close
					 		ENDIF
						ENDIF
					ENDELSE
				ENDIF 
			ENDIF ELSE BEGIN
					print, 'Not enough data for a plot!'
			ENDELSE
			; if you want to have the tankmeans file include trap and non trap data,  have to read in stats file again and separate by ref
			IF makearrays EQ 1 THEN BEGIN
				IF sumdatfilehere NE 0 THEN BEGIN
					CCG_READ,file=statsfile,sumdat
					;need to get nrefs again because it might have changed with q=1
				
					sortsum=SORT(sumdat.field1)
					nrefsum=UNIQ(sumdat[sortsum].field1)
					nrefs=N_ELEMENTS(nrefsum)
					reflist=sumdat[sortsum[nrefsum]].field1
					
					FOR i=0,nrefs-1 DO BEGIN
					refnumspot=WHERE(refcodes.field1 EQ reflist[i])
					
						refnum=refcodes[refnumspot].field2 
						here=WHERE(sumdat.field1 EQ reflist[i],nrefshere)
						
						IF here[0] NE -1 THEN BEGIN
							refmo=MOMENT(sumdat[here].field6,sdev=sdev)
							;IF tank EQ 'MIST-001' THEN stop				
							;tanks increment by z	
							;refs by i
							;format=[columns,rows]=[refs,tank]
							meanarr[refnumspot,z]=refmo[0]
							stdevarr[refnumspot,z]=sdev
							narr[refnumspot,z]=nrefshere
						ENDIF
					ENDFOR	
				ENDIF
			ENDIF
			
		ENDIF
	
		IF lookfordrift EQ 1 THEN BEGIN
			CCG_READ,file=statsfile,statsdata
			
			nstats=N_ELEMENTS(statsdata)
			result=SVDFIT(statsdata.field5-statsdata[0].field5,statsdata.field6,a=[0.],measure_errors=statsdata.field7,chisq=chisq1,sigma=sigma1,yfit=yyfit1)
			result2=SVDFIT(statsdata.field5-statsdata[0].field5,statsdata.field6,a=[0.,0.],measure_errors=statsdata.field7,chisq=chisq1,sigma=sigma1,yfit=yyfit2)
			IF plotplease EQ 1 THEN BEGIN
					
				thisline=PLOT(statsdata.field5,yyfit1,linestyle=1,color='green',OVERPLOT=1)
				thisline2=PLOT(statsdata.field5,yyfit2,linestyle=1,color='blue',OVERPLOT=1)
				
			
			ENDIF
			CCG_READ,file='/home/ccg/michel/tempfiles/chisqprobs.txt',chisq,skip=1

 
			probs=FLTARR(12,38)
			df=INTARR(38)
			df[0]=0
			FOR d=1,37 DO df[d]=chisq[d].field1
			FOR b=0,37 DO BEGIN
			 	probs[0,b]=chisq[b].field2
				probs[1,b]=chisq[b].field3
				probs[2,b]=chisq[b].field4
				probs[3,b]=chisq[b].field5
				probs[4,b]=chisq[b].field6
				probs[5,b]=chisq[b].field7
				probs[6,b]=chisq[b].field8
				probs[7,b]=chisq[b].field9
				probs[8,b]=chisq[b].field10
				probs[9,b]=chisq[b].field11
				probs[10,b]=chisq[b].field12
				probs[11,b]=chisq[b].field13
			ENDFOR

			
			; find degrees freedom
			thisline=WHERE(probs[0,*] EQ j-1)
			; now go see on that line where the chisq falls

			; find degrees freedom
			thisline=WHERE(df EQ nstats)
			; now go see on that line where the chisq falls

			FOR i=0,10 DO BEGIN
				; go through each line
				IF probs[i+1,thisline] GT chisq1 THEN BEGIN
					match=i   ; will give you a vector
					GOTO,out
				ENDIF ELSE BEGIN
					match=11
				ENDELSE
			ENDFOR
			out:
		
		ENDIF
			
		 IF onebyone EQ 1 THEN BEGIN 
	 			IF (alltanks EQ 0) AND (s EQ 1) THEN goto, skipask
				
	   			IF plotplease EQ 1 THEN BEGIN
					result=DIALOG_MESSAGE ('Next Plot?', title = 'Continue',/Question, /cancel)
					IF result EQ 'Cancel' THEN goto,bailout
					IF result EQ 'No' THEN z=z-1
				ENDIF
				skipask:
		ENDIF
	ENDFOR   ; surveillance tank list
	IF writestats EQ 1 THEN BEGIN
	IF makearrays EQ 1 THEN BEGIN
		;print arrays here
		meanarrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.meanfile.txt'
		sdarrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.sdfile.txt'
		narrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.nfile.txt'
		arrformat='(A8,1X,36(F10.5,1X))'
		header='tankname '
		FOR r=0,nrefcodes-1 DO BEGIN
			header=header+STRCOMPRESS(refcodes[r].field1)+' '
		ENDFOR
		FOR p=0,0 DO BEGIN
			OPENW, u, meanarrfile,/GET_LUN	
			PRINTF,u, header
			PRINTF, u,format=arrformat,tanklist[p].field1,meanarr[*,p]
			FREE_LUN, u
			OPENW, u, sdarrfile,/GET_LUN	
			PRINTF,u, header	
			PRINTF, u,format=arrformat,tanklist[p].field1,stdevarr[*,p]
			FREE_LUN, u
			OPENW, u, narrfile,/GET_LUN
			PRINTF,u, header	
			PRINTF, u,format=arrformat,tanklist[p].field1,narr[*,p]
			FREE_LUN, u
		ENDFOR
		
		FOR p=1,ntanks-1 DO BEGIN
			OPENU, u, meanarrfile,/GET_LUN,/APPEND			
				PRINTF, u,format=arrformat,tanklist[p].field1,meanarr[*,p]	
				FREE_LUN, u
			OPENU, u, sdarrfile,/GET_LUN,/APPEND		
				PRINTF, u,format=arrformat,tanklist[p].field1,stdevarr[*,p]
				FREE_LUN, u
			OPENU, u, narrfile,/GET_LUN,/APPEND
				PRINTF, u,format=arrformat,tanklist[p].field1,narr[*,p]
				FREE_LUN, u
		ENDFOR
	
		meanarrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.meanfile.sav'
		sdarrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.sdfile.sav'
		narrfile='/projects/co2c13/'+calsdir+'/internal_cyl/stats/'+thisstats+'/'+sp+'.nfile.sav'	

		SAVE,meanarr,filename=meanarrfile	
		SAVE,stdevarr,filename=sdarrfile
		SAVE,narr,filename=narrfile
	

	ENDIF
	ENDIF
	
	
ENDFOR   ; species loop
bailout:


END

