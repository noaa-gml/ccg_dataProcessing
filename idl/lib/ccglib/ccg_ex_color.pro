;+
PRO 	CCG_EX_COLOR, 		dev=dev
;
CCG_OPENDEV,dev=dev,pen=pen,/portrait

ncolors=256
ncols=8
nrows=32
colpos=FINDGEN(ncols)*0.12+0.03
spen=MAKE_ARRAY(nrows,/STR,VALUE='pen ')
sarr=MAKE_ARRAY(nrows,/INT,VALUE=1)
farr=MAKE_ARRAY(nrows,/INT,VALUE=1)

FOR i=0,ncols-1 DO BEGIN

	start=i*nrows
	pennumber=INDGEN(nrows)+start
	

	CCG_SLEGEND,	x=colpos(i),y=0.90,$
			sarr=sarr,$
			farr=farr,$
			tarr=spen+STRCOMPRESS(STRING(pennumber),/RE),$
			carr=pen(start:start+nrows-1),$
			CHARSIZE=1.0,$
			CHARTHICK=2.0
ENDFOR

CCG_CLOSEDEV,dev=dev
END
;-
