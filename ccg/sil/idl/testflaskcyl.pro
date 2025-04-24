PRO testflaskcyl,sp=sp,tank=tank,mostrecent=mostrecent,savegraphs=savegraphs,plottanks=plottanks  ;,jras=jras


;purpose. TO get testflask cylinders, get numbers for each fill (make sure that
; the fill date is correct)
;if you specify tank, this code assumes that you want the most recent fill of this tank. 
; nals= number of all AL tankfills
; notes, fall '24: this code is confusing in the beginning - it is trying to find the names of the testflask cylinders. 
; Unfortunately the names are also changing in Oct '24, so there are silly bugs related to that.
; around line 112 is where the code matches data to tanks in a useful way. 

;key
;als=altanks=names of common testflasktanks of recent years.
;alcyls=these tanks from reference_external, with fill dates of these tanks
;alcyllist=same, but sorted 

IF sp EQ 'ch4c13' THEN style='oldstyle' ELSE style='newstyle'
;newstyle=AL47-104 naming conventions.

IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF NOT KEYWORD_SET(sp) THEN sp='co2c13'
IF NOT KEYWORD_SET(jras) THEN jras=0
IF NOT KEYWORD_SET(mostrecent) then mostrecent=0
IF NOT KEYWORD_SET(tank) then tank='all'
IF NOT KEYWORD_SET(mostrecent) then mostrecent=0


IF NOT KEYWORD_SET(plottanks) THEN plottanks=1

IF sp EQ 'ch4c13' THEN calsdir='cals' ELSE calsdir='calsfinal'  ;calsieg3'
Print, '-----------------------
print,'calsdir = ' ,calsdir


IF sp EQ 'ch4c13' THEN spec='ch4c13' ELSE spec='co2c13'
extcyldir='/projects/'+spec+'/'+calsdir+'/external_cyl/'
CCG_DIRLIST,dir=extcyldir,/omitdir,altanks

;IF tank EQ 'all' THEN als=WHERE(STRMID(altanks,0,4) EQ 'AL47',ntanks) ELSE als=WHERE(STRMID(altanks,0,7) EQ tank,ntanks)
;altanks=altanks[als]

IF style EQ 'oldstyle' THEN tankfileII = '/projects/co2c13/flask/sb/reference_external.co2c13.091224'  ELSE $
tankfileII = '/projects/co2c13/flask/sb/reference_external.co2c13'   ; even for ch4c13. This will be the  most complete list 
temptankfileII = '/home/ccg/sil/tempfiles/tanktempII.txt'
CCG_SREAD, file = tankfileII, skip = 2, stdarr, /nomessages
m = WHERE(STRMID(stdarr,0,1) NE '#')
saved = stdarr[m]
CCG_SWRITE, file = temptankfileII, saved, /nomessages
CCG_READ, file=temptankfileII, extcyls, /nomessages
next=N_ELEMENTS(extcyls)

;IF tank EQ 'all' THEN alcyls=WHERE(STRMID(extcyls.field1,0,5) EQ 'AL47-',nals) ELSE $
;alcyls=WHERE(STRMID(extcyls.field1,0,7) EQ STRMID('tank',0,7),nals)
;alcyls=WHERE(extcyls.field1 EQ tank,nals)
;alcyllist=extcyls[alcyls]


; need to find a new way to find test flask cylinders, since they are not all AL- tanks anymore
;maybe read from tabfile?

keepthem=INTARR(next)
IF style EQ 'oldstyle' THEN als=['AL47104','AL47108','AL47113','AL47145','ND39909'] ELSE $
als=['CC71657','CC71652','AL47-104','AL47-108','AL47-113','AL47-145','ND39909']

for k=0,next-1 DO BEGIN
	here=WHERE(als EQ extcyls[k].field1)
	IF here[0] NE -1 THEN keepthem[k]=1
	
ENDFOR
ntanks=N_elements(als)
slimdown=WHERE(keepthem EQ 1,nals)
alcyls=extcyls[slimdown]


;; alcyls has all ofthe info of reference_external
;;als= just the names of the test flask cylinders
;IF tank EQ 'all' THEN alcyls=WHERE(STRMID(extcyls.field1,0,5) EQ 'AL47-',nals) ELSE $


sortals=SORT(alcyls.field1)
alcyllist=alcyls[sortals]
altanks=als


IF tank NE 'all' THEN BEGIN
	justthistank=WHERE(alcyllist.field1 EQ tank,nthisone)
	alcyllist=alcyllist[justthistank[nthisone-1]]

	nals=1
ENDIF

;; now have list of all fill dates for each cyl. Even if they are wrong in the data file, we will get them right here. 

alfilldate=FLTARR(nals)
CCG_DATE2DEC,yr=alcyllist.field2,mo=alcyllist.field3,dy=alcyllist.field4,dec=dec
alfilldate=dec

IF sp EQ 'co2c13' THEN sparr=['co2c13','co2o18']
IF sp EQ 'ch4c13' THEN sparr=['ch4c13']
;nsp=N_ELEMENTS(sparr)
;FOR s=0,nsp-1 DO BEGIN
g=0
h=0
;sp=sparr[s]

means=FLTARR(nals)
cyllist=STRARR(nals)  ; just used for sorting out bugs
sdevs=FLTARR(nals)
inst=STRARR(nals)
ref=STRARR(nals)
printthese=INTARR(nals)
FOR a=0,nals-1 DO inst[a]='na'

;;;knobs for sd of run
IF sp EQ 'co2c13' THEN csdknob=0.03 
IF sp EQ 'co2o18' THEN csdknob=0.05
IF sp EQ 'ch4c13' THEN csdknob=0.1
j=0


FOR i=0,ntanks-1 DO BEGIN
	

	; go through data, get out flags
	; get uniq runs
	; if stdev of run is good, add to tank data for each fill of each tank
	; plot?
	print,'i = ',i 
	PRINT,altanks[i]
	
	;; this is temporary
	IF STRMID(altanks[i],0,1) EQ 'A' THEN BEGIN
		
		newname=STRMID(altanks[i],0,4)+STRMID(altanks[i],5,10)
	ENDIF ELSE BEGIN
		newname=altanks[i]
	ENDELSE	

	IF sp EQ 'ch4c13' THEN thefile=extcyldir+altanks[i]+'.ch4c13' ELSE thefile=extcyldir+altanks[i]+'.co2c13'
	isithere=FILE_TEST(thefile)
	IF isithere EQ 0 THEN stop  ;goto,skipthistank
		CCG_READ,file=thefile,data
	; get all of the data
		
	IF sp EQ 'co2c13' THEN goodcdat=WHERE(STRMID(data.field15,0,1) EQ '.',nc)
	IF sp EQ 'co2o18' THEN goodcdat=WHERE(STRMID(data.field18,0,1) EQ '.',nc)		
	IF sp EQ 'ch4c13' THEN goodcdat=WHERE(STRMID(data.field15,0,1) EQ '.',nc)
	
	cdata=data[goodcdat]
	

	ckeepthis=INTARR(nc)
	csdarr=FLTARR(nc)
	;this bit weeds out runs with high variability
	
	FOR c=0,nc-1 DO BEGIN
		IF sp EQ 'ch4c13' THEN BEGIN
			cthisrun=WHERE(cdata[c].field6 EQ cdata.field6 AND cdata[c].field17 EQ cdata.field17 AND cdata[c].field16 EQ cdata.field16,nthis)
					; run number, instrument, ref
			cthisrundata=cdata[cthisrun]
			mo=MOMENT(cthisrundata.field13,sdev=sd)
		ENDIF ELSE BEGIN
		
			cthisrun=WHERE(cdata[c].field6 EQ cdata.field6 AND cdata[c].field20 EQ cdata.field20 AND cdata[c].field19 EQ cdata.field19,nthis)
					; run number, instrument, ref
			cthisrundata=cdata[cthisrun]
			IF sp EQ 'co2c13' THEN mo=MOMENT(cthisrundata.field13,sdev=sd) ELSE mo=MOMENT(cthisrundata.field16,sdev=sd)
		ENDELSE
		
		
		csdarr[c]=sd
		IF csdarr[c] LT csdknob THEN BEGIN
			ckeepthis[c]=1 
		ENDIF ELSE BEGIN
			ckeepthis[c]=0
		ENDELSE	

	ENDFOR

	ckeepdata=WHERE(ckeepthis EQ 1,nckeep,COMPLEMENT=baddata)
		kcdata=cdata[ckeepdata]

	

	;newname=STRMID(altanks[i],0,4)+'-'+STRMID(altanks[i],4,3)
	;numfills=WHERE(newname EQ alcyllist.field1,nfills)
	;numfills=WHERE(STRMID(altanks[i],0,7) EQ alcyllist.field1,nfills)
	 numfills=WHERE(altanks[i] EQ alcyllist.field1,nfills)

	thisalfilldate=alfilldate[numfills]
	sortthese=SORT(thisalfilldate)
	thisalfilldate=thisalfilldate[sortthese]

	ccylarr=FLTARR(nfills,nckeep)
	cinstarr=STRARR(nfills,nckeep)
	crefarr=STRARR(nfills,nckeep)
	cinstarr(*,*)='na'
	crefarr(*,*)='na'
	cadate=FLTARR(nckeep)
	
	FOR c=0,nckeep-1 DO BEGIN
	
		; compare adate to filldate; if it's after filldate, give a fillcode?
			CCG_DATE2DEC,yr=kcdata[c].field7,mo=kcdata[c].field8,dy=kcdata[c].field9,dec=dec
			cadate[c]=dec
		
		FOR f=0,nfills-1 DO BEGIN
			
			IF cadate[c] GT thisalfilldate[nfills-f-1] THEN BEGIN
				;
				IF sp EQ 'ch4c13' THEN ccylarr[nfills-f-1,c]=kcdata[c].field13
			
				IF sp EQ 'co2c13' THEN ccylarr[nfills-f-1,c]=kcdata[c].field13 
				IF sp EQ 'co2o18' THEN ccylarr[nfills-f-1,c]=kcdata[c].field16
				IF sp EQ 'ch4c13' THEN cinstarr[nfills-f-1,c]=kcdata[c].field17 ELSE cinstarr[nfills-f-1,c]=kcdata[c].field20
				;don't really need fill info for ch4c13 at this point, so putting a filler in. Can find data later. 
				IF sp EQ 'ch4c13' THEN crefarr[nfills-f-1,c]='ref' ELSE crefarr[nfills-f-1,c]=kcdata[c].field19
				GOTO, getout
			ENDIF ; analysis date is less than fill. move on.
			
		ENDFOR
	
		getout:	

	ENDFOR



	;IF altanks[i] EQ 'AL47113.ch4c13' THEN STOP
	 params={font_name: 'Helvetica',$
	 thick:3, $
	 symbol:'circle',$
	 sym_filled:1,$
	 linestyle:6,$
	 font_size:15,$
	 ytickdir: 1}  ;points ticks out
		
	fillarr=['aa','bb','cc','dd','ee','ff','gg','hh','ii'] ; I don't know if these will correspond to NOAA fills. 
	FOR f=0,nfills-1 DO BEGIN
	print,'fill = ',STRING(f)
		
		
		IF mostrecent EQ 1 THEN BEGIN
		; start at last date and go until you have a 6 month break.
		justrecent=INTARR(nckeep)
		justrecent[nckeep-1]=1
		FOR x=0,nckeep-1 DO BEGIN
			startdate=cadate[nckeep-1-x]
			prevdate=cadate[nckeep-1-x-1]
			IF startdate-prevdate LT 0.5 THEN BEGIN
				justrecent[nckeep-1-x-1]=1
			ENDIF ELSE BEGIN
				x=x+nckeep
			ENDELSE
		ENDFOR
		justthese=WHERE(justrecent EQ 1)
		cadate=cadate[justthese]
		
		ccylarr=ccylarr[*,justthese]

		ENDIF

		real=WHERE(ccylarr[f,*] NE 0,nreal)
	
		
		
		IF real[0] NE -1 THEN BEGIN
		realinst=WHERE(cinstarr[f,*] NE 'na',nreal)
		mo=MOMENT(ccylarr[f,real],sdev=sd)
		IF sd GT 0.5 THEN STOP
		uplimit=mo[0]+(2*sd)
		downlimit=mo[0]-(2*sd)
		yesdata=WHERE((ccylarr[f,*] GT downlimit AND ccylarr[f,*] LT uplimit),nyes,complement=sucks)
		
		IF yesdata[0] NE -1 THEN BEGIN
			yesmo=MOMENT(ccylarr[f,yesdata],sdev=sdev)
			means[g]=yesmo[0]
			IF sdev GT 0 THEN sdevs[g]=sdev ELSE sdevs[g]=-99
				IF plottanks EQ 1 THEN BEGIN
					
					plotit=PLOT(cadate[real],ccylarr[f,real],_extra=params,color='gray')
					plotit=PLOT(cadate[yesdata],ccylarr[f,yesdata],_extra=params,color='blue',/overplot)
					plotit.axis_style=0
					;;optional plotting of date and value
					
					plotit['axis3'].transparency=100
					plotit['axis2'].transparency=100
					textit=TEXT(0.6,0.88,'mean = '+STRMID(STRCOMPRESS(STRING(means[g]),/REMOVE_ALL),0,5),font_size=15)
			
					textitSD=TEXT(0.6,0.84,'sd = '+STRMID(STRCOMPRESS(STRING(sdevs[g]),/REMOVE_ALL),0,5),font_size=15)
						IF tank EQ 'all' THEN titletext=TEXT(0.2,0.93,alcyllist[g].field1+'-'+alcyllist[g].field5,font_size=16)
					titletext=TEXT(0.5,0.93,altanks[i]+ ' fill '+string(f),font_size=16)
					
					IF savegraphs EQ 1 THEN BEGIN
						savename='/home/ccg/sil/testflasks/plots/'+alcyllist[g].field1+'_'+alcyllist[g].field5+'.'+sp+'.png'
						plotit.save,savename
						plotit.close
					ENDIF ELSE BEGIN
					 	keepgoing=DIALOG_MESSAGE('ok?', title = 'Continue',/Question, /cancel)
						plotit.close
						IF keepgoing EQ 'No' THEN goto,bailout 
						IF keepgoing EQ 'Yes' THEN goto,whocares
						whocares:
						bailout:
					ENDELSE
				ENDIF
			

			theinsts=''
			therefs=''
			instlist=cinstarr[f,realinst]
			sortinst=SORT(instlist)
			
			finduniq=UNIQ(instlist[sortinst])
			ntheinsts=N_ELEMENTS(finduniq)
			FOR n=0,ntheinsts-1 DO theinsts=theinsts+'_'+instlist[sortinst[finduniq[n]]]
			
			reflist=crefarr[f,realinst]
			sortref=SORT(reflist)
			finduniq=UNIQ(reflist[sortref])
			ntherefs=N_ELEMENTS(finduniq)
			FOR n=0,ntherefs-1 DO therefs=therefs+'_'+reflist[sortref[finduniq[n]]]
			
			inst[g]=theinsts   ;cinstarr[f,realinst[nreal-1]]
			ref[g]=therefs     ;crefarr[f,realinst[nreal-1]]
			
			cyllist[g]=altanks[i] +'_'+STRCOMPRESS(STRING(f),/REMOVE_ALL)
			printthese[h]=1
			print,altanks[i]
			
			print,'fill ',STRING(f)
			print,'g = ',g
			print,'mean = ',means[g]
			print,'stdev = ',sdevs[g]
				
				g=g+1
		ENDIF ELSE BEGIN 
			print,'no data'
		ENDELSE
		
	; make array with mean, stdev		
	;f is number of fills
	;i is tanks

	

	;get uniq runs
	;;c data
	ENDIF
	h=h+1
	
	ENDFOR
skipthistank:
ENDFOR

PRINT, 'alldone'


IF tank EQ 'all' THEN BEGIN
IF jras EQ 1 THEN testfile='/home/ccg/sil/testflasks/testflaskcyl.jr.'+sp+'.txt' $
ELSE testfile='/home/ccg/sil/testflasks/testflaskcyl.'+sp+'.txt'
testformat='(A10,1x,I5,1x,I3, I4, A3, F8.3,1x,F8.3,A12,A50)'
header = 'cyl fillyr fillmo filldy fillcode mean sd inst'
OPENW, u,testfile, /GET_LUN
PRINTF,u,header
printthem=WHERE(printthese EQ 1,nprint)
FOR k=0,nprint-1 DO PRINTF,u,format=testformat,  $

alcyllist[printthem[k]].field1,	$
alcyllist[printthem[k]].field2,	$
alcyllist[printthem[k]].field3,	$
alcyllist[printthem[k]].field4,	$
alcyllist[printthem[k]].field5,	$
means[k],	$
sdevs[k],	$
inst[k], $
ref[k]

FREE_LUN,u
;stop
ENDIF
;ENDFOR ;;sp loop

END
