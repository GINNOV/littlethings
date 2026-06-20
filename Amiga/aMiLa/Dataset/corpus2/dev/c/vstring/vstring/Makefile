CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O0 -mcrt=clib2 -std=c99 -Wall
LDFLAGS = -mcrt=clib2

.PHONY: clean install

test: test.c
	${CC} ${CFLAGS} $< -o $@ -O0 -ggdb3 -lm

install:
	install -m 0644 ${DESTDIR}/usr/local/include

clean:
	rm -f test
