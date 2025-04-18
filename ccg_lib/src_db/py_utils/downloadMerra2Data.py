#!/usr/bin/env python3
"""Template for python3 scripts
"""

import os
import sys
import datetime
import argparse
import requests


if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')
import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_file_ops as pyu_file
import py_utils.pyu_util_functions as uf
import urllib.parse as parse

#Function that can be called from main/call class obj
def downloadMerra2Data (kwargs): #Change Name here and main call at bottom
    #Create obj that will do work
    f=DownloadMerra2Data(kwargs)


# overriding requests.Session.rebuild_auth to mantain headers when redirected (https://wiki.earthdata.nasa.gov/display/EL/How+To+Access+Data+With+Python)
class SessionWithHeaderRedirection(requests.Session):
    AUTH_HOST = 'urs.earthdata.nasa.gov'
    def __init__(self, username, password):
        super().__init__()
        self.auth = (username, password)

   # Overrides from the library to keep headers when redirected to or from
   # the NASA auth host.
    def rebuild_auth(self, prepared_request, response):
        headers = prepared_request.headers
        url = prepared_request.url

        if 'Authorization' in headers:
            original_parsed = requests.utils.urlparse(response.request.url)
            redirect_parsed = requests.utils.urlparse(url)

            if (original_parsed.hostname != redirect_parsed.hostname) and \
                    redirect_parsed.hostname != self.AUTH_HOST and \
                    original_parsed.hostname != self.AUTH_HOST:
                del headers['Authorization']
        return

class DownloadMerra2Data(uf.PYUUtilFunctions) :#Change ClassName
    def __init__(self, kwargs):
        super(DownloadMerra2Data, self).__init__()#Change ClassName to match above

        #Make ro connection to db with local handle, readonly except for tmp db
        #self.db=db_conn.RO()

        #Parse any arguements
        self.args=self.parse_args(kwargs)
        self.verbose=self.args['verbose']

        #Use account created by john mund (10/19).  This may need to be updated...
        self.user="john.mund"
        self.password="rurhi4-qefzUb-difmux"
        self.destDir="/model/merra2/Nv"

        #action parameters
        subset=self.args["subset"];
        month=self.args["month"]
        url=self.args['url']
        file=self.args['file']

        #download appropriate ones.
        if(month): self.downloadMonth(month,subset,url)
        elif(file): self.downloadFiles(file)
        else : print("Must pass yearmonth or file of urls.")


    def downloadMonth(self,yearmon,subset,url):
        #Downloads all files in the passed month of subset
        y=str(yearmon)[0:4]
        m=str(yearmon)[4:6]
        url = url+"/"+subset+"/"+y+"/"+m
        pattern="MERRA2" #Hopefully specific enough

        #use wget to fetch the link list
        cmd="wget -q -nH -nd \"%s\" -O - | grep %s | cut -f4 -d%s"%(url,pattern,'\\"')
        from subprocess import Popen, PIPE,check_output
        #cmd='ls'
        #p = Popen(cmd, stdout=PIPE)
        #print(p.stdout.read())
        l=check_output(cmd,shell=True, text=True)
        l=l.split("\n")
        for file in l:
            if file.endswith(".") or file.endswith("/") : continue
            #download it.
            self.downloadFile(url+"/"+file,file,y,m)



    def downloadFiles(self,file):
        #Download all file urls in file.  see help for file desc
        with open(file) as f:
            content = f.readlines()

        content = [x.strip() for x in content]#strip \n

        for file in content:
            if file=='': continue
            if self.verbose :print(("Processing: "+file))
            if not(file.startswith("https")):
                print("File contents incorrect.  See help")
                sys.exit()

            #Parse out the file, month, year from the url
            qs=parse.parse_qs(parse.urlsplit(file).query)
            f=qs['FILENAME']
            t=f[0].split("/")
            #make some assumptions about file name structure
            # https://goldsmr5.gesdisc.eosdis.nasa.gov/daac-bin/OTF/HTTP_services.cgi?FILENAME=%2Fdata%2FMERRA2%2FM2I3NPASM.5.12.4%2F2015%2F01%2FMERRA2_400.inst3_3d_asm_Np.20150101.nc4&FORMAT=nc4%2F&BBOX=-90%2C-180%2C90%2C180&LABEL=MERRA2_400.inst3_3d_asm_Np.20150101.SUB.nc&SHORTNAME=M2I3NPASM&SERVICE=SUBSET_MERRA2&VERSION=1.02&LAYERS=&VARIABLES=
            #filename is (currently) ..../year/month/filename
            filename=t.pop()
            month=t.pop()
            year=t.pop()

            self.downloadFile(file,filename,year,month)


    def downloadFile(self, url,filename,year,month):
        session=SessionWithHeaderRedirection(self.user,self.password)


        try:#Attempt to validate the expected year/month
            if(int(year)<1950 or int(year)>2200 or int(month)<1 or int(month)>12):
                print(("Invalid year("+str(year)+") month("+str(month)+") for directory path.  Unknown file format."))
                sys.exit();
        except:
            print(("Invalid year("+str(year)+") month("+str(month)+") for directory path.  Unknown file format."))
            sys.exit();

        ddir=self.destDir+"/"+year+"/"+month
        #Create if needed.
        if(not(os.path.exists(ddir))):
            try:
                os.makedirs(ddir,777 )

            except Exception as e:
                print(("Couldn't create directory:"+ddir))
                print(e)
            try:
                #attempt to reset perms if os didn't let us set with above.
                os.system("chmod 777 "+self.destDir+"/"+year)
                os.system("chmod 777 "+ddir)
            except:
                print("unable to set file permissions completely")


        fullName=ddir+"/"+filename

        if os.path.isfile(fullName) and os.path.getsize(fullName)>0:
            if self.args['overwrite'] : os.remove(fullName)
            else :
                print((filename+" exists, skipping.  Pass -o to overwrite"))
                return 1
        try:
            print(("Attempting download of:"+fullName))

            #submit request
            response=session.get(url,stream=True)
            print((response.status_code))

            #error?
            response.raise_for_status()

            #save file
            with open(fullName, 'wb') as fd:
                for chunk in response.iter_content(chunk_size=1024*1024):
                    fd.write(chunk)

        except requests.exceptions.HTTPError as e:
            print(e)
            os.remove(file)
        except Exception as e:
            print(e)



    def logit(self,txt):
        logfile=pyu_file.PYUFile(['/tmp/test.txt'])
        logfile.log(txt,self.verbose) #Log to file and output to screen if verbose.

    def parse_args(self,kwargs):
        #Provide help menu and Parse any command line arg
        epi="""
            ex: download all files listed in subset file list created from https://disc.gsfc.nasa.gov/daac-bin/FTPSubset2.pl
            /ccg/src/db/py_utils/downloadMerra2Data.py -f=wget_Ct_ws8Th.txt

            ex: download all files for month of 20150601 in default subset ("M2I3NVASM.5.12.4") from default url ("https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/")
            /ccg/src/db/py_utils/downloadMerra2Data.py -m=201506

            """
        p=pyu_parser.PYUParser("Downloads merra2 files to /model/merra2/Nv",epi)
        parser=p.parser

        parser.add_argument("-o","--overwrite",action='store_true',help="Overwrite any files that current exist")
        parser.add_argument('-f','--file',default='',help="File with a list of urls to download.  Goto here: https://disc.gsfc.nasa.gov/daac-bin/FTPSubset2.pl, submit search then click the 'Save the list of URLS' link under curl example to create an appropriate file.")
        parser.add_argument("-s","--subset",default="M2I3NVASM.5.12.4", help="Merra2 subset options to download.  Default M2I3NVASM.5.12.4   See https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/ for list")
        parser.add_argument("-m","--month",type=int,default='0',help='Format: yyyymm.  If passed, downloads all month files from --subset directory of --url')
        parser.add_argument("-u","--url",default="https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/",help="url to download subset/yyyy/mm data from when passing a month.  Default: https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2/")


        kw=p.parse_args(kwargs)

        return kw

# main body if called as script

if __name__ == "__main__":

    t=list(sys.argv[1:])#Make a copy of the command line arguments so we can append a little meta info to it

    #add help if no arguments were passed.
    if(len(t)==0):t.append("--help");

    #t.append("--callsrc=cmdline")#If needed

    r = downloadMerra2Data(t)#call the wrapper function

    sys.exit( 0 )
