# 
# Target OS : Amiga OS3.X
# Compiler  : GCC
# Author	: emarti, Murat Ozdemir
#
	
objects = alert.o
appname = alert
option  = -O3 -m68020
#libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

alert:	$(objects)
	gcc -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
alert.o:	alert.c
	gcc -c alert.c $(option)
	
clean:
	rm $(objects) $(appname)
	