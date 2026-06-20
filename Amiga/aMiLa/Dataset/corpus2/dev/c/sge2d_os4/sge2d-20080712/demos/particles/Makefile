PROJECTNAME=particles

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

data: datafiles
datafiles:
	rm -rf ./data.d
	../../tools/sga asdf ./data.d cloud.png
