# OS4 GCC PPC makefile for DiskMaster2 V1.9 R.Riedel 2007-01-31

# /GCC/bin for GeekGadgets
BIN = d:\crosscompiler\bin

# the compiler
CC = $(BIN)/ppc-amigaos-gcc
#CC = gcc

# options
#CFLAGS = -D__USE_INLINE__ -mstrict-align -Os -W -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
#CFLAGS = -D__USE_INLINE__ -Os -W -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
#CFLAGS = -D__USE_INLINE__ -g -msoft-float -Os -W -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
#CFLAGS = -D__USE_INLINE__ -D__USE_BASETYPE__ -msoft-float -Os -W -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
#CFLAGS = -D__USE_INLINE__ -msoft-float -Os -W -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
# -funsigned-char
# -Wno-pointer-sign
# -msdata <- reduces reloc-data but might be a problem with hooks
# -D__USE_OLD_TIMEVAL__
# -Wwrite-strings <- gives warnings about writing to constants but also lots of useless warnings...
#CFLAGS = -mcrt=clib2 -g -ggdb -D__USE_INLINE__ -Wno-pointer-sign -Os -Wextra -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration
CFLAGS = -mcrt=clib2 -gstabs -D__USE_INLINE__ -Wno-pointer-sign -Os -Wextra -Wall -Wstrict-prototypes -Wshadow -Werror-implicit-function-declaration


# compile command
COMPILE = $(CC) $(CFLAGS) -c

# linker command
LD = $(CC)
#vlink = $(CC)

# linker flags
#LDFLAGS = -s -msoft-float -mstrict-align -Wl,--cref,-M,-Map=dm2_ppc.map
#LDFLAGS = -s -msoft-float -mstrict-align -Wl,--cref,-M,-Map=dm2_ppc.map -Wl,-Ttext=0x00
#LDFLAGS = -msoft-float -mstrict-align -Wl,--cref,-M,-Map=dm2_ppc.map -Wl,-Ttext=0x00
#LDFLAGS = -s -msoft-float -Wl,--cref,-M,-Map=dm2_ppc.map -Wl,-Ttext=0x00
#LDFLAGS = -msoft-float -Wl,--cref,-M,-Map=dm2_ppc.map -Wl,-Ttext=0x00
LDFLAGS = -mcrt=clib2 -g -ggdb -Wl,--cref,-M,-Map=dm2_ppc.map -Wl,-Ttext=0x00
#LDFLAGS =

# linker libs
LIBS = -lamiga # additional libs, for example -ldebug if you use KPrintF()

# name of binary
PROGRAM = DiskMaster2.OS4

# path to the object-files
OBP = obj_os4

# object files
OBJS = $(OBP)/DMLocale.o $(OBP)/DMPalette.o $(OBP)/DMConfig.o $(OBP)/DMKey.o $(OBP)/DMPreferences.o $(OBP)/DMRequester.o $(OBP)/DMSort.o $(OBP)/DMDisk.o $(OBP)/DMCommands.o $(OBP)/DMParser.o $(OBP)/DMSupport.o $(OBP)/DMWinContent.o $(OBP)/DMWindows.o $(OBP)/DMScreen.o $(OBP)/DMRexx.o $(OBP)/DMMenus.o $(OBP)/DMPack.o $(OBP)/DM.o $(OBP)/DMRead.o

$(PROGRAM) : $(OBJS)
#	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $(PROGRAM)
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@.debug
	@stripreloc $@.debug $@.debug
	ppc-amigaos-strip -R.comment -o $@ $@.debug

$(OBP)/DMLocale.o : DMLocale.c DM.h DMLocale.h
	$(COMPILE) DMLocale.c -o $(OBP)/DMLocale.o

$(OBP)/DMPalette.o : DMPalette.c DM.h DMLocale.h
	$(COMPILE) DMPalette.c -o $(OBP)/DMPalette.o

$(OBP)/DMConfig.o : DMConfig.c DM.h DMLocale.h
	$(COMPILE) DMConfig.c -o $(OBP)/DMConfig.o

$(OBP)/DMKey.o : DMkey.c DM.h DMLocale.h
	$(COMPILE) DMKey.c -o $(OBP)/DMkey.o

$(OBP)/DMPreferences.o : DMPreferences.c DM.h DMLocale.h
	$(COMPILE) DMPreferences.c -o $(OBP)/DMPreferences.o

$(OBP)/DMRequester.o : DMRequester.c DM.h DMLocale.h
	$(COMPILE) DMRequester.c -o $(OBP)/DMRequester.o

$(OBP)/DMSort.o : DMSort.c DM.h DMLocale.h
	$(COMPILE) DMSort.c -o $(OBP)/DMSort.o

$(OBP)/DMDisk.o : DMDisk.c DM.h DMLocale.h
	$(COMPILE) DMDisk.c -o $(OBP)/DMDisk.o

$(OBP)/DMCommands.o : DMCommands.c DM.h DMLocale.h
	$(COMPILE) DMCommands.c -o $(OBP)/DMCommands.o

$(OBP)/DMParser.o : DMParser.c DM.h DMLocale.h
	$(COMPILE) DMParser.c -o $(OBP)/DMParser.o

$(OBP)/DMSupport.o : DMSupport.c DM.h DMLocale.h
	$(COMPILE) DMSupport.c -o $(OBP)/DMSupport.o

$(OBP)/DMWinContent.o : DMWinContent.c DM.h DMLocale.h
	$(COMPILE) DMWinContent.c -o $(OBP)/DMWinContent.o

$(OBP)/DMWindows.o : DMWindows.c DM.h DMLocale.h
	$(COMPILE) DMWindows.c -o $(OBP)/DMWindows.o

$(OBP)/DMScreen.o : DMScreen.c DM.h DMLocale.h
	$(COMPILE) DMScreen.c -o $(OBP)/DMScreen.o

$(OBP)/DMRexx.o : DMRexx.c DM.h DMLocale.h
	$(COMPILE) DMRexx.c -o $(OBP)/DMRexx.o

$(OBP)/DMMenus.o : DMMenus.c DM.h DMLocale.h
	$(COMPILE) DMMenus.c -o $(OBP)/DMMenus.o

$(OBP)/DMPack.o : DMPack.c DM.h DMLocale.h
	$(COMPILE) DMPack.c -o $(OBP)/DMPack.o

$(OBP)/DM.o : DM.c DM.h DMLocale.h
	$(COMPILE) DM.c -o $(OBP)/DM.o

$(OBP)/DMRead.o : DMRead.c DM.h DMLocale.h
	$(COMPILE) DMRead.c -o $(OBP)/DMRead.o
