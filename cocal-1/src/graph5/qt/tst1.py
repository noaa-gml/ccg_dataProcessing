#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
ZetCode PyQt4 tutorial 

This program shows a confirmation 
message box when we click on the close
button of the application window. 

author: Jan Bodnar
website: zetcode.com 
last edited: October 2011
"""

import sys
from PyQt4 import QtGui

from simple import *

class Example(QtGui.QWidget):
    
    def __init__(self):
        super(Example, self).__init__()
        
        self.initUI()
        
        
    def initUI(self):               

	self.wid = Graph(self)

	vbox = QtGui.QVBoxLayout()
#        vbox.addStretch(1)
        vbox.addWidget(self.wid)

	self.setLayout(vbox)

        
#        self.setGeometry(800, 800, 850, 550)  
        self.setWindowTitle('Message box')    
        self.show()
        
        
#    def closeEvent(self, event):
 #       
#        reply = QtGui.QMessageBox.question(self, 'Message',
#            "Are you sure to quit?", QtGui.QMessageBox.Yes | 
#            QtGui.QMessageBox.No, QtGui.QMessageBox.No)

#        if reply == QtGui.QMessageBox.Yes:
#            event.accept()
#        else:
#            event.ignore()        
        
        
def main():
    
    app = QtGui.QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
