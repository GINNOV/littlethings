# 
# Target OS : Amiga OS3.X
# Compiler  : GCC
# Author	: emarti, Murat Ozdemir
#
	
objects = screen.o
appname = screen
option  = -O3 -m68020
#libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

screen:	$(objects)
	gcc -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
screen.o:	screen.c a600.h
	gcc -c screen.c $(option)
	
clean:
	rm $(objects) $(appname)
	