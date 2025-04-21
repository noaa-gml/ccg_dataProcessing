CC = 		gcc -Wall
LIBS = 	
INCLUDES =	as_comm.h

all: as_start_unload as_finish_unload as_open_sample as_close_sample get_as_history term

as_start_unload:	as_start_unload.o as_comm.o 
	$(CC) as_start_unload.o as_comm.o $(LIBS) -o as_start_unload 

as_start_unload.o:	as_start_unload.c $(INCLUDES)
	$(CC) -c as_start_unload.c 


as_finish_unload:	as_finish_unload.o as_comm.o 
	$(CC) as_finish_unload.o as_comm.o $(LIBS) -o as_finish_unload 

as_finish_unload.o:	as_finish_unload.c $(INCLUDES)
	$(CC) -c as_finish_unload.c 


as_open_sample:	as_open_sample.o as_comm.o 
	$(CC) as_open_sample.o as_comm.o $(LIBS) -o as_open_sample 

as_open_sample.o:	as_open_sample.c $(INCLUDES)
	$(CC) -c as_open_sample.c 


as_close_sample:	as_close_sample.o as_comm.o 
	$(CC) as_close_sample.o as_comm.o $(LIBS) -o as_close_sample 

as_close_sample.o:	as_close_sample.c $(INCLUDES)
	$(CC) -c as_close_sample.c 


get_as_history:	get_as_history.o as_comm.o 
	$(CC) get_as_history.o as_comm.o $(LIBS) -o get_as_history 

get_as_history.o:	get_as_history.c $(INCLUDES)
	$(CC) -c get_as_history.c 

term: term.o
	$(CC) term.o -o term

term.o:
	$(CC) -c term.c


as_comm.o:	as_comm.c $(INCLUDES)
	$(CC) -c as_comm.c
