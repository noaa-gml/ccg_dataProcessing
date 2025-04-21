

import sys

sys.path.append("/ccg/src/python3/lib")
import ccg_db

db, c = ccg_db.dbConnect("ccgg")

datanum =  9741117
args = [datanum]
c.callproc('tagwr_getFlaskDataTagList', args)

print(c.fetchall())
