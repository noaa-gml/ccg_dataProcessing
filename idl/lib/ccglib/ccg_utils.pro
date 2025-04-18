;+
; NAME:
;       CCG_UTILS
;
; PURPOSE:
;       Provide some low-level IDL utilities
;
; USAGE:
;       @ccg_utils.pro
;-


FUNCTION        dateDB, d
   
   RETURN, STRMID(d, 0, 4) + '-' + STRMID(d, 4, 2) + '-' + STRMID(d, 6, 2)

END

FUNCTION        timeDB, t
   
   RETURN, STRMID(t, 0, 2) + ':' + STRMID(d, 2, 2) + ':' + STRMID(d, 4, 2)

END

FUNCTION        StartDate, date
   d = LONG(date)
   d = (d LE 9999) ? d*10000L + 101 : d
   d = (d LE 999999L) ? d*100L + 1 : d
   RETURN, LONG(d)
END

FUNCTION        EndDate, date
   d = LONG(date)
   d = (d LE 9999) ? d*10000L + 1231 : d
   d = (d LE 999999L) ? d*100L + 31 : d
   RETURN, LONG(d)
END

FUNCTION   ToString, v
   RETURN, STRCOMPRESS(STRING(v), /RE)
END

FUNCTION   StringPad, v, c, l
    z = SIZE(v, /TYPE) NE 7 ? ToString(v) : v
    FOR i = l - STRLEN(z) - 1, 0, -1 DO z = c + z
    RETURN, z
END

FUNCTION        ValidDate, date

   dim = [[-9, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
          [-9, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]

   READS, ToString(date), FORMAT = '(I4.4,2(I2))', yr, mo, dy

   IF mo LT 1 OR mo GT 12 OR dy LT 1 OR dy GT 31 THEN RETURN, 0

   bool = (dy GE 1 AND dy LE dim[mo, CCG_LEAPYEAR(yr)]) ? 1 : 0
   RETURN, bool
END

FUNCTION        DateDB, date
   s = STRCOMPRESS(STRING(date), /RE)
   RETURN, STRMID(s, 0, 4) + '-' + STRMID(s, 4, 2) + '-' + STRMID(s, 6, 2)
END

FUNCTION        TimeDB, time
   s = STRCOMPRESS(STRING(time), /RE)
   RETURN, STRMID(s, 0, 2) + ':' + STRMID(s, 2, 2) + ':' + STRMID(s, 4, 2)
END

FUNCTION        DateDB2Long, date

   yr = 0L & mo = 0L & dy = 0L
   READS, date, FORMAT = '(I4.4,2(1X,I2))', yr, mo, dy
   RETURN, yr*10000L + mo*100L + dy
END

FUNCTION        TimeDB2Long, time

   hr = 0L & mn = 0L & sc = 0L
   READS, time, FORMAT = '(I2,2(1X,I2))', hr, mn, sc
   RETURN, hr*10000L + mn*100L + sc
END

FUNCTION DateObject, date=date, idate=idate, dd=dd, isodate=isodate, ed=ed

   ; This function returns a date object. User may supply
   ; 1) LONG or STRING date.  Format is 20080131233828. 
   ;    Any portion of the date may be specified.

   ; 2) DOUBLE decimal date, e.g., dd=2008.0846585964379756D

   ; 3) INTEGER date vector e.g, idate = [2008,1,31,23,38,28].
   ;    Any portion of the date may be specified.

   ; 4) ISODATE date e.g, isodate = '2011-08-31T14:58'.
   ;    Any portion of the isodate may be specified.

   ; Written 2008-10-31 (kam)

   dim = [[-9, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
          [-9, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]

   ed = KEYWORD_SET(ed) ? 1 : 0

   obj = CREATE_STRUCT( $
   'yr', 0, 'mo', 1, 'dy', 1, 'hr', 0, 'mn', 0, 'sc', 0, 'dd', 0D, 'jul', 0L, $
   'longdate', 0L, 'longtime', 0L, 'STRdate', '', 'STRtime', '', $
   'DBdate', '0000-00-00', 'DBtime', '00:00:00', $
   'idate', [0,0,0,0,0,0] )

   IF KEYWORD_SET(dd) THEN BEGIN

      CCG_DEC2DATE, dd, yr, mo, dy, hr, mn, sc

      tidate = [yr, mo, dy, hr, mn, sc]

   ENDIF

   IF KEYWORD_SET(date) THEN BEGIN

      tmp = STRARR(6)
      READS, ToString(date), FORMAT='(A4,:,A2,:,A2,:,A2,:,A2,:,A2)', tmp

      j = WHERE(tmp NE "  ")

      CASE N_ELEMENTS(j) OF

      1: tidate = ed EQ 0 ? [FIX(tmp[0]), 1, 1, 0, 0, 0] : [FIX(tmp[0]), 12, 31, 23, 59, 59]
      2: BEGIN
         yr = FIX( tmp[0] )
         mo = FIX( tmp[1] )
         dy = dim[mo, CCG_LEAPYEAR(yr)]
         tidate = ed EQ 0 ? [FIX(tmp[0:1]), 1, 0, 0, 0] : [yr, mo, dy, 23, 59, 59]
         END
      3: tidate = ed EQ 0 ? [FIX(tmp[0:2]), 0, 0, 0] : [FIX(tmp[0:2]), 23, 59, 59]
      4: tidate = ed EQ 0 ? [FIX(tmp[0:3]), 0, 0] : [FIX(tmp[0:3]), 59, 59]
      5: tidate = ed EQ 0 ? [FIX(tmp[0:4]), 0] : [FIX(tmp[0:4]), 59]
      6: tidate = FIX(tmp[0:5])
      ELSE:

      ENDCASE

   ENDIF

   IF KEYWORD_SET(isodate) THEN BEGIN

      tmp = STRARR(6)

      j = STRSPLIT( isodate, "\-|\:|T", /EXTRACT )
      
      CASE N_ELEMENTS(j) OF

      1: tidate = ed EQ 0 ? [FIX(j[0]), 1, 1, 0, 0, 0] : [FIX(j[0]), 12, 31, 23, 59, 59]
      2: BEGIN
         yr = FIX( j[0] )
         mo = FIX( j[1] )
         dy = dim[mo, CCG_LEAPYEAR(yr)]
         tidate = ed EQ 0 ? [FIX(j[0:1]), 1, 0, 0, 0] : [yr,mo,dy, 23, 59, 59]
         END
      3: tidate = ed EQ 0 ? [FIX(j[0:2]), 0, 0, 0] : [FIX(j[0:2]), 23, 59, 59]
      4: tidate = ed EQ 0 ? [FIX(j[0:3]), 0, 0] : [FIX(j[0:3]), 59, 59]
      5: tidate = ed EQ 0 ? [FIX(j[0:4]), 0] : [FIX(j[0:4]), 59]
      6: tidate = FIX(tmp[0:5])
      ELSE:

      ENDCASE

   ENDIF

   IF KEYWORD_SET(idate) THEN BEGIN

      CASE N_ELEMENTS(idate) OF
      1: tidate = ed EQ 0 ? [idate, 1, 1, 0, 0, 0] : [idate, 12, 31, 23, 59, 59]
      2: BEGIN
         dy = dim[idate[1], CCG_LEAPYEAR(idate[0])]
         tidate = ed EQ 0 ? [idate, 1, 0, 0, 0] : [idate, dy, 23, 59, 59]
         END
      3: tidate = ed EQ 0 ? [idate, 0, 0, 0] : [idate, 23, 59, 59]
      4: tidate = ed EQ 0 ? [idate, 0, 0] : [idate, 59, 59]
      5: tidate = ed EQ 0 ? [idate, 0] : [idate, 59]
      6: tidate = idate
      ELSE:

      ENDCASE         

   ENDIF

   obj.idate = tidate

   obj.yr = obj.idate[0]
   obj.mo = obj.idate[1]
   obj.dy = obj.idate[2]
   obj.hr = obj.idate[3]
   obj.mn = obj.idate[4]
   obj.sc = obj.idate[5]

   obj.STRdate = STRING(FORMAT='(I4.4,2(I2.2))', obj.yr, obj.mo, obj.dy)
   obj.longdate = LONG(obj.STRdate)
   obj.DBdate = dateDB(obj.STRdate)

   obj.STRtime = STRING(FORMAT='(3(I2.2))', obj.hr, obj.mn, obj.sc)
   obj.longtime = LONG(obj.STRtime)
   obj.DBtime = timeDB(obj.STRtime)

   CCG_YMD2JUL, obj.yr, obj.mo, obj.dy, jul
   obj.jul = jul

   CCG_DATE2DEC, yr=obj.yr, mo=obj.mo, dy=obj.dy, hr=obj.hr, mn=obj.mn, sc=obj.sc, dec=dec
   obj.dd = dec

   RETURN, obj

END

FUNCTION   SetDataLimit, data, min, max

   j = WHERE(data LT min)
   IF j[0] NE -1 THEN data[j] = min

   j = WHERE(data GT max)
   IF j[0] NE -1 THEN data[j] = max
   RETURN, data
END

FUNCTION   OldSiteFormat, d

   format = '(A3, 1X, I4.4, 4(1X, I2.2), 1X, A8, 1X, A1, 1X, F9.3'
   format = format + ', 1X, A3, 1X, A2, 1X, I4.4, 4(1X, I2.2))'
   
   RETURN, STRING(FORMAT = format, $
   d.code, d.yr, d.mo, d.dy, d.hr, d.mn, d.id, d.meth, $
   d.value, d.flag, d.inst, d.ayr, d.amo, d.ady, d.ahr, d.amn)
END

FUNCTION   DBFormat, d
   ; 
   ; Format used by CCG_FLASKUPDATE
   ;
   ; evn:159040|param:CH4|value:1801.17|flag:...|inst:H4|yr:2004|mo:03|dy:22|hr:09|mn:11|sc:0
   ;

   nvpairs = ['evn:'+STRING(d.evn)]
   nvpairs = [nvpairs,'param:'+STRING(d.parameter)]
   nvpairs = [nvpairs,'value:'+STRING(d.value)]
   nvpairs = [nvpairs,'flag:'+STRING(d.flag)]
   nvpairs = [nvpairs,'inst:'+STRING(d.inst)]
   nvpairs = [nvpairs,'yr:'+STRING(d.ayr)]
   nvpairs = [nvpairs,'mo:'+STRING(d.amo)]
   nvpairs = [nvpairs,'dy:'+STRING(d.ady)]
   nvpairs = [nvpairs,'hr:'+STRING(d.ahr)]
   nvpairs = [nvpairs,'mn:'+STRING(d.amn)]
   nvpairs = [nvpairs,'sc:'+STRING(d.asc)]

   tags = TAG_NAMES(d)

   program_idx = WHERE(tags EQ 'PROGRAM')

   IF ( N_ELEMENTS(program_idx) GT 1 OR program_idx NE -1 ) THEN BEGIN
      nvpairs = [nvpairs,'program:'+STRING(d.program)]
   ENDIF

   RETURN, STRJOIN(nvpairs, '|')
END

FUNCTION   ClipOnXRange, data
   ;
   ; If there exist data that fall outside
   ; defined axis range, set on range limits
   ;
   d = data
   j = WHERE(d LT MIN(!X.CRANGE))
   IF j[0] NE -1 THEN d[j] = MIN(!X.CRANGE)

   j = WHERE(d GT MAX(!X.CRANGE))
   IF j[0] NE -1 THEN d[j] = MAX(!X.CRANGE)

   RETURN, d
END

FUNCTION   ClipOnYRange, data
   ;
   ; If there exist data that fall outside
   ; defined axis range, set on range limits
   ;
   d = data
   j = WHERE(d LT MIN(!Y.CRANGE))
   IF j[0] NE -1 THEN d[j] = MIN(!Y.CRANGE)

   j = WHERE(d GT MAX(!Y.CRANGE))
   IF j[0] NE -1 THEN d[j] = MAX(!Y.CRANGE)

   RETURN, d
END

FUNCTION   ClipOnZRange, data
   ;
   ; If there exist data that fall outside
   ; defined axis range, set on range limits
   ;
   d = data
   j = WHERE(d LT MIN(!Z.CRANGE))
   IF j[0] NE -1 THEN d[j] = MIN(!Z.CRANGE)

   j = WHERE(d GT MAX(!Z.CRANGE))
   IF j[0] NE -1 THEN d[j] = MAX(!Z.CRANGE)

   RETURN, d
END

PRO     PLOT_LOGO,      x, y, $
                        xsize = xsize, $
                        ysize = ysize, $
                        page = page, $
                        portrait = portrait, $
                        dev = dev, $
                        pen = pen, $
                        file = file

   ; Add an image to an existing graphic
   ; If output is to screen, image will be grayed.

   ; Modified to include gif, png, tiff. 2008-10-10 (kam)

   ; Return if file does not exist
   
   IF FILE_TEST(file) EQ 0 THEN RETURN
    
   dev = KEYWORD_SET(dev) ? dev : ''
   ysize = KEYWORD_SET(ysize) ? ysize : 0
   xsize = KEYWORD_SET(xsize) ? xsize : 0

   ; default is landscape

   portrait = KEYWORD_SET(portrait) ? portrait : 0

   ; 'page' keyword is obsolete but backward-compatable

   IF KEYWORD_SET(page) THEN BEGIN

      portrait = page EQ 'portrait' ? 1 : 0
   
   ENDIF

    
   dev_ratio = (portrait EQ 1) ? 1.294 : 0.775
   xsize *= dev_ratio

   xpos = x - xsize / 2.0
   ypos = y - ysize / 2.0

   IF dev NE '' THEN BEGIN

      ; save r,g,b of current color table

      TVLCT, r0,g0,b0, /GET

      IF STREGEX(file, 'jpg$', /FOLD_CASE, /BOOLEAN) NE 0 THEN BEGIN

         READ_JPEG, file, /TRUE, a

         s = SIZE(a)
         ysize = ysize GT 0 ? ysize : xsize / dev_ratio * s[3] / s[2]

         TV, a, /TRUE, xpos, ypos, /NORMAL, XSIZE=xsize, YSIZE=ysize

      ENDIF

      IF STREGEX(file, 'gif$', /FOLD_CASE, /BOOLEAN) NE 0 THEN BEGIN

         READ_GIF, file, a, r, g, b

         s = SIZE(a)
         ysize = ysize GT 0 ? ysize : xsize / dev_ratio * s[2] / s[1]

         TVLCT, r, g, b
         TV, a, xpos, ypos, /NORMAL, XSIZE=xsize, YSIZE=ysize

      ENDIF

      IF STREGEX(file, 'png$', /FOLD_CASE, /BOOLEAN) NE 0 THEN BEGIN

         READ_PNG, file, a, r, g, b

         s = SIZE(a)
         ysize = ysize GT 0 ? ysize : xsize / dev_ratio * s[2] / s[1]

         TVLCT, r, g, b
         TV, a, xpos, ypos, /NORMAL, XSIZE=xsize, YSIZE=ysize

      ENDIF

      IF STREGEX(file, 'tiff$', /FOLD_CASE, /BOOLEAN) NE 0 THEN BEGIN

         READ_TIFF, file, a, r, g, b

         s = SIZE(a)
         ysize = ysize GT 0 ? ysize : xsize / dev_ratio * s[2] / s[1]

         TVLCT, r, g, b
         TV, a, xpos, ypos, /NORMAL, XSIZE=xsize, YSIZE=ysize

      ENDIF

      TVLCT, r0, g0, b0

	ENDIF ELSE BEGIN

		x2 = xpos + xsize
		y2 = ypos + ysize
		POLYFILL, [xpos, x2, x2, xpos], [ypos, ypos, y2, y2], /NORMAL, COLOR = pen[75]

	ENDELSE
END

FUNCTION DataType, val, initval
;
; Determine the data type of the passed value.  
; This function was needed to determine the data
; types of values that were returned from STRSPLIT.
;
; Users should use the SIZE command if the input 
; value is a data type other than STRING.
;
; September 27, 2006 - kam
;
str = STRCOMPRESS(STRUPCASE(STRING(val)), /RE)

barr1 = BYTARR(256) + 1b
barr1[0:32] = 0b
barr1[48:57] = 0b
barr1[BYTE('E')] = 0
barr1[BYTE('+')] = 0
barr1[BYTE('-')] = 0
barr1[BYTE('.')] = 0

ncond = 4
cond = INTARR(ncond)
;
;initialize conditions
;
barr2 = barr1
;
; loop through each character in string
;
FOR i = 0, STRLEN(str) - 1 DO BEGIN

   b = BYTE(STRMID(str, i, 1))
   barr2[b] = 0
   ;
   ; Assess character according to 'ncond' conditions.
   ;
   IF b GE 48b AND b LE 57b THEN cond[0] ++
   IF b EQ 46b THEN cond[1] ++
   IF b EQ 69b THEN cond[2] ++
   ;
   ; If there is a '+' or '-', it should occur as the 
   ; first character in the field or as the first character 
   ; after an 'E'.
   ;
   IF (b EQ 43b OR b EQ 45b) THEN BEGIN
      IF i EQ 0 THEN cond[3] ++ ELSE BEGIN
         z = BYTE(STRMID(str, i - 1, 1))
         cond[3] = z[0] EQ 69b ?  cond[3] ++ : -99
      ENDELSE
   ENDIF
ENDFOR
;
; Now evaluate 'cond' vector.
;
IF   TOTAL(barr2) NE TOTAL(barr1) OR $
     cond[0] EQ 0 OR $
     cond[1] GT 1 OR $
     cond[2] GT 1 OR $
     cond[3] LT 0 THEN BEGIN
         initval = ''
         RETURN, 'STRING'
ENDIF

IF   cond[0] GT 0 AND $
     cond[1] EQ 0 AND $
     cond[2] EQ 0 AND $
     cond[3] GE 0 THEN BEGIN
         initval = 0L
         RETURN, 'LONG64'
ENDIF

IF   cond[0] GT 0 AND $
    (cond[1] EQ 1 OR cond[2] EQ 1) AND $
     cond[3] GE 0 THEN BEGIN
         initval = 0D
         RETURN, 'DOUBLE'
ENDIF
END

FUNCTION   LongCode, code = code, lab = lab, project = project
   ;
   ; This temporary code will build GLOBALVIEW-like name
   ;
   IF NOT KEYWORD_SET(lab) THEN lab = 1
   IF NOT KEYWORD_SET(project) THEN project = 'flask'
   c = code
   nc = N_ELEMENTS(c)
   ;
   CASE project OF
      'flask': BEGIN
               strategy = MAKE_ARRAY(nc, /STR, VALUE = 'D')
               platform = MAKE_ARRAY(nc, /STR, VALUE = '0')
               j = WHERE(STRMATCH(c, 'POC', /FOLD_CASE) OR $
                         STRMATCH(c, 'OPC', /FOLD_CASE) OR $
                         STRMATCH(c, 'WPC', /FOLD_CASE) OR $
                         STRMATCH(c, 'APC', /FOLD_CASE))

               IF j[0] NE -1 THEN platform[j] = '1'
               END
      'pfp':   BEGIN
               strategy = MAKE_ARRAY(nc, /STR, VALUE = 'D')
               platform = MAKE_ARRAY(nc, /STR, VALUE = '2')
               END
      'obs':   BEGIN
               strategy = MAKE_ARRAY(nc, /STR, VALUE = 'C')
               platform = MAKE_ARRAY(nc, /STR, VALUE = '0')
               END
      'tower': BEGIN
               strategy = MAKE_ARRAY(nc, /STR, VALUE = 'C')
               platform = MAKE_ARRAY(nc, /STR, VALUE = '3')
               END
   ENDCASE
   c = STRUPCASE(c + '_' + StringPad(lab, '0', 2) + strategy + platform)
   RETURN, c
END

FUNCTION GetStats, in

   v = in[SORT(in)]
   n = N_ELEMENTS(v)

   ; compute normal statistics

   r = MOMENT(v)

   mn = r[0]
   sd = SQRT(r[1])
   se = sd / SQRT(n)

   ; compute percentiles

   q16 = v[LONG(0.16 * n)]
   q25 = v[LONG(0.25 * n)]
   q50 = (n MOD 2L) ? v[(n + 1L) / 2] : (v[n / 2L] + v[n / 2L + 1]) / 2
   q75 = v[LONG(0.75 * n)]
   q84 =v[LONG(0.84 * n)]

   z = ABS(v - q50)
   z = z[SORT(z)]
   mad = (n MOD 2L) ? z[(n + 1L) / 2] : (z[n / 2L] + z[n / 2L + 1]) / 2

   RETURN, [mn, sd, se, q16, q25, q50, q75, q84, mad]

END

FUNCTION MomentByYear, x=x, y=y, byall=byall, bymonth=bymonth, byyear=byyear
   ;
   ;*************************************************
   ; Compute Mean and Standard Deviation by Year
   ;*************************************************
   ;
   DEFAULT = (-999.999)
   byall = KEYWORD_SET(byall) ? 1 : 0 
   byyear = KEYWORD_SET(byyear) ? 1 : 0 
   bymonth = KEYWORD_SET(bymonth) ? 1 : 0 
   format = '(A16,F16.4,F16.4,I16)'
   a = { text:'', mn:DEFAULT, sd:DEFAULT, n:0 } 
   res = 0

   CCG_DEC2DATE, x, yr, mo, dy
   n = N_ELEMENTS(x)
   
   ; First compute for all data

   mn = MEAN(y)
   sd = n GT 2 ? STDDEV(y) : DEFAULT

   IF byall EQ 1 THEN BEGIN

      a.text = ToString(MIN(yr)) + "-" + ToString(MAX(yr))
      a.mn = mn
      a.sd = sd
      a.n = n

      res = SIZE(res, /TYPE) NE 8 ? [a] : [res, a]

   ENDIF

   ; by year

   FOR iyr = MIN(yr), MAX(yr) DO BEGIN

      j = WHERE(yr EQ iyr)

      IF j[0] EQ -1 THEN CONTINUE

      ; Subset (by year)

      xsub = x[j]
      ysub = y[j]
      nsub = N_ELEMENTS(xsub)

      mn = MEAN(ysub)
      sd = nsub GT 2 ? STDDEV(ysub) : DEFAULT
      
      IF byyear EQ 1 THEN BEGIN

         a.text = ToString(iyr)
         a.mn = mn
         a.sd = sd
         a.n = N_ELEMENTS(ysub)

         res = SIZE(res, /TYPE) NE 8 ? [a] : [res, a]

      ENDIF

      ; Subset (by year/month)

      CCG_DEC2DATE, xsub, yr_sub, mo_sub

      FOR imo = 1, 12 DO BEGIN

         j = WHERE(mo_sub EQ imo)

         IF j[0] EQ -1 THEN CONTINUE

         nsub = N_ELEMENTS(xsub[j])

         mn = MEAN(ysub[j])
         sd = nsub GT 2 ? STDDEV(ysub[j]) : DEFAULT

         IF bymonth EQ 1 THEN BEGIN

            a.text = ToString(iyr) + ' ' + StringPad(imo, '0', 2)
            a.mn = mn
            a.sd = sd
            a.n = nsub

            res = SIZE(res, /TYPE) NE 8 ? [a] : [res, a]

         ENDIF
   
      ENDFOR

   ENDFOR

   RETURN, res

END

FUNCTION ComputePercentile, array, percentile

   ; Compute percentile of the passed array

   array_ = array[ SORT( array ) ]
   n = N_ELEMENTS( array_ )

   IF percentile EQ 50 THEN RETURN, MEDIAN( array_ )

   result = ( n GT 4 ) ?  array_[ FIX( CCG_ROUND( percentile / 100. * n, 0 ) ) ] : -999.999

   RETURN, result

END


FUNCTION CleanName, n

   ; IDL does not allow structure tags to begin with
   ; non-alpha characters (a-z, A-Z).

   n_ =  STREGEX( n, '^[a-z]', /FOLD_CASE, /BOOLEAN ) EQ 1 ? n : "_" + n

   ; IDL does not allow structure tags to have certain non-alphanumeric
   ; characters, e.g., ".".  An underscore (_) is safe.

   FOR i=0, STRLEN(n)-1 DO BEGIN

      c = STRMID( n_, i, 1 )
      c_ = STREGEX( c, '[a-z|0-9|_|$]', /FOLD_CASE, /BOOLEAN ) EQ 1 ? c : "_"
      STRPUT, n_, c_, i

   ENDFOR
      
   RETURN, n_

END

FUNCTION   CCG_INTERPOLATE, x, y, x0=x0, missing=missing

  ; Construct a piecewise linear fit to passed x and y.
  ; Return y0 values given passed x0.

  IF NOT KEYWORD_SET (missing ) THEN missing = !VALUES.D_NAN
  IF N_ELEMENTS(WHERE(FINITE(y) EQ 1)) LT 2 THEN RETURN, missing

  j = SORT(x)

  y0 = INTERPOL(y[j], x[j], x0)

  j = WHERE(x0 LT MIN(x[j]) OR  x0 GT MAX(x[j]))

  IF j[0] NE -1 THEN y0[j] = missing

  RETURN, y0
END

FUNCTION AverageSameAirMeasurements, arr, results=results

   ; Compute average of same air measurements.
   ; "same air" defined as discrete samples with
   ; the same collection date, time, method, and position.
   ;
   ; User supplies structure array from call to CCG_FLASK.
   ;
   ; Function returns a structure array similar to the
   ; user-input array.  Original values of the 'value' and 'unc'
   ; tags are replaced by the mean and standard devation from
   ; the same-air average.  If user-input structure includes a
   ; 'n' and 'evnlist' tag, the function return will include the
   ; the number 'n' of values used to determine the same-air average
   ; and a list of event numbers.
   ;
   ; Return by keyword 'results' is a structure array of date/time, mean,
   ; standard deviation, number of values, and a comma (,) delimited 
   ; string of the event numbers.
   ;
   ; Written: 2012-09-06 (kam)

   If CCG_VDEF( arr ) EQ 0 THEN RETURN, 0

   arr_ = arr[ SORT( arr.str ) ]
   n = N_ELEMENTS( arr_ )

   tags = TAG_NAMES( arr_ )

   key = STRARR( n )

   format = '(A,1X,A1,1X,3(1X,F12.4),1X,I10)'
   uniqkeylen = 61
   FOR i=0L,n-1 DO key[i] = STRING( FORMAT=format, STRMID( arr_[i].str, 4, 19 ), arr_[i].meth, arr_[i].lat, arr_[i].lon, arr_[i].alt, arr_[i].evn )
   uniqkey = key[UNIQ( STRMID( key, 0, uniqkeylen ) )]
   nuniq = N_ELEMENTS( uniqkey )

   ftnreturn = arr_[0:nuniq-1]
   results = REPLICATE( { str:"", date:0D, value:-999.999, stdev:-999.999, n:0, evnlist:'' }, nuniq )

   FOR i=0L,nuniq-1 DO BEGIN
   
      j = WHERE( STRMID( key, 0, uniqkeylen ) EQ STRMID( uniqkey[i], 0, uniqkeylen ), n )

      r =  MOMENT( arr_[j].value )


      ; Results returned by function

      ftnreturn[i] = arr_[j[0]]
      ftnreturn[i].value = r[0]

      k = WHERE( tags EQ 'N' )
      IF k[0] NE -1 THEN ftnreturn[i].n = n

      IF n GT 1 THEN ftnreturn[i].unc = SQRT( r[1] )

      k = WHERE( tags EQ 'EVNLIST' )
      IF k[0] NE -1 THEN ftnreturn[i].evnlist = STRJOIN( ToString( arr_[j].evn ), ',' )

      ; Results returned by keyword

      results[i].str = arr_[j[0]].str
      results[i].date = arr_[j[0]].date
      results[i].value = r[0]
      results[i].n = n
      IF n GT 1 THEN results[i].stdev = SQRT( r[1] )
      results[i].evnlist = STRJOIN( ToString( arr_[j].evn ), ',' )

   ENDFOR

   RETURN, ftnreturn

END
