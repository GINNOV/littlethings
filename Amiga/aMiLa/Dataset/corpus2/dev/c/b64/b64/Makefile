CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -O0 -mcrt=clib2 -DBUILD -std=c99 -Wall
LDFLAGS = -mcrt=clib2
TEST_CFLAGS = -Ideps
CUSTOM_MALLOC_FLAGS = -Db64_malloc=custom_malloc -Db64_realloc=custom_realloc

ifeq ($(USE_CUSTOM_MALLOC), true)
CFLAGS += $(CUSTOM_MALLOC_FLAGS)
endif

default: test base64
#	./$<

test: CFLAGS+=$(TEST_CFLAGS)
test: test.o encode.o decode.o

base64: base64.o encode.o decode.o

clean:
	rm -f *.o test base64

.PHONY: default clean
