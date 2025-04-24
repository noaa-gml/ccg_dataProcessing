PRO make_testgastab,sp=sp
IF sp EQ 'ch4c13' THEN style='oldstyle' ELSE style='newstyle'

;get data from testflaskcyl.co2c13.txt and put it in testgas.tab

tabfile='/projects/co2c13/flask/tstgas.tab'     ; this is really just the file with the dates of which cylinder is in use. Data will come from our files directly 
	; via testflaskcyl.
datafile='/home/ccg/sil/testflasks/testflaskcyl.'+sp+'.txt

CCG_SREAD, file=tabfile, comment='#',skip=18,tabdata
	
truncate=STRMID(tabdata,0,50)

tstfile='/home/ccg/sil/testflasks/tstgastemp.txt'
CCG_SWRITE,file=tstfile ,truncate

CCG_READ,file=tstfile ,tab
ntab=N_ELEMENTS(tab)
value=FLTARR(ntab)
sd=FLTARR(ntab)
inst=STRARR(ntab)
	
; read data file to compare to
CCG_READ,file=datafile,skip=1,data
	
	FOR t=0,ntab -1 DO BEGIN
		IF style EQ 'oldstyle' THEN BEGIN
			IF strmid(tab[t].field5,0,1) EQ 'A' THEN $
				match=WHERE(STRMID(tab[t].field5,5,3) EQ STRMID(data.field1,4,3) AND $ ;name
			    tab[t].field6 EQ STRUPCASE(data.field5))  ELSE $    
			    	match=WHERE(STRMID(tab[t].field5,5,3) EQ STRMID(data.field1,5,3) AND $ ;name
			    tab[t].field6 EQ STRUPCASE(data.field5))    ;fillcode
			    
		ENDIF ELSE BEGIN	
			match=WHERE(STRMID(tab[t].field5,5,3) EQ STRMID(data.field1,5,3) AND $ ;name
			    tab[t].field6 EQ STRUPCASE(data.field5))    ;fillcode
		ENDELSE
		
		IF match[0] EQ -1 THEN BEGIN
			value[t]=-999
			print,'no match'
			
		ENDIF ELSE BEGIN
			value[t]=data[match].field6
			sd[t]=data[match].field7
			inst[t]=data[match].field8
			print,'match'
		ENDELSE
		
	ENDFOR


testfile='/home/ccg/sil/testflasks/tabdata.'+sp+'.txt'
testformat='(I5,I3,I3,I3,A9,A5,I2,F10.4,F10.4,A4,F10.4,A18)'
OPENW, u,testfile, /GET_LUN

FOR k=0,ntab-1 DO PRINTF,u,format=testformat,  $

tab[k].field1,	$
tab[k].field2,	$
tab[k].field3,	$
tab[k].field4,	$
tab[k].field5,	$
tab[k].field6,	$
tab[k].field7,	$
tab[k].field8,	$
value[k], 	$
'#  ',		$
sd[k],          $
inst[k]

FREE_LUN,u


;ENDFOR


END
