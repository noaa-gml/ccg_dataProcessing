;+
; NAME:
;	CCG_FATALERR
;
; PURPOSE:
;
;	This procedure will print a message to stdout before executing a RETALL.
;	The RETALL command returns control to the main IDL program level.

; 	Tab fatal error message 'tab' spaces to the right.
;	If the integer keyword 'tab' is not set then 'tab'
;	is set to 5 by default.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_FATALERR,	'File not found.  Exiting ...'
;	CCG_FATALERR,	'Input parameter was not set.  Exiting ...',tab=8
;
; INPUTS:
;	string:		Text string.
;
; OPTIONAL INPUT PARAMETERS:
;	tab:		Number of integer spaces to
;			shift to right.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	'tab' keyword must follow passed string.
;
; PROCEDURE:
;	No example.
;		
; MODIFICATION HISTORY:
;	Written, KAM, November 1996.
;-
;
PRO	CCG_FATALERR, $
	str, $
	tab = tab, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
IF NOT KEYWORD_SET(tab) THEN tab=5
;
sformat=STRCOMPRESS('(TR'+STRING(tab)+',A0)',/RE)
;
IF CCG_VDEF(str) THEN PRINT,FORMAT=sformat,str
RETALL
END
