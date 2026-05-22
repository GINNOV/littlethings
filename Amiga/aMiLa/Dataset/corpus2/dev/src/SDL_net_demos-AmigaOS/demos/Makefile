CFLAGS=-g -O2 -Wall $(shell sdl-config --cflags)
LDFLAGS=-g -O2 -Wall 
LDLIBS=$(shell sdl-config --libs) -lSDL_net

PROGRAMS=$(basename $(wildcard *.c))

all: $(PROGRAMS)

clean:
	rm -f $(PROGRAMS) *.o

new: clean all

tcpmulticlient.o: tcputil.h
tcpmultiserver.o: tcputil.h

tcptimesyncclient.o: tcptimesync.h
tcptimesyncserver.o: tcptimesync.h
