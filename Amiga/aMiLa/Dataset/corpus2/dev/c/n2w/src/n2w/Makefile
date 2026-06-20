
CC = gcc
CFLAGS = -Wall -pedantic -g -O2
LDFLAGS = -Wall -pedantic -g -O2

GETOPT_SRC = getopt1.c getopt.c getopt.h
GETOPT_OBJ = getopt1.o getopt.o

n2w		  : n2w.o n2w-main.o $(GETOPT_OBJ)
	$(CC) $(LDFLAGS) -o n2w n2w.o n2w-main.o $(GETOPT_OBJ) -lm

n2w.o		  : n2w.c n2w.h

n2w-main.o	  : n2w-main.c n2w.h

getopt1.o	  : getopt1.c getopt.h

getopt.o	  : getopt.c getopt.h
