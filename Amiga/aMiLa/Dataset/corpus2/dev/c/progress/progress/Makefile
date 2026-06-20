CC     = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -std=c99 -I. -mcrt=clib2 -Wall

all: clean test
	@:

test: $(SRC)
	$(CC) $^ -s progress.c test.c $(CFLAGS) -o test-progress -lm

clean:
	rm -f test-progress

.PHONY: clean test
