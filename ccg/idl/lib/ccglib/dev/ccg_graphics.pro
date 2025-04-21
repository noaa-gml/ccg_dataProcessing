;+
; NAME:
; CCG_GRAPHICS
;
; PURPOSE:
;
; CATEGORY:
;   Graphics
;
; CALLING SEQUENCE:
;
;    EXAMPLES:
;
;    IDL> CCG_GRAPHICS, graphics = {p1:p1, p2:p2, p3:p3}, dev = 'png', saveas = 'filename.png' 
; 
; INPUTS:
;
;    graphics:     Structure of data and plot attributes created by "PLOT_ATTRIBUTES". See examples.
;
;    allxrange:    If allxrange is set (allxrange=1 or /allxrange) and if 
;                  graphics contains multiple plots then the xrange for all
;                  plots will be identical.  The exception is for plots where
;                  the "xaxis" keyword has been set by the user.
;
;    allyrange:    If allyrange is set (allyrange=1 or /allyrange) and if 
;                  graphics contains multiple plots then the yrange for all
;                  plots will be identical.  The exception is for plots where
;                  the "yaxis" keyword has been set by the user.
;
;    depth:        Specify the bit depth of colors.  Applies only to PNG device.
;    insert:
;
;    notimestamp:  If set, plot timestamp will be omitted
;
;    xpixels:      Screen width (ignored with dev is specified)
;    ypixels:      Screen height (ignored with dev is specified)
;
;    portrait:     If portrait is set (portrait=1 or /portrait) then graphics 
;                  device will be set to portrait. Default is landscape.
;
;    font:         Specify a True type or vector-drawn (default) font.
;                  True type fonts include Helvetica, Times (see IDL
;                  online help for more information.  
;
;                  Screen graphics will default to vector-drawn fonts
;                  regardless of font keyword setting. 
;
;                  Warning:  Special characters currently do not necessarily 
;                  transfer between vector-drawn and true type fonts.
;
;                  (ex) font='Helvetica'
;
;    notimestamp:
;
;    help:
;
;    saveas:
;
;    row:
;
;    col:
;
;    window:
;
;    wtitle:
;
;    dev:         Specify graphics device.
;
;    optimization: Set graphics optimization when PNG device is specified (options: 'quality' [default]; 'speed').
;
;    chmod:       Set Unix system permissions on new files in octal format. See Unix chmod documentation.
;                 Unix default is 644.
;
; OPTIONAL INPUT PARAMETERS:
;
; Function: DATA_ATTRIBUTES
;
;    EXAMPLES:
;
;    IDL> data = DATA_ATTRIBUTES(x, y, chartext = 'dataset 1')
; 
;    INPUTS: 
; 
;    x:            Vector of x-axis values.
; 
;    y:            Vector of y-axis values.
; 
;    xunc:         Vector of x value uncertainty. Must be the same length as x.
; 
;    yunc:         Vector of y value uncertainty. Must be the same length as y.
; 
;    linestyle:    Integer indicating line style. A value of -1 indicates no line.
; 
;    linethick:    Value specifies line thickness.
; 
;    linecolor:    Value specifies line color.
; 
;    symstyle:     Integer specifies symbol style. Default is -1 (no symbol).
;                  Setting value to -10, will create histogram.
; 
;    symthick:     Value specifies symbol thickness.
; 
;    symcolor:     Integer specifies symbol color.
; 
;    symsize:      Value specifies symbol size.
; 
;    symfill:      Open or solid symbols? Default is 0 (open symbols)
; 
;    charsize:     Size of data text.
; 
;    charthick:    Thickness of data text.
; 
;    chartext:     Data text (e.g., chartext = 'dataset 1')
;
;    label:        NOTE: This keyword is obsolete.  Use chartext.
;
;    charcolor:    Thickness of data text.
;
;    noscale:
; 
;
; Function: PLOT_ATTRIBUTES
;
;    EXAMPLES:
;
;    IDL> graph = PLOT_ATTRIBUTES(data = {tag:data}, legend = 'TL')
; 
;    INPUTS: 
;
;    xaxis:        A vector containing xmin, xmax, xticks, and xminor values, e.g., xaxis=[2006,2007,12, 1]
;                  If not supplied, procedure will determine best values.
;
;    yaxis:        A vector containing ymin, ymax, yticks, and yminor values, e.g., yaxis=[330, 380, 4, 5]
;                  If not supplied, procedure will determine best values.
;
;    annotate:     ***WARNING! KEYWORD OBSOLETE AND WILL BE DISCONTINUED IN FAVOR OF "ANNOTATION" (SEE DOC BELOW)***
;                  Keyword specifies the placement of the annotation string vector (atext).
;                  Keyword options are ...
;
;                  "TL" -  Top Left
;                  "TR" -  Top Right (default)
;                  "BL" -  Bottom Left
;                  "BR" -  Bottom Right
;
;    annotation:   Keyword specifies annotation attributes (e.g. text, position, charsize)
;                  Accepted annotation keyword formats: 
;
;                  1) String array of annotation text...
;                     annotation = ['Annotation Ex 1', 'Annotation Ex. 2']
;
;                  2) structure(s) containing select keyword information... 
;                     annotation = {a1:{TEXT : 'Annotation Ex. 1', POSITION : 'BR'}, a2:{TEXT : 'Annotation Ex. 2', COLOR : 2}}
;
;                  3) structure(s) returned by ANNOTATION_ATTRIBUTES function 
;                     a1 = ANNOTATION_ATTRIBUTES(text = 'Annotation Ex. 1', orientation = 25.0)
;                     a2 = ANNOTATION_ATTRIBUTES(text = 'Annotation Ex. 2', position = [5.8030, -9.0421])
;                     annotation = {a1 : a1, a2 : a2}
;
;    legend:       Keyword specifies the placement of the legend comprised of
;                  chartext from "data attributes".  Labels are vertical unless otherwise
;                  specified.  Keyword options are ...
;
;                  "TL" -  Top Left (default)
;                  "BL" -  Bottom Left
;                  "TLH" -  Top Left Horizontal
;                  "BLH" -  Bottom Left Horizontal
;                   0    -  No legend
;
;    llegend:      Keyword specifies the placement of the line legend comprised of
;                  chartext from "data attributes".  Labels are plotted vertically.
;                  Keyword options are ...
;
;                  "TL" -  Top Left (default)
;                  "BL" -  Bottom Left
;                   0   -  No legend
;
;    slegend:      Keyword specifies the placement of the symbol legend comprised of
;                  charatext from "data attributes".  Labels are plotted vertically.
;                  Keyword options are ...
;
;                  "TL" -  Top Left (default)
;                  "BL" -  Bottom Left
;                   0   -  No legend
;
;    tlegend:      Keyword specifies a legend title
;
;    xcustom:      Keyword specifies custom x-axis options...
;
;                  "hour" -
;                  "day" -
;                  "month" -
;                  "log" - Plot x-axis on a log scale
;
;                  User may also call SetTScustom(t) where 't' is decimal date vector.
;                  SetTScustom will return "hour", "day", "month" or "" depending on
;                  range of "t". 
;
;    ycustom:      Keyword specifies custom y-axis options...
;
;                  "log" - Plot y-axis on a log scale 
;
;    nogrid:       Keyword elimates the grid option from the plot.
;
;    ticklen:      Keyword specifies tick length. Default is -0.02 when keyword set "nogrid".
;                  A value of 0.0 with "nogrid" places tickmarks inside the plot boundary
;
;    background:   Keyword specifies the plot background color index.
;
;    position:     Keyword specifies the lower left and upper right plot position in "normal" coordinates
;
;                  Note: If "/notimestamp" is not passed by the user, a vertical "NOAA ESRL Carbon Cycle" 
;                        timestamp label is added to the y-axis on the right side of the LAST plot on a page. 
;                        Multiple plots on a page should be ordered in the "graphics" keyword so the timestamp
;                        label appears at the desired location.
;
;    xcharsize:    Scales the x-axis tick label character size. Default is 0.7
;
;                  Note: Specify "xcharsize = 0.01" to eliminate x-axis labels 
;                        (e.g. mixing ratio/growth rate timeseries plots that share the x-axis)
;
;    ycharsize:    Scales the y-axis tick label character size. Default is 0.8
;
;                  Note: Specify "ycharsize = 0.01" to eliminate y-axis labels 
;
; Device Attributes
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
;   None.
;
; PROCEDURE:
;
; Must include ccg_graphics.pro in calling procedure.
; First line in procedure after comments should be "@ccg_graphics.pro".
;
; MODIFICATION HISTORY:
;   Written, Ken Masarie and Michael Trudeau, April 2007.
;   Modified, Michael Trudeau, 19 June 2008: added position and xcharsize/ycharsize to PLOT_ATTRIBUTES
;   Modified, Michael Trudeau, 5 October 2008: added ticklen, tlegend, llegend, and slegend to PLOT_ATTRIBUTES
;   Modified, Ken Masarie, November 2008: added ability to include logos (LOGO_ATTRIBUTES)
;   Modified, Ken Masarie, November 2008: modified implementation of timestamp (see TIMESTAMP_ATTRIBUTES)
;   Modified, Ken Masarie, 2008-11-05: added SetTScustom().
;   Modified, Michael Trudeau, 14 November 2008: added chmod keyword to CCG_GRAPHICS
;   Modified, Ken Masarie, 2008-12-19: added procedures FindPlotsRange and FindDataRange.
;   Modified, Ken Masarie, 2009-05-27: fixed bugs in FindPlotsRange and FindDataRange.
;   Modified, Ken Masarie, 2009-06-10: added histogram option (symstyle=(-10))
;   Modified, Ken Masarie, 2009-06-29: replaced data "label" keyword with "chartext".
;   Modified, Ken Masarie, 2009-06-29: added charcolor.
;   Modified, Michael Trudeau, 18 Mar 2010: added xaxis keyword to InHours/InDays functions
;   Modified, Michael Trudeau, 28 Apr 2010: added check for IDL NAN/Infinity values to FindPlotsRange and FindDataRange
;   Modified: Michael Trudeau, 29 Oct 2010: modified PLOT_ATTRIBUTES "annotation" keyword for multiple formats
;-
;
; Get Utility functions
;
@ccg_utils.pro

FUNCTION IS_STRUCT_MATCH, struct1 = struct1, struct2 = struct2

; Function compares two structures (struct1 against struct2). 
; 
; If ALL structure tags, data types, and number of elements in struct1
; match those of struct2, function returns TRUE (1). Note that ALL 
; tags/datatypes/# elements in struct2 DO NOT have to match those of struct1.
; 
; Created 8 Nov 1010, M. Trudeau

tags_struct1 = TAG_NAMES(struct1)
tags_struct2 = TAG_NAMES(struct2)

ntags = 0

FOR i = 0, N_TAGS(struct1) - 1 DO BEGIN

   ; verify tag
   jtag = WHERE(tags_struct2 EQ tags_struct1[i])
   IF jtag[0] EQ -1 THEN CONTINUE

   ; verify datatype
   IF SIZE(struct2.(jtag), /TYPE) NE SIZE(struct1.(i), /TYPE) THEN CONTINUE

   ; verify number of elements
   IF N_ELEMENTS(struct2.(jtag)) NE N_ELEMENTS(struct1.(i)) THEN CONTINUE

   ntags ++
ENDFOR

RETURN, (ntags EQ N_TAGS(struct1))
END

PRO FindPlotsRange, p, range=range, type=type

   ; When autoscaling, user may want all multiple plots 
   ; to get the same autoscale result.
    
   ; Loop through all plots and all data to determine 
   ; minimum and maximum "axis" values.  

   ; Added 2008-12-19 (kam)

   range = [999999D, -999999D]

   np = N_TAGS(p)

   FOR i=0, np-1 DO BEGIN

      nd = N_TAGS(p.(i).data)

      FOR ii=0, nd-1 DO BEGIN

         IF p.(i).data.(ii).noscale EQ 1 THEN CONTINUE

         ; X-Axis

         IF STRCMP(type, 'x', /FOLD_CASE) NE 0 THEN BEGIN

            IF TOTAL( p.(i).xaxis ) NE 0 THEN BEGIN

               data = [ p.(i).xaxis[0], p.(i).xaxis[1] ]
               p.(i).xaxis = 0

            ENDIF ELSE data = p.(i).data.(ii).x

         ENDIF

         ; Y-Axis

         IF STRCMP(type, 'y', /FOLD_CASE) NE 0 THEN BEGIN

            IF TOTAL( p.(i).yaxis ) NE 0 THEN BEGIN

               data = [ p.(i).yaxis[0], p.(i).yaxis[1] ]
               p.(i).yaxis = 0

            ENDIF ELSE data = p.(i).data.(ii).y

         ENDIF

         dmax = MAX(data, MIN=dmin, /NAN)
         range[0] = dmin LT range[0] ? dmin : range[0]
         range[1] = dmax GT range[1] ? dmax : range[1]

      ENDFOR

   ENDFOR

END

PRO FindDataRange, d, range=range, axis=axis, type=type
  

   ; When autoscaling a single plot, we want all data
   ; (where noscale EQ 0) to determine the autoscale result.

   ; Loop through all data to determine minimum and 
   ; maximum X and Y values.  

   ; Added 2008-12-19 (kam)

   range = [999999D, -999999D]

   FOR i=0, N_TAGS(d)-1 DO BEGIN

      IF d.(i).noscale EQ 1 THEN CONTINUE

      IF STRCMP(type, 'x', /FOLD_CASE) NE 0 THEN BEGIN

         IF SIZE( d.(i).xunc,/N_DIMENSIONS ) EQ 1 THEN data = [ d.(i).x-d.(i).xunc,d.(i).x+d.(i).xunc ]
         IF SIZE( d.(i).xunc,/N_DIMENSIONS ) EQ 2 THEN data = [ d.(i).x-d.(i).xunc[0],d.(i).x+d.(i).xunc[1] ]

      ENDIF

      IF STRCMP(type, 'y', /FOLD_CASE) NE 0 THEN BEGIN

         IF SIZE( d.(i).yunc,/N_DIMENSIONS ) EQ 1 THEN data = [ d.(i).y-d.(i).yunc,d.(i).y+d.(i).yunc ]
         IF SIZE( d.(i).yunc,/N_DIMENSIONS ) EQ 2 THEN data = [ d.(i).y-d.(i).yunc[0],d.(i).y+d.(i).yunc[1] ]

      ENDIF

      dmax = MAX(data, MIN=dmin, /NAN)
      range[0] = dmin LT range[0] ? dmin : range[0]
      range[1] = dmax GT range[1] ? dmax : range[1]

   ENDFOR

   ; If "axis" is set, verify that range is within "axis" range

   IF TOTAL(axis) GT 0 THEN BEGIN

      IF range[0] LT axis[0] THEN range[0] = axis[0]
      IF range[1] GT axis[1] THEN range[1] = axis[1]

   ENDIF

END

FUNCTION   SetTScustom, x

   ; Function to determine reasonable TimeSeries 'xcustom' option.
   ; Added 2008-11-05 (kam)

   xcustom = ""

   days = 365 * ( MAX(x) - MIN(x) )
   IF days LT 2 THEN xcustom = "hour"
   IF days GE 2 AND days LT 32 THEN xcustom = "day"
   IF days GE 32 AND days LE 560 THEN xcustom = "month"

   RETURN, xcustom

END

FUNCTION   InMonths, x, xaxis = xaxis
    
   ; Determine X Axis range in "month" format
    
   dim = [[-9, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], $
          [-9, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]]

   IF TOTAL(xaxis) EQ 0 THEN BEGIN

      CCG_DEC2DATE,   MIN(x), yr1, mo1, dy, hr, mn
      CCG_DATE2DEC,   yr=yr1, mo=mo1, dy=dy, hr=hr, mn=mn, dec=xmin

      CCG_DEC2DATE,   MAX(x), yr2, mo2, dy, hr, mn
      CCG_DATE2DEC,   yr=yr2, mo=mo2, dy=dy, hr=hr, mn=mn, dec=xmax
      ;
      ; Re-define minimum and maximum
      ;
      CCG_DATE2DEC,   yr=yr1, mo=mo1, dy=1, hr=0, mn=0, sc=0, dec=xmin
      CCG_DATE2DEC,   yr=yr2, mo=mo2, dy= dim[mo2, CCG_LEAPYEAR(yr2)]+1, hr=0, mn=0, sc=0, dec = xmax

   ENDIF ELSE BEGIN

      xmin = xaxis[0] & xmax = xaxis[1]
      CCG_DEC2DATE,   xmin, yr1, mo1, dy, hr, mn

   ENDELSE

   nmonths = CCG_ROUND((xmax - xmin) * 12.0, 0) 
   IF nmonths EQ 0 THEN nmonths ++

   abbr = (nmonths GE 6 ) ? 1 : 0

   xtickname = MAKE_ARRAY(nmonths + 1, /STR, VALUE = ' ')

   mo = mo1
   FOR i = 0, nmonths DO BEGIN
      CCG_INT2MONTH, imon = mo, mon = mon, one = abbr
      xtickname[i] = mon
      mo = (mo EQ 12) ? 1 : mo + 1
   ENDFOR

   e = { XSTYLE : 1, $
         XRANGE : [xmin, xmax], $
         XMINOR : 1, $
         XTICKS : nmonths, $
         XTICKNAME : xtickname}

   RETURN, e
END

FUNCTION   InDays, x, xaxis = xaxis
    
   ; Determine X Axis range in "day" format
    
   DIY=365
   DAY = 1.0 / DIY

   IF TOTAL(xaxis) EQ 0 THEN BEGIN
      CCG_DEC2DATE,   MIN(x), yr, mo, dy, hr, mn, sc
      CCG_YMD2JUL, yr, mo, dy, julmin
      CCG_DATE2DEC,   yr=yr, mo=mo, dy=dy, hr=0, mn=0, sc=0, dec=xmin
      fday = dy

      CCG_DEC2DATE,   MAX(x), yr, mo, dy, hr, mn, sc
      dy = (hr GT 0 OR mn GT 0 OR sc GT 0) ? dy + 1 : dy
      CCG_YMD2JUL, yr, mo, dy, julmax
      CCG_DATE2DEC,   yr=yr, mo=mo, dy=dy, hr=0, mn=0, sc=0, dec=xmax

      ndays = CCG_ROUND((xmax - xmin) * DIY, 0) + 1
   ENDIF ELSE BEGIN
      xmin = xaxis[0] & xmax = xaxis[1]
      CCG_DEC2DATE,   xmin, yr, mo, dy, hr, mn, sc
      fday = dy

      ndays = CCG_ROUND((xmax - xmin) * DIY, 0)  + 1
   ENDELSE

   xtickname = MAKE_ARRAY(ndays, /STR, VALUE = ' ')

   FOR i = 0, ndays-1 DO BEGIN

      CCG_DEC2DATE, xmin + (i * DAY), yr, mo, dy
      xtickname[i] = ToString(dy)

   ENDFOR

   e = { XSTYLE : 1, $
         XRANGE : [xmin, xmax], $
         XTICKS : ndays - 1, $
         XMINOR : 1, $
         XTICKNAME : xtickname}

   RETURN, e
END

FUNCTION   InHours, x, xaxis = xaxis
    
   ; Determine X Axis range in "hour" format
    
   HIY = 8760

   IF TOTAL(xaxis) EQ 0 THEN BEGIN
      CCG_DEC2DATE,   MIN(x), yr, mo, dy, hr, mn, sc
      CCG_DATE2DEC,   yr = yr, mo = mo, dy = dy, hr = hr, mn = 0, sc = 0, dec = xmin
      fhour = hr

      CCG_DEC2DATE,   MAX(x), yr, mo, dy, hr, mn, sc
      hr = (mn GT 0 OR sc GT 0) ? hr + 1 : hr
      CCG_DATE2DEC,   yr = yr, mo = mo, dy = dy, hr = hr, mn = 0, sc = 0, dec = xmax

      nhours = CCG_ROUND((xmax - xmin) * HIY, 0) + 1
   ENDIF ELSE BEGIN
      xmin = xaxis[0] & xmax = xaxis[1]
      CCG_DEC2DATE,   xmin, yr, mo, dy, hr, mn, sc
      fhour = hr

      nhours = CCG_ROUND((xmax - xmin) * HIY, 0) + 1
   ENDELSE
   ;
   ;If there are more than 30 hours then re-adjust 'hour' scale.
   ;
   steps = 1
   IF nhours GT 30 THEN BEGIN
           IF nhours MOD 2 EQ 1 THEN nhours ++
           nhours = nhours / 2.0
      steps = 2
   ENDIF

   xtickname = MAKE_ARRAY(nhours, /STR, VALUE = ' ')

   j = fhour
   FOR i = 0, nhours - 1 DO BEGIN
      IF j GT 23 THEN j = 0
      xtickname[i] = ToString(j)
      j = j + steps
   ENDFOR

   e = { XSTYLE : 1, $
         XRANGE : [xmin, xmax], $
         XTICKS : nhours - 1, $
         XMINOR : 1, $
         XTICKNAME : xtickname}

   RETURN, e
END

FUNCTION  TIMESTAMP_ATTRIBUTES, $
          position=position, $
          charthick=charthick, $
          charsize=charsize, $
          orientation=orientation, $
          alignment=alignment, $
          text=text

   ; initialization

   today = CCG_SYSDATE()

   ; Default assignments

   charsize = KEYWORD_SET(charsize) ? FLOAT(charsize) : 0
   charthick = KEYWORD_SET(charthick) ? FLOAT(charthick) : 0
   orientation = KEYWORD_SET(orientation) ? FLOAT(orientation) : 90
   alignment = KEYWORD_SET(alignment) ? FLOAT(alignment) : 0.0
   text = KEYWORD_SET(text) ? text : 'NOAA ESRL Carbon Cycle, ' + today.s4

   ts_attr = { text:text, charsize:charsize, charthick:charthick, alignment:alignment, orientation:orientation }

   RETURN, ts_attr 

END

FUNCTION ANNOTATION_ATTRIBUTES, text = text, $
                                position = position, $
                                orientation = orientation, $
                                charsize = charsize, $
                                charthick = charthick, $
                                color = color

   ; Default assignments

   text = KEYWORD_SET(text) ? STRING(text) : ''
   position = KEYWORD_SET(position) ? position : 'TL'
   orientation = KEYWORD_SET(orientation) ? orientation : 0.0
   charsize = KEYWORD_SET(charsize) ? charsize : 1.5 
   charthick = KEYWORD_SET(charthick) ? charthick : 2.0 
   color = KEYWORD_SET(color) ? color : 1

   ; create a structure

   annotation_attr = {text:text, $
                      position:position, $
                      orientation:orientation, $
                      charsize:charsize, $
                      charthick:charthick, $
                      color:color}

   RETURN, annotation_attr

END


FUNCTION  LOGO_ATTRIBUTES, $
          position=position, $
          xsize=xsize, ysize=ysize, $
          file=file

   ; Default assignments

   ; if file has no path then use default directory

   file = KEYWORD_SET(file) ? file : ''

   file = STREGEX(file, '/', /BOOLEAN) NE 0 ? file : '/ccg/web/logos/'+file

   ; position can either be a string (TL, TR, BL, BR) or a 2-element vector 
   ; containing x and y in NORMAL coordinates ([0.5, 0.5])

   position = KEYWORD_SET(position) ? position : 'BR'

   ; xsize and ysize are in NORMAL coordinates

   xsize = KEYWORD_SET(xsize) ? xsize : 0
   ysize = KEYWORD_SET(ysize) ? ysize : 0
 
   logo_attr = { file:file, position:position, xsize:xsize, ysize:ysize }

   RETURN, logo_attr 

END

FUNCTION  DATA_ATTRIBUTES, x, y, $
          xunc = xunc, $
          yunc = yunc, $
          linestyle = linestyle, $
          linethick = linethick, $
          linecolor = linecolor, $
          symstyle = symstyle, $
          symthick = symthick, $
          symcolor = symcolor, $
          symsize = symsize, $
          symfill = symfill, $
          charsize = charsize, $
          charthick = charthick, $
          chartext = chartext, $
          charcolor = charcolor, $
          noscale = noscale, $
          yclip = yclip, $
          label = label
    
   ;   define some default values

   x = REFORM(DOUBLE(x))
   y = REFORM(DOUBLE(y))

   IF N_ELEMENTS(x) NE N_ELEMENTS(y) THEN $
   CCG_FATALERR, "DATA ATTRIBUTES Error: x and y must be the same size."

   xunc = (KEYWORD_SET(xunc)) ? REFORM(xunc) : MAKE_ARRAY(N_ELEMENTS(x), /DOUBLE, VALUE = 0)
   yunc = (KEYWORD_SET(yunc)) ? REFORM(yunc) : MAKE_ARRAY(N_ELEMENTS(y), /DOUBLE, VALUE = 0) 

   IF N_ELEMENTS(x) NE N_ELEMENTS(xunc) THEN $
   CCG_FATALERR, "DATA ATTRIBUTES Error: x and xunc must be the same size."

   IF N_ELEMENTS(y) NE N_ELEMENTS(yunc) THEN $
   CCG_FATALERR, "DATA ATTRIBUTES Error: y and yunc must be the same size."

   linestyle = (KEYWORD_SET(linestyle)) ? FIX(linestyle) : 0
   linethick = (KEYWORD_SET(linethick)) ? FLOAT(linethick) : 2.0
   linecolor = (KEYWORD_SET(linecolor)) ? FIX(linecolor) : 0
   symstyle = (KEYWORD_SET(symstyle)) ? symstyle : 0 
   symthick = (KEYWORD_SET(symthick)) ? FLOAT(symthick) : 2.0
   symcolor = (KEYWORD_SET(symcolor)) ? FIX(symcolor) : 0
   symsize = (KEYWORD_SET(symsize)) ? FLOAT(symsize) : 0.6
   symfill = (KEYWORD_SET(symfill)) ? FIX(symfill) : 0

   ; "chartext" will replace the "label" keyword.
   ;  The "label" keyword can be phased out 2009-06-29 (kam)

   IF KEYWORD_SET(label) THEN chartext = STRING(label)

   chartext = (KEYWORD_SET(chartext)) ? chartext : ""
   
   charsize = (KEYWORD_SET(charsize)) ? FLOAT(charsize) : 1.5
   charthick = (KEYWORD_SET(charthick)) ? FLOAT(charthick) : 2.0
   charcolor = (KEYWORD_SET(charcolor)) ? FLOAT(charcolor) : 0
   noscale = (KEYWORD_SET(noscale)) ? 1 : 0
   yclip = (KEYWORD_SET(yclip)) ? 1 : 0

   ;
   ;   create a structure 
   ;
   data_attr = CREATE_STRUCT( $
              'x', x, $
              'y', y, $
              'xunc', xunc, $
              'yunc', yunc, $
              'linestyle', linestyle, $
              'linethick', linethick, $
              'linecolor', linecolor, $
              'symstyle', symstyle, $
              'symthick', symthick, $
              'symcolor', symcolor, $
              'symsize', symsize, $
              'symfill', symfill, $
              'charsize', charsize, $
              'chartext', chartext, $
              'charthick', charthick, $
              'charcolor', charcolor, $
              'noscale', noscale, $
              'yclip',yclip )

   RETURN, data_attr 
END

FUNCTION  PLOT_ATTRIBUTES, data = data, $
             title = title, $
             xtitle = xtitle, $
             ytitle = ytitle, $
             xaxis = xaxis, $
             yaxis = yaxis, $
             plotthick = plotthick, $
             plotcolor = plotcolor, $
             background = background, $
             logo = logo, $
             sp = sp, $
             annotate = annotate, $
             atext = atext, $
             annotation = annotation, $
             tlegend = tlegend, $
             legend = legend, $
             llegend = llegend, $
             slegend = slegend, $
             position = position, $
             xcharsize = xcharsize, $
             ycharsize = ycharsize, $
             charsize = charsize, $
             charthick = charthick, $
             xcustom = xcustom, $
             ycustom = ycustom, $
             ticklen = ticklen, $
             timestamp = timestamp, $
             nogrid = nogrid
    
   ;   error checking
    
   IF (r = SIZE(data, /TYPE)) NE 8 THEN $
   CCG_FATALERR, "PLOT_ATTRUBUTES Error: Passed data keyword is not a structure."
    
   ;   define some default values
    
   title = (KEYWORD_SET(title)) ? STRING(title) : ''
   xtitle = (KEYWORD_SET(xtitle)) ? STRING(xtitle) : ''
   ytitle = (KEYWORD_SET(ytitle)) ? STRING(ytitle) : ''
   xaxis = (KEYWORD_SET(xaxis)) ? xaxis : 0
   yaxis = (KEYWORD_SET(yaxis)) ? yaxis : 0
   plotthick = (KEYWORD_SET(plotthick)) ? FLOAT(plotthick) : 2.0
   plotcolor = (KEYWORD_SET(plotcolor)) ? FIX(plotcolor) : 1 
   sp = (KEYWORD_SET(sp)) ? STRING(sp) : ''
   tlegend = (KEYWORD_SET(tlegend)) ? STRING(tlegend) : ''
   legend = (KEYWORD_SET(legend)) ? STRING(legend) : 'BL'
   llegend = (KEYWORD_SET(llegend)) ? STRING(llegend) : ''
   slegend = (KEYWORD_SET(slegend)) ? STRING(slegend) : ''
   legend = (KEYWORD_SET(llegend) OR KEYWORD_SET(slegend)) ? '' : legend
   position = (KEYWORD_SET(position)) ? position : 0
   xcharsize = (KEYWORD_SET(xcharsize)) ? FLOAT(xcharsize) : 0.7
   ycharsize = (KEYWORD_SET(ycharsize)) ? FLOAT(ycharsize) : 0.8
   charsize = (KEYWORD_SET(charsize)) ? FLOAT(charsize) : 1.5
   charthick = (KEYWORD_SET(charthick)) ? FLOAT(charthick) : 2.0
   xcustom = (KEYWORD_SET(xcustom)) ? STRING(xcustom) : ''
   ycustom = (KEYWORD_SET(ycustom)) ? STRING(ycustom) : ''
   ticklen = (SIZE(ticklen, /TYPE) NE 0) ? ticklen : -0.02
   ticklen = (KEYWORD_SET(nogrid)) ? ticklen : 1.0
   gridstyle = (KEYWORD_SET(nogrid)) ? 0 : 1
   annotate = KEYWORD_SET(annotate) ? annotate : 'TRV'
   atext = KEYWORD_SET(atext) ? atext : [""]
   background = KEYWORD_SET(background) ? background : 0
   logo = KEYWORD_SET(logo) ? logo : 0
   timestamp = KEYWORD_SET(timestamp) ? timestamp : TIMESTAMP_ATTRIBUTES()

   ; determine annotation datatype, Modified: 29 Oct 2010, M. Trudeau

   CASE SIZE(annotation, /TYPE) OF
     7: BEGIN 
          annotation_ = annotation
 
          FOR i = 0, N_ELEMENTS(annotation_) - 1 DO BEGIN
             tag = 'a' + ToString(i)
             struct = ANNOTATION_ATTRIBUTES(text = annotation_[i])
             annotation = (i EQ 0) ? CREATE_STRUCT(tag, struct) : CREATE_STRUCT(annotation, tag, struct)
          ENDFOR
        END
     8: BEGIN
          FOR i = 0, N_TAGS(annotation) - 1 DO BEGIN
             struct2 = (TOTAL(STRMATCH(TAG_NAMES(annotation.(i)), 'POSITION')) EQ 0) ? ANNOTATION_ATTRIBUTES() : $
                       ANNOTATION_ATTRIBUTES(_EXTRA = {POSITION : annotation.(i).position}) 
          
             IF NOT IS_STRUCT_MATCH(struct1 = annotation.(i), struct2 = struct2) THEN CONTINUE
          
             tag = 'a' + ToString(i)
             struct = ANNOTATION_ATTRIBUTES(_EXTRA = annotation.(i))
             annotation_ = (SIZE(annotation_, /TYPE) EQ 0) ? CREATE_STRUCT(tag, struct) : CREATE_STRUCT(annotation_, tag, struct)
          ENDFOR
          
          annotation = (SIZE(annotation_, /TYPE) EQ 8) ? annotation_ : 0
        END 
     ELSE: annotation = 0
   ENDCASE
   ;
   ;   create a structure 
   ;
   plot_attr =  { data:data, $
                  title:title, $
                  xtitle:xtitle, $
                  ytitle:ytitle, $
                  annotate:annotate, $
                  atext:atext, $
                  annotation:annotation, $
                  xaxis:xaxis, $
                  yaxis:yaxis, $
                  plotthick:plotthick, $
                  plotcolor:plotcolor, $
                  sp:sp, $
                  tlegend:tlegend, $
                  legend:legend, $
                  llegend:llegend, $
                  slegend:slegend, $
                  position:position, $
                  xcharsize:xcharsize, $
                  ycharsize:ycharsize, $
                  charsize:charsize, $
                  charthick:charthick, $
                  xcustom:xcustom, $
                  ycustom:ycustom, $
                  ticklen:ticklen, $
                  background:background, $
                  logo:logo, $
                  timestamp:timestamp, $
                  gridstyle:gridstyle $
                }

   RETURN, plot_attr 
END

PRO    CCG_GRAPHICS, $

   graphics = graphics, $
   insert = insert, $
   pen = pen, $
   portrait = portrait, $
   font = font, $
   notimestamp = notimestamp, $
   help = help, $
   saveas = saveas, $
   row = row, $
   col = col, $
   xpixels=xpixels, $
   ypixels=ypixels, $
   window = window, $
   depth = depth, $
   wtitle = wtitle, $
   allxrange = allxrange, $
   allyrange = allyrange, $
   chmod = chmod, $
   error = error, $
   quality = quality, $
   optimization=optimization, $
   dev = dev
   ;
   ; Help?
   ;
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   ;
   ; Check for non-keyword parameters
   ; If exist, they must be structures
   ;
   IF NOT KEYWORD_SET(graphics) THEN CCG_SHOWDOC

   IF (r = SIZE(graphics, /TYPE)) NE 8 THEN CCG_SHOWDOC
   ;
   ; set a few default values
   ;
   window = (KEYWORD_SET(window)) ? window : '0'
   wtitle = (KEYWORD_SET(wtitle)) ? wtitle : ''
   saveas = (KEYWORD_SET(saveas)) ? saveas : ''
   insert = (KEYWORD_SET(insert)) ? 1 : 0
   portrait = KEYWORD_SET(portrait) ? 1 : 0
   font = KEYWORD_SET(font) ? font : ''
   notimestamp = KEYWORD_SET(notimestamp) ? 1 : 0
   xpixels = KEYWORD_SET(xpixels) ? xpixels : 0
   ypixels = KEYWORD_SET(ypixels) ? ypixels : 0
   allxrange = KEYWORD_SET(allxrange) ? 1 : 0 
   allyrange = KEYWORD_SET(allyrange) ? 1 : 0 
   chmod = KEYWORD_SET(chmod) ? FIX(chmod) : 0 
   optimization = KEYWORD_SET(optimization) ? optimization : 'quality'
   depth = (KEYWORD_SET(depth)) ? depth : ''
   ;
   ; Misc initialization
   ;
   DEFAULT = (-9999.999)
   error = (-1)

   ngraphics = N_TAGS(graphics)
   
   ; Prepare a change of file permissions, added 14 November 2008 - Trudeau
   ; (1) Convert octal file permissions mask to bit mask
   ; (2) Test for pre-existing files of the same name (Permissions will be set on new files only)

   READS, ToString(chmod), FORMAT = '(O)', bitmask
   bitmask = FIX(bitmask)

   IF KEYWORD_SET(dev) AND KEYWORD_SET(bitmask) THEN BEGIN

      ; extract the path + filename (without file extension) from saveas

      filename = (STRPOS(saveas, '.') EQ -1) ? saveas : STRMID(saveas, 0, STRPOS(saveas, '.', /REVERSE_SEARCH))

      ; compile a list of requested file extensions from dev

      ext = STRSPLIT(dev, '_', /EXTRACT)

      ; create a list of all possible output filenames (always check for a postscript)

      files = [saveas, filename + '.' + ext, filename + '.ps']

      ; search for pre-existing files

      preexisting = FILE_TEST(files)

   ENDIF ELSE preexisting = 1
   ;
   ; set up graphics device 
   ;
   IF NOT insert THEN CCG_OPENDEV, dev = dev, pen = pen, saveas = saveas, $
   win = window, font=font, portrait = portrait, title = wtitle, $
   xpixels=xpixels, ypixels=ypixels
   ;
   ; Aspect Ratio
   ;
   aspect = !D.X_SIZE / FLOAT(!D.Y_SIZE)
   ;
   ; If row and col are not specified,
   ; the number of rows and colums should
   ; be multiple of number of graphs.
    
   row = (KEYWORD_SET(row)) ? row : CEIL(SQRT(ngraphics))
   col = (KEYWORD_SET(col)) ? col : CEIL(FLOAT(ngraphics) / row)
   !P.MULTI = [0, col, row, 0, 0]
   
   ; Common X and/or Y ranges for multiple plots?
   ; Added FindPlotsRange routine. 2008-12-19 (kam)

   IF allxrange EQ 1 AND ngraphics GT 1 THEN FindPlotsRange, graphics, range=x_allplots_range, type='x'
   IF allyrange EQ 1 AND ngraphics GT 1 THEN FindPlotsRange, graphics, range=y_allplots_range, type='y'

   ; loop through each graph
    
   FOR i = 0, ngraphics - 1 DO BEGIN
       
      ; retrieve plot structure tags, assigned values, and data
       
      graph = graphics.(i)
          
      ; get gas-dependent plotting title
        
      IF KEYWORD_SET(graph.sp) AND NOT KEYWORD_SET(graph.ytitle) THEN BEGIN
         CCG_GASINFO, sp = graph.sp, title = ytitle
         graph.ytitle = ytitle
      ENDIF
       
      ; Allow user to specify Y range
       
      IF SIZE(graph.yaxis, /DIMENSION) EQ 4 AND TOTAL(graph.yaxis) NE 0 THEN BEGIN
      ey = { ystyle:1, yrange:[graph.yaxis[0], graph.yaxis[1]], yticks:graph.yaxis[2], yminor:graph.yaxis[3] }
      ENDIF ELSE ey = { ystyle:16 }
       
      ; Allow user to specify X range
       
      IF SIZE(graph.xaxis, /DIMENSION) EQ 4 AND TOTAL(graph.xaxis) NE 0 THEN BEGIN
      ex = { xstyle:1, xrange:[graph.xaxis[0], graph.xaxis[1]], xticks:graph.xaxis[2], xminor:graph.xaxis[3] }
      ENDIF ELSE ex = { xstyle:16 }

      ; Modified to use FindDataRange routine. 2008-12-19 (kam)

      FindDataRange, graph.data, range=x_alldata_range, type='x', axis=graph.xaxis
      FindDataRange, graph.data, range=y_alldata_range, type='y', axis=graph.yaxis

      ; Are there at least 2 valid data points?
       
      valid = WHERE((FINITE(x_alldata_range) AND FINITE(y_alldata_range)) EQ 1)
      IF N_ELEMENTS(valid) LT 2 THEN CONTINUE 

      ; The keyword "all<axis>range" ensures that all plots will get the same 
      ; autoscale result from IDL (see the "FindPlotsRange" procedure).  The
      ; "FindPlotsRange" procedure is similar to the procedure "FindDataRange", 
      ; which ensures that a single plot will get the same autoscale result from 
      ; IDL.  Added 2008-12-19 (kam)

      IF allxrange EQ 1 AND ngraphics GT 1 THEN BEGIN

         dmax = MAX([x_alldata_range, x_allplots_range], MIN=dmin)
         x_alldata_range = [dmin, dmax]

      ENDIF

      IF allyrange EQ 1 AND ngraphics GT 1 THEN BEGIN

         dmax = MAX([y_alldata_range, y_allplots_range], MIN=dmin)
         y_alldata_range = [dmin, dmax]

      ENDIF
       
      ; custom x-axis?
       
      CASE graph.xcustom OF
      'hour':  ex = InHours(x_alldata_range, xaxis = graph.xaxis)
      'day':   ex = InDays(x_alldata_range, xaxis = graph.xaxis)
      'month': ex = InMonths(x_alldata_range, xaxis = graph.xaxis)
      'log':   BEGIN
               ex = CREATE_STRUCT(ex, 'xlog', 1)
          ;
          ; timestamp not function for log plots...fix this!
          ;
               notimestamp = 1
               END
      ELSE:
      ENDCASE
      ;
      ; custom y-axis?
      ;
      CASE graph.ycustom OF
      'log':   BEGIN
               ey = CREATE_STRUCT(ey, 'ylog', 1)
          ;
          ; timestamp not function for log plots...fix this!
          ;
               notimestamp = 1
               END
      ELSE:
      ENDCASE

      ndata = N_TAGS(graph.data)

      ; set of "plot" keywords

      ep = { nodata:1, color:pen[graph.plotcolor], $
             charsize:graph.charsize, charthick:graph.charthick, $
             title:graph.title, noerase:0, $
             ygridstyle:graph.gridstyle, ythick:graph.plotthick, yticklen:graph.ticklen, $
             ycharsize:graph.ycharsize*graph.charsize, ytitle:graph.ytitle, $
             xgridstyle:graph.gridstyle, xthick:graph.plotthick, xticklen:graph.ticklen, $
             xcharsize:graph.xcharsize*graph.charsize, xtitle:graph.xtitle $
           }

       
      ; Create "EXTRA" structure
       
      e = CREATE_STRUCT(ex, ey, ep)
       
      ; include position information if passed by user 
      ; (this overrides the !P.MULTI system variable defaults with each loop)
       
      IF KEYWORD_SET(graph.position) THEN e = CREATE_STRUCT(e, {POSITION:graph.position})

      ; Define !P variables (ORDER MATTERS: 1)

      e.xstyle += 4
      e.ystyle += 4

      PLOT,   [x_alldata_range], [y_alldata_range], _EXTRA = e

      ; Draw plot with background only

      IF graph.background NE 0 THEN BEGIN

         POLYFILL, [!X.CRANGE, REVERSE(!X.CRANGE)], $
         [!Y.CRANGE[0], !Y.CRANGE[0], !Y.CRANGE[1], !Y.CRANGE[1]], COLOR = graph.background

      ENDIF

      e.xstyle -= 4
      e.ystyle -= 4
      e.noerase = 1

      !P.MULTI[0] ++
       
      ; Initialize data-independent legend/annotation parameters (ORDER MATTERS: 2)

      xrange = (STRCMP(graph.xcustom, 'log', /FOLD_CASE) EQ 1) ? 10^!X.CRANGE : !X.CRANGE
      yrange = (STRCMP(graph.ycustom, 'log', /FOLD_CASE) EQ 1) ? 10^!Y.CRANGE : !Y.CRANGE

      xy = CONVERT_COORD(xrange, yrange, /DATA, /TO_DEVICE)
      dx = xy[0, 1] - xy[0, 0]
      dy = xy[1, 1] - xy[1, 0]

      xy = CONVERT_COORD([xy[0,0] + 0.025 * dx / aspect , xy[0,1] - 0.035 * dx / aspect], $
                         [xy[1,0] + 0.025 * dy / aspect, xy[1,1] - 0.055 * dy / aspect], /DEVICE, /TO_DATA)

      top = xy[1,1]
      bottom = xy[1,0]
      left = xy[0,0]
      right = xy[0,1]

      ; add logo? (ORDER MATTERS: 3)

      IF SIZE(graph.logo, /TYPE) EQ 8 THEN BEGIN

         IF SIZE(graph.logo.position, /TYPE) EQ 7 THEN BEGIN

            CASE graph.logo.position OF
            'TL': xy = [left, top]
            'BL': xy = [left, bottom]
            'TR': xy = [right, top]
            'BR': xy = [right, bottom]
            ELSE:  xy = [right, bottom]
            ENDCASE

            xy2 = CONVERT_COORD(xy[0], xy[1], /DATA, /TO_NORMAL)

         ENDIF ELSE xy2 = graph.logo.position

         PLOT_LOGO, xy2[0]-graph.logo.xsize/2, xy2[1]+graph.logo.ysize/2, $
         xsize=graph.logo.xsize, ysize=graph.logo.ysize, portrait=portrait, $
         file=graph.logo.file, dev=dev, pen=pen

      ENDIF

      ; Draw plot (ORDER MATTERS: 4)

      PLOT,   [x_alldata_range], [y_alldata_range], _EXTRA = e

      !P.MULTI[0] --

      ; legend counter

      lcnt = 0

      FOR ii = 0, ndata - 1 DO BEGIN

         data = graph.data.(ii)

         color = (ii LT 70) ? pen[ii + 1] : pen[(ii + 1) MOD 70]
         symstyle_ = (data.symstyle) ? data.symstyle : ii + 1

         data_tags = TAG_NAMES(data)

         x = data.x
         y = data.y

   ;      x = ClipOnXRange(x)

         IF STRCMP(graph.ycustom, 'log', /FOLD_CASE) EQ 0 AND data.noscale EQ 0 THEN y = ClipOnYRange(y)

         ; Added yclip tag 2013-02-15 (kam)
         IF data.yclip EQ 1 THEN y = ClipOnYRange(y)
         ;
         ; Symbol?
         ; 
         symsize = data.symsize
         symthick = data.symthick 
         symfill = data.symfill 
         symcolor = (data.symcolor NE 0) ? pen[data.symcolor] : color

         CASE (r = SIZE(data.symstyle, /TYPE)) OF
         2:   BEGIN
              psym = 0
              IF data.symstyle EQ -10 THEN psym = 10
              IF data.symstyle GT   0 THEN psym = 8

              symstyle_ = data.symstyle
              END
         7:   BEGIN
              psym = 0
              FOR iii = 0, N_ELEMENTS(x) - 1 DO $
              XYOUTS, x[iii], y[iii], data.symstyle, COLOR = symcolor, $
              CHARSIZE = data.symsize, CHARTHICK = data.symthick, ALIGNMENT = 0.5
              END
         ELSE:   
         ENDCASE
          
         ; Plot symbol
          
         IF psym EQ 8 THEN BEGIN

            CCG_SYMBOL, sym = symstyle_, fill = symfill, thick = symthick
            OPLOT, [x], [y], COLOR = symcolor, PSYM = psym, SYMSIZE = symsize

         ENDIF

         ; Line?
           
         linestyle = data.linestyle
         linethick = data.linethick
         linecolor = (data.linecolor NE 0) ? pen[data.linecolor] : color
          
         ; Plot Histogram
         ; Added histogram option, set by symstyle=(-10). 2009-06 10 (kam)
          
         IF psym EQ 10 THEN BEGIN

            ; width of polyfill is 40% of minimum dx

            width = 0.4 * MIN( ABS( x - SHIFT(x, 1) ) )

            FOR ib=0, N_ELEMENTS(x)-1 DO BEGIN

               pxval = [ x[ib]-width, x[ib]-width, x[ib]+width, x[ib]+width ]
               pyval = [ 0, y[ib], y[ib], 0]

               POLYFILL, pxval, pyval, COLOR=symcolor
               PLOTS, pxval, pyval, COLOR=linecolor

            ENDFOR

         ENDIF

         IF linestyle GE 0 AND PSYM NE 10 THEN $
         OPLOT, [x], [y], COLOR = linecolor, THICK = linethick, LINESTYLE = linestyle

         ;
         ; Error Bars?
         ; Note:  Error bar color is matched to symbol color.  If user doesn't specify
         ; a symbol color, a default symbol color will be assigned.  
         ;
         IF TOTAL(data.xunc) NE 0 THEN BEGIN
            IF SIZE(data.xunc, /N_DIMENSIONS) EQ 1 THEN CCG_ERRPLOT, $
               data.y, data.x - data.xunc, data.x + data.xunc, COLOR = symcolor, y = 1, thick = linethick
            IF SIZE(data.xunc, /N_DIMENSIONS) EQ 2 THEN CCG_ERRPLOT, $
               data.y, data.xunc[0, *], data.xunc[1, *], COLOR = symcolor, y = 1, thick = linethick
         ENDIF
         IF TOTAL(data.yunc) NE 0 THEN BEGIN
            IF SIZE(data.yunc, /N_DIMENSIONS) EQ 1 THEN CCG_ERRPLOT, $
               data.x, data.y - data.yunc, data.y + data.yunc, COLOR = symcolor, thick = linethick
            IF SIZE(data.yunc, /N_DIMENSIONS) EQ 2 THEN CCG_ERRPLOT, $
               data.x, data.yunc[0, *], data.yunc[1, *], COLOR = symcolor, thick = linethick
         ENDIF

         e = CREATE_STRUCT({  CHARTHICK : data.charthick, CHARSIZE : 0.85 * data.charsize })

         ; Add a legend?

         ; Message from Mike: Ken, in consolidating the legend/llegend/slegend keywords into the "legend" keywork,
         ;                    make an option for no legend (perhaps legend = "") even though the user may have passed
         ;                    label/chartext information into DATA_ATTRIBUTES
         IF KEYWORD_SET(graph.legend) OR KEYWORD_SET(graph.llegend) OR KEYWORD_SET(graph.slegend) THEN BEGIN

            j = WHERE(STRCMP(data_tags, 'chartext', /FOLD_CASE))
            IF j[0] EQ -1 THEN CONTINUE
     
            IF (data.chartext EQ '') THEN CONTINUE
            xyout = data.chartext + '  '

            IF KEYWORD_SET(graph.legend) THEN legend = STRUPCASE(graph.legend)
            IF KEYWORD_SET(graph.llegend) THEN legend = STRUPCASE(graph.llegend)
            IF KEYWORD_SET(graph.slegend) THEN legend = STRUPCASE(graph.slegend)

            text_ali = 0

            CASE legend OF
            'TL': xy = [left, top]
            'BL': xy = [left, bottom]
            'TLH': xy = [left, top]
            'BLH': xy = [left, bottom]
            'TR': BEGIN
                  xy = [right, top]
                  text_ali=1
                  END
            'BR': BEGIN
                  xy = [right, bottom]
                  text_ali=1
                  END
            ELSE:  xy = [left, top]
            ENDCASE

            ; Convert coordinates to device

            xy = CONVERT_COORD(xy, /DATA, /TO_DEVICE)

            ; Do we have a legend title to plot?

            IF KEYWORD_SET(graph.tlegend) THEN BEGIN
            
               ; If we have a "top" legend then plot the legend title first

               g = CREATE_STRUCT(e, { COLOR : pen[graph.plotcolor] })

               IF (lcnt EQ 0) AND (STRMID(legend, 0, 1) EQ 'T') THEN BEGIN
                  yadj = 1.25 * !D.Y_CH_SIZE * e.charsize * lcnt
                  yadj = -yadj
                  yadj = STRLEN(legend) EQ 2 ? yadj : 0

                  xy2 = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_DATA)

                  IF yadj NE 0 OR lcnt EQ 0 THEN XYOUTS, xy2[0], xy2[1], graph.tlegend, _EXTRA = g ELSE XYOUTS, graph.tlegend, _EXTRA = g

                  lcnt ++
               ENDIF

               ; If we have a "bottom" legend then plot the legend title last

               IF (lcnt EQ ndata - 1) AND (STRMID(legend, 0, 1) EQ 'B') THEN BEGIN
                  yadj = 1.25 * !D.Y_CH_SIZE * e.charsize * (lcnt + 1)
                  yadj = STRLEN(legend) EQ 2 ? yadj : 0

                  xy2 = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_DATA)

                  IF yadj NE 0 OR lcnt EQ 0 THEN XYOUTS, xy2[0], xy2[1], graph.tlegend, _EXTRA = g ELSE XYOUTS, graph.tlegend, _EXTRA = g
               ENDIF 
            ENDIF


            ; Set legend color
            ; Use charcolor if set, otherwise use linecolor or symcolor

            charcolor = data.charcolor
            IF charcolor EQ 0 AND linestyle GE 0 THEN charcolor = linecolor
            IF charcolor EQ 0 AND symstyle_ NE -1 THEN charcolor = symcolor
            
            f = CREATE_STRUCT(e, { COLOR:charcolor, ali:text_ali } )

            ; Vertical adjustment

            yadj = 1.25 * !D.Y_CH_SIZE * e.charsize * lcnt
            yadj = (STRMID(legend, 0, 1) EQ 'B') ? yadj : -yadj
            yadj = STRLEN(legend) EQ 2 ? yadj : 0

            xy2 = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_DATA)

            ; Plot legend

            IF KEYWORD_SET(graph.legend) THEN BEGIN
               IF yadj NE 0 OR lcnt EQ 0 THEN XYOUTS, xy2[0], xy2[1], xyout, _EXTRA = f ELSE XYOUTS, xyout, _EXTRA = f
            ENDIF

            ; Plot llegend

            IF KEYWORD_SET(graph.llegend) THEN BEGIN
               IF STRLEN(legend) GT 2 THEN CCG_FATALERR, 'Horizontal line legend not allowed. Exiting...'
               IF data.linestyle EQ -1 THEN CCG_FATALERR, '"llegend" keyword set without "linestyle". Exiting...'

               xynormal = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_NORMAL)

               CCG_LLEGEND, x = xynormal[0], y = xynormal[1], $
                            tarr = xyout, larr = data.linestyle, carr = linecolor, $ 
                            thick = linethick, charsize = f.charsize, charthick = f.charthick
            ENDIF

            ; Plot slegend

            IF KEYWORD_SET(graph.slegend) THEN BEGIN
               IF STRLEN(legend) GT 2 THEN CCG_FATALERR, 'Horizontal symbol legend not allowed. Exiting...'
               IF data.symstyle EQ 0 THEN CCG_FATALERR, '"slegend" specified without "symstyle". Exiting...'

               xynormal = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_NORMAL)

               CCG_SLEGEND, x = xynormal[0], y = xynormal[1], $
                            tarr = xyout, sarr = data.symstyle, farr = symfill, carr = symcolor, $ 
                            thick = symthick, charsize = f.charsize, charthick = f.charthick
            ENDIF

            lcnt ++

         ENDIF

      ENDFOR
      
      ; plot annotations, created 2009-06-26 (kam, mt), modified 2 Nov 2010 (mt) 

      IF KEYWORD_SET(graph.annotation) THEN BEGIN

         ; group annotation tags by position

         FOR itag = 0, N_TAGS(graph.annotation) - 1 DO BEGIN
            position_ = STRJOIN(ToString(graph.annotation.(itag).position), ",")
            position = (itag EQ 0) ? position_ : [position, position_]
         ENDFOR

         group = position[UNIQ(position, SORT(position))]

         ; loop through groups

         FOR igroup = 0, N_ELEMENTS(group) - 1 DO BEGIN

            jtag = WHERE(position EQ group[igroup])
          
            IF STRMATCH(group[igroup], 'B*') THEN jtag = REVERSE(jtag)

            ; loop through annotations

            FOR itag = 0, N_ELEMENTS(jtag) - 1 DO BEGIN

               attr = graph.annotation.(jtag[itag])

               IF (SIZE(attr.position, /TYPE) EQ 7) THEN BEGIN
                  CASE STRUPCASE(attr.position) OF 
                  'BL': xydata = [left, bottom]
                  'BLH': xydata = [left, bottom]
                  'BR': xydata = [right, bottom]
                  'TL': xydata = [left, top]
                  'TLH': xydata = [left, top]
                  'TR': xydata = [right, top]
                  ELSE: xydata = [right, top]
                  ENDCASE
               ENDIF ELSE BEGIN
                  xydata = attr.position
               ENDELSE

               ; calculate vertical adjustment, add to device coordinates, convert to data coordinates

               yadj = 1.25 * !D.Y_CH_SIZE * attr.charsize * itag
               IF STRMATCH(group[igroup], 'T*') THEN yadj = -yadj 
               IF NOT (STRLEN(group[igroup]) EQ 2) THEN yadj = 0

               xydevice = CONVERT_COORD(xydata, /DATA, /TO_DEVICE)
               xydata = CONVERT_COORD(xydevice[0], xydevice[1] + yadj, /DEVICE, /TO_DATA)

               ; make subsequent calls to XYOUTS without "xydata" when multiple annotations are plotted horizontally

               ali = STRMATCH(group[igroup], '?L*') ? 0 : 1
               space = (N_ELEMENTS(jtag) EQ 1) ? "" : "  "

               IF (yadj NE 0) OR (itag EQ 0) THEN BEGIN
                  XYOUTS, xydata[0], xydata[1], attr.text + space, _EXTRA = { CHARSIZE:attr.charsize, $
                                                                              CHARTHICK:attr.charthick, $
                                                                              ORIENTATION:attr.orientation, $
                                                                              COLOR:pen[attr.color], $
                                                                              ALI:ali }
               ENDIF ELSE BEGIN
                  XYOUTS, attr.text + space, _EXTRA = { CHARSIZE:attr.charsize, $
                                                        CHARTHICK:attr.charthick, $
                                                        ORIENTATION:attr.orientation, $
                                                        COLOR:pen[attr.color], $
                                                        ALI:ali }
               ENDELSE

            ENDFOR
 
         ENDFOR

      ENDIF

      ; annotate graph?
      ; This is original code and will be removed once the above
      ; code has stabilized.  2009-06-26 (kam, mt)

      IF SIZE(graph.atext, /TYPE) EQ 7 THEN BEGIN

         graph.annotate = STRUPCASE(graph.annotate)

         CASE graph.annotate OF
         'BL': xy = [left, bottom]
         'BR': xy = [right, bottom]
         'TL': xy = [left, top]
         'TR': xy = [right, top]
         ELSE:  xy = [right, top]
         ENDCASE

         ; convert coordinates to device

         xy = CONVERT_COORD(xy, /DATA, /TO_DEVICE)

         ali = (STRMID(graph.annotate, 1, 1) EQ 'L')  ? 0 : 1
         graph.atext = (STRMID(graph.annotate, 0, 1) EQ 'T') ? graph.atext : REVERSE(graph.atext)

         f = CREATE_STRUCT(e, { COLOR:pen[1], ALI:ali })

         FOR k = 0, N_ELEMENTS(graph.atext) - 1 DO BEGIN

            ; vertical adjustment
      
            yadj = 1.25 * !D.Y_CH_SIZE * e.charsize * k
            yadj = (STRMID(graph.annotate, 0, 1) EQ 'B') ? yadj : -yadj

            xy2 = CONVERT_COORD(xy[0], xy[1] + yadj, /DEVICE, /TO_DATA)

            XYOUTS, xy2[0], xy2[1], graph.atext[k], _EXTRA = f

         ENDFOR

      ENDIF

      IF notimestamp EQ 0 THEN BEGIN

         ; Add time stamp

         xy = CONVERT_COORD(!X.CRANGE, !Y.CRANGE, /DATA, /TO_NORMAL)
         dy = xy[1, 1] - xy[1, 0]
         z = graph.timestamp.charsize NE 0  ? graph.timestamp.charsize : graph.charsize
         charsize = dy / aspect * z

         xy = CONVERT_COORD(!X.CRANGE, !Y.CRANGE, /DATA, /TO_DEVICE)
         dx = xy[0, 1] - xy[0, 0]
         dy = xy[1, 1] - xy[1, 0]

         xy = CONVERT_COORD([xy[0, 1] + 0.02 * dx / aspect], [xy[1, 0] + 0.01 * dy / aspect], /DEVICE, /TO_NORMAL)

         CCG_TIMESTAMP, $
         x = xy[0], y = xy[1], $
         ALI = graph.timestamp.alignment, $
         ORI = graph.timestamp.orientation, $
         /NORMAL, $
         text = graph.timestamp.text, $
         charthick = graph.timestamp.charthick NE 0 ? graph.timestamp.charthick : graph.charthick, $
         CHARSIZE = charsize

      ENDIF

   ENDFOR
       
   ; close graphics device
       
   IF NOT insert THEN CCG_CLOSEDEV, dev = dev, saveas = saveas, optimization=optimization, depth=depth 

   ; set user requested file permissions, added 14 November 2008 - Trudeau

   FOR ifiles = 0, N_ELEMENTS(preexisting) - 1 DO BEGIN

      ; if there is a pre-existing file, then no change of permissions

      IF preexisting[ifiles] THEN CONTINUE

      ; if a new file has not been created, then don't attempt a change of permissions

      IF NOT FILE_TEST(files[ifiles]) THEN CONTINUE

      FILE_CHMOD, files[ifiles], bitmask
   ENDFOR

   error = 0

END
