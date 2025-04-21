import os
import time

from lock_file import LockFile

lock_f = LockFile("zzz.pid")

pid = os.getpid()
s = str(pid).encode()
print(s)
time.sleep(10)

