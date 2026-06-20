# Before running "make -f makefile" be sure to set _pchar to "|" and _mchar to "&&"

CC=//luxcc
VM32AS=//luxvm/luxasvm -vm32
VM64AS=//luxvm/luxasvm -vm64
LIBC_SRC_FILES=libc.c ctype.c errno.c stdio.c stdlib.c string.c

all: crt0 libc

#
# LuxVM stuff.
#

crt0: /obj/vm32/crt0.o /obj/vm64/crt0.o

/obj/vm32/crt0.o: crt0_32.s
	$(VM32AS) crt0_32.s -o /obj/vm32/crt0.o

/obj/vm64/crt0.o: crt0_64.s
	$(VM64AS) crt0_64.s -o /obj/vm64/crt0.o

libc: /obj/vm32/libc.o /obj/vm64/libc.o

/obj/vm32/libc.o: $(LIBC_SRC_FILES)
	$(CC) -q -mvm32 libc.c -o libc.s && $(VM32AS) libc.s -o /obj/vm32/libc.o && delete libc.s

/obj/vm64/libc.o: $(LIBC_SRC_FILES)
	$(CC) -q -mvm64 libc.c -o libc.s && $(VM64AS) libc.s -o /obj/vm64/libc.o && delete libc.s

clean:
	delete /obj/vm32/#?.o force
	delete /obj/vm64/#?.o force

.PHONY: all clean crt0 libc
