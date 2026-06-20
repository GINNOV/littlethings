CC = g++
LD = g++
CFLAGS = `sdl-config --cflags` 
LDFLAGS = `sdl-config --libs` -lSDL_image
RM   = /bin/rm -f
OBJS = mouse_tile.o 
PROG = mouse_tile
VERS = 0.1.0

.PHONY: clean distclean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
mouse_tile.o: mouse_tile.cpp
	$(CC) $(CFLAGS) -O2 -c mouse_tile.cpp
clean:
	$(RM) *~ $(OBJS) $(PROG)
.PHONY: clean
