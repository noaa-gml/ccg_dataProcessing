
PRO plot_sitedata_qaqc,site=site,savegraphs=savegraphs,$
strategy=strategy,project=project,evn=evn

;written 4/14/11 sem
; this plots data along with flags.
; archived versions have old vs new plotting options. Updated to only include new versions 5/2020
; sly cleaned up, added options (bias check, plotevn, etc 3/4/2025)

IF NOT KEYWORD_SET(savegraphs) THEN savegraphs=0
IF NOT KEYWORD_SET(strategy) THEN strategy='flask'
IF NOT KEYWORD_SET(project) THEN project='ccg_surface'
IF KEYWORD_SET(evn) THEN BEGIN    ; can see where a particulart flask lands on a time series. 
	CCG_FLASK, evn=evn,x
	site=x.code
	plotevn=1
ENDIF ELSE BEGIN
	plotevn=0
ENDELSE

;strategy='pfp'
;;project='ccg_aircraft'


;these are data choices
data='db'   ;sitefile'
getdata=1  ; applies to anything that needs digging into data.
;if looking at pressures ...
skipdataplots=0  ; this goes right to pressure tests


makebigplot=1  ; a value of 0 allows you to skip to bias tests.
;------ You should choose just ONE of the following options
justgooddata=0     ;	; if you just want good data
refcheck=0		; if you want to plot by working standard
hardflags=1		; if you want to plot by flag. (not sure if regularplot should be 0 or 1)
softflags=0		; might want to just add this to hard flag code; not recently used.
inst=0			; could maybe merge this with refs - different symbols? 
plotpressures=0          ; this might require some troubleshooting

;---- and choose one or the other, or neither (but not both)
c13only=0
o18only=0


;these are plotting choices
onebyone=1
IF savegraphs EQ 1 THEN onebyone=0
yr1=1990
IF plotevn EQ 1 THEN yr1=FIX(x.date-1)
yr2=2024
justrecent=0
onlypd=0     ;hardflags has to be equal to 1, but then it'll only plot pair difference data
adderr=0
adate=0
plotresidsc=0  ; if you do this, only do c13 or o18.
fontsize=15
addsc=0      ; if you want to add smooth curve to data 
addtr=0         ; or trend to data

;------if ref check eq 1 then choose one of the options below

plotcorrection=0 ;have to have refcheck=1
;IF plotcorrection EQ 1 THEN yr1=2016    ; for simplicity ... refs are all two pt corrected by then. 
biascheck=0		; if you want to plot by difference from working standard
plotbyref=0



; now let the code do its thing.
date=[yr1,yr2]

IF c13only EQ 1 THEN ypixels=450 ELSE ypixels=900
xpixels=1400			

IF NOT KEYWORD_SET(site) THEN site='all'

spec=['co2c13','co2o18']
s=0
	IF project EQ 'ccg_surface' THEN BEGIN 
		IF strategy EQ 'flask' THEN initfile ='/home/ccg/michel/initfiles/init.co2c13.flask.2023' 
		IF strategy EQ 'pfp' THEN initfile='/home/ccg/michel/initfiles/init.co2c13.surface.pfp.2020'
	ENDIF ELSE BEGIN
		IF strategy EQ 'flask' THEN stop ; this isn't an option
		IF strategy EQ 'pfp' THEN initfile='/home/ccg/michel/initfiles/init.co2c13.aircraft.pfp.2020'
	ENDELSE
	
	CCG_READINIT,file=initfile,initparams
	nsites=N_ELEMENTS(initparams.desc)
	sites=initparams.desc.site_code
	sitelongnames=initparams.desc.site_name

IF site NE 'all' THEN BEGIN
	thissite=WHERE(sites EQ STRUPCASE(site))
	IF thissite[0] NE -1 THEN BEGIN
		sites=sites[thissite]
		sitelongnames=sitelongnames[thissite]
		nsites=1
		onebyone=0
		sitename=(initparams.desc(thissite).site_name)
	ENDIF ELSE BEGIN
		print,'site = '+site
		stop
		sites=strarr(1)
		sites[0]=site
		 sitelongnames=sitelongnames[0]
		nsites=1
		onebyone=0
		sitename=(initparams.desc.site_name)
	ENDELSE
ENDIF

;sites=['spo','mlo','smo','cgo','bhd','syo']
FOR i=0,nsites-1 DO BEGIN
	backone:
		print, 'Processing Number: ',i
		print,sites[i]
		bigsite = sites[i] + '  ' + spec[s]
		site=STRLOWCASE(sites[i])
		sitename=STRLOWCASE(sites[i])
		sitelongname=sitelongnames[i]
		IF STRLEN(sites[i]) GT 3 THEN goto, skipthisone
		;IF softflags EQ 1 THEN BEGIN
			;savefile='/home/ccg/michel/plots/siteplots/'+site+'.soft.co2c13.png'
		;ENDIF ELSE BEGIN
			savefile='/home/ccg/michel/plots/siteplots/'+site+'.qaqc.co2c13'
			;IF strategy EQ 'pfp' THEN savefile=savefile+'.pfp'
			;IF project EQ 'ccg_aircraft' THEN savefile=savefile+'.aircraft'
			
			;IF onlypd EQ 1 THEN savefile=savefile+'.pd'
			;savefile=savefile+'.png'
		;ENDELSE
		
		
		savefile='/home/ccg/michel/plots/siteplots/'+sites[i]+'.'+strategy
		IF spec[s] EQ 'c13' THEN axis=[-10,-6,.5,1] ELSE axis=[-5,3,.5,1]
	IF data EQ 'db' THEN BEGIN
		CCG_FLASK,site=site,date=date,sp='co2c13', $
		project=project,strategy=strategy,cdata
	ENDIF ELSE BEGIN
		stop
		savefile=savefile+'.sf'
		;sitefiledir='/home/ccg/sil/ch4c13/'+sitekey+'/'
		;sitefiledir='/home/ccg/michel/co2c13/sieg_deifiles/sieg_newsitefiles/' 
		sitefiledir='/home/ccg/michel/co2c13/instaar_archive/' 
		
		isitdei=STRPOS(sitefiledir,'dei')
		IF isitdei[0] NE -1 THEN itisdei=1 ELSE itisdei=0
		CCG_READ, file=sitefiledir+STRLOWCASE(site)+'.co2c13',skip=1,sitedat
			nlines=n_elements(sitedat)
		
		cdata=REPLICATE({code:'',$
			evn:'',$
			date:0.0,$
			adate:0.0,$
			value:0.0,$
			flag:'',$
			ref:'',$
			unc:0.0},nlines)

			cdata.code=sitedat.field1
			
			
			; this is from before 5/20/22
			;cdata.value=sitedat.field9
			;IF itisdei EQ 0 THEN cdata.flag=sitedat.field10 ELSE cdata.flag=sitedat.field11
			
			;cdata.unc=sitedat.field17
			;FOR z=0,nlines-1 DO BEGIN
			;	CCG_DATE2DEC,yr=sitedat[z].field2,mo=sitedat[z].field3,dy=sitedat[z].field4,hr=sitedat[z].field5,mn=sitedat[z].field6,dec=dec
			;	cdata[z].date=dec
			;	IF itisdei EQ 0 THEN BEGIN
			;		CCG_DATE2DEC,yr=sitedat[z].field12,mo=sitedat[z].field13,dy=sitedat[z].field14,hr=sitedat[z].field15,mn=sitedat[z].field16,dec=dec
			;		cdata[z].adate=dec
			;	ENDIF ELSE BEGIN
			;		CCG_DATE2DEC,yr=sitedat[z].field13,mo=sitedat[z].field14,dy=sitedat[z].field15,hr=sitedat[z].field16,mn=sitedat[z].field17,dec=dec
			;		cdata[z].adate=dec
			;	ENDELSE
			;ENDFOR
			
			;rewrote to work with INSTAAR archive
			
			cdata.value=sitedat.field9
			cdata.unc=sitedat.field10
			cdata.flag=sitedat.field11
			FOR z=0,nlines-1 DO BEGIN
				CCG_DATE2DEC,yr=sitedat[z].field2,mo=sitedat[z].field3,dy=sitedat[z].field4,hr=sitedat[z].field5,mn=sitedat[z].field6,dec=dec
				cdata[z].date=dec
				CCG_DATE2DEC,yr=sitedat[z].field13,mo=sitedat[z].field14,dy=sitedat[z].field15,hr=sitedat[z].field16,mn=sitedat[z].field17,dec=dec
					cdata[z].adate=dec
			ENDFOR
			getrefdata=0
			;do this later ....
			; check the 'biascheck' feature! I may have already done this! 
			;IF getrefdata EQ 1 THEN BEGIN
			;	enum=sitedat[z].evn,inst=sitedat[z].inst,ref=ref,runnum=runnum,pos=pos
			;	cdata[z].ref=ref	
			;ENDIF
			
			keep=WHERE(cdata.date GT yr1)
			cdata=cdata[keep]
			
			;IF getdata EQ 1 THEN BEGIN
			;	FOR z=0,nlines-1 DO BEGIN
			;	CCG_FLASK, site=cdata[z].code,id=sitedat[z].field8,date=cdata[z].date,findevn
			;	cdata[z].evn= STRTRIM(findevn[0].evn,2)
			
				;ENDFOR
			;ENDIF
	ENDELSE
	nc=N_ELEMENTS(cdata)

	IF n_elements(cdata) LE 1 THEN GOTO, skipthisone
	
	;IF hardflags EQ 0 THEN BEGIN
	;	keep=WHERE(STRMID(cdata.flag,0,1) NE '!',nkeep)   ; changed this, because now I want these data
	;	cdata=cdata[keep]
	;	
	;ENDIF
	cvalue=cdata.value
	IF adate EQ 1 THEN cdate=cdata.adate ELSE cdate=cdata.date

	IF justrecent EQ 1 THEN BEGIN
		lastdate=cdate[nc-1]
		IF lastdate LT 2019.5 THEN goto,skipthisone
	ENDIF
	
	
	cunc=cdata.unc
	
	dotflag=WHERE(STRMID(cdata.flag,0,2) EQ '..')
	
	IF hardflags EQ 1 THEN BEGIN
		exclflag=WHERE(STRMID(cdata.flag,0,1) EQ '!')
		aflag=WHERE(STRMID(cdata.flag,0,1) EQ 'A')
		pflag=WHERE(STRMID(cdata.flag,0,1) EQ 'P')
		plusflag=WHERE(STRMID(cdata.flag,0,1) EQ '+')
		minusflag=WHERE(STRMID(cdata.flag,0,1) EQ '-')
		lflag=WHERE(STRMID(cdata.flag,0,1) EQ 'L')
		hflag=WHERE(STRMID(cdata.flag,0,1) EQ 'H')
		tflag=WHERE(STRMID(cdata.flag,0,1) EQ 'T')
		nflag=WHERE(STRMID(cdata.flag,0,1) EQ 'N')
		cflag=WHERE(STRMID(cdata.flag,0,1) EQ 'C')
		bflag=WHERE(STRMID(cdata.flag,0,1) EQ 'B')
		littlenflag=WHERE(STRMID(cdata.flag,0,1) EQ 'n')   
	
		xflag=WHERE(STRMID(cdata.flag,0,2) EQ '.X')

	ENDIF 
	IF softflags EQ 1 THEN xflag=WHERE(STRMID(cdata.flag,0,2) EQ '.X')

	
	
			
		
	cmedval=MEDIAN(cvalue)
	chighval=MAX(cvalue[dotflag])
	clowval=MIN(cvalue[dotflag])
	;chighval=MAX(cvalue[notexcl])
	;clowval=MIN(cvalue[notexcl])
	
	
	;figure out yrange	
	;IF chighval-clowval GT 1 THEN BEGIN
		cymin=clowval-0.2  ;cmedval-0.4
		cymax=chighval+0.2 ;cmedval+0.4
		
	;ENDIF ELSE BEGIN
	;	cymin=cmedval-0.35
	;	cymax=cmedval+0.35
	;ENDELSE

	IF hardflags EQ 1 THEN BEGIN
		cymin=FIX(cmedval-2)
		cymax=FIX(cmedval+2) ; using fix because it's going to sci. notation on  
	
	ENDIF 
	
	
	
	; now get o18 data
	CCG_FLASK,site=site,date=date,sp='co2o18', $
	project=project,strategy=strategy,odata
	no=N_ELEMENTS(odata)
	;goodounc=WHERE(odata.unc GT 0)
	;odata=odata[goodounc]
	
	
	;
	;IF hardflags EQ 0 THEN BEGIN
	;	keep=WHERE(STRMID(odata.flag,0,1) NE '!',nkeep)
	;	odata=odata[keep]
	;ENDIF
	
	;nkeep=N_ELEMENTS(odata)
	ovalue=odata.value
	IF adate EQ 1 THEN odate=odata.adate ELSE odate=odata.date
	ounc=odata.unc
	
	odotflag=WHERE(STRMID(odata.flag,0,2) EQ '..')
	IF hardflags EQ 1 THEN BEGIN
		oplusflag=WHERE(STRMID(odata.flag,0,1) EQ '+')
		ominusflag=WHERE(STRMID(odata.flag,0,1) EQ '-')
		oexclflag=WHERE(STRMID(odata.flag,0,1) EQ '!')
		oaflag=WHERE(STRMID(odata.flag,0,1) EQ 'A')
		opflag=WHERE(STRMID(odata.flag,0,1) EQ 'P')
		olflag=WHERE(STRMID(odata.flag,0,1) EQ 'L')
		ohflag=WHERE(STRMID(odata.flag,0,1) EQ 'H')
		otflag=WHERE(STRMID(odata.flag,0,1) EQ 'T')
		onflag=WHERE(STRMID(odata.flag,0,1) EQ 'N')
		ocflag=WHERE(STRMID(odata.flag,0,1) EQ 'C')
		obflag=WHERE(STRMID(odata.flag,0,1) EQ 'B')
		oxflag=WHERE(STRMID(odata.flag,0,2) EQ '.X')
		olittlenflag=WHERE(STRMID(odata.flag,0,1) EQ 'n')
		owflag=WHERE(STRMID(odata.flag,0,1) EQ 'W')
	ENDIF 
	IF softflags EQ 1 THEN oxflag=WHERE(STRMID(odata.flag,0,2) EQ '.X')
			

	;figure out yrange
	omedval=MEDIAN(ovalue)
	ohighval=MAX(ovalue)
	olowval=MIN(ovalue)
	;IF ohighval-olowval GT 1 THEN BEGIN
		oymin=FIX(omedval-3)
		oymax=FIX(omedval+3) ; using fix because it's going to sci. notation on  
	;	;y labels
	;ENDIF ELSE BEGIN
	;	oymin=omedval-0.25
	;	oymax=omedval+0.25
	;ENDELSE

	IF hardflags EQ 1 THEN BEGIN
		oymin=FIX(omedval-6)
		oymax=FIX(omedval+3) ; using fix because it's going to sci. notation on  
	
	ENDIF 
	
	
	;oymin=-12
	;oymax=2
	IF strategy EQ 'pfp' THEN BEGIN
		oymin=FIX(omedval-8)
		oymax=FIX(omedval+4) ; using fix because it's going to sci. notation on
	ENDIF
	; this assumes that c13 and o18 have the same start date. That should be the case ...
		xmin=odate[0] 
		xmax=odate[no-1]

	
	; start plotting
		
	newcarr=['blue','green','lime green','red','purple','orange','medium blue','plum','medium turquoise',$
	'sky blue','magenta','plum','cadet blue','dark sea green','coral','firebrick','indigo','orange red','dodger blue','forest green','light steel blue','tomato']
	bigcarr=['green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue',$
					'light green','maroon','sky blue','plum','cadet blue','dark sea green','coral','firebrick','indigo','orange red',$
					'dodger blue','purple','forest green','light steel blue','tomato','hot pink',$
					'chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown',$
					'green','red','lime green','orange','medium blue','orchid','medium turquoise','medium violet red','midnight blue','black','purple',$
					'green','blue','brown','chocolate', 'dark slate blue','rosy brown', 'deep pink','aqua','blue','purple','rosy brown']
		
	;tarr=['.','+','-','!','A','P','L','H','T','W','N','n']
	tarr=['.','+','-','!','A','P','L','H','T','N','C','B','secX','n','W']
	noptions=N_ELEMENTS(tarr)
	ourxrange=[xmin,xmax+1]
	 params={linestyle:6, $
	 font_name: 'Helvetica',$
	 sym_filled: 0,$
	 thick:10, $
	 symbol:'circle', $
	 sym_thick:2,$
	 sym_size: 0.4,$   ;symsize,$
	 xrange:ourxrange,$
	font_size:22,$
	 ytickdir: 0}  ;points ticks out
	 IF skipdataplots EQ 1 THEN goto,skipthedata
	 IF makebigplot EQ 0 THEN goto,skipbigplot	
	 w=window(location=[100,100],dimensions=[xpixels,ypixels]) 
	IF c13only EQ 1 THEN ourposition = [0.12,0.15,0.87,0.9] ELSE ourposition=[0.1,0.52,0.88,0.9]
	IF c13only EQ 1 THEN ourshowtext=1 ELSE ourshowtext=0
	current=0
	dowehaveit=INTARR(noptions)
	
	IF o18only EQ 1 THEN GOTO,skipc13
	; this plot is just faint grey circles ....	
	IF adderr EQ 0 THEN BEGIN
		thisplot=PLOT(cdate,cvalue,$
		/current,$
		POSITION=ourposition,$     ;0.18,0.55,0.94,0.95
		YRANGE=[cymin,cymax],$
		YSTYLE=1,$
		YMINOR=2,$
		YTITLE='$\delta$$^{13}$C - CO$_2$ ($\permil$)',$
		;AXIS_STYLE=8,$
		dimensions=[xpixels,ypixels],$
		color= 'light grey',$
		sym_size=0.2,$
		font_name='Helvetica',$
		_extra=params,$
		XSHOWTEXT=ourshowtext)
	ENDIF ELSE BEGIN
		thisplot=ERRORPLOT(cdate,cvalue,cunc,$
		/current,$
		POSITION=ourposition,$     ;0.18,0.55,0.94,0.95
		YRANGE=[cymin,cymax],$
		YSTYLE=1,$
		YMINOR=2,$
		YTITLE='$\delta$$^{13}$C - CO$_2$ ($\permil$)',$
		;AXIS_STYLE=1,$
		dimensions=[xpixels,ypixels],$
		color= 'light grey',$
		sym_size=0.2,$
		font_name='Helvetica',$
		_extra=params,$
		XSHOWTEXT=ourshowtext)
	
	ENDELSE
	thisplot['axis2'].transparency=100
	thisplot['axis3'].transparency=100
		
	

	IF hardflags EQ 1 THEN BEGIN
		savefile=savefile+'.hf'
		; good data plotted here
		noinstplot=PLOT(cdate[dotflag],cvalue[dotflag],$
		symbol='circle', $
		 sym_size= 0.4,$  
		sym_filled=1,$
		linestyle=6,$
	        COLOR=newcarr[0],/overplot)  
		
		IF hardflags EQ 1 THEN BEGIN
		;******************************
		
		; this is an array of flag types, so that we only put flags that we have into legend.
		dowehaveit[0]=1  ; we have good data
		IF plusflag[0] NE -1 THEN BEGIN
			plusplot=PLOT(cdate[plusflag],cvalue[plusflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[1],$
			name='+')
			dowehaveit[1]=1
			IF onlypd EQ 1 ThEN plusplot.sym_filled=1
		ENDIF	
		IF minusflag[0] NE -1 THEN BEGIN
			minusplot=PLOT(cdate[minusflag],cvalue[minusflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[2],$
			name='-')
			dowehaveit[2]=1
			IF onlypd EQ 1 ThEN minusplot.sym_filled=1
		ENDIF	
		IF onlypd EQ 1 THEN goto,skipahead
		IF exclflag[0] NE -1 THEN BEGIN
			exclplot=PLOT(cdate[exclflag],cvalue[exclflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[3],$
			name='!')
			dowehaveit[3]=1  ; we have exclamation point flags
		ENDIF		
		
		IF aflag[0] NE -1 THEN BEGIN
			aplot=PLOT(cdate[aflag],cvalue[aflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[4],$
			name='A')
			dowehaveit[4]=1
		ENDIF	
		IF pflag[0] NE -1 THEN BEGIN
			pplot=PLOT(cdate[pflag],cvalue[pflag],$
		        _extra=params,$    
			/overplot,$
                	COLOR=newcarr[5],$
			name='P')
			dowehaveit[5]=1
		ENDIF	
		
		IF lflag[0] NE -1 THEN BEGIN
			lplot=PLOT(cdate[lflag],cvalue[lflag],$
			/overplot,$
	    	        _extra=params,$    
                	COLOR=newcarr[6],$
			name='L')
			dowehaveit[6]=1
		ENDIF	
		IF hflag[0] NE -1 THEN BEGIN
			hplot=PLOT(cdate[hflag],cvalue[hflag],$
			/overplot,$
	       		 _extra=params,$    
                	COLOR=newcarr[7],$
			name='H')
			dowehaveit[7]=1
		ENDIF	
		IF tflag[0] NE -1 THEN BEGIN
			tplot=PLOT(cdate[tflag],cvalue[tflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[8],$
			name='T')
			dowehaveit[8]=1
		ENDIF	
	
		IF nflag[0] NE -1 THEN BEGIN
			nplot=PLOT(cdate[nflag],cvalue[nflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[9],$
			name='N')
			dowehaveit[9]=1
		ENDIF	
		IF cflag[0] NE -1 THEN BEGIN
			nplot=PLOT(cdate[cflag],cvalue[cflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[10],$
			name='N')
			dowehaveit[10]=1
		ENDIF	
		IF bflag[0] NE -1 THEN BEGIN
			nplot=PLOT(cdate[bflag],cvalue[bflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[10],$
			name='B')
			dowehaveit[10]=1
		ENDIF	
		IF xflag[0] NE -1 THEN BEGIN
			nplot=PLOT(cdate[xflag],cvalue[xflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[11],$
			name='X')
			dowehaveit[11]=1
		ENDIF	
	
		IF littlenflag[0] NE -1 THEN BEGIN
			littlenplot=PLOT(cdate[littlenflag],cvalue[littlenflag],$
		       	/overplot,$
			 _extra=params,$    
                	COLOR=newcarr[12],$
			name='n')
			dowehaveit[12]=1
		ENDIF	
		
			
		
		skipahead:
		ENDIF                

	ENDIF 
	
	IF inst EQ 1 THEN BEGIN
	
		savefile=savefile+'.inst'
		dots=cdata[dotflag]
		dotdate=cdate[dotflag]  ;allows you to switch from date to adate.
		cdotvalue=cvalue[dotflag]
		;cdate[dotflag],cvalue[dotflag]
		;cdate[dotflag],cvalue[dotflag]
		o1=WHERE(dots.inst EQ 'o1',no1)
		i2=WHERE(dots.inst EQ 'i2',ni2)
		i6=WHERE(dots.inst EQ 'i6',ni6)
		IF o1[0] NE -1 THEN BEGIN
		o1plot=PLOT(dotdate[o1],cdotvalue[o1],$
			_extra=params,$
	     		   COLOR='crimson',/overplot) 
		ENDIF
		if i2[0] NE -1 THEN BEGIN
			i2plot=PLOT(dotdate[i2],cdotvalue[i2],$
			_extra=params,$
	       		 COLOR='green',/overplot) 
		ENDIF 	
		IF i6[0] NE -1 THEN BEGIN
			i6plot=PLOT(dotdate[i6],cdotvalue[i6],$
			_extra=params,$
	       		 COLOR='blue',/overplot) 
		ENDIF			
		
		

	ENDIF


	IF justgooddata EQ 1 THEN BEGIN
	
		savefile=savefile+'.good'
		gooddataplot=PLOT(cdate[dotflag],cvalue[dotflag],$
		symbol='circle', $
		 sym_size= 0.4,$  
		sym_filled=1,$
		linestyle=6,$
	        COLOR=newcarr[0],/overplot)  
	ENDIF	

	CCG_CCGVU,x=cdate[dotflag],y=cvalue[dotflag],cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly, $
	sc=sc,tr=tr,even=1,residsc=residsc
	; putting this yere so that residuals can be used
	IF addsc EQ 1 THEN BEGIN   ; or addtr
		
		;CCG_CCGVU,x=cdate[dotflag],y=cvalue[dotflag],cutoff1=init.cutoff1,cutoff2=init.cutoff2,nharm=init.nharm,npoly=init.npoly,sc=sc,tr=tr,even=1
		
		;CCG_CCGVU,x=ch4x,y=ch4y,cutoff1=180,cutoff2=667,nharm=init.nharm,npoly=init.npoly,sc=ch4sc,tr=ch4tr,even=1
		;CCG_CCGVU,x=isox,y=isoy,cutoff1=180,cutoff2=667,nharm=2,npoly=3,sc=isosc,tr=isotr,even=1
		IF addsc EQ 1 THEN scplot=PLOT(sc[0,*],sc[1,*],color='orange red',overplot=1,thick=3,linestyle=0)
		IF addtr EQ 1 THEN trplot=PLOT(tr[0,*],tr[1,*],color='orange',overplot=1,thick=3,linestyle=0)
	
	ENDIF
	
	
	IF plotevn EQ 1 THEN BEGIN
		CCG_FLASK,evn=evn,sp='co2c13',evndata
		sizevn=SIZE(evndata)
		IF sizevn[0] NE 0 THEN BEGIN
			nevn=N_ELEMENTS(evndata)
			IF nevn GE 2 THEN BEGIN
			datearr=evndata.adate
			valuearr=evndata.value
			ENDIF ELSE BEGIN
			datearr=[evndata[0].date,evndata[0].date]
			valuearr=[evndata[0].value,evndata[0].value]
			ENDELSE
			for i=0,nevn-1 do BEGIN 
				print,'evn = '+evndata[i].str
				print,'date = '+STRING(datearr[i]) 
				print,'value= '+STRING(valuearr[i])
			ENDFOR
			addevn=plot(datearr,valuearr,linestyle=6,symbol='X',sym_thick=3,color='orange',sym_size=2,sym_filled=1,/overplot)
			
		ENDIF
	ENDIF	
	txt=TEXT(0.11,0.93, STRUPCASE(site)+' : '+sitelongname,font_size=24,/current) 
	skipbigplot:
	
	; this is where you check on what the reference was - can plot by which ref, or the distance between sample and ref.
	IF refcheck EQ 1 THEN BEGIN
	
		diffcolor=BYTARR(nc)
		IF s EQ 0 THEN sp='co2c13' ELSE sp='co2o18'
		difffile='/home/ccg/michel/co2c13/difffiles/'+site+'.refdiffs.co2c13.sav'
	
		reffile='/home/ccg/michel/co2c13/difffiles/'+site+'.refs.co2c13.sav'
	
		CCG_READ,file='/projects/co2c13/flask/sb/ref.sieg.co2c13',refs
		nrefs=N_ELEMENTS(refs)	
		
		;; new, faster way to do this
		CCG_READ,file='/home/ccg/michel/refgas/ref.sieg.data',skip=1,refcodes
		;exclude DEWY
		keep=WHERE(refcodes.field1 NE 'DEWY-001',nrefcodes)
		refcodes=refcodes[keep]
		;stop
		i2refs=WHERE(refcodes.field2 EQ 'i2')		
		i4refs=WHERE(refcodes.field2 EQ 'i4')		
		i6refs=WHERE(refcodes.field2 EQ 'i6')		
		r1refs=WHERE(refcodes.field2 EQ 'r1')		
		o1refs=WHERE(refcodes.field2 EQ 'o1')	
		slowmethod=0
		
		IF slowmethod EQ 1 THEN BEGIN
			IF getdata EQ 1 THEN BEGIN
				refarr=STRARR(nc)
			
				refvalarr=FLTARR(nc)
				diffarr=FLTARR(nc)
				
				
				FOR j=0,nc-1 DO BEGIN
				co2c13_runnum, enum=cdata[j].evn,inst=cdata[j].inst,ref=ref,runnum=runnum,pos=pos
				
				
				;find where cdata.adate is among instruments
				
					IF ref EQ 'unk' THEN BEGIN
						refvalarr[j]=0
					
					ENDIF ELSE BEGIN
						refarr[j]=ref
						findit=WHERE(refs.field1 EQ ref)
						refvalarr[j]=refs[findit].field12
					ENDELSE
		
				ENDFOR
		
		
				diffarr=cdata.value-refvalarr
				SAVE, refarr, filename=reffile
				SAVE, diffarr, filename=difffile
		
			ENDIF ELSE BEGIN
				RESTORE, filename=difffile
				RESTORE, filename=reffile
	
			ENDELSE
		ENDIF ELSE BEGIN
			IF getdata EQ 1 THEN BEGIN
				refarr=STRARR(nc)
			
				refvalarr=FLTARR(nc)
				diffarr=FLTARR(nc)
				
				
				FOR j=0,nc-1 DO BEGIN
				
					these=WHERE(refcodes.field2 EQ cdata[j].inst,nthese)
					FOR k=0,nthese-1 DO BEGIN
						IF cdata[j].adate GT refcodes[these[k]].field9 AND cdata[j].adate LE refcodes[these[k]].field10 THEN BEGIN
							;found your match
							refarr[j]=refcodes[these[k]].field1
							refvalarr[j]=refcodes[these[k]].field13
							
						ENDIF 
					
					ENDFOR					
						
					IF refvalarr[j] EQ 0 THEN BEGIN
						print,'not finding ref'
						STOp
					ENDIF
				ENDFOR
	
				
				diffarr=cdata.value-refvalarr
				SAVE, refarr, filename=reffile
				SAVE, diffarr, filename=difffile
		
			ENDIF ELSE BEGIN
				RESTORE, filename=difffile
				RESTORE, filename=reffile
	
			ENDELSE
		
		ENDELSE	

		
		
		
		IF plotcorrection EQ 1 THEN BEGIN
			m=-0.005
			correction=FLTARR(nc)
			correctedval=FLTARR(nc)
			
			
			for c=0,nc-1 DO BEGIN
				correction[c]=diffarr[c]*m
				correctedval[c]=cdata[c].value-correction[c]
				
			ENDFOR		
			IF makebigplot EQ 1 THEN BEGIN
				;this=PLOT(cdata[dotflag].date,cdata[dotflag].value,/overplot,color='green',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6)
			
				this=PLOT(cdata[dotflag].date,correctedval[dotflag],/overplot,color='green',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6)
			ENDIF
			;that=PLOT(cdata[dotflag].date,correction[dotflag],color='green',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6,dimensions=[800,400],yrange=[-0.1,0.1])
			
		ENDIF
	
		rangemin=-1.0D
		rangemax=1.0D ;0.50D
		
		IF biascheck EQ 1 THEN BEGIN
			scalestretch=255.0/(rangemax-rangemin)   ;slope
			intercept=255.0-(scalestretch*rangemax)
			IF makebigplot EQ 1 THEN BEGIN
				FOR k=0,nc-1 DO diffcolor[k]=(diffarr[k]*scalestretch)-intercept	     
		
				thisplotcol=PLOT(cdata[dotflag].date,cdata[dotflag].value,/overplot,rgb=13,sym_filled=1,vert_color=diffcolor[dotflag],sym_size=0.5,symbol='circle',linestyle=6)
		
				c=COLORBAR(target=thisplot,orientation=1,rgb_table=13,position=[0.95,0.08,0.98,0.94],title='difference from WS, ($\permil$)',range=[rangemin,rangemax])
				c.font_size=16
				c.tickdir=1
				c.textpos=0
				savefile=savefile+'.biascheck'
			ENDIF
		ENDIF	
		IF plotbyref EQ 1 THEN BEGIN
			IF makebigplot EQ 1 THEN BEGIN
			savefile=savefile+'.byref'
				
			w=0
			IF c13only THEN spacer=0.036 ELSE spacer=0.028
			IF o18only THEN spacer=0.036
			
			FOR n=0,nrefs-1 DO BEGIN
				
				thisref=WHERE(refarr EQ refs[n].field1)
			
				IF thisref[0] NE -1 THEN BEGIN
					cdataref=cdata[thisref]
					unflagged=WHERE(STRMID(cdataref.flag,0,2) EQ '..',nunflagged)
					IF nunflagged[0] GE 2 THEN BEGIN
						
						thisplotref=PLOT(cdataref[unflagged].date,cdataref[unflagged].value,sym_filled=1,sym_size=0.5,symbol='circle',/overplot,color=bigcarr[n],linestyle=6)
						refnametext=TEXT(0.9,0.8-(spacer*w),refs[n].field1,font_size=fontsize,color=bigcarr[n])
						w=w+1
					ENDIF
					
				ENDIF
			
			ENDFOR
			ENDIF
	
		ENDIF	
		
		IF makebigplot EQ 1 THEN BEGIN
		IF plotresidsc EQ 1 THEN BEGIN
			c13only=1    ;this will be plotted in the o18 spot
			oplot=PLOT(odate,ovalue,$
			POSITION=[0.1,0.1,0.88,0.48],$
			yrange=[oymin,oymax],$
			YTITLE='residual of smooth curve ($\permil$)',$
			color='light grey',$
			_extra=params,$
			font_name='Helvetica',$
			sym_size=0.2,$
			current=1)
	
		
			FOR n=0,nrefs-1 DO BEGIN
				thisref=WHERE(refarr EQ refs[n].field1)
				IF thisref[0] NE -1 THEN BEGIN
					cdataref=cdata[thisref]
					unflagged=WHERE(STRMID(cdataref.flag,0,2) EQ '..')
					IF unflagged[0] NE -1 THEN BEGIN
						thisplotref=PLOT(residsc[unflagged].field1,residsc[unflagged].field2,sym_filled=1,sym_size=0.7,symbol='circle',/overplot,color=bigcarr[n],linestyle=6)
						; could add legend if o18 only
						
					ENDIF
								
				ENDIF
			ENDFOR
			stop
		
		ENDIF
		ENDIF
		
	
	ENDIF






	current=1
	skipc13:
	IF makebigplot EQ 1 THEN BEGIN
	IF c13only EQ 1 THEN goto,skipoxygen
	IF o18only EQ 1 THEN BEGIN
		o18pos=[0.1,0.1,0.88,0.88]
	ENDIF ELSE BEGIN
		o18pos=[0.1,0.1,0.88,0.48]
	ENDELSE   
	oplot=PLOT(odate,ovalue,$
		POSITION=o18pos,$
		yrange=[oymin,oymax],$
		YTITLE='$\delta$$^{18}$O - CO$_2$ ($\permil$)',$
		color='light grey',$
		_extra=params,$
		font_name='Helvetica',$
		sym_size=0.2,$
		current=1)
	
	oplot['axis2'].transparency=100
	oplot['axis3'].transparency=100
				
	IF hardflags EQ 1 THEN BEGIN
		odata=PLOT(odate[odotflag],ovalue[odotflag],$
			symbol='circle', $
			 sym_size=0.4,$  
			color=newcarr[0],$
			sym_filled=1,$
			linestyle=6,$
	        
			/overplot,$
			name='INSTAAR')
	
		;******************************
		IF oplusflag[0] NE -1 THEN BEGIN
			oplusplot=PLOT(odate[oplusflag],ovalue[oplusflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[1],$
			name='+')
			dowehaveit[1]=1
			IF onlypd EQ 1 THEN oplusplot.sym_filled=1
		ENDIF	
		IF ominusflag[0] NE -1 THEN BEGIN
			ominusplot=PLOT(odate[ominusflag],ovalue[ominusflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[2],$
			name='-')
			dowehaveit[2]=1
			IF onlypd EQ 1 THEN ominusplot.sym_filled=1
		ENDIF	
		IF onlypd EQ 1 THEN goto,skipoxyflags
		IF oexclflag[0] NE -1 THEN BEGIN
			oexclplot=PLOT(odate[oexclflag],ovalue[oexclflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[3],$
			name='!')
			dowehaveit[3]=1
		ENDIF		
		IF oaflag[0] NE -1 THEN BEGIN
			oaplot=PLOT(odate[oaflag],ovalue[oaflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[4],$
			name='A')
			dowehaveit[4]=1
		ENDIF	
		IF opflag[0] NE -1 THEN BEGIN
			opplot=PLOT(odate[opflag],ovalue[opflag],$
		        _extra=params,$    
			/overplot,$
                	COLOR=newcarr[5],$
			name='P')
			dowehaveit[5]=1
		ENDIF	

		IF olflag[0] NE -1 THEN BEGIN
			olplot=PLOT(odate[olflag],ovalue[olflag],$
			/overplot,$
	    	        _extra=params,$    
                	COLOR=newcarr[6],$
			name='L')
			dowehaveit[6]=1
		ENDIF	
		
		IF ohflag[0] NE -1 THEN BEGIN
			ohplot=PLOT(odate[ohflag],ovalue[ohflag],$
			/overplot,$
	       		 _extra=params,$    
                	COLOR=newcarr[7],$
			name='H')
			dowehaveit[7]=1
		ENDIF	
		IF otflag[0] NE -1 THEN BEGIN
			otplot=PLOT(odate[otflag],ovalue[otflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[8],$
			name='T')
			dowehaveit[8]=1
		ENDIF	
	
		IF onflag[0] NE -1 THEN BEGIN
			onplot=PLOT(odate[onflag],ovalue[onflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[9],$
			name='N')
			dowehaveit[9]=1
		ENDIF	

		IF ocflag[0] NE -1 THEN BEGIN
			onplot=PLOT(odate[ocflag],ovalue[ocflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[10],$
			name='C')
			dowehaveit[10]=1
		ENDIF	
		IF obflag[0] NE -1 THEN BEGIN
			obplot=PLOT(odate[obflag],ovalue[obflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[11],$
			name='B')
			dowehaveit[11]=1
		ENDIF	
		IF oxflag[0] NE -1 THEN BEGIN
			oxplot=PLOT(odate[oxflag],ovalue[oxflag],$
			/overplot,$
		        _extra=params,$    
                	COLOR=newcarr[12],$
			name='X')
			dowehaveit[12]=1
		ENDIF		
	
		IF olittlenflag[0] NE -1 THEN BEGIN
			olittlenplot=PLOT(odate[olittlenflag],ovalue[olittlenflag],$
		       	/overplot,$
			 _extra=params,$    
                	COLOR=newcarr[13],$
			name='n')
			dowehaveit[13]=1
		ENDIF	
		IF owflag[0] NE -1 THEN BEGIN
			olittlenplot=PLOT(odate[owflag],ovalue[owflag],$
		       	/overplot,$
			 _extra=params,$    
                	COLOR=newcarr[14],$
			name='W')
			dowehaveit[14]=1
		ENDIF	
	
		skipoxyflags:
			
			
	ENDIF
	
	IF inst EQ 1 THEN BEGIN
	
		odots=odata[odotflag]
		odotdate=odate[odotflag]  ;allows you to switch from date to adate.
		odotvalue=ovalue[odotflag]
		o1=WHERE(odots.inst EQ 'o1',no1)
		i2=WHERE(odots.inst EQ 'i2',ni2)
		i6=WHERE(odots.inst EQ 'i6',ni6)
		IF o1[0] NE -1 THEN BEGIN
			o1oplot=PLOT(odotdate[o1],odotvalue[o1],$
			_extra=params,$
	     		   COLOR='crimson',/overplot,name='o1') 
		ENDIF
		IF i2[0] NE -1 THEN BEGIN
			oi2plot=PLOT(odotdate[i2],odotvalue[i2],$
			_extra=params,$
		       	 COLOR='green',/overplot,name='i2') 
		ENDIF 	
		oi6plot=PLOT(odotdate[i6],odotvalue[i6],$
			_extra=params,$
	       		 COLOR='blue',/overplot,name='i6') 
	
	ENDIF
	
	IF justgooddata EQ 1 THEN BEGIN
		odata=PLOT(odate[odotflag],ovalue[odotflag],$
			symbol='circle', $
			 sym_size=0.4,$  
			color=newcarr[0],$
			sym_filled=1,$
			linestyle=6,$
	        
			/overplot,$
			name='INSTAAR')
	ENDIF
	
	CCG_CCGVU,x=odate[odotflag],y=ovalue[odotflag],cutoff1=initparams.init[i].cutoff1,cutoff2=initparams.init[i].cutoff2,nharm=initparams.init[i].nharm,npoly=initparams.init[i].npoly,$
		residsc=residsc,sc=sc,tr=tr,even=0
	
	IF addsc EQ 1 THEN BEGIN   ; or addtr
		
		;CCG_CCGVU,x=cdate[dotflag],y=cvalue[dotflag],cutoff1=init.cutoff1,cutoff2=init.cutoff2,nharm=init.nharm,npoly=init.npoly,sc=sc,tr=tr,even=1
	
		;CCG_CCGVU,x=ch4x,y=ch4y,cutoff1=180,cutoff2=667,nharm=init.nharm,npoly=init.npoly,sc=ch4sc,tr=ch4tr,even=1
		;CCG_CCGVU,x=isox,y=isoy,cutoff1=180,cutoff2=667,nharm=2,npoly=3,sc=isosc,tr=isotr,even=1
		IF addsc EQ 1 THEN scplot=PLOT(osc[0,*],osc[1,*],color='orange red',overplot=1,thick=3,linestyle=0)
		IF addtr EQ 1 THEN trplot=PLOT(otr[0,*],otr[1,*],color='orange',overplot=1,thick=3,linestyle=0)
		
	ENDIF
	
	
	IF plotevn EQ 1 THEN BEGIN
		CCG_FLASK,evn=evn,sp='co2o18',evndata
		sizevn=SIZE(evndata)
		IF sizevn[0] NE 0 THEN BEGIN
			nevn=N_ELEMENTS(evndata)
			IF nevn GE 2 THEN BEGIN
			datearr=evndata.adate
			valuearr=evndata.value
			ENDIF ELSE BEGIN
			datearr=[evndata[0].date,evndata[0].date]
			valuearr=[evndata[0].value,evndata[0].value]
		
			ENDELSE
			for i=0,nevn-1 do BEGIN 
				print,'evn = '+evndata[i].str
				print,'date = '+STRING(datearr[i]) 
				print,'value= '+STRING(valuearr[i])
			ENDFOR
			addevn=plot(datearr,valuearr,linestyle=6,symbol='X',sym_thick=3,color='orange',sym_size=2,sym_filled=1,/overplot)
		ENDIF
		
	ENDIF
	
	ENDIF
	
	; this is where you check on what the reference was - can plot by which ref, or the distance between sample and ref.
	IF refcheck EQ 1 THEN BEGIN
	
		diffcolor=BYTARR(no)
		odifffile='/home/ccg/michel/co2c13/difffiles/'+site+'.refdiffs.co2o18.sav'
	
		oreffile='/home/ccg/michel/co2c13/difffiles/'+site+'.refs.co2o18.sav'
	
		CCG_READ,file='/projects/co2c13/flask/sb/ref.sieg.co2c13',refs
		nrefs=N_ELEMENTS(refs)
		IF slowmethod EQ 1 THEN BEGIN
			IF getdata EQ 1 THEN BEGIN
				orefarr=STRARR(no)
			
				orefvalarr=FLTARR(no)
				odiffarr=FLTARR(no)
				FOR j=0,no-1 DO BEGIN
					co2c13_runnum, enum=odata[j].evn,inst=odata[j].inst,ref=ref,runnum=runnum,pos=pos
					IF ref EQ 'unk' THEN BEGIN
						orefvalarr[j]=0
					
					ENDIF ELSE BEGIN
						refarr[j]=ref
						findit=WHERE(refs.field1 EQ ref)
						orefvalarr[j]=refs[findit].field12
					ENDELSE
			
				ENDFOR
		
			
				odiffarr=odata.value-orefvalarr
				SAVE, orefarr, filename=oreffile
				SAVE, odiffarr, filename=odifffile
			
			ENDIF ELSE BEGIN
				RESTORE, filename=odifffile
				RESTORE, filename=oreffile
	
			ENDELSE
		ENDIF ELSE BEGIN
		
		
			IF getdata EQ 1 THEN BEGIN
				orefarr=STRARR(no)
			
				orefvalarr=FLTARR(no)
				odiffarr=FLTARR(no)
				
				
				FOR j=0,no-1 DO BEGIN
					these=WHERE(refcodes.field2 EQ odata[j].inst,nthese)
					FOR k=0,nthese-1 DO BEGIN
						;IF odata[j].adate GT refcodes[these[k]].field9 AND odata[j].adate LE refcodes[these[k]].field10 THEN BEGIN
						IF odata[j].adate GT refcodes[these[k]].field9 THEN BEGIN
							;found your match
							orefarr[j]=refcodes[these[k]].field1
							orefvalarr[j]=refcodes[these[k]].field15
							
						ENDIF 
					
					ENDFOR					
					
				;	
				;IF refvalarr[j] EQ 0 THEN STOp
				ENDFOR
	
				
				odiffarr=odata.value-orefvalarr
				SAVE, orefarr, filename=oreffile
				SAVE, odiffarr, filename=odifffiles
			ENDIF ELSE BEGIN
				RESTORE, filename=odifffile
				RESTORE, filename=oreffile
	
			ENDELSE
	
		ENDELSE	
		IF plotcorrection EQ 1 THEN BEGIN
			om=-0.012
			ocorrection=FLTARR(no)
			ocorrectedval=FLTARR(no)
			
			
			for o=0,no-1 DO BEGIN
				ocorrection[o]=odiffarr[o]*om
				ocorrectedval[o]=odata[o].value-ocorrection[o]
				
			ENDFOR		
			IF makebigplot EQ 1 THEN BEGIN
			this=PLOT(odata[odotflag].date,odata[odotflag].value,/overplot,color='green',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6)
			
			this=PLOT(odata[odotflag].date,ocorrectedval[odotflag],/overplot,color='green',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6)
			ENDIF 
			
			;;now plot separately, c on top, o on bottom
			fontsize=16
			
			thata=PLOT(cdata[dotflag].date,correction[dotflag],color='green',symbol='circle',sym_filled=1,sym_size=0.5,linestyle=6,dimensions=[1200,800],position=[0.12,0.5,0.92,0.9],xrange=[yr1,yr2+2],$
			yrange=[-0.02,0.02],xshowtext=0,ytitle='potential bias in $\delta$$^{13}$C$_{CO2}$ ($\permil$)',font_size=fontsize)
			print, 'mean c correction =',mean(correction[dotflag])
			
			;;;;;options, either diffarr
			;NOW a plot of diffarr on a separate axis. 
			plotdiff=0
			plotws=1
			
			IF plotdiff EQ 1 THEN ourcytitle='sample - WS, $\delta$$^{13}$C$_{CO2}$ ($\permil$)' ELSE ourcytitle='WS, $\delta$$^{13}$C$_{CO2}$ ($\permil$)'
			IF plotdiff EQ 1 THEN whattoplot=diffarr[dotflag] ELSE whattoplot=refvalarr[dotflag]
			IF plotdiff EQ 1 THEN thisyrange=[-2,2] ELSE thisyrange=[-9,-7.2]
			thatb=PLOT(cdata[dotflag].date,whattoplot,color='blue',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6,position=[0.12,0.5,0.92,0.9],xrange=[yr1,yr2+2],$
			yrange=thisyrange,xshowtext=0,ytitle=' ',/current,axis_style=4)
			stop
			;yaxis = AXIS('right', $
			;title=ourcytitle,$
			
			;LOCATION=max(thatb.xrange)) 
			 ; $
			;textpos=1,$
			;ticklen=0,$
			;tickfont_size=fontsize,$
			;AXIS_RANGE=thisyrange)
			
			;----
			yaxis = AXIS('Y')
			;, target=thatb, LOCATION=[max(thatb.xrange),0,0], $
			;color='blue',$ 
			;textpos=1,$
			;tickfont_size=fontsize,$
			;AXIS_RANGE=thisyrange)
			;----		
				
			;title=ourcytitle, textpos=1,tickdir=1, , AXIS_RANGE=[-2.0,2.0]
			;now oxygen
			thatc=PLOT(odata[odotflag].date,ocorrection[odotflag],color='green',symbol='circle',sym_filled=1,sym_size=0.5,linestyle=6,yrange=[-0.1,0.1],/current,position=[0.12,0.1,0.92,0.5],xtitle='date',$
			xrange=[yr1,yr2+2],ytitle='potential bias in $\delta$$^{18}$O$_{CO2}$ ($\permil$)',font_size=fontsize)
			
			ouroytitle='sample - WS, $\delta$$^{18}$O$_{CO2}$ ($\permil$)'
			
			IF plotdiff EQ 1 THEN ouroytitle='sample - WS, $\delta$$^{18}$O$_{CO2}$ ($\permil$)' ELSE ouroytitle='WS, $\delta$$^{18$O$_{CO2}$ ($\permil$)'
			IF plotdiff EQ 1 THEN whattoplot=odiffarr[odotflag] ELSE whattoplot=orefvalarr[odotflag]
			IF plotdiff EQ 1 THEN thisyrange=[-5,5] ELSE thisyrange=[-7,1]
			
			thatd=PLOT(odata[odotflag].date,whattoplot,color='blue',symbol='circle',sym_filled=0,sym_size=0.5,linestyle=6,position=[0.12,0.1,0.92,0.5],xrange=[yr1,yr2+2],$
			yrange=[-5.0,5.0],xshowtext=0,ytitle='',/current,axis_style=4)
			;yaxis = AXIS('Y', target=thatd, LOCATION=[max(thatd.xrange),0,0], $
			;textpos=1,$
			;title=ouroytitle,$
			;tickfont_size=fontsize,$
			;AXIS_RANGE=thisyrange)
			print, 'mean o correction =',mean(ocorrection[odotflag])
			
			stop
		ENDIF
		

		IF s EQ 0 THEN BEGIN
			rangemin=-1.0D
			rangemax=1.0D ;0.50D
		ENDIF ELSE BEGIN
			rangemin=-6.0D
			rangemax=6.0D
	
		ENDELSE
		
		IF biascheck EQ 1 THEN BEGIN
			scalestretch=255.0/(rangemax-rangemin)   ;slope
			intercept=255.0-(scalestretch*rangemax)
		
			FOR k=0,no-1 DO diffcolor[k]=(diffarr[k]*scalestretch)-intercept	     
		
			thisplotcol=PLOT(odata[odotflag].date,odata[odotflag].value,/overplot,rgb=13,sym_filled=1,vert_color=diffcolor[odotflag],sym_size=0.7,symbol='circle',linestyle=6)
		
			;if plots need different color bars then maybe keep this in.		
			IF o18only EQ 1 THEN BEGIN
				c=COLORBAR(target=thisplot,orientation=1,rgb_table=13,position=[0.95,0.08,0.98,0.94],title='difference from WS, ($\permil$)',range=[rangemin,rangemax])
				c.font_size=16
				c.tickdir=1
				c.textpos=0
			ENDIF
		ENDIF
		IF plotbyref EQ 1 THEN BEGIN
				
			;thisplotcol=PLOT(cdata[dotflag].date,cdata[dotflag].value,sym_filled=0,sym_size=0.7,symbol='circle',linestyle=6)
		
			FOR n=0,nrefs-1 DO BEGIN
				thisref=WHERE(refarr EQ refs[n].field1)
				IF thisref[0] NE -1 THEN BEGIN
					odataref=odata[thisref]
					unflagged=WHERE(STRMID(odataref.flag,0,2) EQ '..',nunflagged)
					IF nunflagged GE 2 THEN thisplotref=PLOT(odataref[unflagged].date,odataref[unflagged].value,sym_filled=1,sym_size=0.7,symbol='circle',/overplot,color=bigcarr[n],linestyle=6)
				
				ENDIF
			ENDFOR
			
		ENDIF
	
	ENDIF



	
	
	
	
	skipoxygen:
	IF inst EQ 1 THEN BEGIN
	 	IF i2[0] NE -1 THEN $
		
		leg=LEGEND(target=[o1oplot,oi2plot,oi6plot],position=[0.96,0.8],shadow=0,sample_width=0, $
			vertical_spacing=0.06, linestyle=6,font_size=15) $
			ELSE leg=LEGEND(target=[o1oplot,oi6plot],position=[0.96,0.8],shadow=0,sample_width=0, $
			vertical_spacing=0.06, linestyle=6,font_size=15) 
	ENDIF
	
	;; we should make an array of which are in use. Or, print (ie refstats2) as we go
	IF hardflags EQ 1 THEN BEGIN
		;review:	tarr=['.','+','-','!','A','P','L','H','T','N','C','B','n','W']
			
				

		thistarr=['good','flask pair +','flask pair -','hand flagged', 'bad refs','poor precision','trap too low','trap too high','trap too noisy',$
		'collection flag N','collection flag C', 'collection flag B','X flag','little n','W sampling flag']

		nflags=N_ELEMENTS(thistarr)
	;	IF o18only EQ 0 THEN BEGIN
		
			addleg=WHERE(dowehaveit EQ 1,nflags)
			thistarr=thistarr[addleg]
			newcarr=newcarr[addleg]
	;	ENDIF 

		FOR l=0,nflags-1 DO BEGIN
			whichisit=TEXT(0.87,(0.80-(0.04*l)),thistarr[l],font_size=16,color=newcarr[l],/current)
		ENDFOR
	ENDIF
	
;****



	IF savegraphs EQ 1 THEN BEGIN
	
		IF c13only EQ 1 THEN savefile=savefile+'.c13' 
		savefile=savefile+'.png'
		print,savefile
		thisplot.save,savefile
		thisplot.close
	ENDIF

	;FOR q=0,nc-1 DO BEGIN
	;	print, cdata[q].date,'  ',cdata[q].meth
	;	q=q+10
	;ENDFOR
	IF onebyone EQ 1 THEN BEGIN 
   		 result=DIALOG_MESSAGE ('Next Plot?', title = 'Continue',/Question, /cancel)
			IF result EQ 'Cancel' THEN goto,bailout
			IF result EQ 'No' THEN BEGIN
				i=i-1
			ENDIF
	ENDIF


	
skipthedata:
;****
IF plotpressures EQ 1 THEN BEGIN
	savename='/home/ccg/michel/co2c13/pressures/plot_sitedata_pressures_recent.'+site+'.sav'
	

	IF site EQ 'cob' then GOTO, skipthissite
	IF site EQ 'ftl' then GOTO, skipthissite
	IF site EQ 'hfm' then GOTO, skipthissite
	IF site EQ 's2k' then GOTO, skipthissite
	IF site EQ 'san' then GOTO, skipthissite
				
	IF getdata EQ 1 THEN BEGIN
	
		pressures=FLTARR(4,nc)
		
		FOR p=0,nc-1 DO BEGIN
		print,'p= ',p
			co2c13_pressure,enum=cdata[p].evn,pressure=pressure,sambeam=sambeam,sampress=sampress
			pressures[0,p]=cdata[p].evn
			pressures[1,p]=pressure[0]   ; in case of mutliple values I just take the first.
			pressures[2,p]=sampress[0] 
			pressures[3,p]=sambeam[0] 
		
		ENDFOR
		
		SAVE,pressures,filename=savename
		
	ENDIF ELSE BEGIN
		RESTORE,filename=savename
		
		
	ENDELSE

	pdata=WHERE(cdata.meth EQ 'P')
	sdata=WHERE(cdata.meth EQ 'S')
	gdata=WHERE(cdata.meth EQ 'G')
	ddata=WHERE(cdata.meth EQ 'D')
	idata=WHERE(cdata.meth EQ 'I')
	rdata=WHERE(cdata.meth EQ 'R')
	ndata=WHERE(cdata.meth EQ 'N')
	

	
	
		pressovertime=PLOT(cdate,pressures[1,*],$
			DIMENSIONS=[1200,900],$	
		
			POSITION=[0.14,0.62,0.86,0.9],$  
			symbol='circle',$
			sym_filled=0,$		
			YRANGE=[0,20],$
			color='red',$
			sym_size= 0.4,_extra=params,$
			YTITLE='air pressure')
			pressovertime['axis0'].showtext=0
	
		; sometimes air pressure is same as sample pressure. Delete these..
			keep= WHERE(pressures[2,*] NE pressures[1,*])
		;IF keep[0] NE -1 THEN samyield=PLOT(cdate[keep],pressures[2,keep],/current,$
			samyield=PLOT(cdate,pressures[2,*],/current,$
			POSITION=[0.14,0.34,0.86,0.62],$  
			symbol='circle',$
			sym_filled=0,$		
			YRANGE=[0,20],$
			color='red',$
			sym_size= 0.4,_extra=params,$
			YTITLE='sam pressure (mbar)')
		samyield['axis0'].showtext=0
		sambeam=PLOT(cdate,pressures[3,*],/current,$
			POSITION=[0.14,0.06,0.86,0.34],$  
			symbol='circle',$
			sym_filled=0,$		
			YRANGE=[0,7],$
			color='red',$
			sym_size= 0.4,_extra=params,$
			YTITLE='beam (nA)')
		
		
		label =TEXT(0.1,0.93,STRUPCASE(site),/current,font_size=24)
		
		
		;print the data
		newfile='/home/ccg/michel/co2c13/pressures/'+site+'_'+strategy+'_'+project+'.txt'
		;yr=INTARR(nkeep)
		siteformat='(A10,1x,I5,I3,I3,1x,F11.5,1x,F8.3,1x,F8.3,F8.3)'
		header = 'eventnum adate ayr amo ady'
		ccg_dec2date,cdate,yr,mo,dy
		OPENW, u,newfile, /GET_LUN
		PRINTF,u,header
		FOR k=0,nc-1 DO PRINTF,u,format=siteformat,  $
		pressures[0,k],	$
		yr[k],mo[k],dy[k],$
		cdate[k],$
		pressures[1,k],	$
		pressures[2,k],	$
		pressures[3,k]

	FREE_LUN,u


		skipthissite:
		
ENDIF	
	
	






skipthisone:


		 
ENDFOR

bailout:
END
