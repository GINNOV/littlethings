FLASH=../Lib
CPPFLAGS=-I$(FLASH)
LIBS = $(FLASH)/libflash.o -L/usr/X11R6/lib -lX11 -lXext

swfplayer: main.o $(FLASH)/libflash.o
	$(CXX) -o $@ main.o $(LIBS)
