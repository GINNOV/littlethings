CC = gcc
LD = gcc
CFLAGS = `sdl-config --cflags` 
LDFLAGS = `sdl-config --libs` -lSDL_mixer
RM   = /bin/rm -f
OBJS = mix.o
PROG = mix

.PHONY: clean
all: $(PROG)
$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -s -o $(PROG) $(OBJS)
mix.o: mix.c
	$(CC) $(CFLAGS) -c mix.c
clean:
	$(RM) *~ $(OBJS) $(PROG)
