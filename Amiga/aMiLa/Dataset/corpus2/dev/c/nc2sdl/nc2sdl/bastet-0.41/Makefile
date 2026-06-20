#makefile for bastet (c) 2004 Federico Poloni
#modified for SDL/pdcurses in 2012 by Lorence Lombardo

#default paths
BIN_PREFIX=PROGDIR:
DATA_PREFIX=PROGDIR:
HISCORE=bastet.scores

#in order to handle highscores properly, bastet must be setuid.
#games is a standard group, change it to something else if you
#have a non-standard system
GAME_USER=games

CC=gcc -m68020 -m68881
CFLAGS=-Wall -DHIGHSCORE_FILE=\"$(DATA_PREFIX)$(HISCORE)\"
LDFLAGS=-lpdcurses $(shell sdl-config --libs) -lm
SOURCES=main.c game.c highscore.c bast.c
EXNAME=bastet

all: $(EXNAME)

$(EXNAME) : $(SOURCES:.c=.o)
	$(CC) -o $(EXNAME) $(SOURCES:.c=.o) $(LDFLAGS)

%.d: %.c
	set -e; $(CC) -MM $(CFLAGS) $< \
| sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
[ -s $@ ] || rm -f $@

include $(SOURCES:.c=.d)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(SOURCES:.c=.o) $(EXNAME)

mrproper: clean
	rm -f $(SOURCES:.c=.d) *~

install: $(EXNAME)
	cp $(EXNAME) $(BIN_PREFIX)
	chown $(GAME_USER) $(BIN_PREFIX)$(EXNAME)
	chmod u+s $(BIN_PREFIX)$(EXNAME)
	touch $(DATA_PREFIX)$(HISCORE)
	chown $(GAME_USER) $(DATA_PREFIX)$(HISCORE)
	chmod 644 $(DATA_PREFIX)$(HISCORE)
