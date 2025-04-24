
PRO tstflsk_lin,sp=sp,jras=jras,savegraphs=savegraphs,thistank=thistank
getdata=1

IF NOT KEYWORD_SET(sp) THEN sp='co2c13'
IF NOT KEYWORD_SET(thistank) THEN thistank='all'
;must choose ONE of these three

;options for this code. Choose one of these:
lintest=0   ; have not checked this feature
timeseries=0   ; not really in use ..
refcheck=1
;-------------

;if lintest, then choose this
plotbydiff=1

;other options
timezero=2016.0
sitefiles=0
yr1=2016
yr2=2026

this='db'   ; or sf for sitefiles

; goal, get all of the test flask data, match it up with peak heights, see if we see the problem
IF NOT KEYWORD_SET(jras) THEN jras=0
IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF NOT KEYWORD_SET(strategy) THEN strategy='flask'
IF sitefiles EQ 1 THEN BEGIN
	tstfile='/home/ccg/sil/testflasks/testflasks.linrealflagsadded.'+sp+'.txt'  ; OR whatever test file you designate
	IF jras EQ 0 THEN tstfile='/home/ccg/sil/testflasks/testflasks.instaar.'+sp+'.txt' ELSE $
	tstfile='/home/ccg/sil/testflasks/testflasks.jras.'+sp+'.txt'
ENDIF ELSE BEGIN
	tstfile='/home/ccg/sil/testflasks/testflasks.instaar.'+sp+'.txt'
ENDELSE

;testflasksav='/home/ccg/sil/testflasks/testflaskdata/'+sp+'.'+strategy+'.'+this+'.sav'
IF sp EQ 'ch4c13' THEN testflasksav='/home/ccg/sil/testflasks/testflaskdata/'+sp+'.'+strategy+'.'+this+'.sav' $
ELSE testflasksav='/home/ccg/sil/testflasks/testflaskdata/'+sp+'.'+strategy+'.'+this+'.filtered.sav'

RESTORE,filename=testflasksav


;------

bigcarr=['rosy brown', 'deep pink','aqua','blue','green','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue',$
					'light green','maroon','sky blue','plum','cadet blue','dark sea green','coral','firebrick','indigo','orange red',$
					'dodger blue','purple','forest green','light steel blue','tomato','hot pink',$
					'chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue','black','purple',$
					'green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown']


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

ntst=N_ELEMENTS(tst)

tank=STRARR(ntst)

tank=tst.tank+'_'+tst.fill

sortthem=SORT(tank)
tank=tank[sortthem]
tst=tst[sortthem]

utanks=UNIQ(tank)
uniqtanks=tank[utanks]
getdatesa=tst[utanks]  ;get dates of first tank  from the tst file
getdatesb=SORT(getdatesa.adate)   ;sort them by date of first tst flsk
uniqtanks=uniqtanks[getdatesb]  ;reorder uniq tnks


IF thistank NE 'all' THEN BEGIN
	justthisone=WHERE(uniqtanks EQ thistank)
	uniqtanks=uniqtanks[justthisone]
ENDIF

nuniq=N_ELEMENTS(uniqtanks)

params={symbol:'circle',$
	font_size:22,$
	linestyle:6,$
	font_name:'Helvetica',$
	sym_filled:1}

carr=['red','orange','lime green','blue','purple','teal','olive','cyan','forest green','violet','sienna','salmon','lawn green','gray','dark khaki','maroon','thistle',$
'slate blue','deep pink','chocolate','dark salmon','firebrick','plum','tomato','saddle brown','cadet blue','dodger blue','burlywood','light coral','green','aquamarine','royal blue','navy']

IF sp EQ 'co2o18' THEN BEGIN
	ourytitle='$\delta$$^{18}$O$_{CO2}$ ($\permil$)'
	y1=-2.5
	y2=1.5
ENDIF

IF sp EQ 'co2c13' THEN BEGIN
	ourytitle='$\delta$$^{13}$C$_{CO2}$ ($\permil$)'
	y1=-9.5
	y2=-7.5

ENDIF
IF sp EQ 'ch4c13' THEN BEGIN
	ourytitle='$\delta$$^{13}$C$_{CH4}$ ($\permil$)'
	y1=-48.5
	y2=-46.5


ENDIF
fillinderarr=REPLICATE({tankname:'',$
			num:0,$
			startdate:0.0,$
			enddate:0.0,$
			slope:0.0,$
			prob:0.0},nuniq*7)

; make arrays of means and stdevs and ns

IF sp NE 'ch4c13' THEN BEGIN	
	
	CCG_READ,file='/home/ccg/michel/refgas/ref.sieg.data',skip=1,refs
			;exclude DEWY
			keep=WHERE(refs.field1 NE 'DEWY-001',nrefs)
			refs=refs[keep].field1
ENDIF ELSE BEGIN

	refs=['unk','HARP-002','ZEPP-001','GARF-001','KENN-001']
	nrefs=5
	
ENDELSE
	; create arrays to make tables - designed for refcheck
	meanarr=FLTARR(nrefs,nuniq)
	diffarr=FLTARR(nrefs,nuniq)
	stdevarr=FLTARR(nrefs,nuniq)
	narr=INTARR(nrefs,nuniq)			

	;create arrays to look at test flask performance over time
	
	dataovertime=REPLICATE({date:0.0,$
		co2stdev:0.0,$
		stdev:0.0,$
		ref:''},nuniq*10)

p=0 
FOR n=0,nuniq-1 DO BEGIN
	
	
	these=WHERE(tank EQ uniqtanks[n],nflasks)
	flasks=tst[these]

	filterdata=1
	IF lintest EQ 1 THEN filterdata=0 
	IF filterdata EQ 1 THEN BEGIN
		IF nflasks LT 10 THEN goto,skipfilter 
		flaskmo=MOMENT(flasks.value,sdev=sdev)
		flaskmed=MEDIAN(flasks.value)
		
		keep=WHERE(flasks.value GT flaskmed[0]-(3*sdev) AND flasks.value LT flaskmed[0]+3*sdev,nflasks,complement=filteredout)
		thesetst=flasks[keep]
		nfiltered=N_ELEMENTS(filteredout)
		IF nfiltered GE 2 THEN filtered=flasks[filteredout]
		
		; NOTE: I have only filtered data going into refcheck option. Lintest and timeseries still use flasks. 
		skipfilter:
	ENDIF ELSE BEGIN
		thesetst=flasks
		nfiltered=0
	ENDELSE
	nflasks=N_ELEMENTS(thesetst)
	
	IF lintest EQ 1 THEN BEGIN
		IF sitefiles EQ 0 THEN savedir='/home/ccg/sil/testflasks/'+uniqtanks[n]+'_pkhts.sav' ELSE $
		savedir='/home/ccg/sil/testflasks/'+uniqtanks[n]+'_testfiles_pkhts.sav'
	
			
		IF getdata EQ 1 THEN BEGIN
		
			cylpkht=REPLICATE({pkht:0.0,diff:0.0},nflasks)
			FOR f=0,nflasks-1 DO BEGIN
				;get peak ht	
				
				ch4c13_peakht,enum=flasks[f].evn,peakheight=peakheight,refheight=refheight
			
				cylpkht[f].pkht=peakheight[0]
				cylpkht[f].diff=refheight[0]-peakheight[0]   ; just in case it ran twice. Should be rare
			ENDFOR
			SAVE, cylpkht,filename=savedir
			IF sitefiles EQ 0 THEN $
			testfile='/home/ccg/sil/testflasks/testflasks.instaar.pkhts.'+sp+'.txt' $ 
			ELSE testfile='/home/ccg/sil/testflasks/testflasks.testfiles.pkhts.'+sp+'.txt'
	
			;siteformat='(A10,A10,F11.5,1x,A3,F8.3,1x,A4,F13.3,F13.3,1X,A10,A3,F11.5,F11.5)'
			tstformat='(F11.5,I5,I3,I3,F11.5,1x,F11.5,A11, I9, F8.3,1X,F8.3,A3,A4,1X, F8.3,1X,F8.3,A11,A2,A9,1X,I5, 1X,F8.3,A4,F8.3,1X,F8.3,)' 

			OPENW, u,testfile, /GET_LUN
			;PRINTF,u,header
			;printthem=WHERE(printthese EQ 1,nprint)
			FOR k=0,nflasks-1 DO PRINTF,u,format=testformat,  $
			tst[k].date,$
			tst[k].yr,$
			tst[k].mo,$
			tst[k].dy,$
			tst[k].filldate,$
			tst[k].adate,$
			tst[k].id,$
			tst[k].evn,$
			tst[k].value,$
			tst[k].unc,$ 
			tst[k].inst,$ 
			tst[k].flag,$ 
			tst[k].unc,$ 
			tst[k].match,$ 
			tst[k].diff,$ 
			tst[k].tank,$ 
			tst[k].fill,$ 
			tst[k].ref,$ 
			tst[k].runnum,$ 
			tst[k].molfval,$ 
			tst[k].molfflag,$ 
			
			
			cylpkht[k].pkht,$
			cylpkht[k].diff

			FREE_LUN,u
			
		ENDIF ELSE BEGIN
			here=FILE_TEST(savedir)
			IF here EQ 0 THEN goto, skipthislin
			RESTORE, filename=savedir
		ENDELSE

		; get rid of peak=0 samples. OR, figure out why we're not getting peak heights 
		
		IF plotbydiff EQ 1 THEN BEGIN
			nflasks=N_ELEMENTS(flasks)
			thisx=cylpkht.diff
			
		ENDIF ELSE BEGIN
	 		usethese=WHERE(cylpkht.pkht GT 1,nflasks)
			cylpkht=cylpkht[usethese]
			flasks=flasks[usethese]
			thisx=cylpkht.pkht
		ENDELSE
	
		IF n EQ 0 THEN BEGIN
			
			thisplot=PLOT(thisx,flasks.value,dimensions=[1200,600],$
			;position=[0.15,0.15,0.75,0.85],
			color='white',_extra=params)
		
			thisplot.yrange=[y1,y2]
			IF plotbydiff EQ 1 THEN xrange=[-3,7] ELSE thisplot.xrange=[3,12]
			thisplot.ytitle=ourytitle
			IF plotbydiff EQ 1 THEN thisplot.xtitle='difference between standard and sample peak' ELSE thisplot.xtitle='beam height'  ; or, diff
		
		ENDIF 
		oursymsize=0.5
		; check to see if slope of line through points is different than zero. Assume equal errors of 0.06
		errarr=FLTARR(nflasks)+0.06
		
		result=SVDFIT(thisx, flasks.value,a=[0.],measure_errors=errarr,chisq=chisq1,sigma=sigma1,yfit=yfit1)	
		; Now look at chisq statistic
		df=nflasks-1
			nchisq=N_ELEMENTS(chisq)
			FOR d=0,nchisq-1 DO BEGIN
				IF df GE chisq[nchisq-1-d].field1 THEN BEGIN
					thisline=nchisq-1-d
					GOTO, getout
				ENDIF
			ENDFOR
			getout:
			
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

			thisprob=probs[match,0]
			IF match EQ 11 THEn thisprob2=probs[match,0] ELSE thisprob2=probs[match+1,0]
			print,'thisprob = ',thisprob		

	
	
			; now check to see if you're in date range
			
			IF flasks[0].adate GT timezero THEN begin
				add=PLOT(thisx,flasks.value,/overplot,sym_size=oursymsize,color=carr[n],_extra=params)
				line=PLOT(thisx,yfit1,/overplot,color=carr[n],linestyle=1,thick=1)
				tankname=TEXT(0.77,0.85-(0.04*n),uniqtanks[n],font_size=18,color=carr[n])
		
		
				IF thisprob LT 0.1 THEN BEGIN
				; now put a sloped line on it. Assume this will be highly significant. But now I care more about what the slope is. 
					result2=SVDFIT(thisx, flasks.value,a=[0.,0.],measure_errors=errarr,chisq=chisq2,sigma=sigma2,yfit=yfit2)	
					line=PLOT(thisx,yfit2,/overplot,color=carr[n],linestyle=1,thick=3)
					slopestr='slope =  '+ STRMID(STRCOMPRESS(STRING(result2[1]),/REMOVE_ALL),0,5)
					slope=TEXT(0.86,0.85-(0.04*n),slopestr,font_size=18,color=carr[n])
				ENDIF
			ENDIF	
			
			;fillinderarr[n].firstdate=
			;fillinderarr[n].lastdate=
			;fillinderarr[n].num=nflasks
			;fillinderarrp[n].slope=
			;fillinderarr[n].prob=
			skipthislin:
			
	ENDIF  ;lintest
	
	IF timeseries EQ 1 THEN BEGIN
	; time series plots
	
			thisplot=PLOT(tst.adate,tst.value,dimensions=[1000,600],$
			position=[0.15,0.15,0.75,0.85],$
			nodata=1,_extra=params)
			thisplot.xstyle=0
			thisplot.ystyle=0
			
			thisplot.yrange=[y1,y2]
			thisplot.xrange=[min(tst.adate)-1,yr2]
			thisplot.ytitle=ourytitle
			thisplot.xtitle='date'  ; or, diff
	
		FOR n=0,nuniq-1 DO BEGIN
			strpostank=STRPOS(uniqtanks[n],'_')
			thetank=STRMID(uniqtanks[n],0,strpostank)
			thefill=STRMID(uniqtanks[n],strpostank+1,1)
			thistank=WHERE(tst.tank EQ thetank and tst.fill EQ thefill,nthistank)
			
			oursymsize=0.5
			add=PLOT(tst[thistank].adate,tst[thistank].value,overplot=1,sym_size=oursymsize,color=carr[n],_extra=params,xstyle=0,ystyle=0)
				mo=MOMENT(tst[thistank].value,sdev=sdev)
				strsd=STRMID(STRCOMPRESS(STRING(sdev),/REMOVE_ALL),0,5)
				tankname=TEXT(0.78,0.8-(0.04*n),uniqtanks[n]+' sd = '+strsd,font_size=16,color=carr[n]) 
	
	
		ENDFOR
	ENDIF
	
	IF refcheck EQ 1 THEN BEGIN
		plotbyadate=0 
		addregression=1
		IF plotbyadate EQ 1 THEN thedate=thesetst.adate ELSE thedate=thesetst.date
	
		; go through each tankfill
		; plot tstflasks by ref
		alltogether=1   ;if alltogether=1, addco2 needs to be 0
		addco2=0
		IF addco2 EQ 0 THEN BEGIN
			ourdimensions=[1000,500]
			ourposition=[0.12,0.12,0.83,0.94]
			texty=0.8
			
		ENDIF ELSE BEGIN
			ourdimensions=[1000,800]
			;ourdimensions=[600,400]
			IF sp EQ 'ch4c13' THEN ourco2title='CH$_4$ (ppb)' ELSE ourco2title='CO$_2$ (ppm)'
			ourposition=[0.15,0.15,0.75,0.5]
			co2position=[0.15,0.5,0.75,0.85]
			
			texty=0.9
		ENDELSE
	
			symsize=0.6
			makerefplots=1
			print,'n = ',n
			print,uniqtanks[n]
			legsize=18	
			
			thistankmo=MOMENT(thesetst.value,sdev=sdev)
			
		
			IF makerefplots EQ 1 THEN BEGIN
					trythis=WINDOW(location=[100,100],dimensions=ourdimensions) 
			ENDIF 		
			IF addco2 EQ 1 THEN BEGIN
				IF sp EQ 'ch4c13' THEN co2range=10 ELSE co2range=5
				nozeroes=WHERE(thesetst.molfval GT 0.00)
				molfmo=MOMENT(thesetst[nozeroes].molfval,sdev=sdev)
				co2sdev=sdev
				IF makerefplots EQ 1 THEN BEGIN
					thisplot=PLOT(tthedate[nozeroes],thesetst[nozeroes].molfval,/current,dimensions=ourdimensions,$
					position=co2position,color='gray',sym_size=symsize,$
					_extra=params,ytitle=ourco2title)
					thisplot.yrange=[molfmo[0]-co2range,molfmo[0]+co2range]
					thisplot.xrange=[min(thesetst.adate)-0.2,max(thesetst.adate)+0.2]
					thisplot['axis2'].transparency=100
  					thisplot['axis3'].transparency=100
					thisplot.xshowtext=0
				
					IF filterdata EQ 1 AND nfiltered GE 2 THEN BEGIN
						nofzeroes=WHERE(filtered.molfval GT 0.00)
						IF nofzeroes[0] NE -1 THEN fplot=PLOT(filtered[nozeroes].adate,filtered[nofzeroes].molfval,linestyle=6,/overplot,$
						color='red',symbol='x',sym_size=symsize)
					
					ENDIF
					IF sp EQ 'ch4c13' THEN mf='ch4' ELSE mf='co2'
					co2mo=TEXT(0.8,texty+0.1,'stdev '+ mf+ ' = '+STRMID(STRCOMPRESS(STRING(co2sdev),/REMOVE_ALL),0,5),font_size=legsize,color='gray')
				ENDIF	
					
			ENDIF
				
			IF makerefplots EQ 1 THEN BEGIN
				thisplot=PLOT(thedate,thesetst.value,dimensions=ourdimensions,$
				position=ourposition,current=1,sym_size=symsize,$
				color='gray',_extra=params)
				
				
				
				thisplot.xstyle=0
				thisplot.ystyle=0
			
				thisplot['axis2'].transparency=100
  				thisplot['axis3'].transparency=100
			
				
			
				;range=0.45  ; could make species dependent
				IF sp EQ 'co2c13' THEN range=0.3 ELSE range=0.5
				;IF sp EQ 'co2c13' THEN range=0.4
				
				thisplot.yrange=[thistankmo[0]-range,thistankmo[0]+range]
				thisplot.xrange=[min(thesetst.adate)-0.2,max(thesetst.adate)+0.2]
				thisplot.ytitle=ourytitle
				;thisplot.xtitle=uniqtanks[n]
				tanknametext=TEXT(0.2,0.93,uniqtanks[n],font_size=20)
		
				;read refdata
				bigspacer=0.16
				lilspacer=0.038
				w=0
				
				
				IF addregression EQ 1 THEN BEGIN
				
				;------ lsqfit method
					LSQFITGM,x=thedate,y=thesetst.value,m,b,r,sm,sb,yfit,p2
				;	reg=FLTARR(nflasks)
				;	FOR r=0,nflasks-1 DO reg[r]=thedate[r]*m+b
				;	IF makerefplots EQ 1 THEN regline=PLOT(thedate,reg,linestyle=1,color='gray',/overplot)
				
				;------chisq svdfit method
					;first separate by analysis dates
					; find mean and stdev for each
					; then run svdfit
				
					
					;SVDFIT
				
				
				
					
				ENDIF 
			ENDIF	
			FOR r=0,nrefs-1 DO BEGIN
			
				IF addco2 eq 1 THEN dataovertime[p].co2stdev=co2sdev
				
				thisref=WHERE(thesetst.ref EQ refs[r],nthisref)
		
				IF thisref[0] NE -1 THEN BEGIN
				
					;thisref=thesetst[thisref]
					IF nthisref GE 6 THEN BEGIN
					
					
					
						thisrefmo=MOMENT(thesetst[thisref].value,sdev=sdev)
						meanarr[r,n]=thisrefmo[0]
						diffarr[r,n]=thisrefmo[0]-thistankmo[0]
						stdevarr[r,n]=sdev
						narr[r,n]=nthisref
						dataovertime[p].stdev=sdev
						dataovertime[p].ref=refs[r]
						dataovertime[p].date=median(thesetst.date)
						
						IF makerefplots EQ 1 THEN BEGIN
							thisplotref=PLOT(thedate[thisref],thesetst[thisref].value,sym_filled=1,sym_size=symsize,symbol='circle',/overplot,color=bigcarr[r],linestyle=6)
							xt=0.85
							refnametext=TEXT(xt,texty-(bigspacer*w),'WS = ' + refs[r],font_size=legsize,color=bigcarr[r])
							refnamemo=TEXT(xt,texty-(bigspacer*w)-lilspacer,'mean = '+STRMID(STRCOMPRESS(STRING(thisrefmo[0]),/REMOVE_ALL),0,5),font_size=legsize,color=bigcarr[r])
							refnamesd=TEXT(xt,texty-(bigspacer*w)-(2*lilspacer),'stdev = '+STRMID(STRCOMPRESS(STRING(sdev),/REMOVE_ALL),0,5),font_size=legsize,color=bigcarr[r])
							refnamenum=TEXT(xt,texty-(bigspacer*w)-(3*lilspacer),'n = '+STRMID(STRCOMPRESS(STRING(nthisref),/REMOVE_ALL),0,5),font_size=legsize,color=bigcarr[r])
							print,'min = ',min(thesetst[thisref].value)
							print,'max = ',max(thesetst[thisref].value)
							
							w=w+1
						ENDIF
					
						;if sdev GT 0.3 then stop
					
						;tstformat='(A10,A10,F11.5,1x,A3,F8.3,1x,A4,F13.3,F13.3,1X,A10,A3,F11.5,F11.5)'
						testfile='/home/ccg/sil/testflasks/testflaskdata/'+uniqtanks[n]+'_'+refs[r]+'.'+sp+'.txt'
					
						tstformat='(F11.5,I5,I3,I3,F11.5,1x,F11.5,A11, A11, F8.3,F8.3,A3,A4,1X, F8.3,F8.3,A11,A2,A9,I5, F8.3,A4)' 
						tstformat='(F11.5,I5,I3,I3,F11.5,1x,F11.5,A11, I9, F8.3,1X,F8.3,A3,A4,1X, F8.3,1X,F8.3,A11,A2,A9,1X,I5, 1X,F8.3,A4)' 

						OPENW, u,testfile, /GET_LUN
					
						FOR k=0,nthisref-1 DO PRINTF,u,format=tstformat,  $
							thesetst[thisref[k]]
							FREE_LUN,u

						p=p+1
					ENDIF	
				ENDIF
			
			
		
		
			ENDFOR
		
			
			
			
			IF makerefplots EQ 1 THEN BEGIN
			IF filterdata EQ 1 AND nfiltered GE 2 THEN BEGIN
						
				fplot=PLOT(filtered.adate,filtered.value,/overplot,$
					color='red',symbol='x',linestyle=6,sym_size=0.6)
					
				FOR f=0,nfiltered-1 DO PRINT, filtered[f].evn, '   ', filtered[f].value
						
			ENDIF
			
			plottank=1
			IF plottank EQ 1 THEN BEGIN
				;read tank values
				;match the tank
				; plot a couple lines
				
				; but first make sure that these have not been flagged as tank-not-agreeing with flasks. (tstflask_filter.pro)
				IF MEAN(thesetst.diff) GT 800 THEN goto, skiptank
				
				tankdatafile='/home/ccg/sil/testflasks/testflaskcyl.'+sp+'.txt'
				CCG_READ,file=tankdatafile,skip=1,tankresults
			
				lengthuniq=STRLEN(uniqtanks[n])
				capfill=STRMID(uniqtanks[n],lengthuniq-1,1)
				finddash=STRPOS(uniqtanks[n],'_',/REVERSE_SEARCH)
				thetankname=STRMID(uniqtanks[n],0,finddash)
				
				findit=WHERE(tankresults.field1 EQ thetankname AND STRUPCASE(tankresults.field5) EQ capfill)
				

				IF findit[0] NE -1 THEN BEGIN
					;all good data!
					tankmean=tankresults[findit].field6 
					tankstdev=tankresults[findit].field7 
					IF makerefplots EQ 1 THEN BEGIN
						themean=PLOT([min(thesetst.adate)-0.2,max(thesetst.adate)+0.2],[tankmean[0],tankmean[0]],color='gray',/overplot,linestyle=1)
						themean=PLOT([min(thesetst.adate)-0.2,max(thesetst.adate)+0.2],[tankmean[0]+tankstdev[0],tankmean[0]+tankstdev[0]],color='gray',/overplot,linestyle=3)
						themean=PLOT([min(thesetst.adate)-0.2,max(thesetst.adate)+0.2],[tankmean[0]-tankstdev[0],tankmean[0]-tankstdev[0]],color='gray',/overplot,linestyle=3)
					ENDIF
					
				ENDIF
					
					
				skiptank:	
			ENDIF
			IF savegraphs EQ 1 THEN BEGIN
				savename='/home/ccg/sil/testflasks/plots/'+uniqtanks[n]+'_byref.'+sp+'.png'
				thisplot.save,savename
				thisplot.close
			ENDIF
			ENDIF
		ENDIF	
		
ENDFOR
					
IF refcheck EQ 1 THEN BEGIN

keep=WHERE(dataovertime.date NE 0,nlines)
dataovertime=dataovertime[keep]
testfile='/home/ccg/sil/testflasks/testflaskdata/dataovertime.'+sp+'.txt'
					
	tstformat='(F11.5,F11.5,F11.5,A11)' 
					
	OPENW, u,testfile, /GET_LUN
					
	FOR k=0,nlines-1 DO PRINTF,u,format=tstformat,  $
	dataovertime[k]
	FREE_LUN,u
				
stop	
		
diffplot=PLOT(dataovertime.date,dataovertime.stdev,color='blue',symbol='circle', linestyle=6,dimensions=[1400,700]) 
					
			diffplot['axis2'].transparency=100
			diffplot['axis3'].transparency=100
		
			IF sp EQ 'co2c13' THEN BEGIN
					 ourytitle='Standard deviation of testflasks, $\delta$$^{13}$C$_{CO2}$ ($\permil$) '
		
 					ymin=-0.15
					ymax=0.15	
	 		ENDIF ELSE BEGIN 
	  				ourytitle='Standard deviation of testflasks, $\delta$$^{18}$O$_{CO2}$ ($\permil$) '
					 ymin=-0.3
					 ymax=0.3
			ENDELSE
		 
	
	
meanformat='(A12,35(F11.5))'
strformat='(36(A12))'
	nformat='(A12,35(I4))'
testfile='/home/ccg/sil/testflasks/testflaskdata/tankrefsummary.'+sp+'.txt'
strrefs=STRARR(nrefs)
FOR r=0,nrefs-1 DO strrefs[r]=refs[r]
					
OPENW, u,testfile, /GET_LUN
 PRINTF,u,format=strformat,strrefs
					
;printthem=WHERE(printthese EQ 1,nprint)
FOR n=0,nuniq-1 DO BEGIN
	PRINTF,u,format=meanformat, uniqtanks[n],meanarr[*,n]
	PRINTF,u,format=meanformat, uniqtanks[n],stdevarr[*,n]
	PRINTF,u,format=nformat, uniqtanks[n],narr[*,n]
ENDFOR
FREE_LUN,u
makediffplot=0
IF thistank EQ 'all' THEN BEGIN
SAVE,filename='/home/ccg/sil/testflasks/testflaskdata/meanarr.'+sp+'.sav',meanarr
SAVE,filename='/home/ccg/sil/testflasks/testflaskdata/stdevarr.'+sp+'.sav',stdevarr
SAVE,filename='/home/ccg/sil/testflasks/testflaskdata/narr.'+sp+'.sav',narr
SAVE,filename='/home/ccg/sil/testflasks/testflaskdata/uniqtanks.'+sp+'.sav',uniqtanks
makediffplot=1
ENDIF
				;;;-------------------------------
IF makediffplot EQ 1 THEN BEGIN	
	
		xmin=1990
		xmax=2024
			
		; call refcodes_getrange
		;refcodes_getrange,ojunc=ojunc,cjunc=cjunc,middate=middate,firstdate=firstdate,lastdate=lastdate,cdiff=cdiff,odiff=odiff  ; all are arrays in the same order of refcodes.
	
			params={thick:3, $
			font_size:22,$
			yticklen: 0.02,$
			sym_size:1}		 

		;working with diffarr
		indexarr=INDGEN(nrefs)+1

		reftickarr=STRARR(nrefs+1) ; not 2
		reftickarr[0]=' '
		reftickarr[nrefs]=' '
		FOR t=0,nrefs-1 DO reftickarr[t+1]=refs[t]
	
			
				
	
		diffplot=PLOT(indexarr,diffarr[*,0],color='white',dimensions=[1400,700]) 
					
			diffplot['axis2'].transparency=100
			diffplot['axis3'].transparency=100
		
			CASE sp of 
			'co2c13': BEGIN
					 ourytitle='Normalized difference in $\delta$$^{13}$C$_{CO2}$ ($\permil$) of test flasks'
		
 					ymin=-0.15
					ymax=0.15	
	 		END
			'co2o18': BEGIN
					ourytitle='Normalized difference in $\delta$$^{18}$O$_{CO2}$ ($\permil$) of test flasks'
					 ymin=-0.3
					 ymax=0.3
			END
			'ch4c13':BEGIN
					 ourytitle='Normalized difference in $\delta$$^{13}$C$_{CO2}$ ($\permil$) of test flasks'
		
 					ymin=-0.15
					ymax=0.15
		 	END
			ENDCASE
			diffplot.position=[0.15,0.15,0.9,0.9]
			;diffplot.xrange=[0,nrefs+1]
			
			 
			diffplot.yrange=[ymin,ymax]
			diffplot.xrange=[0,40]
			diffplot.ytitle=ourytitle
			diffplot.yminor=1
			diffplot.xminor=1
			diffplot.xshowtext=0
			ax=diffplot.axes
			ax[0].text_orientation=270
			;ax[0].tickinterval=1
			diffplot.xsubticklen=0
			diffplot.xticklen=0
			diffplot._extra=params
		
			diffstatsarr=DBLARR(nrefs,nuniq)	
	
			zeroarr=FLTARR(nrefs)

					;now plot the refs with their errors
				
		
		nameprint=-0.15
		nudge=0.3	
		
		FOR t=0,nuniq-1 DO BEGIN
		 
			print,uniqtanks[t]
		 
			thisdiff=WHERE(diffarr[*,t] NE 0,nthis)
			
			IF thisdiff[0] EQ -1 THEN goto,notthisone
			
			col='red'
			
				IF nthis GE 2 THEN BEGIN 
					diffplotdata=ERRORPLOT(indexarr[thisdiff],diffarr[thisdiff,t],stdevarr[thisdiff,t],_extra=params,color=col,linestyle=6,sym_filled=1,/overplot,$
					symbol='circle') 
					diffplotdata.errorbar_color=col
					diffplotdata.errorbar_capsize=0.1
					diffplotdata.errorbar_thick=2
				ENDIF
			
			print,uniqtanks[t]
		
			notthisone:			
		ENDFOR	
		
		FOR r=0,nrefs-1 DO thisname=TEXT(indexarr[r]+nudge,nameprint,/data,refs[r],orientation=90,font_size=16)
		
ENDIF		
		
ENDIF					



END
