;+
; plot_insitu_ndir, site = 'mlo', date = '2006-10-01'
; plot_insitu_ndir, site = 'brw', date = '2006-01-01'
; plot_insitu_ndir, site = 'brw',/fix
;
; Setting keyword 'fix' will fix y-axis range for % variability [0, 4, 4, 5]
;-
@ccg_utils.pro

PRO     PLOT_, data = data, ytitle = ytitle, title = title, nosymbol = nosymbol, $
        step = step, dev = dev, pen = pen, nplot = nplot, yaxis = yaxis

	IF !P.MULTI[0] EQ nplot THEN ERASE
        ;
        ; Plot data
        ;
        CCG_PLOT, data = data, ytitle = ytitle, $
        title = title, wtitle = title, /insert, $
        linethick = 1, symsize = 0.5, nosymbol = nosymbol, $
        charsize = 2.0, charthick = 1.0, xcustom = step, $
        /nogrid, /nolabid, /noproid, xtitle = 'UTC Time', $
        dev = dev, pen = pen, yaxis = yaxis
        ;
        ; Advance Frame
        ;
        !P.MULTI[0] --
END

FUNCTION READ_RELAY, f , type, normal = normal
       
        z = ''
	normal = KEYWORD_SET(normal) ? 1 : 0
	;
	; Read file
	;
	CCG_READ, file = f, z

	IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
		;
		; Prep data
		;
		CCG_DATE2DEC, yr = z.field1, mo = z.field2, dy = z.field3, $
		hr = z.field4, mn = z.field5, sc = z.field6, dec = x

		y = REFORM(z.field7)
		IF normal THEN BEGIN
			m = MEAN(y)
			y = y - m
			m = ' (' + ToString(STRING(FORMAT = '(F5.1)', m)) + ')'
		ENDIF ELSE m = ''
		z = CREATE_STRUCT('x', x, 'y', y, 'legend', type + m)
	ENDIF
	RETURN, z
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

FUNCTION PercentVariability, d, n
	;
	; Determine variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'W1', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'W1')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'W2', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'W2')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'W3', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		sub = d[j]
		z = ComputeVar(sub, n, 'W3')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d3', z) : CREATE_STRUCT(data, 'd3', z)
	ENDIF

	RETURN, data
END

FUNCTION Variability, d, n
	;
	; Determine variability for each reference gas
	;
	data = ''

	j = WHERE(STRCMP(d.code, 'W1', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		m = MEAN(d[j].(n))
		y = d[j].(n) - m
                m = ToString(STRING(FORMAT = '(F5.2)', m))
		z = CREATE_STRUCT('x', d[j].date, 'y', y, 'legend', 'W1 (' + m + ')')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'W2', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		m = MEAN(d[j].(n))
		y = d[j].(n) - m
                m = ToString(STRING(FORMAT = '(F5.2)', m))
		z = CREATE_STRUCT('x', d[j].date, 'y', y, 'legend', 'W2 (' + m + ')')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
	ENDIF

	j = WHERE(STRCMP(d.code, 'W3', /FOLD_CASE) NE 0)
	IF j[0] NE -1 AND N_ELEMENTS(j) GT 1 THEN BEGIN
		m = MEAN(d[j].(n))
		y = d[j].(n) - m
                m = ToString(STRING(FORMAT = '(F5.2)', m))
		z = CREATE_STRUCT('x', d[j].date, 'y', y, 'legend', 'W3 (' + m + ')')
		data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d3', z) : CREATE_STRUCT(data, 'd3', z)
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

PRO	PLOT_INSITU_NDIR, $
	dev = dev, $
	site = site, $
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
fix = KEYWORD_SET(fix) ? 1 : 0

today = CCG_SYSDATE()
tmpfile = CCG_TMPNAM()

dev = (KEYWORD_SET(dev)) ? dev : ''
sp = 'co2'
wdir = '/projects/co2/in-situ/' + site + '_data/'
qcdir = wdir + 'qc/'
voltdir = wdir + 'data/'
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
;
; Site-specific parameters
;
CASE site OF
'mlo':	BEGIN
	eng = CREATE_STRUCT( $
	'ndir_temp',   '_102', $
	'room_temp',   '_109', $
	'trap_temp',   '_110', $
	'smp_flow',    '_103', $
	'ref_flow',    '_104', $
	'p1_bleed',    '_111', $
	'p2_bleed',    '_112', $
	'p1_press',    '_113', $
	'p2_press',    '_114')
	END
'spo':	BEGIN
	eng = CREATE_STRUCT( $
	'ndir_temp',   '_102', $
	'room_temp',   '_109', $
	'trap_temp',   '_110', $
	'smp_flow',    '_103', $
	'ref_flow',    '_104', $
	'p1_bleed',    '_111', $
	'p2_bleed',    '_112', $
	'p1_press',    '_113', $
	'p2_press',    '_114', $
	'room_press',  '_117')
	END
'brw':	BEGIN
	eng = CREATE_STRUCT( $
	'ndir_temp',   '_102', $
	'room_temp',   '_108', $
	'trap_temp',   '_109', $
	'smp_flow',    '_103', $
	'ref_flow',    '_104', $
	'p1_bleed',    '_110', $
	'p2_bleed',    '_111', $
	'p1_press',    '_112', $
	'p2_press',    '_113')
	END
'smo':	BEGIN
	eng = CREATE_STRUCT( $
	'ndir_temp',   '_102', $
	'room_temp',   '_108', $
	'trap_temp',   '_109', $
	'smp_flow',    '_103', $
	'ref_flow',    '_104', $
	'p1_bleed',    '_110', $
	'p2_bleed',    '_111', $
	'p1_press',    '_112', $
	'p2_press',    '_113')
	END
ELSE:	CCG_FATALERR, "Don't yet know about " + site + "."
ENDCASE
engtags = TAG_NAMES(eng)

ndir = CREATE_STRUCT( $
        'chart',       'Voltage (mV)', $
        'std',         'Voltage', $
        'temp',        'Temperature (!eo!nC)', $
	'trap',        'Temperature (!eo!nC)', $
	'smp_flow',    'Sample Gas Flow Rate (ml min!e-1!n)', $
	'ref_flow',    'Reference Gas Flow Rate (ml min!e-1!n)', $
	'bleed',       'Bleed Flow Rate (L min!e-1!n)', $
        'press',       'Pressure (psi)', $
        'room_press',  'Pressure (psi)')

tags = TAG_NAMES(ndir)
ntags = N_ELEMENTS(tags)
addplots = 2
row = CEIL(SQRT(ntags + addplots))
col = CEIL(FLOAT(ntags + addplots) / row)

inc = 1
forever = 1
yr = 0 & mo = 0 & dy = 0
WHILE forever DO BEGIN
	;
	; Initialize graphics
	;
	z = GET_SCREEN_SIZE()
	CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, xpixels = 1.29 * 0.95 * z[1], ypixels = 0.95 * z[1]

	!P.MULTI = [col * row, col, row, 0, 1]

	title = sp + ' ' + site + ' ' + date
	yrmody = STRSPLIT(date, '-', /EXTRACT)
	;
	; Post message then remove if not needed
	;
	XYOUTS, 0.5, 0.5, 'NO DATA FOR ' + title, CHARSIZE = charsize, ALI = 0.5, /NORMAL

	FOR i = 0, ntags - 1 DO BEGIN

		CASE tags[i] OF
                'CHART': BEGIN
                        data = ''
			;
			; Read 10-sec voltages
			; 
			; 2006 06 10 00 00 10  0.270470 1
			;
			tmp = STRSPLIT(date, '-', /EXTRACT)
			CCG_READ, file = voltdir + tmp[0] + '/' + STRJOIN(tmp) + '.' + sp, raw

			IF (SIZE(raw, /TYPE) EQ 8) THEN BEGIN
				CCG_DATE2DEC, yr = raw.field1, mo = raw.field2, dy = raw.field3, $ 
				hr = raw.field4, mn = raw.field5, sc = raw.field6, dec = x 

				z = CREATE_STRUCT('x', x, 'y', raw.field7, 'legend', '')
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)

				PLOT_, data = data, ytitle = ndir.(i), title = title, /nosymbol, $
				step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
			ENDIF
			END
		'STD':  BEGIN
                        data = ''
			;
			; Read hourly average voltage file
			; 
			READ_INSITU_RAW, date = date, gas = sp, site = site, raw

			IF (SIZE(raw, /TYPE) EQ 8) THEN BEGIN
				rawtags = TAG_NAMES(raw)
				j = WHERE(rawtags EQ 'VOLT')

				data = Variability(raw, j[0])
				IF (SIZE(data, /TYPE) EQ 8) THEN BEGIN
					PLOT_, data = data, ytitle = ndir.(i) + ' (mV)', title = title, $
					step = step, dev = dev, pen = pen, nplot = row * col
				ENDIF

				data = PercentVariability(raw, j[0])
				yaxis = (fix EQ 1) ? [0, 4, 4, 5] : 0
				IF (SIZE(data, /TYPE) EQ 8) THEN BEGIN
					PLOT_, data = data, ytitle = ndir.(i) + ' Variability (%)', title = title, $
					step = step, dev = dev, pen = pen, nplot = row * col, yaxis = yaxis
				ENDIF
			ENDIF
			END
		'TEMP': BEGIN
			data = ''
			;
			; NDIR Temperature
			;
			j = WHERE(STRMATCH(engtags, 'ndir_temp', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'NDIR', /normal)
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
			ENDIF
			;
			; Room Temperature
			;
			j = WHERE(STRMATCH(engtags, 'room_temp', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'Room', /normal)
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
			ENDIF

			IF (SIZE(data, /TYPE) EQ 8) THEN BEGIN
				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'TRAP': BEGIN
			data = ''
			;
			; H2O Trap Temperature
			;
			j = WHERE(STRMATCH(engtags, 'trap_temp', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'Trap')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)

				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'SMP_FLOW': BEGIN
			data = ''
			;
			; Sample Flow Rate
			;
			j = WHERE(STRMATCH(engtags, 'smp_flow', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'SMP')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)

				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'REF_FLOW': BEGIN
			data = ''
			;
			; Reference Cell Flow Rate
			;
			j = WHERE(STRMATCH(engtags, 'ref_flow', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'REF')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)

				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'BLEED': BEGIN
			data = ''
			;
			; P1 Bleed Flow Rate
			;
			j = WHERE(STRMATCH(engtags, 'p1_bleed', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'P1')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
			ENDIF
			;
			; P2 Bleed Flow Rate
			;
			j = WHERE(STRMATCH(engtags, 'p2_bleed', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'P2')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
			ENDIF

			IF (SIZE(data, /TYPE) EQ 8) THEN BEGIN
				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'PRESS': BEGIN
			data = ''
			;
			; P1 Pump Pressure
			;
			j = WHERE(STRMATCH(engtags, 'p1_press', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'P1')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)
			ENDIF
			;
			; P2 Pump Pressure
			;
			j = WHERE(STRMATCH(engtags, 'p2_press', /FOLD_CASE) NE 0)
			relay = STRMID(eng.(j), 1)
			f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
			z = READ_RELAY(f, 'P2')
			IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
				data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d2', z) : CREATE_STRUCT(data, 'd2', z)
			ENDIF

			IF (SIZE(data, /TYPE) EQ 8) THEN BEGIN
				PLOT_, data = data, ytitle = ndir.(i), title = title, $
				step = step, dev = dev, pen = pen, nplot = row * col
			ENDIF
			END
		'ROOM_PRESS': BEGIN
			data = ''
			;
			; Room Pressure (SPO only)
			;
			j = WHERE(STRMATCH(engtags, 'room_press', /FOLD_CASE) NE 0)
			IF j[0] NE -1 THEN BEGIN
				relay = STRMID(eng.(j), 1)
				f = qcdir + yrmody[0] + '/' + relay + '/' + STRJOIN(yrmody) + '.' + relay
				z = READ_RELAY(f, 'ROOM')
				IF (SIZE(z, /TYPE) EQ 8) THEN BEGIN
					data = (SIZE(data, /TYPE) NE 8) ? CREATE_STRUCT('d1', z) : CREATE_STRUCT(data, 'd1', z)

					PLOT_, data = data, ytitle = ndir.(i), title = title, $
					step = step, dev = dev, pen = pen, nplot = row * col
				ENDIF
			ENDIF
			END
		ELSE:
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
ENDWHILE

SPAWN, 'rm -f ' + tmpfile
END
