CC		= /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O0 -I.. -mcrt=clib2 -Wall -Wextra -pedantic

all: compare satisfies intuicompare

.PHONY: compare satisfies
compare: compare.c ../semver.c
	$(CC) $(CFLAGS) -o $@ compare.c ../semver.c

satisfies: satisfies.c ../semver.c
	$(CC) $(CFLAGS) -o $@ satisfies.c ../semver.c

intuicompare: intuicompare.c ../semver.c
	$(CC) $(CFLAGS) -o $@ intuicompare.c ../semver.c

clean:
	rm -f compare satisfies intuicompare ../semver.o *.o
