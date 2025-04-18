;+
; NAME:
;	CCG_FSMERGE
;
; PURPOSE:
;	Merge CO2, CH4, CO, H2, N2O, SF6, d13C and d18O (CO2) flask 
;	measurement values and their flags with the flask sample history
;	and position.
;
;	The returned result is an IDL structure array (see OUTPUT for full 
;	description).  If the result is saved to a file then there is one
;	string for each flask sample.  The format of the merged string is 
;
;       'A3,1X,I4,4(1X,I2.2),1X,A8,1X,A1,1X,F6.2,1X,F7.2,1X,I6,1X,I3,1X,F4.1,
;	8(1X,F8.3,1X,A3)'
;
;	The logic for multiple aliquots is as follows:
; 		If there are multiple strings that match the 31-character
;		key then use the first occurrence of a retained flask value
; 		or if there are no retained flask values
; 		use the first occurrence of a non-background flask value
; 		or if there are no retained and non-background flask values
; 		use first the occurrence of a rejected value flask value
; 		or if there are no measurements use a default value and flag
;
;	Resultant string-vector may be returned and/or saved to files.
;
;	WARNING:	
;		This procedure can take considerable time to run.
;
; CATEGORY:
;	CCG.
;
; CALLING SEQUENCE:
;	CCG_FSMERGE,site='asc',year=1996,result=result
;	CCG_FSMERGE,site='ask',saveas='/users/ken/ask.ccg'
;
; INPUTS:
;
;	site:	   	3-letter site code specified as
;		   	follows.
;
;		   	site='brw'
;		   	site='asc'
;
; OPTIONAL INPUT PARAMETERS:
;	year:		If specified then only flasks sampled during the
;			specified year(s) will be merged.  Year may be a 
;			integer constant or vector, e.g., year=1997, 
;			year=[1994,1996,1997].
;
;	saveas:		If specified the resulting merged string-vector will be 
;			saved to the passed file name, e.g., saveas='.../merge.result'
;			The first line in the saved file is a format statement (see
;			PURPOSE).
;
; OUTPUTS:
;	result:		The return variable that will contain the resulting
;			merged information as an IDL structure array.
;
;	        	Returned result is a structure defined as follows:
;
;	result.str	->	Complete merged string (see PURPOSE section).
;	result.site	->	Sample site code.
;	result.yr	->	Sample year, month, day, hour, and minute (GMT).
;	result.mo	->
;	result.dy	->
;	result.hr	->
;	result.mn	->
;	result.id	->	8-character flask identification.
;	result.meth	->	Sample collection method.
;	result.lat	->	Sample latitude position in decimal degrees.
;	result.long	->	Sample longitude position in decimal degrees.
;	result.alt	->	Sample altitude in meters above sea level (MASL).
;	result.wd	->	Wind direction in degrees during sample collection.
;	result.ws	->	Wind speed during sample collection (m/s).
;	result.meth	->	Sample collection method.
;	result.[sp]val	->	Species analysis value (mixing ratio or del value).
;	result.[sp]flg	->	Species 3-character selection flag.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	CCG_FSMERGE may be called from the IDL command line or
;	from an IDL procedure.
;		Example:
;			CCG_FSMERGE, site='mht',year=1997,result=result
;
;			j=WHERE(STRMID(result.co2flg,0,1) EQ '.' AND
;			        STRMID(result.ch4flg,0,1) EQ '.')
;
;			IF j(0) NE -1 THEN $
;				PLOT,result(j).co2val,result(j).ch4val,PSYM=4,$
;					YSTYLE=1,XSTYLE=1
;		
; MODIFICATION HISTORY:
;	Written:  December 1995 - kam.
;	Modified: May 1997 - kam.
;-
;
PRO 	CCG_FSMERGE,	site=site,$
			year=year,$
			saveas=saveas,$
			result=result
;
;-------------------------------------- check site parameter
;
IF NOT KEYWORD_SET(site) THEN CCG_FATALERR,$
	"Site, 'site', parameter must be set,e.g., CCG_FSMERGE, site='smo',res"
site=STRLOWCASE(site)
;
;-------------------------------------- check result file entry
;
IF NOT KEYWORD_SET(saveas) THEN saveas=0
;
;-------------------------------------- misc initialization
;
DEFAULT=(-9999.999)
UNK='unknown'
f='(A3,1X,I4,4(1X,I2.2),1X,A8,1X,A1,1X,F6.2,1X,F7.2,1X,I6,1X,I3,1X,F4.1,9(1X,F8.3,1X,A3))'

result_str=[f]
netdir='/projects/network/flask/site/'

;
script='/users/ken/scripts/perl/build_ccg'

IF KEYWORD_SET(year) THEN BEGIN
	n=N_ELEMENTS(year)
	syr=STRARR(n)
	FOR i=0,n-1 DO syr(i)=STRCOMPRESS(STRING(year(i)),/RE)
ENDIF ELSE syr=['']

FOR i=0,N_ELEMENTS(syr)-1 DO BEGIN
	SPAWN, script+' '+site+' '+syr(i),r
	result_str=[result_str,r]
ENDFOR
n=N_ELEMENTS(result_str)
;
;Build up structure
;
result=REPLICATE({	ccgmerge,$
			str:		UNK,$
			site: 		UNK,$
			yr:		0,$
			mo:		0,$
			dy:		0,$
			hr:		0,$
			mn:		0,$
			id:		UNK,$
			meth: 		UNK,$
 			lat:		DEFAULT,$
 			long:		DEFAULT,$
 			alt: 		0,$
 			wd: 		0,$
 			ws: 		DEFAULT,$
			co2val:		DEFAULT,$
			co2flg:		UNK,$
			ch4val:		DEFAULT,$
			ch4flg:		UNK,$
			coval:		DEFAULT,$
			coflg:		UNK,$
			h2val:		DEFAULT,$
			h2flg:		UNK,$
			n2oval:		DEFAULT,$
			n2oflg:		UNK,$
			sf6val:		DEFAULT,$
			sf6flg:		UNK,$
			c13val:		DEFAULT,$
			c13flg:		UNK,$
			o18val:		DEFAULT,$
			o18flg:		UNK},$
			n-1)
;
;Fill structure
;
s='' & id='' & me=''
fg1='' & fg2='' & fg3='' & fg4='' & fg5='' & fg6='' & fg7='' & fg8=''
mr1=0. & mr2=0. & mr3=0. & mr4=0. & mr5=0. & mr6=0. & mr7=0. & mr8=0.

FOR i=1,n-1 DO BEGIN
	result(i-1).str=result_str(i)
	READS,result_str(i),FORMAT=f,$
 	s,yr,mo,dy,hr,mn,id,me,lat,lon,alt,wd,ws,$
 	mr1,fg1,mr2,fg2,mr3,fg3,mr4,fg4,mr5,fg5,mr6,fg6,mr7,fg7,mr8,fg8

 	result(i-1).site=s
 	result(i-1).yr=yr & result(i-1).mo=mo & result(i-1).dy=dy
	result(i-1).hr=hr & result(i-1).mn=mn
 	result(i-1).id=id & result(i-1).meth=me
 	result(i-1).lat=lat & result(i-1).long=lon & result(i-1).alt=alt
 	result(i-1).wd=wd & result(i-1).ws=ws
 	result(i-1).co2val=mr1 & result(i-1).co2flg=fg1
 	result(i-1).ch4val=mr2 & result(i-1).ch4flg=fg2
 	result(i-1).coval=mr3 & result(i-1).coflg=fg3
 	result(i-1).h2val=mr4 & result(i-1).h2flg=fg4
 	result(i-1).n2oval=mr5 & result(i-1).n2oflg=fg5
 	result(i-1).sf6val=mr6 & result(i-1).sf6flg=fg6
 	result(i-1).c13val=mr7 & result(i-1).c13flg=fg7
 	result(i-1).o18val=mr8 & result(i-1).o18flg=fg8
ENDFOR
;
;Save results?
;
IF KEYWORD_SET(saveas) THEN CCG_SWRITE,file=saveas,result_str
END
