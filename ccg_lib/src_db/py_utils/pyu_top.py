#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Python Utility Class to output memory information.
python 3+ only.
"""
#To use:
#if('/ccg/src/db/py_utils' not in sys.path):sys.path.append("/ccg/src/db/py_utils")
#top=pyu_top.PYUTop()
#top.start()
#top.stop()


import os
import sys

import datetime
#import time
import resource
import tracemalloc
import linecache


class PYUTop(object):
    """Python Utility Class to output memory information.
    
    
    """
    def __init__(self):
        super(PYUTop, self).__init__()   
        #self.start=time.clock
        
    def start(self):
        tracemalloc.start()
        #self.start=time.clock
        
    def stop(self):
        snapshot = tracemalloc.take_snapshot()
        self._display_top(snapshot)
        #print(time.clock()-self.start, "seconds")
        
    def _display_top(self,snapshot, key_type='lineno', limit=5):
        snapshot = snapshot.filter_traces((
            tracemalloc.Filter(False, "<frozen importlib._bootstrap>"),
            tracemalloc.Filter(False, "<unknown>"),
        ))
        top_stats = snapshot.statistics(key_type)
    
        print(("Top %s lines" % limit))
        for index, stat in enumerate(top_stats[:limit], 1):
            frame = stat.traceback[0]
            # replace "/path/to/module/file.py" with "module/file.py"
            filename = os.sep.join(frame.filename.split(os.sep)[-2:])
            print(("#%s: %s:%s: %.1f KiB"
                  % (index, filename, frame.lineno, stat.size / 1024)))
            line = linecache.getline(frame.filename, frame.lineno).strip()
            if line:
                print(('    %s' % line))
    
        other = top_stats[limit:]
        if other:
            size = sum(stat.size for stat in other)
            print(("%s other: %.1f KiB" % (len(other), size / 1024)))
        total = sum(stat.size for stat in top_stats)
        print(("Total allocated size: %.1f KiB" % (total / 1024)))



    def using(point=""):#THIS one doesn't really work.
        usage=resource.getrusage(resource.RUSAGE_SELF)
        return '''%s: usertime=%s systime=%s mem=%s mb
               '''%(point,usage[0],usage[1],
                    (usage[2])/1024.0 )

