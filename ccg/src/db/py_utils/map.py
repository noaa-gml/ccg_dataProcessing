#!/usr/bin/env python
#db_map.py

"""
create map of passed positional data
"""
from pylab import *
from mpl_toolkits.basemap import Basemap
import os
import sys
import re
import datetime
import argparse

if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')
import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_file_ops as pyu_file




class MapPlot(object) :#Change ClassName
    def __init__(self,verbose=0):
        super(MapPlot, self).__init__()#Change ClassName to match above
        self.verbose=verbose

    def createMap(self,lats, lons,zoomLevel=0):
        #Passed lists of lats and lons, this will create a map and plot the points.

        #Find the midpoint to center the map on
        lon_0= self.getLonMidPoint(lons.min(),lons.max())
        lat_0= self.getLatMidPoint(lats.min(),lats.max())
        if(self.verbose):print((" lon min:"+str(lons.min())+" lon max:"+str(lons.max())+" lon_0:"+str(lon_0)+" lat min:"+str(lats.min())+" lat max:"+str(lats.max())+" lat_0:"+str(lat_0)))

        #Create the Figure window (the base map will go into this)
        fig=plt.figure(figsize=(20,10))
        #deprecated in matplotlib fig.canvas.set_window_title( "CCGG" )
        markersize=10

        #Zoom if asked.
        if zoomLevel >0 : #zoom the boundries in

            z=1000 #margin/border
            r='l'#low res
            if(zoomLevel==3):
                z=7
                r='h'#high
            elif zoomLevel==2 :
                z=10
                r='i'#intermediate
            elif zoomLevel==1 :
                z=30
                r='l'#low

            llcrnrlon=lons.min()-z if lons.min()-z>-180 else -180
            urcrnrlon=lons.max()+z if lons.max()+z<180 else 180
            llcrnrlat=lats.min()-z if lats.min()-z>-90 else -90
            urcrnrlat=lats.max()+z if lats.max()+z<90 else 90

            if(self.verbose):print((" llcrnrlon:"+str(llcrnrlon)+" urcrnrlon:"+str(urcrnrlon)+" llcrnrlat:"+str(llcrnrlat)+" urcrnrlat:"+str(urcrnrlat)))
            m = Basemap(projection='cyl',resolution=r,lon_0=lon_0,lat_0=lat_0,llcrnrlon=llcrnrlon,llcrnrlat=llcrnrlat, urcrnrlon=urcrnrlon, urcrnrlat=urcrnrlat)#moll
            #if(zoomLevel==3): m.bluemarble()
        else: #Full globe

            m = Basemap(projection='robin',lon_0=lon_0,lat_0=lat_0,resolution='l')#moll
            m.drawmeridians(np.arange(-180,180,30),color='gray',dashes=[1,0.000001],linewidth=0.5,latmax=90)
            m.drawparallels(np.arange(-90,90,30),color='gray',dashes=[1,0.0000001],linewidth=0.5,latmax=90)




        ax = fig.add_axes([0.1,0.1,0.8,0.8])
        m.drawcoastlines(color='grey',linewidth=0.3)
        m.drawcountries(color='grey',linewidth=0.3)
        m.drawmapboundary(fill_color='#d0e5ff')
        m.fillcontinents(color='#d8d8d8',lake_color='#d0e5ff')
        m.drawstates(color='grey',linewidth=0.3)
        if zoomLevel==3 : m.drawrivers(color='grey',linewidth=0.1)
        #m.drawlsmask()
        x,y=m(lons,lats)#convert to map coords

        ax.plot(x,y,'.',color='green',markersize=markersize) #Plot

        show()

        plt.close()


    def getLonMidPoint(self,a,b):
        #Returns the minimal longitudinal mid point between a and b (shortest side round globe)
        #Credit Zachery Mund for algorithm
        mid=(a+b)/2 #nominal mid point
        if abs(a)+abs(b)>=180 and a*b<0 : #if a->b is actually the long path and the short path will be around the half point (180) then we need to adjust
            d=1 if mid<=0 else -1 #whether we're going left or right from the half point
            mid=(d*180)+mid

        return mid

    def getLatMidPoint(self,a,b):
        #Returns the latitudinal mid point between two latitudes from equatorial view (won't center on pole) so can plot on map projection
        return (a+b)/2


    def parseArgs(self,kwargs):
        #Provide help menu and Parse any command line arg
        p=pyu_parser.PYUParser("[Description]","[Epilog]")
        parser=p.parser


        kw=p.parse_args(kwargs)

        return kw


