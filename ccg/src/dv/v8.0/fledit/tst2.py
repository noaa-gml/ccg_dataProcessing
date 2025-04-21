
import ccg_dbutils

db = ccg_dbutils.dbUtils(readonly=False)

datanum =  10331395

taglist = db.getFlaskDataTagList(datanum)
appliedtaglist = db.getFlaskDataTags(datanum)

#print(taglist)
print(appliedtaglist)
