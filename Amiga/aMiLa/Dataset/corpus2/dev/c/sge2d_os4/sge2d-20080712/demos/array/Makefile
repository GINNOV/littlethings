PROJECTNAME=array

include ../../setup.project
include ../../setup.$(PLATFORM)

TARGET=$(PROJECTNAME)$(EXEC)

OBJ=main.o

CFLAGS=-Wall -I../../include $(SDLCFLAGS)
LDFLAGS=$(SDLLDFLAGS)

%.o:%.c
	$(CC) -o $@ $(CFLAGS) -c $<

all:$(OBJ)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJ) ../../libsge.a $(STATICLIBS)

clean:
	rm -f stdout.txt stderr.txt
	rm -f $(OBJ)
	rm -f $(TARGET)
