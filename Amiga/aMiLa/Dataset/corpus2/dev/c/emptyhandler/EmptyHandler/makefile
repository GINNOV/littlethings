OBJ = empty.o misc.o

empty-handler: $(OBJ)
    blink $(OBJ) to empty-handler nd sc sd lib lib:amiga.lib lib:lcr.lib
    copy empty-handler l:

misc.o: misc.c
    lc -v -csmuq -rr -ms $(GO) misc

empty.o: empty.c
    lc -v -csmuq -rr -ms $(GO) empty

