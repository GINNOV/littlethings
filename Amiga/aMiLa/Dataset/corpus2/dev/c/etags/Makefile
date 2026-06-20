CFLAGS= -g

etags: etags.c
	$(CC) -o etags ${CFLAGS} -DETAGS etags.c

ctags: etags.c
	$(CC) -o ctags ${CFLAGS} -DCTAGS etags.c
