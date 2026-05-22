include setup.project
include setup.$(PLATFORM)

TARGET=	libsge.a

CFLAGS=-O2 -Wall -Werror -Wpointer-arith -Wmissing-declarations -Wstrict-prototypes -Wmissing-prototypes -Wcast-align -Wshadow -I$(PWD)/include $(SDLCFLAGS) $(DEFINES)

OBJ=	src/sgeinit.o \
	src/sgescreen.o \
	src/sgesound.o \
	src/sgecontrol.o \
	src/sgeresource.o \
	src/sgeevent.o \
	src/sgelist.o \
	src/sgearray.o \
	src/sgespriteimage.o \
	src/sgesprite.o \
	src/sgestage.o \
	src/sgegfx.o \
	src/sgespritegroup.o \
	src/sgegamestate.o \
	src/sgefont.o \
	src/sgepathfinder.o \
	src/sgeparticles.o \
	src/sgemisc.o

.c.o:
	$(CC) -o $@ $(CFLAGS) -c $<

all:$(OBJ)
	$(AR) -rs $(TARGET) $(OBJ)
	$(MAKE) sgetools

test: all
	cd libtest && $(MAKE)
	cd libtest && ./libtest

sgetools:
	cd tools && $(MAKE)

tags:
	ctags src/*.c include/*.h

clean:
	cd demos && $(MAKE) clean
	cd tools && $(MAKE) clean
	cd libtest && $(MAKE) clean
	rm -f $(OBJ)
	rm -f $(TARGET)

demos: examples
examples: all
	cd demos && $(MAKE)

distclean: clean
	rm -f setup.project
