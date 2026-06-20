
target: /UReader\
        /UReaderTTEngine

#CFLAGS=parms=register
#COPTAS=opt nostackcheck optpeep optgo optinline optloop opttime
#CSTARTUP=lib:cres.o

CFLAGS=
COPTAS=
CSTARTUP=lib:c.o

UReader.o: UReader.c
  sc $(CFLAGS) $(COPTAS) OBJNAME UReader.o UReader.c

UReaderTTEngine.o: UReader.c
  sc $(CFLAGS) $(COPTAS) DEFINE UREADER_TTENGINE=1 VERBOSE OBJNAME UReaderTTEngine.o UReader.c

pointers.o: pointers.c
  sc $(CFLAGS) $(COPTAS) OBJNAME pointers.o pointers.c

/UReader: UReader.o pointers.o
  slink $(CSTARTUP),UReader.o,pointers.o\
  TO /UReader\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

/UReaderTTEngine: UReaderTTEngine.o pointers.o
  slink $(CSTARTUP),UReaderTTEngine.o,pointers.o\
  TO /UReaderTTEngine\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE
