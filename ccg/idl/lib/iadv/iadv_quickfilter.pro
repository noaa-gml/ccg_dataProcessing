PRO	IADV_QUICKFILTER,x=x,y=y,ptr2arr

sigmafactor=3.0

RETAIN=1
FILTER=0
;
; Maintain a pointer to original data set
;
ptr2arr=MAKE_ARRAY(N_ELEMENTS(x),/INT,VALUE=RETAIN)

REPEAT BEGIN
	;
	;Call to CCG_CCGVU
	;
	ptr2ret=WHERE(ptr2arr EQ RETAIN)
	x0=x[ptr2ret]
	y0=y[ptr2ret]

	CCG_CCGVU,	x=x0,y=y0,$
			residsc=residsc
	;
	;Determine STDEV of residuals about smooth curve
	;
	one_sigma=STDEV(residsc(1,*))
	;
	;Which samples lie outside one sigma * sigmafactor?
	;
	j=WHERE(ABS(residsc(1,*)) GE sigmafactor*one_sigma)
	nflag=0
	IF j(0) NE -1 THEN BEGIN
		ptr2arr(ptr2ret(j))=FILTER
		nflag=nflag+1
	ENDIF
ENDREP UNTIL nflag EQ 0
END
