CC = 		gcc 
LIBS = 	
INCLUDES =	

all: get_pfp_history_v306j, get_pfp_datalog_v306j

get_pfp_history_v306j:	get_pfp_history_v306j.o  
	$(CC) get_pfp_history_v306j.o  $(LIBS) -o get_pfp_history_v306j 

get_pfp_history_v306j.o:	get_pfp_history_v306j.c 
	$(CC) -c get_pfp_history_v306j.c 

get_pfp_datalog_v306j:	get_pfp_datalog_v306j.o  
	$(CC) get_pfp_datalog_v306j.o  $(LIBS) -o get_pfp_datalog_v306j 

get_pfp_datalog_v306j.o:	get_pfp_datalog_v306j.c 
	$(CC) -c get_pfp_datalog_v306j.c 
