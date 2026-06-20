CC=gcc
CFLAGS=-DUSE_TINYGL -O2
LFLAGS=-noixemul
LIBS=-lTinyGL -lamiga -lm

.c.o:
	$(CC) $(CFLAGS) -c $<

all: basicframework benchmark lesson3 lesson4 lesson5

basicframework: basicframework.o
	$(CC) $(LFLAGS) -o basicframework basicframework.o $(LIBS)

benchmark: benchmark.o
	$(CC) $(LFLAGS) -o benchmark benchmark.o $(LIBS)

lesson3: lesson3.o
	$(CC) $(LFLAGS) -o lesson3 lesson3.o $(LIBS)

lesson4: lesson4.o
	$(CC) $(LFLAGS) -o lesson4 lesson4.o $(LIBS)

lesson5: lesson5.o
	$(CC) $(LFLAGS) -o lesson5 lesson5.o $(LIBS)
	
clean:
	rm -f *.o basicframework benchmark lesson3 lesson4 lesson5
