CXX = g++
LD = g++
CXXFLAGS = -Wall `sdl-config --cflags`
LDFLAGS = -O2 -s `sdl-config --libs`
RM   = /bin/rm -f
OBJS = main.o graphic.o grind.o pathfind.o
PROG = pathfind
VERS = 0.1.0

.PHONY: clean distclean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -o $(PROG) $(OBJS)
clean:
	$(RM) *~ $(OBJS) $(PROG)
.PHONY: clean
