
; you can run these all at once with the code test_flask_comp.pro
; calls testflaskcyl
; make_testgastab
; tstflsk

; currently just has keywords sp and jras 
; but eventually should have savegraphs
; strategy,
; by inst/fill etc



PRO tstflsk,sp=sp,savegraphs=savegraphs,plotbytank=plotbytank,$
plotbyinst=plotbyinst,strategy=strategy


IF NOT KEYWORD_SET(sp) THEN sp='co2c13'
IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF NOT KEYWORD_SET(strategy) THEN strategy='flask'

IF sp EQ 'ch4c13' THEN style='oldstyle' ELSE style='newstyle'

sitefiles=0  ; working with DB data
getdata=1

; you may choose one of these options
; 
plotbytank=1
plotbyinst=0
plotbyref=0

;OR you can plot a summary of test flasks by year
plotsummaries=0
byfill=0
byinst=0
byref=1


yr1=2016
yr2=2026

IF NOT KEYWORD_SET(strategy) THEN strategy='flask'
adate=1

;; look for whether pfps were run first on troi or tpol
doesordermatter=1


IF sitefiles EQ 0 THEN this='db' ELSE this='sf'

;this is the file that will match flask data to cylinder	
 tstgasfile='/home/ccg/sil/testflasks/tabdata.'+sp+'.txt'
 
;this is the sav file that will store data	
testflasksav='/home/ccg/sil/testflasks/testflaskdata/'+sp+'.'+strategy+'.'+this+'.sav'

			


;IF NOT keyword_set(plotbytank) THEN plotbytank=1
;IF NOT keyword_set(plotbyinst) THEN plotbyinst=0
;IF NOT keyword_set(jras) THEN jras=1

;IF plotbyinst EQ 1 THEN plotbytank=0

; purpose: to plot test flask data relative to the cylinder it was filled from
; works in combination with testflaskcyl.pro, which gets data from test flask cylinders, and
; make_testgastab, which compiles that data into the 'tab' file

; either use data base data 'usedb'
;or test jras data 'jras'
;;strategy=strategy,
;jras=0  ;usedb=1
;IF jras EQ 1 THEN sitefiles=1 ELSE sitefiles=0
;sitefiles=1
;IF sitefiles EQ 1 THEN BEGIN
;	IF sp EQ 'co2c13' THEN BEGIN
;		
;		IF jras EQ 1 THEN tstgasfile='/home/ccg/sil/testflasks/tabdata.jr.'+sp+'.txt' $
;			ELSE tstgasfile='/home/ccg/sil/testflasks/tabdata.'+sp+'.txt' 
;		testflaskfile='/home/ccg/sil/'+sp+'/sitefiles_jras06/tst.'+sp
;		
;		
;		IF jras EQ 1 THEN writefile='/home/ccg/sil/testflasks/testflasks.jras.'+sp+'.txt' ELSE $
;;		writefile='/home/ccg/sil/testflasks/testflasks.instaar.'+sp+'.txt';;
;
;	ENDIF 
;	IF sp EQ 'ch4c13' THEN BEGIN	
;		 tstgasfile='/home/ccg/sil/testflasks/tabdata.'+sp+'.txt'
;		; currently same for sitefiles or not
;		
;		
;			testflaskfile='/home/ccg/sil/'+sp+'/testfiles/tst.'+sp
;			newfile='/home/ccg/sil/testflasks/testflaskdata.testfiles.byyear.'+sp+'.txt'
;			writefile='/home/ccg/sil/testflasks/testflasks.testfiles.'+sp+'.txt' 
;	ENDIF
;	IF sp EQ 'co2o18' THEN BEGIN	
;		 tstgasfile='/home/ccg/sil/testflasks/tabdata.'+sp+'.txt'
;		; currently same for sitefiles or not
;		
;		
;			testflaskfile='/home/ccg/sil/'+sp+'/testfiles/tst.'+sp
;			newfile='/home/ccg/sil/testflasks/testflaskdata.testfiles.byyear.'+sp+'.txt'
;			writefile='/home/ccg/sil/testflasks/testflasks.testfiles.'+sp+'.txt' 
;	ENDIF;
;
;ENDIF ELSE BEGIN
;	newfile='/home/ccg/sil/testflasks/testflaskdata.byyear.'+sp+'.txt'
;	writefile='/home/ccg/sil/testflasks/testflasks.instaar.'+sp+'.txt'
;ENDELSE

IF sitefiles EQ 1 THEN BEGIN
	testflaskfile='/home/ccg/sil/'+sp+'/testfiles/tst.'+sp
	; you'll get dat from some file defined here.
	;outputfiles will be named accordingly.
	testflaskfile='/home/ccg/sil/'+sp+'/testfiles/tst.'+sp
	newfile='/home/ccg/sil/testflasks/testflaskdata.byyear.'+sp+'.txt'
	writefile='/home/ccg/sil/testflasks/testflasks.sitefiles.'+strategy+'.'+sp+'.txt'
ENDIF ELSE BEGIN
	;otherwise you'll get data from db
	newfile='/home/ccg/sil/testflasks/testflaskdata.byyear.'+sp+'.txt'
	writefile='/home/ccg/sil/testflasks/testflasks.'+strategy+'.'+sp+'.txt'

ENDELSE



;;; reading test gas tab file within local directory, not what is in /projects. (see lines 15-18 above)
;CCG_SREAD, file=tstgasfile,skip=56,ststtank

CCG_SREAD, file=tstgasfile,skip=0,ststtank

lbsign=STRPOS(ststtank,'#')

truncate=STRMID(ststtank,0,50)

tstfile='/home/ccg/sil/tempfiles/tstgas.txt'
CCG_SWRITE,file=tstfile ,truncate

CCG_READ,file=tstfile ,tsttank
ntanks=n_elements(tsttank)
tankdate=FLTARR(ntanks)

CCG_DATE2DEC,yr=tsttank.field1,mo=tsttank.field2,dy=tsttank.field3,dec=dec
tankdate=dec

sorttanks=SORT(tankdate)
tankdate=tankdate[sorttanks]
tsttank=tsttank[sorttanks]
inst=STRARR(ntanks)
FOR t=0,ntanks-1 DO BEGIN
	lbsign=STRPOS(ststtank[t],'#')
	inst[t]=STRMID(ststtank[t],lbsign+1,2)
ENDFOR
date=[yr1,yr2]

IF sitefiles EQ 0 THEN BEGIN
	CCG_FLASK, site='tst',strategy=strategy,date=date,sp=sp,/ret,tstfiledat
	
		
ENDIF ELSE BEGIN
	
	CCG_READ, file=testflaskfile,tstfiledat

	keep=where(tstfiledat.field2 GT FIX(yr1))

	tstfiledat=tstfiledat[keep]
ENDELSE

ntst=N_ELEMENTS(tstfiledat)

tst=REPLICATE({date:0.0D,$
		yr:0,$
		mo:0,$
		dy:0,$
		filldate:0.0,$   ;used just to number pfps
		adate:0.0D,$
		id:'',$
		evn:'',$
		value:0.0,$
		unc:0.0,$
		inst:'',$
		flag:'', $
		match:0.0,$
		diff:0.0,$
		tank:'',$
		fill:'',$
		ref:'',$
		runnum:0,$
		molfval:0.0,$
		molfflag:''},ntst)



	
IF sitefiles EQ 0 THEN BEGIN
		tst.id=tstfiledat.id
		tst.date=tstfiledat.date
		tst.yr=tstfiledat.yr
		tst.mo=tstfiledat.mo
		tst.dy=tstfiledat.dy
		
		tst.adate=tstfiledat.adate
		tst.evn=tstfiledat.evn
		tst.value=tstfiledat.value
		tst.unc=tstfiledat.unc
		tst.flag=tstfiledat.flag
		tst.inst=tstfiledat.inst

ENDIF ELSE BEGIN	

	
		CCG_DATE2DEC,yr=tstfiledat.field2,mo=tstfiledat.field3,dy=tstfiledat.field4,dec=dec
		tst.date=dec
		CCG_DATE2DEC,yr=tstfiledat.field12,mo=tstfiledat.field13,dy=tstfiledat.field14,$
		hr=tstfiledat.field15,mn=tstfiledat.field16,dec=dec
		tst.adate=dec
		
		tst.id=tstfiledat.field8
	;	compevn=STRING(tstfiledat.field18)
	;	tst.evn=compevn.compress()
		tst.value=tstfiledat.field9
	;	tst.unc=-0.009
		tst.flag=tstfiledat.field10
		tst.inst=tstfiledat.field11
		
ENDELSE




IF getdata EQ 1 THEN BEGIN
;read ref info
		
	
	;FOR i=ntst-50,ntst-1 DO BEGIN
	FOR i=0,ntst-1 DO BEGIN
		; now go get the co2 data for this test flask
		print,'i = ',i
		IF sp EQ 'ch4c13' then mf='ch4' ELSE mf='co2'
		CCG_FLASK, sp=mf,evn=tst[i].evn,co2dat
		sizeco2=SIZE(co2dat)
		IF sizeco2[0] GT 0 THEN BEGIN
			tst[i].molfval=co2dat[0].value   ; this assumes one value per test flask - doesn't look at flagging here
			tst[i].molfflag=co2dat[0].flag
			tst[i].runnum=000
		ENDIF ELSE BEGIN
			tst[i].molfval=0.000   ; this assumes one value per test flask - doesn't look at flagging here
			tst[i].molfflag='---'
			tst[i].runnum=000
		ENDELSE
	
		IF sp EQ 'ch4c13' THEN BEGIN

			IF tst[i].adate LT 2004 THEN BEGIN
				;stop ;; we just don't know it.
				tst[i].ref='olddata'
				tst[i].runnum=runnum
			ENDIF ELSE BEGIN
				ch4c13_runnum,enum=tst[i].evn,ref=ref,runnum=runnum
				tst[i].ref=ref
				 tst[i].runnum=runnum
		
			ENDELSE 
				
				;we could make a refcodes_getrange here, but it's harder because zepp and harp were used
				;interchangeably.
			
		
		ENDIF ELSE BEGIN
			CCG_READ,file='/home/ccg/michel/refgas/ref.sieg.data',skip=1,refcodes
			;exclude DEWY
			keep=WHERE(refcodes.field1 NE 'DEWY-001',nrefcodes)
			refcodes=refcodes[keep]
			these=WHERE(refcodes.field2 EQ tst[i].inst,nthese)
			FOR k=0,nthese-1 DO BEGIN
				IF tst[i].adate GE refcodes[these[k]].field9 THEN BEGIN
					IF tst[i].adate LE refcodes[these[k]].field10 THEN BEGIN
						;found your match
						tst[i].ref=refcodes[these[k]].field1
						print,'ref = ',tst[i].ref
					
						;;;refvalarr[j]=refcodes[these[k]].field13   ; if you want to get values, either fields 13 or 15
					goto,gottheref
			
					ENDIF
				ENDIF 
			ENDFOR	
		ENDELSE
										
		gottheref:
	ENDFOR

	
       ;FOR i=ntst-50,ntst-1 DO BEGIN
	FOR i=0,ntst-1 DO BEGIN
	j=0
	; figure out which tank it was filled from 
	; start date=field8
		FOR j=0,ntanks-1 DO BEGIN
	
			print,tankdate[ntanks-j-1]
			IF tst[i].date GT tankdate[ntanks-j-1] THEN BEGIN
	
				; we have a match at the last one
				tst[i].match=tsttank[ntanks-j-1].field9
				tst[i].tank=tsttank[ntanks-j-1].field5 ;;+'_'+tsttank[ntanks-j-1].field6
				tst[i].fill=tsttank[ntanks-j-1].field6
			
				print,'foundit'
				
				 GOTO, bump
	
			ENDIF ELSE BEGIN
			
				tst[i].match=-99
				tst[i].tank='yabba'
				tst[i].fill='z'
			  print,'not filledby ', tankdate[ntanks-j-1], '   j= ',j
			ENDELSE

		

		ENDFOR
	
		bump:
	ENDFOR
	ok=WHERE(STRMID(tst.flag,0,1) EQ '.',ntst)
	tst=tst[ok]

	SAVE, filename=testflasksav,tst	

ENDIF ELSE BEGIN

	RESTORE,filename=testflasksav

ENDELSE

IF adate EQ 1 THEN tstdate=tst.adate ELSE tstdate=tst.date

tst.diff=tst.value-tst.match
only=WHERE(ABS(tst.diff) LT 10,ntst)

tst=tst[only]
o1=WHERE(tst.inst EQ 'o1')
i2=WHERE(tst.inst EQ 'i2')
i4=WHERE(tst.inst EQ 'i4')
i6=WHERE(tst.inst EQ 'i6')

IF style EQ 'oldstyle' THEN BEGIN
	AL47113=WHERE(tst.tank EQ 'AL47113')
	AL47104=WHERE(tst.tank EQ 'AL47104')
	AL47108=WHERE(tst.tank EQ 'AL47108')
	AL47145=WHERE(tst.tank EQ 'AL47145')

ENDIF ELSE BEGIN
	AL47113=WHERE(tst.tank EQ 'AL47-113')
	AL47104=WHERE(tst.tank EQ 'AL47-104')
	AL47108=WHERE(tst.tank EQ 'AL47-108')
	AL47145=WHERE(tst.tank EQ 'AL47-145')
ENDELSE
	 ND39909=WHERE(tst.tank EQ 'ND39909')

params={linestyle:6, $
	 symbol: 'circle',$
	 font_name: 'Helvetica',$
	 thick:3, $
	 sym_size:0.5,$
	 font_size:16}
	 
bigparams={linestyle:6, $
	 symbol: 'circle',$
	 font_name: 'Helvetica',$
	 thick:3, $
	 sym_size:1.5,$
	  sym_filled:1,$
	 font_size:16}	 
	 
 IF sp EQ 'co2c13' THEN yrange=[-0.2,0.2]
IF sp EQ 'co2o18' THEN yrange=[-0.25,0.25]
IF sp EQ 'ch4c13' THEN yrange=[-0.35,0.35]
IF sp EQ 'co2c13' THEN ytitle='difference in $\delta$$^{13}$C$_C_O_2$ ($\permil$)'
IF sp EQ 'co2o18' THEN ytitle='difference in $\delta$$^{18}$O$_C_O_2$ ($\permil$)'
IF sp EQ 'ch4c13' THEN ytitle='difference in $\delta$$^{13}$C$_C_H_4$ ($\permil$)'

bigcarr=['green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue',$
					'light green','maroon','sky blue','plum','cadet blue','dark sea green','coral','firebrick','indigo','orange red',$
					'dodger blue','purple','forest green','light steel blue','tomato','hot pink',$
					'chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue','black','purple',$
					'green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown']
	 
IF plotsummaries EQ 0 THEN BEGIN

	tstplot=PLOT(tst.adate,tst.diff,dimensions=[1200,600],position=[0.12,0.12,0.87,0.88], color='light gray')
	tstplot['axis2'].transparency=100
	tstplot['axis3'].transparency=100
	tstplot.ytitle=ytitle
	titletext=TEXT(0.2,0.9,'Difference between test flask and test cylinder',font_size=20)

	tstplot.xrange=[yr1,yr2+1]
	tstplot.yrange=yrange
	tstplot._extra=params
	;IF jras EQ 1 THEN txt=TEXT(2018,-0.3, 'JRAS-06',/data,font-size=15) ELSE $
	;txt=TEXT(2018,-0.1, 'INSTAAR',/data,font-size=15) 
	
	IF plotbyinst EQ 1 THEN BEGIN
	
		o1plot=PLOT(tst[o1].adate,tst[o1].diff,/OVERPLOT,name='o1')
		o1plot.color='red'
		o1plot.sym_filled=1
		o1plot._extra=params

		i2plot=PLOT(tst[i2].adate,tst[i2].diff,/OVERPLOT,name='i2')
		i2plot.color='green'
		i2plot.sym_filled=1
		i2plot._extra=params

		IF i4[0] NE -1 THEN BEGIN
			i4plot=PLOT(tst[i4].adate,tst[i4].diff,/OVERPLOT,name='i4')
			i4plot.color='turquoise'
			i4plot.sym_filled=1	
			i4plot._extra=params
		ENDIF
		IF i6[0] NE -1 THEN BEGIN
			i6plot=PLOT(tst[i6].adate,tst[i6].diff,/OVERPLOT,name='i6')
			i6plot.color='blue'
			i6plot.sym_filled=1	
			i6plot._extra=params
		ENDIF

		;leg=legend(target=[o1plot,i2plot,i4plot,i6plot],/data,position=[2015.3, 0.09], shadow=0,sample_width=0, linestyle=6)  ;
		leg=legend(target=[o1plot,i2plot,i6plot],/data,position=[2016.5, -0.09], shadow=0,sample_width=0, linestyle=6)  ;
	ENDIF 

	IF plotbytank EQ 1 THEN BEGIN
		IF AL47104[0] NE -1 THEN BEGIN
			aplot=PLOT(tst[AL47104].adate,tst[AL47104].diff,/OVERPLOT,name='AL47104')
			aplot.color='red'
			aplot.sym_filled=1
			aplot._extra=params
		ENDIF
		
		IF AL47108[0] NE -1 THEN BEGIN
		
			bplot=PLOT(tst[AL47108].adate,tst[AL47108].diff,/OVERPLOT,name='AL47108')
			bplot.color='green'
			bplot.sym_filled=1
			bplot._extra=params
		ENDIF
	
		IF AL47113[0] NE -1 THEN BEGIN		
			cplot=PLOT(tst[AL47113].adate,tst[AL47113].diff,/OVERPLOT,name='AL47113')
			cplot.color='turquoise'
			cplot.sym_filled=1
			cplot._extra=params
		ENDIF
		
		IF AL47145[0] NE -1 THEN BEGIN
		
			dplot=PLOT(tst[AL47145].adate,tst[AL47145].diff,/OVERPLOT,name='AL47145')
			dplot.color='blue'
			dplot.sym_filled=1
			dplot._extra=params
		
		;	leg=legend(target=[aplot,bplot,cplot,dplot],position=[0.99,0.8], font_size=22,shadow=0,sample_width=0, linestyle=6)  ;
		END
		
		IF ND39909[0] NE -1 THEN BEGIN
		
			dplot=PLOT(tst[ND39909].adate,tst[ND39909].diff,/OVERPLOT,name='ND39909')
			dplot.color='blue'
			dplot.sym_filled=1
			dplot._extra=params
		
		;	leg=legend(target=[aplot,bplot,cplot,dplot],position=[0.99,0.8], font_size=22,shadow=0,sample_width=0, linestyle=6)  ;
		END
	ENDIF 	

	IF plotbyref EQ 1 THEN BEGIN
		fontsize=15
		spacer=0.035
		w=0
		IF sp EQ 'ch4c13' THEN BEGIN 
			nrefcodes=5
			refarr=['unk','HARP-002','ZEPP-001','GARF-001','KENN-001']
		ENDIF ELSE BEGIN
			IF getdata EQ 0 THEN BEGIN
					CCG_READ,file='/home/ccg/michel/refgas/ref.sieg.data',skip=1,refcodes
					keep=WHERE(refcodes.field1 NE 'DEWY-001',nrefcodes)
					refcodes=refcodes[keep]
			ENDIF
		ENDELSE
		
		FOR r=0,nrefcodes-1 DO BEGIN
			IF sp EQ 'ch4c13' THEN refdata=WHERE(tst.ref EQ refarr[r],nthisref) ELSE refdata=WHERE(tst.ref EQ refcodes[r].field1,nthisref)
				stop
			IF nthisref GE 2 THEN BEGIN
				thisrefplot=PLOT(tst[refdata].adate,tst[refdata].diff,/OVERPLOT,color=bigcarr[r],_extra=params,linestyle=6,sym_filled=1)
				IF sp EQ 'ch4c13' THEN refnametext=TEXT(0.9,0.8-(spacer*w),refarr[r],font_size=fontsize,color=bigcarr[r])$
					ELSE refnametext=TEXT(0.9,0.8-(spacer*w),refcodes[r].field1,font_size=fontsize,color=bigcarr[r]) 
				
				w=w+1

			ENDIF
		ENDFOR



	ENDIF
ENDIF ELSE BEGIN



; can divy up by year ...
; or by tank-fill
;or by ref

bytankfill=0
IF bytankfill EQ 1 THEN BEGIN
	nlines=N_ELEMENTS(tst)
	tankfill=strarr(nlines)

	tankfill=tst.tank+tst.fill
	sortthem=SORT(tankfill)
	tankfill=tankfill[sortthem]
	tst=tst[sortthem]

	uniqfills=UNIQ(tankfill)
	uniqtesttanks=tst[uniqfills]
	uniqtanks=uniqtesttanks.tank
	uniqtankfills=uniqtesttanks.fill

	nuniq=N_ELEMENTS(uniqtanks)
	
	summary=REPLICATE({tank:'',$
		fill:'',$
		mean:0.0,$
		stdev:0.0,$
		num:0},nuniq)
		
		
	FOR t=0,nuniq-1 DO BEGIN
	summary[t].tank=uniqtanks[t]
	summary[t].fill=uniqtankfills[t]
	findthem=WHERE(tst.tank EQ uniqtanks[t] AND tst.fill EQ uniqtankfills[t],nthese)
	tankmo=MOMENT(tst[findthem].diff,sdev=sdev)
	
	summary[t].mean=tankmo[0]
	summary[t].stdev=sdev
	summary[t].num=nthese
	
	ENDFOR

	tstplot=ERRORPLOT(indgen(nuniq),summary.mean,summary.stdev,dimensions=[1200,600],position=[0.12,0.12,0.87,0.88],color='red')
	tstplot['axis2'].transparency=100
	tstplot['axis3'].transparency=100
	tstplot.ytitle=ytitle
	titletext=TEXT(0.2,0.9,'Difference between test flask and test cylinder',font_size=20)
	tstplot.yrange=yrange
	tstplot._extra=bigparams

ENDIF 
IF byyear EQ 1 THEN BEGIN
	;by year
	nyrs=yr2-yr1+1	
	summary=REPLICATE({yr:0,$
		
		mean:0.0,$
		stdev:0.0,$
		num:0},nyrs)

	FOR y=0,nyrs-1 DO BEGIN
		summary[y].yr=yr1+y
		findthem=WHERE(tst.date GT yr1+y AND tst.date LT yr1+y+1,nthese)
		IF findthem[0] EQ -1 THEN goto,skip
		tankmo=MOMENT(tst[findthem].diff,sdev=sdev)
		summary[y].mean=tankmo[0]
		summary[y].stdev=sdev
		summary[y].num=nthese
		
		skip:
	ENDFOR
	goto,skipfornow
	tstplot=ERRORPLOT(summary.yr,summary.mean,summary.stdev,dimensions=[1200,600],position=[0.12,0.12,0.87,0.88],color='red',sym_size=1)
	tstplot['axis2'].transparency=100
	tstplot['axis3'].transparency=100
	tstplot.ytitle=ytitle
	tstplot.title='Mean difference between test '+strategy +' and test cylinder'
	tstplot.yrange=yrange
	tstplot._extra=bigparams
	tstplot.errorbar_color='red'
	tstplot.errorbar_capsize=0.1
	tstplot.errorbar_thick=2
	tstplot.errorbar_linestyle=0
	skipfornow:
	
ENDIF
IF byref EQ 1 THEN BEGIN
	
	
	summary=REPLICATE({ref:'',$		
		mean:0.0,$
		stdev:0.0,$
		num:0},nrefcodes)

	FOR y=0,nrefcodes-1 DO BEGIN
		summary[y].ref=refcodes[y].field1
		findthem=WHERE(tst.ref EQ refcodes[y].field1,nthese)
		IF findthem[0] EQ -1 THEN goto,skipref
		tankmo=MOMENT(tst[findthem].diff,sdev=sdev)
		summary[y].mean=tankmo[0]
		summary[y].stdev=sdev
		summary[y].num=nthese
		
		skipref:
	ENDFOR
	
	onlythese=WHERE(summary.mean NE 0,nonly)
	summary=summary[onlythese]
	indexarr=INTARR(nonly)
	;goto,skipfornow
	tstplot=ERRORPLOT(indexarr,summary.mean,summary.stdev,dimensions=[1200,600],position=[0.12,0.12,0.87,0.88],color='red',sym_size=1)
	tstplot['axis2'].transparency=100
	tstplot['axis3'].transparency=100

	tstplot.ytitle=ytitle
	tstplot.title='Mean difference between test '+strategy +' and test cylinder'
	tstplot.yrange=yrange
	tstplot.xrange=[-1,nonly+1]
	tstplot._extra=bigparams
	tstplot.errorbar_color='red'
	tstplot.errorbar_capsize=0.1
	tstplot.errorbar_thick=2
	tstplot.errorbar_linestyle=0
	;skipfornow:
	



ENDIF

ENDELSE

;print data to file so I can get after nitty gritty

tstformat='(F11.5,I5,I3,I3,F11.5,1x,F11.5,A11, I9, F8.3,1X,F8.3,A3,A4,1X, F8.3,1X,F8.3,A11,A2,A9,1X,I5, 1X,F8.3,A4)' 
					
;header = 'id,evn,filldate,adate,inst,value,flag,diff,match,tank,fill mf mfflag'
header= 'date yr mo dy (filldate) adate id evn value unc inst flag match diff tank fill ref runnum molfval molfflag'
OPENW, u,writefile, /GET_LUN
PRINTF,u,header
FOR k=0,ntst-1 DO PRINTF,u,format=tstformat,  $
tst[k]


;tst[k].id,$
;tst[k].evn,$
;tst[k].date,$
;tst[k].adate,	$
;tst[k].inst,    $
;tst[k].value,	$
;tst[k].unc,	$
;tst[k].flag,	$
;tst[k].diff,$
;tst[k].match,$
;tst[k].tank,$
;tst[k].fill,$  ; could extract tank instrument and put it here
;tst[k].ref,$
;tst[k].runnum,$
;tst[k].molfval,$
;tst[k].molfflag 
FREE_LUN,u

stop
; for ch4c13
IF sp EQ 'ch4c13' THEN BEGIN
	
	keep=where(ABS(tst.diff LT 10))
	
	tst=tst[keep]

;	keepmo=MOMENT(tst.diff,sdev=sdev)
	
	;assume mean of zero...
;	these=WHERE(tst.diff GT keepmo[0]-(2*sdev))
;	tst=tst[these]
;	andthese=WHERE(tst.diff GT keepmo[0]-(2*sdev))
;	tst=tst[andthese]

; not sure what the intention was here ...
;	olddata=WHERE(tst.date LT 2008.2)
;	oldmo=MOMENT(tstolddiff,sdev=sdev)
;	print,'oldstdev= ',sdev
;	middata=WHERE(tst.date GT 2008.2 AND tst.date LT 2016)
;	middiff=diff[middata]
;	midmo=MOMENT(middiff,sdev=sdev)
;	print,'midstdev= ',sdev;

;	newdata=WHERE(tst.date GE 2016)
;	newdiff=diff[newdata]
;	newmo=MOMENT(newdiff,sdev=sdev)
;	print,'newstdev= ',sdev

	; get a year by year printout of offsets, mean diff
;	nyrs=yr2-yr1+1
;	yrarr=INDGEN(nyrs)+yr1
;	yrstats=FLTARR(3,nyrs)
;	FOR y=0,nyrs-1 DO BEGIN
;		thisyr=WHERE(FIX(tst.adate) EQ yrarr[y],nthis)
;		IF thisyr[0] NE -1 THeN BEGIN
;			thismo=MOMENT(diff[thisyr],sdev=sdev)
;			yrstats[0,y]=thismo[0]
;			yrstats[1,y]=sdev
;			yrstats[2,y]=nthis
;		ENDIF ELSE BEGIN
;			yrstats[*,y]=-9
;		ENDELSE
;	ENDFOR
;	
;	siteformat='(I5,2(F11.4),I4)'
;	header='mean(diff) stdev(diff) n
;	OPENW, u,newfile, /GET_LUN
;	PRINTF,u,header
;	FOR k=0,nyrs-1 DO PRINTF,u,format=siteformat,  yrarr[k],yrstats[*,k]

;	FREE_LUN,u

ENDIF



; look at pfps: 
;find uniq fills
;for each, make plot
;look for drift
;find standard deviation
;find difference from tank fill (mean diff or diff of mean)

IF strategy EQ 'pfp' THEN BEGIN
	
	;scroll through dates, whenever you get to a gap that is bigger than 2 days, you have a new fill
	m=0
	knob=0.01D
	tst[0].filldate=m
	FOR t=1,ntst-1 DO BEGIN
		IF tst[t].date-tst[t-1].date GT knob THEN BEGIN
			m=m+1
			
		ENDIF 
		tst[t].filldate=m
	ENDFOR
		
	uniqfills=UNIQ(tst.filldate)
	nuniq=N_ELEMENTS(uniqfills)
	
	pfparr=REPLICATE({date:0.0,$
			yr:0,$
			mo:0,$
			dy:0,$
			filldate:0,$
			firstevn:'',$
			n:0,$
			mean:0.0,$
			stdev:0.0,$
			avgdiff:0.0,$
			slope:0.0,$
			ref:'',$
			chisq:0.0},nuniq)
	
	FOR n=0,nuniq-1 DO BEGIN
		pfparr[n].date=tst[uniqfills[n]].date
		pfparr[n].filldate=tst[uniqfills[n]].filldate
		 pfparr[n].firstevn=tst[uniqfills[n]].evn
		pfparr[n].yr=tst[uniqfills[n]].yr
		pfparr[n].mo=tst[uniqfills[n]].mo
		pfparr[n].dy=tst[uniqfills[n]].dy
		these=WHERE(tst.date GT pfparr[n].date-knob AND tst.date LT pfparr[n].date+knob,nthis)
		pfparr[n].date=tst[these[0]].date
		pfparr[n].filldate=tst[these[0]].filldate
		thispfp=tst[these]
		mothis=MOMENT(thispfp.value,sdev=sdev)
		pfparr[n].mean=mothis[0]
		pfparr[n].stdev=sdev
		pfparr[n].n=nthis
		plotpfp=1
		IF plotpfp EQ 1 THEN BEGIN
			;could plot by fill
			; or each individual
			; or all on one plot with ncyl number of panels
			flaskno=intarr(nthis)
			FOR f=0,nthis-1 DO BEGIN
				flaskno[f]=FIX(STRMID(thispfp[f].id,5,2))
			ENDFOR
			thispfpplot=PLOT(flaskno,thispfp.value,xrange=[0,13],linestyle=6,symbol='circle',sym_filled=1,color='blue')
			;put a label on the plot with filldate, eventnumbers
			strname=STRCOMPRESS(STRING(pfparr[n].mo),/REMOVE_ALL)+'/'+STRCOMPRESS(STRING(pfparr[n].dy),/REMOVE_ALL)+$
				'/'+STRCOMPRESS(STRING(pfparr[n].yr),/REMOVE_ALL)
			dateprint=TEXT(0.1,0.9,strname,font_size=15)
			evnprint=TEXT(0.1,0.86,pfparr[n].firstevn,font_size=15)
		ENDIF	
		;now get chisq values
		
		

		
	ENDFOR
	

	pfpplot=ERRORPLOT(pfparr.date,pfparr.avgdiff,pfparr.stdev,color='red',sym_size=1.2,sym_filled=1,$
	xrange=[fix(min(pfparr.date)),fix(max(pfparr.date)+1)],linestyle=6)
	
	

	
ENDIF





IF savegraphs EQ 1 THEN BEGIN
	savename='/home/ccg/sil/plots/tstflsk.'+sp
	IF jras EQ 1 THEN savename=savename+'.jras' else savename=savename+'.instaar'
	IF sitefiles EQ 1 THEN BEGIN
		IF sp EQ 'co3c13' THEN BEGIN
			IF jras EQ 1 THEN savename=savename+'.jras' else savename=savename+'.instaar'
		ENDIF ELSE BEGIN
			IF jras EQ 1 THEN savename=savename+'.lintest' else savename=savename+'.instaar'
		ENDELSE
	ENDIF
	IF plotbytank EQ 1 THEN savename=savename+'.bytank'
	IF plotbyinst EQ 1 THEN savename=savename+'.byinst'
	savename=savename+'.png'
	print,savename
	tstplot.save,savename
	tstplot.close
ENDIF ELSE BEGIN

ENDELSE
END
