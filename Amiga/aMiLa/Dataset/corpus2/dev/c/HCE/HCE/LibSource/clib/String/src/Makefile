#
# Makefile for string library routines created 15May89 by Jeff Lydiatt.
#

COBJ= atol.o bsearch.o ctlcnv.o lmemmove.o ltoa.o memccpy.o memchr.o \
      memcmp.o memicmp.o splitpat.o stradj.o strcat.o strcmp.o strcspn.o \
      strdup.o stricmp.o strirpl.o stristr.o strlen.o strlwr.o strncat.o \
      strncmp.o strncpy.o strnicmp.o strpbrk.o strpcpy.o strpos.o strrev.o \
      strrpbrk.o strrpl.o strrpos.o strset.o strspn.o strstr.o strtok.o \
      strtol.o strtrim.o strupr.o substr.o swab.o

CSRC= atol.c bsearch.c ctlcnv.c lmemmove.c ltoa.c memccpy.c memchr.c \
      memcmp.c memicmp.c splitpat.c stradj.c strcat.c strcmp.c strcspn.c \
      strdup.c stricmp.c strirpl.c stristr.c strlen.c strlwr.c strncat.c \
      strncmp.c strncpy.c strnicmp.c strpbrk.c strpcpy.c strpos.c strrev.c \
      strrpbrk.c strrpl.c strrpos.c strset.c strspn.c strstr.c strtok.c \
      strtol.c strtrim.c strupr.c substr.c swab.c

ASRC= bzero.a lmemcpy.a memcpy.a memmove.a memset.a strchr.a strcpy.a strrchr.a         

AOBJ= bzero.o lmemcpy.o memcpy.o memmove.o memset.o strchr.o strcpy.o strrchr.o         

.SUFFIXES:	.c .o .a

.c.o:
	cc -c -d -O $*.c

.a.o:
	a68k -d $*.a

AString.obj:	$(AOBJ) $(COBJ)
	join *.o as String.obj

clean:
	delete *.o
