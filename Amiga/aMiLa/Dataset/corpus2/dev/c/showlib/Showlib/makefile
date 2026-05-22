target: ShowLib

showlib.o: showlib.c
  sc opt optpeep optgo optinline optloop opttime OBJNAME showlib.o showlib.c

parsefd.o: parsefd.c
  sc opt optpeep optgo optinline optloop opttime OBJNAME parsefd.o parsefd.c

Showlib: showlib.o parsefd.o
  slink lib:c.o,showlib.o,parsefd.o\
  TO Showlib\
  LIB lib:sc.lib\
  VERBOSE


