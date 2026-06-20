CC = g++
LD = g++
CFLAGS = `sdl-config --cflags` -Wall 
LDFLAGS = `sdl-config --libs` -lSDL_image
RM   = /bin/rm -f
OBJS = iso_mouse.o 
PROG = iso_mouse
VERS = 0.1.0

.PHONY: clean distclean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
iso_mouse.o: iso_mouse.cpp
	$(CC) $(CFLAGS) -O2 -c iso_mouse.cpp 
clean:
	$(RM) *~ $(OBJS) $(PROG)
.PHONY: clean
