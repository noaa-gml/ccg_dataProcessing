LIB=linpack
FFLAGS=-O
OBJ = \
	dchdc.o	\
	dchdd.o	\
	dchex.o	\
	dchud.o	\
	dgbco.o	\
	dgbdi.o	\
	dgbfa.o	\
	dgbsl.o	\
	dgeco.o	\
	dgedi.o	\
	dgefa.o	\
	dgesl.o	\
	dgtsl.o	\
	dmach.o	\
	dpbco.o	\
	dpbdi.o	\
	dpbfa.o	\
	dpbsl.o	\
	dpoco.o	\
	dpodi.o	\
	dpofa.o	\
	dposl.o	\
	dppco.o	\
	dppdi.o	\
	dppfa.o	\
	dppsl.o	\
	dptsl.o	\
	dqrdc.o	\
	dqrsl.o	\
	dsico.o	\
	dsidi.o	\
	dsifa.o	\
	dsisl.o	\
	dspco.o	\
	dspdi.o	\
	dspfa.o	\
	dspsl.o	\
	dsvdc.o	\
	dtrco.o	\
	dtrdi.o	\
	dtrsl.o

lib$(LIB).a:	$(OBJ)
	ar ru lib$(LIB).a $?
	ranlib lib$(LIB).a

install:	lib$(LIB).a
	ln -s /netlib/netlib/linpack/lib$(LIB).a /usr/local/lib
	rm *.o
