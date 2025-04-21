#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Python Utility Class to wrap common argument parser functions"""

import os
import sys

import datetime
import argparse


class PYUParser(object):
    """Python Utilities Command Line/function call parser wrapper for argparse.
        This is just a simple wrapper for argparse to document calls needed and to set results into a kw dict.
        p=PYUParser("my description","My epilog")
    You still need to add arguements
        parser=p.parser
        #required arg
        parser.add_argument('requiredOption')
	parser.add_argument('-p','--parameter',choices=["co2c13","co2c18"],help='Measured parameter',required='True')
  
        #optional arg
        parser.add_argument('-o','--optionalArg',default='asdf', help="help text")
        #choices
        parser.add_argument('-m','--merge','--m',default=0,choices=(0,1,2), type=int,help="Merge multiple parameters onto 1 line and average mulitple aliquots of same parameter for a sample.  0-> no merge (default), 1-> merge multiple parameters onto 1 line and average multiple aliquots, 2-> same, but with flag and expanded date cols.")
        #levels of verbosity (this one is actually included by default below, but the count construct is a useful example)
        parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
        #true false (default false)
        parser.add_argument("--exclusion",action='store_true',help="If passed, excluded data is removed from output")
        #add group
        evgrp=parser.add_argument_group("Sample Event Filters")
        evgrp.add_argument("-e",'--event_num',help="One or more (comma separated) event numbers");
        
        #Parse into kw dict
        #kwargs can either be a dictionary (when called from code) or a list (sys.argv from command line callers)
        kw=p.parse_args(kwargs)
        
        #or
        kwargs={'-o':'asdf', '--merge':2}
        kw=p.parse_args(kwargs)
        return kw
    """
    
    def __init__(self, description='',epilog='',formatter_class=argparse.RawTextHelpFormatter):
        super(PYUParser, self).__init__()
        self.args={}
        self.parser=argparse.ArgumentParser(description=description,epilog=epilog,formatter_class=formatter_class)
        self.parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
    
    def parse_args( self, kwargs ):
        """Common parsing logic for python code and command line callers.
            kwargs can either be a dictionary (when called from code) or a list (sys.argv from command line callers)
        """
        self.args={} #Reset each call for re-use.        
        t=list()
        
        #If a dict, turn it into a list like sys.argv so we can use the common parsing logic.
        if isinstance(kwargs,dict):
            for n,v in kwargs.items():
                #if n.startswith("-") : t.append(n) #if it already starts with a -, just pass through.
                #else : t.append("--"+n) #prepend with the '--option' syntax for the argparser below.
                t.append(n)
                t.append(v) #Followed by the value (may be blank for flag types)
        else : t=kwargs
        
        #add help if no arguments were passed.
        if(len(t)==0):t.append("--help");

        #Pass through the parser
        opts = self.parser.parse_args(t)
        
        #Create a keyword dictionary of the results
        keyw = {}
        keyw=vars(opts);
        return keyw
    
