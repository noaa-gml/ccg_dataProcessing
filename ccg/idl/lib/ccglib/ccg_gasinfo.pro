;+
; NAME:
;   CCG_GASINFO
;
; PURPOSE:
;   Provide a convenient set of 
;   default species-dependent
;   plotting parameters.  
;
; CATEGORY:
;   Graphics.
;
; CALLING SEQUENCE:
;   CCG_GASINFO, sp = 'ch4', title=title
;   CCG_GASINFO, sp = 'co2, co2c13, co2o18', data
;   CCG_GASINFO, sp = 'all', data
;
; INPUTS:
;
;   help:      Set to view procedure documentation.
;
;   sp:        Gas formula.  May specify a single gas or
;              a list of species.
;                  (ex) sp = 'co'
;                  (ex) sp = 'co2,co2c13,co2o18'
;                  (ex) sp = 'all'
; OPTIONAL INPUTS:
;
;   tt_font:  If set, convert formula and units from
;             vector-drawn to true type.
;
; OUTPUTS:
;   name:     Full name of the specified species
;
;   formula:  Molecular formula (IDL format)
;
;   units:    Measurement units (IDL format)
;
;   title:    'formula (units)' (IDL format)
;
;    data:    Returns an anonymous structure array.
;
;                 data[].sp       -> input 'sp' keyword(s)
;                 data[].formula  -> IDL formatted molecular formula
;                 data[].units    -> IDL formatted measurement units
;                 data[].title    -> combined formula and units
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
;   Example:
;
;      PRO example
;      .
;      .
;      .
;      CCG_GASINFO, sp = 'ch4' , title = xtitle
;      CCG_GASINFO, sp = 'mebr, ocs', data
;      .
;      .
;      .
;      PLOT,   ch4_values, mebr_values,$
;
;         XSTYLE = 16,$
;         XTITLE = xtitle,$
;         
;         YSTYLE = 16,$
;         YTITLE = data[0].title
;      .
;      .
;      .
;      END
;      
; MODIFICATION HISTORY:
;   Written, KAM, March 2005.
;   Modified, KAM, February 2008.
;      Added function to convert from vector-drawn
;      to true type.
;-
;
FUNCTION VECTOR2TT, str

   ; Transform vector-drawn to TT

   ; This logic is not bullet-proof
   ; Added February 11, 2008 - kam

   str_ = str

   ; micromol

   IF (i = STRPOS(str_, '!7l')) NE -1 THEN str_ = STRMID(str_, 0, i) + STRING("265B) + STRMID(str_, i+3)

   ; map !7 -> !M

   WHILE (((i = STRPOS(str_, '!7'))) NE -1) DO STRPUT, str_, '!M', i

   ; per mil

   IF (i = STRPOS(str_, "!10(")) NE -1 THEN str_ = STRMID(str_, 0, i) +  'per mil'

   RETURN, str_

END

PRO   CCG_GASINFO, $   
   sp = sp, $
   formula = formula, $
   name = name, $
   title = title, $
   units = units, $
   tt_font = tt_font, $
   help = help, $
   gasinfo
;
; Note that I am returning both
; a structure and variables.  I
; am preserving the returned variables
; for historical consistency.
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(sp) THEN CCG_SHOWDOC

tt_font = KEYWORD_SET(tt_font) ? 1 : 0

dbdir = '/projects/src/db/'
code = dbdir + 'ccg_gasinfo.pl'
;
; Extract gas details from DB
;
SPAWN, code + ' -parameter=' + sp, arr

IF arr[0] EQ '' THEN RETURN
;
;Define basic structure
;
template = {sp:          '', $
       name:       '', $
       units:   '', $
       formula:    '', $
       title:      ''}

gasinfo = [template]
name = ['']
units = ['']
formula = ['']
title = ['']

n = N_ELEMENTS(arr)

FOR i = 0, n - 1 DO BEGIN

   z = STRSPLIT(arr[i], '|', /EXTRACT, /PRESERVE_NULL)

   template.sp = z[1]
   template.name = z[2]
   template.units = z[8]
   template.formula = z[7]

   ; Convert vector-drawn to TrueType if specified

   IF tt_font EQ 1 THEN BEGIN

      template.units = VECTOR2TT(template.units)
      template.formula = VECTOR2TT(template.formula)

   ENDIF

   template.title = template.formula + ' (' + template.units + ')'

   name = [name, template.name]
   units = [units, template.units]
   formula = [formula, template.formula]

   title = [title, template.title]

   gasinfo = [gasinfo, template]

ENDFOR

gasinfo = gasinfo[1:*]

name = name[1:*]
units = units[1:*]
formula = formula[1:*]
title = title[1:*]

IF n EQ 1 THEN BEGIN
   name = name[0]
   units = units[0]
   formula = formula[0]
   title = title[0]
ENDIF

END
