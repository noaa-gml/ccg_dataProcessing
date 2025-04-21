;+
; NAME:
;	CCG_SORT	
;
; PURPOSE:
;	Sort the passed file using IDL SORT command.
;	User may specify that the sort skip any number
;	of lines at the beginning of the file.  If 'skip'
;	is specified, the sort excludes these lines in the
;	sort.  The excluded lines remain (unsorted) at the
;	beginning of the file.
;
;	Returns the sorted file.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	arr=CCG_SORT(file='filename')
;	arr=CCG_SORT(file='/projects/ch4/flask/site/brw.ch4',skip=1)
;
; INPUTS:
;	file:	Specified file.
;
; OPTIONAL INPUT PARAMETERS:
;	Skip:	Specifies the number of lines at the beginning of
;		the passed file that should be excluded from the sort.
;		On completion of the sort, the excluded lines remain 
;		(unsorted) at the beginning of the file.
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
;		.
;		.
;		.
;		arr=CCG_SORT(file='projects/co/flask/site/brw.co',skip=1)
;		.
;		.
;		.
;		
; MODIFICATION HISTORY:
;	Written, KAM, February 1996.
;-
;
FUNCTION	CCG_SORT,$
		file=file,$
		skip=skip
;
;Read file.
;
CCG_SREAD,	file=file,/nomessages,str
;
IF N_ELEMENTS(str) EQ 1 THEN RETURN,''
IF NOT KEYWORD_SET(skip) THEN skip=0
;
IF skip THEN BEGIN
	headstr=str(0:skip-1)
	str=str(skip:*)
	RETURN, [headstr,str(SORT(str))]
ENDIF ELSE RETURN, str(SORT(str))
END
