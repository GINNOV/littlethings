# 
# Target OS : Amiga OS3.X
# Compiler  : GCC
# Author	: emarti, Murat Ozdemir
#
	
objects = data2raw.o
appname = data2raw
option  = -O3 -m68020
libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

data2raw:	$(objects)
	gcc -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
data2raw.o:	data2raw.c amigafuria.h
	gcc -c data2raw.c $(option)
	
clean:
	rm $(objects) $(appname)
	