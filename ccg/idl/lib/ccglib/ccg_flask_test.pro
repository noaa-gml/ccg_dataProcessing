;+
; NAME:
;   CCG_FLASK_TEST
;
; PURPOSE:
;    Extract discrete (flask and/or pfp) data from RDBMS
;   
;   This procedure is intended to replace CCG_FSREAD,
;   CCG_MSREAD, CCG_FSMERGE, CCG_READMERGE, and 
;   CCG_READACMERGE.
;
;   WARNING:  Use caution when calling this procedure.
;
;   For example...
;
;       IDL>  ccg_flask, sp = 'all', arr 
;
;   will extract all PFP and network flask measurements
;   for all parameters from the RDBMS.  This takes time!
;
; CATEGORY:
;   Data Retrieval
;
; CALLING SEQUENCE:
;   CCG_FLASK_TEST, site='brw',sp='co2',arr
;   CCG_FLASK_TEST, site='brw',sp='co2,co,ch4',date=[2000,2003],/average,arr
;   CCG_FLASK_TEST, site='brw',sp='co2,co,ch4',adate=[2003],arr
;   CCG_FLASK_TEST, site='car',alt=[2500,3500],sp='co2c13',project='ccg_aircraft',arr
;   CCG_FLASK_TEST, site='alt,brw',date=[2004,2004],sp='co2,co2c13',arr
;   CCG_FLASK_TEST, date=[2003,2003],lat=[10,40],lon=[-90,-50],sp='co2',arr
;   CCG_FLASK_TEST, site='stm',sp=['co2'],/nb,arr
;   CCG_FLASK_TEST, site='car',sp='co',project='ccg_aircraft',date=20040202,pid='205',arr
;   CCG_FLASK_TEST, sp='co2,ch4,co',evn=3246,arr
;   CCG_FLASK_TEST, sp='co2',date=[2000,2003],status='ongoing,terminated',arr
;
; INPUTS:
;   No single parameter is required.  If site keyword is NOT specified,
;   search will be site-independent.  If sp keyword is NOT specified,
;   returned data will only include collection details.
;
; OPTIONAL INPUT PARAMETERS:
;   site:        Site code.  May specify a single code or
;                a list of sites.
;                (ex) site='brw'
;                (ex) site='alt,brw,cba'
;
;   pp:          Parameter formula combined with program abbreviation.
;                May specify a single pp or a list of parameter programs.
;                ( The delimiter between parameter and program is a tilde '~'.
;                The delimiter between multiple parameter programs is a comma. )
;                - Please note that this argument takes precedence over
;                  the 'sp' and 'program' arguments.
;                (ex) pp='co~ccgg'
;                (ex) pp='co2~ccgg,benz~hats'
;
;   sp:          Parameter formula.  May specify a single sp or
;                a list of species.
;                (ex) sp='co'
;                (ex) sp='co2,co2c13,co2o18'
;
;   project:     Project abbreviation.  May specify
;                surface (ccg_surface) or aircraft (ccg_aircraft)
;                measurements. Both projects are considered if
;                no keyword is specified [default].
;
;   program:     Program abbreviation.  May specify ccgg, hats, arl, sil, curl, ...
;                If not specified, there will be no program constraints.
;
;   strategy:    Strategy abbreviation.  May specify 2.5L
;                flasks (flask) or PFP flasks (pfp).  Both
;                strategies are considered if no keyword
;                is specified [default].
;
;   status:      Sampling Status.  May specify a single status option or
;                a list of project status options.  Current status options
;                include 1)ongoing, 2)special, 3)terminated, 4)other, 5)binned.
;                (ex) status='ongoing'
;                (ex) status='ongoing,terminated'
;
;   meth:        Collection Method.  May specify a single method or
;                a list of methods.
;                (ex) meth='D'
;                (ex) meth='T,F'
;
;   inst:        Instrument ID.  May specify a single instrument.
;                (ex) inst='L8'
;
;   average:     If keyword set, multiple measurements of the same sample
;                will be averaged. If there is no measurement for the
;                specified parameter, then it will be filled in with the
;                default value and the flag is set to 'FIL'
;
;                Averaging options: 
;                1 - List a row for each event number
;                2 - List a row for each measurement of the first parameter
;                    in the parameter list
;                3 - List a row where all parameters have a measurement
;                    in the database
;
;                Average is determined as follows ...
;
;                If there are multiple strings that match key then
;                   the average of retained flask values is reported
;                or if there are no retained flask values
;                   the average of non-background flask values is reported
;                or if there are no retained and non-background flask values
;                   a single rejected flask value is reported
;                or if there are no measurements
;                   a default value and flag is assigned.
;
;   pairaverage: If keyword set, returns the average of measurements based on
;                site code, collection date & time, method, and parameter
;
;   preliminary: If keyword set, all preliminary data will be flagged with
;                a 'P' in the 3rd column of the QC flag.
;
;   exclusion:   If keyword set, all data to be excluded will be removed
;                from the data structure.
;
;   date:        Limit range of specific parameters.
;   adate:      
;                NOTE: May specify a range of event numbers or a single value
;
;   lat:         The format is as follows:
;   lon:      
;   alt:         parameter = [minimum value, maximum value]
;                or
;                parameter = single value
;
;                (ex) date = [2004, 2005]
;                (ex) date = 20040111
;                (ex) lat = -15, lon = [-175, -165]
;                (ex) alt = [2500, 3500]
;                (ex) evn = 3246
;                (ex) evn = [3246, 3252]
;
;   evn:      
;   id:          Specify flask id (id), id prefix (pid),
;   pid:         or id suffix (sid).
;   sid:
;                (ex) id = '3089-91'
;                (ex) pid = '3089'
;                (ex) sid = '91'
;
;   vp:          Specify the beginning date and time of
;                a vertical profile. The fields are
;                separated by a comma.
;                (ex) vp='2005-03-05,14:40:00'
;
;   ret:         If keyword set, return only values with a
;                period '.' in the 1st and 2nd columns of the QC flag.
;
;   nb:          If keyword set, return only values without a
;                period '.' in the 2nd column QC flag position.
;
;   rej:         If keyword set, return only values without a 
;                period '.' in the 1st column QC flag position.
;
;   flag:        QC flag. Find data that matches the specified
;                quality control flag. A percent sign (%) is used
;                as a string wild card.
;                NOTE: This option overrides keywords ret, nb, and rej
;                (ex) flag = '...'
;                (ex) flag = '.%' matches all QC flags beginning with '.'
;                (ex) flag = '%G' matches all QC flags ending with 'G'
;
;   comment:     If keyword set, include event and data comments when
;                appropriate. Comments may be associated with both
;                event and data information. 
;
;   noprogram:   If keyword set, do not show analysis program.
;
;   showinternalflags:
;                If keyword set, include the internal flags
;
;
;   tags:        This keyword allows user-defined tags to be included
;                in the result structure array.  The keyword must be
;                a structure with the following syntax ...
;
;                tags = {name1:value1, name2:value2, name3:value3 ...}
;
;                (ex) tags = {t1:0, t2:46.5, t3:'test'}
;                (ex) tags = {res_1:0L, res2:0.0, z4:0D, text:''}
;
;                User-defined tags should not conflict with other tags
;                used in this procedure.  Tag names cannot begin with
;                a numeric (i.e., 3d:0).
;
;   nomessages:  If non-zero, messages will be suppressed.
;
;       help:    If non-zero, the procedure documentation is
;                displayed to STDOUT.
;
; OUTPUTS:
;   data:        Returns an anonymous structure array.  Structure
;                tags depend on passed parameters.
;
;                data[].str  -> all parameters joined into a string constant
;                data[].evn  -> event number.  This number uniquely identifies
;                               a flask or pfp sampling event.
;                data[].code   -> 3-letter site code
;                data[].date   -> UTC date/time in decimal format
;                data[].yr   -> UTC sample collection year
;                data[].mo   -> UTC sample collection month
;                data[].dy   -> UTC sample collection day
;                data[].hr   -> UTC sample collection hour 
;                data[].mn   -> UTC sample collection minute
;                data[].id   -> 8-character flask id
;                data[].type   -> 2-character flask id suffix
;                data[].meth   -> single character method
;                data[].lat   -> sample collection latitude
;                data[].lon   -> sample collection longitude
;                data[].alt   -> sample collection altitude (masl)
;
;                If a sp is specified then the following measurement
;                results are returned.
;
;                data[].parameter   -> parameter formula (e.g., co2, co2c13)
;                data[].value      -> data value (mixing ratio, per mil)
;                data[].flag      -> 3-character selection flag
;                data[].inst      -> 2-character analysis instrument code
;                data[].adate      -> analysis date in decimal format
;                data[].ayr      -> sample analysis year (local time)
;                data[].amo      -> sample analysis month (local time)
;                data[].ady      -> sample analysis day (local time)
;                data[].ahr      -> sample analysis hour  (local time)
;                data[].amn      -> sample analysis minute (local time)
;
;                If multiple species are specified and the 'average' keyword
;                is set then the following analysis results are returned.
;
;                data[].<sp>   -> data value (mixing ratio, per mil)
;                data[].<sp>flag   -> 3-character selection flag
;
;                where <sp> is the species formula (e.g., data.co2, data.co2flag).
;
;                If USER-DEFINED tags are specified, they will be included in
;                the structure array.  For example, if the following keyword is
;                specified, tags = {t1:0L, t2:46.5, t3:'test'}, the result structure
;                will include data[].t1, data[].t2, and data[].t3 initialized to
;                0L, 46.5, and 'test' respectively.
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
;   Data are returned in an anonymous structure array.  Users
;   can employ SQL-type IDL commands to manipulate data.
;
;      Example:
;         CCG_FLASK_TEST,$
;         sp='co2,co',$
;         site='car',project='ccg_aircraft',$
;         date=[20040202,20040202],pid='205',vp
;         .
;         .
;         .
;         !P.MULTI=[0,1,2]
;         PLOT, vp.co2,vp.alt,psym=4
;         PLOT, vp.co,vp.alt,psym=4
;
; MODIFICATION HISTORY:
;   Written, KAM, June 2004.
;   Modified, KAM, March 2005.
;   Modified, KAM, September 2006 (user-defined tags)
;   Modified, KAM, April 2011 (add 'program' keyword)
;-
;
    
   ; Get Utility functions
    
   @ccg_utils.pro
    
   PRO   BUILD_SITE, data, comment=comment, $
         noprogram=noprogram, showinternalflags=showinternalflags, tags, a

   n = LONG(N_ELEMENTS(data))

   z = CREATE_STRUCT($
   'str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'mn',0,'sc',0,$
   'id','','type','','meth','',$ 
   'lat',0.0,'lon',0.0,'alt',0.0,'elev',0.0,$
   'date',0.0D,'parameter','')

   IF NOT KEYWORD_SET(noprogram) THEN z = CREATE_STRUCT(z, 'program','');

   z = CREATE_STRUCT(z, 'value',0.0,'unc',0.0,'flag','',$ 
   'inst','','adate',0.0D,'ayr',0,'amo',0,'ady',0,'ahr',0,'amn',0,'asc',0,$
   'evn',0L)

   IF KEYWORD_SET(showinternalflags) THEN z = CREATE_STRUCT(z, 'collection_internalflags', '', 'measurement_internalflags', '');

   IF KEYWORD_SET(comment) THEN z = CREATE_STRUCT(z, 'comment','');

   ; Add user-defined tags?
    
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   a = REPLICATE(z,n)

   FOR i=0L,n-1 DO BEGIN
      str = STRSPLIT(data[i],' ',/EXTRACT)
      nstr = N_ELEMENTS(str)

      a[i].str = data[i]
      a[i].code = str[0]
      a[i].yr = FIX(str[1])
      a[i].mo = FIX(str[2])
      a[i].dy = FIX(str[3])
      a[i].hr = FIX(str[4])
      a[i].mn = FIX(str[5])
      a[i].sc = FIX(str[6])
      a[i].id = str[7]
      a[i].meth = str[8]
      a[i].parameter = str[9]

      shift = 0
      IF ( NOT KEYWORD_SET( noprogram ) ) THEN BEGIN

         a[i].program = str[10]
         shift ++

      ENDIF

      a[i].value = FLOAT(str[10+shift])
      a[i].unc = FLOAT(str[11+shift])
      a[i].flag = str[12+shift]
      a[i].inst = str[13+shift]
      a[i].ayr = FIX(str[14+shift])
      a[i].amo = FIX(str[15+shift])
      a[i].ady = FIX(str[16+shift])
      a[i].ahr = FIX(str[17+shift])
      a[i].amn = FIX(str[18+shift])
      a[i].asc = FIX(str[19+shift])
      a[i].lat = FLOAT(str[20+shift])
      a[i].lon = FLOAT(str[21+shift])
      a[i].alt = FLOAT(str[22+shift])
      a[i].elev = FLOAT(str[23+shift])
      a[i].evn = LONG(str[24+shift])

      IF ( KEYWORD_SET( showinternalflags) ) THEN BEGIN

         a[i].collection_internalflags = str[25+shift]
         a[i].measurement_internalflags = str[26+shift]
         shift ++
         shift ++

      ENDIF

      ; If the user requests comments and comments actually exists
      ; then set the comments in the structure

      IF ( KEYWORD_SET(comment) AND nstr GT 25+shift ) THEN BEGIN
         a[i].comment = STRJOIN(str[25+shift:*],' ')
      ENDIF

      thr = (a[i].hr EQ 99) ? 12 : a[i].hr
      tmn = (a[i].mn EQ 99) ?  0 : a[i].mn
      tsc = (a[i].sc EQ 99) ?  0 : a[i].sc
      CCG_DATE2DEC,yr=a[i].yr,mo=a[i].mo,dy=a[i].dy,hr=thr,mn=tmn,sc=tsc,dec=dec
      a[i].date = dec

      thr = (a[i].ahr EQ 99) ? 12 : a[i].ahr
      tmn = (a[i].amn EQ 99) ?  0 : a[i].amn
      tsc = (a[i].asc EQ 99) ?  0 : a[i].asc
      CCG_DATE2DEC,yr=a[i].ayr,mo=a[i].amo,dy=a[i].ady,hr=thr,mn=tmn,sc=tsc,dec=dec
      a[i].adate = dec 

      k = STRPOS(a[i].id,'-')
      a[i].type = (k[0] NE -1) ? STRMID(a[i].id,k+1,2) : '??'
   ENDFOR
   END

   PRO   BUILD_EVENT, data, sp = sp, comment=comment, tags, a

   ndata = LONG(N_ELEMENTS(data))

   z = CREATE_STRUCT($
   'str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'mn',0,'sc',0,$
   'id','','type','','meth','',$ 
   'lat',0.0,'lon',0.0,'alt',0.0,'elev',0.0,$
   'date',0.0D,$
   'evn',0L)

   IF KEYWORD_SET(comment) THEN z = CREATE_STRUCT(z, 'comment','');


   ;
   ; Add user-defined tags?
   ;
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   tags = TAG_NAMES(z)
   a = REPLICATE(z, ndata)

   FOR i=0L,ndata-1 DO BEGIN

      str = STRSPLIT(data[i],' ',/EXTRACT)
      nstr = N_ELEMENTS(str)

      a[i].str = data[i]
      a[i].code = str[0]
      a[i].yr = FIX(str[1])
      a[i].mo = FIX(str[2])
      a[i].dy = FIX(str[3])
      a[i].hr = FIX(str[4])
      a[i].mn = FIX(str[5])
      a[i].sc = FIX(str[6])
      a[i].id = str[7]
      a[i].meth = str[8]
      a[i].lat = FLOAT(str[9])
      a[i].lon = FLOAT(str[10])
      a[i].alt = FLOAT(str[11])
      a[i].elev = FLOAT(str[12])
      a[i].evn = LONG(str[13])

       
      thr = (a[i].hr EQ 99) ? 12 : a[i].hr
      tmn = (a[i].mn EQ 99) ?  0 : a[i].mn
      tsc = (a[i].sc EQ 99) ?  0 : a[i].sc
      CCG_DATE2DEC,yr=a[i].yr,mo=a[i].mo,dy=a[i].dy,hr=thr,mn=tmn,sc=tsc,dec=dec
      a[i].date = dec

      k = STRPOS(a[i].id,'-')
      a[i].type = (k[0] NE -1) ? STRMID(a[i].id,k+1,2) : '??'

      ; If the user requests comments and comments actually exists
      ; then set the comments in the structure

      IF ( KEYWORD_SET(comment) AND nstr GT 14 ) THEN BEGIN
         a[i].comment = STRJOIN(str[14:*],' ')
      ENDIF
   ENDFOR
   END

   PRO   BUILD_MERGE, data, sp = sp, noprogram=noprogram, headers=headers, tags, a

   ndata = LONG(N_ELEMENTS(data))

   z = CREATE_STRUCT($
   'str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'mn',0,'sc',0,$
   'id','','type','','meth','',$ 
   'lat',0.0,'lon',0.0,'alt',0.0,'elev',0.0,$
   'date',0.0D,$
   'evn',0L)

   IF KEYWORD_SET(comment) THEN z = CREATE_STRUCT(z, 'comment','');


   IF KEYWORD_SET (headers) THEN BEGIN

      str = STRSPLIT(data[0], ' ', /EXTRACT)

      ; Create the structure for program
      ; Each program will have a tag in the main structure
      ; Each program tag will be a structure with the formula and flag under it
      IF KEYWORD_SET (noprogram) THEN BEGIN

         ;
         ; Add tags to the main structure for each parameter
         ; This code will crash if the same parameter is analyzed
         ; by two different labs given the event and data constraints
         ;
         formula_idx = WHERE(headers EQ 'parameter_formula')

         FOR j=0, N_ELEMENTS(formula_idx) - 1 DO BEGIN

            formulastr = str[formula_idx[j]]
            valuestr = str[formula_idx[j]+1]
            flagstr = str[formula_idx[j]+2]

            parameterstruct = CREATE_STRUCT(formulastr, 0.0,$
                                            formulastr + 'flag', '')

            z = CREATE_STRUCT(z, parameterstruct)

         ENDFOR
      ENDIF ELSE BEGIN
         ; noprogram NOT SET

         program_idx = WHERE(headers EQ 'analysis_group_abbr')

         programs = (str[program_idx])[UNIQ(str[program_idx], SORT(str[program_idx]))] 

         FOR i=0, N_ELEMENTS(programs) - 1 DO BEGIN

            programstruct = ''

            idx = WHERE(str EQ programs[i])

            FOR j=0, N_ELEMENTS(idx) - 1 DO BEGIN

               formulastr = str[idx[j]-1]
               programstr = str[idx[j]]
               valuestr = str[idx[j]+1]
               flagstr = str[idx[j]+2]

               parameterstruct = CREATE_STRUCT(formulastr, 0.0,$
                                               formulastr + 'flag', '')

               IF SIZE(programstruct, /TYPE) EQ 8 THEN BEGIN
                  programstruct = CREATE_STRUCT(programstruct, parameterstruct)
               ENDIF ELSE BEGIN
                  programstruct = parameterstruct
               ENDELSE
            ENDFOR

            z = CREATE_STRUCT(z, programs[i], programstruct)
         ENDFOR
      ENDELSE
      
   ENDIF

   ;
   ; Add user-defined tags?
   ;
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   tags = TAG_NAMES(z)
   a = REPLICATE(z, ndata)

   FOR i=0L,ndata-1 DO BEGIN

      str = STRSPLIT(data[i],' ',/EXTRACT)
      nstr = N_ELEMENTS(str)

      a[i].str = data[i]
      a[i].code = str[0]
      a[i].yr = FIX(str[1])
      a[i].mo = FIX(str[2])
      a[i].dy = FIX(str[3])
      a[i].hr = FIX(str[4])
      a[i].mn = FIX(str[5])
      a[i].sc = FIX(str[6])
      a[i].id = str[7]
      a[i].meth = str[8]
      a[i].lat = FLOAT(str[9])
      a[i].lon = FLOAT(str[10])
      a[i].alt = FLOAT(str[11])
      a[i].elev = FLOAT(str[12])
      a[i].evn = LONG(str[13])

      IF KEYWORD_SET (headers) THEN BEGIN

         ; Assign the program+parameter structure values

         IF KEYWORD_SET (noprogram) THEN BEGIN
            ; Assign the parameter values

            formula_idx = WHERE(headers EQ 'parameter_formula')

            FOR j=0, N_ELEMENTS(formula_idx) - 1 DO BEGIN

               formulastr = str[formula_idx[j]]
               valuestr = str[formula_idx[j]+1]
               flagstr = str[formula_idx[j]+2]

               k = WHERE(tags EQ STRUPCASE(formulastr))

               a[i].(k[0]) = FLOAT(valuestr)

               k = WHERE(tags EQ STRUPCASE(formulastr+'flag'))
               a[i].(k[0]) = flagstr

            ENDFOR
         ENDIF ELSE BEGIN
            ; noprogram NOT SET

            program_idx = WHERE(headers EQ 'analysis_group_abbr')

            FOR j=0, N_ELEMENTS(program_idx) - 1 DO BEGIN

               formulastr = str[program_idx[j]-1]
               programstr = str[program_idx[j]]
               valuestr = str[program_idx[j]+1]
               flagstr = str[program_idx[j]+2]

               programtag_idx = WHERE(tags EQ programstr)

               programtags = TAG_NAMES(z.(programtag_idx[0]))

               k = WHERE(programtags EQ STRUPCASE(formulastr))

               a[i].(programtag_idx[0]).(k[0]) = FLOAT(valuestr)

               k = WHERE(programtags EQ STRUPCASE(formulastr+'flag'))

               a[i].(programtag_idx[0]).(k[0]) = flagstr
            ENDFOR
         ENDELSE
      ENDIF
       
      thr = (a[i].hr EQ 99) ? 12 : a[i].hr
      tmn = (a[i].mn EQ 99) ?  0 : a[i].mn
      tsc = (a[i].sc EQ 99) ?  0 : a[i].sc
      CCG_DATE2DEC,yr=a[i].yr,mo=a[i].mo,dy=a[i].dy,hr=thr,mn=tmn,sc=tsc,dec=dec
      a[i].date = dec

      k = STRPOS(a[i].id,'-')
      a[i].type = (k[0] NE -1) ? STRMID(a[i].id,k+1,2) : '??'
   ENDFOR
   END

   PRO   BUILD_PAIRAVG, data, noprogram=noprogram, tags, a

   n = LONG(N_ELEMENTS(data))

   z = CREATE_STRUCT($
   'str','','code','','yr',0,'mo',0,'dy',0,'hr',0,'mn',0,'sc',0,$
   'meth','','date',0.0D,'parameter','')

   IF NOT KEYWORD_SET(noprogram) THEN z = CREATE_STRUCT(z, 'program','')

   z = CREATE_STRUCT(z,'value',0.0,'flag','')
   ;
   ; Add user-defined tags?
   ;
   IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

   a = REPLICATE(z,n)

   FOR i=0L,n-1 DO BEGIN
      str = STRSPLIT(data[i],' ',/EXTRACT)
      a[i].str = data[i]
      a[i].code = str[0]
      a[i].yr = FIX(str[1])
      a[i].mo = FIX(str[2])
      a[i].dy = FIX(str[3])
      a[i].hr = FIX(str[4])
      a[i].mn = FIX(str[5])
      a[i].sc = FIX(str[6])
      a[i].meth = str[7]
      a[i].parameter = str[8]

      IF KEYWORD_SET(noprogram) THEN BEGIN
         a[i].value = FLOAT(str[9])
         a[i].flag = str[10]
      ENDIF ELSE BEGIN
         a[i].program = str[9]
         a[i].value = FLOAT(str[10])
         a[i].flag = str[11]
      ENDELSE

      thr = (a[i].hr EQ 99) ? 12 : a[i].hr
      tmn = (a[i].mn EQ 99) ?  0 : a[i].mn
      tsc = (a[i].sc EQ 99) ?  0 : a[i].sc
      CCG_DATE2DEC,yr=a[i].yr,mo=a[i].mo,dy=a[i].dy,hr=thr,mn=tmn,sc=tsc,dec=dec
       a[i].date = dec
   ENDFOR
   END

   PRO    CCG_FLASK_TEST, $

      site = site, $   
      program = program, $
      noprogram = noprogram, $
      project = project, $
      strategy = strategy, $
      status = status, $
      date = date, $
      evn = evn, $
      flag = flag, $
      id = id, $
      pid = pid, $
      sid = sid, $
      meth = meth, $
      lat = lat, $
      lon = lon, $
      alt = alt, $
      temp = temp, $
      press = press, $
      rh = rh, $
      ws = ws, $
      wd = wd, $
      vp = vp, $
      inst = inst, $

      pp = pp, $
      sp = sp, $
      adate = adate, $
      ret = ret, $
      nb = nb, $
      rej = rej, $

      tags = tags, $

      average = average, $
      pairaverage = pairaverage, $
      preliminary = preliminary, $
      exclusion = exclusion, $
      comment = comment, $

      showinternalflags=showinternalflags, $

      nomessages = nomessages, $
      help = help, $
      arr
   ;
   ;Return to caller if an error occurs
   ;
   ;ON_ERROR,   2
   ;
   ;check input information 
   ;
   IF KEYWORD_SET(help) THEN CCG_SHOWDOC
   IF N_PARAMS() EQ 0 THEN CCG_FATALERR,"Return variable required (CCG_FLASK_TEST,/HELP)."

   project = (KEYWORD_SET(project)) ? project : ''
   program = (KEYWORD_SET(program)) ? program : ''
   noprogram = (KEYWORD_SET(noprogram)) ? 1 : 0
   nomessages = (KEYWORD_SET(nomessages)) ? 1 : 0
   tags = KEYWORD_SET(tags) ? tags : ''
   showinternalflags = (KEYWORD_SET(showinternalflags)) ? 1 : 0
   ;
   ;initialization
   ;
   arr = 0
   data = 0
   dbdir = '/projects/src/db/modules/'
   perlsite = dbdir + 'ccg_flask_test.pl'
   ;
   ; Build argument list
   ;
   args = ''

   ; *******************************************
   ; Event Constraints
   ; *******************************************
   ;
   eargs = ['']
   IF KEYWORD_SET(id) THEN eargs = [eargs,'id:'+id+','+id]
   IF KEYWORD_SET(pid) THEN eargs = [eargs,"substring_index(id,'-',1):"+ToString(pid)+','+ToString(pid)]
   IF KEYWORD_SET(sid) THEN eargs = [eargs,"substring_index(id,'-',-1):"+ToString(sid)+','+ToString(sid)]
   IF KEYWORD_SET(evn) THEN BEGIN
      IF N_ELEMENTS(evn) EQ 1 THEN evn = [evn, evn]
      eargs = [eargs,'num:'+ToString(evn[0])+','+ToString(evn[1])]
   ENDIF
   IF KEYWORD_SET(lat) THEN BEGIN
      IF N_ELEMENTS(lat) EQ 1 THEN lat = [lat, lat]
      eargs = [eargs,'lat:'+ToString(lat[0])+','+ToString(lat[1])]
   ENDIF
   IF KEYWORD_SET(lon) THEN BEGIN
      IF N_ELEMENTS(lon) EQ 1 THEN lon = [lon, lon]
      eargs = [eargs,'lon:'+ToString(lon[0])+','+ToString(lon[1])]
   ENDIF
   IF KEYWORD_SET(alt) THEN BEGIN
      IF N_ELEMENTS(alt) EQ 1 THEN alt = [alt, alt]
      eargs = [eargs,'alt:'+ToString(alt[0])+','+ToString(alt[1])]
   ENDIF
   IF KEYWORD_SET(press) THEN BEGIN
      IF N_ELEMENTS(press) EQ 1 THEN press = [press, press]
      eargs = [eargs,'press:'+ToString(press[0])+','+ToString(press[1])]
   ENDIF
   IF KEYWORD_SET(temp) THEN BEGIN
      IF N_ELEMENTS(temp) EQ 1 THEN temp = [temp, temp]
      eargs = [eargs,'temp:'+ToString(temp[0])+','+ToString(temp[1])]
   ENDIF
   IF KEYWORD_SET(rh) THEN BEGIN
      IF N_ELEMENTS(rh) EQ 1 THEN rh = [rh, rh]
      eargs = [eargs,'rh:'+ToString(rh[0])+','+ToString(rh[1])]
   ENDIF
   IF KEYWORD_SET(ws) THEN BEGIN
      IF N_ELEMENTS(ws) EQ 1 THEN ws = [ws, ws]
      eargs = [eargs,'ws:'+ToString(ws[0])+','+ToString(ws[1])]
   ENDIF
   IF KEYWORD_SET(wd) THEN BEGIN
      IF N_ELEMENTS(wd) EQ 1 THEN wd = [wd, wd]
      eargs = [eargs,'wd:'+ToString(wd[0])+','+ToString(wd[1])]
   ENDIF
   IF KEYWORD_SET(vp) THEN BEGIN
      eargs = [eargs,'vp:'+ToString(vp[0])]
   ENDIF
   IF KEYWORD_SET(date) THEN BEGIN
      IF N_ELEMENTS(date) EQ 1 THEN date = [date, date]

      date = LONG(date)
      d1 = DateDB((date[0] = StartDate(date[0])))
      d2 = DateDB((date[1] = EndDate(date[1])))
      eargs = [eargs,'date:'+d1+','+d2]
   ENDIF

   args = (N_ELEMENTS(eargs) GT 1) ? ' -event="'+STRJOIN(eargs[1:*],'~',/SINGLE)+'"' : ''

   IF KEYWORD_SET(meth) THEN args += ' -method='+meth
   IF KEYWORD_SET(status) THEN args += ' -status='+status
   IF project NE '' THEN args += ' -project='+project
   IF program NE '' THEN args += ' -program='+program
   IF noprogram EQ 1 THEN args += ' -noprogram'
   IF showinternalflags EQ 1 THEN args += ' -showinternalflags'
   IF KEYWORD_SET(strategy) THEN args += ' -strategy='+strategy
   IF KEYWORD_SET(site) THEN args += ' -site='+site
   ;
   ; *******************************************
   ; Data Constraints
   ; *******************************************
   ;
   dargs = ['']
   IF KEYWORD_SET(adate) THEN BEGIN
      IF N_ELEMENTS(adate) EQ 1 THEN adate = [adate, adate]

      adate = LONG(adate)
      d1 = DateDB((adate[0] = StartDate(adate[0])))
      d2 = DateDB((adate[1] = EndDate(adate[1])))
      dargs = [dargs,'date:'+d1+','+d2]
   ENDIF

   IF KEYWORD_SET(flag) THEN BEGIN
      dargs = [dargs, 'flag:'+flag]
   ENDIF ELSE BEGIN
      CASE 1 OF
      KEYWORD_SET(ret):   dargs = [dargs, 'flag:..%']
      KEYWORD_SET(nb):   BEGIN
               dargs = [dargs, 'flag:_._']
               args += ' -not'
               END
      KEYWORD_SET(rej):   BEGIN
               dargs = [dargs, 'flag:.%']
               args += ' -not'
               END
      ELSE:
      ENDCASE
   ENDELSE
   ;
   ; Note: can constrain on 1 or 2 instruments only
   ;
   IF KEYWORD_SET(inst) THEN BEGIN
      IF N_ELEMENTS(inst) EQ 1 THEN inst = [inst,inst]
      dargs = [dargs, 'inst:' + inst[0] + ',' + inst[1]]
   ENDIF

   args += (N_ELEMENTS(dargs) GT 1) ? ' -data="'+STRJOIN(dargs[1:*],'~',/SINGLE)+'"' : ''

   IF KEYWORD_SET(pp) THEN BEGIN
      args += ' -parameterprogram=' + pp
      z = STRSPLIT(pp, ',' , /EXTRACT, COUNT = nsp)

      program = ''
      sp = ''
      FOR i=0,N_ELEMENTS(z)-1 DO BEGIN
         tmp = STRSPLIT(z[i], '~', /EXTRACT)

         sp = ( sp EQ '' ) ? tmp[0] : sp+','+tmp[0]
         program = ( program EQ '' ) ? tmp[1] : program+','+tmp[1]
      ENDFOR
   ENDIF ELSE BEGIN
      IF KEYWORD_SET(sp) THEN BEGIN
         args += ' -parameter=' + sp
         IF sp EQ 'all' THEN nsp = 2 ELSE z = STRSPLIT(sp, ',' , /EXTRACT, COUNT = nsp)
      ENDIF ELSE BEGIN
         sp = '' & nsp = 0
      ENDELSE
   ENDELSE
   ;
   ; *******************************************
   ; Additional Constraints
   ; *******************************************
   ;
   IF KEYWORD_SET(average) THEN BEGIN
      args += ' -merge=' + STRCOMPRESS(average,/REMOVE_ALL)
   ENDIF
   IF KEYWORD_SET(pairaverage) THEN args += ' -pairaverage'

   IF KEYWORD_SET(preliminary) THEN args += ' -preliminary'
   IF KEYWORD_SET(exclusion) THEN args += ' -exclusion'
   IF KEYWORD_SET(comment) THEN args += ' -comment'

   args += ' -stdout -shownames -elevation'
   ;
   ; Retrieve data from DB
   ; 
   tmp = perlsite + args
   IF NOT nomessages THEN CCG_MESSAGE,'Extracting Data ...'
   SPAWN,tmp,data
   IF NOT nomessages THEN CCG_MESSAGE,'Done Extracting Data ...'

   ; A headers line will always be returned
   IF N_ELEMENTS(data) LT 2 THEN RETURN

   headerstr = data[0];
   data = data[1:*];

   headers = STRSPLIT(headerstr,' ', /EXTRACT);

   ; Skip the first element
   headers = headers[1:*];

   IF (KEYWORD_SET(average)) THEN BEGIN 
      BUILD_MERGE, data, sp = sp, noprogram=noprogram, headers=headers, tags, arr
   ENDIF ELSE IF (KEYWORD_SET(pairaverage)) THEN BEGIN
           BUILD_PAIRAVG, data, noprogram=noprogram, tags, arr
   ENDIF ELSE BEGIN
      CASE nsp OF
         0:   BUILD_EVENT, data, comment=comment, tags, arr 
         ELSE:   BUILD_SITE, data, comment=comment, noprogram=noprogram, showinternalflags=showinternalflags, tags, arr
      ENDCASE
   ENDELSE
END
