;+
; NAME:
;	CCG_RGBLOAD
;
; PURPOSE:
; 	Load an RGB color table that has
;	previously been saved using
;	CCG_RGBSAVE.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_RGBLOAD, file=filename
;	CCG_RGBLOAD, file='/users/ken/idl/lib/xcolor_table'
;
; INPUTS:
;	Filename:  file must be a color table that 
;		   was created using CCG_RGBSAVE.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	RGB color table.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Will write over currently defined 
;	IDL color table.
;
; RESTRICTIONS:
;	Color table file must have
;	been created using RGBSAVE.
;
; PROCEDURE:
;	CCG_RGBLOAD may be called from the IDL
;	command line or from an IDL procedure.
;	Example:
;		.
;		.
;		.
;		CCG_RGBLOAD, 	file='colortable'
;		SHADE_SURF,	grid
;		.
;		.
;		.
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;-
;
PRO 	CCG_RGBLOAD, $
	file = file, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
nx=0 & ny=0

OPENR,unit,file,/GET_LUN 
READF,unit,nx,ny
r=FLTARR(nx)
g=r
b=r
READF,unit,r,g,b
FREE_LUN,unit
TVLCT,r,g,b
END
