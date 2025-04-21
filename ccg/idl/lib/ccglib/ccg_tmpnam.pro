;+
; NAME:
;	CCG_TMPNAM
;
; PURPOSE:
;	Return the name of the created temporary file.
;	The naming scheme is <path>/idl.###### where ######
;	is a random alphanumeric sequence assigned by a
;	system call to '/bin/mktemp'.  If 'path' is 
;	not specified the user's HOME directory is used.
;
;	NOTE:	The temporary file is automatically created.
;		The user is responsible for removing the file.
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	tmpfile=CCG_TMPNAM()
;	r=CCG_TMPNAM('/tmp')
;
; INPUTS:
;	None.
;
; OPTIONAL INPUT PARAMETERS:
;	A directory path to associate with the temporary 
;	file.  If no argument is specified, the user's 
;	HOME directory is used.
;
; OUTPUTS:
;	result:	String constant containing the name of temporary file.  
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
;
;	Example 1:
;		IDL> PRINT,CCG_TMPNAM('/tmp')
;		IDL> /tmp/idl.znJr06
;
;	Example 2:
;
;		IDL> tmp1=CCG_TMPNAM()
;		IDL> PRINT,tmp1
;		IDL> /home/ccg/ken/idl.3ovOLN
;		IDL> tmp2=CCG_TMPNAM()
;		IDL> PRINT,tmp2
;		IDL> /home/ccg/ken/idl.uPWSi9
;		IDL> CCG_SWRITE,file=tmp1,'test1'
;		IDL> CCG_SWRITE,file=tmp2,'test2'
;		.
;		.
;		.
;		IDL> SPAWN, 'rm -f '+tmp1+' '+tmp2
;
; MODIFICATION HISTORY:
;	Written, KAM, November 1996.
;	Modified, KAM, July 2002.
;-
;
FUNCTION	CCG_TMPNAM, $
		dir, $
		help = help

IF KEYWORD_SET(help) THEN CCG_SHOWDOC

IF N_PARAMS() EQ 0 THEN dir=GETENV("HOME")+'/' ELSE $
IF CCG_STRRPOS(dir,'/') NE STRLEN(dir)-1 THEN dir=TEMPORARY(dir)+'/'
;
;Does directory exist?
;If not, default to /tmp.
;
CATCH, Error_status
IF Error_status NE 0 THEN dir='/tmp/'

CD, dir,current=cdir
;
;
;Create temporary file
;
SPAWN,'/bin/mktemp '+dir+'idl.XXXXXX',r
r=r[0]
;
;Return to previous directory
;
CD,cdir
RETURN,r
END
