;+
; READ_INSITU_RAW, site = 'tst', date = '2005-12,2006-1', gas = 'co2', inst = 'L3,L8', z
; READ_INSITU_RAW, site = 'sum,tap', date = '2005', gas = 'co2c13', inst = 'o1', data
; READ_INSITU_RAW, site = 'ref', /notsite, date = '2005-12', gas = 'co', inst = 'R5', data
; READ_INSITU_RAW, site = 'ref', date = '2005-12', gas = 'co', inst = 'R5', data
;
; To learn about the returned structure ...
; 
; IDL> help, z, /str
;
; September, 2006 - kam
;-
PRO	READ_INSITU_RAW, $
	date = date, $
	inst = inst, $
	site = site, $
	project = project, $
	gas = gas, $
	notsite = notsite, $
	help = help, $
	data
;
;*****************************************
; Parse keywords
;*****************************************
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(gas) THEN CCG_SHOWDOC
;
;*****************************************
; Initialization
;*****************************************
;
perl = "/home/ccg/ken/idl/qc/in-situ/read_insitu_raw.pl"

z = CREATE_STRUCT($
'str',           '', $
'code',          '', $
'yr',		  0, $
'mo',		  0, $
'dy',	          0, $	
'hr',	          0, $
'mn',		  0, $
'sc',		  0, $
'date',		 0D, $
'volt',		0.0, $
'volt_sd',	0.0, $
'volt_n',	  0, $
'flag',          '', $
'pkht',		 0D, $
'pkar',		 0D, $
'pkwd',		 0D, $
'ret',		0.0, $
'bc',		 '', $
'flow',		0.0, $
'port',	         '')
;
;*****************************************
; Call perl script
;*****************************************
;
args = ''
args = args + ' -g' + gas
IF KEYWORD_SET(site) THEN  args = args + ' -s' + site
IF KEYWORD_SET(date) THEN args = args + ' -d' + date
SPAWN, perl + args, res

data = ''
n = N_ELEMENTS(res)

IF n LE 1 THEN RETURN

data = REPLICATE(z, n)

FOR i = 0, n - 1 DO BEGIN
	;
	; Common to all raw files
	;
	z.str = res[i]

	fields = STRSPLIT(res[i], /EXTRACT)

	z.code = fields[0]
	z.yr = FIX(fields[1])
	z.mo = FIX(fields[2])
	z.dy = FIX(fields[3])
	z.hr = FIX(fields[4])
	z.mn = FIX(fields[5])

	CCG_DATE2DEC, yr = z.yr, mo = z.mo, dy = z.dy, $
        hr = z.hr, mn = z.mn, dec = dec

	z.date = dec
	;
	; ch4, co
	; REF 2006 08 09 00 01  3 2.286568e+06 1.415572e+07  61.9   BB 184.2
	;
	; co2
	; SMP 2006 09 03 00 00 3.07918e-01 1.936e-04 232 .
	; W1  2006 09 03 00 55 2.77088e-01 4.317e-05  12 .
	;
	CASE gas of
	'co2':     BEGIN
	           z.volt = FLOAT(fields[6])
	           z.volt_sd = FLOAT(fields[7])
	           z.volt_n = FIX(fields[8])
	           z.flag = fields[9]
		   END
        ELSE:      BEGIN
                   z.port = FIX(fields[6])
                   z.pkht = DOUBLE(fields[7])
                   z.pkar = DOUBLE(fields[8])
		   z.pkwd = (z.pkht GT 0) ? z.pkar / (z.pkht * 60) : 0
                   z.ret = FLOAT(fields[9])
                   z.bc = fields[10]
                   z.flow = FLOAT(fields[11])
                   END
        ENDCASE

	data[i] = z
ENDFOR
END
