# 
# Target OS : Amiga OS3.X
# Compiler  : GCC
# Author	: emarti, Murat Ozdemir
#
	
objects = window.o
appname = window
option  = -O3 -m68020
#libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

window:	$(objects)
	gcc -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
window.o:	window.c
	gcc -c window.c $(option)
	
clean:
	rm $(objects) $(appname)
	