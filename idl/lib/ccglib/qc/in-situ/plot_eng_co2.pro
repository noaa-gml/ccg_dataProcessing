;+
; plot_eng_co2, site = 'mlo', date = '2006-01-01'
; plot_eng_co2, site = 'brw', date = '2006-04'
;-
@ccg_utils.pro

PRO     PLOT_, data = data, ytitle = ytitle, title = title, $
        step = step, dev = dev, pen = pen, window = window, yaxis = yaxis
        ;
        ; Plot data
        ;
        CCG_PLOT, data = data, ytitle = ytitle, $
        title = title, wtitle = title, /insert, $
        linethick = 1, symsize = 0.5, $
        charsize = 2.0, charthick = 1.0, xcustom = step, $
        /nogrid, /nolabid, /noproid, xtitle = 'Local Time', window = window ++, $
        dev = dev, pen = pen, yaxis = yaxis
        ;
        ; Advance Frame
        ;
        !P.MULTI[0] --
END

PRO	NewDate, task, date, yr0, mo0, dy0

DAY = 0.002739726D

IF dy0 NE 0 THEN BEGIN
	CCG_DATE2DEC, yr = yr0, mo = mo0, dy = dy0, dec = dec
	dec = (task EQ 'inc') ? dec + DAY : dec - DAY
	CCG_DEC2DATE, dec, yr0, mo0, dy0

	date = STRING(FORMAT = '(I4.4,A1,I2.2,A1,I2.2)', yr0, '-', mo0, '-', dy0)
ENDIF ELSE BEGIN
	mo0 = (task EQ 'inc') ? ++ mo0 : -- mo0
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

PRO	PLOT_ENG_CO2, $
	dev = dev, site = site, date = date, $
   nogrid = nogrid, $
	help = help

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

today = CCG_SYSDATE()
tmpfile = CCG_TMPNAM()

site = (KEYWORD_SET(site)) ? STRLOWCASE(site) : 'mlo'
date = (KEYWORD_SET(date)) ? date : STRING(FORMAT = '(I4.4,A1,I2.2)', today.yr, "-", today.mo)
fig = KEYWORD_SET(fig) ? fig : 3
all = KEYWORD_SET(all) ? 1 : 0
nogrid = KEYWORD_SET(nogrid) ? 1 : 0
rm_errors = KEYWORD_SET(rm_errors) ? 1 : 0
wdir = '/projects/co2/in-situ/' + site + '_data/'
qcdir = wdir + 'qc/'
voltdir = wdir + 'data/'

dev = (KEYWORD_SET(dev)) ? dev : ''
window = 0
id = ['']
colorarr = [0]
DEFAULT = (-999.99)
;
; By Day or by Month?
;
tmp = STRSPLIT(date, "-", /EXTRACT)
yr0 = FIX(tmp[0])

CASE N_ELEMENTS(tmp) OF
1:	BEGIN
	step = 'month'
	mo0 = 1
	dy0 = 0
	END
2:	BEGIN
	step = 'month'
	mo0 = FIX(tmp[1])
	dy0 = 0
	END
3:	BEGIN
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
	'_102',        'NDIR Temperature (!eo!nC)', $
	'_109',        'Room Temperature (!eo!nC)', $
	'_110',        'H!i2!nO Trap Temperature (!eo!nC)', $
	'_103',        'Sample Gas Flow Rate (ml min!e-1!n)', $
	'_104',        'Reference Gas Flow Rate (ml min!e-1!n)', $
	'_111',        'P1 Bleed Flow Rate (L min!e-1!n)', $
	'_112',        'P2 Bleed Flow Rate (L min!e-1!n)', $
	'_113',        'P1 Pressure (psi)', $
	'_114',        'P2 Pressure (psi)')
	END
'spo':	BEGIN
	eng = CREATE_STRUCT( $
	'_102',        'NDIR Temperature (!eo!nC)', $
	'_109',        'Room Temperature (!eo!nC)', $
	'_110',        'H!i2!nO Trap Temperature (!eo!nC)', $
	'_103',        'Sample Gas Flow Rate (ml min!e-1!n)', $
	'_104',        'Reference Gas Flow Rate (ml min!e-1!n)', $
	'_111',        'P1 Bleed Flow Rate (L min!e-1!n)', $
	'_112',        'P2 Bleed Flow Rate (L min!e-1!n)', $
	'_113',        'P1 Pressure (psi)', $
	'_114',        'P2 Pressure (psi)', $
	'_117',        'Room Pressure (psi)')
	END
'brw':	BEGIN
	eng = CREATE_STRUCT( $
	'_102',        'NDIR Temperature (!eo!nC)', $
	'_108',        'Room Temperature (!eo!nC)', $
	'_109',        'H!i2!nO Trap Temperature (!eo!nC)', $
	'_103',        'Sample Gas Flow Rate (ml min!e-1!n)', $
	'_104',        'Reference Gas Flow Rate (ml min!e-1!n)', $
	'_110',        'P1 Bleed Flow Rate (L min!e-1!n)', $
	'_111',        'P2 Bleed Flow Rate (L min!e-1!n)', $
	'_112',        'P1 Pressure (psi)', $
	'_113',        'P2 Pressure (psi)')
	END
'smo':	BEGIN
	eng = CREATE_STRUCT( $
	'_102',        'NDIR Temperature (!eo!nC)', $
	'_108',        'Room Temperature (!eo!nC)', $
	'_109',        'H!i2!nO Trap Temperature (!eo!nC)', $
	'_103',        'Sample Gas Flow Rate (ml min!e-1!n)', $
	'_104',        'Reference Gas Flow Rate (ml min!e-1!n)', $
	'_110',        'P1 Bleed Flow Rate (L min!e-1!n)', $
	'_111',        'P2 Bleed Flow Rate (L min!e-1!n)', $
	'_112',        'P1 Pressure (psi)', $
	'_113',        'P2 Pressure (psi)')
	END
ELSE:	CCG_FATALERR, "Don't yet know about " + site + "."
ENDCASE

tags = TAG_NAMES(eng)
ntags = N_ELEMENTS(tags)

row = CEIL(SQRT(ntags))
col = CEIL(FLOAT(ntags) / row)

forever = 1
WHILE forever DO BEGIN

	z = GET_SCREEN_SIZE()
	CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, xpixels = 1.29 * 0.95 * z[1], ypixels = 0.95 * z[1]

	!P.MULTI = [ntags, col, row, 0, 1]

	FOR i = 0, ntags - 1 DO BEGIN

		relay = STRMID(tags[i], 1)
		dir = qcdir + ToString(yr0) + '/' + relay + '/'

		IF step EQ 'month' THEN BEGIN
			SPAWN, 'cat ' + dir + ToString(yr0 * 100L + mo0) + '??.' + relay + ' > ' + tmpfile
			file = tmpfile
		ENDIF ELSE BEGIN
			file = dir + ToString(yr0 * 10000L + mo0 * 100L + dy0) + '.' + relay
		ENDELSE
		;
		; Read file
		;
		CCG_READ, file = file, z

		IF (SIZE(z, /TYPE) NE 8) THEN CONTINUE
		;
		; Prep data
		;
		CCG_DATE2DEC, yr = z.field1, mo = z.field2, dy = z.field3, $
		hr = z.field4, mn = z.field5, sc = z.field6, dec = x

		d = CREATE_STRUCT('x', x, 'y', REFORM(z.field7))

		data = CREATE_STRUCT('d', d)
		;
		; Plot data
		;
                PLOT_, data = data, ytitle = eng.(i), title = date, $
                step = step, dev = dev, pen = pen, window = window
	ENDFOR
	CCG_CLOSEDEV, dev = dev
	;
	; EventHandle
	;
	CURSOR, xd0, yd0, /DOWN, /DATA
	n0 = CONVERT_COORD(xd0, yd0, /DATA, /TO_NORMAL)

	IF !MOUSE.BUTTON EQ 4 THEN forever = 0

	IF !MOUSE.BUTTON EQ 1 THEN BEGIN
		
		IF n0[0] LT 0.5 THEN NewDate, 'dec', date, yr0, mo0, dy0
		IF n0[0] GE 0.5 THEN NewDate, 'inc', date, yr0, mo0, dy0
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
