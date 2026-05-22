CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O0 -mcrt=clib2 -std=c99 -Wall

SRC = $(wildcard *.c)
OBJS = $(SRC:.c=.o)

default: $(OBJS) sample

sample:  $(OBJS)
	@$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f $(OBJS) sample

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: default clean
