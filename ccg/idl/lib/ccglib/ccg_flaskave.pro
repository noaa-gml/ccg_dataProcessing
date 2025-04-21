;+
; NAME:
;	CCG_FLASKAVE
;
; PURPOSE:
;	Calculate retained, rejected, and 
;	non-background CCG flask/pfp averages.
;
;	If flasks have the same year, month, 
;	day, time, and flag type, i.e., ret, rej,
;	or nb then average.
;
;	Data are extracted from RDBMS or read from
;	an imported "site" file.
;
; CATEGORY:
;	Data Retrieval
;
; CALLING SEQUENCE:
;	CCG_FLASKAVE,sp='co2o18',site='asc',xret,yret,xnb,ynb,xrej,yrej
;	CCG_FLASKAVE,sp='co2',site='car030',project='ccg_aircraft',xret,yret,xnb,ynb,xrej,yrej
;	CCG_FLASKAVE,sp='co2',site='mlo', import='/home/ccg/ken/mlo.co2',/nomessages,xret,yret
;
;	CCG_FLASKAVE,file='/projects/co/flask/sites/bme.co',xret,yret (obsolete)
;
; INPUTS:
;	sp:	   	Gas formula, e.g., co, co2, h2, n2o,
;			sf6, ch4, co2o18, co2c13, ch4c13.
;
;	site:	   	Site code.  May include bin specification,
;			e.g., brw, sgp610, pocn30, car3000.
;
;       project:        Project abbreviation.  May be either
;                       ccg_surface or ccg_aircraft. Default is both.
;
;       strategy:       Strategy abbreviation.  May be either
;                       flask or pfp. Default is both.
;
; OPTIONAL INPUT PARAMETERS:
;       file:           file name must include the species name.
;                       co,co2,h2,n2o,sf6,ch4,co2o18,co2c13,ch4c13.
;                       NOTE:  This input option is supported but obsolete.
;                       File path is ignored.
;
;       import:         Specify a text "site" file with no header.
;
;       nomessages:     If non-zero, messages will be suppressed.
;
;	help:		If non-zero, the procedure documentation is
;			displayed to STDOUT.	
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
;	Either sp and site OR import OR file must be specified.
;	
;       When file keyword is set, file name must include gas name (see above).
;       The import keyword must point to a text file with "site" format.
;
; PROCEDURE:
;	CCG_FLASKAVE may be called from the IDL command line or
;	from an IDL procedure.
;		Example:
;			CCG_FLASKAVE,sp='co2o18',site='asc',xret,yret,xnb,ynb,xrej,yrej
;			PLOT, 	xret,yret,PSYM=6,COLOR=pen(2)
;			OPLOT, 	xnb,ynb,PSYM=4,COLOR=pen(3)
;			
;		or
;
;			CCG_FLASKAVE,import='~ken/brw_test.co',xret,yret
;			PLOT, 	xret,yret,PSYM=6,COLOR=pen(2)
;		
; MODIFICATION HISTORY:
;	Written, KAM, November 1993.
;	Modified, KAM, July 1995.
;	Modified, KAM, June 2004.
;-
;
PRO	COMPUTE_AVERAGES,sub,x,y

j = 0 & x = [0D] & y = [0.0]

REPEAT BEGIN
	index = WHERE(sub.x-sub[j].x EQ 0)
	IF index[0] EQ -1 THEN BEGIN
		x = [x,sub[j].x]
		y = [y,sub[j].y]
		j = j+1
	ENDIF ELSE BEGIN
		x = [x,sub[j].x]
		y = [y,TOTAL(sub[index].y)/N_ELEMENTS(index)]
		j = j+N_ELEMENTS(index)
	ENDELSE
ENDREP UNTIL j EQ N_ELEMENTS(sub)
x = x[1:*]
y = y[1:*]
END

PRO 	CCG_FLASKAVE,$
	site=site,$
	sp=sp,$
	project=project,$
	strategy=strategy,$
	file=file,$
	import=import,$
	nomessages=nomessages,$
	help=help,$
	xret,yret,$
	xnb,ynb,$
	xrej,yrej

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;-------------------------------------- check critical input parameters
;
IF NOT KEYWORD_SET(file) AND NOT KEYWORD_SET(import) AND $
   NOT KEYWORD_SET(site) AND NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(project) AND NOT KEYWORD_SET(strategy) THEN BEGIN
   project = 'ccg_surface'
   strategy = 'flask'
ENDIF

site_ = site

;
;-------------------------------------- miscellaneous initialization
;
nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
xret=0 & yret=0 & xnb=0 & ynb=0 & xrej=0 & yrej=0

CCG_FSREAD,file=file,site=site_,sp=sp,project=project,strategy=strategy,$
import=import,nomessages=nomessages,data

IF SIZE( data, /TYPE ) NE 8 THEN RETURN
;
;-------------------------------------- determine average of ret on date and time
;
j = WHERE(STRMID(data.flag,0,2) EQ '..')
IF j[0] NE -1 THEN COMPUTE_AVERAGES,data[j],xret,yret
;
;-------------------------------------- determine average of nb on date and time
;
j = WHERE(STRMID(data.flag,1,1) NE '.')
IF j[0] NE -1 THEN COMPUTE_AVERAGES,data[j],xnb,ynb
;
;-------------------------------------- determine average of rej on date and time
;
j = WHERE(STRMID(data.flag,0,1) NE '.')
IF j[0] NE -1 THEN COMPUTE_AVERAGES,data[j],xrej,yrej
END
