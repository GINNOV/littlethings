target: wget

wget.o: wget.c
  sc INCLUDEDIR=NETINCLUDE: OBJNAME=wget.o wget.c

wget: wget.o
  slink LIB:c.o,wget.o TO wget LIB LIB:sc.lib NOICONS