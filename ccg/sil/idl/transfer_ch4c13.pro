PRO TRANSFER_CH4C13, file=file,pause=pause,keepgoing=keepgoing 
;;;;,csvgood=csvgood,testmode=testmode;no_update=no_update,ref_data=ref_data


print,'running sil_raw_ch4c13'
IF NOT KEYWORD_SET(keepgoing) THEN keepgoing=0

IF keepgoing EQ 1 THEN pause=0 ELSE pause=1



SIL_RAW_CH4C13, file = file+'temp.csv', rawfile    ;;;testmode = testmode, csvgood = csvgood, 


print,'running sil_proc_ch4isotopes. ..'

	SIL_PROC_CH4ISOTOPES, file = rawfile, /DIAGNOSTICS,  $
	update=1,reprintsil=1,printtanks=1,log_data=0,$
	uncertainty=1, pause=pause,sp='ch4c13',secposflags=1,printsitefiles=1


END
