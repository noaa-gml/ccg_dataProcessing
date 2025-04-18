#CC = g77
#CC = gfortran
CC = f95

#WORKDIR = /home/ccg/ken/idllib/linux/ccglib/src/
WORKDIR = /ccg/idl/lib/ccglib/src/

INCL = -L $(WORKDIR)loess/src/support
LIB = -lsupport -lm

OBJ = loess.o predict.o misc.o loessf.o loessc.o 

gas: gas.x
	./gas.x
gas.x:	gas.o $(OBJ)
	$(CC) -ogas.x gas.o $(OBJ) $(INCL) $(LIB)

madeup: madeup.x
	./madeup.x
madeup.x: madeup.o $(OBJ)
	$(CC) -o madeup.x madeup.o $(OBJ) $(INCL) $(LIB)

ethanol: ethanol.x
	./ethanol.x
ethanol.x: ethanol.o $(OBJ)
	$(CC) -o ethanol.x ethanol.o $(OBJ) $(INCL) $(LIB)

air: air.x
	./air.x
air.x: air.o $(OBJ)
	$(CC) -o air.x air.o $(OBJ) $(INCL) $(LIB)

galaxy: galaxy.x
	./galaxy.x
galaxy.x: galaxy.o $(OBJ)
	$(CC) -o galaxy.x galaxy.o $(OBJ) $(INCL) $(LIB)

clean:
	rm -f *.o *.x core
