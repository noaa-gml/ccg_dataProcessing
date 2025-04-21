;+
; NAME:
;	CCG_DIRLIST
;
; PURPOSE:
;	Create a list of all files in
;	the passed directory.  Directory
;	may contain wildcards (*).  List
;	is returned in passed array.
;	
;	If [sp] is specified then the list
;	will contain all site files in the
;	specified species directory.  If 
;	[omitdir] is specified then the 
;	list excludes the path with the file name.
;
; CATEGORY:
;	Text Files.
;
; CALLING SEQUENCE:
;	CCG_DIRLIST,dir='/users/ken/tmp/*.datzc',result
;	CCG_DIRLIST,sp='co2',omitdir=1,list
;
; INPUTS:
;	dir:	Directory path.
;
; OPTIONAL INPUT PARAMETERS:
;	sp:		Species name to produce a site file list.
;			Current species options: 
;
;				co2, ch4, co, h2, n2o,sf6,
;				co2c13, co2o18, ch4c13
;
;	omitdir:	Omit path with site file list.	
;
; OUTPUTS:
;	output:	String array containing list of files.
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
;	CCG_DIRLIST may be called from the IDL command line or
;	from an IDL procedure.
;	Example:
;		CCG_DIRLIST,	dir='/projects/co2/flask/site/*.co2',list
;		
;			This directory path will return a list of files
;			attached to the directory path, i.e., 
;				.
;				/projects/co2/flask/site/alt.co2
;				/projects/co2/flask/site/brw.co2
;				.
;				.
;				.
;		CCG_DIRLIST,	dir='/projects/co2/flask/site',list
;				or
;		CCG_DIRLIST,	dir='/projects/co2/flask/site/*.co2',omitdir=1,list
;		
;			This directory path will return a list of files
;			excluding directory path, i.e., 
;				alt.co2
;				brw.co2
;				.
;				.
;				.
;		
; MODIFICATION HISTORY:
;	Written, KAM, August 1994.
;-
;
PRO 	CCG_DIRLIST, $
	dir = dir, $
	sp = sp, $
	omitdir = omitdir, $
	result, $
	help = help
;
;Check input parameters
;
IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF KEYWORD_SET(sp) AND KEYWORD_SET(dir) THEN BEGIN
	CCG_MESSAGE,'Both [sp] and [dir] may not be specified.  Exiting ...
	CCG_MESSAGE,"(ex) ccg_dirlist,	dir='/projects/co2/flask/site/*.co2',list"
	CCG_MESSAGE,"(ex) ccg_dirlist,	sp='co2',list"
	RETURN
ENDIF
;

dir_ = dir

CATCH, Error_status
IF Error_status NE 0 THEN RETURN

result=''

IF KEYWORD_SET(sp) THEN BEGIN
	 
	;Build directory
	 
	dir_='/projects/'+sp+'/flask/site/'
	filter='*.'+sp

	IF NOT KEYWORD_SET(omitdir) THEN BEGIN
		result = FILE_SEARCH(dir_+filter, /MARK_DIRECTORY)
	ENDIF ELSE BEGIN
		CD,dir,CURRENT=olddir	
		result = FILE_SEARCH(filter, /MARK_DIRECTORY)
		CD,olddir
	ENDELSE

ENDIF ELSE BEGIN
   
   ; Test 'dir_' keyword

   IF FILE_TEST(dir, /DIRECTORY) THEN BEGIN

      dir_ = CCG_STRRPOS(dir_,'/') NE STRLEN(dir_) - 1 ? dir_ + '/*' : dir_ + '*'

   ENDIF

	IF NOT KEYWORD_SET(omitdir) THEN BEGIN

		result = FILE_SEARCH(dir_, /MARK_DIRECTORY)

	ENDIF ELSE BEGIN

		j=0
		k=0
		WHILE j NE -1 DO BEGIN
			j=STRPOS(dir_,'/',k)
			IF j NE -1 THEN k=j+1
		ENDWHILE
		;
 		CD,STRMID(dir_,0,k),CURRENT=olddir	
		result = FILE_SEARCH(STRMID(dir_, k, 100),/MARK_DIRECTORY)
		CD,olddir

	ENDELSE

ENDELSE

END
