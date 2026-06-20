CC      = lc
CFLAGS  = -v
LD      = blink
LDFLAGS = 
LIBS    = lib:lc.lib lib:amiga.lib
AFLAGS  = -iinclude:
ASM     = asm
OBJS    = giraffe.library.o draw.o ellipse.o regions.o \
          layers.o clip.o arrange.o font.o stack.o driver.o

giraffe.library: $(OBJS) giraffe_rev.h giraffe.c
##	revco giraffe COMPILATION
	$(CC) $(CFLAGS) giraffe
	$(LD) $(OBJS) giraffe.o TO giraffe.library LIB $(LIBS)
##	copy giraffe.library /libs
##	copy giraffe.library libs:

giraffe.library.o: giraffe.library.asm
	$(ASM) $(AFLAGS) giraffe.library.asm

##
## The individual components
## of the giraffe library.
##
## Everything is compiled without stack
## correction.  All the stub functions for
## loading the stack reside in giraffe.library.asm

draw.o: draw.c driver.c driver.h common.h
	$(CC) $(CFLAGS) draw
ellipse.o: ellipse.c common.h
	$(CC) $(CFLAGS) ellipse
regions.o: regions.c common.h
	$(CC) $(CFLAGS) regions
clip.o: clip.c common.h
	$(CC) $(CFLAGS) clip
layers.o: layers.c layers.h common.h
	$(CC) $(CFLAGS) layers
arrange.o: arrange.c layers.h common.h
	$(CC) $(CFLAGS) arrange
font.o: font.c common.h
	$(CC) $(CFLAGS) font
stack.o: stack.c common.h
	$(CC) $(CFLAGS) stack
driver.o: driver.c common.h
	$(CC) $(CFLAGS) driver

##
## For updating the lattice 
## pragmas.
giraffe_pragmas.h: giraffe.fd
	fd2pragma giraffe.fd giraffe_pragmas.h
	copy giraffe_pragmas.h include:
	copy giraffe_pragmas.h /include


