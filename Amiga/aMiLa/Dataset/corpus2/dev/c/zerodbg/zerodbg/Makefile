CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O0 -mcrt=clib2 -std=c99 -Wall

example: example.c debug.c
	$(CC) $(CFLAGS) $^ -o $@

.PHONY: test example
