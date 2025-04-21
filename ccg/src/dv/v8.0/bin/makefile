# make command file for gcplot

CC = gcc

CFLAGS = -Wall

LIBS = -lgc -lm

INCLUDEDIR = -Iintegrator

LIBDIR = -Lintegrator

all: gcdata

gcdata: gcdata.o
	gcc gcdata.o $(LIBDIR) $(LIBS) -o gcdata

gcdata.o: gcdata.c
	gcc -c -O $(CFLAGS) $(INCLUDEDIR) $*.c -o $@

clean:
	rm -f gcdata
