;+
; NAME:
;	CCG_FSWRITE	
;
; PURPOSE:
; 	Save flask/pfp data in "site" format.
;	Intended to be used with CCG_FSREAD.
;
;       Except for the sample date/time and the analysis
;       date/time, the site file string is rebuilt using
;       the passed (ccg_fsread) structure.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_FSWRITE,file='filename',data
;	CCG_FSWRITE,file='/users/ken/tmp/test.p3',sp=sp,arr
;
; INPUTS:
;	Array:		Must be of type 'ccgfixed' structure array.
;
;			data().str 	-> entire site string
;			data().x	-> GMT date/time in decimal format
;			data().y	-> fsdata value (mixing ratio, per mil)
;			data().code	-> 3-letter site code
;			data().id	-> 8-character flask id
;			data().type	-> 2-character flask id suffix
;			data().meth	-> single character method
;			data().inst	-> 2-character analysis instrument code
;			data().adate	-> analysis date in decimal format
;			data().flag	-> 3-character selection flag
;		  
;	File:  		Name of destination file.
;
; OPTIONAL INPUT PARAMETERS:
;	sp:  		The default format for the mixing or isotope ratio
;			is F8.3 unless species is set.  For all CCG species
;			except isotopes, format is F8.2.
;
;	nomessages:  	If messages is non-zero	all messages are suppressed.
;
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Will copy an existing file name to file.old.
;
; RESTRICTIONS:
;	Input must be consistent with data structure 
;	exported from CCG_FSREAD.
;
; PROCEDURE:
;	Input structure may be created using call to CCG_FSREAD.
;	The user may create subset arrays and save them in 
;	"site" file format.
;
;		Example:
;			CCG_FSREAD,code='brw',gas='co2',arr
;			.
;			.
;			.
;			PLOT, arr.x,arr.y
;			PLOT, arr(WHERE(arr.meth EQ 'P')).x, $
;			      arr(WHERE(arr.meth EQ 'P')).y
;			.
;			.
;			sub_struct=arr(WHERE(arr.meth EQ 'P' AND arr.x GE 1990))
;			.
;			.
;			.
;			n_butyl=arr(WHERE(arr.meth EQ 'N' AND arr.type EQ '60'))
;			.
;			.
;			CCG_FSWRITE,file='/home/ccg/ken/temp.co2',n_butyl
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;	Modified, KAM, October 1997.
;	Modified, KAM, May 1998.
;	Modified, KAM, June 2004.
;-
;************************************************
;
PRO CCG_FSWRITE,	struct,$
			file=file,$
			sp=sp,$
			help=help,$
			nomessages=nomessages
;
;Return to caller if an error occurs
;
ON_ERROR,	2
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(file) THEN CCG_SHOWDOC
;
nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
;
;Determine format of mixing or isotope ratio.
;
IF NOT KEYWORD_SET(sp) THEN sp='zzz'

dp_2=['co2','ch4','co','h2','n2o','sf6']
j=WHERE(dp_2 EQ sp)
IF j(0) NE -1 THEN dp='2' ELSE dp='3'
;
nstruct=(SIZE(struct))(1)
;
OPENR, unit, file,ERROR=err, /GET_LUN
IF (err EQ 0) THEN BEGIN
	IF NOT nomessages THEN CCG_MESSAGE,file+' exists, making '+file+'.old ...'
	s=STRCOMPRESS('/bin/cp '+file+' '+file+'.old')
	SPAWN,s
	FREE_LUN, unit
ENDIF
;
OPENW, unit, file,/GET_LUN
;
IF NOT nomessages THEN CCG_MESSAGE,'Writing '+file+' ...'

sformat='(A3,1X,A16,1X,A8,1X,A1,1X,F8.'+dp+',1X,A3,1X,A2,1X,A16)'

FOR i=0,nstruct-1 DO PRINTF,	unit, FORMAT=sformat,$
				struct(i).code,$
                                STRMID(struct(i).str,4,16),$
                                struct(i).id,struct(i).meth,$
                                struct(i).y,struct(i).flag,$
                                struct(i).inst,$
                                STRMID(struct(i).str,48,16)
FREE_LUN, unit
;
IF NOT nomessages THEN CCG_MESSAGE,'Done writing '+file+' ...'
END
