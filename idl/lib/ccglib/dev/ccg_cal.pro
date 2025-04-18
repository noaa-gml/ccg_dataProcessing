;+
; NAME:
;   CCG_CAL
;
; PURPOSE:
;    Extract calibration data from RDBMS
;   
; CATEGORY:
;   Data Retrieval
;
; CALLING SEQUENCE:
;   CCG_CAL, id='CC64042', sp='ch4', date='2007-06-13,2007-06-13', arr
;   CCG_CAL, id='CC64042', sp='ch4', date='2007-06-13,2007-06-13', /retained, inst='h5', arr
;   CCG_CAL, id='CC64035,CC64052,CC64040', sp='co2', res
;   CCG_CAL, id='CC64035,CC64052,CC64040', z
;   CCG_CAL, id='CC64040', sp='co2', date='1992-06,1993-01', z
;
; INPUTS:
;   id:        Cylinder ID.  May specify a single cylinder or a list of sites or leave off for all cylinders.
;
; OPTIONAL INPUT PARAMETERS:
;
;   sp:           Parameter formula.  Specify a single species.
;                 If not specified, results for all species are returned.
;
;   date:         Constrain results by date.
;                 (ex) date = '2007-06-13,2007-06-14'
;
;   inst:         Constrain by one or more instruments.  
;		  (ex) inst = 'H5'  or inst = 'H5,H4,H6'
;
;   retained:	  If non-zero, only return retained results.
;
;   nomessages:   If non-zero, messages will be suppressed.
;
;   help:         If non-zero, the procedure documentation is displayed to STDOUT.
;
; OUTPUTS:
;   data:         Returns an anonymous structure array.
;
;                 data[].id               -> cylinder ID 
;                 data[].yr               -> calibration year
;                 data[].mo               -> calibration month
;                 data[].dy               -> calibration day
;                 data[].hr               -> calibration hour
;                 data[].mn               -> calibration minute
;                 data[].dd               -> calibration decimal year
;                 data[].parameter        -> parameter formula (e.g., co2, co2c13)
;                 data[].value            -> calibration result
;                 data[].sd               -> result standard deviation
;                 data[].num              -> number of individual results contributing to "value"
;                 data[].flag             -> single character QC flag
;                 data[].meth             -> fill method
;                 data[].inst             -> analytical instrument
;
;                 If USER-DEFINED tags are specified, they will be included in
;                 the structure array.  For example, if the following keyword is
;                 specified, tags = {t1:0L, t2:46.5, t3:'test'}, the result structure
;                 will include data[].t1, data[].t2, and data[].t3 initialized to
;                 0L, 46.5, and 'test' respectively.
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
; MODIFICATION HISTORY:
;   Written, KAM, July 2007.
;   Added constraint by instrument id and selecting only retained values, AMC, March 2011
;-
;   Made id optional like perl script now is.  jwm 4/16
;
; Get Utility functions
;
@ccg_utils.pro
 
PRO  CCG_CAL, $

     id = id, $
     date = date, $
     sp = sp, $
     retained = retained, $
     inst = inst, $

     tags = tags, $

     nomessages = nomessages, $
     help = help, $
     result
 
; check input information 
 
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF N_PARAMS() EQ 0 THEN CCG_FATALERR, "Return variable required (CCG_CAL,/HELP)."
;IF NOT KEYWORD_SET(id) THEN CCG_SHOWDOC

sp = KEYWORD_SET(sp) ? sp : ''
inst = KEYWORD_SET(inst) ? inst : ''
nomessages = KEYWORD_SET(nomessages) ? 1 : 0
tags = KEYWORD_SET(tags) ? tags : ''
 
;initialization
 
result = 0
data = 0
perlsite = '/projects/src/db/ccg_cal.pl'
 
; Build argument list
 
args = ''

IF KEYWORD_SET(id) THEN args += ' -id=' + id
IF KEYWORD_SET(date) THEN args += ' -date=' + date
IF KEYWORD_SET(sp) THEN args += ' -parameter=' + sp
IF KEYWORD_SET(retained) THEN args += ' -retained=1'
IF KEYWORD_SET(inst) THEN args += ' -instrument=' + inst
 
; Retrieve data from DB
  
tmp = perlsite + args
print,tmp
IF NOT nomessages THEN CCG_MESSAGE, 'Extracting Data ...'
SPAWN, tmp, data
IF NOT nomessages THEN CCG_MESSAGE, 'Done Extracting Data ...'

IF data[0] EQ '' THEN RETURN
n = N_ELEMENTS(data)

z = CREATE_STRUCT('str', '', 'id', '', 'yr', 0, 'mo', 0, 'dy', 0, 'hr', 0, 'mn', 0, 'sc', 0, 'dd', 0D, $
'parameter', '', 'meth', '', 'value', 0.0, 'sd', 0.0, 'num', 0, 'flag', '', $
'inst', '')

; Add user-defined tags?
 
IF SIZE(tags, /TYPE) EQ 8 THEN z = CREATE_STRUCT(z, tags)

; build result structure array

result = REPLICATE(z, n)

; assign fields

; serial_number, date, time, species, mixratio, stddev, num, flag, method, inst

FOR i = 0, n - 1 DO BEGIN

   result[i].str = data[i]

   tmp = STRSPLIT(data[i], '|', /EXTRACT)

   result[i].id = tmp[0]

   z = STRSPLIT(tmp[1], '-', /EXTRACT)

   result[i].yr = FIX(z[0])
   result[i].mo = FIX(z[1])
   result[i].dy = FIX(z[2])

   z = STRSPLIT(tmp[2], ':', /EXTRACT)

   result[i].hr = FIX(z[0])
   result[i].mn = FIX(z[1])
   result[i].sc = FIX(z[2])

   CCG_DATE2DEC, yr=result[i].yr, mo=result[i].mo, dy=result[i].dy, $
                 hr=result[i].hr, mn=result[i].mn, sc=result[i].sc, dec = dd

   result[i].dd = dd

   result[i].parameter = tmp[3]
   result[i].value = FLOAT(tmp[4])
   result[i].sd = FLOAT(tmp[5])
   result[i].num = FIX(tmp[6])
   result[i].flag = tmp[7]
   result[i].meth = tmp[8]
   result[i].inst = tmp[9]

ENDFOR

END
