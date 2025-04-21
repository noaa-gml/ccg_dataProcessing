;+
; NAME:
;	CCG_SPDEFS
;
; PURPOSE:
; 	Provide a convenient set of 
;	default species-dependent
;	plotting parameters.  To view
;	recognized species and all default 
;	settings, call CCG_SPDEFS with no keywords.
;
;	NOTE:
;
;		Please feel free to suggest alternative
;		default values that may be better choices
;		for a wider range of general applications.
;		
;		Please feel free to suggest additional species.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	CCG_SPDEFS,sp='ch4',title=title
;	CCG_SPDEFS,sp='co2c13',title=ytitle,min=ymin,max=ymax
;
; INPUTS:
;	sp:	The species keyword must be set.  Available 
;		species include:
;
;			co2, ch4, co, h2, n2o, sf6
;			f11, f12, f113, mc, cf, ct
;			co2c13, co2o18, co2o17, ch4c13
;
;	NOTE:
;
;		To view recognized species and all default
;		settings, call CCG_SPDEFS with no keywords.
;
; OUTPUTS:
;	name:		Full name of the specified species.  
;
;	title:		Default plotting title for the specified species.  
;
;       units:		Default units for specified species.
;
;	min:		Default minimum range value for the specified species.
;
;	max:		Default maximum range value for the specified species.
;
;	step:		Default step (number of major tick marks) for given 
;			range defined by 'min' and 'max' for the specified species.
;
;	mstep:		Default number of minor tick marks for given 
;			range defined by 'min' and 'max' for the specified species.
;
;	delmin:		Default minimum range for residual values for the specified species.
;
;	delmax:		Default maximum range for residual values for the specified species.
;
;	delstep:	Default step (number of major tick marks) for given 
;			range defined by 'delmin' and 'delmax' for the specified species.
;
;	delmstep:	Default number of minor tick marks for given 
;			range defined by 'delmin' and 'delmax' for the specified species.
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
;		CCG_SPDEFS,sp='ch4',title=xtitle,min=xmin,max=xmax,step=xstep
;		CCG_SPDEFS,sp='co2',title=ytitle,min=ymin,max=ymax,step=ystep
;		.
;		.
;		.
;		PLOT,	ch4_values,co2_values,$
;
;			XSTYLE=1,$
;			XRANGE=[xmin,xmax],$
;			XTICKS=xstep,$
;			XTITLE=xtitle,$
;			
;			YSTYLE=1,$
;			YRANGE=[ymin,ymax],$
;			YTICKS=ystep,$
;			XTITLE=xtitle
;		.
;		.
;		.
;		END
;		
; MODIFICATION HISTORY:
;	Written, KAM, June 1996.
;-
;
PRO	CCG_SPDEFS,$	
	sp=sp,$
	name=name,$
	title=title,$
	units=units,$
	min=min,$
	max=max,$
	step=step,$
	mstep=mstep,$
	delmin=delmin,$
	delmax=delmax,$
	delstep=delstep,$
	delmstep=delmstep

IF NOT KEYWORD_SET(sp) THEN sp=''
;
;Define basic structure
;
z={	spdefs,			$
	sp:	    	'',	$
	name:    	'',	$
	units:		'',	$
	title:   	'',	$
	min:    	0.0,	$
	max:    	0.0,	$
	step:     	0,	$
	minor:		0,	$
	delmin:		0.0,	$
	delmax:		0.0,	$
	delstep:	0,	$
	delminor:	0}
;
;Build array of structure 'spdefs'
;
arr=[		{spdefs,$
		'co2',$
		'Carbon Dioxide',$
		'ppm',$
		'CO!D2!n (!7l!3mol mol!U-1!n)',$
		320,$
		390,$
		7,$
		5,$
		-10,$
		10,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'ch4',$
		'Methane',$
		'ppb',$
		'CH!D4!n (nmol mol!U-1!n)',$
		1500,$
		1900,$
		4,$
		5,$
		-50,$
		50,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'co',$
		'Carbon Monoxide',$
		'ppb',$
		'CO (nmol mol!U-1!n)',$
		0,$
		1000,$
		5,$
		5,$
		-50,$
		200,$
		5,$
		5}]

arr=[arr,	{spdefs,$
		'h2',$
		'Molecular Hydrogen',$
		'ppb',$
		'H!D2!n (nmol mol!U-1!n)',$
		300,$
		800,$
		5,$
		5,$
		-150,$
		150,$
		6,$
		5}]

arr=[arr,	{spdefs,$
		'n2o',$
		'Nitrous Oxide',$
		'ppb',$
		'N!D2!nO (nmol mol!U-1!n)',$
		250,$
		350,$
		4,$
		5,$
		-15,$
		20,$
		7,$
		5}]

arr=[arr,	{spdefs,$
		'sf6',$
		'Sulfur Hexafluoride',$
		'ppt',$
		'SF!D6!n (pmol mol!U-1!n)',$
		3,$
		5,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'co2c13',$
		'!e13!nC/!e12!nC in Carbon Dioxide',$
		'per mil',$
		;'!4d!U13!n!3C (per mil)',$
		'!4d!U13!n!3C (!10(!3)',$
		-9,$
		-7,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'c13',$
		'!e13!nC/!e12!nC in Carbon Dioxide',$
		'per mil',$
		;'!4d!U13!n!3C (per mil)',$
		'!4d!U13!n!3C (!10(!3)',$
		-9,$
		-7,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'co2o18',$
		'!e18!nO/!e16!nO in Carbon Dioxide',$
		'per mil',$
		;'!4d!U18!n!3O (per mil)',$
		'!4d!U18!n!3O (!10(!3)',$
		-3,$
		1,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'o18',$
		'!e18!nO/!e16!nO in Carbon Dioxide',$
		'per mil',$
		;'!4d!U18!n!3O (per mil)',$
		'!4d!U18!n!3O (!10(!3)',$
		-3,$
		1,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'co2o17',$
		'oxygen-17/oxygen-16 in carbon dioxide',$
		'per mil',$
		;'!U17!n!4D!n!3 (per mil)',$
		'!U17!n!4D!n!3 (!10(!3)',$
		-0.5,$
		0.5,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'o17',$
		'oxygen-17/oxygen-16 in carbon dioxide',$
		'per mil',$
		;'!U17!n!4D!n!3 (per mil)',$
		'!U17!n!4D!n!3 (!10(!3)',$
		-0.5,$
		0.5,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'ch4c13',$
		'carbon-13/carbon-12 in methane',$
		'per mil',$
		;'!4d!U13!n!3C (per mil)',$
		'!4d!U13!n!3C (!10(!3)',$
		-48.5,$
		-46.5,$
		4,$
		5,$
		-1,$
		1,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'f11',$
		'trichlorofluoromethane',$
		'ppt',$
		'CFC-11 (pmol mol!U-1!n)',$
		250,$
		300,$
		5,$
		5,$
		-20,$
		100,$
		6,$
		5}]

arr=[arr,	{spdefs,$
		'f12',$
		'dichlorodifluoromethane',$
		'ppt',$
		'CFC-12 (pmol mol!U-1!n)',$
		500,$
		600,$
		5,$
		5,$
		-100,$
		100,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'c2h6',$
		'ethane',$
		'ppt',$
		'C!D2!nH!D6!n (pmol mol!U-1!n)',$
		0,$
		4000,$
		4,$
		5,$
		-20,$
		120,$
		7,$
		5}]

arr=[arr,	{spdefs,$
		'f113',$
		'trichlorotrifluoroethane',$
		'ppt',$
		'CFC-113 (pmol mol!U-1!n)',$
		80,$
		90,$
		5,$
		5,$
		-20,$
		20,$
		8,$
		5}]

arr=[arr,	{spdefs,$
		'mecl',$
		'methylchloroform',$
		'ppt',$
		'CH!D3!n (pmol mol!U-1!n)',$
		50,$
		250,$
		4,$
		5,$
		-20,$
		120,$
		7,$
		5}]

arr=[arr,	{spdefs,$
		'cf',$
		'chloroform,trichloromethane',$
		'ppt',$
		'CHCl!D3!n (pmol mol!U-1!n)',$
		0,$
		200,$
		5,$
		5,$
		-50,$
		150,$
		4,$
		5}]

arr=[arr,	{spdefs,$
		'ct',$
		'carbon tetrachloride',$
		'ppt',$
		'CCl!D4!n (pmol mol!U-1!n)',$
		90,$
		110,$
		4,$
		5,$
		-20,$
		20,$
		8,$
		5}]


i=WHERE(arr.sp EQ sp)
IF i(0) NE -1 THEN BEGIN
	name=arr(i).name
	title=arr(i).title
	units=arr[i].units
	min=arr(i).min
	max=arr(i).max
	step=arr(i).step
	mstep=arr(i).minor
	delmin=arr(i).delmin
	delmax=arr(i).delmax
	delstep=arr(i).delstep
	delmstep=arr(i).delminor
ENDIF ELSE BEGIN
	;
	;List recognized species and parameters.
	;
	CCG_MESSAGE,"Passed species not recognized."
	FOR i=0,N_ELEMENTS(arr)-1 DO $
		PRINT,FORMAT='(A10,A50,A25,2(2(F12.4),2(I10)))',$
		arr(i).sp,arr(i).name,arr(i).title,$
		arr(i).min,arr(i).max,arr(i).step,arr(i).minor,$
		arr(i).delmin,arr(i).delmax,arr(i).delstep,arr(i).delminor
ENDELSE
END
