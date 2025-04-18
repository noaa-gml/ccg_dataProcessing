;+
; NAME:
;	CCG_SYMBOL
;
; PURPOSE:
; 	Create a user defined plotting symbol.
;	The symbol types may be viewed by typing
;	the procedure, 'symbol_ex'.
;	
;		IDL>symbol_ex
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_SYMBOL,sym=4,fill=1
;	CCG_SYMBOL,sym=4,fill=1,thick=2.0
;
; INPUTS:
;	sym:	Integer specifying the symbol type (see below).
;
;	*** CCG_SYMBOL TYPE ***
;
;	0:	dot
;	1:	square
;	2:	circle
;	3:	triangle
;	4:	inverted triangle
;	5:	diamond
;	6:	star 1
;	7:	star 2
;	8:	hourglass
;	9:	bowtie
;	10:	plus
;	11:	asterisk			
;	12:	circle w/ plus
;	13:	circle w/ ex
;	14:	partial arrow (right)
;	15:	partial arrow (right)
;	16:	full arrow
;	17:	vertical line
;	18:	horizontal line
;	19:	right pointer
;	20:	left pointer
;
; OPTIONAL INPUT PARAMETERS:
;
;	fill:	If specified then symbol is filled.
;	thick:	Specifies the line thickness of symbol.  Default:  thick=1.0
;
; OUTPUTS:
;	Defines IDL USER CCG_SYMBOL PSYM=8.
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
;		PRO example
;		.
;		.
;		.
;		CCG_SYMBOL,sym=5			<- open diamond
;		PLOT,x,y,PSYM=8,COLOR=col
;
;		CCG_SYMBOL,sym=2,fill=1			<- filled circle
;		PLOT,x,y,PSYM=8,SYMSIZE=.8,COLOR=col
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, April 1993.
;-
;
PRO 	CCG_SYMBOL, $
	sym = sym, $
	fill = fill, $
	thick = thick, $
	help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC
;
;------------------------------------------------ begin close plot device 
;
IF NOT CCG_VDEF(sym) THEN BEGIN
	PRINT,"Must specify symbol type: "
	PRINT,"  symbol,sym=0		->	dot"
	PRINT,"  symbol,sym=1		->	square"
	PRINT,"  symbol,sym=2 		->	circle"
	PRINT,"  symbol,sym=3		->	triangle"
	PRINT,"  symbol,sym=4		->	triangle (inverted)"
	PRINT,"  symbol,sym=5		->	diamond"
	PRINT,"  symbol,sym=6		->	star 1"
	PRINT,"  symbol,sym=7		->	star 2"
	PRINT,"  symbol,sym=8		->	hourglass"
	PRINT,"  symbol,sym=9		->	bowtie"
	PRINT,"  symbol,sym=10		->	plus"
	PRINT,"  symbol,sym=11		->	asterisk"
	PRINT,"  symbol,sym=12		->	circle w/ plus"
	PRINT,"  symbol,sym=13		->	circle w/ ex"
	PRINT,"  symbol,sym=14		->	partial arrow (right)"
	PRINT,"  symbol,sym=15		->	partial arrow (left)"
	PRINT,"  symbol,sym=16		->	full arrow"	
	PRINT,"  symbol,sym=17		->	vertical line"
	PRINT,"  symbol,sym=18		->	horizontal line"
	PRINT,"  symbol,sym=19		->	right pointer"
	PRINT,"  symbol,sym=20		->	left pointer"
	PRINT,"  symbol,sym=21		->	horizontal rectangle"
	PRINT,"  symbol,sym=22		->	vertical rectangle"
	PRINT,"  symbol,sym=23		->	X"
	PRINT,"Include fill=1 for filled symbol."
	RETURN
ENDIF

IF NOT KEYWORD_SET(fill) THEN fill=0

IF NOT KEYWORD_SET(thick) THEN thick=1

CASE 1 OF
;
;No Symbol
;
(sym EQ 0):	BEGIN
		x=[0, 0]
		y=[0, 0]
		END	
;
;square
;
(sym EQ 1):	BEGIN
		x=[-1,-1, 1, 1,-1]
		y=[-1, 1, 1,-1,-1]
		END	
;
;circle
;
(sym EQ 2):	BEGIN
		x=[1,.866, .707, .500, 0,-.500,-.707,-.866,-1,$
		    -.866,-.707,-.500, 0, .500, .707, .866, 1]
		y=[0,.500, .707, .866, 1, .866, .707, .500, 0,$
		    -.500,-.707,-.866,-1,-.866,-.707,-.500, 0]
		END	
;
;triangle
;
(sym EQ 3):	BEGIN
		x=[-0.924, 0.000, 0.924,-0.924]
		y=[-0.600, 1.000,-0.600,-0.600]
		END
;
;inverted triangle
;
(sym EQ 4):	BEGIN
		x=[-0.924, 0.000, 0.924,-0.924]
		y=[ 0.600,-1.000, 0.600, 0.600]
		END
;
;diamond
;
(sym EQ 5):	BEGIN
		x=[ 0,-1, 0, 1, 0]
		y=[-1, 0, 1, 0,-1]
		END
;
;star 1
;
(sym EQ 6):	BEGIN
		x=[ 0, .4,  1, .7,  1, .4, 0, -.4, -1, -.7,  -1, -.4, 0]
		y=[-1,-.4,-.4,  0, .4, .4, 1,  .4, .4,   0, -.4, -.4,-1]
		END
;
;star 2
;
(sym EQ 7):	BEGIN
		x=[-1,-.2, 0,.2,1, .2, 0,-.2,-1]
		y=[ 0, .2, 1,.2,0,-.2,-1,-.2, 0]
		END
;
;hourglass
;
(sym EQ 8):	BEGIN
		x=[-1, 1,-1,1,-1]
		y=[-1,-1, 1,1,-1]
		END
;
;hourglass (on side)
;
(sym EQ 9):	BEGIN
		x=[-1,-1, 1,1,-1]
		y=[-1, 1,-1,1,-1]
		END
;
;plus
;
(sym EQ 10):	BEGIN
		x=[-1, 1, 0, 0, 0]
		y=[ 0, 0, 0, 1,-1]
		END
;
;asterisk
;
(sym EQ 11):	BEGIN
		x=[-1, 1, 0, 0, 0, 0,-1, 1, 0,-1, 1]
		y=[ 0, 0, 0,-1, 1, 0,-1, 1, 0, 1,-1]
		END
;
;circle and plus
;
(sym EQ 12):	BEGIN
		x=[1,.866, .707, .500, 0,-.500,-.707,-.866,-1,$
		    -.866,-.707,-.500, 0, .500, .707, .866, 1,$
		  -1,   0,    0,    0]
		y=[0,.500, .707, .866, 1, .866, .707, .500, 0,$
		    -.500,-.707,-.866,-1,-.866,-.707,-.500, 0,$
		   0,   0,    1,   -1]
		END	
;
;circle and ex 
;
(sym EQ 13):	BEGIN
		x=[1,.866, .707, .500, 0,-.500,-.707,-.866,-1,$
		    -.866,-.707,-.500, 0, .500, .707, .866, 1,$
		   .866,.707,-.707,    0, .707,-.707]
		y=[0,.500, .707, .866, 1, .866, .707, .500, 0,$
		    -.500,-.707,-.866,-1,-.866,-.707,-.500, 0,$
		   .500,.707,-.707,    0,-.707, .707]
		END	
;
;right arrow 
;
(sym EQ 14):	BEGIN
		x=[ 0.000,0.000,0.342,0.000]
		y=[-1.000,1.000,0.000,0.000]
		END	
;
;left arrow 
;
(sym EQ 15):	BEGIN
		x=[ 0.000,0.000,-0.342,0.000]
		y=[-1.000,1.000, 0.000,0.000]
		END	
;
;full arrow 
;
(sym EQ 16):	BEGIN
		x=[ 0.000,0.000, 0.342,-0.342,0.000]
		y=[-1.000,1.000, 0.000,0.000,1.000]
		END	
;
;vertical line 
;
(sym EQ 17):	BEGIN
		x=[ 0.000,0.000]
		y=[-1.000,1.000]
		END	
;
;horizontal line
;
(sym EQ 18):	BEGIN
		x=[-1.000,1.000]
		y=[ 0.000,0.000]
		END
;
;right pointer
;
(sym EQ 19):	BEGIN
		x=[-1.0, 1.0, -1.0, -1.0]
		y=[-1.0, 0.0,  1.0, -1.0]
		END
;
;left pointer
;
(sym EQ 20):	BEGIN
		x=[-1.0, 1.0, 1.0, -1.0]
		y=[ 0.0,-1.0, 1.0,  0.0]
		END
;
;rectangle1
;
(sym EQ 21):	BEGIN
		x=[-1.0, 1.0, 1.0, -1.0, -1.0]
		y=[-0.5,-0.5, 0.5,  0.5, -0.5]
		END
;
;rectangle2
;
(sym EQ 22):	BEGIN
		x=[-0.5, 0.5, 0.5, -0.5, -0.5]
		y=[-1.0,-1.0, 1.0,  1.0, -1.0]
		END
;
; X
;
(sym EQ 23):	BEGIN
		x=[ -1,  1, 0, -1, 1 ]
		y=[ -1,  1, 0, 1, -1 ]
		END

ENDCASE

USERSYM, x, y, FILL = fill, THICK = thick

END
