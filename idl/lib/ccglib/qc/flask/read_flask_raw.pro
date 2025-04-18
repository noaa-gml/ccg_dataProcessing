;+
; READ_FLASK_RAW, site = 'tst', date = '2005-12,2006-1', gas = 'co2', inst = 'L3,L8', z
; READ_FLASK_RAW, site = 'sum,tap', date = '2005', gas = 'co2c13', inst = 'o1', data
; READ_FLASK_RAW, site = 'ref', /notsite, date = '2005-12', gas = 'co', inst = 'R5', data
; READ_FLASK_RAW, site = 'ref', date = '2005-12', gas = 'co', inst = 'R5', data
;
; To learn about the returned structure ...
; 
; IDL> help, z, /str
;
; July 20, 2006 - kam
;-
PRO	READ_FLASK_RAW, $
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
IF NOT KEYWORD_SET(inst) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(gas) THEN CCG_SHOWDOC
project = KEYWORD_SET(project) ? project : ['flask', 'pfp']
;
;*****************************************
; Initialization
;*****************************************
;
perl = "/home/ccg/ken/idl/qc/flask/read_flask_raw.pl"
data = ''

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
'id',            '', $
'me',            '', $
'volt',		0.0, $
'pkht',		 0D, $
'pkar',		 0D, $
'pkwd',		 0D, $
'ret',		0.0, $
'bc',		 '', $
'flow',		0.0, $
'port',	         '', $
'ayr',		  0, $
'amo',		  0, $
'ady',	          0, $	
'ahr',	          0, $
'amn',		  0, $
'asc',		  0, $
'adate',	 0D)
;
;*****************************************
; Loop through projects
;*****************************************
;
FOR ip = 0, N_ELEMENTS(project) - 1 DO BEGIN
	;
	;*****************************************
	; Call perl script
	;*****************************************
	;
	args = ''
	args = args + ' -i' + inst
	args = args + ' -g' + gas
	args = args + ' -p' + project[ip]
	IF KEYWORD_SET(site) THEN  args = args + ' -s' + site
	IF KEYWORD_SET(date) THEN args = args + ' -d' + date
	IF KEYWORD_SET(notsite) THEN args = args + ' -n'
	SPAWN, perl + args, res

	n = N_ELEMENTS(res)

	IF n LE 1 THEN CONTINUE

	tmpdata = REPLICATE(z, n)

	FOR i = 0, n - 1 DO BEGIN
		;
		; Common to all raw files
		;

		z.str = res[i]

		fields = STRSPLIT(res[i], /EXTRACT)
		z.code = fields[0]

		tmp = STRSPLIT(fields[1], "-", /EXTRACT)
		z.yr = FIX(tmp[0])
		z.mo = FIX(tmp[1])
		z.dy = FIX(tmp[2])

		tmp = STRSPLIT(fields[2], ":", /EXTRACT)
		z.hr = FIX(tmp[0])
		z.mn = FIX(tmp[1])
		z.sc = FIX(tmp[2])

		CCG_DATE2DEC, yr = z.yr, mo = z.mo, dy = z.dy, $
		hr = z.hr, mn = z.mn, sc = z.sc, dec = dec
		z.date = dec

		z.id = fields[3]
		z.me = fields[4]
		z.ayr = FIX(fields[5])
		z.amo = FIX(fields[6])
		z.ady = FIX(fields[7])
		z.ahr = FIX(fields[8])
		z.amn = FIX(fields[9])
		;
		; Skip second information if it exists
		;
		CCG_DATE2DEC, yr = z.ayr, mo = z.amo, dy = z.ady, $
		hr = z.ahr, mn = z.amn, dec = dec
		z.adate = dec

		CASE gas of
		'co2':     BEGIN
			   z.volt = FLOAT(fields[10])
			   z.flow = FLOAT(fields[11])
			   END
		'co2c13':  BEGIN
			   z.port = fields[12]
			   END
		ELSE:      BEGIN
			   z.pkht = DOUBLE(fields[10])
			   z.pkar = DOUBLE(fields[11])
                           z.pkwd = (z.pkht GT 0) ? z.pkar / (z.pkht * 60) : 0
			   z.ret = FLOAT(fields[12])
			   z.bc = fields[13]
			   z.flow = FLOAT(fields[14])
			   END
		ENDCASE

		tmpdata[i] = z
	ENDFOR
	data = (SIZE(data, /TYPE) NE 8) ? tmpdata : [data, tmpdata]
ENDFOR
;
; Sort on Analysis date
;
IF SIZE(data, /TYPE) EQ 8 THEN data = data[SORT(data.adate)]
END
