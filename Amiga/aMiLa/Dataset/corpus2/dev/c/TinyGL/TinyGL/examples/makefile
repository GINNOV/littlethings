CC=gcc
CFLAGS=#-O2 -fomit-frame-pointer -m68020

all: gears lesson3 triangle texobj
 
gears: gears.o
	$(CC) $(LFLAGS) -o $@ $< -lTinyGL -lamiga -lm
	
lesson3: lesson3.o
	$(CC) $(LFLAGS) -o $@ $< -lTinyGL -lamiga -lm

triangle: triangle.o
	$(CC) $(LFLAGS) -o $@ $< -lTinyGL -lamiga -lm

texobj: texobj.o
	$(CC) $(LFLAGS) -o $@ $< -lTinyGL -lamiga -lm

gears.o: gears.c
	$(CC) $(CFLAGS) -c $<

lesson3.o: lesson3.c
	$(CC) $(CFLAGS) -c $<

triangle.o: triangle.c
	$(CC) $(CFLAGS) -c $<

texobj.o: texobj.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm *.o
