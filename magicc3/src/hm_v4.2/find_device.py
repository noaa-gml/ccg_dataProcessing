import pyvisa
import datetime

#rm = pyvisa.ResourceManager('/opt/keysight/iolibs/libktvisa32.so')
t0 = datetime.datetime.now()
rm = pyvisa.ResourceManager()
t1 = datetime.datetime.now()
print("time to get rm", t1-t0)

t0 = datetime.datetime.now()
print(rm.list_resources())
t1 = datetime.datetime.now()
print("time to list resources", t1-t0)
#print(rm.list_resources_info())

print(rm)

#s = rm.open_resource('ASRL/dev/ttyUSB8::INSTR')
#s = rm.open_resource('USB0::0x2A8D::0x5101::MY58018232::0::INSTR')

