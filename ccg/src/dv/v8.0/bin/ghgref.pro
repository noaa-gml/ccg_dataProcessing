FUNCTION GHGref, $
   srcdir=srcdir, $
   saveas=saveas, $
   ddir=ddir, $
   sp=sp, $
   lat=lat, $
   date=date, $
   reference_type=reference_type



   ;***************************************************
   ; Initialization

   reference_type = KEYWORD_SET( reference_type ) ? reference_type : 'zonal'
   srcdir = KEYWORD_SET( srcdir ) ? srcdir : '/webdata/ccgg/GHGreference/' + sp + '/'
   saveas = KEYWORD_SET( saveas ) ? saveas : "GHGreference"
   ddir = KEYWORD_SET( ddir ) ? ddir : GETENV("HOME") + "/"

   ;***************************************************
   ; Subset reference surface

   f = srcdir + "surface.mbl." + sp + ".txt"
print, f
   ref = MY_CCG_SURFACE_SUBSET( infile=f, reference_type=reference_type, date=date, lat=lat, /nographics )

;   print, ref.data

      ; Save data to file

;	outfile = ddir+saveas + "_zonal.txt"
;print, outfile
;      OPENW, fp, outfile, /GET_LUN

;      FOR i=0,N_ELEMENTS( ref.data[0,*] )-1 DO BEGIN

;         PRINTF, fp, FORMAT='(F14.6,F12.4)', ref.data[0,i], ref.data[1,i]
;         PRINT, ref.data[0,i], ref.data[1,i]

;      ENDFOR

;      FREE_LUN, fp


END
