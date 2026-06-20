#
# FuriatuneGUI by emarti
# Version  : 1.0 18032017
# Target OS: Amiga OS3.X
# Compiler : GCC
#

objects = togbutsampleMain.o
appname = togbutsampleMain

CFLAG = -O2 -m68000
LIBS 	= -mcrt=clib2
RZFLAGS = -fstrength-reduce -msmall-code -Wimplicit \
          -Wstrict-prototypes -s -Os -Wall -fomit-frame-pointer

togbutsampleMain:	$(objects)
	gcc -o $(appname) $(objects) $(CFLAG) $(LIBS) $(RZFLAGS)

togbutsampleMain.o:	togbutsampleMain.c
	gcc -c togbutsampleMain.c $(CFLAG) $(RZFLAGS)

clean:
	rm $(objects) $(appname)
