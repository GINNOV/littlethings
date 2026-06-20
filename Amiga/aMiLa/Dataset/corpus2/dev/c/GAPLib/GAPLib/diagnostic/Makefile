#
# Diagnostics makefile
#

CC= gcc
CFLAGS= -O -Wall -I../include -L../lib -lgap -lm
EXECS= CrossoverTest FlipTestTest GaussRandTest TagListTest

test: $(EXECS)
	-@CrossoverTest
	-@FlipTestTest
	-@GaussRandTest
	-@TagListTest

clean:
	-rm -rf *.o $(EXECS)

CrossoverTest: CrossoverTest.c
	$(CC) CrossoverTest.c -o CrossoverTest $(CFLAGS)

FlipTestTest: FlipTestTest.c
	$(CC) FlipTestTest.c -o FlipTestTest $(CFLAGS)

GaussRandTest: GaussRandTest.c
	$(CC) GaussRandTest.c -o GaussRandTest $(CFLAGS)

TagListTest: TagListTest.c
	$(CC) TagListTest.c -o TagListTest $(CFLAGS)
