CC=i386-aros-gcc
CFLAGS=-c -g -Wall -Wextra -Wconversion

# For 32-bit systems
#
VMOBJ = vm32.o

# For 64-bit systems
#
#VMOBJ = vm64.o

all: luxvm luxasvm luxldvm

luxvm: $(VMOBJ) ../util/util.o operations.o
	$(CC) -o luxvm $(VMOBJ) ../util/util.o operations.o

luxasvm: as.o ../util/util.o operations.o
	$(CC) -o luxasvm as.o ../util/util.o operations.o

luxldvm: ld.o ../util/arena.o ../util/util.o
	$(CC) -o luxldvm ld.o ../util/arena.o ../util/util.o

../util/arena.o:
	make -C ../util arena.o

../util/util.o:
	make -C ../util util.o

.c.o:
	$(CC) $(CFLAGS) $*.c

clean:
	rm -f *.o luxvm luxasvm luxldvm

$(VMOBJ): vm.h as.h operations.h
as.o: as.h vm.h ../util/util.h operations.h
ld.o: as.h ../util/arena.h ../util/util.h
operations.o: operations.h ../util/util.h vm.h

.PHONY: all clean
