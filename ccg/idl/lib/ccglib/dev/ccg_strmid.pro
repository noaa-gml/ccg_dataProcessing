FUNCTION	CCG_STRMID,str,b,e

IF N_PARAMS() NE 3 THEN $
	CCG_FATALERR,"Incorrect number of input parameters."

nstr=N_ELEMENTS(str)	
nbegin=N_ELEMENTS(b)	
nend=N_ELEMENTS(e)
result=STRARR(nstr)

IF nbegin EQ 1 THEN b=MAKE_ARRAY(nstr,/INT,VALUE=b)
IF nend EQ 1 THEN e=MAKE_ARRAY(nstr,/INT,VALUE=e)
nbegin=N_ELEMENTS(b)	
nend=N_ELEMENTS(e)

IF (nbegin NE nstr OR nend NE nstr) THEN $
	CCG_FATALERR, "Input parameters must have the same size."

FOR i=0,nstr-1 DO result(i)=STRMID(str(i),b(i),e(i))

IF nstr EQ 1 THEN result=result(0)
	
RETURN,result
END
