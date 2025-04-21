
from PyQt4 import QtGui, QtCore

def getTextExtent(qp, text):

	metrics = qp.fontMetrics()

#	s = metrics.boundingRect(text)
#	w = s.width()
#	h = s.height()

	w = metrics.width(text)
	h = metrics.height()

	return (w,h)

def getTextAscent(qp):

	metrics = qp.fontMetrics()
	return metrics.ascent()
	

def getCharHeight(qp):

	metrics = qp.fontMetrics()

	return metrics.height()

