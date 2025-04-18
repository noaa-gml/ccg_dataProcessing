;+
; $Id: errplot.pro,v 1.1 1993/04/02 19:43:31 idl Exp $
;
;Modified to accommodate line thickness.
;June 1997 - kam
;
;
;Modified to accommodate COLOR.
;March 1994 - kam
;
;Modified to accommodate x/y specification.
;June 1994 - kam
;
;Parameter order is important.
;
;CCG_ERRPLOT,	x,y-yunc,y+yunc,COLOR=pen(2),thick=4
;CCG_ERRPLOT,	y,x-xunc,x+xunc,COLOR=pen(2),y=1,width=2
;
;-
;
PRO 	CCG_ERRPLOT, $
	x, low, high, $
	width = width, $
	color = color, $
	y = y, $
	thick = thick, $
   noclip=noclip,$
	help = help

noclip = KEYWORD_SET( noclip ) ? 1 : 0

IF KEYWORD_SET(help) THEN CCG_SHOWDOC

	on_error,2                      ;Return to caller if an error occurs
	if n_params(0) eq 3 then begin	;X specified?
		up = high
		down = low
		xx = x
		yy = x
	   endif else begin	;Only 2 params
		up = x
		down = low
		xx=findgen(n_elements(up)) ;make our own x
		yy=findgen(n_elements(up)) ;make our own x
	   endelse

	if n_elements(width) eq 0 then width = .01 ;Default width
	width = width/2		;Centered
;
	n = n_elements(up) < n_elements(down) < n_elements(xx) ;# of pnts
	xxmin = min(!x.crange)	;X range
	xxmax = max(!x.crange)
	yymax = max(!y.crange)  ;Y range
	yymin = min(!y.crange)

	IF NOT KEYWORD_SET(thick) THEN thick=1.0

	IF KEYWORD_SET(y) THEN BEGIN
		if !y.type eq 0 then begin	;Test for y linear
			;Linear in y
			wid =  (yymax - yymin) * width ;bars = .01 of plot wide.
		endif else begin		;Logarithmic Y
			yymax = 10.^yymax
			yymin = 10.^yymin
			wid  = (yymax/yymin)* width  ;bars = .01 of plot wide
		endelse
		;
		for i=0,n-1 do begin	;do each point.
			yyy = yy(i)	;y value
			if (yyy ge yymin) and (yyy le yymax) then begin
				plots,  [down(i),down(i),down(i),up(i),up(i),up(i)],$
				        [yyy-wid,yyy+wid,yyy,yyy,yyy-wid,yyy+wid],$
					thick=thick,$
               noclip=noclip,$
					color=color
			endif
		endfor
	ENDIF ELSE BEGIN
		if !x.type eq 0 then begin	;Test for x linear
			;Linear in x
			wid =  (xxmax - xxmin) * width ;bars = .01 of plot wide.
		endif else begin		;Logarithmic X
			xxmax = 10.^xxmax
			xxmin = 10.^xxmin
			wid  = (xxmax/xxmin)* width  ;bars = .01 of plot wide
		endelse
		;
		for i=0,n-1 do begin	;do each point.
			xxx = xx(i)	;x value
			if (xxx ge xxmin) and (xxx le xxmax) then begin
				plots,	[xxx-wid,xxx+wid,xxx,xxx,xxx-wid,xxx+wid],$
				  	[down(i),down(i),down(i),up(i),up(i),up(i)],$
					thick=thick,$
               noclip=noclip,$
					color=color
			endif
		endfor
	ENDELSE
	return
end

