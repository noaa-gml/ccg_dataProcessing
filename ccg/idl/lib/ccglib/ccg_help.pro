;+
; NAME:
;	CCG_HELP
;
; PURPOSE:
; 	Provide general description of CCG
;	library of IDL procedures.
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	CCG_HELP
;
; INPUTS:
;	None.
;
; OPTIONAL INPUT PARAMETERS:
;	noblock:   Set this keyword to allow 
;		   continued access to IDL prompt.
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
;	None.
;
; PROCEDURE:
;	IDL> CCG_HELP
;
; MODIFICATION HISTORY:
;	Written, KAM, September 1994.
;-
;
;************************************************
PRO helplist_ev,ev
;************************************************
;
COMMON	list,	libdir,prolist,helptext
;
i=0 & s=''
file=STRCOMPRESS(libdir+STRLOWCASE(prolist(ev.index))+'.pro',/REMOVE_ALL)
nlines=CCG_LIF(file=file)
str=MAKE_ARRAY(nlines,/STR,VALUE='')
;
OPENR,	unit,file,/GET_LUN
WHILE NOT EOF(unit) DO BEGIN
	READF,unit,s
	str(i)=s
	i=i+1
ENDWHILE
FREE_LUN,unit
;
b=WHERE(str EQ ';+')
e=WHERE(str EQ ';-')
;
;Write to temporary file
;
OPENW,unit,GETENV("HOME")+'/.ccg_help',/GET_LUN
FOR i=b(0),e(0) DO PRINTF,unit,FORMAT='(A0)',str(i)
FREE_LUN,unit
;
IF b(0) EQ -1 OR e(0) EQ -1 THEN BEGIN
	WIDGET_CONTROL,helptext,$
	SET_VALUE='No help on this procedure ...'
ENDIF ELSE BEGIN
	WIDGET_CONTROL,helptext,SET_VALUE=str(b(0):e(0))
ENDELSE
END
;
;************************************************
PRO	donebtn_ev,ev
;************************************************
;
	WIDGET_CONTROL, ev.top, /DESTROY
	;
	;Remove temporary file
	;
	SPAWN,STRCOMPRESS('/bin/rm -f '+GETENV("HOME")+'/.ccg_help')
END
;
;************************************************
PRO 	ccg_help,file=file,noblock=noblock
;************************************************
;
COMMON	list,	libdir,prolist,helptext
COMMON	misc,	font

IF KEYWORD_SET(file) THEN BEGIN
	CCG_SHOWDOC,file=file
	RETURN
ENDIF

noblock = (KEYWORD_SET(noblock)) ? 1 : 0
;
;get procedure list
;
SET_PLOT,	'X'

libdir=!DIR+'/lib/ccglib/'
libdir='/ccg/idl/lib/ccglib/'

CCG_DIRLIST,dir=STRCOMPRESS(libdir+'ccg_*.pro',/REMOVE_ALL),omitdir=1,prolist
FOR i=0,N_ELEMENTS(prolist)-1 DO $
	prolist(i)=STRUPCASE(STRMID(prolist(i),0,STRPOS(prolist(i),'.')))
;
helpbase=WIDGET_BASE(TITLE = libdir+'CCG HELP',/ROW)
leftbase=WIDGET_BASE(helpbase,/COLUMN)
helplist=WIDGET_LIST(leftbase,YSIZE=25,VALUE=prolist,EVENT_PRO='helplist_ev')
helptext=WIDGET_TEXT(helpbase,YSIZE=30,XSIZE=80,/SCROLL)
donebtn=WIDGET_BUTTON(leftbase,VALUE='Done',EVENT_PRO='donebtn_ev')
;
WIDGET_CONTROL, helpbase, /REALIZE
XMANAGER, 	'ccg_help', helpbase,no_block=noblock
END
