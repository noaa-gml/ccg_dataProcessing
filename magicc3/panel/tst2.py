#!/usr/bin/python


from datetime import datetime

now = datetime.utcnow()
print(now)


date = now.strftime("%a %b %d %H:%M:%S %Z %Y")
print(date)

date = now.strftime("%c")
print(date)
