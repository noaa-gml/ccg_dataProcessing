;+
; NAME:
;	CCG_DATASYNC	
;
; PURPOSE:
;       The decimal dates from an input array will be 
;	matched with dates from a reference array.  
;
;       IF an input date and reference date match THEN
;	the corresponding reference value is associated 
;	with the input date.
;
;       IF an input date and reference date do not match
;	THEN a value is linearly interpolated between the 
;	closest neighboring reference values.
;
;	NOTE:
;
;	This procedure will not extrapolate values. 
;	Synchronization using linear interpolation 
;	will occur if and only if there exists at least
;	one reference value before AND at least one reference
;	value after an input date.
;
;	The INPUT array contains two columns: decimal dates
;	and values.
;
;	The REFERENCE array contains two columns:
;	decimal dates and values.
;
;	Results are saved to a user-provided array.
;
;	EXAMPLE OF USE:
;
;	To match flask sampling events with in situ data,
;	create an INPUT array of flask sample dates and mixing
;	ratios.  Create an array of in situ dates (typically
;	hourly averages) and mixing ratios as the REFERENCE array.
;	The results are saved to a user-provied 3-column array:
;	column 1 contains decimal dates where matches or 
;	interpolations could be made, column 2 contains the 
;	corresponding original input values, and column 3 contains 
;	interpolated or matched values from the reference array.  
;	For every date in the resultant array there is both an input 
;	value and a reference value.  However, the resultant array may 
;	be smaller than the original input array due to dates where 
;	interpolation of the reference values could not take place.
;
; CATEGORY:
;	Array Manipulation.
;
; CALLING SEQUENCE:
;	CCG_DATASYNC,refarr=refarr,inputarr=inputarr,def=0,gap=3
;	CCG_DATASYNC,reffile='dataset1',inputfile='dataset2'
;	CCG_DATASYNC,reffile='cmdl_cgo.co2'inputfile='csiro_cgo.co2',resarr=resarr
;	CCG_DATASYNC,reffile='dataset1',inputfile='dataset2',def=0
;	CCG_DATASYNC,reffile='dataset1',inputfile='dataset2',def=0,gap=3
;
; INPUTS:
;	reffile:   Reference file.  File must contain 2 columns:
;		   decimal dates and values.
;
;		   OR
;
;	refarr:	   Reference array. Must contain 2 columns: 
;		   decimal dates and values.
;
;	inputfile: Input file.  File must contain 2 columns:
;		   decimal dates and input values.  The decimal 
;		   dates in the input file will be matched with 
;		   the dates in the reference file.
;
;		   OR
;
;	inputarr:  Input array.  Must contain 2 columns:  decimal
;		   dates and values.  The decimal dates of the input 
;		   array will be matched with the dates in the
; 		   reference array.  If no match is found then a 
;		   reference value is derived from linear interpolation
;		   between the closest neighboring reference values.
;
; OPTIONAL INPUT PARAMETERS:
;	def:	   Contains the pre-assigned default value used in both
;		   files for missing values.  Default:  -999.999.
;
;	gap:	   If the gap (specified in hours) in reference values bracketing
;		   any given input exceeds 'gap' hours then no match is made.
;		   Default:  8760 hours (1 year).
;
;	round:   When round-off prevents matches from occuring, the user
;		   may specify round-off conditions.  The default is 10^(-5).
;		   	
; OUTPUTS:
;	resarr:  User-provided result array contains 3 columns, 
;		   the input decimal dates, the input values, and the 
;		   interpolated or exact values from the reference array.  
;
;		   NOTE:  If values cannot be interpolated because 
;		   there are no neighboring reference values or because the 
;		   user-specified 'gap' keyword prevents an interpolation
;		   then the number of rows (decimal dates) in the resulting 
;   		   array will be less than the input array.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	The input and reference arrays must be formatted
;	with two columns:  column 1 - decimal date
;			   column 2 - value
;
; PROCEDURE:
;		Example:
;			.
;			.
;			.
;			;
;			;'brwis' contains decimal dates and hourly
;			;average mixing ratios from the methane
;			;in situ program at BRW.
;			;
;			;'brwflk' contains decimal dates and mixing
;			;ratios from flask samples collected at BRW.
;			;
;			CCG_DATASYNC,	$
;					refarr=co2is,$
;					inputarr=co2flk,$
;					resarr=resarr
;			;	
;			;Compute differences between flask and in situ (exact
;			;or interpolated values).
;			;
;			flk_minus_is=resarr[1,*]-resarr[2,*]
;			
;			PLOT, resarr[0,*],flk_minus_is
;			.
;			.
;			.
;
;		
; MODIFICATION HISTORY:
;	Written, KAM, October 1995.
;	Modified, KAM, July 1998.
;-
PRO 	CCG_DATASYNC,$
	reffile=reffile,$
	inputfile=inputfile,$
	refarr=refarr,$
	inputarr=inputarr,$
	resarr=resarr,$
	round=round,$
	def=def,gap=gap, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;-----------------------------------------------check input status 
;
IF (NOT KEYWORD_SET(reffile) AND NOT KEYWORD_SET(inputfile)) AND $
   (NOT KEYWORD_SET(refarr) AND NOT KEYWORD_SET(inputarr)) THEN BEGIN
        CCG_MESSAGE,"The reference and source files/arrays must both be specified.  Exiting ..."
        CCG_MESSAGE,"(ex) CCG_DATASYNC,reffile='brw.ref',inputfile='brw.input',resarr=arr
        CCG_MESSAGE,"(ex) CCG_DATASYNC,refarr=refarr,inputarr=inputarr,resarr=arr
        RETURN
ENDIF
;
IF NOT KEYWORD_SET(def) THEN DEFAULT=(-999.999) ELSE DEFAULT=def
IF NOT KEYWORD_SET(round) THEN round=(-5)
IF NOT KEYWORD_SET(gap) THEN gap=8760
HOUR=0.0001141553D

IF KEYWORD_SET(reffile) THEN CCG_FREAD,	file=reffile,nc=2,ref ELSE ref=refarr
IF KEYWORD_SET(inputfile) THEN CCG_FREAD,file=inputfile,nc=2,input ELSE input=inputarr

j=WHERE(ref(1,*)-1 GT DEFAULT)
ref=ref(*,j)

j=WHERE(input(1,*)-1 GT DEFAULT)
input=input(*,j)

ninput=N_ELEMENTS(input[0,*])

n=0
resarr=DBLARR(3,ninput)
;
;Synchronize the input data set to the 
;reference data set.  Linearly interpolate
;between reference values when required.
;
FOR i=0,ninput-1 DO BEGIN
	j=WHERE(CCG_ROUND(ref[0,*],round) EQ CCG_ROUND(input[0,i],round))
	IF j[0] NE -1 THEN BEGIN
		resarr[0,n]=input[0,i]
		resarr[1,n]=input[1,i]
		resarr[2,n]=ref[1,j[0]]
		n=n+1
	ENDIF ELSE BEGIN
		j=WHERE(ref[0,*] LT input[0,i])
		k=WHERE(ref[0,*] GT input[0,i])
		IF j[0] NE -1 AND k[0] NE -1 THEN BEGIN 
			;
			;No extrapolation allowed
			;
			x1=ref[0,N_ELEMENTS(j)-1]
			x2=ref[0,k[0]]
			;
			;If bracketing input values exceed 'gap' in
			;hours then do not sync with reference value.
			; 
			IF x2-x1 LE gap*HOUR THEN BEGIN
				y1=ref[1,N_ELEMENTS(j)-1]
				y2=ref[1,k[0]]
				m=(y2-y1)/(x2-x1)
				b=y2-(m*x2)
				resarr[0,n]=input[0,i]
				resarr[1,n]=input[1,i]
				resarr[2,n]=m*resarr[0,n]+b
				n=n+1
			ENDIF
		ENDIF
	ENDELSE
ENDFOR

resarr=resarr[*,0:n-1]
END
