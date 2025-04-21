import pyvisa

#rm = pyvisa.ResourceManager('/opt/keysight/iolibs/libktvisa32.so')
rm = pyvisa.ResourceManager()

print(rm.list_resources())
#print(rm.list_resources_info())

print(rm)

#s = rm.open_resource('ASRL/dev/ttyUSB8::INSTR')
#s = rm.open_resource('USB0::0x2A8D::0x5101::MY58018232::0::INSTR')

