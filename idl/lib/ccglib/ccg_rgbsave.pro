;+
; NAME:
;	CCG_RGBSAVE
;
; PURPOSE:
; 	Save the currently defined 
;	RGB color table to the passed
;	file name. 
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_RGBSAVE, file=filename
;	CCG_RGBSAVE, file='/users/ken/idl/lib/xcolor_table'
;
; INPUTS:
;	Filename:  File name where color table 
;		   information will be stored.
;
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Will write over an existing file. 
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	IDL color table may be modified
;	using c_edit or palette.  Running
;	CCG_RGBSAVE after a color table edit
;	will save the current table.  This
;	table may then be loaded at any
;	time using CCG_RGBLOAD.
;	
;	Example:
;		.
;		.
;		.
;		IDL> PALETTE
;		IDL> CCG_RGBSAVE,file='/users/ken/colormap'
;		.
;		.
;		.
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;-
;
PRO 	CCG_RGBSAVE, $
	file = file, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC

TVLCT,	r,g,b,/GET

s=SIZE(r)

OPENW,unit,file,/GET_LUN
PRINTF,unit,s(1),3
PRINTF,unit,r,g,b
FREE_LUN,unit
END
