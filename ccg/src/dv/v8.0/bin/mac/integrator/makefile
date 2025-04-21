#
# libintegrator.a Makefile
#


CC = gcc -Wall
CFLAGS =  -O  
#-DDEBUG
#-Aa -D_HPUX_SOURCE


OBJS = 	gc.o gc_integrate.o gc_timefile.o gc_baselinefit.o gc_smooth.o gc_segments.o \
	gc_find.o gc_convert.o gc_resolve.o gc_area.o gc_id.o gc_utils.o gc_detrend.o

#LIB = /usr/local/lib/libintegrator.a
LIB = libgc.a

all:	lib

lib:	gc.h ${OBJS}
	-rm ${LIB}
	ar r ${LIB} ${OBJS}

test:   libgc.a
	cc $(CFLAGS) test.c -L ./ -lgc -lm

clean:
	rm -f *.o

