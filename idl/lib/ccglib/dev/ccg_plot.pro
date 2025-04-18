;+
; ccg_plot
;-
;
; Get Utility functions
;
@ccg_utils.pro

FUNCTION	InMonths, x
;
; Determine X Axis range in "month" format
;
dim = [[-9, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
       [-9, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]

CCG_DEC2DATE,	MIN(x), yr1, mo1, dy, hr, mn
CCG_DATE2DEC,	yr = yr1, mo = mo1, dy = dy, hr = hr, mn = mn, dec = xmin

CCG_DEC2DATE,	MAX(x), yr2, mo2, dy, hr, mn
CCG_DATE2DEC,	yr = yr2, mo = mo2, dy = dy, hr = hr, mn = mn, dec = xmax

nmonths = CCG_ROUND((xmax - xmin) * 12.0, 0) 
IF nmonths EQ 0 THEN nmonths ++
;
; Re-define minimum and maximum
;
CCG_DATE2DEC,	yr = yr1, mo = mo1, dy = 1, hr = 0, mn = 0, dec = xmin
CCG_DATE2DEC,	yr = yr2, mo = mo2, dy = dim[mo2, CCG_LEAPYEAR(yr2)], hr = 23, mn = 59, dec = xmax

abbr = (nmonths GT 12 ) ? 1 : 0

xtickname = MAKE_ARRAY(nmonths + 1, /STR, VALUE = ' ')

mo = mo1
FOR i = 0, nmonths DO BEGIN
	CCG_INT2MONTH, imon = mo, mon = mon, one = abbr
	xtickname[i] = mon
	mo = (mo EQ 12) ? 1 : mo + 1
ENDFOR

e = { XSTYLE : 1, $
      XRANGE : [xmin, xmax], $
      XMINOR : 2, $
      XTICKS : nmonths, $
      XTICKNAME : xtickname}

RETURN, e
END

FUNCTION	InHours, x
;
; Determine X Axis range in "hour" format
;
HIY = 8760

CCG_DEC2DATE,	MIN(x), yr, mo, dy, hr, mn, sc
CCG_DATE2DEC,	yr = yr, mo = mo, dy = dy, hr = hr, mn = mn, sc = sc, dec = xmin
fhour = hr

CCG_DEC2DATE,	MAX(x), yr, mo, dy, hr, mn, sc
CCG_DATE2DEC,	yr = yr, mo = mo, dy = dy, hr = hr, mn = mn, sc = sc, dec = xmax

nhours = CCG_ROUND((xmax - xmin) * HIY, 0) + 1
;
;If there are more than 30 hours then re-adjust 'hour' scale.
;
steps = 1
IF nhours GT 30 THEN BEGIN
        IF nhours MOD 2 EQ 1 THEN nhours ++
        nhours = nhours / 2.0
	steps = 2
ENDIF

xtickname = MAKE_ARRAY(nhours, /STR, VALUE = ' ')

j = fhour
FOR i = 0, nhours - 1 DO BEGIN
	IF j GT 23 THEN j = 0
	xtickname[i] = ToString(j)
	j = j + steps
ENDFOR

e = { XSTYLE : 1, $
      XRANGE : [xmin, xmax], $
      XTICKS : nhours - 1, $
      XMINOR : 1, $
      XTICKNAME : xtickname}

RETURN, e
END

PRO 	CCG_PLOT, $

	data = data, $

	sp = sp, $
	ytitle = ytitle, $
	xtitle = xtitle, $
	title = title, $

	xaxis = xaxis, $
	yaxis = yaxis, $
	xcustom = xcustom, $

	charsize = charsize, $
	charthick = charthick, $
	nosymbol = nosymbol, $
	symstyle = symstyle, $
	symsize = symsize, $
	symfill = symfill, $
	symthick = symthick, $
	noline = noline, $
	linestyle = linestyle, $
	linethick = linethick, $
	position = position, $

	pen = pen, $
	insert = insert, $

	legend = legend, $
	xyouts = xyouts, $

	nolabid = nolabid, $
	noproid = noproid, $
	nogrid = nogrid, $
	portrait = portrait, $

	help = help, $

	saveas = saveas, $
	window = window, $
	wtitle = wtitle, $
	dev = dev
;
; Help?
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
; Check for non-keyword parameters
; If exist, they must be structures
;
IF NOT KEYWORD_SET(data) THEN CCG_SHOWDOC

IF (r = SIZE(data, /TYPE)) NE 8 THEN CCG_SHOWDOC
ndata = N_TAGS(data)

FOR i = 0, ndata - 1 DO BEGIN
	x_all = (i EQ 0) ? [REFORM(data.(i).x)] : [x_all, REFORM(data.(i).x)]
	y_all = (i EQ 0) ? [REFORM(data.(i).y)] : [y_all, REFORM(data.(i).y)]
ENDFOR
;
; Are there at least 2 valid data points?
;
valid = WHERE((FINITE(x_all) AND FINITE(y_all)) EQ 1)
IF N_ELEMENTS(valid) LT 2 THEN RETURN
;
; Misc initialization
;
DEFAULT = (-9999.999)
keyinfo = REPLICATE(CREATE_STRUCT('color', 0, 'line', 0, 'sym', 0), ndata)
;
; If required, assign defaults to graphics parameters
;

charsize = (KEYWORD_SET(charsize)) ? charsize : 1.5
charthick = (KEYWORD_SET(charthick)) ? charthick : 2.0
nosymbol = (KEYWORD_SET(nosymbol)) ? 1 : 0
symsize = (KEYWORD_SET(symsize)) ? symsize : 0.6
symstyle = (KEYWORD_SET(symstyle)) ? symstyle : 0 
symfill = (KEYWORD_SET(symfill)) ? symfill : 0
symthick = (KEYWORD_SET(symthick)) ? symthick : 1.0
noline = (KEYWORD_SET(noline)) ? 1 : 0
linethick = (KEYWORD_SET(linethick)) ? linethick : 2.0
linestyle = (KEYWORD_SET(linestyle)) ? linestyle : 0
ticklen = (KEYWORD_SET(nogrid)) ? -0.02 : 1.0
gridstyle = (KEYWORD_SET(nogrid)) ? 0 : 1
legend = (KEYWORD_SET(legend)) ? legend : 'BL'
xyouts = (KEYWORD_SET(xyouts)) ? xyouts : ''
plotthick = (KEYWORD_SET(plotthick)) ? plotthick : 2.0

title = (KEYWORD_SET(title)) ? title : ' '
xtitle = (KEYWORD_SET(xtitle)) ? xtitle : 'Date'
ytitle = (KEYWORD_SET(ytitle)) ? ytitle : ' '

xcustom = (KEYWORD_SET(xcustom)) ? xcustom : ''
window = (KEYWORD_SET(window)) ? window : '0'
wtitle = (KEYWORD_SET(wtitle)) ? wtitle : ''

insert = (KEYWORD_SET(insert)) ? 1 : 0
saveas = (KEYWORD_SET(saveas)) ? saveas : ''
;
; Get gas-dependent plotting title
;
IF KEYWORD_SET(sp) AND NOT KEYWORD_SET(ytitle) THEN CCG_GASINFO, sp = sp, title = ytitle
;
; Allow user to specify Y range
;
IF SIZE(yaxis, /DIMENSION) EQ 4 THEN BEGIN
	ystyle = 0
	ey = {  YSTYLE:1, $
		YRANGE:[yaxis[0], yaxis[1]], $
		YTICKS:yaxis[2], $
		YMINOR:yaxis[3]}
ENDIF ELSE BEGIN
	ey = {  YSTYLE:16}
ENDELSE
;
; Allow user to specify X range
;
IF SIZE(xaxis, /DIMENSION) EQ 4 THEN BEGIN
	xstyle = 0
	ex = {  XSTYLE:1, $
		XRANGE:[xaxis[0], xaxis[1]], $
		XTICKS:xaxis[2], $
		XMINOR:xaxis[3]}

	date = [xaxis[0], xaxis[1]]
ENDIF ELSE BEGIN
	ex = {  XSTYLE:16}
	date = [DEFAULT, -DEFAULT]
ENDELSE

CASE xcustom OF
'hour':		ex = InHours(x_all)
'day':		ex = InHours(x_all)
'month':	ex = InMonths(x_all)
ELSE:
ENDCASE
;
; Create "EXTRA" structure
;
e = CREATE_STRUCT(ex, ey)
;
; Add POSITION value to EXTRA?
;
if KEYWORD_SET(position) THEN e = CREATE_STRUCT(e, {POSITION : position})
;
; set up graphics device 
;
IF NOT insert THEN CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, $
win = window, title = wtitle, portrait = portrait

PLOT,	[x_all], [y_all], $
	/NOERASE, $
	/NODATA, $
	POSITION = position, $
	COLOR = pen[1], $
	CHARSIZE = charsize, $
	CHARTHICK = charthick, $
	TITLE = title, $

	_EXTRA = e, $

	YSTYLE = ystyle, $
	YGRIDSTYLE = gridstyle, $
	YTICKLEN = ticklen, $
	YTHICK = plotthick, $
	YCHARSIZE = 1.0, $
	YTITLE = ytitle, $

	XSTYLE = xstyle, $
	XGRIDSTYLE = gridstyle, $
	XCHARSIZE = charsize * 0.5, $
	XTICKLEN = ticklen, $
	XTHICK = plotthick, $
	XTITLE = xtitle

OPLOT,	!X.CRANGE, [0,0], $
	COLOR = pen[1], $
	LINESTYLE = 1, $
	THICK = 1.0

FOR i = 0, ndata - 1 DO BEGIN

	color = (i LT 70) ? pen[i + 1] : pen[(i + 1) MOD 70]
	symstyle_ = (symstyle) ? symstyle : i + 1

	psym = (nosymbol) ? 0 : 8
	linestyle = (noline) ? -1 : 0

	tags = TAG_NAMES(data.(i))

	x = data.(i).x
	y = data.(i).y
	
 	x = ClipOnXRange(x)
 	y = ClipOnYRange(y)
	;
	; Symbol?
	; 
	j = WHERE(STRCMP(tags, 'symsize', /FOLD_CASE))
	symsize = (j[0] NE -1) ? data.(i).symsize : symsize
	j = WHERE(STRCMP(tags, 'symthick', /FOLD_CASE))
	symthick = (j[0] NE -1) ? data.(i).symthick : symthick
	j = WHERE(STRCMP(tags, 'symfill', /FOLD_CASE))
	symfill = (j[0] NE -1) ? data.(i).symfill : symfill
	j = WHERE(STRCMP(tags, 'symcolor', /FOLD_CASE))
	IF j[0] NE -1 THEN color = pen[data.(i).symcolor]

	j = WHERE(STRCMP(tags, 'symstyle', /FOLD_CASE))
	IF j[0] NE -1 THEN BEGIN
		CASE (r = SIZE(data.(i).symstyle, /TYPE)) OF
		2:	BEGIN
			psym = (data.(i).symstyle EQ 0) ? 0 : 8
			symstyle_ = data.(i).symstyle
			END
		7:	BEGIN
			psym = 0
			FOR ii = 0, N_ELEMENTS(x) - 1 DO $
			XYOUTS, x[ii], y[ii], data.(i).symstyle, COLOR = color, $
			CHARSIZE = symsize, CHARTHICK = symthick, ALIGNMENT = 0.5
			END
		ELSE:	
		ENDCASE
	ENDIF ELSE symstyle_ = symstyle_
	;
	; Plot symbol
	;
	IF psym EQ 8 THEN BEGIN
 		CCG_SYMBOL, sym = symstyle_, fill = symfill, thick = symthick
		OPLOT, [x], [y], COLOR = color, PSYM = psym, SYMSIZE = symsize
	ENDIF
	;
	; Line?
	; 
	j = WHERE(STRCMP(tags, 'linestyle', /FOLD_CASE))
	linestyle = (j[0] NE -1) ? data.(i).linestyle : linestyle
	j = WHERE(STRCMP(tags, 'linethick', /FOLD_CASE))
	linethick = (j[0] NE -1) ? data.(i).linethick : linethick
	j = WHERE(STRCMP(tags, 'linecolor', /FOLD_CASE))
	IF j[0] NE -1 THEN color = pen[data.(i).linecolor]

	IF linestyle GE 0 THEN OPLOT, [x], [y], COLOR = color, THICK = linethick, LINESTYLE = linestyle
	;
	; Legend details
	;
	keyinfo[i].sym = symstyle
	keyinfo[i].color = color
	keyinfo[i].line = linestyle
ENDFOR
;
; Prepare legend
;
e = CREATE_STRUCT({  CHARTHICK : charthick, CHARSIZE : 0.75 * charsize })
;
; Data coordinates
;
xspan = !X.CRANGE[1] - !X.CRANGE[0]
yspan = !Y.CRANGE[1] - !Y.CRANGE[0]

top = !Y.CRANGE[1] - 0.075 * yspan
bottom = !Y.CRANGE[0] + 0.025 * yspan
left = !X.CRANGE[0] + 0.035 * xspan
right = !X.CRANGE[1] - 0.035 * xspan

; Modified to do vertical legend - Michael Trudeau, 2007-04-10

CASE STRMID(legend, 0, 2) OF
'BL': xy = [left, bottom]
'TL': xy = [left, top]
ELSE:  xy = [left, bottom]
ENDCASE

IF legend NE 'no' THEN BEGIN

   FOR i = 0, ndata - 1 DO BEGIN

      IF legend EQ 'BLV' THEN ii = (ndata - 1) - i ELSE ii = i

      j = WHERE(STRCMP(tags, 'legend', /FOLD_CASE))
      IF j[0] EQ -1 THEN CONTINUE

      IF (data.(ii).legend EQ '') THEN CONTINUE
      t = data.(ii).legend + '  '

      f = CREATE_STRUCT(e, { COLOR : keyinfo[ii].color })
      
      vspace = !D.Y_CH_SIZE * e.charsize * i

      xy_dev = CONVERT_COORD(0, xy[1], /DATA, /TO_DEVICE)

      CASE legend OF
      'BLV': xy_dev[1] = xy_dev[1] + vspace
      'TLV': xy_dev[1] = xy_dev[1] - vspace
      ELSE:  BREAK 
      ENDCASE

      xy_tag = CONVERT_COORD(0, xy_dev[1], /DEVICE, /TO_DATA)

      IF ('BLV' EQ legend) OR ('TLV' EQ legend) OR (i EQ 0) THEN XYOUTS, xy[0], xy_tag[1], t, _EXTRA = f $
                                                            ELSE XYOUTS, t, _EXTRA = f

   ENDFOR
ENDIF

IF xyouts THEN BEGIN
	y = (xy[1] EQ bottom) ? top : bottom
	XYOUTS, xy[0], y, $
	xyouts, $
	charsize = 0.75 * charsize, $
	charthick = charthick, $
	color = pen[1]
ENDIF

IF NOT KEYWORD_SET(nolabid) THEN CCG_LABID
IF NOT KEYWORD_SET(noproid) THEN CCG_PROID
;
; close up shop 
;
IF NOT insert THEN CCG_CLOSEDEV, dev = dev, saveas = saveas
END
