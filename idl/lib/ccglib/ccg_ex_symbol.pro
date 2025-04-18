;+
PRO 		CCG_EX_SYMBOL,	dev=dev
;
;Illustrate the current set of user-defined symbols
;
;Last Modified: June 1996 - KAM
;
CCG_OPENDEV,	dev=dev,portrait=1
;
PLOT,		[0],[0],$
		/NODATA,$
		/NOERASE,$
		XSTYLE=4,$
		YSTYLE=4,$
		TITLE='SYMBOL EX'

CCG_SLEGEND,	x=0.1,y=0.95,$
		sarr=[1,1,1,2,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9],$
		farr=[0,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1],$
		thick = [1,3,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],$
		tarr=[	'CCG_SYMBOL,sym=1',$
			'CCG_SYMBOL,sym=1,thick=3.0',$
			'CCG_SYMBOL,sym=1,fill=1',$
			'CCG_SYMBOL,sym=2',$
			'CCG_SYMBOL,sym=2,thick=3.0',$
			'CCG_SYMBOL,sym=2,fill=1',$
			'CCG_SYMBOL,sym=3',$
			'CCG_SYMBOL,sym=3,fill=1',$
			'CCG_SYMBOL,sym=4',$
			'CCG_SYMBOL,sym=4,fill=1',$
			'CCG_SYMBOL,sym=5',$
			'CCG_SYMBOL,sym=5,fill=1',$
			'CCG_SYMBOL,sym=6',$
			'CCG_SYMBOL,sym=6,fill=1',$
			'CCG_SYMBOL,sym=7',$
			'CCG_SYMBOL,sym=7,fill=1',$
			'CCG_SYMBOL,sym=8',$
			'CCG_SYMBOL,sym=8,fill=1',$
			'CCG_SYMBOL,sym=9',$
			'CCG_SYMBOL,sym=9,fill=1'],$
		CHARSIZE=1.2,$
		CHARTHICK=1.0

CCG_SLEGEND,	x=0.60,y=0.95,$
		sarr=[10,11,12,13,14,15,16,17,18,19,20,21,22,23],$
		farr=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],$
		tarr=[	'CCG_SYMBOL,sym=10',$
			'CCG_SYMBOL,sym=11',$
			'CCG_SYMBOL,sym=12',$
			'CCG_SYMBOL,sym=13',$
			'CCG_SYMBOL,sym=14',$
			'CCG_SYMBOL,sym=15',$
			'CCG_SYMBOL,sym=16',$
			'CCG_SYMBOL,sym=17',$
			'CCG_SYMBOL,sym=18',$
			'CCG_SYMBOL,sym=19',$
			'CCG_SYMBOL,sym=20',$
			'CCG_SYMBOL,sym=21',$
			'CCG_SYMBOL,sym=22, fill=1', $
			'CCG_SYMBOL,sym=23'],$
		CHARSIZE=1.2,$
		CHARTHICK=1.0
;
CCG_CLOSEDEV,	dev=dev
END
;-
