PRO	CCG_QUICKFILTER, $
	x = x, $
	y = y, $

	npoly = npoly, $
	nharm = nharm, $
	interval = interval, $
	cutoff1 = cutoff1, $
	cutoff2 = cutoff2, $
 	
	sigmafactor = sigmafactor, $
	ptr2arr

sigmafactor = (KEYWORD_SET(sigmafactor)) ? sigmafactor : 3

RETAIN = 1
FILTER = 0
;
; Maintain a pointer to original data set
;
ptr2arr = MAKE_ARRAY(N_ELEMENTS(x), /INT, VALUE = RETAIN)

REPEAT BEGIN
	;
	;Call to CCG_CCGVU
	;
	ptr2ret = WHERE(ptr2arr EQ RETAIN)

   IF ptr2ret[0] EQ -1 THEN RETURN

	x0 = x[ptr2ret]
	y0 = y[ptr2ret]

	CCG_CCGVU,	x = x0, y = y0, $
			nharm = nharm, $
			npoly = npoly, $
			interval = interval, $
			cutoff1 = cutoff1, $
			cutoff2 = cutoff2, $
			sc = sc, $
			residsc = residsc
	;
	;Determine STDEV of residuals about smooth curve
	;
	one_sigma = STDEV(residsc(1, *))
	;
	;Which samples lie outside one sigma * sigmafactor?
	;
	j = WHERE(ABS(residsc(1,*)) GE sigmafactor * one_sigma)
	nflag = 0
	IF j(0) NE -1 THEN BEGIN
		ptr2arr[ptr2ret[j]] = FILTER
		nflag = nflag + 1
	ENDIF
ENDREP UNTIL nflag EQ 0
;
; re-introduce values that after the final 
; iteration lie within 1 sigma * sigmafactor
;
j = WHERE(ptr2arr EQ FILTER)

IF j[0] EQ -1 THEN RETURN

FOR i = 0, N_ELEMENTS(j) - 1 DO BEGIN
	z = WHERE(sc[0, *] LE x[j[i]])
	pt1 = z[N_ELEMENTS(z) - 1]
	z = WHERE(sc[0, *] GE x[j[i]])
	pt2 = z[0]

	IF pt1 EQ -1 AND pt2 NE -1 THEN pt1 = pt2
	IF pt2 EQ -1 AND pt1 NE -1 THEN pt2 = pt1

	IF pt1 NE pt2 THEN BEGIN
		m = (sc[1, pt2] - sc[1, pt1]) / (sc[0, pt2] - sc[0, pt1])
		b = sc[1, pt2] - m * sc[0, pt2]
		sc_interp = m * x[j[i]] + b
	ENDIF ELSE sc_interp = sc[1, pt1]

	IF ABS(y[j[i]] - sc_interp) LE (sigmafactor * one_sigma) THEN ptr2arr[j[i]] = RETAIN
ENDFOR
END
