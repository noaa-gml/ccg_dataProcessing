CC = gcc
CFLAGS = -Wall

all: as_send_and_read as_send

as_send_and_read: as_send_and_read.o as_comm.o
	${CC} ${CFLAGS} as_comm.o as_send_and_read.o -o as_send_and_read

as_send: as_send.o as_comm.o
	${CC} ${CFLAGS} as_comm.o as_send.o -o as_send

as_comm.o: as_comm.c
	${CC} ${CFLAGS} -c as_comm.c

as_send_and_read.o: as_send_and_read.c
	${CC} ${CFLAGS} -c as_send_and_read.c

as_send.o: as_send.c
	${CC} ${CFLAGS} -c as_send.c

clean:
	rm -rf *.o as_send_and_read as_send
