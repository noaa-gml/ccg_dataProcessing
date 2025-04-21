; Compile

.RUN ghgref.pro
.RUN surf_subset.pro


; Execution

;z = GHGREF( sp = GETENV( "GHGref_PARAMETER" ), $
;                  lat = GETENV( "GHGref_LATITUDE" ), $
;                  date = GETENV( "GHGref_DATE" ), $
;                  reference_type = GETENV( "GHGref_REFERENCE" ), $
;                  saveas = GETENV( "GHGref_SAVEAS" ), $
;                  ddir = GETENV( "GHGref_DDIR" ), $
;                  dev = dev )

z = GHGREF( sp = "co2", $
                  lat = "-10,10", $
                  reference_type = "zonal", $
                  saveas = GETENV( "GHGref_SAVEAS" ), $
                  ddir = "/ccg/src/dv/v5.34/bin/" )

EXIT

