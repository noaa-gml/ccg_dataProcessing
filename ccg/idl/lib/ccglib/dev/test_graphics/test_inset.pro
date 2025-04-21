@ccg_graphics

PRO TEST_INSET, dev = dev, saveas = saveas

dev = KEYWORD_SET(dev) ? dev : ''
saveas = KEYWORD_SET(saveas) ? saveas : ''

; ~~~~~~~~~~~~~~~~
; create datasets
; ~~~~~~~~~~~~~~~~

; "npts" of x between -1 and 1

npts = 101
x = INDGEN(npts)/(npts * 0.5) - 1.

; gaussian

y1 = EXP(-(x - 0)^2 / (2 * 0.1^2))

; first derivative

y2 = DERIV(x, y1)

; second derivative

y3 = DERIV(x, y2)

; ~~~~~~~~~~~~~~~~
; prepare data attributes
; ~~~~~~~~~~~~~~~~

d1 = DATA_ATTRIBUTES(x, y1, symstyle = 1, symcolor = 2, label = 'Dataset 1')

d2 = DATA_ATTRIBUTES(x, y2, symstyle = 2, symcolor = 2, label = 'Dataset 2')

d3 = DATA_ATTRIBUTES(x, y3, symstyle = 3, symcolor = 2, label = 'Dataset 3')

; ~~~~~~~~~~~~~~~~
; prepare plot attributes 
; ~~~~~~~~~~~~~~~~

; primary plot

p1 = PLOT_ATTRIBUTES(data = {d1:d1}, $
                     /nogrid, $
		     position = [0.16, 0.1, 0.95, 0.95], $
		     title = 'Test - Inset', $
		     ytitle = 'y1-label', $
		     xtitle = 'x-label', $
		     legend = 'TL')

; inset 1

p2 = PLOT_ATTRIBUTES(data = {d2:d2}, $
                     /nogrid, $
           background=25, $
		     xcharsize = 0.01, $
		     charsize = 1.0, $
		     position = [0.68, 0.73, 0.93, 0.93], $
		     ytitle = 'y2-label', $
		     legend = 'TL')

; inset 2

p3 = PLOT_ATTRIBUTES(data = {d3:d3}, $
                     /nogrid, $
		     charsize = 1.0, $
		     position = [0.68, 0.53, 0.93, 0.73], $
		     xtitle = 'x-label', $
		     ytitle = 'y3-label', $
		     legend = 'TL')

datasets = {p2:p2, p3:p3, p1:p1}

; ~~~~~~~~~~~~~~~~
; pass information to graphics procedure
; ~~~~~~~~~~~~~~~~

CCG_GRAPHICS, graphics = datasets, /portrait, wtitle = 'Test - Inset', dev = dev, saveas = saveas

END
