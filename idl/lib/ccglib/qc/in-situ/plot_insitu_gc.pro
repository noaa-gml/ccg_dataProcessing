;+
; plot_insitu_gc, sp = 'ch4', site = 'mlo', date = '2006-01-01'
; plot_insitu_gc, sp = 'co', site = 'brw', date = '2006-01-01'
; plot_insitu_gc, sp = 'co', site = 'brw', date = '2006-01-01', /fix
;
; Setting keyword 'fix' will fix y-axis range for % variability [0, 4, 4, 5]
;-
@ccg_utils.pro

PRO     PLOT_, data = data, ytitle = ytitle, title = title, $
        step = step, dev = dev, pen = pen, nplot = nplot, yaxis = yaxis

        IF !P.MULTI[0] EQ nplot THEN ERASE
        ;
        ; Plot data
        ;
        CCG_PLOT, data = data, ytitle = ytitle, $
        title = title, wtitle = title, /insert, $
        linethick = 1, symsize = 0.5, $
        charsize = 2.0, charthick = 1.0, xcustom = step, $
        /nogrid, /nolabid, /noproid, xtitle = 'UTC Time', $
        dev = dev, pen = pen, yaxis = yaxis
        ;
        ; Advance Frame
        ;
        !P.MULTI[0] --
END

FUNCTION ComputeVar, sub, n, type
	;
	; Shift vector one position to right
	;
	p1 = sub.(n)
	p2 = SHIFT(sub.(n), 1)
	diff = 100 * ABS(p2 - p1) / p1
	;
	; Omit first comparison (i.e., last minus first)
	;
	z = CREATE_STRUCT('x', sub[1:*].date, 'y', diff[1:*], 'legend', type)

	RETURN, z
END

FUNCTION RefSmp, d, code, n
	;
	; Identify ref and samples
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'L', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'L')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'M', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'M')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'H', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'H')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d3', z) : CREATE_STRUCT(data, 'd3', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'REF')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d4', z) : CREATE_STRUCT(data, 'd4', z)
	ENDIF

	j = WHERE(STRCMP(d.code, code, /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'SMP')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d5', z) : CREATE_STRUCT(data, 'd5', z)
	ENDIF

	RETURN, data
END

FUNCTION PercentVariability, d, n
	;
	; Determine variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'L', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'L')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'M', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'M')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'H', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'H')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d3', z) : CREATE_STRUCT(data, 'd3', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'REF')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d4', z) : CREATE_STRUCT(data, 'd4', z)
	ENDIF

	RETURN, data
END

FUNCTION Variability, d, n
	;
	; Determine variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'L', /FOLD_CASE) NE 0)
	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'L')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'M', /FOLD_CASE) NE 0)
	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'M')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'H', /FOLD_CASE) NE 0)
	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'H')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d3', z) : CREATE_STRUCT(data, 'd3', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'REF', /FOLD_CASE) NE 0)
	IF j[0] NE -1 THEN BEGIN
		z = CREATE_STRUCT('x', d[j].date, 'y', d[j].(n), 'legend', 'REF')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d4', z) : CREATE_STRUCT(data, 'd4', z)
	ENDIF

	RETURN, data
END

PRO	NewDate, task, date, yr0, mo0, dy0

	today = CCG_SYSDATE()
	DAY = 0.002739726D

	IF dy0 NE 0 THEN BEGIN
		CCG_DATE2DEC, yr = yr0, mo = mo0, dy = dy0, dec = dec
		dec = (task EQ 1) ? dec + DAY : dec - DAY

		IF dec GT today.d1 THEN RETURN

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

PRO	PLOT_INSITU_GC, $
	dev = dev, $
	site = site, $
	sp = sp, $
	date = date, $
        fix = fix, $
	help = help
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
fix = KEYWORD_SET(fix) ? 1 : 0

today = CCG_SYSDATE()
tmpfile = CCG_TMPNAM()

dev = (KEYWORD_SET(dev)) ? dev : ''
window = 0
;
; Parse Date
;
date = KEYWORD_SET(date) ? date : today.s4
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
	title = sp + ' ' + site + ' ' + date
	;
        ; Post message then remove if not needed
        ;
        XYOUTS, 0.5, 0.5, 'NO DATA FOR ' + title, CHARSIZE = charsize, ALI = 0.5, /NORMAL

	READ_INSITU_RAW, date = date, gas = sp, site = site, raw

	IF (SIZE(raw, /TYPE) EQ 8) THEN BEGIN
		;
		; Initialize graphics
		;
		z = GET_SCREEN_SIZE()
		CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, xpixels = 1.29 * 0.95 * z[1], ypixels = 0.95 * z[1]
		;
		; Prep data
		;
		CCG_DATE2DEC, yr = raw.yr, mo = raw.mo, dy = raw.dy, $
		hr = raw.hr, mn = raw.mn, sc = raw.sc, dec = x

		!P.MULTI = [col * row, col, row, 0, 1]

		FOR i = 0, ntags - 1 DO BEGIN

			j = WHERE(TAG_NAMES(raw) EQ tags[i])
			CASE tags[i] OF
                                'PKHT': BEGIN
                                        data = Variability(raw, j[0])
                                        PLOT_, data = data, ytitle = gc.(i) + ' (counts)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col

                                        data = PercentVariability(raw, j[0])
                                        yaxis = (fix EQ 1) ? [0, 4, 4, 5] : 0
                                        PLOT_, data = data, ytitle = gc.(i) + ' Variability (%)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
                                        END
                                'PKAR': BEGIN
                                        data = Variability(raw, j[0])
                                        PLOT_, data = data, ytitle = gc.(i) + ' (counts)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col

                                        data = PercentVariability(raw, j[0])
                                        yaxis = (fix EQ 1) ? [0, 4, 4, 5] : 0
                                        PLOT_, data = data, ytitle = gc.(i) + ' Variability (%)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
                                        END
                                'PKWD': BEGIN
                                        data = PercentVariability(raw, j[0])
                                        yaxis = (fix EQ 1) ? [0, 4, 4, 5] : 0
                                        PLOT_, data = data, ytitle = gc.(i) + ' Variability (%)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
                                        END
                                'RET':  BEGIN
                                        data = PercentVariability(raw, j[0])
                                        yaxis = (fix EQ 1) ? [0, 1, 5, 2] : 0
                                        PLOT_, data = data, ytitle = gc.(i) + ' Variability (%)', title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
                                        END
                                'FLOW': BEGIN
                                        data = RefSmp(raw, site, j[0])
                                        PLOT_, data = data, ytitle = gc.(i), title = title, $
                                        step = step, dev = dev, pen = pen, nplot = row * col
                                        END
                        ENDCASE
		ENDFOR
		;
		; Close graphics
		;
		CCG_CLOSEDEV, dev = dev
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
