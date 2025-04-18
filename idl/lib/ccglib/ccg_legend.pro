;+
; NAME:
;   CCG_LEGEND
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
;   CCG_LEGEND,x=x,y=y,tarr=tarr,sarr=sarr,farr=farr,carr=carr
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
;      ;define vectors to be passed to CCG_LEGEND.
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
;      ;call to CCG_LEGEND
;      ;
;      CCG_LEGEND,   x=.2,y=.8,$
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
PRO CCG_LEGEND, $

   x=x, $
   y=y, $

   chartext=chartext, $
   charthick=charthick, $
   charsize=charsize, $
  
   symstyle=symstyle, $
   symfill=symfill, $
   symthick=symthick, $
   symsize=symsize, $
  
   linestyle=linestyle, $
   linethick=linethick, $
   linelength=linelength, $

   color=color, $
   
   titletext=titletext, $
   titlesize=titlesize, $
   titlethick=titlethick, $
   titlecolor=titlecolor, $

   frame=frame, $

   help=help

   IF KEYWORD_SET( help ) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( chartext ) THEN CCG_SHOWDOC

   ;determine number of text lines
 
   ntext = N_ELEMENTS( chartext )
   
   ;If keywords are not set then assign default values

   x0 = KEYWORD_SET( x ) ? x : 0.5
   y0 = KEYWORD_SET( y ) ? y : 0.5
   
   IF NOT KEYWORD_SET( charthick ) THEN charthick = MAKE_ARRAY( ntext, /INT, VALUE=1 )
   IF ( n=ntext-N_ELEMENTS( charthick ) ) GT 0 THEN charthick = [ charthick, MAKE_ARRAY( n, /INT, VALUE=charthick[0] ) ]

   IF NOT KEYWORD_SET( charsize ) THEN charsize = MAKE_ARRAY( ntext, /FLOAT, VALUE=1 )
   IF ( n=ntext-N_ELEMENTS( charsize ) ) GT 0 THEN charsize = [ charsize, MAKE_ARRAY( n, /FLOAT, VALUE=charsize[0] ) ]

   IF NOT KEYWORD_SET( symstyle ) THEN symstyle = MAKE_ARRAY( ntext, /INT, VALUE=(-1) )
   IF ( n=ntext-N_ELEMENTS( symstyle ) ) GT 0 THEN symstyle = [ symstyle, MAKE_ARRAY( n, /INT, VALUE=symstyle[0] ) ]

   IF NOT KEYWORD_SET( symthick ) THEN symthick = MAKE_ARRAY( ntext, /FLOAT, VALUE=2 )
   IF ( n=ntext-N_ELEMENTS( symthick ) ) GT 0 THEN symthick = [ symthick, MAKE_ARRAY( n, /FLOAT, VALUE=symthick[0] ) ]

   IF NOT KEYWORD_SET( symfill ) THEN symfill = MAKE_ARRAY( ntext, /INT, VALUE=0 )
   IF ( n=ntext-N_ELEMENTS( symfill ) ) GT 0 THEN symfill = [ symfill, MAKE_ARRAY( n, /INT, VALUE=symfill[0] ) ]

   IF NOT KEYWORD_SET( symsize ) THEN symsize = MAKE_ARRAY( ntext, /FLOAT, VALUE=1 )
   IF ( n=ntext-N_ELEMENTS( symsize ) ) GT 0 THEN symsize = [ symsize, MAKE_ARRAY( n, /FLOAT, VALUE=symsize[0] ) ]
 
   IF NOT KEYWORD_SET( linestyle ) THEN linestyle = MAKE_ARRAY( ntext, /INT, VALUE=(-1) )
   IF ( n=ntext-N_ELEMENTS( linestyle ) ) GT 0 THEN linestyle = [ linestyle, MAKE_ARRAY( n, /INT, VALUE=linestyle[0] ) ]

   IF NOT KEYWORD_SET( linethick ) THEN linethick = MAKE_ARRAY( ntext, /INT, VALUE=4 )
   IF ( n=ntext-N_ELEMENTS( linethick ) ) GT 0 THEN linethick = [ linethick, MAKE_ARRAY( n, /INT, VALUE=linethick[0] ) ]

   IF NOT KEYWORD_SET( linelength ) THEN linelength = MAKE_ARRAY( ntext, /FLOAT, VALUE=4 )
   IF ( n=ntext-N_ELEMENTS( linelength ) ) GT 0 THEN linelength = [ linelength, MAKE_ARRAY( n, /FLOAT, VALUE=linelength[0] ) ]
 
   IF NOT KEYWORD_SET( color ) THEN color = MAKE_ARRAY( ntext, /INT, VALUE=!P.COLOR )
   IF ( n=ntext-N_ELEMENTS( color ) ) GT 0 THEN color = [ color, MAKE_ARRAY( n, /INT, VALUE=color[0] ) ]

   IF NOT KEYWORD_SET( titletext ) THEN titletext = ""
   IF NOT KEYWORD_SET( titlesize ) THEN titlesize = 2
   IF NOT KEYWORD_SET( titlethick ) THEN titlethick = 2
   IF NOT KEYWORD_SET( titlecolor ) THEN titlecolor = !P.COLOR

   ; x-indent depends on the existence of lines and symbols

   j = WHERE( linestyle NE -1, linecount )
   j = WHERE( symstyle NE -1, symcount )

   ; determine maximum text length
   
   maxchars = MAX( STRLEN( chartext ) )

   ; determine maximum line length
   
   linelength *= 0.01
   maxline = linecount GT 0 ? MAX( linelength ) : 0

   ; determine maximum symbol size
   
   maxsym = MAX( symsize )
   
   ; determine mean charsize
   
   meansize = MEAN( charsize )
   yinc=.025*meansize
   
   CASE 1 OF 

      linecount GT 0: xindent = 1.15 * maxline
      symcount GT 0: xindent = 0.01 * maxsym
      ELSE: xindent = 0

   ENDCASE

   yspan = 0
   xspan = 0

   IF titletext NE "" THEN BEGIN

      XYOUTS,      x0,y0,$
                   titletext,$
                   CHARTHICK=titlethick,$
                   CHARSIZE=titlesize,$
                   COLOR=titlecolor, $
                   ALI=0,$
                  /NORMAL

      z = STRLEN( titletext ) * !D.X_CH_SIZE * titlesize * 0.0015
      xspan = z GT xspan ? z : xspan

      y -= yinc

   ENDIF
   ;
   FOR i=0, ntext-1 DO BEGIN

      IF linestyle[i] NE -1 THEN BEGIN

         PLOTS,   [x, x+(linelength[i]) ],$
                  [y-(yinc*i)-(.002*charsize[i]),y-(yinc*i)-(.002*charsize[i])],$
                  LINESTYLE=linestyle[i],$
                  THICK=linethick[i],$
                  COLOR=color[i],$
                  /NORMAL

      END

      IF symstyle[i] NE -1 THEN BEGIN

         CCG_SYMBOL, sym=symstyle[i], fill=symfill[i], thick=symthick[i]

         PLOTS,     x+maxline/2.0,y-(yinc*i),$
                    PSYM=8,$
                    SYMSIZE=symsize[i], $
                    COLOR=color[i],$
                    /NORMAL

      END

     XYOUTS,      x+xindent,y-(yinc*i)-(.007*charsize[i]),$
                  chartext[i],$
                  CHARTHICK=charthick[i],$
                  CHARSIZE=charsize[i],$
                  COLOR=color[i], $
                  ALI=0,$
                  /NORMAL

      z = xindent + STRLEN( chartext[i] ) * !D.X_CH_SIZE * charsize[i] * 0.0015
      xspan = z GT xspan ? z : xspan

  ENDFOR

    
   ;build legend frame
    
   IF KEYWORD_SET( frame ) THEN BEGIN

      maxchars = MAX( STRLEN( [ chartext, titletext ] ) )
      maxsize = MEAN( [ charsize, titlesize ] )

      PLOTS,   x0-(.02*maxsize),$
               y0+(.03*maxsize),$
               /NORMAL
      PLOTS,   x0-(.02*maxsize),$
               y0-(ntext*.025*maxsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x0+(maxsize*.015)+xspan, $
               y0-(ntext*.025*maxsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x0+(maxsize*.015)+xspan, $
               y0+(.03*maxsize),$
               /NORMAL,$
               /CONTINUE
      PLOTS,   x0-(.02*maxsize),$
               y0+(.03*maxsize),$
               /NORMAL,$
               /CONTINUE

   ENDIF

END
