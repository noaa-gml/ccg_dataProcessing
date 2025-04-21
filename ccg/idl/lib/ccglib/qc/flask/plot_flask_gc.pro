;+
; plot_flask_gc, inst = 'H4', sp = 'ch4', date = '2006-01-01'
; plot_flask_gc, inst = 'R5', sp = 'co', date = '2006-01', project = 'flask'
;-
@ccg_utils.pro

PRO	PLOT_, data, ytitle, title, step, dev, pen, window
	;
	; Plot data
	;
	CCG_PLOT, data = data, ytitle = ytitle, $
	title = title, wtitle = title, /insert, $
	linethick = 1, symsize = 0.5, $
	charsize = 2.0, charthick = 1.0, xcustom = step, $
	/nogrid, /nolabid, /noproid, xtitle = 'Local Time', window = window ++, $
	dev = dev, pen = pen
	;
	; Advance Frame
	;
	!P.MULTI[0] --
END

FUNCTION RefSmp, d, n
	;
	; Identify ref and samples
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)

	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].adate, 'y', d[j].(n), 'legend', 'REF', 'symcolor', 1, 'linecolor', 1)
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) EQ 0)

	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].adate, 'y', d[j].(n), 'legend', 'SMP', 'symcolor', 2, 'linecolor', 2)
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	RETURN, data
END

FUNCTION RTPercentVariability, d, n
	;
	; Determine Percent variability for each reference gas and sample gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] NE -1 THEN BEGIN

		sub = d[j]

		j = sub[SORT(sub.id)]
		refid = sub[UNIQ(sub.id)].id

		sub = sub[SORT(sub.adate)]

		FOR i = 0, N_ELEMENTS(refid) - 1 DO BEGIN

			j = WHERE(sub.id EQ refid[i])
			IF N_ELEMENTS(j) EQ 1 THEN CONTINUE
			;
			; Shift vector one position to right
			;
			p1 = sub[j].(n)
			p2 = SHIFT(sub[j].(n), 1)
			diff = 100 * ABS(p2 - p1) / p1
			;
			; Omit first comparison (i.e., last minus first)
			;
			z = CREATE_STRUCT('x', sub[1:*].adate, 'y', diff[1:*], 'legend', refid[i])

			tag = 'd' + ToString(i)
			data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT(tag, z) : CREATE_STRUCT(data, tag, z)
		ENDFOR
	ENDIF
	;
	; Now consider samples
	;
	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) EQ 0)
	IF j[0] NE -1 THEN BEGIN

		sub = d[j]
		;
		; Shift vector one position to right
		;
		p1 = sub[j].(n)
		p2 = SHIFT(sub[j].(n), 1)
		diff = 100 * ABS(p2 - p1) / p1
		;
		; Omit first comparison (i.e., last minus first)
		;
		z = CREATE_STRUCT('x', sub[1:*].adate, 'y', diff[1:*], 'legend', 'SMP')

		tag = 'd' + ToString(i + 1)
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT(tag, z) : CREATE_STRUCT(data, tag, z)
	ENDIF

	RETURN, data
END

FUNCTION PercentVariability, d, n
	;
	; Determine Percent variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] EQ -1 THEN RETURN, ''

	sub = d[j]

	j = sub[SORT(sub.id)]
	refid = sub[UNIQ(sub.id)].id

	sub = sub[SORT(sub.adate)]

	FOR i = 0, N_ELEMENTS(refid) - 1 DO BEGIN

		j = WHERE(sub.id EQ refid[i])
		IF N_ELEMENTS(j) EQ 1 THEN CONTINUE
		;
		; Shift vector one position to right
		;
		p1 = sub[j].(n)
		p2 = SHIFT(sub[j].(n), 1)
		diff = 100 * ABS(p2 - p1) / p1
		;
		; Omit first comparison (i.e., last minus first)
		;
		z = CREATE_STRUCT('x', sub[1:*].adate, 'y', diff[1:*], 'legend', refid[i])

		tag = 'd' + ToString(i)
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT(tag, z) : CREATE_STRUCT(data, tag, z)
	ENDFOR

	RETURN, data
END

FUNCTION Variability, d, n
	;
	; Determine variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] EQ -1 THEN RETURN, ''

	sub = d[j]

	j = sub[SORT(sub.id)]
	refid = sub[UNIQ(sub.id)].id

	sub = sub[SORT(sub.adate)]

	FOR i = 0, N_ELEMENTS(refid) - 1 DO BEGIN

		j = WHERE(sub.id EQ refid[i])
		IF N_ELEMENTS(j) EQ 1 THEN CONTINUE

		z = CREATE_STRUCT('x', sub[j].adate, 'y', sub[j].(n), 'legend', refid[i])

		tag = 'd' + ToString(i)
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT(tag, z) : CREATE_STRUCT(data, tag, z)
	ENDFOR

	RETURN, data
END

PRO	NewDate, task, date, yr0, mo0, dy0

	DAY = 0.002739726D

	IF dy0 NE 0 THEN BEGIN
		CCG_DATE2DEC, yr = yr0, mo = mo0, dy = dy0, dec = dec
		dec = (task EQ 1) ? dec + DAY : dec - DAY
		CCG_DEC2DATE, dec, yr0, mo0, dy0

		date = STRING(FORMAT = '(I4.4,A1,I2.2,A1,I2.2)', yr0, '-', mo0, '-', dy0)
	ENDIF ELSE BEGIN
		mo0 = (task EQ 1) ? ++ mo0 : -- mo0
		IF mo0 EQ 0 THEN BEGIN
			yr0 --
			mo0 = 12
		ENDIF
		IF mo0 EQ 13 THEN BEGIN
			yr0 ++
			mo0 = 1
		ENDIF
		date = STRING(FORMAT = '(I4.4,A1,I2.2)', yr0, '-', mo0)
	ENDELSE
END

PRO	PLOT_FLASK_GC, $
	dev = dev, $
	sp = sp, $
	project = project, $
	date = date, $
	inst = inst, $
	help = help
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(inst) THEN CCG_SHOWDOC
project = KEYWORD_SET(project) ? project : ['flask', 'pfp']

today = CCG_SYSDATE()
tmpfile = CCG_TMPNAM()

dev = (KEYWORD_SET(dev)) ? dev : ''
window = 0
;
; Parse Date
;
date = KEYWORD_SET(date) ? date : today.yr + '-' + today.mo + '-' + today.dy
;
; By Day or by Month?
;
tmp = STRSPLIT(date, "-", /EXTRACT)
yr0 = FIX(tmp[0])

CASE N_ELEMENTS(tmp) OF
1:      BEGIN
        step = 'month'
        mo0 = 1
        dy0 = 0
        END
2:      BEGIN
        step = 'month'
        mo0 = FIX(tmp[1])
        dy0 = 0
        END
3:      BEGIN
        step = 'day'
        mo0 = FIX(tmp[1])
        dy0 = FIX(tmp[2])
        END
ENDCASE

gc = CREATE_STRUCT( $
        'pkht',        'Peak Height', $
        'pkwd',        'Peak Width', $
        'pkar',        'Peak Area', $
        'ret',         'Retention Time', $
        'flow',        'Flow Rate (L min!e-1!n)')

tags = TAG_NAMES(gc)
ntags = N_ELEMENTS(tags)
addplots = 2
row = CEIL(SQRT(ntags + addplots))
col = CEIL(FLOAT(ntags + addplots) / row)

inc = 1
forever = 1
WHILE forever DO BEGIN
	;
	; Read one or more GC rawfiles
	;
	title = sp + ' ' + inst + ' ' + STRJOIN(project, ',') + ' ' + date
	READ_FLASK_RAW, date = date, gas = sp, inst = inst, project = project, raw

	IF (SIZE(raw, /TYPE) EQ 8) THEN BEGIN
		;
		; Initialize graphics
		;
		z = GET_SCREEN_SIZE()
		CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, xpixels = 1.29 * 0.95 * z[1], ypixels = 0.95 * z[1]
		;
		; Prep data
		;
		CCG_DATE2DEC, yr = raw.ayr, mo = raw.amo, dy = raw.ady, $
		hr = raw.ahr, mn = raw.amn, sc = raw.asc, dec = x

		!P.MULTI = [col * row, col, row, 0, 1]

		FOR i = 0, ntags - 1 DO BEGIN

			j = WHERE(TAG_NAMES(raw) EQ tags[i])
			CASE tags[i] OF
 				'PKHT': BEGIN
					data = Variability(raw, j[0])
					PLOT_, data, gc.(i) + ' (counts)', title, step, dev, pen, window

					data = PercentVariability(raw, j[0])
					PLOT_, data, gc.(i) + ' Variability (%)', title, step, dev, pen, window
					END
				'PKAR': BEGIN
					data = Variability(raw, j[0])
					PLOT_, data, gc.(i) + ' (counts)', title, step, dev, pen, window

					data = PercentVariability(raw, j[0])
					PLOT_, data, gc.(i) + ' Variability (%)', title, step, dev, pen, window
					END
				'PKWD': BEGIN
					data = PercentVariability(raw, j[0])
					PLOT_, data, gc.(i) + ' Variability (%)', title, step, dev, pen, window
					END
				'RET': 	BEGIN
					data = RTPercentVariability(raw, j[0])
					PLOT_, data, gc.(i) + ' Variability (%)', title, step, dev, pen, window
					END
				'FLOW': BEGIN
					data = RefSmp(raw, j[0])
					PLOT_, data, gc.(i), title, step, dev, pen, window
					END
			ENDCASE
		ENDFOR
		;
		; Close graphics
		;
		CCG_CLOSEDEV, dev = dev

		IF dev NE '' THEN BEGIN
			forever = 0
			CONTINUE
		ENDIF
		;
		; EventHandle
		;
		CURSOR, xd0, yd0, /DOWN, /DATA
		n0 = CONVERT_COORD(xd0, yd0, /DATA, /TO_NORMAL)

		IF !MOUSE.BUTTON EQ 4 THEN forever = 0

		IF !MOUSE.BUTTON EQ 1 THEN BEGIN
			
			inc = (n0[0] GE 0.5) ? 1 : 0
			NewDate, inc, date, yr0, mo0, dy0

		ENDIF

		IF NOT forever THEN BEGIN
			s = ''
			WSHOW, 0, 0
			READ, s, PROMPT = 'Are you sure? (y/n)'
			IF STRPOS(STRUPCASE(s), 'N') NE -1 THEN BEGIN
				forever = 1
				WSHOW, 0 , 1
			ENDIF
		ENDIF
	ENDIF ELSE NewDate, inc, date, yr0, mo0, dy0
ENDWHILE

SPAWN, 'rm -f ' + tmpfile
END
