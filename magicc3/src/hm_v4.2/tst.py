
import os
import time

path = "zzz"
fd = os.open(path, os.O_CREAT | os.O_WRONLY, 0o666)

time.sleep(1)

os.close(fd)
os.close(fd)
