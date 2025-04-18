;+
; NAME:
;   CCG_FILTER
;
; PURPOSE:
;   This IDL procedure constructs a 'selected' or filtered resultant
;   data set based on iterative curve fits to the supplied data values
;   using techniques described by
;
;      Thoning, K.W., P.P. Tans, and W.D. Komhyr,
;      Atmospheric carbon dioxide at Mauna Loa Observatory, 2,
;      Analysis of the NOAA/GMCC data, 1974-1985,
;      J. Geophys. Res., 94, 8549-8565, 1989.
;
;   This procedure calls 'ccgcrv' developed by Kirk Thoning 
;   of the NOAA GMD Carbon Cycle Group.
;
;   The selected record is achieved when an iteration results in no
;   residuals lying outside a tolerance band specified by the user.
;   The tolerance is defined as [sigmafactor * 1 standard deviation of the
;   residuals about the smooth curve, S(t)], where 'sigmafactor' is set by
;   the user.  Values lying outside the tolerance band are flagged as not
;   representative of background conditions and removed from subsequent fits.
;   Fits continue until there are no further values lying outside the specified
;   filter tolerance.
;  
;   Introduced asymmetric filtering (2012-08-30, kam).  If 'sigmafactor' is a
;   2-element vector, the 1st element will be the positive residual sigma
;   factor and the 2nd element will be the negative residual sigma factor.
;   If 'sigmafactor' is a single value, filtering will be symmetric by default.
;
;   Legend Description:
;
;   SQUARE (blue)       ->   Retained values.
;   PLUS   (green)      ->   Pre-existing second column flag that 
;                            was not previously assigned by this 
;                            IDL procedure.
;   ASTERISK (red)      ->   Hard rejection (first column) flag.  
;                            Values are plotted but not used in
;                            fits.
;   PLUS (magenta)      ->   Values that have been determined (by this 
;                            IDL procedure) to be not-representative of 
;                            the distribution (based on sigma_factor). 
;   SQUARE (magenta)    ->   Values that were considered to be not-
;                            representative of the distribution in one
;                            of the curve fit iterations but fell within
;                            the tolerance band during the last iteration.
;                            In other words, these values have been 
;                            re-introduced into the retained data set.
;
;      WARNING:
;
;      Outcome depends on most input keywords.    The keyword 
;      'interval' should reflect the sample frequency of the 
;      source record.
;
;      When the source data are extracted from the CCG database,
;      all measurement values already assigned an "X" in the middle 
;      column of the QC flag will be re-introduced before fitting
;      begins.
;
;      Data values that have been filtered during the iterative fitting 
;      process, but fall within sigma_factor * 1 standard deviation of
;      the final iteration are re-introduced into the retained data set.  
;      These values are plotted as retained values (different color) in 
;      the final iteration plot, but were not used during the last 
;      iterative fit.
;
;      See CCG_CCGVU for further details on curve fitting parameters.
;
; CATEGORY:
;   Models.
;
;  CALLING SEQUENCE:
;   CCG_FILTER,   sp='co2', program='ccgg', x=x, y=y
;
;   CCG_FILTER,   sp='co2', site='brw', program='ccgg'
;
;   CCG_FILTER,   sp='co2', site='lef', program='ccgg', project='ccg_surface', strategy='flask,pfp'
;
;   CCG_FILTER,   sp='ch4', site='cgo', program='ccgg', sigmafactor=3
;   CCG_FILTER,   sp='n2o', site='cgo', program='ccgg', sigmafactor=[3,1]
;
;   CCG_FILTER,   sp='co2c13', program='sil', $
;                 import='/home/ccg/ken/tmp/brw.co2c13',$
;                 skip=10
;
;   CCG_FILTER,   sp='co', $
;                 program='ccgg',$
;                 site='tap', $
;                 /nographics, $
;                 summary='/home/ccg/ken/tmp/tap_sum.co', $
;                 sigmafactor=3
;
; INPUTS:
;   sp:           Trace gas or isotope identifier.
;                 This string keyword must be specified.  See CCG_GASINFO 
;                 for the   current list of recognized trace species.
;                 If 'sp' and 'site' are specified, data are extracted
;                 from CCGG database.
;
;   site:         Site code.  
;                 If 'sp' and 'site' are specified, data are extracted
;                 from CCGG database.
;
;   program:      Program abbreviation (e.g., ccgg, hats, arl, curl)
;                 This string keyword must be specified. 
;
;   project:      Project code ('ccg_aircraft', 'ccg_surface')
;                 Default is ccg_surface.
;
;   strategy:     Sampling Strategy code, e.g., 'flask', 'pfp'.
;                 Default is both, strategy = 'flask,pfp'.
;
;   x:            Array of abscissa values.  This vector must have dates in
;                 decimal-year notation, e.g., 1996.011234.  'x' and 'y' must
;                 have the same dimensions.
;
;   y:            Array of ordinate values.  This vector contains values
;                 to be fitted.  'x' and 'y' must have the same dimensions.
;
;   import:       Data files with decimal year and mixing/isotope ratio value 
;                 in the first and second columns may be imported.  The 
;                 file must not contain blank entries.  'skip' number of
;                 lines may be skipped (see 'skip' keyword).
;
; OPTIONAL INPUT PARAMETERS:
;
;   skip:         Integer specifying the number of lines to skip at the 
;                 beginning of the import file. Default:  skip = 0.
;
;   sigmafactor:  This keyword sets the tolerance window used in determining
;                 if values are representative of the general population.  The
;                 tolerance is defined as 'sigmafactor' times the residual
;                 standard deviation (RSD) about the smooth curve, S(t).  
;                 Residuals lying outside the tolerance window are flagged 
;                 as not representative of background conditions and excluded 
;                 from  subsequent iterations.  NOTE:  Each subsequent curve 
;                 fit produces a smaller tolerance window as RSD continues to
;                 be minimized.  The process continues until there are no 
;                 further values lying outside the specified tolerance window.
;                 Default:  sigmafactor = 3.0
;
;                 Introduced asymmetric filtering (2012-08-30, kam).  If
;                 'sigmafactor' is a 2-element vector, the 1st element will be 
;                 the positive residual sigma factor and the 2nd element will 
;                 be the negative residual sigma factor.  If 'sigmafactor' is 
;                 a single value, filtering will be symmetric as described above.
;
;   average:      If specified, average values of same-air measurements will be
;                 filtered.  Same-air measurements have the same date, time, meth,
;                 and position (lat,lon,alt).  If an average value is identified
;                 as non-representative, the individual values making up the average
;                 will be assigned the second column 'X' flag.  This feature was
;                 added to avoid instances when some same-air members are included
;                 and some are not.  This keyword is ignored if site and parameter
;                 are not set.  Added 2012-09-07 (kam).
;
;   saveas:       If specified and 'dev' keyword is set, graphics will be
;                 re-routed to 'saveas' file destination.
;
;   outputfile:   If specified and data were extracted from CCG database, 
;                 filtered results will be saved to 'outputfile' in
;                 'site file' format.  Values determined to be not 
;                 representative of background conditions will be 
;                 assigned a single "X" character to the second column of
;                 the QC flag.  All pre-existing flags will remain intact 
;                 except perhaps for those flags previously assigned by this
;                 procedure.
;
;                 If specified and data were 'import'ed, the first two 
;                 columns of the original file will be saved and a third 
;                 column will identify values that have been flagged by 
;                 this procedure.  The flags are described as 
;
;                 Zero (0) - sample is NOT representative of background
;                 conditions.
;
;                 One  (1) - sample is representative of background
;                 conditions.
;
;   update:       If non-zero, the CCGG database is updated.
;
;   summary:      If specified, filter summary details will be 
;                 re-routed to the 'summary' file destination.
;                 The summary includes a list of parameters used 
;                 in the curve fit as well as relevant information 
;                 pertaining to each iteration.
;
;   showall:      Set this keyword to one (1) to display a plot of
;                 each iterative curve fit.
;
;   axis_y:       A 4-element vector containing user-supplied Y-axis parameters.
;                 axis_y = [ymin, ymax, yticks, yminor]
;
;   axis_x:       A 4-element vector containing user-supplied X-axis parameters.
;                 axis_y = [xmin, xmax, xticks, xminor]
;
;   title:        String constant to use for graph title.
;
;    date:        This keyword containing start and end date constrains by sample
;                 date, data extracted from the DB. date = [20020101L, 99991231L],
;                 date = [2001, 2003]
;
;   npoly:        This keyword is used to specify the number of polynomial
;                 terms used in the function f(t).  Note that a default value 
;                 of three (3) is used if the source file contains more than two
;                 (2) years of data, and a value of two (2) is assigned if less
;                 than two (2) years of data are supplied.   Keep in mind that
;                 neither default may be appropiate for the supplied data.
;
;   nharm:        This keyword is used to specify the number of harmonic terms
;                 used in the function f(t).  Note that a default value of 
;                 four (4) is used .  Keep in mind that this default assignment
;                 may not be appropiate for the supplied data.
;
;   interval:     This keyword is used to specify the resolution or time-step 
;                 interval (in days) of the supplied data.  Note that a default
;                 value of seven (7) days is assigned if none is specified.
;                 Keep in mind that this default assignment may not be 
;                 appropiate for the supplied data.
;
;   cutoff1:      This keyword is used to specify the short term filter cutoff 
;                 used in constructing the smooth curve S(t).  Note that a 
;                 default value of eighty (80) is assigned if none is specified.
;                 Keep in mind that this default assignment may not be 
;                 appropiate for the supplied data.
;
;   cutoff2:      This keyword is used to specify the long term filter cutoff 
;                 used in constructing the smooth trend curve T(t).  Note that 
;                 a default value of 667 is assigned if none is specified.  Keep
;                 in mind that this default assignment may not be appropiate
;                 for the supplied data.
;
;   nolabid:      Set this keyword to one (1) to suppress the laboratory
;                 identification and date stamp.   
;
;   noproid:      Set this keyword to one (1) to suppress the procedure stamp.
;
;   dev:          Set this keyword to the desired output device.  
;
; OUTPUTS:
;   None.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   A pre-existing "X" character flag in the 2nd column of the QC flag will
;   be removed before fitting begins (applies only when input data are 
;   extracted from the CCGG database.
;
; RESTRICTIONS:
;   See conditions associated with INPUT keywords.
;
; PROCEDURE:
;   Example:
;      .
;      .
;      .
;      CCG_FILTER,   sp = 'co2c13', $
;                    site = 'brw', $
;                    outputfile = '/home/ccg/ken/tmp/brw.co2c13', $
;                    sigmafactor = 2.5, $
;                    dev = 'psc'
;
;      CCG_FLASKAVE, import = '/home/ccg/ken/tmp/brw.co2c13', $
;                    xret, yret, xnb, ynb
;
;      CCG_SYMBOL,   sym = 1, thick = 2
;
;      PLOT,         xret, yret, $
;                    PSYM = 8, $
;                    COLOR = pen[3]
;
;      CCG_SYMBOL,   sym = 10, thick = 2
;
;      PLOT,         xnb, ynb, $
;                    PSYM = 8, $
;                    COLOR = pen[2]
;      .
;      .
;      .
;      
; MODIFICATION HISTORY:
;   Written, June 1996 - kam.
;   Modified, January 1997 - kam.
;   Modified, June 2005 - kam.
;   Modified, June 2007 - kam.
;   Modified, December 2008 - dyc.
;   Modified, April 2011 to include "program" keyword - kam, dyc.
;   Modified, September 2012 to support asymmetric filtering - kam.
;   Modified, August 2013 to use /nopreserve flag when calling ccg_flaskupdate.pro - kam.
;   Modified, October 2013. Bug fix. Search for 2013-10-23 (kam).
;-
;
; Get Utility functions
;
@ccg_utils.pro

; --------------------------------------->>>
 
PRO   SetFlags, data=data, FIL=FIL, RET=RET
   
   ; Make change to QC flag where appropriate
    
   j = WHERE( data.ptr EQ RET )
   IF j[0] NE -1 THEN data[j].flag = STRMID( data[j].flag,0,1 ) + "." + STRMID( data[j].flag,2,1 )

   j = WHERE( data.ptr EQ FIL )
   IF j[0] NE -1 THEN data[j].flag = STRMID( data[j].flag,0,1 ) + "X" + STRMID( data[j].flag,2,1 )

END

; --------------------------------------->>>

PRO   GRAPH, data=data, dev=dev, sp=sp, $
   FIL=FIL, RET=RET, REJ=REJ, NB=NB, UNFIL=UNFIL, SET=SET, $
   title=title, subtitle=subtitle, ytitle=ytitle, $
   sc=sc, sf=sf, sigma=sigma, saveas=saveas, $
   axis_x=axis_x, axis_y=axis_y
    
   ; Plotting routine
    
   IF NOT KEYWORD_SET(charsize) THEN charsize = 1.5
   IF NOT KEYWORD_SET(charthick) THEN charthick = 2.0
   IF NOT KEYWORD_SET(symsize) THEN symsize = 0.75
   CCG_GASINFO, sp = sp, title = ytitle
    
   ; Allow user to specify Y range
    
   IF SIZE(axis_y, /DIMENSION) EQ 4 THEN BEGIN
      ystyle = 0
      ey = {  YSTYLE:1, $
         YRANGE:[axis_y[0], axis_y[1]], $
         YTICKS:axis_y[2], $
         YMINOR:axis_y[3]}
   ENDIF ELSE BEGIN
      ey = {  YSTYLE:16}
   ENDELSE
    
   ; Allow user to specify X range
    
   IF SIZE(axis_x, /DIMENSION) EQ 4 THEN BEGIN
      xstyle = 0
      ex = {  XSTYLE:1, $
         XRANGE:[axis_x[0], axis_x[1]], $
         XTICKS:axis_x[2], $
         XMINOR:axis_x[3]}
   ENDIF ELSE BEGIN
      ex = {  XSTYLE:16}
   ENDELSE
    
   ; Create "EXTRA" structure
    
   e = CREATE_STRUCT(ex, ey)

   z = GET_SCREEN_SIZE()
   CCG_OPENDEV, dev = dev, pen = pen, $
   saveas = saveas, $
   ypixels = 0.8 * z[1], $
   xpixels = 1.29 * 0.8 * z[1]
    
   ; Do not use rejected values in determining range
    
   j = WHERE( data.ptr NE REJ )
   
   PLOT,   data[j].date, data[j].value, $
      /NODATA, $
      CHARSIZE = charsize, $
      CHARTHICK = charthick, $
      COLOR = pen[1], $
      TITLE = STRTRIM(title, 2), $
      SUBTITLE = STRTRIM(subtitle, 2), $

     _EXTRA = e, $
      
      YSTYLE = ystyle, $
      YTITLE = ytitle, $
      YCHARSIZE = 1.0, $
      YTHICK = 2.0, $
      
      XSTYLE = xstyle, $
      XTITLE = 'YEAR', $
      XCHARSIZE = 1.0, $
      XTHICK = 2.0
    
   ; data set to filter
    
   j = WHERE( data.ptr EQ SET )
   IF j[0] NE -1 THEN BEGIN
      CCG_SYMBOL, sym = 1, fill = 0, thick = 1
      OPLOT, [data[j].date], [data[j].value], $
      PSYM = 8, $
      SYMSIZE =symsize, $
      COLOR = pen[3]
   ENDIF
    
   ; Filtered data
    
   j = WHERE( data.ptr EQ FIL )
   IF j[0] NE -1 THEN BEGIN
      CCG_SYMBOL, sym = 10, fill = 0, thick = 1
      OPLOT, [data[j].date], [data[j].value], $
      PSYM = 8, $
      SYMSIZE =symsize, $
      COLOR = pen[6]
   ENDIF
    
   ; Un-filtered data
    
   j = WHERE( data.ptr EQ UNFIL )
   IF j[0] NE -1 THEN BEGIN
      CCG_SYMBOL, sym = 1, fill = 0, thick = 1
      OPLOT, [data[j].date], [data[j].value], $
      PSYM = 8, $
      SYMSIZE =symsize, $
      COLOR = pen[6]
   ENDIF
    
   ; Rejected data
    
   j = WHERE( data.ptr EQ REJ )
   IF j[0] NE -1 THEN BEGIN
      CCG_SYMBOL, sym = 11, fill = 0, thick = 1
      OPLOT, [data[j].date], [data[j].value], $
      PSYM = 8, $
      SYMSIZE =symsize, $
      COLOR = pen[2]
   ENDIF
    
   ; Non-background data
    
   j = WHERE( data.ptr EQ NB )
   IF j[0] NE -1 THEN BEGIN
      CCG_SYMBOL, sym = 10, fill = 0, thick = 1
      OPLOT, [data[j].date], [data[j].value], $
      PSYM = 8, $
      SYMSIZE =symsize, $
      COLOR = pen[4]
   ENDIF

   OPLOT, sc[0, *], sc[1, *] + sf[0] * sigma, $
   LINESTYLE = 1,$
   THICK = 2.0,$
   COLOR = pen[1]

   OPLOT, sc[0, *], sc[1, *] - sf[1] * sigma, $
   LINESTYLE = 1,$
   THICK = 2.0,$
   COLOR = pen[1]

   OPLOT, sc[0, *], sc[1, *], $
   LINESTYLE = 0,$
   THICK = 2.0,$
   COLOR = pen[1]

   z = SET EQ RET ? "RET" : "AVERAGES"

   CCG_SLEGEND,$
   x = 0.74, y = 0.25, $
   tarr = [  z, z+' (un-filtered)', $
   'NB (filter [s.f. = [' + STRING( FORMAT='(F5.2,A2,F5.2)', sf[0],",",sf[1] ) + '])', $
   'NB (other)', 'REJ'], $
   sarr = [1, 1, 10, 10, 11], $
   carr = [pen[3], pen[6], pen[6], pen[4], pen[2]], $
   charsize = 1.0,$
   charthick = 2.0

   CCG_LABID
      
   CCG_CLOSEDEV, saveas = saveas, dev = dev
END

; --------------------------------------->>>

PRO   CCG_FILTER, $

   x = x, $
   y = y, $

   npoly = npoly, $
   nharm = nharm, $
   interval = interval, $
   cutoff1 = cutoff1, $
   cutoff2 = cutoff2, $
    
   sigmafactor = sigmafactor, $

   sp = sp, $
   site = site, $
   project = project, $
   program = program, $
   strategy = strategy, $
   date = date, $
   average = average, $

   import = import, $
   skip = skip, $

   showall = showall, $
   nographics = nographics, $
   axis_y = axis_y, $
   axis_x = axis_x, $
   title = title, $
   dev = dev, $

   append=append, $
   ExportRetainOnly=ExportRetainOnly, $

   summary = summary, $
   saveas = saveas, $
   update = update, $
   outputfile = outputfile, $

   help = help, $
   quiet = quiet, $
   ptr2arr
 
   ; Initialize variables and keywords
    
   IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC
   IF NOT KEYWORD_SET( program ) AND NOT KEYWORD_SET( import ) AND NOT KEYWORD_SET( x ) THEN CCG_SHOWDOC
   IF NOT (KEYWORD_SET(site) OR KEYWORD_SET(import) OR KEYWORD_SET(x)) THEN CCG_SHOWDOC
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC

   db = 0

   title = (KEYWORD_SET(title)) ? title : ""
   program = (KEYWORD_SET(program)) ? program : ""
   project = (KEYWORD_SET(project)) ? project : "ccg_surface"
   strategy = (KEYWORD_SET(strategy)) ? strategy : "flask"
   sigmafactor = (KEYWORD_SET(sigmafactor)) ? sigmafactor : 3.00
   interval = (KEYWORD_SET(interval)) ? interval : 7
   cutoff1 = (KEYWORD_SET(cutoff1)) ? cutoff1 : 80
   cutoff2 = (KEYWORD_SET(cutoff2)) ? cutoff2 : 667
   quiet = (KEYWORD_SET(quiet)) ? 1 : 0
   skip = (KEYWORD_SET(skip)) ? skip : 0
   date = (KEYWORD_SET(date)) ? date : [19000101L, 99991231L]
   average = KEYWORD_SET( average ) ? 1 : 0
   append = KEYWORD_SET( append ) ? 1 : 0
   update = KEYWORD_SET( update ) ? 1 : 0

   ExportRetainOnly = KEYWORD_SET( ExportRetainOnly ) ? 1 : 0

   ; Prepare for asymmetric filtering
     
   IF N_ELEMENTS( sigmafactor ) EQ 1 THEN sigmafactor = [sigmafactor, sigmafactor]

   IF KEYWORD_SET(summary) THEN OPENW, fpout, summary, /GET_LUN ELSE fpout = (-1)

   FIL = 0 & RET = 1 & REJ = 2 & NB = 3 & UNFIL = 4 & AVG = 5

   SET = RET

   value_type = average EQ 1 ? "Average" : "Individual"
    
   ; --------------------------------------->>>
   ; If data are passed as keywords
    
   IF KEYWORD_SET(x) AND KEYWORD_SET(y) THEN BEGIN
       
      ; Maintain a pointer to original data set
       
      n = N_ELEMENTS(x)
       
      ; Build "flask-like" structure
       
      data = REPLICATE( CREATE_STRUCT( 'date', 0D, 'value', 0D, 'str', '','ptr', RET ), n )
      data.date = x
      data.value = y
      FOR i=0L, n-1 DO data[i].str = STRING( FORMAT='(F12.6, F12.4)', data[i].date, data[i].value )

      IF title EQ '' THEN title = 'passed variables'

   ENDIF
    
   ; --------------------------------------->>>
   ; If data are not passed as keyword parameters, fetch data
    
   IF KEYWORD_SET(site) AND KEYWORD_SET(sp) THEN BEGIN
       
      ; Extract data from DB
      ; jwm - 7/19 - changed to ccg_flask2 wrapper so can exclude method h.
      ;    excluding h (high pressure vessels) because not relevant for this logic.
      ; jwm -8/19 - changed back for now.  This is causing issue in downstream logic that needs to be resolved.
      ; jwm -8/19 - programmed ccg_flask.pl to accept me:-h.  Still need to resolve why ccg_flask2 not working.
      ;  to reproduce uncomment ccg_flask2 line and: 
      ; from /home/ccg/mund/dev/bugs/idl/ccg_flask2_ccg_flask
      ; >idl
      ; IDL> .run ecd_filter_coflasks                                        
      ; IDL> ecd_filter_co, sp='co', initfile='init.co.flask.master.2018.txt'
      

       ;CCG_FLASK2, site=site, sp=sp, nomessage=quiet, date=date, $
      ;strategy=strategy, project=project, program=program, meth='-H', tags={ptr:0, n:0, origflag:'', evnlist:''}, data
        CCG_FLASK, site=site, sp=sp, nomessage=quiet, date=date, $
      strategy=strategy, project=project, program=program, meth='-H', tags={ptr:0, n:0, origflag:'', evnlist:''}, data

      IF (r = SIZE(data, /TYPE)) NE 8 THEN CCG_FATALERR, "No data found."
      IF title EQ '' THEN title = sp + ' from ' + site 
      db = 1

      ; keep a record of original QC flags 
      data.origflag = data.flag
       
      ; Re-introduce all measurements with an "X" character in the
      ; 2nd column of the QC flag.  By convention, only filtering 
      ; routines may assign the upper case "X" to the second column.
      ; NOTE:  We are not altering the flag in data.str! This is important
      ; for later.

      j = WHERE( STRMID( data.flag,1,1 ) EQ "X" )
      IF j[0] NE -1 THEN data[j].flag = STRMID( data[j].flag,0,1 ) + "." + STRMID( data[j].flag,2,1 )

      ; Identify all retained values

      j = WHERE( STRMID( data.flag, 0, 2 ) EQ ".." )
      IF j[0] EQ -1 THEN CCG_FATALERR, "No retained values for site="+site+", sp="+sp+", strategy="+ $
                                        strategy+", project="+project+", program="+program+"."
      data[j].ptr = RET

      ; Identify rejected values

      j = WHERE( STRMID( data.flag, 0, 1 ) NE "." )
      IF j[0] NE -1 THEN data[j].ptr = REJ

      ; Identify non-background values assigned
      ; by means other than this routine

      j = WHERE( STRMID( data.flag, 1, 1 ) NE "." )
      IF j[0] NE -1 THEN data[j].ptr = NB

      ; keep a record of original QC flags 
;      data.origflag = data.flag

      IF average EQ 1 THEN BEGIN

         ; Use measurement averages of retained data instead of retained data

         j = WHERE( data.ptr EQ RET, COMPLEMENT=k )
      
         avgdata = AverageSameAirMeasurements( data[j] )
         IF SIZE( avgdata, /TYPE ) EQ 8 THEN BEGIN

            avgdata.ptr = AVG
            data = [data, avgdata ]

            title = title + ' (AVERAGES)'
            SET = AVG

          ENDIF

      ENDIF

   ENDIF

   ; --------------------------------------->>>
   IF KEYWORD_SET(import) THEN BEGIN
       
      ; Read import file
       
      CCG_FREAD, file = import, skip = skip, nomessage = quiet, nc = 2, tmp

      IF tmp[0] EQ 0 THEN CCG_FATALERR, "No data found in " + import + "."
      IF title EQ '' THEN title = import
       
      ; Build "flask-like" structure
       
      n = N_ELEMENTS( tmp[0, *] )
      data = REPLICATE( CREATE_STRUCT( 'date', 0D, 'value', 0D, 'str', '', 'ptr', RET ), n )
      data.date = REFORM( tmp[0, *] )
      data.value = REFORM( tmp[1, *] )
      FOR i=0L, n-1 DO data[i].str = STRING( FORMAT='(F12.6, F12.4)', data[i].date, data[i].value )
       
   ENDIF
    
   ; --------------------------------------->>>
   ; Print header information
    
   PRINTF, fpout, FORMAT = '(/,A31)', '********************'
   PRINTF, fpout, FORMAT = '(A31)', '**** CCG_FILTER ****'
   PRINTF, fpout, FORMAT = '(A31,/)', '********************'
   PRINTF, fpout, FORMAT = '("Source:",T40,A)', title
   PRINTF, fpout, FORMAT = '("Sigma Factor:",T40,A,/)', STRING( FORMAT='(F5.2,A2,F5.2)', sigmafactor[0],",",sigmafactor[1] )
    
   ; Begin iterations
    
   niter = 1
   REPEAT BEGIN

      iteration = STRING(FORMAT = '(A40)', '**** ITERATION  ' + ToString(niter) + ' ****')
      PRINTF, fpout, FORMAT = '(A,/)', iteration
       
      ;Call to CCG_CCGVU
       
      ptr2set = WHERE( data.ptr EQ SET )

      CCG_CCGVU, x=data[ptr2set].date, y=data[ptr2set].value, $
                 nharm=nharm, npoly=npoly, interval=interval, cutoff1=cutoff1, cutoff2=cutoff2, $
                 sc=sc, residsc=residsc, summary=report
       
      ; Determine STDEV of residuals about smooth curve
       
      one_sigma = STDEV(residsc(1, *))
       
      ; --------------------------------------->>>
      ; Which samples lie outside one sigma * sigmafactor?

      nflag = 0

      ; Positive residuals (upper sigmafactor)

      j = WHERE( residsc[1,*] GE 0 )
   
      IF j[0] NE -1 THEN BEGIN

         k = WHERE( residsc[1,j] GE ( sigmafactor[0] * one_sigma ) )
         IF k[0] NE -1 THEN BEGIN
            data[ptr2set[j[k]]].ptr = FIL
            nflag += N_ELEMENTS(k)
         ENDIF

      ENDIF

      ; Negative residuals (lower sigmafactor)

      j = WHERE( residsc[1,*] LT 0 )
   
      IF j[0] NE -1 THEN BEGIN
       
         k = WHERE( ABS( residsc[1,j] ) GE ( sigmafactor[1] * one_sigma ) )
         IF k[0] NE -1 THEN BEGIN
            data[ptr2set[j[k]]].ptr = FIL
            nflag += N_ELEMENTS(k)
         ENDIF

      ENDIF

      niter ++
       
      ; Print abbreviated fit summary
       
      j = WHERE(STRPOS(report, "parameter") NE -1)
      FOR i = 2, j[0] DO PRINTF, fpout, report[i]
      PRINTF, fpout, " "

      j = WHERE(STRPOS(report, "FILTER PARAMETERS") NE -1)
      FOR i = j[0], j[0] + 3 DO PRINTF, fpout, report[i]
      PRINTF, fpout, " "

      j = WHERE(STRPOS(report, "Residual standard deviation about smooth curve") NE -1)
      PRINTF, fpout, report[j]
      PRINTF, fpout, " "
      
      z = "# " + value_type + " Values Flagged:"
      PRINTF, fpout, FORMAT = '(/,A,T40,A,/)', z,ToString(nflag)
       
      ; Showall Graphics?
       
      IF NOT KEYWORD_SET(showall) THEN CONTINUE

      CCG_CCGVU, x=data[ptr2set].date, y=data[ptr2set].value, $
                 nharm=nharm, npoly=npoly, interval=interval, cutoff1=cutoff1, cutoff2=cutoff2, $
                 /even, sc=sc2

      GRAPH, dev=dev, data=data, sp=sp, $
      FIL=FIL, RET=RET, REJ=REJ, NB=NB, UNFIL=UNFIL, SET=SET, $
      title=title, subtitle=iteration, $
      sc=sc2, sf=sigmafactor, sigma=one_sigma, $
      axis_x=axis_x, axis_y=axis_y

   ENDREP UNTIL nflag EQ 0
    
   ; Filtering completed
   ; --------------------------------------->>>
    
   PRINTF, fpout, STRING(FORMAT = '(/,A40)', '**** FILTERING SUMMARY ****')
    
   ; re-introduce values that after the final 
   ; iteration lie within 1 sigma * sigmafactor
    
   j = WHERE( data.ptr EQ FIL )

   IF j[0] NE -1 THEN BEGIN
      z = "# " + value_type + " Values Flagged:"
      PRINTF, fpout, FORMAT = '(/,A,T40,A)', z, ToString(N_ELEMENTS(j))

      FOR i=0L, N_ELEMENTS(j)-1 DO BEGIN

         z = WHERE( sc[0, *] LE data[j[i]].date )
         pt1 = z[N_ELEMENTS(z) - 1]
         z = WHERE( sc[0, *] GE data[j[i]].date )
         pt2 = z[0]

         IF pt1 EQ -1 AND pt2 NE -1 THEN pt1 = pt2
         IF pt2 EQ -1 AND pt1 NE -1 THEN pt2 = pt1

         IF pt1 NE pt2 THEN BEGIN
            m = (sc[1, pt2] - sc[1, pt1]) / (sc[0, pt2] - sc[0, pt1])
            b = sc[1, pt2] - m * sc[0, pt2]
            sc_interp = m * data[j[i]].date + b
         ENDIF ELSE sc_interp = sc[1, pt1]

         ; Compute residual

         residual = data[j[i]].value - sc_interp

         CASE residual GE 0 OF
            1: IF residual LE (sigmafactor[0] * one_sigma) THEN data[j[i]].ptr = UNFIL
            0: IF ABS( residual ) LE (sigmafactor[1] * one_sigma) THEN data[j[i]].ptr = UNFIL
         ENDCASE

      ENDFOR
      j = WHERE( data.ptr EQ UNFIL )
      n = j[0] EQ -1 ? 0 : N_ELEMENTS(j)
      z = "# " + value_type + " Values Reintroduced:"
      PRINTF, fpout, FORMAT = '(A,T40,A)', z, ToString(n)
   ENDIF

   IF NOT KEYWORD_SET(nographics) THEN BEGIN

      CCG_CCGVU, x=data[ptr2set].date, y=data[ptr2set].value, $
                 nharm=nharm, npoly=npoly, interval=interval, cutoff1=cutoff1, cutoff2=cutoff2, $
                 /even, sc=sc2

      GRAPH, dev=dev, data=data, sp=sp, $
      FIL=FIL, RET=RET, REJ=REJ, NB=NB, UNFIL=UNFIL, SET=SET, $
      title=title, subtitle='Final iteration (' + ToString(niter - 1) + ')' , $
      sc=sc2, sf=sigmafactor, sigma=one_sigma, saveas=saveas, $
      axis_x=axis_x, axis_y=axis_y

   ENDIF
    
   ; --------------------------------------->>>
   ; Un-filtered points should be re-assigned as retained
    
   j = WHERE( data.ptr EQ UNFIL )
   IF j[0] NE -1 THEN data[j].ptr = RET

   ; --------------------------------------->>>
   ; If 'average' is set, filter results for measurement
   ; averages need to be transferred to the individual measurements
   ; making up the average.

   IF average EQ 1 THEN BEGIN

      j = WHERE( data.evnlist NE "", COMPLEMENT=k )
      avgdata = data[j]

      FOR i=0,N_ELEMENTS( avgdata )-1 DO BEGIN

         evns = STRSPLIT( avgdata[i].evnlist, ",", /EXTRACT )
         
         FOR ii=0, N_ELEMENTS( evns )-1 DO BEGIN

            ; Bug fixed.  This line was missing the constraint "data.ptr EQ RET".  As
            ; a result, members of a filtered average were given the "X" flag regardless
            ; of their original flag.  Thus, rejection and other non-background flags 
            ; could be overwritten.  (2013-10-23, kam).  

            data[WHERE( data.evn EQ evns[ii] AND data.ptr EQ RET )].ptr = ( avgdata[i].ptr EQ AVG ) ? RET : avgdata[i].ptr

         ENDFOR

      ENDFOR

      data = data[k]

   ENDIF
    
   ; List values to be flagged with "X"
    
   j = WHERE( data.ptr EQ FIL )

   z = "Total # Individual Values Flagged:"

   IF j[0] NE -1 THEN BEGIN

      ; NOTE:  Pre-existing measurements with an "X" 2nd column flag have
      ; been reintroduced into the retained population by changing data.flag.  BUT,
      ; data.str was not modified so pre-existing "X" measurements will appear in
      ; this list.

      n = N_ELEMENTS(j)
      PRINTF, fpout, FORMAT = '(A,T40,A,/)', z, ToString(n)

      PRINT, " "
      PRINT, "----------------------->>>"
      PRINT, "Measurements Identified to be flagged (IFF update=1)"
      PRINT, " "
      FOR i=0L, n-1 DO PRINTF, fpout, STRING(FORMAT = '(I4, 2X, A)', i+1, data[j[i]].str)

   ENDIF ELSE BEGIN

      PRINTF, fpout, FORMAT = '(A,T40,A,/)', z, ToString(0)

   ENDELSE
    
   ; Close summary output file
    
   IF KEYWORD_SET(summary) THEN FREE_LUN, fpout
    
   ; --------------------------------------->>>
   ; Save filter results?
    
   IF KEYWORD_SET(outputfile) THEN BEGIN
       
      CASE db OF
       
      0:   BEGIN
          
         ; Explanation of numeric flags
          
         CCG_MESSAGE, '***************************************************'
         CCG_MESSAGE, 'Explanation of numeric flags'
         CCG_MESSAGE, '0 - Non-background samples (X) identified by filtering'
         CCG_MESSAGE, '1 - Retained samples'
         CCG_MESSAGE, '***************************************************'
         
         IF ExportRetainOnly EQ 1 THEN BEGIN

            j = WHERE( data.ptr EQ 1 )
            CCG_FWRITE, file=outputfile, nc=2, /double, data[j].date, data[j].value, append=append

         ENDIF ELSE BEGIN

            CCG_FWRITE, file=outputfile, nc=3, /double, data.date, data.value, data.ptr, append=append

         ENDELSE

         END
      1:   BEGIN
           
         SetFlags, data=data, FIL=FIL, RET=RET
          
         ; Save file using old-style site format
          
         FOR i=0, N_ELEMENTS(data.str)-1 DO data[i].str=OldSiteFormat(data[i])

         CCG_SWRITE, file=outputfile, data.str, append=append
         END
      ENDCASE
   ENDIF

   IF db eq 1 THEN BEGIN
      ; Modify QC flag as necessary
          
      SetFlags, data=data, FIL=FIL, RET=RET
          
      ; CCGG DB update procedure is expecting the following format
          
      ; evn:159040|param:CH4|value:1801.17|flag:...|inst:H4|yr:2004|mo:03|dy:22|hr:09|mn:11|sc:0
          
      ; Update only those records where QC flag has been changed from its original value.
      ; Added 2013-08-20 (kam)


      PRINT, " "
      PRINT, "----------------------->>>"
      PRINT, "CCGG DB modifications (IFF update=1)"
      PRINT, " "

      FOR i=0L, N_ELEMENTS(data.str)-1 DO BEGIN

         if data[i].flag EQ data[i].origflag THEN CONTINUE

         data[i].str = DBFormat(data[i])
          
         ; Update QC flags only
         ; Note:  Added "/nopreserve" keyword because logic of ccg_flaskupdate.pl changed.
         ; Not sure when this logic change happened! 
         ; 2013-08-20 (kam)

         CCG_FLASKUPDATE, arr = data[i].str, /flag, update=update, /nopreserve, error = error
         FOR ii=0L, N_ELEMENTS(error)-1 DO PRINT, error[ii]

      ENDFOR
   ENDIF

   RETURN

END
