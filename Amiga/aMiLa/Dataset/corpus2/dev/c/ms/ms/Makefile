CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O0 -DUSE_VSTRING -mcrt=clib2 -std=c99 -Wall -Wextra
SRC = ms.c
DEPS = strtoll.c
OBJS = ms.o $(DEPS:.c=.o)

check: test
#	@./test

test: test.o $(OBJS)
	$(CC) $^ -o $@ $(CFLAGS)

%.o: %.c
	$(CC) $< -c -o $@ $(CFLAGS)

clean:
	rm -f $(OBJS) test.o test

.PHONY: check clean
