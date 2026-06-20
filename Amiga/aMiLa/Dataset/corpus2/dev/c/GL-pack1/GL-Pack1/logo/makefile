CC=gcc
CFLAGS=-DUSE_TINYGL -O2
LFLAGS=-noixemul
OBJS=opengl_logo.o def_logo.o


all: opengl_logo
 
opengl_logo: $(OBJS)
	$(CC) $(LFLAGS) -o $@ $(OBJS) -lTinyGL -lamiga -lm
	
opengl_logo.o: opengl_logo.c
	$(CC) $(CFLAGS) -c $<

def_logo.o: def_logo.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f *.o opengl_logo
