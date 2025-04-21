;+
; MAKE_HEADER, project = 'flask', sp = 'co2', x
; MAKE_HEADER, project = 'ccg', sp = 'co2', x
;-
;
; Get Utility functions
;
@ccg_utils.pro
;
PRO	MAKE_HEADER, $
	project = project, $
	sp = sp, $
	header

IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(project) THEN CCG_SHOWDOC
;
; Misc Initialization
;
sp = STRLOWCASE(sp)
project = STRLOWCASE(project)
IF project EQ 'ccg' THEN sp = 'ccg'
wdir = '/projects/ftp/'
z = CCG_SYSDATE()
today = z.s0
;
;Read PI Details
;
CCG_SREAD, file = wdir + project + '_pi.txt', pi

i = 0
REPEAT BEGIN
	CCG_STRTOK, delimiter = ',', str = pi[i], fields
	i ++
ENDREP UNTIL fields[0] EQ sp

str = 'Contact:  ' + fields[1] + ' (' + STRTRIM(fields[2],2) + '; ' + STRTRIM(fields[3],2) + ')'
;
; Read Header Template
;
CCG_SREAD, file = wdir + 'readme/general.header', header
;
; Add Details
;
; Usage?
;
j = WHERE(header EQ '<<general usage>>')
IF j[0] NE -1 THEN BEGIN
	CCG_SREAD, file = wdir + 'readme/general.usage', arr
	header = [header[0 : j - 1], arr, header[j + 1 : *]]
ENDIF
;
; Reciprocity?
;
j = WHERE(header EQ '<<general reciprocity>>')
IF j[0] NE -1 THEN BEGIN
	CCG_SREAD, file = wdir + 'readme/general.reciprocity', arr
	header = [header[0 : j - 1], arr, header[j + 1 : *]]
ENDIF
;
;Add gas-specific information
;
j = WHERE(header EQ '<<<pi>>>')
header[j] = str
;
;Add date stamp to data file
;
j = WHERE(header EQ '<<<date>>>')
header[j] = 'File Creation:  ' + today

header = [header, ' ']
END
