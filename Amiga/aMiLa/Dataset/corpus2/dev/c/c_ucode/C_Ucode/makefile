
target: Demo01\
        Demo02\
        Demo03\
        Demo04\
        Demo05\
        Babylone

Demo01.o: Demo01.c
  sc OBJNAME Demo01.o Demo01.c

Demo02.o: Demo02.c
  sc OBJNAME Demo02.o Demo02.c

Demo03.o: Demo03.c
  sc OBJNAME Demo03.o Demo03.c

Demo04.o: Demo04.c
  sc OBJNAME Demo04.o Demo04.c

Demo05.o: Demo05.c
  sc OBJNAME Demo05.o Demo05.c

Babylone.o: Babylone.c
  sc OBJNAME Babylone.o Babylone.c

Demo01: Demo01.o
  slink lib:c.o,Demo01.o\
  TO Demo01\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

Demo02: Demo02.o
  slink lib:c.o,Demo02.o\
  TO Demo02\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

Demo03: Demo03.o
  slink lib:c.o,Demo03.o\
  TO Demo03\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

Demo04: Demo04.o
  slink lib:c.o,Demo04.o\
  TO Demo04\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

Demo05: Demo05.o
  slink lib:c.o,Demo05.o\
  TO Demo05\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

Babylone: Babylone.o
  slink lib:c.o,Babylone.o\
  TO Babylone\
  LIB lib:sc.lib,lib:amiga.lib\
  VERBOSE

