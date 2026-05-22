
target: /bin/usbprint /bin/ieee1284.device /bin/RasterDump /bin/DirectDump

CFLAGS=parms=register
COPTS=nostackcheck optpeep optgo optinline optloop opttime

obj/usbprint.o: usbprint.c v31lib.h
  sc $(CFLAGS) $(COPTS) OBJNAME obj/usbprint.o usbprint.c

obj/devent.o: devent.asm
  asm -u -iasminclude: -oobj/devent.o devent.asm

obj/ieee1284.o: ieee1284.c v31lib.h
  sc $(CFLAGS) $(COPTS) OBJNAME obj/ieee1284.o ieee1284.c  

obj/rasterdump.o: rasterdump.c
  sc $(CFLAGS) $(COPTS) OBJNAME obj/rasterdump.o rasterdump.c

obj/gui.o: gui.c gui.h
  sc $(CFLAGS) $(COPTS) OBJNAME obj/gui.o gui.c

obj/image.o: image.c image.h
  sc $(CFLAGS) $(COPTS) OBJNAME obj/image.o image.c

obj/directdump.o: directdump.c image.h
  sc $(CFLAGS) $(COPTS) OBJNAME obj/directdump.o directdump.c

/bin/usbprint: obj/usbprint.o
  slink lib:c.o,obj/usbprint.o\
  TO /bin/usbprint\
  LIB lib:sc.lib\
  VERBOSE NOICONS

/bin/ieee1284.device: obj/devent.o obj/ieee1284.o
  slink obj/devent.o,obj/ieee1284.o\
  TO /bin/ieee1284.device\
  LIB lib:sc.lib\
  VERBOSE NOICONS

/bin/RasterDump: obj/rasterdump.o obj/gui.o
  slink lib:c.o,obj/rasterdump.o,obj/gui.o\
  TO /bin/RasterDump\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE NOICONS
  copy icons/RasterDump.info /bin/RasterDump.info CLONE

/bin/DirectDump: obj/directdump.o obj/image.o obj/gui.o
  slink lib:c.o,obj/directdump.o,obj/image.o,obj/gui.o\
  TO /bin/DirectDump\
  LIB lib:sc.lib,lib:scm.lib,lib:amiga.lib\
  VERBOSE NOICONS
  copy icons/DirectDump.info /bin/DirectDump.info CLONE
