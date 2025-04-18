;+
; NAME:
;	CCG_CD
;
; PURPOSE:
;	Change the current IDL directory 
;	using a file-selection dialog widget
;	or by selecting from a list of user
;	favorites (via a user-provided file).
;
;	Note:  
;
;	This procedure looks for the file
;	'.ccg_cd.dat' in the users home 
;	directory.  This file is used by
;	the procedure to create the list
;	of favorite directories.  The file
;	is a text file that contains a
;	list of directories, e.g., 
;
;		/projects/ch4/flask
;		/projects/co2/flask
;		~ken/tmp
;		/projects/co/maps
;		/projects/co/ids
;		/home/ccg/ken/gv
;		.
;		.
;		.
;
;	There should be no blank lines in 
;	the favorites file.
;
; CATEGORY:
;	Widget Application.
;
; CALLING SEQUENCE:
;	CCG_CD
;	CCG_CD, file=myfavorites
;	CCC_CD, /favorites
;
; INPUTS:
;	None required.
;	
; OPTIONAL INPUT PARAMETERS:
;	file:	File containing a list of favorite 
;		directory paths, e.g.,
;
;			/projects/ch4/flask
;			/projects/co2/flask
;			~ken/tmp
;			/home/ccg/ken/favorite_dir
;			.
;			.
;			.
;
;	favorites:	If set to a non-zero integer, procedure 
;			will go directly to the list of favorite 
;			directories contained in the user provided 
;			file (default: $HOME/.ccg_cd.dat) instead
;			of querying the user.
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
;	No examples.
;
; MODIFICATION HISTORY:
;	Written, KAM, October 1998.
;-
;
PRO CCG_CD_EVENT, ev

COMMON  ccg_cd,  ok,filter,cancel,list,list_index

CASE ev.id OF
    list :	BEGIN
		list_index=WIDGET_INFO(list,/LIST_SELECT)
		END
    ok :	BEGIN
		WIDGET_CONTROL,list,GET_UVALUE=dir
		IF CCG_VDEF(list_index) THEN cd,dir[list_index]
   		WIDGET_CONTROL, ev.top, /DESTROY
		END
    filter :	BEGIN
		WIDGET_CONTROL,list,GET_UVALUE=dir
		IF CCG_VDEF(list_index) THEN z=dir[list_index] ELSE CD,CURRENT=z
   		WIDGET_CONTROL, ev.top, /DESTROY
		z=DIALOG_PICKFILE(PATH=z,GET_PATH=path,TITLE='CCG_CD')
		IF path NE '' THEN CD,path
		END
    cancel:	WIDGET_CONTROL, ev.top, /DESTROY
ENDCASE
END

PRO	CCG_CD,$
	favorites=favorites,$
	file=file
;
;Return to caller if an error occurs
;
ON_ERROR,2

COMMON  ccg_cd,  ok,filter,cancel,list,list_index

font = '*times-medium-r-*180*'

r='No'
IF NOT KEYWORD_SET(file) THEN file=GETENV("HOME")+'/.ccg_cd.dat'
CCG_SREAD,file=file,arr
arr=arr(SORT(arr))
IF KEYWORD_SET(favorites) THEN r='Yes'
IF arr[0] NE '' AND r EQ 'No' THEN r=DIALOG_MESSAGE(TITLE='CCG_CD',/QUESTION,"Select from Favorites")

CASE r OF
'Yes':	BEGIN
	base = WIDGET_BASE(/COLUMN)
	list = WIDGET_LIST(base,VALUE=arr,YSIZE=10,XSIZE=30,FONT=font,UVALUE=arr)
	respbase = WIDGET_BASE(base,/ROW)
	ok = WIDGET_BUTTON(respbase, VALUE="    OK    ",FONT=font,UVALUE='ok')
	filter= WIDGET_BUTTON(respbase, VALUE="  FILTER  ",FONT=font,UVALUE='filter')
	cancel= WIDGET_BUTTON(respbase, VALUE="  CANCEL  ",FONT=font,UVALUE='cancel')
	WIDGET_CONTROL, base, /REALIZE
	XMANAGER, 'CCG_CD', base
	END
'No':	BEGIN
	z=DIALOG_PICKFILE(GET_PATH=path,TITLE='CCG_CD')
	IF path NE '' THEN CD,path
	END
ENDCASE
CD,CURRENT=dir
CCG_MESSAGE,"Current directory:  "+dir
END
