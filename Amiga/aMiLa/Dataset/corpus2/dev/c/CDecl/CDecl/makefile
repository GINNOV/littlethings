cdecl.o: cdecl.c
	cc +p -DAMIGA -DNOGETOPT -DNOVARARGS cdecl.c
cdecl: cdecl.o
	ln cdecl.o -lcl32
cdeclsym: cdecl.c
	cc -n +p -DAMIGA -DNOGETOPT -DNOVARARGS cdecl.c
	ln -g cdecl.o -lcl32
