;+
; NAME:
;	CCG_SYSDATE
;
; PURPOSE:
;	Returns computer system date (local time)
;	in a variety of formats.
;
;	Additional formats can easily incorporated
;	into this procedure.  Contact KAM.
;	
; CATEGORY:
;	Miscellaneous.
;
; CALLING SEQUENCE:
;	r=CCG_SYSDATE()
;
; INPUTS:
;	None.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	result:	Returns an anonymous structure
;		containing the computer system date
;		in a variety of formats.
;
;		The following structure tags are integer constants.
;
;		result.yr	<- 4-digit year
;		result.mo	<- 2-digit month (1-12)
;		result.dy	<- 2-digit day (1-31)
;		result.hr	<- 2-digit hour (0-23)
;		result.mn	<- 2-digit minute (0-59)
;		result.day	<- day-of-week (Mon-Sun)
;		result.month	<- month name (January-December)
;
;
;		The following structure tags are string constants.
;
;		result.s0	<- explicit date (ex. 'Fri May 21 07:18:44 1999')
;		result.s1	<- yyyymmdd (ex. '19990521')
;		result.s2	<- yyyymmddhh (ex. '1999052107')
;		result.s3	<- yyyymmddhhmm (ex. '199905210718')
;		result.s4	<- yyyy-mm-dd (ex. '1999-05-21')
;		result.s5	<- yyyy-mm-dd.hhmm (ex. '1999-05-21.0718')
;		result.s6	<- yyyy mm dd (ex. '1999 05 21')
;		result.s7	<- 'MAY 21 1999'
;		result.s8	<- 'October 1999'
;
;		The following structure tags are long constants.
;
;		result.l1	<- yyyymmdd (ex. 19990521)
;		result.l2	<- yyyymmddhh (ex. 1999052107)
;		result.l3	<- julian date (ex. 1999141)
;
;		The following structure tags are double constants.
;
;		result.d1	<- decimal year (ex. 1999.384469...)
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;
;	Example:
;		IDL> r=CCG_SYSDATE()
;		IDL> PRINT, "File creation date:  "+r.s0
;
; MODIFICATION HISTORY:
;	Written, KAM, January 1999.
;-
;
FUNCTION 	CCG_SYSDATE
;
;**************************************
;
;Return to caller if an error occurs
;
;ON_ERROR,2

a=SYSTIME()
CCG_STRTOK,str=a,delimiter=' ',b
CCG_MONTH2INT,mon=b[1],imon=mo
CCG_INT2MONTH,imon=mo,mon=month,/full
yr=FIX(b[4])
dy=FIX(b[2])
hr=FIX(STRMID(b[3],0,2))
mn=FIX(STRMID(b[3],3,2))
sc=FIX(STRMID(b[3],6,2))

CCG_DATE2DEC,yr=yr,mo=mo,dy=dy,hr=hr,mn=mn,dec=dec
CCG_YMD2JUL,yr,mo,dy,jul

result=CREATE_STRUCT( $

	'yr',yr,'mo',mo,'dy',dy,'hr',hr,'mn',mn,'sc',sc,$
	'day',b[0],'month',b[1],$
	's0',a,$
	's1',STRING(FORMAT='(I4.4,2(I2.2))',yr,mo,dy),$
	's2',STRING(FORMAT='(I4.4,3(I2.2))',yr,mo,dy,hr),$
	's3',STRING(FORMAT='(I4.4,4(I2.2))',yr,mo,dy,hr,mn),$
	's4',STRING(FORMAT='(I4.4,2("-",I2.2))',yr,mo,dy),$
	's5',STRING(FORMAT='(I4.4,2("-",I2.2),".",2(I2.2))',yr,mo,dy,hr,mn),$
	's6',STRING(FORMAT='(I4.4,2(1X,I2.2))',yr,mo,dy),$
	's7',STRING(FORMAT='(A3,1X,I2.2,1X,I4.4)',STRUPCASE(b[1]),dy,yr),$
	's8',STRING(FORMAT='(A,1X,I4.4)',month,yr),$
	's9',STRING(FORMAT='(A,1X,I2,A1,1X,I4.4)',month,dy,',',yr),$
  's10',STRING(FORMAT='(I4.4,2("-",I2.2),"T",I2.2,2(":",I2.2))',yr,mo,dy,hr,mn,sc),$

	'l1',yr*10000L+mo*100L+dy,$
	'l2',yr*1000000L+mo*10000L+dy*100L+hr,$
	'l3',jul,$
	'd1',dec)
RETURN,result
END
