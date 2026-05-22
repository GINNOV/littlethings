all: compile assemble link

compile:
	luxcc -m vm32 -I Development:lib/luxcc/vm_lib/include -o HelloWorld.asm HelloWorld.c
assemble:
	luxasvm -o HelloWorld.o HelloWorld.asm
link:
	luxldvm -o HelloWorld.lux Development:lib/luxcc/obj/vm32/crt0.o Development:lib/luxcc/obj/vm32/libc.o HelloWorld.o
run:
	luxvm HelloWorld.lux
clean:
	delete #?.asm #?.o #?.lux

.PHONY: compile assemble run clean
