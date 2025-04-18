FUNCTION CLEANSITE, site=site

   chk = 0;
   chk = STREGEX( site, "[^A-Za-z0-9]", /BOOLEAN);
   IF chk EQ 1 THEN RETURN, 0

   chk = 0;
   chk = STRLEN( site )
   IF ( chk LE 0 OR chk GT 10 ) THEN RETURN, 0

   IF site EQ 'all' THEN RETURN,1

   z = ''
   code = STRMID(site, 0, 3 )
   dbdir = '/projects/src/db/'
   perl = dbdir + 'ccg_siteinfo.pl'
   SPAWN, perl + " -site=" + code, z
   IF z NE '' THEN RETURN,1

   RETURN,0

END

FUNCTION CLEANSP, sp=sp

   z = ''
   chk = 0;

   chk = STREGEX( sp, "[^A-Za-z0-9]", /BOOLEAN);

   IF chk EQ 1 THEN RETURN, 0

   dbdir = '/projects/src/db/'
   perl = dbdir + 'ccg_gasinfo.pl'
   SPAWN, perl + " -parameter=" + sp, z

   IF z NE '' THEN RETURN,1

   RETURN,0

END

FUNCTION CLEANPROJECT, project=project

   chk = 0;

   chk = STREGEX( project, "[^A-Za-z\-_]", /BOOLEAN);

   IF chk EQ 1 THEN RETURN, 0

   dbdir = '/projects/src/db/'
   perl = dbdir + 'ccg_query.pl'
   sql = "SELECT abbr FROM gmd.project WHERE program_num = '1'"
   SPAWN, perl+' "'+sql+'"',projects
   nprojects = N_ELEMENTS(projects)

   FOR i=0, nprojects-1 DO BEGIN
      ;print, projects[i]
      IF ( projects[i] EQ project ) THEN RETURN, 1
   ENDFOR

   RETURN, 0

END
