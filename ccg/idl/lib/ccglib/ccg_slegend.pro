;+
; NAME:
;   CCG_SLEGEND
;
; PURPOSE:
;   Create a symbol and text legend 
;   and place it on the plotting 
;   surface.
;
;   Type 'ccg_ex_legend' for a legend example.
;
; CATEGORY:
;   Graphics.
;
; CALLING SEQUENCE:
;   CCG_SLEGEND,x=x,y=y,tarr=tarr,sarr=sarr,farr=farr,carr=carr
;
; INPUTS:
;   x: y:        upper left corner of legend.
;                Specify in NORMAL coordinates   
;                i.e., bottom/left of plotting surface -> x=0,y=0 
;                top/right of plotting surface   -> x=1,y=1 
;
;   tarr:        text vector
;   sarr:        symbol vector (see SYMBOL_EX procedure)
;   farr:        fill symbol vector
;                Values of 1 -> fill symbol
;                Values of 0 -> open symbol
;   carr:        color vector (values [0-255])
;
;   NOTE:   All vectors must be the same length
;
; OPTIONAL INPUT PARAMETERS:
;   charsize:    text size (default: 1)
;   charthick:   text thickness (default: 1)
;   thick:       symbol thickness. May be a constant or a vector (default:  1).
;   frame:       Boolean.  1 = draw legend frame; 0 = no legend frame.
;
;   ssizearr:    symbol size vector.  This vector must be the same size as sarr.
;                If not, the first element of ssizearr will be used for all symbols.
;                symbol size is scalued by 0.5 * charsize
;
; OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   All vectors must be the same length
;   Procedure uses symbol assignments from
;   the ccg library CCG_SYMBOL procedure.
;
; PROCEDURE:
;   
;   Example:
;
;      PRO    example,dev=dev
;      ;
;      CCG_OPENDEV,dev=dev,pen=pen
;      .
;      .
;      .
;      ;
;      ;draw initial plot.
;      ;
;      PLOT,   [0,0],[1,1]
;      ;
;      ;define vectors to be passed to CCG_SLEGEND.
;      ;
;      tarr=[   'SQUARE','CIRCLE','TRIANGLE 1','TRIANGLE 2',$
;         'DIAMOND','STAR 1','STAR 2','HOURGLASS',$
;         'BOWTIE','PLUS','ASTERISK','CIRCLE/PLUS',$
;         'CIRCLE/X']
;
;      sarr=[1,2,3,4,5,6,7,8,9,10,11,12,13]
;
;      farr=[1,1,1,1,1,1,1,1,1,0,0,0,0]
;
;      carr=[   pen(1),pen(2),pen(3),pen(4),pen(5),pen(6),$
;         pen(7),pen(8),pen(9),pen(10),pen(11),pen(12),$
;         pen(1)]
;      ;
;      ;call to CCG_SLEGEND
;      ;
;      CCG_SLEGEND,   x=.2,y=.8,$
;            tarr=tarr,$
;            farr=farr,$
;            sarr=sarr,$
;            carr=carr,$
;            charthick=2.0,$
;            charsize=1.0,$
;            frame=1
;      .
;      .
;      .
;      CCG_CLOSEDEV,dev=dev
;      END
;
; MODIFICATION HISTORY:
;   Written, KAM, February 1994.
;   Modified, KAM, January 2010.  To include symbol size array.
;-
;
PRO CCG_SLEGEND, $
    x = x, $
    y = y, $
    tarr = tarr, $
    sarr = sarr, $
    ssizearr = ssizearr, $
    farr = farr, $
    carr = carr,$
    charsize = charsize, $
    charthick = charthick, $
    thick = thick, $
    frame = frame, $
    help = help

   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET(sarr) THEN CCG_SHOWDOC
   nsarr = N_ELEMENTS(sarr)
   ;
   ;If keywords are not set then assign default values
   ;
   IF NOT KEYWORD_SET(charthick) THEN charthick=1
   IF NOT KEYWORD_SET(charsize) THEN charsize=1
   IF NOT KEYWORD_SET(carr) THEN carr = MAKE_ARRAY( nsarr, /INT, VALUE=!P.COLOR )
   IF NOT KEYWORD_SET(farr) THEN farr = MAKE_ARRAY( nsarr, /INT, VALUE=0 )
   IF NOT KEYWORD_SET(tarr) THEN tarr = MAKE_ARRAY( nsarr, /STR, VALUE='' )
   IF NOT KEYWORD_SET(ssizearr) THEN ssizearr = MAKE_ARRAY( nsarr, /FLOAT, VALUE=1.0 )
   IF NOT KEYWORD_SET(x) THEN x=0.5
   IF NOT KEYWORD_SET(y) THEN y=0.5

   IF N_ELEMENTS(ssizearr) NE nsarr THEN ssizearr = MAKE_ARRAY( nsarr, /FLOAT, VALUE=ssizearr[0] )

   IF NOT KEYWORD_SET(thick) THEN thickarr=MAKE_ARRAY(N_ELEMENTS(sarr),/INT,VALUE=1) $
   ELSE thickarr=thick

   IF N_ELEMENTS(thickarr) NE N_ELEMENTS(sarr) THEN $
       thickarr=MAKE_ARRAY(N_ELEMENTS(sarr),/INT,VALUE=thick)
   ;
   ;determine number of lines
   ;
   n=N_ELEMENTS(tarr)
   ;
   ;determine length of longest text
   ;
   tlen=MAX(STRLEN(tarr))
   ;
   ;y increment for text
   ;
   yinc=.025*charsize
   ;
   FOR i=0,n-1 DO BEGIN

      CCG_SYMBOL,   sym=sarr(i),fill=farr(i),thick=thickarr[i]

      PLOTS,       x,y-(yinc*i),$
                   /NORMAL,$
                   PSYM=8,$
                   SYMSIZE=charsize*ssizearr[i],$
                   COLOR=carr(i)

      XYOUTS,      x+.015*charsize,y-(yinc*i)-(.007*charsize),$
                   /NORMAL,$
                   tarr(i),$
                   ALI=0,$
                   CHARTHICK=charthick,$
                   CHARSIZE=charsize,$
                   COLOR=carr(i)

   ENDFOR
   ;
   ;build legend frame
   ;
   IF KEYWORD_SET(frame) THEN BEGIN

      PLOTS,   x-(.02*charsize),$
               y+(.03*charsize),$
               /NORMAL
      PLOTS,   x-(.02*charsize),$
               y-(n*.025*charsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x+(charsize*.015)+(charsize*tlen*.0095)+(charsize*.012),$
               y-(n*.025*charsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x+(charsize*.015)+(charsize*tlen*.0095)+(charsize*.012),$
               y+(.03*charsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x-(.02*charsize),$
               y+(.03*charsize),$
               /NORMAL,$
               /CONTINUE

   ENDIF

END
