# 
# Target OS : Amiga OS3.X
# Compiler  : GCC
# Author	: emarti, Murat Ozdemir
#
	
objects = screendata.o
appname = screendata
option  = -O3 -m68020
#libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

screendata:	$(objects)
	gcc -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
screendata.o:	screendata.c
	gcc -c screendata.c $(option)
	
clean:
	rm $(objects) $(appname)
	