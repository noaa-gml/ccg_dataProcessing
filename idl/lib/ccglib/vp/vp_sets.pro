;+
; NAME:
;       VP_SETS
;
; PURPOSE:
;       Extract PFP data from RDBMS
;
; CALLING SEQUENCE:
;	VP_SETS, sp = 'co', site = 'car', date = [20020101], data
;	VP_SETS, site = 'car', date = [20050114], pid = 211, data
;	VP_SETS, sp = 'all', site = 'dnd', date = [2004, 2005], data
;	VP_SETS, site = 'dnd', /list, list
;
; INPUTS:
;	site:		Site code.  May specify a single code or
;			a list of sites.
;			(ex) site = 'car'
;			(ex) site = 'dnd,fwi'
;
; OPTIONAL INPUT PARAMETERS:
;	sp:	 	Gas formula.  May specify a single sp or
;			a list of species.
;			(ex) sp = 'co'
;			(ex) sp = 'co2,co2c13,co2o18'
;
;	date:		Request data for a certain time period.
;			(ex) date = 2005
;			(ex) date = [2004,2005]
;			(ex) date = 20050112
;			(ex) date = [20050112,20050501]
;
;	pid:		Specify flask id prefix, (ex) pid = '3089'
;
;	mo:		Request data sampled in a subset of months
;			mo = 1 (January samples only)
;			mo = [6,7,8] (June, July, August samples only)
;
;	list:		If non-zero, returns list of profile dates
;			and flask id prefixes.
;
;	nomessages:	If non-zero, suppress messages
;
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
; OUTPUTS:
;	data:		Returns an anonymous structure array.  Structure
;			tags depend on passed parameters.
;
;			IF keyword "list" is non-zero then structure is
;			defined as 
;
;			data[].str 	-> all parameters joined into a string constant
;			data[].date	-> UTC date/time in year-month-day format
;			data[].id	-> flask ID prefix
;
;			ELSE structure is defined as 
;
;			data[].str 	-> all parameters joined into a string constant
;			data[].evn	-> event number.  This number uniquely identifies
;					   a flask or pfp sampling event.
;			data[].code	-> 3-letter site code
;			data[].date	-> UTC date/time in decimal format
;			data[].yr	-> UTC sample collection year
;			data[].mo	-> UTC sample collection month
;			data[].dy	-> UTC sample collection day
;			data[].hr	-> UTC sample collection hour 
;			data[].mn	-> UTC sample collection minute
;			data[].id	-> 8-character flask id
;			data[].type	-> 2-character flask id suffix
;			data[].meth	-> single character method
;			data[].lat	-> sample collection latitude
;			data[].lon	-> sample collection longitude
;			data[].alt	-> sample collection altitude (masl)
;                       data[].temp     -> air temperature (deg C)
;                       data[].press    -> ambient pressure (mbar)
;                       data[].rh       -> relative humidity (%)
;
;			If 'sp' is specified then the following measurement
;			results are returned.
;
;			data[].gas	-> gas formula (e.g., co2, co2c13)
;			data[].value	-> data value (mixing ratio, per mil)
;			data[].flag	-> 3-character selection flag
;			data[].inst	-> 2-character analysis instrument code
;			data[].adate	-> analysis date in decimal format
;			data[].ayr	-> sample analysis year (local time)
;			data[].amo	-> sample analysis month (local time)
;			data[].ady	-> sample analysis day (local time)
;			data[].ahr	-> sample analysis hour  (local time)
;			data[].amn	-> sample analysis minute (local time)
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
;	Data are returned in an anonymous structure array.  Users
;	can employ SQL-type IDL commands to manipulate data.
;
;		Example:
;			VP_SETS,$
;			sp = 'co,co2',$
;			site = 'car',
;			date = [20040202,20040202], pid = '205', vp
;			.
;			.
;			.
;			!P.MULTI = [0,2,1]
;
;			j = WHERE(STRCMP(vp.gas, 'co', /FOLD_CASE))
;			PLOT, vp[j].value, vp[j].alt, psym = 4
;
;			j = WHERE(STRCMP(vp.gas, 'co2', /FOLD_CASE))
;			PLOT, vp[j].value, vp[j].alt, psym = 4
;
; MODIFICATION HISTORY:
;	Written, KAM, April 2005.
;-
;
; Get Utility functions
;
@ccg_utils.pro

PRO	VP_SETS, $
	sp = sp, $
	site = site, $
	date = date, $
	pid = pid, $
	list = list, $
	help = help, $
	mo = mo, $
	nomessages = nomessages, $
	data
;
; Routine to plot sets of profiles
;
; Written: February 9, 2005 - kam
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF KEYWORD_SET(list) THEN sp = 'co2'

IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(date) THEN date = [19000101,99991231]

IF N_ELEMENTS(date) EQ 1 THEN date = [date, date]

date = LONG(date)
d1 = DateDB((date[0] = StartDate(date[0])))
d2 = DateDB((date[1] = EndDate(date[1])))
;
; List profiles?
;
IF KEYWORD_SET(list) THEN BEGIN
	CCG_PFPLISTING, site = site, data

	IF (r = SIZE(data, /TYPE)) NE 8 THEN RETURN

	j = WHERE(data.date GE d1 AND data.date LE d2)
	IF j[0] EQ -1 THEN data = 0

	data = data[j]

	RETURN
ENDIF
;
; Extract data
;
CCG_FLASK, site = site, sp = sp, nomessages = nomessages, project = 'ccg_aircraft', strategy = 'pfp', date = date, pid = pid, data
;
; Constrain by month(s)
;
ptr = [0]
IF KEYWORD_SET(mo) THEN BEGIN

	FOR i = 0, N_ELEMENTS(mo) - 1 DO BEGIN
		j = WHERE(data.mo EQ mo[i])
		IF j[0] EQ -1 THEN CONTINUE
		ptr = [ptr, j]
	ENDFOR
	IF N_ELEMENTS(ptr) GT 1 THEN data = data[ptr[1:*]] ELSE data = 0
ENDIF
END
