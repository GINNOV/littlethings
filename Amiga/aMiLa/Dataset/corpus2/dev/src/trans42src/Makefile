
# created by mkmake. (c)1995 Francesco Devitt
# Wed Feb 08 22:16:31 1995

OBJS = requester.o classes.o util.o globals.o stack.o \
phonemic.o read_pron.o process.o messages.o 

NAME = trans

BUG = define MWDEBUG=1

# Change this for *each* release!

VER = 42
REV = 4
DATE = (15.6.95)

#gencat: gencat.c messages.h
#    sc link gencat.c


# ------ Test -------

#CFLAGS = $(BUG)
#test: $(OBJS) main.o
#    sc link $(OBJS) main.o pname test

LIBNAME = translator.library

all: $(LIBNAME)


trans: trans.o
    sc link trans.o pname trans

# We don't want these compiled with LIBCODE

trans.o: trans.c
    sc trans.c


copyright: copyright.c
    sc link copyright.c pname copyright

_copyright.h: copyright
    copyright $(EXT) $(VER).$(REV) $(DATE) > _copyright.h


# Linking library

$(LIBNAME): $(OBJS) libinit.o
    slink with <<
        
        LIBPREFIX _ 
        LIBFD translator.fd
        
        LIBID "Translator $(VER).$(REV) $(DATE)"
        LIBVERSION $(VER)
        LIBREVISION $(REV)
        
        map "mapfile.map" s
        
        to $(LIBNAME)
        
        FROM lib:libent.o libinit.o $(OBJS)
        LIB lib:sc.lib lib:debug.lib lib:amiga.lib
        
        noicons
    <
    copy $(LIBNAME) libs:
    copy $(LIBNAME) DIST:Libs/$(EXT)_translator.library
    catch flushlib translator.library

usa1: usa_english.o
    sc link usa_english.o

usa2: usa_amiga.o
    sc link usa_amiga.o


# -- made by mkmake --

accents.o: accents.c 
classes.o: classes.c phonemes.h messages.h stack.h 
globals.o: globals.c globals.h phonemes.h messages.h 
copyright.o: copyright.c 
main.o: main.c phonemes.h globals.h 
messages.o: messages.c phonemes.h messages.h 
phonemic.o: phonemic.c phonemes.h messages.h stack.h accents.c 
process.o: process.c DIST:Include/clib/translator_protos.h \
	DIST:Include/pragmas/translator_pragmas.h 
read_pron.o: read_pron.c phonemes.h messages.h 
requester.o: requester.c phonemes.h messages.h _copyright.h
util.o: util.c phonemes.h 
libinit.o: libinit.c globals.h 
stack.o: stack.c stack.h phonemes.h messages.h 
