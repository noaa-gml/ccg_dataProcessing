;+
; NAME:
;	CCG_PFPLISTING
;
; PURPOSE:
;	Create a list of all pfp histories for
;	passed site code.
;
; CATEGORY:
;	Data Retrieval
;
; CALLING SEQUENCE:
;	CCG_PFPLISTING,site='car',arr
;	CCG_PFPLISTING,site='all',arr
;
; INPUTS:
;	site:		PFP site code
;			site = 'car'
;			site = 'nha,dnd'
;			site = 'all'
;
; OPTIONAL INPUT PARAMETERS:
;       help:           If non-zero, the procedure documentation is
;                       displayed to STDOUT.
;		
; OUTPUTS:
;	data:		This array is of type anonymous structure:
;
;			data[].str 	-> result as a string constant
;			data[].date	-> UTC sample collection date of 
;					   first sample in PFP
;			data[].id	-> prefix of PFP serial number
;			data[].code	-> Site code
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;       Site code must designate a PFP project.
;
; PROCEDURE:
;	Once the data are put into the structure 'arr', the
;	user can employ SQL-type IDL commands to create subsets
;	of the site file.  
;		Example:
;			CCG_PFPLISTING,site='car',arr
;			.
;			.
;			.
;			FOR i=0, N_ELEMENTS(arr)-1 DO BEGIN
;				CCG_FLASK,site='car',pid=arr[i].id,date=[arr[i].date,arr[i].date],sp='co2',vp
;				.
;				.
;				.
;			ENDFOR
;
; MODIFICATION HISTORY:
;	Modified, KAM, February 2006.
;	Written, KAM, June 2004.
;-
;
PRO 	CCG_PFPLISTING, $
	site = site,$
	help = help,$
	arr
;
;Check input parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC
IF NOT KEYWORD_SET(site) THEN CCG_SHOWDOC
;
;Initialization
;
arr = 0
dbdir = '/projects/src/db/'
perlcode = dbdir + 'ccg_eventlist.pl'
;
; extract pfp listing from DB
; 
tmp = perlcode +' -strategy=pfp -site='+site
SPAWN, tmp, data

IF data[0] EQ '' THEN RETURN

n = N_ELEMENTS(data)

arr = REPLICATE({	str: '', $
			date:	'', $
			id:	'', $
			code: 	''},$
			n)

FOR i = 0, n - 1 DO BEGIN
	str = STRSPLIT(data[i], /EXTRACT)
	arr[i].str = data[i]
	arr[i].date = str[0]
	arr[i].id = str[1]
	arr[i].code = str[2]
ENDFOR
END
