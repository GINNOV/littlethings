getopt_long.a: getopt_long.c
	$(CC)  -O2 -Wall -c        $? -o $@
	$(CXX) -O2 -Wall -c -x c++ $? -o $@xx

test: getopt_long.c
	$(CC) -O2 $? -DTEST

getopt_long: getopt_long.c
	sc DEF TEST LINK getopt_long.c
	delete getopt_long.lnk


install: getopt_long.axx getopt_long.a
	copy getopt.h GG:include/ CLONE
	ar r GG:ppc-morphos/lib/libgetopt_long.a getopt_long.axx getopt_long.a

dist: getopt_long.a getopt_long
	lha -r u RAM:getopt_long // getopt_long
