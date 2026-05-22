FLAGS = -mcrt=newlib -O2 -Wall $(shell sdl-config --cflags) -Iinclude -I/usr/include/SDL -DVISTK_USE_SDL
GFXLIBS = $(shell sdl-config --libs)

#FLAGS = -O2 -Wall -Iinclude -DVISTK_USE_GGI
#GFXLIB = -lggi

CC = gcc

all:			libs/sgfx.o libs/vistk.o libs/visualize.o libs/visplot.o tests fixme.txt

tests:			tests/test tests/gfxtest

clean:
			-rm -f *.o
			-rm -f libs/*
			-rm -f tests/*
			-rm -f fixme.txt

sgfx.c:			include/sgfx.h

libs/sgfx.o:		sgfx.c
			$(CC) ${FLAGS} -c sgfx.c -o libs/sgfx.o

tests/gfxtest:		gfxtest.c include/sgfx.h libs/sgfx.o include/visualize.h libs/visualize.o
			$(CC) ${FLAGS} -o tests/gfxtest gfxtest.c libs/sgfx.o libs/visualize.o ${GFXLIBS}


libs/visualize.o:	visualize.c include/visualize.h include/sgfx.h
			$(CC) ${FLAGS} -c visualize.c -o libs/visualize.o


libs/visplot.o:		visplot.c include/visplot.h include/visualize.h include/sgfx.h
			$(CC) ${FLAGS} -c visplot.c -o libs/visplot.o


vistkprims.c:		include/vtkprims.h include/visualize.h include/sgfx.h

vtkprims.o:		vtkprims.c include/vtkprims.h
			$(CC) ${FLAGS} -c vtkprims.c -o vtkprims.o

vistk.c:		include/vistk.h include/vtkprims.h include/sgfx.h include/visualize.h

libs/vistk.o:		vistk.c include/vistk.h include/vtkprims.h vtkprims.o
			$(CC) ${FLAGS} -c vistk.c -o vistk_tmp.o
			ld -Ur -static -o libs/vistk.o vistk_tmp.o vtkprims.o
			-rm -f vistk_tmp.o

tests/test:		test.c libs/vistk.o libs/sgfx.o libs/visualize.o
		        $(CC) ${FLAGS} -o tests/test test.c libs/vistk.o libs/visualize.o \
				    libs/sgfx.o ${GFXLIBS}


fixme.txt:		*.c include/*.h
			-grep -n FIXME *.[ch] > fixme.txt

fixme:			fixme.txt
			less fixme.txt
