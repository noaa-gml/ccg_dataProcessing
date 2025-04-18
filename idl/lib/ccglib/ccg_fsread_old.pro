;+
; NAME:
;	CCG_FSREAD_OLD	
;
; PURPOSE:
; 	Read a species-dependent CCG flask site file.
;	Intended to be used with CCG_FSWRITE.
;
;	User may suppress messages.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_FSREAD_OLD,file='filename',arr
;	CCG_FSREAD_OLD,file='/projects/co/flask/site/bme.co',data
;	CCG_FSREAD_OLD,file='/users/ken/mlo.co2',structarr
;
; INPUTS:
;	File:  		file name must include the species name.
;		   	co,co2,h2,n2o,sf6,ch4,o18,c13.
;
; OPTIONAL INPUT PARAMETERS:
;	nomessages:	If non-zero, messages will be suppressed.
;
;	all:		If non-zero, then returned structure will
;			contain all strings including those with
;			default mixing ratios.
;
; OUTPUTS:
;	Data:		This array is of type 'ccgfixed_old' structure:
;
;			arr().str 	-> entire site string
;			arr().x		-> GMT date/time in decimal format
;			arr().y		-> arr value (mixing ratio, per mil)
;			arr().code	-> 3-letter site code
;			arr().id	-> 8-character flask id
;			arr().type	-> 2-character flask id suffix
;			arr().meth	-> single character method
;			arr().inst	-> 2-character analysis instrument code
;			arr().adate	-> analysis date in decimal format
;			arr().source	-> 6-character raw file name
;			arr().flag	-> 3-character selection flag
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Expects a site file format.  File name must
;	contain species name (see INPUTS).
;
; PROCEDURE:
;	Once the site file is read into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the site file.  
;		Example:
;			CCG_FSREAD_OLD,file='/projects/co2/flask/site/brw.co2',arr
;			.
;			.
;			.
;			PLOT, arr.x,arr.y
;			PLOT, arr(WHERE(arr.meth EQ 'P')).x, $
;			      arr(WHERE(arr.meth EQ 'P')).y
;			.
;			.
;			sub_structure=arr(WHERE(arr.meth EQ 'P' AND arr.x GE 90))
;			.
;			.
;			.
;			n_butyl=arr(WHERE(arr.meth EQ 'N' AND arr.type EQ '60'))
;			.
;			.
;			CCG_FSWRITE,file='/users/ken/temp.co2',n_butyl
;
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;-
;
PRO CCG_FSREAD_OLD,	file=file,$
		all=all,$
		nomessages=nomessages,$
		arr
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"Source file name must be specified.  Exiting ..."
	CCG_MESSAGE,"(ex) ccg_fsread,file='/projects/ch4/flask/site/brw.ch4',arr"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0
IF NOT KEYWORD_SET(all) THEN all=0 ELSE all=1
;
;
DEFAULT=(-999.99)
;
CASE 1 OF

(STRPOS(file,"o18") NE -1): 	BEGIN
					DEFAULT=(-999.999)
					header=1
				END
(STRPOS(file,"c13") NE -1): 	BEGIN
					DEFAULT=(-999.999)
					header=1
				END
(STRPOS(file,"co2") NE -1): 	BEGIN
					header=1
				END
(STRPOS(file,"ch4") NE -1): 	BEGIN
					header=1
				END
(STRPOS(file,"n2o") NE -1): 	BEGIN
					header=1
				END
(STRPOS(file,"sf6") NE -1): 	BEGIN
					header=1
				END
(STRPOS(file,"co") NE -1): 	BEGIN
					header=1
				END
(STRPOS(file,"h2") NE -1): 	BEGIN
					header=1
				END
ELSE:				BEGIN
					CCG_MESSAGE,$
					"Source file must include species code."
					CCG_MESSAGE,$
					"Codes include co2,ch4,co,h2,c13,o18."
					RETURN
				END
ENDCASE
;
;Determine number of lines
;in file.
;
nlines=CCG_LIF(file=file)-header
IF nlines LE 0 THEN BEGIN
	arr=0
	RETURN
ENDIF
;
arr=REPLICATE({		ccgfixed_old,		$		 
	 		str:	'',		$
	 		x: 	DBLARR(1),      $
 	  		y: 	0.0, 		$ 
 			code:	'',		$
 	  		id: 	'',		$ 
 	  		type: 	'',		$ 
 	 		meth: 	'', 		$ 
 			inst:	'',		$ 
 			adate:	DBLARR(1),	$
 			source: '',		$
 			flag:	'   '},		$ 
 			nlines)


sformat=$
'(A3,1X,I4.4,1X,4(I2.2,1X),A8,1X,A1,1X,F8.3,1X,A3,1X,A2,1X,I4.4,1X,2(I2.2,1X),A6)'

yr=0  & mo=0  & dy=0  & hr=0  & mn=0
st='' & fi='' & me='' & fl='' & in='' 
ad='' & fg='' & sc='' & mr=0.
ayr=0 & amo=0 & ady=0 & mn=0
dummy=''

OPENR, unit,file,/GET_LUN

i=0 & j=0
IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Opening '+file+' ...'

WHILE NOT EOF(unit) DO BEGIN
	IF (j EQ 0) AND (header EQ 1) THEN BEGIN
		READF,unit,dummy 
	ENDIF ELSE BEGIN
		READF, unit, FORMAT=sformat,  $
			st,yr,mo,dy,hr,mn,fi,me,mr,fg,in,ayr,amo,ady,sc

		IF (hr EQ 99) THEN thr=12 ELSE thr=hr
		IF (mn EQ 99) THEN tmn=0  ELSE tmn=mn

		use=1
                IF NOT all AND  mr-1 LT DEFAULT THEN use=0

                IF use EQ 1 THEN BEGIN
 		 	arr(i).str=STRING(FORMAT=sformat,$
 		 	st,yr,mo,dy,hr,mn,fi,me,mr,fg,in,ayr,amo,ady,sc)
			CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=thr,mn=tmn,dec=dec
 		 	arr(i).x=dec
		 	arr(i).code=st
		 	arr(i).id=fi 
		 	arr(i).meth=me 
		 	arr(i).inst=in
		 	arr(i).flag=fg
			CCG_DATE2DEC,yr=ayr,mo=amo,dy=ady,hr=12,mn=00,dec=dec
 		 	arr(i).adate=dec 
		 	arr(i).source=sc 
		 	arr(i).y=mr 
		 	k=STRPOS(fi,'-')
		 	arr(i).type=STRMID(fi,k+1,2)
		 	i=i+1
		ENDIF
	ENDELSE
		j=j+1
ENDWHILE
FREE_LUN, unit
;
arr=arr(0:i-1)
;
IF NOT KEYWORD_SET(nomessages) THEN CCG_MESSAGE,'Done reading '+file+' ...'
END
