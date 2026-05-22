############################################################
#
#  MAKEFILE for "Guru's Guide" Interrupt Examples
#
#  Requires MANX AZTEC C 3.6A, or better.
#
############################################################

BASEDIR =	Work:Guru
DISKDIR =	DF0:GurusGuide
BACKDIR =	$(BASEDIR)/Examples
CLIBDIR =	:lib

############################################################

PRGS=	intrmon simple simpler tasksig audio cia swi swimsg copper serial

LIBS =		-lc32

COPTS  = 	-II:
CFLAGS = 	+L $(COPTS)
LFLAGS =	+Q

############################################################

all:		$(PRGS)

intrmon:	intrmon.o
		ln $(LFLAGS) intrmon.o $(LIBS)

simple:		simple.o
		ln $(LFLAGS) simple.o $(LIBS)

simpler:	simpler.o intrsup.o
		ln $(LFLAGS) simpler.o intrsup.o $(LIBS)

tasksig:	tasksig.o intrsup.o
		ln $(LFLAGS) tasksig.o intrsup.o $(LIBS)

audio:		audio.o intrsup.o
		ln $(LFLAGS) audio.o intrsup.o $(LIBS)

cia:		cia.o intrsup.o
		ln $(LFLAGS) cia.o intrsup.o $(LIBS)

swi:		swi.o intrsup.o
		ln $(LFLAGS) swi.o intrsup.o $(LIBS)

swimsg:		swimsg.o intrsup.o
		ln $(LFLAGS) swimsg.o intrsup.o $(LIBS)

copper:		copper.o intrsup.o
		ln $(LFLAGS) copper.o intrsup.o $(LIBS)

serial:		serial.o intrsup.o
		ln $(LFLAGS) serial.o intrsup.o $(LIBS)


############################################################

clean:
		rm #?.o
		rm #?.pre

back:
		cp #? $(BACKDIR)
		date to BACK_BACK

disk:
		cp #? $(DISKDIR)
		date to BACK_DISK

newdisk:
		makedir $(DISKDIR)
		make disk
