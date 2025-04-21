
import cPickle

class aa:

    def __init__(self):

	self.a = 1
	self.b = 2
	self.c = 3
	self.d = 4

class bb:

    def __init__(self):

	self.a = 5
	self.b = 6
	self.c = 7
	self.d = 8


A = aa()
B = bb()

print A
print A.a
print B.d

filename = "zzz.dat"
file = open(filename,'wb')
cPickle.dump(A, file)
cPickle.dump(B, file)
file.close()

f = open(filename,'rb')
C = cPickle.load(f)
D = cPickle.load(f)
file.close()


print C.__dict__
print D.__dict__
print C.a
print D.d
