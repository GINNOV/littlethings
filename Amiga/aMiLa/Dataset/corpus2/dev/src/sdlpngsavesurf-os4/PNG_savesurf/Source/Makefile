CC = g++
LD = g++
CFLAGS = `sdl-config --cflags`
LDFLAGS = `sdl-config --libs` -lSDL_image -lpng
RM   = /bin/rm -f
OBJS = savesurf.o
PROG = savesurf

.PHONY: clean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
savesurf.o: savesurf.c
	$(CC) $(CFLAGS) -c savesurf.c
clean:
	$(RM) *~ $(OBJS) $(PROG)
