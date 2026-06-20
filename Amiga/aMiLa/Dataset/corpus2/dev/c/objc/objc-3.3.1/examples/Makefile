
#
# Portable Object Compiler
#

RM=rm -f

esql.o : esql.em
	objc -c esql.em

esql : esql.o
	objc -o esql esql.o

dynclass.o : dynclass.m
	objc -c -fpic dynclass.m

dynclass.so : dynclass.o
	objc -dl dynclass.o -o dynclass.so

dlopen : dynclass.so
	objc -dynamic dlopen.m -o dlopen

cleantmp :
	-$(RM) *.P
	-$(RM) *.c
	-$(RM) *.i

clean : cleantmp
	-$(RM) *.o
	-$(RM) $(PROGRAM) a.out
	-$(RM) dlopen dynclass.so

distclean : clean
	-$(RM) Makefile 

