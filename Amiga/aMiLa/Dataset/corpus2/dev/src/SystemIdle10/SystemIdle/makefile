compileargs = -fbaserel -noixemul -x none -s -m68000
objects = test.o idle.o

test : test.o idle.o
	gcc -o test $(compileargs) $(objects)

test.o : test.c
	gcc -c $(compileargs) test.c

idle.o : idle.c
	gcc -c $(compileargs) idle.c

clean :
	rm $(objects)
