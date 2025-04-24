PRO plot_sitedata_qaqc_ch4c13,project=project,strategy=strategy,softflags=softflags,site=site,$
savegraphs=savegraphs,data=data


;written 4/14/11 sem
; this plots data along with flags.
; archived versions have old vs new plotting options. Updated 5/2020 to only include new versions
; all sorts of new capabilities added in 2021. Linearity corrections, comparisons, peak hegihts ...

; ----general stuff
IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF NOT KEYWORD_SET(softflags) THEN softflags=0
IF NOT KEYWORD_SET(strategy) THEN strategy='flask'
;IF NOT KEYWORD_SET(project) THEN project='ccg_surface'
IF NOT KEYWORD_SET(softflags) THEN softflags=0
IF NOT KEYWORD_SET(site) THEN site='all'
IF NOT KEYWORD_SET(data) THEN data='db' ELSE data='sitefile'
	; if using sitefile, declare this on   line 75 (no longer correct line number ...)

data='db'
;data='sitefile'
;sitekey='trapadj'   ; to differentiate plots of tests made from sitefiles
;sitekey='finallincorr'
;sitekey='nopflags/nopflags'
sitekey='nov22'
fullname=1       ;  site nickname, or real name? 
ourdev='png'
IF savegraphs EQ 1 THEN onebyone=0 ELSE onebyone=1
spec=['ch4c13']
s=0
newsitefiles=1  ;reads cleaned up dei files

; ----- time frame
long=0 ; in case you want a longer record. This matters because you don't want to have to 'getdata' if for different time ranges
IF long EQ 1 THEN yr1=1998 ELSE yr1=2016
yr2=2024
date=[yr1,yr2]

; ----site plots
plotbyadate=0
skipsiteplots=1 ; if you want to go right to plotting peak heights
noflags=1     ; if you want to plot just the good data
addsc=1        ; if you want to add smooth curve to data 
addtr=1         ; or trend to data
addunc=0

; ----peak height plots
makepeaksizeplots=1
getdata=0  ; if you need to get data for peak heights. Set to one the first time, then it'll be faster after that.
		; but remember the date range - have to run it for 'long' or 'not long' and if you want new data, will need to getdata=1
peakhtplots= 1   ; if you want to plot data by peak hts
peakhtdiffs=1     ; instead of getting just the peak height, get the difference between the peak height and the working ref peak avg.  


;_____drift plots
makedriftplots=0
getdriftdata=0

; ----comparisons
addcomparison=0 ; so that I could read in MPI data and plot with ours
addsccomp=1 	 ; add smooth curve to comparison. Only available at ZEP currently
rhul=1
rhulcolor='red'
mpi=1
mpicolor='red'
niwa=1
niwacolor='navy'
tu=1
tucolor='lime'
instaarcolor='blue'

; ----o18data
geto18data=0
ploto18data=0

;; linearity features
	plotlindata=0  ; if you want to add linearity-corrected data
	;IF newsitefiles EQ 0 THEN lindir='/home/ccg/sil/ch4c13/' ELSE lindir='/home/ccg/michel/ch4c13/linrealflagsadded_deifiles/linrealflagsadded_newsitefiles/'
	IF newsitefiles EQ 0 THEN lindir='/home/ccg/sil/ch4c13/' ELSE lindir='/home/ccg/michel/ch4c13/finallin_deifiles/finallin_newsitefiles/'
	;IF newsitefiles EQ 0 THEN lindir='/home/ccg/sil/ch4c13/' ELSE lindir='/home/ccg/michel/ch4c13/nopflagslin_deifiles/nopflagslin_newsitefiles/'
	plotalllins=0
	plotlindiffs=0
	;whichlin='linadjfiles/'   ; for actual 'LIN' data
	;whichlin='linadjustfiles/'   ; for -0.025 permil/nA above 2.5 nA diff correction data
	;whichlin='linadjust04files/'   ; for -0.04 permil/nA above 2.5 nA diff correction data 
	;whichlin='linadjust047files/'   ; for -0.047 permil/nA above 2.5 nA diff correction data 
	;whichlin='linadjustmc03files/'   ; for -0.03 permil monte carlo method
	;whichlin='linadjustmc019files/'   ; for-0.019 permil monte carlo method
	;whichlin='testfiles/'   ; for-0.019 permil monte carlo method
	;whichlin='newlinadjmcreal/'
	;whichlin='zflags/'
	whichlin='finallincorr/finallincorr/'
	;whichlin='nopflags/nopflags/'
	IF plotlindata EQ 1 THEN BEGIN
	IF plotalllins EQ 0 THEN BEGIN
		IF whichlin EQ 'linadjfiles/' THEN linname ='measured within run'
		IF whichlin EQ 'linadjustfiles/' THEN linname ='-0.025 $\permil$/nA'	
		IF whichlin EQ 'linadjust04files/' THEN linname ='-0.04 $\permil$/nA'
		IF whichlin EQ 'linadjust047files/' THEN linname ='-0.047 $\permil$/nA'
		IF whichlin EQ 'linadjustmc03files/' THEN linname ='mc method: -0.03 $\permil$/nA'
		IF whichlin EQ 'linadjustmc019files/' THEN linname ='mc method: -0.019 $\permil$/nA'
		IF whichlin EQ 'testfiles/' THEN linname ='mc method: -0.019 $\permil$/nA'
		IF whichlin EQ 'newlinadjmcreal/' THEN linname ='mc method, real data'
		IF whichlin EQ 'zflags/' THEN linname ='peakheightdiffs flagged'
		IF whichlin EQ 'finallincorr/finallincorr/' THEN linname ='corrected'
		IF whichlin EQ 'nopflags/nopflags/' THEN linname ='nopflags'

	ENDIF ELSE BEGIN
		;IF plotalllins EQ 1 THEN whichlin=['linadjfiles/','linadjustfiles/','linadjust03files/','linadjust047files/']	
		;namearr=['LIN samples only','-0.025 $\permil$/nA','-0.03 $\permil$/nA','-0.047 $\permil$/nA']	
		IF plotalllins EQ 1 THEN whichlin=['linadjustfiles/','linadjust047files/']	
		;namearr=['-0.025 $\permil$/nA','-0.047 $\permil$/nA']	
		IF plotalllins EQ 1 THEN whichlin=['testfiles/','newlinadjmcreal/','addsomeflags_lin/'] ;'zflags/'] 
		namearr=['mc -0.19', 'mcreal','mcreal_flagged'] ;'zflagged']
	ENDELSE
	ENDIF
;; ok, ready to go

initfile ='/home/ccg/michel/initfiles/init.ch4c13.'+strategy+'.2021'
;initfile ='/home/ccg/michel/initfiles/init.ch4c13.'+strategy+'.2022'

CCG_READINIT,file=initfile,initparams
nsites=N_ELEMENTS(initparams.desc)
sites=initparams.desc.site_code


IF site NE 'all' THEN BEGIN
	thissite=WHERE(sites EQ STRUPCASE(site))
		sites=sites[thissite]
		nsites=1
		onebyone=0
		sitenames=(initparams.desc(thissite).site_name)
		init=initparams.init
ENDIF ELSE BEGIN
		
		nsites=N_ELEMENTS(sites)
		IF savegraphs EQ 0 THEN onebyone=1
		sitenames=(initparams.desc.site_name)
		init=initparams.init
ENDELSE


;;;;;	
	;
	
FOR i=0,nsites-1 DO BEGIN

	IF sites[i] EQ 'BAL' THEN goto, skipthisone
	IF sites[i] EQ 'LLB' THEN goto, skipthisone
	IF sites[i] EQ 'WPC' THEN goto, skipthisone

	backone:
		print, 'Processing Number: ',i
		print, 'Plotting ', sites[i]
		bigsite = initparams.desc(i).site_code + '  ' + spec[s]
		site=sites[i]
		thissitename=sitenames[i]
		IF spec[s] EQ 'c13' THEN axis=[-10,-6,0.5,1] ELSE axis=[-5,3,.5,1]
	
		IF data EQ 'db' THEN filename='/home/ccg/silplots/siteplots/'+site+'.ch4c13'
		IF data EQ 'sitefile' THEN filename='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.sitefiles.'+sitekey
		IF softflags EQ 1 THEN filename=filename+'.softflags'
		IF softflags EQ 0 AND noflags EQ 0 THEN filename=filename+'.allflags'
		filename=filename+'.'+ourdev

	

	
	IF data EQ 'db' THEN BEGIN
		CCG_FLASK,site=site,date=date,sp='ch4c13', $
			;project=project,$
			strategy=strategy,cdata
			
			keepouttanks=WHERE(cdata.meth NE 'H')
			cdata=cdata[keepouttanks]
			nlines=N_ELEMENTS(cdata)
		
		
	ENDIF ELSE BEGIN
		;sitefiledir='/home/ccg/sil/ch4c13/072620test/'
		;sitefiledir='/home/ccg/sil/ch4c13/trapadjustfiles/'
		;sitefiledir='/home/ccg/sil/ch4c13/'+sitekey+'/'
		;sitefiledir='/home/ccg/michel/ch4c13/nopflagslin_deifiles/nopflagslin_newsitefiles/'   ; this isn't working ....
		;sitefiledir='/home/ccg/sil/ch4c13/mrasfiles/'
		sitefiledir='/home/ccg/michel/ch4c13/nov22_deifiles/nov22_newsitefiles/'
		
		isitdei=STRPOS(sitefiledir,'dei')
		IF isitdei[0] NE -1 THEN itisdei=1 ELSE itisdei=0

		CCG_SREAD, file=sitefiledir+STRLOWCASE(site)+'.ch4c13',skip=0,x
		
	
		CCG_READ, file=sitefiledir+STRLOWCASE(site)+'.ch4c13',skip=0,sitedat
			nlines=n_elements(sitedat)
	
		cdata=REPLICATE({code:'',$
			evn:'',$
			date:0.0,$
			adate:0.0,$
			value:0.0,$
			flag:'',$
			unc:0.0},nlines)

			cdata.code=sitedat.field1
			cdata.value=sitedat.field9
			cdata.evn= sitedat.field18
			IF itisdei EQ 0 THEN cdata.flag=sitedat.field10 ELSE cdata.flag=sitedat.field11
			
			cdata.unc=sitedat.field17
			FOR z=0,nlines-1 DO BEGIN
				CCG_DATE2DEC,yr=sitedat[z].field2,mo=sitedat[z].field3,dy=sitedat[z].field4,hr=sitedat[z].field5,mn=sitedat[z].field6,dec=dec
				cdata[z].date=dec
				IF itisdei EQ 0 THEN BEGIN
					CCG_DATE2DEC,yr=sitedat[z].field12,mo=sitedat[z].field13,dy=sitedat[z].field14,hr=sitedat[z].field15,mn=sitedat[z].field16,dec=dec
					cdata[z].adate=dec
				ENDIF ELSE BEGIN
					CCG_DATE2DEC,yr=sitedat[z].field13,mo=sitedat[z].field14,dy=sitedat[z].field15,hr=sitedat[z].field16,mn=sitedat[z].field17,dec=dec
					cdata[z].adate=dec
				ENDELSE
			ENDFOR
			keep=WHERE(cdata.date GT yr1)
			cdata=cdata[keep]
			;before evn numbers were available in sitefiles I had to find them ..
			;IF getdata EQ 1 THEN BEGIN
			;	FOR z=0,nlines-1 DO BEGIN
			;	;CCG_FLASK, site=cdata[z].code,id=sitedat[z].field8,date=cdata[z].date,findevn
			;	cdata[z].evn= STRTRIM(findevn[0].evn,2)
			;
			;ENDFOR
			;ENDIF
	ENDELSE

IF n_elements(cdata) EQ 1 THEN GOTO, skipthisone
xflag=WHERE(STRMID(cdata.flag,0,2) EQ 'X',complement=noxflags)
;keep=WHERE(STRMID(cdata.flag,0,1) NE '!')
;cdata=cdata[keep]
cvalue=cdata.value

IF plotbyadate EQ 1 THEN BEGIN
	cdate=cdata.adate 
ENDIF ELSE BEGIN
	 cdate=cdata.date
ENDELSE

cunc=cdata.unc
nc=N_ELEMENTS(cdata)
dotflag=WHERE(STRMID(cdata.flag,0,2) EQ '..',complement=flaggeddata)
aflag=WHERE(STRMID(cdata.flag,0,1) EQ 'A')
pflag=WHERE(STRMID(cdata.flag,0,1) EQ 'P')
plusflag=WHERE(STRMID(cdata.flag,0,1) EQ '+')
minusflag=WHERE(STRMID(cdata.flag,0,1) EQ '-')
lflag=WHERE(STRMID(cdata.flag,0,1) EQ 'L')

hflag=WHERE(STRMID(cdata.flag,0,1) EQ 'H')
tflag=WHERE(STRMID(cdata.flag,2,1) EQ 'T')
dflag=WHERE(STRMID(cdata.flag,0,1) EQ 'D')   ;dne
exflag=WHERE(STRMID(cdata.flag,0,1) EQ '!')
xflag=WHERE(STRMID(cdata.flag,1,1) NE '.')

mflag=WHERE(STRMID(cdata.flag,0,1) EQ 'M')   ; this is a new flag 4/21. If linearity is high and diff from std peak is higher than 2.5
rflag=WHERE(STRMID(cdata.flag,2,1) EQ 'R')

sortvalues=SORT(cvalue)
sortedvalues=cvalue[sortvalues]
cmedval=MEDIAN(sortedvalues)
chighval=sortedvalues[nc-10] ; get 10th highest and lowest value
clowval=sortedvalues[9]

mingood=MIN(cvalue[dotflag])
maxgood=MAX(cvalue[dotflag])

IF softflags EQ 0 THEN BEGIN
	cymin=-48.5
	cymax=-47
	;cymin=-60
	;cymax=-25
	
	;cymin=-48
	;cymax=-46.5

	;cymin=mingood-0.5
	;cymax=maxgood+0.5
	cymin=mingood-0.2
	cymax=maxgood+0.2
ENDIF ELSE BEGIN
	cymin=-51
	cymax=-45
	cymin=-48
	cymax=46
	cymin=mingood-0.5
	cymax=maxgood+0.5

ENDELSE

	carr=['red','green','purple','orange','magenta','blue','turquoise','lime green','slate gray','brown','cyan','pink','brick red']


	tarr=['.','A','P','+','-','L','H','T','D','!','M','R']
	thistarr=['good','bad refs','small peaks','flask pair +','flask pair -','trap -','trap +','noisy trap','drift','handflagged','2pos flag','linearity flag','3pos linearity flag']
	;plot title
		xmin=FIX(MIN(cdate))

	
	params={linestyle:6, $
	 font_name: 'Helvetica',$
	YRANGE:[cymin,cymax],$
	 thick:3, $
	 xrange:[FIX(cdate[0]),yr2],$
	 xtitle:'date',$
	font_size:24,$
	 ytickdir: 1}  ;points ticks out
	
	IF skipsiteplots EQ 1 THEN goto, skipplots	
	  thisplot=WINDOW(location=[100,100],dimensions=[1400,600])
	
	thisplota=PLOT(cdate,cvalue,$
		/current,$
		POSITION=[0.14,0.14,0.86,0.9],$   ;[0.14,0.15,0.94,0.85],$   
		_extra=params,$
		color='white',$
		sym_size= 0.4,$
		YTITLE='$\delta$$^{13}$C (CH$_4$) ($\permil$)')
	
	;thistext=TEXT(0.12,0.95,'$\delta$$^{13}$CH$_4$ of flasks from ' + strupcase(site),$
	;	font_size=20)
	IF fullname EQ 1 THEN thistext=TEXT(0.12,0.94,STRUPCASE(site) + ': '+thissitename,font_size=24) ELSE $
		thistext=TEXT(0.12,0.95,strupcase(site),font_size=30)
	IF plotlindata EQ 1 THEN here=TEXT(0.72,(0.8+(0.04)), 'original',color='grey',/current,font_size=16,/normal)	
	
	IF plotlindata EQ 1 THEN thiscolor='grey' else thiscolor=carr[0]	
	IF plotlindata EQ 1 THEN thissymfill=1 ELSE thissymfill=1
	IF addcomparison then thiscolor=instaarcolor
		
	gooddat=PLOT(cdate[dotflag],cvalue[dotflag],$
		symbol='circle',sym_size=0.4,_extra=params,sym_filled=thissymfill,$
		COLOR=thiscolor,/overplot)

	IF addunc EQ 1 THEN BEGIN
		thisunc=cdata.unc
		fixthese=WHERE(cdata.unc LT 0)
		thisunc[fixthese]=0.06
		fixthese=WHERE(cdata.unc GT 0.5)
		thisunc[fixthese]=0.06
		
		
		uncplot=ERRORPLOT(cdate[dotflag],cvalue[dotflag],thisunc[dotflag],symbol='circle',sym_size=0.4,_extra=params,sym_filled=thissymfill,$
		COLOR=thiscolor,/overplot)

		uncplot.errorbar_color=thiscolor
		uncplot.errorbar_capsize=0.1
		uncplot.errorbar_thick=1
		uncplot.errorbar_linestyle=0

	ENDIF
	If addcomparison EQ 1 THEN BEGIN
	CASE site of
		'ALT': begin
			IF mpi EQ 1 THEN BEGIN
				compfile='/home/ccg/michel/ch4c13icp/mpi.alt.csv
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field2,'/')
					secslash=STRPOS(comp[c].field2,'/',/reverse_search)
					;mo/dy/yr
					mo=FIX(STRMID(comp[c].field2,0,firstslash))
					yr=FIX('20'+STRMID(comp[c].field2,secslash+1,2))
					dy=FIX(STRMID(comp[c].field2,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
				;offset-0.33
				offset=0  ; if on mras scale
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3+offset,_extra=params,symbol='circle',color=mpicolor,sym_size=0.4,sym_filled=1,/overplot)
				label=TEXT(0.76,0.74,'INSTAAR', /current,/normal, font_size=20, color=thiscolor)
			
				label=TEXT(0.76,0.7,'MPI-BGC', /current,/normal,font_size=20, color=mpicolor)
				IF addsccomp EQ 1 THEN BEGIN
					CCG_CCGVU,x=decdate[usecomp],y=comp[usecomp].field3+offset,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
					scplot=PLOT(sc[0,*],sc[1,*],color=mpicolorcolor,overplot=1,thick=2,linestyle=0)
				ENDIF	
			ENDIF 
			
			IF RHUL EQ 1 THEN BEGIN
				showboth=0
				
				IF showboth EQ 1 THEN q=1 else q=2
				FOR p=0,q-1 DO BEGIN
				
					compfilearr=['alt.rhul.ch4c13.csv','alt.rhul.ch4c13.050121.csv']
					compfile='/home/ccg/michel/ch4c13icp/'+compfilearr[p]
					CCG_READ,file=compfile,comp,skip=1,delimiter=','
					ncomp=N_ELEMENTS(comp)
				
					decdate=FLTARR(ncomp)
					FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
					ENDFOR
					usecomp=WHERE(decdate GT 2014,nuse)
					IF p EQ 1 THEN rhulcolor='purple'
					compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',sym_filled=1,color=rhulcolor,sym_size=0.4,/overplot)
					IF p EQ 0 THEN label=TEXT(0.76,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
			
					IF p EQ 0 THEN label=TEXT(0.76,0.7,'RHUL', /current,/normal,font_size=20, color=rhulcolor)
					IF addsccomp EQ 1 THEN BEGIN
					CCG_CCGVU,x=decdate[usecomp],y=comp[usecomp].field3,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
					scplot=PLOT(sc[0,*],sc[1,*],color=rhulcolor,overplot=1,thick=2,linestyle=0)
				ENDIF	
			
					;IF p EQ 1 THEN label=TEXT(0.8,0.66,'RHUL-old', /current,/normal,font_size=20, color=rhulcolor)
					
				ENDFOR
			ENDIF 
		END
		'ASC': begin
			IF RHUL EQ 1 THEN BEGIN
			compfile='/home/ccg/michel/ch4c13icp/asc.rhul.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
			
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
			
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',color=rhulcolor,sym_filled=1,sym_size=0.4,/overplot)
				label=TEXT(0.8,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
			
				label=TEXT(0.8,0.7,'RHUL', /current,/normal,font_size=20, color=rhulcolor)
			
			
			ENDIF
		END
		
		'ZEP': begin
			IF tu EQ 1 THEN BEGIN
				compfile='/home/ccg/michel/ch4c13icp/zep.tu.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
			
				 decdate=FLTARR(ncomp)
				 FOR c=0,ncomp-1 DO BEGIN
					 firstslash=STRPOS(comp[c].field9,'/')
					 secslash=STRPOS(comp[c].field9,'/',/reverse_search)
					 ;mo/dy/yr
					 mo=FIX(STRMID(comp[c].field9,0,firstslash))
					 yr=FIX(STRMID(comp[c].field9,secslash+1,4))
					 dy=FIX(STRMID(comp[c].field9,firstslash+1,(secslash-firstslash-1)))
				
					 CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					 decdate[c]=dec
				ENDFOR
				compplot=PLOT(decdate,comp.field10-0.18,_extra=params,symbol='circle',color=tucolor,sym_filled=1,sym_size=0.4,/overplot)
				label=TEXT(0.76,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
				label=TEXT(0.76,0.7,'TU', /current,/normal,font_size=20, color=tucolor)
				
				IF addsccomp EQ 1 THEN BEGIN
					CCG_CCGVU,x=decdate,y=comp.field10-0.18,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
					IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color=tucolor,overplot=1,thick=2,linestyle=0)
				ENDIF	
			ENDIF
			IF RHUL EQ 1 THEN BEGIN
				showboth=0
				
				IF showboth EQ 1 THEN q=2 else q=1
				FOR p=0,q-1 DO BEGIN

					compfilearr=['zep.rhul.ch4c13.csv','zep.rhul.ch4c13.050121.csv']
					compfile='/home/ccg/michel/ch4c13icp/'+compfilearr[p]
					CCG_READ,file=compfile,comp,skip=1,delimiter=','
					ncomp=N_ELEMENTS(comp)
				
					decdate=FLTARR(ncomp)
					FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
					ENDFOR
					usecomp=WHERE(decdate GT 2014,nuse)
					IF p EQ 1 THEN rhulcolor='purple'
					compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',sym_filled=1,color=rhulcolor,sym_size=0.4,/overplot)
					IF p EQ 0 THEN label=TEXT(0.76,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
			
					IF p EQ 0 THEN label=TEXT(0.76,0.7,'RHUL', /current,/normal,font_size=20, color=rhulcolor)
			
					IF p EQ 1 THEN label=TEXT(0.76,0.66,'RHUL-old', /current,/normal,font_size=20, color=rhulcolor)
					
					IF addsccomp EQ 1 THEN BEGIN
					CCG_CCGVU,x=decdate[usecomp],y=comp[usecomp].field3,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
					IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color=rhulcolor,overplot=1,thick=2,linestyle=0)
					ENDIF
				ENDFOR
			
			ENDIF 
			
		END
		'BHD' : begin
			;compfile='/home/ccg/michel/ch4c13icp/bhd.niwa.ch4c13.csv'
			;CCG_READ,file=compfile,comp,skip=1,delimiter=','
			;ncomp=N_ELEMENTS(comp)
	;	
			;compplot=PLOT(comp.field1,comp.field2+0.13,_extra=params,symbol='circle',color=niwacolor,sym_size=0.4,sym_filled=1,/overplot)
			;label=TEXT(0.8,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
			;label=TEXT(0.8,0.7,'NIWA', /current,/normal,font_size=20, color=niwacolor)
			
				compfile='/home/ccg/michel/ch4c13icp/bhd.niwa.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
			
				 decdate=FLTARR(ncomp)
				 FOR c=0,ncomp-1 DO BEGIN
					 firstslash=STRPOS(comp[c].field9,'-')
					 secslash=STRPOS(comp[c].field9,'-',/reverse_search)
					 ;yr/mo/dy
					  mo=FIX(STRMID(comp[c].field9,firstslash+1,secslash-firstslash-1))
					 yr=FIX(STRMID(comp[c].field9,firstslash-4,4))
					 dy=FIX(STRMID(comp[c].field9,secslash+1,2))
					
					
					 CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					 decdate[c]=dec
				ENDFOR
				;compplot=PLOT(decdate,comp.field10+0.13,_extra=params,symbol='circle',color=tucolor,sym_filled=1,sym_size=0.4,/overplot)
				compplot=PLOT(decdate,comp.field10,_extra=params,symbol='circle',color=niwacolor,sym_filled=1,sym_size=0.4,/overplot)
				
				label=TEXT(0.76,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
				label=TEXT(0.76,0.7,'NIWA', /current,/normal,font_size=20, color=niwacolor)
				
				IF addsccomp EQ 1 THEN BEGIN
					CCG_CCGVU,x=decdate,y=comp.field10+0.13,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
					IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color=tucolor,overplot=1,thick=2,linestyle=0)
				ENDIF	
		stop
		END
		
	ENDCASE
	ENDIF
	
	IF noflags EQ 1 THEN GOTO,skipallflags
	IF softflags NE 1 THEN BEGIN
		
	
			IF aflag[0] NE -1 THEN aplot=PLOT(cdate[aflag],cvalue[aflag],$
				COLOR=carr[1],/overplot,symbol='circle',sym_size= 1.0,sym_filled=1,_extra=params)
			If pflag[0] NE -1 THEN pplot=PLOT(cdate[pflag],cvalue[pflag],$
				COLOR=carr[2],/overplot,symbol='circle',sym_size= 1.0,sym_filled=1,_extra=params)
		
			If plusflag[0] NE -1 THEN plplot=PLOT(cdate[plusflag],cvalue[plusflag],$
				COLOR=carr[3],/overplot,symbol='plus',sym_size= 1.0,sym_filled=1,sym_thick=2,_extra=params)
			If minusflag[0] NE -1 THEN mplot=PLOT(cdate[minusflag],cvalue[minusflag],$
				COLOR=carr[4],/overplot,symbol='hline',sym_size= 1.0,sym_filled=1,sym_thick=2,_extra=params)	
	
			IF lflag[0] NE -1 THEN lplot=PLOT(cdate[lflag],cvalue[lflag],$
				COLOR=carr[5],/overplot,symbol='circle',sym_size= 1.0,sym_filled=1,_extra=params)	
			IF hflag[0] NE -1 THEN hplot=PLOT(cdate[hflag],cvalue[hflag],$
				COLOR=carr[6],/overplot,symbol='circle',sym_size= 1.0,sym_filled=1,_extra=params)	
	
			IF tflag[0] NE -1 THEN tplot=PLOT(cdate[tflag],cvalue[tflag],$
				COLOR=carr[7],/overplot,symbol='X',sym_size= 1.0,sym_filled=1,sym_thick=2,_extra=params)	
			IF dflag[0] NE -1 THEN dplot=PLOT(cdate[dflag],cvalue[dflag],$
				COLOR=carr[8],/overplot,symbol='circle',sym_size= 1.0,sym_filled=1,_extra=params)	
			IF exflag[0] NE -1 THEN explot=PLOT(cdate[exflag],cvalue[exflag],$
				COLOR=carr[9],/overplot,symbol='triangle',sym_size= 1.0,sym_filled=1,_extra=params)
			IF xflag[0] NE -1 THEN explot=PLOT(cdate[xflag],cvalue[xflag],$
				COLOR=carr[10],/overplot,symbol='triangle',sym_size= 1.0,sym_filled=1,_extra=params)	
			;IF mflag[0] NE -1 THEN mplot=PLOT(cdate[mflag],cvalue[mflag],$
			;	COLOR=carr[10],/overplot,symbol='square',sym_size= 1.0,sym_filled=1,_extra=params)	
			;IF rflag[0] NE -1 THEN rplot=PLOT(cdate[rflag],cvalue[rflag],$
			;	COLOR=carr[11],/overplot,symbol='square',sym_size= 1.0,sym_filled=1,_extra=params)	
			
			FOR l=0,10 DO BEGIN
			whichisit=TEXT(0.88,(0.89-(0.04*l)),thistarr[l],font_size=15,color=carr[l],/current)
			ENDFOR
	
		

	ENDIF ELSE BEGIN ;hardflags

		
		
			IF xflag[0] NE -1 THEN xplot=PLOT(cdate[xflag],cvalue[xflag],$
				COLOR='blue',/overplot,_extra=params)	
			
			
			whichisit=TEXT(0.85,(0.70-(0.04*1)),'good data',font_size=15,color='red',/current)
			whichisit=TEXT(0.85,(0.70-(0.04*2)),'non-background',font_size=15,color='blue',/current)
		
			
	
	
	ENDELSE
	skipallflags:
	
	IF plotlindata EQ 1 THEN BEGIN
		IF plotalllins EQ 1 THEN nlindirs=N_ELEMENTS(whichlin) ELSE nlindirs=1
		lincolorarr=['red','orange','magenta','purple']
		FOR q=0,nlindirs-1 DO BEGIN
		
			; go find site data
			; plot by date
			IF newsitefiles EQ 0 THEN BEGIN 
				CCG_READ,file=lindir+whichlin[q]+STRLOWCASE(site)+'.ch4c13',lindat
				nlin=N_ELEMENTS(lindat)
				unflagged=WHERE(STRMID(lindat.field10,0,1) EQ '.',nunflagged,complement=flagged)
				print,'nunflagged = ',nunflagged
				CCG_date2dec,yr=lindat.field12,mo=lindat.field13,dy=lindat.field14,hr=lindat.field15,mn=lindat.field16,dec=dec
					linadate=dec
				CCG_date2dec,yr=lindat.field2,mo=lindat.field3,dy=lindat.field4,hr=lindat.field5,mn=lindat.field6,dec=dec
					lindate=dec	
					
			ENDIF ELSE BEGIN
				CCG_READ,file=lindir+STRLOWCASE(site)+'.ch4c13',lindat
			
				nlin=N_ELEMENTS(lindat)
				unflagged=WHERE(STRMID(lindat.field11,0,1) EQ '.',nunflagged,complement=flagged)
				
				CCG_date2dec,yr=lindat.field13,mo=lindat.field14,dy=lindat.field15,hr=lindat.field16,mn=lindat.field17,dec=dec
					linadate=dec
				CCG_date2dec,yr=lindat.field2,mo=lindat.field3,dy=lindat.field4,hr=lindat.field5,mn=lindat.field6,dec=dec
					lindate=dec	
				
			ENDELSE		
			
			
			
			
			
			IF plotbyadate EQ 1 THEN thisdate=linadate ELSE thisdate=lindate
			
			linplot=PLOT(thisdate[unflagged],lindat[unflagged].field9,symbol='circle',_extra=params,linestyle=6,color=lincolorarr[q],sym_size=0.4,sym_filled=1,/overplot)
			;linplot=PLOT(lindate[flagged],lindat[flagged].field9,symbol='circle',linestyle=6,color='orange',sym_size=0.4,sym_filled=0,/overplot)
			
			IF addunc EQ 1 THEN BEGIN
			
				linunc=lindat.field17
				fixthese=WHERE(linunc LT 0)
				thisunc[fixthese]=0.06
				fixthese=WHERE(linunc GT 0.5)
				linunc[fixthese]=0.06
		
		
				linuncplot=ERRORPLOT(thisdate[unflagged],lindat[unflagged].field9,linunc[unflagged],symbol='circle',_extra=params,linestyle=6,color=lincolorarr[q],sym_size=0.4,sym_filled=1,/overplot)
				
				linuncplot.errorbar_color=lincolorarr[q]
				linuncplot.errorbar_capsize=0.1
				linuncplot.errorbar_thick=1
				linuncplot.errorbar_linestyle=0
				
				
				
				
				
			
				
			ENDIF
			
			if plotalllins EQ 1 THEN lintitle=namearr[q] ELSE lintitle=linname
			name=TEXT(0.72,(0.8-(0.04*q)), lintitle,color=lincolorarr[q],/current,font_size=16,/normal)
			CCG_CCGVU,x=lindate[unflagged],y=lindat[unflagged].field9,cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
			IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color=lincolorarr[q],overplot=1,thick=3,linestyle=0)
		
		ENDFOR
		
	ENDIF
	
	IF data NE 'db' THEN printwhatitis=TEXT(0.9,0.05,data,font_size=14,/current)
	
	IF addsc EQ 1 or addtr EQ 1 THEN BEGIN   ; or addtr
		
		;CCG_CCGVU,x=cdate[dotflag],y=cvalue[dotflag],cutoff1=init.cutoff1,cutoff2=init.cutoff2,nharm=init.nharm,npoly=init.npoly,sc=sc,tr=tr,even=1
	
		CCG_CCGVU,x=cdate[dotflag],y=cvalue[dotflag],cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,sc=sc,tr=tr,even=1
		;CCG_CCGVU,x=ch4x,y=ch4y,cutoff1=180,cutoff2=667,nharm=init.nharm,npoly=init.npoly,sc=ch4sc,tr=ch4tr,even=1
		;CCG_CCGVU,x=isox,y=isoy,cutoff1=180,cutoff2=667,nharm=2,npoly=3,sc=isosc,tr=isotr,even=1
		IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color=thiscolor,overplot=1,thick=3,linestyle=0)
		IF addtr EQ 1 THEN trplot=PLOT(tr[0,*],tr[1,*],color='black',overplot=1,thick=3,linestyle=0)
	ENDIF
	
	
	;this is where we look at residuals
	IF residuals EQ 1 THEN BEGIN
		;-look for runs with lots of bad data
		;-remove data with high residuals
		;-add flag??
		
	
	
	
	
	ENDIF 
	
	
	
	;----
	
	IF savegraphs EQ 1 THEN BEGIN

		thisplot.save,filename
		thisplot.close
	
	ENDIF ELSE BEGIN
	
		IF onebyone EQ 1 THEN BEGIN 
   			 result=DIALOG_MESSAGE ('Next Plot?', title = 'Continue',/Question, /cancel)
			IF result EQ 'Cancel' THEN goto,bailout
			IF result EQ 'No' THEN BEGIN
				i=i-1
			ENDIF
		ENDIF
	ENDELSE
	; look at differences between data streams...
	
	

	IF plotlindata EQ 1 THEN BEGIN	
		IF plotlindiffs eQ 1 THEN BEGIN
		; unfortunately I need to line them up. 
	
		combarr=REPLICATE({evn:'',$
			date:0.0,$
			adate:0.0,$
			oldvalue:0.0,$
			oldunc:0.0,$
			oldflag:'',$
			linvalue:0.0,$
			linunc:0.0,$
			linflag:'',$
			diff:0.0},nlines)

			FOR z=0,nlines-1 DO BEGIN
				combarr[z].evn=cdata[z].evn      ; this won't work for sitedata, only data='db'
				combarr[z].date=cdata[z].date   
				combarr[z].adate=cdata[z].adate   
				combarr[z].oldvalue=cdata[z].value
				combarr[z].oldunc=cdata[z].unc
				combarr[z].oldflag=cdata[z].flag
				
				; now need to match up:
				
				findlin=WHERE(lindat.field8 EQ cdata[z].id AND lindate EQ cdata[z].date AND linadate EQ cdata[z].adate,nfind)
				IF nfind EQ 1 THEN BEGIN
					combarr[z].linvalue=lindat[findlin].field9	
					;combarr[z].linunc=lindat[findlin].fieldxx ;hopefully coming	
					combarr[z].linflag=lindat[findlin].field10	
					
				
				ENDIF ELSE BEGIN
				 	IF findlin[-1] THEN combarr[z].linvalue=-999.9
					IF findlin[-1] THEN combarr[z].linflag='!!!'
					
				ENDELSE
			
			ENDFOR
			filter=WHERE(combarr.linflag EQ '!!!',complement=keep)
			combarr=combarr[keep]
			combarr.diff=combarr.oldvalue-combarr.linvalue
			diffplot=PLOT(combarr.date,combarr.diff,_extra=params,symbol='circle',dimension=[1400,600],POSITION=[0.14,0.14,0.86,0.9],$
				yrange=[-0.2,0.2],ytitle='$\delta$$^{13}$CH$_4$ ($\permil$), oldvalue-linvalue',data='all data',sym_size=0.6)		

			noflag=WHERE(STRMID(combarr.oldflag,0,1) EQ '.')
			Rflag=WHERE(STRMID(combarr.oldflag,2,1) EQ 'R')
			Mflag=WHERE(STRMID(combarr.oldflag,0,1) EQ 'M')
			noflagplot=PLOT(combarr[noflag].date,combarr[noflag].diff,symbol='circle',sym_filled=1,/overplot,color='red',linestyle=6,data='no flags',sym_size=0.6)
			IF Rflag[0] NE -1 THEN rflagplot=PLOT(combarr[Rflag].date,combarr[Rflag].diff,sym_filled=1,symbol='circle',/overplot,color='blue',_extra=params, sym_size=0.6,data='>2.5 nA diff')
			IF Mflag[0] NE -1 THEN Lflagplot=PLOT(combarr[Mflag].date,combarr[Mflag].diff,sym_filled=1,symbol='circle',/overplot,color='green',_extra=params,sym_size=0.6,data='M flag')
		
			leg=legend(target=[diffplot,noflagplot,rflagplot,Lflagplot],position=[0.8,0,8], shadow=0,sample_width=0, linestyle=6)  ;
	
	
		ENDIF
	ENDIF	
	
	skipplots:  ;skip the normal plots
	
	


	



IF peakhtplots EQ 1 THEN BEGIN
	savename='/home/ccg/michel/ch4c13/peakhts/plot_sitedata_peakhts.'+site+'.sav'
	IF long EQ 1 THEN diffsavename='/home/ccg/michel/ch4c13/peakhts/plot_sitedata_diffpeakhts.long.'+site+'.sav' ELSE $
	diffsavename='/home/ccg/michel/ch4c13/peakhts/plot_sitedata_diffpeakhts.'+site+'.sav
	IF long EQ 1 THEN diffsavename='/home/ccg/michel/ch4c13//peakhts/plot_sitedata_refpeakhts.long.'+site+'.sav' ELSE $
	diffsavename='/home/ccg/michel/ch4c13/peakhts/plot_sitedata_refpeakhts.'+site+'.sav
					
	IF getdata EQ 1 THEN BEGIN
		peakhts=FLTARR(2,nlines)
		refhtarr=FLTARR(2,nlines)
		IF peakhtdiffs EQ 1 THEN BEGIN
			refhtarr=FLTARR(2,nlines)
			peakhtdiffarr=FLTARR(2,nlines)
		ENDIF	
		FOR p=0,nlines-1 DO BEGIN
		print,'p= ',p
			ch4c13_peakht,enum=cdata[p].evn,peakheight=peakheight,refheight=refheight
			peakhts[1,p]=peakheight[0]   ; in case of mutliple values I just take the ffffffffffffffirst.
			peakhts[0,p]=cdata[p].evn
		
			;IF peakhtdiffs EQ 1 THEN BEGIN
			refhtarr[0,p]=peakhts[0,p]
			refhtarr[1,p]=refheight[0]
		
			peakhtdiffarr[0,p]=peakhts[0,p]
			peakhtdiffarr[1,p]=refheight[0]-peakhts[1,p]
			
			;ENDIF
		
		ENDFOR
		SAVE,peakhts,filename=savename
		SAVE,refhtarr,filename=refsavename
		SAVE,peakhtdiffarr,filename=diffsavename

	ENDIF ELSE BEGIN
		RESTORE,filename=savename
		RESTORE,filename=refsavename
		RESTORE,filename=diffsavename
	ENDELSE

	IF makepeaksizeplots EQ 1 THEN BEGIN
		;just plot peakheights and ref peaks over time:
	
		peakhtovertime=PLOT(cdate,peakhts[1,*],$
				DIMENSIONS=[1200,800],$	
			
				POSITION=[0.1,0.08,0.84,0.94],$  
				symbol='circle',linestyle=6,font_size=16,$
			
				;YRANGE=[-2,5],$
				color='blue',$
				sym_filled=1,$
				sym_size= 0.4,$
				YTITLE='peak height  (nA)',$
				name='sam peak height')
		
		refpk=PLOT(cdate,refhtarr[1,*],color='green',symbol='circle',sym_size=0.4,/overplot,sym_filled=1,name='ref peak height',linestyle=6)
		;legend=LEG(target=[peakhtovertime,refpk],position=[0.8,0.8],shadow=0,linestyle=6)
	

	pdata=WHERE(cdata.meth EQ 'P')
	sdata=WHERE(cdata.meth EQ 'S')
	gdata=WHERE(cdata.meth EQ 'G')
	ddata=WHERE(cdata.meth EQ 'D')
	idata=WHERE(cdata.meth EQ 'I')
	rdata=WHERE(cdata.meth EQ 'R')
	ndata=WHERE(cdata.meth EQ 'N')
	
	
	
	
		htovertime=PLOT(cdate,peakhtdiffarr[1,*],$
			DIMENSIONS=[1400,600],$	
		
			POSITION=[0.14,0.14,0.86,0.9],$  
			symbol='circle',$
			sym_filled=0,$		
			;YRANGE=[-2,5],$
			color='black',$
			sym_size= 0.4,linestyle=6,font_size=16,$
			YTITLE='peak height diff (nA)')
	
		j=0
		IF sdata[0] NE -1 THEN BEGIN
			sdataplot=PLOT(cdate[sdata],peakhtdiffarr[1,sdata],color='blue',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			stext=TEXT(0.8,0.8-j*0.04,'S',font_size=16,color='blue')
			j=j+1		
		ENDIF
		IF pdata[0] NE -1 THEN BEGIN
			pdataplot=PLOT(cdate[pdata],peakhtdiffarr[1,pdata],color='red',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			ptext=TEXT(0.8,0.8-j*0.04,'P',font_size=16,color='red')
			j=j+1	
		ENDIF
		IF gdata[0] NE -1 THEN BEGIN
			gdataplot=PLOT(cdate[gdata],peakhtdiffarr[1,gdata],color='orange',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			gtext=TEXT(0.8,0.8-j*0.04,'G',font_size=16,color='orange')
			j=j+1	
		ENDIF
		IF ddata[0] NE -1 THEN BEGIN
			ddataplot=PLOT(cdate[ddata],peakhtdiffarr[1,ddata],color='green',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			dtext=TEXT(0.8,0.8-j*0.04,'D',font_size=16,color='green')
			j=j+1	
		ENDIF
		IF idata[0] NE -1 THEN BEGIN
			idataplot=PLOT(cdate[idata],peakhtdiffarr[1,idata],color='purple',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			itext=TEXT(0.8,0.8-j*0.04,'I',font_size=16,color='purple')
			j=j+1	
		ENDIF
		IF rdata[0] NE -1 THEN BEGIN
			rdataplot=PLOT(cdate[rdata],peakhtdiffarr[1,rdata],color='brown',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			rtext=TEXT(0.8,0.8-j*0.04,'R',font_size=16,color='brown')
			j=j+1	
		ENDIF
		IF ndata[0] NE -1 THEN BEGIN
			ndataplot=PLOT(cdate[ndata],peakhtdiffarr[1,ndata],color='pink',/overplot, symbol='circle',sym_filled=1,linestyle=6,sym_size=0.4)
			ntext=TEXT(0.8,0.8-j*0.04,'N',font_size=16,color='brown')
			j=j+1	
		ENDIF
	ENDIF	
	
	
	IF peakhtdiffs eq 0 THEN BEGIN
	;; plotting just peak heights. 
		pkcolor=FLTARR(nlines)
		; convert peak heights to a value between 0-255
		;range=0-13
		
		scalestretch=255.0/18.0
		
		pkcolor=peakhts[1,*]*scalestretch
		     
		  thisplotb=WINDOW(location=[100,100],dimensions=[1400,600])
		
		thisplotdat=PLOT(cdate,cvalue,$
			/current,$
			POSITION=[0.14,0.14,0.86,0.9],$
			;POSITION=[0.1,0.08,0.84,0.94],$   ;[0.14,0.15,0.94,0.85],$   
			YRANGE=[cymin,cymax],$
			color='white',$
			sym_size= 0.4,_extra=params,$
			YTITLE='$\delta$$^{13}$CH$_4$ ($\permil$)')
	
	
	
		thisplotcol=PLOT(cdate,cvalue,/overplot,rgb=13,vert_color=pkcolor,symbol='circle',linestyle=6)
		flags=PLOT(cdate[flaggeddata],cvalue[flaggeddata],symbol='triangle',sym_filled=1,linestyle=6,/overplot)
		
		IF xflag[0] NE -1 THEN moreflags=PLOT(cdate[xflag],cvalue[xflag],symbol='X',linestyle=6,/overplot)

		;thistext=TEXT(0.12,0.95,'$\delta$$^{13}$CH$_4$ of flasks from ' + strupcase(site),$
		;	font_size=20)
	
		
		c=COLORBAR(target=thisplotdat,orientation=1,rgb_table=13,position=[0.93,0.08,0.96,0.94],title='peak height (nA)',range=[0,18])
		c.font_size=16
		c.tickdir=1
		c.textpos=0
	
	
		IF savegraphs EQ 0 THEN stop
		IF savegraphs EQ 1 THEN BEGIN
		
			IF data EQ 'db' THEN filename2='/home/ccg/michel/plots/siteplots/'+site+'.ch4c13.peakhts.'+ourdev
			IF data EQ 'sitefile' THEN filename2='/home/ccg/michel/plots/siteplots/'+site+'.ch4c13.peakhts.sitefiles.'+ourdev
			
			
	
			thisplotb.save,filename2
			thisplotb.close
	
		ENDIF

	ENDIF ELSE BEGIN
		;; plotting diff betw peak heights and refs. 
		fullscale=0
		 thisplotb=WINDOW(location=[100,100],dimensions=[1400,600])
		
		thisplotdat=PLOT(cdate,cvalue,$
			/current,$
		
			POSITION=[0.15,0.15,0.84,0.94],$   ;[0.14,0.15,0.94,0.85],$   
			YRANGE=[cymin,cymax],$
			color='white',$
			sym_size= 0.4,_extra=params,$
			xtitle=ourxtitle,$
			YTITLE='$\delta$$^{13}$CH$_4$ ($\permil$)')
			
		IF fullscale EQ 1 THEN BEGIN
			min=MIN(peakhtdiffarr[1,*])
		
			max=MAX(peakhtdiffarr[1,*])
			range=max-min
			scalestretch=255.0/range   ;slope
			intercept=0.0-1.0*scalestretch*min				;int	
		
			pkcolor=FLTARR(nlines)
			; convert peak heights to a value between 0-255
			FOR p=0,nlines-1 DO BEGIN
			
				pkcolor[p]=(peakhtdiffarr[1,p]*scalestretch)+intercept
			ENDFOR
			
			check=plot(peakhtdiffarr[1,*],pkcolor,symbol='circle',linestyle=0)
			
			IF plotbyadate EQ 1 then ourxtitle='analysis date' ELSE ourxtitle='date'
			
			IF addcomparison EQ 0 THEN BEGIN
		
				thisplotcol=PLOT(cdate[dotflag],cvalue[dotflag],/overplot,rgb=13,vert_color=pkcolor,symbol='circle',linestyle=6)
				thisplotcol=PLOT(cdate[flaggeddata],cvalue[flaggeddata],/overplot,rgb=13,vert_color=pkcolor,symbol='circle',linestyle=6)
				flags=PLOT(cdate[flaggeddata],cvalue[flaggeddata],symbol='triangle',sym_filled=1,linestyle=6,/overplot)
				IF xflag[0] NE -1 THEN moreflags=PLOT(cdate[xflag],cvalue[xflag],symbol='X',linestyle=6,/overplot)
			ENDIF ELSE BEGIN  ; don't plot flagged data
				thisplotcol=PLOT(cdate[dotflag],cvalue[dotflag],/overplot,rgb=13,vert_color=pkcolor[dotflag],symbol='circle',linestyle=6)
			
			ENDELSE
		 
		ENDIF ELSE BEGIN
			min=-1
			max=4
			unfldate=cdate[dotflag]
			onlyunflagged=cvalue[dotflag]
			;onlythese=WHERE(peakhtdiffarr[1,*] GT min AND peakhtdiffarr[1,*] LT max,complement=notthose)
			onlythese=WHERE(peakhtdiffarr[1,onlyunflagged] GT min AND peakhtdiffarr[1,onlyunflagged] LT max,complement=notthose)
			
			range=max-min
			scalestretch=255.0/range   ;slope
			intercept=0.0-1.0*scalestretch*min				;int	
	
			pkcolor=FLTARR(nlines)
			; convert peak heights to a value between 0-255
			FOR p=0,nlines-1 DO BEGIN
			
				pkcolor[p]=(peakhtdiffarr[1,p]*scalestretch)+intercept
			ENDFOR
		
			;check=plot(peakhtdiffarr[1,onlythese],pkcolor[onlythese],symbol='circle',linestyle=0)
			IF plotbyadate EQ 1 then ourxtitle='analysis date' ELSE ourxtitle='date'
			
			IF addcomparison EQ 0 THEN BEGIN
		
				;thisplotcol=PLOT(cdate[onlythese],cvalue[onlythese],/overplot,sym_filled=1,rgb=13,vert_color=pkcolor[onlythese],symbol='circle',linestyle=6)
				thisplotcol=PLOT(unfldate[onlythese],onlyunflagged[onlythese],/overplot,sym_filled=1,rgb=13,vert_color=pkcolor[onlythese],symbol='circle',linestyle=6)
				
				;thisplotcol=PLOT(cdate[notthose],cvalue[notthose],/overplot,color='black',symbol='circle',linestyle=6)
				;flags=PLOT(cdate[flaggeddata],cvalue[flaggeddata],symbol='triangle',sym_filled=1,linestyle=6,/overplot)
				stop
				IF xflag[0] NE -1 THEN moreflags=PLOT(cdate[xflag],cvalue[xflag],symbol='X',linestyle=6,/overplot)
			ENDIF ELSE BEGIN  ; don't plot flagged data
				;thisplotcol=PLOT(cdate[dotflag],cvalue[dotflag],/overplot,rgb=13,vert_color=pkcolor[dotflag],symbol='circle',linestyle=6)
				;;;stop ;and figure this out
			ENDELSE
			
		ENDELSE	
	
		
		thistext=TEXT(0.12,0.95,strupcase(site), font_size=20)
		;thistext=TEXT(0.12,0.95,'$\delta$$^{13}$CH$_4$ of flasks from ' + strupcase(site),$
		;		font_size=20)
	
		
		c=COLORBAR(target=thisplotdat,orientation=1,rgb_table=13,position=[0.93,0.08,0.96,0.94],title='difference in peak height (nA)',range=[min,max])
		c.font_size=16
		c.tickdir=1
		c.textpos=0
	
		If addcomparison EQ 1 THEN BEGIN
		CASE site of
			'ALT': begin
			IF mpi EQ 1 THEN BEGIN
				compfile='/home/ccg/michel/ch4c13icp/mpi.alt.csv
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field2,'/')
					secslash=STRPOS(comp[c].field2,'/',/reverse_search)
					;mo/dy/yr
					mo=FIX(STRMID(comp[c].field2,0,firstslash))
					yr=FIX('20'+STRMID(comp[c].field2,secslash+1,2))
					dy=FIX(STRMID(comp[c].field2,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
				
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3+0.33,_extra=params,symbol='circle',color='black',sym_size=0.4,/overplot)
				label=TEXT(0.7,0.74,'INSTAAR', /current,/normal, font_size=20, color='blue')
			
				label=TEXT(0.7,0.7,'MPI-BGC', /current,/normal,font_size=20, color='black')
			ENDIF 
			IF RHUL EQ 1 THEN BEGIN
			compfile='/home/ccg/michel/ch4c13icp/alt.rhul.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
				
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
			
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',color='purple',sym_size=0.4,/overplot)
				label=TEXT(0.7,0.74,'INSTAAR', /current,/normal, font_size=20, color='red')
			
				label=TEXT(0.7,0.7,'RHUL', /current,/normal,font_size=20, color='purple')
			
			
			ENDIF 
		END
		'ASC': begin
			IF RHUL EQ 1 THEN BEGIN
			compfile='/home/ccg/michel/ch4c13icp/asc.rhul.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
			
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
			
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',color='black',sym_size=0.4,/overplot)
				label=TEXT(0.7,0.74,'INSTAAR', /current,/normal, font_size=20, color='blue')
			
				label=TEXT(0.7,0.7,'RHUL', /current,/normal,font_size=20, color='black')
			
			
			ENDIF
		END
		
		'ZEP': begin
			IF tu EQ 1 THEN BEGIN
				compfile='/home/ccg/michel/ch4c13icp/zep.tu.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
			
				compplot=PLOT(comp.field1,comp.field2-0.18,_extra=params,symbol='circle',color='black',sym_size=0.4,/overplot)
				label=TEXT(0.8,0.74,'INSTAAR', /current,/normal, font_size=20, color='blue')
				label=TEXT(0.8,0.7,'TU', /current,/normal,font_size=20,color='black')
			ENDIF
			
			IF RHUL EQ 1 THEN BEGIN
				compfile='/home/ccg/michel/ch4c13icp/zep.rhul.ch4c13.csv'
				CCG_READ,file=compfile,comp,skip=1,delimiter=','
				ncomp=N_ELEMENTS(comp)
				
				decdate=FLTARR(ncomp)
				FOR c=0,ncomp-1 DO BEGIN
					firstslash=STRPOS(comp[c].field1,'/')
					secslash=STRPOS(comp[c].field1,'/',/reverse_search)
					;mo/dy/yr
					dy=FIX(STRMID(comp[c].field1,0,firstslash))
					yr=FIX(STRMID(comp[c].field1,secslash+1,4))
					mo=FIX(STRMID(comp[c].field1,firstslash+1,(secslash-firstslash-1)))
				
					CCG_date2dec,yr=yr,mo=mo,dy=dy,dec=dec
					decdate[c]=dec
				
				ENDFOR
				usecomp=WHERE(decdate GT 2014,nuse)
			
				compplot=PLOT(decdate[usecomp],comp[usecomp].field3,_extra=params,symbol='circle',color='black',sym_size=0.4,/overplot)
				label=TEXT(0.7,0.74,'INSTAAR', /current,/normal, font_size=20, color='blue')
			
				label=TEXT(0.7,0.7,'RHUL', /current,/normal,font_size=20, color='black')
			
			
			ENDIF 
			
		END
		'BHD' : begin
			compfile='/home/ccg/michel/ch4c13icp/bhd.niwa.ch4c13.csv'
			CCG_READ,file=compfile,comp,skip=1,delimiter=','
			ncomp=N_ELEMENTS(comp)
		
			compplot=PLOT(comp.field1,comp.field2+0.13,_extra=params,symbol='circle',color='black',sym_size=0.4,/overplot)
			label=TEXT(0.7,0.74,'INSTAAR', /current,/normal, font_size=20, color='blue')
			label=TEXT(0.7,0.7,'NIWA', /current,/normal,font_size=20,color='black')
		
		
		END
		
	ENDCASE
	ENDIF
		IF savegraphs EQ 0 THEN stop
		IF savegraphs EQ 1 THEN BEGIN
			
			filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.'
			IF data EQ 'sitefile' THEN filename2=filename2+'sitefile.'
			IF long EQ 1 THEN filename2=filename2+'long.'
			IF plotbyadate EQ 1 THEN filename2=filename2+'adate.'
			filename2=filename2+ourdev
			print,filename2
			thisplotb.save,filename2
			thisplotb.close
	
		ENDIF



	ENDELSE



ENDIF
;;;; ----------------drift plots

IF makedriftplots EQ 1 THEN BEGIN
	driftsavename='/home/ccg/sil/ch4c13/drift/plot_sitedata_drift.'+site+'.sav'
					
	IF getdriftdata EQ 1 THEN BEGIN
		drift=FLTARR(2,nlines)
		
		FOR p=0,nlines-1 DO BEGIN
		print,'p= ',p
		print,'enum = ',cdata[p].evn
			ch4c13_runnum,enum=cdata[p].evn,runnum=runnum,ref=ref
		
			drift[0,p]=cdata[p].evn
		;	drift[1,p]=ref
			IF runnum EQ 0 THEN goto,skipthisdrift  ; but why?
			IF strmid(ref,4,1) NE '-' THEN stop
			; now look up reffile, find data....
			reffile='/projects/ch4c13/cals/internal_cyl/refstat'+ref+'.ch4c13.i1'
			CCG_READ, file=reffile, refdata
			
			thisrun=WHERE(refdata.field5 EQ runnum,nthisrun)
			
			refarr=DBLARR(nthisrun)
			FOR j=0,nthisrun-1 DO BEGIN
				CCG_DATE2DEC, yr=refdata[thisrun[j]].field7,mo=refdata[thisrun[j]].field8,dy=refdata[thisrun[j]].field9,$
				hr=refdata[thisrun[j]].field10,mn=refdata[thisrun[j]].field11,dec=dec
				refarr[j]=dec
			ENDFOR
			
			;loop between refs. 
			;find where in run you are
			segment=0 ; what part of run are you in
			FOR k=0,nthisrun-1 DO BEGIN			
				IF cdata[p].adate GT refarr[k] THEN BEGIN ;ran after this one
					segment=segment+1
					
				ENDIF 
			ENDFOR
			; now based on segment get info on the refs around the segment. segment1=ref2-ref1 etc
			;if no ref after segment then no driftcorr
			
			IF nthisrun GT segment THEN drift[1,p]=refdata[thisrun[segment]].field13-refdata[thisrun[segment-1]].field13
			IF nthisrun EQ segment THEN drift[1,p]=-99.9
			
			
				
			skipthisdrift:		
			
		ENDFOR
		SAVE,drift,filename=driftsavename
		
	ENDIF ELSE BEGIN
		RESTORE,filename=driftsavename
		
	ENDELSE

	driftovertime=1
	drifthisto=0
	IF driftovertime EQ 1 THEN BEGIN
		;just plot drift
	
		driftovertime=PLOT(cdate,drift[1,*],$
			DIMENSIONS=[1400,600],$	
		
			POSITION=[0.14,0.14,0.86,0.9],$  
			symbol='circle',$
			sym_filled=1,$		
			;YRANGE=[-1,1],$
			xrange=[yr1,yr2],$
			yrange=[-1.0,1.0],$
			color='blue',$
			linestyle=6,font=14,$
			sym_size= 0.7,$ ;_extra=params,$
			YTITLE='drift')
			
			IF savegraphs EQ 1 THEN BEGIN
		
				IF data EQ 'db' THEN filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.driftovertime.'+ourdev
				IF data EQ 'sitefile' THEN filename2='/home/ccg/michel/plots/siteplots/'+site+'.ch4c13.driftovertime.sitefiles.'+ourdev
				
				driftovertime.save,filename2
				driftovertime.close
			
			ENDIF
	ENDIF	
	
	If drifthisto EQ 1 THEN begin
		
		pdf = HISTOGRAM(drift[1,*], LOCATIONS=xbin,binsize=0.01)
	
		phisto = PLOT(xbin, pdf, $
		 TITLE='Histogram', XTITLE='drift', YTITLE='Frequency', $
		xrange=[-0.5,0.5], AXIS_STYLE=1, COLOR='red')
			IF savegraphs EQ 1 THEN BEGIN
		
				IF data EQ 'db' THEN filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.drifthisto.'+ourdev
				IF data EQ 'sitefile' THEN filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.drifthisto.sitefiles.'+ourdev
				
				phisto.save,filename2
				phisto.close
			
			ENDIF

	ENDIF
	
	
		driftcolor=BYTARR(nlines)
		; convert peak heights to a value between 0-255
		
		maxdrift=0.5
		mindrift=-0.5
		range=maxdrift-mindrift
		
		
		;calculate slope: (y2-y1)/(X2-x1)
		scalestretch=255.0/range
		;calcualte interceppt: b=y1-(m*x1)
		int=0-(mindrift*scalestretch)
		
	
		for k=0,nlines-1 DO BEGIN
			driftcolor[k]=(drift[1,[k]]*scalestretch)+int
			
			IF (drift[1,k]) GT 2 THEN driftcolor[k]=255
			IF (drift[1,k]) LT -2 THEN driftcolor[k]=0
		 
		
		ENDFOR
		;ourplot=plot(drift[1,*],driftcolor,linestyle=6,sym='circle',sym_size=1,xrange=[-0.3,0.3],yrange=[0,255])
		
		  thisplotb=WINDOW(location=[100,100],dimensions=[1400,600])
		
		thisplotdat=PLOT(cdate,cvalue,$
			/current,$
			POSITION=[0.14,0.14,0.86,0.9],$
			;;POSITION=[0.1,0.08,0.84,0.94],$   ;[0.14,0.15,0.94,0.85],$   
			YRANGE=[cymin,cymax],$
			color='white',$
			sym_size= 0.4,_extra=params,$
			YTITLE='$\delta$$^{13}$CH$_4$ ($\permil$)')
	
	
	
		thisplotcol=PLOT(cdate,cvalue,/overplot,rgb=13,vert_color=driftcolor,sym_size=0.4,sym_filled=1,symbol='circle',linestyle=6)
		
	 	dflags=WHERE(ABS(drift[1,*]) GE 0.25)
		flagplot=PLOT(cdate[flaggeddata],cvalue[flaggeddata],symbol='triangle',sym_filled=0,linestyle=6,/overplot)
		IF dflags[0] NE -1 THEN dflagplot=PLOT(cdate[dflags],cvalue[dflags],symbol='circle',sym_size=0.8, sym_filled=0,linestyle=6,/overplot)
		
		
		;IF xflag[0] NE -1 THEN moreflags=PLOT(cdate[xflag],cvalue[xflag],symbol='X',linestyle=6,/overplot);

		thistext=TEXT(0.12,0.95,strupcase(site), font_size=20)
	
		
		c=COLORBAR(target=thisplotdat,orientation=1,rgb_table=13,position=[0.93,0.08,0.96,0.94],title='amount of drift',range=[mindrift,maxdrift])
		c.font_size=16
		c.tickdir=1
		c.textpos=0
		
		IF savegraphs EQ 0 THEN stop
		IF savegraphs EQ 1 THEN BEGIN
		
			IF data EQ 'db' THEN filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.drift.'+ourdev
			IF data EQ 'sitefile' THEN filename2='/home/ccg/sil/plots/siteplots/'+site+'.ch4c13.drift.sitefiles.'+ourdev
			thisplotb.save,filename2
			thisplotb.close
	
		ENDIF
ENDIF



;---------------------end drift plots
skipthisone:		 
ENDFOR
bailout:


IF ploto18data EQ 1 THEN BEGIN
	savename='/home/ccg/sil/ch4c13/plot_sitedata_o18.'+site+'.sav'
	IF long EQ 1 THEN savename='/home/ccg/sil/ch4c13/plot_sitedata_o18.long.'+site+'.sav'
					
	IF geto18data EQ 1 THEN BEGIN
		o18arr=FLTARR(2,nlines)
		FOR p=0,nlines-1 DO BEGIN
		print,'p= ',p
			ch4c13_o18,enum=cdata[p].evn,o18=o18
			o18arr[1,p]=o18[0]   ; in case of mutliple values I just take the first.
			o18arr[0,p]=cdata[p].evn
		
		
		ENDFOR
		SAVE,o18arr,filename=savename
		
	ENDIF ELSE BEGIN
		RESTORE,filename=savename
		
	ENDELSE
	
	o18plot=PLOT(cdate,o18arr[1,*],linestyle=6,dimensions=[1400,600],POSITION=[0.14,0.14,0.86,0.9],xtitle='date',symbol='circle',color='white',sym_size=0.8,ytitle='$\delta$ 46',font_size=24)
	o18plot.yrange=[-50,50]

	unflagged=PLOT(cdate[dotflag],o18arr[1,dotflag],linestyle=6,color='red',symbol='circle',sym_size=0.8,/overplot,sym_filled=1)
	unflagged=PLOT(cdate[flaggeddata],o18arr[1,flaggeddata],linestyle=6,color='black',symbol='circle',sym_size=0.8,/overplot,sym_filled=0)
stop

ENDIF



END
