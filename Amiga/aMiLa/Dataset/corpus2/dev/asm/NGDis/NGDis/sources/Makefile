#
# (c) 2001 Jouni 'Mr.Spiv' Korhonen / Dead Coders Society
#
#

.PHONY: clean all dep dist
.SUFFIXES:
.SUFFIXES: .c .o .h
.DEFAULT:
	make all
#

SRCS = tlcs900helper.c                  tlcs900statics.c	\
       tlcs900_b0_mem.c                 tlcs900_fixed.c		\
       tlcs900_xx.c                     tlcs900_zz_r.c		\
       tlcs900_zz_rr.c			tlcs900_zz_mem.c	\
       main.c				tlcs900_disasm.c	\
       disasm.c

HDRS = tlcs900d.h disasm.h

OBJS = tlcs900helper.o                  tlcs900statics.o	\
       tlcs900_b0_mem.o                 tlcs900_fixed.o		\
       tlcs900_xx.o                     tlcs900_zz_r.o		\
       tlcs900_zz_rr.o			tlcs900_zz_mem.o	\
       main.o				tlcs900_disasm.o	\
       disasm.o

#

PROG = ngd

#
# If you want to (of course you want to :) compile all source
# for Amiga using Amiga specific stuff then just uncomment the
# OS and CPU defines..
#

CC = gcc
RM = rm -f
CP = cp
OS = #AMIGA
CPU = #68020
DEPEND = .dep
WILD = *
FOO = NGDis - a disassembler for TLCS900H and NeoGeo Pocket is ready

LOCAL_CFLAGS = -O -fomit-frame-pointer
LOCAL_LDFLAGS =

#
#
#

ifeq ($(OS),AMIGA)
	LOCAL_CFLAGS += -noixemul
	RM = delete
	WILD = "\#?"

ifeq ($CPU),68020)
	LOCAL_CFLAGS += -mc68020
endif
endif

#
# rules

all: $(DEPEND) $(PROG)
	@echo $(FOO)

-include $(DEPEND)

$(DEPEND): Makefile
	$(CC) -MM $(SRCS) > $(DEPEND)
	@echo "Dependencies done"

%.o: %.c
	$(CC) $(LOCAL_CFLAGS) -c $< -o $@

$(PROG): $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LOCAL_LDFLAGS) $(LOCAL_LIBDIR) $(LOCAL_LIBS)


clean:
	-$(RM) $(WILD).o
	-$(RM) $(WILD)~
	-$(RM) $(PROG).tgz
	-$(RM) $(DEPEND)
	-$(RM) $(PROG)

dist:
	tar zcvf $(PROG).tgz *.c *.h Makefile readme.txt




