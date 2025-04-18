;@/home/ccg/trudeau/idl/test/ccg_graphics/ccg_graphics.pro
@/ccg/idl/lib/ccglib/dev/ccg_graphics.pro

PRO TEST_XCUSTOM, XAXIS = XAXIS

; create data to plot

nhr = 24

yr = MAKE_ARRAY(nhr, VALUE = 2010)
mo = MAKE_ARRAY(nhr, VALUE = 1)
dy = INTARR(nhr) + 1
hr = INDGEN(nhr)
mn = INTARR(nhr) 
sc = INTARR(nhr)

CCG_DATE2DEC, yr = yr, mo = mo, dy = dy, hr = hr, mn = mn, sc = sc, dec = dec

val = DINDGEN(nhr) + 350D

xaxis = KEYWORD_SET(xaxis) ? [MIN(dec), MAX(dec), 0, 0] : 0

; prepare plots

d1 = DATA_ATTRIBUTES(dec, val)

p1 = PLOT_ATTRIBUTES(data = {d1:d1}, $
                     xcustom = "hour", $
                     xaxis = xaxis, $
                     charsize = 1.3, $ 
		     title = 'Test', $
		     ytitle = 'y-label', $
		     xtitle = 'x-label')

datasets = {p1:p1}

CCG_GRAPHICS, graphics = datasets, wtitle = 'Test', dev = dev, saveas = saveas

END
