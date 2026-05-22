CC = ppc-morphos-gcc-4.4.5 -noixemul
CFLAGS = -Wall -O2 -cstd=c99 -Iusr:local/include
LDFLAGS = -lallegro -L../Release

SRCS = $(wildcard *.c)
BINS = $(patsubst %.c,%,$(SRCS))
OBJS = $(patsubst %.c,%.o,$(SRCS))

all: $(BINS)

%: %.c
	@echo Compiling $<...
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	@rm $(BINS)