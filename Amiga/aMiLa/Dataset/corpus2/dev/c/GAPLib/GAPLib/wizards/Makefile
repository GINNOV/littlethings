#
# Wizard makefile, automagically builds magical programs. :-)
#

DATA= data/report_c.c data/report_h.c data/bm_c.c data/bs_c.c data/bv_c.c \
	data/sk_c.c data/mk.c

OBJS= Conjurer.o

CC= gcc

CFLAGS= -O2 -Wall

all: Conjurer

clean:
	-rm b2c Conjurer.o $(DATA)

data: $(DATA)

Conjurer: $(OBJS)
	$(CC) -s Conjurer.o -o ../bin/Conjurer
	@-chmod 755 ../bin/Conjurer

Conjurer.o: Conjurer.c $(DATA)
	$(CC) -c $(CFLAGS) Conjurer.c -o Conjurer.o

data/report_c.c: Templates/report.c b2c
	b2c <Templates/report.c >data/report_c.c report_c

data/report_h.c: Templates/report.h b2c
	b2c <Templates/report.h >data/report_h.c report_h

data/bm_c.c: Templates/BitMatrix.c b2c
	b2c <Templates/BitMatrix.c >data/bm_c.c Bitmatrix_c

data/bs_c.c: Templates/Bitstring.c b2c
	b2c <Templates/Bitstring.c >data/bs_c.c Bitstring_c

data/bv_c.c: Templates/BoundedRealVector.c b2c
	b2c <Templates/BoundedRealVector.c >data/bv_c.c BRVector_c

data/sk_c.c: Templates/Skeleton.c b2c
	b2c <Templates/Skeleton.c >data/sk_c.c Skeleton_c

data/mk.c: Templates/Makefile b2c
	b2c <Templates/Makefile >data/mk.c mk

b2c: b2c.c
	$(CC) $(CFLAGS) b2c.c -o b2c
	-chmod 755 b2c
