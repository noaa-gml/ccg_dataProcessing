;+
; NAME:
;	CCG_READ	
;
; PURPOSE:
; 	Read a UNIX text or ASCII formatted file.
;	
;	Using the first data record in the file,
;	the procedure determines the data type
;	of each field.  The procedure then assumes
;	that subsequent fields in each column have
;	the same data type.  The procedure returns 
;	the data in an anonymous structure array.
;
;	User may specify 'skip' lines to 
;	skip at the beginning of file.
;
;	User may suppress messages.
;
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_READ,file=filename,skip=3,/nomessages,result
;	CCG_READ,file='/projects/ch4/flask/site/brw.ch4',delimiter=' ',skip=1,result
;	CCG_READ,file='/projects/co/in-situ/brw_data/month/brw199801.co',result
;
; INPUTS:
;	file:	  	source file name.
;
; OPTIONAL INPUT PARAMETERS:
;	skip:		integer specifying the number
;			of lines to skip at the beginning 
;			of the file. 
;
;       delimiter:      Single or multiple-character delimiter.  If no
;                       delimiter is specified then a blank character
;                       (' ') is assumed.
;
;       comment:        Skip lines that begin with the single or multi-character comment
;                       identifier (e.g., ";", "#", "REM").
;
;	nomessages:	If non-zero, messages will be suppressed.
;
;       regex:          If non-zero, then the delimiter is taken as a
;                       regular expression.
;
; OUTPUTS:
;	result:		Anonymous structure array.  The length of the
;			array is determined by the number of data records
;			in the file.  The number of tags in the structure
;			is determined by the number of fields plus 1.
;
;			result[i].str        <- ith record saved as a string constant
;
;			result[i].field1     <- field 1 (column 0) of ith record saved
;						according to the data type determination.
;
;			result[i].field2     <- field 1 (column 1) of ith record saved
;						according to the data type determination.
;			.
;			.
;			.
;
;			result[i].field<n>   <- field <n> (column <n>-1) of ith record saved
;						according to the data type determination.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Fields in each column must be of the same data type.
;
; PROCEDURE:
;
;		Example:
;			CCG_READ,file='/projects/h2/flask/site/mhd.h2',skip=1,result
;		
;			HELP,result,/STR     
;
;			** Structure <4008a390>, 17 tags, length=88, refs=1:
;			STR             STRING    'MHD 1991 06 03 09 50  6188-66 P   541.71 ... '...
;			FIELD1          STRING    'MHD'
;			FIELD2          LONG      1991
;			FIELD3          LONG      6
;			FIELD4          LONG      3
;			FIELD5          LONG      9
;			FIELD6          LONG      50
;			FIELD7          STRING    '6188-66'
;			FIELD8          STRING    'P'
;			FIELD9          DOUBLE    541.71000
;			FIELD10         STRING    '...'
;			FIELD11         STRING    'CS'
;			FIELD12         LONG      1991
;			FIELD13         LONG      6
;			FIELD14         LONG      21
;			FIELD15         LONG      13
;			FIELD16         LONG      44
;
;			CCG_DATE2DEC,yr=r.field2,mo=r.field3,dy=r.field4,hr=r.field5,mn=r.field6,dec=x
;			j=WHERE(STRMID(r.field10,0,2) EQ '..')
;			PLOT,x(j),r(j).field9,PSYM=4
;			.
;			.
;			.
;			END
;
;		
; MODIFICATION HISTORY:
;	Written,  KAM, January 1999.
;-
;
PRO	CCG_READ, $
	file = file, $
	delimiter = delimiter, $
        regex = regex, $
        comment = comment, $
	skip = skip, $
	nomessages = nomessages, $
        datatype=datatype, $
	result, $
	help = help
;
;-----------------------------------------------check input information 
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF NOT KEYWORD_SET(file) THEN BEGIN
	CCG_MESSAGE,"File must be specified.  Exiting ..."
	CCG_MESSAGE,"(ex) CCG_READ,file='~ken/test',result"
	RETURN
ENDIF
;
IF NOT KEYWORD_SET(skip) THEN skip=0
IF NOT KEYWORD_SET(nomessages) THEN nomessages=0 ELSE nomessages=1
IF NOT KEYWORD_SET(delimiter) THEN delimiter=' '
IF NOT KEYWORD_SET(regex) THEN regex=0 ELSE regex=1
result=0
 
; Does file exist?
 
IF FILE_SEARCH(file) EQ "" THEN RETURN
;
IF NOT nomessages THEN CCG_MESSAGE,'Reading '+file+' ...'

CCG_SREAD,file=file,nomessages=1,skip=skip,s
IF s[0] EQ "" THEN RETURN

IF KEYWORD_SET(comment) THEN BEGIN

   ; Modified to include a multi-character comment, e.g., REM
   ; 2009-09-28 (kam)

   j = WHERE(STREGEX(s, '^' + comment, /BOOLEAN) EQ 0)
   s = s[j]

ENDIF

nr = N_ELEMENTS(s)

barr1 = bytarr(256) + 1b
barr1[0:32] = 0b
barr1[48:57] = 0b
barr1[byte('E')] = 0
barr1[byte('+')] = 0
barr1[byte('-')] = 0
barr1[byte('.')] = 0
;
;Determine data type of each field
;using first record.

IF regex EQ 1 THEN BEGIN
   field = STRSPLIT(s[0], delimiter, /extract, /regex)
ENDIF ELSE BEGIN
   IF delimiter EQ ' ' THEN field = STRSPLIT(s[0], /extract) $
   ELSE  field = STRSPLIT(s[0], delimiter, /extract)
ENDELSE
nfields=N_ELEMENTS(field)

fieldtype=STRARR(nfields)

ncond=4
cond=INTARR(ncond)
result=CREATE_STRUCT("str",' ')

FOR i=0L,nfields-1 DO BEGIN
	;
	;initialize conditions
	;
	barr2=barr1
	cond[*]=0
	;
	;number of characters in field
	;
	field[i]=STRTRIM(field[i],2)
	sl=STRLEN(field[i])

        FOR j=0,sl-1 DO BEGIN
                k=BYTE(STRUPCASE(STRMID(field[i],j,1)))
		barr2[k[0]]=0
		;
		;Assess field according to 'ncond' conditions.
		;
		IF k[0] GE 48b AND k[0] LE 57b THEN cond[0]=cond[0]+1
                IF k[0] EQ 46b THEN cond[1]=cond[1]+1
		IF k[0] EQ 69b THEN cond[2]=cond[2]+1
		;
		;if there is a '+' or '-', it should occur as the 
		;first character in the field or as the first character 
		;after an 'E'.
		;
		IF (k[0] EQ 43b OR k[0] EQ 45b) THEN BEGIN
			CASE j OF
			0:	cond[3]=cond[3]+1
			ELSE:	BEGIN
				z=BYTE(STRUPCASE(STRMID(field[i],j-1,1)))
				IF z[0] EQ 69b THEN cond[3]=cond[3]+1 ELSE cond[3]=(-99)
				END
			ENDCASE
		ENDIF
        ENDFOR
	;
	;Now evaluate 'cond' vector.
	;
	fieldn=STRCOMPRESS('field'+STRING(i+1),/RE)
	 
	IF 		TOTAL(barr2) NE TOTAL(barr1) OR $
			cond[0] EQ 0 OR $
			cond[1] GT 1 OR $
			cond[2] GT 1 OR $
			cond[3] LT 0 THEN fieldtype[i]='STRING' $
	ELSE IF 	cond[0] GT 0 AND $
			cond[1] EQ 0 AND $
			cond[2] EQ 0 AND $
			cond[3] GE 0 THEN fieldtype[i]='LONG64' $
	ELSE IF 	cond[0] GT 0 AND $
			(cond[1] EQ 1 OR cond[2] EQ 1) AND $
			cond[3] GE 0 THEN fieldtype[i]='DOUBLE'
	CASE fieldtype[i] OF
	'STRING':	result=CREATE_STRUCT(result,fieldn,' ')
	'LONG64':	result=CREATE_STRUCT(result,fieldn,LONG64(0))
	'DOUBLE':	result=CREATE_STRUCT(result,fieldn,0.0D)
	ENDCASE
ENDFOR

; If "datatype" is set, redefine result structure.
; Added 2011-09-01 (kam)

IF KEYWORD_SET( datatype ) THEN BEGIN

   tags = TAG_NAMES( result )
   ntags = N_ELEMENTS( tags )
   ndatatype = N_ELEMENTS( datatype )
   fieldtype = STRARR( ndatatype )

   IF ndatatype NE ntags-1 THEN RETURN

   result = CREATE_STRUCT("str",' ')
   
   FOR i=0,ndatatype-1 DO BEGIN

      fieldn=STRCOMPRESS('field'+STRING(i+1),/RE)

      CASE STRUPCASE( datatype[i] ) OF
      'S':  BEGIN
            result = CREATE_STRUCT( result, fieldn, " " )
            fieldtype[i] = 'STRING'
            END
      'I':  BEGIN
            result = CREATE_STRUCT( result, fieldn, 0 )
            fieldtype[i] = 'FIX'
            END
      'L':  BEGIN
            result = CREATE_STRUCT( result, fieldn, LONG64(0) )
            fieldtype[i] = 'LONG64'
            END
      'F':  BEGIN
            result = CREATE_STRUCT( result, fieldn, 0.0 )
            fieldtype[i] = 'FLOAT'
            END
      'D':  BEGIN
            result = CREATE_STRUCT( result, fieldn, 0.0D )
            fieldtype[i] = 'DOUBLE'
            END
      ENDCASE

   ENDFOR

ENDIF
;
;Now make a structure array.
;
result=REPLICATE(result,nr)
;
;Now read records and parse accordingly.
;
FOR i=0L,nr-1 DO BEGIN
	result[i].str=s[i]
	;
	; Seems to be a bug in STRSPLIT when file record
	; delimiter is a tab.  June 2005 - kam, amc
	;
        IF regex EQ 1 THEN BEGIN
           IF delimiter EQ ' ' THEN field = STRSPLIT(s[i], /extract, /regex) $
           ELSE  field = STRSPLIT(s[i], delimiter, /extract, /regex)
        ENDIF ELSE BEGIN
           IF delimiter EQ ' ' THEN field = STRSPLIT(s[i], /extract) $
           ELSE  field = STRSPLIT(s[i], delimiter, /extract)
        ENDELSE

	FOR j=0,nfields-1 DO BEGIN
	        result[i].(j+1)=CALL_FUNCTION(fieldtype[j],field[j])
	ENDFOR
ENDFOR
;
IF NOT nomessages THEN CCG_MESSAGE,'Done reading '+file+' ...'
END
