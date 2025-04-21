@ccg_graphics
@ccg_utils

PRO TEST_ANNOTATION, test, dev = dev, saveas = saveas

; To run annotation examples in case statement below, 
; call TEST_ANNOTATION with parameter from 0 to # examples:
;
; IDL>test_annotation, 0
; IDL>test_annotation, 1

test = KEYWORD_SET(test) ? test : 0
dev = KEYWORD_SET(dev) ? dev : ''
saveas = KEYWORD_SET(saveas) ? saveas : ''

; ~~~~~~~~~~~~~~~~
; create dataset
; ~~~~~~~~~~~~~~~~

npts = 51
x = DINDGEN(npts)
y = DBLARR(npts) + 1D

seed = SYSTIME(1)
FOR i = 0, N_ELEMENTS(y) - 1 DO y[i] = y[i] + RANDOMN(seed)

xmax = x[WHERE(y EQ MAX(y))]
ymax = y[WHERE(y EQ MAX(y))]

; ~~~~~~~~~~~~~~~~
; prepare data attributes 
; ~~~~~~~~~~~~~~~~

d1 = DATA_ATTRIBUTES(x, y, symstyle = 1, symcolor = 7, linestyle = -1)

; ~~~~~~~~~~~~~~~~
; prepare plot attributes
; ~~~~~~~~~~~~~~~~

line1 = 'Equation:'
line2 = '!6F(s) = (2!4p)!e-1/2!n !mi!s!a!e!m'  + STRING( "44b) + '!r!b!i-!m' + STRING( "44b) + '!nF(x)e!e-i2!4p!3xs!ndx'

a1 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 1', position = 'BL', charsize = 1.0, color = 3)
a2 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 1', position = 'TR', charsize = 3.0, orientation = 45.0, color = 4)
a3 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 2', position = 'TR', charsize = 3.0, orientation = 45.0, color = 4)
a4 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 1', position = 'TLH', charsize = 2.0, color = 4)
a5 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 2', position = 'TLH', charsize = 2.0, color = 8)
a6 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 2', position = 'BL', charsize = 1.0, color = 8)
a7 = ANNOTATION_ATTRIBUTES(text = 'Annotation Line 3', position = 'BL', charsize = 1.0, color = 6)

CASE test OF

  ; string array, plot two lines of text
  0:annotation = [line1, line2] 

  ; one element string array, plot two lines of text using a carriage return
  1:annotation = line1 + '!C' + line2

  ; structure, plot two lines of text and specify position, color, charsize
  2:annotation = {a1:{TEXT:line1, POSITION:'BL', CHARSIZE:2.0}, a2:{TEXT:line2, POSITION:'BL', COLOR:2}}

  ; structure, indicate dataset maximum with rotated text at the given x,y position in data coordinates
  3:annotation = {a1:{TEXT:'Maximum ', POSITION:[xmax, ymax], ORIENTATION:-25.0, COLOR:4}}

  ; structures as returned by ANNOTATION ATTRIBUTES, 7 annotations grouped by position
  4:annotation = {a1:a1, a2:a2, a3:a3, a4:a4, a5:a5, a6:a6, a7:a7}
ENDCASE

p1 = PLOT_ATTRIBUTES(data = {d1:d1}, $
                     yaxis = [MIN(y) - 3, MAX(y) + 3, 0, 0], $
		     title = 'Test - Annotation', $
		     xtitle = 'x-label', $
		     ytitle = 'y-label', $
                     /nogrid, $
                     tlegend = 'Legend Title', $
                     annotation = annotation)

p2 = PLOT_ATTRIBUTES(data = {d1:d1}, $
                     yaxis = [MIN(y) - 3, MAX(y) + 3, 0, 0], $
		     title = 'Test - Annotate/atext', $
		     xtitle = 'x-label', $
		     ytitle = 'y-label', $
                     /nogrid, $
                     tlegend = 'Legend Title', $
                     annotate = 'BL', $
                     atext = 'Annotate/atext Example')

datasets = {p1:p1, p2:p2}

; ~~~~~~~~~~~~~~~~
; pass information to graphics procedure
; ~~~~~~~~~~~~~~~~

CCG_GRAPHICS, graphics = datasets, /portrait, wtitle = 'Test - Annotation', dev = dev, saveas = saveas

END
