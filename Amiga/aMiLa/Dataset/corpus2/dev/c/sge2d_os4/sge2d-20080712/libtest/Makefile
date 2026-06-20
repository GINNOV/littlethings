include ../setup.project
include ../setup.$(PLATFORM)

TARGET=libtest$(EXEC)

OBJ=main.o

CFLAGS=-Wall -I../include $(SDLCFLAGS)
LDFLAGS=$(SDLLDFLAGS)

.c.o:
	$(CC) -o $@ $(CFLAGS) -c $<

all:$(OBJ)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJ) ../libsge.a $(STATICLIBS)

testdata:
	rm -rf ./data.d
	../tools/sga$(EXEC) asdf ./data.d data/*.*

clean:
	rm -f stdout.txt stderr.txt
	rm -f $(OBJ)
	rm -f $(TARGET)
