;+
; NAME:
;       VP_PLOT
;
; PURPOSE:
;       Plot PFP profile data (mixing ratio vs height)
;
; CALLING SEQUENCE:
;       VP_PLOT, sp = 'co', site = 'car', date = 20020111
;       VP_PLOT, sp = 'co,co2', site = 'car', date = 20050114
;       VP_PLOT, sp = 'mebr,f11a', site = 'dnd', date = [2004, 2005]
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
;	mo:		Request data sampled in a subset of months
;			mo = 1 (January samples only)
;			mo = [6,7,8] (June, July, August samples only)
;
;	average:	If non-zero, plot an "average" of the profiles
;			This is still being developed
;
;	nodata:		If non-zero, do not plot actual data
;
;	xaxis:		Customize X-axis parameters.  Use when only
;			a single gas is specified.
;			(ex) xaxis = [min, max, majorticks, minorticks]
;			(ex) xaxis = [0, 200, 4, 5]
;
;	yaxis:		Customize Y-axis parameters.  
;			(ex) yaxis = [min, max, majorticks, minorticks]
;			(ex) yaxis = [0, 8000, 4, 4]
;
;	nonb:		If non-zero, samples with 2nd column flags are excluded
;
;	norej:		If non-zero, samples with 1st column flags are excluded
;
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;
;	dev:		Specify graphics device
;
; OUTPUTS:
;	none:
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
;
; MODIFICATION HISTORY:
;	Modified kam, March 2007.
;    changed averaging scheme.
;
;	Written, KAM, April 2005.
;-
;
; Get Utility functions
;
@ccg_utils.pro

PRO	VP_PLOT, $
	sp = sp, $
	site = site, $
	xaxis = xaxis, $
	yaxis = yaxis, $
	row = row, $
	col = col, $
	date = date, $
	mo = mo, $
	nodata = nodata, $
	average = average, $
	charsize = charsize, $
	charthick = charthick, $
	nonb = nonb, $
	norej = norej, $
	thick = thick, $
	symsize = symsize, $
	help = help, $
	dev = dev
;
; Routine to plot sets of profiles
;
; Written: March 2005 - kam
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(charsize) THEN charsize = 1.25
IF NOT KEYWORD_SET(charthick) THEN charthick = 2.0
IF NOT KEYWORD_SET(thick) THEN thick = 2.0
IF NOT KEYWORD_SET(symsize) THEN symsize = 1.0

sparr = STRSPLIT(sp, ',' , /EXTRACT, COUNT = nsparr)

ticklen = KEYWORD_SET(nogrid) ? -0.02 : 1
gridstyle = 1

IF NOT KEYWORD_SET(date) THEN date = [19000101L, 99991231L]

IF N_ELEMENTS(date) EQ 1 THEN date = [date, date]

date = LONG(date)
d1 = DateDB((date[0] = StartDate(date[0])))
d2 = DateDB((date[1] = EndDate(date[1])))
;
; Get a list of profiles
;
VP_SETS, site = site, date = date, /list, events

IF (r = SIZE(events, /TYPE)) NE 8 THEN CCG_FATALERR, "No profiles found."
;
; Fetch profile data
;
data = ''
FOR i = 0, N_ELEMENTS(events) - 1 DO BEGIN
	;
	; Constrain by month?
	;
	darr = STRSPLIT(events[i].date, '-', /EXTRACT)
	IF KEYWORD_SET(mo) THEN BEGIN
		j = WHERE(mo EQ darr[1])
		IF j[0] EQ -1 THEN CONTINUE
	ENDIF
	;
	; Get profile
	;
	VP_SETS,site = site, $
		sp = sp, $
		date = STRING(FORMAT = '(I4,2(I2.2))', darr), $
		pid = events[i].id, $
		/nomessage, $
		z
	;
	; If no data available, next i
	;
	IF (r = SIZE(z, /TYPE)) NE 8 THEN CONTINUE
	;
	; Build structure tag name
	;
	tag = '_' + STRJOIN(STRSPLIT(events[i].date, '-', /EXTRACT),'_') + '_' + events[i].id
	;
	; Create or append structure array
	;
	data = ((r = SIZE(data, /TYPE)) NE 8) ? CREATE_STRUCT(tag, z) : CREATE_STRUCT(data, tag, z)

ENDFOR

IF SIZE(data, /TYPE) NE 8 THEN CCG_FATALERR, 'No data'
;
; If row and col are not specified, 
; the number of rows and colums should
; be multiple of number of species.
;
col = (KEYWORD_SET(col)) ? col : CEIL(SQRT(nsparr))
row = (KEYWORD_SET(row)) ? row : CEIL(FLOAT(nsparr) / col)
;
; Initialize Graphics
;
z = GET_SCREEN_SIZE()
CCG_OPENDEV, 	dev = dev, $
		pen = pen, $
		saveas = saveas, $
		/portrait, $
		xpixels = 0.8 * z[1], $
		ypixels = 1.29 * 0.8 * z[1]

!P.MULTI = [0, col, row, 0, 0]

IF SIZE(yaxis, /DIMENSION) EQ 4 THEN BEGIN
	ey = {  YSTYLE:1, $
		YRANGE:[yaxis[0], yaxis[1]], $
		YTICKS:yaxis[2], $
		YMINOR:yaxis[3]}
ENDIF ELSE BEGIN
	ey = {  YSTYLE:16}
ENDELSE

IF SIZE(xaxis, /DIMENSION) EQ 4 THEN BEGIN
	ex = {  XSTYLE:1, $
		XRANGE:[xaxis[0],xaxis[1]], $
		XTICKS:xaxis[2], $
		XMINOR:xaxis[3]}
ENDIF ELSE BEGIN
	ex = {  XSTYLE:16}
ENDELSE

e = CREATE_STRUCT(ex, ey)
;
; Prepare title
;
title = STRUPCASE(site) + ' : ' + d1 + ' thru ' + d2
IF KEYWORD_SET(mo) THEN BEGIN
	CCG_INT2MONTH, imon = mo, mon = mo_info, /three
	title = title + ' [' + STRJOIN(mo_info,', ') + ']'
ENDIF

IF row * col NE 1 THEN BEGIN
	ptitle = title
	title = ''
ENDIF ELSE ptitle = ''

FOR i = 0, nsparr - 1 DO BEGIN

	CCG_GASINFO, sp = sparr[i], title = xtitle
	;
	; Create subset of data 
	;
	x = [0] & y = [0]
	FOR ii = 0, N_TAGS(data) -1 DO BEGIN
		j = WHERE(STRCMP(data.(ii).parameter, sparr[i], /FOLD_CASE))

		IF j[0] EQ -1 THEN CONTINUE
		;
		; Exclude rejected samples when autoscaling
		;
		k = WHERE(STRMID(data.(ii)[j].flag, 0, 1) EQ '.')
		IF k[0] NE -1 THEN BEGIN
			x = [x, data.(ii)[j[k]].value]
			y = [y, data.(ii)[j[k]].alt]
		ENDIF
	ENDFOR
	
	IF N_ELEMENTS(x) EQ 1 THEN CONTINUE

	x = x[1:*]
	y = y[1:*]
	;
	; Use min/max Altitude to determine y0
	;
	y0 = FINDGEN(100) * (MAX(y) - MIN(y)) / 100.0 + MIN(y)

	PLOT,  	x, y, $
		/NODATA, $
		COLOR = pen[1], $
		CHARSIZE = charsize, $
		CHARTHICK = charthick, $
		TITLE = title, $

		YTICKLEN = ticklen, $
		YGRIDSTYLE = gridstyle, $
		YTHICK = thick, $
		YCHARSIZE = 1.0, $
		YTITLE = 'Altitude (m)', $

		_EXTRA = e, $

		XTICKLEN = ticklen, $
		XGRIDSTYLE = gridstyle, $
		XTHICK = thick, $
		XTITLE = xtitle,$
		XCHARSIZE = 1.0

	XYOUTS, 0.5, 0.98, $
		/NORMAL, $
		ptitle, $
		ALI = 0.5, $
		CHARSIZE = charsize, $
		CHARTHICK = charthick, $
		COLOR = pen[1]
	;
	; Create subset of data 
	;
	acc_x = [0.0] & acc_y = [0.0]

	tagnames = TAG_NAMES(data)
	FOR ii = 0, N_TAGS(data) -1 DO BEGIN
		j = WHERE(STRCMP(data.(ii).parameter, sparr[i], /FOLD_CASE))
		IF j[0] EQ -1 THEN CONTINUE

		IF i EQ 0 THEN CCG_MESSAGE, tagnames[ii] + ' : pen[' + ToString(ii + 2) + ']'
		;
		; Work with retained values only
		;
		k = WHERE(STRMID(data.(ii)[j].flag, 0, 2) EQ '..')
		IF k[0] NE -1 AND N_ELEMENTS(k) GT 1 THEN BEGIN

			x = data.(ii)[j[k]].value
			y = data.(ii)[j[k]].alt

			y0_subset = y0[WHERE(y0 GE MIN(y) AND y0 LE MAX(y))]
			x0 = INTERPOL(x, y, y0_subset)
			;
			; Accummulate interpolated profiles
			;
			acc_x = [acc_x, x0]
			acc_y = [acc_y, y0_subset]

			IF NOT KEYWORD_SET(nodata) THEN BEGIN

				CCG_SYMBOL,	sym = 2, fill = 0

				OPLOT, [x], [y], $
				PSYM = -8, $
				SYMSIZE = symsize, $
				THICK = 2.0 * thick, $
				COLOR = pen[ii + 2]
			ENDIF
		ENDIF
		;
		; NB values
		;
		IF NOT KEYWORD_SET(nodata) AND NOT KEYWORD_SET(nonb) THEN BEGIN

			k = WHERE(STRMID(data.(ii)[j].flag, 1, 1) NE '.')
			IF k[0] NE -1 THEN BEGIN

				x = data.(ii)[j[k]].value
				y = data.(ii)[j[k]].alt
				
				x = SetDataLimit(x, !X.CRANGE[0], !X.CRANGE[1])

				CCG_SYMBOL,	sym = 10, fill = 0

				OPLOT, [x], [y], $
				PSYM = 8, $
				SYMSIZE = symsize, $
				THICK = 2.0 * thick, $
				COLOR = pen[ii + 2]
			ENDIF
		ENDIF
		;
		; REJ values
		;
		IF NOT KEYWORD_SET(nodata) AND NOT KEYWORD_SET(norej) THEN BEGIN

			k = WHERE(STRMID(data.(ii)[j].flag, 0, 1) NE '.')
			IF k[0] NE -1 THEN BEGIN

				x = data.(ii)[j[k]].value
				y = data.(ii)[j[k]].alt

				x = SetDataLimit(x, !X.CRANGE[0], !X.CRANGE[1])

				CCG_SYMBOL,	sym = 11, fill = 0

				OPLOT, [x], [y], $
				PSYM = 8, $
				SYMSIZE = symsize, $
				THICK = 2.0 * thick, $
				COLOR = pen[ii + 2]
			ENDIF
		ENDIF
	ENDFOR
	acc_x = acc_x[1:*]
	acc_y = acc_y[1:*]
	;
	; Compute average profile
	;
	j = SORT(acc_y)
	acc_y = acc_y[j]
	acc_x = acc_x[j]
	uniq_y = acc_y[UNIQ(acc_y)]
	ave_x = [0.0]
	sd_x = [0.0]
	FOR ii = 0, N_ELEMENTS(uniq_y) - 1 DO BEGIN
		j = WHERE(acc_y EQ uniq_y[ii])
		
		ave_x = [ave_x, CCG_MEAN(acc_x[j])]
		sd_x = (N_ELEMENTS(j) GT 1) ? [sd_x, STDEV(acc_x[j])] : [sd_x, 0]
	ENDFOR

	ave_x = ave_x[1:*]
	sd_x = sd_x[1:*]

	IF NOT KEYWORD_SET(average) THEN CONTINUE

	color = KEYWORD_SET(nodata) ? pen[2] : pen[1]
   
   ; 1 km bins with width of 1000m

   bins = INDGEN(20) * 1000

	CCG_SYMBOL,	sym = 2, fill = 1

   x = [0.0]
   y = [0.0]


   ; Average accumulated data within bins

   FOR ii = 1, N_ELEMENTS(bins) - 1 DO BEGIN
         j = WHERE(acc_y GE bins[ii - 1] AND acc_y LT bins[ii])

         IF j[0] EQ -1 THEN CONTINUE

         y0 = bins[ii] - 500

         r = MOMENT(acc_x[j])
         x0 = r[0]
         sd = SQRT(r[1])

         x = [x, x0]
         y = [y, y0]

	      CCG_ERRPLOT, [y0], [x0 + sd], [x0 - sd], /y, color = color, thick = thick
	      CCG_ERRPLOT, [x0], [MIN(acc_y[j])], [MAX(acc_y[j])], color = color, thick = thick
   ENDFOR

   OPLOT, [x[1:*]], [y[1:*]], $
   PSYM = -8, $
   SYMSIZE = 1.25 * symsize, $
   THICK = 2.0 * thick, $
   COLOR = color
ENDFOR
;
;----------------------------------------------- close up shop
;
CCG_CLOSEDEV,dev=dev
END
