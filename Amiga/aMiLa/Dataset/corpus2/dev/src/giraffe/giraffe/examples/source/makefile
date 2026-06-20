LIBS = lib:lc.lib lib:amiga.lib
LD   = blink
CC   = lc
MAKE = lmk

##
##  The examples are compiled
## recursively.
examples:
	${MAKE} example1
	${MAKE} example2
	${MAKE} example3
	${MAKE} example4
	${MAKE} example5


##
## suffix rules
.c.o:
	${CC} $*.c
	${LD} lib:c.o $*.o LIB ${LIBS}
	copy $* /bin

##
##  There are a total of
## five examples to check.
example1: example1.o
example2: example2.o
example3: example3.o
example4: example4.o
example5: example5.o

