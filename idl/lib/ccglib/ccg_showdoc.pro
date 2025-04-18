;+
; No Help Available.
;-
PRO     CCG_SHOWDOC, $
	help = help

	IF KEYWORD_SET(help) THEN CCG_SHOWDOC

        HELP, CALLS = a
        file = STRMID(a[1], STRPOS(a[1], '<') + 1, STRPOS(a[1], '.pro') - STRPOS(a[1], '<') + 3)

        CCG_SREAD,file = file, /nomessages, arr
        b = WHERE(arr EQ ';+')
        e = WHERE(arr EQ ';-')

	OPENW, fpout, '/dev/tty', /GET_LUN, /MORE
        FOR i = b[0], e[0] DO PRINTF, fpout, FORMAT = '(A0)', arr[i]
	FREE_LUN, fpout

        RETALL
END
