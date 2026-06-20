# 
# Target OS: Amiga OS3.X
# Compiler : GCC
# Date: 22-01-2017
#
	
appname = Project

objects = main.o
src	= main.c
option  = -O3 -m68020
#libs 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer
#CC	= m68k-amigaos-gcc
CC	= gcc

Project:	$(objects)
	$(CC) -o $(appname) $(objects) $(option) $(libs) $(RZFLAGS)
	
main.o:	main.c
	$(CC) -c $(src) $(option) $(RZFLAGS)
	
clean:
	rm $(objects) $(appname)
