include ../setup.project
include ../setup.$(PLATFORM)

TARGET=sga$(EXEC)

OBJ=sga.o

CFLAGS=-Wall -I../include $(SDLCFLAGS)
LDFLAGS=$(SDLLDFLAGS)

.c.o:
	$(CC) -o $@ $(CFLAGS) -c $<

all:$(OBJ)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJ) ../libsge.a $(STATICLIBS)

test:
	rm -f ./test.db
	$(TARGET) secretkey ./test.db sga.c sga.o

clean:
	rm -rf stdout.txt stderr.txt
	rm -f ./test.db
	rm -f $(OBJ)
	rm -f $(TARGET)
