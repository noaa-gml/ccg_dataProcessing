@iadv_clnlib.pro
@ccg_utils.pro

FUNCTION IADV_PROJECTPI,$
         project=project,$
         sp=sp,$
         site=site

;
; Return the name of the pi for the project and species specified
;
;
;Return to caller if an error occurs
;
;ON_ERROR,	2
;
;-----------------------------------------------check input information 
;
IF NOT KEYWORD_SET(project) THEN CCG_FATALERR,"'project' name must be specified.  Exiting ..."
IF NOT KEYWORD_SET(sp) THEN CCG_FATALERR,"'sp' must be specified.  Exiting ..."
IF NOT KEYWORD_SET(site) THEN CCG_FATALERR,"'site' must be specified.  Exiting ..."
projectchk = CLEANPROJECT(project=project)
IF ( projectchk NE 1 ) THEN CCG_FATALERR, "Invalid 'project' specified. Exiting ..."
spchk = CLEANSP(sp=sp)
IF ( spchk NE 1 ) THEN CCG_FATALERR, "Invalid 'sp' specified. Exiting ..."
sitechk = CLEANSITE(site=site)
IF ( sitechk NE 1 ) THEN CCG_FATALERR, "Invalid 'site' specified. Exiting ..."
;
;
; Read MySQL CCG db
;
srcdir='/projects/src/web/iadv/'

perlcode=srcdir+'iadv_projectpi.pl'
SPAWN, perlcode+' -project='+project+' -parameter='+sp+' -site='+site, res

return,res[0]
END
