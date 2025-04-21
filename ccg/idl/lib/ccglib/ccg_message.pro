;+
; NAME:
;	CCG_MESSAGE	
;
; PURPOSE:
;
; 	Tab messages 'tab' spaces to the right.
;	This is handy for informational messages
;	within procedures or functions.  If the
;	integer keyword 'tab' is not set then 'tab'
;	is set to 5 by default.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_MESSAGE,	'File not found ...',/bell
;	CCG_MESSAGE,	'Done with filter ...',tab=8
;	CCG_MESSAGE,	'hi',tab=40,bell=1
;
; INPUTS:
;	string:		Text string.
;
; OPTIONAL INPUT PARAMETERS:
;	tab:		Number of integer spaces to
;			shift to right.
;
;	bell:		If keyword set, bell will sound.
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
;	Written, KAM, August 1994.
;-
;
PRO	ccg_message, $
	str, $
	bell = bell, $
	tab = tab, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
IF NOT KEYWORD_SET(tab) THEN tab=5
;
sformat=STRCOMPRESS('(TR'+STRING(tab)+',A0)',/REMOVE_ALL)
;
PRINT,FORMAT=sformat,str
IF KEYWORD_SET(bell) THEN PRINT,STRING(7B)
END
