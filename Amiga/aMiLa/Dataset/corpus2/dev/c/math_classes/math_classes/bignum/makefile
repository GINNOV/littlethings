
CC = /bin/g++
# COPTS = -m68020 -m68881 -O


bignumtest: bignum.o bignumtest.o
	$(CC) $(COPTS) bignum.o bignumtest.o -lm -o bignumtest

bignumtest.o: bignumtest.cc bignum.h
	$(CC) $(COPTS) -c bignumtest.cc

bignum.o: bignum.cc bignum.h
	$(CC) $(COPTS) -c bignum.cc


