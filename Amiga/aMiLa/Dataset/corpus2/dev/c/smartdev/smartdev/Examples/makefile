#------------------------------------------------------------------------------

CC			= gcc
STRIP		= strip
CHMOD		= chmod
CP			= cp
RM			= rm
CFLAGS	= -I../Developer/C/include -O2 -Wall -noixemul
LFLAGS	= -lm -labox -noixemul -nostartfiles
CDEFS		= \
	-D__AMIGADATE__=\"$(shell date "+%d.%m.%y")\"\
	-D__YEAR__=\"$(shell date "+%Y")\"

#------------------------------------------------------------------------------

PRG = HDTemp

#------------------------------------------------------------------------------

all: $(PRG)

$(PRG): main.o
	$(CC) main.o -o $@.debug $(LFLAGS)
	$(STRIP) --strip-all --strip-unneeded --remove-section .comment $@.debug -o $@
	$(CHMOD) +x $(PRG)

.c.o:
	$(CC) $(CDEFS) $(CFLAGS) -c $< -o $@

#------------------------------------------------------------------------------

clean:
	$(RM) -f $(PRG) *.o *.debug

install:
	$(CP) $(PRG) C:

uninstall:
	$(RM) -f C:$(PRG)

#------------------------------------------------------------------------------

