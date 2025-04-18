;+
; NAME:
;	CCG_FLASKAVE_OLD
;
; PURPOSE:
;	Calculate retained, rejected, and 
;	non-background CCG flask averages.
;	If flasks have the same year, month, 
;	day, time, and flag type, i.e., ret, rej,
;	or nb then average.
;
; 	Read a species-dependent CCG flask site file.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_FLASKAVE_OLD,sp='o18',site='asc',xret,yret,xnb,ynb,xrej,yrej
;	CCG_FLASKAVE_OLD,sp='co2',site='brw',xret,yret,xnb,ynb,xrej,yrej
;	CCG_FLASKAVE_OLD,sp='co2',file='test',nomessages=1,xret,yret,xnb,ynb,xrej,yrej
;
; INPUTS:
;	sp:	   	The species must be specified as 
;		  	follows.
;
;			sp='co2'
;		   	sp='ch4'
;		   	sp='co'
;		   	sp='h2'
;		   	sp='c13'
;		   	sp='o18'
;		   	sp='sf6'
;		   	sp='n2o'
;
;
;	site:	   	3-letter site code specified as
;		   	follows.
;
;		   	site='brw'
;		   	site='asc'
;
; OPTIONAL INPUT PARAMETERS:
;	header:		If set to 1 then calculate averages
;			only to select date specified in header.
;			If set to 0 then calculate averages
;			through latest analyzed sample.
;			Does not apply to site files with no
;			header information.  
;
;	file:		A file name may be passed instead of
;			a site parameter.  This may be useful
;			if a special site file must be manipulated.
;
;	nomessages:     If non-zero, messages will be suppressed.
;
; OUTPUTS:
;	XRET
;	XNB
;	XREJ
;	 	   Double array.  Decimal date of
;		   averaged values of specified type.
;
;	YRET
;	YNB
;	YREJ
;	 	   Float array.  Averaged value determined
;		   by specified flag type.
;
;		   RET -> retained flask values
;		   NB  -> non-background flask values
;		   REJ -> rejected flask values
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a site file format.
;
; PROCEDURE:
;	CCG_FLASKAVE_OLD may be called from the IDL command line or
;	from an IDL procedure.
;		Example:
;			CCG_FLASKAVE_OLD,sp='o18',site='asc',xret,yret,xnb,ynb,xrej,yrej
;			PLOT, 	xret,yret,PSYM=6,COLOR=pen(2)
;			OPLOT, 	xnb,ynb,PSYM=4,COLOR=pen(3)
;			
;		or
;
;			CCG_FLASKAVE_OLD,sp='co',file='/users/ken/test',xret,yret
;			PLOT, 	xret,yret,PSYM=6,COLOR=pen(2)
;		
; MODIFICATION HISTORY:
;	Written, KAM, November 1993.
;	Modified, KAM, July 1995.
;-
;
PRO CCG_FSREAD2_OLD,	file=file,$
			sp=sp,$
			header=header,$
			nlines=nlines,$
			nomessages=nomessages,$
			x,y,flag
;
x=DBLARR(nlines)
y=FLTARR(nlines)
flag=STRARR(nlines)
DEFAULT=(-999.99)
head=1
;
;Return to caller if an error occurs
;
ON_ERROR,	2	
;
CASE 1 OF
(STRPOS(file,"o18") NE -1 OR sp EQ 'o18'): 	DEFAULT=(-999.999)
(STRPOS(file,"c13") NE -1 OR sp EQ 'c13'): 	DEFAULT=(-999.999)
(STRPOS(file,"co2") NE -1 OR sp EQ 'co2'): 	
(STRPOS(file,"ch4") NE -1 OR sp EQ 'ch4'): 	
(STRPOS(file,"co") NE -1 OR sp EQ 'co'): 	
(STRPOS(file,"h2") NE -1 OR sp EQ 'h2'): 	
(STRPOS(file,"n2o") NE -1 OR sp EQ 'n2o'): 	
(STRPOS(file,"sf6") NE -1 OR sp EQ 'sf6'): 	
ENDCASE

sformat=$
	'(A3,1X,I4.4,1X,4(I2.2,1X),A8,1X,A1,1X,F8.3,'+$
	'1X,A3,1X,A2,1X,I4.4,1X,2(I2.2,1X),A6)'

yr=0  & mo=0  & dy=0  & hr=0  & mn=0
st='' & fi='' & me='' & fl='' & in='' 
ad='' & fg='' & sc='' & mr=0.
ayr=0 & amo=0 & ady=0 & mn=0
dummy=''
syr=0 & smo=0 & sdy=0

OPENR, unit, file,/GET_LUN

i=0 & j=0
IF NOT nomessages THEN CCG_MESSAGE,'Opening '+file+' ...'
WHILE NOT EOF(unit) DO BEGIN
	IF (j EQ 0) AND (head EQ 1) THEN BEGIN
		READF,unit,FORMAT='(A54,I4,1X,I2,1X,I2)',dummy,syr,smo,sdy 
		CCG_DATE2DEC,yr=syr,mo=smo,dy=sdy,hr=12,mn=00,dec=dec
		seldate=dec
	ENDIF ELSE BEGIN
		READF, unit, FORMAT=sformat,  $
			st,yr,mo,dy,hr,mn,fi,me,mr,fg,in,ayr,amo,ady,sc

		IF (hr EQ 99) THEN hr=12
		IF (mn EQ 99) THEN mn=0 

		CCG_DATE2DEC,	yr=ayr,mo=amo,dy=ady,hr=hr,mn=mn,dec=dec
		analdate=dec

		skip=0
		IF (mr NE DEFAULT) THEN BEGIN	
			IF KEYWORD_SET(header) THEN BEGIN
				IF analdate GT seldate THEN skip=1 ELSE	skip=0
			ENDIF
			IF NOT skip THEN BEGIN
				CCG_DATE2DEC,$
				yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
				x(i)=dec
				flag(i)=fg
				y(i)=mr 
				i=i+1
			ENDIF
		ENDIF
	ENDELSE
		j=j+1
ENDWHILE
FREE_LUN, unit
;
IF i GT 0 THEN BEGIN
	x=x(0:i-1)
	y=y(0:i-1)
	flag=flag(0:i-1)
ENDIF ELSE BEGIN
	x=x(0)
	y=y(0)
	flag=flag(0)
ENDELSE
IF NOT nomessages THEN CCG_MESSAGE,'Done reading '+file+' ...'
END

PRO 	CCG_FLASKAVE_OLD,	site=site,$
			sp=sp,$
			file=file,$
			header=header,$
			nomessages=nomessages,$
			xret,yret,$
			xnb,ynb,$
			xrej,yrej
;
;-------------------------------------- check site parameter
;
IF NOT KEYWORD_SET(file) AND NOT KEYWORD_SET(site) THEN BEGIN
	CCG_MESSAGE,"Site, 'site', parameter must be set.  Exiting ..."
	CCG_MESSAGE,"ex:  CCG_FLASKAVE_OLD, site='smo',sp='ch4'"
	RETURN
ENDIF
;
;-------------------------------------- check species parameter
;
IF NOT KEYWORD_SET(sp) THEN BEGIN
	CCG_MESSAGE,"Species, 'sp', parameter must be set.  Exiting ..."
	CCG_MESSAGE,"ex:  CCG_FLASKAVE_OLD, site='smo',sp='ch4'"
	RETURN
ENDIF
;
;-------------------------------------- check messages parameter
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
;
;-------------------------------------- miscellaneous initialization
;
DEFAULT=(-999.99)

sitedir=[ 	'/projects/co2/flask/site/',$
		'/projects/ch4/flask/site/',$
		'/projects/co/flask/site/',$
		'/projects/h2/flask/site/',$
		'/projects/n2o/flask/site/',$
		'/projects/sf6/flask/site/',$
		'/projects/silco2/flask/site/',$
		'/projects/silco2/flask/site/',$
		'/projects/silch4/flask/site/']

ext	=[	'.co2',$
		'.ch4',$
		'.co',$
		'.h2',$
		'.n2o',$
		'.sf6',$
		'.c13',$
		'.o18',$
		'.c13']

headstr	=[	0,$
		1,$
		1,$
		1,$
		1,$
		1,$
		1,$
		1,$
		1]

IF STRLOWCASE(sp) EQ 'co2' THEN isp=0
IF STRLOWCASE(sp) EQ 'ch4' THEN isp=1
IF STRLOWCASE(sp) EQ 'co'  THEN isp=2
IF STRLOWCASE(sp) EQ 'h2'  THEN isp=3
IF STRLOWCASE(sp) EQ 'n2o'  THEN isp=4
IF STRLOWCASE(sp) EQ 'sf6'  THEN isp=5
IF STRLOWCASE(sp) EQ 'c13' THEN isp=6
IF STRLOWCASE(sp) EQ 'o18' THEN isp=7
IF STRLOWCASE(sp) EQ '13ch4' THEN isp=8
;
;-------------------------------------- read site file
;
IF NOT KEYWORD_SET(file) THEN $
	file=STRCOMPRESS(sitedir(isp)+STRLOWCASE(site)+ext(isp),/REMOVE_ALL)
;
;determine number of lines
;in file.
;
nlines=CCG_LIF(file=file)-headstr(isp)
IF nlines LE 0 THEN BEGIN
        xret=0 & yret=0 & xnb=0 & ynb=0 & xrej=0 & yrej=0
        RETURN
ENDIF

xret=MAKE_ARRAY(nlines,/DOUBLE,VALUE=DEFAULT)
yret=MAKE_ARRAY(nlines,/FLOAT,VALUE=DEFAULT)
xnb=MAKE_ARRAY(nlines,/DOUBLE,VALUE=DEFAULT)
ynb=MAKE_ARRAY(nlines,/FLOAT,VALUE=DEFAULT)
xrej=MAKE_ARRAY(nlines,/DOUBLE,VALUE=DEFAULT)
yrej=MAKE_ARRAY(nlines,/FLOAT,VALUE=DEFAULT)
;
CCG_FSREAD2_OLD,file=file,sp=sp,header=header,nomessages=nomessages,nlines=nlines,x,y,flag
;
;-------------------------------------- determine average of ret on date and time
;
iret=WHERE(STRPOS(flag,'.',0) EQ 0 AND STRPOS(flag,'.',1) EQ 1)

IF iret(0) NE -1 THEN BEGIN
	j=0 & k=0
	REPEAT BEGIN
		index=WHERE(x(iret)-x(iret(j)) EQ 0)
		IF index(0) EQ -1 THEN BEGIN
			xret(k)=x(iret(j))
			yret(k)=y(iret(j))
			j=j+1
		ENDIF ELSE BEGIN
			xret(k)=x(iret(j))
			yret(k)=TOTAL(y(iret(index)))/N_ELEMENTS(index)
			j=j+N_ELEMENTS(index)
		ENDELSE
		k=k+1
	ENDREP UNTIL j EQ N_ELEMENTS(iret)
ENDIF ELSE BEGIN
	k=1
ENDELSE
xret=xret(0:k-1)
yret=yret(0:k-1)
;
;-------------------------------------- determine average of nb on date and time
;
inb=WHERE(STRPOS(flag,'.',1) NE 1)

IF inb(0) NE -1 THEN BEGIN
	j=0 & k=0
	REPEAT BEGIN
		index=WHERE(x(inb)-x(inb(j)) EQ 0)
		IF index(0) EQ -1 THEN BEGIN
			xnb(k)=x(inb(j))
			ynb(k)=y(inb(j))
			j=j+1
		ENDIF ELSE BEGIN
			xnb(k)=x(inb(j))
			ynb(k)=TOTAL(y(inb(index)))/N_ELEMENTS(index)
			j=j+N_ELEMENTS(index)
		ENDELSE
		k=k+1
	ENDREP UNTIL j EQ N_ELEMENTS(inb)
ENDIF ELSE BEGIN
	k=1
ENDELSE
xnb=xnb(0:k-1)
ynb=ynb(0:k-1)
;
;-------------------------------------- determine average of rej on date and time
;
irej=WHERE(STRPOS(flag,'.',0) NE 0)

IF irej(0) NE -1 THEN BEGIN
	j=0 & k=0
	REPEAT BEGIN
		index=WHERE(x(irej)-x(irej(j)) EQ 0)
		IF index(0) EQ -1 THEN BEGIN
			xrej(k)=x(irej(j))
			yrej(k)=y(irej(j))
			j=j+1
		ENDIF ELSE BEGIN
			xrej(k)=x(irej(j))
			yrej(k)=TOTAL(y(irej(index)))/N_ELEMENTS(index)
			j=j+N_ELEMENTS(index)
		ENDELSE
		k=k+1
	ENDREP UNTIL j EQ N_ELEMENTS(irej)
ENDIF ELSE BEGIN
	k=1
ENDELSE
xrej=xrej(0:k-1)
yrej=yrej(0:k-1)
RETURN
END
