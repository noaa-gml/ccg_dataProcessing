;@/home/ccg/trudeau/idl/test/ccg_graphics/ccg_graphics.pro
@/ccg/idl/lib/ccglib/dev/ccg_graphics.pro

PRO TEST_NAN, NAN = NAN

; create data to plot

yr = MAKE_ARRAY(24, VALUE = 2010)
mo = MAKE_ARRAY(24, VALUE = 1)
dy = INTARR(24) + 1
hr = INDGEN(24)
mn = INTARR(24) 
sc = INTARR(24)

CCG_DATE2DEC, yr = yr, mo = mo, dy = dy, hr = hr, mn = mn, sc = sc, dec = dec

val = DINDGEN(24) + 350D

IF KEYWORD_SET(NAN) THEN val[0] = !VALUES.D_NAN

dmax = MAX(val, MIN=dmin)
PRINT, dmin, dmax 
PRINT, val

; prepare plots

d1 = DATA_ATTRIBUTES(dec, val)

p1 = PLOT_ATTRIBUTES(data = {d1:d1}, $
                     charsize = 1.3, $ 
		     title = 'Test', $
		     ytitle = 'y-label', $
		     xtitle = 'x-label')

datasets = {p1:p1}

CCG_GRAPHICS, graphics = datasets, wtitle = 'Test', dev = dev, saveas = saveas

END
