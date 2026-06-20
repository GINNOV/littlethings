# Modified for AROS by Pasquale Frega
# In any other makefile below this i have replaced gcc with i386-aros-gcc

all: luxcc luxvm

luxcc:
	make -C src
luxvm:
	make -C src/luxvm

# After compiled everything start AROS, be sure to have make installed, go to
# src/lib/vm_lib and compile; install only after virtual machine libraries are
# compiled on AROS

install:
	cp src/luxcc ../../bin/
	cp src/luxvm/luxvm src/luxvm/luxasvm src/luxvm/luxldvm ../../bin/
	mkdir -p ../../lib/luxcc
	cp -r src/lib/obj/ ../../lib/luxcc/
	mkdir -p ../../lib/luxcc/vm_lib
	cp -r src/lib/vm_lib/include/ ../../lib/luxcc/vm_lib/

uninstall:
	rm -f ../../bin/luxcc
	rm -f ../../bin/luxvm ../../bin/luxasvm ../../bin/luxldvm
	rm -rf ../../lib/luxcc

clean:
	make -C src        clean
	make -C src/luxvm  clean
	make -C src/util   clean

.PHONY: all luxcc luxvm install uninstall clean
