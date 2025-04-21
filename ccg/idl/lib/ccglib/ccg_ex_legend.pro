;+
PRO 		CCG_EX_LEGEND,dev=dev,ccg=ccg
;
;-------------------------------------- procedure description
;
;provides examples of the use of
;	(1)	ccg_opendev
;	(2) 	ccg_slegend
;	(3)	ccg_tlegend
;	(4)	ccg_llegend
;	(5)	ccg_labid
;	(6) 	ccg_closedev
;
;
CCG_OPENDEV,	dev=dev,pen=pen
;
PLOT,	[0,0],[1,1],$
	TITLE='LEGEND EXAMPLE'
;
;intialization of some legend vectors
;
farr=[1,1,1,1,1,1,1,1,1,0,0,0,0]

sarr=[1,2,3,4,5,6,7,8,9,10,11,12,13]

carr=[pen(1),pen(2),pen(3),pen(4),pen(5),pen(6),pen(7),$
	pen(8),pen(9),pen(10),pen(11),pen(12),pen(1)]
;
;Example of symbol legend
;
tarr=['SQUARE','CIRCLE','TRIANGLE 1','TRIANGLE 2','DIAMOND','STAR 1','STAR 2',$
	'HOURGLASS','BOWTIE','PLUS','ASTERISK','CIRCLE/PLUS','CIRCLE/X']

CCG_SLEGEND,	x=.2,y=.8,$
		tarr=tarr,$
		farr=farr,$
		sarr=sarr,$
		carr=carr,$
		charthick=2.0,$
		charsize=1.0,$
		frame=0
;
;Example of text legend
;
tarr=[	'ALT','ASC','AZR','BAL','BME','BMW','BRW',$
      	'CBA','CGO','CHR','CMO','CRZ','GMI']

CCG_TLEGEND,	x=.45,y=.8,$
		tarr=tarr,$
		carr=carr,$
		charthick=2.0,$
		charsize=2.0,$
		frame=1
;
;Example of line legend
;
tarr=[	'This','is','an','example','of','a','line','legend']
larr=[0,1,2,3,4,5,0,1]
carr=[pen(1),pen(2),pen(3),pen(4),pen(5),pen(6),pen(7),pen(8)]
tharr=INDGEN(N_ELEMENTS(carr))+1

CCG_LLEGEND,	x=.7,y=.5,$
		tarr=tarr,$
		larr=larr,$
		carr=carr,$
  		thick=tharr,$
		charthick=2.0,$
		charsize=2.0,$
		frame=0
;
;------------------------------------------------ ccg label
;
IF NOT KEYWORD_SET(ccg) THEN CCG_LABID,full=1
;
;----------------------------------------------- close up shop 
;
CCG_CLOSEDEV,	dev=dev
END
;-
