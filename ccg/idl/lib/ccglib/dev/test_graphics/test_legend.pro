@ccg_graphics

PRO TEST_LEGEND, dev = dev, saveas = saveas

dev = KEYWORD_SET(dev) ? dev : ''
saveas = KEYWORD_SET(saveas) ? saveas : ''

; ~~~~~~~~~~~~~~~~
; create datasets
; ~~~~~~~~~~~~~~~~

; "npts" of x between -2 and 0

npts = 51
x = INDGEN(npts)/(npts * 0.5) - 2.0

; gaussians of increasing width

y1 = EXP(-(x - 0)^2 / (2 * 0.1^2))
y2 = EXP(-(x - 0)^2 / (2 * 0.3^2))
y3 = EXP(-(x - 0)^2 / (2 * 0.5^2))

; ~~~~~~~~~~~~~~~~
; prepare data attributes 
; ~~~~~~~~~~~~~~~~

; datasets 1-3 with user defined symstyle and symcolor

d1 = DATA_ATTRIBUTES(x, y1, symstyle = 1, symcolor = 7, linestyle = -1, label = 'Dataset 1')
d2 = DATA_ATTRIBUTES(x, y2, symstyle = 2, symcolor = 8, linestyle = -1, label = 'Dataset 2')
d3 = DATA_ATTRIBUTES(x, y3, symstyle = 3, symcolor = 9, linestyle = -1, label = 'Dataset 3')

; datasets 1-3 with default linestyle and linecolor

d4 = DATA_ATTRIBUTES(x, y1, label = 'Dataset 1')
d5 = DATA_ATTRIBUTES(x, y2, label = 'Dataset 2')
d6 = DATA_ATTRIBUTES(x, y3, label = 'Dataset 3')

; ~~~~~~~~~~~~~~~~
; prepare plot attributes
; ~~~~~~~~~~~~~~~~

p1 = PLOT_ATTRIBUTES(data = {d1:d1, d2:d2, d3:d3}, $
		     title = 'Test - Symbol Legend', $
		     xtitle = 'x-label', $
		     ytitle = 'y-label', $
                     /nogrid, $
                     tlegend = 'Legend Title', $
		     slegend = 'BR')

p2 = PLOT_ATTRIBUTES(data = {d4:d4, d5:d5, d6:d6}, $
		     title = 'Test - Text Legend', $
		     xtitle = 'x-label', $
		     ytitle = 'y-label', $
                     tlegend = 'Legend Title', $
		     legend = 'TL')

p3 = PLOT_ATTRIBUTES(data = {d4:d4, d5:d5, d6:d6}, $
		     title = 'Test - Line Legend', $
		     xtitle = 'x-label', $
		     ytitle = 'y-label', $
                     /nogrid, $
                     ticklen = 0.0, $
                     tlegend = 'Legend Title', $
		     llegend = 'BL')

datasets = {p2:p2, p3:p3, p1:p1}

; ~~~~~~~~~~~~~~~~
; pass information to graphics procedure
; ~~~~~~~~~~~~~~~~

CCG_GRAPHICS, graphics = datasets, /portrait, wtitle = 'Test - Legend', dev = dev, saveas = saveas

END
