#	@(#)Makefile	8.1 (Berkeley) 6/9/93

PROG=	xstr

xstr : xstr.o
	objc -q xstr.o -o xstr

xstr.o : xstr.m
	objc -q -c xstr.m

clean ::
	-rm strings *.[%ciP]
	-rm *.o xstr

# .include <bsd.prog.mk>
