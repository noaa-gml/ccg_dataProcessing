;+
; NAME:
;	CCG_PROID
;
; PURPOSE:
; 	Place the name of the procedure or function that calls
;	CCG_PROID in the lower left portion of the plotting area.
;	Label includes directory path.
;
;	(ex):
;
;	If CCG_PROID is called from within the procedure 'myprog.pro'
;	then the procedure label that is displayed in the lower left
;	of the plotting area is
;
;		/users/ken/idl/misc/myprog.pro
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_PROID
;	CCG_PROID,	x=0.09,y=0.02,charsize=2.0,charthick=2.0
;	CCG_PROID,	x=0.09,y=0.02,orientation=90,alignment=1
;
; INPUTS:
;	None.
;
; OPTIONAL INPUT PARAMETERS:
;	x: y:		User-supplied coordinates for 
;			placement of procedure/function label.
;			Specify in NORMAL coordinates	
;			i.e., bottom/left of plotting surface -> x=0,y=0 
;			      top/right of plotting surface   -> x=1,y=1 
;
;			Default position coordinates
;				x=0.095
;				y=0.030
;
;	orientation:	Set this keyword to the desired angle, in degrees
;			counter-clockwise, of the text baseline with respect
;			to the horizontal.  Default:  0 (horizontal).
;
;	alignment:	This keyword specifies the horizontal alignment of the
;			text in relation to the point (x,y).  A value of
;			0.0 (the default) left-justifies the text, 0.5 centers
;			the text, and 1.0 right-justifies the text.
;
;	charsize:	Set this to alter the character size of the procedure
;			label.  Default: 0.75.
;
;	charthick:	Set this to alter the character thickness of the 
;			procedure label.  Default:  1.0
;
;       color:          [0-255]
;
;       nopath:         Set this keyword to exclude directory path
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
;	Example:
;
;		PRO 	example,$
;			labid=labid,$
;			proid=proid
;		.
;		.
;		.
;		PLOT,[0,0],[1,1]
;		.
;		.
;		.
;		IF NOT KEYWORD_SET(labid) THEN CCG_LABID
;
;		IF NOT KEYWORD_SET(proid) THEN CCG_PROID
;		
;		note:
;			using the KEYWORD_SET with the variable 'proid'
;			allows the user to omit the label by specifying
;			proid=1 when the example procedure is invoked.
;
;		result:
;			The procedure/function label displayed is
;			<directory path>/example.pro
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, January 1996.
;-
;
PRO	CCG_PROID, $
	x = x, $
	y = y, $
	charsize = charsize, $
	charthick = charthick, $
	alignment = alignment, $
	color = color, $
	nopath = nopath, $
	orientation = orientation, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;return to caller if an error occurs
;
ON_ERROR,2	
;
IF NOT KEYWORD_SET(x) THEN x=0.095
IF NOT KEYWORD_SET(y) THEN y=0.030
IF NOT KEYWORD_SET(orientation) THEN orientation=0
IF NOT KEYWORD_SET(charsize) THEN charsize=0.75
IF NOT KEYWORD_SET(charthick) THEN charthick=1.0
IF NOT KEYWORD_SET(alignment) THEN alignment=0
IF NOT KEYWORD_SET(color) THEN color=!P.COLOR
IF NOT KEYWORD_SET(nopath) THEN nopath=0 ELSE nopath=1
;
;Get procedure/function name
;
HELP,CALLS=a
txt=STRMID(a(1),STRPOS(a(1),'<')+1,STRPOS(a(1),'.pro')-STRPOS(a(1),'<')+3)
;
;Is directory path included?
;
IF STRPOS(txt,'/') EQ -1 THEN BEGIN
	CD,CURRENT=dir
 	txt=dir+'/'+TEMPORARY(txt)
	CD,dir
ENDIF

IF nopath THEN txt=STRMID(txt,CCG_STRRPOS(txt,'/')+1,1000)
	
XYOUTS, x,y,$
	/NORMAL,$
  	'!8'+txt+'!3',$
	ALI=alignment,$
	COLOR=color,$
	ORI=orientation,$
	CHARTHICK=charthick,$
	CHARSIZE=charsize
END
