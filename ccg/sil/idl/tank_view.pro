; NAME:	TANK_VIEW.PRO
;
; PURPOSE:  to pull out data for spific tanks, perform and generate
;	    statistics on the tank, and to graph the results
;
; CATEGORY:  data management
;
; CALLING SEQUENCE:  TANK_VIEW, tank=tank, sp=sp, dev=dev
;
; INPUTS:   tank - full tank number (capital letters ie. EDDA-001)
;	    sp - spies, such as co2c13, ch4c13, or ch3d
;
; OPTIONAL INPUT PARAMETERS:   NONE
;
; OUTPUTS:  A tank statistic file which can be transfered and opened in Excel, 
;	    for the calibration certificate
;	    Graphs the are to be included in calibration certificate
;
; COMMON BLOCKS:  NONE
;
; SIDE EFFECTS:	 NONE, as of yet
;
; RESTRICTIONS:  NONE
;
; PROCEDURE:  
;
; MODIFICATION HISTORY:  Written by VC Dec, 2004
;	Modified: VC May 2005 to include all spies and multiple instruments for co2c13
;modified 2/06 SRE to add fill dates
;modified 8/6/09 SEM to graph 'B' flagged data. B is for bad (but we still want to show it for full disclosure).
;modified 12/7/10 AES to include uncertainty measurements in stat files
; modified at some point to include ch4c13 data
;; 'breakstart' feature added so that you can have a before/after calibration option. Breakstart is the integer or decimal date start year at which to separate
; the different measurement periods. (time less than breakstart = one period, complement=other period)
;;; modified spring 2023 to calculate mean as the mean of all measurement episodes.
;; and accomodate two point calibrated data better

; ----- INITIALIZATION ----------------------------------------------------------
PRO TANK_VIEW,  tank = tank, 		$
		sp = sp, 		$
		filldate = filldate,	$  ;'mmddyyyy'
		c13yrange = c13yrange,  $
		o18yrange = o18yrange,  $
		drange = drange,	$
		savegraphs=savegraphs,  $
		uniqinst=uniqinst,	$
		twpt=twpt,		$   ;two-point scale correction
		breakstart=breakstart,	$
		skipplot=skipplot,	$ 
		jras2=jras2,		$
		bulktankstats=bulktankstats

;Print,'sly needs to fix twpt correction on this code. type .c to continue for now. Bug sly to get it fixed properly.'
;stop


IF NOT KEYWORD_SET(tank) THEN CCG_MESSAGE, 'Tank must be specified!'
IF NOT KEYWORD_SET(sp) THEN sp='co2c13'
IF NOT KEYWORD_SET(uniqinst) THEN uniqinst=0
IF NOT KEYWORD_SET(twpt) THEN twpt=1
IF NOT KEYWORD_SET(breakstart) THEN breakstart=0
IF NOT KEYWORD_SET(skipplot) THEN skipplot=0
;IF NOT KEYWORD_SET(jras2) THEN jras2=0  ; this is goofy. For ch4c13, can't have jras=1

;IF NOT KEYWORD_SET(filldate) THEN $
;	filldate=TextBox(Title='Provide filldate', $
;	Label='filldate mmddyyyy ',cancel=cancelled,Xsize=200,Value='07022013')

IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0 

;newplot parameters		
IF breakstart NE 0 THEN ourfontsize=12 ELSE ourfontsize=15
params={linestyle:6, $
	 symbol: 'circle',$
	 font_name: 'Helvetica',$
	 sym_filled: 1,$
	 thick:3, $
	 sym_size:1,$
	 font_size:ourfontsize,$	
	 ytickdir: 1}  ;points ticks out	
	 
	 co2c13title='$\delta$$^{13}$C-CO$_{2}$ ($\permil$)'
	  co2o18title='$\delta$$^{18}$O-CO$_{2}$ ($\permil$)'
	 coh413title='$\delta$$^{13}$C-CH$_{4}$ ($\permil$)'

IF savegraphs EQ 1 THEN ourdev='png'
	
CASE sp OF
	'co2c13' : BEGIN 
		c13yrange = 0.15
		orange=0.25
	END
	'ch4c13': BEGIN
		c13yrange= 0.25
		
	END
	'ch4h2': BEGIN
		c13yrange=10
	END
ENDCASE

IF NOT KEYWORD_SET(o18yrange) THEN o18yrange = 0.2
IF NOT KEYWORD_SET(drange) THEN drange = 5.00
IF NOT KEYWORD_SET(filldate) THEN filldate = 11111111
IF sp EQ 'ch4c13' THEN jras2=0 ELSE jras2=1

; ----- READ IN TANK FILE -------------------------------------------------------
;calsdir='cals'
IF jras2 EQ 1 THEN calsdir='calsieg2' 
calsdir='calsieg3'  ;final'

IF STRMID(tank,4,1) EQ '-' THEN cyl = 'internal_cyl' ELSE cyl = 'external_cyl'
	print, cyl
IF sp EQ 'co2c13' THEN BEGIN
	print,'******reading from ',calsdir
	;print, '****** confirm that you want JRAS data. If not, please change the code.'
		tankfile = '/projects/'+sp+'/'+calsdir+'/'+cyl+'/'+tank+'.'+sp

ENDIF ELSE BEGIN
	tankfile = '/projects/'+sp+'/cals/external_cyl/'+tank+'.'+sp
	
	
ENDELSE
	sizetank=size(tankfile)
 
	;IF sizetank[0] EQ 0 THEN goto, skipthis
	
	CCG_READ, file=tankfile, /nomessages, tankdata
	

	IF sp NE 'ch4c13' THEN BEGIN
		
		; get rid of ! data
		notrealbad=WHERE(STRMID(tankdata.field15,0,1) NE '!' AND STRMID(tankdata.field18,0,1) NE '!')

		tankdata=tankdata[notrealbad]
		notFbad=WHERE(STRMID(tankdata.field15,0,1) NE 'F' AND STRMID(tankdata.field18,0,1) NE 'F')

		tankdata=tankdata[notFbad]
		; get out DEWY data if we're not in jras mode. ...


		IF jras2 NE 1 THEN BEGIN
	
		keep=WHERE(tankdata.field19 NE 'DEWY-001') 
		tankdata=tankdata[keep]
		keep=WHERE(tankdata.field19 NE 'LOUI-001') 
		tankdata=tankdata[keep]
		ENDIF
	ENDIF
ntankdata = N_ELEMENTS(tankdata)


; ----- FIND DATA THAT MATCHES YOUR FILL DATE ---------------------------------------------
; ------SRE added this 02/20/2006 to accommodate tanks that have gone through SIL and come
; back with a new fill. The sil_proc_co2c13.pro file was edited to go through the
; reference.external.co2c13 file and find the filldate that is appropriate to the analysis date, 
; but all of the data for that tank still goes to a single file (such as AL47108.co2c13). It is
; up to tank_view to discriminate between fills, which is done simply by passing the filldate 
; as a keyword and doing a WHERE statement. (This is only necessary for external tanks, since 
; internal tanks have a -002 to distinguish fills.)
;
; changed this so that you only need a filldate if you have two fills of the tank.



;** new 12/13/17. Do you have multiple fill dates?
decfilldate=FLTARR(ntankdata)
CCG_DATE2DEC,yr=tankdata.field2,mo=tankdata.field3,dy=tankdata.field4,dec=dec
decfilldate=dec
uniqdate=UNIQ(decfilldate)

IF N_ELEMENTS(uniqdate) GT 1 THEN BEGIN


;IF sp EQ 'co2c13' THEN BEGIN ;;;;; change this once you work on CH4 part of code!!
;	IF cyl EQ 'external_cyl' THEN BEGIN
		fillyr = STRMID(filldate,4,4)
		fillmo = STRMID(filldate,0,2)
		filldy = STRMID(filldate,2,2)

		thefilldate=WHERE(tankdata.field2 EQ fillyr AND tankdata.field3 EQ fillmo,ntankdata)
			 ;AND tankdata.field4 EQ filldy, ntankdata)
		tankdata = tankdata[thefilldate]
;	ENDIF	
;ENDIF

ENDIF ELSE BEGIN
		fillyr = STRCOMPRESS(STRING(tankdata[0].field2),/REMOVE_ALL)
		
		fillmo = STRCOMPRESS(STRING(tankdata[0].field3),/REMOVE_ALL)
		IF STRLEN(fillmo) LT 2 THEN fillmo='0'+fillmo
		filldy = STRCOMPRESS(STRING(tankdata[0].field4),/REMOVE_ALL)
		IF STRLEN(filldy) LT 2 THEN filldy='0'+filldy
		filldate=fillmo+filldy+fillyr
ENDELSE


; ----- SORT DATA BY ANALYSIS DATE ---------------------------------------------
date = FLTARR(ntankdata)
FOR i=0, ntankdata-1 DO BEGIN
	CCG_DATE2DEC, yr=tankdata[i].field7, mo=tankdata[i].field8, $
		dy=tankdata[i].field9, hr=tankdata[i].field10, $
		mn=tankdata[i].field11, dec=dec
	date[i]=dec
ENDFOR
datesort=SORT(date)
tankdata=tankdata[datesort]



CASE sp OF 
'co2c13': BEGIN

	instrunarr=STRARR(ntankdata)
	instrunarr=STRCOMPRESS(STRING(tankdata.field6),/REMOVE_ALL)+'_'+tankdata.field20
	sortinstrun=SORT(instrunarr)
	instrunarr=instrunarr[sortinstrun]
	uniqinstrun=UNIQ(instrunarr)
	getwhatyouneed=instrunarr[uniqinstrun]
	nruns=N_ELEMENTS(getwhatyouneed)
	instarr=STRARR(nruns)
	runnum=STRARR(nruns)
	
	
	FOR i=0,nruns-1 DO BEGIN
		parsethem=STRPOS(getwhatyouneed[i],'_')
	
		instarr[i]=STRMID(getwhatyouneed[i],parsethem+1,2)
		runnum[i]=FIX(STRMID(getwhatyouneed[i],0,parsethem))
	ENDFOR

	runstats = REPLICATE	({ adate:'',	 $
					runnum:0,	$
					nc:0,		 $
					aveco2c13:0.0,	 $
					stdevco2c13:0.0, $
					uncertco2c13:0.0, $
					no:0,		 $
					aveco2o18:0.0,	 $
					stdevco2o18:0.0,  $
					uncertco2o18:0.0,$
					ref:'',		 $
					inst:'',	$
					avetwptc13:0.0,$
					avetwpto18:0.0,$
					adatedec:0.0,$
					bestc13:0.0,	 $
					besto18:0.0},	 $
					nruns)   
					
					
					; making this array very long. Cut out zero lines later. 


	m=0  ;to fill up runstats
	FOR i=0, 0 DO BEGIN  ; this is instloop - will remove
	

		numcruns=0			
		numoruns=0
		ctwptspot=intarr(nruns) 
		otwptspot=intarr(nruns)	
		cdatathere=intarr(nruns)
		odatathere=intarr(nruns)
		
		FOR j=0, nruns-1 DO BEGIN 
		
			thisrun = WHERE(tankdata.field20 EQ instarr[j] AND tankdata.field6 EQ runnum[j],nthis)
				;get the general stuff
				runstats[j].adate = STRCOMPRESS(STRING(tankdata[thisrun[0]].field8)+'/'+ $
				STRING(tankdata[thisrun[0]].field9)+'/'+ $
				STRING(tankdata[thisrun[0]].field7), /REMOVE_ALL)
				CCG_DATE2DEC, mo=tankdata[thisrun[0]].field8,$
				dy=tankdata[thisrun[0]].field9,$
				yr=tankdata[thisrun[0]].field7,dec=dec	
				
				runstats[j].adatedec = dec
				
				runstats[j].runnum =tankdata[thisrun[0]].field6
				runstats[j].ref = tankdata[thisrun[0]].field19
				runstats[j].inst = tankdata[thisrun[0]].field20
				
				;separate c and o data
				crundata = tankdata[thisrun]
				orundata=tankdata[thisrun]
			
				;now get out flags
				goodc=WHERE(crundata.field15 EQ '...',nc)
				crundata=crundata[goodc]
				goodo=WHERE(orundata.field18 EQ '...',no)
				
				orundata=orundata[goodo]
				runstats[m].nc = nc
				runstats[m].no=no
			
				
			IF nc GT 1 THEN BEGIN
				cdatathere[j]=1
				runstats[m].aveco2c13 = MEAN(crundata.field13)
				runstats[m].stdevco2c13 = STDDEV(crundata.field13)
				runstats[m].uncertco2c13 = MEAN(crundata.field14)
				
				IF twpt EQ 1 THEN runstats[m].avetwptc13 = MEAN(crundata.field21)
					numcruns=numcruns+1
					
					IF ABS(runstats[m].avetwptc13) GT 0.004 THEN BEGIN
						ctwptspot[j]=1	
						runstats[m].bestc13 = runstats[m].avetwptc13 
					ENDIF ELSE BEGIN
						runstats[m].bestc13 = runstats[m].aveco2c13
					ENDELSE
			ENDIF ELSE BEGIN
				IF nc EQ 1 THEN BEGIN
					
					runstats[m].aveco2c13 = crundata.field13
					runstats[m].stdevco2c13 = 0
					runstats[m].uncertco2c13 = crundata.field14
					IF twpt EQ 1 THEN runstats[m].avetwptc13 = crundata.field21
					numcruns=numcruns+1
					IF ABS(runstats[m].avetwptc13) GT 0.004 THEN BEGIN
						
						runstats[m].bestc13 = runstats[m].avetwptc13 
					ENDIF ELSE BEGIN
						runstats[m].bestc13 = runstats[m].aveco2c13
					ENDELSE
				ENDIF ELSE BEGIN
					runstats[m].aveco2c13 = -99					
					runstats[m].stdevco2c13 = -99	
					runstats[m].uncertco2c13 = -99
				ENDELSE
			ENDELSE
			
			IF no GT 1 THEN BEGIN
				odatathere[j]=1
				runstats[m].aveco2o18 = MEAN(orundata.field16)
				runstats[m].stdevco2o18 = STDDEV(orundata.field16)
				runstats[m].uncertco2o18 = MEAN(orundata.field17)
				IF twpt EQ 1 THEN runstats[m].avetwpto18 = MEAN(orundata.field22)
				numoruns=numoruns+1
				  IF ABS(runstats[m].avetwpto18) GT 0.004 THEN BEGIN
				  	 runstats[m].besto18 = runstats[m].avetwpto18
					 otwptspot[j]=1	
				  ENDIF ELSE BEGIN
				   runstats[m].besto18 = runstats[m].aveco2o18
				ENDELSE
			ENDIF ELSE BEGIN
				IF no EQ 1 THEN BEGIN
					runstats[m].aveco2o18 = orundata.field16
					runstats[m].stdevco2o18 = 0
					runstats[m].uncertco2o18 = orundata.field17
					IF twpt EQ 1 THEN runstats[m].avetwpto18 = orundata.field22
					IF ABS(runstats[m].avetwpto18) GT 0.004 THEN  runstats[m].besto18 = runstats[m].avetwpto18 ELSE $
				   	runstats[m].besto18 = runstats[m].aveco2o18
					numoruns=numoruns+1
				ENDIF ELSE BEGIN
					runstats[m].aveco2o18 = -99
					runstats[m].stdevco2o18 = -99
					runstats[m].uncertco2o18 = -99
				ENDELSE
			ENDELSE
			
			
		
		m=m+1
		ENDFOR	
		
		;now sort by adate
		sortbyadate=SORT(runstats.adatedec)
		runstats=runstats[sortbyadate]
		cdatathere=cdatathere[sortbyadate]
		odatathere=odatathere[sortbyadate]
		ctwptspot=ctwptspot[sortbyadate]
		otwptspot=otwptspot[sortbyadate]
		
		;05/10/23 changing from the mean of all c measurements to the mean of the mean measurement each run
		
			keepc=WHERE(cdatathere EQ 1,nc)
			keepo=WHERE(odatathere EQ 1,no)
			
		tankstats = FLTARR(8,1)
			c13mo=MOMENT(runstats[keepc].bestc13,sdev=sdev)
		
		;pooled standard deviation
		addnoms=0.0
		adddenoms=0.0
		sumnoms=FLTARR(nc)
		sumdenoms=FLTARR(nc)
	
		
		FOR u=0,nc-1 DO BEGIN
			sumnoms[u]=runstats[keepc[u]].stdevco2c13^2*(runstats[keepc[u]].nc-1)
			addnoms=addnoms+sumnoms[u]
			sumdenoms[u]=runstats[keepc[u]].nc-1
			adddenoms=adddenoms+sumdenoms[u]
		ENDFOR
		
		;;;
		tankstats[0,0] = nc		;n
		tankstats[1,0] = c13mo[0]	;aveco2c13
		tankstats[2,0] = (addnoms/adddenoms)^0.5   ;;;sdev
		
		o18there=WHERE(runstats.no GE 2,no)
		o18mo=MOMENT(runstats[keepo].besto18,sdev=sdev)
		
		addnoms=0.0
		adddenoms=0.0
		sumnoms=FLTARR(no)
		sumdenoms=FLTARR(no)
		
		FOR u=0,no-1 DO BEGIN
			sumnoms[u]=runstats[keepo[u]].stdevco2o18^2*(runstats[o18there[u]].no-1)
			addnoms=addnoms+sumnoms[u]
			sumdenoms[u]=runstats[keepo[u]].no-1
			adddenoms=adddenoms+sumdenoms[u]
		ENDFOR
		
		
		tankstats[3,0] = no
		tankstats[4,0] = o18mo[0]	;aveco2o18
		tankstats[5,0] = (addnoms/adddenoms)^0.5   ;;;sdev

	besttankstats=tankstats	
		
		IF breakstart NE 0 THEN BEGIN
			keepc=WHERE(cdatathere EQ 1)
			crunstats=runstats[keepc]
			keepo=WHERE(odatathere EQ 1)
			orunstats=runstats[keepo]
			
			btankstats = FLTARR(8,2)
	
			cbefore=WHERE(crunstats.adatedec LT breakstart,ncbefore,complement=cafter)
			ncafter=N_ELEMENTS(cafter)
			
			obefore=WHERE(orunstats.adatedec LT breakstart,nobefore,complement=oafter)
			noafter=N_ELEMENTS(oafter)
					
			btankstats[0,0] = ncbefore		;n
			btankstats[1,0] = MEAN(crunstats[cbefore].bestc13)	;avec13
			
			addnoms=0.0
			adddenoms=0.0
			sumnoms=FLTARR(ncbefore)
			sumdenoms=FLTARR(ncbefore)
		
			FOR u=0,ncbefore-1 DO BEGIN
				sumnoms[u]=crunstats[cbefore[u]].stdevco2c13^2*(crunstats[cbefore[u]].nc-1)
				addnoms=addnoms+sumnoms[u]
				sumdenoms[u]=crunstats[cbefore[u]].nc-1
				adddenoms=adddenoms+sumdenoms[u]
			ENDFOR
			btankstats[2,0] = (addnoms/adddenoms)^0.5   ;;;sdev
			btankstats[3,0] = N_ELEMENTS(orunstats[obefore])
			btankstats[4,0] = MEAN(orunstats[obefore].besto18)	;aveo18
			
			addnoms=0.0
			adddenoms=0.0
			sumnoms=FLTARR(nobefore)
			sumdenoms=FLTARR(nobefore)
		
			FOR u=0,nobefore-1 DO BEGIN
				sumnoms[u]=orunstats[obefore[u]].stdevco2o18^2*(orunstats[obefore[u]].no-1)
				addnoms=addnoms+sumnoms[u]
				sumdenoms[u]=orunstats[obefore[u]].no-1
				adddenoms=adddenoms+sumdenoms[u]
			ENDFOR
			btankstats[5,0] =(addnoms/adddenoms)^0.5    ;sdevo18
			
			;;; could do this in a loop but keeping it linear for now...
			
			btankstats[0,1] = N_ELEMENTS(crunstats[cafter])		;n
			btankstats[1,1] = MEAN(crunstats[cafter].bestc13)	;avec13
			
			addnoms=0.0
			adddenoms=0.0
			sumnoms=FLTARR(ncafter)
			sumdenoms=FLTARR(ncafter)
		
			FOR u=0,ncafter-1 DO BEGIN
				sumnoms[u]=crunstats[cafter[u]].stdevco2c13^2*(crunstats[cafter[u]].nc-1)
				addnoms=addnoms+sumnoms[u]
				sumdenoms[u]=crunstats[cafter[u]].nc-1
				adddenoms=adddenoms+sumdenoms[u]
			ENDFOR
			btankstats[2,1] = (addnoms/adddenoms)^0.5   ;;;sdev
			btankstats[3,1] = N_ELEMENTS(orunstats[oafter])
			btankstats[4,1] = MEAN(orunstats[oafter].besto18)	;aveo18
			
			addnoms=0.0
			adddenoms=0.0
			sumnoms=FLTARR(noafter)
			sumdenoms=FLTARR(noafter)
		
			FOR u=0,noafter-1 DO BEGIN
				sumnoms[u]=orunstats[oafter[u]].stdevco2o18^2*(orunstats[oafter[u]].no-1)
				addnoms=addnoms+sumnoms[u]
				sumdenoms[u]=orunstats[oafter[u]].no-1
				adddenoms=adddenoms+sumdenoms[u]
			ENDFOR
			btankstats[5,1] = (addnoms/adddenoms)^0.5    ;sdevo18
			
		
		ENDIF
		 	
		
	
		; ----- WRITE TO TANK STAT FILE ---------------------------------------------------
		IF uniqinst EQ 0 THEN BEGIN	
			instname= 'allinst'
		ENDIF ELSE BEGIN
			instname=tankdata[inst[i]].field20
		ENDELSE
		
		IF cyl EQ 'external_cyl' THEN BEGIN
		   statfile = '/projects/'+sp+'/'+calsdir+'/'+cyl+'/stats/'+tank+'.'+filldate+'.'+sp+'.stat.'+instname
		ENDIF ELSE BEGIN
		   statfile ='/projects/'+sp+'/'+calsdir+'/'+cyl+'/stats/'+tank+'.'+sp+'.stat.'+instname
		ENDELSE
		tankformat = '(I4,  2(F9.3),I4,4(F9.3))'
		statformat = '(A11, I8,I3,  3(F9.3), I3,3(F9.3),A11, A4,5(F9.3))'
		IF twpt EQ 1 THEN twptquestion = 'yes' ELSE twptquestion = 'no'
		
		OPENW, u, statfile, /GET_LUN
		PRINTF, u, 'TANK: ' + tank
		PRINTF, u, 'FILL_DATE:  ' + STRCOMPRESS(STRING(tankdata[0].field3) + '/' + $
			STRING(tankdata[0].field4) + '/' + $
			STRING(tankdata[0].field2), /REMOVE_ALL)
		PRINTF, u, 'twpt correction? ' + twptquestion
		PRINTF, u, 'TANK_STATISTICS'
		PRINTF, u, '  NC    13C    STD.DEV.  NO  18O    STD.DEV. twptc13 twpto18'
		IF twpt EQ 1 THEN PRINTF, u, besttankstats, format=tankformat ELSE PRINTF, u ,tankstats,format=tankformat

		IF breakstart NE 0 THEN BEGIN 
			PRINTF, u, breakstart, format='(I6)'
			FOR b=0,1 DO PRINTF,u,btankstats[*,b], format=tankformat
			PRINT, 'breakstart = ', breakstart
			FOR b=0,1 DO PRINT,btankstats[*,b]
		
		ENDIF
		PRINTF, u, 'RUN_STATISTICS'
		PRINTF, u, ' RUN_DATE  NC   13C    STD.DEV  UNCERT  NO  18O    STD.DEV  UNCERT  REF      INST twptc13 twpto18'      
		FOR k=0, nruns-1 DO PRINTF, u, runstats[k], format = statformat
		FREE_LUN, u
		
		n=N_ELEMENTS(tankdata)
		;PRINT, 'NC    13C    STD.DEV.  NO  18O    STD.DEV. twptc13 twpto18'
		PRINT, 'NC = ',besttankstats[0]
		PRINT,'13C       = ',besttankstats[1]
		PRINT,'13Cstdev  = ',besttankstats[2]
		PRINT,'NO = ',besttankstats[3]
		PRINT,'18O = ',besttankstats[4]
		PRINT,'18Ostdev = ',besttankstats[5]
		;IF twpt EQ 1 THEN BEGIN
		;PRINT,'twpt13C = ',besttankstats[6]
		;PRINT,'twpt18O = ',besttankstats[7]
		;ENDIF
		;;;
		plotc13mean=tankstats[1]
		ploto18mean=tankstats[4]
		
	;	IF jras2 EQ 1 THEN BEGIN
	;	PRINT, '********************  BEST VALUE for cylinder is '
	;	IF twpt EQ 1 THEN print, besttankstats ELSE print,tankstats
	;	ENDIF

		bulktankstats=tankstats

	ENDFOR

;IF savegraphs EQ 0 THEN stop	
IF skipplot EQ 1 THEN goto, bedone

;;;NOTE**************
; though we get stats for only ..* data, we want to plot 'B' data also (data removed but for unknown reason)
; so, getting 'new' set of data to work with here. 

	; ----- GRAPH FULL FILE ---------------------------------------------------------
	
	cbflag=WHERE(STRMID(tankdata.field15,0,2) EQ '..' OR STRMID(tankdata.field15,0,2) EQ 'B.',ncb)
	cbdata=tankdata[cbflag]
	obflag=WHERE(STRMID(tankdata.field18,0,2) EQ '..' OR STRMID(tankdata.field18,0,2) EQ 'B.',nob)
	obdata=tankdata[obflag]

	c13 = cbdata.field13
	cindicator=WHERE(cbdata.field7 GE breakstart)  ; this is where to put the line. Need to use cbdata not ctankdata
	
	
	IF twpt EQ 1 THEN twptc13 = cbdata.field21
	ncb=N_ELEMENTS(cbdata)
	xcvalues = INDGEN(ncb) +1
	cflags=cbdata.field21
	plotmean = mean(c13)
	range = c13yrange


;goto,skipfirstplot
	top=0.4
	j=0
	

	
	o1color='purple'
	i2color='blue'
	i4color='green'
	i6color='cyan'
	
	o1 = WHERE(cbdata.field20 EQ 'o1' AND STRMID(cbdata.field15,0,2) EQ '..')
	i2 = WHERE(cbdata.field20 EQ 'i2' AND STRMID(cbdata.field15,0,2) EQ '..')
	i4 = WHERE(cbdata.field20 EQ 'i4' AND STRMID(cbdata.field15,0,2) EQ '..')
	i6 = WHERE(cbdata.field20 EQ 'i6' AND STRMID(cbdata.field15,0,2) EQ '..')
	
	c13plot=PLOT(xcvalues,c13,layout=[1,2,1],position=[0.15,0.55,0.9,0.9])
	c13plot._extra=params
	c13plot.ytitle=co2c13title
	c13plot.xrange=[0,ncb+1]
	c13plot.color='pink'
	c13plot.xtitle='index'
	c13plot.symbol='dot'
	c13plot.xshowtext=0    ; no x values here
	c13plot.yrange=[(plotc13mean-c13yrange),(plotc13mean+c13yrange)]

	;c13plot.ystyle=1
	
	IF o1[0] NE -1 THEN BEGIN
		c13o1=PLOT(xcvalues[o1],c13[o1],/OVERPLOT)
		c13o1._extra=params
		c13o1.color=o1color
		c13o1.symbol='circle'
	ENDIF
	IF i2[0] NE -1 THEN BEGIN
		c13i2=PLOT(xcvalues[i2],c13[i2],/OVERPLOT)
		c13i2._extra=params
		c13i2.color=i2color
		c13i2.symbol='circle'
	ENDIF
	IF i4[0] NE -1 THEN BEGIN
		c13i4=PLOT(xcvalues[i4],c13[i4],/OVERPLOT)
		c13i4._extra=params
		c13i4.color=i4color
		c13i4.symbol='circle'
	ENDIF
	IF i6[0] NE -1 THEN BEGIN
		c13i6=PLOT(xcvalues[i6],c13[i6],/OVERPLOT)
		c13i6._extra=params
		c13i6.color=i6color
		c13i6.symbol='circle'
	ENDIF

	
	IF twpt NE 0 THEN BEGIN
		twptdat=WHERE(cbdata.field21 NE 0 AND STRMID(cbdata.field15,0,2) EQ '..')
		IF twptdat[0] NE -1 THEN BEGIN
		
			c13twptplot=PLOT(xcvalues[twptdat], twptc13[twptdat],/OVERPLOT)
			c13twptplot.symbol='triangle'
			c13twptplot.color='turquoise'
			c13twptplot._extra=params
		ENDIF
	ENDIF
	
	badcdata = WHERE(STRMID(cbdata.field15,0,2) EQ 'B.')
	IF badcdata[0] NE -1 THEN BEGIN
	
		c13badplot=PLOT(xcvalues[badcdata], c13[badcdata],/OVERPLOT)
		c13badplot.symbol='triangle'
		c13badplot.color='red'
		c13badplot._extra=params
	ENDIF

	IF breakstart NE 0 THEN BEGIN
		breakarr=[cindicator[0]+0.5,cindicator[0]+0.5]
		linearr=[(plotmean-range),(plotmean+range)]
		breakplot=PLOT(breakarr,linearr,/OVERPLOT,linestyle=1) 	
	ENDIF	

	o18 = obdata.field16
	oindicator=WHERE(obdata.field7 GE breakstart)  ; this is where to put the line. Need to use cbdata not ctankdata
	IF twpt EQ 1 THEN twpto18 =obdata.field22
	nob=N_ELEMENTS(obdata)
	xovalues = INDGEN(nob) +1
	plotmean = mean(o18)
	oflags=obdata.field18
	range = o18yrange
	
	
	o1 = WHERE(obdata.field20 EQ 'o1' AND STRMID(obdata.field18,0,2) EQ '..')
	i2 = WHERE(obdata.field20 EQ 'i2' AND STRMID(obdata.field18,0,2) EQ '..')
	i4 = WHERE(obdata.field20 EQ 'i4' AND STRMID(obdata.field18,0,2) EQ '..')
	i6 = WHERE(obdata.field20 EQ 'i6' AND STRMID(obdata.field18,0,2) EQ '..')
	
	o18plot=PLOT(xovalues,o18,layout=[1,2,1],position=[0.15,0.1,0.9,0.45],/CURRENT)

	o18plot._extra=params
	o18plot.xtitle='index'
	o18plot.yrange=[(ploto18mean-orange),(ploto18mean+orange)]
	
	o18plot.ytitle=co2o18title
	o18plot.xrange=[0,nob+1]
	o18plot.color='pink'
	o18plot.symbol='dot'
	
	IF o1[0] NE -1 THEN BEGIN
		o18o1=PLOT(xovalues[o1],o18[o1],/OVERPLOT,name='o1')
		o18o1._extra=params
		o18o1.color=o1color
		o18o1.symbol='circle'
		;plottarget.o1=o18o1
		o1text=TEXT(0.8,top-(0.04*j), 'o1', font_color=o1color, font_size=16)
		j=j+1
	ENDIF
	
	IF i2[0] NE -1 THEN BEGIN
		o18i2=PLOT(xovalues[i2],o18[i2],/OVERPLOT,name='i2')
		o18i2._extra=params
		o18i2.color=i2color
		o18i2.symbol='circle'
		o1text=TEXT(0.8,top-(0.04*j), 'i2', font_color=i2color, font_size=16)
		j=j+1
	ENDIF
	IF i4[0] NE -1 THEN BEGIN
		o18i4=PLOT(xovalues[i4],o18[i4],/OVERPLOT,name='i4')
		o18i4._extra=params
		o18i4.color=i4color
		o18i4.symbol='circle'
		i4text=TEXT(0.8,top-(0.04*j), 'i4', font_color=i4color, font_size=16)
		j=j+1
		
	ENDIF
	IF i6[0] NE -1 THEN BEGIN
		o18i6=PLOT(xovalues[i6],o18[i6],/OVERPLOT,name='i6')
		o18i6._extra=params
		o18i6.color=i6color
		o18i6.symbol='circle'	
		i6text=TEXT(0.8,top-(0.04*j), 'i6', font_color=i6color, font_size=16)
		j=j+1
		
	ENDIF

	
	
	IF twpt NE 0 THEN BEGIN
		twptdat=WHERE(obdata.field21 NE 0 AND STRMID(obdata.field18,0,2) EQ '..')
		IF twptdat[0] NE -1 THEN BEGIN
		
			o18twptplot=PLOT(xovalues[twptdat],$
			twpto18[twptdat],/OVERPLOT,name='two point')
			o18twptplot.symbol='triangle'
			o18twptplot.color='turquoise'
			o18twptplot._extra=params
			twpttext=TEXT(0.65,top-(0.04*j), 'scale corrected data', font_color='turquoise', font_size=16)
		ENDIF

	ENDIF
	
	
	
	
	
	badodata = WHERE(STRMID(oflags,0,2) EQ 'B.')
	IF badodata[0] NE -1 THEN BEGIN
		o18badplot=PLOT(xovalues[badodata], o18[badodata],/OVERPLOT,name='not used')
		o18badplot.symbol='triangle'
		o18badplot.color='red'
		o18badplot._extra=params
		;plottarget.bad=o18badplot
		twpttext=TEXT(0.75,top-(0.08*j), 'flagged data', font_color='red', font_size=16)
	ENDIF
	;***********************

	IF breakstart NE 0 THEN BEGIN
		obreakarr=[oindicator[0]+0.5,oindicator[0]+0.5]
		olinearr=[(plotmean-range),(plotmean+range)]
		breakplot=PLOT(obreakarr,olinearr,/OVERPLOT,linestyle=1,name='new data') 	
	ENDIF	
	
;skipfirstplot:	

	
	;;;;;;;;----------------------
	;this is the second plot: adate vs mean and stdev of measurement episode
	
	top=0.4
	j=0
	IF breakstart EQ 0 THEN BEGIN
		c13plot=ERRORPLOT(runstats[keepc].adatedec,runstats[keepc].aveco2c13,runstats[keepc].stdevco2c13,layout=[1,2,1],position=[0.15,0.55,0.9,0.9])
	
		c13plot._extra=params
		c13plot.ytitle=co2c13title
		c13plot.color='blue'
		c13plot.symbol='circle'
		c13plot.xshowtext=0    ; no x values here
		c13plot.yrange=[(plotc13mean-c13yrange),(plotc13mean+c13yrange)]
		c13plot.xrange=[(runstats[keepc[0]].adatedec-0.02),(runstats[keepc[nc-1]].adatedec+0.02)]
		c13plot.errorbar_color='blue'
		c13plot.errorbar_capsize=0.1
		c13plot.ERRORBAR_THICK=2
	
	
	
		
		IF twpt NE 0 THEN BEGIN
			IF twptdat[0] NE -1 THEN BEGIN
			     twpthere=WHERE(ABS(runstats.avetwptc13) GT 0.004,ntwpthere)
			     	IF ntwpthere GT 1 THEN BEGIN 
				c13twptplot=ERRORPLOT(runstats[twpthere].adatedec,runstats[twpthere].avetwptc13,runstats[twpthere].stdevco2c13,/OVERPLOT)
				ENDIF ELSE BEGIN
				c13twptplot=ERRORPLOT([runstats[twpthere].adatedec,runstats[twpthere].adatedec],[runstats[twpthere].avetwptc13,runstats[twpthere].avetwptc13],[runstats[twpthere].stdevco2c13,runstats[twpthere].stdevco2c13],/OVERPLOT)
				ENDELSE
				c13twptplot.symbol='triangle'
				c13twptplot.color='turquoise'
				c13twptplot._extra=params
				c13twptplot.errorbar_color='turquoise'
				c13twptplot.errorbar_capsize=0.1
				c13twptplot.errorbar_thick=2
			ENDIF
		ENDIF
	
	
		o18plot=ERRORPLOT(runstats[keepo].adatedec,runstats[keepo].aveco2o18,runstats[keepo].stdevco2o18,layout=[1,2,1],position=[0.15,0.1,0.9,0.45],/current)
	
	
	
		o18plot._extra=params
		o18plot.ytitle=co2o18title
		o18plot.color='blue'
		o18plot.xtitle='analysis date'
		o18plot.symbol='circle'
		o18plot.errorbar_color='blue'
		o18plot.errorbar_capsize=0.1
		o18plot.errorbar_thick=2
		
		o18plot.yrange=[(ploto18mean-o18yrange),(ploto18mean+o18yrange)]
		o18plot.xrange=[(runstats[keepo[0]].adatedec-0.02),(runstats[keepo[no-1]].adatedec+0.02)]
		;o18plot.ystyle=1
	
		top=0.4
		j=0
	

	
		IF twpt NE 0 THEN BEGIN
			IF twptdat[0] NE -1 THEN BEGIN
			     twpthere=WHERE(ABS(runstats.avetwpto18) GT 0.004,ntwpthere)
			 	IF ntwpthere GT 1 THEN BEGIN
				o18twptplot=ERRORPLOT(runstats[twpthere].adatedec,runstats[twpthere].avetwpto18,runstats[twpthere].stdevco2o18,/OVERPLOT)
				ENDIF ELSE BEGIN
				o18twptplot=ERRORPLOT([runstats[twpthere].adatedec,runstats[twpthere].adatedec],[runstats[twpthere].avetwpto18,runstats[twpthere].avetwpto18],[runstats[twpthere].stdevco2o18,runstats[twpthere].stdevco2o18],/OVERPLOT)
				ENDELSE
				o18twptplot.symbol='triangle'
				o18twptplot.color='turquoise'
				o18twptplot._extra=params
				o18twptplot.errorbar_color='turquoise'
				o18twptplot.errorbar_capsize=0.1
				o18twptplot.errorbar_thick=2
				twpttext=TEXT(0.65,top-(0.04*j), 'scale corrected data', font_color='turquoise', font_size=16)
			ENDIF
		ENDIF
	
		TITLE=TEXT(0.45,0.94, tank, font_size=20)

	
	PRINT, '--------------------------------------------------------------------'
	PRINT, '--------------------------------------------------------------------'
	PRINT, 'continue if you would like the plot without the scale-corrected data'
	PRINT, '--------------------------------------------------------------------'
	PRINT, '--------------------------------------------------------------------'
	
	;this is the second plot: adate vs mean and stdev of measurement episode
	;c13plot.close
	

	
	IF twpt NE 0 THEN BEGIN
		IF twptdat[0] NE -1 THEN BEGIN
		     ctwpthere=WHERE(ctwptspot EQ 1)	
	
		finalc13plot=ERRORPLOT(runstats[ctwpthere].adatedec,runstats[ctwpthere].avetwptc13,runstats[ctwpthere].stdevco2c13,layout=[1,2,1],position=[0.15,0.55,0.9,0.9])
		finalc13plot._extra=params
		finalc13plot.ytitle=co2c13title
		finalc13plot.color='blue'
		finalc13plot.symbol='circle'
		finalc13plot.xshowtext=0    ; no x values here
		finalc13plot.yrange=[(plotc13mean-c13yrange),(plotc13mean+c13yrange)]
	
		finalc13plot.xrange=[(runstats[0].adatedec-0.02),(runstats[nc-1].adatedec+0.02)]
		finalc13plot.errorbar_color='blue'
		finalc13plot.errorbar_capsize=0.1
		finalc13plot.ERRORBAR_THICK=2
	        ;finalc13plot.ystyle=1
	
		ENDIF
	ENDIF	
	IF twpt NE 0 THEN BEGIN
		IF twptdat[0] NE -1 THEN BEGIN
		     twpthere=WHERE(otwptspot EQ 1)
				
	
	
			finalo18plot=ERRORPLOT(runstats[twpthere].adatedec,runstats[twpthere].avetwpto18,runstats[twpthere].stdevco2o18,layout=[1,2,1],position=[0.15,0.1,0.9,0.45],/current)
			
			finalo18plot._extra=params
			finalo18plot.ytitle=co2o18title
			finalo18plot.color='blue'
			finalo18plot.xtitle='analysis date'
			finalo18plot.symbol='circle'
			finalo18plot.errorbar_color='blue'
			finalo18plot.errorbar_capsize=0.1
			finalo18plot.errorbar_thick=2
		
			finalo18plot.yrange=[(ploto18mean-o18yrange),(ploto18mean+o18yrange)]
			finalo18plot.xrange=[(runstats[0].adatedec-0.02),(runstats[no-1].adatedec+0.02)]
			;finalo18plot.ystyle=1
	
	
		ENDIF
	ENDIF
	
		TITLE=TEXT(0.45,0.94, tank, font_size=20)

	IF twpt NE 0 THEN BEGIN
		IF savegraphs EQ 1 THEN BEGIN
		finalc13plot.save,'/projects/co2c13/'+calsdir+'/external_cyl/plots/'+tank+'.twpt.adate.png'
		finalc13plot.close
		ENDIF
	ENDIF 

	ENDIF ELSE BEGIN 


	;breakstart plots



	beforerange=[crunstats[cbefore[0]].adatedec-0.04,crunstats[cbefore[ncbefore-1]].adatedec+0.04]
	afterrange=[crunstats[cafter[0]].adatedec-0.04,crunstats[cafter[ncafter-1]].adatedec+0.04]

	c13plot=ERRORPLOT(crunstats[cbefore].adatedec,crunstats[cbefore].aveco2c13,crunstats[cbefore].stdevco2c13,position=[0.12,0.5,0.48,0.9])
	
	c13plot._extra=params
	c13plot.ytitle=co2c13title
	c13plot.color='blue'
	c13plot.symbol='circle'
	c13plot.xshowtext=0    ; no x values here
	c13plot.yrange=[(plotc13mean-c13yrange),(plotc13mean+c13yrange)]
	;c13plot.xrange=beforerange
	c13plot.errorbar_color='blue'
	c13plot.errorbar_capsize=0.1
	c13plot.ERRORBAR_THICK=2
        ;c13plot.ystyle=1
	
	c13plot['axis2'].transparency=100
	c13plot['axis3'].transparency=100
	

	c13plota=ERRORPLOT(crunstats[cafter].adatedec,crunstats[cafter].aveco2c13,crunstats[cafter].stdevco2c13,position=[0.56,0.5,0.98,0.9],/current)
	

	c13plota['axis2'].transparency=100
	c13plota['axis3'].transparency=100
	c13plota['axis1'].transparency=100
	c13plota._extra=params
	c13plota.color='blue'
	c13plota.symbol='circle'
	c13plota.xshowtext=0    ; no x values here
	c13plota.yrange=[(plotc13mean-c13yrange),(plotc13mean+c13yrange)]
	;c13plota.xrange=afterrange
	c13plota.errorbar_color='blue'
	c13plota.errorbar_capsize=0.1
	
	c13plota.ERRORBAR_THICK=2
      

      o18plot=ERRORPLOT(orunstats[obefore].adatedec,orunstats[obefore].aveco2o18,orunstats[obefore].stdevco2o18,position=[0.12,0.1,0.48,0.45],/current)
	
	o18plot._extra=params
	o18plot.ytitle=co2o18title
	o18plot.color='blue'
	o18plot.symbol='circle'
	o18plot.xshowtext=1    ; no x values here
	o18plot.yrange=[(ploto18mean-o18yrange),(ploto18mean+o18yrange)]
	;o18plot.xrange=beforerange
	o18plot.errorbar_color='blue'
	o18plot.errorbar_capsize=0.1
	o18plot.ERRORBAR_THICK=2
        ;o18plot.ystyle=1
	
	o18plot['axis2'].transparency=100
	o18plot['axis3'].transparency=100
	;o18plot.textorientation=90

	o18plota=ERRORPLOT(orunstats[oafter].adatedec,orunstats[oafter].aveco2o18,orunstats[oafter].stdevco2o18,position=[[0.56,0.1,0.98,0.45]],/current)
	
	
	o18plota['axis2'].transparency=100
	o18plota['axis3'].transparency=100
	o18plota['axis1'].transparency=100
	o18plota._extra=params
	o18plota.color='blue'
	o18plota.symbol='circle'
	o18plota.xshowtext=1    ; no x values here
	o18plota.yrange=[(ploto18mean-o18yrange),(ploto18mean+o18yrange)]
	;o18plota.xrange=afterrange
	o18plota.errorbar_color='blue'
	o18plota.errorbar_capsize=0.1
	o18plota.ERRORBAR_THICK=2
	;o18plota.textorientation=90
	o18plot.ERRORBAR_THICK=2
      
      
		TITLE=TEXT(0.45,0.94, tank, font_size=20)
		
		
	IF savegraphs EQ 1 THEN BEGIN
	
	
	
		c13plot.save,'/projects/co2c13/'+calsdir+'/external_cyl/plots/'+tank+'.twpt.breakstart.adate.png'
		c13plot.close
		
	ENDIF 	
stop
;;;
ENDELSE
		


END ; case 'co2c13'





;**************************************************************************************8888


ELSE: BEGIN    ;ch4c13

	; ----- DO STATS ON EACH RUN AND ON WHOLE FILE ----------------------------------
	; AVERAGE, STANDARD DEVIATION, N, AND STANDARD ERROR (ONLY FOR WHOLE FILE)
	
	
	

	;****************end of original
				
	c13flag=WHERE(STRMID(tankdata.field15,0,2) EQ '..',nctankdata)
	ctankdata=tankdata[c13flag]
	

	inst=UNIQ(tankdata.field17, SORT(tankdata.field17))
	ninst=N_ELEMENTS(inst)

	FOR i=0, ninst-1 DO BEGIN
		thisinst=tankdata[inst[i]].field17
	
	
		count = WHERE(tankdata.field17 EQ thisinst,ntankdata)
		tankdatainst = tankdata(count)    ;all data from this inst
		runs=UNIQ(tankdatainst.field6)
		
		tankruns=tankdatainst[runs]       ;array of uniq runs from inst
		runarr=tankruns.field6		  ; just list of runs	

		nruns=N_ELEMENTS(runs)
		
		runstats = REPLICATE	({ adate:'',	 $
					nc:0,		 $
					ave:0.0,	 $
					stdev:0.0, $
					unc:0.0, $
					ref:'',		 $
					inst:''},$
					nruns)
		adatedec=FLTARR(nruns)		
		FOR j=0, nruns-1 DO BEGIN
		
			runstats[j].adate = STRCOMPRESS(STRING(tankdata[runs[j]].field8)+'/'+ $
				STRING(tankdata[runs[j]].field9)+'/'+ $
				STRING(tankdata[runs[j]].field7), /REMOVE_ALL)
			ccg_date2dec,yr=tankdata[runs[j]].field7,mo=tankdata[runs[j]].field8,dy=tankdata[runs[j]].field9,dec=dec	
			adatedec[j]=dec	
			crun = WHERE(ctankdata.field6 EQ runarr[j], nc)
			IF crun[0] NE -1 THEN BEGIN 
				crundata = ctankdata[crun]
			ENDIF ELSE BEGIN
				nc = 0
			ENDELSE
			
			runstats[j].nc = nc
			
			IF nc GT 1 THEN BEGIN
				runstats[j].ave = MEAN(crundata.field13)
				runstats[j].stdev = STDDEV(crundata.field13)
				runstats[j].unc=crundata[0].field14
			ENDIF ELSE BEGIN
				IF nc EQ 1 THEN BEGIN
					runstats[j].ave = crundata.field13
					runstats[j].stdev = 0
					runstats[j].unc=-99
				ENDIF ELSE BEGIN
					runstats[j].ave = -99					
					runstats[j].stdev = -99	
					runstats[j].unc=-99
				ENDELSE
		
			ENDELSE
						
			
			
			runstats[j].ref = tankruns[j].field16
			runstats[j].inst = tankruns[j].field17
		ENDFOR
			
		tankstats = FLTARR(3)
		;tankstats[0] = nctankdata		;n
		;tankstats[1] = MEAN(ctankdata.field13)	;aveco2c13
		;tankstats[2] = (STDDEV(ctankdata.field13)) ;stdevco2c13
		
		goodruns=WHERE(runstats.nc GT 1,ngood)
		goodmo=MOMENT(runstats[goodruns].ave,sdev=sdev)
		tankstats[0] = ngood		;n
		tankstats[1] = goodmo[0]
		
		runstats=runstats[goodruns]
		
		;pooled standard deviation
		addnoms=0.0
		adddenoms=0.0
		sumnoms=FLTARR(ngood)
		sumdenoms=FLTARR(ngood)
	
		
		FOR u=0,ngood-1 DO BEGIN
			sumnoms[u]=runstats[u].stdev^2*(runstats[u].nc-1)
			addnoms=addnoms+sumnoms[u]
			sumdenoms[u]=runstats[u].nc-1
			adddenoms=adddenoms+sumdenoms[u]
		ENDFOR
		
		
		tankstats[2] = (addnoms/adddenoms)^0.5   ;;; weighted sdev   

	; ----- WRITE TO TANK STAT FILE ---------------------------------------------------
	statfile = '/projects/'+sp+'/cals/'+cyl+'/stats/'+tank+'.'+sp+'.stat'
	tankformat = '(I4, 2(F9.3))'
	statformat = '(A11,I3, 3(F9.3), A11, A4)'
	OPENW, u, statfile, /GET_LUN
	PRINTF, u, 'TANK: ' + tank
	PRINTF, u, 'INSTRUMENT: ' + tankdata[0].field17
	PRINTF, u, 'FILL_DATE:  ' + STRCOMPRESS(STRING(tankdata[0].field3) + '/' + $
		STRING(tankdata[0].field4) + '/' + $
		STRING(tankdata[0].field2), /REMOVE_ALL)
		PRINTF, u, 'TANK_STATISTICS'
	PRINTF, u, '  N    VALUE    weighted stdev'
	PRINTF, u, tankstats, format=tankformat
	PRINTF, u, 'RUN_STATISTICS'
	PRINTF, u, ' RUN_DATE    N   VALUE    STD.DEV  UNC REF      INST'      
	FOR i=0, ngood-1 DO PRINTF, u, runstats[i], format = statformat

	FREE_LUN, u
	n=N_ELEMENTS(tankdata)
	stop
	
	ENDFOR	
	; ----- GRAPH FULL FILE ---------------------------------------------------------
	

		
	
	cbflag=WHERE(STRMID(tankdata.field15,0,2) EQ '..' OR STRMID(tankdata.field15,0,2) EQ 'B.')
	cbdata=tankdata[cbflag]
	newplot=0
	IF newplot EQ 0 THEN BEGIN
		IF savegraphs EQ 1 THEN BEGIN
			IF cyl EQ 'external_cyl' THEN BEGIN
			ccg_opendev,dev=ourdev,pen=pen,$
				saveas='/projects/'+sp+'/cals/'+cyl+'/stats/'+tank+'.'+filldate+'.'+sp+'.'+ourdev
			ENDIF ELSE BEGIN
			ccg_opendev,dev=ourdev,$
				saveas='/projects/'+sp+'/cals/'+cyl+'/stats/'+tank+'.'+sp+'.'+ourdev
			ENDELSE
		ENDIF ELSE BEGIN
			ccg_opendev,dev=dev
		ENDELSE
	ENDIF		
		c13 = cbdata.field13
		ncb=N_ELEMENTS(cbdata)
		xcvalues = INDGEN(ncb) +1
		
		plotmean = mean(c13)
		range = c13yrange
		;xarr=INDGEN(nc+1)-1
	
	IF newplot EQ 0 THEN BEGIN
			PLOT, c13, TITLE=tank+' '+sp, /NODATA, $
			YRANGE=[(plotmean-range),(plotmean+range)], $
			POSITION=[0.1,0.25,0.90,0.85], /YSTYLE,$
			XSTYLE=1,$
			xrange=[0,ncb+1]  ;,$
			;ytitle=co2c13.title
			;XTICKNAME=xarr
			
			;o1 = WHERE(cbdata.field17 EQ 'o1' AND STRMID(cbdata.field15,0,2) EQ '..')
			;IF o1[0] NE -1 THEN OPLOT, xcvalues[o1], c13[o1], PSYM=1, SYMSIZE=1.0, THICK=2.0, COLOR=20
			i1 = WHERE(cbdata.field17 EQ 'i1' AND STRMID(cbdata.field15,0,2) EQ '..')
			IF i1[0] NE -1 THEN OPLOT, xcvalues[i1], c13[i1], PSYM=5, SYMSIZE=1.0, THICK=2.0, COLOR=16
			i3 = WHERE(cbdata.field17 EQ 'i3' AND STRMID(cbdata.field15,0,2) EQ '..')
			IF i3[0] NE -1 THEN OPLOT, xcvalues[i3], c13[i3], PSYM=6, SYMSIZE=1.0, THICK=2.0, COLOR=19
	ENDIF ELSE BEGIN
		; new plotting procedure goes here
		thisplot=PLOT(indgen(ncb)+1,c13, TITLE=tank, $
			YRANGE=[(plotmean-c13yrange),(plotmean+c13yrange)], $
			dimensions=[800,500],$
			
			POSITION=[0.15,0.15,0.90,0.85], $
			_extra=params,$
			color='blue',$
			xtitle='index',$
			YTITLE='$\delta$$^{13}$CH$_4$ ($\permil$)',$
			xrange=[0,ncb+1]) ;,$
			;ytitle=co2c13.title
			;XTICKNAME=xarr
		
			;o1 = WHERE(cbdata.field17 EQ 'o1' AND STRMID(cbdata.field15,0,2) EQ '..')
			;IF o1[0] NE -1 THEN OPLOT, xcvalues[o1], c13[o1], PSYM=1, SYMSIZE=1.0, THICK=2.0, COLOR=20
			;i1 = WHERE(cbdata.field17 EQ 'i1' AND STRMID(cbdata.field15,0,2) EQ '..')
			;IF i1[0] NE -1 THEN OPLOT, xcvalues[i1], c13[i1], PSYM=5, SYMSIZE=1.0, THICK=2.0, COLOR=16
			;i3 = WHERE(cbdata.field17 EQ 'i3' AND STRMID(cbdata.field15,0,2) EQ '..')
			;IF i3[0] NE -1 THEN OPLOT, xcvalues[i3], c13[i3], PSYM=6, SYMSIZE=1.0, THICK=2.0, COLOR=19
	ENDELSE
	

	
	badcdata = WHERE(STRMID(cbdata.field15,0,2) EQ 'B.')
	IF badcdata[0] NE -1 THEN OPLOT, xcvalues[badcdata], c13[badcdata], PSYM=4, SYMSIZE=1.0, THICK=2.0, COLOR=12

	OFFSCALE, x=findgen(n), y=c13, topedge=(plotmean+range), bottomedge=(plotmean-range), psym=1, COLOR=19

	
	IF savegraphs EQ 1 THEN BEGIN
		IF newplot EQ 1 THEN BEGIN
		stop
		; what happens here? 
			savename='/projects/'+sp+'/'+calsdir+'/'+cyl+'/stats/'+tank+'.'+sp+'.png'
			thisplot.save,savename
			;ccg_closedev,dev=ourdev,$
			savename='/projects/'+sp+'/'+calsdir+'/'+cyl+'/stats/'+tank+'.'+sp+'.png'
			thisplot.save,savename
			thisplot.close
			
		ENDIF
	ENDIF 
	
	print,'runstats = ',runstats
	print,'tankstats = ',tankstats
	;
	
	
	;;; new stuff here
	
	
	top=0.4
	j=0
	
	
	c13plot=ERRORPLOT(adatedec[goodruns],runstats.ave,runstats.stdev,position=[0.15,0.15,0.9,0.85])
	
	
	
	c13plot._extra=params
	c13plot.ytitle='$\delta$$^{13}$C-CH$_4$ ($\permil$)'
	c13plot.xtitle='analysis date'
	c13plot.color='blue'
	c13plot.symbol='circle'
		c13plot.yrange=[(plotmean-range),(plotmean+range)]

	c13plot.xrange=[(adatedec[goodruns[0]]-0.02),(adatedec[goodruns[ngood-1]]+0.02)]
	c13plot.errorbar_color='blue'
	c13plot.errorbar_capsize=0.1
	
	c13plot.ERRORBAR_THICK=2
        ;c13plot.ystyle=1
	
		
		TITLE=TEXT(0.45,0.94, tank, font_size=20)
	

	;;;;
	
	
	
	
	
END ; case 'ch4'




ENDCASE
skipthis:
bedone:
END
