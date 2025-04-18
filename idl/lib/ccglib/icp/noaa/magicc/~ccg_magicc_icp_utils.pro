;
; Utilities used in the Magicc ICP procedures  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION        ConvertDate,d
        z = STRCOMPRESS(STRING(d),/RE)
        CASE STRLEN(z) OF
        4:      z = STRMID(z,0,4)+'-'+STRMID(z,4,2)+'-'+STRMID(z,6,2)
        6:      z = STRMID(z,0,4)+'-'+STRMID(z,4,2)
        ELSE:
        ENDCASE
        RETURN, z
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to convert long formatted date (20060101) to dec
FUNCTION	LongDate2Dec, date

	yr = LONG(date / 10000)
	tmp = date - (yr * 10000)
	mo = FIX(tmp / 100)
	dy = FIX(tmp - (mo * 100))
	CCG_DATE2DEC, yr = yr, mo = mo, dy = dy, hr = 0, mn = 0, dec = dec
	RETURN, dec
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to return a list of months between two passed dates
;	Returns yyyymm of each month starting with first month and 
; 	ending with 1 past last month.  Returns yyyymm
;	Ex. pass 20060408,20070408  Returns array year and month
; 		200604 
;		200605 
;		    .
;		    .
;		200704 
;		200705
FUNCTION Month_List, date

	yrmo = date / 100
	yr = yrmo / 100
	mo = yrmo - (yr*100)

	nyears = yr[1] - yr[0]
	nmonths = (nyears * 12) + (mo[1] - mo[0])

	date_time = TIMEGEN(nmonths +2, UNIT='Months', $
	        START=JULDAY((yrmo[0] - (yr[0]*100)),01,yr[0]))

	CALDAT, date_time, month, day, year
	month = STRING(month, FORMAT = '(I02)')

	list = ToString(year) + ToString(month) 
	RETURN, list 
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to determine the analysis number from the event number
;               and the analysis_date
; Returns an integer of the analysis number
;		ex. 1 for first analysis, 2 for second, 3 for 3rd,etc.
FUNCTION        ANALYSIS_NUMBER,$
		default,$
                data,$
                evn,$
                analysis_date

	
	num=FIX(default)	
        j=WHERE(data.evn EQ evn)
	If j[0] EQ -1 THEN RETURN, num
        temp=data[j].adate
        temp=temp(SORT(temp))
        k=WHERE(temp EQ analysis_date)
	IF k[0] EQ -1 THEN RETURN, num
        num=k[0]+1
        RETURN, num


END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTION to find test gas value by date, date is dec
FUNCTION        CYLINDER_VALUES_BY_DATE,$
        date,$
        cyln_values,$
        default

	value=DOUBLE(default)
	j=WHERE(cyln_values.start_date LE date)
	IF j[0] EQ -1 THEN RETURN, value
	tank_index=j[N_ELEMENTS(j)-1]
	IF (cyln_values[tank_index].parameters[0]-1) LE default THEN RETURN, value
	value=0.0
	FOR i=0, cyln_values[tank_index].num_para-1 DO BEGIN
	value=value + cyln_values[tank_index].parameters[i]*(date-cyln_values[tank_index].time_zero)^(i)
	ENDFOR
	RETURN, value

END
; end DETERMINE_CYLN_VALUES_BY_DATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure to make wrkdata structures for each instrument   
;
; Construct pointers to instrument-specific data
; End up with a structure containing a structure for each instrument
PRO 	INSTRUMENT_SPECIFIC_DATA, $
		data = data, $
		inst = inst, $
		wrkdata = wrkdata, $
		ninst = ninst

	FOR i=0,ninst-1 DO BEGIN
	        j = WHERE(STRUPCASE(data.inst) EQ STRUPCASE(inst[i]))
	
	        IF j[0] EQ -1 THEN CONTINUE
			IF SIZE( valid_instruments, /TYPE) EQ 7 THEN $
				valid_instruments = [valid_instruments, inst[i]] ELSE $
				valid_instruments = [inst[i]]

		        wrkdata = (SIZE(wrkdata, /TYPE) NE 8) ? CREATE_STRUCT(inst[i],data[j]) : $
						CREATE_STRUCT(wrkdata,inst[i],data[j])
	
		ENDFOR

        ; Determine the number of valid instruments from the input list for this time period
        ; change inst array to include only valid inst.  Return inst and ninst correlating
        ; to only those instruments passed in that have data associated with them.
        IF SIZE( valid_instruments, /TYPE) EQ 0 THEN BEGIN
		; if no data found for inst during passed date range, return 0 and ''
                ninst = 0
                inst = ''

        ENDIF ELSE BEGIN
                ninst = N_TAGS(wrkdata)
                inst = valid_instruments

        ENDELSE

END
; end INSTRUMENT_SPECIFIC_DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extract assigned values for cylinders from lookup tables.  Either
;	testgas.tab or magicc_target.tab
PRO     CYLINDER_VALUES, sp=sp, filename = filename, cyln_values=cyln_values

;	filename = '/projects/' + STRLOWCASE(sp) + '/' $
;		STRLOWCASE(strategy) + '/tstgas.tab'
	CCG_SREAD,file=filename,skip=18,str_cyln_values
	ncyln_values=N_ELEMENTS(str_cyln_values)


	; create structure template for test gas data
	z=CREATE_STRUCT($
	'start_date',   0D,$
	'tank',         '',$
	'fill',         '',$
	'num_para',     0,$
	'time_zero',    0D,$
	'parameters',   DBLARR(7))

	;initialize structure for cyln_values data
	cyln_values=[z]


	FOR i=0,ncyln_values-1 DO BEGIN
		tmp_str_cyln_values = STRSPLIT(str_cyln_values[i], '#', /EXTRACT)
	        CCG_STRTOK,str=tmp_str_cyln_values[0],delimiter=' ',temp
	        CCG_DATE2DEC,yr=temp[0],mo=temp[1],dy=temp[2],hr=temp[3],dec=dec

	        z.start_date=dec
	        z.tank=temp[4]
	        z.fill=temp[5]
	        z.num_para=FIX(temp[6])
	        z.parameters[*]=0.0D
	        z.time_zero=DOUBLE(temp[7])

	        IF z.num_para NE 0 THEN BEGIN
	                FOR j=0,z.num_para-1 DO z.parameters[j] = DOUBLE(temp[8+j])
	        ENDIF ELSE BEGIN
	                z.parameters[0]=DOUBLE(temp[8])
	        ENDELSE

	        ; Concatenate current record to structure array
	        cyln_values=[cyln_values,z]

	ENDFOR

	cyln_values=cyln_values[1:*]
END
; END CYLN_VALUES.PRO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







